# Verified Tone Sprint — Progress Tracker

Deadline: Aug 1, 6 PM. Resume point for usage-limit interruptions — if the session stops, say "continue" and work resumes from the first unchecked item.

## Status

- [x] Batch 1 (Phase 42) — user requests + Weezer catalog + midwest emo (25 songs) — `20260731120000_phase42_verified_tone_profiles.sql`
- [x] Batch 2 (Phase 43) — pop-punk / emo deep cuts (25 songs) — `20260731130000_phase43_verified_tone_profiles.sql`
- [x] Batch 3 (Phase 44) — grunge / 90s alt deep cuts (25 songs) — `20260731140000_phase44_verified_tone_profiles.sql`
- [x] Batch 4 (Phase 45) — indie rock deep cuts (AM, Strokes, White Stripes, Interpol, Killers, Bloc Party, Vampire Weekend, YYYs — 25 songs) — `20260731150000_phase45_verified_tone_profiles.sql`
- [x] Batch 5 (Phase 46) — classic metal deep cuts (Metallica, Megadeth, Maiden, Priest, Pantera, Ozzy/Rhoads, Dio-era Sabbath, Slayer, Motorhead — 25 songs) — `20260731160000_phase46_verified_tone_profiles.sql`
- [x] Batch 6 (Phase 47) — viral/TikTok-era songs (Polyphia, bedroom pop, dream pop, jazz pop — 25 songs) — `20260731170000_phase47_verified_tone_profiles.sql`
- [x] Guard migration re-run — `20260731180000_guard_verified_profiles_phase42_47.sql`
- [x] Final audit — static integrity audit passed: 150 songs, 158 profiles, no duplicates, all JSON valid, settings in range
- [x] Commit + push
- [x] Run migrations on Supabase — phases 42-47 + guard applied via `supabase db push` (live count 1167)
- [x] Batch 7 (Phase 48) — 2000s alt/nu-metal + gaps (Creep, Hysteria bassline, QOTSA, RATM, Incubus — 25 songs) — pushed + live (count 1192)
- [x] Batch 8 (Phase 49) — modern metalcore (Sleep Token, Bad Omens, Spiritbox, Lorna Shore, Ghost, Gojira, Periphery — 25 songs) — pushed + live (count 1217)
- [x] Batch 9 (Phase 50) — 2020s rock revival + indie singer-songwriter (The 1975, GVF, Olivia Rodrigo, Phoebe Bridgers, Noah Kahan, Fontaines D.C., Harry Styles — 25 songs) — pushed + live (count 1242)
- [x] Batch 10 (Phase 51) — anime/J-rock canon (Unravel, Gurenge, AKFG, OOR, BABYMETAL, KICK BACK, The Rumbling — 25 songs) — pushed + live (count 1267)
- [x] Batch 11 (Phase 52) — Indian indie/Bollywood canon (Prateek Kuhad, Anuv Jain, KK, Arijit, Local Train, Jal Aadat, Rockstar — 25 songs) — pushed + live (count 1292; hid 3 stale Mohit Chauhan "Sadda Haq" templated rows)
- [x] Batch 12 (Phase 53) — K-rock/math rock/emo revival (DAY6, CHON, Covet, toe, tricot, Mom Jeans, TMP, Origami Angel, DGD, Sungha Jung — 25 songs) — pushed + live (count 1317)
- [x] Batch 13 (Phase 54) — pop-guitar canon + ska (Taylor Swift x6, Bruno Mars, Avril, No Doubt, 311, RBF, Interrupters — 25 songs) — pushed + live (count 1342; hid my duplicate Hey There Delilah song row — an older verified one existed under a different artist slug)
- [x] Batch 14 (Phase 55) — britpop + 90s radio + women of rock (Oasis deep cuts, The Verve, Pulp, 3EB, Joan Jett, Alanis, Cranberries Linger — 25 songs) — pushed + live (count 1367)
- [x] Batch 15 (Phase 56) — 60s canon + surf/rockabilly (Misirlou, Apache, Stray Cats, Dylan x3, Country Roads, Byrds, Rumble, Green Onions — 25 songs) — pushed + live (count 1391; hid 2 templated Paul Simon "The Boxer" rows)
- [x] Batch 16 (Phase 57) — 80s new wave/pop-rock riffs (Cars, Billy Idol, INXS, TFF, Pretenders, Outfield, My Sharona, Blondie, Benatar — 25 songs) — pushed + live (count 1416)
- [x] Batch 17 (Phase 58) — country canon (Morgan Wallen, Zach Top, Strait, Shania, Chicks, Vince Gill, Neon Moon, Wagon Wheel — 25 songs) — pushed + live (count 1438)
- [x] Search-gap tracking BUILT — `search_logs` table + logging in music/search route; tested live (gap query: `select normalized_query, count(*) from search_logs where db_match_count = 0 group by 1 order by 2 desc`)
- [x] Batch 18 (Phase 59) — DEMAND-DRIVEN from UG India top-100 tabs (Khat #1, Arz Kiya Hai #2, Saiyaara, Kabir Singh, Zara Zara, Pehla Nasha, Kabira, Night Changes, Goodness of God — 25 songs) — pushed + live (count 1463)
- [ ] Remaining UG-list gaps for a future batch: Khamoshiyan, Raabta, Jeena Jeena, Pani Da Rang, Samjhawan, Khuda Jaane, Phir Mohabbat, Lag Ja Gale, A Thousand Years, Let Down (Radiohead), Darkhaast, Haareya, Can't Help Falling in Love (check Elvis coverage)
- [x] Batch 19 (Phase 60) — US/GLOBAL demand-driven from UG all-time top-100 (Can't Help Falling in Love #3, Viva la Vida, The Scientist, Only Exception, Shallow, Let It Be, Hey Jude, Yesterday, Jolene, Chasing Cars, September Ends + acoustic arrangements of piano-ballad canon — 25 songs) — pushed + live (count 1488)
- [ ] NOTE: user's target audience is US — future demand batches should use UG GLOBAL/all-time + US-region lists, not the India-localized daily list (phase 59 used India list; still valuable for diaspora + current Discord users)
- [x] Batch 20 (Phase 61) — current US singer-songwriter/indie (The Night We Met, Cherry Wine, Mayer deep cuts incl. Neon, Billie Eilish x3, SZA x2, Gracie Abrams, Zach Bryan, Red Clay Strays — 25 songs) — pushed + live (count 1513)
- [x] Batch 21 (Phase 62) — funk-YouTube scene + post-rock + 2000s radio fills (Dean Town bassline, Cory Wong, Tom Misch, EITS, Blurry, The Reason, worship, Teenie Hodges — 25 songs) — pushed + live (count 1534)
- [x] Batch 22 (Phase 63) — power ballads + screen themes (November Rain + GNR Illusion era, I Remember You, When the Children Cry, Still Loving You, Top Gun Anthem, James Bond, The Last of Us, Red Right Hand, GoT — 25 songs) — pushed + live (count 1559)
- [x] Batch 23 (Phase 64) — folk/indie fingerpicking canon (Pink Moon, Between the Bars, Heartbeats, Mystery of Love, Holocene, Mumford x2, Bloom, Old Pine — 25 songs) — pushed + live (count 1584; hid 2 templated Little Lion Man rows)
- [x] Batch 24 (Phase 65) — classic rock deep cuts II (Zeppelin acoustic side, Stones Wild Horses/Sympathy, Bowie Heroes/Moonage, T. Rex, Child in Time, Riders on the Storm, American Woman, Black Betty — 25 songs) — pushed + live (count 1607)
- [x] Batch 25 (Phase 66) — punk/proto-punk canon + garage revival (Stooges, Marquee Moon, GSTQ, Misfits, Fugazi, NOFX, My Girl, The xx Intro, Jet, Hives, Wolfmother — 25 songs) — pushed + live (count 1631)
- [x] Batch 26 (Phase 67) — shoegaze/dream-pop canon (MBV glide guitar, Slowdive, Cocteau, Fade Into You, DIIV, Alvvays, Let Down, Weird Fishes, Hum Stars, Sonic Youth, Pavement — 25 songs) — pushed + live (count 1656)
- [x] Batch 27 (Phase 68) — 2010s festival rock + Aussie surf-indie + Latin fills (Kathleen, Naive, Wombats, Ocean Alley, Spacey Jane, Lamento Boliviano, Royal Blood split-signal bass — 25 songs) — pushed + live (count 1681)
- [x] Batch 28 (Phase 69) — industrial + melodeath + 2024-25 hits (Du Hast, NIN, Dragula, In Flames, Bard's Song, A Bar Song, Die With a Smile, LP Emptiness Machine, Ordinary, End of Beginning — 25 songs) — pushed + live (count 1705)
- [x] Batch 29 (Phase 70) — US jam/roots canon (Grateful Dead x5, Phish, Billy Strings, JBT Ocean, DMB, Romeo and Juliet, Brothers in Arms, The Weight, Ohio, Steely Dan, Classical Gas — 25 songs) — pushed + live (count 1727)
- [x] Batch 30 (Phase 71) — songbook second tier (Beatles x8, Queen acoustic, Floyd Wall acoustic, Eagles, S&G America, Never Going Back Again, Seger, Van Morrison, Dock of the Bay, Stand by Me — 25 songs) — pushed + live (count 1752)
- [x] Batch 31 (Phase 72) — delta blues roots + soul standards + Christmas canon (Son House, Skip James, Freight Train, People Get Ready, Soul Man, Jingle Bell Rock, Blue Christmas, Feliz Navidad, TSO — 25 songs) — pushed + live (count 1777)
- [x] Batch 32 (Phase 73) — classical canon + world/bossa + US reggae-rock + country fingerstyle (Asturias, Recuerdos, Spanish Romance, Girl from Ipanema, IZ Rainbow, Rebelution, Stick Figure, Windy and Warm, Trigger, Hank — 25 songs) — pushed + live (count 1802; SPRINT CROSSED 800 SONGS)
- [x] Batch 33 (Phase 74) — 2000s heavy completeness (ADTR x3, Slipknot singles, Korn, P.O.D., Bodies, post-hardcore canon: Underoath/Thrice/Thursday/Saosin, metalcore fills: INK/Parkway/Beartooth/AA — 25 songs) — pushed + live (count 1827)
- [x] Batch 34 (Phase 75) — 90s alt-radio singles (Flagpole Sitta, Sex and Candy, The Freshmen, I Alone, Shimmer, Take a Picture — 25 songs) — pushed + live (count 1852)
- [x] Batch 35 (Phase 76) — 2010s festival-radio + stomp-folk (Shut Up and Dance, Home, Way Down We Go, Stubborn Love, S.O.B., I Will Wait — 25 songs) — pushed + live (count 1877)
- [x] Batch 36 (Phase 77) — 2000s Britrock (Dakota, Chelsea Dagger, Libertines, Kaiser Chiefs, Valerie, Motorcycle Emptiness — 25 songs) — pushed + live (count 1902)
- [x] Batch 37 (Phase 78) — ICONIC BASSLINES as bass-mode profiles with mode-restricted deletes (Another One Bites the Dust, Billie Jean, Jamerson x2, Jaco, Schism, YYZ, Cliff's FWTBT intro, The Chain — 25 songs) — pushed + live (count 1927; guitar+bass coexist confirmed on FWTBT & Longview)
- [x] Batch 38 (Phase 79) — basslines vol. 2: funk/session legends (Larry Graham slap origin, Jamerson, Jaco Teen Town/Birdland, Rocco, Rainey's Peg, Lemmy, Harris gallop, Cliff's Orion, Entwistle's Real Me, Guns of Brixton — 25 songs) — pushed + live (count 1952; Sweet Emotion guitar+bass coexist confirmed)
- [ ] NOTE: audit script is now mode-aware; remaining "duplicate" flags are false positives from multi-part songs (same artist/song/mode with 2 part rows, e.g. The Weekend intro+chorus) — DB unique constraint (song+mode+part_type+tone_type+part_label) guarantees real uniqueness; include part_label in the audit key if it matters later
- [x] Batch 39 (Phase 80) — funk/soul guitar canon vol. 2 (Nolen chicken-scratch x3, Cropper Stax deep cuts, Respect, Grapevine, Shaft wah, Easy solo, Pusherman, Low Rider, Time Has Come Today — 25 songs) — pushed + live (count 1975)
- [x] Batch 40 (Phase 81) — riff-classic one-hitters + 70s-00s radio canon (Slow Ride, Stranglehold, 25 or 6 to 4/Kath, Rocky Mountain Way talk box, Foreigner, Runnin' Down a Dream, Kryptonite, Kravitz, Beautiful Day, China Grove, Suffragette City — 25 songs) — pushed + live (count 1999 — database effectively DOUBLED from 1018)
- [x] Batch 41 (Phase 82) — prog leftovers + J-rock vol 2 + tone-chaser leads (Silent Lucidity, Frame by Frame, Ready Steady Go, Robinson, New Born, Albatross/Peter Green, Bridge of Sighs/Uni-Vibe, Watermelon in Easter Hay, Rock Bottom, Emerald, Frampton talk box — 25 songs) — pushed + live (count 2024 — CROSSED 2,000)
- [x] Batch 42 (Phase 83) — basslines vol. 3: post-punk school + legendary bass parts (Hooky x5, Gallup x2, Tina's Psycho Killer, McCartney's Rain/Something, JPJ Lemon Song, Duff, Maxwell Murder, Peaches growl, Gigantic, Sabotage, Timmy C, Jamerson's My Girl, Stand by Me, Walk on the Wild Side, 46&2, Peace Sells — 25 songs) — pushed + live (count 2049; LWTUA guitar+bass coexist confirmed)
- [x] Batch 43 (Phase 84) — global canon + viral + 2000s one-hit alt (Kino Soviet monument x2, Molchat Doma, APT., Messy, La Flaca, Maldito Duende, OPM 214/Buwan/Ere, Indonesian Dan/Separuh Aku, First Day of My Life, Aeroplane Over the Sea, No Children, Teenage Dirtbag, Stacy's Mom — 25 songs) — pushed + live (count 2073)
- [x] Batch 50 (Phase 91) — J-Rock/anime canon per Discord tip (Kessoku Band x2, Kurenai, GazettE, GO!!!, Battle Without Honor, Clock Strikes, After Dark, Zetsubou Billy, Megitsune, Senbonzakura, Guren no Yumiya, Again, Kaikai Kitan, Asterisk) + modern metal fills (Blinding Faith, Hypa Hypa, Baba Yaga) — pushed + live (public count 2230; audit caught 5 phase-59 dups pre-push, swapped; deduped SiM post-push)
- [x] Batch 49 (Phase 90) — iconic weird/characteristic sounds per Reddit research (Just Like Heaven, Smiths x2, In-A-Gadda-Da-Vida, Cannonball, Jane's Addiction x2, Owner of a Lonely Heart, Roundabout, Beat It, Hocus Pocus, Hum Stars, Pepper, Rusty Cage, This Must Be the Place, Loser, Ocean Man, Peaches, Unsung, Green Machine — 25 songs) — pushed + live (public count 2206; deduped Roundabout/Stars/Owner vs old yes/hum artist slugs)
- [x] Batch 48 (Phase 89) — blues-legend gaps (B.B. King x2, Killing Floor, Cross Road Blues, Rollin' Stone, Let's Go Crazy) + 2000s emo/post-hardcore (Ohio Is for Lovers, King for a Day, Until the Day I Die, Deadbolt, You're Not Alone — 25 songs) — pushed + live (count 2189; consolidated dup B.B. King artist b-b-king → bb-king)
- [x] Batch 47 (Phase 88) — US female indie/alt + reggae-rock summer scene (Night Shift, Pristine, Be Sweet, Mitski x2, MJ Lenderman, Wednesday, American Teenager, girl in red, Garden Song, Badfish, All Mixed Up, MYSTERY, Closer to the Sun — 25 songs) — pushed + live (count 2164)
- [x] Batch 46 (Phase 87) — modern US country/red-dirt (wait in the truck, Rock and a Hard Place, Loud and Heavy, February 28 2016, Seneca Creek, Coal, White Horse, In Your Love, you look like you love me, Need a Favor — 25 songs) — pushed + live (count 2139)
- [x] Batch 45 (Phase 86) — US southern/blues revival + worship + 2010s teen canon (Midnight in Harlem, Soulshine, Larkin Poe, Kingfish, Way Maker, 10,000 Reasons, 5SOS x2, Sucker, Cough Syrup, Freaks, Dizzy on the Comedown — 25 songs) — pushed + live (count 2114; hid 4 templated Leeland Way Maker + 4 templated 10,000 Reasons dupes)
- [x] Batch 44 (Phase 85) — US radio completeness (VH Jump/Unchained/ATBL, R.E.M. x3, Summer of '69, Jack & Diane, Detroit Rock City, Sister Christian, Any Way You Want It, Round Here, Drops of Jupiter — 25 songs) — pushed + live (count 2092)
- [ ] Message .mr.toaster. (Go Away + Oakwood re-test) and aamesss — they said they'll test tomorrow (2026-08-01)

## Notes

- "Flutter" (tester said "by Claire") — artist unconfirmed, ASK TESTER which band before researching. Not in Batch 1.
- Quality bar: per-song researched or honestly-generic gear (never invented models), per-part settings, empty effects [] when recording used none, song-specific notes, honest confidence (68-85).
- Format: follow `20260725240000_phase12_verified_tone_profiles.sql` exactly (target CTE → delete effects/sources/profiles → insert admin_verified).
