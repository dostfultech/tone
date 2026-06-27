import { type TonePartType, type ToneRequest, type ToneType } from "@/lib/mock-data";
import { createSupabaseAdminClient } from "@/lib/supabase/admin";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { brand } from "@/lib/brand";

export type ToneProfileEffect = {
  effectOrder: number;
  effectType: string;
  effectName: string;
  placement: string;
  settings: Record<string, number | string>;
};

export type ToneProfileSource = {
  sourceType: string;
  title: string;
  url?: string | null;
  notes?: string | null;
  credibility: number;
};

export type ToneProfile = {
  id: string;
  songTitle: string;
  artistName: string;
  mode: "guitar" | "bass";
  partType: TonePartType;
  partLabel: string;
  toneType: ToneType;
  originalGuitar?: string | null;
  originalAmp?: string | null;
  originalCab?: string | null;
  originalPickup?: string | null;
  originalSettings: Record<string, number>;
  effects: ToneProfileEffect[];
  adaptationNotes: string[];
  playingNotes: string[];
  sourceSummary?: string | null;
  confidence: number;
  verificationStatus: "starter_estimate" | "needs_review" | "community_submitted" | "admin_verified";
  sources: ToneProfileSource[];
};

type DbToneProfile = {
  id: string;
  song_title: string;
  artist_name: string;
  mode: "guitar" | "bass";
  part_type: TonePartType;
  part_label: string;
  tone_type: ToneType;
  original_guitar: string | null;
  original_amp: string | null;
  original_cab: string | null;
  original_pickup: string | null;
  original_settings: Record<string, number>;
  adaptation_notes: string[];
  playing_notes: string[];
  source_summary: string | null;
  confidence: number;
  verification_status: ToneProfile["verificationStatus"];
  tone_profile_effects?: Array<{
    effect_order: number;
    effect_type: string;
    effect_name: string;
    placement: string;
    settings: Record<string, number | string>;
  }>;
  tone_profile_sources?: Array<{
    source_type: string;
    title: string;
    url: string | null;
    notes: string | null;
    credibility: number;
  }>;
};

const starterProfiles: ToneProfile[] = [
  starter("perfect-ed-sheeran-rhythm", "Perfect", "Ed Sheeran", "guitar", "rhythm", "main acoustic progression", "acoustic", "Steel-string acoustic with piezo or mic blend", "Studio acoustic preamp / DI", "acoustic pickup or mic", { gain: 2, bass: 4, mids: 5, treble: 7, presence: 6, compression: 3, reverb: 3, delay: 0 }, ["Light compressor", "Small room reverb"], 72),
  starter("comfortably-numb-second-solo", "Comfortably Numb", "Pink Floyd", "guitar", "solo", "second solo", "distorted", "Strat-style single-coil guitar", "Hiwatt-style clean platform with sustain pedals", "bridge or bridge/neck single coil", { gain: 6, bass: 4, mids: 6, treble: 6, presence: 6, reverb: 3, delay: 4 }, ["Sustain/fuzz drive", "Tape-style delay", "Plate reverb"], 78),
  starter("enter-sandman-rhythm", "Enter Sandman", "Metallica", "guitar", "rhythm", "main rhythm riff", "high_gain", "Humbucker guitar", "Mesa/Boogie-style high-gain amp", "bridge humbucker", { gain: 8, bass: 7, mids: 3, treble: 6, presence: 6, reverb: 1, delay: 0 }, ["Tight gate", "Post amp graphic EQ"], 76),
  starter("master-of-puppets-rhythm", "Master of Puppets", "Metallica", "guitar", "rhythm", "downpicked rhythm", "high_gain", "Humbucker guitar", "Mesa/Boogie Mark-style amp", "bridge humbucker", { gain: 8, bass: 6, mids: 4, treble: 6, presence: 5, reverb: 0, delay: 0 }, ["Fast gate", "Tight metal EQ"], 77),
  starter("sultans-of-swing-lead", "Sultans of Swing", "Dire Straits", "guitar", "lead", "lead and fills", "clean", "Strat-style single-coil guitar", "Clean Fender/Vibrolux-style amp", "bridge/middle single coils", { gain: 3, bass: 4, mids: 5, treble: 7, presence: 6, reverb: 2, delay: 0 }, ["Light clean compression", "Spring reverb"], 76),
  starter("smells-like-teen-spirit-rhythm", "Smells Like Teen Spirit", "Nirvana", "guitar", "rhythm", "chorus rhythm", "distorted", "Offset-style guitar with humbucker or hot single coil", "Clean amp pushed by distortion pedal", "bridge pickup", { gain: 7, bass: 5, mids: 5, treble: 6, presence: 5, reverb: 1, delay: 0 }, ["Classic distortion", "Subtle clean-section chorus"], 75),
  starter("come-as-you-are-riff", "Come As You Are", "Nirvana", "guitar", "riff", "watery intro riff", "clean", "Offset-style guitar", "Clean combo amp", "neck or middle pickup", { gain: 3, bass: 5, mids: 5, treble: 5, presence: 4, reverb: 2, delay: 0 }, ["Watery chorus", "Small room"], 76),
  starter("sweet-child-o-mine-lead", "Sweet Child O' Mine", "Guns N' Roses", "guitar", "lead", "intro lead", "distorted", "Les Paul-style humbucker guitar", "Marshall-style high-gain head", "neck humbucker for intro, bridge for bite", { gain: 6, bass: 5, mids: 7, treble: 6, presence: 5, reverb: 2, delay: 2 }, ["Amp gain", "Short lead delay", "Plate ambience"], 76),
  starter("back-in-black-rhythm", "Back in Black", "AC/DC", "guitar", "rhythm", "main rhythm", "crunch", "SG-style humbucker guitar", "Marshall Plexi/JMP-style amp", "bridge humbucker", { gain: 5, bass: 5, mids: 7, treble: 6, presence: 5, reverb: 1, delay: 0 }, ["Amp crunch"], 78),
  starter("hotel-california-solo", "Hotel California", "Eagles", "guitar", "solo", "dual-guitar solo", "crunch", "Les Paul / Tele-style lead guitars", "Fender or small-tube amp edge of breakup", "bridge pickup with tone rolled slightly", { gain: 5, bass: 5, mids: 6, treble: 6, presence: 5, reverb: 2, delay: 1 }, ["Edge-of-breakup amp drive", "Plate reverb"], 74),
  starter("purple-haze-riff", "Purple Haze", "Jimi Hendrix", "guitar", "riff", "main riff and lead", "fuzz", "Strat-style single-coil guitar", "Marshall-style loud clean/crunch amp", "neck/bridge single coils", { gain: 7, bass: 5, mids: 6, treble: 6, presence: 6, reverb: 1, delay: 0 }, ["Vintage fuzz face-style fuzz", "Wah accents"], 76),
  starter("seven-nation-army-riff", "Seven Nation Army", "The White Stripes", "guitar", "riff", "octave riff", "fuzz", "Semi-hollow or electric guitar", "Amp with octave/fuzz front end", "neck pickup or dark bridge tone", { gain: 6, bass: 6, mids: 6, treble: 4, presence: 4, reverb: 1, delay: 0 }, ["Down-octave effect", "Raw fuzz"], 74),
  starter("californication-lead", "Californication", "Red Hot Chili Peppers", "guitar", "lead", "main lead melody", "clean", "Strat-style single-coil guitar", "Clean Fender/Marshall-style amp", "neck single coil", { gain: 3, bass: 5, mids: 5, treble: 6, presence: 5, reverb: 2, delay: 0 }, ["Light leveling", "Small room"], 73),
  starter("hysteria-bassline", "Hysteria", "Muse", "bass", "bassline", "main fuzz bass riff", "bass_drive", "Bass guitar with hot pickups", "Bass amp / DI with fuzz and synth-like drive", "bridge-heavy bass pickup blend", { gain: 7, bass: 6, mids: 7, treble: 5, presence: 5, compression: 6, reverb: 0, delay: 0 }, ["Compressed bass fuzz", "Heavy compression", "Mid-forward bass EQ"], 76),
  starter("paranoid-riff", "Paranoid", "Black Sabbath", "guitar", "riff", "main riff", "crunch", "SG-style humbucker guitar", "Laney/Marshall-style driven amp", "bridge humbucker", { gain: 6, bass: 5, mids: 7, treble: 5, presence: 5, reverb: 1, delay: 0 }, ["Vintage amp drive", "Mid-forward EQ"], 74)
];

export async function findToneProfile(request: ToneRequest): Promise<ToneProfile | null> {
  const fromDatabase = await findToneProfileFromSupabase(request);
  if (fromDatabase) return fromDatabase;
  return findStarterToneProfile(request);
}

export async function listCommunityToneProfiles(query: string) {
  const normalized = normalize(query);
  const supabase = await createSupabaseServerClient();

  if (supabase) {
    try {
      let dbQuery = supabase
        .from("song_tone_profiles")
        .select("id, song_title, artist_name, mode, part_type, part_label, tone_type, original_guitar, original_amp, confidence, verification_status")
        .eq("is_public", true)
        .order("confidence", { ascending: false })
        .limit(60);

      if (normalized) {
        dbQuery = dbQuery.ilike("search_text", `%${escapeLike(normalized)}%`);
      }

      const { data, error } = await dbQuery;
      if (!error && data?.length) {
        return data
          .slice()
          .sort((left, right) => {
            const leftSynthetic = isSyntheticLibraryProfile(left.song_title, left.artist_name);
            const rightSynthetic = isSyntheticLibraryProfile(right.song_title, right.artist_name);
            if (leftSynthetic !== rightSynthetic) {
              return leftSynthetic ? 1 : -1;
            }

            return right.confidence - left.confidence;
          })
          .map((profile) => {
            const display = displayProfileIdentity(profile.id, profile.song_title, profile.artist_name);

            return {
              id: profile.id,
              song: display.songTitle,
              artist: display.artistName,
              part: profile.part_label,
              mode: profile.mode,
              score: profile.confidence,
              guitar: profile.original_guitar || "Original guitar unknown",
              amp: profile.original_amp || "Original amp unknown",
              toneType: profile.tone_type,
              verificationStatus: profile.verification_status
            };
          });
      }
    } catch {
      // Fall through to starter catalog for local development or unapplied migrations.
    }
  }

  return starterProfiles
    .filter((profile) => {
      const haystack = normalize(`${profile.songTitle} ${profile.artistName} ${profile.partLabel} ${profile.toneType}`);
      return !normalized || haystack.includes(normalized);
    })
    .slice(0, 60)
    .map((profile) => ({
      id: profile.id,
      song: profile.songTitle,
      artist: profile.artistName,
      part: profile.partLabel,
      mode: profile.mode,
      score: profile.confidence,
      guitar: profile.originalGuitar || "Original guitar unknown",
      amp: profile.originalAmp || "Original amp unknown",
      toneType: profile.toneType,
      verificationStatus: profile.verificationStatus
    }));
}

function isSyntheticLibraryProfile(songTitle: string, artistName: string) {
  const combined = `${songTitle} ${artistName}`.toLowerCase();
  return combined.includes("tone database song") || combined.includes("tonefex session library");
}

function displayProfileIdentity(profileId: string, songTitle: string, artistName: string) {
  if (!isSyntheticLibraryProfile(songTitle, artistName)) {
    return { songTitle, artistName };
  }

  const index = syntheticProfileIndex(profileId || `${songTitle}-${artistName}`);
  const firstWords = [
    "Midnight", "Silver", "Golden", "Electric", "Quiet", "Restless", "Velvet", "Neon", "Falling", "Broken",
    "Static", "Young", "Wild", "Secret", "Blue", "Crimson", "Open", "Dark", "Shallow", "Northern"
  ];
  const secondWords = [
    "Horizon", "Cinema", "Signal", "Letters", "Highway", "Ghost", "River", "Fever", "Seasons", "Dreams",
    "Mercy", "Thunder", "Satellite", "Mirrors", "Motion", "Fire", "Crown", "Ocean", "Echo", "Run",
    "Silence", "Street", "Lights", "Colour", "Gravity"
  ];
  const artistNames = [
    "North Avenue", "Silver Line", "Midnight Arcade", "Velvet Echo", "Neon Harbour", "Atlas Fire", "Paper Satellites",
    "Golden Static", "Afterglow Parade", "Hollow Avenue", "Blue Cinema", "Signal Hearts", "Wild Meridian",
    "Electric Letters", "The Last Seasons", "Lowlight District", "Cassette Bloom", "Crimson Youth", "Polar Fires", "Sunday Lights"
  ];

  return {
    songTitle: `${firstWords[index % firstWords.length]} ${secondWords[Math.floor(index / firstWords.length) % secondWords.length]}`,
    artistName: artistNames[index % artistNames.length]
  };
}

function syntheticProfileIndex(seed: string) {
  let hash = 0;
  for (let index = 0; index < seed.length; index += 1) {
    hash = (hash * 31 + seed.charCodeAt(index)) % 500;
  }

  return Math.abs(hash);
}

export async function getCommunityToneProfileById(profileId: string) {
  const normalizedId = profileId.trim();
  if (!normalizedId) {
    return null;
  }

  const supabase = await createSupabaseServerClient();
  if (supabase) {
    try {
      const { data, error } = await supabase
        .from("song_tone_profiles")
        .select(
          "id, song_title, artist_name, mode, part_type, part_label, tone_type, original_guitar, original_amp, original_cab, original_pickup, original_settings, adaptation_notes, playing_notes, source_summary, confidence, verification_status, tone_profile_effects(effect_order, effect_type, effect_name, placement, settings), tone_profile_sources(source_type, title, url, notes, credibility)"
        )
        .eq("id", normalizedId)
        .eq("is_public", true)
        .maybeSingle();

      if (!error && data) {
        return mapDbToneProfile(data);
      }
    } catch {
      // Fall through to starter catalog when database lookup is unavailable.
    }
  }

  return starterProfiles.find((profile) => profile.id === normalizedId) || null;
}

export async function createMissingSongRequest(request: ToneRequest, userId?: string | null) {
  const admin = createSupabaseAdminClient();
  if (!admin) return;

  try {
    await admin.from("song_requests").insert({
      user_id: userId || null,
      song_title: request.song,
      artist_name: request.artist,
      mode: request.mode,
      part_type: request.partType || inferPartType(request.part),
      tone_type: request.toneType || "auto",
      requested_gear: request
    });
  } catch {
    // Missing-song requests should never block the actual tone workflow.
  }
}

export function buildResearchPayload(request: ToneRequest, toneProfile: ToneProfile | null) {
  if (!toneProfile) {
    return {
      song: request.song,
      artist: request.artist,
      foundProfile: false,
      likelyRig:
        request.mode === "bass"
          ? `No stored bass profile yet. ${brand.appName} will generate a cautious DI/amp adaptation and queue this song for research.`
          : `No stored profile yet. ${brand.appName} will generate a cautious guitar adaptation and queue this song for research.`,
      sourcesChecked: [`${brand.appName} tone catalog`, "starter profile fallback", "AI adaptation fallback"],
      confidence: 54
    };
  }

  return {
    song: toneProfile.songTitle,
    artist: toneProfile.artistName,
    foundProfile: true,
    profileId: toneProfile.id,
    partType: toneProfile.partType,
    toneType: toneProfile.toneType,
    likelyRig: [toneProfile.originalGuitar, toneProfile.originalAmp, toneProfile.originalCab].filter(Boolean).join(" -> "),
    originalSettings: toneProfile.originalSettings,
    effects: toneProfile.effects.map((effect) => effect.effectName),
    sourcesChecked: toneProfile.sources.map((source) => source.title),
    verificationStatus: toneProfile.verificationStatus,
    sourceSummary: toneProfile.sourceSummary,
    confidence: toneProfile.confidence
  };
}

async function findToneProfileFromSupabase(request: ToneRequest): Promise<ToneProfile | null> {
  const supabase = await createSupabaseServerClient();
  if (!supabase) return null;

  try {
    let dbQuery = supabase
      .from("song_tone_profiles")
      .select(
        "id, song_title, artist_name, mode, part_type, part_label, tone_type, original_guitar, original_amp, original_cab, original_pickup, original_settings, adaptation_notes, playing_notes, source_summary, confidence, verification_status, tone_profile_effects(effect_order, effect_type, effect_name, placement, settings), tone_profile_sources(source_type, title, url, notes, credibility)"
      )
      .eq("is_public", true)
      .eq("mode", request.mode)
      .ilike("search_text", `%${escapeLike(request.song)}%`)
      .limit(20);

    const artist = request.artist.trim();
    if (artist && artist.toLowerCase() !== "unknown artist") {
      dbQuery = dbQuery.ilike("artist_name", `%${escapeLike(artist)}%`);
    }

    const { data, error } = await dbQuery;
    if (error || !data?.length) return null;

    return data.map(mapDbToneProfile).sort((a, b) => scoreProfile(b, request) - scoreProfile(a, request))[0] || null;
  } catch {
    return null;
  }
}

function findStarterToneProfile(request: ToneRequest) {
  return starterProfiles
    .filter((profile) => profile.mode === request.mode)
    .map((profile) => ({ profile, score: scoreProfile(profile, request) }))
    .filter(({ score }) => score > 25)
    .sort((a, b) => b.score - a.score)[0]?.profile || null;
}

function scoreProfile(profile: ToneProfile, request: ToneRequest) {
  const title = normalize(profile.songTitle);
  const artist = normalize(profile.artistName);
  const partType = request.partType || inferPartType(request.part);
  const toneType = request.toneType || "auto";
  const requestedSong = normalize(request.song);
  const requestedArtist = normalize(request.artist);

  let score = 0;
  if (title === requestedSong) score += 100;
  else if (title.includes(requestedSong) || requestedSong.includes(title)) score += 55;
  if (artist === requestedArtist) score += 45;
  else if (artist.includes(requestedArtist) || requestedArtist.includes(artist)) score += 20;
  if (profile.partType === partType) score += 20;
  if (profile.partLabel.toLowerCase().includes(request.part.toLowerCase())) score += 8;
  if (toneType === "auto" || profile.toneType === toneType) score += 15;
  return score;
}

function mapDbToneProfile(profile: DbToneProfile): ToneProfile {
  const display = displayProfileIdentity(profile.id, profile.song_title, profile.artist_name);

  return {
    id: profile.id,
    songTitle: display.songTitle,
    artistName: display.artistName,
    mode: profile.mode,
    partType: profile.part_type,
    partLabel: profile.part_label,
    toneType: profile.tone_type,
    originalGuitar: profile.original_guitar,
    originalAmp: profile.original_amp,
    originalCab: profile.original_cab,
    originalPickup: profile.original_pickup,
    originalSettings: profile.original_settings || {},
    adaptationNotes: profile.adaptation_notes || [],
    playingNotes: profile.playing_notes || [],
    sourceSummary: profile.source_summary,
    confidence: profile.confidence,
    verificationStatus: profile.verification_status,
    effects: (profile.tone_profile_effects || [])
      .map((effect) => ({
        effectOrder: effect.effect_order,
        effectType: effect.effect_type,
        effectName: effect.effect_name,
        placement: effect.placement,
        settings: effect.settings || {}
      }))
      .sort((a, b) => a.effectOrder - b.effectOrder),
    sources: (profile.tone_profile_sources || []).map((source) => ({
      sourceType: source.source_type,
      title: source.title,
      url: source.url,
      notes: source.notes,
      credibility: source.credibility
    }))
  };
}

function starter(
  id: string,
  songTitle: string,
  artistName: string,
  mode: "guitar" | "bass",
  partType: TonePartType,
  partLabel: string,
  toneType: ToneType,
  originalGuitar: string,
  originalAmp: string,
  originalPickup: string,
  originalSettings: Record<string, number>,
  effects: string[],
  confidence: number
): ToneProfile {
  return {
    id,
    songTitle,
    artistName,
    mode,
    partType,
    partLabel,
    toneType,
    originalGuitar,
    originalAmp,
    originalCab: mode === "bass" ? "Bass cab or studio DI" : "Guitar cab or studio chain",
    originalPickup,
    originalSettings,
    effects: effects.map((effectName, index) => ({
      effectOrder: index + 1,
      effectType: normalize(effectName).split(" ")[0] || "effect",
      effectName,
      placement: index === 0 ? "front" : "post",
      settings: {}
    })),
    adaptationNotes: [
      "Starter profile: use as a practical baseline, then refine by ear against the recording.",
      "Compensate pickup output first, then rebalance amp EQ."
    ],
    playingNotes: [
      "Match the part's dynamics before changing gain.",
      "Use the recording as the final reference for EQ and ambience."
    ],
    sourceSummary: "Starter estimate for MVP use. Promote to verified after review against reliable rig sources or community submissions.",
    confidence,
    verificationStatus: "starter_estimate",
    sources: [
      {
        sourceType: "internal_seed",
        title: `${brand.appName} starter tone estimate`,
        notes: "Useful baseline, not an exact verified artist rig.",
        credibility: 55
      }
    ]
  };
}

function inferPartType(part: string): TonePartType {
  const normalized = normalize(part);
  if (normalized.includes("solo")) return "solo";
  if (normalized.includes("lead")) return "lead";
  if (normalized.includes("riff")) return "riff";
  if (normalized.includes("intro")) return "intro";
  if (normalized.includes("chorus")) return "chorus";
  if (normalized.includes("bass")) return "bassline";
  if (normalized.includes("rhythm")) return "rhythm";
  return "main";
}

function normalize(value: string) {
  return value.toLowerCase().replace(/[^a-z0-9]+/g, " ").trim();
}

function escapeLike(value: string) {
  return value.replace(/[%_]/g, "\\$&");
}
