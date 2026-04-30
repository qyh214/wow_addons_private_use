-- By D4KiR
local _, SpecBisTooltip = ...
local s = {}
if SpecBisTooltip:GetWoWBuild() == "RETAIL" then
    function SpecBisTooltip:GetTranslationMap()
        return s
    end
end

-- SOURCE FROM: 22.01.2026
if SpecBisTooltip:GetWoWBuild() == "RETAIL" then
    function SpecBisTooltip:TranslationenUS()
        s["npc;drop=224552"] = {"Rasha'nan", "Nerub-ar Palace"}
        s["npc;drop=223779"] = {"Anub'arash <The Thousand Scars>", "Nerub-ar Palace"}
        s["npc;sold=224270"] = {"Ip'xal", "City of Threads"}
        s["spell;created=450226"] = {"Everforged Vambraces", "CRAFTING"}
        s["spell;created=450222"] = {"Everforged Greatbelt", "CRAFTING"}
        s["npc;drop=219778"] = {"Queen Ansurek", "Nerub-ar Palace"}
        s["npc;drop=162693"] = {"Nalthor the Rimebinder", "The Necrotic Wake"}
        s["npc;drop=213179"] = {"Avanoxx", "Ara-Kara, City of Echoes"}
        s["npc;drop=162689"] = {"Surgeon Stitchflesh", "The Necrotic Wake"}
        s["npc;drop=219853"] = {"Sikran <Captain of the Sureki>", "Nerub-ar Palace"}
        s["spell;created=450220"] = {"Everforged Sabatons", "CRAFTING"}
        s["npc;drop=214506"] = {"Broodtwister Ovi'nax", "Nerub-ar Palace"}
        s["npc;drop=164501"] = {"Mistcaller", "Mists of Tirna Scithe"}
        s["npc;drop=40319"] = {"Drahga Shadowburner <Twilight's Hammer Courier>", "Grim Batol"}
        s["npc;drop=215405"] = {"Anub'zekt <Swarmguard>", "Ara-Kara, City of Echoes"}
        s["npc;drop=211089"] = {"Anub'ikkaj", "The Dawnbreaker"}
        s["npc;drop=39625"] = {"General Umbriss <Servant of Deathwing>", "Grim Batol"}
        s["npc;drop=213217"] = {"Speaker Brokk", "The Stonevault"}
        s["npc;drop=129208"] = {"Dread Captain Lockwood", "Siege of Boralus"}
        s["npc;drop=213119"] = {"Void Speaker Eirich", "The Stonevault"}
        s["npc;drop=216320"] = {"The Coaglamation", "City of Threads"}
        s["npc;drop=128650"] = {"Chopper Redhook", "Siege of Boralus"}
        s["npc;drop=128651"] = {"Hadal Darkfathom", "Siege of Boralus"}
        s["npc;drop=164567"] = {"Ingra Maloch", "Mists of Tirna Scithe"}
        s["npc;drop=210156"] = {"Skarmorak", "The Stonevault"}
        s["npc;drop=128649"] = {"Sergeant Bainbridge", "Siege of Boralus"}
        s["spell;created=450242"] = {"Charged Slicer", "CRAFTING"}
        s["npc;drop=228470"] = {"Nexus-Princess Ky'veza", "Nerub-ar Palace"}
        s["npc;drop=214502"] = {"The Bloodbound Horror", "Nerub-ar Palace"}
        s["npc;drop=216658"] = {"Izo, the Grand Splicer", "City of Threads"}
        s["npc;drop=163157"] = {"Amarth <The Harvester>", "The Necrotic Wake"}
        s["npc;drop=211087"] = {"Speaker Shadowcrown", "The Dawnbreaker"}
        s["npc;drop=40484"] = {"Erudax <The Duke of Below>", "Grim Batol"}
        s["npc;drop=210108"] = {"E.D.N.A", "The Stonevault"}
        s["npc;drop=162691"] = {"Blightbone", "The Necrotic Wake"}
        s["spell;created=441057"] = {"Rune-Branded Waistband", "CRAFTING"}
        s["npc;drop=216619"] = {"Orator Krix'vizk <The Fifth Strand>", "City of Threads"}
        s["spell;created=450232"] = {"Everforged Warglaive", "CRAFTING"}
        s["npc;drop=215407"] = {"Ki'katal the Harvester", "Ara-Kara, City of Echoes"}
        s["npc;drop=128652"] = {"Viq'Goth <Terror of the Deep>", "Siege of Boralus"}
        s["spell;created=444070"] = {"Adrenal Surge Clasp", "CRAFTING"}
        s["spell;created=450231"] = {"Everforged Longsword", "CRAFTING"}
        s["npc;drop=40177"] = {"Forgemaster Throngus", "Grim Batol"}
        s["npc;drop=164517"] = {"Tred'ova", "Mists of Tirna Scithe"}
        s["spell;created=435382"] = {"Binding of Binding", "CRAFTING"}
        s["npc;drop=216648"] = {"Nx <Fang of the Queen>", "City of Threads"}
        s["npc;drop=207207"] = {"Voidstone Monstrosity", "The Rookery"}
        s["spell;created=450235"] = {"Charged Hexsword", "CRAFTING"}
        s["spell;created=444197"] = {"Vagabond's Torch", "CRAFTING"}
        s["npc;drop=208743"] = {"Blazikon", "Darkflame Cleft"}
        s["npc;drop=210271"] = {"Brew Master Aldryr", "Cinderbrew Meadery"}
        s["npc;drop=207205"] = {"Stormguard Gorren", "The Rookery"}
        s["npc;drop=218002"] = {"Benk Buzzbee <Beekeeper>", "Cinderbrew Meadery"}
        s["npc;drop=209230"] = {"Kyrioss", "The Rookery"}
        s["spell;created=450230"] = {"Everforged Dagger", "CRAFTING"}
        s["spell;created=441066"] = {"Glyph-Etched Vambraces", "CRAFTING"}
        s["spell;created=441061"] = {"Glyph-Etched Gauntlets", "CRAFTING"}
        s["spell;created=447352"] = {"P.0.W. x2", "CRAFTING"}
        s["npc;drop=208478"] = {"Volcoross", "Amirdrassil, the Dream's Hope"}
        s["spell;created=446940"] = {"Consecrated Cloak", "CRAFTING"}
        s["spell;created=450239"] = {"Charged Halberd", "CRAFTING"}
        s["spell;created=445355"] = {"Scepter of Radiant Magics", "CRAFTING"}
        s["npc;drop=210267"] = {"I'pa", "Cinderbrew Meadery"}
        s["npc;drop=214661"] = {"Goldie Baronbottom <BEE.E.O.>", "Cinderbrew Meadery"}
        s["npc;drop=210153"] = {"Ol' Waxbeard", "Darkflame Cleft"}
        s["npc;drop=207946"] = {"Captain Dailcry", "Priory of the Sacred Flame"}
        s["spell;created=446937"] = {"Consecrated Slippers", "CRAFTING"}
        s["spell;created=444198"] = {"Vagabond's Careful Crutch", "CRAFTING"}
        s["spell;created=441058"] = {"Rune-Branded Armbands", "CRAFTING"}
        s["spell;created=441052"] = {"Rune-Branded Kickers", "CRAFTING"}
        s["spell;created=441055"] = {"Rune-Branded Legwraps", "CRAFTING"}
        s["spell;created=435385"] = {"Amulet of Earthen Craftsmanship", "CRAFTING"}
        s["spell;created=450237"] = {"Charged Facesmasher", "CRAFTING"}
        s["spell;created=450238"] = {"Charged Claymore", "CRAFTING"}
        s["npc;drop=207939"] = {"Baron Braunpyke", "Priory of the Sacred Flame"}
        s["npc;drop=210797"] = {"The Darkness", "Darkflame Cleft"}
        s["spell;created=441053"] = {"Rune-Branded Grasps", "CRAFTING"}
        s["spell;created=446938"] = {"Consecrated Cuffs", "CRAFTING"}
        s["spell;created=444199"] = {"Vagabond's Bounding Baton", "CRAFTING"}
        s["spell;created=450224"] = {"Everforged Helm", "CRAFTING"}
        s["spell;created=450234"] = {"Everforged Greataxe", "CRAFTING"}
        s["spell;created=435384"] = {"Ring of Earthen Craftsmanship", "CRAFTING"}
        s["spell;created=441060"] = {"Glyph-Etched Stompers", "CRAFTING"}
        s["npc;sold=227003"] = {"Kir'xal <Collector of Curiosities>", "City of Threads"}
        s["object;contained=413590"] = {"Bountiful Coffer", "The Dread Pit"}
        s["spell;created=441065"] = {"Glyph-Etched Binding", "CRAFTING"}
        s["npc;drop=215657"] = {"Ulgrax the Devourer", "Nerub-ar Palace"}
        s["object;contained=413563"] = {"Heavy Trunk", "Mycomancer Cavern"}
        s["npc;drop=202318"] = {"Response Team Watcher", "Zaralek Cavern"}
        s["npc;drop=203355"] = {"Captain Reykal", "Zaralek Cavern"}
        s["spell;created=427185"] = {"Algari Alchemist Stone", "CRAFTING"}
        s["npc;sold=219222"] = {"Lalandi <Conquest Quartermaster>", "Dornogal"}
        s["item:contained=229354"] = {"Algari Adventurer's Cache", ""}
        s["item:contained=229129"] = {"Cache of Delver's Spoils", ""}
        s["quest;reward=78636"] = {"Retaking the Mines", ""}
        s["quest;reward=79342"] = {"As He Departs", ""}
        s["quest;reward=78232"] = {"Rewriting the Rewritten", ""}
        s["spell;created=455393"] = {"Radiance", ""}
        s["spell;created=455394"] = {"Ascension", ""}
        s["spell;created=455392"] = {"Symbiosis", ""}
        s["spell;created=455391"] = {"Vivacity", ""}
        s["npc;drop=226305"] = {"Emperor Dagran Thaurissan", "Blackrock Depths"}
        s["npc;drop=226306"] = {"Golem Lord Argelmach", "Blackrock Depths"}
        s["npc;drop=226315"] = {"Lord Roccor", "Blackrock Depths"}
        s["npc;drop=217489"] = {"Anub'arash <The Thousand Scars>", "Nerub-ar Palace"}
        s["npc;drop=223839"] = {"Queen's Guard Ge'zah", "Nerub-ar Palace"}
        s["spell;created=447314"] = {"Studious Brilliance Expeditor", "CRAFTING"}
        s["spell;created=446939"] = {"Consecrated Cord", "CRAFTING"}
        s["spell;created=450229"] = {"Everforged Stabber", "CRAFTING"}
        s["npc;drop=229992"] = {"Stalagnarok", "Siren Isle"}
        s["npc;sold=231824"] = {"Kari Bridgeblaster <Junkmaster>", "Undermine"}
        s["npc;drop=226396"] = {"Swampface", "Operation: Floodgate"}
        s["npc;drop=229181"] = {"Flarendo <The Furious>", "Liberation of Undermine"}
        s["npc;drop=144246"] = {"K.U.-J.0.", "Operation: Mechagon"}
        s["npc;drop=241526"] = {"Chrome King Gallywix", "Liberation of Undermine"}
        s["npc;drop=228458"] = {"One-Armed Bandit", "Liberation of Undermine"}
        s["npc;drop=228652"] = {"Rik Reverb <Official Gallywix Hype Man>", "Liberation of Undermine"}
        s["npc;drop=164451"] = {"Dessia the Decapitator", "Theater of Pain"}
        s["npc;drop=129227"] = {"Azerokk", "The MOTHERLODE!!"}
        s["npc;drop=225821"] = {"The Geargrinder <Vexie's War Tank>", "Liberation of Undermine"}
        s["npc;drop=230583"] = {"Sprocketmonger Lockenstock", "Liberation of Undermine"}
        s["npc;drop=229953"] = {"Mug'Zee <Heads of Security>", "Liberation of Undermine"}
        s["npc;drop=230322"] = {"Stix Bunkjunker", "Liberation of Undermine"}
        s["npc;drop=131227"] = {"Mogul Razdunk", "The MOTHERLODE!!"}
        s["npc;drop=129231"] = {"Rixxa Fluxflame <Chief Scientist>", "The MOTHERLODE!!"}
        s["npc;drop=162317"] = {"Gorechop", "Theater of Pain"}
        s["npc;drop=226404"] = {"Geezle Gigazap", "Operation: Floodgate"}
        s["npc;drop=165946"] = {"Mordretha, the Endless Empress", "Theater of Pain"}
        s["npc;drop=226403"] = {"Keeza Quickfuse", "Operation: Floodgate"}
        s["npc;drop=132713"] = {"Mogul Razdunk", "The MOTHERLODE!!"}
        s["npc;drop=230828"] = {"Chief Foreman Gutso <Venture Co.>", "Undermine"}
        s["npc;drop=230800"] = {"Slugger the Smart", "Undermine"}
        s["npc;drop=230934"] = {"Ratspit <Court of Rats>", "Undermine"}
        s["npc;drop=152619"] = {"King Mechagon", "Operation: Mechagon"}
        s["npc;drop=150397"] = {"King Mechagon", "Operation: Mechagon"}
        s["npc;drop=129214"] = {"Coin-Operated Crowd Pummeler", "The MOTHERLODE!!"}
        s["npc;drop=144248"] = {"Head Machinist Sparkflux", "Operation: Mechagon"}
        s["spell;created=447315"] = {"Overclocked Idea Generator", "CRAFTING"}
        s["npc;drop=208745"] = {"The Candle King", "Darkflame Cleft"}
        s["npc;drop=162329"] = {"Xav the Unfallen", "Theater of Pain"}
        s["npc;drop=226398"] = {"Big M.O.M.M.A.", "Operation: Floodgate"}
        s["quest;reward=83125"] = {"Price Hike", "Zuldazar"}
        s["object;contained=476068"] = {"Papa's Prized Putter", "Undermine"}
        s["npc;drop=144244"] = {"The Platinum Pummeler", "Operation: Mechagon"}
        s["spell;created=473400"] = {"Reconfiguring for Spell Casting", "CRAFTING"}
        s["npc;drop=162309"] = {"Kul'tharok", "Theater of Pain"}
        s["npc;drop=207940"] = {"Prioress Murrpray", "Priory of the Sacred Flame"}
        s["npc;drop=242255"] = {"Geezle Gigazap", "Operation: Floodgate"}
        s["npc;drop=150222"] = {"Gunker", "Operation: Mechagon"}
        s["npc;drop=230946"] = {"V.V. Goosworth <Disgraced Slimeologist>", "Undermine"}
        s["npc;drop=150159"] = {"King Gobbamak", "Operation: Mechagon"}
        s["object;contained=507768"] = {"Jettisoned Pile of Goblin-Bucks", "Sidestreet Sluice"}
        s["npc;drop=231310"] = {"Darkfuse Precipitant", "Undermine"}
        s["npc;drop=229288"] = {"King Flamespite <Flarendo's Manager>", "Liberation of Undermine"}
        s["npc;drop=229284"] = {"Guk Boomdog <The Slop Hawker>", "Liberation of Undermine"}
        s["spell;created=441051"] = {"Rune-Branded Tunic", "CRAFTING"}
        s["npc;drop=247989"] = {"Forgeweaver Araz", "Manaforge Omega"}
        s["npc;drop=237861"] = {"Fractillus <The Shatterer>", "Manaforge Omega"}
        s["npc;drop=175646"] = {"P.O.S.T. Master", "Tazavesh, the Veiled Market"}
        s["npc;drop=156827"] = {"Echelon", "Halls of Atonement"}
        s["npc;drop=233814"] = {"Plexus Sentinel", "Manaforge Omega"}
        s["npc;drop=237661"] = {"Adarus Duskblaze", "Manaforge Omega"}
        s["npc;drop=177269"] = {"So'leah <Cartel So>", "Tazavesh, the Veiled Market"}
        s["npc;drop=233815"] = {"Loom'ithar", "Manaforge Omega"}
        s["npc;drop=237763"] = {"Nexus-King Salhadaar", "Manaforge Omega"}
        s["npc;drop=233824"] = {"Dimensius", "Manaforge Omega"}
        s["npc;drop=234933"] = {"Taah'bat <The Relentless>", "Eco-Dome Al'dani"}
        s["spell;created=1249111"] = {"Receive Wraps", "CRAFTING"}
        s["npc;drop=233816"] = {"Soulbinder Naazindhri", "Manaforge Omega"}
        s["npc;drop=165408"] = {"Halkias <The Sin-Stained Goliath>", "Halls of Atonement"}
        s["npc;drop=175663"] = {"Hylbrande <Sword of the Keepers>", "Tazavesh, the Veiled Market"}
        s["npc;drop=164185"] = {"Echelon", "Halls of Atonement"}
        s["npc;drop=165410"] = {"High Adjudicator Aleez", "Halls of Atonement"}
        s["npc;drop=176556"] = {"Alcruux <The Glutton>", "Tazavesh, the Veiled Market"}
        s["npc;drop=247283"] = {"Soul-Scribe", "Eco-Dome Al'dani"}
        s["npc;drop=175546"] = {"Timecap'n Hooktail", "Tazavesh, the Veiled Market"}
        s["npc;drop=175806"] = {"So'azmi", "Tazavesh, the Veiled Market"}
        s["npc;drop=176563"] = {"Zo'gron", "Tazavesh, the Veiled Market"}
        s["npc;drop=176705"] = {"Venza Goldfuse", "Tazavesh, the Veiled Market"}
        s["npc;drop=234893"] = {"Azhiccar", "Eco-Dome Al'dani"}
        s["npc;drop=164218"] = {"Lord Chamberlain", "Halls of Atonement"}
        s["npc;drop=175616"] = {"Zo'phex <The Sentinel>", "Tazavesh, the Veiled Market"}
        s["spell;created=450223"] = {"Everforged Defender", "CRAFTING"}
        s["npc;drop=244752"] = {"Nexus-Princess Ky'veza", "Voidrazor Sanctuary"}
        s["npc;drop=231981"] = {"Maw of the Sands", "K'aresh"}
        s["npc;drop=234845"] = {"Sthaarbs <the Mindroiler>", "K'aresh"}
        s["object;contained=416265"] = {"Pilfered Trunk", "The Dread Pit"}
        s["npc;drop=235853"] = {"Waygate Watcher", "Manaforge Omega"}
        s["npc;drop=239454"] = {"Darkmage Zadus", "Manaforge Omega"}
        s["npc;sold=248303"] = {"Zah'ran <Delve Trinkets>", "Excavation Site 9"}
        s["quest;reward=91009"] = {"Durable Information Storage Container", "Dornogal"}
        s["spell;created=441063"] = {"Glyph-Etched Cuisses", "CRAFTING"}
    end

    function SpecBisTooltip:TranslationdeDE()
        s["npc;drop=223779"] = {"Anub'arash <Die Tausend Narben>", "Palast der Nerub'ar"}
        s["spell;created=450226"] = {"Ewiggeschmiedete Unterarmschienen", "CRAFTING"}
        s["npc;drop=162693"] = {"Nalthor der Eisbinder", "Die Nekrotische Schneise"}
        s["npc;drop=162689"] = {"Chirurg Fleischnaht", "Die Nekrotische Schneise"}
        s["npc;drop=219853"] = {"Sikran <Hauptmann der Sureki>", "Palast der Nerub'ar"}
        s["spell;created=450220"] = {"Ewiggeschmiedete Sabatons", "CRAFTING"}
        s["npc;drop=214506"] = {"Brutverderber Ovi'nax", "Palast der Nerub'ar"}
        s["npc;drop=164501"] = {"Nebelruferin", "Die Nebel von Tirna Scithe"}
        s["npc;drop=40319"] = {"Drahga Schattenbrenner <Kurier des Schattenhammers>", "Grim Batol"}
        s["npc;drop=215405"] = {"Anub'zekt <Schwarmwache>", "Ara-Kara, Stadt der Echos"}
        s["npc;drop=39625"] = {"General Umbriss <Diener von Todesschwinge>", "Grim Batol"}
        s["npc;drop=213217"] = {"Sprecher Brokk", "Das Steingewölbe"}
        s["npc;drop=129208"] = {"Schreckenskapitänin Luebke", "Die Belagerung von Boralus"}
        s["npc;drop=213119"] = {"Leerensprecher Eirich", "Das Steingewölbe"}
        s["npc;drop=216320"] = {"Das Koaglamat", "Stadt der Fäden"}
        s["npc;drop=128650"] = {"Rothaken der Häcksler", "Die Belagerung von Boralus"}
        s["npc;drop=128651"] = {"Hadal Dunkelgrund", "Die Belagerung von Boralus"}
        s["npc;drop=128649"] = {"Unteroffizier Badbrück", "Die Belagerung von Boralus"}
        s["spell;created=450242"] = {"Geladener Schlitzer", "CRAFTING"}
        s["npc;drop=228470"] = {"Nexusprinzessin Ky'veza", "Palast der Nerub'ar"}
        s["npc;drop=214502"] = {"Der blutgebundene Schrecken", "Palast der Nerub'ar"}
        s["npc;drop=216658"] = {"Izo, die große Verbinderin", "Stadt der Fäden"}
        s["npc;drop=163157"] = {"Amarth <Der Ernter>", "Die Nekrotische Schneise"}
        s["npc;drop=211087"] = {"Sprecherin Schattenkrone", "Die Morgenbringer"}
        s["npc;drop=40484"] = {"Erudax <Der Herzog der Tiefe>", "Grim Batol"}
        s["npc;drop=210108"] = {"I.N.G.A.", "Das Steingewölbe"}
        s["npc;drop=162691"] = {"Pestknochen", "Die Nekrotische Schneise"}
        s["spell;created=441057"] = {"Runengezeichneter Gürtelbund", "CRAFTING"}
        s["npc;drop=216619"] = {"Orator Krix'vizk <Der fünfte Strang>", "Stadt der Fäden"}
        s["spell;created=450232"] = {"Ewiggeschmiedete Kriegsgleve", "CRAFTING"}
        s["npc;drop=215407"] = {"Ki'katal die Ernterin", "Ara-Kara, Stadt der Echos"}
        s["npc;drop=128652"] = {"Viq'Goth <Schrecken der Tiefe>", "Die Belagerung von Boralus"}
        s["spell;created=444070"] = {"Schnalle des Adrenalinschubs", "CRAFTING"}
        s["spell;created=450231"] = {"Ewiggeschmiedetes Langschwert", "CRAFTING"}
        s["npc;drop=40177"] = {"Schmiedemeister Throngus", "Grim Batol"}
        s["spell;created=435382"] = {"Bindung der Bindung", "CRAFTING"}
        s["npc;drop=216648"] = {"Nx <Fangzahn der Königin>", "Stadt der Fäden"}
        s["npc;drop=207207"] = {"Leerensteinmonstrosität", "Die Brutstätte"}
        s["spell;created=450235"] = {"Geladenes Hexerschwert", "CRAFTING"}
        s["spell;created=444197"] = {"Fackel des Vagabunden", "CRAFTING"}
        s["npc;drop=208743"] = {"Lohenzar", "Dunkelflammenspalt"}
        s["npc;drop=210271"] = {"Braumeister Aldryr", "Metbrauerei Glutbräu"}
        s["npc;drop=207205"] = {"Sturmwache Gorren", "Die Brutstätte"}
        s["npc;drop=218002"] = {"Benk Sumsebrumm <Imker>", "Metbrauerei Glutbräu"}
        s["spell;created=450230"] = {"Ewiggeschmiedeter Dolch", "CRAFTING"}
        s["spell;created=441066"] = {"Glyphengravierte Unterarmschienen", "CRAFTING"}
        s["spell;created=441061"] = {"Glyphengravierte Stulpen", "CRAFTING"}
        s["spell;created=447352"] = {"W.U.M.M.S. x2", "CRAFTING"}
        s["spell;created=446940"] = {"Geweihter Umhang", "CRAFTING"}
        s["spell;created=450239"] = {"Geladene Hellebarde", "CRAFTING"}
        s["spell;created=445355"] = {"Szepter der strahlenden Magie", "CRAFTING"}
        s["npc;drop=214661"] = {"Goldie Barontasch <BIEN.E.O.>", "Metbrauerei Glutbräu"}
        s["npc;drop=210153"] = {"Alter Wachsbart", "Dunkelflammenspalt"}
        s["npc;drop=207946"] = {"Hauptmann Talschrei", "Priorat der Heiligen Flamme"}
        s["spell;created=446937"] = {"Geweihte Pantoffeln", "CRAFTING"}
        s["spell;created=444198"] = {"Kompakte Krücke des Vagabunden", "CRAFTING"}
        s["spell;created=441058"] = {"Runengezeichnete Armbinden", "CRAFTING"}
        s["spell;created=441052"] = {"Runengezeichnete Treter", "CRAFTING"}
        s["spell;created=441055"] = {"Runengezeichnete Beinwickel", "CRAFTING"}
        s["spell;created=435385"] = {"Amulett der irdenen Handwerkskunst", "CRAFTING"}
        s["spell;created=450237"] = {"Geladener Kieferbrecher", "CRAFTING"}
        s["spell;created=450238"] = {"Geladenes Claymore", "CRAFTING"}
        s["npc;drop=207939"] = {"Baron Braunspyß", "Priorat der Heiligen Flamme"}
        s["npc;drop=210797"] = {"Die Finsternis", "Dunkelflammenspalt"}
        s["spell;created=441053"] = {"Runengezeichneter Handschutz", "CRAFTING"}
        s["spell;created=446938"] = {"Geweihte Manschetten", "CRAFTING"}
        s["spell;created=444199"] = {"Belebter Baton des Vagabunden", "CRAFTING"}
        s["spell;created=450224"] = {"Ewiggeschmiedeter Helm", "CRAFTING"}
        s["spell;created=450234"] = {"Ewiggeschmiedete Großaxt", "CRAFTING"}
        s["spell;created=435384"] = {"Ring der irdenen Handwerkskunst", "CRAFTING"}
        s["spell;created=441060"] = {"Glyphengravierte Stampfer", "CRAFTING"}
        s["npc;sold=227003"] = {"Kir'xal <Kuriositätensammlerin>", "Stadt der Fäden"}
        s["object;contained=413590"] = {"Großzügiger Kasten", "Der Terrorschacht"}
        s["spell;created=441065"] = {"Glyphengravierte Bindungen", "CRAFTING"}
        s["npc;drop=215657"] = {"Ulgrax der Verschlinger", "Palast der Nerub'ar"}
        s["spell;created=450222"] = {"Ewiggeschmiedeter Großgürtel", "CRAFTING"}
        s["npc;drop=219778"] = {"Königin Ansurek", "Palast der Nerub'ar"}
        s["object;contained=413563"] = {"Schwere Truhe", "Mykomantenhöhle"}
        s["npc;drop=202318"] = {"Hüterin der Eingreiftruppe", "Zaralekhöhle"}
        s["npc;drop=203355"] = {"Hauptmann Reykal", "Zaralekhöhle"}
        s["spell;created=427185"] = {"Algarischer Alchemistenstein", "CRAFTING"}
        s["npc;sold=219222"] = {"Lalandi <Rüstmeister für Eroberungspunkte>", "Dornogal"}
        s["item:contained=229354"] = {"Truhe eines Algariabenteurers", ""}
        s["item:contained=229129"] = {"Erbeutete Tiefenforscherschätze", ""}
        s["quest;reward=78636"] = {"Rückeroberung der Minen", ""}
        s["quest;reward=79342"] = {"Als er geht", ""}
        s["quest;reward=78232"] = {"Manipulation der Manipulierten", ""}
        s["spell;created=455393"] = {"Strahlen", ""}
        s["spell;created=455394"] = {"Aszendenz", ""}
        s["spell;created=455392"] = {"Symbiose", ""}
        s["spell;created=455391"] = {"Lebhaftigkeit", ""}
        s["npc;drop=226305"] = {"[Emperor Dagran Thaurissan]", "Schwarzfelstiefen"}
        s["npc;drop=226306"] = {"[Golem Lord Argelmach]", "Schwarzfelstiefen"}
        s["npc;drop=226315"] = {"[Lord Roccor]", "Schwarzfelstiefen"}
        s["npc;sold=224270"] = {"Ip'xal <Ausstatterin des Helden>", "Stadt der Fäden"}
        s["npc;drop=217489"] = {"Anub'arash <Die Tausend Narben>", "Palast der Nerub'ar"}
        s["npc;drop=223839"] = {"Königinnenwache Ge'zah", "Palast der Nerub'ar"}
        s["spell;created=447314"] = {"Gelehriger Brillanzbeschleuniger", "CRAFTING"}
        s["spell;created=446939"] = {"Geweihte Kordel", "CRAFTING"}
        s["spell;created=450229"] = {"Ewiggeschmiedeter Stecher", "CRAFTING"}
        s["npc;sold=231824"] = {"[Kari Bridgeblaster]", "Lorenhall"}
        s["npc;drop=226396"] = {"[Swampface]", "Operation: Schleuse"}
        s["npc;drop=229181"] = {"[Flarendo]", "Befreiung von Lorenhall"}
        s["npc;drop=241526"] = {"[Chrome King Gallywix]", "Befreiung von Lorenhall"}
        s["npc;drop=228458"] = {"[One-Armed Bandit]", "Befreiung von Lorenhall"}
        s["npc;drop=228652"] = {"[Rik Reverb]", "Befreiung von Lorenhall"}
        s["npc;drop=164451"] = {"Dessia die Enthaupterin", "Theater der Schmerzen"}
        s["npc;drop=225821"] = {"[The Geargrinder]", "Befreiung von Lorenhall"}
        s["npc;drop=230583"] = {"[Sprocketmonger Lockenstock]", "Befreiung von Lorenhall"}
        s["npc;drop=229953"] = {"[Mug'Zee]", "Befreiung von Lorenhall"}
        s["npc;drop=230322"] = {"[Stix Bunkjunker]", "Befreiung von Lorenhall"}
        s["npc;drop=131227"] = {"Mogul Ratztunk", "Das RIESENFLÖZ!!"}
        s["npc;drop=129231"] = {"Rixxa Fluxflamme <Leitende Wissenschaftlerin>", "Das RIESENFLÖZ!!"}
        s["npc;drop=162317"] = {"Bluthack", "Theater der Schmerzen"}
        s["npc;drop=226404"] = {"Giesel Gigaschock", "Operation: Schleuse"}
        s["npc;drop=165946"] = {"Mordretha, die Unendliche Kaiserin", "Theater der Schmerzen"}
        s["npc;drop=226403"] = {"[Keeza Quickfuse]", "Operation: Schleuse"}
        s["npc;drop=132713"] = {"Mogul Ratztunk", "Das RIESENFLÖZ!!"}
        s["npc;drop=230828"] = {"[Chief Foreman Gutso]", "Lorenhall"}
        s["npc;drop=230800"] = {"[Slugger the Smart]", "Lorenhall"}
        s["npc;drop=230934"] = {"[Ratspit]", "Lorenhall"}
        s["npc;drop=152619"] = {"König Mechagon", "Operation: Mechagon"}
        s["npc;drop=150397"] = {"König Mechagon", "Operation: Mechagon"}
        s["npc;drop=129214"] = {"Münzbetriebener Meuteverprügler", "Das RIESENFLÖZ!!"}
        s["npc;drop=144248"] = {"Hochmaschinist Funkenstrom", "Operation: Mechagon"}
        s["spell;created=447315"] = {"Übertakteter Ideengenerator", "CRAFTING"}
        s["npc;drop=208745"] = {"Der Kerzenkönig", "Dunkelflammenspalt"}
        s["npc;drop=162329"] = {"Xav der Unbesiegte", "Theater der Schmerzen"}
        s["npc;drop=226398"] = {"[Big M.O.M.M.A.]", "Operation: Schleuse"}
        s["quest;reward=83125"] = {"", "Zuldazar"}
        s["object;contained=476068"] = {"[Papa's Prized Putter]", "Lorenhall"}
        s["npc;drop=144244"] = {"Der Platinprügler", "Operation: Mechagon"}
        s["spell;created=473400"] = {"Für Zauberwirken rekonfigurieren", "CRAFTING"}
        s["npc;drop=207940"] = {"Priorin Murrbet", "Priorat der Heiligen Flamme"}
        s["npc;drop=242255"] = {"[Geezle Gigazap]", "Operation: Schleuse"}
        s["npc;drop=150222"] = {"Schmierer", "Operation: Mechagon"}
        s["npc;drop=230946"] = {"[V.V. Goosworth]", "Lorenhall"}
        s["npc;drop=150159"] = {"König Gobbamak", "Operation: Mechagon"}
        s["npc;drop=231310"] = {"Fällmittel der Düsternisverschmolzenen", "Lorenhall"}
        s["npc;drop=229288"] = {"König Bösflamme <Leuchtendos Manager>", "Befreiung von Lorenhall"}
        s["npc;drop=229284"] = {"Guk Bummhund <Der Grützehändler>", "Befreiung von Lorenhall"}
        s["object;contained=507768"] = {"Über Bord geworfener Haufen Goblinkohle", "Ausgrabungsstätte 9"}
        s["spell;created=441051"] = {"Runengezeichnete Tunika", "CRAFTING"}
        s["npc;drop=237861"] = {"Fractillus <[The Shatterer]>", "Die Manaschmiede Omega"}
        s["npc;drop=175646"] = {"P.O.S.T.-Meister", "Tazavesh, der Verhüllte Markt"}
        s["npc;drop=177269"] = {"So'leah <Kartell So>", "Tazavesh, der Verhüllte Markt"}
        s["npc;drop=234933"] = {"Taah'bat <Die Erbarmungslosen>", "Die Biokuppel Al'dani"}
        s["spell;created=1249111"] = {"Wickel erhalten", "CRAFTING"}
        s["npc;drop=165408"] = {"Halkias <Der Sündenbefleckte Goliath>", "Hallen der Sühne"}
        s["npc;drop=175663"] = {"Hylbrand <Schwert der Hüter>", "Tazavesh, der Verhüllte Markt"}
        s["npc;drop=165410"] = {"Hochadjudikatorin Aleez", "Hallen der Sühne"}
        s["npc;drop=176556"] = {"Alcruux <Der Nimmersatt>", "Tazavesh, der Verhüllte Markt"}
        s["npc;drop=247283"] = {"Seelenschreiberin", "Die Biokuppel Al'dani"}
        s["npc;drop=175546"] = {"Zeitkäpt'n Hakenschwanz", "Tazavesh, der Verhüllte Markt"}
        s["npc;drop=176705"] = {"Venza Goldschmelz", "Tazavesh, der Verhüllte Markt"}
        s["npc;drop=164218"] = {"Oberster Kämmerer", "Hallen der Sühne"}
        s["npc;drop=175616"] = {"Zo'phex <Der Hüter>", "Tazavesh, der Verhüllte Markt"}
        s["spell;created=450223"] = {"Ewiggeschmiedeter Verteidiger", "CRAFTING"}
        s["npc;drop=244752"] = {"Nexusprinzessin Ky'veza", "Das Leerenmesserrefugium"}
        s["npc;drop=231981"] = {"Schlund der Sande", "K'aresh"}
        s["npc;drop=234845"] = {"Sthaarbs <der Geisttrüber>", "K'aresh"}
        s["object;contained=416265"] = {"Stibitzte Truhe", "Der Terrorschacht"}
        s["npc;drop=247989"] = {"Schmiedeweber Araz", "Die Manaschmiede Omega"}
        s["npc;drop=233814"] = {"Plexuswache", "Die Manaschmiede Omega"}
        s["npc;drop=237661"] = {"Adarus Dämmerflamme", "Die Manaschmiede Omega"}
        s["npc;drop=237763"] = {"Nexuskönig Salhadaar", "Die Manaschmiede Omega"}
        s["npc;drop=233816"] = {"Seelenbinderin Naazindhri", "Die Manaschmiede Omega"}
        s["npc;drop=235853"] = {"Torbeobachter", "Die Manaschmiede Omega"}
        s["npc;drop=239454"] = {"Dunkelmagier Zadus", "Die Manaschmiede Omega"}
        s["npc;sold=248303"] = {"Zah'ran <[Delve Trinkets]>", "Ausgrabungsstätte 9"}
        s["quest;reward=91009"] = {"Dateninformationssicherungsbehältnis", "Dornogal"}
        s["spell;created=441063"] = {"Glyphengravierte Beinschienen", "CRAFTING"}
    end

    function SpecBisTooltip:TranslationesES()
        s["npc;drop=223779"] = {"Anub'arash <Las Mil Cicatrices>", "Palacio Nerub'ar"}
        s["spell;created=450226"] = {"Avambrazos de forja eterna", "CRAFTING"}
        s["spell;created=450222"] = {"Gran cinturón de forja eterna", "CRAFTING"}
        s["npc;drop=219778"] = {"Reina Ansurek", "Palacio Nerub'ar"}
        s["npc;drop=162693"] = {"Nalthor Clamaescarcha", "Estela Necrótica"}
        s["npc;drop=162689"] = {"Cirujano Cosecarne", "Estela Necrótica"}
        s["npc;drop=219853"] = {"Sikran <Capitán de los sureki>", "Palacio Nerub'ar"}
        s["spell;created=450220"] = {"Escarpes de forja eterna", "CRAFTING"}
        s["npc;drop=214506"] = {"Tuercelinajes Ovi'nax", "Palacio Nerub'ar"}
        s["npc;drop=164501"] = {"Clamaneblina", "Nieblas de Tirna Scithe"}
        s["npc;drop=40319"] = {"Drahga Quemasombras <Mensajero del Martillo Crepuscular>", "Grim Batol"}
        s["npc;drop=215405"] = {"Anub'zekt <Guardaenjambre>", "Ara-Kara, Ciudad de los Ecos"}
        s["npc;drop=39625"] = {"General Umbriss <Siervo de Alamuerte>", "Grim Batol"}
        s["npc;drop=213217"] = {"Orador Brokk", "La Petrocámara"}
        s["npc;drop=129208"] = {"Capitana aterradora Lockwood", "Asedio de Boralus"}
        s["npc;drop=213119"] = {"Portavoz del Vacío Eirich", "La Petrocámara"}
        s["npc;drop=216320"] = {"Coaglamación", "Ciudad Tejida"}
        s["npc;drop=128650"] = {"Cortador Ganchorrojo", "Asedio de Boralus"}
        s["npc;drop=128651"] = {"Hadal Brazasombría", "Asedio de Boralus"}
        s["npc;drop=128649"] = {"Sargento Bainbridge", "Asedio de Boralus"}
        s["spell;created=450242"] = {"Cercenadora cargada", "CRAFTING"}
        s["npc;drop=228470"] = {"Princesa del Nexo Ky'veza", "Palacio Nerub'ar"}
        s["npc;drop=214502"] = {"El horror vinculado a la sangre", "Palacio Nerub'ar"}
        s["npc;drop=216658"] = {"Izo la Gran Ensambladora", "Ciudad Tejida"}
        s["npc;drop=163157"] = {"Amarth <El Cosechador>", "Estela Necrótica"}
        s["npc;drop=211087"] = {"Oradora Coronasombría", "El Rompealbas"}
        s["npc;drop=40484"] = {"Erudax <El Duque de las profundidades>", "Grim Batol"}
        s["npc;drop=210108"] = {"E.D.N.A.", "La Petrocámara"}
        s["npc;drop=162691"] = {"Huesoañublo", "Estela Necrótica"}
        s["spell;created=441057"] = {"Pretina con runas marcadas", "CRAFTING"}
        s["npc;drop=216619"] = {"Orador Krix'vizk <El Quinto Hilo>", "Ciudad Tejida"}
        s["spell;created=450232"] = {"Guja de guerra de forja eterna", "CRAFTING"}
        s["npc;drop=215407"] = {"Ki'katal la Cosechadora", "Ara-Kara, Ciudad de los Ecos"}
        s["npc;drop=128652"] = {"Viq'Goth <Terror de las profundidades>", "Asedio de Boralus"}
        s["spell;created=444070"] = {"Cinto de aumento suprarrenal", "CRAFTING"}
        s["spell;created=450231"] = {"Tizona de forja eterna", "CRAFTING"}
        s["npc;drop=40177"] = {"Maestro de forja Throngus", "Grim Batol"}
        s["spell;created=435382"] = {"Anillo de vinculación", "CRAFTING"}
        s["npc;drop=216648"] = {"Nx <Colmillo de la Reina>", "Ciudad Tejida"}
        s["npc;drop=207207"] = {"Monstruosidad de piedra del Vacío", "El Grajero"}
        s["spell;created=450235"] = {"Espada embrujada cargada", "CRAFTING"}
        s["spell;created=444197"] = {"Antorcha de vagabundo", "CRAFTING"}
        s["npc;drop=208743"] = {"Llamakon", "Grieta de Flama Oscura"}
        s["npc;drop=210271"] = {"Maestro cervecero Aldryr", "Lagar de Tragoceniza"}
        s["npc;drop=207205"] = {"Guardiatormenta Gorren", "El Grajero"}
        s["npc;drop=218002"] = {"Benk Abejorro <Apicultor>", "Lagar de Tragoceniza"}
        s["spell;created=450230"] = {"Daga de forja eterna", "CRAFTING"}
        s["spell;created=441066"] = {"Avambrazos con glifos grabados", "CRAFTING"}
        s["spell;created=441061"] = {"Guanteletes con glifos grabados", "CRAFTING"}
        s["spell;created=446940"] = {"Capa consagrada", "CRAFTING"}
        s["spell;created=450239"] = {"Alabarda cargada", "CRAFTING"}
        s["spell;created=445355"] = {"Cetro de magia radiante", "CRAFTING"}
        s["npc;drop=214661"] = {"Áurea Barónez <MIEL.E.O.>", "Lagar de Tragoceniza"}
        s["npc;drop=210153"] = {"Viejo Barbacera", "Grieta de Flama Oscura"}
        s["npc;drop=207946"] = {"Capitán Gritoldía", "Priorato de la Llama Sagrada"}
        s["spell;created=446937"] = {"Zapatillas consagradas", "CRAFTING"}
        s["spell;created=444198"] = {"Muleta cuidadosa de vagabundo", "CRAFTING"}
        s["spell;created=441058"] = {"Bandas con runas marcadas", "CRAFTING"}
        s["spell;created=441052"] = {"Chanclos con runas marcadas", "CRAFTING"}
        s["spell;created=441055"] = {"Perneras con runas marcadas", "CRAFTING"}
        s["spell;created=435385"] = {"Amuleto de artesanía terránea", "CRAFTING"}
        s["spell;created=450237"] = {"Machacacaras cargado", "CRAFTING"}
        s["spell;created=450238"] = {"Mandoble cargado", "CRAFTING"}
        s["npc;drop=207939"] = {"Barón Braunpyke", "Priorato de la Llama Sagrada"}
        s["npc;drop=210797"] = {"La Oscuridad", "Grieta de Flama Oscura"}
        s["spell;created=441053"] = {"Mandiletes con runas marcadas", "CRAFTING"}
        s["spell;created=446938"] = {"Puños consagrados", "CRAFTING"}
        s["spell;created=444199"] = {"Bastón delimitador de vagabundo", "CRAFTING"}
        s["spell;created=450224"] = {"Yelmo de forja eterna", "CRAFTING"}
        s["spell;created=450234"] = {"Gran hacha de forja eterna", "CRAFTING"}
        s["spell;created=435384"] = {"Anillo de artesanía terránea", "CRAFTING"}
        s["spell;created=441060"] = {"Apisonadoras con glifos grabados", "CRAFTING"}
        s["npc;sold=227003"] = {"Kir'xal <Recaudadora de curiosidades>", "Ciudad Tejida"}
        s["object;contained=413590"] = {"Arca pródiga", "Foso del Pavor"}
        s["spell;created=441065"] = {"Ataduras con glifos grabados", "CRAFTING"}
        s["npc;drop=215657"] = {"Ul'grax el Devorador", "Palacio Nerub'ar"}
        s["object;contained=413563"] = {"Baúl pesado", "Caverna del Micomante"}
        s["npc;drop=202318"] = {"Vigía del equipo de respuesta", "Caverna Zaralek"}
        s["npc;drop=203355"] = {"Capitana Reykal", "Caverna Zaralek"}
        s["spell;created=427185"] = {"Piedra de alquimista algariana", "CRAFTING"}
        s["npc;sold=219222"] = {"Lalandi <Intendente de conquista>", "Dornogal"}
        s["item:contained=229354"] = {"Alijo de aventurero algariano", ""}
        s["item:contained=229129"] = {"Alijo de botín de las profundidades", ""}
        s["quest;reward=78636"] = {"La reconquista de las minas", ""}
        s["quest;reward=79342"] = {"Y llega la despedida", ""}
        s["quest;reward=78232"] = {"Reescribir lo reescrito", ""}
        s["spell;created=455393"] = {"Resplandor", ""}
        s["spell;created=455394"] = {"Ascensión", ""}
        s["spell;created=455392"] = {"Simbiosis", ""}
        s["spell;created=455391"] = {"Vivacidad", ""}
        s["npc;drop=226305"] = {"[Emperor Dagran Thaurissan]", "Profundidades de Roca Negra"}
        s["npc;drop=226306"] = {"[Golem Lord Argelmach]", "Profundidades de Roca Negra"}
        s["npc;drop=226315"] = {"[Lord Roccor]", "Profundidades de Roca Negra"}
        s["npc;sold=224270"] = {"Ip'xal <Sastra de héroes>", "Ciudad Tejida"}
        s["npc;drop=217489"] = {"Anub'arash <Las Mil Cicatrices>", "Palacio Nerub'ar"}
        s["npc;drop=223839"] = {"Guardia de la reina Ge'zah", "Palacio Nerub'ar"}
        s["spell;created=447314"] = {"Expedidor de luminosidad estudioso", "CRAFTING"}
        s["spell;created=446939"] = {"Cordón consagrado", "CRAFTING"}
        s["spell;created=450229"] = {"Apuñaladora de forja eterna", "CRAFTING"}
        s["npc;drop=229992"] = {"Estalagmirok", "Isla de la Sirena"}
        s["npc;sold=231824"] = {"[Kari Bridgeblaster]", "Minahonda"}
        s["npc;drop=226396"] = {"[Swampface]", "Operación: Compuerta"}
        s["npc;drop=229181"] = {"[Flarendo]", "Liberación de Minahonda"}
        s["npc;drop=144246"] = {"KU-J0", "Operación: Mecandria"}
        s["npc;drop=241526"] = {"[Chrome King Gallywix]", "Liberación de Minahonda"}
        s["npc;drop=228458"] = {"[One-Armed Bandit]", "Liberación de Minahonda"}
        s["npc;drop=228652"] = {"[Rik Reverb]", "Liberación de Minahonda"}
        s["npc;drop=164451"] = {"Dessia la Decapitadora", "Teatro del Dolor"}
        s["npc;drop=225821"] = {"[The Geargrinder]", "Liberación de Minahonda"}
        s["npc;drop=230583"] = {"[Sprocketmonger Lockenstock]", "Liberación de Minahonda"}
        s["npc;drop=229953"] = {"[Mug'Zee]", "Liberación de Minahonda"}
        s["npc;drop=230322"] = {"[Stix Bunkjunker]", "Liberación de Minahonda"}
        s["npc;drop=129231"] = {"Rixxa Flujollama <Jefa científica>", "VETA MADRE"}
        s["npc;drop=162317"] = {"Tajasangre", "Teatro del Dolor"}
        s["npc;drop=226404"] = {"Geezle Gigachispa", "Operación: Compuerta"}
        s["npc;drop=165946"] = {"Mordretha, la Emperatriz Eterna", "Teatro del Dolor"}
        s["npc;drop=226403"] = {"[Keeza Quickfuse]", "Operación: Compuerta"}
        s["npc;drop=230828"] = {"[Chief Foreman Gutso]", "Minahonda"}
        s["npc;drop=230800"] = {"[Slugger the Smart]", "Minahonda"}
        s["npc;drop=230934"] = {"[Ratspit]", "Minahonda"}
        s["npc;drop=152619"] = {"Rey Mecandria", "Operación: Mecandria"}
        s["npc;drop=150397"] = {"Rey Mecandria", "Operación: Mecandria"}
        s["npc;drop=129214"] = {"Repartetundas de pago", "VETA MADRE"}
        s["npc;drop=144248"] = {"Maquinista jefe Flujochispa", "Operación: Mecandria"}
        s["spell;created=447315"] = {"Generador de ideas sobrecargado", "CRAFTING"}
        s["npc;drop=208745"] = {"Rey Vela", "Grieta de Flama Oscura"}
        s["npc;drop=162329"] = {"Xav el Invicto", "Teatro del Dolor"}
        s["npc;drop=226398"] = {"[Big M.O.M.M.A.]", "Operación: Compuerta"}
        s["quest;reward=83125"] = {"", "Zuldazar"}
        s["object;contained=476068"] = {"[Papa's Prized Putter]", "Minahonda"}
        s["npc;drop=144244"] = {"Repartetundas de platino", "Operación: Mecandria"}
        s["spell;created=473400"] = {"Reconfiguración para lanzamiento de hechizos", "CRAFTING"}
        s["npc;drop=207940"] = {"Priora Murrezo", "Priorato de la Llama Sagrada"}
        s["npc;drop=242255"] = {"[Geezle Gigazap]", "Operación: Compuerta"}
        s["npc;drop=150222"] = {"Mugroso", "Operación: Mecandria"}
        s["npc;drop=230946"] = {"[V.V. Goosworth]", "Minahonda"}
        s["npc;drop=150159"] = {"Rey Gobbamak", "Operación: Mecandria"}
        s["npc;drop=231310"] = {"Precipitante de Fundisombras", "Minahonda"}
        s["npc;drop=229288"] = {"Rey Escupellamas <Gerente de Flarendo>", "Liberación de Minahonda"}
        s["npc;drop=229284"] = {"Guk Bumcan <El vendedor de bazofia>", "Liberación de Minahonda"}
        s["object;contained=507768"] = {"Montón desechado de goblindólares", "Excavación 9"}
        s["spell;created=441051"] = {"Guerrera con runas marcadas", "CRAFTING"}
        s["npc;drop=237861"] = {"Fractillus <[The Shatterer]>", "Forja de Maná Omega"}
        s["npc;drop=175646"] = {"Jefe de correos", "Tazavesh, el Mercado Velado"}
        s["npc;drop=177269"] = {"So'leah <Cártel So>", "Tazavesh, el Mercado Velado"}
        s["npc;drop=234933"] = {"Taah'bat <El Incansable>", "Ecodomo Al'dani"}
        s["spell;created=1249111"] = {"Recibir mantón", "CRAFTING"}
        s["npc;drop=165408"] = {"Halkias <El goliat impenitente>", "Salas de la Expiación"}
        s["npc;drop=175663"] = {"Hylbrande <Espada de los guardianes>", "Tazavesh, el Mercado Velado"}
        s["npc;drop=165410"] = {"Gran adjudicadora Aleez", "Salas de la Expiación"}
        s["npc;drop=176556"] = {"Alcruux <El Glotón>", "Tazavesh, el Mercado Velado"}
        s["npc;drop=247283"] = {"Escriba de almas", "Ecodomo Al'dani"}
        s["npc;drop=175546"] = {"Cronocapitana Colagarfio", "Tazavesh, el Mercado Velado"}
        s["npc;drop=176705"] = {"Venza Fundioro", "Tazavesh, el Mercado Velado"}
        s["npc;drop=164218"] = {"Lord chambelán", "Salas de la Expiación"}
        s["npc;drop=175616"] = {"Zo'phex <El Centinela>", "Tazavesh, el Mercado Velado"}
        s["spell;created=450223"] = {"Defensor de forja eterna", "CRAFTING"}
        s["npc;drop=244752"] = {"Princesa del Nexo Ky'veza", "Santuario Filovacío"}
        s["npc;drop=231981"] = {"Fauce de las arenas", "K'aresh"}
        s["npc;drop=234845"] = {"Sthaarbs <El Tuercementes>", "K'aresh"}
        s["object;contained=416265"] = {"Baúl birlado", "Foso del Pavor"}
        s["npc;drop=247989"] = {"Tejeforjas Araz", "Forja de Maná Omega"}
        s["npc;drop=233814"] = {"Centinela del plexo", "Forja de Maná Omega"}
        s["npc;drop=237661"] = {"Adarus Fulgorsombrío", "Forja de Maná Omega"}
        s["npc;drop=237763"] = {"Rey-nexo Salhadaar", "Forja de Maná Omega"}
        s["npc;drop=233816"] = {"Vinculadora de almas Naazindhri", "Forja de Maná Omega"}
        s["npc;drop=235853"] = {"Vigía de puerta", "Forja de Maná Omega"}
        s["npc;drop=239454"] = {"Mago oscuro Zadus", "Forja de Maná Omega"}
        s["npc;sold=248303"] = {"Zah'ran <[Delve Trinkets]>", "Excavación 9"}
        s["quest;reward=91009"] = {"Depósito de Información Segura Contenida y Organizada", "Dornogal"}
        s["spell;created=441063"] = {"Quijotes con glifos grabados", "CRAFTING"}
    end

    function SpecBisTooltip:TranslationfrFR()
        s["npc;drop=223779"] = {"Anub'arash <Les Mille cicatrices>", "Palais des Nérub’ar"}
        s["spell;created=450226"] = {"Protège-bras en forge perpétuelle", "CRAFTING"}
        s["spell;created=450222"] = {"Grande ceinture en forge perpétuelle", "CRAFTING"}
        s["npc;drop=219778"] = {"Reine Ansurek", "Palais des Nérub’ar"}
        s["npc;drop=162693"] = {"Nalthor le Lieur-de-Givre", "Sillage nécrotique"}
        s["npc;drop=162689"] = {"Docteur Sutur", "Sillage nécrotique"}
        s["npc;drop=219853"] = {"Sikran <Capitaine des Surekis>", "Palais des Nérub’ar"}
        s["spell;created=450220"] = {"Solerets en forge perpétuelle", "CRAFTING"}
        s["npc;drop=214506"] = {"Toressaim Ovi'nax", "Palais des Nérub’ar"}
        s["npc;drop=164501"] = {"Mandebrume", "Brumes de Tirna Scithe"}
        s["npc;drop=40319"] = {"Drahga Brûle-Ombre <Messager du Marteau du crépuscule>", "Grim Batol"}
        s["npc;drop=215405"] = {"Anub'zekt <Garde-essaim>", "Ara-Kara, la cité des Échos"}
        s["npc;drop=39625"] = {"Général Umbriss <Serviteur d'Aile de mort>", "Grim Batol"}
        s["npc;drop=213217"] = {"Mandataire Brokk", "La Cavepierre"}
        s["npc;drop=129208"] = {"Capitaine de l'effroi Boisclos", "Siège de Boralus"}
        s["npc;drop=213119"] = {"Orateur du Vide Eirich", "La Cavepierre"}
        s["npc;drop=216320"] = {"La Coaglamation", "Cité des Fils"}
        s["npc;drop=128650"] = {"Crochesang", "Siège de Boralus"}
        s["npc;drop=128651"] = {"Hadal Sombrabysse", "Siège de Boralus"}
        s["npc;drop=128649"] = {"Sergent Bainbridge", "Siège de Boralus"}
        s["spell;created=450242"] = {"Tranchoir chargé", "CRAFTING"}
        s["npc;drop=228470"] = {"Princesse-nexus Ky'veza", "Palais des Nérub’ar"}
        s["npc;drop=214502"] = {"L'horreur liée par le sang", "Palais des Nérub’ar"}
        s["npc;drop=216658"] = {"Izo le Grand Faisceau", "Cité des Fils"}
        s["npc;drop=163157"] = {"Amarth <Le Moissonneur>", "Sillage nécrotique"}
        s["npc;drop=211087"] = {"Mandataire Couronne d'ombre", "Le Brise-Aube"}
        s["npc;drop=40484"] = {"Erudax <Le duc d'En bas>", "Grim Batol"}
        s["npc;drop=210108"] = {"E.D.N.A.", "La Cavepierre"}
        s["npc;drop=162691"] = {"Chancros", "Sillage nécrotique"}
        s["spell;created=441057"] = {"Baudrier marqué de runes", "CRAFTING"}
        s["npc;drop=216619"] = {"Mandataire Krix'vizk <Le cinquième filament>", "Cité des Fils"}
        s["spell;created=450232"] = {"Glaive de guerre en forge perpétuelle", "CRAFTING"}
        s["npc;drop=215407"] = {"Ki'katal la Moissonneuse", "Ara-Kara, la cité des Échos"}
        s["npc;drop=128652"] = {"Viq'Goth <Terreur des abysses>", "Siège de Boralus"}
        s["spell;created=444070"] = {"Fermoir d’afflux surrénal", "CRAFTING"}
        s["spell;created=450231"] = {"Épée longue en forge perpétuelle", "CRAFTING"}
        s["npc;drop=40177"] = {"Maître-forge Throngus", "Grim Batol"}
        s["spell;created=435382"] = {"Lien bienfaiteur", "CRAFTING"}
        s["npc;drop=216648"] = {"Nx <Croc de la Reine>", "Cité des Fils"}
        s["npc;drop=207207"] = {"Monstruosité de pierre du Vide", "La colonie"}
        s["spell;created=450235"] = {"Maléfilame chargée", "CRAFTING"}
        s["spell;created=444197"] = {"Torche de vagabondage", "CRAFTING"}
        s["npc;drop=210271"] = {"Maître brasseur Aldryr", "Hydromellerie de Brassecendre"}
        s["npc;drop=207205"] = {"Garde de la tempête Gorren", "La colonie"}
        s["npc;drop=218002"] = {"Benk Bourdon <Apiculteur>", "Hydromellerie de Brassecendre"}
        s["spell;created=450230"] = {"Dague en forge perpétuelle", "CRAFTING"}
        s["spell;created=441066"] = {"Protège-bras gravés de glyphes", "CRAFTING"}
        s["spell;created=441061"] = {"Gantelets gravés de glyphes", "CRAFTING"}
        s["spell;created=447352"] = {"P.A.N. x2", "CRAFTING"}
        s["spell;created=446940"] = {"Cape consacrée", "CRAFTING"}
        s["spell;created=450239"] = {"Hallebarde chargée", "CRAFTING"}
        s["spell;created=445355"] = {"Sceptre des magies radieuses", "CRAFTING"}
        s["npc;drop=214661"] = {"Goldie Baronnie <DRH>", "Hydromellerie de Brassecendre"}
        s["npc;drop=210153"] = {"Vieux Barbecire", "Faille de Flamme-Noire"}
        s["npc;drop=207946"] = {"Capitaine Dailcri", "Prieuré de la Flamme sacrée"}
        s["spell;created=446937"] = {"Mules consacrées", "CRAFTING"}
        s["spell;created=444198"] = {"Béquille prudente de vagabondage", "CRAFTING"}
        s["spell;created=441058"] = {"Bracières marquées de runes", "CRAFTING"}
        s["spell;created=441052"] = {"Demi-bottes marquées de runes", "CRAFTING"}
        s["spell;created=441055"] = {"Jambards marqués de runes", "CRAFTING"}
        s["spell;created=435385"] = {"Amulette d’artisanat terrestre", "CRAFTING"}
        s["spell;created=450237"] = {"Pilonneur chargé", "CRAFTING"}
        s["spell;created=450238"] = {"Claymore chargée", "CRAFTING"}
        s["npc;drop=207939"] = {"Baron Braunpique", "Prieuré de la Flamme sacrée"}
        s["npc;drop=210797"] = {"Les Ténèbres", "Faille de Flamme-Noire"}
        s["spell;created=441053"] = {"Poignées marquées de runes", "CRAFTING"}
        s["spell;created=446938"] = {"Crispins consacrés", "CRAFTING"}
        s["spell;created=444199"] = {"Férule de vagabondage", "CRAFTING"}
        s["spell;created=450224"] = {"Heaume en forge perpétuelle", "CRAFTING"}
        s["spell;created=450234"] = {"Bardiche en forge perpétuelle", "CRAFTING"}
        s["spell;created=435384"] = {"Anneau d’artisanat terrestre", "CRAFTING"}
        s["spell;created=441060"] = {"Croquenots gravés de glyphes", "CRAFTING"}
        s["npc;sold=227003"] = {"Kir'xal <Collectionneuse de curiosités>", "Cité des Fils"}
        s["object;contained=413590"] = {"Coffre abondant", "La fosse de l’Effroi"}
        s["spell;created=441065"] = {"Lien gravé de glyphes", "CRAFTING"}
        s["npc;drop=215657"] = {"Ulgrax le Dévoreur", "Palais des Nérub’ar"}
        s["object;contained=413563"] = {"Malle lourde", "Grotte de Mycomancie"}
        s["npc;drop=202318"] = {"Gardienne de l'équipe d'intervention", "Grotte de Zaralek"}
        s["npc;drop=203355"] = {"Capitaine Reykal", "Grotte de Zaralek"}
        s["spell;created=427185"] = {"Pierre d’alchimiste algarie", "CRAFTING"}
        s["npc;sold=219222"] = {"Lalandi <Intendante des emblèmes de conquête>", "Dornogal"}
        s["item:contained=229354"] = {"Cache d’aventurier algari", ""}
        s["item:contained=229129"] = {"Cache de butin des Gouffres", ""}
        s["quest;reward=78636"] = {"Reprendre les mines", ""}
        s["quest;reward=79342"] = {"Dans son départ", ""}
        s["quest;reward=78232"] = {"Réécrire la réécriture", ""}
        s["spell;created=455394"] = {"Sublimation", ""}
        s["spell;created=455392"] = {"Symbiose", ""}
        s["spell;created=455391"] = {"Vivacité", ""}
        s["npc;drop=226305"] = {"[Emperor Dagran Thaurissan]", "Les profondeurs de Rochenoire"}
        s["npc;drop=226306"] = {"[Golem Lord Argelmach]", "Les profondeurs de Rochenoire"}
        s["npc;drop=226315"] = {"[Lord Roccor]", "Les profondeurs de Rochenoire"}
        s["npc;sold=224270"] = {"Ip'xal <Tailleuse héroïque>", "Cité des Fils"}
        s["npc;drop=217489"] = {"Anub'arash <Les Mille cicatrices>", "Palais des Nérub’ar"}
        s["npc;drop=223839"] = {"Garde de la reine Ge'zah", "Palais des Nérub’ar"}
        s["spell;created=447314"] = {"Expéditeur d’illumination studieuse", "CRAFTING"}
        s["spell;created=446939"] = {"Corde consacrée", "CRAFTING"}
        s["spell;created=450229"] = {"Eustache en forge perpétuelle", "CRAFTING"}
        s["npc;sold=231824"] = {"[Kari Bridgeblaster]", "Terremine"}
        s["npc;drop=226396"] = {"[Swampface]", "Opération Vannes ouvertes"}
        s["npc;drop=229181"] = {"[Flarendo]", "Libération de Terremine"}
        s["npc;drop=241526"] = {"[Chrome King Gallywix]", "Libération de Terremine"}
        s["npc;drop=228458"] = {"[One-Armed Bandit]", "Libération de Terremine"}
        s["npc;drop=228652"] = {"[Rik Reverb]", "Libération de Terremine"}
        s["npc;drop=164451"] = {"Dessia la Décapiteuse", "Théâtre de la Souffrance"}
        s["npc;drop=225821"] = {"[The Geargrinder]", "Libération de Terremine"}
        s["npc;drop=230583"] = {"[Sprocketmonger Lockenstock]", "Libération de Terremine"}
        s["npc;drop=229953"] = {"[Mug'Zee]", "Libération de Terremine"}
        s["npc;drop=230322"] = {"[Stix Bunkjunker]", "Libération de Terremine"}
        s["npc;drop=131227"] = {"Nabab Razzbam", "Le Filon"}
        s["npc;drop=129231"] = {"Rixxa Fluxifuge <Scientifique en chef>", "Le Filon"}
        s["npc;drop=162317"] = {"Trancheboyau", "Théâtre de la Souffrance"}
        s["npc;drop=226404"] = {"[Geezle Gigazap]", "Opération Vannes ouvertes"}
        s["npc;drop=165946"] = {"Mordretha, l'impératrice immortelle", "Théâtre de la Souffrance"}
        s["npc;drop=226403"] = {"[Keeza Quickfuse]", "Opération Vannes ouvertes"}
        s["npc;drop=132713"] = {"Nabab Razzbam", "Le Filon"}
        s["npc;drop=230828"] = {"[Chief Foreman Gutso]", "Terremine"}
        s["npc;drop=230800"] = {"[Slugger the Smart]", "Terremine"}
        s["npc;drop=230934"] = {"[Ratspit]", "Terremine"}
        s["npc;drop=152619"] = {"Roi Mécagone", "Opération Mécagone"}
        s["npc;drop=150397"] = {"Roi Mécagone", "Opération Mécagone"}
        s["npc;drop=129214"] = {"Disperseur de foule automatique", "Le Filon"}
        s["npc;drop=144248"] = {"Machiniste en chef Electroflux", "Opération Mécagone"}
        s["spell;created=447315"] = {"Générateur d’idées débridé", "CRAFTING"}
        s["npc;drop=208745"] = {"Le roi-bougie", "Faille de Flamme-Noire"}
        s["npc;drop=162329"] = {"Xav l'Invaincu", "Théâtre de la Souffrance"}
        s["npc;drop=226398"] = {"[Big M.O.M.M.A.]", "Opération Vannes ouvertes"}
        s["quest;reward=83125"] = {"", "Zuldazar"}
        s["object;contained=476068"] = {"[Papa's Prized Putter]", "Terremine"}
        s["npc;drop=144244"] = {"Le « Tabasseur de platine »", "Opération Mécagone"}
        s["spell;created=473400"] = {"Reconfiguration pour les sorts", "CRAFTING"}
        s["npc;drop=207940"] = {"Prieuresse Murrpray", "Prieuré de la Flamme sacrée"}
        s["npc;drop=242255"] = {"[Geezle Gigazap]", "Opération Vannes ouvertes"}
        s["npc;drop=150222"] = {"Salcrass", "Opération Mécagone"}
        s["npc;drop=230946"] = {"[V.V. Goosworth]", "Terremine"}
        s["npc;drop=150159"] = {"Roi Gobbamak", "Opération Mécagone"}
        s["npc;drop=231310"] = {"Précipitant imprégné de ténèbres", "Terremine"}
        s["npc;drop=229288"] = {"Roi Hargnembrase <Impresario de Fusendo>", "Libération de Terremine"}
        s["npc;drop=229284"] = {"Guk Boumouaf <Vendeur de gruau>", "Libération de Terremine"}
        s["object;contained=507768"] = {"Tas de devises gobelines éjectées", "Site d’excavation 9"}
        s["spell;created=441051"] = {"Tunique marquée de runes", "CRAFTING"}
        s["npc;drop=237861"] = {"Fractillus <[The Shatterer]>", "Manaforge Oméga"}
        s["npc;drop=175646"] = {"Maître de P.O.S.T.E.", "Tazavesh, le marché dissimulé"}
        s["npc;drop=177269"] = {"So'leah <Cartel So>", "Tazavesh, le marché dissimulé"}
        s["npc;drop=234933"] = {"Taah'bat <L'Implacable>", "Écodôme Al’dani"}
        s["spell;created=1249111"] = {"Recevoir les bandelettes", "CRAFTING"}
        s["npc;drop=165408"] = {"Halkias <Le goliath vicié>", "Salles de l’Expiation"}
        s["npc;drop=175663"] = {"Hylbrande <Epée des gardiens>", "Tazavesh, le marché dissimulé"}
        s["npc;drop=165410"] = {"Grande adjudicatrice Alize", "Salles de l’Expiation"}
        s["npc;drop=176556"] = {"Alcruux <Le glouton>", "Tazavesh, le marché dissimulé"}
        s["npc;drop=247283"] = {"Scribe de l'âme", "Écodôme Al’dani"}
        s["npc;drop=175546"] = {"Chronocapitaine Harpagone", "Tazavesh, le marché dissimulé"}
        s["npc;drop=176705"] = {"Venza Mèchedor", "Tazavesh, le marché dissimulé"}
        s["npc;drop=164218"] = {"Grand chambellan", "Salles de l’Expiation"}
        s["npc;drop=175616"] = {"Zo'phex <La Sentinelle>", "Tazavesh, le marché dissimulé"}
        s["spell;created=450223"] = {"Défenseur en forge perpétuelle", "CRAFTING"}
        s["npc;drop=244752"] = {"Princesse-nexus Ky'veza", "Sanctuaire du Rasoir du Vide"}
        s["npc;drop=231981"] = {"Gueule des sables", "K’aresh"}
        s["npc;drop=234845"] = {"Sthaarbs <L'Agitateur>", "K’aresh"}
        s["object;contained=416265"] = {"Malle chapardée", "La fosse de l’Effroi"}
        s["npc;drop=247989"] = {"Tisseforge Araz", "Manaforge Oméga"}
        s["npc;drop=233814"] = {"Sentinelle du Plexus", "Manaforge Oméga"}
        s["npc;drop=237661"] = {"Adarus Soirbrasier", "Manaforge Oméga"}
        s["npc;drop=233815"] = {"Rou'ethar", "Manaforge Oméga"}
        s["npc;drop=237763"] = {"Roi-nexus Salhadaar", "Manaforge Oméga"}
        s["npc;drop=233816"] = {"Lieuse d'âme Naazindhri", "Manaforge Oméga"}
        s["npc;drop=235853"] = {"Guetteur de portail", "Manaforge Oméga"}
        s["npc;drop=239454"] = {"Mage sombre Zadus", "Manaforge Oméga"}
        s["npc;sold=248303"] = {"Zah'ran <[Delve Trinkets]>", "Site d’excavation 9"}
        s["quest;reward=91009"] = {"Dispositif d’Informations Sécurisé de Qualité Universelle et Éprouvée", "Dornogal"}
        s["spell;created=441063"] = {"Cuissières gravées de glyphes", "CRAFTING"}
    end

    function SpecBisTooltip:TranslationitIT()
        s["npc;drop=223779"] = {"Anub'arash <[The Thousand Scars]>", "Palazzo dei Nerub'ar"}
        s["spell;created=450226"] = {"Avambracci Eternoforgiati", "CRAFTING"}
        s["spell;created=450222"] = {"Grancintura Eternoforgiata", "CRAFTING"}
        s["npc;drop=219778"] = {"Regina Ansurek", "Palazzo dei Nerub'ar"}
        s["npc;drop=162693"] = {"Nalthor il Vincolabrina", "Scia Necrotica"}
        s["npc;drop=162689"] = {"Chirurgo Cucicarne", "Scia Necrotica"}
        s["npc;drop=219853"] = {"Sikran <Capitano dei Sureki>", "Palazzo dei Nerub'ar"}
        s["spell;created=450220"] = {"Calzari Eternoforgiati", "CRAFTING"}
        s["npc;drop=214506"] = {"Mutastirpe Ovi'nax", "Palazzo dei Nerub'ar"}
        s["npc;drop=164501"] = {"Evocanebbie", "Nebbie di Tirna Falcis"}
        s["npc;drop=40319"] = {"Drahga Strinaombre <Emissario del Martello del Crepuscolo>", "Grim Batol"}
        s["npc;drop=215405"] = {"Anub'zekt <Guardia dello Sciame>", "Ara-Kara, Città degli Echi"}
        s["npc;drop=39625"] = {"Generale Umbriss <Servitore di Alamorte>", "Grim Batol"}
        s["npc;drop=213217"] = {"Oratore Brokk", "Volta di Pietra"}
        s["npc;drop=129208"] = {"Capitano del Terrore Serralegno", "Assedio di Boralus"}
        s["npc;drop=213119"] = {"Oratore del Vuoto Eirich", "Volta di Pietra"}
        s["npc;drop=216320"] = {"L'Amalgama Coagulato", "Città dei Fili"}
        s["npc;drop=128650"] = {"Tagliatore Ganciorosso", "Assedio di Boralus"}
        s["npc;drop=128651"] = {"Hadal Fondoscuro", "Assedio di Boralus"}
        s["npc;drop=128649"] = {"Sergente Bainbridge", "Assedio di Boralus"}
        s["spell;created=450242"] = {"Ascia Tagliente Caricata", "CRAFTING"}
        s["npc;drop=228470"] = {"Principessa del Nexus Ky'veza", "Palazzo dei Nerub'ar"}
        s["npc;drop=214502"] = {"Orrore Vincolasangue", "Palazzo dei Nerub'ar"}
        s["npc;drop=216658"] = {"Izo, la Gran Giuntatrice", "Città dei Fili"}
        s["npc;drop=163157"] = {"Amarth <Il Mietitore>", "Scia Necrotica"}
        s["npc;drop=211087"] = {"Oratrice Sertombra", "Alba Infranta"}
        s["npc;drop=40484"] = {"Erudax <Duca delle Profondità>", "Grim Batol"}
        s["npc;drop=210108"] = {"E.D.N.A.", "Volta di Pietra"}
        s["npc;drop=162691"] = {"Piagaossa", "Scia Necrotica"}
        s["spell;created=441057"] = {"Fusciacca Marchiata con Rune", "CRAFTING"}
        s["npc;drop=216619"] = {"Oratore Krix'vizk <Il Quinto Filo>", "Città dei Fili"}
        s["spell;created=450232"] = {"Lame da Guerra Eternoforgiate", "CRAFTING"}
        s["npc;drop=215407"] = {"Ki'katal la Mietitrice", "Ara-Kara, Città degli Echi"}
        s["npc;drop=128652"] = {"Viq'goth <Terrore del Profondo>", "Assedio di Boralus"}
        s["spell;created=444070"] = {"Fibbia dell'Impeto Adrenalinico", "CRAFTING"}
        s["spell;created=450231"] = {"Spada Lunga Eternoforgiata", "CRAFTING"}
        s["npc;drop=40177"] = {"Mastro Forgiatore Throngus", "Grim Batol"}
        s["spell;created=435382"] = {"Vera del Vincolo", "CRAFTING"}
        s["npc;drop=216648"] = {"Nx <Zanna della Regina>", "Città dei Fili"}
        s["npc;drop=207207"] = {"Mostruosità della Pietra del Vuoto", "Corveria"}
        s["spell;created=450235"] = {"Spada Maledetta Carica", "CRAFTING"}
        s["spell;created=444197"] = {"Torcia del Vagabondo", "CRAFTING"}
        s["npc;drop=208743"] = {"Ardikon", "Faglia di Fiammoscura"}
        s["npc;drop=210271"] = {"Maestro dell'Idromele Aldryr", "Idromelificio Cinereo"}
        s["npc;drop=207205"] = {"Guardia della Tempesta Gorren", "Corveria"}
        s["npc;drop=218002"] = {"Benk il Ronzante <Apicoltore>", "Idromelificio Cinereo"}
        s["spell;created=450230"] = {"Pugnale Eternoforgiato", "CRAFTING"}
        s["spell;created=441066"] = {"Avambracci Incisi con Glifi", "CRAFTING"}
        s["spell;created=441061"] = {"Guanti Lunghi Incisi con Glifi", "CRAFTING"}
        s["spell;created=446940"] = {"Mantello Consacrato", "CRAFTING"}
        s["spell;created=450239"] = {"Alabarda Carica", "CRAFTING"}
        s["spell;created=445355"] = {"Scettro delle Magie Radiose", "CRAFTING"}
        s["npc;drop=214661"] = {"Dora Bottepiena <Amministratrice Mielegata>", "Idromelificio Cinereo"}
        s["npc;drop=210153"] = {"Vecchio Barbacera", "Faglia di Fiammoscura"}
        s["npc;drop=207946"] = {"Capitano Urlassiduo", "Prioria della Fiamma Sacra"}
        s["spell;created=446937"] = {"Pianelle Consacrate", "CRAFTING"}
        s["spell;created=444198"] = {"Stampella Attenta del Vagabondo", "CRAFTING"}
        s["spell;created=441058"] = {"Antibracci Marchiati con Rune", "CRAFTING"}
        s["spell;created=441052"] = {"Tiracalci Marchiati con Rune", "CRAFTING"}
        s["spell;created=441055"] = {"Coprigambe Marchiati con Rune", "CRAFTING"}
        s["spell;created=435385"] = {"Amuleto dell'Artigianato Terrigeno", "CRAFTING"}
        s["spell;created=450237"] = {"Sfondafacce Carico", "CRAFTING"}
        s["spell;created=450238"] = {"Spadone Carico", "CRAFTING"}
        s["npc;drop=207939"] = {"Barone Piccasolda", "Prioria della Fiamma Sacra"}
        s["npc;drop=210797"] = {"L'Oscurità", "Faglia di Fiammoscura"}
        s["spell;created=441053"] = {"Guardamani Marchiati con Rune", "CRAFTING"}
        s["spell;created=446938"] = {"Polsiere Consacrate", "CRAFTING"}
        s["spell;created=444199"] = {"Bacchetta Vincolante del Vagabondo", "CRAFTING"}
        s["spell;created=450224"] = {"Elmo Eternoforgiato", "CRAFTING"}
        s["spell;created=450234"] = {"Grandascia Eternoforgiata", "CRAFTING"}
        s["spell;created=435384"] = {"Anello dell'Artigianato Terrigeno", "CRAFTING"}
        s["spell;created=441060"] = {"Stivalacci Incisi con Glifi", "CRAFTING"}
        s["npc;sold=227003"] = {"Kir'xal <Collezionista di Curiosità>", "Città dei Fili"}
        s["object;contained=413590"] = {"Scrigno Fruttuoso", "Fossa del Terrore"}
        s["spell;created=441065"] = {"Cinta Incisa con Glifi", "CRAFTING"}
        s["npc;drop=215657"] = {"Ulgrax il Divoratore", "Palazzo dei Nerub'ar"}
        s["object;contained=413563"] = {"Baule Pesante", "Caverna del Micomante"}
        s["npc;drop=202318"] = {"Osservatrice della Squadra di Risposta", "Caverna di Zaralek"}
        s["npc;drop=203355"] = {"Capitana Reykal", "Caverna di Zaralek"}
        s["spell;created=427185"] = {"Pietra Alchemica Algari", "CRAFTING"}
        s["npc;sold=219222"] = {"Lalandi <Quartiermastro della Conquista>", "Dornogal"}
        s["item:contained=229354"] = {"Cassa dell'Avventuriero Algari", ""}
        s["item:contained=229129"] = {"Cassa di Spoglie delle Scorribande", ""}
        s["quest;reward=78636"] = {"Riconquistare le miniere", ""}
        s["quest;reward=79342"] = {"Mentre se ne va", ""}
        s["quest;reward=78232"] = {"Riscrivere i riscritti", ""}
        s["spell;created=455393"] = {"Radiosità", ""}
        s["spell;created=455394"] = {"Ascensione", ""}
        s["spell;created=455392"] = {"Simbiosi", ""}
        s["spell;created=455391"] = {"Vivacità", ""}
        s["npc;drop=226305"] = {"[Emperor Dagran Thaurissan]", "Sotterranei di Roccianera"}
        s["npc;drop=226306"] = {"[Golem Lord Argelmach]", "Sotterranei di Roccianera"}
        s["npc;drop=226315"] = {"[Lord Roccor]", "Sotterranei di Roccianera"}
        s["npc;sold=224270"] = {"Ip'xal <Stilista dell'Eroe>", "Città dei Fili"}
        s["npc;drop=217489"] = {"Anub'arash <Le Mille Cicatrici>", "Palazzo dei Nerub'ar"}
        s["npc;drop=223839"] = {"Guardia della Regina Ge'zah", "Palazzo dei Nerub'ar"}
        s["spell;created=447314"] = {"Acceleratore di Acume Erudito", "CRAFTING"}
        s["spell;created=446939"] = {"Fascione Consacrato", "CRAFTING"}
        s["spell;created=450229"] = {"Daga Eternoforgiata", "CRAFTING"}
        s["npc;sold=231824"] = {"[Kari Bridgeblaster]", "Cavafonda"}
        s["npc;drop=226396"] = {"[Swampface]", "Operazione: Paratoia"}
        s["npc;drop=229181"] = {"[Flarendo]", "Liberazione di Cavafonda"}
        s["npc;drop=241526"] = {"[Chrome King Gallywix]", "Liberazione di Cavafonda"}
        s["npc;drop=228458"] = {"[One-Armed Bandit]", "Liberazione di Cavafonda"}
        s["npc;drop=228652"] = {"[Rik Reverb]", "Liberazione di Cavafonda"}
        s["npc;drop=164451"] = {"Dessia la Decapitatrice", "Teatro del Dolore"}
        s["npc;drop=225821"] = {"[The Geargrinder]", "Liberazione di Cavafonda"}
        s["npc;drop=230583"] = {"[Sprocketmonger Lockenstock]", "Liberazione di Cavafonda"}
        s["npc;drop=229953"] = {"[Mug'Zee]", "Liberazione di Cavafonda"}
        s["npc;drop=230322"] = {"[Stix Bunkjunker]", "Liberazione di Cavafonda"}
        s["npc;drop=131227"] = {"Magnate Trucirazzi", "Vena Madre"}
        s["npc;drop=129231"] = {"Rixxa Flussafumi <Capo Scienziato>", "Vena Madre"}
        s["npc;drop=162317"] = {"Fendisangue", "Teatro del Dolore"}
        s["npc;drop=226404"] = {"Geezle Gigascossa", "Operazione: Paratoia"}
        s["npc;drop=165946"] = {"Mordretha, l'Imperatrice Eterna", "Teatro del Dolore"}
        s["npc;drop=226403"] = {"[Keeza Quickfuse]", "Operazione: Paratoia"}
        s["npc;drop=132713"] = {"Magnate Trucirazzi", "Vena Madre"}
        s["npc;drop=230828"] = {"[Chief Foreman Gutso]", "Cavafonda"}
        s["npc;drop=230800"] = {"[Slugger the Smart]", "Cavafonda"}
        s["npc;drop=230934"] = {"[Ratspit]", "Cavafonda"}
        s["npc;drop=152619"] = {"Re Meccagon", "Operazione: Meccagon"}
        s["npc;drop=150397"] = {"Re Meccagon", "Operazione: Meccagon"}
        s["npc;drop=129214"] = {"Sfollagente a Gettoni", "Vena Madre"}
        s["npc;drop=144248"] = {"Gran Macchinista Flussascintille", "Operazione: Meccagon"}
        s["spell;created=447315"] = {"Generatore di Idee Velocizzato", "CRAFTING"}
        s["npc;drop=208745"] = {"Il Re delle Candele", "Faglia di Fiammoscura"}
        s["npc;drop=162329"] = {"Xav l'Immortale", "Teatro del Dolore"}
        s["npc;drop=226398"] = {"[Big M.O.M.M.A.]", "Operazione: Paratoia"}
        s["quest;reward=83125"] = {"", "Zuldazar"}
        s["object;contained=476068"] = {"[Papa's Prized Putter]", "Cavafonda"}
        s["npc;drop=144244"] = {"Flagellatore Platinato", "Operazione: Meccagon"}
        s["spell;created=473400"] = {"Riconfigurazione per Lancio d'Incantesimi", "CRAFTING"}
        s["npc;drop=207940"] = {"Priora Fedecerda", "Prioria della Fiamma Sacra"}
        s["npc;drop=150222"] = {"Sporcheria", "Operazione: Meccagon"}
        s["npc;drop=230946"] = {"[V.V. Goosworth]", "Cavafonda"}
        s["npc;drop=150159"] = {"Re Gobbamak", "Operazione: Meccagon"}
        s["npc;drop=231310"] = {"Precipitante dei Micciascura", "Cavafonda"}
        s["npc;drop=229288"] = {"Re Ontardente <Responsabile di Motorendo>", "Liberazione di Cavafonda"}
        s["npc;drop=229284"] = {"Guk Tirabotte <Il Venditore di Sbobba>", "Liberazione di Cavafonda"}
        s["object;contained=507768"] = {"Mucchio di Soldi dei Goblin Gettati", "Sito di Scavo 9"}
        s["spell;created=441051"] = {"Giubba Marchiata con Rune", "CRAFTING"}
        s["npc;drop=237861"] = {"Fractillus <[The Shatterer]>", "Manaforgia Omega"}
        s["npc;drop=175646"] = {"Direttore della P.O.S.T.A.", "Tazavesh, il Bazar Celato"}
        s["npc;drop=156827"] = {"Eminenth", "Sale della Redenzione"}
        s["npc;drop=177269"] = {"So'leah <Cartello So>", "Tazavesh, il Bazar Celato"}
        s["npc;drop=234933"] = {"Taah'bat <L'Implacabile>", "Ecosfera Al'dani"}
        s["spell;created=1249111"] = {"Ricevimento Fasciature", "CRAFTING"}
        s["npc;drop=165408"] = {"Halkias <Mastodonte Macchiato dal Peccato>", "Sale della Redenzione"}
        s["npc;drop=175663"] = {"Hylbrande <Spada dei Custodi>", "Tazavesh, il Bazar Celato"}
        s["npc;drop=164185"] = {"Eminenth", "Sale della Redenzione"}
        s["npc;drop=165410"] = {"Gran Giudice Aleez", "Sale della Redenzione"}
        s["npc;drop=176556"] = {"Alcruux <L'Ingordo>", "Tazavesh, il Bazar Celato"}
        s["npc;drop=175546"] = {"Capitano del Tempo Coduncino", "Tazavesh, il Bazar Celato"}
        s["npc;drop=176705"] = {"Venza Micciadoro", "Tazavesh, il Bazar Celato"}
        s["npc;drop=164218"] = {"Ciambellano Supremo", "Sale della Redenzione"}
        s["npc;drop=175616"] = {"Zo'phex <La Sentinella>", "Tazavesh, il Bazar Celato"}
        s["spell;created=450223"] = {"Difensore Eternoforgiato", "CRAFTING"}
        s["npc;drop=244752"] = {"Principessa del Nexus Ky'veza", "Santuario Fendivuoto"}
        s["npc;drop=231981"] = {"Fauci delle Sabbie", "K'aresh"}
        s["npc;drop=234845"] = {"Sthaarbs <Il Turbamenti>", "K'aresh"}
        s["object;contained=416265"] = {"Baule Trafugato", "Fossa del Terrore"}
        s["npc;drop=247989"] = {"Tessiforgia Araz", "Manaforgia Omega"}
        s["npc;drop=233814"] = {"Sentinella del Plesso", "Manaforgia Omega"}
        s["npc;drop=237661"] = {"Adarus Fiammavespro", "Manaforgia Omega"}
        s["npc;drop=237763"] = {"Re del Nexus Salhadaar", "Manaforgia Omega"}
        s["npc;drop=233816"] = {"Vincolatrice d'Anime Naazindhri", "Manaforgia Omega"}
        s["npc;drop=235853"] = {"Guardiano del Portale di Traslocazione", "Manaforgia Omega"}
        s["npc;drop=239454"] = {"Mago Oscuro Zadus", "Manaforgia Omega"}
        s["npc;sold=248303"] = {"Zah'ran <[Delve Trinkets]>", "Sito di Scavo 9"}
        s["quest;reward=91009"] = {"Deposito Informazioni Sicure a Controllo Ottimale", "Dornogal"}
        s["spell;created=441063"] = {"Cosciali Incisi con Glifi", "CRAFTING"}
    end

    function SpecBisTooltip:TranslationkoKR()
        s["npc;drop=224552"] = {"라샤난", "네룹아르 궁전"}
        s["npc;drop=223779"] = {"아눕아라쉬 <일천 개의 상흔>", "네룹아르 궁전"}
        s["npc;sold=224270"] = {"입잘", "실타래의 도시"}
        s["spell;created=450226"] = {"영원벼림 완갑", "CRAFTING"}
        s["spell;created=450222"] = {"영원벼림 철갑허리띠", "CRAFTING"}
        s["npc;drop=219778"] = {"여왕 안수레크", "네룹아르 궁전"}
        s["npc;drop=162693"] = {"냉기결속사 날토르", "죽음의 상흔"}
        s["npc;drop=213179"] = {"아바녹스", "메아리의 도시 아라카라"}
        s["npc;drop=162689"] = {"의사 스티치플레시", "죽음의 상흔"}
        s["npc;drop=219853"] = {"시크란 <수레키 대장>", "네룹아르 궁전"}
        s["spell;created=450220"] = {"영원벼림 발덮개", "CRAFTING"}
        s["npc;drop=214506"] = {"혈족왜곡자 오비낙스", "네룹아르 궁전"}
        s["npc;drop=164501"] = {"미스트콜러", "티르너 사이드의 안개"}
        s["npc;drop=40319"] = {"드라가 섀도버너 <황혼의 망치단 급사>", "그림 바톨"}
        s["npc;drop=215405"] = {"아눕젝트 <무리경비병>", "메아리의 도시 아라카라"}
        s["npc;drop=211089"] = {"아눕이카즈", "새벽인도자호"}
        s["npc;drop=39625"] = {"장군 움브리스 <데스윙의 하수인>", "그림 바톨"}
        s["npc;drop=213217"] = {"대변자 브록", "바위금고"}
        s["npc;drop=129208"] = {"공포의 선장 록우드", "보랄러스 공성전"}
        s["npc;drop=213119"] = {"공허 대변자 에리히", "바위금고"}
        s["npc;drop=216320"] = {"응집체", "실타래의 도시"}
        s["npc;drop=128650"] = {"난도질꾼 레드후크", "보랄러스 공성전"}
        s["npc;drop=128651"] = {"하달 다크패덤", "보랄러스 공성전"}
        s["npc;drop=164567"] = {"잉그라 말로크", "티르너 사이드의 안개"}
        s["npc;drop=210156"] = {"스카모락", "바위금고"}
        s["npc;drop=128649"] = {"하사관 베인브릿지", "보랄러스 공성전"}
        s["spell;created=450242"] = {"충만한 절단도끼", "CRAFTING"}
        s["npc;drop=228470"] = {"연합공작 카이베자", "네룹아르 궁전"}
        s["npc;drop=214502"] = {"피결속 공포", "네룹아르 궁전"}
        s["npc;drop=216658"] = {"대접합사 이조", "실타래의 도시"}
        s["npc;drop=163157"] = {"아마스 <수확자>", "죽음의 상흔"}
        s["npc;drop=211087"] = {"대변자 섀도크라운", "새벽인도자호"}
        s["npc;drop=40484"] = {"에루닥스 <지하 군주>", "그림 바톨"}
        s["npc;drop=210108"] = {"토.보.무.전", "바위금고"}
        s["npc;drop=162691"] = {"역병뼈닥이", "죽음의 상흔"}
        s["spell;created=441057"] = {"룬낙인 허리보호띠", "CRAFTING"}
        s["npc;drop=216619"] = {"웅변가 크릭스비즈크 <다섯 번째 가닥>", "실타래의 도시"}
        s["spell;created=450232"] = {"영원벼림 전투검", "CRAFTING"}
        s["npc;drop=215407"] = {"수확자 키카탈", "메아리의 도시 아라카라"}
        s["npc;drop=128652"] = {"비크고스 <심해의 공포>", "보랄러스 공성전"}
        s["spell;created=444070"] = {"솟구치는 아드레날린 죔쇠띠", "CRAFTING"}
        s["spell;created=450231"] = {"영원벼림 장검", "CRAFTING"}
        s["npc;drop=40177"] = {"제련장인 트롱구스", "그림 바톨"}
        s["npc;drop=164517"] = {"트레도바", "티르너 사이드의 안개"}
        s["spell;created=435382"] = {"결속의 고리", "CRAFTING"}
        s["npc;drop=216648"] = {"늑스 <여왕의 송곳니>", "실타래의 도시"}
        s["npc;drop=207207"] = {"공허석 괴수", "부화장"}
        s["spell;created=450235"] = {"충만한 사술검", "CRAFTING"}
        s["spell;created=444197"] = {"방랑자의 횃불", "CRAFTING"}
        s["npc;drop=208743"] = {"블레지콘", "어둠불꽃 동굴"}
        s["npc;drop=210271"] = {"양조장인 알드리르", "잿불맥주 양조장"}
        s["npc;drop=207205"] = {"폭풍수호병 고렌", "부화장"}
        s["npc;drop=218002"] = {"벤크 버즈비 <벌지기>", "잿불맥주 양조장"}
        s["npc;drop=209230"] = {"키리오스", "부화장"}
        s["spell;created=450230"] = {"영원벼림 단검", "CRAFTING"}
        s["spell;created=441066"] = {"문양새김 완갑", "CRAFTING"}
        s["spell;created=441061"] = {"문양새김 건틀릿", "CRAFTING"}
        s["spell;created=447352"] = {"분.해.포. x2", "CRAFTING"}
        s["npc;drop=208478"] = {"볼코로스", "꿈의 희망 아미드랏실"}
        s["spell;created=446940"] = {"축성된 망토", "CRAFTING"}
        s["spell;created=450239"] = {"충만한 미늘창", "CRAFTING"}
        s["spell;created=445355"] = {"빛나는 마법의 홀", "CRAFTING"}
        s["npc;drop=210267"] = {"이파", "잿불맥주 양조장"}
        s["npc;drop=214661"] = {"골디 바론바텀 <최고 양봉 경영자>", "잿불맥주 양조장"}
        s["npc;drop=210153"] = {"밀랍수염 영감", "어둠불꽃 동굴"}
        s["npc;drop=207946"] = {"대장 데일크라이", "신성한 불꽃의 수도원"}
        s["spell;created=446937"] = {"축성된 끌신", "CRAFTING"}
        s["spell;created=444198"] = {"방랑자의 신중한 목발", "CRAFTING"}
        s["spell;created=441058"] = {"룬낙인 완장", "CRAFTING"}
        s["spell;created=441052"] = {"룬낙인 장화", "CRAFTING"}
        s["spell;created=441055"] = {"룬낙인 다리싸개", "CRAFTING"}
        s["spell;created=435385"] = {"토석인 장인 정신의 아뮬렛", "CRAFTING"}
        s["spell;created=450237"] = {"충만한 얼굴분쇄기", "CRAFTING"}
        s["spell;created=450238"] = {"충만한 클레이모어", "CRAFTING"}
        s["npc;drop=207939"] = {"남작 브라운파이크", "신성한 불꽃의 수도원"}
        s["npc;drop=210797"] = {"어둠의 존재", "어둠불꽃 동굴"}
        s["spell;created=441053"] = {"룬낙인 손아귀", "CRAFTING"}
        s["spell;created=446938"] = {"축성된 소매장식", "CRAFTING"}
        s["spell;created=444199"] = {"방랑자의 도약하는 지휘봉", "CRAFTING"}
        s["spell;created=450224"] = {"영원벼림 투구", "CRAFTING"}
        s["spell;created=450234"] = {"영원벼림 거대도끼", "CRAFTING"}
        s["spell;created=435384"] = {"토석인 장인 정신의 반지", "CRAFTING"}
        s["spell;created=441060"] = {"문양새김 디딤장화", "CRAFTING"}
        s["npc;sold=227003"] = {"키르잘 <진귀품 수집가>", "실타래의 도시"}
        s["object;contained=413590"] = {"풍요로운 금고", "공포의 무저갱"}
        s["spell;created=441065"] = {"문양새김 결속띠", "CRAFTING"}
        s["npc;drop=215657"] = {"포식자 울그락스", "네룹아르 궁전"}
        s["object;contained=413563"] = {"육중한 보관함", "일몰의 성소"}
        s["npc;drop=202318"] = {"대응반 감시자", "자랄레크 동굴"}
        s["npc;drop=203355"] = {"대장 레이칼", "자랄레크 동굴"}
        s["spell;created=427185"] = {"알가르 연금술사 돌", "CRAFTING"}
        s["npc;sold=219222"] = {"랄란디 <정복 병참장교>", "도르노갈"}
        s["item:contained=229354"] = {"알가르 모험가의 보관함", ""}
        s["item:contained=229129"] = {"구렁 탐험가의 전리품 보관함", ""}
        s["quest;reward=78636"] = {"광산 탈환", ""}
        s["quest;reward=79342"] = {"떠나는 길에", ""}
        s["quest;reward=78232"] = {"퇴고의 퇴고", ""}
        s["spell;created=455393"] = {"광휘", ""}
        s["spell;created=455394"] = {"승천", ""}
        s["spell;created=455392"] = {"공생", ""}
        s["spell;created=455391"] = {"생기", ""}
        s["npc;drop=226305"] = {"[Emperor Dagran Thaurissan]", "검은바위 나락"}
        s["npc;drop=226306"] = {"[Golem Lord Argelmach]", "검은바위 나락"}
        s["npc;drop=226315"] = {"[Lord Roccor]", "검은바위 나락"}
        s["npc;drop=217489"] = {"아눕아라쉬 <일천 개의 상흔>", "네룹아르 궁전"}
        s["npc;drop=223839"] = {"여왕 근위병 게자", "네룹아르 궁전"}
        s["spell;created=447314"] = {"근면한 총명함 촉진기", "CRAFTING"}
        s["spell;created=446939"] = {"축성된 장식끈", "CRAFTING"}
        s["spell;created=450229"] = {"영원벼림 찌르개", "CRAFTING"}
        s["npc;drop=229992"] = {"스탈라그나로그", "세이렌의 섬"}
        s["npc;sold=231824"] = {"[Kari Bridgeblaster]", "언더마인"}
        s["npc;drop=226396"] = {"[Swampface]", "작전명: 수문"}
        s["npc;drop=229181"] = {"[Flarendo]", "언더마인 해방전선"}
        s["npc;drop=144246"] = {"쿠.조.", "작전명: 메카곤"}
        s["npc;drop=241526"] = {"[Chrome King Gallywix]", "언더마인 해방전선"}
        s["npc;drop=228458"] = {"[One-Armed Bandit]", "언더마인 해방전선"}
        s["npc;drop=228652"] = {"[Rik Reverb]", "언더마인 해방전선"}
        s["npc;drop=164451"] = {"참수자 데시아", "고통의 투기장"}
        s["npc;drop=129227"] = {"아제로크", "왕노다지 광산!!"}
        s["npc;drop=225821"] = {"[The Geargrinder]", "언더마인 해방전선"}
        s["npc;drop=230583"] = {"[Sprocketmonger Lockenstock]", "언더마인 해방전선"}
        s["npc;drop=229953"] = {"[Mug'Zee]", "언더마인 해방전선"}
        s["npc;drop=230322"] = {"[Stix Bunkjunker]", "언더마인 해방전선"}
        s["npc;drop=131227"] = {"모굴 라즈덩크", "왕노다지 광산!!"}
        s["npc;drop=129231"] = {"릭사 플럭스플레임 <수석 과학자>", "왕노다지 광산!!"}
        s["npc;drop=162317"] = {"선혈토막", "고통의 투기장"}
        s["npc;drop=226404"] = {"기즐 기가잽", "작전명: 수문"}
        s["npc;drop=165946"] = {"무한의 여제 모르드레타", "고통의 투기장"}
        s["npc;drop=226403"] = {"[Keeza Quickfuse]", "작전명: 수문"}
        s["npc;drop=132713"] = {"모굴 라즈덩크", "왕노다지 광산!!"}
        s["npc;drop=230828"] = {"[Chief Foreman Gutso]", "언더마인"}
        s["npc;drop=230800"] = {"[Slugger the Smart]", "언더마인"}
        s["npc;drop=230934"] = {"[Ratspit]", "언더마인"}
        s["npc;drop=152619"] = {"왕 메카곤", "작전명: 메카곤"}
        s["npc;drop=150397"] = {"왕 메카곤", "작전명: 메카곤"}
        s["npc;drop=129214"] = {"동전 투입식 군중 난타기", "왕노다지 광산!!"}
        s["npc;drop=144248"] = {"수석 기계공 스파크플럭스", "작전명: 메카곤"}
        s["spell;created=447315"] = {"과부하된 발상 생성기", "CRAFTING"}
        s["npc;drop=208745"] = {"양초왕", "어둠불꽃 동굴"}
        s["npc;drop=162329"] = {"몰락하지 않은 자 자브", "고통의 투기장"}
        s["npc;drop=226398"] = {"[Big M.O.M.M.A.]", "작전명: 수문"}
        s["quest;reward=83125"] = {"", "줄다자르"}
        s["object;contained=476068"] = {"[Papa's Prized Putter]", "언더마인"}
        s["npc;drop=144244"] = {"백금 난타로봇", "작전명: 메카곤"}
        s["spell;created=473400"] = {"주문 시전 맞춤 조정", "CRAFTING"}
        s["npc;drop=162309"] = {"쿨타로크", "고통의 투기장"}
        s["npc;drop=207940"] = {"수도원장 머프레이", "신성한 불꽃의 수도원"}
        s["npc;drop=150222"] = {"진창오물", "작전명: 메카곤"}
        s["npc;drop=230946"] = {"[V.V. Goosworth]", "언더마인"}
        s["npc;drop=150159"] = {"왕 고바막", "작전명: 메카곤"}
        s["npc;drop=231310"] = {"다크퓨즈 침전물", "언더마인"}
        s["npc;drop=229288"] = {"왕 불꽃원한 <플레렌도의 담당자>", "언더마인 해방전선"}
        s["npc;drop=229284"] = {"구크 붐도그 <음식물 행상인>", "언더마인 해방전선"}
        s["object;contained=507768"] = {"버려진 고블린 화폐 더미", "채굴지 9호"}
        s["spell;created=441051"] = {"룬낙인 튜닉", "CRAFTING"}
        s["npc;drop=237861"] = {"Fractillus <[The Shatterer]>", "마나괴철로 종극점"}
        s["npc;drop=175646"] = {"우.정.국.장.", "미지의 시장 타자베쉬"}
        s["npc;drop=156827"] = {"에첼론", "속죄의 전당"}
        s["npc;drop=177269"] = {"소레아 <소 중개단>", "미지의 시장 타자베쉬"}
        s["npc;drop=234933"] = {"타바트 <가혹한 자>", "생태지구 알다니"}
        s["spell;created=1249111"] = {"붕대 받기", "CRAFTING"}
        s["npc;drop=165408"] = {"할키아스 <죄악에 물든 거수>", "속죄의 전당"}
        s["npc;drop=175663"] = {"힐브란데 <수호자의 칼>", "미지의 시장 타자베쉬"}
        s["npc;drop=164185"] = {"에첼론", "속죄의 전당"}
        s["npc;drop=165410"] = {"대심판관 알리즈", "속죄의 전당"}
        s["npc;drop=176556"] = {"알크룩스 <게걸먹보>", "미지의 시장 타자베쉬"}
        s["npc;drop=175546"] = {"시간선장 후크테일", "미지의 시장 타자베쉬"}
        s["npc;drop=175806"] = {"소아즈미", "미지의 시장 타자베쉬"}
        s["npc;drop=176563"] = {"조그론", "미지의 시장 타자베쉬"}
        s["npc;drop=176705"] = {"벤자 골드퓨즈", "미지의 시장 타자베쉬"}
        s["npc;drop=234893"] = {"아즈히카르", "생태지구 알다니"}
        s["npc;drop=164218"] = {"시종장", "속죄의 전당"}
        s["npc;drop=175616"] = {"조펙스 <파수꾼>", "미지의 시장 타자베쉬"}
        s["spell;created=450223"] = {"영원벼림 파수 방패", "CRAFTING"}
        s["npc;drop=244752"] = {"연합공작 카이베자", "공허서슬 성역"}
        s["npc;drop=231981"] = {"모래의 아귀", "크아레쉬"}
        s["npc;drop=234845"] = {"스타브스 <정신교란자>", "크아레쉬"}
        s["object;contained=416265"] = {"도둑맞은 보관함", "공포의 무저갱"}
        s["npc;drop=247989"] = {"제련직공 아라즈", "마나괴철로 종극점"}
        s["npc;drop=233814"] = {"흐름망 파수꾼", "마나괴철로 종극점"}
        s["npc;drop=237661"] = {"아다루스 더스크블레이즈", "마나괴철로 종극점"}
        s["npc;drop=233815"] = {"룸이타르", "마나괴철로 종극점"}
        s["npc;drop=237763"] = {"연합왕 살라다르", "마나괴철로 종극점"}
        s["npc;drop=233824"] = {"디멘시우스", "마나괴철로 종극점"}
        s["npc;drop=233816"] = {"영혼술사 나진드리", "마나괴철로 종극점"}
        s["npc;drop=235853"] = {"차원문 감시자", "마나괴철로 종극점"}
        s["npc;drop=239454"] = {"암흑마법사 자두스", "마나괴철로 종극점"}
        s["npc;sold=248303"] = {"자흐란 <구렁 장신구>", "채굴지 9호"}
        s["quest;reward=91009"] = {"고강도 정보 저장소", "도르노갈"}
        s["spell;created=441063"] = {"문양새김 다리가리개", "CRAFTING"}
    end

    function SpecBisTooltip:TranslationptBR()
        s["npc;drop=223779"] = {"Anub'arash <As Mil Cicatrizes>", "Palácio Nerub-ar"}
        s["spell;created=450226"] = {"Avambraços Semperforja", "CRAFTING"}
        s["spell;created=450222"] = {"Correão Semperforja", "CRAFTING"}
        s["npc;drop=219778"] = {"Rainha Ansurek", "Palácio Nerub-ar"}
        s["npc;drop=162693"] = {"Nalthor, o Senhor da Geada", "A Chaga Necrótica"}
        s["npc;drop=162689"] = {"Cirurgião Suturítico", "A Chaga Necrótica"}
        s["npc;drop=219853"] = {"Sikran <Capitão dos Sureki>", "Palácio Nerub-ar"}
        s["spell;created=450220"] = {"Escarpes Semperforja", "CRAFTING"}
        s["npc;drop=214506"] = {"Prolemante Ovi'nax", "Palácio Nerub-ar"}
        s["npc;drop=164501"] = {"Chamabruma", "Brumas de Tirna Scithe"}
        s["npc;drop=40319"] = {"Drahga Queimassombra <Mensageiro do Martelo do Crepúsculo>", "Grim Batol"}
        s["npc;drop=215405"] = {"Anub'zekt <Zanguarda>", "Ara-Kara, a Cidade dos Ecos"}
        s["npc;drop=39625"] = {"General Umbriss <Servo do Asa da Morte>", "Grim Batol"}
        s["npc;drop=213217"] = {"Mensageiro Brokk", "Abóboda de Pedra"}
        s["npc;drop=129208"] = {"Terrível Capitã Madeira", "Cerco de Boralus"}
        s["npc;drop=213119"] = {"Voz do Caos Eirich", "Abóboda de Pedra"}
        s["npc;drop=216320"] = {"A Coaglamação", "Cidade das Tramas"}
        s["npc;drop=128650"] = {"Gancho Estraçalho", "Cerco de Boralus"}
        s["npc;drop=128651"] = {"Hadal Abismo Negro", "Cerco de Boralus"}
        s["npc;drop=128649"] = {"Sargento Belponte", "Cerco de Boralus"}
        s["spell;created=450242"] = {"Fatiador Carregado", "CRAFTING"}
        s["npc;drop=228470"] = {"Princesa do Nexus Ky'veza", "Palácio Nerub-ar"}
        s["npc;drop=214502"] = {"O Terror Sanguino", "Palácio Nerub-ar"}
        s["npc;drop=216658"] = {"Izo, a Grande Entrançadora", "Cidade das Tramas"}
        s["npc;drop=163157"] = {"Amarth <O Ceifador>", "A Chaga Necrótica"}
        s["npc;drop=211087"] = {"Mensageira Coronumbra", "Alvorada"}
        s["npc;drop=40484"] = {"Erúdax <O Duque do Abismo>", "Grim Batol"}
        s["npc;drop=210108"] = {"E.D.N.A.", "Abóboda de Pedra"}
        s["npc;drop=162691"] = {"Pragosso", "A Chaga Necrótica"}
        s["spell;created=441057"] = {"Cintel com Marcações Rúnicas", "CRAFTING"}
        s["npc;drop=216619"] = {"Orador Krix'vizk <O Quinto Fio>", "Cidade das Tramas"}
        s["spell;created=450232"] = {"Glaive de Guerra Semperforja", "CRAFTING"}
        s["npc;drop=215407"] = {"Ki'katal, a Ceifadora", "Ara-Kara, a Cidade dos Ecos"}
        s["npc;drop=128652"] = {"Viq'Goth <Terror das Profundezas>", "Cerco de Boralus"}
        s["spell;created=444070"] = {"Fecho do Surto Adrenal", "CRAFTING"}
        s["spell;created=450231"] = {"Espada Longa Semperforja", "CRAFTING"}
        s["npc;drop=40177"] = {"Mestre Forjador Throngus", "Grim Batol"}
        s["spell;created=435382"] = {"Vínculo da Vinculação", "CRAFTING"}
        s["npc;drop=216648"] = {"Nx <Presa da Rainha>", "Cidade das Tramas"}
        s["npc;drop=207207"] = {"Monstruosidade da Pedra do Caos", "O Viveiro"}
        s["spell;created=450235"] = {"Bagateira Carregada", "CRAFTING"}
        s["spell;created=444197"] = {"Tocha do Vagabundo", "CRAFTING"}
        s["npc;drop=208743"] = {"Brasikon", "Fenda Chamanegra"}
        s["npc;drop=210271"] = {"Mestre Fermentador Aldryr", "Hidromelaria Cinzagris"}
        s["npc;drop=207205"] = {"Tempesguarda Gorren", "O Viveiro"}
        s["npc;drop=218002"] = {"Apílio Abelhudo <Apicultor>", "Hidromelaria Cinzagris"}
        s["spell;created=450230"] = {"Adaga Semperforja", "CRAFTING"}
        s["spell;created=441066"] = {"Avambraços Gravados com Glifos", "CRAFTING"}
        s["spell;created=441061"] = {"Manoplas Gravadas com Glifos", "CRAFTING"}
        s["spell;created=447352"] = {"P0U x2", "CRAFTING"}
        s["spell;created=446940"] = {"Manto Consagrado", "CRAFTING"}
        s["spell;created=450239"] = {"Alabarda Carregada", "CRAFTING"}
        s["spell;created=445355"] = {"Cetro de Magias Radiantes", "CRAFTING"}
        s["npc;drop=214661"] = {"Doura de Ricalhaz Nababa <Apoisidente>", "Hidromelaria Cinzagris"}
        s["npc;drop=210153"] = {"Velho Barbacera", "Fenda Chamanegra"}
        s["npc;drop=207946"] = {"Capitão Bradano", "Priorado da Chama Sagrada"}
        s["spell;created=446937"] = {"Sapatilhas Consagradas", "CRAFTING"}
        s["spell;created=444198"] = {"Bengala Cautelosa do Vagabundo", "CRAFTING"}
        s["spell;created=441058"] = {"Embraces com Marcações Rúnicas", "CRAFTING"}
        s["spell;created=441052"] = {"Pisantes com Marcações Rúnicas", "CRAFTING"}
        s["spell;created=441055"] = {"Culotes com Marcações Rúnicas", "CRAFTING"}
        s["spell;created=435385"] = {"Amuleto da Confecção Terrana", "CRAFTING"}
        s["spell;created=450237"] = {"Quebra-fuça Carregado", "CRAFTING"}
        s["spell;created=450238"] = {"Espadão Carregado", "CRAFTING"}
        s["npc;drop=207939"] = {"Barão Hastanha", "Priorado da Chama Sagrada"}
        s["npc;drop=210797"] = {"A Escuridão", "Fenda Chamanegra"}
        s["spell;created=441053"] = {"Agarres com Marcações Rúnicas", "CRAFTING"}
        s["spell;created=446938"] = {"Manilhas Consagradas", "CRAFTING"}
        s["spell;created=444199"] = {"Bastão Vinculante do Vagabundo", "CRAFTING"}
        s["spell;created=450224"] = {"Elmo Semperforja", "CRAFTING"}
        s["spell;created=450234"] = {"Machadão Semperforja", "CRAFTING"}
        s["spell;created=435384"] = {"Anel da Confecção Terrana", "CRAFTING"}
        s["spell;created=441060"] = {"Pisoteadores Gravados com Glifos", "CRAFTING"}
        s["npc;sold=227003"] = {"Kir'xal <Colecionadora de Curiosidades>", "Cidade das Tramas"}
        s["object;contained=413590"] = {"Cofre Abundante", "Fosso do Pavor"}
        s["spell;created=441065"] = {"Amarra Gravada com Glifos", "CRAFTING"}
        s["npc;drop=215657"] = {"Ulgrax, o Devorador", "Palácio Nerub-ar"}
        s["object;contained=413563"] = {"Baú Pesado", "Caverna Micomante"}
        s["npc;drop=202318"] = {"Vigia da Equipe de Resposta", "Caverna Zaralek"}
        s["npc;drop=203355"] = {"Capitã Reykal", "Caverna Zaralek"}
        s["spell;created=427185"] = {"Pedra do Alquimista Algari", "CRAFTING"}
        s["npc;sold=219222"] = {"Lalandi <Intendente de Dominação>", "Dornogal"}
        s["item:contained=229354"] = {"Baú do Aventureiro Algari", ""}
        s["item:contained=229129"] = {"Baú de Espólios do Imersor", ""}
        s["quest;reward=78636"] = {"Retomada das minas", ""}
        s["quest;reward=79342"] = {"E ele se vai", ""}
        s["quest;reward=78232"] = {"Reprogramando o reprogramado", ""}
        s["spell;created=455393"] = {"Resplendor", ""}
        s["spell;created=455394"] = {"Ascensão", ""}
        s["spell;created=455392"] = {"Simbiose", ""}
        s["spell;created=455391"] = {"Vivacidade", ""}
        s["npc;drop=226305"] = {"[Emperor Dagran Thaurissan]", "Abismo Rocha Negra"}
        s["npc;drop=226306"] = {"[Golem Lord Argelmach]", "Abismo Rocha Negra"}
        s["npc;drop=226315"] = {"[Lord Roccor]", "Abismo Rocha Negra"}
        s["npc;sold=224270"] = {"Ip'xal <Provedora do Herói>", "Cidade das Tramas"}
        s["npc;drop=217489"] = {"Anub'arash <As Mil Cicatrizes>", "Palácio Nerub-ar"}
        s["npc;drop=223839"] = {"Guarda da Rainha Ge'zah", "Palácio Nerub-ar"}
        s["spell;created=447314"] = {"Facilitador de Inteligência Acadêmica", "CRAFTING"}
        s["spell;created=446939"] = {"Cordão Consagrado", "CRAFTING"}
        s["spell;created=450229"] = {"Apunhalador Semperforja", "CRAFTING"}
        s["npc;drop=229992"] = {"Estalagnarok", "Ilha das Sirenas"}
        s["npc;sold=231824"] = {"[Kari Bridgeblaster]", "Inframina"}
        s["npc;drop=226396"] = {"[Swampface]", "Operação: Comporta"}
        s["npc;drop=229181"] = {"[Flarendo]", "Libertação da Inframina"}
        s["npc;drop=241526"] = {"[Chrome King Gallywix]", "Libertação da Inframina"}
        s["npc;drop=228458"] = {"[One-Armed Bandit]", "Libertação da Inframina"}
        s["npc;drop=228652"] = {"[Rik Reverb]", "Libertação da Inframina"}
        s["npc;drop=164451"] = {"Déssia, a Decapitadora", "Teatro da Dor"}
        s["npc;drop=225821"] = {"[The Geargrinder]", "Libertação da Inframina"}
        s["npc;drop=230583"] = {"[Sprocketmonger Lockenstock]", "Libertação da Inframina"}
        s["npc;drop=229953"] = {"[Mug'Zee]", "Libertação da Inframina"}
        s["npc;drop=230322"] = {"[Stix Bunkjunker]", "Libertação da Inframina"}
        s["npc;drop=131227"] = {"Dalberto Frustrus", "MEGAMINA!!!"}
        s["npc;drop=129231"] = {"Rixxa Fazfaísca <Cientista-chefe>", "MEGAMINA!!!"}
        s["npc;drop=162317"] = {"Estripança", "Teatro da Dor"}
        s["npc;drop=226404"] = {"Guizol Gigazap", "Operação: Comporta"}
        s["npc;drop=165946"] = {"Mordretha, a Imperatriz Infinda", "Teatro da Dor"}
        s["npc;drop=226403"] = {"[Keeza Quickfuse]", "Operação: Comporta"}
        s["npc;drop=132713"] = {"Barão dos Negócios Frustrus", "MEGAMINA!!!"}
        s["npc;drop=230828"] = {"[Chief Foreman Gutso]", "Inframina"}
        s["npc;drop=230800"] = {"[Slugger the Smart]", "Inframina"}
        s["npc;drop=230934"] = {"[Ratspit]", "Inframina"}
        s["npc;drop=152619"] = {"Rei Gnomecan", "Operação: Gnomecan"}
        s["npc;drop=150397"] = {"Rei Gnomecan", "Operação: Gnomecan"}
        s["npc;drop=129214"] = {"Espanca-gente de Ficha", "MEGAMINA!!!"}
        s["npc;drop=144248"] = {"Maquinista-chefe Fluichispa", "Operação: Gnomecan"}
        s["spell;created=447315"] = {"Gerador de Ideias Turbinado", "CRAFTING"}
        s["npc;drop=208745"] = {"O Rei da Vela", "Fenda Chamanegra"}
        s["npc;drop=162329"] = {"Xav, o Não-caído", "Teatro da Dor"}
        s["npc;drop=226398"] = {"[Big M.O.M.M.A.]", "Operação: Comporta"}
        s["quest;reward=83125"] = {"", "Zuldazar"}
        s["object;contained=476068"] = {"[Papa's Prized Putter]", "Inframina"}
        s["npc;drop=144244"] = {"Esbordoador de Platina", "Operação: Gnomecan"}
        s["spell;created=473400"] = {"Reconfigurando para Lançamento de Feitiços", "CRAFTING"}
        s["npc;drop=207940"] = {"Priora Orália", "Priorado da Chama Sagrada"}
        s["npc;drop=150222"] = {"Visgueiro", "Operação: Gnomecan"}
        s["npc;drop=230946"] = {"[V.V. Goosworth]", "Inframina"}
        s["npc;drop=150159"] = {"Rei Gobbamak", "Operação: Gnomecan"}
        s["npc;drop=231310"] = {"Precipitante Sombrafuso", "Inframina"}
        s["npc;drop=229288"] = {"Rei Flamódio <Empresário de Flarendo>", "Libertação da Inframina"}
        s["npc;drop=229284"] = {"Guk Bumcão <Falcoeiro de Meleca>", "Libertação da Inframina"}
        s["object;contained=507768"] = {"Pilha de Moedas Goblínicas Descartadas", "Sítio de Escavação 9"}
        s["spell;created=441051"] = {"Túnica com Marcações Rúnicas", "CRAFTING"}
        s["npc;drop=237861"] = {"Fractillus <[The Shatterer]>", "Manaforja Ômega"}
        s["npc;drop=175646"] = {"Chefe do C.O.R.R.E.I.O", "Tazavesh, o Mercado Oculto"}
        s["npc;drop=156827"] = {"Escalon", "Salões da Expiação"}
        s["npc;drop=177269"] = {"So'leah <Cartel So>", "Tazavesh, o Mercado Oculto"}
        s["npc;drop=234933"] = {"Taah'bat <O Incansável>", "Ecodomo Al'dani"}
        s["spell;created=1249111"] = {"Receber Faixas", "CRAFTING"}
        s["npc;drop=165408"] = {"Hálkias <Golias Maculado pelo Pecado>", "Salões da Expiação"}
        s["npc;drop=175663"] = {"Hylbrande <Espada dos Guardiões>", "Tazavesh, o Mercado Oculto"}
        s["npc;drop=164185"] = {"Escalon", "Salões da Expiação"}
        s["npc;drop=165410"] = {"Alta-adjudicadora Alee", "Salões da Expiação"}
        s["npc;drop=176556"] = {"Alcruux <O Glutão>", "Tazavesh, o Mercado Oculto"}
        s["npc;drop=247283"] = {"Escriba d'Alma", "Ecodomo Al'dani"}
        s["npc;drop=175546"] = {"Capitã Temporal Rabo-de-gancho", "Tazavesh, o Mercado Oculto"}
        s["npc;drop=176705"] = {"Vina Fusauro", "Tazavesh, o Mercado Oculto"}
        s["npc;drop=164218"] = {"Lorde Camarista", "Salões da Expiação"}
        s["npc;drop=175616"] = {"Zo'phex <A Sentinela>", "Tazavesh, o Mercado Oculto"}
        s["spell;created=450223"] = {"Defensor Semperforja", "CRAFTING"}
        s["npc;drop=244752"] = {"Princesa do Nexus Ky'veza", "Santuário Navalha do Caos"}
        s["npc;drop=231981"] = {"Bocarra das Areias", "K'aresh"}
        s["npc;drop=234845"] = {"Sthaarbs <o Espiramente>", "K'aresh"}
        s["object;contained=416265"] = {"Baú Furtado", "Fosso do Pavor"}
        s["npc;drop=247989"] = {"Tece-forja Araz", "Manaforja Ômega"}
        s["npc;drop=233814"] = {"Sentinela do Plexo", "Manaforja Ômega"}
        s["npc;drop=237661"] = {"Adarus Gumúmbrio", "Manaforja Ômega"}
        s["npc;drop=233815"] = {"Fian'dhar", "Manaforja Ômega"}
        s["npc;drop=237763"] = {"Rei do Nexus Salhadaar", "Manaforja Ômega"}
        s["npc;drop=233816"] = {"Atalmas Naazindhri", "Manaforja Ômega"}
        s["npc;drop=235853"] = {"Vigia do Pórtico", "Manaforja Ômega"}
        s["npc;drop=239454"] = {"Neromago Zadus", "Manaforja Ômega"}
        s["npc;sold=248303"] = {"Zah'ran <[Delve Trinkets]>", "Sítio de Escavação 9"}
        s["quest;reward=91009"] = {"Dispositivo de Informações Seguras Confiável", "Dornogal"}
        s["spell;created=441063"] = {"Cuísses Gravadas com Glifos", "CRAFTING"}
    end

    function SpecBisTooltip:TranslationruRU()
        s["npc;drop=224552"] = {"Раша'нан", "Неруб'арский дворец"}
        s["npc;drop=223779"] = {"Ануб'араш <Меченный тысячей шрамов>", "Неруб'арский дворец"}
        s["npc;sold=224270"] = {"Ип'ксал", "Город Нитей"}
        s["spell;created=450226"] = {"Выкованные навеки тяжелые наручи", "CRAFTING"}
        s["spell;created=450222"] = {"Выкованный навеки большой пояс", "CRAFTING"}
        s["npc;drop=219778"] = {"Королева Ансурек", "Неруб'арский дворец"}
        s["npc;drop=162693"] = {"Налтор Криомант", "Смертельная тризна"}
        s["npc;drop=213179"] = {"Аванокс", "Ара-Кара, Город Отголосков"}
        s["npc;drop=162689"] = {"Хирург Трупошов", "Смертельная тризна"}
        s["npc;drop=219853"] = {"Сикран <Капитан суреки>", "Неруб'арский дворец"}
        s["spell;created=450220"] = {"Выкованные навеки башмаки", "CRAFTING"}
        s["npc;drop=214506"] = {"Исказитель яиц Ови'накс", "Неруб'арский дворец"}
        s["npc;drop=164501"] = {"Призывательница Туманов", "Туманы Тирна Скитта"}
        s["npc;drop=40319"] = {"Драгх Горячий Мрак <Курьер Сумеречного Молота>", "Грим Батол"}
        s["npc;drop=215405"] = {"Ануб'зект <Страж роя>", "Ара-Кара, Город Отголосков"}
        s["npc;drop=211089"] = {"Ануб'иккадж", "Сияющий Рассвет"}
        s["npc;drop=39625"] = {"Генерал Умбрисс <Служитель Смертокрыла>", "Грим Батол"}
        s["npc;drop=213217"] = {"Глашатай Брокк", "Каменный Свод"}
        s["npc;drop=129208"] = {"Жуткий капитан Локвуд", "Осада Боралуса"}
        s["npc;drop=213119"] = {"Вестник Бездны Эйрих", "Каменный Свод"}
        s["npc;drop=216320"] = {"Сгустолиция", "Город Нитей"}
        s["npc;drop=128650"] = {"Головорез Краснокрюк", "Осада Боралуса"}
        s["npc;drop=128651"] = {"Хадал Черная Бездна", "Осада Боралуса"}
        s["npc;drop=164567"] = {"Ингра Малох", "Туманы Тирна Скитта"}
        s["npc;drop=210156"] = {"Скарморак", "Каменный Свод"}
        s["npc;drop=128649"] = {"Сержант Бейнбридж", "Осада Боралуса"}
        s["spell;created=450242"] = {"Заряженный рассекатель", "CRAFTING"}
        s["npc;drop=228470"] = {"Принцесса Нексуса Ки'веза", "Неруб'арский дворец"}
        s["npc;drop=214502"] = {"Скованный кровью ужас", "Неруб'арский дворец"}
        s["npc;drop=216658"] = {"Изо Великая Сращивательница", "Город Нитей"}
        s["npc;drop=163157"] = {"Амарт <Жнец>", "Смертельная тризна"}
        s["npc;drop=211087"] = {"Проповедница Темная Корона", "Сияющий Рассвет"}
        s["npc;drop=40484"] = {"Эрудакс <Повелитель Глубин>", "Грим Батол"}
        s["npc;drop=210108"] = {"ЗАЗУ", "Каменный Свод"}
        s["npc;drop=162691"] = {"Чумокост", "Смертельная тризна"}
        s["spell;created=441057"] = {"Боевой пояс с руническим клеймом", "CRAFTING"}
        s["npc;drop=216619"] = {"Оратор Крикс'визк <Пятая Нить>", "Город Нитей"}
        s["spell;created=450232"] = {"Выкованный навеки боевой клинок", "CRAFTING"}
        s["npc;drop=215407"] = {"Ки'катал Жница", "Ара-Кара, Город Отголосков"}
        s["npc;drop=128652"] = {"Вик'Гот <Кошмар глубин>", "Осада Боралуса"}
        s["spell;created=444070"] = {"Застежка выброса адреналина", "CRAFTING"}
        s["spell;created=450231"] = {"Выкованный навеки длинный меч", "CRAFTING"}
        s["npc;drop=40177"] = {"Начальник кузни Тронг", "Грим Батол"}
        s["npc;drop=164517"] = {"Тред'ова", "Туманы Тирна Скитта"}
        s["spell;created=435382"] = {"Узы связи", "CRAFTING"}
        s["npc;drop=216648"] = {"Нкс <Клык королевы>", "Город Нитей"}
        s["npc;drop=207207"] = {"Чудище камня Бездны", "Гнездовье"}
        s["spell;created=450235"] = {"Заряженный колдовской меч", "CRAFTING"}
        s["spell;created=444197"] = {"Факел бродяги", "CRAFTING"}
        s["npc;drop=208743"] = {"Пламекон", "Расселина Темного Пламени"}
        s["npc;drop=210271"] = {"Хмелевар Алдрир", "Искроварня"}
        s["npc;drop=207205"] = {"Бурестраж Горрен", "Гнездовье"}
        s["npc;drop=218002"] = {"Бенк Жужжикс <Пчеловод>", "Искроварня"}
        s["npc;drop=209230"] = {"Кириосс", "Гнездовье"}
        s["spell;created=450230"] = {"Выкованный навеки кинжал", "CRAFTING"}
        s["spell;created=441066"] = {"Гравированные символами тяжелые наручи", "CRAFTING"}
        s["spell;created=441061"] = {"Гравированные символами рукавицы", "CRAFTING"}
        s["spell;created=447352"] = {"ПИФ-П4Ф", "CRAFTING"}
        s["npc;drop=208478"] = {"Вулкаросс", "Амирдрассил, Надежда Сна"}
        s["spell;created=446940"] = {"Освященный плащ", "CRAFTING"}
        s["spell;created=450239"] = {"Заряженная алебарда", "CRAFTING"}
        s["spell;created=445355"] = {"Скипетр сияющей магии", "CRAFTING"}
        s["npc;drop=210267"] = {"И'па", "Искроварня"}
        s["npc;drop=214661"] = {"Голди Барондон <Надзирательница медоварни>", "Искроварня"}
        s["npc;drop=210153"] = {"Старый Воскобород", "Расселина Темного Пламени"}
        s["npc;drop=207946"] = {"Капитан Дейлкрай", "Приорат Священного Пламени"}
        s["spell;created=446937"] = {"Освященные туфли", "CRAFTING"}
        s["spell;created=444198"] = {"Аккуратная трость бродяги", "CRAFTING"}
        s["spell;created=441058"] = {"Поручи с руническим клеймом", "CRAFTING"}
        s["spell;created=441052"] = {"Тяжелые ботинки с руническим клеймом", "CRAFTING"}
        s["spell;created=441055"] = {"Бриджи с руническим клеймом", "CRAFTING"}
        s["spell;created=435385"] = {"Амулет мастерства земельников", "CRAFTING"}
        s["spell;created=450237"] = {"Заряженный разбиватель шлемов", "CRAFTING"}
        s["spell;created=450238"] = {"Заряженный клеймор", "CRAFTING"}
        s["npc;drop=207939"] = {"Барон Браунпайк", "Приорат Священного Пламени"}
        s["npc;drop=210797"] = {"Тьма", "Расселина Темного Пламени"}
        s["spell;created=441053"] = {"Захваты с руническим клеймом", "CRAFTING"}
        s["spell;created=446938"] = {"Освященные манжеты", "CRAFTING"}
        s["spell;created=444199"] = {"Ограничивающий жезл бродяги", "CRAFTING"}
        s["spell;created=450224"] = {"Выкованный навеки шлем", "CRAFTING"}
        s["spell;created=450234"] = {"Выкованный навеки большой топор", "CRAFTING"}
        s["spell;created=435384"] = {"Кольцо мастерства земельников", "CRAFTING"}
        s["spell;created=441060"] = {"Гравированные символами высокие ботинки", "CRAFTING"}
        s["npc;sold=227003"] = {"Кир'ксал <Сборщица диковинок>", "Город Нитей"}
        s["object;contained=413590"] = {"Богатый сундук", "Яма Ужаса"}
        s["spell;created=441065"] = {"Гравированная символами обвязка", "CRAFTING"}
        s["npc;drop=215657"] = {"Улгракс Пожиратель", "Неруб'арский дворец"}
        s["object;contained=413563"] = {"Тяжелый ларь", "Пещера микомантов"}
        s["npc;drop=202318"] = {"Дозорная группы реагирования", "Пещера Заралек"}
        s["npc;drop=203355"] = {"Капитан Рэйкал", "Пещера Заралек"}
        s["item:contained=229354"] = {"Тайник алгарийского искателя приключений", ""}
        s["item:contained=229129"] = {"Тайник с трофеями из вылазок", ""}
        s["quest;reward=78636"] = {"Битва за рудники", ""}
        s["quest;reward=79342"] = {"Расставание", ""}
        s["quest;reward=78232"] = {"Переписывая переписанное", ""}
        s["spell;created=455393"] = {"Сияние", ""}
        s["spell;created=455394"] = {"Вознесение", ""}
        s["spell;created=455392"] = {"Симбиоз", ""}
        s["spell;created=427185"] = {"Алгарийский алхимический камень", "CRAFTING"}
        s["spell;created=455391"] = {"Бодрость", ""}
        s["npc;sold=219222"] = {"Лаланди <Награды за очки завоевания>", "Дорногал"}
        s["npc;drop=226305"] = {"[Emperor Dagran Thaurissan]", "Глубины Черной горы"}
        s["npc;drop=226306"] = {"[Golem Lord Argelmach]", "Глубины Черной горы"}
        s["npc;drop=226315"] = {"[Lord Roccor]", "Глубины Черной горы"}
        s["npc;drop=217489"] = {"Ануб'араш <Меченный тысячей шрамов>", "Неруб'арский дворец"}
        s["npc;drop=223839"] = {"Стражник королевы Ге'за", "Неруб'арский дворец"}
        s["spell;created=447314"] = {"Ускоритель мыслительного процесса", "CRAFTING"}
        s["spell;created=446939"] = {"Освященный шнурованный ремень", "CRAFTING"}
        s["spell;created=450229"] = {"Выкованный навеки пронзатель", "CRAFTING"}
        s["npc;drop=229992"] = {"Сталагнарос", "Остров Сирен"}
        s["npc;sold=231824"] = {"[Kari Bridgeblaster]", "Нижняя Шахта"}
        s["npc;drop=226396"] = {"[Swampface]", "Операция: шлюз"}
        s["npc;drop=229181"] = {"[Flarendo]", "Освобождение Нижней Шахты"}
        s["npc;drop=144246"] = {"КУ-ДЖ0", "Операция 'Мехагон'"}
        s["npc;drop=241526"] = {"[Chrome King Gallywix]", "Освобождение Нижней Шахты"}
        s["npc;drop=228458"] = {"[One-Armed Bandit]", "Освобождение Нижней Шахты"}
        s["npc;drop=228652"] = {"[Rik Reverb]", "Освобождение Нижней Шахты"}
        s["npc;drop=164451"] = {"Дессия Обезглавливательница", "Театр Боли"}
        s["npc;drop=129227"] = {"Азерокк", "ЗОЛОТАЯ ЖИЛА!!!"}
        s["npc;drop=225821"] = {"[The Geargrinder]", "Освобождение Нижней Шахты"}
        s["npc;drop=230583"] = {"[Sprocketmonger Lockenstock]", "Освобождение Нижней Шахты"}
        s["npc;drop=229953"] = {"[Mug'Zee]", "Освобождение Нижней Шахты"}
        s["npc;drop=230322"] = {"[Stix Bunkjunker]", "Освобождение Нижней Шахты"}
        s["npc;drop=131227"] = {"Шеф Разданк", "ЗОЛОТАЯ ЖИЛА!!!"}
        s["npc;drop=129231"] = {"Рикса Огневерт <Старший ученый>", "ЗОЛОТАЯ ЖИЛА!!!"}
        s["npc;drop=162317"] = {"Кроворуб", "Театр Боли"}
        s["npc;drop=226404"] = {"Гизл Гигабжик", "Операция: шлюз"}
        s["npc;drop=165946"] = {"Мордрета, Вечная императрица", "Театр Боли"}
        s["npc;drop=226403"] = {"[Keeza Quickfuse]", "Операция: шлюз"}
        s["npc;drop=132713"] = {"Шеф Разданк", "ЗОЛОТАЯ ЖИЛА!!!"}
        s["npc;drop=230828"] = {"[Chief Foreman Gutso]", "Нижняя Шахта"}
        s["npc;drop=230800"] = {"[Slugger the Smart]", "Нижняя Шахта"}
        s["npc;drop=230934"] = {"[Ratspit]", "Нижняя Шахта"}
        s["npc;drop=152619"] = {"Король Мехагон", "Операция 'Мехагон'"}
        s["npc;drop=150397"] = {"Король Мехагон", "Операция 'Мехагон'"}
        s["npc;drop=129214"] = {"Платный разгонятель толпы", "ЗОЛОТАЯ ЖИЛА!!!"}
        s["npc;drop=144248"] = {"Главный машинист Искроточец", "Операция 'Мехагон'"}
        s["spell;created=447315"] = {"Перегруженный генератор идей", "CRAFTING"}
        s["npc;drop=208745"] = {"Свечной Король", "Расселина Темного Пламени"}
        s["npc;drop=162329"] = {"Ксав Несломленный", "Театр Боли"}
        s["npc;drop=226398"] = {"[Big M.O.M.M.A.]", "Операция: шлюз"}
        s["quest;reward=83125"] = {"", "Зулдазар"}
        s["object;contained=476068"] = {"[Papa's Prized Putter]", "Нижняя Шахта"}
        s["npc;drop=144244"] = {"'Платиновый лупцеватор'", "Операция 'Мехагон'"}
        s["spell;created=473400"] = {"Рекалибровка для заклинаний", "CRAFTING"}
        s["npc;drop=162309"] = {"Кул'тарок", "Театр Боли"}
        s["npc;drop=207940"] = {"Настоятельница Муррпрэй", "Приорат Священного Пламени"}
        s["npc;drop=242255"] = {"[Geezle Gigazap]", "Операция: шлюз"}
        s["npc;drop=150222"] = {"Токсикоид", "Операция 'Мехагон'"}
        s["npc;drop=230946"] = {"[V.V. Goosworth]", "Нижняя Шахта"}
        s["npc;drop=150159"] = {"Король Гоббамак", "Операция 'Мехагон'"}
        s["npc;drop=231310"] = {"Стимулирующий реагент Мрачных Минеров", "Нижняя Шахта"}
        s["npc;drop=229288"] = {"Король Флэймспайт <Менеджер Пламендо>", "Освобождение Нижней Шахты"}
        s["npc;drop=229284"] = {"Гук Бумгавс <Продавец варева>", "Освобождение Нижней Шахты"}
        s["object;contained=507768"] = {"Выброшенная куча гоблинской валюты", "Место раскопок 9"}
        s["spell;created=441051"] = {"Мундир с руническим клеймом", "CRAFTING"}
        s["npc;drop=237861"] = {"Fractillus <[The Shatterer]>", "Манагорн Омега"}
        s["npc;drop=175646"] = {"ПОЧТ-мейстер", "Тайный рынок Тазавеш"}
        s["npc;drop=156827"] = {"Эшелон", "Чертоги Покаяния"}
        s["npc;drop=177269"] = {"Со'лея <Картель Со>", "Тайный рынок Тазавеш"}
        s["npc;drop=234933"] = {"Таа'бат <Неумолимый>", "Заповедник 'Аль'дани'"}
        s["spell;created=1249111"] = {"Получение повязок", "CRAFTING"}
        s["npc;drop=165408"] = {"Халкиас <Запятнанный грехом голиаф>", "Чертоги Покаяния"}
        s["npc;drop=175663"] = {"Хильбранд <Меч Хранителей>", "Тайный рынок Тазавеш"}
        s["npc;drop=164185"] = {"Эшелон", "Чертоги Покаяния"}
        s["npc;drop=165410"] = {"Верховный адъюдикатор Ализа", "Чертоги Покаяния"}
        s["npc;drop=176556"] = {"Алькруукс <Обжора>", "Тайный рынок Тазавеш"}
        s["npc;drop=175546"] = {"Хронокэп Крюкохвост", "Тайный рынок Тазавеш"}
        s["npc;drop=175806"] = {"Со'азми", "Тайный рынок Тазавеш"}
        s["npc;drop=176563"] = {"Зо'грон", "Тайный рынок Тазавеш"}
        s["npc;drop=176705"] = {"Венца Голдаплавс", "Тайный рынок Тазавеш"}
        s["npc;drop=234893"] = {"Ажиккар", "Заповедник 'Аль'дани'"}
        s["npc;drop=164218"] = {"Лорд-камергер", "Чертоги Покаяния"}
        s["npc;drop=175616"] = {"Зо'фекс <Часовой>", "Тайный рынок Тазавеш"}
        s["spell;created=450223"] = {"Выкованный навеки защитник", "CRAFTING"}
        s["npc;drop=244752"] = {"Принцесса Нексуса Ки'веза", "Убежище рассекателя Бездны"}
        s["npc;drop=231981"] = {"Пасть песков", "К'ареш"}
        s["npc;drop=234845"] = {"Стаарбс <Будоражащий>", "К'ареш"}
        s["object;contained=416265"] = {"Опустошенный ларь", "Яма Ужаса"}
        s["npc;drop=247989"] = {"Ткач горна Араз", "Манагорн Омега"}
        s["npc;drop=233814"] = {"Сплетенный страж", "Манагорн Омега"}
        s["npc;drop=237661"] = {"Адар Вспышка Сумерек", "Манагорн Омега"}
        s["npc;drop=233815"] = {"Ткан'итар", "Манагорн Омега"}
        s["npc;drop=237763"] = {"Соправитель Салхадаар", "Манагорн Омега"}
        s["npc;drop=233824"] = {"Пространствус", "Манагорн Омега"}
        s["npc;drop=233816"] = {"Стражница душ Наазиндри", "Манагорн Омега"}
        s["npc;drop=235853"] = {"Смотритель путевых врат", "Манагорн Омега"}
        s["npc;drop=239454"] = {"Темный маг Зейд", "Манагорн Омега"}
        s["npc;sold=248303"] = {"Zah'ran <[Delve Trinkets]>", "Место раскопок 9"}
        s["quest;reward=91009"] = {"Долговечный Информационный Сохраняющий Контейнер", "Дорногал"}
        s["spell;created=441063"] = {"Гравированные символами шоссы", "CRAFTING"}
    end

    function SpecBisTooltip:TranslationzhCN()
        s["npc;drop=224552"] = {"拉夏南", "尼鲁巴尔王宫"}
        s["npc;drop=223779"] = {"Anub'arash <[The Thousand Scars]>", "尼鲁巴尔王宫"}
        s["npc;sold=224270"] = {"伊普克萨", "千丝之城"}
        s["spell;created=450226"] = {"永铸腕甲", "CRAFTING"}
        s["spell;created=450222"] = {"永铸重型腰带", "CRAFTING"}
        s["npc;drop=219778"] = {"安苏雷克女王", "尼鲁巴尔王宫"}
        s["npc;drop=162693"] = {"缚霜者纳尔佐", "通灵战潮"}
        s["npc;drop=213179"] = {"阿瓦诺克斯", "艾拉-卡拉，回响之城"}
        s["npc;drop=162689"] = {"外科医生缝肉", "通灵战潮"}
        s["npc;drop=219853"] = {"席克兰 <苏雷吉队长>", "尼鲁巴尔王宫"}
        s["spell;created=450220"] = {"永铸战靴", "CRAFTING"}
        s["npc;drop=214506"] = {"虫巢扭曲者欧维纳克斯", "尼鲁巴尔王宫"}
        s["npc;drop=164501"] = {"唤雾者", "塞兹仙林的迷雾"}
        s["npc;drop=40319"] = {"达加·燃影者 <暮光之锤信使>", "格瑞姆巴托"}
        s["npc;drop=215405"] = {"阿努布泽克特 <虫群卫士>", "艾拉-卡拉，回响之城"}
        s["npc;drop=211089"] = {"阿努布伊卡基", "破晨号"}
        s["npc;drop=39625"] = {"乌比斯将军 <死亡之翼的仆从>", "格瑞姆巴托"}
        s["npc;drop=213217"] = {"代言人布洛克", "矶石宝库"}
        s["npc;drop=129208"] = {"恐怖船长洛克伍德", "围攻伯拉勒斯"}
        s["npc;drop=213119"] = {"虚空代言人艾里克", "矶石宝库"}
        s["npc;drop=216320"] = {"凝结聚合体", "千丝之城"}
        s["npc;drop=128650"] = {"“屠夫”血钩", "围攻伯拉勒斯"}
        s["npc;drop=128651"] = {"哈达尔·黑渊", "围攻伯拉勒斯"}
        s["npc;drop=164567"] = {"英格拉·马洛克", "塞兹仙林的迷雾"}
        s["npc;drop=210156"] = {"斯卡莫拉克", "矶石宝库"}
        s["npc;drop=128649"] = {"拜恩比吉中士", "围攻伯拉勒斯"}
        s["spell;created=450242"] = {"充能切斧", "CRAFTING"}
        s["npc;drop=228470"] = {"节点女亲王凯威扎", "尼鲁巴尔王宫"}
        s["npc;drop=214502"] = {"血缚恐魔", "尼鲁巴尔王宫"}
        s["npc;drop=216658"] = {"大捻接师艾佐", "千丝之城"}
        s["npc;drop=163157"] = {"阿玛厄斯 <收割者>", "通灵战潮"}
        s["npc;drop=211087"] = {"代言人夏多克朗", "破晨号"}
        s["npc;drop=40484"] = {"埃鲁达克 <地狱公爵>", "格瑞姆巴托"}
        s["npc;drop=162691"] = {"凋骨", "通灵战潮"}
        s["spell;created=441057"] = {"符烙腰带", "CRAFTING"}
        s["npc;drop=216619"] = {"演说者基克斯威兹克 <第五帛丝>", "千丝之城"}
        s["spell;created=450232"] = {"永铸战刃", "CRAFTING"}
        s["npc;drop=215407"] = {"收割者吉卡塔尔", "艾拉-卡拉，回响之城"}
        s["npc;drop=128652"] = {"维克戈斯 <深渊魔王>", "围攻伯拉勒斯"}
        s["spell;created=450231"] = {"永铸长剑", "CRAFTING"}
        s["npc;drop=40177"] = {"铸炉之主索朗格斯", "格瑞姆巴托"}
        s["npc;drop=164517"] = {"特雷德奥瓦", "塞兹仙林的迷雾"}
        s["spell;created=435382"] = {"知己之玑", "CRAFTING"}
        s["npc;drop=216648"] = {"恩克斯 <女王之牙>", "千丝之城"}
        s["npc;drop=207207"] = {"虚空石畸体", "驭雷栖巢"}
        s["spell;created=450235"] = {"充能妖术剑", "CRAFTING"}
        s["spell;created=444197"] = {"流浪者的火炬", "CRAFTING"}
        s["npc;drop=208743"] = {"布雷炙孔", "暗焰裂口"}
        s["npc;drop=210271"] = {"酿造大师阿德里尔", "燧酿酒庄"}
        s["npc;drop=207205"] = {"雷卫戈伦", "驭雷栖巢"}
        s["npc;drop=218002"] = {"本克·鸣蜂 <养蜂人>", "燧酿酒庄"}
        s["npc;drop=209230"] = {"凯里欧斯", "驭雷栖巢"}
        s["spell;created=450230"] = {"永铸匕首", "CRAFTING"}
        s["spell;created=441066"] = {"刻纹腕扣", "CRAFTING"}
        s["spell;created=441061"] = {"刻纹护手", "CRAFTING"}
        s["spell;created=447352"] = {"P.0.W. x2型", "CRAFTING"}
        s["npc;drop=208478"] = {"沃尔科罗斯", "阿梅达希尔，梦境之愿"}
        s["spell;created=446940"] = {"圣化披风", "CRAFTING"}
        s["spell;created=450239"] = {"充能长戟", "CRAFTING"}
        s["spell;created=445355"] = {"光耀魔法节杖", "CRAFTING"}
        s["npc;drop=210267"] = {"艾帕", "燧酿酒庄"}
        s["npc;drop=214661"] = {"戈尔迪·底爵 <蜂老板>", "燧酿酒庄"}
        s["npc;drop=210153"] = {"老蜡须", "暗焰裂口"}
        s["npc;drop=207946"] = {"戴尔克莱上尉", "圣焰隐修院"}
        s["spell;created=446937"] = {"圣化便鞋", "CRAFTING"}
        s["spell;created=444198"] = {"流浪者的精细腋杖", "CRAFTING"}
        s["spell;created=441058"] = {"符烙束腕", "CRAFTING"}
        s["spell;created=441052"] = {"符烙之靴", "CRAFTING"}
        s["spell;created=441055"] = {"符烙裤子", "CRAFTING"}
        s["spell;created=435385"] = {"土灵匠工护符", "CRAFTING"}
        s["spell;created=450237"] = {"充能碎面锤", "CRAFTING"}
        s["spell;created=450238"] = {"充能大剑", "CRAFTING"}
        s["npc;drop=207939"] = {"布朗派克男爵", "圣焰隐修院"}
        s["npc;drop=210797"] = {"黑暗之主", "暗焰裂口"}
        s["spell;created=441053"] = {"符烙手套", "CRAFTING"}
        s["spell;created=446938"] = {"圣化腕扣", "CRAFTING"}
        s["spell;created=444199"] = {"流浪者的划界指挥棒", "CRAFTING"}
        s["spell;created=450224"] = {"永铸之盔", "CRAFTING"}
        s["spell;created=450234"] = {"永铸巨斧", "CRAFTING"}
        s["spell;created=435384"] = {"土灵匠工之戒", "CRAFTING"}
        s["spell;created=441060"] = {"刻纹便鞋", "CRAFTING"}
        s["npc;sold=227003"] = {"基尔克萨 <奇珍收集者>", "千丝之城"}
        s["object;contained=413590"] = {"丰裕宝匣", "恐惧陷坑"}
        s["spell;created=441065"] = {"刻纹腰链", "CRAFTING"}
        s["npc;drop=215657"] = {"噬灭者乌格拉克斯", "尼鲁巴尔王宫"}
        s["spell;created=444070"] = {"肾上腺素激涌腰带", "CRAFTING"}
        s["item:contained=229354"] = {"阿加冒险者的宝箱", ""}
        s["object;contained=413563"] = {"沉重之箱", "丝菌师洞穴"}
        s["item:contained=229129"] = {"一箱地下堡行者的宝藏", ""}
        s["quest;reward=78636"] = {"夺回矿坑", ""}
        s["npc;drop=202318"] = {"响应战队守护者", "查拉雷克洞窟"}
        s["npc;drop=203355"] = {"雷卡尔上尉", "查拉雷克洞窟"}
        s["quest;reward=79342"] = {"他的辞别", ""}
        s["quest;reward=78232"] = {"反复覆写", ""}
        s["spell;created=455393"] = {"光辉", ""}
        s["spell;created=455394"] = {"扬升", ""}
        s["spell;created=455392"] = {"共生", ""}
        s["spell;created=427185"] = {"阿加炼金石", "CRAFTING"}
        s["spell;created=455391"] = {"盎溢", ""}
        s["npc;sold=219222"] = {"拉兰迪 <征服军需官>", "多恩诺嘉尔"}
        s["npc;drop=226305"] = {"[Emperor Dagran Thaurissan]", "黑石深渊"}
        s["npc;drop=226306"] = {"[Golem Lord Argelmach]", "黑石深渊"}
        s["npc;drop=226315"] = {"[Lord Roccor]", "黑石深渊"}
        s["npc;drop=217489"] = {"阿努巴拉什 <千疤者>", "尼鲁巴尔王宫"}
        s["npc;drop=223839"] = {"女王亲卫杰扎", "尼鲁巴尔王宫"}
        s["spell;created=447314"] = {"勤勉聪慧激励器", "CRAFTING"}
        s["spell;created=446939"] = {"圣化腰索", "CRAFTING"}
        s["spell;created=450229"] = {"永铸戳刺者", "CRAFTING"}
        s["npc;drop=210108"] = {"E.D.N.A.", "矶石宝库"}
        s["npc;drop=229992"] = {"石笋纳罗克", "海妖岛"}
        s["npc;sold=231824"] = {"[Kari Bridgeblaster]", "安德麦"}
        s["npc;drop=226396"] = {"[Swampface]", "水闸行动"}
        s["npc;drop=229181"] = {"[Flarendo]", "解放安德麦"}
        s["npc;drop=144246"] = {"狂犬K.U.-J.0.", "麦卡贡行动"}
        s["npc;drop=241526"] = {"[Chrome King Gallywix]", "解放安德麦"}
        s["npc;drop=228458"] = {"[One-Armed Bandit]", "解放安德麦"}
        s["npc;drop=228652"] = {"[Rik Reverb]", "解放安德麦"}
        s["npc;drop=164451"] = {"斩首者德茜雅", "伤逝剧场"}
        s["npc;drop=129227"] = {"艾泽洛克", "暴富矿区！！"}
        s["npc;drop=225821"] = {"[The Geargrinder]", "解放安德麦"}
        s["npc;drop=230583"] = {"[Sprocketmonger Lockenstock]", "解放安德麦"}
        s["npc;drop=229953"] = {"[Mug'Zee]", "解放安德麦"}
        s["npc;drop=230322"] = {"[Stix Bunkjunker]", "解放安德麦"}
        s["npc;drop=131227"] = {"商业大亨拉兹敦克", "暴富矿区！！"}
        s["npc;drop=129231"] = {"瑞克莎·流火", "暴富矿区！！"}
        s["npc;drop=162317"] = {"斩血", "伤逝剧场"}
        s["npc;drop=165946"] = {"无尽女皇莫德蕾莎", "伤逝剧场"}
        s["npc;drop=226403"] = {"[Keeza Quickfuse]", "水闸行动"}
        s["npc;drop=132713"] = {"商业大亨拉兹敦克", "暴富矿区！！"}
        s["npc;drop=230828"] = {"[Chief Foreman Gutso]", "安德麦"}
        s["npc;drop=230800"] = {"[Slugger the Smart]", "安德麦"}
        s["npc;drop=230934"] = {"[Ratspit]", "安德麦"}
        s["npc;drop=152619"] = {"麦卡贡国王", "麦卡贡行动"}
        s["npc;drop=150397"] = {"麦卡贡国王", "麦卡贡行动"}
        s["npc;drop=129214"] = {"投币式群体打击者", "暴富矿区！！"}
        s["npc;drop=144248"] = {"首席机械师闪流", "麦卡贡行动"}
        s["spell;created=447315"] = {"超频构想发生器", "CRAFTING"}
        s["npc;drop=208745"] = {"蜡烛之王", "暗焰裂口"}
        s["npc;drop=162329"] = {"无堕者哈夫", "伤逝剧场"}
        s["npc;drop=226398"] = {"[Big M.O.M.M.A.]", "水闸行动"}
        s["quest;reward=83125"] = {"", "祖达萨"}
        s["object;contained=476068"] = {"[Papa's Prized Putter]", "安德麦"}
        s["npc;drop=144244"] = {"白金拳手", "麦卡贡行动"}
        s["spell;created=473400"] = {"施法重配置", "CRAFTING"}
        s["npc;drop=162309"] = {"库尔萨洛克", "伤逝剧场"}
        s["npc;drop=207940"] = {"隐修院长穆普雷", "圣焰隐修院"}
        s["npc;drop=242255"] = {"[Geezle Gigazap]", "水闸行动"}
        s["npc;drop=150222"] = {"冈克", "麦卡贡行动"}
        s["npc;drop=230946"] = {"[V.V. Goosworth]", "安德麦"}
        s["npc;drop=150159"] = {"戈巴马克国王", "麦卡贡行动"}
        s["npc;drop=231310"] = {"暗索沉淀剂", "安德麦"}
        s["npc;drop=226404"] = {"吉泽尔·超震", "水闸行动"}
        s["npc;drop=229288"] = {"喷焰大王 <弗莱兰多的经理>", "解放安德麦"}
        s["npc;drop=229284"] = {"古克·轰犬 <污液贩子>", "解放安德麦"}
        s["object;contained=507768"] = {"丢弃的地精货币堆", "九号挖掘场"}
        s["spell;created=441051"] = {"符烙胸甲", "CRAFTING"}
        s["npc;drop=237861"] = {"Fractillus <[The Shatterer]>", "法力熔炉：欧米伽"}
        s["npc;drop=175646"] = {"P.O.S.T.总管", "塔扎维什，帷纱集市"}
        s["npc;drop=156827"] = {"艾谢朗", "赎罪大厅"}
        s["npc;drop=177269"] = {"索·莉亚 <索财团>", "塔扎维什，帷纱集市"}
        s["npc;drop=234933"] = {"塔尔·巴特 <无情者>", "奥尔达尼生态圆顶"}
        s["spell;created=1249111"] = {"收到裹布", "CRAFTING"}
        s["npc;drop=165408"] = {"哈尔吉亚斯 <罪污巨像>", "赎罪大厅"}
        s["npc;drop=175663"] = {"希尔布兰德 <守护者之剑>", "塔扎维什，帷纱集市"}
        s["npc;drop=164185"] = {"艾谢朗", "赎罪大厅"}
        s["npc;drop=165410"] = {"高阶裁决官阿丽兹", "赎罪大厅"}
        s["npc;drop=176556"] = {"阿尔克鲁克斯 <暴食者>", "塔扎维什，帷纱集市"}
        s["npc;drop=175546"] = {"时空船长钩尾", "塔扎维什，帷纱集市"}
        s["npc;drop=175806"] = {"索·阿兹密", "塔扎维什，帷纱集市"}
        s["npc;drop=176563"] = {"佐·格伦", "塔扎维什，帷纱集市"}
        s["npc;drop=176705"] = {"雯扎·金线", "塔扎维什，帷纱集市"}
        s["npc;drop=234893"] = {"阿兹希卡", "奥尔达尼生态圆顶"}
        s["npc;drop=164218"] = {"宫务大臣", "赎罪大厅"}
        s["npc;drop=175616"] = {"佐·菲克斯 <哨卫>", "塔扎维什，帷纱集市"}
        s["spell;created=450223"] = {"永铸防御者", "CRAFTING"}
        s["npc;drop=244752"] = {"节点女亲王凯威扎", "虚空之锋庇护所"}
        s["npc;drop=231981"] = {"沙海之喉", "卡雷什"}
        s["npc;drop=234845"] = {"司萨阿布斯 <心智搅荡者>", "卡雷什"}
        s["object;contained=416265"] = {"失窃之箱", "恐惧陷坑"}
        s["npc;drop=247989"] = {"熔炉编织者阿拉兹", "法力熔炉：欧米伽"}
        s["npc;drop=233814"] = {"集能哨兵", "法力熔炉：欧米伽"}
        s["npc;drop=237661"] = {"阿达拉斯·暮焰", "法力熔炉：欧米伽"}
        s["npc;drop=233815"] = {"卢米萨尔", "法力熔炉：欧米伽"}
        s["npc;drop=237763"] = {"节点之王萨哈达尔", "法力熔炉：欧米伽"}
        s["npc;drop=233824"] = {"迪门修斯", "法力熔炉：欧米伽"}
        s["npc;drop=233816"] = {"缚魂者娜欣达利", "法力熔炉：欧米伽"}
        s["npc;drop=235853"] = {"界门观察者", "法力熔炉：欧米伽"}
        s["npc;drop=239454"] = {"暗法师扎杜斯", "法力熔炉：欧米伽"}
        s["npc;sold=248303"] = {"Zah'ran <[Delve Trinkets]>", "九号挖掘场"}
        s["quest;reward=91009"] = {"牢固信息保全容器", "多恩诺嘉尔"}
        s["spell;created=441063"] = {"刻纹护腿", "CRAFTING"}
    end

    function SpecBisTooltip:TranslationzhTW()
        s["npc;drop=224552"] = {"拉夏南", "尼鲁巴尔王宫"}
        s["npc;drop=223779"] = {"Anub'arash <[The Thousand Scars]>", "尼鲁巴尔王宫"}
        s["npc;sold=224270"] = {"伊普克萨", "千丝之城"}
        s["spell;created=450226"] = {"永铸腕甲", "CRAFTING"}
        s["spell;created=450222"] = {"永铸重型腰带", "CRAFTING"}
        s["npc;drop=219778"] = {"安苏雷克女王", "尼鲁巴尔王宫"}
        s["npc;drop=162693"] = {"缚霜者纳尔佐", "通灵战潮"}
        s["npc;drop=213179"] = {"阿瓦诺克斯", "艾拉-卡拉，回响之城"}
        s["npc;drop=162689"] = {"外科医生缝肉", "通灵战潮"}
        s["npc;drop=219853"] = {"席克兰 <苏雷吉队长>", "尼鲁巴尔王宫"}
        s["spell;created=450220"] = {"永铸战靴", "CRAFTING"}
        s["npc;drop=214506"] = {"虫巢扭曲者欧维纳克斯", "尼鲁巴尔王宫"}
        s["npc;drop=164501"] = {"唤雾者", "塞兹仙林的迷雾"}
        s["npc;drop=40319"] = {"达加·燃影者 <暮光之锤信使>", "格瑞姆巴托"}
        s["npc;drop=215405"] = {"阿努布泽克特 <虫群卫士>", "艾拉-卡拉，回响之城"}
        s["npc;drop=211089"] = {"阿努布伊卡基", "破晨号"}
        s["npc;drop=39625"] = {"乌比斯将军 <死亡之翼的仆从>", "格瑞姆巴托"}
        s["npc;drop=213217"] = {"代言人布洛克", "矶石宝库"}
        s["npc;drop=129208"] = {"恐怖船长洛克伍德", "围攻伯拉勒斯"}
        s["npc;drop=213119"] = {"虚空代言人艾里克", "矶石宝库"}
        s["npc;drop=216320"] = {"凝结聚合体", "千丝之城"}
        s["npc;drop=128650"] = {"“屠夫”血钩", "围攻伯拉勒斯"}
        s["npc;drop=128651"] = {"哈达尔·黑渊", "围攻伯拉勒斯"}
        s["npc;drop=164567"] = {"英格拉·马洛克", "塞兹仙林的迷雾"}
        s["npc;drop=210156"] = {"斯卡莫拉克", "矶石宝库"}
        s["npc;drop=128649"] = {"拜恩比吉中士", "围攻伯拉勒斯"}
        s["spell;created=450242"] = {"充能切斧", "CRAFTING"}
        s["npc;drop=228470"] = {"节点女亲王凯威扎", "尼鲁巴尔王宫"}
        s["npc;drop=214502"] = {"血缚恐魔", "尼鲁巴尔王宫"}
        s["npc;drop=216658"] = {"大捻接师艾佐", "千丝之城"}
        s["npc;drop=163157"] = {"阿玛厄斯 <收割者>", "通灵战潮"}
        s["npc;drop=211087"] = {"代言人夏多克朗", "破晨号"}
        s["npc;drop=40484"] = {"埃鲁达克 <地狱公爵>", "格瑞姆巴托"}
        s["npc;drop=162691"] = {"凋骨", "通灵战潮"}
        s["spell;created=441057"] = {"符烙腰带", "CRAFTING"}
        s["npc;drop=216619"] = {"演说者基克斯威兹克 <第五帛丝>", "千丝之城"}
        s["spell;created=450232"] = {"永铸战刃", "CRAFTING"}
        s["npc;drop=215407"] = {"收割者吉卡塔尔", "艾拉-卡拉，回响之城"}
        s["npc;drop=128652"] = {"维克戈斯 <深渊魔王>", "围攻伯拉勒斯"}
        s["spell;created=450231"] = {"永铸长剑", "CRAFTING"}
        s["npc;drop=40177"] = {"铸炉之主索朗格斯", "格瑞姆巴托"}
        s["npc;drop=164517"] = {"特雷德奥瓦", "塞兹仙林的迷雾"}
        s["spell;created=435382"] = {"知己之玑", "CRAFTING"}
        s["npc;drop=216648"] = {"恩克斯 <女王之牙>", "千丝之城"}
        s["npc;drop=207207"] = {"虚空石畸体", "驭雷栖巢"}
        s["spell;created=450235"] = {"充能妖术剑", "CRAFTING"}
        s["spell;created=444197"] = {"流浪者的火炬", "CRAFTING"}
        s["npc;drop=208743"] = {"布雷炙孔", "暗焰裂口"}
        s["npc;drop=210271"] = {"酿造大师阿德里尔", "燧酿酒庄"}
        s["npc;drop=207205"] = {"雷卫戈伦", "驭雷栖巢"}
        s["npc;drop=218002"] = {"本克·鸣蜂 <养蜂人>", "燧酿酒庄"}
        s["npc;drop=209230"] = {"凯里欧斯", "驭雷栖巢"}
        s["spell;created=450230"] = {"永铸匕首", "CRAFTING"}
        s["spell;created=441066"] = {"刻纹腕扣", "CRAFTING"}
        s["spell;created=441061"] = {"刻纹护手", "CRAFTING"}
        s["spell;created=447352"] = {"P.0.W. x2型", "CRAFTING"}
        s["npc;drop=208478"] = {"沃尔科罗斯", "阿梅达希尔，梦境之愿"}
        s["spell;created=446940"] = {"圣化披风", "CRAFTING"}
        s["spell;created=450239"] = {"充能长戟", "CRAFTING"}
        s["spell;created=445355"] = {"光耀魔法节杖", "CRAFTING"}
        s["npc;drop=210267"] = {"艾帕", "燧酿酒庄"}
        s["npc;drop=214661"] = {"戈尔迪·底爵 <蜂老板>", "燧酿酒庄"}
        s["npc;drop=210153"] = {"老蜡须", "暗焰裂口"}
        s["npc;drop=207946"] = {"戴尔克莱上尉", "圣焰隐修院"}
        s["spell;created=446937"] = {"圣化便鞋", "CRAFTING"}
        s["spell;created=444198"] = {"流浪者的精细腋杖", "CRAFTING"}
        s["spell;created=441058"] = {"符烙束腕", "CRAFTING"}
        s["spell;created=441052"] = {"符烙之靴", "CRAFTING"}
        s["spell;created=441055"] = {"符烙裤子", "CRAFTING"}
        s["spell;created=435385"] = {"土灵匠工护符", "CRAFTING"}
        s["spell;created=450237"] = {"充能碎面锤", "CRAFTING"}
        s["spell;created=450238"] = {"充能大剑", "CRAFTING"}
        s["npc;drop=207939"] = {"布朗派克男爵", "圣焰隐修院"}
        s["npc;drop=210797"] = {"黑暗之主", "暗焰裂口"}
        s["spell;created=441053"] = {"符烙手套", "CRAFTING"}
        s["spell;created=446938"] = {"圣化腕扣", "CRAFTING"}
        s["spell;created=444199"] = {"流浪者的划界指挥棒", "CRAFTING"}
        s["spell;created=450224"] = {"永铸之盔", "CRAFTING"}
        s["spell;created=450234"] = {"永铸巨斧", "CRAFTING"}
        s["spell;created=435384"] = {"土灵匠工之戒", "CRAFTING"}
        s["spell;created=441060"] = {"刻纹便鞋", "CRAFTING"}
        s["npc;sold=227003"] = {"基尔克萨 <奇珍收集者>", "千丝之城"}
        s["object;contained=413590"] = {"丰裕宝匣", "恐惧陷坑"}
        s["spell;created=441065"] = {"刻纹腰链", "CRAFTING"}
        s["npc;drop=215657"] = {"噬灭者乌格拉克斯", "尼鲁巴尔王宫"}
        s["spell;created=444070"] = {"肾上腺素激涌腰带", "CRAFTING"}
        s["item:contained=229354"] = {"阿加冒险者的宝箱", ""}
        s["object;contained=413563"] = {"沉重之箱", "丝菌师洞穴"}
        s["item:contained=229129"] = {"一箱地下堡行者的宝藏", ""}
        s["quest;reward=78636"] = {"夺回矿坑", ""}
        s["npc;drop=202318"] = {"响应战队守护者", "查拉雷克洞窟"}
        s["npc;drop=203355"] = {"雷卡尔上尉", "查拉雷克洞窟"}
        s["quest;reward=79342"] = {"他的辞别", ""}
        s["quest;reward=78232"] = {"反复覆写", ""}
        s["spell;created=455393"] = {"光辉", ""}
        s["spell;created=455394"] = {"扬升", ""}
        s["spell;created=455392"] = {"共生", ""}
        s["spell;created=427185"] = {"阿加炼金石", "CRAFTING"}
        s["spell;created=455391"] = {"盎溢", ""}
        s["npc;sold=219222"] = {"拉兰迪 <征服军需官>", "多恩诺嘉尔"}
        s["npc;drop=226305"] = {"[Emperor Dagran Thaurissan]", "黑石深渊"}
        s["npc;drop=226306"] = {"[Golem Lord Argelmach]", "黑石深渊"}
        s["npc;drop=226315"] = {"[Lord Roccor]", "黑石深渊"}
        s["npc;drop=217489"] = {"阿努巴拉什 <千疤者>", "尼鲁巴尔王宫"}
        s["npc;drop=223839"] = {"女王亲卫杰扎", "尼鲁巴尔王宫"}
    end
end
