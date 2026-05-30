// Supabase Edge Function: AI-powered convocatoria scraper
// Runs daily via GitHub Actions cron
// Uses Claude Haiku for minimal cost (~$0.09/year)

import { getEnabledSources, ConvocatoriaSource } from "./sources.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const claudeApiKey = Deno.env.get("CLAUDE_API_KEY");

const supabase = createClient(supabaseUrl, supabaseKey);

interface ScrapedConvocatoria {
  title: string;
  description: string;
  source_url: string;
  source_name: string;
  country: string;
  language: string;
}

interface ParsedConvocatoria {
  title_es: string;
  title_en: string;
  description_es: string;
  description_en: string;
  category_slug: string;
  amount_local: number | null;
  currency: string;
  deadline: string | null;
  region_es: string;
  region_en: string;
  source_url: string;
  source_name: string;
  is_public: boolean;
  is_permanent: boolean;
}

// Normalize text for dedup: lowercase, strip accents, collapse spaces
function normalize(text: string): string {
  return text
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/\s+/g, " ")
    .trim();
}

// Check if two titles are similar enough to be duplicates (>= 80% overlap)
function titlesAreSimilar(a: string, b: string): boolean {
  const na = normalize(a);
  const nb = normalize(b);
  if (na === nb) return true;
  if (na.includes(nb) || nb.includes(na)) return true;
  // Word overlap ratio
  const wordsA = new Set(na.split(" ").filter((w) => w.length > 3));
  const wordsB = new Set(nb.split(" ").filter((w) => w.length > 3));
  if (wordsA.size === 0 || wordsB.size === 0) return false;
  let overlap = 0;
  for (const w of wordsA) if (wordsB.has(w)) overlap++;
  return overlap / Math.max(wordsA.size, wordsB.size) >= 0.8;
}

// Scrape a source for convocatoria-like links
async function scrapeSource(
  source: ConvocatoriaSource
): Promise<ScrapedConvocatoria[]> {
  try {
    const response = await fetch(source.url, {
      headers: {
        "User-Agent":
          "Mozilla/5.0 (compatible; ConvocaNet/1.0; +https://bel-marduk.github.io/convocanet/)",
      },
      redirect: "follow",
    });

    if (!response.ok) {
      console.error(`[SKIP] ${source.name}: HTTP ${response.status}`);
      return [];
    }

    const html = await response.text();

    // Extract all links with text
    const linkRegex = /<a[^>]*href="([^"]*)"[^>]*>(.*?)<\/a>/gis;
    const convocatorias: ScrapedConvocatoria[] = [];
    const seen = new Set<string>();
    let match;

    while ((match = linkRegex.exec(html)) !== null) {
      const href = match[1].trim();
      const text = match[2].replace(/<[^>]*>/g, "").trim();

      // Filter: reasonable length, looks like a convocatoria, not a nav/footer link
      if (text.length < 15 || text.length > 300) continue;
      if (seen.has(text.toLowerCase())) continue;

      const keywords =
        /convocatoria|beca|fondo|programa|grant|call|fund|scholarship|fellowship|oportunidad|apoyo|financiamiento|subsidio|donacion|donation|proposal|solicitud/i;
      if (!keywords.test(text)) continue;

      seen.add(text.toLowerCase());

      // Build absolute URL
      let fullUrl = href;
      if (href.startsWith("/")) {
        const base = new URL(source.url);
        fullUrl = `${base.origin}${href}`;
      } else if (!href.startsWith("http")) {
        fullUrl = `${source.url}/${href}`;
      }

      convocatorias.push({
        title: text,
        description: "",
        source_url: fullUrl,
        source_name: source.name,
        country: source.country,
        language: source.language,
      });
    }

    // Also extract h2/h3 titles without links
    const titleRegex = /<h[2-3][^>]*>(.*?)<\/h[2-3]>/gis;
    while ((match = titleRegex.exec(html)) !== null) {
      const text = match[1].replace(/<[^>]*>/g, "").trim();
      if (text.length < 15 || text.length > 200) continue;
      if (seen.has(text.toLowerCase())) continue;

      const keywords =
        /convocatoria|beca|fondo|programa|grant|call|fund|scholarship|fellowship/i;
      if (!keywords.test(text)) continue;

      seen.add(text.toLowerCase());
      convocatorias.push({
        title: text,
        description: "",
        source_url: source.url,
        source_name: source.name,
        country: source.country,
        language: source.language,
      });
    }

    return convocatorias.slice(0, 15);
  } catch (error) {
    console.error(`[ERROR] ${source.name}:`, error);
    return [];
  }
}

// Use Claude Haiku to parse and normalize scraped data
async function parseWithClaude(
  scraped: ScrapedConvocatoria[]
): Promise<ParsedConvocatoria[]> {
  if (!claudeApiKey || scraped.length === 0) {
    return scraped.map((s) => ({
      title_es: s.language === "es" ? s.title : "",
      title_en: s.language === "en" ? s.title : "",
      description_es: s.language === "es" ? s.description || "Sin descripción" : "",
      description_en: s.language === "en" ? s.description || "No description" : "",
      category_slug: "social",
      amount_local: null,
      currency: "USD",
      deadline: null,
      region_es: s.country,
      region_en: s.country,
      source_url: s.source_url,
      source_name: s.source_name,
      is_public: true,
      is_permanent: true,
    }));
  }

  // Batch all items in a single prompt to minimize API calls
  const items = scraped.map((s, i) => ({
    i,
    title: s.title,
    desc: s.description,
    country: s.country,
    lang: s.language,
    url: s.source_url,
    src: s.source_name,
  }));

  const prompt = `Eres un extractor de convocatorias (becas, grants, fondos, programas).
Analiza esta lista y devuelve un JSON array.

Para cada item:
- "i": mismo índice
- "title_es": título en español (si original es inglés, traducir)
- "title_en": título en inglés (si original es español, traducir)
- "desc_es": descripción corta en español (máx 100 palabras)
- "desc_en": descripción corta en inglés (máx 100 palabras)
- "cat": uno de: educacion|salud|medioambiente|cultura|social|tecnologia|genero|alimentacion|transparencia|derechos-humanos
- "amt": monto numérico o null si no se menciona
- "cur": código de moneda (USD, MXN, EUR, etc.) o "USD" si no se menciona
- "dl": fecha límite YYYY-MM-DD o null si no hay fecha o es permanente
- "perm": true si es permanente/sin fecha límite, false si tiene deadline
- "reg": país/región

Items:
${JSON.stringify(items)}

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
        model: "claude-haiku-4-20250414",
        max_tokens: 4096,
        messages: [{ role: "user", content: prompt }],
      }),
    });

    const data = await response.json();
    const content = data.content?.[0]?.text;

    if (content) {
      const jsonMatch = content.match(/\[[\s\S]*\]/);
      if (jsonMatch) {
        const parsed = JSON.parse(jsonMatch[0]) as any[];
        return parsed.map((p) => {
          const original = scraped[p.i] || scraped[0];
          return {
            title_es: p.title_es || "",
            title_en: p.title_en || "",
            description_es: p.desc_es || "Sin descripción",
            description_en: p.desc_en || "No description",
            category_slug: p.cat || "social",
            amount_local: typeof p.amt === "number" ? p.amt : null,
            currency: p.cur || "USD",
            deadline: p.dl || null,
            region_es: p.reg || original.country,
            region_en: p.reg || original.country,
            source_url: original.source_url,
            source_name: original.source_name,
            is_public: true,
            is_permanent: p.perm === true || p.dl === null,
          };
        });
      }
    }
  } catch (error) {
    console.error("Claude API error:", error);
  }

  // Fallback: return scraped data as-is
  return scraped.map((s) => ({
    title_es: s.language === "es" ? s.title : "",
    title_en: s.language === "en" ? s.title : "",
    description_es: s.language === "es" ? s.description || "Sin descripción" : "",
    description_en: s.language === "en" ? s.description || "No description" : "",
    category_slug: "social",
    amount_local: null,
    currency: "USD",
    deadline: null,
    region_es: s.country,
    region_en: s.country,
    source_url: s.source_url,
    source_name: s.source_name,
    is_public: true,
    is_permanent: true,
  }));
}

// Deduplicate against existing convocatorias (title + URL + fuzzy)
async function deduplicate(
  convocatorias: ParsedConvocatoria[]
): Promise<ParsedConvocatoria[]> {
  if (convocatorias.length === 0) return [];

  const urls = convocatorias
    .map((c) => c.source_url)
    .filter((u) => u && u.length > 0);

  // Fetch existing titles and URLs for comparison
  const { data: existing } = await supabase
    .from("convocatorias")
    .select("title_es, source_url");

  const existingList = (existing || []) as { title_es: string; source_url: string | null }[];

  return convocatorias.filter((c) => {
    // Skip if title is empty
    if (!c.title_es && !c.title_en) return false;

    const checkTitle = c.title_es || c.title_en;

    for (const e of existingList) {
      // URL match → duplicate
      if (c.source_url && e.source_url && c.source_url === e.source_url) {
        return false;
      }
      // Title fuzzy match → duplicate
      if (e.title_es && titlesAreSimilar(checkTitle, e.title_es)) {
        return false;
      }
    }
    return true;
  });
}

// Insert new convocatorias via admin RPC
async function insertConvocatorias(
  convocatorias: ParsedConvocatoria[]
): Promise<number> {
  let inserted = 0;

  for (const conv of convocatorias) {
    // Skip if both titles are empty
    if (!conv.title_es && !conv.title_en) continue;

    // Get category ID
    const { data: category } = await supabase
      .from("categories")
      .select("id")
      .eq("slug", conv.category_slug)
      .maybeSingle();

    const status = conv.is_permanent || !conv.deadline ? "permanent" : "active";

    const payload: Record<string, unknown> = {
      title_es: conv.title_es || conv.title_en,
      title_en: conv.title_en || conv.title_es,
      description_es: conv.description_es,
      description_en: conv.description_en,
      currency: conv.currency || "USD",
      status,
      is_public: conv.is_public,
      source_url: conv.source_url,
      source_name: conv.source_name,
      region_es: conv.region_es,
      region_en: conv.region_en,
    };

    if (category?.id) payload.category_id = category.id;
    if (conv.amount_local != null) payload.amount_local = conv.amount_local;
    if (conv.deadline) payload.deadline = conv.deadline;

    const { error } = await supabase.rpc("admin_insert_convocatoria", {
      p_data: payload,
    });

    if (!error) {
      inserted++;
    } else {
      console.error("Insert error:", error.message);
    }
  }

  return inserted;
}

// Main handler
Deno.serve(async (_req) => {
  try {
    const startTime = Date.now();
    console.log("AI Scraper started");

    const sources = getEnabledSources();
    console.log(`Sources enabled: ${sources.length}`);

    // 1. Scrape all sources (parallel with concurrency limit)
    const allScraped: ScrapedConvocatoria[] = [];
    const batchSize = 5;
    for (let i = 0; i < sources.length; i += batchSize) {
      const batch = sources.slice(i, i + batchSize);
      const results = await Promise.all(batch.map(scrapeSource));
      for (let j = 0; j < results.length; j++) {
        allScraped.push(...results[j]);
        if (results[j].length > 0) {
          console.log(`  ${batch[j].name}: ${results[j].length} items`);
        }
      }
    }
    console.log(`Total scraped: ${allScraped.length}`);

    // 2. Parse with Claude Haiku (single batch call)
    const parsed = await parseWithClaude(allScraped);
    console.log(`Parsed: ${parsed.length}`);

    // 3. Deduplicate against DB
    const unique = await deduplicate(parsed);
    console.log(`After dedup: ${unique.length}`);

    // 4. Insert into database
    const inserted = await insertConvocatorias(unique);
    console.log(`Inserted: ${inserted}`);

    const elapsed = ((Date.now() - startTime) / 1000).toFixed(1);

    // 5. Log results
    await supabase.from("audit_log").insert({
      action: "ai_scraper_run",
      entity: "convocatorias",
      details: {
        sources_enabled: sources.length,
        total_scraped: allScraped.length,
        parsed: parsed.length,
        unique: unique.length,
        inserted,
        elapsed_s: parseFloat(elapsed),
      },
    });

    return new Response(
      JSON.stringify({
        success: true,
        sources: sources.length,
        scraped: allScraped.length,
        parsed: parsed.length,
        unique: unique.length,
        inserted,
        elapsed: `${elapsed}s`,
      }),
      { headers: { "Content-Type": "application/json" } }
    );
  } catch (error) {
    console.error("Scraper error:", error);
    return new Response(
      JSON.stringify({ success: false, error: (error as Error).message }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }
});
