-- ConvocaNet Migration 007: Fix admin users listing
-- SECURITY DEFINER RPCs that bypass RLS for admin user management

DROP FUNCTION IF EXISTS get_all_users();
DROP FUNCTION IF EXISTS search_users(text);

CREATE FUNCTION get_all_users()
RETURNS TABLE (
  id UUID,
  full_name TEXT,
  organization TEXT,
  phone TEXT,
  country TEXT,
  interests TEXT[],
  role TEXT,
  whatsapp_enabled BOOLEAN,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
AS '
BEGIN
  RETURN QUERY
  SELECT p.id, p.full_name, p.organization, p.phone, p.country,
         p.interests, p.role, p.whatsapp_enabled, p.created_at, p.updated_at
  FROM profiles p
  ORDER BY p.created_at DESC;
END;
';

CREATE FUNCTION search_users(search_term TEXT)
RETURNS TABLE (
  id UUID,
  full_name TEXT,
  organization TEXT,
  phone TEXT,
  country TEXT,
  interests TEXT[],
  role TEXT,
  whatsapp_enabled BOOLEAN,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
AS '
BEGIN
  RETURN QUERY
  SELECT p.id, p.full_name, p.organization, p.phone, p.country,
         p.interests, p.role, p.whatsapp_enabled, p.created_at, p.updated_at
  FROM profiles p
  WHERE p.full_name ILIKE ''%'' || search_term || ''%''
     OR p.organization ILIKE ''%'' || search_term || ''%''
  ORDER BY p.created_at DESC;
END;
';
