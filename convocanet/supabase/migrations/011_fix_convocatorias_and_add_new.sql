-- Migration 011: Fix convocatorias — remove expired, add real ones with future deadlines
-- Run in Supabase SQL Editor

-- ============================================
-- 1. Mark expired convocatorias (deadline already passed)
-- ============================================
UPDATE convocatorias SET status = 'expired', updated_at = now()
WHERE deadline IS NOT NULL AND deadline < CURRENT_DATE AND status = 'active';

-- ============================================
-- 2. Add NEW convocatorias (not already in seed 003)
--    Seed already has ALL SECIHTI convocatorias with future deadlines:
--    Investigación Científica, Esp. Médicas Extranjero, Doble Grado STEM,
--    Cultura y Arte, Rotaciones Médicas, Inclusión, Movilidad, Posgrado Nacional,
--    Esp. Médicas Nacionales, Formación CP, Maternidad (nacional), ECOS Nord,
--    Matilde Montoya, Copa FutBotMX (expired)
--    New below: Maternidad Extranjero (different URL), + international + permanent
-- ============================================
DO $$
DECLARE
  edu_id UUID;
  salud_id UUID;
  tech_id UUID;
  social_id UUID;
BEGIN
  SELECT id INTO edu_id FROM categories WHERE slug = 'educacion';
  SELECT id INTO salud_id FROM categories WHERE slug = 'salud';
  SELECT id INTO tech_id FROM categories WHERE slug = 'tecnologia';
  SELECT id INTO social_id FROM categories WHERE slug = 'social';

  INSERT INTO convocatorias (
    title_es, title_en, description_es, description_en,
    requirements_es, requirements_en,
    category_id, amount_local, currency, deadline,
    region_es, region_en, source_url, source_name, status, is_public
  ) VALUES

  -- =============================================
  -- SECIHTI: Convocatoria NUEVA con fecha de cierre
  -- =============================================

  -- Apoyo Complementario Maternidad/Paternidad Extranjero — Cierre: 03 Dic 2026
  -- (Different URL from seed — seed has becas-nacionales version, this is extranjero version)
  (
    'Apoyo Complementario de Maternidad y Paternidad en el Extranjero y de Consolidación 2026',
    'Maternity and Paternity Complementary Support Abroad and Consolidation 2026',
    'SECIHTI ofrece apoyo económico complementario a beneficiarios de becas de posgrado en el extranjero y de consolidación durante su periodo de maternidad o paternidad.',
    'SECIHTI offers complementary financial support to postgraduate scholarship holders abroad and in consolidation during maternity or paternity leave.',
    'Ser beneficiario vigente de beca SECIHTI en el extranjero o de consolidación, presentar acta de nacimiento del hijo, tramitar dentro del periodo correspondiente.',
    'Current SECIHTI scholarship holder abroad or in consolidation, present child''s birth certificate, apply within the corresponding period.',
    social_id, NULL, 'MXN', '2026-12-03',
    'Internacional', 'International',
    'https://secihti.mx/convocatoria/becas-al-extranjero/apoyo-complementario/convocatoria-2026-apoyo-complementario-de-maternidad-y-paternidad-nacional-en-el-extranjero-y-de-consolidacion-2/',
    'SECIHTI', 'active', true
  ),

  -- =============================================
  -- OTRAS FUENTES: Convocatorias con fecha de cierre 2026-2027
  -- =============================================

  -- Chevening 2027-2028 (UK Government) — Abre Ago 2026, cierra ~Nov 2026
  (
    'Becas Chevening 2027-2028 — Gobierno del Reino Unido',
    'Chevening Scholarships 2027-2028 — UK Government',
    'Programa de becas del gobierno del Reino Unido para profesionales destacados de México y el mundo que deseen cursar una maestría de un año en universidades británicas. Cubre colegiatura, manutención, pasajes y seguro médico.',
    'UK government scholarship program for outstanding professionals from Mexico and worldwide to pursue a one-year master''s degree at UK universities. Covers tuition, living expenses, travel, and health insurance.',
    'Ser mexicano, tener al menos dos años de experiencia profesional, licenciatura terminada, dominio del inglés (IELTS 6.5+), carta de aceptación de universidad británica, demostrar liderazgo y compromiso de retorno.',
    'Mexican national, at least two years professional experience, completed bachelor''s degree, English proficiency (IELTS 6.5+), acceptance letter from UK university, demonstrate leadership and return commitment.',
    edu_id, NULL, 'MXN', '2026-11-04',
    'México y Reino Unido', 'Mexico and United Kingdom',
    'https://www.chevening.org/scholarships/application-timeline/',
    'Chevening', 'active', true
  ),

  -- Google PhD Fellowship 2026
  (
    'Google PhD Fellowship Program 2026',
    'Google PhD Fellowship Program 2026',
    'Programa de Google que apoya a estudiantes de doctorado que realizan investigaciones innovadoras en áreas como inteligencia artificial, sistemas distribuidos, seguridad, salud computacional y más.',
    'Google program supporting doctoral students conducting innovative research in areas such as artificial intelligence, distributed systems, security, computational health, and more.',
    'Estar inscrito en programa de doctorado, investigación en áreas relevantes para Google, ser nombrado por la universidad (no se aceptan aplicaciones directas).',
    'Enrolled in a doctoral program, research in areas relevant to Google, university nomination required (no direct applications).',
    tech_id, NULL, 'USD', '2026-08-15',
    'Global', 'Global',
    'https://research.google/outreach/phd-fellowship/',
    'Google', 'active', true
  ),

  -- Wellcome Trust — Science Grants 2026-2027
  (
    'Wellcome Trust — Science Grants 2026-2027',
    'Wellcome Trust — Science Grants 2026-2027',
    'Financiamiento del Wellcome Trust para investigadores en ciencias de la salud, ciencias biomédicas y salud global. Apoya proyectos de investigación de cualquier duración con presupuestos flexibles.',
    'Wellcome Trust funding for researchers in health sciences, biomedical sciences, and global health. Supports research projects of any duration with flexible budgets.',
    'Investigador con adscripción institucional, proyecto de investigación en ciencias de la salud o biomédicas, justificación del impacto, plan de trabajo detallado.',
    'Researcher with institutional affiliation, research project in health or biomedical sciences, impact justification, detailed work plan.',
    salud_id, NULL, 'GBP', '2027-03-01',
    'Global', 'Global',
    'https://wellcome.org/grant-funding/guidance/applying-funding',
    'Wellcome Trust', 'active', true
  ),

  -- =============================================
  -- PERMANENTES: Programas siempre abiertos, URLs específicas
  -- =============================================

  -- Estímulo Fiscal I+D (SECIHTI) — Ley del ISR Art. 202-205
  (
    'Estímulo Fiscal a la Investigación y Desarrollo de Tecnología (Ley del ISR Art. 202-205)',
    'Tax Incentive for Research and Technology Development (ISR Law Art. 202-205)',
    'Programa permanente de SECIHTI que permite a empresas deducir el 30% de inversiones en I+D y obtener un crédito fiscal del 30% sobre gastos e inversiones en investigación y desarrollo tecnológico. Aplicación continua durante todo el año.',
    'Permanent SECIHTI program allowing companies to deduct 30% of R&D investments and obtain a 30% tax credit on research and technology development expenses and investments. Year-round continuous application.',
    'Empresa constituida en México con proyectos de investigación y desarrollo tecnológico, Registro Nacional de Instituciones y Empresas Científicas y Tecnológicas vigente.',
    'Company incorporated in Mexico with research and technology development projects, active National Registry of Scientific and Technological Institutions and Companies.',
    tech_id, NULL, 'MXN', NULL,
    'México (Nacional)', 'Mexico (National)',
    'https://secihti.mx/tecnologias-e-innovacion/estimulo-fiscal-a-la-investigacion-y-desarrollo-de-tecnologia/',
    'SECIHTI', 'permanent', true
  ),

  -- Proyectos sin Mediar Convocatoria (SECIHTI)
  (
    'Proyectos de Desarrollo Tecnológico e Innovación sin Mediar Convocatoria',
    'Technology Development and Innovation Projects — Open Call (No Fixed Deadline)',
    'SECIHTI permite la presentación de propuestas de proyectos de desarrollo tecnológico, innovación y vinculación durante todo el año, sin fecha de cierre. Las propuestas se evalúan de forma continua.',
    'SECIHTI accepts technology development, innovation, and collaboration project proposals year-round with no closing date. Proposals are evaluated on a rolling basis.',
    'Empresa o institución mexicana, proyecto de desarrollo tecnológico o innovación con impacto nacional, Registro Nacional de Instituciones y Empresas Científicas y Tecnológicas vigente.',
    'Mexican company or institution, technology development or innovation project with national impact, active National Registry of Scientific and Technological Institutions and Companies.',
    tech_id, NULL, 'MXN', NULL,
    'México (Nacional)', 'Mexico (National)',
    'https://secihti.mx/tecnologias-e-innovacion/proyectos-sin-mediar-convocatoria/',
    'SECIHTI', 'permanent', true
  ),

  -- Google for Nonprofits
  (
    'Google for Nonprofits — Ad Grants y Herramientas Gratuitas',
    'Google for Nonprofits — Ad Grants and Free Tools',
    'Programa permanente de Google que ofrece a organizaciones sin fines de lucro acceso gratuito a Google Ads ($10,000 USD/mes), Google Workspace, YouTube Premium y herramientas de mapeo. Sin fecha de cierre.',
    'Permanent Google program providing nonprofits with free access to Google Ads ($10,000 USD/month), Google Workspace, YouTube Premium, and mapping tools. No closing date.',
    'Organización sin fines de lucro registrada, válida para beneficencia en su país, sitio web activo.',
    'Registered nonprofit organization, valid charity status in its country, active website.',
    tech_id, NULL, 'USD', NULL,
    'Global', 'Global',
    'https://www.google.com/nonprofits/',
    'Google.org', 'permanent', true
  ),

  -- Salesforce.org Power of Us
  (
    'Salesforce.org — Power of Us Program (10 Licencias Gratuitas)',
    'Salesforce.org — Power of Us Program (10 Free Licenses)',
    'Programa permanente de Salesforce que dona hasta 10 licencias de Salesforce Lightning a organizaciones sin fines de lucro e instituciones educativas. Incluye acceso a Trailhead para capacitación.',
    'Permanent Salesforce program donating up to 10 Salesforce Lightning licenses to nonprofits and educational institutions. Includes Trailhead access for training.',
    'Organización sin fines de lucro o institución educativa registrada, válida para beneficencia.',
    'Registered nonprofit organization or educational institution, valid charity status.',
    tech_id, NULL, 'USD', NULL,
    'Global', 'Global',
    'https://www.salesforce.org/power-of-us/',
    'Salesforce.org', 'permanent', true
  ),

  -- Microsoft Philanthropies — Tech for Social Impact
  (
    'Microsoft Philanthropies — Tech for Social Impact',
    'Microsoft Philanthropies — Tech for Social Impact',
    'Programa permanente de Microsoft que ofrece créditos de Azure, descuentos en licencias de Microsoft 365 y Dynamics 365, y capacitación digital para organizaciones sin fines de lucro.',
    'Permanent Microsoft program offering Azure credits, discounted Microsoft 365 and Dynamics 365 licenses, and digital training for nonprofits.',
    'Organización sin fines de lucro registrada, compromiso de uso tecnológico para impacto social.',
    'Registered nonprofit organization, commitment to technology use for social impact.',
    tech_id, NULL, 'USD', NULL,
    'Global', 'Global',
    'https://www.microsoft.com/en-us/philanthropies/tech-for-social-impact',
    'Microsoft', 'permanent', true
  );

END $$;
