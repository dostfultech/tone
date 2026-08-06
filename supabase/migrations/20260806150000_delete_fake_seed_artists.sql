-- Phase A: delete fake AI-generated artists (2026-08-06).
-- Migration 20260627181253 procedurally generated 96 fictional artists
-- ("Mason North", "Amber Satellite", "Atlas Bloom", ...) with template
-- song titles ("Midnight Parade", "Golden Hearts", ...). All their content
-- is starter_estimate noise that pollutes search results.
-- artists -> songs -> song_tone_profiles all cascade on delete.
begin;

create temp table fake_artist_names(name text primary key) on commit drop;
insert into fake_artist_names(name) values
  ('Avery Stone'),('Midnight Union'),('Harbor Lights'),('The Static Hearts'),('Marlowe & The Radio Club'),('Noah Vale'),('Velvet Circuit'),('Ember Lane'),
  ('North Coast Saints'),('The Sundown Theory'),('Mia Calder'),('Atlas Bloom'),('Silver Echo'),('The Electric Highways'),('Jonah Reed'),('Paper Satellites'),
  ('Luna Vesper'),('The Neon Atlas'),('Westline Drive'),('Riley Monroe'),('The Hollow Signals'),('Golden Arcade'),('Mason North'),('Ivy Meridian'),
  ('The Violet District'),('August Reverie'),('Signal Harbor'),('The Chrome Seasons'),('Nova Ember'),('Cedar Hollow'),('The Midnight Lines'),('Sage Anthem'),
  ('Roman Vale'),('The Afterlight'),('Cobalt Avenue'),('The Aurora Set'),('Ella Arden'),('Lowlight Parade'),('Monarch Fires'),('The Breakwater Club'),
  ('Skylane'),('The Velvet Youth'),('Scarlet Harbor'),('The Northern Frame'),('Ari Lennon'),('Blackroom Cinema'),('The Meridian Vale'),('Amber Satellite'),
  ('Caleb Stone'),('The Coastal Theory'),('Dawn Electric'),('The Silver Parade'),('Luca Hayes'),('The Atlas Reverie'),('Mila Hart'),('The Signal Coast'),
  ('Nico Wilder'),('The Quiet Divide'),('Olive Monroe'),('The Skyline Union'),('Parker Grey'),('The Crimson Detail'),('Quinn Archer'),('The Lantern Waves'),
  ('River Knox'),('The Marble City'),('Sienna Vale'),('The Alpine Static'),('Tobias Reed'),('The Modern Saints'),('Uma Calder'),('The Echo Borough'),
  ('Vera Sloan'),('The Cinder Theory'),('Wes Arden'),('The Harbour District'),('Xavier Lane'),('The Night Circuit'),('Yara Monroe'),('The Falling Atlas'),
  ('Zane Mercer'),('The Broken Theatre'),('Aster Reed'),('The Open Avenue'),('Bella North'),('The Shallow Oceans'),('Cassian Vale'),('The Lunar Project'),
  ('Delia Rose'),('The Cedar Signal'),('Ellis Ward'),('The Glass Frontier'),('Finn Harper'),('The Golden Transit'),('Gia Rowan'),('The Motion Hours');

-- Safety: never delete an artist that somehow has verified profiles.
do $$
declare
  protected int;
begin
  select count(*) into protected
  from public.artists a
  join fake_artist_names f on f.name = a.name
  where exists (
    select 1
    from public.songs s
    join public.song_tone_profiles p on p.song_id = s.id
    where s.artist_id = a.id
      and p.verification_status = 'admin_verified'
  );
  if protected > 0 then
    raise exception 'SAFETY ABORT: % fake-list artists have verified profiles — review before deleting', protected;
  end if;
end $$;

-- Also remove any orphan profiles that reference these artist names by text
-- (defensive; song_id cascade should cover them).
delete from public.song_tone_profiles p
using fake_artist_names f
where lower(p.artist_name) = lower(f.name);

delete from public.artists a
using fake_artist_names f
where a.name = f.name;

-- Post-conditions
do $$
declare
  leftover int;
  real_profiles int;
begin
  select count(*) into leftover
  from public.artists a
  join fake_artist_names f on f.name = a.name;
  if leftover > 0 then
    raise exception 'POST-CONDITION FAILED: % fake artists remain', leftover;
  end if;

  select count(*) into leftover
  from public.song_tone_profiles p
  join fake_artist_names f on lower(f.name) = lower(p.artist_name);
  if leftover > 0 then
    raise exception 'POST-CONDITION FAILED: % fake-artist profiles remain', leftover;
  end if;

  -- Real catalog untouched: Metallica must still be present and verified.
  select count(*) into real_profiles
  from public.song_tone_profiles
  where artist_name = 'Metallica' and verification_status = 'admin_verified';
  if real_profiles = 0 then
    raise exception 'POST-CONDITION FAILED: real verified content missing after cleanup';
  end if;
end $$;

commit;
