-- ConvocaNet Migration 007: Fix admin users listing
-- The recursive RLS policy on profiles fails because the subquery
-- that checks admin role is itself subject to RLS, causing a loop.
-- Solution: SECURITY DEFINER RPC that bypasses RLS.

CREATE OR REPLACE FUNCTION get_all_users()
RETURNS SETOF profiles AS $$
  SELECT * FROM profiles ORDER BY created_at DESC;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Also update the search variant
CREATE OR REPLACE FUNCTION search_users(search_term TEXT)
RETURNS SETOF profiles AS $$
  SELECT * FROM profiles
  WHERE full_name ILIKE '%' || search_term || '%'
     OR organization ILIKE '%' || search_term || '%'
  ORDER BY created_at DESC;
$$ LANGUAGE plpgsql SECURITY DEFINER;
