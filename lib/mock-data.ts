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
  cabinet?: string;
  pickup?: string;
  effectsMode?: string;
  multiFx?: string;
  selectedFx?: string;
  goingDirect?: boolean;
  customPickups?: {
    neck?: string;
    middle?: string;
    bridge?: string;
  };
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
  { id: "squier-strat", name: "Squier Stratocaster", description: "Classic Strat platform with bell-like cleans and affordable versatility." },
  { id: "les-paul", name: "Gibson Les Paul Standard", description: "Mahogany body, set neck, medium output humbuckers." },
  { id: "epiphone-les-paul", name: "Epiphone Les Paul", description: "Affordable single-cut with thick humbucker sustain and classic rock feel." },
  { id: "gibson-les-paul", name: "Gibson Les Paul", description: "Classic solid-body electric with dual humbuckers and rich midrange sustain." },
  { id: "prs-custom", name: "PRS Custom 24", description: "Balanced humbuckers with modern split-coil flexibility." },
  { id: "prs-se-custom-24", name: "PRS SE Custom 24", description: "Warm but versatile dual-humbucker design with modern playability." },
  { id: "ibanez-rg", name: "Ibanez RG550", description: "Fast superstrat platform with high-output bridge tones." },
  { id: "ibanez-rg-generic", name: "Ibanez RG", description: "High-output superstrat with fast neck and metal-friendly response." },
  { id: "ibanez-gio", name: "Ibanez GIO GRX70QA", description: "Budget HSH guitar built for flexible clean and rock tones." },
  { id: "ibanez-azes40", name: "Ibanez AZES40", description: "Modern AZ-style HSS guitar with versatile switching and balanced feel." },
  { id: "tele", name: "Fender Telecaster", description: "Tight bridge bite with a woody neck pickup." },
  { id: "squier-tele", name: "Squier Telecaster", description: "Simple, rugged Tele-style platform with twangy bridge character." },
  { id: "player-tele-hh", name: "Fender Player II Telecaster HH", description: "Dual-humbucker Tele with thicker mids and modern punch." },
  { id: "jazzmaster", name: "Fender Jazzmaster", description: "Wide single coils, airy mids, offset resonance." },
  { id: "jaguar", name: "Fender Jaguar", description: "Short-scale offset with bright attack and percussive rhythm feel." },
  { id: "sg", name: "Gibson SG Standard", description: "Lightweight dual humbucker guitar with upper-mid snap." },
  { id: "epiphone-sg", name: "Epiphone SG Standard", description: "Affordable SG-style guitar with bright humbuckers and classic hard-rock bite." },
  { id: "gretsch", name: "Gretsch G5420T", description: "Hollow body chime with Filter'Tron-style articulation." }
  ,{ id: "epiphone-casino", name: "Epiphone Casino", description: "Fully hollow thinline with dogear P-90 pickups and airy attack." }
  ,{ id: "es335", name: "Gibson ES-335", description: "Classic semi-hollow with warm sustain, punch, and wide dynamic range." }
  ,{ id: "es339-p90", name: "Epiphone ES-339 P-90 PRO", description: "Compact semi-hollow feel with punchy dual P-90 response." }
  ,{ id: "rickenbacker-330", name: "Rickenbacker 330", description: "Jangly semi-hollow double-cut prized for chime-rich cleans." }
  ,{ id: "harley-benton-sc450", name: "Harley Benton SC-450 CS", description: "Single-cut dual-humbucker platform with classic Les Paul-style weight and sustain." }
  ,{ id: "schecter-omen-extreme", name: "Schecter Omen Extreme-6", description: "Dual-humbucker rock guitar with coil-splitting and modern output." }
  ,{ id: "schecter-demon", name: "Schecter Demon-6", description: "Metal-focused active-pickup guitar with tight lows and aggressive gain response." }
  ,{ id: "schecter-c1-platinum", name: "Schecter C-1 Platinum", description: "Mahogany superstrat with high-output active voice and modern sustain." }
  ,{ id: "jackson-dinky", name: "Jackson Dinky", description: "High-output superstrat with fast neck and sharp modern attack." }
  ,{ id: "esp-mh10", name: "ESP LTD MH-10", description: "Entry-level superstrat geared toward driven rock and metal sounds." }
  ,{ id: "esp-ec256", name: "ESP LTD EC-256", description: "Single-cut mahogany guitar with punchy humbuckers and modern comfort." }
  ,{ id: "hss-strat", name: "HSS Stratocaster", description: "Versatile Strat layout with humbucker bridge and clear single-coil sparkle." }
  ,{ id: "yamaha-pacifica-112v", name: "Yamaha Pacifica 112V", description: "Quality HSS solid-body with balanced cleans and usable rock tones." }
  ,{ id: "yamaha-pacifica-012", name: "Yamaha Pacifica 012", description: "Entry-level HSS guitar with flexible clean-to-crunch range." }
  ,{ id: "evh-wolfgang-special", name: "EVH Wolfgang Special", description: "High-performance solidbody with dual humbuckers, Floyd Rose tremolo, and focused rock sustain." }
];

export const amps: GearItem[] = [
  { id: "deluxe", name: "Fender Deluxe Reverb", description: "Sparkly blackface clean tone and spring reverb." },
  { id: "champion-20", name: "Fender Champion 20", description: "Compact modeling combo with multiple voices and built-in effects." },
  { id: "champion-100", name: "Fender Champion 100", description: "Loud dual-channel combo with versatile clean and voiced gain modes." },
  { id: "frontman-20g", name: "Fender Frontman 20G", description: "Simple practice combo with familiar Fender clean and a drive channel." },
  { id: "mustang-lt25", name: "Fender Mustang LT25", description: "Small digital modeling combo with easy presets and headphone practice." },
  { id: "mustang-lt50", name: "Fender Mustang LT50", description: "12-inch modeling combo with expanded presets and room-filling output." },
  { id: "mustang-gtx50", name: "Fender Mustang GTX 50", description: "Wi-Fi-enabled 50-watt modeler with broad amp and effects coverage." },
  { id: "mustang-gtx100", name: "Fender Mustang GTX 100", description: "100-watt stage-ready modeler with deep amp and cab options." },
  { id: "mustang-micro", name: "Fender Mustang Micro", description: "Headphone amp with portable modeling tones and practice features." },
  { id: "plexi", name: "Marshall Super Lead 1959", description: "Classic Plexi crunch with vocal upper mids." },
  { id: "jcm800", name: "Marshall JCM800 2203", description: "Focused hard-rock gain with aggressive presence." },
  { id: "dsl40cr", name: "Marshall DSL40CR", description: "All-valve combo with classic Marshall gain and flexible channel switching." },
  { id: "mg30fx", name: "Marshall MG30FX", description: "Practice combo with onboard effects and classic Marshall-flavored voicing." },
  { id: "code-25", name: "Marshall CODE 25", description: "Compact modeling combo with Marshall MST preamp and cab simulation." },
  { id: "code-50", name: "Marshall CODE 50", description: "50-watt modeling combo with broad Marshall-inspired programmable tones." },
  { id: "ac30", name: "Vox AC30 Top Boost", description: "Chime, compression, and mid-forward breakup." },
  { id: "vox-mini-go-50", name: "VOX Mini GO 50", description: "Portable modeling combo with VET amp sounds and practice tools." },
  { id: "vox-vt40x", name: "Vox VT40X", description: "Valvetronix combo with tube-assisted preamp feel and flexible amp models." },
  { id: "vox-pathfinder-10", name: "Vox Pathfinder 10", description: "Small solid-state combo with bright cleans and simple control layout." },
  { id: "rectifier", name: "Mesa/Boogie Dual Rectifier", description: "Thick modern high gain and deep low end." },
  { id: "slo", name: "Soldano SLO-100", description: "Saturated lead gain with smooth harmonic sustain." },
  { id: "katana", name: "Boss Katana Artist", description: "Flexible modeling combo with effects and power scaling." },
  { id: "katana-gen3-50", name: "Boss Katana Gen 3 50W", description: "Updated 50-watt Katana combo with evolved Tube Logic response." },
  { id: "line6-spider", name: "Line 6 Spider", description: "Classic modeling combo with multiple amp voices and effects." },
  { id: "line6-spider-v20", name: "Line 6 Spider V 20", description: "Compact digital modeling combo with cab sims and practice features." },
  { id: "blackstar-idcore-v4", name: "Blackstar ID:Core V4", description: "Stereo modeling combo with multiple amp voices and effects." },
  { id: "orange-crush", name: "Orange Crush", description: "Solid-state combo with Orange-flavored clean and dirty channels." },
  { id: "orange-crush-12", name: "Orange Crush 12", description: "Small analog practice combo with a direct and punchy Orange voice." },
  { id: "positive-grid-spark", name: "Positive Grid Spark", description: "Desktop modeling amp with app-based preset control and practice tools." },
  { id: "peavey-vypyr-15", name: "Peavey Vypyr 15", description: "Modeling combo with multiple amps, effects, and metal-friendly tones." },
  { id: "joyo-dc-15", name: "Joyo DC-15", description: "Digital practice combo with multiple amp models and built-in rhythm functions." },
  { id: "yamaha-ga15ii", name: "Yamaha GA15II", description: "Compact two-channel practice combo with simple controls and solid cleans." },
  { id: "yamaha-thr", name: "Yamaha THR", description: "Desktop modeling amp known for polished low-volume tones and USB practice use." },
  { id: "roland-cube-10gx", name: "Roland Cube-10GX", description: "Small high-gain-capable practice combo with COSM modeling and app support." },
  { id: "nux-mighty-60", name: "Nux Mighty 60", description: "Affordable modeling combo with broad clean-to-high-gain coverage." },
  { id: "harley-benton-hb40mfx", name: "Harley Benton HB-40MFX", description: "40-watt modeling combo with onboard effects and multiple voicings." },
  { id: "helix", name: "Line 6 Helix Native", description: "Multi-amp modeler and effects platform." }
];

export const bassGuitars: GearItem[] = [
  { id: "precision", name: "Fender Precision Bass", description: "Split-coil punch and focused low mids." },
  { id: "jazz", name: "Fender Jazz Bass", description: "Dual single-coil definition with scooped blend." },
  { id: "stingray", name: "Music Man StingRay", description: "Active humbucker bite with clean low end." },
  { id: "rick", name: "Rickenbacker 4003", description: "Grinding treble presence and piano-like attack." },
  { id: "esp-surveyor-87", name: "ESP LTD Surveyor '87", description: "PJ-style bass with vintage attitude, modern electronics, and tight active response." },
  { id: "fender-aerodyne-jazz-pj", name: "Fender Aerodyne Jazz Bass PJ", description: "Sleek PJ bass with Jazz Bass comfort and Precision-style punch." },
  { id: "fender-cb60sce-acoustic-bass", name: "Fender CB-60SCE Acoustic Bass Guitar", description: "Acoustic-electric bass with onboard preamp for warm unplugged or direct tones." },
  { id: "fender-deluxe-active-jazz", name: "Fender Deluxe Active Jazz Bass", description: "Active Jazz Bass platform with flexible EQ and modern output." },
  { id: "fender-player-jaguar-bass", name: "Fender Player Jaguar Bass", description: "Offset PJ bass with punchy lows and versatile pickup blending." }
];

export const bassAmps: GearItem[] = [
  { id: "svt", name: "Ampeg SVT-CL", description: "Classic tube bass stack with growl." },
  { id: "b15", name: "Ampeg B-15N", description: "Vintage roundness and soft compression." },
  { id: "gk", name: "Gallien-Krueger 800RB", description: "Fast transient response and upper-mid snap." },
  { id: "darkglass", name: "Darkglass Microtubes 900", description: "Modern clean power and controllable drive." },
  { id: "acoustic-b26c", name: "Acoustic B26C Bass Combo", description: "Compact bass combo with simple EQ and practice-friendly punch." },
  { id: "aguilar-db750", name: "Aguilar DB 750", description: "Powerful hybrid bass head with high-voltage preamp and focused stage authority." },
  { id: "ampeg-pf50t", name: "Ampeg PF-50T", description: "All-tube Portaflex bass head with vintage warmth and recording-friendly DI." },
  { id: "cort-cm20b", name: "Cort CM20B", description: "20-watt solid-state bass combo for practice and clean bass fundamentals." },
  { id: "cort-cm40b", name: "Cort CM40B", description: "40-watt bass combo with expanded headroom and straightforward EQ." },
  { id: "cort-gb35j", name: "Cort GB35J", description: "Bass amp profile for clean practice tones and controlled low-end response." },
  { id: "crate-bx15", name: "Crate BX-15", description: "Small practice bass combo with simple controls and punchy low-mid response." },
  { id: "crazy-tube-hi-power", name: "Crazy Tube Circuits Hi Power", description: "Amp-in-a-box bass/guitar preamp flavor with direct-friendly vintage response." }
];

export const cabinets: GearItem[] = [
  { id: "mesa-recto-412", name: "Mesa/Boogie Rectifier 4x12", description: "Deep low end, tight high-gain focus, and modern projection." },
  { id: "marshall-1960a", name: "Marshall 1960A 4x12", description: "Classic British 4x12 with punchy mids and familiar rock bark." },
  { id: "orange-ppc212", name: "Orange PPC212", description: "Focused 2x12 response with rich mids and tight projection." },
  { id: "fender-deluxe-112", name: "Fender Deluxe Reverb 1x12", description: "Open 1x12 response for clean and edge-of-breakup tones." },
  { id: "ampeg-410hlf", name: "Ampeg SVT-410HLF", description: "4x10 bass cabinet with extended low end and aggressive punch." },
  { id: "darkglass-212", name: "Darkglass DG212N", description: "Modern bass 2x12 cab with tight lows and direct-ready feel." }
];

export const effectsCatalog: GearItem[] = [
  { id: "ua-dream-65", name: "Universal Audio Dream 65", description: "Amp-sim pedal for polished direct clean sounds." },
  { id: "walrus-acs1", name: "Walrus Audio ACS1", description: "Stereo amp and cab simulator for direct and hybrid rigs." },
  { id: "lr-baggs-session-di", name: "LR Baggs Session DI", description: "Acoustic preamp and DI with musical compression and EQ." },
  { id: "darkglass-alpha-omega-photon", name: "Darkglass Alpha Omega Photon", description: "Bass preamp and drive with cab simulation and modern bite." },
  { id: "boss-ns2", name: "Boss NS-2 Noise Suppressor", description: "Noise Gate | Utility" },
  { id: "cry-baby-wah", name: "Dunlop Cry Baby Wah", description: "Wah | Filter" },
  { id: "digitech-whammy", name: "DigiTech Whammy", description: "Pitch | Utility" },
  { id: "ir-loader", name: "IR Loader", description: "Cab Sim | IR Loader" },
  { id: "mxr-phase-90", name: "MXR Phase 90", description: "Phaser | Modulation" },
  { id: "ehx-electric-mistress", name: "EHX Electric Mistress", description: "Flanger | Modulation" }
];

export const pickups = [
  { id: "sd-jb", name: "Seymour Duncan JB", category: "High-output humbucker" },
  { id: "emg-81", name: "EMG 81", category: "Active humbucker" },
  { id: "emg-85", name: "EMG 85", category: "Active humbucker" },
  { id: "emg-87", name: "EMG 87", category: "Active high-output" },
  { id: "emg-89", name: "EMG 89", category: "Active coil-splittable humbucker" },
  { id: "paf", name: "PAF-style Humbucker", category: "Medium-output vintage" },
  { id: "hot-rails", name: "Hot Rails", category: "Single-coil sized humbucker" },
  { id: "vintage-single", name: "Vintage Single Coil", category: "Low-output single coil" },
  { id: "p90", name: "P-90", category: "Wide single coil" },
  { id: "dimarzio-super-distortion", name: "DiMarzio Super Distortion (DP100)", category: "High-output humbucker" },
  { id: "dimarzio-tone-zone", name: "DiMarzio Tone Zone (DP155)", category: "High-output warm humbucker" },
  { id: "dimarzio-evolution", name: "DiMarzio Evolution (DP159)", category: "High-output articulate humbucker" },
  { id: "bare-knuckle-nailbomb", name: "Bare Knuckle Nailbomb", category: "High-output rock humbucker" },
  { id: "fishman-fluence-modern", name: "Fishman Fluence Modern", category: "Multi-voice active humbucker" },
  { id: "fishman-fluence-classic", name: "Fishman Fluence Classic", category: "Multi-voice vintage humbucker" },
  { id: "sd-jazz", name: "Seymour Duncan Jazz (SH-2)", category: "Clear neck humbucker" },
  { id: "sd-ssl5", name: "Seymour Duncan SSL-5", category: "Overwound single coil" }
];

export const pedalPresets = [
  { id: "tight-rock", name: "Tight Rock Chain", category: "overdrive", pedals: ["Tube-style overdrive", "Graphic EQ", "Plate reverb"] },
  { id: "ambient-lead", name: "Ambient Lead", category: "delay", pedals: ["Analog delay", "Hall reverb", "Compressor"] },
  { id: "modern-metal", name: "Modern Metal", category: "distortion", pedals: ["Noise gate", "Boost", "Parametric EQ"] },
  { id: "vintage-clean", name: "Vintage Clean", category: "boost", pedals: ["Compressor", "Spring reverb", "Tape echo"] },
  { id: "ten-band-eq", name: "10-Band EQ", category: "EQ", pedals: ["Graphic EQ", "Utility", "Post gain shaping"] },
  { id: "ts9-tube-screamer", name: "TS9 Tube Screamer", category: "Overdrive", pedals: ["Overdrive", "Mid boost", "Tighten low end"] },
  { id: "classic-fuzz", name: "Classic Fuzz", category: "Fuzz", pedals: ["Fuzz", "Boost", "Vintage sustain"] },
  { id: "studio-compressor", name: "Studio Compressor", category: "Compressor", pedals: ["Compression", "Leveling", "Sustain"] },
  { id: "noise-gate", name: "Noise Gate", category: "Noise Gate", pedals: ["Gate", "Tight stops", "High gain cleanup"] },
  { id: "analog-delay", name: "Analog Delay", category: "Delay", pedals: ["Delay", "Slapback", "Lead ambience"] },
  { id: "spring-reverb", name: "Spring Reverb", category: "Reverb", pedals: ["Reverb", "Amp ambience", "Vintage space"] }
];

export const partOptions: Array<{ value: TonePartType; label: string }> = [
  { value: "main", label: "Main" },
  { value: "riff", label: "Riff" },
  { value: "rhythm", label: "Rhythm" },
  { value: "solo", label: "Solo" },
  { value: "lead", label: "Lead" },
  { value: "intro", label: "Intro" },
  { value: "chorus", label: "Chorus" },
  { value: "bridge", label: "Bridge" },
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
  { id: "perfect-ed-sheeran", song: "Perfect", artist: "Ed Sheeran", part: "main progression", mode: "guitar", album: "Divide (Deluxe)", duration: "4:23", artworkColor: "#42a5c8" },
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
    trialDays: 3,
    trialAdaptations: 3,
    adaptations: "20 custom tone adaptations per month",
    saved: "15 saved tones per month",
    perks: ["Gear preset creation", "Guitar and bass mode", "Community tone lookup"]
  },
  {
    id: "expert",
    name: "Expert",
    monthly: 10.99,
    annual: 49.99,
    trialDays: 3,
    trialAdaptations: 5,
    adaptations: "Unlimited custom tone adaptations",
    saved: "Unlimited saved tones",
    perks: ["Gear preset creation", "Priority support", "Multi-FX preset translation", "Tone database access"]
  }
];

export function lookupGear(items: GearItem[], query: string) {
  const normalized = query.toLowerCase().trim();
  if (!normalized) {
    return items.slice(0, 60);
  }

  return items
    .filter((item) => `${item.name} ${item.description}`.toLowerCase().includes(normalized))
    .slice(0, 60);
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
  const effects = request.goingDirect || request.effectsMode === "multi_fx"
    ? buildDirectEffects(request, toneProfile)
    : toneProfile?.effects?.length
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
    id: buildToneResultId(request, toneProfile || null, total),
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

function buildDirectEffects(request: ToneRequest, toneProfile?: ToneProfileInput | null) {
  const unit = request.multiFx || request.amp || "your modeler";
  const cab = request.cabinet || toneProfile?.originalCab || "matching cab IR";
  const baseEffects = toneProfile?.effects?.length
    ? toneProfile.effects.map((effect, index) => `${index + 1}. ${effect.effectName}${effect.placement ? ` (${effect.placement})` : ""}`)
    : ["Gate before amp block", "Studio EQ after cab block", "Delay and reverb last"];

  return [
    `Multi-FX patch: ${unit}`,
    `Amp block: ${toneProfile?.originalAmp || "closest matching amp model"}`,
    `Cab/IR block: ${cab}`,
    request.selectedFx ? `Available effects preset: ${request.selectedFx}` : "Post EQ, delay, and reverb after the cab block",
    ...baseEffects
  ].slice(0, 8);
}

function buildToneResultId(request: ToneRequest, toneProfile: ToneProfileInput | null, total: number) {
  const profileMarker = toneProfile ? toneProfile.id : "starter-fallback";
  return `tone-${profileMarker}-${buildDeterministicHash(`${request.song}|${request.artist}|${request.guitar}|${request.amp}|${request.part}|${total}`)}`.slice(0, 28);
}

function buildDeterministicHash(value: string) {
  let hash = 2166136261;
  for (let index = 0; index < value.length; index += 1) {
    hash ^= value.charCodeAt(index);
    hash = Math.imul(hash, 16777619);
  }

  return (hash >>> 0).toString(16).padStart(8, "0");
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
