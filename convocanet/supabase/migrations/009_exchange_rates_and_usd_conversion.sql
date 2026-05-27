-- ============================================
-- Migration 009: Exchange rates + automatic USD conversion
-- Solves: funding totals were summing mixed currencies blindly
-- ============================================

-- 1. Exchange rates table
CREATE TABLE IF NOT EXISTS exchange_rates (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  currency_code TEXT NOT NULL,
  rate_to_usd DECIMAL(12,6) NOT NULL,
  rate_date DATE NOT NULL DEFAULT CURRENT_DATE,
  source TEXT DEFAULT 'frankfurter.app',
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(currency_code, rate_date)
);

-- No direct access — only via SECURITY DEFINER functions
ALTER TABLE exchange_rates ENABLE ROW LEVEL SECURITY;
CREATE POLICY "No direct access to exchange_rates"
  ON exchange_rates FOR ALL
  USING (false);

-- Index for fast lookups
CREATE INDEX IF NOT EXISTS idx_exchange_rates_lookup
  ON exchange_rates(currency_code, rate_date DESC);


-- 2. Helper: get exchange rate for a currency on a given date
--    Falls back to most recent rate if exact date not found.
--    USD always returns 1.0. Unknown currencies return NULL.
CREATE OR REPLACE FUNCTION get_exchange_rate(p_currency TEXT, p_date DATE DEFAULT CURRENT_DATE)
RETURNS DECIMAL(12,6)
LANGUAGE sql STABLE SECURITY DEFINER
AS $$
  SELECT COALESCE(
    (SELECT rate_to_usd FROM exchange_rates
     WHERE currency_code = p_currency AND rate_date = p_date
     LIMIT 1),
    (SELECT rate_to_usd FROM exchange_rates
     WHERE currency_code = p_currency AND rate_date < p_date
     ORDER BY rate_date DESC LIMIT 1),
    CASE WHEN p_currency = 'USD' THEN 1.0::DECIMAL(12,6) ELSE NULL END
  );
$$;


-- 3. Trigger function: auto-set amount_usd on INSERT/UPDATE
CREATE OR REPLACE FUNCTION set_amount_usd()
RETURNS TRIGGER AS $$
DECLARE
  v_rate DECIMAL(12,6);
BEGIN
  -- If no local amount or currency is USD, amount_usd = amount_local
  IF NEW.amount_local IS NULL OR NEW.currency IS NULL OR NEW.currency = 'USD' THEN
    NEW.amount_usd := NEW.amount_local;
    RETURN NEW;
  END IF;

  v_rate := get_exchange_rate(NEW.currency);

  IF v_rate IS NOT NULL THEN
    NEW.amount_usd := ROUND(NEW.amount_local * v_rate, 2);
  ELSE
    -- No rate available — leave as NULL (stats will skip it)
    NEW.amount_usd := NULL;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- 4. Attach trigger to convocatorias
DROP TRIGGER IF EXISTS trigger_set_amount_usd ON convocatorias;
CREATE TRIGGER trigger_set_amount_usd
  BEFORE INSERT OR UPDATE OF amount_local, currency ON convocatorias
  FOR EACH ROW
  EXECUTE FUNCTION set_amount_usd();


-- 5. Backfill RPC: recalculate amount_usd for all existing rows
CREATE OR REPLACE FUNCTION backfill_amount_usd()
RETURNS INTEGER
LANGUAGE plpgsql SECURITY DEFINER
AS $$
DECLARE
  v_count INTEGER;
BEGIN
  UPDATE convocatorias
  SET amount_local = amount_local  -- no-op that fires the trigger
  WHERE amount_local IS NOT NULL;

  GET DIAGNOSTICS v_count = ROW_COUNT;
  RETURN v_count;
END;
$$;


-- 6. Update get_landing_stats() — sum amount_usd + include rate_date
CREATE OR REPLACE FUNCTION get_landing_stats()
RETURNS JSON
LANGUAGE sql SECURITY DEFINER
AS $$
  SELECT json_build_object(
    'user_count', (
      SELECT COUNT(*) FROM profiles
      WHERE role <> 'admin' AND (organization IS NULL OR TRIM(organization) = '')
    ),
    'org_count', (
      SELECT COUNT(*) FROM profiles
      WHERE role <> 'admin' AND organization IS NOT NULL AND TRIM(organization) <> ''
    ),
    'active_count', (
      SELECT COUNT(*) FROM convocatorias WHERE status IN ('active', 'permanent')
    ),
    'total_amount_usd', (
      SELECT COALESCE(SUM(amount_usd), 0) FROM convocatorias
      WHERE status IN ('active', 'permanent') AND amount_usd IS NOT NULL
    ),
    'published_count', (
      SELECT COUNT(*) FROM convocatorias
    ),
    'rate_date', (
      SELECT MAX(rate_date)::TEXT FROM exchange_rates
    )
  );
$$;


-- 7. Update get_admin_stats() — sum amount_usd + include rate_date
CREATE OR REPLACE FUNCTION get_admin_stats()
RETURNS JSON
LANGUAGE sql SECURITY DEFINER
AS $$
  SELECT json_build_object(
    'user_count', (SELECT COUNT(*) FROM profiles),
    'admin_count', (SELECT COUNT(*) FROM profiles WHERE role = 'admin'),
    'active_count', (SELECT COUNT(*) FROM convocatorias WHERE status IN ('active', 'permanent')),
    'total_amount_usd', (
      SELECT COALESCE(SUM(amount_usd), 0) FROM convocatorias
      WHERE status IN ('active', 'permanent') AND amount_usd IS NOT NULL
    ),
    'message_count', (SELECT COUNT(*) FROM contact_messages),
    'unread_message_count', (SELECT COUNT(*) FROM contact_messages WHERE read = false),
    'expired_count', (SELECT COUNT(*) FROM convocatorias WHERE status = 'expired'),
    'draft_count', (SELECT COUNT(*) FROM convocatorias WHERE status = 'draft'),
    'rate_date', (SELECT MAX(rate_date)::TEXT FROM exchange_rates)
  );
$$;


-- 8. Update get_dashboard_stats() — sum amount_usd + include rate_date
CREATE OR REPLACE FUNCTION get_dashboard_stats()
RETURNS JSON
LANGUAGE sql SECURITY DEFINER
AS $$
  SELECT json_build_object(
    'active_count', (
      SELECT COUNT(*) FROM convocatorias WHERE status IN ('active', 'permanent')
    ),
    'total_amount_usd', (
      SELECT COALESCE(SUM(amount_usd), 0) FROM convocatorias
      WHERE status IN ('active', 'permanent') AND amount_usd IS NOT NULL
    ),
    'user_count', (SELECT COUNT(*) FROM profiles),
    'published_count', (SELECT COUNT(*) FROM convocatorias),
    'expired_count', (SELECT COUNT(*) FROM convocatorias WHERE status = 'expired'),
    'public_count', (
      SELECT COUNT(*) FROM convocatorias
      WHERE is_public = true AND status IN ('active', 'permanent')
    ),
    'private_count', (
      SELECT COUNT(*) FROM convocatorias
      WHERE is_public = false AND status IN ('active', 'permanent')
    ),
    'rate_date', (SELECT MAX(rate_date)::TEXT FROM exchange_rates)
  );
$$;
