// Amp-specific panel controls — the "deep" tweak parameters a particular amp exposes
// beyond the universal gain/bass/mid/treble knobs. This is what makes the output feel
// like it knows the user's exact amp. Every control below is a REAL control on the named
// amp; values are derived from the tone's character. Amps whose panel is just the standard
// EQ (e.g. a vintage Plexi, a JCM800, a plain Fender) return null — we never invent params.

export interface AmpPanelControl {
  key: string;
  label: string;
  value: string;
  note?: string;
}

export interface AmpPanelControls {
  title: string;
  controls: AmpPanelControl[];
}

export interface AmpPanelContext {
  ampName: string;
  originalAmp: string | null;
  toneType: string;
  partType: string;
  goingDirect: boolean;
}

const HEAVY_TONES = new Set(["high_gain", "metal", "modern_metal", "heavy", "djent"]);
const CLEAN_TONES = new Set(["clean", "acoustic", "bass_clean"]);
const CRUNCH_TONES = new Set(["crunch", "edge_of_breakup", "classic_rock"]);

const isHeavy = (t: string) => HEAVY_TONES.has(t);
const isClean = (t: string) => CLEAN_TONES.has(t);
const isCrunch = (t: string) => CRUNCH_TONES.has(t);
const isSolo = (p: string) => p === "solo" || p === "lead";

const gate = (t: string): AmpPanelControl => ({
  key: "noise_gate",
  label: "Noise Gate",
  value: isHeavy(t) ? "On — medium" : "Off / light",
  note: isHeavy(t) ? "Tames hum and string noise on high-gain patches." : "Not needed at lower gain."
});

function powerTubeFor(originalAmp: string | null, toneType: string): string {
  const amp = (originalAmp ?? "").toLowerCase();
  if (/vox|ac30|ac15/.test(amp)) return "EL84";
  if (/marshall|jcm|plexi|jtm|super lead|1959|jvm|dsl/.test(amp)) return "EL34";
  if (/princeton|champ|deluxe/.test(amp)) return "6V6";
  if (/fender|twin|bassman|vibro|super reverb|blackface|tweed/.test(amp)) return "6L6";
  if (/mesa|recto|mark|5150|6505|soldano|slo|engl|diezel|peavey/.test(amp)) return "6L6";
  if (isClean(toneType)) return "6V6";
  if (isCrunch(toneType)) return "EL34";
  return "6L6";
}

// ── Boss Katana (Tone Studio "Tube Logic" params + front panel) ──
function katana(ctx: AmpPanelContext): AmpPanelControl[] {
  const heavy = isHeavy(ctx.toneType);
  const clean = isClean(ctx.toneType);
  const solo = isSolo(ctx.partType);
  return [
    { key: "cab_resonance", label: "Cab Resonance", value: heavy ? "Modern" : "Vintage", note: heavy ? "Tightens the low end for high-gain riffing." : "Rounder, classic open-speaker response." },
    { key: "bloom", label: "Bloom", value: clean || solo ? "3" : "1", note: clean || solo ? "A little bloom fattens sustained notes and cleans." : "Keep low so palm-mutes stay tight." },
    { key: "sag", label: "Sag", value: heavy ? "2" : clean ? "5" : "4", note: heavy ? "Low sag = fast, tight power response." : "Adds vintage compression and touch feel." },
    { key: "bright", label: "Bright", value: clean ? "On" : "Off", note: clean ? "Adds sparkle to clean chords." : "Off keeps high-gain from getting fizzy." },
    { key: "solo_level", label: "Solo Level", value: solo ? "+6 dB" : "Off", note: solo ? "Engage the Solo boost so the lead cuts through." : "Leave off for rhythm parts." },
    { key: "power_control", label: "Power Control", value: "50W", note: "50W for band volume; drop to 0.5W for cranked feel at bedroom levels." }
  ];
}

// ── Boss Nextone (selectable power-tube type + Tone Studio params) ──
function nextone(ctx: AmpPanelContext): AmpPanelControl[] {
  const heavy = isHeavy(ctx.toneType);
  const clean = isClean(ctx.toneType);
  return [
    { key: "power_tube", label: "Power Tube", value: powerTubeFor(ctx.originalAmp, ctx.toneType), note: "Voices the power stage toward the original amp's tube type." },
    { key: "sag", label: "Sag", value: heavy ? "2" : clean ? "5" : "4", note: heavy ? "Low sag for a tight response." : "Adds vintage compression." },
    { key: "bright", label: "Bright", value: clean ? "On" : "Off" },
    { key: "power_control", label: "Power Control", value: "40W", note: "Full power for the band; lower for cranked feel quietly." }
  ];
}

// ── Blackstar ID / HT (ISF = American↔British voicing + Voice) ──
function blackstar(ctx: AmpPanelContext): AmpPanelControl[] {
  const heavy = isHeavy(ctx.toneType);
  const british = /marshall|vox|jcm|plexi|orange|hiwatt/i.test(ctx.originalAmp ?? "");
  const isf = british ? "8" : heavy ? "2" : isClean(ctx.toneType) ? "5" : "6";
  return [
    { key: "isf", label: "ISF", value: isf, note: "Fully down = American (tight, scooped); fully up = British (woody, mid-forward)." },
    { key: "voice", label: "Voice", value: isClean(ctx.toneType) ? "Clean Warm" : isCrunch(ctx.toneType) ? "Crunch" : "OD 1/2", note: "Pick the voice band matching the tone's gain." },
    gate(ctx.toneType)
  ];
}

// ── Line 6 Catalyst (6 amp voicings + Boost) ──
function catalyst(ctx: AmpPanelContext): AmpPanelControl[] {
  const voicing = isClean(ctx.toneType) ? "Clean / Chime" : isCrunch(ctx.toneType) ? "Crunch" : "Dynamic / Elektrik";
  return [
    { key: "voicing", label: "Amp Voicing", value: voicing, note: "Rotate the Amp knob to this voicing family." },
    { key: "boost", label: "Boost", value: isSolo(ctx.partType) || isHeavy(ctx.toneType) ? "On" : "Off", note: isSolo(ctx.partType) ? "Kick the Boost in for the lead." : isHeavy(ctx.toneType) ? "Tightens and pushes the high-gain voicing." : "Leave off for rhythm." },
    { key: "reverb", label: "Reverb", value: isClean(ctx.toneType) ? "Spring — low" : "Off / hint", note: "Onboard reverb; keep subtle." }
  ];
}

// ── Mesa/Boogie Rectifier (rectifier tracking + channel mode) ──
function rectifier(ctx: AmpPanelContext): AmpPanelControl[] {
  const heavy = isHeavy(ctx.toneType);
  return [
    { key: "rectifier", label: "Rectifier", value: heavy ? "Bold" : "Spongy", note: heavy ? "Diode/Bold for a tight, fast attack." : "Tube/Spongy for softer sag and feel." },
    { key: "channel_mode", label: "Channel Mode", value: heavy ? "Modern" : isCrunch(ctx.toneType) ? "Vintage" : "Raw", note: "Voicing mode on the active channel." },
    { key: "presence", label: "Presence", value: heavy ? "6" : "4", note: "Per-channel presence shapes the top-end bite." }
  ];
}

// ── Mesa Mark series (5-band graphic EQ) ──
function markSeries(ctx: AmpPanelContext): AmpPanelControl[] {
  return [
    {
      key: "graphic_eq",
      label: "5-Band Graphic EQ",
      value: isHeavy(ctx.toneType) ? "V-curve" : "Gentle smile",
      note: isHeavy(ctx.toneType)
        ? "Classic Mark metal V: 80Hz up, 240Hz down, 750Hz all the way down, 2.2k up, 6.6k up."
        : "Slight smile — nudge 80Hz and 2.2k up a touch, leave the mids near flat."
    },
    { key: "presence", label: "Presence / Treble Shift", value: isHeavy(ctx.toneType) ? "On" : "Off", note: "Engages the extra high-end voicing on Mark amps." }
  ];
}

// ── Vox AC30 / AC15 (Top Boost + Tone Cut) ──
function voxAc(ctx: AmpPanelContext): AmpPanelControl[] {
  return [
    { key: "channel", label: "Channel", value: "Top Boost", note: "The chime and gain live on the Top Boost channel." },
    { key: "tone_cut", label: "Tone Cut", value: isClean(ctx.toneType) ? "2" : "4", note: "Rolls off top-end after the phase inverter — raise it to tame fizz." },
    { key: "tremolo", label: "Tremolo", value: "Off", note: "Engage Speed/Depth only for vintage warble." }
  ];
}

// ── Roland JC-120 Jazz Chorus (Chorus/Vibrato + Bright) ──
function jazzChorus(ctx: AmpPanelContext): AmpPanelControl[] {
  return [
    { key: "chorus", label: "Chorus", value: isClean(ctx.toneType) ? "On — Rate 3 / Depth 5" : "Off", note: "The JC's signature stereo chorus; subtle on cleans." },
    { key: "bright", label: "Bright", value: "On", note: "Adds the glassy JC top-end sparkle." },
    { key: "channel", label: "Channel", value: "Channel 2 (Effect)", note: "Use the effect channel for chorus/reverb access." }
  ];
}

// ── Modern Marshall JVM / DSL (Resonance + mode) ──
function marshallModern(ctx: AmpPanelContext): AmpPanelControl[] {
  const heavy = isHeavy(ctx.toneType);
  return [
    { key: "resonance", label: "Resonance", value: heavy ? "6" : "4", note: "Deep control — sets low-end thump from the power stage." },
    { key: "mode", label: "Channel Mode", value: isClean(ctx.toneType) ? "Green (Clean)" : isCrunch(ctx.toneType) ? "Orange (Crunch)" : "Red (Lead)", note: "Green/Orange/Red LED per channel sets the gain voicing." },
    { key: "presence", label: "Presence", value: heavy ? "6" : "5" }
  ];
}

// ── EVH 5150III / Peavey 6505 / 5150 (Resonance + Bright) ──
function highGain5150(ctx: AmpPanelContext): AmpPanelControl[] {
  return [
    { key: "resonance", label: "Resonance", value: isHeavy(ctx.toneType) ? "6" : "4", note: "Low-end response for the power section — more for chugging riffs." },
    { key: "presence", label: "Presence", value: isHeavy(ctx.toneType) ? "6" : "5", note: "Post-EQ high-end cut/bite." },
    { key: "bright", label: "Bright", value: isClean(ctx.toneType) ? "On" : "Off" }
  ];
}

// ── Orange (Shape on the dirty channel) ──
function orange(ctx: AmpPanelContext): AmpPanelControl[] {
  return [
    { key: "shape", label: "Shape", value: isHeavy(ctx.toneType) ? "3" : "6", note: "Low = scooped/aggressive, high = mid-forward and thick." },
    { key: "channel", label: "Channel", value: isClean(ctx.toneType) ? "Clean" : "Dirty" }
  ];
}

// ── ENGL (Depth + Mid Boost) ──
function engl(ctx: AmpPanelContext): AmpPanelControl[] {
  return [
    { key: "depth", label: "Depth", value: isHeavy(ctx.toneType) ? "6" : "4", note: "Adds low-end punch to the power amp." },
    { key: "mid_boost", label: "Mid Boost", value: isSolo(ctx.partType) ? "On" : "Off", note: "Mid Boost pushes leads forward." }
  ];
}

// ── Fender blackface/silverface (Bright + Tremolo) ──
function fenderBlackface(ctx: AmpPanelContext): AmpPanelControl[] {
  return [
    { key: "bright", label: "Bright Switch", value: isClean(ctx.toneType) ? "On" : "Off", note: "Adds sparkle on cleans; switch off if it gets brittle when pushed." },
    { key: "tremolo", label: "Tremolo (Speed/Intensity)", value: "Off", note: "Engage only for surf/vintage warble." }
  ];
}

// Amp archetype detection → precise, honest description + the well-documented Line 6 Helix
// model name (Helix's amp list is stable and public). We name the ACTUAL original amp in the
// instruction, so it's specific and true regardless of the user's modeler; the Helix string is
// only surfaced when the user is on a Helix/HX/POD. Other modelers' proprietary model strings
// are intentionally NOT guessed.
// Archetype detection → precise character label + the specific model name inside the two
// modelers whose amp lists are public/stable: Line 6 Helix/HX and IK AmpliTube 5. Names are
// sourced (Helix docs; AmpliTube 5 gear list) — NOT guessed. Order: specific → broad.
type ModelerModels = { helix?: string; amplitube?: string };
const ARCHETYPES: Array<{ pattern: RegExp; label: string; models: ModelerModels }> = [
  { pattern: /deluxe\s*reverb/i, label: "a blackface Fender Deluxe clean", models: { helix: "US Deluxe Nrm", amplitube: "'65 Deluxe Reverb" } },
  { pattern: /princeton/i, label: "a Fender Princeton clean", models: { helix: "US Princess", amplitube: "'65 Princeton" } },
  { pattern: /super\s*reverb/i, label: "a Fender Super Reverb clean", models: { helix: "US Double Nrm", amplitube: "'65 Super Reverb" } },
  { pattern: /twin|vibrolux|vibroverb|blackface|silverface/i, label: "a blackface Fender clean", models: { helix: "US Double Nrm", amplitube: "'65 Twin Reverb" } },
  { pattern: /bassman|tweed|\bchamp\b/i, label: "a tweed Fender-style", models: { helix: "Tweed Blues Nrm", amplitube: "'53 Bassman" } },
  { pattern: /ac-?30|ac-?15|\bvox\b/i, label: "a Vox AC-style Class-A chime", models: { helix: "A30 Fawn Brt", amplitube: "BM 30" } },
  { pattern: /jcm\s*800|2203|2204/i, label: "a Marshall JCM800", models: { helix: "Brit 2204", amplitube: "Brit 8000" } },
  { pattern: /\bjvm\b|\bdsl\b|jcm\s*900/i, label: "a modern Marshall high-gain", models: { helix: "Brit 2204", amplitube: "Satch VM" } },
  { pattern: /plexi|super\s*lead|1959|\bjtm\b|\bjmp\b/i, label: "a Marshall Plexi 100W", models: { helix: "Brit Plexi Brt", amplitube: "Super Lead (Plexi)" } },
  { pattern: /triple\s*rec/i, label: "a Mesa Triple Rectifier high-gain", models: { helix: "Cali Rectifire Red", amplitube: "Triple Rectifier" } },
  { pattern: /dual\s*rec|rectifier|recto/i, label: "a Mesa Rectifier modern high-gain", models: { helix: "Cali Rectifire Red", amplitube: "Dual Rectifier" } },
  { pattern: /mark\s*iic|iic\+/i, label: "a Mesa Mark IIC+ lead", models: { helix: "Cali IV Lead", amplitube: "Mark IIC+" } },
  { pattern: /mark\s*iv/i, label: "a Mesa Mark IV lead", models: { helix: "Cali IV Lead", amplitube: "Mark IV" } },
  { pattern: /mark\s*(iii|v)|boogie\s*mark|\bmark\b/i, label: "a Mesa Mark-series lead", models: { helix: "Cali IV Lead", amplitube: "Mark IIC+" } },
  { pattern: /soldano|\bslo\b/i, label: "a Soldano SLO-100 boutique high-gain", models: { helix: "Solo Lead OD", amplitube: "SLD 100" } },
  { pattern: /5150|6505|\bevh\b/i, label: "an EVH / Peavey 5150 high-gain", models: { helix: "PV Panama", amplitube: "SJ50" } },
  { pattern: /diezel|\bvh4\b/i, label: "a Diezel modern high-gain", models: { helix: "Fatality", amplitube: "VHandcraft 4" } },
  { pattern: /friedman/i, label: "a Friedman hot-rodded Marshall", models: { helix: "Placater Dirty" } },
  { pattern: /hiwatt/i, label: "a Hiwatt clean/crunch", models: { helix: "WhoWatt 100", amplitube: "HiAmp" } },
  { pattern: /dumble|two-?rock|overdrive\s*special/i, label: "a Dumble-style smooth overdrive", models: { helix: "Line 6 Litigator" } },
  { pattern: /jazz\s*chorus|jc-?120/i, label: "a Roland JC clean", models: { helix: "Jazz Rivet 120", amplitube: "Jazz Amp 120" } },
  { pattern: /orange|rockerverb/i, label: "an Orange dirty-channel crunch", models: { amplitube: "RockerVerb 50" } },
  { pattern: /marshall/i, label: "a Marshall-style British crunch", models: { helix: "Brit Plexi Nrm", amplitube: "Super Lead (Plexi)" } }
];

function describeAmpArchetype(originalAmp: string | null): { label: string | null; models: ModelerModels } {
  if (!originalAmp) return { label: null, models: {} };
  const match = ARCHETYPES.find((entry) => entry.pattern.test(originalAmp));
  return match ? { label: match.label, models: match.models } : { label: null, models: {} };
}

function detectModeler(ampName: string): "helix" | "amplitube" | null {
  if (/helix|\bhx\b|line\s*6|\bpod\b/i.test(ampName)) return "helix";
  if (/amplitube|ik\s*multimedia/i.test(ampName)) return "amplitube";
  return null;
}

// The amp-model recommendation for a modeler user — always names the real original amp (so it's
// specific + true on any modeler), and gives the EXACT in-app model name when we can (Helix/HX,
// AmpliTube). Other modelers get the accurate archetype rather than a guessed model string.
function modelerAmpControl(ctx: AmpPanelContext): AmpPanelControl {
  if (!ctx.originalAmp) {
    return { key: "amp_model", label: "Amp Model", value: "Match to original", note: "Pick the amp model closest to the original amp." };
  }
  const arche = describeAmpArchetype(ctx.originalAmp);
  const modeler = detectModeler(ctx.ampName);
  const exactModel = modeler ? arche.models[modeler] : undefined;
  const modelerLabel = modeler === "helix" ? "Helix/HX" : "AmpliTube";

  if (exactModel) {
    // AmpliTube sells amp models à la carte, so the user may not own the exact one.
    // Lead with the specific model but make clear a similar owned model is fine.
    if (modeler === "amplitube") {
      return {
        key: "amp_model",
        label: "Amp Model",
        value: `"${exactModel}" or similar`,
        note: `AmpliTube models are sold separately — load "${exactModel}" if you own it, otherwise any similar ${ctx.originalAmp}-style model works.`
      };
    }
    return {
      key: "amp_model",
      label: "Amp Model",
      value: `"${exactModel}"`,
      note: `Load ${modelerLabel}'s "${exactModel}" model — its take on a ${ctx.originalAmp}.`
    };
  }

  const character = arche.label ? ` — ${arche.label}` : "";
  return {
    key: "amp_model",
    label: "Amp Model",
    value: `${ctx.originalAmp}-style`,
    note: `Load the model closest to a ${ctx.originalAmp}${character}.`
  };
}

// ── Generic app-modeler practice amps (Spark / Spider / Mustang / Vypyr / THR) ──
function appModeler(ctx: AmpPanelContext): AmpPanelControl[] {
  return [modelerAmpControl(ctx), gate(ctx.toneType)];
}

// ── Generic amp modeler / plugin (AmpliTube, Helix, Neural, Fractal, Boss GT, Pod…) ──
function pluginModeler(ctx: AmpPanelContext): AmpPanelControl[] {
  return [
    modelerAmpControl(ctx),
    gate(ctx.toneType),
    { key: "input_level", label: "Input Level", value: "Unity (0 dB)", note: "Set your interface input so the amp block sees a real instrument level." },
    { key: "cab_block", label: "Cab / IR Block", value: "On", note: "Keep the cab/IR block enabled — it is the speaker part of the tone." }
  ];
}

// Order matters: specific patterns before broad ones.
const PANEL_PROFILES: Array<{ pattern: RegExp; title: string; build: (ctx: AmpPanelContext) => AmpPanelControl[] }> = [
  { pattern: /katana/i, title: "Katana Controls", build: katana },
  { pattern: /nextone/i, title: "Nextone Controls", build: nextone },
  { pattern: /blackstar/i, title: "Blackstar Controls", build: blackstar },
  { pattern: /catalyst/i, title: "Catalyst Controls", build: catalyst },
  { pattern: /mark\s*(ii|iii|iv|v|c\+)|boogie\s*mark/i, title: "Mark Series Controls", build: markSeries },
  { pattern: /rectifier|recto|dual\s*rec|triple\s*rec/i, title: "Rectifier Controls", build: rectifier },
  { pattern: /\bac-?30\b|\bac-?15\b|vox\s*ac/i, title: "AC Controls", build: voxAc },
  { pattern: /jazz\s*chorus|jc-?120|roland\s*jc/i, title: "Jazz Chorus Controls", build: jazzChorus },
  { pattern: /\b(jvm|dsl)/i, title: "Marshall Controls", build: marshallModern },
  { pattern: /5150|6505|\bevh\b/i, title: "High-Gain Controls", build: highGain5150 },
  { pattern: /engl/i, title: "ENGL Controls", build: engl },
  { pattern: /orange|rockerverb/i, title: "Orange Controls", build: orange },
  { pattern: /twin|deluxe\s*reverb|princeton|vibrolux|vibroverb|super\s*reverb|bassman|blackface|silverface/i, title: "Fender Controls", build: fenderBlackface },
  { pattern: /spark|spider|mustang|vypyr|\bthr\b|thr-?\d/i, title: "Modeler Setup", build: appModeler }
];

export function buildAmpPanelControls(ctx: AmpPanelContext): AmpPanelControls | null {
  if (!ctx.ampName) {
    return null;
  }

  const matched = PANEL_PROFILES.find((profile) => profile.pattern.test(ctx.ampName));
  if (matched) {
    const controls = matched.build(ctx);
    return controls.length ? { title: matched.title, controls } : null;
  }

  // Going direct into a multi-fx unit / plugin: universal modeler guidance.
  if (ctx.goingDirect) {
    const controls = pluginModeler(ctx);
    return controls.length ? { title: "Modeler Setup", controls } : null;
  }

  // Physical, non-modeled amp whose panel is just the standard EQ — nothing extra to add.
  return null;
}
