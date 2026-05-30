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
  // MEXICO
  // ============================================
  {
    name: "Gobierno de México",
    url: "https://www.gob.mx/convocatorias",
    country: "México",
    language: "es",
    enabled: true,
  },
  {
    name: "CONAHCYT",
    url: "https://conahcyt.mx/convocatorias/",
    country: "México",
    language: "es",
    enabled: true,
  },
  {
    name: "INFONAVIT",
    url: "https://www.infonavit.org.mx/wps/wcm/connect/infonavit/investigacion/convocatorias",
    country: "México",
    language: "es",
    enabled: true,
  },

  // ============================================
  // COLOMBIA
  // ============================================
  {
    name: "Gobierno de Colombia",
    url: "https://www.gov.co/convocatorias",
    country: "Colombia",
    language: "es",
    enabled: true,
  },
  {
    name: "MinCiencias",
    url: "https://minciencias.gov.co/convocatorias",
    country: "Colombia",
    language: "es",
    enabled: true,
  },

  // ============================================
  // ARGENTINA
  // ============================================
  {
    name: "Gobierno de Argentina",
    url: "https://www.argentina.gob.ar/convocatorias",
    country: "Argentina",
    language: "es",
    enabled: true,
  },

  // ============================================
  // CHILE
  // ============================================
  {
    name: "Gobierno de Chile",
    url: "https://www.gob.cl/convocatorias",
    country: "Chile",
    language: "es",
    enabled: true,
  },
  {
    name: "ANID Chile",
    url: "https://www.anid.cl/concursos/",
    country: "Chile",
    language: "es",
    enabled: true,
  },

  // ============================================
  // PERU
  // ============================================
  {
    name: "Gobierno de Perú",
    url: "https://www.gob.pe/convocatorias",
    country: "Perú",
    language: "es",
    enabled: true,
  },
  {
    name: "FONCODES",
    url: "https://www.foncodes.gob.pe/convocatorias",
    country: "Perú",
    language: "es",
    enabled: true,
  },

  // ============================================
  // INTERNATIONAL GOVERNMENT / MULTILATERAL
  // ============================================
  {
    name: "USAID",
    url: "https://www.usaid.gov/work-usaid/partnership-opportunities",
    country: "Internacional",
    language: "en",
    enabled: true,
  },
  {
    name: "IDB",
    url: "https://www.iadb.org/en/opportunities",
    country: "Internacional",
    language: "en",
    enabled: true,
  },
  {
    name: "European Commission",
    url: "https://ec.europa.eu/info/funding-tenders/opportunities/portal/",
    country: "Internacional",
    language: "en",
    enabled: true,
  },
  {
    name: "World Bank Grants",
    url: "https://www.worldbank.org/en/grants",
    country: "Internacional",
    language: "en",
    enabled: true,
  },
  {
    name: "OAS Scholarships",
    url: "https://www.oas.org/en/scholarships/",
    country: "Internacional",
    language: "es",
    enabled: true,
  },

  // ============================================
  // PRIVATE PHILANTHROPY FOUNDATIONS
  // ============================================
  {
    name: "Ford Foundation",
    url: "https://www.fordfoundation.org/work/our-grants/",
    country: "Internacional",
    language: "en",
    enabled: true,
  },
  {
    name: "Open Society Foundations",
    url: "https://www.opensocietyfoundations.org/grants",
    country: "Internacional",
    language: "en",
    enabled: true,
  },
  {
    name: "MacArthur Foundation",
    url: "https://www.macfound.org/programs",
    country: "Internacional",
    language: "en",
    enabled: true,
  },
  {
    name: "Rockefeller Foundation",
    url: "https://www.rockefellerfoundation.org/what-we-do/",
    country: "Internacional",
    language: "en",
    enabled: true,
  },
  {
    name: "Mastercard Foundation",
    url: "https://mastercardfdn.org/en/our-work/",
    country: "Internacional",
    language: "en",
    enabled: true,
  },
  {
    name: "Skoll Foundation",
    url: "https://www.skoll.org/awardees/",
    country: "Internacional",
    language: "en",
    enabled: true,
  },
  {
    name: "Kellogg Foundation",
    url: "https://www.wkkf.org/grants",
    country: "Internacional",
    language: "en",
    enabled: true,
  },
  {
    name: "Wellcome Trust",
    url: "https://wellcome.org/what-we-do/grants",
    country: "Internacional",
    language: "en",
    enabled: true,
  },
  {
    name: "Avina Foundation",
    url: "https://avina.net/en/what-we-do/",
    country: "Internacional",
    language: "en",
    enabled: true,
  },

  // ============================================
  // CORPORATE GIVING PROGRAMS
  // ============================================
  {
    name: "Google.org",
    url: "https://www.google.org/",
    country: "Internacional",
    language: "en",
    enabled: true,
  },
  {
    name: "Microsoft Philanthropies",
    url: "https://www.microsoft.com/en-us/philanthropies",
    country: "Internacional",
    language: "en",
    enabled: true,
  },
  {
    name: "Salesforce.org",
    url: "https://www.salesforce.org/",
    country: "Internacional",
    language: "en",
    enabled: true,
  },

  // ============================================
  // SCHOLARSHIP AGGREGATORS
  // ============================================
  {
    name: "ScholarshipPortal",
    url: "https://www.scholarshipportal.com/scholarships/latin-america",
    country: "Internacional",
    language: "en",
    enabled: true,
  },
  {
    name: "Chevening",
    url: "https://www.chevening.org/scholarships/",
    country: "Internacional",
    language: "en",
    enabled: true,
  },

  // ============================================
  // NGO / GRANT AGGREGATORS
  // ============================================
  {
    name: "Funds for NGOs",
    url: "https://www.fundsforngos.org/latest-funds-for-ngos/",
    country: "Internacional",
    language: "en",
    enabled: true,
  },
  {
    name: "NGO Jobsite",
    url: "https://www.ngojobsite.com/jobs/funding/",
    country: "Internacional",
    language: "en",
    enabled: true,
  },
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
