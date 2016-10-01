DraenorTreasures = LibStub("AceAddon-3.0"):NewAddon("DraenorTreasures", "AceBucket-3.0", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
local HandyNotes = LibStub("AceAddon-3.0"):GetAddon("HandyNotes", true)

if not HandyNotes then return end

local iconDefaults = {
    default = "Interface\\Icons\\TRADE_ARCHAEOLOGY_CHESTOFTINYGLASSANIMALS",
    unknown = "Interface\\Addons\\HandyNotes_DraenorTreasures\\Artwork\\chest_normal_daily.tga",
    swprare = "Interface\\Icons\\Trade_Archaeology_Fossil_SnailShell",
    shrine = "Interface\\Icons\\inv_misc_statue_02",
    glider = "Interface\\Icons\\inv_feather_04",
    rocket = "Interface\\Icons\\ability_mount_rocketmount",
    skull_blue = "Interface\\Addons\\HandyNotes_DraenorTreasures\\Artwork\\RareIconBlue.tga",
    skull_green = "Interface\\Addons\\HandyNotes_DraenorTreasures\\Artwork\\RareIconGreen.tga",
    skull_grey = "Interface\\Addons\\HandyNotes_DraenorTreasures\\Artwork\\RareIcon.tga",
    skull_orange = "Interface\\Addons\\HandyNotes_DraenorTreasures\\Artwork\\RareIconOrange.tga",
    skull_purple = "Interface\\Addons\\HandyNotes_DraenorTreasures\\Artwork\\RareIconPurple.tga",
    skull_red = "Interface\\Addons\\HandyNotes_DraenorTreasures\\Artwork\\RareIconRed.tga",
    skull_yellow = "Interface\\Addons\\HandyNotes_DraenorTreasures\\Artwork\\RareIconYellow.tga",
}

local PlayerFaction, _ = UnitFactionGroup("player")
DraenorTreasures.nodes = { }

local nodes = DraenorTreasures.nodes
local isTomTomloaded = false
local isDBMloaded = false
local isHN_LRTloaded = false


nodes["ShadowmoonValleyDR"] = {
    [54924501]={ "35581", "Alchemist's Satchel", "Herbs", "", "default", "treasure_smv","109124"},
    [52834837]={ "35584", "Ancestral Greataxe", "i519 2H Strength Axe", "", "default", "treasure_smv","113560"},
    [41422798]={ "33869", "Armored Elekk Tusk", "i518 Trinket Bonus Armor + Mastery on use", "", "default", "treasure_smv","108902"},
    [37784435]={ "33584", "Ashes of A'kumbo", "Consumable for Rested XP", "", "default", "treasure_smv","113531"},
    [49313760]={ "33867", "Astrologer's Box", "Toy", "", "default", "treasure_smv","109739"},
    [36774142]={ "33046", "Beloved's Offering", "Flavor Item - Offhand", "", "default", "treasure_smv","113547"},
    [37182313]={ "33613", "Bubbling Cauldron", "i516 Caster Offhand", "In a cave; the entrance is slightly to the northeast, at 38, 22.3", "default", "treasure_smv","108945"},
    [84564478]={ "33885", "Cargo of the Raven Queen", "Garrison Resources", "", "default", "treasure_smv","824"},
    [33453961]={ "33569", "Carved Drinking Horn", "Reusable Mana Potion", "", "default", "treasure_smv","113545"},
    [61706790]={ "34743", "Crystal Blade of Torvath", "Trash Item", "Interacting with the object causes three Silverleaf Ancients to spawn; you can only loot the item after they are dead", "default", "treasure_smv","111636"},
    [20383065]={ "33575", "Demonic Cache", "i550 Intellect Neck", "", "default", "treasure_smv","108904"},
    [29853748]={ "36879", "Dusty Lockbox", "Random Greens + Gold", "On top of a giant stone arch; to reach it, jump across the other stone arches, starting on a cliff ledge to the west", "default", "treasure_smv","824"},
    [51753549]={ "33037", "False-Bottomed Jar", "Gold", "", "default", "treasure_smv","824"},
    [26530568]={ "34174", "Fantastic Fish", "Garrison Resources", "", "default", "treasure_smv","824"},
    [34394623]={ "33891", "Giant Moonwillow Cone", "i522 Wand", "", "default", "treasure_smv","108901"},
    [48724753]={ "35798", "Glowing Cave Mushroom", "Herbs", "", "default", "treasure_smv","109127"},
    [38484308]={ "33614", "Greka's Urn", "i528 Trinket Haste + Strength Proc", "", "default", "treasure_smv","113408"},
    [47154603]={ "33564", "Hanging Satchel", "i518 Agility/Intellect Leather Gloves", "", "default", "treasure_smv","108900"},
    [42106130]={ "33041", "Iron Horde Cargo Shipment", "Garrison Resources", "", "default", "treasure_smv","824"},
    [37515925]={ "33567", "Iron Horde Tribute", "Trinket Multistrike + DMG on use", "", "default", "treasure_smv","108903"},
    [57924531]={ "33568", "Kaliri Egg", "25 Garrison Resources", "", "default", "treasure_smv","113271"},
    [58882193]={ "35603", "Mikkal's Chest", "Trash Item", "", "default", "treasure_smv","113215"},
    [52882486]={ "37254", "Mushroom-Covered Chest", "25 Garrison Resources", "", "default", "treasure_smv","113388"},
    [66963349]={ "36507", "Orc Skeleton", "i526 Strength Ring", "", "default", "treasure_smv","116875"},
    [43756062]={ "33611", "Peaceful Offering 1", "Trash Items", "", "default", "treasure_smv","107650"},
    [45226049]={ "33610", "Peaceful Offering 2", "Trash Items", "", "default", "treasure_smv","107650"},
    [44486357]={ "33384", "Peaceful Offering 3", "Trash Items", "", "default", "treasure_smv","107650"},
    [44495914]={ "33612", "Peaceful Offering 4", "Trash Items", "", "default", "treasure_smv","107650"},
    [31223905]={ "33886", "Ronokk's Belongings", "i522 Strength Cloak", "", "default", "treasure_smv","109081"},
    [22893385]={ "33572", "Rotting Basket", "Trash Item", "Inside Bloodthorn Cave", "default", "treasure_smv","113373"},
    [36684455]={ "33573", "Rovo's Dagger", "i520 Agility Dagger", "", "default", "treasure_smv","113378"},
    [67058418]={ "33565", "Scaly Rylak Egg", "Trash Item", "!!! LEVEL 100 AREA !!!", "default", "treasure_smv","44722"},
    [45822458]={ "33570", "Shadowmoon Exile Treasure", "25 Garrison Resources", "In a cave below Exile Rise", "default", "treasure_smv","113388"},
    [29994536]={ "35919", "Shadowmoon Sacrificial Dagger", "i524 Caster Dagger", "", "default", "treasure_smv","113563"},
    [28233924]={ "33883", "Shadowmoon Treasure", "Garrison Resources", "", "default", "treasure_smv","824"},
    [27050248]={ "35280", "Stolen Treasure", "Garrison Resources", "", "default", "treasure_smv","824"},
    [55821997]={ "35600", "Strange Spore", "Pet", "On top of the giant mushroom", "default", "treasure_smv","118104"},
    [37192601]={ "35677", "Sunken Fishing boat", "Fish", "", "default", "treasure_smv","118414"},
    [28820720]={ "35279", "Sunken Treasure", "Garrison Resources", "", "default", "treasure_smv","824"},
    [55297487]={ "35580", "Swamplighter Hive", "Toy", "", "default", "treasure_smv","117550"},
    [35854087]={ "33540", "Uzko's Knickknacks", "i525 Agility/Intellect Leather Boots", "", "default", "treasure_smv","113546"},
    [34214353]={ "33866", "Veema's Herb Bag", "Herbs", "", "default", "treasure_smv","109124"},
    [51147912]={ "33574", "Vindicator's Cache", "Toy", "!!! LEVEL 100 AREA !!!", "default", "treasure_smv","113375"},
    [39208391]={ "33566", "Waterlogged Chest", "i520 Strength Fist Weapon + Garrison Resources", "", "default", "treasure_smv","113372"},
    [37203640]={ "33061", "Amaukwa", "i516 Agility/Intellect Mail Body", "Flies around a very large area", "skull_grey", "rare_smv","109060"},
    [50807880]={ "37356", "Aqualir", "i620 Intellect Ring", "!!! Level 101 !!!", "skull_blue", "rare_h_smv","119387"},
    [68208480]={ "37410", "Avalanche", "i620 Strength 1H Mace", "!!! Level 100 !!!", "skull_blue", "rare_h_smv","119400"},
    [52801680]={ "35731", "Ba'ruun", "Reusable Food without Buff", "", "skull_grey", "rare_smv","113540"},
    [43807740]={ "33383", "Brambleking Fili", "i620 Agility Staff", "!!! Level 100 !!!", "skull_blue", "rare_h_smv","117551"},
    [48604360]={ "33064", "Dark Emanation", "i516 Intellect Fistweapon", "Inside a cave; kill cultists to make him attackable", "skull_grey", "rare_smv","109075"},
    [41008300]={ "35448", "Darkmaster Go'vid", "i525 Intellect Staff + Lobstrok Summon", "", "skull_grey", "rare_smv","113548"},
    [49604200]={ "35555", "Darktalon", "i520 Agility Cloak", "", "skull_grey", "rare_smv","113541"},
    [46007160]={ "37351", "Demidos", "i620 Agility/Strength Tank Neck + Pet + Achievement", "!!! Level 102 !!! To get to his plateau from Sorcethar's Rise, jump up on rocks on the east side", "skull_green", "rare_h_smv","119377"},
    [67806380]={ "35688", "Enavra", "i523 Intellect Neck", "Interacting with her corpse spawns her spirit to fight", "skull_grey", "rare_smv","113556"},
    [61606180]={ "35725", "Faebright", "i526 Agility/Intellect Leather Pants", "", "skull_grey", "rare_smv","113557"},
    [37404880]={ "35558", "Hypnocroak", "Toy", "", "skull_green", "rare_smv","113631"},
    [57404840]={ "35909", "Insha'tar", "i520 Agility/Intellect Mail Boots", "", "skull_grey", "rare_smv","113571"},
    [40804440]={ "33043", "Killmaw", "i516 Agility Dagger", "", "skull_grey", "rare_smv","109078"},
    [32203500]={ "33039", "Ku'targ the Voidseer", "i516 Agility/Intellect Mail Gloves", "", "skull_grey", "rare_smv","109061"},
    [48007760]={ "37355", "Lady Temptessa", "i620 Agility/Intellect Leather Boots", "!!! Level 101 !!!", "skull_blue", "rare_h_smv","119360"},
    [37601460]={ "33055", "Leaf-Reader Kurri", "i518 Trinket Versatility + Heal Proc", "", "skull_grey", "rare_smv","108907"},
    [44802080]={ "35906", "Mad King Sporeon", "i519 Agility Staff", "", "skull_grey", "rare_smv","113561"},
    [29605080]={ "37357", "Malgosh Shadowkeeper", "i620 Agility/Intellect Mail Helm", "!!! Level 100 !!!", "skull_blue", "rare_h_smv","119369"},
    [51807920]={ "37353", "Master Sergeant Milgra", "i620 Agility/Intellect Mail Gloves", "!!! Level 101 !!!", "skull_blue", "rare_h_smv","119368"},
    [38607020]={ "35523", "Morva Soultwister", "i520 1H Caster Mace", "", "skull_grey", "rare_smv","113559"},
    [44005760]={ "33642", "Mother Om'ra", "i522 Trinket Int + Mastery Proc", "Kill cultists to make her attackable", "skull_grey", "rare_smv","113527"},
    [58408680]={ "37409", "Nagidna", "i620 Agility/Intellect Leather Shoulders", "!!! Level 100 !!! In a Cave - Entrance is at 59,89", "skull_blue", "rare_h_smv","119364"},
    [50207240]={ "37352", "Quartermaster Hershak", "i620 Strength/Intellect Plate Pants", "!!! Level 101 !!!", "skull_blue", "rare_h_smv","119382"},
    [48602260]={ "35553", "Rai'vosh", "Reusable Slowfall Item", "", "skull_grey", "rare_smv","113542"},
    [53005060]={ "34068", "Rockhoof", "i516 Strength Shield", "", "skull_grey", "rare_smv","109077"},
    [48208100]={ "37354", "Shadowspeaker Niir", "i620 Caster Dagger", "!!! Level 101 !!!", "skull_blue", "rare_h_smv","119396"},
    [61005520]={ "35732", "Shinri", "400% Ground Mount with Cooldown", "Roams in a large area - often evades and despawns", "skull_grey", "rare_smv","113543"},
    [61408880]={ "37411", "Slivermaw", "i620 Strength 2H Sword", "!!! Level 100 !!!", "skull_blue", "rare_h_smv","119411"},
    [27604360]={ "36880", "Sneevel", "i519 Cloth Pants", "", "skull_grey", "rare_smv","118734"},
    [21602100]={ "33640", "Veloss", "i516 Intellect Ring", "", "skull_grey", "rare_smv","108906"},
    [54607060]={ "33643", "Venomshade", "i516 Agility/Intellect Leather Boots", "", "skull_grey", "rare_smv","108957"},
    [31905720]={ "37359", "Voidreaver Urnae", "i620 Agility 1H Axe", "!!! Level 100 !!!", "skull_blue", "rare_h_smv","119392"},
    [32604140]={ "35847", "Voidseer Kalurg", "i516 Cloth Waist", "Kill cultists to make him attackable", "skull_grey", "rare_smv","109074"},
    [48806640]={ "33389", "Yggdrel", "Toy", "", "skull_green", "rare_smv","113570"},
    [29405150]={ "37357", "Malgosh Shadowkeeper", "i620 Agility/Intellect Mail Helm", "!!! Level 100 !!!", "skull_blue", "rare_h_smv","119369"},
    [54003040]={ "99999900", "Pathrunner", "", "", "skull_orange", "mount_pr", "116773"},
    [43003220]={ "99999900", "Pathrunner", "", "", "skull_orange", "mount_pr", "116773"},
    [39603660]={ "99999900", "Pathrunner", "", "", "skull_orange", "mount_pr", "116773"},
    [44604380]={ "99999900", "Pathrunner", "", "", "skull_orange", "mount_pr", "116773"},
    [56205240]={ "99999900", "Pathrunner", "", "", "skull_orange", "mount_pr", "116773"},
    [45806820]={ "99999900", "Pathrunner", "", "", "skull_orange", "mount_pr", "116773"},
    [50907250]={ "99999901", "Void Talon", "Random Portal Spawn", "", "skull_purple", "mount_vt", "121815"},
    [49607160]={ "99999901", "Void Talon", "Random Portal Spawn", "", "skull_purple", "mount_vt", "121815"},
    [41907570]={ "99999901", "Void Talon", "Random Portal Spawn", "", "skull_purple", "mount_vt", "121815"},
    [48706990]={ "99999901", "Void Talon", "Random Portal Spawn", "", "skull_purple", "mount_vt", "121815"},
    [43207100]={ "99999901", "Void Talon", "Random Portal Spawn", "", "skull_purple", "mount_vt", "121815"},
    [46607000]={ "99999901", "Void Talon", "Random Portal Spawn", "", "skull_purple", "mount_vt", "121815"},
    [50307130]={ "99999901", "Void Talon", "Random Portal Spawn", "", "skull_purple", "mount_vt", "121815"},
}

nodes["FrostfireRidge"] = {
    [23172495]={ "33916", "Arena Master's War Horn", "Toy", "Up in the stands above the arena", "default", "treasure_ffr","108735"},
    [24242712]={ "33501", "Arena Spectator's Chest", "Alcoholic Beverages", "On top of the stone arch; jump to it from the top of the nearby tower", "default", "treasure_ffr","63293"},
    [61904254]={ "33511", "Borrok the Devourer", "i516 Intellect Shield", "Feed him 20 Ogres to get the loot", "default", "treasure_ffr","112110"},
    [42161930]={ "34520", "Burning Pearl", "i525 Trinket Multistrike + Mastery Proc", "!!! LEVEL 100 AREA !!!", "default", "treasure_ffr","120341"},
    [50161870]={ "33531", "Clumsy Cragmaul Brute", "i516 Agility/Intellect Mail Helm", "!!! LEVEL 100 AREA !!! On lower cliff ledge", "default", "treasure_ffr","112096"},
    [42663175]={ "33940", "Crag-Leaper's Cache", "i516 Agility/Intellect Mail Boots", "Jump on the spears in the wall to reach it", "default", "treasure_ffr","112187"},
    [40902010]={ "34473", "Envoy's Satchel", "Trash Item", "!!! LEVEL 100 AREA !!!", "default", "treasure_ffr","110536"},
    [43665562]={ "34841", "Forgotten Supplies", "Garrison Resources", "", "default", "treasure_ffr","824"},
    [24184860]={ "34507", "Frozen Frostwolf Axe", "i516 Spellpower Axe", "in a cave", "default", "treasure_ffr","110689"},
    [57175216]={ "34476", "Frozen Orc Skeleton", "i516 Trinket Mastery + Pet Proc", "", "default", "treasure_ffr","111554"},
    [25522050]={ "34648", "Gnawed Bone", "i516 Agility Dagger", "", "default", "treasure_ffr","111415"},
    [66712640]={ "33948", "Goren Leftovers", "25 Garrison Resources", "!!! LEVEL 100 AREA !!! In a cave on top of a mountain, path upwards starts at 69.3, 24", "default", "treasure_ffr","111543"},
    [68124586]={ "33947", "Grimfrost Treasure", "Garrison Resources", "", "default", "treasure_ffr","824"},
    [56727186]={ "36863", "Iron Horde Munitions", "Garrison Resources", "", "default", "treasure_ffr","824"},
    [68906910]={ "33017", "Iron Horde Supplies", "Garrison Resources", "", "default", "treasure_ffr","824"},
    [21890963]={ "33926", "Lagoon Pool", "Toy", "Requires Fishing", "default", "treasure_ffr","108739"},
    [19211202]={ "34642", "Lucky Coin", "Flavor Item - Gold Coin", "Sells for 25g", "default", "treasure_ffr","111408"},
    [38303782]={ "33502", "Obsidian Petroglyph", "Consumable for 5% rested XP", "On a mountain; ramp starts up the mountain at 39, 42.5", "default", "treasure_ffr","112087"},
    [28296663]={ "34470", "Pale Fishmonger", "Fish", "", "default", "treasure_ffr","111666"},
    [21685076]={ "34931", "Pale Loot Sack", "Garrison Resources", "In a cave", "default", "treasure_ffr","824"},
    [37265914]={ "34967", "Raided Loot", "Garrison Resources", "On top of the tower", "default", "treasure_ffr","824"},
    [09834533]={ "34641", "Sealed Jug", "Flavor Item - Lore", "", "default", "treasure_ffr","111407"},
    [27654280]={ "33500", "Slave's Stash", "Alcoholic Beverages", "", "default", "treasure_ffr","43696"},
    [23971291]={ "34647", "Snow-Covered Strongbox", "Gold", "", "default", "treasure_ffr",""},
    [16124972]={ "33942", "Supply Dump", "Garrison Resources", "", "default", "treasure_ffr","824"},
    [64722573]={ "33946", "Survivalist's Cache", "Garrison Resources", "", "default", "treasure_ffr","824"},
    [34192348]={ "32803", "Thunderlord Cache", "i516 Agility/Strength Polearm", "", "default", "treasure_ffr","107658"},
    [64406586]={ "33505", "Wiggling Egg", "Pet", "", "default", "treasure_ffr","112107"},
    [54843545]={ "33525", "Young Orc Traveler", "unknown", "You need to Collect Parts from Young Orc Woman and Young Orc Traveler to finish this", "default", "treasure_ffr","112206"},
    [63401470]={ "33525", "Young Orc Woman", "unknown", "You need to Collect Parts from Young Orc Woman and Young Orc Traveler to finish this", "default", "treasure_ffr","112206"},
    [39661718]={ "33532", "Cragmaul Cache", "Primal Spirit + Apexis Crystals", "!!! LEVEL 100 AREA !!!", "default", "treasure_ffr","120945"},
    [45365034]={ "33011", "Grizzled Frostwolf Veteran", "i516 Trinket Stamina + 2% Heal on Kill", "Loot contained in Dusty Chest after talking to NPC and defeating waves of orcs", "default", "treasure_ffr","106899"},
    [88605740]={ "37525", "Ak'ox the Slaughterer", "i620 Agility/Intellect Leather Waist", "!!! Level 100 !!!", "skull_blue", "rare_h_ffr","119365"},
    [27405000]={ "34497", "Breathless", "Toy", "", "skull_green", "rare_ffr","111476"},
    [66403140]={ "33843", "Broodmother Reeg'ak", "i516 Trinket Intellect + Multistrike Proc", "", "skull_grey", "rare_ffr","111533"},
    [34002320]={ "32941", "Canyon Icemother", "25 Garrison Resources", "", "skull_grey", "rare_ffr","101436"},
    [41206820]={ "34843", "Chillfang", "i513 Agility/Intellect Leather Pants", "", "skull_grey", "rare_ffr","111953"},
    [40404700]={ "33014", "Cindermaw", "i516 Caster Dagger", "", "skull_grey", "rare_ffr","111490"},
    [25405500]={ "34129", "Coldstomp the Griever", "i516 Intellect Neck", "", "skull_grey", "rare_ffr","112066"},
    [54606940]={ "34131", "Coldtusk", "i516 Agility/Strength 1H Sword", "", "skull_grey", "rare_ffr","111484"},
    [67407820]={ "34477", "Cyclonic Fury", "i516 Cloth Shoulders", "", "skull_grey", "rare_ffr","112086"},
    [71404680]={ "33504", "Firefury Giant", "i516 Offhand", "", "skull_grey", "rare_ffr","107661"},
    [54602220]={ "32918", "Giant-Slayer Kul", "i516 Trinket Versatility + Agility Proc", "", "skull_grey", "rare_ffr","111530"},
    [70003600]={ "37562", "Gorg'ak the Lava Guzzler", "i620 Strength Fistweapon", "!!! Level 100 !!!", "skull_blue", "rare_h_ffr","111545"},
    [70003600]={ "37388", "Gorivax", "i620 Intellect Cloth Bracer", "", "skull_blue", "rare_h_ffr","119358"},
    [38606300]={ "34865", "Grutush the Pillager", "i513 Agility/Intellect Mail Pants", "", "skull_grey", "rare_ffr","112077"},
    [50305260]={ "34825", "Gruuk", "i513 Trinket Haste + Critical Strike", "", "skull_grey", "rare_ffr","111948"},
    [47005520]={ "34839", "Gurun", "i513 Strength Cloak", "", "skull_grey", "rare_ffr","111955"},
    [68801940]={ "37382", "Hoarfrost", "i620 Intellect Spirit Ring", "!!! Level 101 !!!", "skull_blue", "rare_h_ffr","119415"},
    [58603420]={ "34130", "Huntmaster Kuang", "Garrison Resources", "", "skull_grey", "rare_ffr","824"},
    [48202340]={ "37386", "Jabberjaw", "i620 Caster Shield", "!!! Level 101 !!!", "skull_blue", "rare_h_ffr","119390"},
    [61602640]={ "34708", "Jehil the Climber", "i516 Agility/Intellect Leather Boots", "", "skull_grey", "rare_ffr","112078"},
    [43002100]={ "37387", "Moltnoma", "i620 Cloth Shoulders", "!!! Level 101 !!!", "skull_blue", "rare_h_ffr","119356"},
    [70002700]={ "37381", "Mother of Goren", "i620 Strength Neck", "!!! Level 101 !!!", "skull_blue", "rare_h_ffr","119376"},
    [83604720]={ "37402", "Ogom the Mangler", "i620 Agility/Intellect Leather Bracer", "!!! Level 100 !!!", "skull_blue", "rare_h_ffr","119366"},
    [36803400]={ "33938", "Primalist Mur'og", "i516 Cloth Pants", "", "skull_grey", "rare_ffr","111576"},
    [86604880]={ "37401", "Ragore Driftstalker", "i620 Agility/Intellect Leather Chest", "!!! Level 100 !!!", "skull_blue", "rare_h_ffr","119359"},
    [76406340]={ "34132", "Scout Goreseeker", "i516 Agility/Intellect Leather Body", "", "skull_grey", "rare_ffr","112094"},
    [45001500]={ "37385", "Slogtusk the Corpse-Eater", "i620 Agility/Intellect Leather Helm", "!!! Level 101 !!!", "skull_blue", "rare_h_ffr","119362"},
    [38201600]={ "37383", "Son of Goramal", "i620 Caster Mace", "!!! Level 101 !!!", "skull_blue", "rare_h_ffr","119399"},
    [26803160]={ "34133", "The Beater", "i516 Strength 2H Mace", "", "skull_grey", "rare_ffr","111475"},
    [72203300]={ "37361", "The Bone Crawler", "i620 Intellect/Strength Plate Chest", "!!! Level 101 !!!", "skull_blue", "rare_h_ffr","111534"},
    [43600940]={ "37384", "Tor'goroth", "i620 Offhand + Flavor Item", "!!! Level 101 !!!", "skull_blue", "rare_h_ffr","119379"},
    [40601240]={ "34522", "Ug'lok the Frozen", "i620 Intellect Staff", "!!! Level 101 !!!", "skull_blue", "rare_h_ffr","119409"},
    [72402420]={ "37378", "Valkor", "100 Garrison Resources", "!!! Level 101 !!!", "skull_blue", "rare_h_ffr","119416"},
    [70603900]={ "37379", "Vrok the Ancient", "100 Garrison Resources", "!!! Level 101 !!!", "skull_blue", "rare_h_ffr","119416"},
    [40402780]={ "34559", "Yaga the Scarred", "i516 Agility/Intellect Leather Waist", "On the lower cliff ledge", "skull_grey", "rare_ffr","111477"},
    [84604680]={ "37403", "Earthshaker Holar", "i620 Agility Neck", "!!! Level 100 !!!", "skull_blue", "rare_h_ffr","119374"},
    [66602540]={ "37380", "Gibblette the Cowardly", "i620 Agility Cloak + Flavor item", "!!! Level 101 !!! In a cave on top of a mountain, path upwards starts at 69.3, 24", "skull_blue", "rare_h_ffr","119349"},
    [86804500]={ "37404", "Kaga the Ironbender", "i620 Agility/Intellect Mail Waist", "!!! Level 100 !!!", "skull_blue", "rare_h_ffr","119372"},
    [63407940]={ "99999902", "Gorok", "", "", "skull_orange", "mount_go", "116674"},
    [22806640]={ "99999902", "Gorok", "", "", "skull_orange", "mount_go", "116674"},
    [64806300]={ "99999902", "Gorok", "", "", "skull_orange", "mount_go", "116674"},
    [51805060]={ "99999902", "Gorok", "", "", "skull_orange", "mount_go", "116674"},
    [58001840]={ "99999902", "Gorok", "", "", "skull_orange", "mount_go", "116674"},
    [15804900]={ "99999903", "Nok-Karosh", "", "Location is approximate", "skull_yellow", "mount_no", "116794"},
    [51001990]={ "99999904", "Void Talon", "Random Portal Spawn", "", "skull_purple", "mount_vt", "121815"},
    [52501780]={ "99999904", "Void Talon", "Random Portal Spawn", "", "skull_purple", "mount_vt", "121815"},
    [53801730]={ "99999904", "Void Talon", "Random Portal Spawn", "", "skull_purple", "mount_vt", "121815"},
    [47702750]={ "99999904", "Void Talon", "Random Portal Spawn", "", "skull_purple", "mount_vt", "121815"},
}

nodes["BladespireFortress"] = {
    [37106980]={ "35370", "Doorogs Secret Stash", "Gold + Trash Item", "Second floor of Bladespire Citadel, outside", "default", "treasure_ffr_bsf","113189"},
    [31406670]={ "35367", "Gorr'thogg's Personal Reserve", "Alcoholic Beverages", "Top floor of Bladespire Citadel, next to the throne", "default", "treasure_ffr_bsf","118108"},
    [36402880]={ "35347", "Ogre Booty", "Garrison Resources", "Second floor of Bladespire Citadel", "default", "treasure_ffr_bsf","824"},
    [53102790]={ "35368", "Ogre Booty", "Gold", "First floor of Bladespire Citadel; have to climb some crates to reach the chest", "default", "treasure_ffr_bsf",""},
    [49106790]={ "35369", "Ogre Booty", "Gold", "First floor of Bladespire Citadel; have to climb some crates to reach the chest", "default", "treasure_ffr_bsf",""},
    [46201560]={ "35371", "Ogre Booty", "Gold", "Second floor of Bladespire Citadel", "default", "treasure_ffr_bsf",""},
    [52605200]={ "35373", "Ogre Booty", "Gold", "Second floor of Bladespire Citadel; have to climb some crates to reach the chest", "default", "treasure_ffr_bsf",""},
    [51301790]={ "35567", "Ogre Booty", "Garrison Resources", "Second floor of Bladespire Citadel", "default", "treasure_ffr_bsf","824"},
    [76806220]={ "35568", "Ogre Booty", "Garrison Resources", "Second floor of Bladespire Citadel", "default", "treasure_ffr_bsf","824"},
    [70506780]={ "35569", "Ogre Booty", "Garrison Resources", "Second floor of Bladespire Citadel", "default", "treasure_ffr_bsf","824"},
    [44706450]={ "35570", "Ogre Booty", "Gold", "First floor of Bladespire Citadel", "default", "treasure_ffr_bsf",""},
}

nodes["Gorgrond"] = {
    [41735297]={ "36506", "Brokor's Sack", "i538 Caster Staff", "", "default", "treasure_gg","118702"},
    [42368341]={ "36625", "Discarded Pack", "Gold + Random Green", "", "default", "treasure_gg",""},
    [41827802]={ "36658", "Evermorn Supply Cache", "Random Green", "", "default", "treasure_gg",""},
    [40367660]={ "36621", "Explorer Canister", "50 Garrison Resources", "", "default", "treasure_gg","118710"},
    [40047223]={ "36170", "Femur of Improbability", "Trash Item", "", "default", "treasure_gg","118715"},
    [46104999]={ "36651", "Harvestable Precious Crystal", "Garrison Resources", "", "default", "treasure_gg","824"},
    [42584685]={ "35056", "Horned Skull", "Garrison Resources", "", "default", "treasure_gg","824"},
    [43694248]={ "36618", "Iron Supply Chest", "Garrison Resources", "", "default", "treasure_gg","824"},
    [44207427]={ "35709", "Laughing Skull Cache", "Garrison Resources", "Up in a tree", "default", "treasure_gg","824"},
    [43109290]={ "34241", "Ockbar's Pack", "Trash Item", "", "default", "treasure_gg","118227"},
    [52516696]={ "36509", "Odd Skull", "i535 Offhand", "", "default", "treasure_gg","118717"},
    [46244295]={ "36521", "Petrified Rylak Egg", "Trash Item", "", "default", "treasure_gg","118707"},
    [43957055]={ "36118", "Pile of Rubble", "Random Green", "", "default", "treasure_gg",""},
    [53127449]={ "36654", "Remains of Balik Orecrusher", "Trash Item", "", "default", "treasure_gg","118714"},
    [57845597]={ "36605", "Remains of Balldir Deeprock", "Trash Item", "", "default", "treasure_gg","118703"},
    [39036805]={ "36631", "Sasha's Secret Stash", "Gold + Random Green", "", "default", "treasure_gg",""},
    [44954262]={ "36634", "Sniper's Crossbow", "i539 Crossbow", "", "default", "treasure_gg","118713"},
    [48129337]={ "36604", "Stashed Emergency Rucksack", "Gold + Random Green", "", "default", "treasure_gg",""},
    [52977995]={ "34940", "Strange Looking Dagger", "i537 Agility Dagger", "", "default", "treasure_gg","118718"},
    [57086530]={ "37249", "Strange Spore", "Pet", "On top of a mushroom slice sticking out of the cliff", "default", "treasure_gg","118106"},
    [45694972]={ "36610", "Suntouched Spear", "Trash Item", "", "default", "treasure_gg","118708"},
    [59296379]={ "36628", "Vindicator's Hammer", "i539 Strength 2H Mace", "", "default", "treasure_gg","118712"},
    [48944731]={ "36203", "Warm Goren Egg", "Egg which hatches into a Toy after 7 days", "", "default", "treasure_gg","118705"},
    [49284363]={ "36596", "Weapons Cache", "100 Garrison Resources", "", "default", "treasure_gg","107645"},
    [58604120]={ "37371", "Alkali", "i620 Agility/Intellect Leather Gloves", "!!! Level 100 !!!", "skull_blue", "rare_h_gg","119361"},
    [40007900]={ "35335", "Bashiok", "Toy", "", "skull_green", "rare_gg","118222"},
    [69204460]={ "37369", "Basten + Nultra + Valstil", "Toy + i620 Cloth Waist", "!!! Level 100 !!! All 3 together", "skull_green", "rare_h_gg","119357"},
    [39407460]={ "36597", "Berthora", "i532 Agility/Intellect Mail Shoulders", "", "skull_grey", "rare_gg","118232"},
    [46003360]={ "37368", "Blademaster Ro'gor", "i620 Cloth Boots", "!!! Level 101 !!!", "skull_blue", "rare_h_gg","119228"},
    [53404460]={ "35503", "Char the Burning", "i536 2H Caster Mace", "", "skull_grey", "rare_gg","118212"},
    [48202100]={ "37362", "Defector Dazgo", "i620 Strength Polearm", "!!! Level 101 !!!", "skull_blue", "rare_h_gg","119224"},
    [57603580]={ "37370", "Depthroot", "i620 Agility Polearm", "!!! Level 100 !!! One of two possible Spawnpoints", "skull_blue", "rare_h_gg","119406"},
    [72604040]={ "37370", "Depthroot", "i620 Agility Polearm", "!!! Level 100 !!! One of two possible Spawnpoints", "skull_blue", "rare_h_gg","119406"},
    [50002380]={ "37366", "Durp the Hated", "i620 Agility Leather Waist", "!!! Level 101 !!!", "skull_blue", "rare_h_gg","119225"},
    [72803580]={ "37373", "Firestarter Grash", "i620 Strength/Intellect Plate Gloves", "!!! Level 100 !!! One of two possible Spawnpoints", "skull_blue", "rare_h_gg","119381"},
    [58003640]={ "37373", "Firestarter Grash", "i620 Strength/Intellect Plate Gloves", "!!! Level 100 !!! One of two possible Spawnpoints", "skull_blue", "rare_h_gg","119381"},
    [57406860]={ "36387", "Fossilwood the Petrified", "Toy", "", "skull_green", "rare_gg","118221"},
    [41804540]={ "36391", "Gelgor of the Blue Flame", "i534 Trinket Versatility + Intellect Proc", "", "skull_grey", "rare_gg","118230"},
    [46205080]={ "36204", "Glut", "i534 Trinket Agility + Multistrike Proc", "", "skull_grey", "rare_gg","118229"},
    [52805360]={ "37413", "Gnarljaw", "i620 Intellect Fistweapon", "!!! Level 100 !!!", "skull_blue", "rare_h_gg","119397"},
    [46804320]={ "36186", "Greldrok the Cunning", "i534 Strength 1H Mace", "", "skull_grey", "rare_gg","118210"},
    [59604300]={ "37375", "Grove Warden Yal", "i620 Intellect Cloak", "!!! Level 100 !!!", "skull_blue", "rare_h_gg","119414"},
    [52207020]={ "35908", "Hive Queen Skrikka", "i534 Spellpower Axe", "", "skull_grey", "rare_gg","118209"},
    [47002380]={ "37365", "Horgg", "i620 Agility/Intellect Mail Chest", "!!! Level 100 !!!", "skull_blue", "rare_h_gg","119229"},
    [55004660]={ "37377", "Hunter Bal'ra", "i620 Bow", "!!! Level 100 !!!", "skull_blue", "rare_h_gg","119412"},
    [47603060]={ "37367", "Inventor Blammo", "i620 Agility Gun + Flavor Item", "!!! Level 101 !!!", "skull_blue", "rare_h_gg","119226"},
    [52205580]={ "37412", "King Slime", "i620 Strength Cloak", "!!! Level 100 !!!", "skull_blue", "rare_h_gg","119351"},
    [50605320]={ "36178", "Mandrakor", "Pet", "", "skull_green", "rare_gg","118709"},
    [49003380]={ "37363", "Maniacal Madgard", "i620 Intellect Neck", "!!! Level 101 !!!", "skull_blue", "rare_h_gg","119230"},
    [61803930]={ "37376", "Mogamago", "i620 Strength Shield", "!!! Level 100 !!!", "skull_blue", "rare_h_gg","119391"},
    [47002580]={ "37364", "Morgo Kain", "i620 Strength/Intellect Plate Helm", "!!! Level 100 !!!", "skull_blue", "rare_h_gg","119227"},
    [53407820]={ "34726", "Mother Araneae", "i534 Agility Dagger", "", "skull_grey", "rare_gg","118208"},
    [37608140]={ "36600", "Riptar", "i539 Caster Dagger", "", "skull_grey", "rare_gg","118231"},
    [47804140]={ "36393", "Rolkor", "i539 Trinket Strength + Critical Strike Proc", "", "skull_grey", "rare_gg","118211"},
    [54207240]={ "36837", "Stompalupagus", "i537 2H Agility/Strength Mace", "", "skull_grey", "rare_gg","118228"},
    [38206620]={ "35910", "Stomper Kreego", "Ogre Brewing Kit", "Can create Alcoholic Beverages every 7 days", "skull_grey", "rare_gg","118224"},
    [40205960]={ "36394", "Sulfurious", "Toy", "", "skull_green", "rare_gg","114227"},
    [44609220]={ "36656", "Sunclaw", "i533 Agility Fistweapon", "", "skull_grey", "rare_gg","118223"},
    [59903200]={ "37374", "Swift Onyx Flayer", "i620 Agility/Intellect Mail Boots", "!!! Level 100 !!!", "skull_blue", "rare_h_gg","119367"},
    [64006180]={ "36794", "Sylldross", "i540 Agility/Intellect Leather Boots", "", "skull_grey", "rare_gg","118213"},
    [76004200]={ "37405", "Typhon", "Apexis Crystals", "!!! Level 100 !!!", "skull_blue", "rare_h_gg","823"},
    [63803160]={ "37372", "Venolasix", "i620 Agility Dagger", "!!! Level 100 !!!", "skull_blue", "rare_h_gg","119395"},
    [41402640]={ "99999905", "Poundfist", "", "", "skull_orange", "mount_po", "116792"},
    [50404180]={ "99999905", "Poundfist", "", "", "skull_orange", "mount_po", "116792"},
    [45404760]={ "99999905", "Poundfist", "", "", "skull_orange", "mount_po", "116792"},
    [43205540]={ "99999905", "Poundfist", "", "", "skull_orange", "mount_po", "116792"},
    [48805540]={ "99999905", "Poundfist", "", "", "skull_orange", "mount_po", "116792"},
    [56004000]={ "99999906", "Void Talon", "Random Portal Spawn", "", "skull_purple", "mount_vt", "121815"},
    [51603880]={ "99999906", "Void Talon", "Random Portal Spawn", "", "skull_purple", "mount_vt", "121815"},
    [54004500]={ "99999906", "Void Talon", "Random Portal Spawn", "", "skull_purple", "mount_vt", "121815"},
    [43403440]={ "99999906", "Void Talon", "Random Portal Spawn", "", "skull_purple", "mount_vt", "121815"},
}

nodes["Talador"] = {
    [36509610]={ "34182", "Aarko's Family Treasure", "i557 Crossbow", "", "default", "treasure_td","117567"},
    [62083238]={ "34236", "Amethyl Crystal", "100 Garrison Resources", "", "default", "treasure_td","116131"},
    [81843494]={ "34260", "Aruuna Mining Cart", "Ores", "", "default", "treasure_td","109118"},
    [62414797]={ "34252", "Barrel of Fish", "Fish", "", "default", "treasure_td","110506"},
    [33297680]={ "34259", "Bonechewer Remnants", "Garrison Resources", "", "default", "treasure_td","824"},
    [37607490]={ "34148", "Bonechewer Spear", "i566 Agility/Intellect Mail Gloves", "The spear spawns from the corpse of Viperlash", "default", "treasure_td","112371"},
    [73525137]={ "34471", "Bright Coin", "i560 Trinket Versatility + Bonus Armor proc", "", "default", "treasure_td","116127"},
    [70100700]={ "36937", "Burning Blade Cache", "Apexis Crystal", "", "default", "treasure_td","823"},
    [77044996]={ "34248", "Charred Sword", "i563 2H Strength Sword", "", "default", "treasure_td","116116"},
    [66508694]={ "34239", "Curious Deathweb Egg", "Toy", "", "default", "treasure_td","117569"},
    [58901200]={ "33933", "Deceptia's Smoldering Boots", "Toy", "", "default", "treasure_td","108743"},
    [55256671]={ "34253", "Draenei Weapons", "100 Garrison Resources", "", "default", "treasure_td","116118"},
    [35419656]={ "34249", "Farmer's Bounty", "Garrison Resources", "", "default", "treasure_td","824"},
    [57362866]={ "34238", "Foreman's Lunchbox", "Reusable Food/Drink", "", "default", "treasure_td","116120"},
    [64587920]={ "34251", "Iron Box", "i554 1H Strength Mace", "", "default", "treasure_td","117571"},
    [75003600]={ "33649", "Iron Scout", "Garrison Resources", "", "default", "treasure_td","824"},
    [57207540]={ "34134", "Isaari's Cache", "i564 Agility Neck", "", "default", "treasure_td","117563"},
    [65471137]={ "34233", "Jug of Aged Ironwine", "Alcoholic Beverages", "", "default", "treasure_td","117568"},
    [75684140]={ "34261", "Keluu's Belongings", "Gold", "", "default", "treasure_td",""},
    [53972769]={ "34290", "Ketya's Stash", "Pet", "", "default", "treasure_td","116402"},
    [38191242]={ "34258", "Light of the Sea", "Gold", "", "default", "treasure_td",""},
    [68805620]={ "34101", "Lightbearer", "Trash Item", "", "default", "treasure_td","109192"},
    [52562954]={ "34235", "Luminous Shell", "i557 Intellect Neck", "", "default", "treasure_td","116132"},
    [78211471]={ "34263", "Pure Crystal Dust", "i554 Agility Ring", "", "default", "treasure_td","117572"},
    [75784472]={ "34250", "Relic of Aruuna", "Trash Item", "", "default", "treasure_td","116128"},
    [46969174]={ "34256", "Relic of Telmor", "Trash Item", "", "default", "treasure_td","116128"},
    [64901330]={ "34232", "Rook's Tacklebox", "+4 Fishing Line", "", "default", "treasure_td","116117"},
    [65968513]={ "34276", "Rusted Lockbox", "Random Green", "", "default", "treasure_td",""},
    [39505520]={ "34254", "Soulbinder's Reliquary", "i558 Intellect Ring", "", "default", "treasure_td","117570"},
    [74602930]={ "35162", "Teroclaw Nest 1", "Pet", "Only one Teroclaw Nest can be looted", "default", "treasure_td","112699"},
    [39307770]={ "35162", "Teroclaw Nest 10", "Pet", "Only one Teroclaw Nest can be looted", "default", "treasure_td","112699"},
    [73503070]={ "35162", "Teroclaw Nest 2", "Pet", "Only one Teroclaw Nest can be looted", "default", "treasure_td","112699"},
    [74303400]={ "35162", "Teroclaw Nest 3", "Pet", "Only one Teroclaw Nest can be looted", "default", "treasure_td","112699"},
    [72803560]={ "35162", "Teroclaw Nest 4", "Pet", "Only one Teroclaw Nest can be looted", "default", "treasure_td","112699"},
    [72403700]={ "35162", "Teroclaw Nest 5", "Pet", "Only one Teroclaw Nest can be looted", "default", "treasure_td","112699"},
    [70903550]={ "35162", "Teroclaw Nest 6", "Pet", "Only one Teroclaw Nest can be looted", "default", "treasure_td","112699"},
    [70803200]={ "35162", "Teroclaw Nest 7", "Pet", "Only one Teroclaw Nest can be looted", "default", "treasure_td","112699"},
    [54105630]={ "35162", "Teroclaw Nest 8", "Pet", "Only one Teroclaw Nest can be looted", "default", "treasure_td","112699"},
    [39807670]={ "35162", "Teroclaw Nest 9", "Pet", "Only one Teroclaw Nest can be looted", "default", "treasure_td","112699"},
    [38338450]={ "34257", "Treasure of Ango'rosh", "Flavor Item - Throwing Rock", "", "default", "treasure_td","116119"},
    [65448860]={ "34255", "Webbed Sac", "Gold", "", "default", "treasure_td",""},
    [40608950]={ "34140", "Yuuri's Gift", "Garrison Resources", "", "default", "treasure_td","824"},
    [28397419]={ "36829", "Gift of the Ancients", "i563 Intellect Ring", "Inside a cave; turn all the three statues so they face away from the empty block in the middle to spawn the chest", "default", "treasure_td","118686"},
    [39304172]={ "34207", "Sparkling Pool", "Garrison Resources + Fishing items", "Requires Fishing", "default", "treasure_td","112623"},
    [46603520]={ "37338", "Avatar of Socrethar", "i620 Offhand", "!!! Level 101 !!!", "skull_blue", "rare_h_td","119378"},
    [44003800]={ "37339", "Bombardier Gu'gok", "i620 Crossbow", "!!! Level 101 !!!", "skull_blue", "rare_h_td","119413"},
    [37607040]={ "34165", "Cro Fleshrender", "i558 Strength 1H Mace", "", "skull_grey", "rare_td","116123"},
    [68201580]={ "34142", "Dr. Gloom", "Flavor Item - Stink Bombs", "", "skull_grey", "rare_td","112499"},
    [34205700]={ "34221", "Echo of Murmur", "Toy", "", "skull_green", "rare_td","113670"},
    [50808380]={ "35018", "Felbark", "i554 Caster Shield", "", "skull_grey", "rare_td","112373"},
    [50203520]={ "37341", "Felfire Consort", "i620 Agility Ring", "!!! Level 101 !!!", "skull_blue", "rare_h_td","119386"},
    [46005500]={ "34145", "Frenzied Golem", "i563 Agility/Strength 1H Sword or i563 Caster Dagger", "", "skull_grey", "rare_td","113287"},
    [67408060]={ "34929", "Gennadian", "i558 Trinket Agility + Mastery Proc", "", "skull_grey", "rare_td","116075"},
    [31806380]={ "34189", "Glimmerwing", "Shorttime Speedbuff with limited charges", "", "skull_grey", "rare_td","116113"},
    [22207400]={ "36919", "Grrbrrgle", "i588 Agility/Intellect Leather Waist", "Click on the Restless Crate", "skull_grey", "rare_td",""},
    [47603900]={ "37340", "Gug'tol", "i620 Caster Sword", "!!! Level 101 !!!", "skull_blue", "rare_h_td","119402"},
    [48002500]={ "37312", "Haakun the All-Consuming", "i620 Strength 1H Sword", "!!! Level 100 !!!", "skull_blue", "rare_h_td","119403"},
    [62004600]={ "34185", "Hammertooth", "i558 Agility/Intellect Mail Chest", "", "skull_grey", "rare_td","116124"},
    [78005040]={ "34167", "Hen-Mother Hami", "i556 Intellect Cloak", "", "skull_grey", "rare_td","112369"},
    [56606360]={ "35219", "Kharazos the Triumphant + Galzomar + Sikthiss", "Toy", "One of them - loot once", "skull_green", "rare_td","116122"},
    [66808540]={ "34498", "Klikixx", "Toy", "", "skull_green", "rare_td","116125"},
    [37203760]={ "37348", "Kurlosh Doomfang", "i620 Agility Dagger", "!!! Level 102 !!!", "skull_blue", "rare_h_td","119394"},
    [33803780]={ "37346", "Lady Demlash", "i620 Cloth Chest", "!!! Level 102 !!!", "skull_blue", "rare_h_td","119352"},
    [37802140]={ "37342", "Legion Vanguard", "i620 Strength/Intellect Plate Bracer", "!!! Level 101 !!!", "skull_blue", "rare_h_td","119385"},
    [49009200]={ "34208", "Lo'marg Jawcrusher", "i558 Strength Neck", "", "skull_grey", "rare_td","116070"},
    [30502640]={ "37345", "Lord Korinak", "i620 Strength Ring", "!!! Level 102 !!!", "skull_blue", "rare_h_td","119388"},
    [39004960]={ "37349", "Matron of Sin", "i620 Cloth Gloves", "!!! Level 102 !!!", "skull_blue", "rare_h_td","119353"},
    [86403040]={ "34859", "No'losh", "i558 Trinket Versatility + Int Proc", "", "skull_grey", "rare_td","116077"},
    [31404750]={ "37344", "Orumo the Observer", "i620 Intellect Neck + Pet", "!!! Level 102 !!! Requires 5 players to click objects to summon", "skull_green", "rare_h_td","119375"},
    [59505960]={ "34196", "Ra'kahn", "i563 Agility Fistweapon", "", "skull_grey", "rare_td","116112"},
    [41004200]={ "37347", "Shadowflame Terrorwalker", "i620 Strength 1H Axe", "!!! Level 102 !!!", "skull_blue", "rare_h_td","119393"},
    [41805940]={ "34671", "Shirzir", "i554 Agility/Intellect Leather Boots", "", "skull_grey", "rare_td","112370"},
    [67703550]={ "36858", "Steeltusk", "i559 Agility Polearm", "", "skull_grey", "rare_td","117562"},
    [46002740]={ "37337", "Strategist Ankor + Archmagus Tekar + Soulbinder Naylana", "i620 Intellect Cloak", "!!! Level 101 !!! All 3 together", "skull_blue", "rare_h_td","119350"},
    [59008800]={ "34171", "Taladorantula", "i565 Agility Sword", "", "skull_grey", "rare_td","116126"},
    [53909100]={ "34668", "Talonpriest Zorkra", "i560 Cloth Helm", "", "skull_grey", "rare_td","116110"},
    [63802070]={ "34945", "Underseer Bloodmane", "i554 Strength Ring", "don't kill his Pet", "skull_grey", "rare_td","112475"},
    [36804100]={ "37350", "Vigilant Paarthos", "i620 Intellect/Strength Plate Shoulders", "!!! Level 102 !!!", "skull_blue", "rare_h_td","119383"},
    [69603340]={ "34205", "Wandering Vindicator", "i554 Strength 1H Sword", "", "skull_grey", "rare_td","112261"},
    [38001460]={ "37343", "Xothear the Destroyer", "i620 Agility/Intellect Mail Shoulders + Flavor Item", "!!! Level 100 !!!", "skull_blue", "rare_h_td","119371"},
    [53802580]={ "34135", "Yazheera the Incinerator", "i554 Agility/Intellect Mail Bracer", "", "skull_grey", "rare_td","112263"},
    [78805540]={ "99999907", "Silthide", "", "", "skull_orange", "mount_si", "116767"},
    [67406000]={ "99999907", "Silthide", "", "", "skull_orange", "mount_si", "116767"},
    [61803220]={ "99999907", "Silthide", "", "", "skull_orange", "mount_si", "116767"},
    [62104500]={ "99999907", "Silthide", "", "", "skull_orange", "mount_si", "116767"},
    [55608060]={ "99999907", "Silthide", "", "", "skull_orange", "mount_si", "116767"},
    [47004800]={ "99999908", "Void Talon", "Random Portal Spawn", "", "skull_purple", "mount_vt", "121815"},
    [39705540]={ "99999908", "Void Talon", "Random Portal Spawn", "", "skull_purple", "mount_vt", "121815"},
    [52002600]={ "99999908", "Void Talon", "Random Portal Spawn", "", "skull_purple", "mount_vt", "121815"},
    [46205260]={ "99999908", "Void Talon", "Random Portal Spawn", "", "skull_purple", "mount_vt", "121815"},
    [51904120]={ "99999908", "Void Talon", "Random Portal Spawn", "", "skull_purple", "mount_vt", "121815"},
}

nodes["SpiresOfArak"] = {
    [40595497]={ "36458", "Abandoned Mining Pick", "i578 Strength 1H Axe", "Allows faster Mining in Draenor", "default", "treasure_soa","116913"},
    [36195446]={ "36462", "Admiral Taylor's Coffer", "Garrison Resources", "Requires An Old Key", "default", "treasure_soa","824"},
    [37705640]={ "36462", "An Old Key", "Key for a Chest in Admiral Taylors Garrison", "", "default", "treasure_soa","116020"},
    [49203721]={ "36445", "Assassin's Spear", "i580 Agility Polearm", "", "default", "treasure_soa","116835"},
    [55539086]={ "36367", "Campaign Contributions", "Gold", "", "default", "treasure_soa",""},
    [68428898]={ "36453", "Coinbender's Payment", "Garrison Resources", "", "default", "treasure_soa","824"},
    [36585791]={ "36418", "Ephial's Dark Grimoire", "i579 Offhand", "", "default", "treasure_soa","116914"},
    [50502210]={ "36246", "Fractured Sunstone", "Trash Item", "", "default", "treasure_soa","116919"},
    [37154750]={ "36420", "Garrison Supplies", "Garrison Resources", "", "default", "treasure_soa","824"},
    [41855042]={ "36451", "Garrison Workman's Hammer", "i580 Strength 1H Mace", "", "default", "treasure_soa","116918"},
    [48604450]={ "36386", "Gift of Anzu", "i585 Crossbow", "Drink an Elixir of Shadow Sight near the Shrine to get the Gift of Anzu", "default", "treasure_soa","118237"},
    [57007900]={ "36390", "Gift of Anzu", "i585 Caster 1H Sword", "Drink an Elixir of Shadow Sight near the Shrine to get the Gift of Anzu", "default", "treasure_soa","118241"},
    [46954044]={ "36389", "Gift of Anzu", "i585 Agility/Strength Polearm", "Drink an Elixir of Shadow Sight near the Shrine to get the Gift of Anzu", "default", "treasure_soa","118238"},
    [52031958]={ "36392", "Gift of Anzu", "i585 Caster Staff", "Drink an Elixir of Shadow Sight near the Shrine to get the Gift of Anzu", "default", "treasure_soa","118239"},
    [42402670]={ "36388", "Gift of Anzu", "i585 Wand", "Drink an Elixir of Shadow Sight near the Shrine to get the Gift of Anzu", "default", "treasure_soa","118242"},
    [61105537]={ "36381", "Gift of Anzu", "i585 Agility/Strength 1H Sword", "Drink an Elixir of Shadow Sight near the Shrine to get the Gift of Anzu", "default", "treasure_soa","118240"},
    [50332579]={ "36444", "Iron Horde Explosives", "Trash Item", "", "default", "treasure_soa","118691"},
    [50782874]={ "36247", "Lost Herb Satchel", "Herbs", "", "default", "treasure_soa","109124"},
    [47773612]={ "36411", "Lost Ring", "i578 Intellect Ring", "", "default", "treasure_soa","116911"},
    [52474280]={ "36416", "Misplaced Scroll", "Archaeology Fragments", "Requires Archaeology and possibly a little bit of jumping", "default", "treasure_soa_a",""},
    [42691832]={ "36244", "Misplaced Scrolls", "Archaeology Fragments", "Requires Archaeology and possibly a little bit of jumping", "default", "treasure_soa_a",""},
    [63586737]={ "36454", "Mysterious Mushrooms", "Herbs", "", "default", "treasure_soa","109127"},
    [60808780]={ "35481", "Nizzix's Chest", "Garrison Resources", "Click on Nizzix's Escape Pod at 60.9 88.0 and follow him to the shore", "default", "treasure_soa","824"},
    [53315552]={ "36403", "Offering to the Raven Mother 1", "Consumable for 5% rested XP", "", "default", "treasure_soa","118267"},
    [48355261]={ "36405", "Offering to the Raven Mother 2", "Consumable for 5% rested XP", "", "default", "treasure_soa","118267"},
    [48905470]={ "36406", "Offering to the Raven Mother 3", "Consumable for 5% rested XP", "", "default", "treasure_soa","118267"},
    [51886465]={ "36407", "Offering to the Raven Mother 4", "Consumable for 5% rested XP", "", "default", "treasure_soa","118267"},
    [60976387]={ "36410", "Offering to the Raven Mother 5", "Consumable for 5% rested XP", "", "default", "treasure_soa","118267"},
    [58706024]={ "36340", "Ogron Plunder", "Trash Items", "", "default", "treasure_soa","116921"},
    [36283934]={ "36402", "Orcish Signaling Horn", "i577 Trinket Multistrike + Strength Proc", "", "default", "treasure_soa","120337"},
    [36821716]={ "36243", "Outcast's Belongings 1", "Gold + Random Green", "", "default", "treasure_soa",""},
    [42172168]={ "36447", "Outcast's Belongings 2", "Gold + Random Green", "", "default", "treasure_soa",""},
    [46903406]={ "36446", "Outcast's Pouch", "Gold + Random Green", "", "default", "treasure_soa",""},
    [42961637]={ "36245", "Relics of the Outcasts 1", "Archaeology Fragments", "Requires Archaeology and possibly a little bit of jumping", "default", "treasure_soa_a",""},
    [45964415]={ "36354", "Relics of the Outcasts 2", "Archaeology Fragments", "Requires Archaeology and possibly a little bit of jumping", "default", "treasure_soa_a",""},
    [43162726]={ "36355", "Relics of the Outcasts 3", "Archaeology Fragments", "Requires Archaeology and possibly a little bit of jumping", "default", "treasure_soa_a",""},
    [67373983]={ "36356", "Relics of the Outcasts 4", "Archaeology Fragments", "Requires Archaeology and possibly a little bit of jumping", "default", "treasure_soa_a",""},
    [60215391]={ "36359", "Relics of the Outcasts 5", "Archaeology Fragments", "Requires Archaeology and possibly a little bit of jumping", "default", "treasure_soa_a",""},
    [51894892]={ "36360", "Relics of the Outcasts 6", "Archaeology Fragments", "Requires Archaeology and possibly a little bit of jumping", "default", "treasure_soa_a",""},
    [37375056]={ "36657", "Rooby's Roo", "i581 Strength Neck", "You need to feed the dog with Rooby Reat from the chef in the cellar", "default", "treasure_soa","116887"},
    [44331204]={ "36377", "Rukhmar's Image", "Trash Item", "", "default", "treasure_soa","118693"},
    [59179064]={ "36366", "Sailor Zazzuk's 180-Proof Rum", "Alcoholic Beverages", "", "default", "treasure_soa","116917"},
    [68333893]={ "36375", "Sethekk Idol", "Trash Item", "", "default", "treasure_soa","118692"},
    [71644859]={ "36450", "Sethekk Ritual Brew", "Healing Potions + Alcoholic Beverages", "", "default", "treasure_soa","109223"},
    [56232881]={ "36362", "Shattered Hand Cache", "Garrison Resources", "", "default", "treasure_soa","824"},
    [47923065]={ "36361", "Shattered Hand Lockbox", "True Steel Lockbox", "", "default", "treasure_soa","116920"},
    [60868461]={ "36456", "Shredder Parts", "Garrison Resources", "", "default", "treasure_soa","824"},
    [56294531]={ "36433", "Smuggled Apexis Artifacts", "Archaeology Fragments", "Requires Archaeology and possibly a little bit of jumping", "default", "treasure_soa_a",""},
    [59638134]={ "36365", "Spray-O-Matic 5000 XT", "Garrison Resources", "", "default", "treasure_soa","824"},
    [34142751]={ "36421", "Sun-Touched Cache 1", "Garrison Resources", "", "default", "treasure_soa","824"},
    [33292727]={ "36422", "Sun-Touched Cache 2", "Archaeology Fragments", "Requires Archaeology and possibly a little bit of jumping", "default", "treasure_soa_a",""},
    [54353255]={ "36364", "Toxicfang Venom", "100 Garrison Resources", "", "default", "treasure_soa","118695"},
    [66475653]={ "36455", "Waterlogged Satchel", "Gold + Random Green", "", "default", "treasure_soa",""},
    [57802220]={ "36374", "Statue of Anzu", "Trash Item", "", "default", "treasure_soa","118694"},
    [58208460]={ "36291", "Betsi Boombasket", "i583 Gun", "", "skull_grey", "rare_soa","116907"},
    [46802300]={ "35599", "Blade-Dancer Aeryx", "Trash Item", "", "skull_grey", "rare_soa","116839"},
    [64006480]={ "36283", "Blightglow", "i586 Agility/Intellect Leather Shoulders", "", "skull_grey", "rare_soa","118205"},
    [46402860]={ "36267", "Durkath Steelmaw", "i586 Agility/Intellect Mail Boots", "", "skull_grey", "rare_soa","118198"},
    [69005400]={ "37406", "Echidna", "unknown", "!!! Level 100 !!!", "skull_blue", "rare_h_soa",""},
    [54803960]={ "36297", "Festerbloom", "i584 Offhand", "", "skull_grey", "rare_soa","118200"},
    [25202420]={ "36943", "Gaze", "Garrison Resources", "", "skull_grey", "rare_soa","824"},
    [74404280]={ "37390", "Gluttonous Giant", "i620 Wand", "!!! Level 100 !!!", "skull_blue", "rare_h_soa","119404"},
    [33005900]={ "36305", "Gobblefin", "Trash Item", "", "skull_grey", "rare_soa","116836"},
    [59201500]={ "36887", "Hermit Palefur", "i582 Cloth Helm", "", "skull_grey", "rare_soa","118279"},
    [56609460]={ "36306", "Jiasska the Sporegorger", "i589 Trinket Haste + Int Proc", "", "skull_grey", "rare_soa","118202"},
    [62603740]={ "36268", "Kalos the Bloodbathed", "i588 Cloth Body", "", "skull_grey", "rare_soa","118735"},
    [53208900]={ "36396", "Mutafen", "i589 Strength 2H Mace", "", "skull_grey", "rare_soa","118206"},
    [36405240]={ "36129", "Nas Dunberlin", "i578 Agility/Strength Polearm", "", "skull_grey", "rare_soa","116837"},
    [66005500]={ "36288", "Oskiira the Vengeful", "i589 Agility Dagger", "", "skull_grey", "rare_soa","118204"},
    [59403740]={ "36279", "Poisonmaster Bortusk", "i583 Trinket Multistrike + DMG on Use", "", "skull_grey", "rare_soa","118199"},
    [38402780]={ "36470", "Rotcap", "Pet", "", "skull_green", "rare_soa","118107"},
    [69004880]={ "36276", "Sangrikrass", "i589 Agility/Intellect Leather Body", "", "skull_grey", "rare_soa","118203"},
    [71203380]={ "37392", "Shadow Hulk", "i620 Agility/Intellect Leather Pants", "!!! Level 100 !!!", "skull_blue", "rare_h_soa","119363"},
    [52003540]={ "36478", "Shadowbark", "i579 Caster Shield", "", "skull_grey", "rare_soa","118201"},
    [51800720]={ "37394", "Solar Magnifier", "i620 Intellect Polearm", "!!! Level 100 !!!", "skull_blue", "rare_h_soa","119407"},
    [33402200]={ "36265", "Stonespite", "i577 Agility/Intellect Mail Pants", "", "skull_grey", "rare_soa","116858"},
    [58604520]={ "36298", "Sunderthorn", "i578 Agility 1H Sword", "", "skull_grey", "rare_soa","116855"},
    [52805480]={ "36472", "Swarmleaf", "i582 Caster Staff", "", "skull_grey", "rare_soa","116857"},
    [54606320]={ "36278", "Talonbreaker", "i578 Agility Neck", "", "skull_grey", "rare_soa","116838"},
    [57407400]={ "36254", "Tesska the Broken", "i578 Intellect Neck", "", "skull_grey", "rare_soa","116852"},
    [71702010]={ "37360", "Formless Nightmare", "i620 Agility/Intellect Mail Bracer", "!!! Level 100 !!! Located inside Void Portal phase", "skull_blue", "rare_h_soa","119373"},
    [71404500]={ "37393", "Giga Sentinel", "i620 Agility 1H Sword", "!!! Level 100 !!!", "skull_blue", "rare_h_soa","119401"},
    [70402380]={ "37361", "Kenos the Unraveler", "i620 Cloth Helm", "!!! Level 100 !!! Located inside Void Portal phase; requires 3 players to click objects to summon", "skull_blue", "rare_h_soa","119354"},
    [74413864]={ "37391", "Mecha Plunderer", "i620 Agility 1H Mace", "!!! Level 100 !!!", "skull_blue", "rare_h_soa","119398"},
    [72401940]={ "37358", "Soul-Twister Torek", "Toy + i620 Caster Staff", "!!! Level 100 !!!", "skull_green", "rare_h_soa","119410"},
    [72903090]={ "37359", "Voidreaver Urnae", "i620 Agility 1H Axe", "!!! Level 100 !!!", "skull_blue", "rare_h_soa","119392"},
    [47002000]={ "99999909", "Void Talon", "Random Portal Spawn", "", "skull_purple", "mount_vt", "121815"},
    [50400610]={ "99999909", "Void Talon", "Random Portal Spawn", "", "skull_purple", "mount_vt", "121815"},
    [36551820]={ "99999909", "Void Talon", "Random Portal Spawn", "", "skull_purple", "mount_vt", "121815"},
    [60801120]={ "99999909", "Void Talon", "Random Portal Spawn", "", "skull_purple", "mount_vt", "121815"},
}

nodes["NagrandDraenor"] = {
    [73071080]={ "35951", "A Pile of Dirt", "Garrison Resources", "", "default", "treasure_ng","824"},
    [67655971]={ "35759", "Abandoned Cargo", "Random Greens", "", "default", "treasure_ng",""},
    [38404940]={ "36711", "Abu'Gar's Favorite Lure", "Abu'Gar's Favorite Lure", "Combine with the other Abu'Gar Parts for a follower (just north of Telaar)", "default", "treasure_ng","114245"},
    [85403870]={ "36711", "Abu'gar's Missing Reel", "Abu'Gar's Finest Reel", "Combine with the other Abu'Gar Parts for a follower (just north of Telaar)", "default", "treasure_ng","114243"},
    [65906120]={ "36711", "Abu'gar's Vitality", "Abu'gar's Vitality", "Combine with the other Abu'Gar Parts for a follower (just north of Telaar)", "default", "treasure_ng","114242"},
    [75816203]={ "36077", "Adventurer's Mace", "Random Green Mace", "", "default", "treasure_ng",""},
    [82275660]={ "35765", "Adventurer's Pack", "Random Green", "", "default", "treasure_ng",""},
    [45635200]={ "35969", "Adventurer's Pack", "Random Green", "", "default", "treasure_ng",""},
    [69955244]={ "35597", "Adventurer's Pack", "Random Green", "", "default", "treasure_ng",""},
    [56567294]={ "36050", "Adventurer's Pouch", "Garrison Resources", "On a ledge below a cliff; you need to fall from the top to reach it", "default", "treasure_ng","824"},
    [73931405]={ "35955", "Adventurer's Sack", "Random Green", "", "default", "treasure_ng",""},
    [81461307]={ "35953", "Adventurer's Staff", "i593 Caster Staff", "", "default", "treasure_ng","116640"},
    [73057554]={ "35673", "Appropriated Warsong Supplies", "Garrison Resources", "", "default", "treasure_ng","824"},
    [62546708]={ "36116", "Bag of Herbs", "Herbs", "", "default", "treasure_ng","109124"},
    [77312807]={ "35986", "Bone-Carved Dagger", "i597 Agility Dagger", "", "default", "treasure_ng","116760"},
    [77081662]={ "36174", "Bounty of the Elements", "Garrison Resources", "Use the elemental Stones to access", "default", "treasure_ng","824"},
    [81083725]={ "35661", "Brilliant Dreampetal", "Manareg Potion", "Take Explorer Renzo's Glider to get there [north-east of here]", "default", "treasure_ng","118262"},
    [85415347]={ "35696", "Burning Blade Cache", "Random Green", "", "default", "treasure_ng","824"},
    [66961949]={ "35954", "Elemental Offering", "Trash Item", "", "default", "treasure_ng","118234"},
    [78901556]={ "36036", "Elemental Shackles", "i605 Agility Ring", "", "default", "treasure_ng","118251"},
    [53407320]={ "900003", "Explorer Bibsi", "Nothing", "You need to use a rocket to get to her [south-east of her position]", "glider", "treasure_ng",""},
    [67601420]={ "900004", "Explorer Dez", "Nothing", "You can reach him from the east starting at the elemental plateau", "glider", "treasure_ng",""},
    [87204100]={ "900005", "Explorer Garix", "Nothing", "Is required for 2 Treasures [1 south, 1 south-east]", "glider", "treasure_ng",""},
    [75606460]={ "900006", "Explorer Razzuk", "Nothing", "Is required for some other Treasures", "glider", "treasure_ng",""},
    [83803380]={ "900007", "Explorer Renzo", "Nothing", "Is required for 3 Treasures [2 north-east, 1 south-west]", "glider", "treasure_ng",""},
    [45866629]={ "36020", "Fragment of Oshu'gun", "i607 Intellect Shield", "", "default", "treasure_ng","117981"},
    [73052153]={ "35692", "Freshwater Clam", "Trash Item", "", "default", "treasure_ng","118233"},
    [88901824]={ "35660", "Fungus-Covered Chest", "Garrison Resources", "Take Explorer Renzo's Glider to get there [south-west of here]", "default", "treasure_ng","824"},
    [75374711]={ "36074", "Gambler's Purse", "Flavor Item", "", "default", "treasure_ng","118236"},
    [43225755]={ "35987", "Genedar Debris", "Garrison Resources", "", "default", "treasure_ng","824"},
    [48066011]={ "35999", "Genedar Debris", "Garrison Resources", "", "default", "treasure_ng","824"},
    [48587279]={ "36008", "Genedar Debris", "Garrison Resources", "", "default", "treasure_ng","824"},
    [44696757]={ "36002", "Genedar Debris", "Garrison Resources", "", "default", "treasure_ng","824"},
    [55356828]={ "36011", "Genedar Debris", "Garrison Resources", "", "default", "treasure_ng","824"},
    [72976212]={ "35590", "Goblin Pack", "Garrison Resources", "Take Explorer Razzuk's Glider to get there [south-east of here]", "default", "treasure_ng","824"},
    [47207425]={ "35576", "Goblin Pack", "Garrison Resources", "Take Explorer Bibsi's Glider to get there [east of here]", "default", "treasure_ng","824"},
    [58285249]={ "35694", "Golden Kaliri Egg", "Trash Item", "In the nest in the tree", "default", "treasure_ng","118266"},
    [38345872]={ "36109", "Goldtoe's Plunder", "Gold", "Key on the Parrot", "default", "treasure_ng",""},
    [87107288]={ "36051", "Grizzlemaw's Bonepile", "Pet Toy", "", "default", "treasure_ng","118054"},
    [87624498]={ "35622", "Hidden Stash", "Garrison Resources", "Take Explorer Garix's Glider to get there [north of here]", "default", "treasure_ng","824"},
    [67384906]={ "36039", "Highmaul Sledge", "i605 Strength Ring", "", "default", "treasure_ng","118252"},
    [75236563]={ "36099", "Important Exploration Supplies", "Alcoholic Beverages", "", "default", "treasure_ng","61986"},
    [61765747]={ "36082", "Lost Pendant", "i593 Green Amulet", "", "default", "treasure_ng","116687"},
    [70531385]={ "35643", "Mountain Climber's Pack", "Garrison Resources", "Take Explorer Dez's Glider to get there [west of here]", "default", "treasure_ng","824"},
    [80967979]={ "36049", "Ogre Beads", "i605 Str Ring", "", "default", "treasure_ng","118255"},
    [57796205]={ "36115", "Pale Elixir", "Manareg Potion", "", "default", "treasure_ng","118278"},
    [58295931]={ "36021", "Pokkar's Thirteenth Axe", "i605 1H Strength Axe", "", "default", "treasure_ng","116688"},
    [72716092]={ "36035", "Polished Saberon Skull", "i605 Agility/Strength Ring", "", "default", "treasure_ng","118254"},
    [58507630]={ "900008", "Rocket to Explorer Bibsi", "Nothing", "Is required to get to Explorer Bibsi", "rocket", "treasure_ng",""},
    [75186494]={ "36102", "Saberon Stash", "Gold", "", "default", "treasure_ng",""},
    [89073313]={ "36857", "Smuggler's Cache", "Garrison Resources", "", "default", "treasure_ng","824"},
    [40346864]={ "37435", "Spirit Coffer", "Garrison Resources", "", "default", "treasure_ng","824"},
    [50128228]={ "35577", "Steamwheedle Supplies", "Garrison Resources", "Take Explorer Bibsi's Glider to get there [north-east of here]", "default", "treasure_ng","824"},
    [52678008]={ "35583", "Steamwheedle Supplies", "Garrison Resources", "Take Explorer Bibsi's Glider to get there [north of here]", "default", "treasure_ng","824"},
    [77835195]={ "35591", "Steamwheedle Supplies", "Garrison Resources", "Take Explorer Razzuk's Glider to get there [south of here]", "default", "treasure_ng","824"},
    [64591762]={ "35648", "Steamwheedle Supplies", "Garrison Resources", "Take Explorer Dez's Glider to get there [north-east of here]", "default", "treasure_ng","824"},
    [70601860]={ "35646", "Steamwheedle Supplies", "Garrison Resources", "Take Explorer Dez's Glider to get there [north-west of here]", "default", "treasure_ng","824"},
    [87602028]={ "35662", "Steamwheedle Supplies", "Garrison Resources", "Take Explorer Renzo's Glider to get there [south-west of here]", "default", "treasure_ng","824"},
    [88274262]={ "35616", "Steamwheedle Supplies", "Garrison Resources", "Take Explorer Garix's Glider to get there [north-west of here]", "default", "treasure_ng","824"},
    [64716583]={ "36046", "Telaar Defender Shield", "i605 Agility/Intellect Ring", "", "default", "treasure_ng","118253"},
    [37717065]={ "34760", "Treasure of Kull'krosh", "Garrison Resources", "", "default", "treasure_ng","824"},
    [49976651]={ "35579", "Void-Infused Crystal", "i613 2H Strength Sword", "Take Explorer Bibsi's Glider to get there [south-east of here]", "default", "treasure_ng","118264"},
    [51726029]={ "35695", "Warsong Cache", "Garrison Resources", "", "default", "treasure_ng","824"},
    [52414438]={ "36073", "Warsong Helm", "i609 Agility/Intellect Mail Helm", "", "default", "treasure_ng","118250"},
    [73047036]={ "35678", "Warsong Lockbox", "Garrison Resources", "", "default", "treasure_ng","824"},
    [76066990]={ "35682", "Warsong Spear", "Trash Item", "Take Explorer Razzuk's Glider to get there [north of here]", "default", "treasure_ng","118678"},
    [80656054]={ "35593", "Warsong Spoils", "Garrison Resources", "Take Explorer Razzuk's Glider to get there [west of here]", "default", "treasure_ng","824"},
    [89406588]={ "35976", "Warsong Supplies", "Garrison Resources", "", "default", "treasure_ng","824"},
    [64763573]={ "36071", "Watertight Bag", "20 Slot Bag", "", "default", "treasure_ng","118235"},
    [53386425]={ "36088", "Adventurer's Pouch", "Random Green", "In a cave; entrance is to the east", "default", "treasure_ng","824"},
    [35475725]={ "36846", "Spirit's Gift", "Garrison Resources", "", "default", "treasure_ng","824"},
    [84605340]={ "35778", "Ancient Blademaster", "i598 Strength Neck", "", "skull_grey", "rare_ng","116832"},
    [51001600]={ "37210", "Aogexon", "Reputation Item for Steamwheedle Preservation Society", "", "swprare", "rare_s_ng","118654"},
    [62601680]={ "37211", "Bergruu", "Reputation Item for Steamwheedle Preservation Society", "", "swprare", "rare_s_ng","118655"},
    [77006400]={ "35735", "Berserk T-300 Series Mark II", "Garrison Resources", "In a cave, opened with a switch", "skull_grey", "rare_ng","824"},
    [40001600]={ "37396", "Bonebreaker", "i620 Agility/Intellect Mail Pants", "", "skull_blue", "rare_h_ng","119370"},
    [43003640]={ "37400", "Brutag Grimblade", "i620 Intellect/Strength Plate Boots", "", "skull_blue", "rare_h_ng","119380"},
    [34607700]={ "34727", "Captain Ironbeard", "Toy + i607 Gun", "", "skull_green", "rare_ng","118244"},
    [64203000]={ "37221", "Dekorhan", "Reputation Item for Steamwheedle Preservation Society", "", "swprare", "rare_s_ng","118656"},
    [60003800]={ "37222", "Direhoof", "Reputation Item for Steamwheedle Preservation Society", "", "swprare", "rare_s_ng","118657"},
    [38602240]={ "37395", "Durg Spinecrusher", "i620 Agility 2H Mace", "", "skull_blue", "rare_h_ng","119405"},
    [89004120]={ "35623", "Explorer Nozzand", "Trash Item", "", "skull_grey", "rare_ng","118679"},
    [74801180]={ "35836", "Fangler", "Trash Items", "", "skull_grey", "rare_ng","116836"},
    [70004180]={ "35893", "Flinthide", "i609 Strength Shield", "", "skull_grey", "rare_ng","116807"},
    [48202220]={ "37223", "Gagrog the Brutal", "Reputation Item for Steamwheedle Preservation Society", "", "swprare", "rare_s_ng","118658"},
    [52205580]={ "35715", "Gar'lua", "i605 Trinket Multistrike + Wolf Proc", "", "skull_grey", "rare_ng","118246"},
    [42207860]={ "34725", "Gaz'orda", "i602 Intellect Ring", "In the cave", "skull_grey", "rare_ng","116798"},
    [66605660]={ "35717", "Gnarlhoof the Rabid", "i598 Trinket Multistrike + Agi Proc", "", "skull_grey", "rare_ng","116824"},
    [93202820]={ "35898", "Gorepetal", "i602 Agility/Intellect Leather Gloves", "The gloves let you gather herbs faster while in Draenor", "skull_grey", "rare_ng","116916"},
    [42003680]={ "37472", "Gortag Steelgrip", "Apexis Crystals", "Summoned by Signal Horn object using Secret Meeting Details item", "skull_blue", "rare_h_ng","824"},
    [84603660]={ "36159", "Graveltooth", "i609 Agility/Intellect Leather Bracer", "", "skull_grey", "rare_ng","118689"},
    [66805120]={ "35714", "Greatfeather", "i600 Cloth Body", "", "skull_grey", "rare_ng","116795"},
    [86007160]={ "35784", "Grizzlemaw", "i610 Strength Cloak", "", "skull_grey", "rare_ng","118687"},
    [80603040]={ "35923", "Hunter Blacktooth", "i609 Agility 2H Mace", "", "skull_grey", "rare_ng","118245"},
    [87005500]={ "34862", "Hyperious", "i597 Trinket Haste + Mastery Proc", "", "skull_grey", "rare_ng","116799"},
    [45803480]={ "37399", "Karosh Blackwind", "i620 Cloth Pants", "", "skull_blue", "rare_h_ng","119355"},
    [43803440]={ "37473", "Krahl Deadeye", "Apexis Crystals", "Summoned by Signal Horn object using Secret Meeting Details item", "skull_blue", "rare_h_ng",""},
    [58201200]={ "37398", "Krud the Eviscerator", "i620 Intellect/Strength Plate Waist + Achievement", "Kill 15 mobs near him to make him become attackable", "skull_blue", "rare_h_ng","119384"},
    [52009000]={ "37408", "Lernaea", "unknown", "", "skull_blue", "rare_h_ng",""},
    [81206000]={ "35932", "Malroc Stonesunder", "i597 Agility Staff", "", "skull_grey", "rare_ng","116796"},
    [45801520]={ "36229", "Mr. Pinchy Sr.", "i616 Trinket Multistrike + Lobstrok Proc", "", "skull_grey", "rare_ng","118690"},
    [34005100]={ "37224", "Mu'gra", "Reputation Item for Steamwheedle Preservation Society", "", "swprare", "rare_s_ng","118659"},
    [47607080]={ "35865", "Netherspawn", "Pet", "", "skull_green", "rare_ng","116815"},
    [42804920]={ "35875", "Ophiis", "i602 Cloth Pants", "", "skull_grey", "rare_ng","116765"},
    [61806900]={ "35943", "Outrider Duretha", "i598 Agility/Intellect Leather Boots", "", "skull_grey", "rare_ng","116800"},
    [58201800]={ "37637", "Pit Beast", "i620 Agility/Strength Tank Cloak", "", "skull_blue", "rare_h_ng","120317"},
    [38001960]={ "37397", "Pit Slayer", "i620 Strength Ring", "", "skull_blue", "rare_h_ng","119389"},
    [73605780]={ "35712", "Redclaw the Feral", "i604 Intellect Fistweapon", "", "skull_grey", "rare_ng","118243"},
    [58008400]={ "35900", "Ru'klaa", "i608 Intellect/Strength Plate Shoulder", "", "skull_grey", "rare_ng","118688"},
    [54806120]={ "35931", "Scout Pokhar", "i601 Strength 1H Axe", "", "skull_grey", "rare_ng","116797"},
    [60934775]={ "35912", "Sean Whitesea", "i600 Agility/Intellect Leather Waist", "Spawns when Abandoned Chest is looted", "skull_grey", "rare_ng","116834"},
    [75606500]={ "36128", "Soulfang", "i597 Intellect Sword", "", "skull_grey", "rare_ng","116806"},
    [58403580]={ "37225", "Thek'talon", "Reputation Item for Steamwheedle Preservation Society", "", "swprare", "rare_s_ng","118660"},
    [65003900]={ "35920", "Tura'aka", "i609 Agility Cloak", "", "skull_grey", "rare_ng","116814"},
    [37003800]={ "37520", "Vileclaw", "Reputation Item for Steamwheedle Preservation Society", "", "swprare", "rare_s_ng","120172"},
    [82607620]={ "34645", "Warmaster Blugthol", "i600 Strength/Intellect Plate Bracer", "", "skull_grey", "rare_ng","116805"},
    [70602940]={ "35877", "Windcaller Korast", "i598 Caster Staff", "", "skull_grey", "rare_ng","116808"},
    [41004400]={ "37226", "Xelganak", "Reputation Item for Steamwheedle Preservation Society", "", "swprare", "rare_s_ng","118661"},
    [26203420]={ "98198", "Rukdug", "Pet Drop", "", "skull_green", "rare_h_ng", "129216"},
    [28503030]={ "98199", "Pugg", "Pet Drop", "", "skull_green", "rare_h_ng", "129217"},
    [23803790]={ "98200", "Guk", "Pet Drop", "", "skull_green", "rare_h_ng", "129218"},
    [50003440]={ "99999910", "Nakk the Thunderer", "", "", "skull_yellow", "mount_na", "116659"},
    [55003500]={ "99999910", "Nakk the Thunderer", "", "", "skull_yellow", "mount_na", "116659"},
    [62801540]={ "99999910", "Nakk the Thunderer", "", "", "skull_yellow", "mount_na", "116659"},
    [64601980]={ "99999910", "Nakk the Thunderer", "", "", "skull_yellow", "mount_na", "116659"},
    [76203180]={ "99999911", "Luk'hok", "", "", "skull_orange", "mount_lu", "116661"},
    [66604400]={ "99999911", "Luk'hok", "", "", "skull_orange", "mount_lu", "116661"},
    [72805360]={ "99999911", "Luk'hok", "", "", "skull_orange", "mount_lu", "116661"},
    [79205600]={ "99999911", "Luk'hok", "", "", "skull_orange", "mount_lu", "116661"},
    [84206360]={ "99999911", "Luk'hok", "", "", "skull_orange", "mount_lu", "116661"},
    [57302670]={ "99999912", "Void Talon", "Random Portal Spawn", "", "skull_purple", "mount_vt", "121815"},
    [40504760]={ "99999912", "Void Talon", "Random Portal Spawn", "", "skull_purple", "mount_vt", "121815"},
    [45903140]={ "99999912", "Void Talon", "Random Portal Spawn", "", "skull_purple", "mount_vt", "121815"},
    [51001600]={ "37210", "Aogexon", "Reputation Item for Steamwheedle Preservation Society", "", "swprare", "rare_s_ng","118654"},
}

nodes["TanaanJungle"] = {
    [15005440]={ "38754", "Axe of Weeping Wolf", "i650 Strength 2H Axe", "First floor of north-east tower", "default", "treasure_tj","127325"},
    [15905930]={ "38757", "The Eye of Grannok", "i650 Intellect/Haste/Multistrike Trinket", "Second floor of south-east tower", "default", "treasure_tj","128220"},
    [17305690]={ "38755", "Spoils of War", "500 Garrison Resources", "", "default", "treasure_tj","824"},
    [17005300]={ "38283", "Stolen Captains Chest", "a little bit of gold", "", "default", "treasure_tj",""},
    [15904980]={ "38208", "Weathered Axe", "i650 Agility 1H Axe", "In the podling cave", "default", "treasure_tj","127324"},
    [25305020]={ "38735", "Borrowed Enchanted Spyglass", "i650 Intellect/Critical Trinket", "At the top of the east tower", "default", "treasure_tj","128222"},
    [22004780]={ "38678", "Bleeding Hollow Warchest", "100 Garrison Resources", ".", "default", "treasure_tj","824"},
    [26804410]={ "38683", "Looted Bleeding Hollow Treasure", "Transformation Item", "Tanaan campaign #3 completion is required to unlock", "default", "treasure_tj","127709"},
    [19304090]={ "38320", "The Blade of Kra'nak", "i650 Agility 1H Sword", "Underwater", "default", "treasure_tj","127338"},
    [31403110]={ "38732", "Jeweled Arakkoa Effigy", "WoD Gem", "Jump through the rocks", "default", "treasure_tj","127413"},
    [28803460]={ "38863", "Partially Mined Apexis Crystal", "Apexis Crystals", "Cave Entrance is at 29.2 / 31.1", "default", "treasure_tj","823"},
    [34703460]={ "38742", "Skull of the Mad Chief", "Item for Slow Fall/Water Walk", "Cave Entrance is at 32.5 / 37.4", "default", "treasure_tj","127669"},
    [26506300]={ "38741", "Looted Bleeding Hollow Treasure", "Apexis Crystals and Garrison Resources", "At the top of the tower", "default", "treasure_tj","823"},
    [32407040]={ "38426", "Tome of Secrets", "Toy", "", "default", "treasure_tj","127670"},
    [30407200]={ "38629", "Polished Crystal", "WoD Gem", "", "default", "treasure_tj","127390"},
    [37004620]={ "38640", "Pale Removal Equipment", "Garrison Resources", "", "default", "treasure_tj","824"},
    [36304350]={ "37956", "Strange Sapphire", "i650 Stamina/Bonus Armor Trinket", "", "default", "treasure_tj","127397"},
    [43203830]={ "38821", "The Commanders Shield", "i650 Strength/Intellect Shield", "", "default", "treasure_tj","127348"},
    [42803540]={ "38822", "Dazzling Rod", "Toy", "  At the top of the north-east tower", "default", "treasure_tj","127859"},
    [46904210]={ "38776", "Sacrificial Blade", "i650 Spellpower Dagger", "", "default", "treasure_tj","127328"},
    [46904440]={ "38773", "Fel-Drenched Satchel", "Cosmetic Headgear(Goggles)", "", "default", "treasure_tj","128218"},
    [46903660]={ "38771", "Book of Zyzzix", "i650 Caster Offhand", "", "default", "treasure_tj","127347"},
    [50806490]={ "38731", "Overgrown Relic", "i650 Agility/Strength Ring", "", "default", "treasure_tj","127412"},
    [54806930]={ "38593", "Lodged Hunting Spear", "i650 Agility Polearm", "", "default", "treasure_tj","127334"},
    [47907040]={ "38705", "Crystalized Essence of Elements", "i650 Caster Fist Weapon", "", "default", "treasure_tj","127329"},
    [57006500]={ "38591", "Forgotten Sack", "Flavour Item + Raw Beast Hides", "", "default", "treasure_tj","110609"},
    [46207280]={ "38739", "Mysterious Corrupted Obelisk", "Accessory", "Tanaan campaign #5 completion is required to unlock", "default", "treasure_tj","128320"},
    [41607330]={ "38657", "Forgotten Champions Blade", "i650 Strength 2H Sword", "", "default", "treasure_tj","127339"},
    [40807550]={ "38639", "The Perfect Blossom", "Toy", "Get the immunity buff from nearby Mysterious Fruits to prevent loot cast interruption.", "default", "treasure_tj","127766"},
    [40607980]={ "38638", "Snake Charmer Flute", "i650 Caster 2H Mace", "", "default", "treasure_tj","127333"},
    [34407830]={ "38762", "Stashed Iron Sea Booty #3", "Gold and Garrison Resources", "Cave Entrance is at 37.5 / 76.0", "default", "treasure_tj","824"},
    [35007730]={ "38761", "Stashed Iron Sea Booty #2", "Gold and Garrison Resources", "Cave Entrance is at 37.5 / 76.0", "default", "treasure_tj","824"},
    [33907810]={ "38760", "Stashed Iron Sea Booty #1", "Gold and Garrison Resources", "Cave Entrance is at 37.5 / 76.0", "default", "treasure_tj","824"},
    [35907860]={ "38758", "Ironbeards Treasure", "Gold and Garrison Resources", "", "default", "treasure_tj","824"},
    [37708070]={ "38788", "Brazier of Awakening", "Ressurection Accessory", "", "default", "treasure_tj","127770"},
    [48507520]={ "38814", "Looted Mystical Staff", "i650 Caster Staff", "Cave Entrance is at 44.4 / 77.5", "default", "treasure_tj","127337"},
    [49907680]={ "38809", "Bleeding Hollow Mushroom Stash", "Food with Side effects", "Cave Entrance is at 44.4 / 77.5", "default", "treasure_tj","128223"},
    [62107070]={ "38602", "Crystalized Fel Spike", "i650 Intellect/Spirit Trinket", "", "default", "treasure_tj","128217"},
    [61207580]={ "38601", "Blackfang Isle Cache", "Garrison Resources", "", "default", "treasure_tj","824"},
    [49907960]={ "38703", "Scouts Belongings", "i650 Agility Cloak", "Top of the cave", "default", "treasure_tj","127354"},
    [49908120]={ "38702", "Discarded Helm", "i650 Agility/Intellect Mail Helm", "Inside the cave", "default", "treasure_tj","127312"},
    [64704280]={ "38701", "Loose Soil", "Transformation Toy", "", "default", "treasure_tj","127396"},
    [51702430]={ "38686", "Rune Etched Femur", "i650 Wand", "", "default", "treasure_tj","127341"},
    [58502520]={ "38679", "Jewel of the Fallen Star", "WoD Gem", "", "default", "treasure_tj","115524"},
    [62602050]={ "38682", "Censer of Torment", "i650 Strength/Versatility Trinket", "", "default", "treasure_tj","127401"},
    [51603270]={ "39075", "Fel-Tainted Apexis Formation", "Apexis Crystals", "Hanging from the pillar's edge", "default", "treasure_tj","823"},
    [28702330]={ "38334", "Jewel of Hellfire", "Toy", "", "default", "treasure_tj","127668"},
    [63402810]={ "38740", "Forgotten Shard of the Cipher", "Pet", "Tanaan campaign #6 completion is required to unlock", "default", "treasure_tj","128309"},
    [54909070]={ "39470", "Dead Mans Chest", "Garrison Resource", "", "default", "treasure_tj","824"},
    [65908500]={ "39469", "Bejeweled Egg", "Trash Item", "", "default", "treasure_tj","128386"},
    [69705600]={ "38704", "Forgotten Iron Horde Supplies", "Garrison Resources", "", "default", "treasure_tj","824"},
    [73604320]={ "38779", "Stashed Bleeding Hollow Loot", "Gold + Trash Item", "First floor of north-east tower.", "default", "treasure_tj",""},
    [13605680]={ "38747", "Tho'gar Gorefist", "i655 Agility/Intellect Mail Boots", "", "skull_blue", "rare_h_tj","127310","28347"},
    [13005700]={ "38751", "The Iron Houndmaster", "i655 Strength/Intellect Plate Shoulders", "Capture Strongpoint (west) to make him spawn. Iron Front event required", "skull_blue", "rare_h_tj","127321","28350"},
    [16005920]={ "38750", "Grannok", "i655 Intellect Neck", "At the top of the south-east tower.", "skull_blue", "rare_h_tj","127649","28348"},
    [15005420]={ "38746", "Commander Krag'goth", "i655 Strength/Intellect Plate Gloves", "At the top of the north-east tower", "skull_blue", "rare_h_tj","127319", "28346"},
    [16005720]={ "38752", "Szirek the Twisted", "i655 Cloth Gloves", "Capture Strongpoint (east) to make him spawn. Iron Front event required", "skull_blue", "rare_h_tj","127296","28349"},
    [16804860]={ "38282", "Podlord Wakkawam", "i655 Agility Staff", "", "skull_blue", "rare_h_tj","127336", "28329"},
    [23605200]={ "38262", "Bilkor the Thrower", "i655 Agility/Intellect Leather Shoulder", "", "skull_blue", "rare_h_tj","127307","28351"},
    [20404980]={ "38263", "Rogond the Tracker", "i655 Agility/Intellect Mail Shoulder", "", "skull_blue", "rare_h_tj","127314","28352"},
    [19805360]={ "38736", "Driss Vile", "i655 Gun", "At the top of the south tower", "skull_blue", "rare_h_tj","127331","28369"},
    [25504620]={ "38264", "Drivnul", "i655 Cloth Pants", "", "skull_blue", "rare_h_tj","127298","28354"},
    [23204840]={ "38265", "Dorg the Bloody", "i655 Cloth Belt", "Killing mobs in the area will make him spawn somewhere in the area", "skull_blue", "rare_h_tj","127301","28353"},
    [22805120]={ "38266", "Bloodhunter Zulk", "i655 Agility/Intellect Leather Boots", "Interrupting Bleeding Hollow activities will make him spawn", "skull_blue", "rare_h_tj","127303","28355"},
    [22205080]={ "39159", "Remnant of the Blood Moon", "Toy", "Draining Blood Moon empty will make it spawn. Zeth'Gol event required", "skull_green", "rare_h_tj","127666"},
    [16804340]={ "38034", "Rasthe", "i655 Crit/Mastery/Multistrike Trinket", "", "skull_blue", "rare_h_tj","127661","28341"},
    [20404000]={ "38028", "High Priest Ikzan", "Transformation Accessory", "Roams the whole camp", "skull_green", "rare_h_tj","122117"},
    [27603280]={ "37937", "Varyx the Damned", "i655 Intellect Ring", "Need 5 players to open his prison", "skull_blue", "rare_h_tj","127351", "28340"},
    [26305420]={ "38496", "Relgor", "i655 Agility Polearm", "", "skull_blue", "rare_h_tj","127335","28356"},
    [28605080]={ "38775", "Felbore", "i655 Strength Ring", "Cave Entrance is at 31.3 / 53.5", "skull_blue", "rare_h_tj","127350","28372"},
    [31406800]={ "38031", "Ceraxas", "Fel Pup - Pet", "doesn't actually drop the pet, but spawns the quest required to get it", "skull_green", "rare_h_tj","","28336"},
    [27607480]={ "38030", "Jax'zor", "i655 Strength/Intellect Plate Belt", "Cave Entrance is at 29.6 / 70.6", "skull_blue", "rare_h_tj","127322","28335"},
    [25807900]={ "38032", "Mistress Thavra", "i655 Cloth Shoulders", "Cave Entrance is at 29.6 / 70.6", "skull_blue", "rare_h_tj","127300","28337"},
    [25407720]={ "38029", "Lady Oran", "i655 Agility/Intellect Mail Wrist", "Cave Entrance is at 29.6 / 70.6", "skull_blue", "rare_h_tj","127316","28334"},
    [31607280]={ "38026", "Imp-Master Valessa", "Accessory", "", "skull_green", "rare_h_tj","127655","28333"},
    [35404680]={ "38609", "Belgork", "i655 Strength/Intellect Shield", "", "skull_blue", "rare_h_tj","127650","28363"},
    [34004440]={ "38620", "Thromma the Gutslicer", "i655 Agility Dagger", "", "skull_blue", "rare_h_tj","127327","28362"},
    [33003570]={ "38709", "Gorabosh", "i655 Agility/Intellect Leather Gloves", "", "skull_blue", "rare_h_tj","127304","28368"},
    [37003280]={ "39045", "Zoug the Heavy", "i655 Agility/Intellect Leather Belt", "", "skull_blue", "rare_h_tj","127308","28723"},
    [39603260]={ "39046", "Harbormaster Korak", "i655 Agility/Intellect Mail Body", "", "skull_blue", "rare_h_tj","127309","28724"},
    [42403730]={ "37953", "Sergeant Mor'grak", "i655 Strength/Intellect Plate Boots", "", "skull_blue", "rare_h_tj","127318","28339"},
    [44603760]={ "37990", "Cindral the Wildfire", "i655 Versatility/Mastery/Multistrike Trinket", "Killing all Remnant of Cindral in the forge will make it spawn", "skull_blue", "rare_h_tj","127660","28338"},
    [45804700]={ "38634", "Felsmith Damorka", "i655 Agility/Intellect Leather Body", "", "skull_blue", "rare_h_tj","127302","28726"},
    [50003600]={ "38411", "Executor Riloth", "i655 Strength/Intellect Plate Bracer", "", "skull_blue", "rare_h_tj","127323","28380"},
    [46204240]={ "38400", "Grand Warlock Nethekurse", "i655 Cloth Body", "", "skull_blue", "rare_h_tj","127299","28343"},
    [51004600]={ "38749", "Commander Org'mok", "i655 Agility/Intellect Mail Pants", "Patrols around the area", "skull_blue", "rare_h_tj","127313","28731"},
    [48005720]={ "38820", "Captain Grok'mar", "i655 Strength/Intellect Plate Pants", "", "skull_blue", "rare_h_tj","127664","28730"},
    [49706140]={ "38812", "Shadowthrash", "i655 Agility/Intellect Leather Bracer", "", "skull_blue", "rare_h_tj","127665","28725"},
    [52206510]={ "38726", "Magwia", "i655 Strength 1H Mace", "", "skull_blue", "rare_h_tj","127332","28345"},
    [40807000]={ "38209", "Bramblefell", "Toy - Cooking Fire", "", "skull_green", "rare_h_tj","127652" ,"28330"},
    [39606810]={ "38825", "Kris'kar the Unredeemed ", "i655 Strength 1H Sword", "Cave Entrance is at 42.5 / 68.9", "skull_blue", "rare_h_tj","127653","28377"},
    [34307250]={ "38654", "The Goreclaw", "i655 Agility/Intellect Leather Helm", "Cave Entrance is at 36.2 / 72.4", "skull_blue", "rare_h_tj","127305","28367"},
    [39407380]={ "38632", "The Night Haunter", "i655 Strength Cloak", "Collect 10 Stacks of his debuff to spawn him by finding 'copies' of him or by touching mutilated corpses", "skull_blue", "rare_h_tj","127355","28366"},
    [41007880]={ "38628", "Sylissa", "i655 Agility/Intellect Mail Gloves", "", "skull_blue", "rare_h_tj","127311","28364"},
    [41807380]={ "38631", "Rendrak", "i655 Intellect Cloak", "", "skull_blue", "rare_h_tj","127356","28365"},
    [36207970]={ "38756", "Captain Ironbeard ", "Toy", "Cave Entrance is at 37.5 / 76.0", "skull_green", "rare_h_tj","127659","28370"},
    [34607820]={ "38764", "Glub'glok", "i655 Strength/Intellect Plate Body", "Cave Entrance is at 37.5 / 76.0. You need to open a chest to actually spawn him", "skull_blue", "rare_h_tj","127317","28371"},
    [51007440]={ "38696", "Bleeding Hollow Horror", "i655 Stamina/Bonus Armor Trinket", "Cave Entrance is at 44.4 / 77.5", "skull_blue", "rare_h_tj","127654","28376"},
    [57606720]={ "38589", "Broodlord Ixkor", "i655 Agility Ring", "", "skull_blue", "rare_h_tj","127349","28357"},
    [62607200]={ "38600", "Soulslicer", "i655 Agility/Intellect Mail Belt", "", "skull_blue", "rare_h_tj","127315","28358"},
    [63608110]={ "38604", "Gloomtalon", "i655 Agility/Intellect Leather Pants", "", "skull_blue", "rare_h_tj","127306","28359"},
    [52108390]={ "38605", "Krell the Serene", "i655 Agility/Multistrike Trinket", "", "skull_blue", "rare_h_tj","127418","28360"},
    [48807280]={ "38597", "The Blackfang", "i655 Agility Fist Weapon", "", "skull_blue", "rare_h_tj","127330","28361"},
    [48402850]={ "38207", "Zeter'el", "i655 Strength 2H Sword", "Cave Entrance is at 48.1 / 33.0", "skull_blue", "rare_h_tj","127340","28331"},
    [52802560]={ "38211", "Felspark", "i655 Cloth Bracer", "", "skull_blue", "rare_h_tj","127656","28332"},
    [53602170]={ "38557", "Painmistress Selora", "i655 Cloth Helm", "Complete the event by killing mob waves to make her spawn", "skull_blue", "rare_h_tj","127297","28342"},
    [57102280]={ "38457", "Putre'thar", "i655 Intellect/Spirit Trinket", "", "skull_blue", "rare_h_tj","127657","28727"},
    [53002000]={ "38580", "Overlord Ma'gruth", "i655 Strength/Intellect Plate Helm", "", "skull_blue", "rare_h_tj","127320","28729"},
    [60202090]={ "38579", "Xanzith the Everlasting", "i655 Intellect Offhand", "", "skull_blue", "rare_h_tj","127658","28728"},
    [65403660]={ "38700", "Steelsnout", "i655 Agility/Strength Cloak", "", "skull_blue", "rare_h_tj","127357","28344"},
    [52604020]={ "38430", "Argosh the Destroyer", "i655 Crossbow", "", "skull_blue", "rare_h_tj","127326","28722"},
    [41407960]={ "37407", "Keravnos", "unknown", "", "skull_blue", "rare_h_tj",""},
    [88005550]={ "40104", "Smashum Grabb", "Toy", "", "skull_green", "rare_h_tj","108634"},
    [83504380]={ "40105", "Drakum", "Toy", "", "skull_green", "rare_h_tj","108631"},
    [80405680]={ "40106", "Gondar", "Toy", "", "skull_green", "rare_h_tj","108633"},
    [40705630]={ "40107", "Fel Overseer Mudlump", "Dismounting item", "", "skull_green", "rare_h_tj","129295"},
    [13505900]={ "39288", "Terrorfist", "Mounts + Oil", "His spawn will be announced by Frogan: A massive gronnling is heading for Rangari Refuge! We are going to require some assistance!", "skull_red", "mount_tj",""},
    [23204040]={ "39287", "Deathtalon", "Mounts + Oil", "His spawn will be announced by Shadow Lord Iskar: Behind the veil, all you find is death!", "skull_red", "mount_tj",""},
    [32407400]={ "39290", "Vengeance", "Mounts + Oil", "His spawn will be announced by Tyrant Velhari: Insects deserve to be crushed!", "skull_red", "mount_tj",""},
    [47005260]={ "39289", "Doomroller", "Mounts + Oil", "His spawn will be announced by Siegemaster Mar'tak: Hah-ha! Trample their corpses!", "skull_red", "mount_tj",""},
}

nodes["garrisonsmvalliance_tier1"] = {
    [49604380]={ "35530", "Lunarfall Egg", "Garrison Resources", "on a wagon", "default", "treasure_smv","824"},
    [42405436]={ "35381", "Pippers' Buried Supplies 1", "Garrison Resources", "", "default", "treasure_smv","824"},
    [50704850]={ "35382", "Pippers' Buried Supplies 2", "Garrison Resources", "", "default", "treasure_smv","824"},
    [30802830]={ "35383", "Pippers' Buried Supplies 3", "Garrison Resources", "", "default", "treasure_smv","824"},
    [49197683]={ "35384", "Pippers' Buried Supplies 4", "Garrison Resources", "", "default", "treasure_smv","824"},
    [51800110]={ "35289", "Spark's Stolen Supplies", "Garrison Resources", "in a cave in the lake", "default", "treasure_smv","824"},
}

nodes["garrisonsmvalliance_tier2"] = {
    [37306590]={ "35530", "Lunarfall Egg", "Garrison Resources", "on a wagon", "default", "treasure_smv","824"},
    [41685803]={ "35381", "Pippers' Buried Supplies 1", "Garrison Resources", "", "default", "treasure_smv","824"},
    [51874545]={ "35382", "Pippers' Buried Supplies 2", "Garrison Resources", "", "default", "treasure_smv","824"},
    [34972345]={ "35383", "Pippers' Buried Supplies 3", "Garrison Resources", "", "default", "treasure_smv","824"},
    [46637608]={ "35384", "Pippers' Buried Supplies 4", "Garrison Resources", "", "default", "treasure_smv","824"},
    [51800110]={ "35289", "Spark's Stolen Supplies", "Garrison Resources", "in a cave in the lake", "default", "treasure_smv","824"},
}

nodes["garrisonsmvalliance_tier3"] = {
    [61277261]={ "35530", "Lunarfall Egg", "Garrison Resources", "in the tent", "default", "treasure_smv","824"},
    [60575515]={ "35381", "Pippers' Buried Supplies 1", "Garrison Resources", "", "default", "treasure_smv","824"},
    [37307491]={ "35382", "Pippers' Buried Supplies 2", "Garrison Resources", "", "default", "treasure_smv","824"},
    [37864378]={ "35383", "Pippers' Buried Supplies 3", "Garrison Resources", "", "default", "treasure_smv","824"},
    [61527154]={ "35384", "Pippers' Buried Supplies 4", "Garrison Resources", "", "default", "treasure_smv","824"},
    [51800110]={ "35289", "Spark's Stolen Supplies", "Garrison Resources", "in a cave in the lake", "default", "treasure_smv","824"},
}

nodes["garrisonffhorde_tier1"] = {
    [74505620]={ "34937", "Lady Sena's Other Materials Stash", "Garrison Resources", "", "default", "treasure_ffr","824"},
}

nodes["garrisonffhorde_tier2"] = {
    [74505620]={ "34937", "Lady Sena's Other Materials Stash", "Garrison Resources", "", "default", "treasure_ffr","824"},
}

nodes["garrisonffhorde_tier3"] = {
    [74505620]={ "34937", "Lady Sena's Other Materials Stash", "Garrison Resources", "", "default", "treasure_ffr","824"},
}

nodes["MardumtheShatteredAbyss"] = {
	[34857020]={ "39970", "Small Treasure Chest", "", "", "default", "treasure_dh", "129210"},
	[45017785]={ "39971", "Small Treasure Chest", "Reusable Flask", "", "default", "treasure_dh", "129192"},
	[41763761]={ "40759", "Small Treasure Chest", "", "", "default", "treasure_dh", "129196"},
	[51135079]={ "40743", "Small Treasure Chest", "", "", "default", "treasure_dh", "129210"},
	[76243899]={ "40338", "Small Treasure Chest", "", "cave entrance at 77.0 to 41.4", "default", "treasure_dh", "129210"},
	[82075043]={ "40820", "Small Treasure Chest", "", "", "default", "treasure_dh", "129196"},
	[78755047]={ "40274", "Small Treasure Chest", "", "", "default", "treasure_dh", "129210"},
	[73494892]={ "39975", "Small Treasure Chest", "", "", "default", "treasure_dh", "129195"},
	[42194916]={ "40223", "Small Treasure Chest", "", "", "default", "treasure_dh", "129210"},
	[23065389]={ "40797", "Small Treasure Chest", "", "cave entrance at 23.6 to 54.2", "default", "treasure_dh", "129210"},
	[66922767]={ "39974", "Small Treasure Chest", "", "", "default", "treasure_dh", "129210"},
	[74285453]={ "39977", "Small Treasure Chest", "", "cave entrance at 70.7 to 54.0", "default", "treasure_dh", "129210"},
	[69704240]={ "39976", "Small Treasure Chest", "", "", "default", "treasure_dh", "129210"},
	
	[68852759]={ "40234", "General Volroth", "", "", "skull_grey", "rare_dh", "128947"},
	[81034124]={ "40233", "Overseer Brutarg", "", "", "skull_grey", "rare_dh", "133580"},
	[74475731]={ "40232", "King Voras", "", "", "skull_grey", "rare_dh", "128944"},
}

nodes["CrypticHollow"] = {
	[48761530]={ "39972", "Small Treasure Chest", "", "", "default", "treasure_dh", "129196"},
	[54855845]={ "39973", "Small Treasure Chest", "", "", "default", "treasure_dh", "128946"},
}

nodes["SoulEngine"] = {
	[50304964]={ "40772", "Small Treasure Chest", "", "", "default", "treasure_dh", "129210"},
	[51235740]={ "40231", "Count Nefarious", "", "", "skull_grey", "rare_dh", "128948"},
}

nodes["VaultOfTheWardensDH"] = {
	[58693475]={ "40909", "Small Treasure Chest", "", "First Stage", "default", "treasure_dh", "129210"},
	[47325464]={ "38690", "Small Treasure Chest", "", "First Stage", "default", "treasure_dh", "129210"},
	[32104817]={ "40911", "Small Treasure Chest", "", "Second Stage", "default", "treasure_dh", "129196"},
	[41506361]={ "40914", "Small Treasure Chest", "", "Second Stage", "default", "treasure_dh", "129196"},
	[56994013]={ "40913", "Small Treasure Chest", "", "Second Stage", "default", "treasure_dh", "129210"},
	[41413287]={ "40912", "Small Treasure Chest", "", "Second Stage", "default", "treasure_dh", "129210"},
	[24421005]={ "40915", "Small Treasure Chest", "", "Third Stage", "default", "treasure_dh", "129210"},
	[23268157]={ "40916", "Small Treasure Chest", "", "Third Stage", "default", "treasure_dh", "129210"},
	
	[68743628]={ "40301", "Wrath-Lord Lekos", "", "", "skull_grey", "rare_dh", "128958"},
	[49543284]={ "40251", "Kethrazor", "", "", "skull_grey", "rare_dh", "128945"},
}

if (PlayerFaction == "Alliance") then
    nodes["ShadowmoonValleyDR"][29600620]={ "35281", "Bahameye", "Fire Ammonite", "", "skull_grey", "rare_smv","111666"}
    nodes["Gorgrond"][60805400]={ "36502", "Biolante", "Quest Item for XP", "You must finish the quest before this element gets removed from the map", "skull_grey", "rare_gg","116159"}
    nodes["Gorgrond"][46004680]={ "35816", "Charl Doomwing", "Quest Item for XP", "You must finish the quest before this element gets removed from the map", "skull_grey", "rare_gg","113457"}
    nodes["Gorgrond"][42805920]={ "35812", "Crater Lord Igneous", "Quest Item for XP", "You must finish the quest before this element gets removed from the map", "skull_grey", "rare_gg","113449"}
    nodes["Gorgrond"][40505100]={ "35809", "Dessicus of the Dead Pools", "Quest Item for XP", "You must finish the quest before this element gets removed from the map", "skull_grey", "rare_gg","113446"}
    nodes["Gorgrond"][51804160]={ "35808", "Erosian the Violent", "Quest Item for XP", "You must finish the quest before this element gets removed from the map", "skull_grey", "rare_gg","113445"}
    nodes["Gorgrond"][58006360]={ "35813", "Fungal Praetorian", "Quest Item for XP", "You must finish the quest before this element gets removed from the map", "skull_grey", "rare_gg","113453"}
    nodes["ShadowmoonValleyDR"][21603300]={ "33664", "Gorum", "i516 Agility/Intellect Ring", "Inside Bloodthorn Cave - Spawns at the Ceiling", "skull_grey", "rare_smv","113082"}
    nodes["Gorgrond"][52406580]={ "35820", "Khargax the Devourer", "Quest Item for XP", "You must finish the quest before this element gets removed from the map", "skull_grey", "rare_gg","113461"}
    nodes["ShadowmoonValleyDR"][30301990]={ "35530", "Lunarfall Egg", "Garrison Resources", "Changes position to inside the garrison once it is built", "default", "treasure_smv","824"}
    nodes["Gorgrond"][51206360]={ "35817", "Roardan the Sky Terror", "Quest Item for XP", "Flies around a lot, Coordinates are just somewhere on his route!You must finish the quest before this element gets removed from the map", "skull_grey", "rare_gg","113458"}
    nodes["ShadowmoonValleyDR"][42804100]={ "33038", "Windfang Matriarch", "i516 Agility/Strength 1H Sword", "Is part of the Embaari Crystal Defense Event", "skull_grey", "rare_smv","113553"}
end

if (PlayerFaction == "Horde") then
    nodes["Gorgrond"][60805400]={ "36503", "Biolante", "Quest Item for XP", "You must finish the quest before this element gets removed from the map", "skull_grey", "rare_gg","116160"}
    nodes["Gorgrond"][46004680]={ "35815", "Charl Doomwing", "Quest Item for XP", "You must finish the quest before this element gets removed from the map", "skull_grey", "rare_gg","113456"}
    nodes["Gorgrond"][42805920]={ "35811", "Crater Lord Igneous", "Quest Item for XP", "You must finish the quest before this element gets removed from the map", "skull_grey", "rare_gg","113448"}
    nodes["Gorgrond"][40505100]={ "35810", "Dessicus of the Dead Pools", "Quest Item for XP", "You must finish the quest before this element gets removed from the map", "skull_grey", "rare_gg","113447"}
    nodes["Gorgrond"][51804160]={ "35807", "Erosian the Violent", "Quest Item for XP", "You must finish the quest before this element gets removed from the map", "skull_grey", "rare_gg","113444"}
    nodes["Gorgrond"][58006360]={ "35814", "Fungal Praetorian", "Quest Item for XP", "You must finish the quest before this element gets removed from the map", "skull_grey", "rare_gg","113454"}
    nodes["Gorgrond"][52406580]={ "35819", "Khargax the Devourer", "Quest Item for XP", "You must finish the quest before this element gets removed from the map", "skull_grey", "rare_gg","113460"}
    nodes["Talador"][61107170]={ "34116", "Norana's Cache", "i564 Agility Neck", "", "default", "treasure_td","117563"}
    nodes["Gorgrond"][51206360]={ "35818", "Roardan the Sky Terror", "Quest Item for XP", "Flies around a lot, Coordinates are just somewhere on his route!You must finish the quest before this element gets removed from the map", "skull_grey", "rare_gg","113459"}
end

local function GetItem(ID)
    if (ID == "824" or ID == "823") then
        local currency, _, _ = GetCurrencyInfo(ID)

        if (currency ~= nil) then
            return currency
        else
            return "Error loading CurrencyID"
        end
    else
        local _, item, _, _, _, _, _, _, _, _ = GetItemInfo(ID)

        if (item ~= nil) then
            return item
        else
            return "Error loading ItemID"
        end
    end
end 

local function GetIcon(ID)
    if (ID == "824" or ID == "823") then
        local _, _, icon = GetCurrencyInfo(ID)

        if (icon ~= nil) then
            return icon
        else
            return "Interface\\Icons\\inv_misc_questionmark"
        end
    else
        local _, _, _, _, _, _, _, _, _, icon = GetItemInfo(ID)

        if (icon ~= nil) then
            return icon
        else
            return "Interface\\Icons\\inv_misc_questionmark"
        end
    end
end

function DraenorTreasures:OnEnter(mapFile, coord)
    if (not nodes[mapFile][coord]) then return end
    
    local tooltip = self:GetParent() == WorldMapButton and WorldMapTooltip or GameTooltip

    if ( self:GetCenter() > UIParent:GetCenter() ) then
        tooltip:SetOwner(self, "ANCHOR_LEFT")
    else
        tooltip:SetOwner(self, "ANCHOR_RIGHT")
    end

    tooltip:SetText(nodes[mapFile][coord][2])
    if (nodes[mapFile][coord][3] ~= nil) and (DraenorTreasures.db.profile.show_loot == true) then
        if ((nodes[mapFile][coord][7] ~= nil) and (nodes[mapFile][coord][7] ~= "")) then
            tooltip:AddLine(("Loot: " .. GetItem(nodes[mapFile][coord][7])), nil, nil, nil, true)

            if ((nodes[mapFile][coord][3] ~= nil) and (nodes[mapFile][coord][3] ~= "")) then
                tooltip:AddLine(("Lootinfo: " .. nodes[mapFile][coord][3]), nil, nil, nil, true)
            end
        else
            tooltip:AddLine(("Loot: " .. nodes[mapFile][coord][3]), nil, nil, nil, true)
        end
    end

    if (nodes[mapFile][coord][4] ~= "") and (DraenorTreasures.db.profile.show_notes == true) then
     tooltip:AddLine(("Notes: " .. nodes[mapFile][coord][4]), nil, nil, nil, true)
    end

    tooltip:Show()
end

local isMoving = false
local info = {}
local clickedMapFile = nil
local clickedCoord = nil

local function generateMenu(button, level)
    if (not level) then return end

    for k in pairs(info) do info[k] = nil end

    if (level == 1) then
        info.isTitle = 1
        info.text = "DraenorTreasures"
        info.notCheckable = 1
        UIDropDownMenu_AddButton(info, level)
        
        info.disabled = nil
        info.isTitle = nil
        info.notCheckable = nil
        info.text = "Remove this Object from the Map"
        info.func = DTDisableTreasure
        info.arg1 = clickedMapFile
        info.arg2 = clickedCoord
        UIDropDownMenu_AddButton(info, level)
        
        if isTomTomloaded == true then
            info.text = "Add this location to TomTom waypoints"
            info.func = DTaddtoTomTom
            info.arg1 = clickedMapFile
            info.arg2 = clickedCoord
            UIDropDownMenu_AddButton(info, level)
        end

        if isDBMloaded == true then
            info.text = "Add this treasure as DBM Arrow"
            info.func = DTAddDBMArrow
            info.arg1 = clickedMapFile
            info.arg2 = clickedCoord
            UIDropDownMenu_AddButton(info, level)
            
            info.text = "Hide DBM Arrow"
            info.func = DTHideDBMArrow
            UIDropDownMenu_AddButton(info, level)
        end

        info.text = CLOSE
        info.func = function() CloseDropDownMenus() end
        info.arg1 = nil
        info.arg2 = nil
        info.notCheckable = 1
        UIDropDownMenu_AddButton(info, level)

        info.text = "Restore Removed Objects"
        info.func = DTResetDB
        info.arg1 = nil
        info.arg2 = nil
        info.notCheckable = 1
        UIDropDownMenu_AddButton(info, level)
        
    end
end

local HandyNotes_DraenorTreasuresDropdownMenu = CreateFrame("Frame", "HandyNotes_DraenorTreasuresDropdownMenu")
HandyNotes_DraenorTreasuresDropdownMenu.displayMode = "MENU"
HandyNotes_DraenorTreasuresDropdownMenu.initialize = generateMenu

function DraenorTreasures:OnClick(button, down, mapFile, coord)
    if button == "RightButton" and down then
        clickedMapFile = mapFile
        clickedCoord = coord
        ToggleDropDownMenu(1, nil, HandyNotes_DraenorTreasuresDropdownMenu, self, 0, 0)
    end
end

function DraenorTreasures:OnLeave(mapFile, coord)
    if self:GetParent() == WorldMapButton then
        WorldMapTooltip:Hide()
    else
        GameTooltip:Hide()
    end
end

local options = {
    type = "group",
    name = "DraenorTreasures",
    desc = "Locations of treasures in Draenor.",
    get = function(info) return DraenorTreasures.db.profile[info.arg] end,
    set = function(info, v) DraenorTreasures.db.profile[info.arg] = v; DraenorTreasures:Refresh() end,
    args = {
        desc = {
            name = "General Settings",
            type = "description",
            order = 0,
        },
        icon_scale_treasures = {
            type = "range",
            name = "Icon Scale for Treasures",
            desc = "The scale of the icons",
            min = 0.25, max = 3, step = 0.01,
            arg = "icon_scale_treasures",
            order = 1,
        },
        icon_scale_rares = {
            type = "range",
            name = "Icon Scale for Rares",
            desc = "The scale of the icons",
            min = 0.25, max = 3, step = 0.01,
            arg = "icon_scale_rares",
            order = 2,
        },
        icon_alpha = {
            type = "range",
            name = "Icon Alpha",
            desc = "The alpha transparency of the icons",
            min = 0, max = 1, step = 0.01,
            arg = "icon_alpha",
            order = 20,
        },
        VisibilityOptions = {
            type = "group",
            name = "Visibility Settings",
            desc = "Visibility Settings",
            args = {
                VisibilityGroup = {
                    type = "group",
                    order = 0,
                    name = "Select what to show:",
                    inline = true,
                    args = {
                        groupSMV = {
                            type = "header",
                            name = "Shadowmoon Valley",
                            desc = "Shadowmoon Valley",
                            order = 0,
                        },
                        treasureSMV = {
                            type = "toggle",
                            arg = "treasure_smv",
                            name = "Treasures",
                            desc = "Treasures that give various items",
                            order = 1,
                            width = "half",
                        },
                        rareSMV = {
                            type = "toggle",
                            arg = "rare_smv",
                            name = "Rares",
                            desc = "Rare spawns for leveling players",
                            order = 2,
                            width = "half",
                        },
                        rareHSMV = {
                            type = "toggle",
                            arg = "rare_h_smv",
                            name = "Rares - Level 100",
                            desc = "Rare spawns for level 100 players",
                            order = 3,
                            width = "normal",
                        },
                        groupFFR = {
                            type = "header",
                            name = "Frostfire Ridge",
                            desc = "Frostfire Ridge",
                            order = 10,
                        },  
                        treasureFFR = {
                            type = "toggle",
                            arg = "treasure_ffr",
                            name = "Treasures",
                            desc = "Treasures that give various items",
                            width = "half",
                            order = 11,
                        },
                        rareFFR = {
                            type = "toggle",
                            arg = "rare_ffr",
                            name = "Rares",
                            desc = "Rare spawns for leveling players",
                            width = "half",
                            order = 12,
                        },
                        rareHFFR = {
                            type = "toggle",
                            arg = "rare_h_ffr",
                            name = "Rares - Level 100",
                            desc = "Rare spawns for level 100 players",
                            width = "normal",
                            order = 13,
                        },
                        treasureFFRBSF = {
                            type = "toggle",
                            arg = "treasure_ffr_bsf",
                            name = "Treasures - Bladespire Fortress",
                            desc = "Found in Bladespire Fortress",
                            width = "full",
                            order = 14,
                        },
                        groupGG = {
                            type = "header",
                            name = "Gorgrond",
                            desc = "Gorgrond",
                            order = 20,
                        },  
                        treasureGG = {
                            type = "toggle",
                            arg = "treasure_gg",
                            name = "Treasures",
                            desc = "Treasures that give various items",
                            width = "half",
                            order = 21,
                        },
                        rareGG = {
                            type = "toggle",
                            arg = "rare_gg",
                            name = "Rares",
                            desc = "Rare spawns for leveling players",
                            width = "half",
                            order = 22,
                        },  
                        rareHGG = {
                            type = "toggle",
                            arg = "rare_h_gg",
                            name = "Rares - Level 100",
                            desc = "Rare spawns for level 100 players",
                            width = "normal",
                            order = 23,
                        },  
                        treasureGGL = {
                            type = "toggle",
                            arg = "treasure_gg_l",
                            name = "Lumber Mill",
                            desc = "Treasures for the Lumber Mill Outpost",
                            order = 24,
                        },  
                        treasureGGB = {
                            type = "toggle",
                            arg = "treasure_gg_b",
                            name = "Sparring Arena",
                            desc = "Treasures for the Sparring Arena Outpost",
                            order = 25,
						},
						overrideGG = {
                            type = "toggle",
                            arg = "gorgrond_override",
                            name = "Force Lumber Mill/Sparring Arena",
                            desc = "Always show Lumber Mill/Sparring Arena treasures depending on the selection to the left and not by questID. This selection will require an interface reload to take effect.",
							width = "full",
                            order = 26,
                        },  
                        groupTD = {
                            type = "header",
                            name = "Talador",
                            desc = "Talador",
                            order = 30,
                        },  
                        treasureTD = {
                            type = "toggle",
                            arg = "treasure_td",
                            name = "Treasures",
                            desc = "Treasures that give various items",
                            width = "half",
                            order = 31,
                        },
                        rareTD = {
                            type = "toggle",
                            arg = "rare_td",
                            name = "Rares",
                            desc = "Rare spawns for leveling players",
                            width = "half",
                            order = 32,
                        },  
                        rareHTD = {
                            type = "toggle",
                            arg = "rare_h_td",
                            name = "Rares - Level 100",
                            desc = "Rare spawns for level 100 players",
                            width = "normal",
                            order = 33,
                        },  
                        groupSOA = {
                            type = "header",
                            name = "Spires of Arak",
                            desc = "Spires of Arak",
                            order = 40,
                        },    
                        treasureSOA = {
                            type = "toggle",
                            arg = "treasure_soa",
                            name = "Treasures",
                            desc = "Treasures that give various items",
                            width = "half",
                            order = 41,
                        },
                        rareSOA = {
                            type = "toggle",
                            arg = "rare_soa",
                            name = "Rares",
                            desc = "Rare spawns for leveling players",
                            width = "half",
                            order = 42,
                        },  
                        rareHSOA = {
                            type = "toggle",
                            arg = "rare_h_soa",
                            name = "Rares - Level 100",
                            desc = "Rare spawns for level 100 players",
                            width = "normal",
                            order = 43,
                        },
                        treasureSOAA = {
                            type = "toggle",
                            arg = "treasure_soa_a",
                            name = "Treasures - Archaeology",
                            desc = "Requires the Archaeology profression",
                            width = "full",
                            order = 44,
                        },  
                        groupNG = {
                            type = "header",
                            name = "Nagrand",
                            desc = "Nagrand",
                            order = 50,
                        },      
                        treasureNG = {
                            type = "toggle",
                            arg = "treasure_ng",
                            name = "Treasures",
                            desc = "Treasures that give various items",
                            width = "half",
                            order = 51,
                        },
                        rareNG = {
                            type = "toggle",
                            arg = "rare_ng",
                            name = "Rares",
                            desc = "Rare spawns for leveling players",
                            width = "half",
                            order = 52,
                        },
                        rareHNG = {
                            type = "toggle",
                            arg = "rare_h_ng",
                            name = "Rares - Level 100",
                            desc = "Rare spawns for level 100 players",
                            width = "normal",
                            order = 53,
                        },
                        rareSNG = {
                            type = "toggle",
                            arg = "rare_s_ng",
                            name = "Rares - Steamwheedle Preservation Society",
                            desc = "Rare spawns that drop reputation bonus items",
                            width = "full",
                            order = 54,
                        },
                        groupTJ = {
                            type = "header",
                            name = "Tanaan Jungle",
                            desc = "Tanaan Jungle",
                            order = 60,
                        },
                        treasureTJ = {
                            type = "toggle",
                            arg = "treasure_tj",
                            name = "Treasures",
                            desc = "Treasures that give various items",
                            width = "half",
                            order = 61,
                        },
                        rareHTJ = {
                            type = "toggle",
                            arg = "rare_h_tj",
                            name = "Rares - Level 100",
                            desc = "Rare spawns for level 100 players",
                            width = "normal",
                            order = 62,
                        },
                        rareATJ = {
                            type = "toggle",
                            arg = "rare_a_tj_new",
                            name = "Rares still needed for the [Jungle Stalker] achievement",
                            desc = "This has priority over the option [Always show already looted Rares]",
                            width = "full",
                            order = 63,
                        },
                        groupMount = {
                            type = "header",
                            name = "Mount Rares",
                            desc = "Mount Rares",
                            order = 70,
                        },
                        mountTJ = {
                            type = "toggle",
                            arg = "mount_tj",
                            name = "Tanaan Jungle Rares",
                            desc = "Has a chance to drop an item that contains 1 of 3 different mounts",
                            order = 71,
                        },
                        mountPR = {
                            type = "toggle",
                            arg = "mount_pr",
                            name = "Pathrunner",
                            desc = "Found in Shadowmoon Valley",
                            order = 72,
                        },
                        mountPO = {
                            type = "toggle",
                            arg = "mount_po",
                            name = "Poundfist",
                            desc = "Found in Gorgrond",
                            order = 73,
                        },
                        mountGO = {
                            type = "toggle",
                            arg = "mount_go",
                            name = "Gorok",
                            desc = "Found in Frostfire Ridge",
                            order = 74,
                        },
                        mountSI = {
                            type = "toggle",
                            arg = "mount_si",
                            name = "Silthide",
                            desc = "Found in Talador",
                            order = 75,
                        },
                        mountLU = {
                            type = "toggle",
                            arg = "mount_lu",
                            name = "Luk'hok",
                            desc = "Found in Nagrand",
                            order = 76,
                        },
                        mountNA = {
                            type = "toggle",
                            arg = "mount_na",
                            name = "Nakk the Thunderer",
                            desc = "Found in Nagrand",
                            order = 77,
                        },
                        mountNO = {
                            type = "toggle",
                            arg = "mount_no",
                            name = "Nok-Karosh",
                            desc = "Found in Frostfire Ridge",
                            order = 78,
                        },
                        mountVT = {
                            type = "toggle",
                            arg = "mount_vt",
                            name = "Void Talon",
                            desc = "Portal found in multiple zones",
                            order = 79,
                        },
						groupDH = {
                            type = "header",
                            name = "Demon Hunter",
                            desc = "Demon Hunter only zones",
                            order = 80,
                        },    
                        treasureDH = {
                            type = "toggle",
                            arg = "treasure_dh",
                            name = "Treasures",
                            desc = "Treasures that give various items",
                            width = "normal",
                            order = 81,
                        },
                        rareDH = {
                            type = "toggle",
                            arg = "rare_dh",
                            name = "Rares",
                            desc = "Rare spawns",
                            width = "normal",
                            order = 82,
                        },  
                    },
                },
                alwaysshowrares = {
                    type = "toggle",
                    arg = "alwaysshowrares",
                    name = "Also show already looted Rares",
                    desc = "Show every rare regardless of looted status",
                    order = 100,
                    width = "full",
                },
                alwaysshowtreasures = {
                    type = "toggle",
                    arg = "alwaysshowtreasures",
                    name = "Also show already looted Treasures",
                    desc = "Show every treasure regardless of looted status",
                    order = 101,
                    width = "full",
                },
                show_loot = {
                    type = "toggle",
                    arg = "show_loot",
                    name = "Show Loot",
                    desc = "Shows the Loot for each Treasure/Rare",
                    order = 102,
                },
                show_notes = {
                    type = "toggle",
                    arg = "show_notes",
                    name = "Show Notes",
                    desc = "Shows the notes each Treasure/Rare if available",
                    order = 103,
                },
            },
        },
    },
}

function DraenorTreasures:OnInitialize()
    local defaults = {
        profile = {
            icon_scale_treasures = 1.5,
            icon_scale_rares = 2.0,
            icon_alpha = 1.00,
            alwaysshowrares = false,
            alwaysshowtreasures = false,
            save = true,
            treasure_smv = true,
            treasure_ffr = true,
            treasure_ffr_bsf = true,
            treasure_gg = true,
            treasure_gg_b = true,
            treasure_gg_l = true,
            treasure_ng = true,
            treasure_soa = true,
            treasure_soa_a = true,
            treasure_td = true,
            treasure_tj = true,
			treasure_dh = true,
            rare_smv = true,
            rare_ffr = true,
            rare_gg = true,
            rare_td = true,
            rare_soa = true,
            rare_ng = true,
            rare_h_gg = true,
            rare_h_ffr = true,
            rare_s_gg = true,
            rare_h_td = true,
            rare_h_soa = true,
            rare_h_ng = true,
            rare_h_tj = true,
            rare_s_gg = true,
            rare_s_ng = true,
            rare_a_tj_new = false,
			rare_dh = true,
            mount_tj = true,
            mount_pr = true,
            mount_go = true,
            mount_no = true,
            mount_po = true,
            mount_si = true,
            mount_na = true,
            mount_lu = true,
            mount_vt = true,
			gorgrond_override = false,
            world_bosses = true,
            show_loot = true,
            show_notes = true,
        },
    }

    self.db = LibStub("AceDB-3.0"):New("DraenorTreasuresDB", defaults, "Default")
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "WorldEnter")
end

function DraenorTreasures:WorldEnter()
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    self:ScheduleTimer("QuestCheck", 5)
    self:ScheduleTimer("RegisterWithHandyNotes", 8)
	self:ScheduleTimer("LoadCheck",6)
	--self:ScheduleTimer("LoginMessage", 10)
end

function DraenorTreasures:QuestCheck()
    do
        if ((IsQuestFlaggedCompleted(36386) == false) or (IsQuestFlaggedCompleted(36390) == false) or (IsQuestFlaggedCompleted(36389) == false) or (IsQuestFlaggedCompleted(36392) == false) or (IsQuestFlaggedCompleted(36388) == false) or (IsQuestFlaggedCompleted(36381) == false)) then
            nodes["SpiresOfArak"][43901500]={ "36395", "Elixir of Shadow Sight 1", "Elixir of Shadow Sight", "Elixir can be used at Shrine of Terrok for 1 of 6 i585 Weapons (see Gift of Anzu) Object will be removed as soon as you loot all Gifts of Anzu", "default", "treasure_soa","115463"}
            nodes["SpiresOfArak"][43802470]={ "36397", "Elixir of Shadow Sight 2", "Elixir of Shadow Sight", "Elixir can be used at Shrine of Terrok for 1 of 6 i585 Weapons (see Gift of Anzu) Object will be removed as soon as you loot all Gifts of Anzu", "default", "treasure_soa","115463"}
            nodes["SpiresOfArak"][69204330]={ "36398", "Elixir of Shadow Sight 3", "Elixir of Shadow Sight", "Elixir can be used at Shrine of Terrok for 1 of 6 i585 Weapons (see Gift of Anzu) Object will be removed as soon as you loot all Gifts of Anzu", "default", "treasure_soa","115463"}
            nodes["SpiresOfArak"][48906250]={ "36399", "Elixir of Shadow Sight 4", "Elixir of Shadow Sight", "Elixir can be used at Shrine of Terrok for 1 of 6 i585 Weapons (see Gift of Anzu) Object will be removed as soon as you loot all Gifts of Anzu", "default", "treasure_soa","115463"}
            nodes["SpiresOfArak"][55602200]={ "36400", "Elixir of Shadow Sight 5", "Elixir of Shadow Sight", "Elixir can be used at Shrine of Terrok for 1 of 6 i585 Weapons (see Gift of Anzu) Object will be removed as soon as you loot all Gifts of Anzu", "default", "treasure_soa","115463"}
            nodes["SpiresOfArak"][53108450]={ "36401", "Elixir of Shadow Sight 6", "Elixir of Shadow Sight", "Elixir can be used at Shrine of Terrok for 1 of 6 i585 Weapons (see Gift of Anzu) Object will be removed as soon as you loot all Gifts of Anzu", "default", "treasure_soa","115463"}
        end
        if (IsQuestFlaggedCompleted(36249) or IsQuestFlaggedCompleted(36250) or DraenorTreasures.db.profile.gorgrond_override == true) then
            --Gorgrond Lumber Mill is active if either of these Quest IDs are true
            nodes["Gorgrond"][49074846]={ "35952", "Aged Stone Container", "", "QuestID is missing, will stay active until manually disabled", "default", "treasure_gg_l","824"}
            nodes["Gorgrond"][42345477]={ "36003", "Aged Stone Container", "", "", "default", "treasure_gg_l","824"}
            nodes["Gorgrond"][47514363]={ "36717", "Aged Stone Container", "", "", "default", "treasure_gg_l","824"}
            nodes["Gorgrond"][53354679]={ "35701", "Ancient Titan Chest", "", "", "default", "treasure_gg_l","824"}
            nodes["Gorgrond"][50155376]={ "35984", "Ancient Titan Chest", "", "", "default", "treasure_gg_l","824"}
            nodes["Gorgrond"][42084607]={ "36720", "Ancient Titan Chest", "", "", "default", "treasure_gg_l","824"}
            nodes["Gorgrond"][41988155]={ "35982", "Botani Essence Seed", "", "", "default", "treasure_gg_l","824"}
            nodes["Gorgrond"][49657883]={ "35968", "Forgotten Ogre Cache", "", "", "default", "treasure_gg_l","824"}
            nodes["Gorgrond"][47016905]={ "35971", "Forgotten Skull Cache", "", "", "default", "treasure_gg_l","824"}
            nodes["Gorgrond"][45808931]={ "36019", "Forgotten Skull Cache", "", "", "default", "treasure_gg_l","824"}
            nodes["Gorgrond"][39335627]={ "36716", "Forgotten Skull Cache", "", "", "default", "treasure_gg_l","824"}
            nodes["Gorgrond"][56745727]={ "35965", "Mysterious Petrified Pod", "", "", "default", "treasure_gg_l","824"}
            nodes["Gorgrond"][41147726]={ "35980", "Mysterious Petrified Pod", "", "", "default", "treasure_gg_l","824"}
            nodes["Gorgrond"][60507276]={ "36015", "Mysterious Petrified Pod", "", "", "default", "treasure_gg_l","824"}
            nodes["Gorgrond"][63285719]={ "36430", "Mysterious Petrified Pod", "", "", "default", "treasure_gg_l","824"}
            nodes["Gorgrond"][47647679]={ "36714", "Mysterious Petrified Pod", "", "", "default", "treasure_gg_l","824"}
            nodes["Gorgrond"][51756909]={ "36715", "Mysterious Petrified Pod", "", "", "default", "treasure_gg_l","824"}
            nodes["Gorgrond"][40956732]={ "35979", "Obsidian Crystal Formation", "", "", "default", "treasure_gg_l","824"}
            nodes["Gorgrond"][45969357]={ "35975", "Remains of Explorer Engineer Toldirk Ashlamp", "", "", "default", "treasure_gg_l","824"}
            nodes["Gorgrond"][51806148]={ "35966", "Remains of Grimnir Ashpick", "", "", "default", "treasure_gg_l","824"}
            nodes["Gorgrond"][51647226]={ "35967", "Unknown Petrified Egg", "", "", "default", "treasure_gg_l","824"}
            nodes["Gorgrond"][45318195]={ "35981", "Unknown Petrified Egg", "", "", "default", "treasure_gg_l","824"}
            nodes["Gorgrond"][42914350]={ "36001", "Unknown Petrified Egg", "", "", "default", "treasure_gg_l","824"}
            nodes["Gorgrond"][53007906]={ "36713", "Unknown Petrified Egg", "", "", "default", "treasure_gg_l","824"}
            nodes["Gorgrond"][47245180]={ "36718", "Unknown Petrified Egg", "", "", "default", "treasure_gg_l","824"}
        end
        if (IsQuestFlaggedCompleted(36251) or IsQuestFlaggedCompleted(36252) or DraenorTreasures.db.profile.gorgrond_override == true) then
            --Gorgrond Sparring Arena is active if either of these Quest IDs are true
            nodes["Gorgrond"][45634931]={ "36722", "Aged Stone Container", "", "", "default", "treasure_gg_b","824"}
            nodes["Gorgrond"][43224574]={ "36723", "Aged Stone Container", "", "", "default", "treasure_gg_b","824"}
            nodes["Gorgrond"][41764527]={ "36726", "Aged Stone Container", "", "", "default", "treasure_gg_b","824"}
            nodes["Gorgrond"][48115516]={ "36730", "Aged Stone Container", "", "", "default", "treasure_gg_b","824"}
            nodes["Gorgrond"][51334055]={ "36734", "Aged Stone Container", "", "", "default", "treasure_gg_b","824"}
            nodes["Gorgrond"][46056305]={ "36736", "Aged Stone Container", "", "", "default", "treasure_gg_b","824"}
            nodes["Gorgrond"][58125146]={ "36739", "Aged Stone Container", "", "", "default", "treasure_gg_b","824"}
            nodes["Gorgrond"][59567275]={ "36781", "Aged Stone Container", "", "", "default", "treasure_gg_b","824"}
            nodes["Gorgrond"][45748821]={ "36784", "Aged Stone Container", "", "", "default", "treasure_gg_b","824"}
            nodes["Gorgrond"][45544298]={ "36733", "Ancient Ogre Cache", "", "", "default", "treasure_gg_b","824"}
            nodes["Gorgrond"][45076993]={ "36737", "Ancient Ogre Cache", "", "", "default", "treasure_gg_b","824"}
            nodes["Gorgrond"][61555855]={ "36740", "Ancient Ogre Cache", "", "", "default", "treasure_gg_b","824"}
            nodes["Gorgrond"][54257313]={ "36782", "Ancient Ogre Cache", "", "", "default", "treasure_gg_b","824"}
            nodes["Gorgrond"][42179308]={ "36787", "Ancient Ogre Cache", "", "", "default", "treasure_gg_b","824"}
            nodes["Gorgrond"][41528652]={ "36789", "Ancient Ogre Cache", "", "", "default", "treasure_gg_b","824"}
            nodes["Gorgrond"][49425084]={ "36710", "Ancient Titan Chest", "", "", "default", "treasure_gg_b","824"}
            nodes["Gorgrond"][42195203]={ "36727", "Ancient Titan Chest", "", "", "default", "treasure_gg_b","824"}
            nodes["Gorgrond"][43365169]={ "36731", "Ancient Titan Chest", "", "", "default", "treasure_gg_b","824"}
            nodes["Gorgrond"][47923998]={ "36735", "Ancient Titan Chest", "", "", "default", "treasure_gg_b","824"}
            nodes["Gorgrond"][50326658]={ "36738", "Ancient Titan Chest", "", "", "default", "treasure_gg_b","824"}
            nodes["Gorgrond"][49128248]={ "36783", "Ancient Titan Chest", "", "", "default", "treasure_gg_b","824"}
            nodes["Gorgrond"][48114638]={ "36721", "Obsidian Crystal Formation", "", "", "default", "treasure_gg_b","824"}
            nodes["Gorgrond"][41855889]={ "36728", "Obsidian Crystal Formation", "", "", "default", "treasure_gg_b","824"}
            nodes["Gorgrond"][42056429]={ "36729", "Obsidian Crystal Formation", "", "", "default", "treasure_gg_b","824"}
            nodes["Gorgrond"][44184665]={ "36732", "Obsidian Crystal Formation", "", "", "default", "treasure_gg_b","824"}
        end
    end
end

function DraenorTreasures:RegisterWithHandyNotes()
    do
        local function iter(t, prestate)
            if not t then return nil end

            local state, value = next(t, prestate)

            while state do
                if (value[1] and self.db.profile[value[6]] and not DraenorTreasures:HasBeenLooted(value)) and (value[6] == "rare_h_tj") then
                    if (self.db.profile.rare_a_tj_new) then
                        if ((value[8] ~= nil) and (value[8] ~= "")) then
                            local _, _, completed, _, _, _, _, _, _, _, _ = GetAchievementCriteriaInfoByID(10070, value[8])

                            if (completed == false) then
                                if ((value[7] ~= nil) and (value[7] ~= "")) then
                                    GetIcon(value[7]) --this should precache the Item, so that the loot is correctly returned
                                end

                                if ((value[5] == "default") or (value[5] == "unknown")) then
                                    if ((value[7] ~= nil) and (value[7] ~= "")) then
                                        return state, nil, GetIcon(value[7]), DraenorTreasures.db.profile.icon_scale_treasures, DraenorTreasures.db.profile.icon_alpha
                                    else
                                        return state, nil, iconDefaults[value[5]], DraenorTreasures.db.profile.icon_scale_treasures, DraenorTreasures.db.profile.icon_alpha
                                    end
                                end

                                return state, nil, iconDefaults[value[5]], DraenorTreasures.db.profile.icon_scale_rares, DraenorTreasures.db.profile.icon_alpha
                            end
                        end
                    else
                        if ((value[7] ~= nil) and (value[7] ~= "")) then
                            GetIcon(value[7]) --this should precache the Item, so that the loot is correctly returned
                        end

                        if ((value[5] == "default") or (value[5] == "unknown")) then
                            if ((value[7] ~= nil) and (value[7] ~= "")) then
                                return state, nil, GetIcon(value[7]), DraenorTreasures.db.profile.icon_scale_treasures, DraenorTreasures.db.profile.icon_alpha
                            else
                                return state, nil, iconDefaults[value[5]], DraenorTreasures.db.profile.icon_scale_treasures, DraenorTreasures.db.profile.icon_alpha
                            end
                        end

                        return state, nil, iconDefaults[value[5]], DraenorTreasures.db.profile.icon_scale_rares, DraenorTreasures.db.profile.icon_alpha 
                    end
                end

                -- QuestID[1], Name[2], Loot[3], Notes[4], Icon[5], Tag[6], ItemID[7]
                if (value[1] and self.db.profile[value[6]] and not DraenorTreasures:HasBeenLooted(value)) and (value[6] ~= "rare_h_tj") then
                    if ((value[7] ~= nil) and (value[7] ~= "")) then
                        GetIcon(value[7]) --this should precache the Item, so that the loot is correctly returned
                    end

                    if ((value[5] == "default") or (value[5] == "unknown")) then
                        if ((value[7] ~= nil) and (value[7] ~= "")) then
                            return state, nil, GetIcon(value[7]), DraenorTreasures.db.profile.icon_scale_treasures, DraenorTreasures.db.profile.icon_alpha
                        else
                            return state, nil, iconDefaults[value[5]], DraenorTreasures.db.profile.icon_scale_treasures, DraenorTreasures.db.profile.icon_alpha
                        end
                    end

                    return state, nil, iconDefaults[value[5]], DraenorTreasures.db.profile.icon_scale_rares, DraenorTreasures.db.profile.icon_alpha
                end

                state, value = next(t, state)
            end
        end

        function DraenorTreasures:GetNodes(mapFile, isMinimapUpdate, dungeonLevel)
            return iter, nodes[mapFile], nil
        end
    end

    HandyNotes:RegisterPluginDB("DraenorTreasures", self, options)
    self:RegisterBucketEvent({ "LOOT_CLOSED" }, 2, "Refresh")
    self:Refresh()
end
 
function DraenorTreasures:Refresh()
    self:SendMessage("HandyNotes_NotifyUpdate", "DraenorTreasures")
end

function DTResetDB()
    table.wipe(DraenorTreasures.db.char)
    DraenorTreasures:Refresh()
end

function DraenorTreasures:HasBeenLooted(value)
    if (self.db.profile.alwaysshowtreasures and (string.find(value[6], "treasure") ~= nil)) then return false end
    if (self.db.profile.alwaysshowrares and (string.find(value[6], "treasure") == nil)) then return false end
    if (DraenorTreasures.db.char[value[1]] and self.db.profile.save) then return true end
    if (IsQuestFlaggedCompleted(value[1])) then
        return true
    end

    return false
end

function DTDisableTreasure(button, mapFile, coord)
    if (nodes[mapFile][coord][1] ~= nil) then
        DraenorTreasures.db.char[nodes[mapFile][coord][1]] = true;
    end

    DraenorTreasures:Refresh()
end

function DraenorTreasures:LoadCheck()
	if (IsAddOnLoaded("TomTom")) then 
		isTomTomloaded = true
	end

	if (IsAddOnLoaded("DBM-Core")) then 
		isDBMloaded = true
	end

	if (IsAddOnLoaded("HandyNotes_LegionRaresTreasures")) then 
		isHN_LRTloaded = true
	end

	if isDBMloaded == true then
		local ArrowDesc = DBMArrow:CreateFontString(nil, "OVERLAY", "GameTooltipText")
		ArrowDesc:SetWidth(400)
		ArrowDesc:SetHeight(100)
		ArrowDesc:SetPoint("CENTER", DBMArrow, "CENTER", 0, -35)
		ArrowDesc:SetTextColor(1, 1, 1, 1)
		ArrowDesc:SetJustifyH("CENTER")
		DBMArrow.Desc = ArrowDesc
	end
end

function DTaddtoTomTom(button, mapFile, coord)
    if isTomTomloaded == true then
        local mapId = HandyNotes:GetMapFiletoMapID(mapFile)
        local x, y = HandyNotes:getXY(coord)
        local desc = nodes[mapFile][coord][2];

        if (nodes[mapFile][coord][3] ~= nil) and (DraenorTreasures.db.profile.show_loot == true) then
            if ((nodes[mapFile][coord][7] ~= nil) and (nodes[mapFile][coord][7] ~= "")) then
                desc = desc.."\nLoot: " .. GetItem(nodes[mapFile][coord][7]);
                desc = desc.."\nLoot Info: " .. nodes[mapFile][coord][3];
            else
                desc = desc.."\nLoot: " .. nodes[mapFile][coord][3];
            end
        end

        if (nodes[mapFile][coord][4] ~= "") and (DraenorTreasures.db.profile.show_notes == true) then
            desc = desc.."\nNotes: " .. nodes[mapFile][coord][4]
        end

        TomTom:AddMFWaypoint(mapId, nil, x, y, {
            title = desc,
            persistent = nil,
            minimap = true,
            world = true
        })
    end
end

function DTAddDBMArrow(button, mapFile, coord)
    if isDBMloaded == true then
        local mapId = HandyNotes:GetMapFiletoMapID(mapFile)
        local x, y = HandyNotes:getXY(coord)
        local desc = nodes[mapFile][coord][2];

        if (nodes[mapFile][coord][3] ~= nil) and (DraenorTreasures.db.profile.show_loot == true) then
            if ((nodes[mapFile][coord][7] ~= nil) and (nodes[mapFile][coord][7] ~= "")) then
                desc = desc.."\nLoot: " .. GetItem(nodes[mapFile][coord][7]);
                desc = desc.."\nLootinfo: " .. nodes[mapFile][coord][3];
            else
                desc = desc.."\nLoot: " .. nodes[mapFile][coord][3];
            end
        end

        if (nodes[mapFile][coord][4] ~= "") and (DraenorTreasures.db.profile.show_notes == true) then
            desc = desc.."\nNotes: " .. nodes[mapFile][coord][4]
        end
		if not DBMArrow.Desc:IsShown() then
			DBMArrow.Desc:Show()
		end

        x = x*100
        y = y*100
		DBMArrow.Desc:SetText(desc)
		DBM.Arrow:ShowRunTo(x, y, nil, nil, true)
    end
end

function DTHideDBMArrow()
    DBM.Arrow:Hide(true)
end

function DraenorTreasures:LoginMessage()
	if isHN_LRTloaded == false then
	print("|cff00E5EE<|cffFFC125HN:DraenorTreasures|cff00E5EE>|cff00ff00In preparation for the legion release the treasures and rares for the |cffA330C9Demon Hunter|cff00ff00 starting experience have been temporarily added to this addon.")
	--print("|cff00ff00These together with all the treasures and rares in the new legion zones can be found in the new addon |cffff0000Handynotes_LegionRares&Treasures |cff00ff00available through Curse.com")
	--print("|cff00ccffhttp://www.curse.com/addons/wow/handynotes_legionrarestreasures")
	end 
end