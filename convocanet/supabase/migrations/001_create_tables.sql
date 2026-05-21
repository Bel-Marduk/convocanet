-- ConvocaNet Database Schema
-- Run this in Supabase SQL Editor

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- TABLE: profiles
-- ============================================
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT NOT NULL,
  organization TEXT,
  phone TEXT,
  country TEXT,
  interests TEXT[] DEFAULT '{}',
  role TEXT DEFAULT 'user' CHECK (role IN ('user', 'admin')),
  whatsapp_enabled BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================
-- TABLE: categories
-- ============================================
CREATE TABLE IF NOT EXISTS categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name_es TEXT NOT NULL,
  name_en TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  icon TEXT,
  color TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================
-- TABLE: convocatorias
-- ============================================
CREATE TABLE IF NOT EXISTS convocatorias (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title_es TEXT NOT NULL,
  title_en TEXT NOT NULL,
  description_es TEXT NOT NULL,
  description_en TEXT NOT NULL,
  requirements_es TEXT,
  requirements_en TEXT,
  category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
  amount_usd DECIMAL(12,2),
  amount_local DECIMAL(12,2),
  currency TEXT DEFAULT 'USD',
  deadline DATE,
  region_es TEXT,
  region_en TEXT,
  source_url TEXT,
  source_name TEXT,
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'permanent', 'expired', 'draft')),
  is_public BOOLEAN DEFAULT true,
  created_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Indexes for convocatorias
CREATE INDEX IF NOT EXISTS idx_convocatorias_status ON convocatorias(status);
CREATE INDEX IF NOT EXISTS idx_convocatorias_category ON convocatorias(category_id);
CREATE INDEX IF NOT EXISTS idx_convocatorias_deadline ON convocatorias(deadline);
CREATE INDEX IF NOT EXISTS idx_convocatorias_created ON convocatorias(created_at DESC);

-- ============================================
-- TABLE: user_favorites
-- ============================================
CREATE TABLE IF NOT EXISTS user_favorites (
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  convocatoria_id UUID REFERENCES convocatorias(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (user_id, convocatoria_id)
);

-- ============================================
-- TABLE: contact_messages
-- ============================================
CREATE TABLE IF NOT EXISTS contact_messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  organization TEXT,
  message TEXT NOT NULL,
  read BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================
-- TABLE: audit_log
-- ============================================
CREATE TABLE IF NOT EXISTS audit_log (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
  action TEXT NOT NULL,
  entity TEXT NOT NULL,
  entity_id UUID,
  details JSONB,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_audit_log_created ON audit_log(created_at DESC);

-- ============================================
-- FUNCTION: Auto-update updated_at
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers
CREATE TRIGGER trigger_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trigger_convocatorias_updated_at
  BEFORE UPDATE ON convocatorias
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ============================================
-- FUNCTION: Auto-create profile on signup
-- ============================================
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO profiles (id, full_name, organization, phone, country, interests)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email),
    NEW.raw_user_meta_data->>'organization',
    NEW.raw_user_meta_data->>'phone',
    NEW.raw_user_meta_data->>'country',
    CASE
      WHEN NEW.raw_user_meta_data->>'interests' IS NOT NULL
      THEN ARRAY(SELECT jsonb_array_elements_text(NEW.raw_user_meta_data->'interests'))
      ELSE '{}'
    END
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- ============================================
-- FUNCTION: Expire old convocatorias
-- ============================================
CREATE OR REPLACE FUNCTION expire_old_convocatorias()
RETURNS void AS $$
BEGIN
  UPDATE convocatorias
  SET status = 'expired'
  WHERE status = 'active'
    AND deadline < CURRENT_DATE;
END;
$$ LANGUAGE plpgsql;
