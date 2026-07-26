---
name: tone-ugc-pipeline
description: Full UGC content pipeline for the guitar tone app. Generates AI creator characters, reaction videos, and social media posts using the 5 established personas (Jake, Sarah, Marcus, Alex, Dave). Triggers on "create tone content", "make UGC for the app", "tone app video", "generate content batch", or any request to produce marketing videos for the guitar tone adaptation app. Chains /ugc-hot-girl + /higgsfield-image-auto + /seedance-auto-generate + posting.
---

# Tone App UGC Pipeline

End-to-end content creation pipeline for the guitar tone adaptation app. Takes a song/tone from the app's database and produces a complete UGC reaction video with AI-generated creator, ready for multi-platform posting.

---

## 5 AI Creator Personas

Each persona has a distinct look, voice, and content angle. Rotate between them for variety.

### 1. Jake Morrison — The Hyped Beginner
- **Age**: 19-21, male
- **Look**: Messy dark hair, band tee, bedroom setup with LED strips
- **Energy**: Excited, wide-eyed, "bro this is insane" reactions
- **Soul 2.0 prompt style**: "Young guy, early 20s, messy dark brown hair, excited wide-eyed expression, mouth slightly open in amazement, wearing a vintage Metallica t-shirt, LED strip lights in background (purple/blue glow), close-up selfie angle, natural skin texture, shot on iPhone 15 Pro, photorealistic, 4K"
- **Video prompt style**: "The guy from @image1 reacts with genuine amazement, leaning forward toward camera, mouth drops open, then breaks into an excited grin. Points at something off-screen (the phone/app). Bedroom with LED lights, casual handheld camera feel, TikTok energy."
- **Hook format**: "BRO I just made my $200 amp sound like [ARTIST]"

### 2. Sarah Chen — The Gear Reviewer
- **Age**: 25-28, female
- **Look**: Clean setup, good lighting, analytical expression, minimalist style
- **Soul 2.0 prompt style**: "Young Asian woman, mid 20s, shoulder-length straight black hair with subtle highlights, thoughtful analytical expression, slight knowing smile, wearing a simple black crew neck, clean minimalist desk setup visible behind, ring light illumination, medium close-up, natural skin texture, photorealistic, 4K, shot on Sony A7III"
- **Video prompt style**: "The woman from @image1 examines something closely on a phone screen, nods thoughtfully, raises one eyebrow in impressed surprise, then looks at camera with a confident 'told you so' expression. Clean desk setup, professional ring light, calm and measured energy."
- **Hook format**: "I tested this tone matching app against a $3000 rig. Here's what happened."

### 3. Marcus Reed — The Metal Skeptic
- **Age**: 28-32, male
- **Look**: Beard, dark clothing, arms crossed initially, converted skeptic energy
- **Soul 2.0 prompt style**: "Man in late 20s, short dark beard, strong jawline, skeptical expression with one eyebrow raised, arms crossed, wearing plain black henley, dark moody room with warm side lighting, medium close-up, natural skin texture with slight stubble detail, photorealistic, 4K"
- **Video prompt style**: "The man from @image1 starts with arms crossed and skeptical expression. He uncrosses arms, leans in toward the screen, expression shifts from doubt to genuine surprise. Nods slowly in approval. Dark moody room, warm directional lighting, authentic reaction energy."
- **Hook format**: "I didn't believe this app could nail a [GENRE] tone. I was wrong."

### 4. Alex Rivera — The Broke Student
- **Age**: 20-22, male
- **Look**: Hoodie, messy dorm room, budget gear visible, genuine excitement
- **Soul 2.0 prompt style**: "Young Latino guy, early 20s, wavy dark hair slightly messy, genuine bright smile, wearing an oversized grey hoodie, small dorm room visible behind with posters and a cheap practice amp, warm natural window light from the left, close-up selfie angle, natural skin texture, candid energy, photorealistic, 4K, shot on iPhone"
- **Video prompt style**: "The guy from @image1 checks his phone screen, eyes go wide, breaks into a huge genuine smile, pumps fist slightly. Looks at camera like telling a friend exciting news. Messy dorm room background, natural window light, authentic casual energy."
- **Hook format**: "This FREE app just replaced $500 worth of pedals"

### 5. Dave Kowalski — The Dad Rocker
- **Age**: 42-48, male
- **Look**: Slightly graying hair, garage/basement setup, classic rock posters, warm nostalgic energy
- **Soul 2.0 prompt style**: "Middle-aged man, mid 40s, short brown hair with gray at temples, warm genuine smile with laugh lines, wearing a faded Led Zeppelin t-shirt, garage workshop/music room behind with classic rock posters and a tube amp visible, warm overhead lighting, medium close-up, natural weathered skin texture, friendly approachable energy, photorealistic, 4K"
- **Video prompt style**: "The man from @image1 listens to something, eyes soften with nostalgia, nods along slowly with a warm knowing smile. Touches chin thoughtfully, then looks at camera with an impressed 'not bad' expression. Garage music room, warm lighting, weekend vibe."
- **Hook format**: "My kids showed me this app and now I sound like [CLASSIC ARTIST] again"

---

## Pipeline Flow

```
Step 1: Pick a song/tone from the app database
Step 2: Pick a creator persona (rotate through 1-5)
Step 3: Generate character image  →  /ugc-hot-girl or use persona prompt above
Step 4: Generate reaction video   →  /seedance-auto-generate
Step 5: Write caption + hashtags  →  Platform-specific copy
Step 6: Post via Blotato/Postiz   →  MCP multi-platform publish
Step 7: Update SESSION-RESUME.md  →  Track progress
```

---

## Step-by-Step Automation

### Step 1: Select Content

Pick a song from the app's tone database. Good candidates:
- Popular songs people search for (Metallica, RHCP, Hendrix, etc.)
- Songs trending on social media right now
- Songs from the "verified" tone profiles list
- Genre variety: rotate between rock, metal, blues, pop, indie

### Step 2: Select Creator

Rotate through the 5 personas. Each creator has a natural genre fit:
- **Jake**: Pop-punk, modern metal, indie rock
- **Sarah**: Any genre (analytical angle works universally)
- **Marcus**: Metal, hard rock, djent, prog
- **Alex**: Budget-friendly angles, any genre
- **Dave**: Classic rock, blues, 70s/80s/90s rock

### Step 3: Generate Character Image

Use the persona's Soul 2.0 prompt from above. Run `/higgsfield-image-auto` with the prompt.

### Step 4: Generate Reaction Video

Combine the persona's video prompt style with the specific song context:

**Template:**
```
[PERSONA VIDEO PROMPT], reacting to hearing [SONG] by [ARTIST] tone
come through their amp. [PERSONA-SPECIFIC REACTION]. 
9:16 vertical, handheld camera feel, 8 seconds, TikTok/Reels energy.
```

**Example (Jake + "Enter Sandman"):**
```
The guy from @image1 reacts with genuine amazement to hearing the Enter 
Sandman guitar tone come through his small practice amp. His mouth drops 
open, he leans forward in disbelief, then breaks into an excited grin 
pointing at the amp. Bedroom with LED lights, casual handheld camera 
feel, 9:16 vertical, TikTok energy. "No way that's MY amp" energy.
```

Run `/seedance-auto-generate` with this prompt + the character image.

### Step 5: Write Platform Copy

**Instagram Reels caption template:**
```
[HOOK LINE from persona]

[1-2 sentences about what the app does]

Link in bio to try it free

#GuitarTone #[ARTIST] #[SONG] #ToneMatching #GuitarApp 
#GuitarGear #[GENRE] #GuitarPlayer #MusicTech
```

**YouTube Shorts title template:**
```
[HOOK LINE] #shorts #guitar #[ARTIST]
```

**AI Disclosure (ALWAYS include):**
```
Created with AI | AI-generated content
```

### Step 6: Post via MCP

If Blotato is connected:
```
Post this video to Instagram Reels and YouTube Shorts with the caption above.
Schedule for [TIME based on posting schedule in CLAUDE.md].
```

### Step 7: Update SESSION-RESUME.md

After each video, update the progress table:
```
| 1 | Jake Morrison | Done | Done | Done | Scheduled 9am | Complete |
```

---

## Batch Content Example

**Monday batch (3 videos):**

| Time | Creator | Song | Hook |
|------|---------|------|------|
| 9am | Jake | "Enter Sandman" — Metallica | "BRO my $200 amp just did Enter Sandman" |
| 2pm | Marcus | "Paranoid" — Black Sabbath | "I didn't believe this app could nail Sabbath tone. I was wrong." |
| 7pm | Screen recording | "Comfortably Numb" — Pink Floyd | [App demo, no AI creator needed] |

**Tuesday batch:**

| Time | Creator | Song | Hook |
|------|---------|------|------|
| 9am | Sarah | "Under the Bridge" — RHCP | "I tested this tone app against a real Strat + tube amp setup" |
| 2pm | Alex | "Smells Like Teen Spirit" — Nirvana | "This FREE app just nailed Kurt Cobain's tone on my budget amp" |
| 7pm | Dave | "Hotel California" — Eagles | "My kids showed me this app and now I sound like the Eagles again" |

---

## Quality Checklist

Before posting each video:
- [ ] AI disclosure label included in caption
- [ ] Hook lands in first 2 seconds
- [ ] 9:16 vertical format
- [ ] Song name and artist mentioned
- [ ] App name/link visible or mentioned
- [ ] Caption includes relevant hashtags (8-12)
- [ ] Scheduled at optimal time for target audience
