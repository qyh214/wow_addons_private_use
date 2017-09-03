local myname, ns = ...

local merge = function(t1, t2)
    for k, v in pairs(t2) do
        t1[k] = v
    end
end

merge(ns.points["Azsuna"], {
    [29255365] = {quest=42417, npc=107327, item=129079}, -- Bilebrain
    [30784800] = {quest=42286, npc=107136, item=141873}, -- Houndmaster Stroxis
    [32302970] = {quest=38238, npc=91187, item=129067, note="Patrols the beach"}, -- Beacher
    [32604880] = {quest=44108, npc=109504, item=129075}, -- Ragemaw
    [33404120] = {quest=44670, npc=107105, item=141869}, -- Broodmother Lizax
    [34953390] = {quest=42505, npc=107657, item=141868, note="Walks around the pool"}, -- Arcanist Shal'iman
    [35305030] = {quest=38037, npc=90803, item=129083, note="Cache of Infernals"}, -- Infernal Lord
    [37404320] = {quest=42280, npc=107113, item=141875}, -- Vorthax
    [41054180] = {quest=37537, npc=89016, item=129080}, -- Ravyn-Drath
    [43152815] = {quest=38352, npc=91579, item=129056}, -- Doomlord Kazrok
    [45305780] = {quest=37824, npc=89884, item=129090}, -- Flog the Captain-Eater
    [47203420] = {quest=37726, npc=89650, item=129082}, -- Valiyaka the Stormbringer
    [49105520] = {quest=37909, npc=90164, item=129069, note="Patrols the road"}, -- Warbringer Mox'na
    [49500880] = {quest=37928, npc=90217, item=129061}, -- Normantis the Deposed
    [50003440] = {quest=37823, npc=89865, item=129072}, -- Mrrgrl the Tidereaver
    [50803160] = {quest=37869, npc=90057, item=129084}, -- Daggerbeak
    [52402305] = {quest=38268, npc=91289, item=129063}, -- Cailyn Paledoom
    [53404400] = {quest=37821, npc=89846, item=129066}, -- Captain Volo'ren
    [55104590] = {quest=42450, npc=107127, item=129086}, -- Brawlgoth
    [55476980] = {quest=42699, npc=108255, item=141877}, -- Coura, Mistress of Arcana
    [56102905] = {quest=38061, npc=90901, item=138395}, -- Pridelord Meowl
    [58517882] = {quest=44671, npc=108136, item=129081}, -- The Muscle
    [59304630] = {quest=38212, npc=91100, item=129068, note="Top of the mountain"}, -- Brogozog
    [59601230] = {quest=37932, npc=90244, item=129085, note="Unbound rift"}, -- Arcavellus
    [59705520] = {quest=37822, npc=89850, item=129065}, -- The Oracle
    [61306200] = {quest=38217, npc=91113, item=129062}, -- Tide Behemoth
    [65164000] = {quest=37820, npc=89816, item=129091, note="Horn of the Siren"}, -- Golza the Iron Fin
    [65555680] = {quest=42221, npc=106990, item=129073}, -- Chief Bitterbrine
    [67105140] = {quest=37989, npc=90505, item=129064}, -- Syphonus
})
merge(ns.points["Highmountain"], {
    [36751635] = {quest=40084, npc=98299, item=131799}, -- Bodash the Hoarder
    [37704570] = {quest=40405, npc=97449, item=131761}, -- Bristlemaul
    [40955775] = {quest=39963, npc=97793, item=131773, note="Abandoned Fishing Pole"}, -- Flamescale
    [41503185] = {quest=40175, npc=98890, item=131921}, -- Slumber
    [41954150] = {quest=39782, npc=97203, item=129175, note="Abandoned Fishing Pole"}, -- Tenpak Flametotem
    [43164800] = {quest=40413, npc=100230, item=131781, note="Loot chest afterwards"}, -- Amateur hunters (100230, 100231, 100232)
    [44201210] = {quest=39994, npc=97933, item=131798, note="Wanders a bit"}, -- Crab Rider Grmlrml
    [45705500] = {quest=40681, npc=101077, item=131730}, -- Sekhan
    [46500745] = {quest=40096, npc=98311, item=131797}, -- Mrrklr
    [46653145] = {quest=39646, npc=96410, item=131900, note="Abandoned Fishing Pole"}, -- Majestic Elderhorn
    [48404015] = {quest=39806, npc=97345, item=131809, note="1/4 of slow fall toy", toy=true}, -- Crawshuk the Hungry
    [48502545] = {quest=39646, npc=96410, item=131900, note="Wanders a bit"}, -- Majestic Elderhorn
    [48605000] = {quest=39784, npc=97215, item=131756, note="Help him tame Arru, loot inside the cave afterwards"}, -- Beastmaster Pao'lek
    [49202710] = {quest=40242, npc=96621, item=131808}, -- Mellok, Son of Torok 
    [50803460] = {quest=40406, npc=98024, item=131776, note="In cave"}, -- Luggut the Eggeater
    [51052570] = {quest=39762, npc=97093, item=131791}, -- Shara Felbreath
    [51054825] = {quest=39802, npc=97326, item=138783}, -- Hartli the Snatcher
    [51453190] = {quest=39465, npc=95872, item=131769}, -- Skullhat
    [53755125] = {quest=39872, npc=97653, item=131800, note="Loot chest afterwards"}, -- Taurson
    [54404110] = {quest=40414, npc=100495, item=131780, note="Cave entrance @ 55.1, 44.3. Blow out candles."}, -- Devouring Darkness
    [55104430] = ns.path(40414),
    [54447454] = {quest=40773, npc=101649, item=1220}, -- Frostshard
    [54504060] = {quest=39866, npc=97593, item=131792, note="Top of mountain"}, -- Mynta Talonscreech
    [56357250] = {quest=39235, npc=94877, item=138396}, -- Brogrul the Mighty
    [56406050] = {quest=40347, npc=96590, item=131775, note="Wanders a bit"}, -- Gurbog da Basher
    [52405850] = {quest=40423, npc=109498, item=131767, note="Use the Seemingly Unguarded Treasure to summon the Unethical Adventurers"}, -- Unethical Adventurers
})
merge(ns.points["Stormheim"], {
    [36505250] = {quest=38472, npc=92152, item=138418}, -- Whitewater Typhoon
    [38454305] = {quest=38626, npc=92599, item=129101}, -- Bloodstalker Alpha
    [40657240] = {quest=38424, npc=91892, item=129113}, -- Thane Irglov the Merciless
    [41456700] = {quest=38333, npc=91529, item=129291}, -- Glimar Ironfist
    [41753410] = {quest=40068, npc=98188, item=132898, note="Cave under the statue's axe"}, -- Egyl the Enduring
    [45857735] = {quest=38431, npc=91874, item=129048}, -- Bladesquall
    [46808405] = {quest=38425, npc=91803, item=129206}, -- Fathnyr
    [47154985] = {quest=38774, npc=93166, item=129163}, -- Tiptog the Lost
    [49507175] = {quest=38423, npc=91795, item=129208}, -- Stormdrake Matriarch
    [51607465] = {quest=42591, npc=107926, item=138417}, -- Hannval the Butcher
    [54802940] = {quest=42437, npc=107487, item=130132}, -- Starbuck
    [58004515] = {quest=38642, npc=92685, item=129123}, -- Captain Brvet
    [58353390] = {quest=43342, npc=110363, item=139387}, -- Roteye
    [59806805] = {quest=39031, npc=92751, item=132895}, -- Ivory Sentinel
    [61554335] = {quest=40081, npc=98268, item=129199}, -- Tarben
    [62056050] = {quest=39120, npc=94413, item=129133}, -- Isel the Hammer
    [63707420] = {quest=37908, npc=90139, item=140686}, -- Inquisitor Ernstenbok
    [64805175] = {quest=38847, npc=93401, item=129219}, -- Urgev the Flayer
    [67303990] = {quest=38685, npc=92763, item=129041}, -- The Nameless King
    [72504990] = {quest=38837, npc=93371, item=129035}, -- Mordvigbjorn
    [73454765] = {quest=40109, npc=98421, item=138419}, -- Kottr Vondyr
    [73906060] = {quest=43343, npc=94347, item=130134, faction="Alliance"}, -- Dread-Rider Cortis
    [78606115] = {quest=40113, npc=98503, item=138421}, -- Grrvrgull the Conqueror
})
merge(ns.points["Suramar"], {
    --[67065161] = {quest=99999, npc=, item=1220, note="marked as rare but seems to have no questID yet"}, -- Broodmother Shu'malis
    [13555345] = {quest=44124, npc=112802, item=140949}, -- Mar'tura
    [16552655] = {quest=43996, npc=103841, item=140401}, -- Shadowquill
    [18606105] = {quest=43542, npc=110824, item=140399}, -- Tideclaw
    [22155180] = {quest=41319, npc=99792, item=121806}, -- Elfbane
    [24052540] = {quest=43484, npc=105547, item=121759}, -- Rauren
    [24403515] = {quest=44071, npc=112497, item=139897}, -- Maia the White Wolf
    [24554740] = {quest=43449, npc=110577, item=140388}, -- Oreth the Vile
    [26104075] = {quest=42831, npc=109054, item=139926}, -- Shal'an
    [27756545] = {quest=43992, npc=110832, item=121747, note="Portal Key"}, -- Gorgroth
    [29405330] = {quest=44676, npc=113368, item=138839, note="Cave entrance @ 29.3, 50.7"}, -- Llorian
    [29305070] = ns.path(44676),
    [33705125] = {quest=43954, npc=111197, item=140934}, -- Anax
    [33801510] = {quest=43717, npc=106351, item=140372}, -- Artificer Lothaire
    [34156100] = {quest=43351, npc=110024, item=140386}, -- Mal'Dreth the Corruptor
    [35256725] = {quest=44675, npc=106526, item=141866}, -- Lady Rivantas
    [36203380] = {quest=43718, npc=111329, item=140390}, -- Matron Hagatha
    [38052280] = {quest=43369, npc=110438, item=140406}, -- Siegemaster Aedrin
    [40953280] = {quest=43358, npc=110340, item=121739}, -- Myonix
    [42058005] = {quest=43348, npc=109954, item=140405}, -- Magister Phaedris
    [42155640] = {quest=43580, npc=110870, item=121754}, -- Apothecary Faldren
    [48055635] = {quest=40905, npc=102303, item=121735}, -- Lieutenant Strathmar
    [49607900] = {quest=43603, npc=111007, item=140396}, -- Randril
    [53203020] = {quest=40897, npc=99610, item=121755}, -- Garvrulg
    [54455610] = {quest=43792, npc=111651, item=121808}, -- Degren
    [54806375] = {quest=43794, npc=111649, item=139918}, -- Ambassador D'vwinn
    [61005300] = {quest=43597, npc=110944, item=140404, note="Wanders a bit"}, -- Guardian Thor'el
    [61653960] = {quest=43993, npc=103223, item=121737}, -- Hertha Grimdottir
    [62506370] = {quest=43793, npc=111653, item=121810}, -- Miasu
    [62554810] = {quest=43495, npc=110726, item=139969}, -- Cadraeus
    [65555915] = {quest=43481, npc=110656, item=140403}, -- Arcanist Lylandre
    [66656715] = {quest=43968, npc=107846, item=140314, toy=true}, -- Pinchshank
    [67657105] = {quest=41136, npc=103214, item=140381, note="Cave entrance @ 72.4, 68.1"}, -- Har'kess the Insatiable
    [72406810] = ns.path(41136),
    [68155895] = {quest=41135, npc=100864, item=139952, note="Cave entrance @ 69.9, 57.0"}, -- Cora'Kar
    [69905700] = ns.path(41135),
    [75505730] = {quest=44003, npc=103575, item=121801}, -- Reef Lord Raj'his
    [80157000] = {quest=40680, npc=103183, item=140019, note="Wanders along the underwater trench"}, -- Rok'nash
    [87856250] = {quest=41786, npc=103827, item=140384}, -- King Morgalash
})
merge(ns.points["Valsharah"], {
    [34405830] = {quest=39121, npc=94414, item=141876}, -- Kiranys Duskwhisper
    [38055280] = {quest=38772, npc=92423, item=130136}, -- Theryssia
    [41657825] = {quest=38479, npc=92180, item=130171}, -- Seersei
    [44155210] = {quest=38767, npc=92965, item=130166, note="Bottom floor"}, -- Darkshade
    [45608880] = {quest=43446, npc=110562, item=130135}, -- Bahagar
    [47205800] = {quest=39357, npc=95221, item=130214}, -- Mad Henryk
    [52808750] = {quest=38889, npc=93686, item=128690, note="Shivering Ashmaw Cub"}, -- Jinikki the Puncturer
    [58753400] = {quest=40080, npc=93030, item=1220}, -- Ironbranch
    [59757745] = {quest=38468, npc=92117, item=130154, note="Talk to Lorel Sagefeather"}, -- Gorebeak
    [60304425] = {quest=39858, npc=97517, item=130125}, -- Dreadbog
    [60359065] = {quest=38887, npc=93654, item=130115, note="Talk to Elindya Featherlight, then follow her"}, -- Skul'vrax
    [61056940] = {quest=39596, npc=95318, item=130137}, -- Perrexx the Corruptor
    [61802955] = {quest=40079, npc=98241, item=130118}, -- Lyrath Moonfeather
    [62604750] = {quest=38780, npc=93205, item=130121}, -- Thondrax
    [65805345] = {quest=40126, npc=95123, item=130122}, -- Grelda the Hag
    [66853685] = {quest=39856, npc=97504, item=130116}, -- Wraithtalon
    [67156960] = {quest=43176, npc=109708, item=130133}, -- Undergrell Attack
    [67504510] = {quest=39130, npc=94485, item=130168}, -- Pollous the Fetid
})
merge(ns.points["Helheim"], {
    [28156375] = {quest=39870, npc=97630, item=129188, pet=true}, -- Soulthirster
    [85105030] = {quest=38461, npc=92040, item=129044}, -- Fenri
})
merge(ns.points["TempleofaThousandLights"], {
    [62303090] = {quest=42699, npc=108255, item=141877}, -- Coura, Mistress of Arcana
})

-- Argus:
merge(ns.points["ArgusSurface"], { -- Krokuun
    [33007600] = {quest=48562, npc=122912}, -- Commander Sathrenael
    [38145920] = {quest=48563, npc=122911, item=153299, note="Either go through the Xenedar, or climb up from 42, 57.1"}, -- Commander Vecaya
    [41707020] = {quest=48666, npc=125820}, -- Imp Mother Laglath
    [44390734] = {quest=48561, npc=125824, note="Entrance is south east at 50.3, 17.3"}, -- Khazaduum
    [44505870] = {quest=48564, npc=124775, item=153255}, -- Commander Endaxis
    [53403090] = {quest=48565, npc=123464, item=153124, toy=true}, -- Sister Subversia
    [55508020] = {quest=48628, npc=123689, item=153329}, -- Talestra the Vile
    [58007480] = {quest=48627, npc=120393}, -- Siegemaster Voraan
    [60802080] = {quest=48629, npc=125388, item=153114}, -- Vagath the Betrayed
    [69605750] = {quest=48664, npc=124804, item=153263}, -- Tereck the Selector
    [69708050] = {quest=48665, npc=125479}, -- Tar Spitter
    [70503370] = {quest=48667, npc=126419, item=153190}, -- Naroua
})

merge(ns.points["ArgusCore"], { -- Antoran Wastes
    [50905530] = {quest=48820, npc=127118}, -- Worldsplitter Skuul
    [52702950] = {quest=nil, npc=127291}, -- Watcher Aival
    [53103580] = {quest=48810, npc=126199, item=152903, mount=true}, -- Vrax'thul
    [54003800] = {quest=48966, npc=127581, item=153195, pet=true, note="Gather bones in Scavenger's Boneyard"}, -- The Many-Faced Devourer
    [55702190] = {quest=48824, npc=127300, item=153319}, -- Void Warden Valsuran
    [56204550] = {quest=49241, npc=122999}, -- Gar'zoth
    [57403290] = {quest=49240, npc=122947, item=153327}, -- Mistress Il'thendra
    [58001200] = {quest=48968, npc=127703, note="3 people on the runes to summon; don't interrupt Doom Star"}, -- Doomcaster Suprax
    [60575159] = {quest=48816, npc=127084, note="Use the portal slightly west from him at 80, 62.4"}, -- Commander Texlaz
    [60674831] = {quest=48815, npc=126946, item=151543}, -- Inquisitor Vethroz
    [60902290] = {quest=nil, npc=127376}, -- Chief Alchemist Munculus
    [61703720] = {quest=49183, npc=122958, item=152905, mount=true}, -- Blistermaw
    [61906430] = {quest=48814, npc=126338}, -- Wrath-Lord Yarez
    [62405380] = {quest=48813, npc=126254}, -- Lieutenant Xakaar
    [63102520] = {quest=48821, npc=48835, item=152790, mount=true}, -- Houndmaster Kerrax
    [63225754] = {quest=48811, npc=126115, note="The entrance to the cave is north east from her in the spider area at 66, 54.1"}, -- Ven'orn
    [63902090] = {quest=48809, npc=126040, note="Entrance to the cave is south east - use the eastern bridge to get there."}, -- Puscilla
    [64304820] = {quest=48812, npc=126208, item=153190}, -- Varga
    [66981777] = {quest=48970, npc=127705, item=153252, pet=true}, -- Mother Rosula
    [73207080] = {quest=48817, npc=127090, item=153324}, -- Admiral Rel'var
    [75605650] = {quest=48818, npc=127096}, -- All-Seer Xanarian
})
merge(ns.points["ArgusCitadelSpire"], { -- Nath'raxas Spire
    [38954032] = {quest=48561, npc=125824}, -- Khazaduum
})

merge(ns.points["ArgusMacAree"], { -- MacAree
    [27202980] = {quest=48707, npc=126869}, -- Captain Faruq
    [30304040] = {quest=nil, npc=127323}, -- Ataxon
    [33704750] = {quest=48705, npc=126867, item=152844, mount=true}, -- Venomtail Skyfin
    [35203720] = {quest=nil, npc=126885}, -- Umbraliss
    [35505870] = {quest=nil, npc=126896, note="On the 2nd floor."}, -- Herald of Chaos
    [36302360] = {quest=nil, npc=126865}, -- Vigilant Thanos
    [38705580] = {quest=48697, npc=126860, item=153190}, -- Kaara the Pale
    [39206660] = {quest=nil, npc=126868}, -- Turek the Lucid
    [41301160] = {quest=nil, npc=126864, item=152998}, -- Feasel the Muffin Thief
    [43806020] = {quest=48700, npc=126862, item=153193, toy=true}, -- Baruut the Bloodthirsty
    [44204980] = {quest=nil, npc=126898, item=153190}, -- Sabuul
    [44607160] = {quest=nil, npc=122838}, -- Shadowcaster Voruun
    [48504090] = {quest=nil, npc=126899}, -- Jed'hin Champion Vorusk
    [49505280] = {quest=48935, npc=126913}, -- Slithon the Last
    [49700990] = {quest=nil, npc=126912, mount=true}, -- Skreeg the Devourer
    [55705990] = {quest=nil, npc=126852, item=152814, mount=true}, -- Wrangler Kravos
    [56801450] = {quest=nil, npc=126910}, -- Commander Xethgar
    [58003090] = {quest=nil, npc=125497}, -- Overseer Y'Sorna
    [59203770] = {quest=48714, npc=124440}, -- Overseer Y'Beda
    [60402970] = {quest=48717, npc=125498}, -- Overseer Y'Morna
    [61405020] = {quest=48718, npc=126900, item=153181, toy=true, note="Can drop three different scroll toys"}, -- Instructor Tarahna
    [63806460] = {quest=nil, npc=126866}, -- Vigilant Kuro
    [64002950] = {quest=48719, npc=126908}, -- Zul'tan the Numerous
    [65306750] = {quest=nil, npc=126815}, -- Soultwisted Monstrosity
    [70404670] = {quest=nil, npc=126889}, -- Sorolis the Ill-Fated
})

-- DH starter:
merge(ns.points["MardumtheShatteredAbyss"], {
    [68852760] = {quest=40234, npc=82877, item=128947}, -- General Volroth
    [74455730] = {quest=40232, npc=97059, item=128944}, -- King Voras
    [81054125] = {quest=40233, npc=97057, item=133580}, -- Overseer Brutarg

})
merge(ns.points["SoulEngine"], {
    [51255740] = {quest=40231, npc=97058, item=128948}, -- Count Nefarious
})
merge(ns.points["VaultOfTheWardensDH"], {
    [49553285] = {quest=40251, npc=96997, item=128945}, -- Kethrazor
    [68753630] = {quest=40301, npc=97069, item=128958}, -- Wrath-Lord Lekos
})
