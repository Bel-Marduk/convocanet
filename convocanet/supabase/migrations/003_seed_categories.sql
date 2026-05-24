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

-- Seed real convocatorias (SECIHTI — gob.mx)
DO $$
DECLARE
  edu_id UUID;
  salud_id UUID;
  cult_id UUID;
  tech_id UUID;
  social_id UUID;
BEGIN
  SELECT id INTO edu_id FROM categories WHERE slug = 'educacion';
  SELECT id INTO salud_id FROM categories WHERE slug = 'salud';
  SELECT id INTO cult_id FROM categories WHERE slug = 'cultura';
  SELECT id INTO tech_id FROM categories WHERE slug = 'tecnologia';
  SELECT id INTO social_id FROM categories WHERE slug = 'social';

  -- Delete old sample data
  DELETE FROM convocatorias WHERE source_name = 'Sample';

  INSERT INTO convocatorias (
    title_es, title_en, description_es, description_en,
    requirements_es, requirements_en,
    category_id, amount_local, currency, deadline,
    region_es, region_en, source_url, source_name, status, is_public
  ) VALUES
  (
    'Convocatoria Nacional de Investigación Científica y Humanística 2026',
    'National Scientific and Humanities Research Call 2026',
    'Convocatoria de SECIHTI para financiar proyectos de investigación básica, ciencia de frontera e investigación humanística en universidades y centros de investigación de México. Tres capítulos: Ciencia Básica, Investigación Humanística y Ejes Estratégicos.',
    'SECIHTI call to fund basic science, frontier science, and humanities research projects at Mexican universities and research centers. Three chapters: Basic Science, Humanities Research, and Strategic Axes.',
    'Investigadores con adscripción institucional, proyecto de investigación vigente, carta de aceptación de la institución, cumplir con los lineamientos del capítulo correspondiente.',
    'Researchers with institutional affiliation, active research project, institutional acceptance letter, compliance with chapter-specific guidelines.',
    edu_id, NULL, 'MXN', '2026-06-30',
    'México (Nacional)', 'Mexico (National)',
    'https://secihti.mx/convocatoria/ciencias-y-humanidades/convocatoria-nacional-de-investigacion-cientifica-y-humanistica-2026/',
    'SECIHTI', 'active', true
  ),
  (
    'Becas de Posgrado para Especialidades Médicas en el Extranjero 2026',
    'Postgraduate Scholarships for Medical Specialties Abroad 2026',
    'SECIHTI ofrece becas para médicos mexicanos que deseen cursar especialidades médicas en instituciones de alto nivel en el extranjero, con cobertura de colegiatura, manutención y pasajes.',
    'SECIHTI offers scholarships for Mexican physicians to pursue medical specialties at top-tier international institutions, covering tuition, living expenses, and travel.',
    'Título de médico cirujano, carta de aceptación de institución extranjera, promedio mínimo de 8.5, no contar con otra beca gubernamental, servicio social completado.',
    'Medical degree, acceptance letter from foreign institution, minimum GPA of 8.5, no other government scholarship, completed social service.',
    salud_id, NULL, 'MXN', '2026-07-31',
    'Internacional', 'International',
    'https://secihti.mx/convocatoria/becas-al-extranjero/especialidades-medicas/convocatorias-2026-becas-de-posgrado-para-especialidades-medicas-en-el-extranjero/',
    'SECIHTI', 'active', true
  ),
  (
    'Becas de Posgrado en Ciencia y Humanidades en el Extranjero 2026',
    'Postgraduate Scholarships in Science and Humanities Abroad 2026',
    'Programa de SECIHTI para cursar maestría o doctorado en ciencias o humanidades en universidades internacionales reconocidas. Incluye manutención, colegiatura, seguro médico y pasajes.',
    'SECIHTI program for master''s or doctoral studies in science or humanities at recognized international universities. Includes living expenses, tuition, health insurance, and travel.',
    'Licenciatura terminada con promedio mínimo 8.5, carta de aceptación de universidad extranjera, dominio del idioma del país destino, proyecto de investigación o estudio.',
    'Completed bachelor''s degree with minimum GPA of 8.5, acceptance letter from foreign university, proficiency in destination country language, research or study project.',
    edu_id, NULL, 'MXN', '2026-05-22',
    'Internacional', 'International',
    'https://secihti.mx/convocatoria/becas-al-extranjero/posgrado-en-ciencias-y-humanidades/convocatoria-2026-becas-de-posgrado-en-ciencia-y-humanidades-en-el-extranjero/',
    'SECIHTI', 'expired', true
  ),
  (
    'Becas de Doble Grado México-Francia en Ingenierías STEM 2026',
    'Mexico-France Double Degree in STEM Engineering 2026',
    'Convocatoria para obtener un doble grado de ingeniería en universidades francesas y mexicanas. Los estudiantes cursan parte de sus estudios en cada país y reciben el título de ambas instituciones.',
    'Call to obtain a double engineering degree from French and Mexican universities. Students split their studies between both countries and receive degrees from both institutions.',
    'Ser estudiante de ingeniería en universidad mexicana participante, promedio mínimo 8.0, dominio del francés (B2 mínimo), carta de motivación.',
    'Engineering student at participating Mexican university, minimum GPA of 8.0, French proficiency (B2 minimum), motivation letter.',
    edu_id, NULL, 'MXN', '2026-06-09',
    'México y Francia', 'Mexico and France',
    'https://secihti.mx/convocatoria/becas-al-extranjero/doble-grado-mexico-francia-ingenierias-stem/convocatoria-2026-becas-de-doble-grado-mexico-francia-en-ingenierias-stem/',
    'SECIHTI', 'active', true
  ),
  (
    'Apoyo a Profesionales de la Cultura y el Arte: Posgrado en el Extranjero 2026',
    'Support for Culture and Arts Professionals: Graduate Studies Abroad 2026',
    'SECIHTI financia estudios de posgrado en el extranjero para profesionales de la cultura y las artes que busquen fortalecer sus competencias y contribuir al desarrollo cultural de México.',
    'SECIHTI funds graduate studies abroad for culture and arts professionals seeking to strengthen their skills and contribute to Mexico''s cultural development.',
    'Título profesional en disciplina artística o cultural, carta de aceptación de institución extranjera, trayectoria profesional demostrable, proyecto de vinculación con México.',
    'Professional degree in arts or culture discipline, acceptance letter from foreign institution, demonstrated professional trajectory, Mexico engagement project.',
    cult_id, NULL, 'MXN', '2026-08-07',
    'Internacional', 'International',
    'https://secihti.mx/convocatoria/becas-al-extranjero/apoyo-a-profesionales-de-la-cultura-y-el-arte/convocatoria-2026-apoyo-a-profesionales-de-la-cultura-y-el-arte-para-estudios-de-posgrado-en-el-extranjero/',
    'SECIHTI', 'active', true
  ),
  (
    'Convocatoria ECOS Nord 2026 — Colaboración México-Francia',
    'ECOS Nord 2026 Call — Mexico-France Collaboration',
    'Programa de cooperación científica bilateral entre México y Francia para financiar proyectos de investigación conjuntos, misiones académicas y estancias de investigación entre ambos países.',
    'Bilateral scientific cooperation program between Mexico and France to fund joint research projects, academic missions, and research stays between both countries.',
    'Investigadores con adscripción institucional en México, proyecto conjunto con investigador francés, carta de compromiso de ambas instituciones, plan de trabajo binacional.',
    'Researchers with institutional affiliation in Mexico, joint project with French researcher, commitment letter from both institutions, binational work plan.',
    edu_id, NULL, 'MXN', '2026-06-01',
    'México y Francia', 'Mexico and France',
    'https://secihti.mx/convocatoria/ciencias-y-humanidades/ecos-nord/convocatoria-ecos-nord-2026/',
    'SECIHTI', 'active', true
  ),
  (
    'Premio Mujeres en Ciencias Biológicas y de la Salud: Matilde Montoya 2026',
    'Women in Biological and Health Sciences Award: Matilde Montoya 2026',
    'Premio de SECIHTI que reconoce la trayectoria de mujeres investigadoras en ciencias biológicas y de la salud, en honor a Matilde Montoya, primera médica mexicana.',
    'SECIHTI award recognizing the career of women researchers in biological and health sciences, honoring Matilde Montoya, Mexico''s first female physician.',
    'Ser mujer investigadora en ciencias biológicas o de la salud, trayectoria científica comprobable, adscripción a institución de investigación o academia en México.',
    'Women researchers in biological or health sciences, proven scientific trajectory, affiliation with research institution or academy in Mexico.',
    salud_id, NULL, 'MXN', '2026-06-08',
    'México (Nacional)', 'Mexico (National)',
    'https://secihti.mx/convocatoria/desarrollo-tecnologico-vinculacion-e-innovacion/premio-mujeres-en-ciencias-biologicas-y-de-la-salud-matilde-montoya-2/',
    'SECIHTI', 'active', true
  ),
  (
    'Becas para Rotaciones Médicas y Estancias Técnicas 2026',
    'Medical Rotations and Technical Stays Scholarships 2026',
    'SECIHTI ofrece apoyos para rotaciones médicas y estancias técnicas nacionales e internacionales alineadas a las prioridades del sector salud en México.',
    'SECIHTI offers support for national and international medical rotations and technical stays aligned with Mexico''s health sector priorities.',
    'Médico con especialidad en curso o concluida, carta de aceptación de institución destino, proyecto alineado a prioridades nacionales de salud, compromiso de retorno.',
    'Physician with completed or ongoing specialty, acceptance letter from destination institution, project aligned with national health priorities, return commitment.',
    salud_id, NULL, 'MXN', '2026-10-23',
    'Nacional e Internacional', 'National & International',
    'https://secihti.mx/convocatoria/becas-al-extranjero/rotaciones-medicas-y-estancias-tecnicas/convocatoria-2026-becas-para-rotaciones-medicas-y-estancias-tecnicas-nacionales-y-en-el-extranjero-alineadas-a-las-prioridades-nacionales-del-sector-salud/',
    'SECIHTI', 'active', true
  ),
  (
    'Convocatoria Copa FutBotMX: Capítulo Visión por Computadora 2026',
    'FutBotMX Cup: Computer Vision Chapter 2026',
    'Competencia de SECIHTI para equipos de estudiantes e investigadores que desarrollen robots autónomos con visión por computadora para jugar fútbol, promoviendo STEM y la innovación tecnológica.',
    'SECIHTI competition for student and researcher teams developing autonomous robots with computer vision to play soccer, promoting STEM and technological innovation.',
    'Equipo de 3 a 6 integrantes, estar inscrito en institución educativa mexicana, proyecto de robot con visión por computadora, registro en la plataforma FutBotMX.',
    'Team of 3 to 6 members, enrolled in Mexican educational institution, computer vision robot project, registration on the FutBotMX platform.',
    tech_id, NULL, 'MXN', '2026-05-22',
    'México (Nacional)', 'Mexico (National)',
    'https://secihti.mx/convocatoria/desarrollo-tecnologico-vinculacion-e-innovacion/convocatoria-copa-futbotmx-capitulo-vision-por-computadora/',
    'SECIHTI', 'expired', true
  ),
  (
    'Becas Nacionales para Estudios de Posgrado 2026',
    'National Postgraduate Scholarships 2026',
    'Becas de SECIHTI para estudios de maestría y doctorado en universidades nacionales. Incluye manutención, colegiatura y apoyos complementarios de movilidad para investigadores en formación.',
    'SECIHTI scholarships for master''s and doctoral studies at national universities. Includes living expenses, tuition, and complementary mobility support for researchers in training.',
    'Ser mexicano, estar inscrito en programa de posgrado en universidad nacional, promedio mínimo de 8.0, no contar con otra beca gubernamental para el mismo nivel.',
    'Mexican national, enrolled in a postgraduate program at a national university, minimum GPA of 8.0, no other government scholarship at the same level.',
    edu_id, NULL, 'MXN', '2026-11-28',
    'México (Nacional)', 'Mexico (National)',
    'https://secihti.mx/convocatoria/becas-nacionales/convocatoria-de-becas-nacionales-para-estudios-de-posgrado-2026/',
    'SECIHTI', 'active', true
  ),
  (
    'Becas Nacionales de Inclusión 2026',
    'National Inclusion Scholarships 2026',
    'Programa de SECIHTI que ofrece becas de licenciatura para jefas de familia y apoyos complementarios para personas indígenas y con discapacidad que cursan posgrados nacionales.',
    'SECIHTI program offering undergraduate scholarships for female heads of household and complementary support for Indigenous persons and persons with disabilities pursuing national postgraduate studies.',
    'Línea A: ser jefa de familia mexicana cursando licenciatura. Líneas B y C: ser beneficiario vigente de beca SECIHTI de posgrado nacional y ser indígena o persona con discapacidad.',
    'Line A: Mexican female head of household pursuing undergraduate studies. Lines B & C: current SECIHTI national postgraduate scholarship holder who is Indigenous or a person with a disability.',
    social_id, NULL, 'MXN', '2026-09-25',
    'México (Nacional)', 'Mexico (National)',
    'https://secihti.mx/convocatoria/becas-nacionales/convocatoria-becas-nacionales-de-inclusion-2026/',
    'SECIHTI', 'active', true
  ),
  (
    'Apoyos Complementarios de Movilidad 2026',
    'Complementary Mobility Support 2026',
    'SECIHTI ofrece apoyos de movilidad internacional, nacional, en sectores de interés y para programas de doble titulación a beneficiarios de becas nacionales vigentes.',
    'SECIHTI offers international, domestic, priority-sector, and double-degree mobility support to current national scholarship holders.',
    'Ser beneficiario vigente de beca nacional SECIHTI, carta de aceptación de institución destino, plan de estancia aprobado por tutor.',
    'Current SECIHTI national scholarship holder, acceptance letter from destination institution, tutor-approved stay plan.',
    edu_id, NULL, 'MXN', '2026-10-31',
    'Nacional e Internacional', 'National & International',
    'https://secihti.mx/convocatoria/becas-nacionales/convocatoria-de-apoyos-complementarios-de-movilidad-en-el-extranjero-movilidad-nacional-movilidad-en-los-sectores-de-interes-y-movilidad-para-programas-de-doble-titulacion-2026/',
    'SECIHTI', 'active', true
  ),
  (
    'Becas de Especialidades Médicas Nacionales 2026',
    'National Medical Specialties Scholarships 2026',
    'SECIHTI ofrece becas de posgrado y apoyos complementarios de movilidad para médicos mexicanos que cursen especialidades médicas en instituciones nacionales de salud.',
    'SECIHTI offers postgraduate scholarships and complementary mobility support for Mexican physicians pursuing medical specialties at national health institutions.',
    'Título de médico cirujano, estar inscrito en programa de especialidad médica nacional, promedio mínimo de 8.0, servicio social completado.',
    'Medical degree, enrolled in a national specialty program, minimum GPA of 8.0, completed social service.',
    salud_id, NULL, 'MXN', '2026-11-28',
    'México (Nacional)', 'Mexico (National)',
    'https://secihti.mx/convocatoria/becas-nacionales/convocatoria-de-becas-de-posgrado-y-apoyos-complementarios-de-movilidad-para-especialidades-medicas-nacionales-2026/',
    'SECIHTI', 'active', true
  ),
  (
    'Becas para la Formación en Centros Públicos SECIHTI 2026',
    'Training Scholarships at SECIHTI Public Centers 2026',
    'Programa de becas de SECIHTI para formación de investigadores en centros públicos de investigación adscritos a la Secretaría. Cubre manutención y colegiatura.',
    'SECIHTI scholarship program for training researchers at public research centers under the Secretariat. Covers living expenses and tuition.',
    'Ser mexicano, estar inscrito en programa de formación en centro público SECIHTI, cumplir requisitos del nivel inmediato anterior.',
    'Mexican national, enrolled in a training program at a SECIHTI public center, meet prior-level requirements.',
    edu_id, NULL, 'MXN', '2026-10-23',
    'México (Nacional)', 'Mexico (National)',
    'https://secihti.mx/convocatoria/becas-nacionales/convocatoria-becas-nacionales-para-la-formacion-en-cp-secihti-2026/',
    'SECIHTI', 'active', true
  ),
  (
    'Apoyo Complementario de Maternidad y Paternidad 2026',
    'Maternity and Paternity Complementary Support 2026',
    'SECIHTI ofrece apoyo económico complementario a beneficiarios de becas nacionales de posgrado durante su periodo de maternidad o paternidad.',
    'SECIHTI offers complementary financial support to national postgraduate scholarship holders during maternity or paternity leave.',
    'Ser beneficiario vigente de beca nacional de posgrado SECIHTI, presentar acta de nacimiento del hijo, tramitar dentro del periodo correspondiente.',
    'Current SECIHTI national postgraduate scholarship holder, present child''s birth certificate, apply within the corresponding period.',
    social_id, NULL, 'MXN', '2026-12-03',
    'México (Nacional)', 'Mexico (National)',
    'https://secihti.mx/convocatoria/becas-nacionales/convocatoria-2026-apoyo-complementario-de-maternidad-y-paternidad-nacional-en-el-extranjero-y-de-consolidacion/',
    'SECIHTI', 'active', true
  );
END $$;
