-- Migration 010: Scraper fixes + scheduling
-- Run in Supabase SQL Editor after enabling pg_cron extension

-- 1. Add 'pending' to the status CHECK constraint
ALTER TABLE convocatorias DROP CONSTRAINT IF EXISTS convocatorias_status_check;
ALTER TABLE convocatorias ADD CONSTRAINT convocatorias_status_check
  CHECK (status IN ('active', 'permanent', 'expired', 'draft', 'pending'));

-- 2. Unique index on source_url to prevent duplicates at DB level
CREATE UNIQUE INDEX IF NOT EXISTS idx_convocatorias_source_url
  ON convocatorias(source_url)
  WHERE source_url IS NOT NULL AND source_url != '';

-- 3. Enable pg_cron and schedule auto-expiration
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Schedule expire_old_convocatorias() daily at 5:00 AM UTC
-- Uses ON CONFLICT to avoid error if job already exists
SELECT cron.schedule(
  'expire-old-convocatorias',
  '0 5 * * *',
  $$SELECT expire_old_convocatorias()$$
);
