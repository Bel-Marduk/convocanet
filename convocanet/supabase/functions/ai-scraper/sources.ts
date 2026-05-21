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
  // Mexico
  {
    name: "Gobierno de México",
    url: "https://www.gob.mx/convocatorias",
    country: "México",
    language: "es",
    enabled: true,
  },
  {
    name: "CONACYT",
    url: "https://www.conacyt.gob.mx/index.php/convocatorias",
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

  // Colombia
  {
    name: "Gobierno de Colombia",
    url: "https://www.gov.co/convocatorias",
    country: "Colombia",
    language: "es",
    enabled: true,
  },
  {
    name: "Colciencias",
    url: "https://www.colciencias.gov.co/convocatorias",
    country: "Colombia",
    language: "es",
    enabled: true,
  },

  // Argentina
  {
    name: "Gobierno de Argentina",
    url: "https://www.argentina.gob.ar/convocatorias",
    country: "Argentina",
    language: "es",
    enabled: true,
  },

  // Chile
  {
    name: "Gobierno de Chile",
    url: "https://www.gob.cl/convocatorias",
    country: "Chile",
    language: "es",
    enabled: true,
  },
  {
    name: "CNCA Chile",
    url: "https://www.cnca.cl/convocatorias",
    country: "Chile",
    language: "es",
    enabled: true,
  },

  // Peru
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

  // International
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
    name: "Ford Foundation",
    url: "https://www.fordfoundation.org/work/our-grants/",
    country: "Internacional",
    language: "en",
    enabled: true,
  },

  // Aggregators
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
