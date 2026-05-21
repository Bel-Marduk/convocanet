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
        filter_ambiente: "Medio Ambiente",
        filter_cultura: "Cultura",
        filter_social: "Desarrollo Social",
        btn_postular: "Postular",
        btn_ver_mas: "Ver más",
        // Convocatoria modal
        modal_requisitos: "Requisitos",
        modal_monto_label: "Monto",
        modal_fecha_label: "Fecha límite",
        modal_region_label: "Región",
        modal_categoria_label: "Categoría",
        modal_postular: "Postular a esta convocatoria",
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
        // Convocatoria data
        conv1_title: "Fondo de Innovación Educativa 2026",
        conv1_desc: "Programa de financiamiento para proyectos educativos que busquen mejorar la calidad de la educación en comunidades rurales y urbanas marginadas mediante metodologías innovadoras.",
        conv1_req: "Ser A.C. constituida hace al menos 2 años, contar con RFC vigente, experiencia comprobable en proyectos educativos, presentar plan de trabajo detallado.",
        conv2_title: "Programa de Salud Comunitaria Integral",
        conv2_desc: "Convocatoria dirigida a asociaciones que implementen programas de prevención, atención primaria y promoción de la salud en zonas de alta vulnerabilidad social.",
        conv2_req: "A.C. con experiencia en el sector salud, convenio con instituciones de salud, personal capacitado, cobertura mínima de 500 beneficiarios.",
        conv3_title: "Beca Verde: Restauración Ecológica",
        conv3_desc: "Financiamiento para proyectos de reforestación, restauración de ecosistemas y conservación de biodiversidad liderados por organizaciones de la sociedad civil.",
        conv3_req: "A.C. ambientalista, proyecto en zona prioritaria de conservación, alianza con ejido o comunidad, compromiso de co-financiamiento del 20%.",
        conv4_title: "Impulso Cultural: Arte y Comunidad",
        conv4_desc: "Apoyo económico para proyectos artísticos y culturales que promuevan la identidad local, la inclusión social y el acceso democrático a la cultura.",
        conv4_req: "A.C. cultural, mínimo 3 años de actividad continua, sede propia o convenio de espacio, plan de sustentabilidad a 3 años.",
        conv5_title: "Fondo de Desarrollo Social Local",
        conv5_desc: "Programa de fortalecimiento comunitario que financia proyectos de infraestructura social, generación de empleo y participación ciudadana.",
        conv5_req: "A.C. con presencia comunitaria demostrable, acta de asamblea comunitaria, contraparte del 30%, informes de impacto anteriores.",
        conv6_title: "Convocatoria de Tecnología Social",
        conv6_desc: "Fondo para proyectos que utilicen la tecnología como herramienta de inclusión social, desarrollo comunitario y reducción de brechas digitales.",
        conv6_req: "A.C. con experiencia en tecnología, proyecto escalable, alianza con empresa tech, plan de capacitación digital incluido.",
        conv7_title: "Programa Mujeres Líderes 2026",
        conv7_desc: "Convocatoria especial para asociaciones lideradas por mujeres que promuevan la equidad de género, el empoderamiento femenino y la prevención de violencia.",
        conv7_req: "A.C. con liderazgo femenino comprobable, programa de acompañamiento psicológico, alianza con red de mujeres, informe de género.",
        conv8_title: "Fondo de Transparencia y Gobernanza",
        conv8_desc: "Financiamiento para proyectos que fortalezcan la transparencia, el acceso a la información pública y la participación ciudadana en la toma de decisiones.",
        conv8_req: "A.C. enfocada en gobernanza, experiencia en incidencia política, red de aliados institucionales, compromiso de divulgación de resultados.",
        conv9_title: "Beca de Alimentación y Nutrición",
        conv9_desc: "Programa dirigido a asociaciones que combatan la inseguridad alimentaria mediante huertos comunitarios, bancos de alimentos y educación nutricional.",
        conv9_req: "A.C. con programa alimentario activo, convenio con DIF o similar, infraestructura de distribución, cobertura mínima de 200 familias."
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
        filter_ambiente: "Environment",
        filter_cultura: "Culture",
        filter_social: "Social Development",
        btn_postular: "Apply",
        btn_ver_mas: "View more",
        // Modal
        modal_requisitos: "Requirements",
        modal_monto_label: "Amount",
        modal_fecha_label: "Deadline",
        modal_region_label: "Region",
        modal_categoria_label: "Category",
        modal_postular: "Apply to this call",
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
        // Convocatoria data
        conv1_title: "Educational Innovation Fund 2026",
        conv1_desc: "Funding program for educational projects seeking to improve education quality in rural and marginalized urban communities through innovative methodologies.",
        conv1_req: "A.C. established for at least 2 years, valid tax ID (RFC), verifiable experience in educational projects, detailed work plan.",
        conv2_title: "Comprehensive Community Health Program",
        conv2_desc: "Call for associations implementing prevention, primary care, and health promotion programs in areas of high social vulnerability.",
        conv2_req: "A.C. with health sector experience, agreement with health institutions, trained staff, minimum coverage of 500 beneficiaries.",
        conv3_title: "Green Grant: Ecological Restoration",
        conv3_desc: "Funding for reforestation, ecosystem restoration, and biodiversity conservation projects led by civil society organizations.",
        conv3_req: "Environmental A.C., project in a priority conservation area, alliance with ejido or community, 20% co-funding commitment.",
        conv4_title: "Cultural Boost: Art & Community",
        conv4_desc: "Financial support for artistic and cultural projects that promote local identity, social inclusion, and democratic access to culture.",
        conv4_req: "Cultural A.C., minimum 3 years of continuous activity, own venue or space agreement, 3-year sustainability plan.",
        conv5_title: "Local Social Development Fund",
        conv5_desc: "Community strengthening program financing social infrastructure projects, job creation, and citizen participation.",
        conv5_req: "A.C. with demonstrable community presence, community assembly minutes, 30% counterpart funding, previous impact reports.",
        conv6_title: "Social Technology Call",
        conv6_desc: "Fund for projects using technology as a tool for social inclusion, community development, and bridging digital divides.",
        conv6_req: "Tech-experienced A.C., scalable project, tech company alliance, digital training plan included.",
        conv7_title: "Women Leaders Program 2026",
        conv7_desc: "Special call for women-led associations promoting gender equity, female empowerment, and violence prevention.",
        conv7_req: "A.C. with proven female leadership, psychological support program, women's network alliance, gender report.",
        conv8_title: "Transparency & Governance Fund",
        conv8_desc: "Funding for projects strengthening transparency, public information access, and citizen participation in decision-making.",
        conv8_req: "Governance-focused A.C., policy advocacy experience, institutional allies network, results dissemination commitment.",
        conv9_title: "Food & Nutrition Grant",
        conv9_desc: "Program for associations combating food insecurity through community gardens, food banks, and nutritional education.",
        conv9_req: "A.C. with active food program, agreement with DIF or similar, distribution infrastructure, minimum coverage of 200 families."
    }
};

// ===== Convocatorias Data =====
const convocatorias = [
    {
        id: 1,
        category: "educacion",
        catLabel: { es: "Educación", en: "Education" },
        catClass: "cat-educacion",
        titleKey: "conv1_title",
        descKey: "conv1_desc",
        reqKey: "conv1_req",
        amount: { es: "$850,000 MXN", en: "$50,000 USD" },
        deadline: "2026-07-15",
        region: { es: "Nacional", en: "National" },
        status: "abierta",
        statusLabel: { es: "Abierta", en: "Open" },
        icon: "fas fa-graduation-cap"
    },
    {
        id: 2,
        category: "salud",
        catLabel: { es: "Salud", en: "Health" },
        catClass: "cat-salud",
        titleKey: "conv2_title",
        descKey: "conv2_desc",
        reqKey: "conv2_req",
        amount: { es: "$1,200,000 MXN", en: "$70,600 USD" },
        deadline: "2026-08-01",
        region: { es: "Centro y Sur", en: "Central & Southern" },
        status: "abierta",
        statusLabel: { es: "Abierta", en: "Open" },
        icon: "fas fa-heartbeat"
    },
    {
        id: 3,
        category: "medioambiente",
        catLabel: { es: "Medio Ambiente", en: "Environment" },
        catClass: "cat-medioambiente",
        titleKey: "conv3_title",
        descKey: "conv3_desc",
        reqKey: "conv3_req",
        amount: { es: "$650,000 MXN", en: "$38,200 USD" },
        deadline: "2026-06-30",
        region: { es: "Sureste", en: "Southeast" },
        status: "abierta",
        statusLabel: { es: "Abierta", en: "Open" },
        icon: "fas fa-leaf"
    },
    {
        id: 4,
        category: "cultura",
        catLabel: { es: "Cultura", en: "Culture" },
        catClass: "cat-cultura",
        titleKey: "conv4_title",
        descKey: "conv4_desc",
        reqKey: "conv4_req",
        amount: { es: "$450,000 MXN", en: "$26,500 USD" },
        deadline: "2026-09-15",
        region: { es: "Nacional", en: "National" },
        status: "proxima",
        statusLabel: { es: "Próxima", en: "Coming Soon" },
        icon: "fas fa-palette"
    },
    {
        id: 5,
        category: "social",
        catLabel: { es: "Desarrollo Social", en: "Social Development" },
        catClass: "cat-social",
        titleKey: "conv5_title",
        descKey: "conv5_desc",
        reqKey: "conv5_req",
        amount: { es: "$980,000 MXN", en: "$57,600 USD" },
        deadline: "2026-07-31",
        region: { es: "Norte y Centro", en: "Northern & Central" },
        status: "abierta",
        statusLabel: { es: "Abierta", en: "Open" },
        icon: "fas fa-people-carry"
    },
    {
        id: 6,
        category: "social",
        catLabel: { es: "Desarrollo Social", en: "Social Development" },
        catClass: "cat-social",
        titleKey: "conv6_title",
        descKey: "conv6_desc",
        reqKey: "conv6_req",
        amount: { es: "$720,000 MXN", en: "$42,350 USD" },
        deadline: "2026-08-20",
        region: { es: "Nacional", en: "National" },
        status: "abierta",
        statusLabel: { es: "Abierta", en: "Open" },
        icon: "fas fa-laptop-code"
    },
    {
        id: 7,
        category: "social",
        catLabel: { es: "Desarrollo Social", en: "Social Development" },
        catClass: "cat-social",
        titleKey: "conv7_title",
        descKey: "conv7_desc",
        reqKey: "conv7_req",
        amount: { es: "$560,000 MXN", en: "$32,950 USD" },
        deadline: "2026-06-15",
        region: { es: "Nacional", en: "National" },
        status: "abierta",
        statusLabel: { es: "Abierta", en: "Open" },
        icon: "fas fa-venus"
    },
    {
        id: 8,
        category: "social",
        catLabel: { es: "Desarrollo Social", en: "Social Development" },
        catClass: "cat-social",
        titleKey: "conv8_title",
        descKey: "conv8_desc",
        reqKey: "conv8_req",
        amount: { es: "$380,000 MXN", en: "$22,350 USD" },
        deadline: "2026-09-30",
        region: { es: "Nacional", en: "National" },
        status: "proxima",
        statusLabel: { es: "Próxima", en: "Coming Soon" },
        icon: "fas fa-balance-scale"
    },
    {
        id: 9,
        category: "salud",
        catLabel: { es: "Salud", en: "Health" },
        catClass: "cat-salud",
        titleKey: "conv9_title",
        descKey: "conv9_desc",
        reqKey: "conv9_req",
        amount: { es: "$530,000 MXN", en: "$31,200 USD" },
        deadline: "2026-07-10",
        region: { es: "Centro y Occidente", en: "Central & Western" },
        status: "abierta",
        statusLabel: { es: "Abierta", en: "Open" },
        icon: "fas fa-utensils"
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
        </div>
        <h4 style="margin-bottom: 8px; font-size: 0.95rem;">${translations[lang].modal_requisitos}:</h4>
        <p class="modal-desc" style="margin-bottom: 24px; font-size: 0.9rem;">${translations[lang][conv.reqKey]}</p>
        <button class="btn btn-primary btn-full modal-btn" onclick="handleApply()">
            <i class="fas fa-paper-plane"></i>
            ${translations[lang].modal_postular}
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
