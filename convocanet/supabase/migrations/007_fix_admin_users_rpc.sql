-- ConvocaNet Migration 007: Fix admin users listing
-- The recursive RLS policy on profiles fails because the subquery
-- that checks admin role is itself subject to RLS, causing a loop.
-- Solution: SECURITY DEFINER RPC that bypasses RLS.

CREATE OR REPLACE FUNCTION get_all_users()
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
) AS $$
  SELECT p.id, p.full_name, p.organization, p.phone, p.country,
         p.interests, p.role, p.whatsapp_enabled, p.created_at, p.updated_at
  FROM profiles p
  ORDER BY p.created_at DESC;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION search_users(search_term TEXT)
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
) AS $$
  SELECT p.id, p.full_name, p.organization, p.phone, p.country,
         p.interests, p.role, p.whatsapp_enabled, p.created_at, p.updated_at
  FROM profiles p
  WHERE p.full_name ILIKE '%' || search_term || '%'
     OR p.organization ILIKE '%' || search_term || '%'
  ORDER BY p.created_at DESC;
$$ LANGUAGE plpgsql SECURITY DEFINER;
