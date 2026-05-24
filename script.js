// ===== Translations =====
const translations = {
    es: {
        // Nav
        nav_inicio: "Inicio",
        nav_caracteristicas: "Características",
        nav_convocatorias: "Convocatorias",
        nav_estadisticas: "Estadísticas",
        nav_nosotros: "Nosotros",
        nav_contacto: "Contacto",
        // Hero
        hero_badge: "Plataforma de Convocatorias 2026",
        hero_title: 'Conectando <span class="gradient-text">Asociaciones Civiles</span> con Oportunidades',
        hero_subtitle: "Centralizamos las convocatorias públicas para que tu organización encuentre financiamiento, programas y alianzas estratégicas en un solo lugar.",
        hero_btn_ver: "Ver Convocatorias",
        hero_btn_conocer: "Conocer Más",
        hero_stat_activas: "Convocatorias Activas",
        hero_stat_asociaciones: "Asociaciones Registradas",
        hero_stat_exitos: "% Tasa de Éxito",
        // Features
        features_tag: "CARACTERÍSTICAS",
        features_title: "Todo lo que necesitas en un solo lugar",
        features_subtitle: "Herramientas diseñadas para simplificar la búsqueda y postulación a convocatorias.",
        feature1_title: "Búsqueda Inteligente",
        feature1_desc: "Filtra convocatorias por sector, monto, región y fecha límite. Encuentra las oportunidades perfectas para tu organización.",
        feature2_title: "Alertas Personalizadas",
        feature2_desc: "Recibe notificaciones por correo cuando se publiquen nuevas convocatorias que coincidan con el perfil de tu asociación.",
        feature3_title: "Gestión Documental",
        feature3_desc: "Almacena y organiza todos los documentos necesarios para tus postulaciones en un repositorio seguro y accesible.",
        feature4_title: "Panel de Seguimiento",
        feature4_desc: "Monitorea el estado de todas tus postulaciones en tiempo real con un panel visual e intuitivo.",
        feature5_title: "Red Colaborativa",
        feature5_desc: "Conecta con otras asociaciones civiles para formar alianzas estratégicas y presentar proyectos conjuntos.",
        feature6_title: "Transparencia Total",
        feature6_desc: "Cada convocatoria incluye criterios de evaluación, historial de resultados y feedback de participantes anteriores.",
        // Convocatorias
        conv_tag: "CONVOCATORIAS ABIERTAS",
        conv_title: "Oportunidades Disponibles",
        conv_subtitle: "Explora las convocatorias vigentes y encuentra el apoyo que tu asociación necesita.",
        filter_todas: "Todas",
        filter_edu: "Educación",
        filter_salud: "Salud",
        filter_tecnologia: "Tecnología",
        filter_cultura: "Cultura",
        filter_social: "Desarrollo Social",
        btn_postular: "Postular",
        btn_ver_mas: "Ver más",
        btn_ver_fuente: "Ver fuente oficial",
        // Convocatoria modal
        modal_requisitos: "Requisitos",
        modal_monto_label: "Monto",
        modal_fecha_label: "Fecha límite",
        modal_region_label: "Región",
        modal_categoria_label: "Categoría",
        modal_postular: "Postular a esta convocatoria",
        modal_fuente_label: "Fuente",
        // Stats
        stats_publicadas: "Convocatorias Publicadas",
        stats_financiamiento: "En Financiamiento",
        stats_organizaciones: "Organizaciones Activas",
        stats_estados: "Estados Conectados",
        // Testimonials
        test_tag: "TESTIMONIOS",
        test_title: "Lo que dicen las asociaciones",
        test1_text: '"Gracias a ConvocaNet obtuvimos una beca que transformó nuestro programa de educación comunitaria. La plataforma es intuitiva y las alertas nos mantienen siempre informados."',
        test1_role: "Directora, Fundación Educar",
        test2_text: '"La red colaborativa nos permitió encontrar aliados para un proyecto ambiental que ahora impacta a 5 comunidades. Una herramienta indispensable."',
        test2_role: "Coordinador, EcoVerde A.C.",
        test3_text: '"El panel de seguimiento nos da claridad sobre el estado de nuestras postulaciones. Ya no perdemos oportunidades por fechas límite."',
        test3_role: "Presidenta, Manos Unidas A.C.",
        // CTA
        cta_title: "¿Listo para encontrar tu próxima convocatoria?",
        cta_subtitle: "Únete a más de 1,500 asociaciones civiles que ya están aprovechando estas oportunidades.",
        cta_btn: "Comenzar Ahora",
        // Contact
        contact_tag: "CONTACTO",
        contact_title: "¿Tienes preguntas?",
        contact_subtitle: "Nuestro equipo está listo para ayudarte a aprovechar al máximo ConvocaNet.",
        contact_dir: "Ciudad de México, México",
        form_nombre: "Nombre completo",
        form_email: "Correo electrónico",
        form_org: "Nombre de la asociación",
        form_msg: "Mensaje",
        form_btn: "Enviar Mensaje",
        // Footer
        footer_desc: "Conectando asociaciones civiles con oportunidades de financiamiento y desarrollo desde 2024.",
        footer_plataforma: "Plataforma",
        footer_conv: "Convocatorias",
        footer_feat: "Características",
        footer_stats: "Estadísticas",
        footer_nosotros: "Nosotros",
        footer_recursos: "Recursos",
        footer_blog: "Blog",
        footer_guia: "Guías de Postulación",
        footer_faq: "Preguntas Frecuentes",
        footer_api: "API para Desarrolladores",
        footer_legal: "Legal",
        footer_priv: "Privacidad",
        footer_terms: "Términos de Uso",
        footer_cookies: "Cookies",
        footer_copy: "© 2026 ConvocaNet. Todos los derechos reservados.",
        // Toast
        toast_enviado: "Mensaje enviado correctamente",
        toast_postulacion: "Redirigiendo al formulario de postulación...",
        // Convocatoria data (reales — SECIHTI / gob.mx)
        conv1_title: "Convocatoria Nacional de Investigación Científica y Humanística 2026",
        conv1_desc: "Convocatoria de SECIHTI para financiar proyectos de investigación básica, ciencia de frontera e investigación humanística en universidades y centros de investigación de México. Tres capítulos: Ciencia Básica, Investigación Humanística y Ejes Estratégicos.",
        conv1_req: "Investigadores con adscripción institucional, proyecto de investigación vigente, carta de aceptación de la institución, cumplir con los lineamientos del capítulo correspondiente.",
        conv2_title: "Becas de Posgrado para Especialidades Médicas en el Extranjero 2026",
        conv2_desc: "SECIHTI ofrece becas para médicos mexicanos que deseen cursar especialidades médicas en instituciones de alto nivel en el extranjero, con cobertura de colegiatura, manutención y pasajes.",
        conv2_req: "Título de médico cirujano, carta de aceptación de institución extranjera, promedio mínimo de 8.5, no contar con otra beca gubernamental, servicio social completado.",
        conv3_title: "Becas de Posgrado en Ciencia y Humanidades en el Extranjero 2026",
        conv3_desc: "Programa de SECIHTI para cursar maestría o doctorado en ciencias o humanidades en universidades internacionales reconocidas. Incluye manutención, colegiatura, seguro médico y pasajes.",
        conv3_req: "Licenciatura terminada con promedio mínimo 8.5, carta de aceptación de universidad extranjera, dominio del idioma del país destino, proyecto de investigación o estudio.",
        conv4_title: "Becas de Doble Grado México-Francia en Ingenierías STEM 2026",
        conv4_desc: "Convocatoria para obtener un doble grado de ingeniería en universidades francesas y mexicanas. Los estudiantes cursan parte de sus estudios en cada país y reciben el título de ambas instituciones.",
        conv4_req: "Ser estudiante de ingeniería en universidad mexicana participante, promedio mínimo 8.0, dominio del francés (B2 mínimo), carta de motivación.",
        conv5_title: "Apoyo a Profesionales de la Cultura y el Arte: Posgrado en el Extranjero 2026",
        conv5_desc: "SECIHTI financia estudios de posgrado en el extranjero para profesionales de la cultura y las artes que busquen fortalecer sus competencias y contribuir al desarrollo cultural de México.",
        conv5_req: "Título profesional en disciplina artística o cultural, carta de aceptación de institución extranjera, trayectoria profesional demostrable, proyecto de vinculación con México.",
        conv6_title: "Convocatoria ECOS Nord 2026 — Colaboración México-Francia",
        conv6_desc: "Programa de cooperación científica bilateral entre México y Francia para financiar proyectos de investigación conjuntos, misiones académicas y estancias de investigación entre ambos países.",
        conv6_req: "Investigadores con adscripción institucional en México, proyecto conjunto con investigador francés, carta de compromiso de ambas instituciones, plan de trabajo binacional.",
        conv7_title: "Premio Mujeres en Ciencias Biológicas y de la Salud: Matilde Montoya 2026",
        conv7_desc: "Premio de SECIHTI que reconoce la trayectoria de mujeres investigadoras en ciencias biológicas y de la salud, en honor a Matilde Montoya, primera médica mexicana.",
        conv7_req: "Ser mujer investigadora en ciencias biológicas o de la salud, trayectoria científica comprobable, adscripción a institución de investigación o academia en México.",
        conv8_title: "Becas para Rotaciones Médicas y Estancias Técnicas 2026",
        conv8_desc: "SECIHTI ofrece apoyos para rotaciones médicas y estancias técnicas nacionales e internacionales alineadas a las prioridades del sector salud en México.",
        conv8_req: "Médico con especialidad en curso o concluida, carta de aceptación de institución destino, proyecto alineado a prioridades nacionales de salud, compromiso de retorno.",
        conv9_title: "Convocatoria Copa FutBotMX: Capítulo Visión por Computadora 2026",
        conv9_desc: "Competencia de SECIHTI para equipos de estudiantes e investigadores que desarrollen robots autónomos con visión por computadora para jugar fútbol, promoviendo STEM y la innovación tecnológica.",
        conv9_req: "Equipo de 3 a 6 integrantes, estar inscrito en institución educativa mexicana, proyecto de robot con visión por computadora, registro en la plataforma FutBotMX."
    },
    en: {
        // Nav
        nav_inicio: "Home",
        nav_caracteristicas: "Features",
        nav_convocatorias: "Open Calls",
        nav_estadisticas: "Statistics",
        nav_nosotros: "About",
        nav_contacto: "Contact",
        // Hero
        hero_badge: "Open Calls Platform 2026",
        hero_title: 'Connecting <span class="gradient-text">Civil Associations</span> with Opportunities',
        hero_subtitle: "We centralize public calls so your organization can find funding, programs, and strategic partnerships in one place.",
        hero_btn_ver: "View Open Calls",
        hero_btn_conocer: "Learn More",
        hero_stat_activas: "Active Calls",
        hero_stat_asociaciones: "Registered Associations",
        hero_stat_exitos: "% Success Rate",
        // Features
        features_tag: "FEATURES",
        features_title: "Everything you need in one place",
        features_subtitle: "Tools designed to simplify searching and applying to open calls.",
        feature1_title: "Smart Search",
        feature1_desc: "Filter calls by sector, amount, region, and deadline. Find the perfect opportunities for your organization.",
        feature2_title: "Custom Alerts",
        feature2_desc: "Receive email notifications when new calls matching your association's profile are published.",
        feature3_title: "Document Management",
        feature3_desc: "Store and organize all documents needed for your applications in a secure, accessible repository.",
        feature4_title: "Tracking Dashboard",
        feature4_desc: "Monitor the status of all your applications in real time with a visual, intuitive dashboard.",
        feature5_title: "Collaborative Network",
        feature5_desc: "Connect with other civil associations to form strategic alliances and submit joint projects.",
        feature6_title: "Full Transparency",
        feature6_desc: "Each call includes evaluation criteria, results history, and feedback from previous participants.",
        // Convocatorias
        conv_tag: "OPEN CALLS",
        conv_title: "Available Opportunities",
        conv_subtitle: "Explore current calls and find the support your association needs.",
        filter_todas: "All",
        filter_edu: "Education",
        filter_salud: "Health",
        filter_tecnologia: "Technology",
        filter_cultura: "Culture",
        filter_social: "Social Development",
        btn_postular: "Apply",
        btn_ver_mas: "View more",
        btn_ver_fuente: "View official source",
        // Modal
        modal_requisitos: "Requirements",
        modal_monto_label: "Amount",
        modal_fecha_label: "Deadline",
        modal_region_label: "Region",
        modal_categoria_label: "Category",
        modal_postular: "Apply to this call",
        modal_fuente_label: "Source",
        // Stats
        stats_publicadas: "Published Calls",
        stats_financiamiento: "In Funding",
        stats_organizaciones: "Active Organizations",
        stats_estados: "Connected States",
        // Testimonials
        test_tag: "TESTIMONIALS",
        test_title: "What associations say",
        test1_text: '"Thanks to ConvocaNet we obtained a grant that transformed our community education program. The platform is intuitive and the alerts keep us always informed."',
        test1_role: "Director, Fundación Educar",
        test2_text: '"The collaborative network allowed us to find allies for an environmental project that now impacts 5 communities. An indispensable tool."',
        test2_role: "Coordinator, EcoVerde A.C.",
        test3_text: '"The tracking dashboard gives us clarity on the status of our applications. We no longer miss opportunities due to deadlines."',
        test3_role: "President, Manos Unidas A.C.",
        // CTA
        cta_title: "Ready to find your next open call?",
        cta_subtitle: "Join over 1,500 civil associations already taking advantage of these opportunities.",
        cta_btn: "Get Started",
        // Contact
        contact_tag: "CONTACT",
        contact_title: "Have questions?",
        contact_subtitle: "Our team is ready to help you make the most of ConvocaNet.",
        contact_dir: "Mexico City, Mexico",
        form_nombre: "Full name",
        form_email: "Email address",
        form_org: "Association name",
        form_msg: "Message",
        form_btn: "Send Message",
        // Footer
        footer_desc: "Connecting civil associations with funding and development opportunities since 2024.",
        footer_plataforma: "Platform",
        footer_conv: "Open Calls",
        footer_feat: "Features",
        footer_stats: "Statistics",
        footer_nosotros: "About",
        footer_recursos: "Resources",
        footer_blog: "Blog",
        footer_guia: "Application Guides",
        footer_faq: "FAQ",
        footer_api: "Developer API",
        footer_legal: "Legal",
        footer_priv: "Privacy",
        footer_terms: "Terms of Use",
        footer_cookies: "Cookies",
        footer_copy: "© 2026 ConvocaNet. All rights reserved.",
        // Toast
        toast_enviado: "Message sent successfully",
        toast_postulacion: "Redirecting to application form...",
        // Convocatoria data (real — SECIHTI / gob.mx)
        conv1_title: "National Scientific and Humanities Research Call 2026",
        conv1_desc: "SECIHTI call to fund basic science, frontier science, and humanities research projects at Mexican universities and research centers. Three chapters: Basic Science, Humanities Research, and Strategic Axes.",
        conv1_req: "Researchers with institutional affiliation, active research project, institutional acceptance letter, compliance with chapter-specific guidelines.",
        conv2_title: "Postgraduate Scholarships for Medical Specialties Abroad 2026",
        conv2_desc: "SECIHTI offers scholarships for Mexican physicians to pursue medical specialties at top-tier international institutions, covering tuition, living expenses, and travel.",
        conv2_req: "Medical degree, acceptance letter from foreign institution, minimum GPA of 8.5, no other government scholarship, completed social service.",
        conv3_title: "Postgraduate Scholarships in Science and Humanities Abroad 2026",
        conv3_desc: "SECIHTI program for master's or doctoral studies in science or humanities at recognized international universities. Includes living expenses, tuition, health insurance, and travel.",
        conv3_req: "Completed bachelor's degree with minimum GPA of 8.5, acceptance letter from foreign university, proficiency in destination country language, research or study project.",
        conv4_title: "Mexico-France Double Degree in STEM Engineering 2026",
        conv4_desc: "Call to obtain a double engineering degree from French and Mexican universities. Students split their studies between both countries and receive degrees from both institutions.",
        conv4_req: "Engineering student at participating Mexican university, minimum GPA of 8.0, French proficiency (B2 minimum), motivation letter.",
        conv5_title: "Support for Culture and Arts Professionals: Graduate Studies Abroad 2026",
        conv5_desc: "SECIHTI funds graduate studies abroad for culture and arts professionals seeking to strengthen their skills and contribute to Mexico's cultural development.",
        conv5_req: "Professional degree in arts or culture discipline, acceptance letter from foreign institution, demonstrated professional trajectory, Mexico engagement project.",
        conv6_title: "ECOS Nord 2026 Call — Mexico-France Collaboration",
        conv6_desc: "Bilateral scientific cooperation program between Mexico and France to fund joint research projects, academic missions, and research stays between both countries.",
        conv6_req: "Researchers with institutional affiliation in Mexico, joint project with French researcher, commitment letter from both institutions, binational work plan.",
        conv7_title: "Women in Biological and Health Sciences Award: Matilde Montoya 2026",
        conv7_desc: "SECIHTI award recognizing the career of women researchers in biological and health sciences, honoring Matilde Montoya, Mexico's first female physician.",
        conv7_req: "Women researchers in biological or health sciences, proven scientific trajectory, affiliation with research institution or academy in Mexico.",
        conv8_title: "Medical Rotations and Technical Stays Scholarships 2026",
        conv8_desc: "SECIHTI offers support for national and international medical rotations and technical stays aligned with Mexico's health sector priorities.",
        conv8_req: "Physician with completed or ongoing specialty, acceptance letter from destination institution, project aligned with national health priorities, return commitment.",
        conv9_title: "FutBotMX Cup: Computer Vision Chapter 2026",
        conv9_desc: "SECIHTI competition for student and researcher teams developing autonomous robots with computer vision to play soccer, promoting STEM and technological innovation.",
        conv9_req: "Team of 3 to 6 members, enrolled in Mexican educational institution, computer vision robot project, registration on the FutBotMX platform."
    }
};

// ===== Convocatorias Data (reales — SECIHTI) =====
const convocatorias = [
    {
        id: 1,
        category: "educacion",
        catLabel: { es: "Educación", en: "Education" },
        catClass: "cat-educacion",
        titleKey: "conv1_title",
        descKey: "conv1_desc",
        reqKey: "conv1_req",
        amount: { es: "Variable", en: "Variable" },
        deadline: "2026-06-30",
        region: { es: "México (Nacional)", en: "Mexico (National)" },
        sourceUrl: "https://secihti.mx/convocatoria/ciencias-y-humanidades/convocatoria-nacional-de-investigacion-cientifica-y-humanistica-2026/",
        sourceName: "SECIHTI",
        status: "abierta",
        statusLabel: { es: "Abierta", en: "Open" },
        icon: "fas fa-flask"
    },
    {
        id: 2,
        category: "salud",
        catLabel: { es: "Salud", en: "Health" },
        catClass: "cat-salud",
        titleKey: "conv2_title",
        descKey: "conv2_desc",
        reqKey: "conv2_req",
        amount: { es: "Beca completa", en: "Full scholarship" },
        deadline: "2026-07-31",
        region: { es: "Internacional", en: "International" },
        sourceUrl: "https://secihti.mx/convocatoria/becas-al-extranjero/especialidades-medicas/convocatorias-2026-becas-de-posgrado-para-especialidades-medicas-en-el-extranjero/",
        sourceName: "SECIHTI",
        status: "abierta",
        statusLabel: { es: "Abierta", en: "Open" },
        icon: "fas fa-heartbeat"
    },
    {
        id: 3,
        category: "educacion",
        catLabel: { es: "Educación", en: "Education" },
        catClass: "cat-educacion",
        titleKey: "conv3_title",
        descKey: "conv3_desc",
        reqKey: "conv3_req",
        amount: { es: "Beca completa", en: "Full scholarship" },
        deadline: "2026-05-22",
        region: { es: "Internacional", en: "International" },
        sourceUrl: "https://secihti.mx/convocatoria/becas-al-extranjero/posgrado-en-ciencias-y-humanidades/convocatoria-2026-becas-de-posgrado-en-ciencia-y-humanidades-en-el-extranjero/",
        sourceName: "SECIHTI",
        status: "abierta",
        statusLabel: { es: "Abierta", en: "Open" },
        icon: "fas fa-graduation-cap"
    },
    {
        id: 4,
        category: "educacion",
        catLabel: { es: "Educación", en: "Education" },
        catClass: "cat-educacion",
        titleKey: "conv4_title",
        descKey: "conv4_desc",
        reqKey: "conv4_req",
        amount: { es: "Doble titulación", en: "Double degree" },
        deadline: "2026-06-09",
        region: { es: "México y Francia", en: "Mexico and France" },
        sourceUrl: "https://secihti.mx/convocatoria/becas-al-extranjero/doble-grado-mexico-francia-ingenierias-stem/convocatoria-2026-becas-de-doble-grado-mexico-francia-en-ingenierias-stem/",
        sourceName: "SECIHTI",
        status: "abierta",
        statusLabel: { es: "Abierta", en: "Open" },
        icon: "fas fa-microchip"
    },
    {
        id: 5,
        category: "cultura",
        catLabel: { es: "Cultura", en: "Culture" },
        catClass: "cat-cultura",
        titleKey: "conv5_title",
        descKey: "conv5_desc",
        reqKey: "conv5_req",
        amount: { es: "Beca de posgrado", en: "Postgraduate scholarship" },
        deadline: "2026-08-07",
        region: { es: "Internacional", en: "International" },
        sourceUrl: "https://secihti.mx/convocatoria/becas-al-extranjero/apoyo-a-profesionales-de-la-cultura-y-el-arte/convocatoria-2026-apoyo-a-profesionales-de-la-cultura-y-el-arte-para-estudios-de-posgrado-en-el-extranjero/",
        sourceName: "SECIHTI",
        status: "abierta",
        statusLabel: { es: "Abierta", en: "Open" },
        icon: "fas fa-palette"
    },
    {
        id: 6,
        category: "educacion",
        catLabel: { es: "Educación", en: "Education" },
        catClass: "cat-educacion",
        titleKey: "conv6_title",
        descKey: "conv6_desc",
        reqKey: "conv6_req",
        amount: { es: "Financiamiento bilateral", en: "Bilateral funding" },
        deadline: "2026-06-01",
        region: { es: "México y Francia", en: "Mexico and France" },
        sourceUrl: "https://secihti.mx/convocatoria/ciencias-y-humanidades/ecos-nord/convocatoria-ecos-nord-2026/",
        sourceName: "SECIHTI",
        status: "abierta",
        statusLabel: { es: "Abierta", en: "Open" },
        icon: "fas fa-globe-americas"
    },
    {
        id: 7,
        category: "salud",
        catLabel: { es: "Salud", en: "Health" },
        catClass: "cat-salud",
        titleKey: "conv7_title",
        descKey: "conv7_desc",
        reqKey: "conv7_req",
        amount: { es: "Premio honorífico", en: "Honorary award" },
        deadline: "2026-06-08",
        region: { es: "México (Nacional)", en: "Mexico (National)" },
        sourceUrl: "https://secihti.mx/convocatoria/desarrollo-tecnologico-vinculacion-e-innovacion/premio-mujeres-en-ciencias-biologicas-y-de-la-salud-matilde-montoya-2/",
        sourceName: "SECIHTI",
        status: "abierta",
        statusLabel: { es: "Abierta", en: "Open" },
        icon: "fas fa-award"
    },
    {
        id: 8,
        category: "salud",
        catLabel: { es: "Salud", en: "Health" },
        catClass: "cat-salud",
        titleKey: "conv8_title",
        descKey: "conv8_desc",
        reqKey: "conv8_req",
        amount: { es: "Beca + viáticos", en: "Scholarship + per diem" },
        deadline: "2026-10-23",
        region: { es: "Nacional e Internacional", en: "National & International" },
        sourceUrl: "https://secihti.mx/convocatoria/becas-al-extranjero/rotaciones-medicas-y-estancias-tecnicas/convocatoria-2026-becas-para-rotaciones-medicas-y-estancias-tecnicas-nacionales-y-en-el-extranjero-alineadas-a-las-prioridades-nacionales-del-sector-salud/",
        sourceName: "SECIHTI",
        status: "abierta",
        statusLabel: { es: "Abierta", en: "Open" },
        icon: "fas fa-stethoscope"
    },
    {
        id: 9,
        category: "tecnologia",
        catLabel: { es: "Tecnología", en: "Technology" },
        catClass: "cat-tecnologia",
        titleKey: "conv9_title",
        descKey: "conv9_desc",
        reqKey: "conv9_req",
        amount: { es: "Inscripción gratuita", en: "Free registration" },
        deadline: "2026-05-22",
        region: { es: "México (Nacional)", en: "Mexico (National)" },
        sourceUrl: "https://secihti.mx/convocatoria/desarrollo-tecnologico-vinculacion-e-innovacion/convocatoria-copa-futbotmx-capitulo-vision-por-computadora/",
        sourceName: "SECIHTI",
        status: "abierta",
        statusLabel: { es: "Abierta", en: "Open" },
        icon: "fas fa-robot"
    }
];

// ===== State =====
let currentLang = "es";
let currentFilter = "todas";
let currentTestimonial = 0;
let isDark = false;

// ===== DOM Elements =====
const themeToggle = document.getElementById("themeToggle");
const themeIcon = document.getElementById("themeIcon");
const langToggle = document.getElementById("langToggle");
const langLabel = langToggle.querySelector(".lang-label");
const hamburger = document.getElementById("hamburger");
const navLinks = document.getElementById("navLinks");
const convGrid = document.getElementById("convGrid");
const modalOverlay = document.getElementById("modalOverlay");
const modal = document.getElementById("modal");
const modalClose = document.getElementById("modalClose");
const modalBody = document.getElementById("modalBody");
const contactForm = document.getElementById("contactForm");
const toast = document.getElementById("toast");
const toastMsg = document.getElementById("toastMsg");
const navbar = document.getElementById("navbar");
const testimonialTrack = document.getElementById("testimonialTrack");
const prevBtn = document.getElementById("prevBtn");
const nextBtn = document.getElementById("nextBtn");
const carouselDots = document.getElementById("carouselDots");

// ===== Theme Toggle =====
function setTheme(dark) {
    isDark = dark;
    document.documentElement.setAttribute("data-theme", dark ? "dark" : "light");
    themeIcon.className = dark ? "fas fa-sun" : "fas fa-moon";
    localStorage.setItem("theme", dark ? "dark" : "light");
}

themeToggle.addEventListener("click", () => setTheme(!isDark));

// Init theme
const savedTheme = localStorage.getItem("theme");
if (savedTheme === "dark" || (!savedTheme && window.matchMedia("(prefers-color-scheme: dark)").matches)) {
    setTheme(true);
}

// ===== Language Toggle =====
function setLanguage(lang) {
    currentLang = lang;
    document.documentElement.lang = lang;
    langLabel.textContent = lang.toUpperCase();

    document.querySelectorAll("[data-i18n]").forEach(el => {
        const key = el.getAttribute("data-i18n");
        if (translations[lang][key]) {
            el.innerHTML = translations[lang][key];
        }
    });

    // Re-render convocatorias
    renderConvocatorias();

    // Update testimonial text
    updateTestimonial();
}

langToggle.addEventListener("click", () => {
    setLanguage(currentLang === "es" ? "en" : "es");
});

// ===== Mobile Menu =====
hamburger.addEventListener("click", () => {
    hamburger.classList.toggle("active");
    navLinks.classList.toggle("active");
});

navLinks.querySelectorAll("a").forEach(link => {
    link.addEventListener("click", () => {
        hamburger.classList.remove("active");
        navLinks.classList.remove("active");
    });
});

// ===== Navbar Scroll =====
let lastScroll = 0;
window.addEventListener("scroll", () => {
    const currentScroll = window.scrollY;
    navbar.classList.toggle("scrolled", currentScroll > 50);
    lastScroll = currentScroll;
});

// ===== Particles =====
function createParticles() {
    const container = document.getElementById("particles");
    for (let i = 0; i < 20; i++) {
        const particle = document.createElement("div");
        particle.classList.add("particle");
        particle.style.left = Math.random() * 100 + "%";
        particle.style.width = (Math.random() * 4 + 3) + "px";
        particle.style.height = particle.style.width;
        particle.style.animationDuration = (Math.random() * 15 + 10) + "s";
        particle.style.animationDelay = (Math.random() * 10) + "s";
        container.appendChild(particle);
    }
}
createParticles();

// ===== Counter Animation =====
function animateCounters() {
    const counters = document.querySelectorAll("[data-count]");
    counters.forEach(counter => {
        if (counter.dataset.animated) return;
        const target = +counter.getAttribute("data-count");
        const rect = counter.getBoundingClientRect();
        if (rect.top < window.innerHeight && rect.bottom > 0) {
            counter.dataset.animated = "true";
            let current = 0;
            const increment = target / 60;
            const timer = setInterval(() => {
                current += increment;
                if (current >= target) {
                    counter.textContent = target.toLocaleString();
                    clearInterval(timer);
                } else {
                    counter.textContent = Math.floor(current).toLocaleString();
                }
            }, 25);
        }
    });
}

window.addEventListener("scroll", animateCounters);
setTimeout(animateCounters, 500);

// ===== Scroll Animations =====
function handleScrollAnimations() {
    document.querySelectorAll("[data-aos]").forEach(el => {
        const rect = el.getBoundingClientRect();
        if (rect.top < window.innerHeight - 80) {
            el.classList.add("aos-animate");
        }
    });
}

window.addEventListener("scroll", handleScrollAnimations);
window.addEventListener("load", handleScrollAnimations);

// ===== Render Convocatorias =====
function formatDate(dateStr) {
    const date = new Date(dateStr + "T00:00:00");
    const options = { year: "numeric", month: "long", day: "numeric" };
    return date.toLocaleDateString(currentLang === "es" ? "es-MX" : "en-US", options);
}

function renderConvocatorias() {
    const filtered = currentFilter === "todas"
        ? convocatorias
        : convocatorias.filter(c => c.category === currentFilter);

    convGrid.innerHTML = filtered.map(conv => `
        <div class="conv-card" data-id="${conv.id}">
            <div class="conv-card-header">
                <span class="conv-category ${conv.catClass}">
                    <i class="${conv.icon}"></i>
                    ${conv.catLabel[currentLang]}
                </span>
                <span class="conv-badge ${conv.status}">${conv.statusLabel[currentLang]}</span>
            </div>
            <div class="conv-card-body">
                <h3>${translations[currentLang][conv.titleKey]}</h3>
                <p>${translations[currentLang][conv.descKey]}</p>
                <div class="conv-meta">
                    <span class="conv-meta-item">
                        <i class="fas fa-calendar-alt"></i>
                        ${formatDate(conv.deadline)}
                    </span>
                    <span class="conv-meta-item">
                        <i class="fas fa-map-marker-alt"></i>
                        ${conv.region[currentLang]}
                    </span>
                </div>
            </div>
            <div class="conv-card-footer">
                <span class="conv-amount">${conv.amount[currentLang]}</span>
                <button class="conv-apply" data-id="${conv.id}">
                    ${translations[currentLang].btn_ver_mas}
                </button>
            </div>
        </div>
    `).join("");

    // Attach click events
    document.querySelectorAll(".conv-card").forEach(card => {
        card.addEventListener("click", (e) => {
            if (e.target.closest(".conv-apply") || e.target.closest(".conv-card")) {
                openModal(+card.dataset.id);
            }
        });
    });
}

// ===== Filters =====
document.querySelectorAll(".filter-btn").forEach(btn => {
    btn.addEventListener("click", () => {
        document.querySelectorAll(".filter-btn").forEach(b => b.classList.remove("active"));
        btn.classList.add("active");
        currentFilter = btn.dataset.filter;
        renderConvocatorias();
    });
});

// ===== Modal =====
function openModal(id) {
    const conv = convocatorias.find(c => c.id === id);
    if (!conv) return;

    const lang = currentLang;
    modalBody.innerHTML = `
        <span class="conv-category ${conv.catClass}" style="margin-bottom: 16px; display: inline-flex;">
            <i class="${conv.icon}"></i>
            ${conv.catLabel[lang]}
        </span>
        <h2>${translations[lang][conv.titleKey]}</h2>
        <p class="modal-desc">${translations[lang][conv.descKey]}</p>
        <div class="modal-details">
            <div class="modal-detail-item">
                <label>${translations[lang].modal_monto_label}</label>
                <span>${conv.amount[lang]}</span>
            </div>
            <div class="modal-detail-item">
                <label>${translations[lang].modal_fecha_label}</label>
                <span>${formatDate(conv.deadline)}</span>
            </div>
            <div class="modal-detail-item">
                <label>${translations[lang].modal_region_label}</label>
                <span>${conv.region[lang]}</span>
            </div>
            <div class="modal-detail-item">
                <label>${translations[lang].modal_categoria_label}</label>
                <span>${conv.catLabel[lang]}</span>
            </div>
            <div class="modal-detail-item">
                <label>${translations[lang].modal_fuente_label || 'Fuente'}</label>
                <span><a href="${conv.sourceUrl || '#'}" target="_blank" rel="noopener" style="color: var(--primary, #6366f1); text-decoration: underline;">${conv.sourceName || 'SECIHTI'}</a></span>
            </div>
        </div>
        <h4 style="margin-bottom: 8px; font-size: 0.95rem;">${translations[lang].modal_requisitos}:</h4>
        <p class="modal-desc" style="margin-bottom: 24px; font-size: 0.9rem;">${translations[lang][conv.reqKey]}</p>
        <button class="btn btn-primary btn-full modal-btn" onclick="window.open('${conv.sourceUrl || '#'}', '_blank')">
            <i class="fas fa-external-link-alt"></i>
            ${translations[lang].btn_ver_fuente}
        </button>
    `;

    modalOverlay.classList.add("active");
    document.body.style.overflow = "hidden";
}

function closeModal() {
    modalOverlay.classList.remove("active");
    document.body.style.overflow = "";
}

modalClose.addEventListener("click", closeModal);
modalOverlay.addEventListener("click", (e) => {
    if (e.target === modalOverlay) closeModal();
});

document.addEventListener("keydown", (e) => {
    if (e.key === "Escape") closeModal();
});

function handleApply() {
    closeModal();
    showToast(translations[currentLang].toast_postulacion);
}

// ===== Toast =====
function showToast(msg) {
    toastMsg.textContent = msg;
    toast.classList.add("show");
    setTimeout(() => toast.classList.remove("show"), 3000);
}

// ===== Contact Form =====
contactForm.addEventListener("submit", (e) => {
    e.preventDefault();
    showToast(translations[currentLang].toast_enviado);
    contactForm.reset();
});

// ===== Testimonial Carousel =====
const totalTestimonials = 3;

function createDots() {
    carouselDots.innerHTML = "";
    for (let i = 0; i < totalTestimonials; i++) {
        const dot = document.createElement("div");
        dot.classList.add("carousel-dot");
        if (i === 0) dot.classList.add("active");
        dot.addEventListener("click", () => goToTestimonial(i));
        carouselDots.appendChild(dot);
    }
}

function goToTestimonial(index) {
    currentTestimonial = index;
    testimonialTrack.style.transform = `translateX(-${index * 100}%)`;
    document.querySelectorAll(".carousel-dot").forEach((dot, i) => {
        dot.classList.toggle("active", i === index);
    });
}

function updateTestimonial() {
    // Testimonial text is updated via data-i18n attributes in HTML
}

prevBtn.addEventListener("click", () => {
    goToTestimonial((currentTestimonial - 1 + totalTestimonials) % totalTestimonials);
});

nextBtn.addEventListener("click", () => {
    goToTestimonial((currentTestimonial + 1) % totalTestimonials);
});

// Auto-play carousel
let autoPlay = setInterval(() => {
    goToTestimonial((currentTestimonial + 1) % totalTestimonials);
}, 5000);

// Pause on hover
document.querySelector(".testimonial-carousel").addEventListener("mouseenter", () => clearInterval(autoPlay));
document.querySelector(".testimonial-carousel").addEventListener("mouseleave", () => {
    autoPlay = setInterval(() => {
        goToTestimonial((currentTestimonial + 1) % totalTestimonials);
    }, 5000);
});

createDots();

// ===== Smooth scroll for anchor links =====
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener("click", (e) => {
        e.preventDefault();
        const target = document.querySelector(anchor.getAttribute("href"));
        if (target) {
            target.scrollIntoView({ behavior: "smooth" });
        }
    });
});

// ===== Init =====
renderConvocatorias();
