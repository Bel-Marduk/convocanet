// Convocatoria sources configuration
// Update this file to add/remove sources for the AI scraper

export interface ConvocatoriaSource {
  name: string;
  url: string;
  country: string;
  language: "es" | "en" | "pt";
  selectors?: {
    title?: string;
    description?: string;
    link?: string;
    amount?: string;
    deadline?: string;
  };
  enabled: boolean;
}

export const CONVOCATORIA_SOURCES: ConvocatoriaSource[] = [
  // ============================================
  // MEXICO — Primary source (verified working)
  // ============================================
  {
    name: "SECIHTI",
    url: "https://secihti.mx/convocatorias/",
    country: "México",
    language: "es",
    enabled: true,
  },
  {
    name: "SECIHTI — Tecnología e Innovación",
    url: "https://secihti.mx/tecnologias-e-innovacion/",
    country: "México",
    language: "es",
    enabled: true,
  },

  // ============================================
  // COLOMBIA
  // ============================================
  {
    name: "MinCiencias",
    url: "https://minciencias.gov.co/convocatorias",
    country: "Colombia",
    language: "es",
    enabled: true,
  },

  // ============================================
  // CHILE
  // ============================================
  {
    name: "ANID Chile",
    url: "https://www.anid.cl/concursos/",
    country: "Chile",
    language: "es",
    enabled: true,
  },

  // ============================================
  // INTERNATIONAL — Verified accessible
  // ============================================
  {
    name: "OAS Scholarships",
    url: "https://www.oas.org/en/scholarships/",
    country: "Internacional",
    language: "es",
    enabled: true,
  },
  {
    name: "Chevening",
    url: "https://www.chevening.org/scholarships/",
    country: "Internacional",
    language: "en",
    enabled: true,
  },
  {
    name: "DAAD Scholarship Database",
    url: "https://www2.daad.de/deutschland/stipendium/datenbank/en/21148-scholarship-database/",
    country: "Internacional",
    language: "en",
    enabled: true,
  },
  {
    name: "Erasmus Mundus Catalogue",
    url: "https://erasmus-plus.ec.europa.eu/opportunities/opportunities-for-individuals/students/erasmus-mundus-joint-masters",
    country: "Internacional",
    language: "en",
    enabled: true,
  },
  {
    name: "Wellcome Trust Grants",
    url: "https://wellcome.org/grant-funding/guidance/applying-funding",
    country: "Internacional",
    language: "en",
    enabled: true,
  },
  {
    name: "Google PhD Fellowship",
    url: "https://research.google/outreach/phd-fellowship/",
    country: "Internacional",
    language: "en",
    enabled: true,
  },
  {
    name: "CERN Careers",
    url: "https://careers.cern/",
    country: "Internacional",
    language: "en",
    enabled: true,
  },

  // ============================================
  // DISABLED — Broken URLs (404, timeout, blocked)
  // Re-enable if URLs are fixed
  // ============================================
  // gob.mx/convocatorias → 404
  // conahcyt.mx → redirects to secihti.mx (now listed above)
  // infonavit.org.mx → timeout
  // gov.co/convocatorias → timeout
  // argentina.gob.ar → timeout
  // gob.cl/convocatorias → timeout
  // gob.pe/convocatorias → timeout
  // foncodes.gob.pe → timeout
  // USAID → timeout
  // IDB → timeout
  // European Commission → JS-only rendering, scraper can't parse
  // World Bank → 404
  // Ford Foundation → no unsolicited grants
  // Open Society → no open grants
  // MacArthur → blocked
  // Rockefeller → no unsolicited grants
  // Mastercard Foundation → blocked
  // Skoll Foundation → timeout
  // Kellogg Foundation → timeout
  // Avina Foundation → timeout
  // Google.org → no specific grant listings
  // Microsoft Philanthropies → blocked
  // Salesforce.org → timeout
  // ScholarshipPortal → redirects to mastersportal.com
  // Funds for NGOs → Cloudflare blocked
  // NGO Jobsite → timeout
];

// Get enabled sources
export function getEnabledSources(): ConvocatoriaSource[] {
  return CONVOCATORIA_SOURCES.filter((s) => s.enabled);
}

// Get sources by country
export function getSourcesByCountry(country: string): ConvocatoriaSource[] {
  return CONVOCATORIA_SOURCES.filter(
    (s) => s.enabled && s.country === country
  );
}
