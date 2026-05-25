-- ConvocaNet Migration 005: User Viewed Tracking, Countries & Admin Enhancements
-- Run this in Supabase SQL Editor after migrations 001-004

-- ============================================
-- TABLE: user_viewed_convocatorias
-- Tracks which convocatorias a user has marked as "viewed"
-- ============================================
CREATE TABLE IF NOT EXISTS user_viewed_convocatorias (
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  convocatoria_id UUID REFERENCES convocatorias(id) ON DELETE CASCADE,
  viewed_at TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (user_id, convocatoria_id)
);

CREATE INDEX IF NOT EXISTS idx_user_viewed_user ON user_viewed_convocatorias(user_id);

ALTER TABLE user_viewed_convocatorias ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own viewed convocatorias"
  ON user_viewed_convocatorias FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own viewed convocatorias"
  ON user_viewed_convocatorias FOR ALL
  USING (auth.uid() = user_id);

-- ============================================
-- TABLE: countries
-- Reference table for country filtering
-- ============================================
CREATE TABLE IF NOT EXISTS countries (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name_es TEXT NOT NULL,
  name_en TEXT NOT NULL,
  code TEXT UNIQUE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE countries ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Countries are viewable by everyone"
  ON countries FOR SELECT
  USING (true);

-- Seed Latin American countries + major international ones
INSERT INTO countries (name_es, name_en, code) VALUES
  ('Mexico', 'Mexico', 'MX'),
  ('Colombia', 'Colombia', 'CO'),
  ('Argentina', 'Argentina', 'AR'),
  ('Chile', 'Chile', 'CL'),
  ('Peru', 'Peru', 'PE'),
  ('Brasil', 'Brazil', 'BR'),
  ('Ecuador', 'Ecuador', 'EC'),
  ('Guatemala', 'Guatemala', 'GT'),
  ('Cuba', 'Cuba', 'CU'),
  ('Bolivia', 'Bolivia', 'BO'),
  ('Republica Dominicana', 'Dominican Republic', 'DO'),
  ('Honduras', 'Honduras', 'HN'),
  ('Paraguay', 'Paraguay', 'PY'),
  ('El Salvador', 'El Salvador', 'SV'),
  ('Nicaragua', 'Nicaragua', 'NI'),
  ('Costa Rica', 'Costa Rica', 'CR'),
  ('Panama', 'Panama', 'PA'),
  ('Uruguay', 'Uruguay', 'UY'),
  ('Venezuela', 'Venezuela', 'VE'),
  ('Espana', 'Spain', 'ES'),
  ('Estados Unidos', 'United States', 'US'),
  ('Francia', 'France', 'FR'),
  ('Canada', 'Canada', 'CA'),
  ('Alemania', 'Germany', 'DE'),
  ('Reino Unido', 'United Kingdom', 'GB')
ON CONFLICT (code) DO NOTHING;

-- ============================================
-- Missing RLS Policies
-- ============================================

-- Users can insert their own profile (needed for signup flow)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'profiles' AND policyname = 'Users can insert own profile'
  ) THEN
    CREATE POLICY "Users can insert own profile"
      ON profiles FOR INSERT
      WITH CHECK (auth.uid() = id);
  END IF;
END $$;

-- Admins can delete profiles
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'profiles' AND policyname = 'Admins can delete profiles'
  ) THEN
    CREATE POLICY "Admins can delete profiles"
      ON profiles FOR DELETE
      USING (
        EXISTS (
          SELECT 1 FROM profiles
          WHERE id = auth.uid() AND role = 'admin'
        )
      );
  END IF;
END $$;

-- Admins can delete contact messages
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'contact_messages' AND policyname = 'Admins can delete contact messages'
  ) THEN
    CREATE POLICY "Admins can delete contact messages"
      ON contact_messages FOR DELETE
      USING (
        EXISTS (
          SELECT 1 FROM profiles
          WHERE id = auth.uid() AND role = 'admin'
        )
      );
  END IF;
END $$;

-- ============================================
-- FUNCTION: get_admin_stats()
-- Returns comprehensive admin dashboard stats
-- ============================================
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
    'draft_count', (SELECT COUNT(*) FROM convocatorias WHERE status = 'draft')
  ) INTO result;
  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
