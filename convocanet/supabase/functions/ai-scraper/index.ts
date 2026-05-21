// Supabase Edge Function: AI-powered convocatoria scraper
// Runs daily via pg_cron to find new convocatorias

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const claudeApiKey = Deno.env.get("CLAUDE_API_KEY");

const supabase = createClient(supabaseUrl, supabaseKey);

// Sources to scrape
const SOURCES = [
  {
    name: "Gobierno de México",
    url: "https://www.gob.mx/convocatorias",
    country: "México",
  },
  {
    name: "CONACYT México",
    url: "https://www.conacyt.gob.mx/index.php/convocatorias",
    country: "México",
  },
  {
    name: "Gobierno de Colombia",
    url: "https://www.gov.co/convocatorias",
    country: "Colombia",
  },
  {
    name: "Gobierno de Argentina",
    url: "https://www.argentina.gob.ar/convocatorias",
    country: "Argentina",
  },
  {
    name: "Gobierno de Chile",
    url: "https://www.gob.cl/convocatorias",
    country: "Chile",
  },
  {
    name: "Gobierno de Perú",
    url: "https://www.gob.pe/convocatorias",
    country: "Perú",
  },
  {
    name: "Funds for NGOs",
    url: "https://www.fundsforngos.org/latest-funds-for-ngos/",
    country: "Internacional",
  },
];

interface ScrapedConvocatoria {
  title: string;
  description: string;
  source_url: string;
  source_name: string;
  country: string;
  amount_text?: string;
  deadline_text?: string;
}

interface ParsedConvocatoria {
  title_es: string;
  title_en: string;
  description_es: string;
  description_en: string;
  category_slug: string;
  amount_usd: number | null;
  deadline: string | null;
  region_es: string;
  region_en: string;
  source_url: string;
  source_name: string;
  is_public: boolean;
}

// Scrape a source for convocatorias
async function scrapeSource(
  source: (typeof SOURCES)[0]
): Promise<ScrapedConvocatoria[]> {
  try {
    const response = await fetch(source.url, {
      headers: {
        "User-Agent":
          "Mozilla/5.0 (compatible; ConvocaNet/1.0; +https://convocanet.org)",
      },
    });

    if (!response.ok) {
      console.error(`Failed to fetch ${source.url}: ${response.status}`);
      return [];
    }

    const html = await response.text();

    // Basic HTML parsing for convocatoria-like content
    // In production, use more sophisticated parsing per source
    const convocatorias: ScrapedConvocatoria[] = [];

    // Extract title-like elements (h2, h3 with links)
    const titleRegex =
      /<(?:h[2-3]|a)[^>]*>([^<]*(?:convocatoria|beca|fondo|programa|grant|call|fund)[^<]*)<\/(?:h[2-3]|a)>/gi;
    let match;

    while ((match = titleRegex.exec(html)) !== null) {
      const title = match[1].trim();
      if (title.length > 10 && title.length < 200) {
        convocatorias.push({
          title,
          description: "",
          source_url: source.url,
          source_name: source.name,
          country: source.country,
        });
      }
    }

    return convocatorias.slice(0, 10); // Limit per source
  } catch (error) {
    console.error(`Error scraping ${source.name}:`, error);
    return [];
  }
}

// Use Claude to parse and normalize scraped data
async function parseWithClaude(
  scraped: ScrapedConvocatoria[]
): Promise<ParsedConvocatoria[]> {
  if (!claudeApiKey || scraped.length === 0) {
    return scraped.map((s) => ({
      title_es: s.title,
      title_en: s.title,
      description_es: s.description || "Sin descripción disponible",
      description_en: s.description || "No description available",
      category_slug: "social",
      amount_usd: null,
      deadline: null,
      region_es: s.country,
      region_en: s.country,
      source_url: s.source_url,
      source_name: s.source_name,
      is_public: true,
    }));
  }

  const prompt = `Analiza las siguientes convocatorias scraped y devuelve un JSON array con el siguiente formato para cada una:
{
  "title_es": "título en español",
  "title_en": "título en inglés",
  "description_es": "descripción en español",
  "description_en": "descripción en inglés",
  "category_slug": "educacion|salud|medioambiente|cultura|social|tecnologia|genero|alimentacion|transparencia|derechos-humanos",
  "amount_usd": número o null,
  "deadline": "YYYY-MM-DD" o null,
  "region_es": "región en español",
  "region_en": "región en inglés",
  "source_url": "url original",
  "source_name": "nombre de la fuente",
  "is_public": true/false
}

Convocatorias:
${JSON.stringify(scraped, null, 2)}

Responde SOLO con el JSON array, sin texto adicional.`;

  try {
    const response = await fetch("https://api.anthropic.com/v1/messages", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-api-key": claudeApiKey,
        "anthropic-version": "2023-06-01",
      },
      body: JSON.stringify({
        model: "claude-sonnet-4-20250514",
        max_tokens: 4096,
        messages: [{ role: "user", content: prompt }],
      }),
    });

    const data = await response.json();
    const content = data.content?.[0]?.text;

    if (content) {
      // Extract JSON from response
      const jsonMatch = content.match(/\[[\s\S]*\]/);
      if (jsonMatch) {
        return JSON.parse(jsonMatch[0]);
      }
    }
  } catch (error) {
    console.error("Claude API error:", error);
  }

  // Fallback: return scraped data as-is
  return scraped.map((s) => ({
    title_es: s.title,
    title_en: s.title,
    description_es: s.description || "Sin descripción disponible",
    description_en: s.description || "No description available",
    category_slug: "social",
    amount_usd: null,
    deadline: null,
    region_es: s.country,
    region_en: s.country,
    source_url: s.source_url,
    source_name: s.source_name,
    is_public: true,
  }));
}

// Deduplicate against existing convocatorias
async function deduplicate(
  convocatorias: ParsedConvocatoria[]
): Promise<ParsedConvocatoria[]> {
  const titles = convocatorias.map((c) => c.title_es.toLowerCase());

  const { data: existing } = await supabase
    .from("convocatorias")
    .select("title_es")
    .in(
      "title_es",
      convocatorias.map((c) => c.title_es)
    );

  const existingTitles = new Set(
    (existing || []).map((e: any) => e.title_es.toLowerCase())
  );

  return convocatorias.filter(
    (c) => !existingTitles.has(c.title_es.toLowerCase())
  );
}

// Insert new convocatorias into database
async function insertConvocatorias(
  convocatorias: ParsedConvocatoria[]
): Promise<number> {
  let inserted = 0;

  for (const conv of convocatorias) {
    // Get category ID
    const { data: category } = await supabase
      .from("categories")
      .select("id")
      .eq("slug", conv.category_slug)
      .single();

    const { error } = await supabase.from("convocatorias").insert({
      title_es: conv.title_es,
      title_en: conv.title_en,
      description_es: conv.description_es,
      description_en: conv.description_en,
      category_id: category?.id || null,
      amount_usd: conv.amount_usd,
      deadline: conv.deadline,
      region_es: conv.region_es,
      region_en: conv.region_en,
      source_url: conv.source_url,
      source_name: conv.source_name,
      status: "active",
      is_public: conv.is_public,
    });

    if (!error) {
      inserted++;
    } else {
      console.error("Insert error:", error);
    }
  }

  return inserted;
}

// Main handler
serve(async (req) => {
  try {
    console.log("AI Scraper started");

    // 1. Scrape all sources
    const allScraped: ScrapedConvocatoria[] = [];
    for (const source of SOURCES) {
      const scraped = await scrapeSource(source);
      allScraped.push(...scraped);
      console.log(`Scraped ${scraped.length} from ${source.name}`);
    }

    console.log(`Total scraped: ${allScraped.length}`);

    // 2. Parse with Claude
    const parsed = await parseWithClaude(allScraped);
    console.log(`Parsed: ${parsed.length}`);

    // 3. Deduplicate
    const unique = await deduplicate(parsed);
    console.log(`After dedup: ${unique.length}`);

    // 4. Insert into database
    const inserted = await insertConvocatorias(unique);
    console.log(`Inserted: ${inserted}`);

    // 5. Log results
    await supabase.from("audit_log").insert({
      action: "ai_scraper_run",
      entity: "convocatorias",
      details: {
        sources_scraped: SOURCES.length,
        total_scraped: allScraped.length,
        parsed: parsed.length,
        unique: unique.length,
        inserted,
      },
    });

    return new Response(
      JSON.stringify({
        success: true,
        scraped: allScraped.length,
        parsed: parsed.length,
        unique: unique.length,
        inserted,
      }),
      {
        headers: { "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    console.error("Scraper error:", error);
    return new Response(
      JSON.stringify({ success: false, error: (error as Error).message }),
      {
        status: 500,
        headers: { "Content-Type": "application/json" },
      }
    );
  }
});
