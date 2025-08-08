local ADDON_NAME, ns = ...

function ns.LoadMapNotesMinimapInfo()
local minimap = ns.minimap

--##################################
--####### Classic MoP minimap ######
--##################################

minimap[1467] = { } -- Outland
minimap[998] = { } -- Undercity

--##############################
--####### Classic minimap ######
--##############################

--############################
--######### Kalimdor #########
--############################

-- Azeroth/Continent map minimap
minimap[1411]  = { } -- Durotar
minimap[1412]  = { } -- Mulgore
minimap[1413] = { } -- Barrens    
minimap[1414] = { } -- Kalimdor 
minimap[1438] = { } -- Teldrassil
minimap[1439] = { } -- Darkshore
minimap[1440] = { } -- Ashenvale  
minimap[1441] = { } -- Thousand Needles  
minimap[1442] = { } -- Stonetalon Mountains
minimap[1443] = { } -- Desolace      
minimap[1444] = { } -- Feralas
minimap[1445] = { } -- Dustwallow
minimap[1446] = { } -- Tanaris
minimap[1447] = { } -- Azshara
minimap[1448] = { } -- Felwood
minimap[1449] = { } -- Un'Goro Crater
minimap[1450] = { } -- Moonglade    
minimap[1451] = { } -- Silithus    
minimap[1452] = { } -- Winterspring
minimap[1454] = { } -- Orgrimmar 
minimap[1455] = { } -- Ironforge
minimap[1456] = { } -- Thunder Bluff
minimap[1457] = { } -- Darnassus
minimap[1950] = { } -- Blutmythosinsel

--############################
--###### Eastern Kingdom #####
--############################

-- Azeroth/Continent map minimap
minimap[217] = { } -- Ruins of Gilneas
minimap[1415] = { } -- Eastern Kingdoms
minimap[1416] = { } -- Alterac Valley 
minimap[1417] = { } -- Arathi Highlands
minimap[1418] = { } -- Badlands
minimap[1419] = { } -- Blasted Lands
minimap[1420] = { } -- Tirisfal   
minimap[1421] = { } -- Silverpine Forest
minimap[1422] = { } -- WesternPlaguelands 
minimap[1423] = { } -- EasternPlagueland
minimap[1424] = { } -- Hillsbrad Foothills
minimap[1425] = { } -- The Hinterlands
minimap[1426] = { } -- DunMorogh 
minimap[1427] = { } -- Searing Gorge
minimap[1428] = { } -- BurningSteppes    
minimap[1429] = { } -- Elwynn Forest
minimap[1430] = { } -- DeadwindPass   
minimap[1431] = { } -- Duskwood
minimap[1432] = { } -- Loch Modan
minimap[1433] = { } -- Redridge Mountains
minimap[1434] = { } -- Stranglethorn Vale
minimap[1435] = { } -- SwampOfSorrows
minimap[1436] = { } -- Westfall    
minimap[1437] = { } -- Wettlands
minimap[1453] = { } -- Stormwind City   
minimap[1458] = { } -- Undercity Old Version
minimap[1941] = { } -- Eversong Woods
minimap[1942] = { } -- Ghostlands
minimap[1943] = { } -- Azurmythosinsel
minimap[1947] = { } -- Exodar
minimap[1954] = { } -- Silvermoon City
minimap[1957] = { } -- Isle of Quel'Danas



--####################
--###### Outland #####
--####################

minimap[1944] = { } -- Hellfire
minimap[1945] = { } -- Outland
minimap[1946] = { } -- Zangarmarsh
minimap[1948] = { } -- ShadowmoonValley
minimap[1949] = { } -- Schergrat
minimap[1951] = { } -- Nagrand
minimap[1952] = { } -- TerokkarForest
minimap[1953] = { } -- Netherstorm
minimap[1955] = { } -- Shattrath


--###########################
--####### Retail minimap ####
--###########################

-- Azeroth/Continent map minimap
minimap[407] = { } -- Darkmoon
minimap[946] = { } -- WorldMap
minimap[947] = { } -- Azeroth
minimap[971] = { } -- Telogros Rift

--############################
--######### Kalimdor #########
--############################

-- Azeroth/Continent map minimap
minimap[1]  = { } -- Durotar
minimap[7]  = { } -- Mulgore
minimap[10] = { } -- Barrens    
minimap[11] = { } -- Wailing Caverns
minimap[12] = { } -- Kalimdor 
minimap[57] = { } -- Teldrassil
minimap[62] = { } -- Darkshore Vanilla
minimap[63] = { } -- Ashenvale  
minimap[64] = { } -- Thousand Needles  
minimap[65] = { } -- Stonetalon Mountains   
minimap[66] = { } -- Desolace    
minimap[67] = { } -- Maraudon Outside  
minimap[68] = { } -- Maraudon Foulspore Cavern    
minimap[69] = { } -- Feralas
minimap[70] = { } -- Dustwallow
minimap[71] = { } -- Tanaris
minimap[74] = { } -- Timeless Tunnel
minimap[75] = { } -- Caverns of Time lower half
minimap[76] = { } -- Azshara
minimap[77] = { } -- Felwood
minimap[78] = { } -- Un'Goro Crater
minimap[80] = { } -- Moonglade
minimap[81] = { } -- Silithus  
minimap[83] = { } -- Winterspring  
minimap[85] = { } -- Orgrimmar 
minimap[86] = { } -- Ragefire -- of Shadow
minimap[87] = { } -- Ironforge
minimap[88] = { } -- Thunder Bluff
minimap[89] = { } -- Teldrassil / Darnassus
minimap[97] = { } -- Azurmythosinsel
minimap[103] = { } -- Exodar
minimap[106] = { } -- Blutmythosinsel
minimap[199] = { } -- Southern Barrens  
minimap[327] = { } -- AhnQiraj The Fallen Kingdom 
minimap[460] = { } -- Shadowglen
minimap[461] = { } -- Valley of Trials
minimap[462] = { } --Camp Narache
minimap[468] = { } -- Am'Mental
minimap[503] = { } -- Shlae'gararena
-- Dungeon map minimap
minimap[130] = { } -- The Culling of Stratholme
minimap[131] = { } -- Stratholme City
minimap[213] = { } -- Ragefire Chasm
minimap[219] = { } -- Zul'Farrak
minimap[221] = { } -- Blackfathom Deeps - The Pool of Ask'Ar
minimap[222] = { } -- Moonshrine Sanctum
minimap[223] = { } -- The Forgotten Pool
minimap[235] = { } -- Dire Maul Gordok Commons
minimap[236] = { } -- Dire Maul Capital Gardens
minimap[239] = { } -- Dire Maul Warpwood Quarter
minimap[240] = { } -- Dire Maul Warpwood Quarter 
minimap[247] = { } -- Ruins of Ahn'Qiraj
minimap[248] = { } -- Onyxia Lair
minimap[273] = { } -- The Black Morass
minimap[274] = { } -- Old Hillsbrad Foothills
minimap[277] = { } -- Lost City of the Tol'vir
minimap[279] = { } -- Wailing Caverns
minimap[280] = { } -- Maraudon Caverns of Maraudon - Purple Crystal 
minimap[281] = { } -- Caverns of Maraudon
minimap[297] = { } -- Halls of Orientation
minimap[299] = { } -- Die Vier Sitze
minimap[297] = { } -- Hall des Lichts
minimap[298] = { } -- Grab des Erdwüters
minimap[300] = { } -- Razorfen Downs
minimap[301] = { } -- Razorfen Kraul
minimap[320] = { } -- Temple of Ahn'Qiraj - Die Tempeltore
minimap[321] = { } -- Höhle von C'Thun
minimap[319] = { } -- Untergrund des Schwarmbaus
minimap[324] = { } -- The Stonecore
minimap[325] = { } -- The Vortex Pinnacle
minimap[328] = { } -- Throne of the Four Winds
minimap[367] = { } -- Firelands
minimap[369] = { } -- Sulfuron Keep
minimap[398] = { } -- Well of Eternity
minimap[399] = { } -- Hour of Twilight
minimap[400] = { } -- Wyrmrest Temple
minimap[401] = { } -- End Time 
minimap[402] = { } -- Azure Dragonshrine
minimap[403] = { } -- End Time - Ruby Dragonshrine
minimap[409] = { } -- Dragon Soul
minimap[410] = { } -- Maw of Go'rath
minimap[411] = { } -- Maw of Shu'ma
minimap[412] = { } -- Eye of Eternity
minimap[1580] = { } -- AhnQiraj The Fallen Kingdom 

--############################
--###### Eastern Kingdom #####
--############################

-- Azeroth/Continent map minimap
minimap[13] = { } -- Eastern Kingdoms   
minimap[14] = { } -- Arathi Highlands
minimap[15] = { } -- Badlands
minimap[16] = { } -- Badlands Uldaman Cave
minimap[17] = { } -- Blasted Lands
minimap[18] = { } -- Tirisfal   
minimap[19] = { } -- ScarletMonasteryEntrance 
minimap[21] = { } -- Silverpine Forest
minimap[22] = { } -- WesternPlaguelands 
minimap[23] = { } -- EasternPlagueland
minimap[25] = { } -- Hillsbrad Foothills
minimap[26] = { } -- The Hinterlands
minimap[27] = { } -- DunMorogh
minimap[28] = { } -- Coldridge
minimap[30] = { } -- New Tinker Town  
minimap[32] = { } -- Searing Gorge
minimap[33] = { } -- BlackrockMountain
minimap[34] = { } -- BlackrockMountain - Blackrock Caverns
minimap[35] = { } -- BlackrockMountain - Blackrock Depths
minimap[36] = { } -- BurningSteppes    
minimap[37] = { } -- Elwynn Forest
minimap[42] = { } -- DeadwindPass   
minimap[47] = { } -- Duskwood
minimap[48] = { } -- Loch Modan
minimap[49] = { } -- Redridge Mountains
minimap[50] = { } -- StranglethornJungle
minimap[51] = { } -- SwampOfSorrows
minimap[52] = { } -- Westfall    
minimap[55] = { } -- The Deadmines Caverns
minimap[56] = { } -- Wettlands
minimap[84] = { } -- Stormwind City   
minimap[90] = { } -- Undercity Old Version
minimap[94] = { } -- Eversong Woods
minimap[110] = { } -- Silvermoon City   
minimap[210] = { } -- Stranglethorn Vale
minimap[224] = { } -- The Cape of Stranglethorn
minimap[245] = { } -- Tol Barad Pensinsula
minimap[425] = { } -- Nordhain
minimap[427] = { } -- Coldridge Valley
minimap[465] = { } -- Deadend
minimap[467] = { } -- Sunstrider Isle
minimap[469] = { } -- New Tinkertown 
minimap[499] = { } -- Trail - Bizmos Boxbar
minimap[500] = { } -- Bizmos Boxbar
minimap[2070] = { } -- New Tirisfal
-- Dungeon map minimap 
minimap[162] = { } -- Naxxramas - Inside Dungeon Map
minimap[163] = { } -- Naxxramas - Inside Dungeon Map
minimap[164] = { } -- Naxxramas - Inside Dungeon Map
minimap[165] = { } -- Naxxramas - Inside Dungeon Map
minimap[166] = { } -- Naxxramas - Inside Dungeon Map
minimap[167] = { } -- Naxxramas - Inside Dungeon Map
minimap[220] = { } -- Tempel of Atal'hakkar
minimap[225] = { } -- The Stockade  
minimap[226] = { } -- Gnomeregan - Inside Dungeon Map   
minimap[227] = { } -- Gnomeregan - Inside Dungeon Map
minimap[228] = { } -- Gnomeregan - Inside Dungeon Map
minimap[229] = { } -- Gnomeregan - Inside Dungeon Map
minimap[230] = { } -- Uldaman - Inside Dungeon Map
minimap[231] = { } -- Uldaman - Inside Dungeon Map
minimap[232] = { } -- Molten Core
minimap[242] = { } -- Blackwing Depths - Inside Dungeon Map
minimap[243] = { } -- Blackrock Depths - Inside Dungeon Map
minimap[1186] = { } -- Blackrock Depths - Inside Dungeon Map
minimap[250] = { } -- Lower Blackrock Spire - Inside Dungeon Map
minimap[251] = { } -- Lower Blackrock Spire - Inside Dungeon Map
minimap[252] = { } -- Lower Blackrock Spire - Inside Dungeon Map
minimap[253] = { } -- Lower Blackrock Spire - Inside Dungeon Map
minimap[254] = { } -- Lower Blackrock Spire - Inside Dungeon Map
minimap[255] = { } -- Lower Blackrock Spire - Inside Dungeon Map
minimap[282] = { } -- Baradin Hold
minimap[283] = { } -- Blackrock Caverns - Inside Dungeon Map      
minimap[284] = { } -- Blackrock Caverns - Inside Dungeon Map 
minimap[285] = { } -- Blackwing Descent - Inside Dungeon Map
minimap[286] = { } -- Blackwing Descent - Inside Dungeon Map
minimap[287] = { } -- Blackwing Lair - Inside Dungeon Map
minimap[288] = { } -- Blackwing Lair - Inside Dungeon Map
minimap[289] = { } -- Blackwing Lair - Inside Dungeon Map
minimap[290] = { } -- Blackwing Lair - Inside Dungeon Map
minimap[291] = { } -- Deadmines - Inside Dungeon Map
minimap[292] = { } -- Deadmines - Inside Dungeon Map
minimap[293] = { } -- Grim Batol
minimap[294] = { } -- Bastion of Twilight - Inside Dungeon Map
minimap[295] = { } -- Bastion of Twilight - Inside Dungeon Map
minimap[302] = { } -- Old Scarlet Monastery - Inside Dungeon Map - Graveyard
minimap[303] = { } -- Old Scarlet Monastery - Inside Dungeon Map - Library
minimap[304] = { } -- Old Scarlet Monastery - Inside Dungeon Map - Armory
minimap[305] = { } -- Old Scarlet Monastery - Inside Dungeon Map - Cathedral   
minimap[306] = { } -- Old Scholomance - Inside Dungeon Map - The Reliquary
minimap[307] = { } -- Old Scholomance - Inside Dungeon Map - Chamber of Summoning
minimap[308] = { } -- Old Scholomance - Inside Dungeon Map - The Upper Study
minimap[309] = { } -- Old Scholomance - Inside Dungeon Map - Headmaster's Study
minimap[310] = { } -- Shadowfang Keep - Inside Dungeon Map
minimap[311] = { } -- Shadowfang Keep - Inside Dungeon Map
minimap[316] = { } -- Shadowfang Keep - Inside Dungeon Map
minimap[312] = { } -- Shadowfang Keep - Inside Dungeon Map
minimap[313] = { } -- Shadowfang Keep - Inside Dungeon Map
minimap[314] = { } -- Shadowfang Keep - Inside Dungeon Map
minimap[315] = { } -- Shadowfang Keep - Inside Dungeon Map
minimap[317] = { } -- Stratholme - Main Gate
minimap[318] = { } -- Stratholme Service Entrance
minimap[322] = { } -- Throne of the Tides - Inside Dungeon Map  
minimap[323] = { } -- Throne of the Tides - Inside Dungeon Map   
minimap[333] = { } -- Zul'Aman
minimap[335] = { } -- Sunwell Plateau 
minimap[336] = { } -- Sunwell Plateau - Dungeon Map
minimap[337] = { } -- Zul'Gurub
minimap[348] = { } -- Magisters'Terrace - Dungeon Map
minimap[349] = { } -- Magisters'Terrace - Dungeon Map      
minimap[350] = { } -- Karazhan - Inside Dungeon Map
minimap[351] = { } -- Karazhan - Inside Dungeon Map
minimap[352] = { } -- Karazhan - Inside Dungeon Map
minimap[353] = { } -- Karazhan - Inside Dungeon Map
minimap[354] = { } -- Karazhan - Inside Dungeon Map
minimap[355] = { } -- Karazhan - Inside Dungeon Map
minimap[356] = { } -- Karazhan - Inside Dungeon Map
minimap[357] = { } -- Karazhan - Inside Dungeon Map
minimap[358] = { } -- Karazhan - Inside Dungeon Map
minimap[359] = { } -- Karazhan - Inside Dungeon Map
minimap[360] = { } -- Karazhan - Inside Dungeon Map
minimap[361] = { } -- Karazhan - Inside Dungeon Map
minimap[362] = { } -- Karazhan - Inside Dungeon Map
minimap[363] = { } -- Karazhan - Inside Dungeon Map
minimap[364] = { } -- Karazhan - Inside Dungeon Map
minimap[365] = { } -- Karazhan - Inside Dungeon Map
minimap[366] = { } -- Karazhan - Inside Dungeon Map
minimap[432] = { } -- Scarlet Halls
minimap[436] = { } -- Scarlet Monastery
minimap[431] = { } -- Scarlet Halls
minimap[435] = { } -- Scarlet Monastery
minimap[476] = { } -- Scholomance - Inside Dungeon Map    
minimap[477] = { } -- Scholomance - Inside Dungeon Map
minimap[478] = { } -- Scholomance - Inside Dungeon Map
minimap[479] = { } -- Scholomance - Inside Dungeon Map
minimap[616] = { } -- Upper Blackrock Spire - Inside Dungeon Map
minimap[617] = { } -- Upper Blackrock Spire - Inside Dungeon Map
minimap[617] = { } -- Upper Blackrock Spire - Inside Dungeon Map
minimap[618] = { } -- Upper Blackrock Spire - Inside Dungeon Map
minimap[809] = { } -- Return to Karazhan - Inside Dungeon Map
minimap[814] = { } -- Return to Karazhan - Inside Dungeon Map
minimap[2071] = { } -- Uldaman Legacy of Tyr

--############################
--######### Outland ##########
--############################

-- Azeroth/Continent map minimap
minimap[95] = { } -- Ghostlands    
minimap[100] = { } -- Hellfire 
minimap[101] = { } -- Outland
minimap[102] = { } -- Zangarmarsh   
minimap[104] = { } -- ShadowmoonValley  
minimap[105] = { } -- BladesEdgeMountains  
minimap[107] = { } -- Nagrand    
minimap[108] = { } -- TerokkarForest
minimap[109] = { } -- Netherstorm
minimap[111] = { } -- Shattrath
minimap[122] = { } -- Sunwel, Isle of Quel'Danas 
-- Dungeon map minimap 
minimap[246] = { } -- Shattered Halls
minimap[256] = { } -- Auchenai Crypts - Inside Dungeon Map
minimap[257] = { } -- Auchenai Crypts - Inside Dungeon Map
minimap[258] = { } -- Sethekk Halls - Inside Dungeon Map
minimap[259] = { } -- Sethekk Halls - Inside Dungeon Map
minimap[260] = { } -- Shadow Labyrinth
minimap[261] = { } -- Blood Furnace
minimap[262] = { } -- The Underbog
minimap[263] = { } -- Steamvault - Inside Dungeon Map
minimap[264] = { } -- Steamvault - Inside Dungeon Map
minimap[265] = { } -- Slave Pens
minimap[266] = { } -- Botanica
minimap[267] = { } -- Mechanar - Inside Dungeon Map
minimap[268] = { } -- Mechanar - Inside Dungeon Map
minimap[269] = { } -- Arcatraz - Inside Dungeon Map
minimap[270] = { } -- Arcatraz - Inside Dungeon Map
minimap[271] = { } -- Arcatraz - Inside Dungeon Map
minimap[272] = { } -- Mana Tombs
minimap[332] = { } -- Serpentshrine Cavern
minimap[330] = { } -- Gruul
minimap[331] = { } -- Magtheridons
minimap[334] = { } -- The Eye
minimap[339] = { } -- Black Temple
minimap[340] = { } -- Karabor Sewers
minimap[341] = { } -- Sanctuary of Shadows
minimap[342] = { } -- Halls of Anguish
minimap[343] = { } -- Gorefiend's Vigil
minimap[344] = { } -- Den of Mortal Delights
minimap[345] = { } -- Chamber of Command
minimap[346] = { } -- Temple Summit
minimap[347] = { } -- Hellfire Ramparts

--############################
--## Wrath of the Lich King ##
--############################

-- Azeroth/Continent map minimap
minimap[113] = { } -- Northrend
minimap[114] = { } -- Borean Tundra
minimap[115] = { } -- Dragonblight    
minimap[116] = { } -- Grizzly Hills
minimap[117] = { } -- HowlingFjord    
minimap[118] = { } -- IcecrownGlacier  
minimap[119] = { } -- Sholazar Basin
minimap[120] = { } -- The Storm Peaks
minimap[121] = { } -- Zul'Drak
minimap[123] = { } -- LakeWintergrasp  
minimap[125] = { } -- Dalaran City    
minimap[126] = { } -- Dalaran City Basement
minimap[127] = { } -- Crystalsong Forest 
minimap[170] = { } -- Hrothgar's Landing
-- Dungeon map minimap 
minimap[129] = { } -- The Nexus
minimap[132] = { } -- Ahn'kahet
minimap[133] = { } -- Utgarde Keep - Inside Dungeon Map
minimap[134] = { } -- Utgarde Keep - Inside Dungeon Map
minimap[135] = { } -- Utgarde Keep - Inside Dungeon Map
minimap[136] = { } -- Utgarde Pinnacle - Inside Dungeon Map
minimap[137] = { } -- Utgarde Pinnacle - Inside Dungeon Map
minimap[138] = { } -- Halls of Lightning - Inside Dungeon Map
minimap[139] = { } -- Halls of Lightning - Inside Dungeon Map
minimap[140] = { } -- Halls of Stone   
minimap[142] = { } -- The Oculus - Inside Dungeon Map
minimap[143] = { } -- The Oculus - Inside Dungeon Map
minimap[144] = { } -- The Oculus - Inside Dungeon Map
minimap[145] = { } -- The Oculus - Inside Dungeon Map
minimap[146] = { } -- The Oculus - Inside Dungeon Map
minimap[147] = { } -- Ulduar - Inside Dungeon Map
minimap[149] = { } -- Ulduar - Inside Dungeon Map
minimap[154] = { } -- Gundrak
minimap[155] = { } -- Sanctum of Obsidian
minimap[156] = { } -- Vault of Archavon
minimap[157] = { } -- Azjol Nerub - Inside Dungeon Map
minimap[158] = { } -- Azjol Nerub - Inside Dungeon Map
minimap[159] = { } -- Azjol Nerub - Inside Dungeon Map
minimap[160] = { } -- Drak'Tharon Keep - Inside Dungeon Map
minimap[161] = { } -- Drak'Tharon Keep - Inside Dungeon Map
minimap[166] = { } -- Naxxramas 
minimap[168] = { } -- Violet Keep
minimap[171] = { } -- Trial of the Champion
minimap[172] = { } -- Trial of the Crusader - Inside Dungeon Map
minimap[173] = { } -- Trial of the Crusader - Inside Dungeon Map
minimap[183] = { } -- the Soulforges
minimap[184] = { } -- Pit of Saron
minimap[185] = { } -- Halls of Reflection
minimap[186] = { } -- IcecrownGlacier - Inside Dungeon Map
minimap[187] = { } -- IcecrownGlacier - Inside Dungeon Map
minimap[188] = { } -- IcecrownGlacier - Inside Dungeon Map
minimap[190] = { } -- IcecrownGlacier - Inside Dungeon Map
minimap[191] = { } -- IcecrownGlacier - Inside Dungeon Map
minimap[189] = { } -- IcecrownGlacier - Inside Dungeon Map
minimap[192] = { } -- IcecrownGlacier - Inside Dungeon Map
minimap[200] = { } -- Sanctum of Ruby

--############################
--######### Catalysm #########
--############################

-- Azeroth/Continent map minimap
minimap[198] = { } -- Hyjal
minimap[201] = { } -- Tang'Thar Forest
minimap[203] = { } -- Vashjir
minimap[204] = { } -- VashjirDepths 
minimap[205] = { } -- Shimmering Expanse
minimap[207] = { } -- Deepholm
minimap[241] = { } -- TwilightHighlands   
minimap[244] = { } -- TolBarad    
minimap[249] = { } -- Uldum  
minimap[948] = { } -- The Maelstrom
minimap[1527] = { } -- Uldum

--############################
--##### Misk of Pandaria #####
--############################

-- Azeroth/Continent map minimap
minimap[371] = { } -- TheJadeForest
minimap[376] = { } -- ValleyoftheFourWinds
minimap[378] = { } -- The Wandering Isle 
minimap[379] = { } -- KunLaiSummit  
minimap[388] = { } -- TownlongWastes    
minimap[390] = { } -- ValeofEternalBlossoms  
minimap[391] = { } -- Shrine of Two Moons first floor
minimap[392] = { } -- Shrine of Two Moons second floor
minimap[393] = { } -- Shrine of Seven Stars first floor
minimap[394] = { } -- Shrine of Seven Stars second floor
minimap[418] = { } -- Krasarang Wilds
minimap[422] = { } -- DreadWastes   
minimap[424] = { } -- Pandaria   
minimap[433] = { } -- The Veiles Stairs
minimap[434] = { } -- The Old Passage
minimap[504] = { } -- IsleoftheThunderKing
minimap[507] = { } -- Isle of Giants
minimap[554] = { } -- Timeless Isle
minimap[1530] = { } -- ValeofEternalBlossoms New
-- Dungeon map minimap 
minimap[429] = { } -- The Temple of the Jade Serpent - Inside Dungeon Map
minimap[430] = { } -- The Temple of the Jade Serpent - Inside Dungeon Map
minimap[437] = { } -- Gate of the Setting Sun - Inside Dungeon Map
minimap[438] = { } -- Gate of the Setting Sun - Inside Dungeon Map
minimap[439] = { } -- Stormstout Brewery - Inside Dungeon Map
minimap[440] = { } -- Stormstout Brewery - Inside Dungeon Map
minimap[440] = { } -- Stormstout Brewery - Inside Dungeon Map
minimap[441] = { } -- Stormstout Brewery - Inside Dungeon Map
minimap[441] = { } -- Stormstout Brewery - Inside Dungeon Map
minimap[442] = { } -- Stormstout Brewery - Inside Dungeon Map
minimap[444] = { } -- Shado-Pan Monastery - Inside Dungeon Map
minimap[443] = { } -- Shado-Pan Monastery - Inside Dungeon Map
minimap[445] = { } -- Shado-Pan Monastery - Inside Dungeon Map
minimap[446] = { } -- Shado-Pan Monastery - Inside Dungeon Map
minimap[453] = { } -- Mogu'shan Palace - Inside Dungeon Map
minimap[454] = { } -- Mogu'shan Palace - Inside Dungeon Map
minimap[455] = { } -- Mogu'shan Palace - Inside Dungeon Map
minimap[456] = { } -- Terrace of Endless Spring
minimap[457] = { } -- Siege of Niuzao Temple - Inside Dungeon Map
minimap[458] = { } -- Siege of Niuzao Temple - Inside Dungeon Map
minimap[459] = { } -- Siege of Niuzao Temple - Inside Dungeon Map
minimap[471] = { } -- Mogu'shan Vaults - Inside Dungeon Map
minimap[472] = { } -- Mogu'shan Vaults - Inside Dungeon Map
minimap[473] = { } -- Mogu'shan Vaults - Inside Dungeon Map
minimap[474] = { } -- Heart of Fear - Inside Dungeon Map
minimap[475] = { } -- Heart of Fear - Inside Dungeon Map
minimap[508] = { } -- Throne of Thunder - Inside Dungeon Map
minimap[509] = { } -- Throne of Thunder - Inside Dungeon Map
minimap[509] = { } -- Throne of Thunder - Inside Dungeon Map
minimap[510] = { } -- Throne of Thunder - Inside Dungeon Map
minimap[511] = { } -- Throne of Thunder - Inside Dungeon Map
minimap[511] = { } -- Throne of Thunder - Inside Dungeon Map
minimap[512] = { } -- Throne of Thunder - Inside Dungeon Map
minimap[512] = { } -- Throne of Thunder - Inside Dungeon Map
minimap[513] = { } -- Throne of Thunder - Inside Dungeon Map
minimap[513] = { } -- Throne of Thunder - Inside Dungeon Map
minimap[514] = { } -- Throne of Thunder - Inside Dungeon Map
minimap[556] = { } -- Siege of Orgrimmar - Inside Dungeon Map
minimap[557] = { } -- Siege of Orgrimmar - Inside Dungeon Map
minimap[558] = { } -- Siege of Orgrimmar - Inside Dungeon Map
minimap[559] = { } -- Siege of Orgrimmar - Inside Dungeon Map
minimap[560] = { } -- Siege of Orgrimmar - Inside Dungeon Map
minimap[561] = { } -- Siege of Orgrimmar - Inside Dungeon Map
minimap[562] = { } -- Siege of Orgrimmar - Inside Dungeon Map
minimap[563] = { } -- Siege of Orgrimmar - Inside Dungeon Map
minimap[564] = { } -- Siege of Orgrimmar - Inside Dungeon Map
minimap[565] = { } -- Siege of Orgrimmar - Inside Dungeon Map
minimap[566] = { } -- Siege of Orgrimmar - Inside Dungeon Map
minimap[567] = { } -- Siege of Orgrimmar - Inside Dungeon Map

--############################
--#### Warlords of Draenor ###
--############################

-- Azeroth/Continent map minimap
minimap[463] = { } -- Echo Isles
minimap[525] = { } -- FrostfireRidge
minimap[526] = { } -- FrostfireRidge Speerspiesserfestung
minimap[527] = { } -- FrostfireRidge Speerspiesserfestung Speerspießerhof
minimap[534] = { } -- TanaanJungle
minimap[535] = { } -- Talador
minimap[539] = { } -- ShadowmoonValleyDR
minimap[542] = { } -- SpiresOfArak
minimap[543] = { } -- Gorgrond
minimap[550] = { } -- NagrandDraenor
minimap[572] = { } -- Draenor
minimap[582] = { } -- Moonrise
minimap[588] = { } -- Ashran
minimap[590] = { } -- Frostwall
minimap[622] = { } -- Stormshild
minimap[624] = { } -- Warspear
-- Dungeon map minimap 
minimap[573] = { } -- Bloodmaul Slag Mines
minimap[574] = { } -- Shadowmoon Burial Grounds - Inside Dungeon Map
minimap[575] = { } -- Shadowmoon Burial Grounds - Inside Dungeon Map
minimap[576] = { } -- Shadowmoon Burial Grounds - Inside Dungeon Map
minimap[593] = { } -- Auchindoun
minimap[595] = { } -- Iron Docks
minimap[596] = { } -- Blackrock Foundry - Inside Dungeon Map
minimap[597] = { } -- Blackrock Foundry - Inside Dungeon Map
minimap[598] = { } -- Blackrock Foundry - Inside Dungeon Map
minimap[599] = { } -- Blackrock Foundry - Inside Dungeon Map
minimap[600] = { } -- Blackrock Foundry - Inside Dungeon Map
minimap[601] = { } -- Skyreach - Inside Dungeon Map
minimap[602] = { } -- Skyreach - Inside Dungeon Map
minimap[606] = { } -- Grimrail Depot - Inside Dungeon Map
minimap[607] = { } -- Grimrail Depot - Inside Dungeon Map
minimap[608] = { } -- Grimrail Depot - Inside Dungeon Map
minimap[609] = { } -- Grimrail Depot - Inside Dungeon Map
minimap[610] = { } -- Highmaul - Inside Dungeon Map
minimap[611] = { } -- Highmaul - Inside Dungeon Map
minimap[612] = { } -- Highmaul - Inside Dungeon Map
minimap[613] = { } -- Highmaul - Inside Dungeon Map
minimap[614] = { } -- Highmaul - Inside Dungeon Map
minimap[615] = { } -- Highmaul - Inside Dungeon Map
minimap[620] = { } -- The Everbloom - Inside Dngeon Map
minimap[621] = { } -- The Everbloom - Inside Dngeon Map
minimap[661] = { } -- Hellfire Citadel - Inside Dungeon Map
minimap[662] = { } -- Hellfire Citadel - Inside Dungeon Map
minimap[663] = { } -- Hellfire Citadel - Inside Dungeon Map
minimap[664] = { } -- Hellfire Citadel - Inside Dungeon Map
minimap[665] = { } -- Hellfire Citadel - Inside Dungeon Map
minimap[666] = { } -- Hellfire Citadel - Inside Dungeon Map
minimap[667] = { } -- Hellfire Citadel - Inside Dungeon Map
minimap[668] = { } -- Hellfire Citadel - Inside Dungeon Map
minimap[669] = { } -- Hellfire Citadel - Inside Dungeon Map
minimap[670] = { } -- Hellfire Citadel - Inside Dungeon Map

--############################
--########## Legion ##########
--############################

-- Azeroth/Continent map minimap
minimap[619] = { } -- Broken Isles
minimap[627] = { } -- Dalaran
minimap[628] = { } -- Dalaran Shadowside
minimap[629] = { } -- Dalaran inner Circle
minimap[630] = { } -- Aszuna
minimap[634] = { } -- Stormheim
minimap[641] = { } -- Val'sharah
minimap[646] = { } -- Broken Shore
minimap[650] = { } -- Highmountain
minimap[652] = { } -- Highmountain Thundertotem Basement
minimap[680] = { } -- Suramar
minimap[750] = { } -- Highmountain Thundertotem
minimap[790] = { } -- Eye of Aszhara
minimap[830] = { } -- Krokuun
minimap[831] = { } -- Vindikaar upper deck
minimap[832] = { } -- Vindikaar lower deck
minimap[882] = { } -- Eredath
minimap[885] = { } -- Antoran Wastes
minimap[905] = { } -- Argus
minimap[941] = { } -- Krokuun, Vindikaar Lower Deck
-- Dungeon map minimap 
minimap[704] = { } -- Halls of Valor  
minimap[706] = { } -- Maw of Souls
minimap[710] = { } -- Vault of the Wardens
minimap[713] = { } -- Eye of Azshara
minimap[731] = { } -- Neltharion's Lair
minimap[732] = { } -- Assault on Violet Hold
minimap[733] = { } -- Darkheart Thicket
minimap[749] = { } -- The Arcway
minimap[751] = { } -- Black Rook Hold
minimap[761] = { } -- Court of Stars
minimap[764] = { } -- The Nighthold
minimap[765] = { } -- The Nighthold
minimap[777] = { } -- The Emerald Nightmare
minimap[807] = { } -- Trial of Valor
minimap[845] = { } -- Cathedral of Eternal Night
minimap[850] = { } -- Tomb of Sargeras
minimap[903] = { } -- Seat of the Triumvirate
minimap[909] = { } -- Antorus, the Burning Throne

--############################
--##### Battle of Azeroth ####
--############################

-- Azeroth/Continent map minimap
minimap[862] = { } -- Zuldazar
minimap[863] = { } -- Nazmir
minimap[864] = { } -- Vol'Dun
minimap[875] = { } -- Zandalar
minimap[876] = { } --Kul'Tiras
minimap[895] = { } -- Tiragarde Sound
minimap[896] = { } -- Drustvar
minimap[942] = { } -- Stormsong Valley
minimap[1161] = { } --  Boralus City
minimap[1163] = { } -- Inside Dazar'alor
minimap[1164] = { } -- Inside Dazar'alor second Floor
minimap[1165] = { } -- Dazar'alor
minimap[1169] = { } -- Tol Dagor
minimap[1355] = {} -- Nazjatar
minimap[1462] = {} -- Mechagon
minimap[1528] = {} -- Nazjatar - The Eternal Palace Entrance Map
-- Dungeon map minimap 
minimap[934] = { } -- Atal'Dazar
minimap[936] = { } -- Freehold
minimap[974] = { } -- Tol Dagor
minimap[1004] = { } -- Kings Rest
minimap[1010] = { } -- The Motherlode
minimap[1015] = { } -- Waycrest Manor
minimap[1038] = { } -- Temple of Sethraliss
minimap[1039] = { } -- Shrine of the Storm
minimap[1041] = { } -- The Underrot      
minimap[1148] = { } -- Uldir    
minimap[1162] = { } -- Siege of Boralus
minimap[1345] = { } -- Crucible of Storms
minimap[1358] = { } -- Battle of Dazar'alor
minimap[1490] = { } -- Operation: Mechagon
minimap[1512] = { } -- The Eternal Palace    

--############################
--####### Shadowlands ########
--############################

-- Azeroth/Continent map minimap
minimap[1525] = { } -- Revendreth
minimap[1533] = { } -- Bastion
minimap[1536] = { } -- Maldraxxus
minimap[1543] = { } -- The Maw
minimap[1550] = { } -- Shadowlands
minimap[1565] = { } -- Ardenweald
minimap[1670] = { } -- Oribos
minimap[1671] = { } -- Oribos Uppder Side
minimap[1911] = { } -- Torghast
minimap[1912] = { } -- Torghast Rune
minimap[1961] = { } -- Korthia
minimap[1970] = { } -- Zereth Mortis 
minimap[2016] = { } -- Tazavesh, the Veiled Market
-- Dungeon map minimap 
minimap[1663] = { } -- Halls of Atonement
minimap[1666] = { } -- The Necrotic Wake
minimap[1669] = { } -- Mists of Tirna Scithe
minimap[1674] = { } -- Plaguefall
minimap[1675] = { } -- Sanguine Depths
minimap[1680] = { } -- De Other Side
minimap[1683] = { } -- Theater of Pain
minimap[1692] = { } -- Spires of Ascension
minimap[1735] = { } -- Castle Nathria 
minimap[1989] = { } -- Tazavesh, the Veiled Market
minimap[1998] = { } -- Sanctum of Domination  
minimap[2047] = { } -- Sepulcher of the First Ones
minimap[2051] = { } -- Sepulcher of the First Ones

--############################
--####### Dragonflight #######
--############################

-- Azeroth/Continent map minimap
minimap[1978] = { } -- Dragon Isles
minimap[2022] = { } -- The Waking Shores
minimap[2023] = { } -- Ohn'ahran Plains
minimap[2024] = { } -- The Azure Span
minimap[2025] = { } -- Thaldraszus
minimap[2026] = { } -- The Forbidden Reach
minimap[2133] = { } -- Zaralek Cavern
minimap[2112] = { } -- Valdrakken
minimap[2151] = { } -- The Forbidden Isle
minimap[2200] = { } -- The Emerald Dream
minimap[2239] = { } -- Bel'ameth, Amirdrassil
minimap[2266] = { } -- The Timeways - Millenia's Threshold
-- Dungeon map minimap
minimap[2073] = { } -- The Azure Vault
minimap[2080] = { } -- Neltharus
minimap[2082] = { } -- Halls of Infusion  
minimap[2093] = { } -- The Nokhud Offensive
minimap[2095] = { } -- Ruby Life Pools 
minimap[2096] = { } -- Brackenhide Hollow
minimap[2097] = { } -- Algeth'ar Academy
minimap[2190] = { } -- Dawn of the Infinite
minimap[2119] = { } -- Vault of the Incarnates
minimap[2166] = { } -- Aberrus, the Shadowed Crucible
minimap[2232] = { } -- Amirdrassil - Inside Dungeon Map
minimap[2238] = { } -- Amirdrassil - Inside Dungeon Map

--###############################
--####### The War Withinn #######
--###############################

-- Azeroth/Continent map minimap
minimap[2339] = { } -- Dornogal
minimap[2248] = { } -- Isle of Dorn
minimap[2274] = { } -- Khaz Algar
minimap[2255] = { } -- Azj-Kahet
minimap[2256] = { } -- Azj-Kathet_Lower
minimap[2215] = { } -- Hallowfall
minimap[2213] = { } -- Nerub'ar
minimap[2216] = { } -- Nerub'ar_Lower
minimap[2214] = { } -- The Ringing Deeps
minimap[2367] = { } -- Chamber of Memory
minimap[2369] = { } -- Siren Isle
minimap[2322] = { } -- Hall of Awakening
minimap[2346] = { } -- Undermine
minimap[2371] = { } -- K'aresh
minimap[2472] = { } -- Tazavesh
-- Dungeon map nodes
minimap[2315] = { } -- The Rookery - Inside Dungeon Map
minimap[2335] = { } -- The Cinderbrew Meadery - Inside Dungeon Map
minimap[2359] = { } -- The Dawnbreaker - Inside Dungeon Map
minimap[2308] = { } -- Priory of the Sacred Flame - Inside Dungeon Map
minimap[2341] = { } -- The Stonevault - Inside Dungeon Map
minimap[2303] = { } -- Darkflame Cleft - Inside Dungeon Map
minimap[2357] = { } -- Ara-Kara, City of Echoes - Inside Dungeon Map
minimap[2343] = { } -- City of Threads - Inside Dungeon Map
minimap[2387] = { } -- Operation: Floodgate - Inside Dungeon Map
minimap[2292] = { } -- Nerub-ar Palace - Inside Dungeon Map
minimap[2449] = { } -- Eco-Dome Al'dani - Inside Dungeon Map
minimap[2460] = { } -- Manaforge Omega - Inside Dungeon Map
-- Delves map nodes
minimap[2259] = { } -- Tak-Rethan-Abyss - Inside Dungeon Map
minimap[2299] = { } -- The Underkeep - Inside Dungeon Map
minimap[2348] = { } -- Zekvir's Lair - Inside Dungeon Map
minimap[2347] = { } -- The Spiral Weave - Inside Dungeon Map
minimap[2312] = { } -- Mycomancer Cavern - Inside Dungeon Map
minimap[2310] = { } -- Skittering Breach - Inside Dungeon Map
minimap[2301] = { } -- The Sinkhole - Inside Dungeon Map
minimap[2277] = { } -- Nightfall Sanctum - Inside Dungeon Map
minimap[2251] = { } -- The Waterworks - Inside Dungeon Map
minimap[2302] = { } -- The Waterworks - Inside Dungeon Map
minimap[2269] = { } -- Earthcrawl Mines - Inside Dungeon Map
minimap[2249] = { } -- Fungal Folly - Inside Dungeon Map
minimap[2250] = { } -- Kriegval's Rest - Inside Dungeon Map
minimap[2396] = { } -- Rowdy Rifts - Inside Dungeon Map
minimap[2423] = { } -- Sidestreet Sluice - Inside Dungeon Map
minimap[2420] = { } -- Sidestreet Sluice - The Pits - Inside Dungeon Map
minimap[2452] = { } -- Archival Assault - Inside Dungeon Map
minimap[2484] = { } -- Voidscar Cavern - Inside Dungeon Map
end