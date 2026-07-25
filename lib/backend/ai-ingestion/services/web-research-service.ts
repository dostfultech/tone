// Live web-research provider for AI tone ingestion.
//
// When a song has no verified tone data, the AI researcher can pull real sources
// (rig rundowns, artist interviews, forum posts) from the web and synthesize an
// accurate profile from them — the ToneAdapt approach — instead of relying only on
// the model's own memory. This is gated behind a search API key and degrades
// gracefully: with no key, research returns null and ingestion falls back to the
// existing closed-book generation, so nothing breaks.
//
// Supported providers (set ONE): TAVILY_API_KEY (recommended) or SERPER_API_KEY.

export type WebResearchSource = {
  title: string;
  url: string;
  snippet: string;
};

export type WebResearchResult = {
  query: string;
  answer: string | null;
  sources: WebResearchSource[];
};

export type WebResearchInput = {
  song?: string | null;
  artist?: string | null;
  part?: string | null;
  mode?: string | null;
};

export function isWebResearchEnabled(): boolean {
  return Boolean(process.env.TAVILY_API_KEY || process.env.SERPER_API_KEY);
}

function buildQuery(input: WebResearchInput): string | null {
  const song = (input.song || "").trim();
  const artist = (input.artist || "").trim();
  if (!song || !artist) {
    return null;
  }
  const instrument = input.mode === "bass" ? "bass" : "guitar";
  const part = (input.part || "main").trim();
  return `${artist} "${song}" ${part} ${instrument} tone: rig rundown, amp settings, pickups, effects, pedals used on the recording`;
}

async function fetchJson(url: string, init: RequestInit, timeoutMs = 9000): Promise<unknown | null> {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeoutMs);
  try {
    const response = await fetch(url, { ...init, signal: controller.signal });
    if (!response.ok) {
      return null;
    }
    return await response.json();
  } catch {
    return null;
  } finally {
    clearTimeout(timer);
  }
}

async function tavilySearch(apiKey: string, query: string): Promise<WebResearchResult | null> {
  const data = (await fetchJson("https://api.tavily.com/search", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      api_key: apiKey,
      query,
      search_depth: "advanced",
      max_results: 6,
      include_answer: true,
      include_raw_content: false
    })
  })) as { answer?: string; results?: Array<{ title?: string; url?: string; content?: string }> } | null;

  if (!data || !Array.isArray(data.results)) {
    return null;
  }

  const sources: WebResearchSource[] = data.results
    .map((row) => ({
      title: String(row.title || "").trim(),
      url: String(row.url || "").trim(),
      snippet: String(row.content || "").trim().slice(0, 600)
    }))
    .filter((row) => row.url && (row.title || row.snippet));

  if (!sources.length) {
    return null;
  }

  return { query, answer: data.answer ? String(data.answer).slice(0, 1200) : null, sources };
}

async function serperSearch(apiKey: string, query: string): Promise<WebResearchResult | null> {
  const data = (await fetchJson("https://google.serper.dev/search", {
    method: "POST",
    headers: { "X-API-KEY": apiKey, "Content-Type": "application/json" },
    body: JSON.stringify({ q: query, num: 8 })
  })) as {
    organic?: Array<{ title?: string; link?: string; snippet?: string }>;
    answerBox?: { answer?: string; snippet?: string };
  } | null;

  if (!data || !Array.isArray(data.organic)) {
    return null;
  }

  const sources: WebResearchSource[] = data.organic
    .map((row) => ({
      title: String(row.title || "").trim(),
      url: String(row.link || "").trim(),
      snippet: String(row.snippet || "").trim().slice(0, 600)
    }))
    .filter((row) => row.url && (row.title || row.snippet));

  if (!sources.length) {
    return null;
  }

  const answer = data.answerBox?.answer || data.answerBox?.snippet || null;
  return { query, answer: answer ? String(answer).slice(0, 1200) : null, sources };
}

export async function researchToneSources(input: WebResearchInput): Promise<WebResearchResult | null> {
  const query = buildQuery(input);
  if (!query) {
    return null;
  }

  const tavilyKey = process.env.TAVILY_API_KEY;
  if (tavilyKey) {
    return tavilySearch(tavilyKey, query);
  }

  const serperKey = process.env.SERPER_API_KEY;
  if (serperKey) {
    return serperSearch(serperKey, query);
  }

  return null;
}
