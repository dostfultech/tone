with profile_seed as (
  select *
  from jsonb_to_recordset($toneadapt_profiles$
  [
    {"title":"Master of Puppets","artist":"Metallica","album":"Master of Puppets","release_year":1986,"mode":"guitar","part_type":"riff","part_label":"main riff","tone_type":"distorted","genre":"metal","tone_category":"rhythm","difficulty":"expert","original_guitar":"ESP MX-220 style humbucker guitar","original_amp":"Mesa/Boogie Mark IIC+ high-gain amp","original_cab":"closed-back 4x12 guitar cab","original_pickup":"bridge humbucker","confidence":88,"versions_count":728,"era":"1980s"},
    {"title":"Enter Sandman","artist":"Metallica","album":"Metallica","release_year":1991,"mode":"guitar","part_type":"riff","part_label":"main riff","tone_type":"distorted","genre":"metal","tone_category":"rhythm","difficulty":"advanced","original_guitar":"ESP MX-220 black humbucker guitar","original_amp":"Mesa/Boogie Mark IIC+ high-gain amp","original_cab":"closed-back 4x12 guitar cab","original_pickup":"bridge humbucker","confidence":86,"versions_count":362,"era":"1990s"},
    {"title":"Sweet Child O' Mine","artist":"Guns N' Roses","album":"Appetite for Destruction","release_year":1987,"mode":"guitar","part_type":"riff","part_label":"intro riff","tone_type":"distorted","genre":"rock","tone_category":"lead","difficulty":"advanced","original_guitar":"mid-80s Kris Derrig Les Paul-style humbucker guitar","original_amp":"1977 Marshall Super Lead 100-watt head","original_cab":"Marshall 4x12 guitar cab","original_pickup":"neck humbucker for intro, bridge humbucker for bite","confidence":84,"versions_count":247,"era":"1980s"},
    {"title":"Hotel California","artist":"Eagles","album":"Hotel California","release_year":1976,"mode":"guitar","part_type":"solo","part_label":"dual-guitar outro solo","tone_type":"distorted","genre":"rock","tone_category":"lead","difficulty":"expert","original_guitar":"Fender Telecaster and Les Paul-style lead guitars","original_amp":"Fender black-panel Deluxe-style combo","original_cab":"open-back combo speaker","original_pickup":"bridge pickup with tone rolled slightly back","confidence":84,"versions_count":237,"era":"1970s"},
    {"title":"Comfortably Numb","artist":"Pink Floyd","album":"The Wall","release_year":1979,"mode":"guitar","part_type":"solo","part_label":"second solo","tone_type":"distorted","genre":"rock","tone_category":"lead","difficulty":"expert","original_guitar":"1969 Fender Stratocaster-style single-coil guitar","original_amp":"Hiwatt DR103 100-watt clean platform","original_cab":"WEM-style 4x12 guitar cab","original_pickup":"bridge or bridge-neck single-coil blend","confidence":84,"versions_count":198,"era":"1970s"},
    {"title":"Smells Like Teen Spirit","artist":"Nirvana","album":"Nevermind","release_year":1991,"mode":"guitar","part_type":"riff","part_label":"chorus riff","tone_type":"distorted","genre":"rock","tone_category":"rhythm","difficulty":"advanced","original_guitar":"early-90s Japanese Fender offset humbucker guitar","original_amp":"Mesa/Boogie Studio Preamp into power amp","original_cab":"4x12 guitar cab","original_pickup":"bridge humbucker","confidence":82,"versions_count":196,"era":"1990s"},
    {"title":"Floods","artist":"Pantera","album":"The Great Southern Trendkill","release_year":1996,"mode":"guitar","part_type":"solo","part_label":"main solo","tone_type":"distorted","genre":"metal","tone_category":"lead","difficulty":"expert","original_guitar":"Washburn Dime 333-style humbucker guitar","original_amp":"Randall RG-100ES solid-state amp","original_cab":"Randall 4x12 guitar cab","original_pickup":"bridge humbucker","confidence":84,"versions_count":170,"era":"1990s"},
    {"title":"Seek & Destroy","artist":"Metallica","album":"Kill 'Em All","release_year":1983,"mode":"guitar","part_type":"riff","part_label":"main riff","tone_type":"distorted","genre":"metal","tone_category":"rhythm","difficulty":"advanced","original_guitar":"1981 Gibson Flying V-style humbucker guitar","original_amp":"Marshall JMP 2203 modified 100-watt head","original_cab":"closed-back 4x12 guitar cab","original_pickup":"bridge humbucker","confidence":82,"versions_count":170,"era":"1980s"},
    {"title":"Creeping Death","artist":"Metallica","album":"Ride the Lightning","release_year":1984,"mode":"guitar","part_type":"riff","part_label":"main riff","tone_type":"distorted","genre":"metal","tone_category":"rhythm","difficulty":"advanced","original_guitar":"ESP MX220 custom humbucker guitar","original_amp":"Mesa/Boogie Mark IIC+ high-gain amp","original_cab":"closed-back 4x12 guitar cab","original_pickup":"bridge humbucker","confidence":82,"versions_count":169,"era":"1980s"},
    {"title":"Ain't Talkin' 'Bout Love","artist":"Van Halen","album":"Van Halen","release_year":1978,"mode":"guitar","part_type":"riff","part_label":"main riff","tone_type":"distorted","genre":"rock","tone_category":"rhythm","difficulty":"advanced","original_guitar":"Frankenstrat-style humbucker guitar","original_amp":"Marshall Super Lead-style plexi head","original_cab":"Marshall 4x12 guitar cab","original_pickup":"bridge humbucker","confidence":81,"versions_count":165,"era":"1970s"},
    {"title":"Unholy Confessions","artist":"Avenged Sevenfold","album":"Waking the Fallen","release_year":2003,"mode":"guitar","part_type":"riff","part_label":"main riff","tone_type":"distorted","genre":"metal","tone_category":"rhythm","difficulty":"advanced","original_guitar":"Gibson Les Paul-style humbucker guitar","original_amp":"Bogner Uberschall 120-watt tube head","original_cab":"closed-back 4x12 guitar cab","original_pickup":"bridge humbucker","confidence":81,"versions_count":163,"era":"2000s"},
    {"title":"My Own Summer (Shove It)","artist":"Deftones","album":"Around the Fur","release_year":1997,"mode":"guitar","part_type":"riff","part_label":"main riff","tone_type":"distorted","genre":"metal","tone_category":"rhythm","difficulty":"advanced","original_guitar":"ESP Stef B-7 seven-string humbucker guitar","original_amp":"Mesa/Boogie Dual Rectifier-style high-gain amp","original_cab":"oversized 4x12 guitar cab","original_pickup":"bridge humbucker","confidence":80,"versions_count":141,"era":"1990s"},
    {"title":"Everlong","artist":"Foo Fighters","album":"The Colour and the Shape","release_year":1997,"mode":"guitar","part_type":"riff","part_label":"driving main riff","tone_type":"distorted","genre":"rock","tone_category":"rhythm","difficulty":"advanced","original_guitar":"Gibson Explorer-style humbucker guitar","original_amp":"Mesa/Boogie Dual Rectifier-style amp","original_cab":"closed-back 4x12 guitar cab","original_pickup":"bridge humbucker","confidence":79,"versions_count":118,"era":"1990s"},
    {"title":"One","artist":"Metallica","album":"...And Justice for All","release_year":1988,"mode":"guitar","part_type":"riff","part_label":"heavy rhythm riff","tone_type":"distorted","genre":"metal","tone_category":"rhythm","difficulty":"advanced","original_guitar":"ESP MX-220 humbucker guitar","original_amp":"Mesa/Boogie Mark IIC+ high-gain amp","original_cab":"closed-back 4x12 guitar cab","original_pickup":"bridge humbucker","confidence":79,"versions_count":100,"era":"1980s"},
    {"title":"Walk","artist":"Pantera","album":"Vulgar Display of Power","release_year":1992,"mode":"guitar","part_type":"riff","part_label":"main riff","tone_type":"distorted","genre":"metal","tone_category":"rhythm","difficulty":"advanced","original_guitar":"Dean ML-style humbucker guitar","original_amp":"Randall RG-100ES solid-state amp","original_cab":"Randall 4x12 guitar cab","original_pickup":"bridge humbucker","confidence":79,"versions_count":100,"era":"1990s"},
    {"title":"Layla","artist":"Derek & The Dominos","album":"Layla and Other Assorted Love Songs","release_year":1970,"mode":"guitar","part_type":"riff","part_label":"main riff","tone_type":"distorted","genre":"rock","tone_category":"lead","difficulty":"advanced","original_guitar":"1960 Fender Stratocaster or humbucker lead guitar","original_amp":"Fender Champ tweed-style combo","original_cab":"small open-back combo speaker","original_pickup":"bridge or middle pickup","confidence":78,"versions_count":98,"era":"1970s"},
    {"title":"Be Quiet and Drive (Far Away)","artist":"Deftones","album":"Around the Fur","release_year":1997,"mode":"guitar","part_type":"riff","part_label":"main riff","tone_type":"distorted","genre":"metal","tone_category":"rhythm","difficulty":"advanced","original_guitar":"ESP Custom Stephen Carpenter-style humbucker guitar","original_amp":"ADA MP-1 preamp into power amp","original_cab":"4x12 guitar cab","original_pickup":"bridge humbucker","confidence":78,"versions_count":89,"era":"1990s"},
    {"title":"Fade to Black","artist":"Metallica","album":"Ride the Lightning","release_year":1984,"mode":"guitar","part_type":"solo","part_label":"outro solo","tone_type":"distorted","genre":"metal","tone_category":"lead","difficulty":"expert","original_guitar":"Gibson Flying V-style humbucker guitar","original_amp":"Marshall JCM800 2203-style head","original_cab":"closed-back 4x12 guitar cab","original_pickup":"bridge humbucker","confidence":78,"versions_count":84,"era":"1980s"},
    {"title":"Back In Black","artist":"AC/DC","album":"Back in Black","release_year":1980,"mode":"guitar","part_type":"riff","part_label":"main riff","tone_type":"distorted","genre":"rock","tone_category":"rhythm","difficulty":"intermediate","original_guitar":"Gibson SG Standard-style humbucker guitar","original_amp":"Marshall 1959 Super Lead 100-watt head","original_cab":"Marshall 4x12 guitar cab","original_pickup":"bridge humbucker","confidence":77,"versions_count":83,"era":"1980s"},
    {"title":"Money for Nothing","artist":"Dire Straits","album":"Brothers in Arms","release_year":1985,"mode":"guitar","part_type":"riff","part_label":"main riff","tone_type":"distorted","genre":"rock","tone_category":"rhythm","difficulty":"advanced","original_guitar":"Les Paul-style humbucker guitar","original_amp":"Laney-style British amplifier","original_cab":"closed-back guitar cab","original_pickup":"bridge humbucker with cocked-wah EQ","confidence":77,"versions_count":82,"era":"1980s"},
    {"title":"Cowboys from Hell","artist":"Pantera","album":"Cowboys from Hell","release_year":1990,"mode":"guitar","part_type":"riff","part_label":"main riff","tone_type":"distorted","genre":"metal","tone_category":"rhythm","difficulty":"advanced","original_guitar":"Dean ML-style humbucker guitar","original_amp":"Randall RG-series solid-state amp","original_cab":"Randall 4x12 guitar cab","original_pickup":"bridge humbucker","confidence":77,"versions_count":81,"era":"1990s"},
    {"title":"November Rain","artist":"Guns N' Roses","album":"Use Your Illusion I","release_year":1991,"mode":"guitar","part_type":"solo","part_label":"outro solo","tone_type":"distorted","genre":"rock","tone_category":"lead","difficulty":"expert","original_guitar":"Kris Derrig Les Paul-style humbucker guitar","original_amp":"Marshall Silver Jubilee 2555 100-watt head","original_cab":"Marshall 4x12 guitar cab","original_pickup":"neck humbucker for singing sustain","confidence":78,"versions_count":79,"era":"1990s"},
    {"title":"Bohemian Rhapsody","artist":"Queen","album":"A Night at the Opera","release_year":1975,"mode":"guitar","part_type":"solo","part_label":"featured solo","tone_type":"distorted","genre":"rock","tone_category":"lead","difficulty":"advanced","original_guitar":"Brian May Red Special-style guitar","original_amp":"Vox AC30 Top Boost-style combo","original_cab":"open-back combo speakers","original_pickup":"series single-coil pickup blend","confidence":77,"versions_count":77,"era":"1970s"},
    {"title":"Can't Stop","artist":"Red Hot Chili Peppers","album":"By the Way","release_year":2002,"mode":"guitar","part_type":"riff","part_label":"main riff","tone_type":"distorted","genre":"rock","tone_category":"rhythm","difficulty":"intermediate","original_guitar":"1960 Fender Stratocaster-style single-coil guitar","original_amp":"Marshall Major-style studio clean/crunch amp","original_cab":"4x12 guitar cab","original_pickup":"bridge or middle single-coil","confidence":76,"versions_count":75,"era":"2000s"},
    {"title":"Ride the Lightning","artist":"Metallica","album":"Ride the Lightning","release_year":1984,"mode":"guitar","part_type":"riff","part_label":"main riff","tone_type":"distorted","genre":"metal","tone_category":"rhythm","difficulty":"advanced","original_guitar":"Gibson Flying V-style humbucker guitar","original_amp":"Marshall JCM800-style high-gain head","original_cab":"closed-back 4x12 guitar cab","original_pickup":"bridge humbucker","confidence":77,"versions_count":74,"era":"1980s"},
    {"title":"Welcome To The Jungle","artist":"Guns N' Roses","album":"Appetite for Destruction","release_year":1987,"mode":"guitar","part_type":"riff","part_label":"main riff","tone_type":"distorted","genre":"rock","tone_category":"rhythm","difficulty":"advanced","original_guitar":"Kris Derrig Les Paul-style humbucker guitar","original_amp":"1977 Marshall Super Lead model 1959 head","original_cab":"Marshall 4x12 guitar cab","original_pickup":"bridge humbucker","confidence":76,"versions_count":68,"era":"1980s"},
    {"title":"Paranoid","artist":"Black Sabbath","album":"Paranoid","release_year":1970,"mode":"guitar","part_type":"riff","part_label":"main riff","tone_type":"distorted","genre":"metal","tone_category":"rhythm","difficulty":"intermediate","original_guitar":"1964 Gibson SG-style humbucker guitar","original_amp":"Laney Supergroup MK1 LA100BL-style head","original_cab":"Laney or Marshall 4x12 cab","original_pickup":"bridge humbucker","confidence":76,"versions_count":65,"era":"1970s"},
    {"title":"For Whom the Bell Tolls","artist":"Metallica","album":"Ride the Lightning","release_year":1984,"mode":"guitar","part_type":"riff","part_label":"main riff","tone_type":"distorted","genre":"metal","tone_category":"rhythm","difficulty":"advanced","original_guitar":"Gibson Explorer-style humbucker guitar","original_amp":"Marshall JMP 2203 modified 100-watt head","original_cab":"closed-back 4x12 guitar cab","original_pickup":"bridge humbucker","confidence":76,"versions_count":64,"era":"1980s"},
    {"title":"One","artist":"Metallica","album":"...And Justice for All","release_year":1988,"mode":"guitar","part_type":"riff","part_label":"clean intro riff","tone_type":"clean","genre":"metal","tone_category":"clean","difficulty":"advanced","original_guitar":"ESP MX220 custom humbucker guitar","original_amp":"Roland JC-120 Jazz Chorus-style clean amp","original_cab":"stereo clean combo speakers","original_pickup":"neck humbucker or split-coil clean setting","confidence":76,"versions_count":64,"era":"1980s"},
    {"title":"Slow Dancing in a Burning Room","artist":"John Mayer","album":"Continuum","release_year":2006,"mode":"guitar","part_type":"riff","part_label":"main riff","tone_type":"distorted","genre":"blues","tone_category":"lead","difficulty":"advanced","original_guitar":"2004 Fender Stratocaster-style single-coil guitar","original_amp":"Dumble Overdrive Special-style amp","original_cab":"open-back 2x12 guitar cab","original_pickup":"neck single-coil","confidence":76,"versions_count":63,"era":"2000s"},
    {"title":"Nothing Else Matters","artist":"Metallica","album":"Metallica","release_year":1991,"mode":"guitar","part_type":"solo","part_label":"featured solo","tone_type":"distorted","genre":"metal","tone_category":"lead","difficulty":"advanced","original_guitar":"ESP KH-2 or ESP MX220 humbucker guitar","original_amp":"Mesa/Boogie Mark IIC+ lead channel","original_cab":"closed-back 4x12 guitar cab","original_pickup":"neck humbucker for sustain","confidence":76,"versions_count":61,"era":"1990s"},
    {"title":"Stairway to Heaven","artist":"Led Zeppelin","album":"Led Zeppelin IV","release_year":1971,"mode":"guitar","part_type":"solo","part_label":"featured solo","tone_type":"distorted","genre":"rock","tone_category":"lead","difficulty":"advanced","original_guitar":"1959 Fender Telecaster-style single-coil guitar","original_amp":"Supro Coronado 1690T-style combo","original_cab":"small combo speaker","original_pickup":"bridge single-coil","confidence":76,"versions_count":61,"era":"1970s"},
    {"title":"Sultans of Swing","artist":"Dire Straits","album":"Dire Straits","release_year":1978,"mode":"guitar","part_type":"solo","part_label":"lead fills and solo","tone_type":"clean","genre":"rock","tone_category":"lead","difficulty":"advanced","original_guitar":"1978 Fender Stratocaster-style single-coil guitar","original_amp":"Fender Silverface Vibrolux-style clean combo","original_cab":"open-back 2x10 combo speakers","original_pickup":"bridge and middle single-coil blend","confidence":76,"versions_count":59,"era":"1970s"},
    {"title":"Animal I Have Become","artist":"Three Days Grace","album":"One-X","release_year":2006,"mode":"guitar","part_type":"riff","part_label":"main riff","tone_type":"distorted","genre":"rock","tone_category":"rhythm","difficulty":"intermediate","original_guitar":"Ibanez humbucker guitar","original_amp":"Diezel VH4-style high-gain amp","original_cab":"closed-back 4x12 guitar cab","original_pickup":"bridge humbucker","confidence":75,"versions_count":56,"era":"2000s"},
    {"title":"Crazy Train","artist":"Ozzy Osbourne","album":"Blizzard of Ozz","release_year":1980,"mode":"guitar","part_type":"riff","part_label":"main riff","tone_type":"distorted","genre":"metal","tone_category":"rhythm","difficulty":"advanced","original_guitar":"1974 Gibson Les Paul Custom-style humbucker guitar","original_amp":"1975-76 Marshall JMP 1959 Super Lead-style head","original_cab":"Marshall 4x12 guitar cab","original_pickup":"bridge humbucker","confidence":75,"versions_count":56,"era":"1980s"},
    {"title":"Basket Case","artist":"Green Day","album":"Dookie","release_year":1994,"mode":"guitar","part_type":"riff","part_label":"main riff","tone_type":"distorted","genre":"punk","tone_category":"rhythm","difficulty":"intermediate","original_guitar":"Fender Stratocaster Blue-style humbucker guitar","original_amp":"Marshall 1959 SLP-style amp","original_cab":"Marshall 4x12 guitar cab","original_pickup":"bridge humbucker","confidence":74,"versions_count":52,"era":"1990s"},
    {"title":"Pride and Joy","artist":"Stevie Ray Vaughan & Double Trouble","album":"Texas Flood","release_year":1983,"mode":"guitar","part_type":"riff","part_label":"shuffle riff","tone_type":"distorted","genre":"blues","tone_category":"lead","difficulty":"advanced","original_guitar":"1963 Fender Stratocaster-style single-coil guitar","original_amp":"Fender Vibroverb blackface-style combo","original_cab":"open-back combo speakers","original_pickup":"neck or middle single-coil","confidence":74,"versions_count":52,"era":"1980s"},
    {"title":"Blackened","artist":"Metallica","album":"...And Justice for All","release_year":1988,"mode":"guitar","part_type":"riff","part_label":"main riff","tone_type":"distorted","genre":"metal","tone_category":"rhythm","difficulty":"expert","original_guitar":"ESP MX220 EET-style humbucker guitar","original_amp":"Mesa/Boogie Mark IIC+ head","original_cab":"closed-back 4x12 guitar cab","original_pickup":"bridge humbucker","confidence":75,"versions_count":52,"era":"1980s"},
    {"title":"Nothing Else Matters","artist":"Metallica","album":"Metallica","release_year":1991,"mode":"guitar","part_type":"riff","part_label":"clean intro figure","tone_type":"clean","genre":"metal","tone_category":"clean","difficulty":"intermediate","original_guitar":"ESP MX220 custom humbucker guitar","original_amp":"Mesa/Boogie Mark IIC+ clean channel","original_cab":"closed-back 4x12 guitar cab","original_pickup":"neck humbucker clean setting","confidence":74,"versions_count":52,"era":"1990s"},
    {"title":"Beat It","artist":"Michael Jackson","album":"Thriller","release_year":1982,"mode":"guitar","part_type":"solo","part_label":"featured solo","tone_type":"distorted","genre":"rock","tone_category":"lead","difficulty":"expert","original_guitar":"Charvel Frankie Strat-style humbucker guitar","original_amp":"Marshall 1959 Super Lead-style head","original_cab":"Marshall 4x12 guitar cab","original_pickup":"bridge humbucker","confidence":75,"versions_count":50,"era":"1980s"},
    {"title":"Still Got the Blues","artist":"Gary Moore","album":"Still Got the Blues","release_year":1990,"mode":"guitar","part_type":"solo","part_label":"featured solo","tone_type":"distorted","genre":"blues","tone_category":"lead","difficulty":"advanced","original_guitar":"1959 Gibson Les Paul-style humbucker guitar","original_amp":"1989 Marshall JTM45 Reissue-style amp","original_cab":"Marshall 4x12 guitar cab","original_pickup":"neck humbucker","confidence":74,"versions_count":50,"era":"1990s"},
    {"title":"Panama","artist":"Van Halen","album":"1984","release_year":1984,"mode":"guitar","part_type":"riff","part_label":"main riff","tone_type":"distorted","genre":"rock","tone_category":"rhythm","difficulty":"advanced","original_guitar":"Kramer 5150 Frankenstein-style humbucker guitar","original_amp":"Marshall Super Lead 1959-style head","original_cab":"Marshall 4x12 guitar cab","original_pickup":"bridge humbucker","confidence":74,"versions_count":49,"era":"1980s"},
    {"title":"Nightmare","artist":"Avenged Sevenfold","album":"Nightmare","release_year":2010,"mode":"guitar","part_type":"riff","part_label":"main riff","tone_type":"distorted","genre":"metal","tone_category":"rhythm","difficulty":"advanced","original_guitar":"Schecter Synyster Gates-style humbucker guitar","original_amp":"Bogner Uberschall 120-watt tube head","original_cab":"closed-back 4x12 guitar cab","original_pickup":"bridge humbucker","confidence":74,"versions_count":48,"era":"2010s"},
    {"title":"Time","artist":"Pink Floyd","album":"The Dark Side of the Moon","release_year":1973,"mode":"guitar","part_type":"solo","part_label":"featured solo","tone_type":"distorted","genre":"rock","tone_category":"lead","difficulty":"advanced","original_guitar":"1969 Fender Stratocaster-style single-coil guitar","original_amp":"Hiwatt DR103 100-watt head","original_cab":"WEM-style 4x12 guitar cab","original_pickup":"bridge or neck single-coil blend","confidence":74,"versions_count":45,"era":"1970s"},
    {"title":"Come As You Are","artist":"Nirvana","album":"Nevermind","release_year":1991,"mode":"guitar","part_type":"riff","part_label":"clean intro riff","tone_type":"clean","genre":"rock","tone_category":"clean","difficulty":"intermediate","original_guitar":"1991-1992 Japanese Fender Kurt Cobain-style offset guitar","original_amp":"Fender clean combo-style amp","original_cab":"open-back combo speaker","original_pickup":"neck single-coil or humbucker clean setting","confidence":74,"versions_count":44,"era":"1990s"},
    {"title":"Iron Man","artist":"Black Sabbath","album":"Paranoid","release_year":1970,"mode":"guitar","part_type":"riff","part_label":"main riff","tone_type":"distorted","genre":"metal","tone_category":"rhythm","difficulty":"intermediate","original_guitar":"1965 Gibson SG-style humbucker guitar","original_amp":"Laney Supergroup MK1 100-watt head","original_cab":"Laney or Marshall 4x12 cab","original_pickup":"bridge humbucker","confidence":73,"versions_count":44,"era":"1970s"},
    {"title":"Bat Country","artist":"Avenged Sevenfold","album":"City of Evil","release_year":2005,"mode":"guitar","part_type":"riff","part_label":"main riff","tone_type":"distorted","genre":"metal","tone_category":"rhythm","difficulty":"advanced","original_guitar":"Schecter Synyster Gates Custom humbucker guitar","original_amp":"Bogner Uberschall-style high-gain head","original_cab":"closed-back 4x12 guitar cab","original_pickup":"bridge humbucker","confidence":73,"versions_count":44,"era":"2000s"},
    {"title":"Holy Wars... The Punishment Due","artist":"Megadeth","album":"Rust in Peace","release_year":1990,"mode":"guitar","part_type":"riff","part_label":"main riff","tone_type":"distorted","genre":"metal","tone_category":"rhythm","difficulty":"expert","original_guitar":"Jackson KV1-style humbucker guitar","original_amp":"Marshall JCM800 2203-style head","original_cab":"closed-back 4x12 guitar cab","original_pickup":"bridge humbucker","confidence":74,"versions_count":42,"era":"1990s"},
    {"title":"No More Tears","artist":"Ozzy Osbourne","album":"No More Tears","release_year":1991,"mode":"guitar","part_type":"riff","part_label":"main riff","tone_type":"distorted","genre":"metal","tone_category":"rhythm","difficulty":"advanced","original_guitar":"Les Paul-style humbucker guitar","original_amp":"Marshall JCM800 2203 100-watt head","original_cab":"Marshall 4x12 guitar cab","original_pickup":"bridge humbucker","confidence":73,"versions_count":40,"era":"1990s"},
    {"title":"Hail to the King","artist":"Avenged Sevenfold","album":"Hail to the King","release_year":2013,"mode":"guitar","part_type":"riff","part_label":"main riff","tone_type":"distorted","genre":"metal","tone_category":"rhythm","difficulty":"intermediate","original_guitar":"Schecter Synyster Gates-style humbucker guitar","original_amp":"Schecter Hellwin Stage-style high-gain amp","original_cab":"closed-back 4x12 guitar cab","original_pickup":"bridge humbucker","confidence":73,"versions_count":40,"era":"2010s"},
    {"title":"Symphony of Destruction","artist":"Megadeth","album":"Countdown to Extinction","release_year":1992,"mode":"guitar","part_type":"riff","part_label":"main riff","tone_type":"distorted","genre":"metal","tone_category":"rhythm","difficulty":"intermediate","original_guitar":"Jackson King V-style humbucker guitar","original_amp":"Marshall JMP-1 tube MIDI preamp into power amp","original_cab":"Marshall 4x12 guitar cab","original_pickup":"bridge humbucker","confidence":73,"versions_count":39,"era":"1990s"},
    {"title":"Kickstart My Heart","artist":"Motley Crue","album":"Dr. Feelgood","release_year":1989,"mode":"guitar","part_type":"riff","part_label":"main riff","tone_type":"distorted","genre":"rock","tone_category":"rhythm","difficulty":"intermediate","original_guitar":"Kramer Baretta-style humbucker guitar","original_amp":"Marshall Super Lead plexi-style 100-watt head","original_cab":"Marshall 4x12 guitar cab","original_pickup":"bridge humbucker","confidence":72,"versions_count":39,"era":"1980s"},
    {"title":"Purple Rain","artist":"Prince & The Revolution","album":"Purple Rain","release_year":1984,"mode":"guitar","part_type":"riff","part_label":"clean rhythm figure","tone_type":"clean","genre":"rock","tone_category":"clean","difficulty":"intermediate","original_guitar":"Rickenbacker or Hohner-style hot-rodded guitar","original_amp":"Mesa/Boogie Mark-style clean amp","original_cab":"open-back guitar cab","original_pickup":"single-coil or split-coil clean setting","confidence":72,"versions_count":38,"era":"1980s"},
    {"title":"Purple Rain","artist":"Prince & The Revolution","album":"Purple Rain","release_year":1984,"mode":"guitar","part_type":"solo","part_label":"outro solo","tone_type":"distorted","genre":"rock","tone_category":"lead","difficulty":"advanced","original_guitar":"Hohner HG-490 Madcat Tele-style guitar","original_amp":"Mesa/Boogie Mark-style lead amp","original_cab":"open-back guitar cab","original_pickup":"bridge single-coil","confidence":72,"versions_count":35,"era":"1980s"},
    {"title":"Killing in the Name (Live at 2000)","artist":"Rage Against the Machine","album":"Live at the Grand Olympic Auditorium","release_year":2000,"mode":"guitar","part_type":"riff","part_label":"live main riff","tone_type":"distorted","genre":"rock","tone_category":"rhythm","difficulty":"intermediate","original_guitar":"custom Arm The Homeless-style humbucker guitar","original_amp":"Marshall JCM800 2205-style head","original_cab":"Marshall 4x12 guitar cab","original_pickup":"bridge humbucker","confidence":72,"versions_count":38,"era":"2000s"},
    {"title":"Aerials","artist":"System of a Down","album":"Toxicity","release_year":2001,"mode":"guitar","part_type":"riff","part_label":"main riff","tone_type":"distorted","genre":"metal","tone_category":"rhythm","difficulty":"intermediate","original_guitar":"Ibanez Iceman IC300-style humbucker guitar","original_amp":"Mesa/Boogie Triple Rectifier-style amp","original_cab":"oversized 4x12 guitar cab","original_pickup":"bridge humbucker","confidence":72,"versions_count":37,"era":"2000s"},
    {"title":"Cemetery Gates","artist":"Pantera","album":"Cowboys from Hell","release_year":1990,"mode":"guitar","part_type":"riff","part_label":"main riff","tone_type":"distorted","genre":"metal","tone_category":"rhythm","difficulty":"advanced","original_guitar":"Dean ML 1981-style humbucker guitar","original_amp":"Randall RG100ES solid-state amp","original_cab":"Randall 4x12 guitar cab","original_pickup":"bridge humbucker","confidence":72,"versions_count":37,"era":"1990s"},
    {"title":"Afterlife","artist":"Avenged Sevenfold","album":"Avenged Sevenfold","release_year":2007,"mode":"guitar","part_type":"riff","part_label":"main riff","tone_type":"distorted","genre":"metal","tone_category":"rhythm","difficulty":"advanced","original_guitar":"Schecter Synyster Gates Custom humbucker guitar","original_amp":"Bogner Uberschall-style high-gain amp","original_cab":"closed-back 4x12 guitar cab","original_pickup":"bridge humbucker","confidence":72,"versions_count":37,"era":"2000s"},
    {"title":"Highway to Hell","artist":"AC/DC","album":"Highway to Hell","release_year":1979,"mode":"guitar","part_type":"riff","part_label":"main riff","tone_type":"distorted","genre":"rock","tone_category":"rhythm","difficulty":"intermediate","original_guitar":"Gibson SG Standard-style humbucker guitar","original_amp":"Marshall Super Lead 1959-style head","original_cab":"Marshall 4x12 guitar cab","original_pickup":"bridge humbucker","confidence":72,"versions_count":37,"era":"1970s"},
    {"title":"Seize the Day","artist":"Avenged Sevenfold","album":"City of Evil","release_year":2005,"mode":"guitar","part_type":"solo","part_label":"featured solo","tone_type":"distorted","genre":"metal","tone_category":"lead","difficulty":"advanced","original_guitar":"Schecter Synyster Gates-style humbucker guitar","original_amp":"Mesa/Boogie Dual Rectifier-style amp","original_cab":"closed-back 4x12 guitar cab","original_pickup":"neck humbucker for solo sustain","confidence":72,"versions_count":36,"era":"2000s"},
    {"title":"Raining Blood","artist":"Slayer","album":"Reign in Blood","release_year":1986,"mode":"guitar","part_type":"riff","part_label":"main riff","tone_type":"distorted","genre":"metal","tone_category":"rhythm","difficulty":"advanced","original_guitar":"B.C. Rich Bich circa-1986 humbucker guitar","original_amp":"Marshall JCM800-style high-gain head","original_cab":"closed-back 4x12 guitar cab","original_pickup":"bridge humbucker","confidence":72,"versions_count":36,"era":"1980s"},
    {"title":"Sad But True","artist":"Metallica","album":"Metallica","release_year":1991,"mode":"guitar","part_type":"riff","part_label":"main riff","tone_type":"distorted","genre":"metal","tone_category":"rhythm","difficulty":"intermediate","original_guitar":"ESP MX-220 black-finish humbucker guitar","original_amp":"Mesa/Boogie Mark IIC+ high-gain amp","original_cab":"closed-back 4x12 guitar cab","original_pickup":"bridge humbucker","confidence":72,"versions_count":36,"era":"1990s"},
    {"title":"Faint","artist":"Linkin Park","album":"Meteora","release_year":2003,"mode":"guitar","part_type":"riff","part_label":"main riff","tone_type":"distorted","genre":"rock","tone_category":"rhythm","difficulty":"intermediate","original_guitar":"PRS Custom 24 humbucker guitar","original_amp":"Mesa/Boogie Dual Rectifier-style amp","original_cab":"oversized 4x12 guitar cab","original_pickup":"bridge humbucker","confidence":72,"versions_count":36,"era":"2000s"},
    {"title":"Come As You Are","artist":"Nirvana","album":"Nevermind","release_year":1991,"mode":"guitar","part_type":"riff","part_label":"distorted chorus riff","tone_type":"distorted","genre":"rock","tone_category":"rhythm","difficulty":"intermediate","original_guitar":"Japanese Fender Kurt Cobain-style offset guitar","original_amp":"Mesa/Boogie Studio-style preamp or clean amp with chorus/distortion","original_cab":"4x12 guitar cab","original_pickup":"bridge pickup","confidence":72,"versions_count":35,"era":"1990s"},
    {"title":"Man in the Box (Live)","artist":"Alice In Chains","album":"Live","release_year":2000,"mode":"guitar","part_type":"riff","part_label":"live main riff","tone_type":"distorted","genre":"metal","tone_category":"rhythm","difficulty":"intermediate","original_guitar":"G&L Rampage-style humbucker guitar","original_amp":"Bogner Fish preamp into tube power amp","original_cab":"closed-back 4x12 guitar cab","original_pickup":"bridge humbucker","confidence":72,"versions_count":35,"era":"1990s"},
    {"title":"Babydoll","artist":"Dominic Fike","album":"Don't Forget About Me, Demos","release_year":2018,"mode":"guitar","part_type":"riff","part_label":"main riff","tone_type":"distorted","genre":"rock","tone_category":"rhythm","difficulty":"beginner","original_guitar":"Fender Stratocaster-style electric guitar","original_amp":"unknown direct or small-combo amp chain","original_cab":"studio DI or compact combo speaker","original_pickup":"bridge or middle single-coil","confidence":68,"versions_count":35,"era":"2010s"}
  ]
  $toneadapt_profiles$::jsonb) as p(
    title text,
    artist text,
    album text,
    release_year integer,
    mode text,
    part_type text,
    part_label text,
    tone_type text,
    genre text,
    tone_category text,
    difficulty text,
    original_guitar text,
    original_amp text,
    original_cab text,
    original_pickup text,
    confidence integer,
    versions_count integer,
    era text
  )
),
normalized_seed as (
  select
    *,
    lower(trim(both '-' from regexp_replace(artist, '[^a-zA-Z0-9]+', '-', 'g'))) as artist_slug,
    lower(trim(both '-' from regexp_replace(title, '[^a-zA-Z0-9]+', '-', 'g'))) as song_slug
  from profile_seed
),
artist_rows as (
  select distinct artist as name, artist_slug as slug
  from normalized_seed
),
upsert_artists as (
  insert into public.artists (name, slug, country, search_text, is_active)
  select name, slug, 'Global', concat_ws(' ', name, 'tone database artist'), true
  from artist_rows
  on conflict (slug) do update set
    name = excluded.name,
    search_text = excluded.search_text,
    is_active = true,
    updated_at = now()
  returning id, slug, name
),
song_rows as (
  select distinct on (artist_slug, song_slug)
    title,
    artist,
    artist_slug,
    song_slug,
    album,
    release_year,
    era
  from normalized_seed
  order by artist_slug, song_slug, versions_count desc
),
upsert_songs as (
  insert into public.songs (
    artist_id,
    title,
    slug,
    album,
    release_year,
    search_text,
    is_active
  )
  select
    a.id,
    s.title,
    s.song_slug,
    s.album,
    s.release_year,
    concat_ws(' ', s.title, a.name, s.album, s.era, 'tone database toneadapt community'),
    true
  from song_rows s
  join upsert_artists a on a.slug = s.artist_slug
  on conflict (artist_id, slug) do update set
    title = excluded.title,
    album = excluded.album,
    release_year = excluded.release_year,
    search_text = excluded.search_text,
    is_active = true,
    updated_at = now()
  returning id, slug, title, artist_id
),
profile_source as (
  select
    s.id as song_id,
    n.title,
    n.artist,
    n.album,
    n.mode,
    n.part_type,
    n.part_label,
    n.tone_type,
    n.genre,
    n.tone_category,
    n.difficulty,
    n.original_guitar,
    n.original_amp,
    n.original_cab,
    n.original_pickup,
    n.confidence,
    n.versions_count,
    n.era
  from normalized_seed n
  join upsert_artists a on a.slug = n.artist_slug
  join upsert_songs s on s.artist_id = a.id and s.slug = n.song_slug
),
upsert_profiles as (
  insert into public.song_tone_profiles (
    song_id, song_title, artist_name, mode, part_type, part_label, tone_type,
    genre, tone_category, difficulty,
    original_guitar, original_amp, original_cab, original_pickup,
    original_effects, original_settings, adaptation_notes, playing_notes,
    source_summary, confidence, verification_status, search_text, is_public
  )
  select
    p.song_id,
    p.title,
    p.artist,
    p.mode,
    p.part_type,
    p.part_label,
    p.tone_type,
    p.genre,
    p.tone_category,
    p.difficulty,
    p.original_guitar,
    p.original_amp,
    p.original_cab,
    p.original_pickup,
    case
      when p.tone_type = 'clean' then jsonb_build_array(
        jsonb_build_object('effect_type', 'compression', 'effect_name', 'light compressor', 'placement', 'front', 'settings', jsonb_build_object('compression', 2, 'level', 5)),
        jsonb_build_object('effect_type', 'modulation', 'effect_name', 'subtle chorus or doubling', 'placement', 'post_gain', 'settings', jsonb_build_object('depth', 2, 'mix', 2)),
        jsonb_build_object('effect_type', 'reverb', 'effect_name', 'small room or spring reverb', 'placement', 'post_gain', 'settings', jsonb_build_object('mix', 2, 'decay', 3))
      )
      when p.part_type = 'solo' then jsonb_build_array(
        jsonb_build_object('effect_type', 'drive', 'effect_name', 'sustain boost', 'placement', 'front', 'settings', jsonb_build_object('gain', 4, 'tone', 6, 'level', 6)),
        jsonb_build_object('effect_type', 'delay', 'effect_name', 'lead delay', 'placement', 'post_gain', 'settings', jsonb_build_object('mix', 3, 'time', 4, 'feedback', 3)),
        jsonb_build_object('effect_type', 'reverb', 'effect_name', 'plate reverb', 'placement', 'post_gain', 'settings', jsonb_build_object('mix', 2, 'decay', 4))
      )
      else jsonb_build_array(
        jsonb_build_object('effect_type', 'gate', 'effect_name', 'tight noise gate', 'placement', 'front', 'settings', jsonb_build_object('threshold', 5, 'release', 3)),
        jsonb_build_object('effect_type', 'drive', 'effect_name', 'focused overdrive boost', 'placement', 'front', 'settings', jsonb_build_object('gain', 3, 'tone', 6, 'level', 6)),
        jsonb_build_object('effect_type', 'eq', 'effect_name', 'post-amp shape EQ', 'placement', 'post_gain', 'settings', jsonb_build_object('low', 5, 'mid', 6, 'high', 5))
      )
    end,
    case
      when p.tone_type = 'clean' and p.part_type = 'solo' then '{"gain":3,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":3,"delay":2,"compression":3,"master":6}'::jsonb
      when p.tone_type = 'clean' then '{"gain":3,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"compression":3,"master":6}'::jsonb
      when p.part_type = 'solo' then '{"gain":7,"bass":5,"mids":7,"treble":6,"presence":6,"reverb":2,"delay":3,"master":6}'::jsonb
      when p.genre = 'metal' then '{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb
      when p.genre = 'blues' then '{"gain":5,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":2,"delay":1,"master":6}'::jsonb
      else '{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb
    end,
    array[
      'Screenshot-derived catalog seed: use as a practical starting point and refine by ear against the recording.',
      'Start by matching the pickup and gain structure, then adjust bass and presence for your own cab or headphones.',
      'If your amp is lower-gain than the source rig, add a clean boost before increasing amp gain.'
    ],
    array[
      'Match the attack and muting of the part before changing EQ.',
      'Use less ambience live than on headphones so the riff stays clear.',
      'For solos, favor sustain and mids over extra distortion.'
    ],
    concat('Visible ToneAdapt community card seed with ', p.versions_count::text, ' versions shown in the supplied screenshots; includes visible instrument, part, tone type, era and likely source-rig metadata.'),
    p.confidence,
    'needs_review',
    concat_ws(' ', p.title, p.artist, p.album, p.genre, p.tone_category, p.difficulty, p.era, p.part_label, p.tone_type, p.original_guitar, p.original_amp, p.original_pickup, 'toneadapt community tone database'),
    true
  from profile_source p
  on conflict (song_id, mode, part_type, tone_type, part_label) do update set
    song_title = excluded.song_title,
    artist_name = excluded.artist_name,
    genre = excluded.genre,
    tone_category = excluded.tone_category,
    difficulty = excluded.difficulty,
    original_guitar = excluded.original_guitar,
    original_amp = excluded.original_amp,
    original_cab = excluded.original_cab,
    original_pickup = excluded.original_pickup,
    original_effects = excluded.original_effects,
    original_settings = excluded.original_settings,
    adaptation_notes = excluded.adaptation_notes,
    playing_notes = excluded.playing_notes,
    source_summary = excluded.source_summary,
    confidence = excluded.confidence,
    verification_status = excluded.verification_status,
    search_text = excluded.search_text,
    is_public = true,
    updated_at = now()
  returning id, song_title, artist_name, mode, part_type, part_label, tone_type, original_effects
),
effect_rows as (
  select
    p.id as profile_id,
    effect.value,
    effect.ordinality as effect_order
  from upsert_profiles p
  cross join lateral jsonb_array_elements(p.original_effects) with ordinality as effect(value, ordinality)
)
insert into public.tone_profile_effects (profile_id, effect_order, effect_type, effect_name, placement, settings)
select
  e.profile_id,
  e.effect_order::integer,
  e.value ->> 'effect_type',
  e.value ->> 'effect_name',
  coalesce(e.value ->> 'placement', 'post_gain'),
  coalesce(e.value -> 'settings', '{}'::jsonb)
from effect_rows e
on conflict (profile_id, effect_order) do update set
  effect_type = excluded.effect_type,
  effect_name = excluded.effect_name,
  placement = excluded.placement,
  settings = excluded.settings;

insert into public.tone_profile_sources (profile_id, source_type, title, url, notes, credibility)
select
  p.id,
  'internal_seed',
  'ToneAdapt screenshot community card seed',
  null,
  'Profile created from the visible community-card metadata supplied in screenshots. Treat as a useful baseline until reviewed against primary rig sources.',
  45
from public.song_tone_profiles p
where p.source_summary like 'Visible ToneAdapt community card seed%'
  and not exists (
    select 1
    from public.tone_profile_sources s
    where s.profile_id = p.id
      and s.source_type = 'internal_seed'
      and s.title = 'ToneAdapt screenshot community card seed'
  );
