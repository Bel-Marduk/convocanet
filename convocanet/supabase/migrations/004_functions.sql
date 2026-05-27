-- Supabase Edge Function for AI-powered convocatoria scraping
-- This function is called by pg_cron daily

-- Enable pg_cron extension (run once in Supabase SQL Editor)
-- CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Schedule the AI scraper to run daily at 6:00 AM UTC
-- SELECT cron.schedule(
--   'ai-scraper-daily',
--   '0 6 * * *',
--   $$
--     SELECT net.http_post(
--       url := 'https://YOUR_PROJECT.supabase.co/functions/v1/ai-scraper',
--       headers := '{"Authorization": "Bearer YOUR_SERVICE_ROLE_KEY", "Content-Type": "application/json"}'::jsonb,
--       body := '{"source": "cron"}'::jsonb
--     );
--   $$
-- );

-- Function to get dashboard stats
CREATE OR REPLACE FUNCTION get_dashboard_stats()
RETURNS JSON AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_build_object(
    'active_count', (
      SELECT COUNT(*) FROM convocatorias
      WHERE status IN ('active', 'permanent')
    ),
    'total_amount_usd', (
      SELECT COALESCE(SUM(amount_local), 0) FROM convocatorias
      WHERE status IN ('active', 'permanent')
    ),
    'user_count', (
      SELECT COUNT(*) FROM profiles
    ),
    'published_count', (
      SELECT COUNT(*) FROM convocatorias
    ),
    'expired_count', (
      SELECT COUNT(*) FROM convocatorias
      WHERE status = 'expired'
    ),
    'public_count', (
      SELECT COUNT(*) FROM convocatorias
      WHERE is_public = true AND status IN ('active', 'permanent')
    ),
    'private_count', (
      SELECT COUNT(*) FROM convocatorias
      WHERE is_public = false AND status IN ('active', 'permanent')
    )
  ) INTO result;

  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get convocatorias matching user interests
CREATE OR REPLACE FUNCTION get_matching_convocatorias(user_id UUID)
RETURNS SETOF convocatorias AS $$
DECLARE
  user_interests TEXT[];
BEGIN
  SELECT interests INTO user_interests
  FROM profiles
  WHERE id = user_id;

  RETURN QUERY
  SELECT c.*
  FROM convocatorias c
  JOIN categories cat ON c.category_id = cat.id
  WHERE c.status IN ('active', 'permanent')
    AND c.is_public = true
    AND (
      user_interests IS NULL
      OR array_length(user_interests, 1) IS NULL
      OR cat.slug = ANY(user_interests)
    )
  ORDER BY c.deadline ASC NULLS LAST
  LIMIT 20;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to search convocatorias
CREATE OR REPLACE FUNCTION search_convocatorias(
  search_term TEXT DEFAULT NULL,
  category_slug TEXT DEFAULT NULL,
  status_filter TEXT DEFAULT NULL,
  min_amount DECIMAL DEFAULT NULL,
  max_amount DECIMAL DEFAULT NULL,
  page_size INT DEFAULT 20,
  page_offset INT DEFAULT 0
)
RETURNS TABLE (
  id UUID,
  title_es TEXT,
  title_en TEXT,
  description_es TEXT,
  description_en TEXT,
  category_name_es TEXT,
  category_name_en TEXT,
  amount_usd DECIMAL,
  deadline DATE,
  status TEXT,
  total_count BIGINT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    c.id,
    c.title_es,
    c.title_en,
    c.description_es,
    c.description_en,
    cat.name_es,
    cat.name_en,
    c.amount_usd,
    c.deadline,
    c.status,
    COUNT(*) OVER() as total_count
  FROM convocatorias c
  LEFT JOIN categories cat ON c.category_id = cat.id
  WHERE
    c.is_public = true
    AND (status_filter IS NULL OR c.status = status_filter)
    AND (category_slug IS NULL OR cat.slug = category_slug)
    AND (min_amount IS NULL OR c.amount_usd >= min_amount)
    AND (max_amount IS NULL OR c.amount_usd <= max_amount)
    AND (
      search_term IS NULL
      OR c.title_es ILIKE '%' || search_term || '%'
      OR c.title_en ILIKE '%' || search_term || '%'
      OR c.description_es ILIKE '%' || search_term || '%'
      OR c.description_en ILIKE '%' || search_term || '%'
    )
  ORDER BY c.deadline ASC NULLS LAST
  LIMIT page_size
  OFFSET page_offset;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
