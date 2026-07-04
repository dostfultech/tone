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
  genre: string;
  mode: "guitar" | "bass";
  partType: TonePartType;
  partLabel: string;
  toneType: ToneType;
  toneCategory: string;
  difficulty: string;
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
  genre: string;
  mode: "guitar" | "bass";
  part_type: TonePartType;
  part_label: string;
  tone_type: ToneType;
  tone_category: string;
  difficulty: string;
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

export type CommunityToneQuery = {
  query: string;
  instrument?: "all" | "guitar" | "bass";
  part?: "all" | "riff" | "solo";
  tone?: "all" | "clean" | "distorted";
  sort?: "top" | "popular" | "recent";
  page?: number;
  pageSize?: number;
};

export type CommunityToneListResult = {
  results: CommunityToneListItem[];
  total: number;
  page: number;
  pageSize: number;
  hasMore: boolean;
};

type CommunityToneListItem = {
  id: string;
  song: string;
  artist: string;
  genre: string;
  difficulty: string;
  part: string;
  mode: string;
  score: number;
  guitar: string;
  amp: string;
  pickupType: string;
  toneType?: string;
  toneCategory?: string;
  verificationStatus?: string;
};

type GeneratedToneResultForIngestion = {
  accuracy?: number;
  originalRig?: string;
  originalSettings?: Record<string, number>;
  targetSettings?: Record<string, number>;
  effects?: string[];
  playingTips?: string[];
  pickupAdvice?: string;
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

export async function listCommunityToneProfiles(options: CommunityToneQuery): Promise<CommunityToneListResult> {
  const page = Math.max(1, options.page || 1);
  const pageSize = Math.min(Math.max(options.pageSize || 24, 12), 48);
  const normalized = normalize(options.query || "");
  const supabase = await createSupabaseServerClient();
  const instrument = options.instrument || "all";
  const part = options.part || "all";
  const tone = options.tone || "all";
  const sort = options.sort || "top";

  if (supabase) {
    try {
      let dbQuery = supabase
        .from("song_tone_profiles")
        .select("id, song_title, artist_name, genre, mode, part_type, part_label, tone_type, tone_category, difficulty, original_guitar, original_amp, original_pickup, confidence, verification_status", { count: "exact" })
        .eq("is_public", true)
        .not("song_title", "ilike", "Tone Database Song %")
        .not("artist_name", "ilike", "Tonefex Session Library");

      if (instrument !== "all") {
        dbQuery = dbQuery.eq("mode", instrument);
      }

      if (part !== "all") {
        dbQuery = dbQuery.eq("part_type", part);
      }

      if (tone !== "all") {
        dbQuery = dbQuery.or(`tone_type.ilike.%${escapeLike(tone)}%,tone_category.ilike.%${escapeLike(tone)}%`);
      }

      if (normalized) {
        dbQuery = dbQuery.or(`search_text.ilike.%${escapeLike(normalized)}%,song_title.ilike.%${escapeLike(normalized)}%,artist_name.ilike.%${escapeLike(normalized)}%`);
      }

      if (sort === "recent") {
        dbQuery = dbQuery.order("updated_at", { ascending: false });
      } else if (sort === "popular") {
        dbQuery = dbQuery.order("confidence", { ascending: false }).order("song_title", { ascending: true });
      } else {
        dbQuery = dbQuery.order("confidence", { ascending: false }).order("updated_at", { ascending: false });
      }

      dbQuery = dbQuery.range((page - 1) * pageSize, page * pageSize - 1);

      const { data, error, count } = await dbQuery;
      if (!error) {
        const mappedProfiles: CommunityToneListItem[] = (data || [])
          .filter((profile) => !isSyntheticLibraryProfile(profile.song_title, profile.artist_name))
          .map((profile) => ({
          id: profile.id,
          song: profile.song_title,
          artist: profile.artist_name,
          genre: profile.genre || "rock",
          difficulty: profile.difficulty || "intermediate",
          part: profile.part_label,
          mode: profile.mode,
          score: profile.confidence,
          guitar: profile.original_guitar || "Original guitar unknown",
          amp: profile.original_amp || "Original amp unknown",
          pickupType: profile.original_pickup || "Pickup unknown",
          toneType: profile.tone_type,
          toneCategory: profile.tone_category,
          verificationStatus: profile.verification_status
        }));

        if ((count || 0) >= pageSize || page > 1 || mappedProfiles.length >= pageSize) {
          return {
            results: mappedProfiles,
            total: count || mappedProfiles.length,
            page,
            pageSize,
            hasMore: page * pageSize < (count || mappedProfiles.length)
          };
        }

        const fallbackProfiles: CommunityToneListItem[] = starterProfiles
          .filter((profile) => {
            const haystack = normalize(`${profile.songTitle} ${profile.artistName} ${profile.partLabel} ${profile.toneType} ${profile.genre} ${profile.toneCategory} ${profile.difficulty}`);
            if (instrument !== "all" && profile.mode !== instrument) return false;
            if (part !== "all" && profile.partType !== part) return false;
            if (tone !== "all" && !`${profile.toneType} ${profile.toneCategory}`.includes(tone)) return false;
            return !normalized || haystack.includes(normalized);
          })
          .map((profile) => ({
            id: profile.id,
            song: profile.songTitle,
            artist: profile.artistName,
            genre: profile.genre,
            difficulty: profile.difficulty,
            part: profile.partLabel,
            mode: profile.mode,
            score: profile.confidence,
            guitar: profile.originalGuitar || "Original guitar unknown",
            amp: profile.originalAmp || "Original amp unknown",
            pickupType: profile.originalPickup || "Pickup unknown",
            toneType: profile.toneType,
            toneCategory: profile.toneCategory,
            verificationStatus: profile.verificationStatus
          }));

        const merged = mergeCommunityProfiles(mappedProfiles, fallbackProfiles);
        const paginated = merged.slice((page - 1) * pageSize, page * pageSize);
        return {
          results: paginated,
          total: merged.length,
          page,
          pageSize,
          hasMore: page * pageSize < merged.length
        };
      }
    } catch {
      // Fall through to starter catalog for local development or unapplied migrations.
    }
  }

  const starterResults = starterProfiles
    .filter((profile) => {
      const haystack = normalize(`${profile.songTitle} ${profile.artistName} ${profile.partLabel} ${profile.toneType} ${profile.genre} ${profile.toneCategory} ${profile.difficulty}`);
      if (normalized && !haystack.includes(normalized)) return false;
      if (instrument !== "all" && profile.mode !== instrument) return false;
      if (part !== "all" && profile.partType !== part) return false;
      if (tone !== "all" && !`${profile.toneType} ${profile.toneCategory}`.includes(tone)) return false;
      return true;
    })
    .map((profile) => ({
      id: profile.id,
      song: profile.songTitle,
      artist: profile.artistName,
      genre: profile.genre,
      difficulty: profile.difficulty,
      part: profile.partLabel,
      mode: profile.mode,
      score: profile.confidence,
      guitar: profile.originalGuitar || "Original guitar unknown",
      amp: profile.originalAmp || "Original amp unknown",
      pickupType: profile.originalPickup || "Pickup unknown",
      toneType: profile.toneType,
      toneCategory: profile.toneCategory,
      verificationStatus: profile.verificationStatus
    }))
    .sort((left, right) => sort === "recent" ? left.song.localeCompare(right.song) : right.score - left.score);

  return {
    results: starterResults.slice((page - 1) * pageSize, page * pageSize),
    total: starterResults.length,
    page,
    pageSize,
    hasMore: page * pageSize < starterResults.length
  };
}

function isSyntheticLibraryProfile(songTitle: string, artistName: string) {
  const combined = `${songTitle} ${artistName}`.toLowerCase();
  return combined.includes("tone database song") || combined.includes("tonefex session library");
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
          "id, song_title, artist_name, genre, mode, part_type, part_label, tone_type, tone_category, difficulty, original_guitar, original_amp, original_cab, original_pickup, original_settings, adaptation_notes, playing_notes, source_summary, confidence, verification_status, tone_profile_effects(effect_order, effect_type, effect_name, placement, settings), tone_profile_sources(source_type, title, url, notes, credibility)"
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

export async function saveGeneratedMasterTone(request: ToneRequest, result: GeneratedToneResultForIngestion, _userId?: string | null) {
  const admin = createSupabaseAdminClient();
  if (!admin) return null;

  const artistName = request.artist || "Unknown Artist";
  const songTitle = request.song || "Unknown Song";
  const artistSlug = slugify(artistName);
  const songSlug = slugify(songTitle);
  const partType = request.partType || inferPartType(request.part);
  const toneType = request.toneType || "auto";
  const partLabel = request.part || "main part";
  const confidence = clampConfidence(Math.min(result.accuracy || 65, 78));
  const sourceSummary = "AI fallback generated this reusable master tone after a missing catalog profile.";

  try {
    const { data: artist } = await admin
      .from("artists")
      .upsert(
        {
          name: artistName,
          slug: artistSlug,
          search_text: normalize(`${artistName} ${artistSlug}`),
          is_active: true
        },
        { onConflict: "slug" }
      )
      .select("id")
      .single();

    if (!artist?.id) return null;

    const { data: song } = await admin
      .from("songs")
      .upsert(
        {
          artist_id: artist.id,
          title: songTitle,
          slug: songSlug,
          search_text: normalize(`${songTitle} ${artistName} ${songSlug}`),
          is_active: true
        },
        { onConflict: "artist_id,slug" }
      )
      .select("id")
      .single();

    if (!song?.id) return null;

    const { data: profile } = await admin
      .from("song_tone_profiles")
      .upsert(
        {
          song_id: song.id,
          song_title: songTitle,
          artist_name: artistName,
          mode: request.mode,
          part_type: partType,
          part_label: partLabel,
          tone_type: toneType,
          tone_category: toneType === "clean" || toneType === "acoustic" || toneType === "bass_clean" ? "clean" : partType === "solo" || partType === "lead" ? "lead" : "rhythm",
          difficulty: confidence >= 76 ? "intermediate" : "beginner",
          original_guitar: request.guitar || null,
          original_amp: request.goingDirect || request.effectsMode === "multi_fx" ? request.multiFx || request.amp || null : request.amp || null,
          original_cab: request.cabinet || null,
          original_pickup: formatCustomPickupSummary(request.customPickups) || request.pickup || null,
          original_settings: result.originalSettings || result.targetSettings || {},
          adaptation_notes: [
            "Generated once during AI fallback, then stored as a reusable master tone for future rule-engine adaptations.",
            result.pickupAdvice || "Review pickup output and source rig details before admin verification."
          ],
          playing_notes: result.playingTips?.slice(0, 6) || [],
          source_summary: sourceSummary,
          confidence,
          verification_status: "needs_review",
          search_text: normalize(`${songTitle} ${artistName} ${partLabel} ${toneType}`),
          is_public: true
        },
        { onConflict: "song_id,mode,part_type,tone_type,part_label" }
      )
      .select("id")
      .single();

    if (!profile?.id) return null;

    await admin.from("tone_profile_effects").delete().eq("profile_id", profile.id);
    const effects = (result.effects || []).slice(0, 8).map((effectName, index) => ({
      profile_id: profile.id,
      effect_order: index + 1,
      effect_type: normalize(effectName).split(" ")[0] || "effect",
      effect_name: effectName,
      placement: index === 0 ? "front" : "post",
      settings: {}
    }));
    if (effects.length) {
      await admin.from("tone_profile_effects").insert(effects);
    }

    await admin.from("tone_profile_sources").delete().eq("profile_id", profile.id).eq("source_type", "internal_seed");
    await admin.from("tone_profile_sources").insert({
      profile_id: profile.id,
      source_type: "internal_seed",
      title: `${brand.appName} AI fallback ingestion`,
      notes: "Stored automatically to avoid repeating live AI generation for the same master tone.",
      credibility: 45
    });

    await admin
      .from("song_requests")
      .update({ status: "fulfilled" })
      .eq("song_title", songTitle)
      .eq("artist_name", artistName)
      .eq("mode", request.mode);

    return profile.id as string;
  } catch {
    return null;
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
        "id, song_title, artist_name, genre, mode, part_type, part_label, tone_type, tone_category, difficulty, original_guitar, original_amp, original_cab, original_pickup, original_settings, adaptation_notes, playing_notes, source_summary, confidence, verification_status, tone_profile_effects(effect_order, effect_type, effect_name, placement, settings), tone_profile_sources(source_type, title, url, notes, credibility)"
      )
      .eq("is_public", true)
      .not("song_title", "ilike", "Tone Database Song %")
      .not("artist_name", "ilike", "Tonefex Session Library")
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
  return {
    id: profile.id,
    songTitle: profile.song_title,
    artistName: profile.artist_name,
    genre: profile.genre || "rock",
    mode: profile.mode,
    partType: profile.part_type,
    partLabel: profile.part_label,
    toneType: profile.tone_type,
    toneCategory: profile.tone_category || "rhythm",
    difficulty: profile.difficulty || "intermediate",
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

function mergeCommunityProfiles(
  primary: CommunityToneListItem[],
  fallback: CommunityToneListItem[]
) {
  const seen = new Set<string>();
  const merged: typeof primary = [];

  for (const item of [...primary, ...fallback]) {
    const key = `${normalize(item.song)}|${normalize(item.artist)}|${item.mode}|${normalize(item.part)}`;
    if (seen.has(key)) {
      continue;
    }

    seen.add(key);
    merged.push(item);
  }

  return merged;
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
    genre: mode === "bass" ? "alt rock" : toneType === "acoustic" ? "acoustic" : "classic rock",
    mode,
    partType,
    partLabel,
    toneType,
    toneCategory: partType === "solo" || partType === "lead" ? "lead" : partType === "bassline" ? "bass" : toneType === "crunch" ? "crunch" : toneType === "clean" ? "clean" : toneType === "distorted" || toneType === "high_gain" || toneType === "fuzz" ? "distortion" : "rhythm",
    difficulty: confidence >= 76 ? "advanced" : confidence >= 72 ? "intermediate" : "beginner",
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

function slugify(value: string) {
  const slug = normalize(value).replaceAll(" ", "-");
  return slug || "unknown";
}

function clampConfidence(value: number) {
  return Math.max(0, Math.min(100, Math.round(value)));
}

function formatCustomPickupSummary(pickups: ToneRequest["customPickups"]) {
  if (!pickups) return "";
  return [
    pickups.neck ? `neck: ${pickups.neck}` : null,
    pickups.middle ? `middle: ${pickups.middle}` : null,
    pickups.bridge ? `bridge: ${pickups.bridge}` : null
  ].filter(Boolean).join(", ");
}

function escapeLike(value: string) {
  return value.replace(/[%_]/g, "\\$&");
}
