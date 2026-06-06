-- Migration 012: Add 'rejected' (no aprobada) status
-- Run this in Supabase SQL Editor

-- 1. Add 'rejected' to the status CHECK constraint
ALTER TABLE convocatorias DROP CONSTRAINT IF EXISTS convocatorias_status_check;
ALTER TABLE convocatorias ADD CONSTRAINT convocatorias_status_check
  CHECK (status IN ('active', 'permanent', 'expired', 'draft', 'pending', 'rejected'));

-- 2. Update get_admin_stats to also count rejected
CREATE OR REPLACE FUNCTION get_admin_stats()
RETURNS JSON AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_build_object(
    'user_count', (SELECT COUNT(*) FROM profiles),
    'admin_count', (SELECT COUNT(*) FROM profiles WHERE role = 'admin'),
    'active_count', (SELECT COUNT(*) FROM convocatorias WHERE status IN ('active', 'permanent')),
    'total_amount_usd', (SELECT COALESCE(SUM(amount_usd), 0) FROM convocatorias WHERE status IN ('active', 'permanent')),
    'message_count', (SELECT COUNT(*) FROM contact_messages),
    'unread_message_count', (SELECT COUNT(*) FROM contact_messages WHERE read = false),
    'expired_count', (SELECT COUNT(*) FROM convocatorias WHERE status = 'expired'),
    'draft_count', (SELECT COUNT(*) FROM convocatorias WHERE status = 'draft'),
    'rejected_count', (SELECT COUNT(*) FROM convocatorias WHERE status = 'rejected')
  ) INTO result;
  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
