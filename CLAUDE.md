# Tone App — Project Instructions

## About This Project
Guitar tone adaptation app. Users match famous guitar tones from songs using their own gear. The app has 1000+ verified tone profiles across 488 artists.

---

## Higgsfield UGC Video Pipeline

### Tools
- Image: Higgsfield Soul 2.0 (`/image/soul-v2`)
- Video: Seedance 2.0 (`/create/video?model=seedance_2_0`)
- UGC Factory: `/lipsync-studio?ugc-studio=true`

### Default Image Settings
- Model: Soul 2.0
- Aspect ratio: 3:4 (portrait)
- Resolution: 2K
- Count: 1

### Default Video Settings
- Model: Seedance 2.0
- Duration: 8s
- Ratio: 9:16 (vertical for Reels/Shorts)
- Resolution: 720p

### Critical Workflow Rules
- Clear prompt bar via JavaScript before typing new prompts
- Screenshot after clearing to confirm empty state
- Request user confirmation before clicking Generate (costs credits)
- Use `@image1` in video prompts to reference uploaded images
- Update SESSION-RESUME.md after each generation for crash recovery

### Prompt Bar Clearing (CRITICAL)

**Image pages (`/image/*`)** — Standard input:
```javascript
const input = document.querySelector('[id="hf:tour-image-prompt"]');
input.value = '';
input.dispatchEvent(new Event('input', { bubbles: true }));
```

**Video pages (`/create/video`)** — Lexical rich text editor:
```javascript
const editor = document.querySelector('[data-lexical-editor]');
editor.focus();
document.execCommand('selectAll');
document.execCommand('delete');
```

Per-prompt workflow:
1. Run JavaScript clear snippet
2. Screenshot and confirm empty
3. Type prompt (use `slowly: true` for Lexical on video pages)
4. Click Generate
5. Run clear immediately after
6. Wait 7 seconds
7. Repeat

---

## Content Brand Guidelines

### Target Audience
Guitar players who want to sound like their favorite songs — beginners to intermediate, ages 16-35.

### Content Style
- Faceless / AI UGC format (creator is from India, cannot show face)
- 70% screen recordings of the app, 20% AI UGC reaction videos, 10% hands-only guitar POV
- All content 9:16 vertical for Instagram Reels, YouTube Shorts (TikTok banned in India)
- Hook must land in first 2 seconds

### 5 AI Creator Personas (for UGC rotation)
1. **Jake Morrison** — Hyped beginner, "bro I just got this tone" energy
2. **Sarah Chen** — Calm gear reviewer, analytical breakdown style
3. **Marcus Reed** — Metal skeptic, "prove it" attitude, won over by results
4. **Alex Rivera** — Broke college student, excited about free/cheap gear solutions
5. **Dave Kowalski** — Weekend dad rocker, nostalgic classic rock vibe

### Hook Templates (proven formats from ToneAdapt)
- "I just matched [ARTIST]'s tone with a $200 amp"
- "POV: Your [CHEAP AMP] sounds like [EXPENSIVE AMP]"
- "This app just made my [AMP] sound like [SONG]"
- "Stop buying pedals. This is all you need."
- "[SONG] tone in 30 seconds"

### AI Disclosure (REQUIRED)
- India IT Rules 2026: "Clear and prominent" AI content labeling required
- Always add "AI-generated" or "Created with AI" in video description
- Instagram/YouTube: Use platform AI disclosure labels when available

---

## Social Media Posting

### Platforms (priority order)
1. Instagram Reels
2. YouTube Shorts
3. X / Twitter
4. Facebook Reels
5. Threads

### Posting Tools (MCP servers)
- Blotato: `mcp.blotato.com/mcp` — 9 platforms, $29/mo
- Postiz: Self-hosted, free, 30+ platforms
- Buffer: `mcp.buffer.com/mcp` — Free tier, create-only

### Posting Schedule
- 3x per day (ToneAdapt's proven cadence)
- Morning: Screen recording (app demo)
- Afternoon: AI UGC reaction video
- Evening: Hands-only guitar POV or trending audio remix
