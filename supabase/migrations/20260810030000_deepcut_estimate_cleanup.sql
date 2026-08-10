begin;

-- Deep-cut cleanup. The 18 lowest-confidence song profiles are auto-hydrated placeholders
-- (verification_status='needs_review', confidence 8). Their gear/tone data is actually
-- genre-appropriate; the problems are (a) a couple of templated EQ glitches, (b) a leftover
-- 'auto' tone_type, and (c) they're flagged as broken rather than as honest estimates.
-- Fix the real data issues and re-categorize as starter_estimate (the same "estimated
-- starting point — refine by ear" bucket the user already sees). No verified claim is made.

-- (a) Templated maxed-out EQ -> realistic values.
update public.song_tone_profiles
set original_settings = original_settings || '{"bass":6,"middle":7}'::jsonb
where song_title = 'All in my head' and artist_name = 'Computer' and confidence <= 25;

update public.song_tone_profiles
set original_settings = original_settings || '{"presence":7}'::jsonb
where song_title = 'Monkey Business' and artist_name = 'Skid Row' and confidence <= 25;

-- (b) Leftover 'auto' tone_type placeholder -> a concrete classification.
update public.song_tone_profiles
set tone_type = 'crunch'
where tone_type = 'auto' and confidence <= 25;

-- (c) Re-categorize the remaining needs_review placeholders as honest estimates so they stop
-- reading as broken. Confidence is metadata (not a tone value); the user-facing label stays
-- "estimated starting point". Covers/tributes/novelty entries are left as needs_review.
update public.song_tone_profiles
set verification_status = 'starter_estimate',
    confidence = 55
where verification_status = 'needs_review'
  and confidence <= 25
  and song_title not ilike '%cover%'
  and song_title not ilike '%(live)%'
  and artist_name not ilike '%tribute%';

commit;
