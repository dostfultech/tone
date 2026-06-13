export type GearItem = {
  id: string;
  name: string;
  description: string;
  category?: string;
};

export type TonePartType = "main" | "riff" | "solo" | "lead" | "rhythm" | "intro" | "chorus" | "bridge" | "bassline";
export type ToneType = "auto" | "clean" | "crunch" | "distorted" | "high_gain" | "fuzz" | "acoustic" | "bass_clean" | "bass_drive";

export type ToneRequest = {
  mode: "guitar" | "bass";
  song: string;
  artist: string;
  part: string;
  partType?: TonePartType;
  toneType?: ToneType;
  guitar: string;
  amp: string;
  pickup?: string;
  effectsMode?: string;
};

export type ToneProfileInput = {
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
  effects: Array<{ effectName: string; effectType?: string; placement?: string; settings?: Record<string, number | string> }>;
  adaptationNotes: string[];
  playingNotes: string[];
  sourceSummary?: string | null;
  confidence: number;
  verificationStatus: string;
};

export type SongItem = {
  id: string;
  song: string;
  artist: string;
  part: string;
  mode: "guitar" | "bass";
  album: string;
  duration: string;
  artworkColor: string;
  artworkUrl?: string;
  source?: "local" | "itunes";
};

export const guitars: GearItem[] = [
  { id: "strat", name: "Fender Stratocaster", description: "Single coils, clear attack, bright neck and bridge positions." },
  { id: "les-paul", name: "Gibson Les Paul Standard", description: "Mahogany body, set neck, medium output humbuckers." },
  { id: "prs-custom", name: "PRS Custom 24", description: "Balanced humbuckers with modern split-coil flexibility." },
  { id: "ibanez-rg", name: "Ibanez RG550", description: "Fast superstrat platform with high-output bridge tones." },
  { id: "tele", name: "Fender Telecaster", description: "Tight bridge bite with a woody neck pickup." },
  { id: "jazzmaster", name: "Fender Jazzmaster", description: "Wide single coils, airy mids, offset resonance." },
  { id: "sg", name: "Gibson SG Standard", description: "Lightweight dual humbucker guitar with upper-mid snap." },
  { id: "gretsch", name: "Gretsch G5420T", description: "Hollow body chime with Filter'Tron-style articulation." }
];

export const amps: GearItem[] = [
  { id: "deluxe", name: "Fender Deluxe Reverb", description: "Sparkly blackface clean tone and spring reverb." },
  { id: "plexi", name: "Marshall Super Lead 1959", description: "Classic Plexi crunch with vocal upper mids." },
  { id: "jcm800", name: "Marshall JCM800 2203", description: "Focused hard-rock gain with aggressive presence." },
  { id: "ac30", name: "Vox AC30 Top Boost", description: "Chime, compression, and mid-forward breakup." },
  { id: "rectifier", name: "Mesa/Boogie Dual Rectifier", description: "Thick modern high gain and deep low end." },
  { id: "slo", name: "Soldano SLO-100", description: "Saturated lead gain with smooth harmonic sustain." },
  { id: "katana", name: "Boss Katana Artist", description: "Flexible modeling combo with effects and power scaling." },
  { id: "helix", name: "Line 6 Helix Native", description: "Multi-amp modeler and effects platform." }
];

export const bassGuitars: GearItem[] = [
  { id: "precision", name: "Fender Precision Bass", description: "Split-coil punch and focused low mids." },
  { id: "jazz", name: "Fender Jazz Bass", description: "Dual single-coil definition with scooped blend." },
  { id: "stingray", name: "Music Man StingRay", description: "Active humbucker bite with clean low end." },
  { id: "rick", name: "Rickenbacker 4003", description: "Grinding treble presence and piano-like attack." }
];

export const bassAmps: GearItem[] = [
  { id: "svt", name: "Ampeg SVT-CL", description: "Classic tube bass stack with growl." },
  { id: "b15", name: "Ampeg B-15N", description: "Vintage roundness and soft compression." },
  { id: "gk", name: "Gallien-Krueger 800RB", description: "Fast transient response and upper-mid snap." },
  { id: "darkglass", name: "Darkglass Microtubes 900", description: "Modern clean power and controllable drive." }
];

export const pickups = [
  { id: "sd-jb", name: "Seymour Duncan JB", category: "High-output humbucker" },
  { id: "emg-81", name: "EMG 81", category: "Active humbucker" },
  { id: "paf", name: "PAF-style Humbucker", category: "Medium-output vintage" },
  { id: "hot-rails", name: "Hot Rails", category: "Single-coil sized humbucker" },
  { id: "vintage-single", name: "Vintage Single Coil", category: "Low-output single coil" },
  { id: "p90", name: "P-90", category: "Wide single coil" }
];

export const pedalPresets = [
  { id: "tight-rock", name: "Tight Rock Chain", category: "overdrive", pedals: ["Tube-style overdrive", "Graphic EQ", "Plate reverb"] },
  { id: "ambient-lead", name: "Ambient Lead", category: "delay", pedals: ["Analog delay", "Hall reverb", "Compressor"] },
  { id: "modern-metal", name: "Modern Metal", category: "distortion", pedals: ["Noise gate", "Boost", "Parametric EQ"] },
  { id: "vintage-clean", name: "Vintage Clean", category: "boost", pedals: ["Compressor", "Spring reverb", "Tape echo"] }
];

export const partOptions: Array<{ value: TonePartType; label: string }> = [
  { value: "main", label: "Main" },
  { value: "riff", label: "Riff" },
  { value: "rhythm", label: "Rhythm" },
  { value: "solo", label: "Solo" },
  { value: "lead", label: "Lead" },
  { value: "intro", label: "Intro" },
  { value: "chorus", label: "Chorus" },
  { value: "bassline", label: "Bassline" }
];

export const toneTypeOptions: Array<{ value: ToneType; label: string }> = [
  { value: "auto", label: "Auto-detect" },
  { value: "clean", label: "Clean" },
  { value: "crunch", label: "Crunch" },
  { value: "distorted", label: "Distorted" },
  { value: "high_gain", label: "High gain" },
  { value: "fuzz", label: "Fuzz" },
  { value: "acoustic", label: "Acoustic" },
  { value: "bass_clean", label: "Bass clean" },
  { value: "bass_drive", label: "Bass drive" }
];

export const multiFxUnits = [
  { id: "helix-floor", name: "Line 6 Helix Floor", brand: "Line 6" },
  { id: "quad-cortex", name: "Neural DSP Quad Cortex", brand: "Neural DSP" },
  { id: "gt1000", name: "Boss GT-1000", brand: "Boss" },
  { id: "fm9", name: "Fractal FM9", brand: "Fractal Audio" }
];

export const songs: SongItem[] = [
  { id: "perfect-ed-sheeran", song: "Perfect", artist: "Ed Sheeran", part: "main progression", mode: "guitar", album: "÷ (Deluxe)", duration: "4:23", artworkColor: "#42a5c8" },
  { id: "perfect-simple-plan", song: "Perfect", artist: "Simple Plan", part: "chorus rhythm", mode: "guitar", album: "No Pads, No Helmets...Just Balls", duration: "4:37", artworkColor: "#b64a33" },
  { id: "perfect-one-direction", song: "Perfect", artist: "One Direction", part: "chorus rhythm", mode: "guitar", album: "Made in the A.M. (Deluxe Edition)", duration: "3:50", artworkColor: "#8a5a44" },
  { id: "perfect-exceeder", song: "Perfect (Exceeder)", artist: "Mason & Princess Superstar", part: "synth bass hook", mode: "bass", album: "Perfect (Exceeder)", duration: "2:41", artworkColor: "#62656a" },
  { id: "perfect-fairground", song: "Perfect", artist: "Fairground Attraction", part: "acoustic rhythm", mode: "guitar", album: "The First of a Million Kisses", duration: "3:37", artworkColor: "#e75f70" },
  { id: "comfortably-numb", song: "Comfortably Numb", artist: "Pink Floyd", part: "second solo", mode: "guitar", album: "The Wall", duration: "6:22", artworkColor: "#d2b46d" },
  { id: "enter-sandman", song: "Enter Sandman", artist: "Metallica", part: "rhythm", mode: "guitar", album: "Metallica", duration: "5:31", artworkColor: "#1f2937" },
  { id: "sultans", song: "Sultans of Swing", artist: "Dire Straits", part: "lead", mode: "guitar", album: "Dire Straits", duration: "5:48", artworkColor: "#c17d45" },
  { id: "everlong", song: "Everlong", artist: "Foo Fighters", part: "chorus rhythm", mode: "guitar", album: "The Colour and the Shape", duration: "4:10", artworkColor: "#c73835" },
  { id: "sweet-child", song: "Sweet Child O' Mine", artist: "Guns N' Roses", part: "intro lead", mode: "guitar", album: "Appetite for Destruction", duration: "5:56", artworkColor: "#3f6b4a" },
  { id: "hotel-california", song: "Hotel California", artist: "Eagles", part: "outro solo", mode: "guitar", album: "Hotel California", duration: "6:30", artworkColor: "#c58b47" },
  { id: "smells-like-teen-spirit", song: "Smells Like Teen Spirit", artist: "Nirvana", part: "chorus rhythm", mode: "guitar", album: "Nevermind", duration: "5:01", artworkColor: "#2b7c9b" },
  { id: "black-dog", song: "Black Dog", artist: "Led Zeppelin", part: "main riff", mode: "guitar", album: "Led Zeppelin IV", duration: "4:55", artworkColor: "#6a5d4f" },
  { id: "hysteria", song: "Hysteria", artist: "Muse", part: "main bass riff", mode: "bass", album: "Absolution", duration: "3:47", artworkColor: "#6d6f76" },
  { id: "come-together", song: "Come Together", artist: "The Beatles", part: "bass line", mode: "bass", album: "Abbey Road", duration: "4:20", artworkColor: "#8db1a7" },
  { id: "schism", song: "Schism", artist: "Tool", part: "intro bass", mode: "bass", album: "Lateralus", duration: "6:47", artworkColor: "#58614d" },
  { id: "another-one-bites", song: "Another One Bites the Dust", artist: "Queen", part: "bass riff", mode: "bass", album: "The Game", duration: "3:35", artworkColor: "#31343b" },
  { id: "billie-jean", song: "Billie Jean", artist: "Michael Jackson", part: "bass groove", mode: "bass", album: "Thriller", duration: "4:54", artworkColor: "#d7d9dc" }
];

export const plans = [
  {
    id: "beginner",
    name: "Beginner",
    monthly: 6.99,
    annual: 39.99,
    trialAdaptations: 5,
    adaptations: "20 custom tone adaptations per month",
    saved: "15 saved tones per month",
    perks: ["Gear preset creation", "Guitar and bass mode", "Community tone lookup"]
  },
  {
    id: "expert",
    name: "Expert",
    monthly: 10.99,
    annual: 49.99,
    trialAdaptations: 8,
    adaptations: "Unlimited custom tone adaptations",
    saved: "Unlimited saved tones",
    perks: ["Gear preset creation", "Priority support", "Multi-FX preset translation", "Tone database access"]
  }
];

export function lookupGear(items: GearItem[], query: string) {
  const normalized = query.toLowerCase().trim();
  if (!normalized) {
    return items.slice(0, 6);
  }

  return items
    .filter((item) => `${item.name} ${item.description}`.toLowerCase().includes(normalized))
    .slice(0, 8);
}

export function buildToneResult(request: ToneRequest, toneProfile?: ToneProfileInput | null) {
  const seed = `${request.song}-${request.artist}-${request.guitar}-${request.amp}-${request.part}`;
  const total = seed.split("").reduce((acc, char) => acc + char.charCodeAt(0), 0);
  const baseSettings = toneProfile?.originalSettings || {
    gain: 3 + (total % 6),
    bass: 4 + (total % 4),
    mids: 4 + ((total >> 2) % 5),
    treble: 5 + ((total >> 3) % 4),
    presence: 4 + ((total >> 4) % 5),
    reverb: request.part.toLowerCase().includes("solo") ? 4 : 2,
    delay: request.part.toLowerCase().includes("lead") || request.part.toLowerCase().includes("solo") ? 5 : 1
  };
  const targetSettings = adaptSettings(baseSettings, request, toneProfile || null);
  const accuracy = toneProfile ? Math.min(96, Math.max(62, toneProfile.confidence + 8)) : 76 + (total % 19);
  const originalRig = toneProfile
    ? [
        toneProfile.originalGuitar || "Original guitar unknown",
        toneProfile.originalPickup ? `pickup/source: ${toneProfile.originalPickup}` : null,
        toneProfile.originalAmp || "Original amp unknown",
        toneProfile.originalCab || null,
        toneProfile.sourceSummary || null
      ]
        .filter(Boolean)
        .join(" | ")
    : request.mode === "bass"
      ? "Likely studio bass chain: direct signal, compressed tube-style amp, mild saturation."
      : "Likely source chain: humbucker guitar, British-style gain stage, delay/reverb after the amp.";
  const effects = toneProfile?.effects?.length
    ? toneProfile.effects.map((effect, index) => `${index + 1}. ${effect.effectName}${effect.placement ? ` (${effect.placement})` : ""}`)
    : request.effectsMode === "multi_fx"
      ? ["Amp block first", "Studio EQ after amp", "Stereo delay", "Room reverb"]
      : ["Low-gain boost", "Post-amp EQ", "Short ambience"];
  const playingTips = toneProfile?.playingNotes?.length
    ? [...toneProfile.playingNotes, ...toneProfile.adaptationNotes].slice(0, 6)
    : [
        "Match the part's pick intensity before changing amp gain.",
        "Set mids by ear against the track, then rebalance bass and presence.",
        "Use less reverb live than on headphones to keep the riff articulate."
      ];

  return {
    id: `${Date.now()}-${total}`,
    request,
    accuracy,
    originalRig,
    originalSettings: baseSettings,
    targetSettings,
    pickupAdvice: request.mode === "bass"
      ? "Favor the pickup blend with the clearest attack; roll tone back slightly if the low mids cloud up."
      : `Start with ${request.pickup || "your bridge pickup"} and lower the guitar volume until the pick attack opens up.`,
    effects,
    playingTips,
    sourceProfile: toneProfile
      ? {
          id: toneProfile.id,
          partType: toneProfile.partType,
          toneType: toneProfile.toneType,
          partLabel: toneProfile.partLabel,
          confidence: toneProfile.confidence,
          verificationStatus: toneProfile.verificationStatus
        }
      : null
  };
}

function adaptSettings(settings: Record<string, number>, request: ToneRequest, toneProfile: ToneProfileInput | null) {
  const target = { ...settings };
  const sourcePickup = `${toneProfile?.originalPickup || toneProfile?.originalGuitar || ""}`.toLowerCase();
  const userPickup = `${request.pickup || request.guitar}`.toLowerCase();
  const userAmp = request.amp.toLowerCase();
  const toneType = request.toneType || toneProfile?.toneType || "auto";

  if (sourcePickup.includes("single") && (userPickup.includes("humbucker") || userPickup.includes("les paul") || userPickup.includes("sg"))) {
    target.gain = clampKnob((target.gain || 5) - 1);
    target.bass = clampKnob((target.bass || 5) - 1);
    target.treble = clampKnob((target.treble || 5) + 1);
    target.presence = clampKnob((target.presence || 5) + 1);
  }

  if (sourcePickup.includes("humbucker") && (userPickup.includes("single") || userPickup.includes("strat") || userPickup.includes("tele"))) {
    target.gain = clampKnob((target.gain || 5) + 1);
    target.bass = clampKnob((target.bass || 5) + 1);
    target.treble = clampKnob((target.treble || 5) - 1);
  }

  if (userAmp.includes("katana") || userAmp.includes("mustang") || userAmp.includes("helix") || userAmp.includes("line 6")) {
    target.mids = clampKnob((target.mids || 5) + 1);
    target.presence = clampKnob((target.presence || 5) + 1);
  }

  if (toneType === "clean" || toneType === "acoustic" || toneType === "bass_clean") {
    target.gain = clampKnob(Math.min(target.gain || 3, toneType === "acoustic" ? 2 : 3));
    target.reverb = clampKnob(target.reverb ?? 2);
  }

  if (toneType === "distorted" || toneType === "high_gain" || toneType === "fuzz" || toneType === "bass_drive") {
    target.gain = clampKnob(Math.max(target.gain || 5, toneType === "high_gain" ? 8 : 6));
  }

  target.master = target.master ?? 6;

  return Object.fromEntries(Object.entries(target).map(([key, value]) => [key, clampKnob(value)]));
}

function clampKnob(value: number) {
  return Math.max(0, Math.min(10, Math.round(value)));
}
