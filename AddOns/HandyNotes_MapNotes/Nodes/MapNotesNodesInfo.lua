local ADDON_NAME, ns = ...

function ns.LoadMapNotesNodesInfo()
local nodes = ns.nodes

--################################
--####### Classic MoP Nodes ######
--################################

nodes[1467] = { } -- Outland
nodes[998] = { } -- Undercity

--############################
--####### Classic Nodes ######
--############################

--############################
--######### Kalimdor #########
--############################

-- Azeroth/Continent map nodes
nodes[1411]  = { } -- Durotar
nodes[1412]  = { } -- Mulgore
nodes[1413] = { } -- Barrens    
nodes[1414] = { } -- Kalimdor 
nodes[1438] = { } -- Teldrassil
nodes[1439] = { } -- Darkshore
nodes[1440] = { } -- Ashenvale  
nodes[1441] = { } -- Thousand Needles  
nodes[1442] = { } -- Stonetalon Mountains
nodes[1443] = { } -- Desolace      
nodes[1444] = { } -- Feralas
nodes[1445] = { } -- Dustwallow
nodes[1446] = { } -- Tanaris
nodes[1447] = { } -- Azshara
nodes[1448] = { } -- Felwood
nodes[1449] = { } -- Un'Goro Crater
nodes[1450] = { } -- Moonglade    
nodes[1451] = { } -- Silithus    
nodes[1452] = { } -- Winterspring
nodes[1454] = { } -- Orgrimmar 
nodes[1455] = { } -- Ironforge
nodes[1456] = { } -- Thunder Bluff
nodes[1457] = { } -- Darnassus
nodes[1950] = { } -- Blutmythosinsel

--############################
--###### Eastern Kingdom #####
--############################

-- Azeroth/Continent map nodes
nodes[217] = { } -- Ruins of Gilneas
nodes[1415] = { } -- Eastern Kingdoms
nodes[1416] = { } -- Alterac Valley 
nodes[1417] = { } -- Arathi Highlands
nodes[1418] = { } -- Badlands
nodes[1419] = { } -- Blasted Lands
nodes[1420] = { } -- Tirisfal   
nodes[1421] = { } -- Silverpine Forest
nodes[1422] = { } -- WesternPlaguelands 
nodes[1423] = { } -- EasternPlagueland
nodes[1424] = { } -- Hillsbrad Foothills
nodes[1425] = { } -- The Hinterlands
nodes[1426] = { } -- DunMorogh 
nodes[1427] = { } -- Searing Gorge
nodes[1428] = { } -- BurningSteppes    
nodes[1429] = { } -- Elwynn Forest
nodes[1430] = { } -- DeadwindPass   
nodes[1431] = { } -- Duskwood
nodes[1432] = { } -- Loch Modan
nodes[1433] = { } -- Redridge Mountains
nodes[1434] = { } -- Stranglethorn Vale
nodes[1435] = { } -- SwampOfSorrows
nodes[1436] = { } -- Westfall    
nodes[1437] = { } -- Wettlands
nodes[1453] = { } -- Stormwind City   
nodes[1458] = { } -- Undercity Old Version
nodes[1941] = { } -- Eversong Woods
nodes[1942] = { } -- Ghostlands
nodes[1943] = { } -- Azurmythosinsel
nodes[1947] = { } -- Exodar
nodes[1954] = { } -- Silvermoon City
nodes[1957] = { } -- Isle of Quel'Danas

--####################
--###### Outland #####
--####################

nodes[1944] = { } -- Hellfire
nodes[1945] = { } -- Outland
nodes[1946] = { } -- Zangarmarsh
nodes[1948] = { } -- ShadowmoonValley
nodes[1949] = { } -- BladesEdgeMountains
nodes[1951] = { } -- Nagrand
nodes[1952] = { } -- TerokkarForest
nodes[1953] = { } -- Netherstorm
nodes[1955] = { } -- Shattrath


--###########################
--####### Retail Nodes ######
--###########################

-- Azeroth/Continent map nodes
nodes[407] = { } -- Darkmoon
nodes[946] = { } -- Worldmap
nodes[947] = { } -- Azeroth
nodes[971] = { } -- Telogros Rift

--############################
--######### Kalimdor #########
--############################

-- Azeroth/Continent map nodes
nodes[1]  = { } -- Durotar
nodes[7]  = { } -- Mulgore
nodes[10] = { } -- Barrens    
nodes[11] = { } -- Wailing Caverns
nodes[12] = { } -- Kalimdor 
nodes[57] = { } -- Teldrassil
nodes[62] = { } -- Darkshore Vanilla
nodes[63] = { } -- Ashenvale  
nodes[64] = { } -- Thousand Needles  
nodes[65] = { } -- Stonetalon Mountains   
nodes[66] = { } -- Desolace    
nodes[67] = { } -- Maraudon Outside  
nodes[68] = { } -- Maraudon Foulspore Cavern    
nodes[69] = { } -- Feralas
nodes[70] = { } -- Dustwallow
nodes[71] = { } -- Tanaris
nodes[74] = { } -- Timeless Tunnel
nodes[75] = { } -- Caverns of Time lower half
nodes[76] = { } -- Azshara
nodes[77] = { } -- Felwood
nodes[78] = { } -- Un'Goro Crater
nodes[80] = { } -- Moonglade
nodes[81] = { } -- Silithus    
nodes[83] = { } -- Winterspring   
nodes[85] = { } -- Orgrimmar 
nodes[86] = { } -- Ragefire -- of Shadow
nodes[87] = { } -- Ironforge
nodes[88] = { } -- Thunder Bluff
nodes[89] = { } -- Teldrassil / Darnassus
nodes[97] = { } -- Azurmythosinsel
nodes[103] = { } -- Exodar
nodes[106] = { } -- Blutmythosinsel
nodes[199] = { } -- Southern Barrens  
nodes[327] = { } -- AhnQiraj The Fallen Kingdom 
nodes[460] = { } -- Shadowglen
nodes[461] = { } -- Valley of Trials
nodes[462] = { } -- Camp Narache
nodes[468] = { } -- Am'Mental
nodes[503] = { } -- Shlae'gararena
-- Dungeon map nodes
nodes[130] = { } -- The Culling of Stratholme
nodes[131] = { } -- Stratholme City
nodes[213] = { } -- Ragefire Chasm
nodes[219] = { } -- Zul'Farrak
nodes[221] = { } -- Blackfathom Deeps - The Pool of Ask'Ar
nodes[222] = { } -- Moonshrine Sanctum
nodes[223] = { } -- The Forgotten Pool
nodes[235] = { } -- Dire Maul Gordok Commons
nodes[236] = { } -- Dire Maul Capital Gardens
nodes[239] = { } -- Dire Maul Warpwood Quarter
nodes[240] = { } -- Dire Maul Warpwood Quarter 
nodes[247] = { } -- Ruins of Ahn'Qiraj
nodes[248] = { } -- Onyxia Lair
nodes[273] = { } -- The Black Morass
nodes[274] = { } -- Old Hillsbrad Foothills
nodes[277] = { } -- Lost City of the Tol'vir
nodes[279] = { } -- Wailing Caverns
nodes[280] = { } -- Maraudon Caverns of Maraudon - Purple Crystal 
nodes[281] = { } -- Caverns of Maraudon
nodes[297] = { } -- Halls of Orientation
nodes[299] = { } -- Die Vier Sitze
nodes[297] = { } -- Hall des Lichts
nodes[298] = { } -- Grab des Erdwüters
nodes[300] = { } -- Razorfen Downs
nodes[301] = { } -- Razorfen Kraul
nodes[320] = { } -- Temple of Ahn'Qiraj - Die Tempeltore
nodes[321] = { } -- Höhle von C'Thun
nodes[319] = { } -- Untergrund des Schwarmbaus
nodes[324] = { } -- The Stonecore
nodes[325] = { } -- The Vortex Pinnacle
nodes[328] = { } -- Throne of the Four Winds
nodes[367] = { } -- Firelands
nodes[369] = { } -- Sulfuron Keep
nodes[398] = { } -- Well of Eternity
nodes[399] = { } -- Hour of Twilight
nodes[400] = { } -- Wyrmrest Temple
nodes[401] = { } -- End Time 
nodes[402] = { } -- Azure Dragonshrine
nodes[403] = { } -- End Time - Ruby Dragonshrine
nodes[409] = { } -- Dragon Soul
nodes[410] = { } -- Maw of Go'rath
nodes[411] = { } -- Maw of Shu'ma
nodes[412] = { } -- Eye of Eternity
nodes[1580] = { } -- AhnQiraj The Fallen Kingdom 

--############################
--###### Eastern Kingdom #####
--############################

-- Azeroth/Continent map nodes
nodes[13] = { } -- Eastern Kingdoms   
nodes[14] = { } -- Arathi Highlands
nodes[15] = { } -- Badlands
nodes[16] = { } -- Badlands Uldaman Cave
nodes[17] = { } -- Blasted Lands
nodes[18] = { } -- Tirisfal   
nodes[19] = { } -- ScarletMonasteryEntrance 
nodes[21] = { } -- Silverpine Forest
nodes[22] = { } -- WesternPlaguelands 
nodes[23] = { } -- EasternPlagueland
nodes[25] = { } -- Hillsbrad Foothills
nodes[26] = { } -- The Hinterlands
nodes[27] = { } -- DunMorogh
nodes[28] = { } -- Coldridge
nodes[30] = { } -- New Tinker Town  
nodes[32] = { } -- Searing Gorge
nodes[33] = { } -- BlackrockMountain
nodes[34] = { } -- BlackrockMountain - Blackrock Caverns
nodes[35] = { } -- BlackrockMountain - Blackrock Depths
nodes[36] = { } -- BurningSteppes    
nodes[37] = { } -- Elwynn Forest
nodes[42] = { } -- DeadwindPass  
nodes[47] = { } -- Duskwood
nodes[48] = { } -- Loch Modan
nodes[49] = { } -- Redridge Mountains
nodes[50] = { } -- Jungle
nodes[51] = { } -- SwampOfSorrows
nodes[52] = { } -- Westfall    
nodes[55] = { } -- The Deadmines Caverns
nodes[56] = { } -- Wettlands
nodes[84] = { } -- Stormwind City   
nodes[90] = { } -- Undercity Old Version
nodes[94] = { } -- Eversong Woods
nodes[110] = { } -- Silvermoon City   
nodes[210] = { } -- Stranglethorn Vale
nodes[224] = { } -- The Cape of Stranglethorn
nodes[245] = { } -- Tol Barad Pensinsula
nodes[425] = { } -- Nordhain
nodes[427] = { } -- Coldridge Valley
nodes[465] = { } -- Deathknell
nodes[467] = { } -- Sunstrider Isle
nodes[469] = { } -- New Tinkertown 
nodes[499] = { } -- Trail - Bizmos Boxbar
nodes[500] = { } -- Bizmos Boxbar
nodes[2070] = { } -- New Tirisfal
-- Dungeon map nodes 
nodes[162] = { } -- Naxxramas - Inside Dungeon Map
nodes[163] = { } -- Naxxramas - Inside Dungeon Map
nodes[164] = { } -- Naxxramas - Inside Dungeon Map
nodes[165] = { } -- Naxxramas - Inside Dungeon Map
nodes[166] = { } -- Naxxramas - Inside Dungeon Map
nodes[167] = { } -- Naxxramas - Inside Dungeon Map
nodes[220] = { } -- Tempel of Atal'hakkar
nodes[225] = { } -- The Stockade  
nodes[226] = { } -- Gnomeregan - Inside Dungeon Map   
nodes[227] = { } -- Gnomeregan - Inside Dungeon Map
nodes[228] = { } -- Gnomeregan - Inside Dungeon Map
nodes[229] = { } -- Gnomeregan - Inside Dungeon Map
nodes[230] = { } -- Uldaman - Inside Dungeon Map
nodes[231] = { } -- Uldaman - Inside Dungeon Map
nodes[232] = { } -- Molten Core
nodes[242] = { } -- Blackwing Depths - Inside Dungeon Map
nodes[243] = { } -- Blackrock Depths - Inside Dungeon Map
nodes[1186] = { } -- Blackrock Depths - Inside Dungeon Map
nodes[250] = { } -- Lower Blackrock Spire - Inside Dungeon Map
nodes[251] = { } -- Lower Blackrock Spire - Inside Dungeon Map
nodes[252] = { } -- Lower Blackrock Spire - Inside Dungeon Map
nodes[253] = { } -- Lower Blackrock Spire - Inside Dungeon Map
nodes[254] = { } -- Lower Blackrock Spire - Inside Dungeon Map
nodes[255] = { } -- Lower Blackrock Spire - Inside Dungeon Map
nodes[282] = { } -- Baradin Hold
nodes[283] = { } -- Blackrock Caverns - Inside Dungeon Map      
nodes[284] = { } -- Blackrock Caverns - Inside Dungeon Map 
nodes[285] = { } -- Blackwing Descent - Inside Dungeon Map
nodes[286] = { } -- Blackwing Descent - Inside Dungeon Map
nodes[287] = { } -- Blackwing Lair - Inside Dungeon Map
nodes[288] = { } -- Blackwing Lair - Inside Dungeon Map
nodes[289] = { } -- Blackwing Lair - Inside Dungeon Map
nodes[290] = { } -- Blackwing Lair - Inside Dungeon Map
nodes[291] = { } -- Deadmines - Inside Dungeon Map
nodes[292] = { } -- Deadmines - Inside Dungeon Map
nodes[293] = { } -- Grim Batol
nodes[294] = { } -- Bastion of Twilight - Inside Dungeon Map
nodes[295] = { } -- Bastion of Twilight - Inside Dungeon Map
nodes[302] = { } -- Old Scarlet Monastery - Inside Dungeon Map - Graveyard
nodes[303] = { } -- Old Scarlet Monastery - Inside Dungeon Map - Library
nodes[304] = { } -- Old Scarlet Monastery - Inside Dungeon Map - Armory
nodes[305] = { } -- Old Scarlet Monastery - Inside Dungeon Map - Cathedral   
nodes[306] = { } -- Old Scholomance - Inside Dungeon Map - The Reliquary
nodes[307] = { } -- Old Scholomance - Inside Dungeon Map - Chamber of Summoning
nodes[308] = { } -- Old Scholomance - Inside Dungeon Map - The Upper Study
nodes[309] = { } -- Old Scholomance - Inside Dungeon Map - Headmaster's Study
nodes[310] = { } -- Shadowfang Keep - Inside Dungeon Map
nodes[311] = { } -- Shadowfang Keep - Inside Dungeon Map
nodes[316] = { } -- Shadowfang Keep - Inside Dungeon Map
nodes[312] = { } -- Shadowfang Keep - Inside Dungeon Map
nodes[313] = { } -- Shadowfang Keep - Inside Dungeon Map
nodes[314] = { } -- Shadowfang Keep - Inside Dungeon Map
nodes[315] = { } -- Shadowfang Keep - Inside Dungeon Map
nodes[317] = { } -- Stratholme - Main Gate
nodes[318] = { } -- Stratholme Service Entrance
nodes[322] = { } -- Throne of the Tides - Inside Dungeon Map  
nodes[323] = { } -- Throne of the Tides - Inside Dungeon Map   
nodes[333] = { } -- Zul'Aman
nodes[335] = { } -- Sunwell Plateau 
nodes[336] = { } -- Sunwell Plateau - Dungeon Map
nodes[337] = { } -- Zul'Gurub
nodes[348] = { } -- Magisters'Terrace - Dungeon Map
nodes[349] = { } -- Magisters'Terrace - Dungeon Map      
nodes[350] = { } -- Karazhan - Inside Dungeon Map
nodes[351] = { } -- Karazhan - Inside Dungeon Map
nodes[352] = { } -- Karazhan - Inside Dungeon Map
nodes[353] = { } -- Karazhan - Inside Dungeon Map
nodes[354] = { } -- Karazhan - Inside Dungeon Map
nodes[355] = { } -- Karazhan - Inside Dungeon Map
nodes[356] = { } -- Karazhan - Inside Dungeon Map
nodes[357] = { } -- Karazhan - Inside Dungeon Map
nodes[358] = { } -- Karazhan - Inside Dungeon Map
nodes[359] = { } -- Karazhan - Inside Dungeon Map
nodes[360] = { } -- Karazhan - Inside Dungeon Map
nodes[361] = { } -- Karazhan - Inside Dungeon Map
nodes[362] = { } -- Karazhan - Inside Dungeon Map
nodes[363] = { } -- Karazhan - Inside Dungeon Map
nodes[364] = { } -- Karazhan - Inside Dungeon Map
nodes[365] = { } -- Karazhan - Inside Dungeon Map
nodes[366] = { } -- Karazhan - Inside Dungeon Map
nodes[432] = { } -- Scarlet Halls
nodes[436] = { } -- Scarlet Monastery
nodes[431] = { } -- Scarlet Halls
nodes[435] = { } -- Scarlet Monastery
nodes[476] = { } -- Scholomance - Inside Dungeon Map    
nodes[477] = { } -- Scholomance - Inside Dungeon Map
nodes[478] = { } -- Scholomance - Inside Dungeon Map
nodes[479] = { } -- Scholomance - Inside Dungeon Map
nodes[616] = { } -- Upper Blackrock Spire - Inside Dungeon Map
nodes[617] = { } -- Upper Blackrock Spire - Inside Dungeon Map
nodes[617] = { } -- Upper Blackrock Spire - Inside Dungeon Map
nodes[618] = { } -- Upper Blackrock Spire - Inside Dungeon Map
nodes[809] = { } -- Return to Karazhan - Inside Dungeon Map
nodes[814] = { } -- Return to Karazhan - Inside Dungeon Map
nodes[2071] = { } -- Uldaman Legacy of Tyr

--############################
--######### Outland ##########
--############################

-- Azeroth/Continent map nodes
nodes[95] = { } -- Ghostlands    
nodes[100] = { } -- Hellfire 
nodes[101] = { } -- Outland
nodes[102] = { } -- Zangarmarsh   
nodes[104] = { } -- ShadowmoonValley  
nodes[105] = { } -- BladesEdgeMountains  
nodes[107] = { } -- Nagrand  
nodes[108] = { } -- TerokkarForest
nodes[109] = { } -- Netherstorm
nodes[111] = { } -- Shattrath
nodes[122] = { } -- Sunwel, Isle of Quel'Danas 
-- Dungeon map nodes 
nodes[246] = { } -- Shattered Halls
nodes[256] = { } -- Auchenai Crypts - Inside Dungeon Map
nodes[257] = { } -- Auchenai Crypts - Inside Dungeon Map
nodes[258] = { } -- Sethekk Halls - Inside Dungeon Map
nodes[259] = { } -- Sethekk Halls - Inside Dungeon Map
nodes[260] = { } -- Shadow Labyrinth
nodes[261] = { } -- Blood Furnace
nodes[262] = { } -- The Underbog
nodes[263] = { } -- Steamvault - Inside Dungeon Map
nodes[264] = { } -- Steamvault - Inside Dungeon Map
nodes[265] = { } -- Slave Pens
nodes[266] = { } -- Botanica
nodes[267] = { } -- Mechanar - Inside Dungeon Map
nodes[268] = { } -- Mechanar - Inside Dungeon Map
nodes[269] = { } -- Arcatraz - Inside Dungeon Map
nodes[270] = { } -- Arcatraz - Inside Dungeon Map
nodes[271] = { } -- Arcatraz - Inside Dungeon Map
nodes[272] = { } -- Mana Tombs
nodes[332] = { } -- Serpentshrine Cavern
nodes[330] = { } -- Gruul
nodes[331] = { } -- Magtheridons
nodes[334] = { } -- The Eye
nodes[339] = { } -- Black Temple
nodes[340] = { } -- Karabor Sewers
nodes[341] = { } -- Sanctuary of Shadows
nodes[342] = { } -- Halls of Anguish
nodes[343] = { } -- Gorefiend's Vigil
nodes[344] = { } -- Den of Mortal Delights
nodes[345] = { } -- Chamber of Command
nodes[346] = { } -- Temple Summit
nodes[347] = { } -- Hellfire Ramparts

--############################
--## Wrath of the Lich King ##
--############################

-- Azeroth/Continent map nodes
nodes[113] = { } -- Northrend
nodes[114] = { } -- Borean Tundra
nodes[115] = { } -- Dragonblight   
nodes[116] = { } -- Grizzly Hills
nodes[117] = { } -- HowlingFjord    
nodes[118] = { } -- IcecrownGlacier  
nodes[119] = { } -- Sholazar Basin
nodes[120] = { } -- The Storm Peaks
nodes[121] = { } -- Zul'Drak
nodes[123] = { } -- LakeWintergrasp  
nodes[125] = { } -- Dalaran City    
nodes[126] = { } -- Dalaran City Basement
nodes[127] = { } -- Crystalsong Forest 
nodes[170] = { } -- Hrothgar's Landing
-- Dungeon map nodes 
nodes[129] = { } -- The Nexus
nodes[132] = { } -- Ahn'kahet
nodes[133] = { } -- Utgarde Keep - Inside Dungeon Map
nodes[134] = { } -- Utgarde Keep - Inside Dungeon Map
nodes[135] = { } -- Utgarde Keep - Inside Dungeon Map
nodes[136] = { } -- Utgarde Pinnacle - Inside Dungeon Map
nodes[137] = { } -- Utgarde Pinnacle - Inside Dungeon Map
nodes[138] = { } -- Halls of Lightning - Inside Dungeon Map
nodes[139] = { } -- Halls of Lightning - Inside Dungeon Map
nodes[140] = { } -- Halls of Stone   
nodes[142] = { } -- The Oculus - Inside Dungeon Map
nodes[143] = { } -- The Oculus - Inside Dungeon Map
nodes[144] = { } -- The Oculus - Inside Dungeon Map
nodes[145] = { } -- The Oculus - Inside Dungeon Map
nodes[146] = { } -- The Oculus - Inside Dungeon Map
nodes[147] = { } -- Ulduar - Inside Dungeon Map
nodes[149] = { } -- Ulduar - Inside Dungeon Map
nodes[154] = { } -- Gundrak
nodes[155] = { } -- Sanctum of Obsidian
nodes[156] = { } -- Vault of Archavon
nodes[157] = { } -- Azjol Nerub - Inside Dungeon Map
nodes[158] = { } -- Azjol Nerub - Inside Dungeon Map
nodes[159] = { } -- Azjol Nerub - Inside Dungeon Map
nodes[160] = { } -- Drak'Tharon Keep - Inside Dungeon Map
nodes[161] = { } -- Drak'Tharon Keep - Inside Dungeon Map
nodes[166] = { } -- Naxxramas 
nodes[168] = { } -- Violet Keep
nodes[171] = { } -- Trial of the Champion
nodes[172] = { } -- Trial of the Crusader - Inside Dungeon Map
nodes[173] = { } -- Trial of the Crusader - Inside Dungeon Map
nodes[183] = { } -- the Soulforges
nodes[184] = { } -- Pit of Saron
nodes[185] = { } -- Halls of Reflection
nodes[186] = { } -- IcecrownGlacier - Inside Dungeon Map
nodes[187] = { } -- IcecrownGlacier - Inside Dungeon Map
nodes[188] = { } -- IcecrownGlacier - Inside Dungeon Map
nodes[190] = { } -- IcecrownGlacier - Inside Dungeon Map
nodes[191] = { } -- IcecrownGlacier - Inside Dungeon Map
nodes[189] = { } -- IcecrownGlacier - Inside Dungeon Map
nodes[192] = { } -- IcecrownGlacier - Inside Dungeon Map
nodes[200] = { } -- Sanctum of Ruby

--############################
--######### Catalysm #########
--############################

-- Azeroth/Continent map nodes
nodes[198] = { } -- Hyjal
nodes[201] = { } -- Tang'Thar Forest
nodes[203] = { } -- Vashjir
nodes[204] = { } -- VashjirDepths 
nodes[205] = { } -- Shimmering Expanse
nodes[207] = { } -- Deepholm
nodes[241] = { } -- TwilightHighlands   
nodes[244] = { } -- TolBarad    
nodes[249] = { } -- Uldum  
nodes[948] = { } -- The Maelstrom
nodes[1527] = { } -- Uldum

--############################
--##### Misk of Pandaria #####
--############################

-- Azeroth/Continent map nodes
nodes[371] = { } -- TheJadeForest
nodes[376] = { } -- ValleyoftheFourWinds  
nodes[378] = { } -- The Wandering Isle   
nodes[379] = { } -- KunLaiSummit  
nodes[388] = { } -- TownlongWastes    
nodes[390] = { } -- ValeofEternalBlossoms  
nodes[391] = { } -- Shrine of Two Moons first floor
nodes[392] = { } -- Shrine of Two Moons second floor
nodes[393] = { } -- Shrine of Seven Stars first floor
nodes[394] = { } -- Shrine of Seven Stars second floor
nodes[418] = { } -- Krasarang Wilds
nodes[422] = { } -- DreadWastes   
nodes[424] = { } -- Pandaria   
nodes[433] = { } -- The Veiles Stairs
nodes[434] = { } -- The Old Passage
nodes[504] = { } -- IsleoftheThunderKing
nodes[507] = { } -- Isle of Giants
nodes[554] = { } -- Timeless Isle
nodes[1530] = { } -- ValeofEternalBlossoms New
-- Dungeon map nodes 
nodes[429] = { } -- The Temple of the Jade Serpent - Inside Dungeon Map
nodes[430] = { } -- The Temple of the Jade Serpent - Inside Dungeon Map
nodes[437] = { } -- Gate of the Setting Sun - Inside Dungeon Map
nodes[438] = { } -- Gate of the Setting Sun - Inside Dungeon Map
nodes[439] = { } -- Stormstout Brewery - Inside Dungeon Map
nodes[440] = { } -- Stormstout Brewery - Inside Dungeon Map
nodes[440] = { } -- Stormstout Brewery - Inside Dungeon Map
nodes[441] = { } -- Stormstout Brewery - Inside Dungeon Map
nodes[441] = { } -- Stormstout Brewery - Inside Dungeon Map
nodes[442] = { } -- Stormstout Brewery - Inside Dungeon Map
nodes[444] = { } -- Shado-Pan Monastery - Inside Dungeon Map
nodes[443] = { } -- Shado-Pan Monastery - Inside Dungeon Map
nodes[445] = { } -- Shado-Pan Monastery - Inside Dungeon Map
nodes[446] = { } -- Shado-Pan Monastery - Inside Dungeon Map
nodes[453] = { } -- Mogu'shan Palace - Inside Dungeon Map
nodes[454] = { } -- Mogu'shan Palace - Inside Dungeon Map
nodes[455] = { } -- Mogu'shan Palace - Inside Dungeon Map
nodes[456] = { } -- Terrace of Endless Spring
nodes[457] = { } -- Siege of Niuzao Temple - Inside Dungeon Map
nodes[458] = { } -- Siege of Niuzao Temple - Inside Dungeon Map
nodes[459] = { } -- Siege of Niuzao Temple - Inside Dungeon Map
nodes[471] = { } -- Mogu'shan Vaults - Inside Dungeon Map
nodes[472] = { } -- Mogu'shan Vaults - Inside Dungeon Map
nodes[473] = { } -- Mogu'shan Vaults - Inside Dungeon Map
nodes[474] = { } -- Heart of Fear - Inside Dungeon Map
nodes[475] = { } -- Heart of Fear - Inside Dungeon Map
nodes[508] = { } -- Throne of Thunder - Inside Dungeon Map
nodes[509] = { } -- Throne of Thunder - Inside Dungeon Map
nodes[509] = { } -- Throne of Thunder - Inside Dungeon Map
nodes[510] = { } -- Throne of Thunder - Inside Dungeon Map
nodes[511] = { } -- Throne of Thunder - Inside Dungeon Map
nodes[511] = { } -- Throne of Thunder - Inside Dungeon Map
nodes[512] = { } -- Throne of Thunder - Inside Dungeon Map
nodes[512] = { } -- Throne of Thunder - Inside Dungeon Map
nodes[513] = { } -- Throne of Thunder - Inside Dungeon Map
nodes[513] = { } -- Throne of Thunder - Inside Dungeon Map
nodes[514] = { } -- Throne of Thunder - Inside Dungeon Map
nodes[556] = { } -- Siege of Orgrimmar - Inside Dungeon Map
nodes[557] = { } -- Siege of Orgrimmar - Inside Dungeon Map
nodes[558] = { } -- Siege of Orgrimmar - Inside Dungeon Map
nodes[559] = { } -- Siege of Orgrimmar - Inside Dungeon Map
nodes[560] = { } -- Siege of Orgrimmar - Inside Dungeon Map
nodes[561] = { } -- Siege of Orgrimmar - Inside Dungeon Map
nodes[562] = { } -- Siege of Orgrimmar - Inside Dungeon Map
nodes[563] = { } -- Siege of Orgrimmar - Inside Dungeon Map
nodes[564] = { } -- Siege of Orgrimmar - Inside Dungeon Map
nodes[565] = { } -- Siege of Orgrimmar - Inside Dungeon Map
nodes[566] = { } -- Siege of Orgrimmar - Inside Dungeon Map
nodes[567] = { } -- Siege of Orgrimmar - Inside Dungeon Map

--############################
--#### Warlords of Draenor ###
--############################

-- Azeroth/Continent map nodes
nodes[463] = { } -- Echo Isles
nodes[525] = { } -- FrostfireRidge
nodes[526] = { } -- FrostfireRidge Speerspiesserfestung
nodes[527] = { } -- FrostfireRidge Speerspiesserfestung Speerspießerhof
nodes[534] = { } -- TanaanJungle
nodes[535] = { } -- Talador
nodes[539] = { } -- ShadowmoonValleyDR
nodes[542] = { } -- SpiresOfArak
nodes[543] = { } -- Gorgrond
nodes[550] = { } -- NagrandDraenor
nodes[572] = { } -- Draenor
nodes[582] = { } -- Moonrise
nodes[588] = { } -- Ashran
nodes[590] = { } -- Frostwall
nodes[622] = { } -- Stormshild
nodes[624] = { } -- Warspear
-- Dungeon map nodes 
nodes[573] = { } -- Bloodmaul Slag Mines
nodes[574] = { } -- Shadowmoon Burial Grounds - Inside Dungeon Map
nodes[575] = { } -- Shadowmoon Burial Grounds - Inside Dungeon Map
nodes[576] = { } -- Shadowmoon Burial Grounds - Inside Dungeon Map
nodes[593] = { } -- Auchindoun
nodes[595] = { } -- Iron Docks
nodes[596] = { } -- Blackrock Foundry - Inside Dungeon Map
nodes[597] = { } -- Blackrock Foundry - Inside Dungeon Map
nodes[598] = { } -- Blackrock Foundry - Inside Dungeon Map
nodes[599] = { } -- Blackrock Foundry - Inside Dungeon Map
nodes[600] = { } -- Blackrock Foundry - Inside Dungeon Map
nodes[601] = { } -- Skyreach - Inside Dungeon Map
nodes[602] = { } -- Skyreach - Inside Dungeon Map
nodes[606] = { } -- Grimrail Depot - Inside Dungeon Map
nodes[607] = { } -- Grimrail Depot - Inside Dungeon Map
nodes[608] = { } -- Grimrail Depot - Inside Dungeon Map
nodes[609] = { } -- Grimrail Depot - Inside Dungeon Map
nodes[610] = { } -- Highmaul - Inside Dungeon Map
nodes[611] = { } -- Highmaul - Inside Dungeon Map
nodes[612] = { } -- Highmaul - Inside Dungeon Map
nodes[613] = { } -- Highmaul - Inside Dungeon Map
nodes[614] = { } -- Highmaul - Inside Dungeon Map
nodes[615] = { } -- Highmaul - Inside Dungeon Map
nodes[620] = { } -- The Everbloom - Inside Dngeon Map
nodes[621] = { } -- The Everbloom - Inside Dngeon Map
nodes[661] = { } -- Hellfire Citadel - Inside Dungeon Map
nodes[662] = { } -- Hellfire Citadel - Inside Dungeon Map
nodes[663] = { } -- Hellfire Citadel - Inside Dungeon Map
nodes[664] = { } -- Hellfire Citadel - Inside Dungeon Map
nodes[665] = { } -- Hellfire Citadel - Inside Dungeon Map
nodes[666] = { } -- Hellfire Citadel - Inside Dungeon Map
nodes[667] = { } -- Hellfire Citadel - Inside Dungeon Map
nodes[668] = { } -- Hellfire Citadel - Inside Dungeon Map
nodes[669] = { } -- Hellfire Citadel - Inside Dungeon Map
nodes[670] = { } -- Hellfire Citadel - Inside Dungeon Map

--############################
--########## Legion ##########
--############################

-- Azeroth/Continent map nodes
nodes[619] = { } -- Broken Isles
nodes[627] = { } -- Dalaran
nodes[628] = { } -- Dalaran Shadowside
nodes[629] = { } -- Dalaran inner Circle
nodes[630] = { } -- Aszuna
nodes[634] = { } -- Stormheim
nodes[641] = { } -- Val'sharah
nodes[646] = { } -- Broken Shore
nodes[650] = { } -- Highmountain
nodes[652] = { } -- Highmountain Thundertotem Basement
nodes[680] = { } -- Suramar
nodes[750] = { } -- Highmountain Thundertotem
nodes[790] = { } -- Eye of Aszhara
nodes[830] = { } -- Krokuun
nodes[831] = { } -- Vindikaar upper deck
nodes[832] = { } -- Vindikaar lower deck
nodes[882] = { } -- Eredath
nodes[885] = { } -- Antoran Wastes
nodes[905] = { } -- Argus
nodes[941] = { } -- Krokuun, Vindikaar Lower Deck
-- Dungeon map nodes 
nodes[704] = { } -- Halls of Valor  
nodes[706] = { } -- Maw of Souls
nodes[710] = { } -- Vault of the Wardens
nodes[713] = { } -- Eye of Azshara
nodes[731] = { } -- Neltharion's Lair
nodes[732] = { } -- Assault on Violet Hold
nodes[733] = { } -- Darkheart Thicket
nodes[749] = { } -- The Arcway
nodes[751] = { } -- Black Rook Hold
nodes[761] = { } -- Court of Stars
nodes[764] = { } -- The Nighthold
nodes[765] = { } -- The Nighthold
nodes[777] = { } -- The Emerald Nightmare
nodes[807] = { } -- Trial of Valor
nodes[845] = { } -- Cathedral of Eternal Night
nodes[850] = { } -- Tomb of Sargeras
nodes[903] = { } -- Seat of the Triumvirate
nodes[909] = { } -- Antorus, the Burning Throne

--############################
--##### Battle of Azeroth ####
--############################

-- Azeroth/Continent map nodes
nodes[862] = { } -- Zuldazar
nodes[863] = { } -- Nazmir
nodes[864] = { } -- Vol'Dun
nodes[875] = { } -- Zandalar
nodes[876] = { } --Kul'Tiras
nodes[895] = { } -- Tiragarde Sound
nodes[896] = { } -- Drustvar
nodes[942] = { } -- Stormsong Valley
nodes[1161] = { } -- Boralus City
nodes[1163] = { } -- Inside Dazar'alor
nodes[1164] = { } -- Inside Dazar'alor second Floor
nodes[1165] = { } -- Dazar'alor
nodes[1169] = { } -- Tol Dagor
nodes[1355] = {} -- Nazjatar
nodes[1462] = {} -- Mechagon
nodes[1528] = {} -- Nazjatar - The Eternal Palace Entrance Map
-- Dungeon map nodes 
nodes[934] = { } -- Atal'Dazar
nodes[936] = { } -- Freehold
nodes[974] = { } -- Tol Dagor
nodes[1004] = { } -- Kings Rest
nodes[1010] = { } -- The Motherlode
nodes[1015] = { } -- Waycrest Manor
nodes[1038] = { } -- Temple of Sethraliss
nodes[1039] = { } -- Shrine of the Storm
nodes[1041] = { } -- The Underrot      
nodes[1148] = { } -- Uldir    
nodes[1162] = { } -- Siege of Boralus
nodes[1345] = { } -- Crucible of Storms
nodes[1358] = { } -- Battle of Dazar'alor
nodes[1490] = { } -- Operation: Mechagon
nodes[1512] = { } -- The Eternal Palace    

--############################
--####### Shadowlands ########
--############################

-- Azeroth/Continent map nodes
nodes[1525] = { } -- Revendreth
nodes[1533] = { } -- Bastion
nodes[1536] = { } -- Maldraxxus
nodes[1543] = { } -- The Maw
nodes[1550] = { } -- Shadowlands
nodes[1565] = { } -- Ardenweald
nodes[1670] = { } -- Oribos
nodes[1671] = { } -- Oribos Uppder Side
nodes[1911] = { } -- Torghast
nodes[1912] = { } -- Torghast Rune
nodes[1961] = { } -- Korthia
nodes[1970] = { } -- Zereth Mortis 
nodes[2016] = { } -- Tazavesh, the Veiled Market
-- Dungeon map nodes 
nodes[1663] = { } -- Halls of Atonement
nodes[1666] = { } -- The Necrotic Wake
nodes[1669] = { } -- Mists of Tirna Scithe
nodes[1674] = { } -- Plaguefall
nodes[1675] = { } -- Sanguine Depths
nodes[1680] = { } -- De Other Side
nodes[1683] = { } -- Theater of Pain
nodes[1692] = { } -- Spires of Ascension
nodes[1735] = { } -- Castle Nathria 
nodes[1989] = { } -- Tazavesh, the Veiled Market
nodes[1998] = { } -- Sanctum of Domination  
nodes[2047] = { } -- Sepulcher of the First Ones
nodes[2051] = { } -- Sepulcher of the First Ones

--############################
--####### Dragonflight #######
--############################

-- Azeroth/Continent map nodes
nodes[1978] = { } -- Dragon Isles
nodes[2022] = { } -- The Waking Shores
nodes[2023] = { } -- Ohn'ahran Plains
nodes[2024] = { } -- The Azure Span
nodes[2025] = { } -- Thaldraszus
nodes[2026] = { } -- The Forbidden Reach
nodes[2133] = { } -- Zaralek Cavern
nodes[2112] = { } -- Valdrakken
nodes[2151] = { } -- The Forbidden Isle
nodes[2200] = { } -- The Emerald Dream
nodes[2239] = { } -- Bel'ameth, Amirdrassil
nodes[2266] = { } -- The Timeways - Millenia's Threshold
-- Dungeon map nodes
nodes[2073] = { } -- The Azure Vault
nodes[2080] = { } -- Neltharus
nodes[2082] = { } -- Halls of Infusion  
nodes[2093] = { } -- The Nokhud Offensive
nodes[2095] = { } -- Ruby Life Pools 
nodes[2096] = { } -- Brackenhide Hollow
nodes[2097] = { } -- Algeth'ar Academy
nodes[2190] = { } -- Dawn of the Infinite
nodes[2119] = { } -- Vault of the Incarnates
nodes[2166] = { } -- Aberrus, the Shadowed Crucible
nodes[2232] = { } -- Amirdrassil - Inside Dungeon Map
nodes[2238] = { } -- Amirdrassil - Inside Dungeon Map

--###############################
--####### The War Withinn #######
--###############################

-- Azeroth/Continent map nodes
nodes[2339] = { } -- Dornogal
nodes[2248] = { } -- Isle of Dorn
nodes[2274] = { } -- Khaz Algar
nodes[2255] = { } -- Azj-Kahet
nodes[2256] = { } -- Azj-Kathet_Lower
nodes[2215] = { } -- Hallowfall
nodes[2213] = { } -- Nerub'ar
nodes[2216] = { } -- Nerub'ar_Lower
nodes[2214] = { } -- The Ringing Deeps
nodes[2367] = { } -- Chamber of Memory
nodes[2369] = { } -- Siren Isle
nodes[2322] = { } -- Hall of Awakening
nodes[2346] = { } -- Undermine
nodes[2371] = { } -- K'aresh
nodes[2472] = { } -- Tazavesh
-- Dungeon map nodes
nodes[2315] = { } -- The Rookery - Inside Dungeon Map
nodes[2335] = { } -- The Cinderbrew Meadery - Inside Dungeon Map
nodes[2359] = { } -- The Dawnbreaker - Inside Dungeon Map
nodes[2308] = { } -- Priory of the Sacred Flame - Inside Dungeon Map
nodes[2341] = { } -- The Stonevault - Inside Dungeon Map
nodes[2303] = { } -- Darkflame Cleft - Inside Dungeon Map
nodes[2357] = { } -- Ara-Kara, City of Echoes - Inside Dungeon Map
nodes[2343] = { } -- City of Threads - Inside Dungeon Map
nodes[2387] = { } -- Operation: Floodgate - Inside Dungeon Map
nodes[2292] = { } -- Nerub-ar Palace - Inside Dungeon Map
nodes[2449] = { } -- Eco-Dome Al'dani - Inside Dungeon Map
nodes[2460] = { } -- Manaforge Omega - Inside Dungeon Map
-- Delves map nodes
nodes[2259] = { } -- Tak-Rethan-Abyss - Inside Dungeon Map
nodes[2299] = { } -- The Underkeep - Inside Dungeon Map
nodes[2348] = { } -- Zekvir's Lair - Inside Dungeon Map
nodes[2347] = { } -- The Spiral Weave - Inside Dungeon Map
nodes[2312] = { } -- Mycomancer Cavern - Inside Dungeon Map
nodes[2310] = { } -- Skittering Breach - Inside Dungeon Map
nodes[2301] = { } -- The Sinkhole - Inside Dungeon Map
nodes[2277] = { } -- Nightfall Sanctum - Inside Dungeon Map
nodes[2251] = { } -- The Waterworks - Inside Dungeon Map
nodes[2302] = { } -- The Waterworks - Inside Dungeon Map
nodes[2269] = { } -- Earthcrawl Mines - Inside Dungeon Map
nodes[2249] = { } -- Fungal Folly - Inside Dungeon Map
nodes[2250] = { } -- Kriegval's Rest - Inside Dungeon Map
nodes[2396] = { } -- Rowdy Rifts - Inside Dungeon Map
nodes[2423] = { } -- Sidestreet Sluice - Inside Dungeon Map
nodes[2420] = { } -- Sidestreet Sluice - The Pits - Inside Dungeon Map
nodes[2452] = { } -- Archival Assault - Inside Dungeon Map
nodes[2484] = { } -- Voidscar Cavern - Inside Dungeon Map
end