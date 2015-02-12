DraenorTreasures = LibStub("AceAddon-3.0"):NewAddon("DraenorTreasures", "AceBucket-3.0", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
local HandyNotes = LibStub("AceAddon-3.0"):GetAddon("HandyNotes", true)
if not HandyNotes then return end
local iconDefaults = {
default = "Interface\\Icons\\TRADE_ARCHAEOLOGY_CHESTOFTINYGLASSANIMALS",
unknown = "Interface\\Addons\\HandyNotes_DraenorTreasures\\Artwork\\chest_normal_daily.tga",
hundredrare = "Interface\\Addons\\HandyNotes_DraenorTreasures\\Artwork\\RareIconBlue.tga",
rare = "Interface\\Addons\\HandyNotes_DraenorTreasures\\Artwork\\RareIcon.tga",
swprare = "Interface\\Icons\\Trade_Archaeology_Fossil_SnailShell",
shrine = "Interface\\Icons\\inv_misc_statue_02",
glider = "Interface\\Icons\\inv_feather_04",
rocket = "Interface\\Icons\\ability_mount_rocketmount",
}
local PlayerFaction, _ = UnitFactionGroup("player")
DraenorTreasures.nodes = { }
local nodes = DraenorTreasures.nodes
local isTomTomloaded = false

if (IsAddOnLoaded("TomTom")) then 
	isTomTomloaded = true
end


nodes["ShadowmoonValleyDR"] = {
--SMV Treasures
[54924501]={ "35581", "Alchemist's Satchel", "Herbs", "", "default", "SMVTreasures","109124"},
[52834837]={ "35584", "Ancestral Greataxe", "i519 2H Strength Axe", "", "default", "SMVTreasures","113560"},
[41422798]={ "33869", "Armored Elekk Tusk", "i518 Trinket Bonus Armor + Mastery on use", "", "default", "SMVTreasures","108902"},
[37784435]={ "33584", "Ashes of A'kumbo", "Consumable for Rested XP", "", "default", "SMVTreasures","113531"},
[49313760]={ "33867", "Astrologer's Box", "Toy", "", "default", "SMVTreasures","109739"},
[36774142]={ "33046", "Beloved's Offering", "Flavor Item - Offhand", "", "default", "SMVTreasures","113547"},
[37182313]={ "33613", "Bubbling Cauldron", "i516 Caster Offhand", "In a cave; the entrance is slightly to the northeast, at 38, 22.3", "default", "SMVTreasures","108945"},
[84564478]={ "33885", "Cargo of the Raven Queen", "Garrison Resources", "", "default", "SMVTreasures","824"},
[33453961]={ "33569", "Carved Drinking Horn", "Reusable Mana Potion", "", "default", "SMVTreasures","113545"},
[61706790]={ "34743", "Crystal Blade of Torvath", "Trash Item", "Interacting with the object causes three Silverleaf Ancients to spawn; you can only loot the item after they are dead", "default", "SMVTreasures","111636"},
[20383065]={ "33575", "Demonic Cache", "i550 Intellect Neck", "", "default", "SMVTreasures","108904"},
[29853748]={ "36879", "Dusty Lockbox", "Random Greens + Gold", "On top of a giant stone arch; to reach it, jump across the other stone arches, starting on a cliff ledge to the west", "default", "SMVTreasures","824"},
[51753549]={ "33037", "False-Bottomed Jar", "Gold", "", "default", "SMVTreasures","824"},
[26530568]={ "34174", "Fantastic Fish", "Garrison Resources", "", "default", "SMVTreasures","824"},
[34394623]={ "33891", "Giant Moonwillow Cone", "i522 Wand", "", "default", "SMVTreasures","108901"},
[48724753]={ "35798", "Glowing Cave Mushroom", "Herbs", "", "default", "SMVTreasures","109127"},
[38484308]={ "33614", "Greka's Urn", "i528 Trinket Haste + Strength Proc", "", "default", "SMVTreasures","113408"},
[47154603]={ "33564", "Hanging Satchel", "i518 Agility/Intellect Leather Gloves", "", "default", "SMVTreasures","108900"},
[42106130]={ "33041", "Iron Horde Cargo Shipment", "Garrison Resources", "", "default", "SMVTreasures","824"},
[37515925]={ "33567", "Iron Horde Tribute", "Trinket Multistrike + DMG on use", "", "default", "SMVTreasures","108903"},
[57924531]={ "33568", "Kaliri Egg", "25 Garrison Resources", "", "default", "SMVTreasures","113271"},
[58882193]={ "35603", "Mikkal's Chest", "Trash Item", "", "default", "SMVTreasures","113215"},
[52882486]={ "37254", "Mushroom-Covered Chest", "25 Garrison Resources", "", "default", "SMVTreasures","113388"},
[66963349]={ "36507", "Orc Skeleton", "i526 Strength Ring", "", "default", "SMVTreasures","116875"},
[43756062]={ "33611", "Peaceful Offering 1", "Trash Items", "", "default", "SMVTreasures","107650"},
[45226049]={ "33610", "Peaceful Offering 2", "Trash Items", "", "default", "SMVTreasures","107650"},
[44486357]={ "33384", "Peaceful Offering 3", "Trash Items", "", "default", "SMVTreasures","107650"},
[44495914]={ "33612", "Peaceful Offering 4", "Trash Items", "", "default", "SMVTreasures","107650"},
[31223905]={ "33886", "Ronokk's Belongings", "i522 Strength Cloak", "", "default", "SMVTreasures","109081"},
[22893385]={ "33572", "Rotting Basket", "Trash Item", "Inside Bloodthorn Cave", "default", "SMVTreasures","113373"},
[36684455]={ "33573", "Rovo's Dagger", "i520 Agility Dagger", "", "default", "SMVTreasures","113378"},
[67058418]={ "33565", "Scaly Rylak Egg", "Trash Item", "!!! LEVEL 100 AREA !!!", "default", "SMVTreasures","44722"},
[45822458]={ "33570", "Shadowmoon Exile Treasure", "25 Garrison Resources", "In a cave below Exile Rise", "default", "SMVTreasures","113388"},
[29994536]={ "35919", "Shadowmoon Sacrificial Dagger", "i524 Caster Dagger", "", "default", "SMVTreasures","113563"},
[28233924]={ "33883", "Shadowmoon Treasure", "Garrison Resources", "", "default", "SMVTreasures","824"},
[27050248]={ "35280", "Stolen Treasure", "Garrison Resources", "", "default", "SMVTreasures","824"},
[55821997]={ "35600", "Strange Spore", "Pet", "On top of the giant mushroom", "default", "SMVTreasures","118104"},
[37192601]={ "35677", "Sunken Fishing boat", "Fish", "", "default", "SMVTreasures","118414"},
[28820720]={ "35279", "Sunken Treasure", "Garrison Resources", "", "default", "SMVTreasures","824"},
[55297487]={ "35580", "Swamplighter Hive", "Toy", "", "default", "SMVTreasures","117550"},
[35854087]={ "33540", "Uzko's Knickknacks", "i525 Agility/Intellect Leather Boots", "", "default", "SMVTreasures","113546"},
[34214353]={ "33866", "Veema's Herb Bag", "Herbs", "", "default", "SMVTreasures","109124"},
[51147912]={ "33574", "Vindicator's Cache", "Toy", "!!! LEVEL 100 AREA !!!", "default", "SMVTreasures","113375"},
[39208391]={ "33566", "Waterlogged Chest", "i520 Strength Fist Weapon + Garrison Resources", "", "default", "SMVTreasures","113372"},
--SMVRares
[37203640]={ "33061", "Amaukwa", "i516 Agility/Intellect Mail Body", "Flies around a very large area", "rare", "SMVRares","109060"},
[50807880]={ "37356", "Aqualir", "i620 Intellect Ring", "!!! Level 101 !!!", "hundredrare", "SMVHundred","119387"},
[68208480]={ "37410", "Avalanche", "i620 Strength 1H Mace", "!!! Level 100 !!!", "hundredrare", "SMVHundred","119400"},
[52801680]={ "35731", "Ba'ruun", "Reusable Food without Buff", "", "rare", "SMVRares","113540"},
[43807740]={ "33383", "Brambleking Fili", "i620 Agility Staff", "!!! Level 100 !!!", "hundredrare", "SMVHundred","117551"},
[48604360]={ "33064", "Dark Emanation", "i516 Intellect Fistweapon", "Inside a cave; kill cultists to make him attackable", "rare", "SMVRares","109075"},
[41008300]={ "35448", "Darkmaster Go'vid", "i525 Intellect Staff + Lobstrok Summon", "", "rare", "SMVRares","113548"},
[49604200]={ "35555", "Darktalon", "i520 Agility Cloak", "", "rare", "SMVRares","113541"},
[46007160]={ "37351", "Demidos", "i620 Agility/Strength Tank Neck + Pet + Achievement", "!!! Level 102 !!! To get to his plateau from Sorcethar's Rise, jump up on rocks on the east side", "hundredrare", "SMVHundred","119377"},
[67806380]={ "35688", "Enavra", "i523 Intellect Neck", "Interacting with her corpse spawns her spirit to fight", "rare", "SMVRares","113556"},
[61606180]={ "35725", "Faebright", "i526 Agility/Intellect Leather Pants", "", "rare", "SMVRares","113557"},
[37404880]={ "35558", "Hypnocroak", "Toy", "", "rare", "SMVRares","113631"},
[57404840]={ "35909", "Insha'tar", "i520 Agility/Intellect Mail Boots", "", "rare", "SMVRares","113571"},
[40804440]={ "33043", "Killmaw", "i516 Agility Dagger", "", "rare", "SMVRares","109078"},
[32203500]={ "33039", "Ku'targ the Voidseer", "i516 Agility/Intellect Mail Gloves", "", "rare", "SMVRares","109061"},
[48007760]={ "37355", "Lady Temptessa", "i620 Agility/Intellect Leather Boots", "!!! Level 101 !!!", "hundredrare", "SMVHundred","119360"},
[37601460]={ "33055", "Leaf-Reader Kurri", "i518 Trinket Versatility + Heal Proc", "", "rare", "SMVRares","108907"},
[44802080]={ "35906", "Mad King Sporeon", "i519 Agility Staff", "", "rare", "SMVRares","113561"},
[29605080]={ "37357", "Malgosh Shadowkeeper", "i620 Agility/Intellect Mail Helm", "!!! Level 100 !!!", "hundredrare", "SMVHundred","119369"},
[51807920]={ "37353", "Master Sergeant Milgra", "i620 Agility/Intellect Mail Gloves", "!!! Level 101 !!!", "hundredrare", "SMVHundred","119368"},
[38607020]={ "35523", "Morva Soultwister", "i520 1H Caster Mace", "", "rare", "SMVRares","113559"},
[44005760]={ "33642", "Mother Om'ra", "i522 Trinket Int + Mastery Proc", "Kill cultists to make her attackable", "rare", "SMVRares","113527"},
[58408680]={ "37409", "Nagidna", "i620 Agility/Intellect Leather Shoulders", "!!! Level 100 !!! In a Cave - Entrance is at 59,89", "hundredrare", "SMVHundred","119364"},
[50207240]={ "37352", "Quartermaster Hershak", "i620 Strength/Intellect Plate Pants", "!!! Level 101 !!!", "hundredrare", "SMVHundred","119382"},
[48602260]={ "35553", "Rai'vosh", "Reusable Slowfall Item", "", "rare", "SMVRares","113542"},
[53005060]={ "34068", "Rockhoof", "i516 Strength Shield", "", "rare", "SMVRares","109077"},
[48208100]={ "37354", "Shadowspeaker Niir", "i620 Caster Dagger", "!!! Level 101 !!!", "hundredrare", "SMVHundred","119396"},
[61005520]={ "35732", "Shinri", "400% Ground Mount with Cooldown", "Roams in a large area - often evades and despawns", "rare", "SMVRares","113543"},
[61408880]={ "37411", "Slivermaw", "i620 Strength 2H Sword", "!!! Level 100 !!!", "hundredrare", "SMVHundred","119411"},
[27604360]={ "36880", "Sneevel", "i519 Cloth Pants", "", "rare", "SMVRares","118734"},
[21602100]={ "33640", "Veloss", "i516 Intellect Ring", "", "rare", "SMVRares","108906"},
[54607060]={ "33643", "Venomshade", "i516 Agility/Intellect Leather Boots", "", "rare", "SMVRares","108957"},
[31905720]={ "37359", "Voidreaver Urnae", "i620 Agility 1H Axe", "!!! Level 100 !!!", "hundredrare", "SMVHundred","119392"},
[32604140]={ "35847", "Voidseer Kalurg", "i516 Cloth Waist", "Kill cultists to make him attackable", "rare", "SMVRares","109074"},
[48806640]={ "33389", "Yggdrel", "Toy", "", "rare", "SMVRares","113570"},
[29405150]={ "37357", "Malgosh Shadowkeeper", "i620 Agility/Intellect Mail Helm", "!!! Level 100 !!!", "hundredrare", "SMVHundred","119369"},
}
nodes["FrostfireRidge"] = {
--FFRTreasures
[23172495]={ "33916", "Arena Master's War Horn", "Toy", "Up in the stands above the arena", "default", "FFRTreasures","108735"},
[24242712]={ "33501", "Arena Spectator's Chest", "Alcoholic Beverages", "On top of the stone arch; jump to it from the top of the nearby tower", "default", "FFRTreasures","63293"},
[61904254]={ "33511", "Borrok the Devourer", "i516 Intellect Shield", "Feed him 20 Ogres to get the loot", "default", "FFRTreasures","112110"},
[42161930]={ "34520", "Burning Pearl", "i525 Trinket Multistrike + Mastery Proc", "!!! LEVEL 100 AREA !!!", "default", "FFRTreasures","120341"},
[50161870]={ "33531", "Clumsy Cragmaul Brute", "i516 Agility/Intellect Mail Helm", "!!! LEVEL 100 AREA !!! On lower cliff ledge", "default", "FFRTreasures","112096"},
[42663175]={ "33940", "Crag-Leaper's Cache", "i516 Agility/Intellect Mail Boots", "Jump on the spears in the wall to reach it", "default", "FFRTreasures","112187"},
[40902010]={ "34473", "Envoy's Satchel", "Trash Item", "!!! LEVEL 100 AREA !!!", "default", "FFRTreasures","110536"},
[43665562]={ "34841", "Forgotten Supplies", "Garrison Resources", "", "default", "FFRTreasures","824"},
[24184860]={ "34507", "Frozen Frostwolf Axe", "i516 Spellpower Axe", "in a cave", "default", "FFRTreasures","110689"},
[57175216]={ "34476", "Frozen Orc Skeleton", "i516 Trinket Mastery + Pet Proc", "", "default", "FFRTreasures","111554"},
[25522050]={ "34648", "Gnawed Bone", "i516 Agility Dagger", "", "default", "FFRTreasures","111415"},
[66712640]={ "33948", "Goren Leftovers", "25 Garrison Resources", "!!! LEVEL 100 AREA !!! In a cave on top of a mountain, path upwards starts at 69.3, 24", "default", "FFRTreasures","111543"},
[68124586]={ "33947", "Grimfrost Treasure", "Garrison Resources", "", "default", "FFRTreasures","824"},
[56727186]={ "36863", "Iron Horde Munitions", "Garrison Resources", "", "default", "FFRTreasures","824"},
[68906910]={ "33017", "Iron Horde Supplies", "Garrison Resources", "", "default", "FFRTreasures","824"},
[21890963]={ "33926", "Lagoon Pool", "Toy", "Requires Fishing", "default", "FFRTreasures","108739"},
[19211202]={ "34642", "Lucky Coin", "Flavor Item - Gold Coin", "Sells for 25g", "default", "FFRTreasures","111408"},
[38303782]={ "33502", "Obsidian Petroglyph", "Consumable for 5% rested XP", "On a mountain; ramp starts up the mountain at 39, 42.5", "default", "FFRTreasures","112087"},
[28296663]={ "34470", "Pale Fishmonger", "Fish", "", "default", "FFRTreasures","111666"},
[21685076]={ "34931", "Pale Loot Sack", "Garrison Resources", "In a cave", "default", "FFRTreasures","824"},
[37265914]={ "34967", "Raided Loot", "Garrison Resources", "On top of the tower", "default", "FFRTreasures","824"},
[09834533]={ "34641", "Sealed Jug", "Flavor Item - Lore", "", "default", "FFRTreasures","111407"},
[27654280]={ "33500", "Slave's Stash", "Alcoholic Beverages", "", "default", "FFRTreasures","43696"},
[23971291]={ "34647", "Snow-Covered Strongbox", "Garrison Resources", "", "default", "FFRTreasures","824"},
[16124972]={ "33942", "Supply Dump", "Garrison Resources", "", "default", "FFRTreasures","824"},
[64722573]={ "33946", "Survivalist's Cache", "Garrison Resources", "", "default", "FFRTreasures","824"},
[34192348]={ "32803", "Thunderlord Cache", "i516 Agility/Strength Polearm", "", "default", "FFRTreasures","107658"},
[64406586]={ "33505", "Wiggling Egg", "Pet", "", "default", "FFRTreasures","112107"},
[54843545]={ "33525", "Young Orc Traveler", "unknown", "You need to Collect Parts from Young Orc Woman and Young Orc Traveler to finish this", "default", "FFRTreasures","112206"},
[63401470]={ "33525", "Young Orc Woman", "unknown", "You need to Collect Parts from Young Orc Woman and Young Orc Traveler to finish this", "default", "FFRTreasures","112206"},
[39661718]={ "33532", "Cragmaul Cache", "Primal Spirit + Apexis Crystals", "!!! LEVEL 100 AREA !!!", "default", "FFRTreasures","120945"},
[45365034]={ "33011", "Grizzled Frostwolf Veteran", "i516 Trinket Stamina + 2% Heal on Kill", "Loot contained in Dusty Chest after talking to NPC and defeating waves of orcs", "default", "FFRTreasures","106899"},
--FFRRares
[88605740]={ "37525", "Ak'ox the Slaughterer", "i620 Agility/Intellect Leather Waist", "!!! Level 100 !!!", "hundredrare", "FFRHundred","119365"},
[27405000]={ "34497", "Breathless", "Toy", "", "rare", "FFRRares","111476"},
[66403140]={ "33843", "Broodmother Reeg'ak", "i516 Trinket Intellect + Multistrike Proc", "", "rare", "FFRRares","111533"},
[34002320]={ "32941", "Canyon Icemother", "25 Garrison Resources", "", "rare", "FFRRares","101436"},
[41206820]={ "34843", "Chillfang", "i513 Agility/Intellect Leather Pants", "", "rare", "FFRRares","111953"},
[40404700]={ "33014", "Cindermaw", "i516 Caster Dagger", "", "rare", "FFRRares","111490"},
[25405500]={ "34129", "Coldstomp the Griever", "i516 Intellect Neck", "", "rare", "FFRRares","112066"},
[54606940]={ "34131", "Coldtusk", "i516 Agility/Strength 1H Sword", "", "rare", "FFRRares","111484"},
[67407820]={ "34477", "Cyclonic Fury", "i516 Cloth Shoulders", "", "rare", "FFRRares","112086"},
[71404680]={ "33504", "Firefury Giant", "i516 Offhand", "", "rare", "FFRRares","107661"},
[54602220]={ "32918", "Giant-Slayer Kul", "i516 Trinket Versatility + Agility Proc", "", "rare", "FFRRares","111530"},
[70003600]={ "37562", "Gorg'ak the Lava Guzzler", "i620 Strength Fistweapon", "!!! Level 100 !!!", "hundredrare", "FFRHundred","111545"},
[70003600]={ "37388", "Gorivax", "i620 Intellect Cloth Bracer", "", "hundredrare", "FFRHundred","119358"},
[38606300]={ "34865", "Grutush the Pillager", "i513 Agility/Intellect Mail Pants", "", "rare", "FFRRares","112077"},
[50305260]={ "34825", "Gruuk", "i513 Trinket Haste + Critical Strike", "", "rare", "FFRRares","111948"},
[47005520]={ "34839", "Gurun", "i513 Strength Cloak", "", "rare", "FFRRares","111955"},
[68801940]={ "37382", "Hoarfrost", "i620 Intellect Spirit Ring", "!!! Level 101 !!!", "hundredrare", "FFRHundred","119415"},
[58603420]={ "34130", "Huntmaster Kuang", "Garrison Resources", "", "rare", "FFRRares","824"},
[48202340]={ "37386", "Jabberjaw", "i620 Caster Shield", "!!! Level 101 !!!", "hundredrare", "FFRHundred","119390"},
[61602640]={ "34708", "Jehil the Climber", "i516 Agility/Intellect Leather Boots", "", "rare", "FFRRares","112078"},
[43002100]={ "37387", "Moltnoma", "i620 Cloth Shoulders", "!!! Level 101 !!!", "hundredrare", "FFRHundred","119356"},
[70002700]={ "37381", "Mother of Goren", "i620 Strength Neck", "!!! Level 101 !!!", "hundredrare", "FFRHundred","119376"},
[83604720]={ "37402", "Ogom the Mangler", "i620 Agility/Intellect Leather Bracer", "!!! Level 100 !!!", "hundredrare", "FFRHundred","119366"},
[36803400]={ "33938", "Primalist Mur'og", "i516 Cloth Pants", "", "rare", "FFRRares","111576"},
[86604880]={ "37401", "Ragore Driftstalker", "i620 Agility/Intellect Leather Chest", "!!! Level 100 !!!", "hundredrare", "FFRHundred","119359"},
[76406340]={ "34132", "Scout Goreseeker", "i516 Agility/Intellect Leather Body", "", "rare", "FFRRares","112094"},
[45001500]={ "37385", "Slogtusk the Corpse-Eater", "i620 Agility/Intellect Leather Helm", "!!! Level 101 !!!", "hundredrare", "FFRHundred","119362"},
[38201600]={ "37383", "Son of Goramal", "i620 Caster Mace", "!!! Level 101 !!!", "hundredrare", "FFRHundred","119399"},
[26803160]={ "34133", "The Beater", "i516 Strength 2H Mace", "", "rare", "FFRRares","111475"},
[72203300]={ "37361", "The Bone Crawler", "i620 Intellect/Strength Plate Chest", "!!! Level 101 !!!", "hundredrare", "FFRHundred","111534"},
[43600940]={ "37384", "Tor'goroth", "i620 Offhand + Flavor Item", "!!! Level 101 !!!", "hundredrare", "FFRHundred","119379"},
[40601240]={ "34522", "Ug'lok the Frozen", "i620 Intellect Staff", "!!! Level 101 !!!", "hundredrare", "FFRHundred","119409"},
[72402420]={ "37378", "Valkor", "100 Garrison Resources", "!!! Level 101 !!!", "hundredrare", "FFRHundred","119416"},
[70603900]={ "37379", "Vrok the Ancient", "100 Garrison Resources", "!!! Level 101 !!!", "hundredrare", "FFRHundred","119416"},
[40402780]={ "34559", "Yaga the Scarred", "i516 Agility/Intellect Leather Waist", "On the lower cliff ledge", "rare", "FFRRares","111477"},
[84604680]={ "37403", "Earthshaker Holar", "i620 Agility Neck", "!!! Level 100 !!!", "hundredrare", "FFRHundred","119374"},
[66602540]={ "37380", "Gibblette the Cowardly", "i620 Agility Cloak + Flavor item", "!!! Level 101 !!! In a cave on top of a mountain, path upwards starts at 69.3, 24", "hundredrare", "FFRHundred","119349"},
[86804500]={ "37404", "Kaga the Ironbender", "i620 Agility/Intellect Mail Waist", "!!! Level 100 !!!", "hundredrare", "FFRHundred","119372"},
}
nodes["BladespireFortress"] = {
[26613949]={ "35370", "Doorogs Secret Stash", "Gold + Trash Item", "Second floor of Bladespire Citadel, outside", "default", "FFRBF","113189"},
[26403642]={ "35367", "Gorr'thogg's Personal Reserve", "Alcoholic Beverages", "Top floor of Bladespire Citadel, next to the throne", "default", "FFRBF","118108"},
[26603520]={ "35347", "Ogre Booty", "Garrison Resources", "Second floor of Bladespire Citadel", "default", "FFRBF","824"},
[28293440]={ "35368", "Ogre Booty", "Gold", "First floor of Bladespire Citadel; have to climb some crates to reach the chest", "default", "FFRBF",""},
[27783917]={ "35369", "Ogre Booty", "Gold", "First floor of Bladespire Citadel; have to climb some crates to reach the chest", "default", "FFRBF",""},
[27603382]={ "35371", "Ogre Booty", "Gold", "Second floor of Bladespire Citadel; have to climb some crates to reach the chest", "default", "FFRBF",""},
[27173763]={ "35373", "Ogre Booty", "Gold", "Second floor of Bladespire Citadel; have to climb some crates to reach the chest", "default", "FFRBF",""},
[28093409]={ "35567", "Ogre Booty", "Garrison Resources", "Second floor of Bladespire Citadel", "default", "FFRBF","824"},
[30723869]={ "35568", "Ogre Booty", "Garrison Resources", "Second floor of Bladespire Citadel", "default", "FFRBF","824"},
[30083927]={ "35569", "Ogre Booty", "Garrison Resources", "Second floor of Bladespire Citadel", "default", "FFRBF","824"},
[27283876]={ "35570", "Ogre Booty", "Gold", "First floor of Bladespire Citadel", "default", "FFRBF",""},
}
nodes["Gorgrond"] = {
--GorgrondTreasures
[41735297]={ "36506", "Brokor's Sack", "i538 Caster Staff", "", "default", "GorgrondTreasures","118702"},
[42368341]={ "36625", "Discarded Pack", "Gold + Random Green", "", "default", "GorgrondTreasures",""},
[41827802]={ "36658", "Evermorn Supply Cache", "Random Green", "", "default", "GorgrondTreasures",""},
[40367660]={ "36621", "Explorer Canister", "50 Garrison Resources", "", "default", "GorgrondTreasures","118710"},
[40047223]={ "36170", "Femur of Improbability", "Trash Item", "", "default", "GorgrondTreasures","118715"},
[46104999]={ "36651", "Harvestable Precious Crystal", "Garrison Resources", "", "default", "GorgrondTreasures","824"},
[42584685]={ "35056", "Horned Skull", "Garrison Resources", "", "default", "GorgrondTreasures","824"},
[43694248]={ "36618", "Iron Supply Chest", "Garrison Resources", "", "default", "GorgrondTreasures","824"},
[44207427]={ "35709", "Laughing Skull Cache", "Garrison Resources", "Up in a tree", "default", "GorgrondTreasures","824"},
[43109290]={ "34241", "Ockbar's Pack", "Trash Item", "", "default", "GorgrondTreasures","118227"},
[52516696]={ "36509", "Odd Skull", "i535 Offhand", "", "default", "GorgrondTreasures","118717"},
[46244295]={ "36521", "Petrified Rylak Egg", "Trash Item", "", "default", "GorgrondTreasures","118707"},
[43957055]={ "36118", "Pile of Rubble", "Random Green", "", "default", "GorgrondTreasures",""},
[53127449]={ "36654", "Remains of Balik Orecrusher", "Trash Item", "", "default", "GorgrondTreasures","118714"},
[57845597]={ "36605", "Remains of Balldir Deeprock", "Trash Item", "", "default", "GorgrondTreasures","118703"},
[39036805]={ "36631", "Sasha's Secret Stash", "Gold + Random Green", "", "default", "GorgrondTreasures",""},
[44954262]={ "36634", "Sniper's Crossbow", "i539 Crossbow", "", "default", "GorgrondTreasures","118713"},
[48129337]={ "36604", "Stashed Emergency Rucksack", "Gold + Random Green", "", "default", "GorgrondTreasures",""},
[52977995]={ "34940", "Strange Looking Dagger", "i537 Agility Dagger", "", "default", "GorgrondTreasures","118718"},
[57086530]={ "37249", "Strange Spore", "Pet", "On top of a mushroom slice sticking out of the cliff", "default", "GorgrondTreasures","118106"},
[45694972]={ "36610", "Suntouched Spear", "Trash Item", "", "default", "GorgrondTreasures","118708"},
[59296379]={ "36628", "Vindicator's Hammer", "i539 Strength 2H Mace", "", "default", "GorgrondTreasures","118712"},
[48944731]={ "36203", "Warm Goren Egg", "Egg which hatches into a Toy after 7 days", "", "default", "GorgrondTreasures","118705"},
[49284363]={ "36596", "Weapons Cache", "100 Garrison Resources", "", "default", "GorgrondTreasures","107645"},
--GorgrondRares
[58604120]={ "37371", "Alkali", "i620 Agility/Intellect Leather Gloves", "!!! Level 100 !!!", "hundredrare", "GorgrondHundred","119361"},
[40007900]={ "35335", "Bashiok", "Toy", "", "rare", "GorgrondRares","118222"},
[69204460]={ "37369", "Basten + Nultra + Valstil", "Toy + i620 Cloth Waist", "!!! Level 100 !!! All 3 together", "hundredrare", "GorgrondHundred","119357"},
[39407460]={ "36597", "Berthora", "i532 Agility/Intellect Mail Shoulders", "", "rare", "GorgrondRares","118232"},
[46003360]={ "37368", "Blademaster Ro'gor", "i620 Cloth Boots", "!!! Level 101 !!!", "hundredrare", "GorgrondHundred","119228"},
[53404460]={ "35503", "Char the Burning", "i536 2H Caster Mace", "", "rare", "GorgrondRares","118212"},
[48202100]={ "37362", "Defector Dazgo", "i620 Strength Polearm", "!!! Level 101 !!!", "hundredrare", "GorgrondHundred","119224"},
[57603580]={ "37370", "Depthroot", "i620 Agility Polearm", "!!! Level 100 !!! One of two possible Spawnpoints", "hundredrare", "GorgrondHundred","119406"},
[72604040]={ "37370", "Depthroot", "i620 Agility Polearm", "!!! Level 100 !!! One of two possible Spawnpoints", "hundredrare", "GorgrondHundred","119406"},
[50002380]={ "37366", "Durp the Hated", "i620 Agility Leather Waist", "!!! Level 101 !!!", "hundredrare", "GorgrondHundred","119225"},
[72803580]={ "37373", "Firestarter Grash", "i620 Strength/Intellect Plate Gloves", "!!! Level 100 !!! One of two possible Spawnpoints", "hundredrare", "GorgrondHundred","119381"},
[58003640]={ "37373", "Firestarter Grash", "i620 Strength/Intellect Plate Gloves", "!!! Level 100 !!! One of two possible Spawnpoints", "hundredrare", "GorgrondHundred","119381"},
[57406860]={ "36387", "Fossilwood the Petrified", "Toy", "", "rare", "GorgrondRares","118221"},
[41804540]={ "36391", "Gelgor of the Blue Flame", "i534 Trinket Versatility + Intellect Proc", "", "rare", "GorgrondRares","118230"},
[46205080]={ "36204", "Glut", "i534 Trinket Agility + Multistrike Proc", "", "rare", "GorgrondRares","118229"},
[52805360]={ "37413", "Gnarljaw", "i620 Intellect Fistweapon", "!!! Level 100 !!!", "hundredrare", "GorgrondHundred","119397"},
[46804320]={ "36186", "Greldrok the Cunning", "i534 Strength 1H Mace", "", "rare", "GorgrondRares","118210"},
[59604300]={ "37375", "Grove Warden Yal", "i620 Intellect Cloak", "!!! Level 100 !!!", "hundredrare", "GorgrondHundred","119414"},
[52207020]={ "35908", "Hive Queen Skrikka", "i534 Spellpower Axe", "", "rare", "GorgrondRares","118209"},
[47002380]={ "37365", "Horgg", "i620 Agility/Intellect Mail Chest", "!!! Level 100 !!!", "hundredrare", "GorgrondHundred","119229"},
[55004660]={ "37377", "Hunter Bal'ra", "i620 Bow", "!!! Level 100 !!!", "hundredrare", "GorgrondHundred","119412"},
[47603060]={ "37367", "Inventor Blammo", "i620 Agility Gun + Flavor Item", "!!! Level 101 !!!", "hundredrare", "GorgrondHundred","119226"},
[52205580]={ "37412", "King Slime", "i620 Strength Cloak", "!!! Level 100 !!!", "hundredrare", "GorgrondHundred","119351"},
[50605320]={ "36178", "Mandrakor", "Pet", "", "rare", "GorgrondRares","118709"},
[49003380]={ "37363", "Maniacal Madgard", "i620 Intellect Neck", "!!! Level 101 !!!", "hundredrare", "GorgrondHundred","119230"},
[61803930]={ "37376", "Mogamago", "i620 Strength Shield", "!!! Level 100 !!!", "hundredrare", "GorgrondHundred","119391"},
[47002580]={ "37364", "Morgo Kain", "i620 Strength/Intellect Plate Helm", "!!! Level 100 !!!", "hundredrare", "GorgrondHundred","119227"},
[53407820]={ "34726", "Mother Araneae", "i534 Agility Dagger", "", "rare", "GorgrondRares","118208"},
[37608140]={ "36600", "Riptar", "i539 Caster Dagger", "", "rare", "GorgrondRares","118231"},
[47804140]={ "36393", "Rolkor", "i539 Trinket Strength + Critical Strike Proc", "", "rare", "GorgrondRares","118211"},
[54207240]={ "36837", "Stompalupagus", "i537 2H Agility/Strength Mace", "", "rare", "GorgrondRares","118228"},
[38206620]={ "35910", "Stomper Kreego", "Ogre Brewing Kit", "Can create Alcoholic Beverages every 7 days", "rare", "GorgrondRares","118224"},
[40205960]={ "36394", "Sulfurious", "Toy", "", "rare", "GorgrondRares","114227"},
[44609220]={ "36656", "Sunclaw", "i533 Agility Fistweapon", "", "rare", "GorgrondRares","118223"},
[59903200]={ "37374", "Swift Onyx Flayer", "i620 Agility/Intellect Mail Boots", "!!! Level 100 !!!", "hundredrare", "GorgrondHundred","119367"},
[64006180]={ "36794", "Sylldross", "i540 Agility/Intellect Leather Boots", "", "rare", "GorgrondRares","118213"},
[76004200]={ "37405", "Typhon", "Apexis Crystals", "!!! Level 100 !!!", "hundredrare", "GorgrondHundred","823"},
[63803160]={ "37372", "Venolasix", "i620 Agility Dagger", "!!! Level 100 !!!", "hundredrare", "GorgrondHundred","119395"},
}
nodes["Talador"] = {
--TaladorTreasures
[36509610]={ "34182", "Aarko's Family Treasure", "i557 Crossbow", "", "default", "TaladorTreasures","117567"},
[62083238]={ "34236", "Amethyl Crystal", "100 Garrison Resources", "", "default", "TaladorTreasures","116131"},
[81843494]={ "34260", "Aruuna Mining Cart", "Ores", "", "default", "TaladorTreasures","109118"},
[62414797]={ "34252", "Barrel of Fish", "Fish", "", "default", "TaladorTreasures","110506"},
[33297680]={ "34259", "Bonechewer Remnants", "Garrison Resources", "", "default", "TaladorTreasures","824"},
[37607490]={ "34148", "Bonechewer Spear", "i566 Agility/Intellect Mail Gloves", "The spear spawns from the corpse of Viperlash", "default", "TaladorTreasures","112371"},
[73525137]={ "34471", "Bright Coin", "i560 Trinket Versatility + Bonus Armor proc", "", "default", "TaladorTreasures","116127"},
[70100700]={ "36937", "Burning Blade Cache", "Apexis Crystal", "", "default", "TaladorTreasures","823"},
[77044996]={ "34248", "Charred Sword", "i563 2H Strength Sword", "", "default", "TaladorTreasures","116116"},
[66508694]={ "34239", "Curious Deathweb Egg", "Toy", "", "default", "TaladorTreasures","117569"},
[58901200]={ "33933", "Deceptia's Smoldering Boots", "Toy", "", "default", "TaladorTreasures","108743"},
[55256671]={ "34253", "Draenei Weapons", "100 Garrison Resources", "", "default", "TaladorTreasures","116118"},
[35419656]={ "34249", "Farmer's Bounty", "Garrison Resources", "", "default", "TaladorTreasures","824"},
[57362866]={ "34238", "Foreman's Lunchbox", "Reusable Food/Drink", "", "default", "TaladorTreasures","116120"},
[64587920]={ "34251", "Iron Box", "i554 1H Strength Mace", "", "default", "TaladorTreasures","117571"},
[75003600]={ "33649", "Iron Scout", "Garrison Resources", "", "default", "TaladorTreasures","824"},
[57207540]={ "34134", "Isaari's Cache", "i564 Agility Neck", "", "default", "TaladorTreasures","117563"},
[65471137]={ "34233", "Jug of Aged Ironwine", "Alcoholic Beverages", "", "default", "TaladorTreasures","117568"},
[75684140]={ "34261", "Keluu's Belongings", "Gold", "", "default", "TaladorTreasures",""},
[53972769]={ "34290", "Ketya's Stash", "Pet", "", "default", "TaladorTreasures","116402"},
[38191242]={ "34258", "Light of the Sea", "Garrison Resources", "", "default", "TaladorTreasures","824"},
[68805620]={ "34101", "Lightbearer", "Trash Item", "", "default", "TaladorTreasures","109192"},
[52562954]={ "34235", "Luminous Shell", "i557 Intellect Neck", "", "default", "TaladorTreasures","116132"},
[78211471]={ "34263", "Pure Crystal Dust", "i554 Agility Ring", "", "default", "TaladorTreasures","117572"},
[75784472]={ "34250", "Relic of Aruuna", "Trash Item", "", "default", "TaladorTreasures","116128"},
[46969174]={ "34256", "Relic of Telmor", "Trash Item", "", "default", "TaladorTreasures","116128"},
[64901330]={ "34232", "Rook's Tacklebox", "+4 Fishing Line", "", "default", "TaladorTreasures","116117"},
[65968513]={ "34276", "Rusted Lockbox", "Random Green", "", "default", "TaladorTreasures",""},
[39505520]={ "34254", "Soulbinder's Reliquary", "i558 Intellect Ring", "", "default", "TaladorTreasures","117570"},
[74602930]={ "35162", "Teroclaw Nest 1", "Pet", "Only one Teroclaw Nest can be looted", "default", "TaladorTreasures","112699"},
[39307770]={ "35162", "Teroclaw Nest 10", "Pet", "Only one Teroclaw Nest can be looted", "default", "TaladorTreasures","112699"},
[73503070]={ "35162", "Teroclaw Nest 2", "Pet", "Only one Teroclaw Nest can be looted", "default", "TaladorTreasures","112699"},
[74303400]={ "35162", "Teroclaw Nest 3", "Pet", "Only one Teroclaw Nest can be looted", "default", "TaladorTreasures","112699"},
[72803560]={ "35162", "Teroclaw Nest 4", "Pet", "Only one Teroclaw Nest can be looted", "default", "TaladorTreasures","112699"},
[72403700]={ "35162", "Teroclaw Nest 5", "Pet", "Only one Teroclaw Nest can be looted", "default", "TaladorTreasures","112699"},
[70903550]={ "35162", "Teroclaw Nest 6", "Pet", "Only one Teroclaw Nest can be looted", "default", "TaladorTreasures","112699"},
[70803200]={ "35162", "Teroclaw Nest 7", "Pet", "Only one Teroclaw Nest can be looted", "default", "TaladorTreasures","112699"},
[54105630]={ "35162", "Teroclaw Nest 8", "Pet", "Only one Teroclaw Nest can be looted", "default", "TaladorTreasures","112699"},
[39807670]={ "35162", "Teroclaw Nest 9", "Pet", "Only one Teroclaw Nest can be looted", "default", "TaladorTreasures","112699"},
[38338450]={ "34257", "Treasure of Ango'rosh", "Flavor Item - Throwing Rock", "", "default", "TaladorTreasures","116119"},
[65448860]={ "34255", "Webbed Sac", "Gold", "", "default", "TaladorTreasures",""},
[40608950]={ "34140", "Yuuri's Gift", "Garrison Resources", "", "default", "TaladorTreasures","824"},
[28397419]={ "36829", "Gift of the Ancients", "i563 Intellect Ring", "Inside a cave; turn all the three statues so they face away from the empty block in the middle to spawn the chest", "default", "TaladorTreasures","118686"},
[39304172]={ "34207", "Sparkling Pool", "Garrison Resources + Fishing items", "Requires Fishing", "default", "TaladorTreasures","112623"},
--TaladorRares
[46603520]={ "37338", "Avatar of Socrethar", "i620 Offhand", "!!! Level 101 !!!", "hundredrare", "TaladorHundred","119378"},
[44003800]={ "37339", "Bombardier Gu'gok", "i620 Crossbow", "!!! Level 101 !!!", "hundredrare", "TaladorHundred","119413"},
[37607040]={ "34165", "Cro Fleshrender", "i558 Strength 1H Mace", "", "rare", "TaladorRares","116123"},
[68201580]={ "34142", "Dr. Gloom", "Flavor Item - Stink Bombs", "", "rare", "TaladorRares","112499"},
[34205700]={ "34221", "Echo of Murmur", "Toy", "", "rare", "TaladorRares","113670"},
[50808380]={ "35018", "Felbark", "i554 Caster Shield", "", "rare", "TaladorRares","112373"},
[50203520]={ "37341", "Felfire Consort", "i620 Agility Ring", "!!! Level 101 !!!", "hundredrare", "TaladorHundred","119386"},
[46005500]={ "34145", "Frenzied Golem", "i563 Agility/Strength 1H Sword or i563 Caster Dagger", "", "rare", "TaladorRares","113287"},
[67408060]={ "34929", "Gennadian", "i558 Trinket Agility + Mastery Proc", "", "rare", "TaladorRares","116075"},
[31806380]={ "34189", "Glimmerwing", "Shorttime Speedbuff with limited charges", "", "rare", "TaladorRares","116113"},
[22207400]={ "36919", "Grrbrrgle", "no loot", "Restless Crate; quest doesn't flag as completed, probably bugged", "rare", "TaladorRares",""},
[47603900]={ "37340", "Gug'tol", "i620 Caster Sword", "!!! Level 101 !!!", "hundredrare", "TaladorHundred","119402"},
[48002500]={ "37312", "Haakun the All-Consuming", "i620 Strength 1H Sword", "!!! Level 100 !!!", "hundredrare", "TaladorHundred","119403"},
[62004600]={ "34185", "Hammertooth", "i558 Agility/Intellect Mail Chest", "", "rare", "TaladorRares","116124"},
[78005040]={ "34167", "Hen-Mother Hami", "i556 Intellect Cloak", "", "rare", "TaladorRares","112369"},
[56606360]={ "35219", "Kharazos the Triumphant + Galzomar + Sikthiss", "Toy", "One of them - loot once", "rare", "TaladorRares","116122"},
[66808540]={ "34498", "Klikixx", "Toy", "", "rare", "TaladorRares","116125"},
[37203760]={ "37348", "Kurlosh Doomfang", "i620 Agility Dagger", "!!! Level 102 !!!", "hundredrare", "TaladorHundred","119394"},
[33803780]={ "37346", "Lady Demlash", "i620 Cloth Chest", "!!! Level 102 !!!", "hundredrare", "TaladorHundred","119352"},
[37802140]={ "37342", "Legion Vanguard", "i620 Strength/Intellect Plate Bracer", "!!! Level 101 !!!", "hundredrare", "TaladorHundred","119385"},
[49009200]={ "34208", "Lo'marg Jawcrusher", "i558 Strength Neck", "", "rare", "TaladorRares","116070"},
[30502640]={ "37345", "Lord Korinak", "i620 Strength Ring", "!!! Level 102 !!!", "hundredrare", "TaladorHundred","119388"},
[39004960]={ "37349", "Matron of Sin", "i620 Cloth Gloves", "!!! Level 102 !!!", "hundredrare", "TaladorHundred","119353"},
[86403040]={ "34859", "No'losh", "i558 Trinket Versatility + Int Proc", "", "rare", "TaladorRares","116077"},
[31404750]={ "37344", "Orumo the Observer", "i620 Intellect Neck + Pet", "!!! Level 102 !!! Requires 5 players to click objects to summon", "hundredrare", "TaladorHundred","119375"},
[59505960]={ "34196", "Ra'kahn", "i563 Agility Fistweapon", "", "rare", "TaladorRares","116112"},
[41004200]={ "37347", "Shadowflame Terrorwalker", "i620 Strength 1H Axe", "!!! Level 102 !!!", "hundredrare", "TaladorHundred","119393"},
[41805940]={ "34671", "Shirzir", "i554 Agility/Intellect Leather Boots", "", "rare", "TaladorRares","112370"},
[67703550]={ "36858", "Steeltusk", "i559 Agility Polearm", "", "rare", "TaladorRares","117562"},
[46002740]={ "37337", "Strategist Ankor + Archmagus Tekar + Soulbinder Naylana", "i620 Intellect Cloak", "!!! Level 101 !!! All 3 together", "hundredrare", "TaladorHundred","119350"},
[59008800]={ "34171", "Taladorantula", "i565 Agility Sword", "", "rare", "TaladorRares","116126"},
[53909100]={ "34668", "Talonpriest Zorkra", "i560 Cloth Helm", "", "rare", "TaladorRares","116110"},
[63802070]={ "34945", "Underseer Bloodmane", "i554 Strength Ring", "don't kill his Pet", "rare", "TaladorRares","112475"},
[36804100]={ "37350", "Vigilant Paarthos", "i620 Intellect/Strength Plate Shoulders", "!!! Level 102 !!!", "hundredrare", "TaladorHundred","119383"},
[69603340]={ "34205", "Wandering Vindicator", "i554 Strength 1H Sword", "", "rare", "TaladorRares","112261"},
[38001460]={ "37343", "Xothear the Destroyer", "i620 Agility/Intellect Mail Shoulders + Flavor Item", "!!! Level 100 !!!", "hundredrare", "TaladorHundred","119371"},
[53802580]={ "34135", "Yazheera the Incinerator", "i554 Agility/Intellect Mail Bracer", "", "rare", "TaladorRares","112263"},
}
nodes["SpiresOfArak"] = {
--SoATreasures
[40595497]={ "36458", "Abandoned Mining Pick", "i578 Strength 1H Axe", "Allows faster Mining in Draenor", "default", "SoATreasures","116913"},
[36195446]={ "36462", "Admiral Taylor's Coffer", "Garrison Resources", "Requires An Old Key", "default", "SoATreasures","824"},
[37705640]={ "36462", "An Old Key", "Key for a Chest in Admiral Taylors Garrison", "", "default", "SoATreasures","116020"},
[49203721]={ "36445", "Assassin's Spear", "i580 Agility Polearm", "", "default", "SoATreasures","116835"},
[55539086]={ "36366", "Campaign Contributions", "Gold", "", "default", "SoATreasures",""},
[68428898]={ "36453", "Coinbender's Payment", "Garrison Resources", "", "default", "SoATreasures","824"},
[36585791]={ "36418", "Ephial's Dark Grimoire", "i579 Offhand", "", "default", "SoATreasures","116914"},
[50502210]={ "36246", "Fractured Sunstone", "Trash Item", "", "default", "SoATreasures","116919"},
[37154750]={ "36420", "Garrison Supplies", "Garrison Resources", "", "default", "SoATreasures","824"},
[41855042]={ "36451", "Garrison Workman's Hammer", "i580 Strength 1H Mace", "", "default", "SoATreasures","116918"},
[48604450]={ "36386", "Gift of Anzu", "i585 Crossbow", "Drink an Elixir of Shadow Sight near the Shrine to get the Gift of Anzu", "default", "SoATreasures","118237"},
[57007900]={ "36390", "Gift of Anzu", "i585 Caster 1H Sword", "Drink an Elixir of Shadow Sight near the Shrine to get the Gift of Anzu", "default", "SoATreasures","118241"},
[46954044]={ "36389", "Gift of Anzu", "i585 Agility/Strength Polearm", "Drink an Elixir of Shadow Sight near the Shrine to get the Gift of Anzu", "default", "SoATreasures","118238"},
[52031958]={ "36392", "Gift of Anzu", "i585 Caster Staff", "Drink an Elixir of Shadow Sight near the Shrine to get the Gift of Anzu", "default", "SoATreasures","118239"},
[42402670]={ "36388", "Gift of Anzu", "i585 Wand", "Drink an Elixir of Shadow Sight near the Shrine to get the Gift of Anzu", "default", "SoATreasures","118242"},
[61105537]={ "36381", "Gift of Anzu", "i585 Agility/Strength 1H Sword", "Drink an Elixir of Shadow Sight near the Shrine to get the Gift of Anzu", "default", "SoATreasures","118240"},
[50332579]={ "36444", "Iron Horde Explosives", "Trash Item", "", "default", "SoATreasures","118691"},
[50782874]={ "36247", "Lost Herb Satchel", "Herbs", "", "default", "SoATreasures","109124"},
[47773612]={ "36411", "Lost Ring", "i578 Intellect Ring", "", "default", "SoATreasures","116911"},
[52474280]={ "36416", "Misplaced Scroll", "Archaeology Fragments", "Requires Archaeology and possibly a little bit of jumping", "default", "SoAArchaeology",""},
[42691832]={ "36244", "Misplaced Scrolls", "Archaeology Fragments", "Requires Archaeology and possibly a little bit of jumping", "default", "SoAArchaeology",""},
[63586737]={ "36454", "Mysterious Mushrooms", "Herbs", "", "default", "SoATreasures","109127"},
[60808780]={ "35481", "Nizzix's Chest", "Garrison Resources", "Click on Nizzix's Escape Pod at 60.9 88.0 and follow him to the shore", "default", "SoATreasures","824"},
[53315552]={ "36403", "Offering to the Raven Mother 1", "Consumable for 5% rested XP", "", "default", "SoATreasures","118267"},
[48355261]={ "36405", "Offering to the Raven Mother 2", "Consumable for 5% rested XP", "", "default", "SoATreasures","118267"},
[48905470]={ "36406", "Offering to the Raven Mother 3", "Consumable for 5% rested XP", "", "default", "SoATreasures","118267"},
[51886465]={ "36407", "Offering to the Raven Mother 4", "Consumable for 5% rested XP", "", "default", "SoATreasures","118267"},
[60976387]={ "36410", "Offering to the Raven Mother 5", "Consumable for 5% rested XP", "", "default", "SoATreasures","118267"},
[58706024]={ "36340", "Ogron Plunder", "Trash Items", "", "default", "SoATreasures","116921"},
[36283934]={ "36402", "Orcish Signaling Horn", "i577 Trinket Multistrike + Strength Proc", "", "default", "SoATreasures","120337"},
[36821716]={ "36243", "Outcast's Belongings 1", "Gold + Random Green", "", "default", "SoATreasures",""},
[42172168]={ "36447", "Outcast's Belongings 2", "Gold + Random Green", "", "default", "SoATreasures",""},
[46903406]={ "36446", "Outcast's Pouch", "Gold + Random Green", "", "default", "SoATreasures",""},
[42961637]={ "36245", "Relics of the Outcasts 1", "Archaeology Fragments", "Requires Archaeology and possibly a little bit of jumping", "default", "SoAArchaeology",""},
[45964415]={ "36354", "Relics of the Outcasts 2", "Archaeology Fragments", "Requires Archaeology and possibly a little bit of jumping", "default", "SoAArchaeology",""},
[43162726]={ "36355", "Relics of the Outcasts 3", "Archaeology Fragments", "Requires Archaeology and possibly a little bit of jumping", "default", "SoAArchaeology",""},
[67373983]={ "36356", "Relics of the Outcasts 4", "Archaeology Fragments", "Requires Archaeology and possibly a little bit of jumping", "default", "SoAArchaeology",""},
[60215391]={ "36359", "Relics of the Outcasts 5", "Archaeology Fragments", "Requires Archaeology and possibly a little bit of jumping", "default", "SoAArchaeology",""},
[51894892]={ "36360", "Relics of the Outcasts 6", "Archaeology Fragments", "Requires Archaeology and possibly a little bit of jumping", "default", "SoAArchaeology",""},
[37375056]={ "36657", "Rooby's Roo", "i581 Strength Neck", "You need to feed the dog with Rooby Reat from the chef in the cellar", "default", "SoATreasures","116887"},
[44331204]={ "36377", "Rukhmar's Image", "Trash Item", "", "default", "SoATreasures","118693"},
[59179064]={ "36366", "Sailor Zazzuk's 180-Proof Rum", "Alcoholic Beverages", "", "default", "SoATreasures","116917"},
[68333893]={ "36375", "Sethekk Idol", "Trash Item", "", "default", "SoATreasures","118692"},
[71644859]={ "36450", "Sethekk Ritual Brew", "Healing Potions + Alcoholic Beverages", "", "default", "SoATreasures","109223"},
[56232881]={ "36362", "Shattered Hand Cache", "Garrison Resources", "", "default", "SoATreasures","824"},
[47923065]={ "36361", "Shattered Hand Lockbox", "True Steel Lockbox", "", "default", "SoATreasures","116920"},
[60868461]={ "36456", "Shredder Parts", "Garrison Resources", "", "default", "SoATreasures","824"},
[56294531]={ "36433", "Smuggled Apexis Artifacts", "Archaeology Fragments", "Requires Archaeology and possibly a little bit of jumping", "default", "SoAArchaeology",""},
[59638134]={ "36365", "Spray-O-Matic 5000 XT", "Garrison Resources", "", "default", "SoATreasures","824"},
[34142751]={ "36421", "Sun-Touched Cache 1", "Garrison Resources", "", "default", "SoATreasures","824"},
[33292727]={ "36422", "Sun-Touched Cache 2", "Archaeology Fragments", "Requires Archaeology and possibly a little bit of jumping", "default", "SoAArchaeology",""},
[54353255]={ "36364", "Toxicfang Venom", "100 Garrison Resources", "", "default", "SoATreasures","118695"},
[66475653]={ "36455", "Waterlogged Satchel", "Gold + Random Green", "", "default", "SoATreasures",""},
[57802220]={ "36374", "Statue of Anzu", "Trash Item", "", "default", "SoATreasures","118694"},
--SoARares
[58208460]={ "36291", "Betsi Boombasket", "i583 Gun", "", "rare", "SoARares","116907"},
[46802300]={ "35599", "Blade-Dancer Aeryx", "Trash Item", "", "rare", "SoARares","116839"},
[64006480]={ "36283", "Blightglow", "i586 Agility/Intellect Leather Shoulders", "", "rare", "SoARares","118205"},
[46402860]={ "36267", "Durkath Steelmaw", "i586 Agility/Intellect Mail Boots", "", "rare", "SoARares","118198"},
[69005400]={ "37406", "Echidna", "unknown", "!!! Level 100 !!!", "hundredrare", "SoAHundred",""},
[54803960]={ "36297", "Festerbloom", "i584 Offhand", "", "rare", "SoARares","118200"},
[25202420]={ "36943", "Gaze", "Garrison Resources", "", "rare", "SoARares","824"},
[74404280]={ "37390", "Gluttonous Giant", "i620 Wand", "!!! Level 100 !!!", "hundredrare", "SoAHundred","119404"},
[33005900]={ "36305", "Gobblefin", "Trash Item", "", "rare", "SoARares","116836"},
[59201500]={ "36887", "Hermit Palefur", "i582 Cloth Helm", "", "rare", "SoARares","118279"},
[56609460]={ "36306", "Jiasska the Sporegorger", "i589 Trinket Haste + Int Proc", "", "rare", "SoARares","118202"},
[62603740]={ "36268", "Kalos the Bloodbathed", "i588 Cloth Body", "", "rare", "SoARares","118735"},
[53208900]={ "36396", "Mutafen", "i589 Strength 2H Mace", "", "rare", "SoARares","118206"},
[36405240]={ "36129", "Nas Dunberlin", "i578 Agility/Strength Polearm", "", "rare", "SoARares","116837"},
[66005500]={ "36288", "Oskiira the Vengeful", "i589 Agility Dagger", "", "rare", "SoARares","118204"},
[59403740]={ "36279", "Poisonmaster Bortusk", "i583 Trinket Multistrike + DMG on Use", "", "rare", "SoARares","118199"},
[38402780]={ "36470", "Rotcap", "Pet", "", "rare", "SoARares","118107"},
[69004880]={ "36276", "Sangrikrass", "i589 Agility/Intellect Leather Body", "", "rare", "SoARares","118203"},
[71203380]={ "37392", "Shadow Hulk", "i620 Agility/Intellect Leather Pants", "!!! Level 100 !!!", "hundredrare", "SoAHundred","119363"},
[52003540]={ "36478", "Shadowbark", "i579 Caster Shield", "", "rare", "SoARares","118201"},
[51800720]={ "37394", "Solar Magnifier", "i620 Intellect Polearm", "!!! Level 100 !!!", "hundredrare", "SoAHundred","119407"},
[33402200]={ "36265", "Stonespite", "i577 Agility/Intellect Mail Pants", "", "rare", "SoARares","116858"},
[58604520]={ "36298", "Sunderthorn", "i578 Agility 1H Sword", "", "rare", "SoARares","116855"},
[52805480]={ "36472", "Swarmleaf", "i582 Caster Staff", "", "rare", "SoARares","116857"},
[54606320]={ "36278", "Talonbreaker", "i578 Agility Neck", "", "rare", "SoARares","116838"},
[57407400]={ "36254", "Tesska the Broken", "i578 Intellect Neck", "", "rare", "SoARares","116852"},
[71702010]={ "37360", "Formless Nightmare", "i620 Agility/Intellect Mail Bracer", "!!! Level 100 !!! Located inside Void Portal phase", "hundredrare", "SoAHundred","119373"},
[71404500]={ "37393", "Giga Sentinel", "i620 Agility 1H Sword", "!!! Level 100 !!!", "hundredrare", "SoAHundred","119401"},
[70402380]={ "37361", "Kenos the Unraveler", "i620 Cloth Helm", "!!! Level 100 !!! Located inside Void Portal phase; requires 3 players to click objects to summon", "hundredrare", "SoAHundred","119354"},
[74413864]={ "37391", "Mecha Plunderer", "i620 Agility 1H Mace", "!!! Level 100 !!!", "hundredrare", "SoAHundred","119398"},
[72401940]={ "37358", "Soul-Twister Torek", "Toy + i620 Caster Staff", "!!! Level 100 !!!", "hundredrare", "SoAHundred","119410"},
[72903090]={ "37359", "Voidreaver Urnae", "i620 Agility 1H Axe", "!!! Level 100 !!!", "hundredrare", "SoAHundred","119392"},
}
nodes["NagrandDraenor"] = {
--NagrandTreasures
[73071080]={ "35951", "A Pile of Dirt", "Garrison Resources", "", "default", "NagrandTreasures","824"},
[67655971]={ "35759", "Abandoned Cargo", "Random Greens", "", "default", "NagrandTreasures",""},
[38404940]={ "36711", "Abu'Gar's Favorite Lure", "Abu'Gar's Favorite Lure", "Combine with the other Abu'Gar Parts for a follower (just north of Telaar)", "default", "NagrandTreasures","114245"},
[85403870]={ "36711", "Abu'gar's Missing Reel", "Abu'Gar's Finest Reel", "Combine with the other Abu'Gar Parts for a follower (just north of Telaar)", "default", "NagrandTreasures","114243"},
[65906120]={ "36711", "Abu'gar's Vitality", "Abu'gar's Vitality", "Combine with the other Abu'Gar Parts for a follower (just north of Telaar)", "default", "NagrandTreasures","114242"},
[75816203]={ "36077", "Adventurer's Mace", "Random Green Mace", "", "default", "NagrandTreasures",""},
[82275660]={ "35765", "Adventurer's Pack", "Random Green", "", "default", "NagrandTreasures",""},
[45635200]={ "35969", "Adventurer's Pack", "Random Green", "", "default", "NagrandTreasures",""},
[69955244]={ "35597", "Adventurer's Pack", "Random Green", "", "default", "NagrandTreasures",""},
[56567294]={ "36050", "Adventurer's Pouch", "Garrison Resources", "On a ledge below a cliff; you need to fall from the top to reach it", "default", "NagrandTreasures","824"},
[73931405]={ "35955", "Adventurer's Sack", "Random Green", "", "default", "NagrandTreasures",""},
[81461307]={ "35953", "Adventurer's Staff", "i593 Caster Staff", "", "default", "NagrandTreasures","116640"},
[73057554]={ "35673", "Appropriated Warsong Supplies", "Garrison Resources", "", "default", "NagrandTreasures","824"},
[62546708]={ "36116", "Bag of Herbs", "Herbs", "", "default", "NagrandTreasures","109124"},
[77312807]={ "35986", "Bone-Carved Dagger", "i597 Agility Dagger", "", "default", "NagrandTreasures","116760"},
[77081662]={ "36174", "Bounty of the Elements", "Garrison Resources", "Use the elemental Stones to access", "default", "NagrandTreasures","824"},
[81083725]={ "35661", "Brilliant Dreampetal", "Manareg Potion", "Take Explorer Renzo's Glider to get there [north-east of here]", "default", "NagrandTreasures","118262"},
[85415347]={ "35696", "Burning Blade Cache", "Random Green", "", "default", "NagrandTreasures","824"},
[66961949]={ "35954", "Elemental Offering", "Trash Item", "", "default", "NagrandTreasures","118234"},
[78901556]={ "36036", "Elemental Shackles", "i605 Agility Ring", "", "default", "NagrandTreasures","118251"},
[53407320]={ "900003", "Explorer Bibsi", "Nothing", "You need to use a rocket to get to her [south-east of her position]", "glider", "NagrandTreasures",""},
[67601420]={ "900004", "Explorer Dez", "Nothing", "You can reach him from the east starting at the elemental plateau", "glider", "NagrandTreasures",""},
[87204100]={ "900005", "Explorer Garix", "Nothing", "Is required for 2 Treasures [1 south, 1 south-east]", "glider", "NagrandTreasures",""},
[75606460]={ "900006", "Explorer Razzuk", "Nothing", "Is required for some other Treasures", "glider", "NagrandTreasures",""},
[83803380]={ "900007", "Explorer Renzo", "Nothing", "Is required for 3 Treasures [2 north-east, 1 south-west]", "glider", "NagrandTreasures",""},
[45866629]={ "36020", "Fragment of Oshu'gun", "i607 Intellect Shield", "", "default", "NagrandTreasures","117981"},
[73052153]={ "35692", "Freshwater Clam", "Trash Item", "", "default", "NagrandTreasures","118233"},
[88901824]={ "35660", "Fungus-Covered Chest", "Garrison Resources", "Take Explorer Renzo's Glider to get there [south-west of here]", "default", "NagrandTreasures","824"},
[75374711]={ "36074", "Gambler's Purse", "Flavor Item", "", "default", "NagrandTreasures","118236"},
[43225755]={ "35987", "Genedar Debris", "Garrison Resources", "", "default", "NagrandTreasures","824"},
[48066011]={ "35999", "Genedar Debris", "Garrison Resources", "", "default", "NagrandTreasures","824"},
[48587279]={ "36008", "Genedar Debris", "Garrison Resources", "", "default", "NagrandTreasures","824"},
[44696757]={ "36002", "Genedar Debris", "Garrison Resources", "", "default", "NagrandTreasures","824"},
[55356828]={ "36011", "Genedar Debris", "Garrison Resources", "", "default", "NagrandTreasures","824"},
[72976212]={ "35590", "Goblin Pack", "Garrison Resources", "Take Explorer Razzuk's Glider to get there [south-east of here]", "default", "NagrandTreasures","824"},
[47207425]={ "35576", "Goblin Pack", "Garrison Resources", "Take Explorer Bibsi's Glider to get there [east of here]", "default", "NagrandTreasures","824"},
[58285249]={ "35694", "Golden Kaliri Egg", "Trash Item", "In the nest in the tree", "default", "NagrandTreasures","118266"},
[38345872]={ "36109", "Goldtoe's Plunder", "Gold", "Key on the Parrot", "default", "NagrandTreasures",""},
[87107288]={ "36051", "Grizzlemaw's Bonepile", "Pet Toy", "", "default", "NagrandTreasures","118054"},
[87624498]={ "35622", "Hidden Stash", "Garrison Resources", "Take Explorer Garix's Glider to get there [north of here]", "default", "NagrandTreasures","824"},
[67384906]={ "36039", "Highmaul Sledge", "i605 Strength Ring", "", "default", "NagrandTreasures","118252"},
[75236563]={ "36099", "Important Exploration Supplies", "Alcoholic Beverages", "", "default", "NagrandTreasures","61986"},
[61765747]={ "36082", "Lost Pendant", "i593 Green Amulet", "", "default", "NagrandTreasures","116687"},
[70531385]={ "35643", "Mountain Climber's Pack", "Garrison Resources", "Take Explorer Dez's Glider to get there [west of here]", "default", "NagrandTreasures","824"},
[80967979]={ "36049", "Ogre Beads", "i605 Str Ring", "", "default", "NagrandTreasures","118255"},
[57796205]={ "36115", "Pale Elixir", "Manareg Potion", "", "default", "NagrandTreasures","118278"},
[58295931]={ "36021", "Pokkar's Thirteenth Axe", "i605 1H Strength Axe", "", "default", "NagrandTreasures","116688"},
[72716092]={ "36035", "Polished Saberon Skull", "i605 Agility/Strength Ring", "", "default", "NagrandTreasures","118254"},
[58507630]={ "900008", "Rocket to Explorer Bibsi", "Nothing", "Is required to get to Explorer Bibsi", "rocket", "NagrandTreasures",""},
[75186494]={ "36102", "Saberon Stash", "Gold", "", "default", "NagrandTreasures",""},
[89073313]={ "36857", "Smuggler's Cache", "Garrison Resources", "", "default", "NagrandTreasures","824"},
[40346864]={ "37435", "Spirit Coffer", "Garrison Resources", "", "default", "NagrandTreasures","824"},
[50128228]={ "35577", "Steamwheedle Supplies", "Garrison Resources", "Take Explorer Bibsi's Glider to get there [north-east of here]", "default", "NagrandTreasures","824"},
[52678008]={ "35583", "Steamwheedle Supplies", "Garrison Resources", "Take Explorer Bibsi's Glider to get there [north of here]", "default", "NagrandTreasures","824"},
[77835195]={ "35591", "Steamwheedle Supplies", "Garrison Resources", "Take Explorer Razzuk's Glider to get there [south of here]", "default", "NagrandTreasures","824"},
[64591762]={ "35648", "Steamwheedle Supplies", "Garrison Resources", "Take Explorer Dez's Glider to get there [north-east of here]", "default", "NagrandTreasures","824"},
[70601860]={ "35646", "Steamwheedle Supplies", "Garrison Resources", "Take Explorer Dez's Glider to get there [north-west of here]", "default", "NagrandTreasures","824"},
[87602028]={ "35662", "Steamwheedle Supplies", "Garrison Resources", "Take Explorer Renzo's Glider to get there [south-west of here]", "default", "NagrandTreasures","824"},
[88274262]={ "35616", "Steamwheedle Supplies", "Garrison Resources", "Take Explorer Garix's Glider to get there [north-west of here]", "default", "NagrandTreasures","824"},
[64716583]={ "36046", "Telaar Defender Shield", "i605 Agility/Intellect Ring", "", "default", "NagrandTreasures","118253"},
[37717065]={ "34760", "Treasure of Kull'krosh", "Garrison Resources", "", "default", "NagrandTreasures","824"},
[49976651]={ "35579", "Void-Infused Crystal", "i613 2H Strength Sword", "Take Explorer Bibsi's Glider to get there [south-east of here]", "default", "NagrandTreasures","118264"},
[51726029]={ "35695", "Warsong Cache", "Garrison Resources", "", "default", "NagrandTreasures","824"},
[52414438]={ "36073", "Warsong Helm", "i609 Agility/Intellect Mail Helm", "", "default", "NagrandTreasures","118250"},
[73047036]={ "35678", "Warsong Lockbox", "Garrison Resources", "", "default", "NagrandTreasures","824"},
[76066990]={ "35682", "Warsong Spear", "Trash Item", "Take Explorer Razzuk's Glider to get there [north of here]", "default", "NagrandTreasures","118678"},
[80656054]={ "35593", "Warsong Spoils", "Garrison Resources", "Take Explorer Razzuk's Glider to get there [west of here]", "default", "NagrandTreasures","824"},
[89406588]={ "35976", "Warsong Supplies", "Garrison Resources", "", "default", "NagrandTreasures","824"},
[64763573]={ "36071", "Watertight Bag", "20 Slot Bag", "", "default", "NagrandTreasures","118235"},
[53386425]={ "36088", "Adventurer's Pouch", "Random Green", "In a cave; entrance is to the east", "default", "NagrandTreasures","824"},
[35475725]={ "36846", "Spirit's Gift", "Garrison Resources", "", "default", "NagrandTreasures","824"},
--NagrandRares
[84605340]={ "35778", "Ancient Blademaster", "i598 Strength Neck", "", "rare", "NagrandRares","116832"},
[51001600]={ "37210", "Aogexon", "Reputation Item for Steamwheedle Preservation Society", "", "swprare", "NagrandSWP","118654"},
[62601680]={ "37211", "Bergruu", "Reputation Item for Steamwheedle Preservation Society", "", "swprare", "NagrandSWP","118655"},
[77006400]={ "35735", "Berserk T-300 Series Mark II", "Garrison Resources", "In a cave, opened with a switch", "rare", "NagrandRares","824"},
[40001600]={ "37396", "Bonebreaker", "i620 Agility/Intellect Mail Pants", "", "hundredrare", "NagrandHundred","119370"},
[43003640]={ "37400", "Brutag Grimblade", "i620 Intellect/Strength Plate Boots", "", "hundredrare", "NagrandHundred","119380"},
[34607700]={ "34727", "Captain Ironbeard", "Toy + i607 Gun", "", "rare", "NagrandRares","118244"},
[64203000]={ "37221", "Dekorhan", "Reputation Item for Steamwheedle Preservation Society", "", "swprare", "NagrandSWP","118656"},
[60003800]={ "37222", "Direhoof", "Reputation Item for Steamwheedle Preservation Society", "", "swprare", "NagrandSWP","118657"},
[38602240]={ "37395", "Durg Spinecrusher", "i620 Agility 2H Mace", "", "hundredrare", "NagrandHundred","119405"},
[89004120]={ "35623", "Explorer Nozzand", "Trash Item", "", "rare", "NagrandRares","118679"},
[74801180]={ "35836", "Fangler", "Trash Items", "", "rare", "NagrandRares","116836"},
[70004180]={ "35893", "Flinthide", "i609 Strength Shield", "", "rare", "NagrandRares","116807"},
[48202220]={ "37223", "Gagrog the Brutal", "Reputation Item for Steamwheedle Preservation Society", "", "swprare", "NagrandSWP","118658"},
[52205580]={ "35715", "Gar'lua", "i605 Trinket Multistrike + Wolf Proc", "", "rare", "NagrandRares","118246"},
[42207860]={ "34725", "Gaz'orda", "i602 Intellect Ring", "In the cave", "rare", "NagrandRares","116798"},
[66605660]={ "35717", "Gnarlhoof the Rabid", "i598 Trinket Multistrike + Agi Proc", "", "rare", "NagrandRares","116824"},
[93202820]={ "35898", "Gorepetal", "i602 Agility/Intellect Leather Gloves", "The gloves let you gather herbs faster while in Draenor", "rare", "NagrandRares","116916"},
[42003680]={ "37472", "Gortag Steelgrip", "Apexis Crystals", "Summoned by Signal Horn object using Secret Meeting Details item", "hundredrare", "NagrandHundred","824"},
[84603660]={ "36159", "Graveltooth", "i609 Agility/Intellect Leather Bracer", "", "rare", "NagrandRares","118689"},
[66805120]={ "35714", "Greatfeather", "i600 Cloth Body", "", "rare", "NagrandRares","116795"},
[86007160]={ "35784", "Grizzlemaw", "i610 Strength Cloak", "", "rare", "NagrandRares","118687"},
[80603040]={ "35923", "Hunter Blacktooth", "i609 Agility 2H Mace", "", "rare", "NagrandRares","118245"},
[87005500]={ "34862", "Hyperious", "i597 Trinket Haste + Mastery Proc", "", "rare", "NagrandRares","116799"},
[45803480]={ "37399", "Karosh Blackwind", "i620 Cloth Pants", "", "hundredrare", "NagrandHundred","119355"},
[43803440]={ "37473", "Krahl Deadeye", "Apexis Crystals", "Summoned by Signal Horn object using Secret Meeting Details item", "hundredrare", "NagrandHundred",""},
[58201200]={ "37398", "Krud the Eviscerator", "i620 Intellect/Strength Plate Waist + Achievement", "Kill 15 mobs near him to make him become attackable", "hundredrare", "NagrandHundred","119384"},
[52009000]={ "37408", "Lernaea", "unknown", "", "hundredrare", "NagrandHundred",""},
[81206000]={ "35932", "Malroc Stonesunder", "i597 Agility Staff", "", "rare", "NagrandRares","116796"},
[45801520]={ "36229", "Mr. Pinchy Sr.", "i616 Trinket Multistrike + Lobstrok Proc", "", "rare", "NagrandRares","118690"},
[34005100]={ "37224", "Mu'gra", "Reputation Item for Steamwheedle Preservation Society", "", "swprare", "NagrandSWP","118659"},
[47607080]={ "35865", "Netherspawn", "Pet", "", "rare", "NagrandRares","116815"},
[42804920]={ "35875", "Ophiis", "i602 Cloth Pants", "", "rare", "NagrandRares","116765"},
[61806900]={ "35943", "Outrider Duretha", "i598 Agility/Intellect Leather Boots", "", "rare", "NagrandRares","116800"},
[58201800]={ "37637", "Pit Beast", "i620 Agility/Strength Tank Cloak", "", "hundredrare", "NagrandHundred","120317"},
[38001960]={ "37397", "Pit Slayer", "i620 Strength Ring", "", "hundredrare", "NagrandHundred","119389"},
[73605780]={ "35712", "Redclaw the Feral", "i604 Intellect Fistweapon", "", "rare", "NagrandRares","118243"},
[58008400]={ "35900", "Ru'klaa", "i608 Intellect/Strength Plate Shoulder", "", "rare", "NagrandRares","118688"},
[54806120]={ "35931", "Scout Pokhar", "i601 Strength 1H Axe", "", "rare", "NagrandRares","116797"},
[60934775]={ "35912", "Sean Whitesea", "i600 Agility/Intellect Leather Waist", "Spawns when Abandoned Chest is looted", "rare", "NagrandRares","116834"},
[75606500]={ "36128", "Soulfang", "i597 Intellect Sword", "", "rare", "NagrandRares","116806"},
[58403580]={ "37225", "Thek'talon", "Reputation Item for Steamwheedle Preservation Society", "", "swprare", "NagrandSWP","118660"},
[65003900]={ "35920", "Tura'aka", "i609 Agility Cloak", "", "rare", "NagrandRares","116814"},
[37003800]={ "37520", "Vileclaw", "Reputation Item for Steamwheedle Preservation Society", "", "swprare", "NagrandSWP","120172"},
[82607620]={ "34645", "Warmaster Blugthol", "i600 Strength/Intellect Plate Bracer", "", "rare", "NagrandRares","116805"},
[70602940]={ "35877", "Windcaller Korast", "i598 Caster Staff", "", "rare", "NagrandRares","116808"},
[41004400]={ "37226", "Xelganak", "Reputation Item for Steamwheedle Preservation Society", "", "swprare", "NagrandSWP","118661"},
}
nodes["TanaanJungle"] = {
--TanaanJungleRares
[41407960]={ "37407", "Keravnos", "unknown", "", "hundredrare", "TanaanHundred",""},
}
nodes["garrisonsmvalliance_tier1"] = {
[49604380]={ "35530", "Lunarfall Egg", "Garrison Resources", "on a wagon", "default", "SMVTreasures","824"},
[42405436]={ "35381", "Pippers' Buried Supplies 1", "Garrison Resources", "", "default", "SMVTreasures","824"},
[50704850]={ "35382", "Pippers' Buried Supplies 2", "Garrison Resources", "", "default", "SMVTreasures","824"},
[30802830]={ "35383", "Pippers' Buried Supplies 3", "Garrison Resources", "", "default", "SMVTreasures","824"},
[49197683]={ "35384", "Pippers' Buried Supplies 4", "Garrison Resources", "", "default", "SMVTreasures","824"},
[51800110]={ "35289", "Spark's Stolen Supplies", "Garrison Resources", "in a cave in the lake", "default", "SMVTreasures","824"},
 }
nodes["garrisonsmvalliance_tier2"] = {
[37306590]={ "35530", "Lunarfall Egg", "Garrison Resources", "on a wagon", "default", "SMVTreasures","824"},
[41685803]={ "35381", "Pippers' Buried Supplies 1", "Garrison Resources", "", "default", "SMVTreasures","824"},
[51874545]={ "35382", "Pippers' Buried Supplies 2", "Garrison Resources", "", "default", "SMVTreasures","824"},
[34972345]={ "35383", "Pippers' Buried Supplies 3", "Garrison Resources", "", "default", "SMVTreasures","824"},
[46637608]={ "35384", "Pippers' Buried Supplies 4", "Garrison Resources", "", "default", "SMVTreasures","824"},
[51800110]={ "35289", "Spark's Stolen Supplies", "Garrison Resources", "in a cave in the lake", "default", "SMVTreasures","824"},
 }
nodes["garrisonsmvalliance_tier3"] = {
[61277261]={ "35530", "Lunarfall Egg", "Garrison Resources", "in the tent", "default", "SMVTreasures","824"},
[60575515]={ "35381", "Pippers' Buried Supplies 1", "Garrison Resources", "", "default", "SMVTreasures","824"},
[37307491]={ "35382", "Pippers' Buried Supplies 2", "Garrison Resources", "", "default", "SMVTreasures","824"},
[37864378]={ "35383", "Pippers' Buried Supplies 3", "Garrison Resources", "", "default", "SMVTreasures","824"},
[61527154]={ "35384", "Pippers' Buried Supplies 4", "Garrison Resources", "", "default", "SMVTreasures","824"},
[51800110]={ "35289", "Spark's Stolen Supplies", "Garrison Resources", "in a cave in the lake", "default", "SMVTreasures","824"},
 }
nodes["garrisonffhorde_tier1"] = {
[74505620]={ "34937", "Lady Sena's Other Materials Stash", "Garrison Resources", "", "default", "FFRTreasures","824"},
}
nodes["garrisonffhorde_tier2"] = {
[74505620]={ "34937", "Lady Sena's Other Materials Stash", "Garrison Resources", "", "default", "FFRTreasures","824"},
}
nodes["garrisonffhorde_tier3"] = {
[74505620]={ "34937", "Lady Sena's Other Materials Stash", "Garrison Resources", "", "default", "FFRTreasures","824"},
}

if (PlayerFaction == "Alliance") then
nodes["ShadowmoonValleyDR"][29600620]={ "35281", "Bahameye", "Fire Ammonite", "", "rare", "SMVRares","111666"}
nodes["Gorgrond"][60805400]={ "36502", "Biolante", "Quest Item for XP", "You must finish the quest before this element gets removed from the map", "rare", "GorgrondRares","116159"}
nodes["Gorgrond"][46004680]={ "35816", "Charl Doomwing", "Quest Item for XP", "You must finish the quest before this element gets removed from the map", "rare", "GorgrondRares","113457"}
nodes["Gorgrond"][42805920]={ "35812", "Crater Lord Igneous", "Quest Item for XP", "You must finish the quest before this element gets removed from the map", "rare", "GorgrondRares","113449"}
nodes["Gorgrond"][40505100]={ "35809", "Dessicus of the Dead Pools", "Quest Item for XP", "You must finish the quest before this element gets removed from the map", "rare", "GorgrondRares","113446"}
nodes["Gorgrond"][51804160]={ "35808", "Erosian the Violent", "Quest Item for XP", "You must finish the quest before this element gets removed from the map", "rare", "GorgrondRares","113445"}
nodes["Gorgrond"][58006360]={ "35813", "Fungal Praetorian", "Quest Item for XP", "You must finish the quest before this element gets removed from the map", "rare", "GorgrondRares","113453"}
nodes["ShadowmoonValleyDR"][21603300]={ "33664", "Gorum", "i516 Agility/Intellect Ring", "Inside Bloodthorn Cave - Spawns at the Ceiling", "rare", "SMVRares","113082"}
nodes["Gorgrond"][52406580]={ "35820", "Khargax the Devourer", "Quest Item for XP", "You must finish the quest before this element gets removed from the map", "rare", "GorgrondRares","113461"}
nodes["ShadowmoonValleyDR"][30301990]={ "35530", "Lunarfall Egg", "Garrison Resources", "Changes position to inside the garrison once it is built", "default", "SMVTreasures","824"}
nodes["Gorgrond"][51206360]={ "35817", "Roardan the Sky Terror", "Quest Item for XP", "Flies around a lot, Coordinates are just somewhere on his route!You must finish the quest before this element gets removed from the map", "rare", "GorgrondRares","113458"}
nodes["ShadowmoonValleyDR"][42804100]={ "33038", "Windfang Matriarch", "i516 Agility/Strength 1H Sword", "Is part of the Embaari Crystal Defense Event", "rare", "SMVRares","113553"}
end
if (PlayerFaction == "Horde") then
nodes["Gorgrond"][60805400]={ "36503", "Biolante", "Quest Item for XP", "You must finish the quest before this element gets removed from the map", "rare", "GorgrondRares","116160"}
nodes["Gorgrond"][46004680]={ "35815", "Charl Doomwing", "Quest Item for XP", "You must finish the quest before this element gets removed from the map", "rare", "GorgrondRares","113456"}
nodes["Gorgrond"][42805920]={ "35811", "Crater Lord Igneous", "Quest Item for XP", "You must finish the quest before this element gets removed from the map", "rare", "GorgrondRares","113448"}
nodes["Gorgrond"][40505100]={ "35810", "Dessicus of the Dead Pools", "Quest Item for XP", "You must finish the quest before this element gets removed from the map", "rare", "GorgrondRares","113447"}
nodes["Gorgrond"][51804160]={ "35807", "Erosian the Violent", "Quest Item for XP", "You must finish the quest before this element gets removed from the map", "rare", "GorgrondRares","113444"}
nodes["Gorgrond"][58006360]={ "35814", "Fungal Praetorian", "Quest Item for XP", "You must finish the quest before this element gets removed from the map", "rare", "GorgrondRares","113454"}
nodes["Gorgrond"][52406580]={ "35819", "Khargax the Devourer", "Quest Item for XP", "You must finish the quest before this element gets removed from the map", "rare", "GorgrondRares","113460"}
nodes["Talador"][61107170]={ "34116", "Norana's Cache", "i564 Agility Neck", "", "default", "TaladorTreasures","117563"}
nodes["Gorgrond"][51206360]={ "35818", "Roardan the Sky Terror", "Quest Item for XP", "Flies around a lot, Coordinates are just somewhere on his route!You must finish the quest before this element gets removed from the map", "rare", "GorgrondRares","113459"}
end

 function GetItem(ID)
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
 function GetIcon(ID)
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
	
		info.isTitle      = 1
		info.text         = "DraenorTreasures"
		info.notCheckable = 1
		UIDropDownMenu_AddButton(info, level)
		
		info.disabled     = nil
		info.isTitle      = nil
		info.notCheckable = nil
		info.text = "Remove this Object from the Map"
		info.func = DisableTreasure
		info.arg1 = clickedMapFile
		info.arg2 = clickedCoord
		UIDropDownMenu_AddButton(info, level)
		
		if isTomTomloaded == true then
			info.text = "Add this location to TomTom waypoints"
			info.func = addtoTomTom
			info.arg1 = clickedMapFile
			info.arg2 = clickedCoord
			UIDropDownMenu_AddButton(info, level)
		end

		info.text         = CLOSE
		info.func         = function() CloseDropDownMenus() end
		info.arg1         = nil
		info.arg2         = nil
		info.notCheckable = 1
		UIDropDownMenu_AddButton(info, level)

		info.text         = "Restore Removed Objects"
		info.func         = ResetDB
		info.arg1         = nil
		info.arg2         = nil
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
	name = "Select what to show in which zone:",
	inline = true,
	args = {
SMVGroup = {
	name = "Shadowmoon Valley",
	desc = "Shadowmoon Valley",
	type = "header",
	order = 0,
	},
SMVTreasures = {
   type = "toggle",
   name = "Treasures",
   arg = "SMVTreasures",
   order = 1,
   width = "half",
  },
SMVRares = {
   type = "toggle",
   name = "Rares",
   arg = "SMVRares",
   order = 2,
   width = "half",
  },
SMVHundredRares = {
   type = "toggle",
   name = "L100 Rares",
   desc = "Level 100 Rarespawns",
   arg = "SMVHundred",
   order = 3,
   width = "half",
  },
SMVShrines = {
   type = "toggle",
   name = "Shrines",
   arg = "SMVShrine",
   order = 4,
   width = "half",
  },
FFRGroup = {
	name = "Frostfire Ridge",
	desc = "Frostfire Ridge",
	type = "header",
	order = 10,
	},	
FFRTreasures = {
   type = "toggle",
   name = "Treasures",
   arg = "FFRTreasures",
   width = "half",
   order = 11,
  },
FFRBF = {
   type = "toggle",
   name = "Bladespire",
   desc = "Treasures in Bladespire Fortress",
   arg = "FFRBF",
   width = "half",
   order = 12,
  },
FFRRares = {
   type = "toggle",
   name = "Rares",
   arg = "FFRRares",
   width = "half",
   order = 13,
  },
FFRHundredRares = {
   type = "toggle",
   name = "L100 Rares",
   desc = "Level 100 Rarespawns",
   arg = "FFRHundred",
   width = "half",
   order = 14,
  },
FFRShrines = {
   type = "toggle",
   name = "Shrines",
   arg = "FFRShrine",
   order = 15,
   width = "half",
  },
GorgrondGroup = {
	name = "Gorgrond",
	desc = "Gorgrond",
	type = "header",
	order = 20,
	},	
GorgrondTreasures = {
   type = "toggle",
   name = "Treasures",
   arg = "GorgrondTreasures",
   width = "half",
   order = 21,
  },
GorgrondRares = {
   type = "toggle",
   name = "Rares",
   arg = "GorgrondRares",
   width = "half",
   order = 22,
  },  
GorgrondHundredRares = {
   type = "toggle",
   name = "L100 Rares",
   arg = "GorgrondHundred",
   desc = "Level 100 Rarespawns",
   width = "normal",
   order = 23,
  },  
GorgrondLumber = {
   type = "toggle",
   name = "Lumber Mill Treasures",
   arg = "GorgrondLumber",
   desc = "Lumber Mill Treasures",
   width = "normal",
   order = 24,
  },  
GorgrondBoulder = {
   type = "toggle",
   name = "Sparring Arena Treasures",
   arg = "GorgrondBoulder",
   desc = "Sparring Arena Treasures",
   width = "normal",
   order = 25,
  },  
TaladorGroup = {
	name = "Talador",
	desc = "Talador",
	type = "header",
	order = 30,
	},	
TaladorTreasures = {
   type = "toggle",
   name = "Treasures",
   arg = "TaladorTreasures",
   width = "half",
   order = 31,
  },
TaladorRares = {
   type = "toggle",
   name = "Rares",
   arg = "TaladorRares",
   width = "half",
   order = 32,
  },  
TaladorHundredRares = {
   type = "toggle",
   name = "L100 Rares",
   arg = "TaladorHundred",
   desc = "Level 100 Rarespawns",
   width = "normal",
   order = 33,
  },  
SoAGroup = {
	name = "Spires of Arak",
	desc = "Spires of Arak",
	type = "header",
	order = 40,
	},	  
SoATreasures = {
   type = "toggle",
   name = "Treasures",
   arg = "SoATreasures",
   width = "half",
   order = 41,
  },
SoARares = {
   type = "toggle",
   name = "Rares",
   arg = "SoARares",
   width = "half",
   order = 42,
  },  
SoAHundredRares = {
   type = "toggle",
   name = "L100 Rares",
   desc = "Level 100 Rarespawns",
   arg = "SoAHundred",
   width = "half",
   order = 43,
  },
SoAArchaeology = {
   type = "toggle",
   name = "SoAArchaeology",
   desc = "Archaeology Treasures",
   arg = "SoAArchaeology",
   width = "half",
   order = 44,
},  
NagrandGroup = {
	name = "Nagrand",
	desc = "Nagrand",
	type = "header",
	order = 50,
	},	    
  NagrandTreasures = {
   type = "toggle",
   name = "Treasures",
   arg = "NagrandTreasures",
   width = "half",
   order = 51,
  },
  NagrandRares = {
   type = "toggle",
   name = "Rares",
   arg = "NagrandRares",
   width = "half",
   order = 52,
  },
  NagrandHundredRares = {
   type = "toggle",
   name = "L100 Rares",
   arg = "NagrandHundred",
   desc = "Level 100 Rarespawns",
   width = "half",
   order = 53,
  },
  NagrandSWPRares = {
   type = "toggle",
   name = "SWP Rares",
   desc = "Steamwheedle Preservation Society Rares",
   arg = "NagrandSWP",
   width = "half",
   order = 54,
  },
 TanaanGroup = {
	name = "Tanaan Jungle",
	desc = "Tanaan Jungle",
	type = "header",
	order = 55,
	},	
TanaanHundredRares = {
   type = "toggle",
   name = "L100 Rares",
   arg = "TanaanHundred",
   desc = "Level 100 Rarespawns",
   width = "normal",
   order = 56,
  },  
	},
  },
  alwaysshow = {
   type = "toggle",
   name = "Also show already looted(killed) Treasures(Rares)",
   desc = "Show every treasure/rare regardless of looted status",
   arg = "alwaysshow",
   order = 100,
   width = "full",
  },
    show_loot = {
   type = "toggle",
   name = "Show Loot",
   desc = "Shows the Loot for each Treasure/Rare",
   arg = "show_loot",
   order = 101,
   },
  show_notes = {
   type = "toggle",
   name = "Show Notes",
   desc = "Shows the notes each Treasure/Rare if available",
   arg = "show_notes",
   order = 101,
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
   alwaysshow = false,
   save = true,
   SMVTreasures = true,
   SMVRares = true,
   SMVHundred = true,
   SMVShrine = true,
   FFRTreasures = true,
   FFRRares = true,
   FFRHundred = true,
   FFRShrine = true,
   FFRBF = false,
   GorgrondTreasures = true,
   GorgrondRares = true,
   GorgrondHundred = true,
   GorgrondLumber = true,
   GorgrondBoulder = true,
   TaladorTreasures = true,
   TaladorRares = true,
   TaladorHundred = true,
   SoATreasures = true,
   SoARares = true,
   SoAHundred = true,
   SoAArchaeology = true,
   NagrandTreasures = true,
   NagrandRares = true,
   NagrandHundred = true,
   NagrandSWP = true,
   TanaanHundred = true,
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
end

function DraenorTreasures:QuestCheck()
do
	if ((IsQuestFlaggedCompleted(36386) == false) or (IsQuestFlaggedCompleted(36390) == false) or (IsQuestFlaggedCompleted(36389) == false) or (IsQuestFlaggedCompleted(36392) == false) or (IsQuestFlaggedCompleted(36388) == false) or (IsQuestFlaggedCompleted(36381) == false)) then
		nodes["SpiresOfArak"][43901500]={ "36395", "Elixir of Shadow Sight 1", "Elixir of Shadow Sight", "Elixir can be used at Shrine of Terrok for 1 of 6 i585 Weapons (see Gift of Anzu) Object will be removed as soon as you loot all Gifts of Anzu", "default", "SoATreasures","115463"}
		nodes["SpiresOfArak"][43802470]={ "36397", "Elixir of Shadow Sight 2", "Elixir of Shadow Sight", "Elixir can be used at Shrine of Terrok for 1 of 6 i585 Weapons (see Gift of Anzu) Object will be removed as soon as you loot all Gifts of Anzu", "default", "SoATreasures","115463"}
		nodes["SpiresOfArak"][69204330]={ "36398", "Elixir of Shadow Sight 3", "Elixir of Shadow Sight", "Elixir can be used at Shrine of Terrok for 1 of 6 i585 Weapons (see Gift of Anzu) Object will be removed as soon as you loot all Gifts of Anzu", "default", "SoATreasures","115463"}
		nodes["SpiresOfArak"][48906250]={ "36399", "Elixir of Shadow Sight 4", "Elixir of Shadow Sight", "Elixir can be used at Shrine of Terrok for 1 of 6 i585 Weapons (see Gift of Anzu) Object will be removed as soon as you loot all Gifts of Anzu", "default", "SoATreasures","115463"}
		nodes["SpiresOfArak"][55602200]={ "36400", "Elixir of Shadow Sight 5", "Elixir of Shadow Sight", "Elixir can be used at Shrine of Terrok for 1 of 6 i585 Weapons (see Gift of Anzu) Object will be removed as soon as you loot all Gifts of Anzu", "default", "SoATreasures","115463"}
		nodes["SpiresOfArak"][53108450]={ "36401", "Elixir of Shadow Sight 6", "Elixir of Shadow Sight", "Elixir can be used at Shrine of Terrok for 1 of 6 i585 Weapons (see Gift of Anzu) Object will be removed as soon as you loot all Gifts of Anzu", "default", "SoATreasures","115463"}
	end
	if (IsQuestFlaggedCompleted(36249) or IsQuestFlaggedCompleted(36250)) then
		--Gorgrond Lumber Mill is active if either of these Quest IDs are true
		nodes["Gorgrond"][49074846]={ "950000", "Aged Stone Container", "", "QuestID is missing, will stay active until manually disabled", "default", "GorgrondLumber","824"}
		nodes["Gorgrond"][42345477]={ "36003", "Aged Stone Container", "", "", "default", "GorgrondLumber","824"}
		nodes["Gorgrond"][47514363]={ "36717", "Aged Stone Container", "", "", "default", "GorgrondLumber","824"}
		nodes["Gorgrond"][53354679]={ "35701", "Ancient Titan Chest", "", "", "default", "GorgrondLumber","824"}
		nodes["Gorgrond"][50155376]={ "35984", "Ancient Titan Chest", "", "", "default", "GorgrondLumber","824"}
		nodes["Gorgrond"][42084607]={ "36720", "Ancient Titan Chest", "", "", "default", "GorgrondLumber","824"}
		nodes["Gorgrond"][41988155]={ "35982", "Botani Essence Seed", "", "", "default", "GorgrondLumber","824"}
		nodes["Gorgrond"][49657883]={ "35968", "Forgotten Ogre Cache", "", "", "default", "GorgrondLumber","824"}
		nodes["Gorgrond"][47016905]={ "35971", "Forgotten Skull Cache", "", "", "default", "GorgrondLumber","824"}
		nodes["Gorgrond"][45808931]={ "36019", "Forgotten Skull Cache", "", "", "default", "GorgrondLumber","824"}
		nodes["Gorgrond"][39335627]={ "36716", "Forgotten Skull Cache", "", "", "default", "GorgrondLumber","824"}
		nodes["Gorgrond"][56745727]={ "35965", "Mysterious Petrified Pod", "", "", "default", "GorgrondLumber","824"}
		nodes["Gorgrond"][41147726]={ "35980", "Mysterious Petrified Pod", "", "", "default", "GorgrondLumber","824"}
		nodes["Gorgrond"][60507276]={ "36015", "Mysterious Petrified Pod", "", "", "default", "GorgrondLumber","824"}
		nodes["Gorgrond"][63285719]={ "36430", "Mysterious Petrified Pod", "", "", "default", "GorgrondLumber","824"}
		nodes["Gorgrond"][47647679]={ "36714", "Mysterious Petrified Pod", "", "", "default", "GorgrondLumber","824"}
		nodes["Gorgrond"][51756909]={ "36715", "Mysterious Petrified Pod", "", "", "default", "GorgrondLumber","824"}
		nodes["Gorgrond"][40956732]={ "35979", "Obsidian Crystal Formation", "", "", "default", "GorgrondLumber","824"}
		nodes["Gorgrond"][45969357]={ "35975", "Remains of Explorer Engineer Toldirk Ashlamp", "", "", "default", "GorgrondLumber","824"}
		nodes["Gorgrond"][51806148]={ "35966", "Remains of Grimnir Ashpick", "", "", "default", "GorgrondLumber","824"}
		nodes["Gorgrond"][51647226]={ "35967", "Unknown Petrified Egg", "", "", "default", "GorgrondLumber","824"}
		nodes["Gorgrond"][45318195]={ "35981", "Unknown Petrified Egg", "", "", "default", "GorgrondLumber","824"}
		nodes["Gorgrond"][42914350]={ "36001", "Unknown Petrified Egg", "", "", "default", "GorgrondLumber","824"}
		nodes["Gorgrond"][53007906]={ "36713", "Unknown Petrified Egg", "", "", "default", "GorgrondLumber","824"}
		nodes["Gorgrond"][47245180]={ "36718", "Unknown Petrified Egg", "", "", "default", "GorgrondLumber","824"}
	end
	if (IsQuestFlaggedCompleted(36251) or IsQuestFlaggedCompleted(36252)) then
		--Gorgrond Sparring Arena is active if either of these Quest IDs are true
		nodes["Gorgrond"][45634931]={ "36722", "Aged Stone Container", "", "", "default", "GorgrondBoulder","824"}
		nodes["Gorgrond"][43224574]={ "36723", "Aged Stone Container", "", "", "default", "GorgrondBoulder","824"}
		nodes["Gorgrond"][41764527]={ "36726", "Aged Stone Container", "", "", "default", "GorgrondBoulder","824"}
		nodes["Gorgrond"][48115516]={ "36730", "Aged Stone Container", "", "", "default", "GorgrondBoulder","824"}
		nodes["Gorgrond"][51334055]={ "36734", "Aged Stone Container", "", "", "default", "GorgrondBoulder","824"}
		nodes["Gorgrond"][46056305]={ "36736", "Aged Stone Container", "", "", "default", "GorgrondBoulder","824"}
		nodes["Gorgrond"][58125146]={ "36739", "Aged Stone Container", "", "", "default", "GorgrondBoulder","824"}
		nodes["Gorgrond"][59567275]={ "36781", "Aged Stone Container", "", "", "default", "GorgrondBoulder","824"}
		nodes["Gorgrond"][45748821]={ "36784", "Aged Stone Container", "", "", "default", "GorgrondBoulder","824"}
		nodes["Gorgrond"][45544298]={ "36733", "Ancient Ogre Cache", "", "", "default", "GorgrondBoulder","824"}
		nodes["Gorgrond"][45076993]={ "36737", "Ancient Ogre Cache", "", "", "default", "GorgrondBoulder","824"}
		nodes["Gorgrond"][61555855]={ "36740", "Ancient Ogre Cache", "", "", "default", "GorgrondBoulder","824"}
		nodes["Gorgrond"][54257313]={ "36782", "Ancient Ogre Cache", "", "", "default", "GorgrondBoulder","824"}
		nodes["Gorgrond"][42179308]={ "36787", "Ancient Ogre Cache", "", "", "default", "GorgrondBoulder","824"}
		nodes["Gorgrond"][41528652]={ "36789", "Ancient Ogre Cache", "", "", "default", "GorgrondBoulder","824"}
		nodes["Gorgrond"][49425084]={ "36710", "Ancient Titan Chest", "", "", "default", "GorgrondBoulder","824"}
		nodes["Gorgrond"][42195203]={ "36727", "Ancient Titan Chest", "", "", "default", "GorgrondBoulder","824"}
		nodes["Gorgrond"][43365169]={ "36731", "Ancient Titan Chest", "", "", "default", "GorgrondBoulder","824"}
		nodes["Gorgrond"][47923998]={ "36735", "Ancient Titan Chest", "", "", "default", "GorgrondBoulder","824"}
		nodes["Gorgrond"][50326658]={ "36738", "Ancient Titan Chest", "", "", "default", "GorgrondBoulder","824"}
		nodes["Gorgrond"][49128248]={ "36783", "Ancient Titan Chest", "", "", "default", "GorgrondBoulder","824"}
		nodes["Gorgrond"][48114638]={ "36721", "Obsidian Crystal Formation", "", "", "default", "GorgrondBoulder","824"}
		nodes["Gorgrond"][41855889]={ "36728", "Obsidian Crystal Formation", "", "", "default", "GorgrondBoulder","824"}
		nodes["Gorgrond"][42056429]={ "36729", "Obsidian Crystal Formation", "", "", "default", "GorgrondBoulder","824"}
		nodes["Gorgrond"][44184665]={ "36732", "Obsidian Crystal Formation", "", "", "default", "GorgrondBoulder","824"}
	end
end
end

function DraenorTreasures:RegisterWithHandyNotes()
do
	local function iter(t, prestate)
		if not t then return nil end
		local state, value = next(t, prestate)
		while state do
			    -- QuestID[1], Name[2], Loot[3], Notes[4], Icon[5], Tag[6], ItemID[7]
			    if (value[1] and self.db.profile[value[6]] and not DraenorTreasures:HasBeenLooted(value)) then
					if ((value[5] == "default") or (value[5] == "unknown")) then
						if ((value[7] ~= nil) and (value[7] ~= "")) then
							return state, nil, GetIcon(value[7]), DraenorTreasures.db.profile.icon_scale_treasures, DraenorTreasures.db.profile.icon_alpha
						else
							GetIcon(value[7]) --this should precache the Item, so that the loot is correctly returned
							return state, nil, iconDefaults[value[5]], DraenorTreasures.db.profile.icon_scale_treasures, DraenorTreasures.db.profile.icon_alpha
						end
					end
				if ((value[7] ~= nil) and (value[7] ~= "")) then
				 	GetIcon(value[7]) --this should precache the Item, so that the loot is correctly returned
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

function ResetDB()
	table.wipe(DraenorTreasures.db.char)
	DraenorTreasures:Refresh()
end

function DraenorTreasures:HasBeenLooted(value)
if (self.db.profile.alwaysshow) then return false end
if (DraenorTreasures.db.char[value[1]] and self.db.profile.save) then return true end
if (IsQuestFlaggedCompleted(value[1])) then
	return true
end
return false
end

function DisableTreasure(button, mapFile, coord)
	if (nodes[mapFile][coord][1] ~= nil) then
		DraenorTreasures.db.char[nodes[mapFile][coord][1]] = true;
	end
	DraenorTreasures:Refresh()
end
function addtoTomTom(button, mapFile, coord)
	if isTomTomloaded == true then
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
		TomTom:AddMFWaypoint(mapId, nil, x, y, {
			title = desc,
			persistent = nil,
			minimap = true,
			world = true
		})
	end
end