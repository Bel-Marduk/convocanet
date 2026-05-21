-- Seed categories for ConvocaNet

INSERT INTO categories (name_es, name_en, slug, icon, color) VALUES
  ('Educación', 'Education', 'educacion', 'school', '#6366f1'),
  ('Salud', 'Health', 'salud', 'health', '#ec4899'),
  ('Medio Ambiente', 'Environment', 'medioambiente', 'eco', '#10b981'),
  ('Cultura', 'Culture', 'cultura', 'palette', '#f59e0b'),
  ('Desarrollo Social', 'Social Development', 'social', 'people', '#06b6d4'),
  ('Tecnología', 'Technology', 'tecnologia', 'computer', '#8b5cf6'),
  ('Género', 'Gender', 'genero', 'wc', '#ec4899'),
  ('Alimentación', 'Food & Nutrition', 'alimentacion', 'restaurant', '#f97316'),
  ('Transparencia', 'Transparency', 'transparencia', 'balance', '#6366f1'),
  ('Derechos Humanos', 'Human Rights', 'derechos-humanos', 'gavel', '#ef4444')
ON CONFLICT (slug) DO NOTHING;

-- Seed sample convocatorias (for development)
DO $$
DECLARE
  edu_id UUID;
  salud_id UUID;
  amb_id UUID;
  cult_id UUID;
  social_id UUID;
BEGIN
  SELECT id INTO edu_id FROM categories WHERE slug = 'educacion';
  SELECT id INTO salud_id FROM categories WHERE slug = 'salud';
  SELECT id INTO amb_id FROM categories WHERE slug = 'medioambiente';
  SELECT id INTO cult_id FROM categories WHERE slug = 'cultura';
  SELECT id INTO social_id FROM categories WHERE slug = 'social';

  INSERT INTO convocatorias (
    title_es, title_en, description_es, description_en,
    requirements_es, requirements_en,
    category_id, amount_usd, deadline,
    region_es, region_en, status, is_public
  ) VALUES
  (
    'Fondo de Innovación Educativa 2026',
    'Educational Innovation Fund 2026',
    'Programa de financiamiento para proyectos educativos que busquen mejorar la calidad de la educación en comunidades rurales y urbanas marginadas mediante metodologías innovadoras.',
    'Funding program for educational projects seeking to improve education quality in rural and marginalized urban communities through innovative methodologies.',
    'Ser A.C. constituida hace al menos 2 años, contar con RFC vigente, experiencia comprobable en proyectos educativos, presentar plan de trabajo detallado.',
    'A.C. established for at least 2 years, valid tax ID (RFC), verifiable experience in educational projects, detailed work plan.',
    edu_id, 50000, '2026-07-15',
    'Nacional', 'National', 'active', true
  ),
  (
    'Programa de Salud Comunitaria Integral',
    'Comprehensive Community Health Program',
    'Convocatoria dirigida a asociaciones que implementen programas de prevención, atención primaria y promoción de la salud en zonas de alta vulnerabilidad social.',
    'Call for associations implementing prevention, primary care, and health promotion programs in areas of high social vulnerability.',
    'A.C. con experiencia en el sector salud, convenio con instituciones de salud, personal capacitado, cobertura mínima de 500 beneficiarios.',
    'A.C. with health sector experience, agreement with health institutions, trained staff, minimum coverage of 500 beneficiaries.',
    salud_id, 70600, '2026-08-01',
    'Centro y Sur', 'Central & Southern', 'active', true
  ),
  (
    'Beca Verde: Restauración Ecológica',
    'Green Grant: Ecological Restoration',
    'Financiamiento para proyectos de reforestación, restauración de ecosistemas y conservación de biodiversidad liderados por organizaciones de la sociedad civil.',
    'Funding for reforestation, ecosystem restoration, and biodiversity conservation projects led by civil society organizations.',
    'A.C. ambientalista, proyecto en zona prioritaria de conservación, alianza con ejido o comunidad, compromiso de co-financiamiento del 20%.',
    'Environmental A.C., project in a priority conservation area, alliance with ejido or community, 20% co-funding commitment.',
    amb_id, 38200, '2026-06-30',
    'Sureste', 'Southeast', 'active', true
  ),
  (
    'Impulso Cultural: Arte y Comunidad',
    'Cultural Boost: Art & Community',
    'Apoyo económico para proyectos artísticos y culturales que promuevan la identidad local, la inclusión social y el acceso democrático a la cultura.',
    'Financial support for artistic and cultural projects that promote local identity, social inclusion, and democratic access to culture.',
    'A.C. cultural, mínimo 3 años de actividad continua, sede propia o convenio de espacio, plan de sustentabilidad a 3 años.',
    'Cultural A.C., minimum 3 years of continuous activity, own venue or space agreement, 3-year sustainability plan.',
    cult_id, 26500, '2026-09-15',
    'Nacional', 'National', 'permanent', true
  ),
  (
    'Fondo de Desarrollo Social Local',
    'Local Social Development Fund',
    'Programa de fortalecimiento comunitario que financia proyectos de infraestructura social, generación de empleo y participación ciudadana.',
    'Community strengthening program financing social infrastructure projects, job creation, and citizen participation.',
    'A.C. con presencia comunitaria demostrable, acta de asamblea comunitaria, contraparte del 30%, informes de impacto anteriores.',
    'A.C. with demonstrable community presence, community assembly minutes, 30% counterpart funding, previous impact reports.',
    social_id, 57600, '2026-07-31',
    'Norte y Centro', 'Northern & Central', 'active', true
  ),
  (
    'Programa Mujeres Líderes 2026',
    'Women Leaders Program 2026',
    'Convocatoria especial para asociaciones lideradas por mujeres que promuevan la equidad de género, el empoderamiento femenino y la prevención de violencia.',
    'Special call for women-led associations promoting gender equity, female empowerment, and violence prevention.',
    'A.C. con liderazgo femenino comprobable, programa de acompañamiento psicológico, alianza con red de mujeres, informe de género.',
    'A.C. with proven female leadership, psychological support program, women''s network alliance, gender report.',
    social_id, 32950, '2026-06-15',
    'Nacional', 'National', 'active', true
  );
END $$;
