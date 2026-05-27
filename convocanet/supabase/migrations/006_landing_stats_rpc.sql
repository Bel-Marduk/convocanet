-- ============================================
-- FUNCTION: get_landing_stats()
-- Public landing page stats: user & org counts, active convocatorias, total funding
-- SECURITY DEFINER bypasses RLS so anonymous visitors can see aggregated stats
-- ============================================
CREATE OR REPLACE FUNCTION get_landing_stats()
RETURNS JSON AS $$
DECLARE
  result JSON;
BEGIN
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
      SELECT COALESCE(SUM(amount_local), 0) FROM convocatorias WHERE status IN ('active', 'permanent')
    ),
    'published_count', (
      SELECT COUNT(*) FROM convocatorias
    )
  ) INTO result;
  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
