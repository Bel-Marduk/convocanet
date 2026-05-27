-- ConvocaNet Migration 008: SECURITY DEFINER RPCs for admin CRUD
-- The convocatorias RLS policies silently block updates (0 rows affected)
-- because the recursive subquery on profiles can fail in edge cases.
-- Solution: SECURITY DEFINER RPCs that bypass RLS entirely.

DROP FUNCTION IF EXISTS admin_update_convocatoria(UUID, JSONB);
DROP FUNCTION IF EXISTS admin_insert_convocatoria(JSONB);
DROP FUNCTION IF EXISTS admin_delete_convocatoria(UUID);

-- Admin: Update convocatoria
CREATE FUNCTION admin_update_convocatoria(p_id UUID, p_data JSONB)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS '
BEGIN
  UPDATE convocatorias
  SET title_es = COALESCE(p_data->>''title_es'', title_es),
      title_en = COALESCE(p_data->>''title_en'', title_en),
      description_es = COALESCE(p_data->>''description_es'', description_es),
      description_en = COALESCE(p_data->>''description_en'', description_en),
      requirements_es = COALESCE(p_data->>''requirements_es'', requirements_es),
      requirements_en = COALESCE(p_data->>''requirements_en'', requirements_en),
      category_id = COALESCE((p_data->>''category_id'')::UUID, category_id),
      amount_local = COALESCE((p_data->>''amount_local'')::NUMERIC, amount_local),
      currency = COALESCE(p_data->>''currency'', currency),
      deadline = COALESCE((p_data->>''deadline'')::DATE, deadline),
      region_es = COALESCE(p_data->>''region_es'', region_es),
      region_en = COALESCE(p_data->>''region_en'', region_en),
      source_url = COALESCE(p_data->>''source_url'', source_url),
      source_name = COALESCE(p_data->>''source_name'', source_name),
      status = COALESCE(p_data->>''status'', status),
      is_public = COALESCE((p_data->>''is_public'')::BOOLEAN, is_public),
      updated_at = NOW()
  WHERE id = p_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION ''Convocatoria % no encontrada'', p_id;
  END IF;
END;
';

-- Admin: Insert convocatoria
CREATE FUNCTION admin_insert_convocatoria(p_data JSONB)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS '
DECLARE
  new_id UUID;
BEGIN
  INSERT INTO convocatorias (
    title_es, title_en, description_es, description_en,
    requirements_es, requirements_en,
    category_id, amount_local, currency,
    deadline, region_es, region_en,
    source_url, source_name,
    status, is_public
  ) VALUES (
    p_data->>''title_es'',
    p_data->>''title_en'',
    p_data->>''description_es'',
    p_data->>''description_en'',
    p_data->>''requirements_es'',
    p_data->>''requirements_en'',
    (p_data->>''category_id'')::UUID,
    (p_data->>''amount_local'')::NUMERIC,
    COALESCE(p_data->>''currency'', ''MXN''),
    (p_data->>''deadline'')::DATE,
    p_data->>''region_es'',
    p_data->>''region_en'',
    p_data->>''source_url'',
    p_data->>''source_name'',
    COALESCE(p_data->>''status'', ''active''),
    COALESCE((p_data->>''is_public'')::BOOLEAN, true)
  ) RETURNING id INTO new_id;

  RETURN new_id;
END;
';

-- Admin: Delete convocatoria
CREATE FUNCTION admin_delete_convocatoria(p_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS '
BEGIN
  DELETE FROM convocatorias WHERE id = p_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION ''Convocatoria % no encontrada'', p_id;
  END IF;
END;
';
