# Tone Database

Canonical structure:

```text
artists -> songs -> song_parts -> master_tones -> master_tone_suggested_pedals
```

`master_tones` stores gear-independent musical targets: instrument/tone type, 0-10 controls, EQ/modulation, tempo, archetypes, pickup preference, abstract pedal suggestions, confidence, verification, metadata, and version. It must not store a user's concrete rig, final adapted output, prompt/completion, or cache result.

`song_tone_profiles`, effects, and sources are compatibility data. The v1 repository may bridge them when normalized knowledge is absent; do not remove them while callers/data remain.

Admin ingestion creates/revises normalized tones and review decisions. Reuse canonical identities, represent evidence honestly, version semantic changes, and ensure source/profile version changes invalidate cache keys.
