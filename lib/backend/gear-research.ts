import type { SupabaseClient } from "@supabase/supabase-js";
import { createOpenAIClient } from "@/lib/provider-clients";

// AI-researched specs for a piece of gear the catalog didn't have. Stored in the
// gear_search_misses review queue for admin approval — never written to the live catalog.
const gearSpecSchema = {
  type: "object",
  additionalProperties: false,
  required: ["brand", "model", "category", "technology", "controls", "character", "exists", "confidence"],
  properties: {
    brand: { type: ["string", "null"] },
    model: { type: ["string", "null"] },
    category: { type: "string" }, // refined type, e.g. "solid-state combo amp", "overdrive pedal", "HH electric guitar"
    technology: { type: ["string", "null"] }, // amps only: tube | solid_state | digital_modeling | plugin
    controls: { type: "array", items: { type: "string" }, maxItems: 20 }, // the REAL controls it has
    character: { type: "string" }, // short tone description
    exists: { type: "boolean" }, // false if the model can't be confidently identified
    confidence: { type: "integer", minimum: 0, maximum: 100 }
  }
};

// Best-effort: research a missing gear's real specs once and stash them in the review queue.
// Gated so it only fires for genuine demand (searched 2+ times) and researches each gear a
// single time — no typeahead spam, cost bounded to the number of unique missing items.
// Never throws (fire-and-forget from the search path).
export async function maybeResearchGear(admin: SupabaseClient, kind: string, query: string): Promise<void> {
  try {
    const name = query.trim();
    if (name.length < 4) return;
    const normalizedKey = `${kind.toLowerCase().trim()} | ${name.toLowerCase()}`;

    const { data: row } = await admin
      .from("gear_search_misses")
      .select("id, match_count, search_count, research_status")
      .eq("normalized_key", normalizedKey)
      .maybeSingle();

    // Only research a real, catalog-missing, not-yet-researched item with repeat demand.
    if (!row || row.match_count > 0 || (row.search_count ?? 0) < 2 || row.research_status !== "pending") {
      return;
    }

    const client = createOpenAIClient();
    if (!client) return;
    // Claim it first so concurrent searches don't double-research.
    await admin.from("gear_search_misses").update({ research_status: "researching" }).eq("id", row.id);

    const model = process.env.AI_INGESTION_MODEL || process.env.OPENAI_MODEL || "gpt-4.1";
    const completion = await client.chat.completions.create({
      model,
      temperature: 0.2,
      messages: [
        {
          role: "system",
          content:
            "You are a guitar-gear catalog researcher. Given the kind and name of a piece of gear a user entered, return its REAL specs: brand, model, a refined category, amp technology (tube/solid_state/digital_modeling/plugin) if it is an amp, the actual physical controls it has, and a short tone character. Never invent controls or specs. If you cannot confidently identify the specific model, set exists=false, confidence low, and leave unknown fields null. Return JSON only."
        },
        { role: "user", content: JSON.stringify({ kind, name }) }
      ],
      response_format: { type: "json_schema", json_schema: { name: "gear_specs", strict: true, schema: gearSpecSchema } }
    } as never);

    const content = completion.choices[0]?.message?.content;
    if (!content) {
      await admin.from("gear_search_misses").update({ research_status: "failed", research_model: model }).eq("id", row.id);
      return;
    }
    const specs = JSON.parse(content);
    await admin
      .from("gear_search_misses")
      .update({ researched_specs: specs, research_status: "done", research_model: model })
      .eq("id", row.id);
  } catch (error) {
    console.error("[gear-research] failed", error instanceof Error ? error.message : error);
  }
}
