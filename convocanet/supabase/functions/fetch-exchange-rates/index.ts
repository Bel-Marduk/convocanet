// Supabase Edge Function: Fetch daily exchange rates
// Source: frankfurter.app (ECB data, no API key needed)
// Converts: rate_to_usd = 1 / rate (inverse of USD-based rates)

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const supabase = createClient(supabaseUrl, supabaseKey);

// Currencies used in ConvocaNet (from edit_convocatoria_screen.dart)
const CURRENCIES = [
  "MXN", "EUR", "GBP", "CAD", "BRL", "ARS", "COP", "CLP", "PEN",
  "GTQ", "CRC", "PAB", "BOB", "PYG", "UYU", "HNL", "NIO", "DOP",
];

Deno.serve(async (_req) => {
  try {
    // Fetch latest rates from frankfurter.app (base = USD)
    const apiUrl = `https://api.frankfurter.app/latest?from=USD&to=${CURRENCIES.join(",")}`;
    const response = await fetch(apiUrl);

    if (!response.ok) {
      throw new Error(`frankfurter.app returned ${response.status}`);
    }

    const data = await response.json();
    const rates: Record<string, number> = data.rates;
    const rateDate: string = data.date; // "YYYY-MM-DD"

    console.log(`Fetched rates for ${rateDate}: ${Object.keys(rates).length} currencies`);

    // Build upsert rows — invert rate: rate_to_usd = 1 / rate
    const rows = Object.entries(rates).map(([currency, rate]) => ({
      currency_code: currency,
      rate_to_usd: 1 / (rate as number),
      rate_date: rateDate,
      source: "frankfurter.app",
    }));

    // Also add USD = 1.0
    rows.push({
      currency_code: "USD",
      rate_to_usd: 1.0,
      rate_date: rateDate,
      source: "frankfurter.app",
    });

    // Upsert into exchange_rates
    const { error: upsertError } = await supabase
      .from("exchange_rates")
      .upsert(rows, { onConflict: "currency_code,rate_date" });

    if (upsertError) {
      throw new Error(`Upsert error: ${upsertError.message}`);
    }

    console.log(`Upserted ${rows.length} rates for ${rateDate}`);

    // Backfill amount_usd for existing convocatorias
    const { data: backfilled, error: backfillError } = await supabase
      .rpc("backfill_amount_usd");

    if (backfillError) {
      console.error("Backfill error:", backfillError.message);
    }

    const result = {
      success: true,
      date: rateDate,
      rates_fetched: rows.length,
      backfilled: backfilled ?? 0,
      currencies: Object.keys(rates),
    };

    console.log("Result:", JSON.stringify(result));

    return new Response(JSON.stringify(result), {
      headers: { "Content-Type": "application/json" },
    });
  } catch (error) {
    console.error("Exchange rate fetch error:", error);
    return new Response(
      JSON.stringify({ success: false, error: (error as Error).message }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }
});
