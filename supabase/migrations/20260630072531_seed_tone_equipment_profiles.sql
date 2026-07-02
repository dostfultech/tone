alter table public.tone_adaptation_cache
  alter column source_profile_id drop not null;

comment on column public.tone_adaptation_cache.source_profile_id is
  'Database song_tone_profiles id when available. Null is allowed for starter/library profiles that are generated in application code.';

with profile_seed as (
  select
    gi.id as gear_item_id,
    gi.item_type as equipment_type,
    case
      when gi.item_type in ('guitar', 'bass_guitar') and coalesce(gi.pickup_type, '') ilike '%active%' then 'active_pickup_instrument'
      when gi.item_type in ('guitar', 'bass_guitar') and coalesce(gi.pickup_type, '') ilike '%humbucker%' then 'humbucker_instrument'
      when gi.item_type in ('guitar', 'bass_guitar') and coalesce(gi.pickup_type, '') ilike '%single%' then 'single_coil_instrument'
      when gi.item_type = 'amp' and coalesce(gi.amp_type, '') ilike '%modeling%' then 'modeling_guitar_amp'
      when gi.item_type = 'amp' and gi.voicing_tags && array['british', 'plexi', 'crunch'] then 'british_guitar_amp'
      when gi.item_type = 'amp' and gi.voicing_tags && array['blackface', 'sparkle', 'clean'] then 'american_clean_amp'
      when gi.item_type = 'amp' and gi.voicing_tags && array['modern', 'saturated', 'bass-heavy'] then 'modern_high_gain_amp'
      when gi.item_type = 'bass_amp' and gi.voicing_tags && array['modern', 'drive', 'tight'] then 'modern_bass_amp'
      when gi.item_type = 'bass_amp' and gi.voicing_tags && array['vintage', 'round', 'warm'] then 'vintage_bass_amp'
      when gi.item_type = 'multi_fx' then 'modeling_processor'
      when gi.item_type = 'pickup' then 'pickup'
      else concat(coalesce(gi.instrument_type, 'general'), '_', gi.item_type)
    end as transfer_class,
    case
      when gi.item_type in ('guitar', 'bass_guitar') then jsonb_build_object(
        'knobScale', '0-10',
        'controls', jsonb_build_array(
          jsonb_build_object('key', 'volume', 'label', 'Volume', 'type', 'knob', 'default', 10),
          jsonb_build_object('key', 'tone', 'label', 'Tone', 'type', 'knob', 'default', 7),
          jsonb_build_object('key', 'pickupSelector', 'label', 'Pickup selector', 'type', 'selector')
        )
      )
      when gi.item_type in ('amp', 'bass_amp') then jsonb_build_object(
        'knobScale', '0-10',
        'controls', jsonb_build_array(
          jsonb_build_object('key', 'gain', 'label', 'Gain', 'type', 'knob'),
          jsonb_build_object('key', 'bass', 'label', 'Bass', 'type', 'knob'),
          jsonb_build_object('key', 'mids', 'label', 'Mids', 'type', 'knob'),
          jsonb_build_object('key', 'treble', 'label', 'Treble', 'type', 'knob'),
          jsonb_build_object('key', 'presence', 'label', 'Presence', 'type', 'knob'),
          jsonb_build_object('key', 'master', 'label', 'Master', 'type', 'knob')
        )
      )
      when gi.item_type = 'multi_fx' then jsonb_build_object(
        'knobScale', '0-10',
        'controls', jsonb_build_array(
          jsonb_build_object('key', 'ampBlock', 'label', 'Amp block', 'type', 'model'),
          jsonb_build_object('key', 'cabBlock', 'label', 'Cab block', 'type', 'model'),
          jsonb_build_object('key', 'postEq', 'label', 'Post EQ', 'type', 'eq')
        )
      )
      else jsonb_build_object(
        'knobScale', '0-10',
        'controls', jsonb_build_array()
      )
    end as control_schema,
    jsonb_build_object(
      'displayName', concat(gi.brand, ' ', gi.model),
      'brand', gi.brand,
      'model', gi.model,
      'category', gi.category,
      'instrumentType', gi.instrument_type,
      'pickupType', gi.pickup_type,
      'ampType', gi.amp_type,
      'gainRange', gi.gain_range,
      'voicingTags', to_jsonb(gi.voicing_tags),
      'outputLevel', case
        when coalesce(gi.pickup_type, '') ilike '%active%' then 'active'
        when coalesce(gi.pickup_type, '') ilike '%high-output%' or gi.voicing_tags && array['high-output', 'aggressive'] then 'high'
        when coalesce(gi.pickup_type, '') ilike '%single%' or gi.voicing_tags && array['bright', 'glassy', 'twang', 'chime'] then 'low_medium'
        else 'medium'
      end,
      'gainCapacity', case
        when gi.gain_range = 'high' then 9
        when gi.gain_range = 'medium-high' then 8
        when gi.gain_range = 'low-high' then 7
        when gi.gain_range = 'medium' then 6
        when gi.gain_range = 'low-medium' then 4
        else 5
      end,
      'eqBias', jsonb_build_object(
        'gain', case
          when gi.item_type in ('guitar', 'bass_guitar', 'pickup') and coalesce(gi.pickup_type, '') ilike '%active%' then -2
          when gi.item_type in ('guitar', 'bass_guitar', 'pickup') and (coalesce(gi.pickup_type, '') ilike '%humbucker%' or gi.voicing_tags && array['high-output', 'aggressive']) then -1
          when gi.item_type in ('guitar', 'bass_guitar', 'pickup') and (coalesce(gi.pickup_type, '') ilike '%single%' or gi.voicing_tags && array['bright', 'glassy', 'twang', 'chime']) then 1
          when gi.item_type in ('amp', 'bass_amp') and gi.gain_range in ('high', 'medium-high', 'low-high') then -1
          when gi.item_type in ('amp', 'bass_amp') and gi.gain_range in ('low-medium', 'medium') then 1
          else 0
        end,
        'bass', case
          when gi.voicing_tags && array['bass-heavy', 'thick', 'round', 'low-mid', 'growl'] then -1
          when gi.voicing_tags && array['bright', 'glassy', 'twang', 'sparkle', 'single-coil'] or coalesce(gi.pickup_type, '') ilike '%single%' then 1
          else 0
        end,
        'mids', case
          when gi.voicing_tags && array['scooped'] then 1
          when gi.voicing_tags && array['mid-forward', 'upper-mid', 'british', 'growl'] then -1
          else 0
        end,
        'treble', case
          when gi.voicing_tags && array['bright', 'glassy', 'twang', 'chime', 'sparkle', 'cutting'] then -1
          when gi.voicing_tags && array['warm', 'thick', 'round', 'smooth', 'dark'] then 1
          else 0
        end,
        'presence', case
          when gi.voicing_tags && array['bright', 'aggressive', 'cutting', 'present'] then -1
          when gi.voicing_tags && array['warm', 'round', 'smooth', 'vintage'] then 1
          else 0
        end
      ),
      'toneTypeAdjustments', jsonb_build_object(
        'clean', jsonb_build_object('gain', -1),
        'crunch', jsonb_build_object('gain', case when gi.gain_range in ('high', 'medium-high', 'low-high') then -1 else 0 end),
        'distorted', jsonb_build_object('gain', case when gi.gain_range in ('high', 'medium-high', 'low-high') then -1 else 1 end),
        'high_gain', jsonb_build_object(
          'gain', case when gi.gain_range in ('high', 'medium-high', 'low-high') then -1 else 1 end,
          'bass', case when gi.voicing_tags && array['bass-heavy', 'thick', 'modern'] then -1 else 0 end,
          'mids', case when gi.voicing_tags && array['scooped', 'modern'] then 1 else 0 end
        ),
        'fuzz', jsonb_build_object('gain', -1, 'treble', case when gi.voicing_tags && array['bright', 'cutting'] then -1 else 0 end),
        'bass_clean', jsonb_build_object('gain', -1, 'compression', 1),
        'bass_drive', jsonb_build_object('gain', case when gi.gain_range in ('high', 'low-high') then -1 else 1 end, 'mids', 1)
      ),
      'advice', to_jsonb(array_remove(array[
        case when gi.item_type in ('guitar', 'bass_guitar') then 'Set instrument volume and tone before changing amp EQ.' end,
        case when gi.item_type in ('amp', 'bass_amp') then 'Use the gain range as a ceiling, then refine EQ against the recording.' end,
        case when gi.item_type = 'multi_fx' then 'Keep amp/cab blocks simple first, then add post EQ and ambience.' end,
        case when gi.item_type = 'pickup' then 'Use pickup output as the first gain-compensation step.' end
      ], null))
    ) as behavior_profile,
    case
      when gi.source_urls <> '{}'::text[] then 74
      else 66
    end as confidence
  from public.gear_items gi
  where gi.is_active = true
    and gi.item_type in ('guitar', 'bass_guitar', 'amp', 'bass_amp', 'pickup', 'multi_fx')
)
insert into public.tone_equipment_profiles (
  gear_item_id,
  equipment_type,
  schema_version,
  profile_version,
  transfer_class,
  control_schema,
  behavior_profile,
  confidence,
  source,
  is_active
)
select
  gear_item_id,
  equipment_type,
  1,
  1,
  transfer_class,
  control_schema,
  behavior_profile,
  confidence,
  'seed',
  true
from profile_seed
on conflict (gear_item_id, equipment_type) do update set
  schema_version = excluded.schema_version,
  profile_version = greatest(public.tone_equipment_profiles.profile_version, excluded.profile_version),
  transfer_class = excluded.transfer_class,
  control_schema = excluded.control_schema,
  behavior_profile = excluded.behavior_profile,
  confidence = excluded.confidence,
  source = excluded.source,
  is_active = true,
  updated_at = now();
