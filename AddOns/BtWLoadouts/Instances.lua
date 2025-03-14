--[[
    Instance handling code

    Dungeon Difficulty ids:
        1:  Normal
        2:  Heroic
        23: Mythic
        8:  Mythic Keystone

    Raid Difficulty ids:
        17: Flex LFR
        14: Flex Normal
        15: Flex Heroic
        16: Mythic
]]

local _,Internal = ...
local L = Internal.L or {}

local format = string.format
local select = select
local pairs = pairs
local GetAffixInfo = C_ChallengeMode.GetAffixInfo
local GetInstanceInfo = GetInstanceInfo
local GetAreaInfo = C_Map.GetAreaInfo
local IsEncounterComplete = C_EncounterJournal.IsEncounterComplete

local dungeonDifficultiesAll = {1,2,23};
local raidDifficultiesAll = {17,14,15,16};
local instanceDifficulties = {
    -- Classic
    [  48] = { 1}, -- Blackfathom Deeps
    [ 230] = { 1, 19}, -- Blackrock Depths
    [ 229] = { 1}, -- Lower Blackrock Spire
    [ 429] = { 1}, -- Dire Maul
    [  90] = { 1}, -- Gnomeregan
    [ 349] = { 1}, -- Maraudon
    [ 389] = { 1}, -- Ragefire Chasm
    [ 129] = { 1}, -- Razorfen Downs
    [  47] = { 1}, -- Razorfen Kraul
    [ 329] = { 1}, -- Stratholme
    [ 109] = { 1}, -- The Temple of Atal'hakkar
    [  34] = { 1}, -- The Stockade
    [  70] = { 1}, -- Uldaman
    [  43] = { 1}, -- Wailing Caverns
    [ 209] = { 1}, -- Zul'Farrak
    [ 409] = { 9, 18}, -- Molten Core
    [ 469] = { 9, 18}, -- Blackwing Lair
    [ 509] = { 3}, -- Ruins of Ahn'Qiraj
    [ 531] = { 9, 18}, -- Temple of Ahn'Qiraj
    [2792] = {14, 15, 17}, -- Blackrock Depths

    -- The Burning Crusade
    [ 558] = { 1,  2}, -- Auchenai Crypts
    [ 543] = { 1,  2}, -- Hellfire Ramparts
    [ 585] = { 1,  2}, -- Magisters' Terrace
    [ 557] = { 1,  2}, -- Mana-Tombs
    [ 560] = { 1,  2}, -- Old Hillsbrad Foothills
    [ 556] = { 1,  2}, -- Sethekk Halls
    [ 555] = { 1,  2}, -- Shadow Labyrinth
    [ 552] = { 1,  2}, -- The Arcatraz
    [ 269] = { 1,  2}, -- The Black Morass
    [ 542] = { 1,  2}, -- The Blood Furnace
    [ 553] = { 1,  2}, -- The Botanica
    [ 554] = { 1,  2}, -- The Mechanar
    [ 540] = { 1,  2}, -- The Shattered Halls
    [ 547] = { 1,  2, 19}, -- The Slave Pens
    [ 545] = { 1,  2}, -- The Steamvault
    [ 546] = { 1,  2}, -- The Underbog
    [ 532] = { 3}, -- Karazhan
    [ 565] = { 4}, -- Gruul's Lair
    [ 544] = { 4}, -- Magtheridon's Lair
    [ 548] = { 4}, -- Serpentshrine Cavern
    [ 550] = { 4}, -- The Eye
    [ 534] = { 4}, -- The Battle for Mount Hyjal
    [ 564] = {14, 33}, -- Black Temple
    [ 580] = { 4}, -- Sunwell Plateau

    -- Wrath of the Lich King
    [ 619] = { 1,  2}, -- Ahn'kahet: The Old Kingdom
    [ 601] = { 1,  2}, -- Azjol-Nerub
    [ 600] = { 1,  2}, -- Drak'Tharon Keep
    [ 604] = { 1,  2}, -- Gundrak
    [ 602] = { 1,  2}, -- Halls of Lightning
    [ 668] = { 1,  2}, -- Halls of Reflection
    [ 599] = { 1,  2}, -- Halls of Stone
    [ 658] = { 1,  2}, -- Pit of Saron
    [ 595] = { 1,  2}, -- The Culling of Stratholme
    [ 632] = { 1,  2}, -- The Forge of Souls
    [ 576] = { 1,  2}, -- The Nexus
    [ 578] = { 1,  2}, -- The Oculus
    [ 608] = { 1,  2}, -- The Violet Hold
    [ 650] = { 1,  2}, -- Trial of the Champion
    [ 574] = { 1,  2}, -- Utgarde Keep
    [ 575] = { 1,  2}, -- Utgarde Pinnacle
    [ 624] = { 3,  4}, -- Vault of Archavon
    [ 533] = { 3,  4}, -- Naxxramas
    [ 615] = { 3,  4}, -- The Obsidian Sanctum
    [ 616] = { 3,  4}, -- The Eye of Eternity
    [ 649] = { 3,  4,  5,  6}, -- Trial of the Crusader
    [ 631] = { 3,  4,  5,  6}, -- Icecrown Citadel
    [ 603] = {14, 33}, -- Ulduar
    [ 249] = { 3,  4}, -- Onyxia's Lair
    [ 724] = { 3,  4,  5,  6}, -- The Ruby Sanctum

    -- Cataclysm
    [ 645] = { 1,  2}, -- Blackrock Caverns
    [  36] = { 1,  2}, -- Deadmines
    [ 644] = { 1,  2}, -- Halls of Origination
    [ 755] = { 1,  2}, -- Lost City of the Tol'vir
    [  33] = { 1,  2, 19}, -- Shadowfang Keep
    [ 725] = { 1,  2}, -- The Stonecore
    [ 657] = { 1,  2}, -- The Vortex Pinnacle
    [ 643] = { 1,  2}, -- Throne of the Tides
    [ 568] = { 1,  2}, -- Zul'Aman
    [ 859] = { 1,  2}, -- Zul'Gurub
    [ 670] = { 1,  2}, -- Grim Batol
    [ 938] = { 2}, -- End Time
    [ 939] = { 2}, -- Well of Eternity
    [ 940] = { 2}, -- Hour of Twilight
    [ 671] = { 3,  4,  5,  6}, -- The Bastion of Twilight
    [ 669] = { 3,  4,  5,  6}, -- Blackwing Descent
    [ 967] = { 3,  4,  5,  6,  7}, -- Dragon Soul
    [ 720] = {14, 15, 33}, -- Firelands
    [ 754] = { 3,  4,  5,  6}, -- Throne of the Four Winds

    -- Mists of Pandaria
    [ 961] = { 1,  2}, -- Stormstout Brewery
    [ 960] = { 1,  2}, -- Temple of the Jade Serpent
    [ 994] = { 1,  2}, -- Mogu'shan Palace
    [ 962] = { 1,  2}, -- Gate of the Setting Sun
    [1011] = { 1,  2}, -- Siege of Niuzao Temple
    [ 959] = { 1,  2}, -- Shado-Pan Monastery
    [1007] = { 1,  2}, -- Scholomance
    [1001] = { 1,  2}, -- Scarlet Halls
    [1004] = { 1,  2}, -- Scarlet Monastery
    [1008] = { 3,  4,  5,  6,  7}, -- Mogu'shan Vaults
    [1009] = { 3,  4,  5,  6,  7}, -- Heart of Fear
    [ 996] = { 3,  4,  5,  6,  7}, -- Terrace of Endless Spring
    [1098] = { 3,  4,  5,  6,  7}, -- Throne of Thunder
    [1136] = raidDifficultiesAll, -- Siege of Orgrimmar

    -- Warlords of Draenor
    [1175] = dungeonDifficultiesAll, -- Bloodmaul Slag Mines
    [1209] = dungeonDifficultiesAll, -- Skyreach
    [1208] = dungeonDifficultiesAll, -- Grimrail Depot
    [1176] = dungeonDifficultiesAll, -- Shadowmoon Burial Grounds
    [1182] = dungeonDifficultiesAll, -- Auchindoun
    [1279] = dungeonDifficultiesAll, -- The Everbloom
    [1358] = { 1,  2,  8, 19, 23}, -- Upper Blackrock Spire
    [1195] = dungeonDifficultiesAll, -- Iron Docks
    [1205] = raidDifficultiesAll, -- Blackrock Foundry
    [1228] = raidDifficultiesAll, -- Highmaul
    [1448] = raidDifficultiesAll, -- Hellfire Citadel

    -- Legion
    [1493] = dungeonDifficultiesAll, -- Vault of the Wardens
    [1456] = dungeonDifficultiesAll, -- Eye of Azshara
    [1477] = dungeonDifficultiesAll, -- Halls of Valor
    [1492] = dungeonDifficultiesAll, -- Maw of Souls
    [1516] = { 2, 23}, -- The Arcway
    [1501] = dungeonDifficultiesAll, -- Black Rook Hold
    [1466] = dungeonDifficultiesAll, -- Darkheart Thicket
    [1458] = dungeonDifficultiesAll, -- Neltharion's Lair
    [1544] = { 1,  2, 23}, -- Assault on Violet Hold
    [1571] = { 2, 23}, -- Court of Stars
    [1651] = { 2, 23}, -- Return to Karazhan
    [1677] = { 2, 23}, -- Cathedral of Eternal Night
    [1753] = { 2, 23}, -- Seat of the Triumvirate
    [1520] = raidDifficultiesAll, -- The Emerald Nightmare
    [1530] = raidDifficultiesAll, -- The Nighthold
    [1648] = raidDifficultiesAll, -- Trial of Valor
    [1676] = raidDifficultiesAll, -- Tomb of Sargeras
    [1712] = raidDifficultiesAll, -- Antorus, the Burning Throne

    -- Battle for Azeroth
    [1763] = dungeonDifficultiesAll, -- Atal'Dazar
    [1754] = dungeonDifficultiesAll, -- Freehold
    [1594] = dungeonDifficultiesAll, -- The MOTHERLODE!!
    [1771] = dungeonDifficultiesAll, -- Tol Dagor
    [1862] = dungeonDifficultiesAll, -- Waycrest Manor
    [1841] = dungeonDifficultiesAll, -- The Underrot
    [1822] = { 2, 23}, -- Siege of Boralus
    [1877] = dungeonDifficultiesAll, -- Temple of Sethraliss
    [1864] = dungeonDifficultiesAll, -- Shrine of the Storm
    [1762] = { 2, 23}, -- Kings' Rest
    [2097] = { 2, 23}, -- Operation: Mechagon
    [1861] = raidDifficultiesAll, -- Uldir
    [2070] = raidDifficultiesAll, -- Battle of Dazar'alor
    [2096] = raidDifficultiesAll, -- Crucible of Storms
    [2164] = raidDifficultiesAll, -- The Eternal Palace
    [2217] = raidDifficultiesAll, -- Ny'alotha, the Waking City

    -- Shadowlands
    [2286] = dungeonDifficultiesAll, -- The Necrotic Wake
    [2289] = dungeonDifficultiesAll, -- Plaguefall
    [2290] = dungeonDifficultiesAll, -- Mists of Tirna Scithe
    [2287] = dungeonDifficultiesAll, -- Halls of Atonement
    [2285] = dungeonDifficultiesAll, -- Spires of Ascension
    [2293] = dungeonDifficultiesAll, -- Theater of Pain
    [2291] = dungeonDifficultiesAll, -- De Other Side
    [2284] = dungeonDifficultiesAll, -- Sanguine Depths
    [2441] = { 2, 23}, -- Tazavesh, the Veiled Market
    [2296] = raidDifficultiesAll, -- Castle Nathria
    [2450] = raidDifficultiesAll, -- Sanctum of Domination
    [2481] = raidDifficultiesAll, -- Sepulcher of the First Ones

    -- Dragonflight
    [2520] = { 205, 1,  2, 23 }, -- Brackenhide Hollow
    [2451] = { 205, 1,  2, 23 }, -- Uldaman: Legacy of Tyr
    [2516] = { 205, 1,  2, 23 }, -- The Nokhud Offensive
    [2519] = { 205, 1,  2, 23 }, -- Neltharus
    [2526] = { 205, 1,  2, 23 }, -- Algeth'ar Academy
    [2515] = { 205, 1,  2, 23 }, -- The Azure Vault
    [2521] = { 205, 1,  2, 23 }, -- Ruby Life Pools
    [2527] = { 205, 1,  2, 23 }, -- Halls of Infusion
    [2579] = { 2, 23}, -- Dawn of the Infinite
    [2522] = raidDifficultiesAll, -- Vault of the Incarnates
    [2569] = raidDifficultiesAll, -- Aberrus, the Shadowed Crucible
    [2549] = raidDifficultiesAll, -- Amirdrassil, the Dream's Hope

    -- The War Within
    [2651] = { 205, 1,  2, 23 }, -- Darkflame Cleft
    [2648] = { 205, 1,  2, 23, 216 }, -- The Rookery
    [2649] = { 205, 1,  2, 23, 216 }, -- Priory of the Sacred Flame
    [2662] = { 205, 1,  2, 23 }, -- The Dawnbreaker
    [2660] = { 205, 1,  2, 23 }, -- Ara-Kara, City of Echoes
    [2661] = { 205, 1,  2, 23 }, -- Cinderbrew Meadery
    [2652] = { 205, 1,  2, 23 }, -- The Stonevault
    [2669] = { 205, 1,  2, 23 }, -- City of Threads
    [2773] = { 205, 1,  2, 23 }, -- Operation: Floodgate
    [2657] = { 220, 17, 14, 15, 16 }, -- Nerub-ar Palace
    [2769] = { 14, 15, 16, 17, 220 }, -- Liberation of Undermine
}
if Internal.IsDragonflightSeason1 then
    instanceDifficulties[2515] = { 1, 2, 23, 8 } -- The Azure Vault
    instanceDifficulties[2516] = { 1, 2, 23, 8 } -- The Nokhud Offensive
    instanceDifficulties[2521] = { 1, 2, 23, 8 } -- Ruby Life Pools
    instanceDifficulties[2526] = { 1, 2, 23, 8 } -- Algeth'ar Academy
    instanceDifficulties[ 960] = { 8 } -- Temple of the Jade Serpent
    instanceDifficulties[1176] = { 8 } -- Shadowmoon Burial Grounds
    instanceDifficulties[1477] = { 8 } -- Halls of Valor
    instanceDifficulties[1571] = { 8 } -- Court of Stars
elseif Internal.IsDragonflightSeason2 then
    instanceDifficulties[2515] = { 1, 2, 23, 8 } -- The Azure Vault
    instanceDifficulties[2516] = { 1, 2, 23, 8 } -- The Nokhud Offensive
    instanceDifficulties[2521] = { 1, 2, 23, 8 } -- Ruby Life Pools
    instanceDifficulties[2526] = { 1, 2, 23, 8 } -- Algeth'ar Academy
    instanceDifficulties[ 657] = { 8 } -- The Vortex Pinnacle
    instanceDifficulties[1458] = { 8 } -- Neltharion's Lair
    instanceDifficulties[1754] = { 8 } -- Freehold
    instanceDifficulties[1841] = { 8 } -- The Underrot
elseif Internal.IsDragonflightSeason3 then
    instanceDifficulties[ 643] = { 8 } -- Throne of the Tides
    instanceDifficulties[1279] = { 8 } -- The Everbloom
    instanceDifficulties[1466] = { 8 } -- Darkheart Thicket
    instanceDifficulties[1501] = { 8 } -- Black Rook Hold
    instanceDifficulties[1763] = { 8 } -- Atal'Dazar
    instanceDifficulties[1862] = { 8 } -- Waycrest Manor
    instanceDifficulties[2579] = { 2, 23,  8} -- Dawn of the Infinites
elseif Internal.IsDragonflightSeason4 then
    instanceDifficulties[2519] = { 1, 2, 23, 8 } -- Neltharus
    instanceDifficulties[2520] = { 1, 2, 23, 8 } -- Brackenhide Hollow
    instanceDifficulties[2527] = { 1, 2, 23, 8 } -- Halls of Infusion
    instanceDifficulties[2451] = { 1, 2, 23, 8 } -- Uldaman: Legacy of Tyr

    instanceDifficulties[2515] = { 1, 2, 23, 8 } -- The Azure Vault
    instanceDifficulties[2516] = { 1, 2, 23, 8 } -- The Nokhud Offensive
    instanceDifficulties[2521] = { 1, 2, 23, 8 } -- Ruby Life Pools
    instanceDifficulties[2526] = { 1, 2, 23, 8 } -- Algeth'ar Academy
elseif Internal.IsTheWarWithinSeason1 then
    instanceDifficulties[2660] = { 205, 1, 2, 23, 8 } -- Ara-Kara, City of Echoes
    instanceDifficulties[2669] = { 205, 1, 2, 23, 8 } -- City of Threads
    instanceDifficulties[2652] = { 205, 1, 2, 23, 8 } -- The Stonevault
    instanceDifficulties[2662] = { 205, 1, 2, 23, 8 } -- The Dawnbreaker

    instanceDifficulties[2290] = { 8 } -- Mists of Tirna Scithe
    instanceDifficulties[2286] = { 8 } -- The Necrotic Wake
    instanceDifficulties[1822] = { 8 } -- Siege of Boralus
    instanceDifficulties[ 670] = { 8 } -- Grim Batol
elseif Internal.IsTheWarWithinSeason2 then
    instanceDifficulties[2661] = { 205, 1, 2, 23, 8 } -- Cinderbrew Meadery
    instanceDifficulties[2651] = { 205, 1, 2, 23, 8 } -- Darkflame Cleft
    instanceDifficulties[2649] = { 205, 1, 2, 23, 8, 216 } -- Priory of the Sacred Flame
    instanceDifficulties[2648] = { 205, 1, 2, 23, 8, 216 } -- The Rookery

    instanceDifficulties[2773] = { 205, 1, 2, 23, 8 } -- Operation: Floodgate

    instanceDifficulties[2293] = { 8 } -- Theater of Pain
    instanceDifficulties[2097] = { 8 } -- Operation: Mechagon
    instanceDifficulties[1594] = { 8 } -- The MOTHERLODE!!
end
Internal.dungeonDifficultiesAll = { 205, 1, 2, 23, 8 };
Internal.raidDifficultiesAll = { 220, 17, 14, 15, 16 };
local dungeonInfo = {
    {
        name = L["Classic"],
        instances = {
              48, -- Blackfathom Deeps
             230, -- Blackrock Depths
             229, -- Lower Blackrock Spire
             429, -- Dire Maul
              90, -- Gnomeregan
             349, -- Maraudon
             389, -- Ragefire Chasm
             129, -- Razorfen Downs
              47, -- Razorfen Kraul
             329, -- Stratholme
             109, -- The Temple of Atal'hakkar
              34, -- The Stockade
              70, -- Uldaman
              43, -- Wailing Caverns
             209, -- Zul'Farrak
            1001, -- Scarlet Halls
            1004, -- Scarlet Monastery
            1007, -- Scholomance
              36, -- Deadmines
              33, -- Shadowfang Keep
        }
    },
    {
        name = L["The Burning Crusade"],
        instances = {
             558, -- Auchenai Crypts
             543, -- Hellfire Ramparts
             585, -- Magisters' Terrace
             557, -- Mana-Tombs
             560, -- Old Hillsbrad Foothills
             556, -- Sethekk Halls
             555, -- Shadow Labyrinth
             552, -- The Arcatraz
             269, -- The Black Morass
             542, -- The Blood Furnace
             553, -- The Botanica
             554, -- The Mechanar
             540, -- The Shattered Halls
             547, -- The Slave Pens
             545, -- The Steamvault
             546, -- The Underbog
        }
    },
    {
        name = L["Wrath of the Lich King"],
        instances = {
             619, -- Ahn'kahet: The Old Kingdom
             601, -- Azjol-Nerub
             600, -- Drak'Tharon Keep
             604, -- Gundrak
             602, -- Halls of Lightning
             668, -- Halls of Reflection
             599, -- Halls of Stone
             658, -- Pit of Saron
             595, -- The Culling of Stratholme
             632, -- The Forge of Souls
             576, -- The Nexus
             578, -- The Oculus
             608, -- The Violet Hold
             650, -- Trial of the Champion
             574, -- Utgarde Keep
             575, -- Utgarde Pinnacle
        }
    },
    {
        name = L["Cataclysm"],
        instances = {
             645, -- Blackrock Caverns
              36, -- Deadmines
             644, -- Halls of Origination
             755, -- Lost City of the Tol'vir
              33, -- Shadowfang Keep
             725, -- The Stonecore
             657, -- The Vortex Pinnacle
             643, -- Throne of the Tides
             568, -- Zul'Aman
             859, -- Zul'Gurub
             670, -- Grim Batol
             938, -- End Time
             939, -- Well of Eternity
             940, -- Hour of Twilight
        }
    },
    {
        name = L["Mists of Pandaria"],
        instances = {
             961, -- Stormstout Brewery
             960, -- Temple of the Jade Serpent
             994, -- Mogu'shan Palace
             962, -- Gate of the Setting Sun
            1011, -- Siege of Niuzao Temple
             959, -- Shado-Pan Monastery
            1007, -- Scholomance
            1001, -- Scarlet Halls
            1004, -- Scarlet Monastery
        }
    },
    {
        name = L["Warlords of Draenor"],
        instances = {
            1175, -- Bloodmaul Slag Mines
            1209, -- Skyreach
            1208, -- Grimrail Depot
            1176, -- Shadowmoon Burial Grounds
            1182, -- Auchindoun
            1279, -- The Everbloom
            1358, -- Upper Blackrock Spire
            1195, -- Iron Docks
        }
    },
    {
        name = L["Legion"],
        instances = {
            1493, -- Vault of the Wardens
            1456, -- Eye of Azshara
            1477, -- Halls of Valor
            1492, -- Maw of Souls
            1516, -- The Arcway
            1501, -- Black Rook Hold
            1466, -- Darkheart Thicket
            1458, -- Neltharion's Lair
            1544, -- Assault on Violet Hold
            1571, -- Court of Stars
            1651, -- Return to Karazhan
            1677, -- Cathedral of Eternal Night
            1753, -- Seat of the Triumvirate
        }
    },
    {
        name = L["Battle for Azeroth"],
        instances = {
            1763, -- Atal'Dazar
            1754, -- Freehold
            1594, -- The MOTHERLODE!!
            1771, -- Tol Dagor
            1862, -- Waycrest Manor
            1841, -- The Underrot
            1822, -- Siege of Boralus
            1877, -- Temple of Sethraliss
            1864, -- Shrine of the Storm
            1762, -- Kings' Rest
            2097, -- Operation: Mechagon
        }
    },
    {
        name = L["Shadowlands"],
        instances = {
            2286, -- The Necrotic Wake
            2289, -- Plaguefall
            2290, -- Mists of Tirna Scithe
            2287, -- Halls of Atonement
            2285, -- Spires of Ascension
            2293, -- Theater of Pain
            2291, -- De Other Side
            2284, -- Sanguine Depths
            2441, -- Tazavesh, the Veiled Market
        }
    },
    {
        name = L["Dragonflight"],
        instances = {
            2520, -- Brackenhide Hollow
            2451, -- Uldaman: Legacy of Tyr
            2516, -- The Nokhud Offensive
            2519, -- Neltharus
            2526, -- Algeth'ar Academy
            2515, -- The Azure Vault
            2521, -- Ruby Life Pools
            2527, -- Halls of Infusion
            2579, -- Dawn of the Infinite
        }
    },
    {
        name = L["The War Within"],
        instances = {
            2651, -- Darkflame Cleft
            2648, -- The Rookery
            2649, -- Priory of the Sacred Flame
            2662, -- The Dawnbreaker
            2660, -- Ara-Kara, City of Echoes
            2661, -- Cinderbrew Meadery
            2652, -- The Stonevault
            2669, -- City of Threads
            2773, -- Operation: Floodgate
        }
    },
}
if Internal.IsDragonflightSeason1 then
    local instances = dungeonInfo[10].instances;
    instances[#instances+1] = 960 -- Temple of the Jade Serpent
    instances[#instances+1] = 1176 -- Shadowmoon Burial Grounds
    instances[#instances+1] = 1477 -- Halls of Valor
    instances[#instances+1] = 1571 -- Court of Stars
elseif Internal.IsDragonflightSeason2 then
    local instances = dungeonInfo[10].instances;
    instances[#instances+1] = 657 -- The Vortex Pinnaclee Serpent
    instances[#instances+1] = 1458 -- Neltharion's Lairl Grounds
    instances[#instances+1] = 1754 -- Freehold
    instances[#instances+1] = 1841 -- The Underrot
elseif Internal.IsDragonflightSeason3 then
    local instances = dungeonInfo[10].instances;
    instances[#instances+1] = 643 -- Throne of the Tides
    instances[#instances+1] = 1279 -- The Everbloom
    instances[#instances+1] = 1466 -- Darkheart Thicket
    instances[#instances+1] = 1501 -- Black Rook Hold
    instances[#instances+1] = 1763 -- Atal'Dazar
    instances[#instances+1] = 1862 -- Waycrest Manor
elseif Internal.IsTheWarWithinSeason1 then
    local instances = dungeonInfo[11].instances;
    instances[#instances+1] = 2290 -- Mists of Tirna Scithe
    instances[#instances+1] = 2286 -- The Necrotic Wake
    instances[#instances+1] = 1822 -- Siege of Boralus
    instances[#instances+1] =  670 -- Grim Batol
elseif Internal.IsTheWarWithinSeason2 then
    local instances = dungeonInfo[11].instances;
    instances[#instances+1] = 2293 -- Theater of Pain
    instances[#instances+1] = 2097 -- Operation: Mechagon
    instances[#instances+1] = 1594 -- The MOTHERLODE!!
end
local raidInfo = {
    {
        name = L["Classic"],
        instances = {
             409, -- Molten Core
             469, -- Blackwing Lair
             509, -- Ruins of Ahn'Qiraj
             531, -- Temple of Ahn'Qiraj
            2792, -- Blackrock Depths
        }
    },
    {
        name = L["The Burning Crusade"],
        instances = {
             532, -- Karazhan
             565, -- Gruul's Lair
             544, -- Magtheridon's Lair
             548, -- Serpentshrine Cavern
             550, -- The Eye
             534, -- The Battle for Mount Hyjal
             564, -- Black Temple
             580, -- Sunwell Plateau
        }
    },
    {
        name = L["Wrath of the Lich King"],
        instances = {
             624, -- Vault of Archavon
             533, -- Naxxramas
             615, -- The Obsidian Sanctum
             616, -- The Eye of Eternity
             649, -- Trial of the Crusader
             631, -- Icecrown Citadel
             603, -- Ulduar
             249, -- Onyxia's Lair
             724, -- The Ruby Sanctum
        }
    },
    {
        name = L["Cataclysm"],
        instances = {
             671, -- The Bastion of Twilight
             669, -- Blackwing Descent
             967, -- Dragon Soul
             720, -- Firelands
             754, -- Throne of the Four Winds
        }
    },
    {
        name = L["Mists of Pandaria"],
        instances = {
            1008, -- Mogu'shan Vaults
            1009, -- Heart of Fear
             996, -- Terrace of Endless Spring
            1098, -- Throne of Thunder
            1136, -- Siege of Orgrimmar
        }
    },
    {
        name = L["Warlords of Draenor"],
        instances = {
            1205, -- Blackrock Foundry
            1228, -- Highmaul
            1228, -- Draenor
            1448, -- Hellfire Citadel
        }
    },
    {
        name = L["Legion"],
        instances = {
            1520, -- The Emerald Nightmare
            1530, -- The Nighthold
            1648, -- Trial of Valor
            1676, -- Tomb of Sargeras
            1712, -- Antorus, the Burning Throne
        }
    },
    {
        name = L["Battle for Azeroth"],
        instances = {
            1861, -- Uldir
            2070, -- Battle of Dazar'alor
            2096, -- Crucible of Storms
            2164, -- The Eternal Palace
            2217, -- Ny'alotha, the Waking City
        }
    },
    {
        name = L["Shadowlands"],
        instances = {
            2296, -- Castle Nathria
            2450, -- Sanctum of Domination
            2481, -- Sepulcher of the First Ones
        }
    },
    {
        name = L["Dragonflight"],
        instances = {
            2522, -- Vault of the Incarnates
            2569, -- Aberrus, the Shadowed Crucible
            2549, -- Amirdrassil, the Dream's Hope
        }
    },
    {
        name = L["The War Within"],
        instances = {
            2657, -- Nerub-ar Palace
            2769, -- Liberation of Undermine
        }
    },
}
local scenarioInfo = {
	{
		name = L["Classic"],
		instances = {
		},
	},
	{
		name = L["TBC"],
		instances = {
		},
	},
	{
		name = L["Wrath"],
		instances = {
		},
	},
	{
		name = L["Cata"],
		instances = {
		},
	},
	{
		name = L["Panda"],
		instances = {
		},
	},
	{
		name = L["WoD"],
		instances = {
		},
	},
	{
		name = L["Legion"],
		instances = {
		},
	},
	{
		name = L["Battle for Azeroth"],
		instances = {
			{nil, 38, (function () return string.format("%s %s", GetDifficultyInfo(38), L["Island Expedition"]) end)()}, -- Normal Island
			{nil, 39, (function () return string.format("%s %s", GetDifficultyInfo(39), L["Island Expedition"]) end)()}, -- Heroic Island
			{nil, 40, (function () return string.format("%s %s", GetDifficultyInfo(40), L["Island Expedition"]) end)()}, -- Mythic Island
			{nil, 45, (function () return string.format("%s %s", GetDifficultyInfo(45), L["Island Expedition"]) end)()}, -- PvP Island

			{nil, 147, (function () return string.format("%s %s", GetDifficultyInfo(147), L["Warfront"]) end)()}, -- Normal Warfront
			{nil, 149, (function () return string.format("%s %s", GetDifficultyInfo(149), L["Warfront"]) end)()}, -- Heroic Warfront

			{nil, 152, (function () return GetDifficultyInfo(152) end)()}, -- Vision of N'Zoth
			{nil, 153, (function () return GetDifficultyInfo(153) end)()}, -- Teeming Island
		},
	},
	{
		name = L["Shadowlands"],
		instances = {
			{nil, 167, (function () return GetDifficultyInfo(167) end)()}, -- Torghast
		},
	},
	{
		name = L["Dragonflight"],
		instances = {
		},
	},
	{
		name = L["The War Within"],
		instances = {
			{nil, 208, (function () return GetDifficultyInfo(208) end)()}, -- Delves
		},
	}
};
local battlegroundInfo = {
	{
		name = L["Classic"],
		instances = {
		},
	},
	{
		name = L["TBC"],
		instances = {
		},
	},
	{
		name = L["Wrath"],
		instances = {
		},
	},
	{
		name = L["Cata"],
		instances = {
		},
	},
	{
		name = L["Panda"],
		instances = {
		},
	},
	{
		name = L["WoD"],
		instances = {
		},
	},
	{
		name = L["Legion"],
		instances = {
		},
	},
	{
		name = L["Battle for Azeroth"],
		instances = {
		},
	},
	{
		name = L["Shadowlands"],
		instances = {
			2106, -- Warsong Gulch
			2107, -- Arathi Basin
			30,   -- Alterac Valley
			566,  -- Eye of the Storm
            968,  -- Rated Eye of the Storm
			628,  -- Isle of Conquest
			761,  -- The Battle for Gilneas
			2118, -- Battle for Wintergrasp
			1191, -- Ashran
			726,  -- Twin Peaks
			727,  -- Silvershard Mines
			998,  -- Temple of Kotmogu
			1803, -- Seething Shore
			2245, -- Deepwind Gorge
		},
	},
	{
		name = L["Dragonflight"],
		instances = {
			2106, -- Warsong Gulch
			2107, -- Arathi Basin
			30,   -- Alterac Valley
			566,  -- Eye of the Storm
            968,  -- Rated Eye of the Storm
			628,  -- Isle of Conquest
			761,  -- The Battle for Gilneas
			2118, -- Battle for Wintergrasp
			1191, -- Ashran
			726,  -- Twin Peaks
			727,  -- Silvershard Mines
			998,  -- Temple of Kotmogu
			1803, -- Seething Shore
			2245, -- Deepwind Gorge
		},
	},
	{
		name = L["The War Within"],
		instances = {
			2106, -- Warsong Gulch
			2107, -- Arathi Basin
			30,   -- Alterac Valley
			566,  -- Eye of the Storm
            968,  -- Rated Eye of the Storm
			628,  -- Isle of Conquest
			761,  -- The Battle for Gilneas
			2118, -- Battle for Wintergrasp
			1191, -- Ashran
			726,  -- Twin Peaks
			727,  -- Silvershard Mines
			998,  -- Temple of Kotmogu
			1803, -- Seething Shore
			2245, -- Deepwind Gorge
		},
	}
};
-- List of bosses within an instance
-- InstanceID to JournalInstanceID[]
local instanceBosses = {
    -- Classic
    [  48] = { -- Blackfathom Deeps
         368, -- Ghamoo-Ra
         436, -- Domina
         426, -- Subjugator Kor'ul
        1145, -- Thruk
         447, -- Guardian of the Deep
        1144, -- Executioner Gore
         437, -- Twilight Lord Bathiel
         444, -- Aku'mai
    },
    [ 230] = { -- Blackrock Depths
         369, -- High Interrogator Gerstahn
         370, -- Lord Roccor
         371, -- Houndmaster Grebmar
         372, -- Ring of Law
         373, -- Pyromancer Loregrain
         374, -- Lord Incendius
         375, -- Warder Stilgiss
         376, -- Fineous Darkvire
         377, -- Bael'Gar
         378, -- General Angerforge
         379, -- Golem Lord Argelmach
         380, -- Hurley Blackbreath
         381, -- Phalanx
         383, -- Plugger Spazzring
         384, -- Ambassador Flamelash
         385, -- The Seven
         386, -- Magmus
         387, -- Emperor Dagran Thaurissan
    },
    [ 229] = { -- Lower Blackrock Spire
         388, -- Highlord Omokk
         389, -- Shadow Hunter Vosh'gajin
         390, -- War Master Voone
         391, -- Mother Smolderweb
         392, -- Urok Doomhowl
         393, -- Quartermaster Zigris
         394, -- Halycon
         395, -- Gizrul the Slavener
         396, -- Overlord Wyrmthalak
    },
    [ 429] = { -- Dire Maul
         402, -- Zevrim Thornhoof
         403, -- Hydrospawn
         404, -- Lethtendris
         405, -- Alzzin the Wildshaper
         406, -- Tendris Warpwood
         407, -- Illyanna Ravenoak
         408, -- Magister Kalendris
         409, -- Immol'thar
         410, -- Prince Tortheldrin
         411, -- Guard Mol'dar
         412, -- Stomper Kreeg
         413, -- Guard Fengus
         414, -- Guard Slip'kik
         415, -- Captain Kromcrush
         416, -- Cho'Rush the Observer
         417, -- King Gordok
    },
    [  90] = { -- Gnomeregan
         419, -- Grubbis
         420, -- Viscous Fallout
         421, -- Electrocutioner 6000
         418, -- Crowd Pummeler 9-60
         422, -- Mekgineer Thermaplugg
    },
    [ 349] = { -- Maraudon
         423, -- Noxxion
         424, -- Razorlash
         425, -- Tinkerer Gizlock
         427, -- Lord Vyletongue
         428, -- Celebras the Cursed
         429, -- Landslide
         430, -- Rotgrip
         431, -- Princess Theradras
    },
    [ 389] = { -- Ragefire Chasm
         694, -- Adarogg
         695, -- Dark Shaman Koranthal
         696, -- Slagmaw
         697, -- Lava Guard Gordoth
    },
    [ 129] = { -- Razorfen Downs
        1142, -- Aarux
         433, -- Mordresh Fire Eye
        1143, -- Mushlump
        1146, -- Death Speaker Blackthorn
        1141, -- Amnennar the Coldbringer
    },
    [  47] = { -- Razorfen Kraul
         896, -- Hunter Bonetusk
         895, -- Roogug
         899, -- Warlord Ramtusk
         900, -- Groyat, the Blind Hunter
         901, -- Charlga Razorflank
    },
    [ 329] = { -- Stratholme
         443, -- Hearthsinger Forresten
         445, -- Timmy the Cruel
         749, -- Commander Malor
         446, -- Willey Hopebreaker
         448, -- Instructor Galford
         449, -- Balnazzar
         450, -- The Unforgiven
         451, -- Baroness Anastari
         452, -- Nerub'enkan
         453, -- Maleki the Pallid
         454, -- Magistrate Barthilas
         455, -- Ramstein the Gorger
         456, -- Lord Aurius Rivendare
    },
    [ 109] = { -- The Temple of Atal'hakkar
         457, -- Avatar of Hakkar
         458, -- Jammal'an the Prophet
         459, -- Wardens of the Dream
         463, -- Shade of Eranikus
    },
    [  34] = { -- The Stockade
         464, -- Hogger
         465, -- Lord Overheat
         466, -- Randolph Moloch
    },
    [  70] = { -- Uldaman
         467, -- Revelosh
         468, -- The Lost Dwarves
         469, -- Ironaya
         748, -- Obsidian Sentinel
         470, -- Ancient Stone Keeper
         471, -- Galgann Firehammer
         472, -- Grimlok
         473, -- Archaedas
    },
    [  43] = { -- Wailing Caverns
         474, -- Lady Anacondra
         476, -- Lord Pythas
         475, -- Lord Cobrahn
         477, -- Kresh
         478, -- Skum
         479, -- Lord Serpentis
         480, -- Verdan the Everliving
         481, -- Mutanus the Devourer
    },
    [ 209] = { -- Zul'Farrak
         483, -- Gahz'rilla
         484, -- Antu'sul
         485, -- Theka the Martyr
         486, -- Witch Doctor Zum'rah
         487, -- Nekrum & Sezz'ziz
         489, -- Chief Ukorz Sandscalp
    },
    [1001] = { -- Scarlet Halls
         660, -- Houndmaster Braun
         656, -- Flameweaver Koegler
         654, -- Armsmaster Harlan
    },
    [1004] = { -- Scarlet Monastery
         688, -- Thalnos the Soulrender
         671, -- Brother Korloff
         674, -- High Inquisitor Whitemane
    },
    [1007] = { -- Scholomance
         659, -- Instructor Chillheart
         663, -- Jandice Barov
         665, -- Rattlegore
         666, -- Lilian Voss
         684, -- Darkmaster Gandling
    },
    [  36] = { -- Deadmines
          89, -- Glubtok
          90, -- Helix Gearbreaker
          91, -- Foe Reaper 5000
          92, -- Admiral Ripsnarl
          93, -- "Captain" Cookie
          95, -- Vanessa VanCleef
    },
    [  33] = { -- Shadowfang Keep
          96, -- Baron Ashbury
          97, -- Baron Silverlaine
          98, -- Commander Springvale
          99, -- Lord Walden
         100, -- Lord Godfrey
    },
    [ 409] = { -- Molten Core
        1519, -- Lucifron
        1520, -- Magmadar
        1521, -- Gehennas
        1522, -- Garr
        1523, -- Shazzrah
        1524, -- Baron Geddon
        1525, -- Sulfuron Harbinger
        1526, -- Golemagg the Incinerator
        1527, -- Majordomo Executus
        1528, -- Ragnaros
    },
    [ 469] = { -- Blackwing Lair
        1529, -- Razorgore the Untamed
        1530, -- Vaelastrasz the Corrupt
        1531, -- Broodlord Lashlayer
        1532, -- Firemaw
        1533, -- Ebonroc
        1534, -- Flamegor
        1535, -- Chromaggus
        1536, -- Nefarian
    },
    [ 509] = { -- Ruins of Ahn'Qiraj
        1537, -- Kurinnaxx
        1538, -- General Rajaxx
        1539, -- Moam
        1540, -- Buru the Gorger
        1541, -- Ayamiss the Hunter
        1542, -- Ossirian the Unscarred
    },
    [ 531] = { -- Temple of Ahn'Qiraj
        1543, -- The Prophet Skeram
        1547, -- Silithid Royalty
        1544, -- Battleguard Sartura
        1545, -- Fankriss the Unyielding
        1548, -- Viscidus
        1546, -- Princess Huhuran
        1549, -- The Twin Emperors
        1550, -- Ouro
        1551, -- C'Thun
    },
    [2792] = { -- Blackrock Depths
        2663, -- Lord Roccor
        2664, -- Bael'Gar
        2665, -- Lord Incendius
        2666, -- Golem Lord Argelmach
        2667, -- The Seven
        2668, -- General Angerforge
        2669, -- Ambassador Flamelash
        2670, -- Emperor Dagran Thaurissan
    },

    -- The Burning Crusade
    [ 558] = { -- Auchenai Crypts
         523, -- Shirrak the Dead Watcher
         524, -- Exarch Maladaar
    },
    [ 543] = { -- Hellfire Ramparts
         527, -- Watchkeeper Gargolmar
         528, -- Omor the Unscarred
         529, -- Vazruden the Herald
    },
    [ 585] = { -- Magisters' Terrace
         530, -- Selin Fireheart
         531, -- Vexallus
         532, -- Priestess Delrissa
         533, -- Kael'thas Sunstrider
    },
    [ 557] = { -- Mana-Tombs
         534, -- Pandemonius
         535, -- Tavarok
         536, -- Yor
         537, -- Nexus-Prince Shaffar
    },
    [ 560] = { -- Old Hillsbrad Foothills
         538, -- Lieutenant Drake
         539, -- Captain Skarloc
         540, -- Epoch Hunter
    },
    [ 556] = { -- Sethekk Halls
         541, -- Darkweaver Syth
         542, -- Anzu
         543, -- Talon King Ikiss
    },
    [ 555] = { -- Shadow Labyrinth
         544, -- Ambassador Hellmaw
         545, -- Blackheart the Inciter
         546, -- Grandmaster Vorpil
         547, -- Murmur
    },
    [ 552] = { -- The Arcatraz
         548, -- Zereketh the Unbound
         549, -- Dalliah the Doomsayer
         550, -- Wrath-Scryer Soccothrates
         551, -- Harbinger Skyriss
    },
    [ 269] = { -- The Black Morass
         552, -- Chrono Lord Deja
         553, -- Temporus
         554, -- Aeonus
    },
    [ 542] = { -- The Blood Furnace
         555, -- The Maker
         556, -- Broggok
         557, -- Keli'dan the Breaker
    },
    [ 553] = { -- The Botanica
         558, -- Commander Sarannis
         559, -- High Botanist Freywinn
         560, -- Thorngrin the Tender
         561, -- Laj
         562, -- Warp Splinter
    },
    [ 554] = { -- The Mechanar
         563, -- Mechano-Lord Capacitus
         564, -- Nethermancer Sepethrea
         565, -- Pathaleon the Calculator
    },
    [ 540] = { -- The Shattered Halls
         566, -- Grand Warlock Nethekurse
         728, -- Blood Guard Porung
         568, -- Warbringer O'mrogg
         569, -- Warchief Kargath Bladefist
    },
    [ 547] = { -- The Slave Pens
         570, -- Mennu the Betrayer
         571, -- Rokmar the Crackler
         572, -- Quagmirran
    },
    [ 545] = { -- The Steamvault
         573, -- Hydromancer Thespia
         574, -- Mekgineer Steamrigger
         575, -- Warlord Kalithresh
    },
    [ 546] = { -- The Underbog
         576, -- Hungarfen
         577, -- Ghaz'an
         578, -- Swamplord Musel'ek
         579, -- The Black Stalker
    },
    [ 532] = { -- Karazhan
        1552, -- Servant's Quarters
        1553, -- Attumen the Huntsman
        1554, -- Moroes
        1555, -- Maiden of Virtue
        1556, -- Opera Hall
        1557, -- The Curator
        1559, -- Shade of Aran
        1560, -- Terestian Illhoof
        1561, -- Netherspite
        1562, -- Chess Event
        1764, -- Chess Event
        1563, -- Prince Malchezaar
    },
    [ 565] = { -- Gruul's Lair
        1564, -- High King Maulgar
        1565, -- Gruul the Dragonkiller
    },
    [ 544] = { -- Magtheridon's Lair
        1566, -- Magtheridon
    },
    [ 548] = { -- Serpentshrine Cavern
        1567, -- Hydross the Unstable
        1568, -- The Lurker Below
        1569, -- Leotheras the Blind
        1570, -- Fathom-Lord Karathress
        1571, -- Morogrim Tidewalker
        1572, -- Lady Vashj
    },
    [ 550] = { -- The Eye
        1573, -- Al'ar
        1574, -- Void Reaver
        1575, -- High Astromancer Solarian
        1576, -- Kael'thas Sunstrider
    },
    [ 534] = { -- The Battle for Mount Hyjal
        1577, -- Rage Winterchill
        1578, -- Anetheron
        1579, -- Kaz'rogal
        1580, -- Azgalor
        1581, -- Archimonde
    },
    [ 564] = { -- Black Temple
        1582, -- High Warlord Naj'entus
        1583, -- Supremus
        1584, -- Shade of Akama
        1585, -- Teron Gorefiend
        1586, -- Gurtogg Bloodboil
        1587, -- Reliquary of Souls
        1588, -- Mother Shahraz
        1589, -- The Illidari Council
        1590, -- Illidan Stormrage
    },
    [ 580] = { -- Sunwell Plateau
        1591, -- Kalecgos
        1592, -- Brutallus
        1593, -- Felmyst
        1594, -- The Eredar Twins
        1595, -- M'uru
        1596, -- Kil'jaeden
    },

    -- Wrath of the Lich King
    [ 619] = { -- Ahn'kahet: The Old Kingdom
         580, -- Elder Nadox
         581, -- Prince Taldaram
         582, -- Jedoga Shadowseeker
         583, -- Amanitar
         584, -- Herald Volazj
    },
    [ 601] = { -- Azjol-Nerub
         585, -- Krik'thir the Gatewatcher
         586, -- Hadronox
         587, -- Anub'arak
    },
    [ 600] = { -- Drak'Tharon Keep
         588, -- Trollgore
         589, -- Novos the Summoner
         590, -- King Dred
         591, -- The Prophet Tharon'ja
    },
    [ 604] = { -- Gundrak
         592, -- Slad'ran
         593, -- Drakkari Colossus
         594, -- Moorabi
         595, -- Eck the Ferocious
         596, -- Gal'darah
    },
    [ 602] = { -- Halls of Lightning
         597, -- General Bjarngrim
         598, -- Volkhan
         599, -- Ionar
         600, -- Loken
    },
    [ 668] = { -- Halls of Reflection
         601, -- Falric
         602, -- Marwyn
         603, -- Escape from Arthas
    },
    [ 599] = { -- Halls of Stone
         604, -- Krystallus
         605, -- Maiden of Grief
         606, -- Tribunal of Ages
         607, -- Sjonnir the Ironshaper
    },
    [ 658] = { -- Pit of Saron
         608, -- Forgemaster Garfrost
         609, -- Ick & Krick
         610, -- Scourgelord Tyrannus
    },
    [ 595] = { -- The Culling of Stratholme
         611, -- Meathook
         612, -- Salramm the Fleshcrafter
         613, -- Chrono-Lord Epoch
         614, -- Mal'Ganis
    },
    [ 632] = { -- The Forge of Souls
         615, -- Bronjahm
         616, -- Devourer of Souls
    },
    [ 576] = { -- The Nexus
         617, -- Commander Stoutbeard
         833, -- Commander Kolurg
         618, -- Grand Magus Telestra
         619, -- Anomalus
         620, -- Ormorok the Tree-Shaper
         621, -- Keristrasza
    },
    [ 578] = { -- The Oculus
         622, -- Drakos the Interrogator
         623, -- Varos Cloudstrider
         624, -- Mage-Lord Urom
         625, -- Ley-Guardian Eregos
    },
    [ 608] = { -- The Violet Hold
         626, -- Erekem
         627, -- Moragg
         628, -- Ichoron
         629, -- Xevozz
         630, -- Lavanthor
         631, -- Zuramat the Obliterator
         632, -- Cyanigosa
    },
    [ 650] = { -- Trial of the Champion
         634, -- Grand Champions
         834, -- Grand Champions
         635, -- Eadric the Pure
         636, -- Argent Confessor Paletress
         637, -- The Black Knight
    },
    [ 574] = { -- Utgarde Keep
         638, -- Prince Keleseth
         639, -- Skarvald & Dalronn
         640, -- Ingvar the Plunderer
    },
    [ 575] = { -- Utgarde Pinnacle
         641, -- Svala Sorrowgrave
         642, -- Gortok Palehoof
         643, -- Skadi the Ruthless
         644, -- King Ymiron
    },
    [ 624] = { -- Vault of Archavon
        1597, -- Archavon the Stone Watcher
        1598, -- Emalon the Storm Watcher
        1599, -- Koralon the Flame Watcher
        1600, -- Toravon the Ice Watcher
    },
    [ 533] = { -- Naxxramas
        1601, -- Anub'Rekhan
        1602, -- Grand Widow Faerlina
        1603, -- Maexxna
        1604, -- Noth the Plaguebringer
        1605, -- Heigan the Unclean
        1606, -- Loatheb
        1607, -- Instructor Razuvious
        1608, -- Gothik the Harvester
        1609, -- The Four Horsemen
        1610, -- Patchwerk
        1611, -- Grobbulus
        1612, -- Gluth
        1613, -- Thaddius
        1614, -- Sapphiron
        1615, -- Kel'Thuzad
    },
    [ 615] = { -- The Obsidian Sanctum
        1616, -- Sartharion
    },
    [ 616] = { -- The Eye of Eternity
        1617, -- Malygos
    },
    [ 649] = { -- Trial of the Crusader
        1618, -- The Northrend Beasts
        1619, -- Lord Jaraxxus
        1621, -- Champions of the Horde
        1620, -- Champions of the Alliance
        1622, -- Twin Val'kyr
        1623, -- Anub'arak
    },
    [ 631] = { -- Icecrown Citadel
        1624, -- Lord Marrowgar
        1625, -- Lady Deathwhisper
        1627, -- Icecrown Gunship Battle
        1626, -- Icecrown Gunship Battle
        1628, -- Deathbringer Saurfang
        1629, -- Festergut
        1630, -- Rotface
        1631, -- Professor Putricide
        1632, -- Blood Prince Council
        1633, -- Blood-Queen Lana'thel
        1634, -- Valithria Dreamwalker
        1635, -- Sindragosa
        1636, -- The Lich King
    },
    [ 603] = { -- Ulduar
        1637, -- Flame Leviathan
        1638, -- Ignis the Furnace Master
        1639, -- Razorscale
        1640, -- XT-002 Deconstructor
        1641, -- The Assembly of Iron
        1642, -- Kologarn
        1643, -- Auriaya
        1644, -- Hodir
        1645, -- Thorim
        1646, -- Freya
        1647, -- Mimiron
        1648, -- General Vezax
        1649, -- Yogg-Saron
        1650, -- Algalon the Observer
    },
    [ 249] = { -- Onyxia's Lair
        1651, -- Onyxia
    },
    [ 724] = { -- The Ruby Sanctum
        1652, -- Halion
    },

    -- Cataclysm
    [ 645] = { -- Blackrock Caverns
         105, -- Rom'ogg Bonecrusher
         106, -- Corla, Herald of Twilight
         107, -- Karsh Steelbender
         108, -- Beauty
         109, -- Ascendant Lord Obsidius
    },
    [  36] = { -- Deadmines
          89, -- Glubtok
          90, -- Helix Gearbreaker
          91, -- Foe Reaper 5000
          92, -- Admiral Ripsnarl
          93, -- "Captain" Cookie
          95, -- Vanessa VanCleef
    },
    [ 644] = { -- Halls of Origination
         124, -- Temple Guardian Anhuur
         125, -- Earthrager Ptah
         126, -- Anraphet
         127, -- Isiset, Construct of Magic
         128, -- Ammunae, Construct of Life
         129, -- Setesh, Construct of Destruction
         130, -- Rajh, Construct of Sun
    },
    [ 755] = { -- Lost City of the Tol'vir
         117, -- General Husam
         118, -- Lockmaw
         119, -- High Prophet Barim
         122, -- Siamat
    },
    [  33] = { -- Shadowfang Keep
          96, -- Baron Ashbury
          97, -- Baron Silverlaine
          98, -- Commander Springvale
          99, -- Lord Walden
         100, -- Lord Godfrey
    },
    [ 725] = { -- The Stonecore
         110, -- Corborus
         111, -- Slabhide
         112, -- Ozruk
         113, -- High Priestess Azil
    },
    [ 657] = { -- The Vortex Pinnacle
         114, -- Grand Vizier Ertan
         115, -- Altairus
         116, -- Asaad, Caliph of Zephyrs
    },
    [ 643] = { -- Throne of the Tides
         101, -- Lady Naz'jar
         102, -- Commander Ulthok, the Festering Prince
         103, -- Mindbender Ghur'sha
         104, -- Ozumat
    },
    [ 568] = { -- Zul'Aman
         186, -- Akil'zon
         187, -- Nalorakk
         188, -- Jan'alai
         189, -- Halazzi
         190, -- Hex Lord Malacrass
         191, -- Daakara
    },
    [ 859] = { -- Zul'Gurub
         175, -- High Priest Venoxis
         176, -- Bloodlord Mandokir
         177, -- Cache of Madness - Gri'lek
         178, -- Cache of Madness - Hazza'rah
         179, -- Cache of Madness - Renataki
         180, -- Cache of Madness - Wushoolay
         181, -- High Priestess Kilnara
         184, -- Zanzil
         185, -- Jin'do the Godbreaker
    },
    [ 670] = { -- Grim Batol
        2617, -- General Umbriss
        2627, -- Forgemaster Throngus
        2618, -- Drahga Shadowburner
        2619, -- Erudax, the Duke of Below
    },
    [ 938] = { -- End Time
         340, -- Echo of Baine
         285, -- Echo of Jaina
         323, -- Echo of Sylvanas
         283, -- Echo of Tyrande
         289, -- Murozond
    },
    [ 939] = { -- Well of Eternity
         290, -- Peroth'arn
         291, -- Queen Azshara
         292, -- Mannoroth and Varo'then
    },
    [ 940] = { -- Hour of Twilight
         322, -- Arcurion
         342, -- Asira Dawnslayer
         341, -- Archbishop Benedictus
    },
    [ 671] = { -- The Bastion of Twilight
         156, -- Halfus Wyrmbreaker
         157, -- Theralion and Valiona
         158, -- Ascendant Council
         167, -- Cho'gall
         168, -- Sinestra
    },
    [ 669] = { -- Blackwing Descent
         169, -- Omnotron Defense System
         170, -- Magmaw
         171, -- Atramedes
         172, -- Chimaeron
         173, -- Maloriak
         174, -- Nefarian's End
    },
    [ 967] = { -- Dragon Soul
         311, -- Morchok
         324, -- Warlord Zon'ozz
         325, -- Yor'sahj the Unsleeping
         317, -- Hagara the Stormbinder
         331, -- Ultraxion
         332, -- Warmaster Blackhorn
         318, -- Spine of Deathwing
         333, -- Madness of Deathwing
    },
    [ 720] = { -- Firelands
         192, -- Beth'tilac
         193, -- Lord Rhyolith
         194, -- Alysrazor
         195, -- Shannox
         196, -- Baleroc, the Gatekeeper
         197, -- Majordomo Staghelm
         198, -- Ragnaros
    },
    [ 754] = { -- Throne of the Four Winds
         154, -- The Conclave of Wind
         155, -- Al'Akir
    },

    -- Mists of Pandaria
    [ 961] = { -- Stormstout Brewery
         668, -- Ook-Ook
         669, -- Hoptallus
         670, -- Yan-Zhu the Uncasked
    },
    [ 960] = { -- Temple of the Jade Serpent
         672, -- Wise Mari
         664, -- Lorewalker Stonestep
         658, -- Liu Flameheart
         335, -- Sha of Doubt
    },
    [ 994] = { -- Mogu'shan Palace
         708, -- Trial of the King
         690, -- Gekkan
         698, -- Xin the Weaponmaster
    },
    [ 962] = { -- Gate of the Setting Sun
         655, -- Saboteur Kip'tilak
         675, -- Striker Ga'dok
         676, -- Commander Ri'mok
         649, -- Raigonn
    },
    [1011] = { -- Siege of Niuzao Temple
         693, -- Vizier Jin'bak
         738, -- Commander Vo'jak
         692, -- General Pa'valak
         727, -- Wing Leader Ner'onok
    },
    [ 959] = { -- Shado-Pan Monastery
         673, -- Gu Cloudstrike
         657, -- Master Snowdrift
         685, -- Sha of Violence
         686, -- Taran Zhu
    },
    [1007] = { -- Scholomance
         659, -- Instructor Chillheart
         663, -- Jandice Barov
         665, -- Rattlegore
         666, -- Lilian Voss
         684, -- Darkmaster Gandling
    },
    [1001] = { -- Scarlet Halls
         660, -- Houndmaster Braun
         656, -- Flameweaver Koegler
         654, -- Armsmaster Harlan
    },
    [1004] = { -- Scarlet Monastery
         688, -- Thalnos the Soulrender
         671, -- Brother Korloff
         674, -- High Inquisitor Whitemane
    },
    [1008] = { -- Mogu'shan Vaults
         679, -- The Stone Guard
         689, -- Feng the Accursed
         682, -- Gara'jal the Spiritbinder
         687, -- The Spirit Kings
         726, -- Elegon
         677, -- Will of the Emperor
    },
    [1009] = { -- Heart of Fear
         745, -- Imperial Vizier Zor'lok
         744, -- Blade Lord Ta'yak
         713, -- Garalon
         741, -- Wind Lord Mel'jarak
         737, -- Amber-Shaper Un'sok
         743, -- Grand Empress Shek'zeer
    },
    [ 996] = { -- Terrace of Endless Spring
         683, -- Protectors of the Endless
         742, -- Tsulong
         729, -- Lei Shi
         709, -- Sha of Fear
    },
    [1098] = { -- Throne of Thunder
         827, -- Jin'rokh the Breaker
         819, -- Horridon
         816, -- Council of Elders
         825, -- Tortos
         821, -- Megaera
         828, -- Ji-Kun
         818, -- Durumu the Forgotten
         820, -- Primordius
         824, -- Dark Animus
         817, -- Iron Qon
         829, -- Twin Empyreans
         832, -- Lei Shen
         831, -- Ra-den
    },
    [1136] = { -- Siege of Orgrimmar
         852, -- Immerseus
         849, -- The Fallen Protectors
         866, -- Norushen
         867, -- Sha of Pride
         868, -- Galakras
         881, -- Galakras
         864, -- Iron Juggernaut
         856, -- Kor'kron Dark Shaman
         850, -- General Nazgrim
         846, -- Malkorok
         870, -- Spoils of Pandaria
         851, -- Thok the Bloodthirsty
         865, -- Siegecrafter Blackfuse
         853, -- Paragons of the Klaxxi
         869, -- Garrosh Hellscream
    },

    -- Warlords of Draenor
    [1175] = { -- Bloodmaul Slag Mines
         893, -- Magmolatus
         888, -- Slave Watcher Crushto
         887, -- Roltall
         889, -- Gug'rokk
    },
    [1209] = { -- Skyreach
         965, -- Ranjit
         966, -- Araknath
         967, -- Rukhran
         968, -- High Sage Viryx
    },
    [1208] = { -- Grimrail Depot
        1138, -- Rocketspark and Borka
        1163, -- Nitrogg Thundertower
        1133, -- Skylord Tovra
    },
    [1176] = { -- Shadowmoon Burial Grounds
        1139, -- Sadana Bloodfury
        1168, -- Nhallish
        1140, -- Bonemaw
        1160, -- Ner'zhul
    },
    [1182] = { -- Auchindoun
        1185, -- Vigilant Kaathar
        1186, -- Soulbinder Nyami
        1216, -- Azzakel
        1225, -- Teron'gor
    },
    [1279] = { -- The Everbloom
        1214, -- Witherbark
        1207, -- Ancient Protectors
        1208, -- Archmage Sol
        1209, -- Xeri'tac
        1210, -- Yalnu
    },
    [1358] = { -- Upper Blackrock Spire
        1226, -- Orebender Gor'ashan
        1227, -- Kyrak
        1228, -- Commander Tharbek
        1229, -- Ragewing the Untamed
        1234, -- Warlord Zaela
    },
    [1195] = { -- Iron Docks
        1235, -- Fleshrender Nok'gar
        1236, -- Grimrail Enforcers
        1237, -- Oshir
        1238, -- Skulloc
    },
    [1205] = { -- Blackrock Foundry
        1202, -- Oregorger
        1155, -- Hans'gar and Franzok
        1122, -- Beastlord Darmac
        1161, -- Gruul
        1123, -- Flamebender Ka'graz
        1147, -- Operator Thogar
        1154, -- The Blast Furnace
        1162, -- Kromog
        1203, -- The Iron Maidens
         959, -- Blackhand
    },
    [1228] = { -- Highmaul
        1128, -- Kargath Bladefist
         971, -- The Butcher
        1195, -- Tectus
        1196, -- Brackenspore
        1148, -- Twin Ogron
        1153, -- Ko'ragh
        1197, -- Imperator Mar'gok
    },
    [1228] = { -- Draenor
        1291, -- Drov the Ruiner
        1211, -- Tarlna the Ageless
        1262, -- Rukhmar
        1452, -- Supreme Lord Kazzak
    },
    [1448] = { -- Hellfire Citadel
        1426, -- Hellfire Assault
        1425, -- Iron Reaver
        1392, -- Kormrok
        1432, -- Hellfire High Council
        1396, -- Kilrogg Deadeye
        1372, -- Gorefiend
        1433, -- Shadow-Lord Iskar
        1427, -- Socrethar the Eternal
        1391, -- Fel Lord Zakuun
        1447, -- Xhul'horac
        1394, -- Tyrant Velhari
        1395, -- Mannoroth
        1438, -- Archimonde
    },

    -- Legion
    [1493] = { -- Vault of the Wardens
        1467, -- Tirathon Saltheril
        1695, -- Inquisitor Tormentorum
        1468, -- Ash'golm
        1469, -- Glazer
        1470, -- Cordana Felsong
    },
    [1456] = { -- Eye of Azshara
        1480, -- Warlord Parjesh
        1490, -- Lady Hatecoil
        1491, -- King Deepbeard
        1479, -- Serpentrix
        1492, -- Wrath of Azshara
    },
    [1477] = { -- Halls of Valor
        1485, -- Hymdall
        1486, -- Hyrja
        1487, -- Fenryr
        1488, -- God-King Skovald
        1489, -- Odyn
    },
    [1492] = { -- Maw of Souls
        1502, -- Ymiron, the Fallen King
        1512, -- Harbaron
        1663, -- Helya
    },
    [1516] = { -- The Arcway
        1497, -- Ivanyr
        1498, -- Corstilax
        1499, -- General Xakal
        1500, -- Nal'tira
        1501, -- Advisor Vandros
    },
    [1501] = { -- Black Rook Hold
        1518, -- The Amalgam of Souls
        1653, -- Illysanna Ravencrest
        1664, -- Smashspite the Hateful
        1672, -- Lord Kur'talos Ravencrest
    },
    [1466] = { -- Darkheart Thicket
        1654, -- Archdruid Glaidalis
        1655, -- Oakheart
        1656, -- Dresaron
        1657, -- Shade of Xavius
    },
    [1458] = { -- Neltharion's Lair
        1662, -- Rokmora
        1665, -- Ularogg Cragshaper
        1673, -- Naraxas
        1687, -- Dargrul the Underking
    },
    [1544] = { -- Assault on Violet Hold
        1694, -- Shivermaw
        1693, -- Festerface
        1702, -- Blood-Princess Thal'ena
        1696, -- Anub'esset
        1686, -- Mindflayer Kaahrj
        1688, -- Millificent Manastorm
        1697, -- Sael'orn
        1711, -- Fel Lord Betrug
    },
    [1571] = { -- Court of Stars
        1718, -- Patrol Captain Gerdo
        1719, -- Talixae Flamewreath
        1720, -- Advisor Melandrus
    },
    [1651] = { -- Return to Karazhan
        1820, -- Opera Hall: Wikket
        1826, -- Opera Hall: Westfall Story
        1827, -- Opera Hall: Beautiful Beast
        1825, -- Maiden of Virtue
        1837, -- Moroes
        1835, -- Attumen the Huntsman
        1836, -- The Curator
        1817, -- Shade of Medivh
        1818, -- Mana Devourer
        1838, -- Viz'aduum the Watcher
    },
    [1677] = { -- Cathedral of Eternal Night
        1905, -- Agronox
        1906, -- Thrashbite the Scornful
        1904, -- Domatrax
        1878, -- Mephistroth
    },
    [1753] = { -- Seat of the Triumvirate
        1979, -- Zuraal the Ascended
        1980, -- Saprish
        1981, -- Viceroy Nezhar
        1982, -- L'ura
    },
    [1520] = { -- The Emerald Nightmare
        1703, -- Nythendra
        1738, -- Il'gynoth, Heart of Corruption
        1744, -- Elerethe Renferal
        1667, -- Ursoc
        1704, -- Dragons of Nightmare
        1750, -- Cenarius
        1726, -- Xavius
    },
    [1530] = { -- The Nighthold
        1706, -- Skorpyron
        1725, -- Chronomatic Anomaly
        1731, -- Trilliax
        1751, -- Spellblade Aluriel
        1762, -- Tichondrius
        1713, -- Krosus
        1761, -- High Botanist Tel'arn
        1732, -- Star Augur Etraeus
        1872, -- Grand Magistrix Elisande
        1743, -- Grand Magistrix Elisande
        1737, -- Gul'dan
    },
    [1648] = { -- Trial of Valor
        1819, -- Odyn
        1830, -- Guarm
        1829, -- Helya
    },
    [1676] = { -- Tomb of Sargeras
        1862, -- Goroth
        1867, -- Demonic Inquisition
        1856, -- Harjatan
        1903, -- Sisters of the Moon
        1861, -- Mistress Sassz'ine
        1896, -- The Desolate Host
        1897, -- Maiden of Vigilance
        1873, -- Fallen Avatar
        1898, -- Kil'jaeden
    },
    [1712] = { -- Antorus, the Burning Throne
        1992, -- Garothi Worldbreaker
        1987, -- Felhounds of Sargeras
        1997, -- Antoran High Command
        1985, -- Portal Keeper Hasabel
        2025, -- Eonar the Life-Binder
        2009, -- Imonar the Soulhunter
        2004, -- Kin'garoth
        1983, -- Varimathras
        1986, -- The Coven of Shivarra
        1984, -- Aggramar
        2031, -- Argus the Unmaker
    },

    -- Battle for Azeroth
    [1763] = { -- Atal'Dazar
        2082, -- Priestess Alun'za
        2036, -- Vol'kaal
        2083, -- Rezan
        2030, -- Yazma
    },
    [1754] = { -- Freehold
        2102, -- Skycap'n Kragg
        2093, -- Council o' Captains
        2094, -- Ring of Booty
        2095, -- Harlan Sweete
    },
    [1594] = { -- The MOTHERLODE!!
        2109, -- Coin-Operated Crowd Pummeler
        2114, -- Azerokk
        2115, -- Rixxa Fluxflame
        2116, -- Mogul Razdunk
    },
    [1771] = { -- Tol Dagor
        2097, -- The Sand Queen
        2098, -- Jes Howlis
        2099, -- Knight Captain Valyri
        2096, -- Overseer Korgus
    },
    [1862] = { -- Waycrest Manor
        2125, -- Heartsbane Triad
        2126, -- Soulbound Goliath
        2127, -- Raal the Gluttonous
        2128, -- Lord and Lady Waycrest
        2129, -- Gorak Tul
    },
    [1841] = { -- The Underrot
        2157, -- Elder Leaxa
        2131, -- Cragmaw the Infested
        2130, -- Sporecaller Zancha
        2158, -- Unbound Abomination
    },
    [1822] = { -- Siege of Boralus
        2132, -- Chopper Redhook
        2133, -- Sergeant Bainbridge
        -- 2654, -- Chopper Redhook, M+ version?
        2173, -- Dread Captain Lockwood
        2134, -- Hadal Darkfathom
        2140, -- Viq'Goth
    },
    [1877] = { -- Temple of Sethraliss
        2142, -- Adderis and Aspix
        2143, -- Merektha
        2144, -- Galvazzt
        2145, -- Avatar of Sethraliss
    },
    [1864] = { -- Shrine of the Storm
        2153, -- Aqu'sirr
        2154, -- Tidesage Council
        2155, -- Lord Stormsong
        2156, -- Vol'zith the Whisperer
    },
    [1762] = { -- Kings' Rest
        2165, -- The Golden Serpent
        2171, -- Mchimba the Embalmer
        2170, -- The Council of Tribes
        2172, -- Dazar, The First King
    },
    [2097] = { -- Operation: Mechagon
        2357, -- King Gobbamak
        2358, -- Gunker
        2360, -- Trixie & Naeno
        2355, -- HK-8 Aerial Oppression Unit
        2336, -- Tussle Tonks
        2339, -- K.U.-J.0.
        2348, -- Machinist's Garden
        2331, -- King Mechagon
    },
    [1861] = { -- Uldir
        2168, -- Taloc
        2167, -- MOTHER
        2169, -- Zek'voz, Herald of N'Zoth
        2146, -- Fetid Devourer
        2166, -- Vectis
        2195, -- Zul, Reborn
        2194, -- Mythrax the Unraveler
        2147, -- G'huun
    },
    [2070] = { -- Battle of Dazar'alor
        2344, -- Champion of the Light
        2333, -- Champion of the Light
        2340, -- Grong, the Revenant
        2323, -- Jadefire Masters
        2325, -- Grong, the Jungle Lord
        2341, -- Jadefire Masters
        2342, -- Opulence
        2330, -- Conclave of the Chosen
        2335, -- King Rastakhan
        2334, -- High Tinker Mekkatorque
        2337, -- Stormwall Blockade
        2343, -- Lady Jaina Proudmoore
    },
    [2096] = { -- Crucible of Storms
        2328, -- The Restless Cabal
        2332, -- Uu'nat, Harbinger of the Void
    },
    [2164] = { -- The Eternal Palace
        2352, -- Abyssal Commander Sivara
        2347, -- Blackwater Behemoth
        2353, -- Radiance of Azshara
        2354, -- Lady Ashvane
        2351, -- Orgozoa
        2359, -- The Queen's Court
        2349, -- Za'qul, Harbinger of Ny'alotha
        2361, -- Queen Azshara
    },
    [2217] = { -- Ny'alotha, the Waking City
        2368, -- Wrathion, the Black Emperor
        2365, -- Maut
        2369, -- The Prophet Skitra
        2377, -- Dark Inquisitor Xanesh
        2372, -- The Hivemind
        2367, -- Shad'har the Insatiable
        2373, -- Drest'agath
        2374, -- Il'gynoth, Corruption Reborn
        2370, -- Vexiona
        2364, -- Ra-den the Despoiled
        2366, -- Carapace of N'Zoth
        2375, -- N'Zoth the Corruptor
    },

    -- Shadowlands
    [2286] = { -- The Necrotic Wake
        2395, -- Blightbone
        2391, -- Amarth, The Harvester
        2392, -- Surgeon Stitchflesh
        2396, -- Nalthor the Rimebinder
    },
    [2289] = { -- Plaguefall
        2419, -- Globgrog
        2403, -- Doctor Ickus
        2423, -- Domina Venomblade
        2404, -- Margrave Stradama
    },
    [2290] = { -- Mists of Tirna Scithe
        2400, -- Ingra Maloch
        2402, -- Mistcaller
        2405, -- Tred'ova
    },
    [2287] = { -- Halls of Atonement
        2406, -- Halkias, the Sin-Stained Goliath
        2387, -- Echelon
        2411, -- High Adjudicator Aleez
        2413, -- Lord Chamberlain
    },
    [2285] = { -- Spires of Ascension
        2399, -- Kin-Tara
        2416, -- Ventunax
        2414, -- Oryphrion
        2412, -- Devos, Paragon of Doubt
    },
    [2293] = { -- Theater of Pain
        2397, -- An Affront of Challengers
        2401, -- Gorechop
        2390, -- Xav the Unfallen
        2389, -- Kul'tharok
        2417, -- Mordretha, the Endless Empress
    },
    [2291] = { -- De Other Side
        2408, -- Hakkar the Soulflayer
        2409, -- The Manastorms
        2398, -- Dealer Xy'exa
        2410, -- Mueh'zala
    },
    [2284] = { -- Sanguine Depths
        2388, -- Kryxis the Voracious
        2415, -- Executor Tarvold
        2421, -- Grand Proctor Beryllia
        2407, -- General Kaal
    },
    [2441] = { -- Tazavesh, the Veiled Market
        2437, -- Zo'phex the Sentinel
        2454, -- The Grand Menagerie
        2436, -- Mailroom Mayhem
        2452, -- Myza's Oasis
        2451, -- So'azmi
        2448, -- Hylbrande
        2449, -- Timecap'n Hooktail
        2455, -- So'leah
    },
    [2296] = { -- Castle Nathria
        2393, -- Shriekwing
        2429, -- Huntsman Altimor
        2422, -- Sun King's Salvation
        2418, -- Artificer Xy'mox
        2428, -- Hungering Destroyer
        2420, -- Lady Inerva Darkvein
        2426, -- The Council of Blood
        2394, -- Sludgefist
        2425, -- Stone Legion Generals
        2424, -- Sire Denathrius
    },
    [2450] = { -- Sanctum of Domination
        2435, -- The Tarragrue
        2442, -- The Eye of the Jailer
        2439, -- The Nine
        2444, -- Remnant of Ner'zhul
        2445, -- Soulrender Dormazain
        2443, -- Painsmith Raznal
        2446, -- Guardian of the First Ones
        2447, -- Fatescribe Roh-Kalo
        2440, -- Kel'Thuzad
        2441, -- Sylvanas Windrunner
    },
    [2481] = { -- Sepulcher of the First Ones
        2458, -- Vigilant Guardian
        2465, -- Skolex, the Insatiable Ravener
        2470, -- Artificer Xy'mox
        2459, -- Dausegne, the Fallen Oracle
        2460, -- Prototype Pantheon
        2461, -- Lihuvim, Principal Architect
        2463, -- Halondrus the Reclaimer
        2469, -- Anduin Wrynn
        2457, -- Lords of Dread
        2467, -- Rygelon
        2464, -- The Jailer
    },

    -- Dragonflight
    [2520] = { -- Brackenhide Hollow
        2471, -- Hackclaw's War-Band
        2473, -- Treemouth
        2472, -- Gutshot
        2474, -- Decatriarch Wratheye
    },
    [2451] = { -- Uldaman: Legacy of Tyr
        2475, -- The Lost Dwarves
        2487, -- Bromach
        2484, -- Sentinel Talondras
        2476, -- Emberon
        2479, -- Chrono-Lord Deios
    },
    [2516] = { -- The Nokhud Offensive
        2498, -- Granyth
        2497, -- The Raging Tempest
        2478, -- Teera and Maruuk
        2477, -- Balakar Khan
    },
    [2519] = { -- Neltharus
        2490, -- Chargath, Bane of Scales
        2489, -- Forgemaster Gorek
        2494, -- Magmatusk
        2501, -- Warlord Sargha
    },
    [2526] = { -- Algeth'ar Academy
        2509, -- Vexamus
        2512, -- Overgrown Ancient
        2495, -- Crawth
        2514, -- Echo of Doragosa
    },
    [2515] = { -- The Azure Vault
        2492, -- Leymor
        2505, -- Azureblade
        2483, -- Telash Greywing
        2508, -- Umbrelskul
    },
    [2521] = { -- Ruby Life Pools
        2488, -- Melidrussa Chillworn
        2485, -- Kokia Blazehoof
        2503, -- Kyrakka and Erkhart Stormvein
    },
    [2527] = { -- Halls of Infusion
        2504, -- Watcher Irideus
        2507, -- Gulping Goliath
        2510, -- Khajin the Unyielding
        2511, -- Primal Tsunami
    },
    [2579] = { -- Dawn of the Infinite
        2521, -- Chronikar
        2528, -- Manifested Timeways
        2535, -- Blight of Galakrond
        2537, -- Iridikron the Stonescaled
        2526, -- Tyr, the Infinite Keeper
        2536, -- Morchie
        2534, -- Time-Lost Battlefield
        2533, -- Time-Lost Battlefield
        2538, -- Chrono-Lord Deios
    },
    [2522] = { -- Vault of the Incarnates
        2480, -- Eranog
        2500, -- Terros
        2486, -- The Primal Council
        2482, -- Sennarth, the Cold Breath
        2502, -- Dathea, Ascended
        2491, -- Kurog Grimtotem
        2493, -- Broodkeeper Diurna
        2499, -- Raszageth the Storm-Eater
    },
    [2569] = { -- Aberrus, the Shadowed Crucible
        2522, -- Kazzara, the Hellforged
        2529, -- The Amalgamation Chamber
        2530, -- The Forgotten Experiments
        2524, -- Assault of the Zaqali
        2525, -- Rashok, the Elder
        2532, -- The Vigilant Steward, Zskarn
        2527, -- Magmorax
        2523, -- Echo of Neltharion
        2520, -- Scalecommander Sarkareth
    },
    [2549] = { -- Amirdrassil, the Dream's Hope
        2564, -- Gnarlroot
        2554, -- Igira the Cruel
        2557, -- Volcoross
        2555, -- Council of Dreams
        2553, -- Larodar, Keeper of the Flame
        2556, -- Nymue, Weaver of the Cycle
        2563, -- Smolderon
        2565, -- Tindral Sageswift, Seer of the Flame
        2519, -- Fyrakk the Blazing
    },

    -- The War Within
    [2651] = { -- Darkflame Cleft
        2569, -- Ol' Waxbeard
        2559, -- Blazikon
        2560, -- The Candle King
        2561, -- The Darkness
    },
    [2648] = { -- The Rookery
        2566, -- Kyrioss
        2567, -- Stormguard Gorren
        2568, -- Voidstone Monstrosity
    },
    [2649] = { -- Priory of the Sacred Flame
        2571, -- Captain Dailcry
        2570, -- Baron Braunpyke
        2573, -- Prioress Murrpray
    },
    [2662] = { -- The Dawnbreaker
        2580, -- Speaker Shadowcrown
        2581, -- Anub'ikkaj
        2593, -- Rasha'nan
    },
    [2660] = { -- Ara-Kara, City of Echoes
        2583, -- Avanoxx
        2584, -- Anub'zekt
        2585, -- Ki'katal the Harvester
    },
    [2661] = { -- Cinderbrew Meadery
        2586, -- Brew Master Aldryr
        2588, -- Benk Buzzbee
        2587, -- I'pa
        2589, -- Goldie Baronbottom
    },
    [2652] = { -- The Stonevault
        2572, -- E.D.N.A.
        2579, -- Skarmorak
        2590, -- Master Machinists
        2582, -- Void Speaker Eirich
    },
    [2669] = { -- City of Threads
        2594, -- Orator Krix'vizk
        2595, -- Fangs of the Queen
        2600, -- The Coaglamation
        2596, -- Izo, the Grand Splicer
    },
    [2773] = { -- Operation: Floodgate
        2648, -- Big M.O.M.M.A.
        2649, -- Demolition Duo
        2650, -- Swampface
        2651, -- Geezle Gigazap
    },
    [2657] = { -- Nerub-ar Palace
        2607, -- Ulgrax the Devourer
        2611, -- The Bloodbound Horror
        2599, -- Sikran, Captain of the Sureki
        2609, -- Rasha'nan
        2612, -- Broodtwister Ovi'nax
        2601, -- Nexus-Princess Ky'veza
        2608, -- The Silken Court
        2602, -- Queen Ansurek
    },
    [2769] = { -- Liberation of Undermine
        2639, -- Vexie and the Geargrinders
        2640, -- Cauldron of Carnage
        2641, -- Rik Reverb
        2642, -- Stix Bunkjunker
        2653, -- Sprocketmonger Lockenstock
        2644, -- The One-Armed Bandit
        2645, -- Mug'Zee, Heads of Security
        2646, -- Chrome King Gallywix
    },
}
-- A map of npc ids to JournalInstanceID, this might not be the bosses npc id,
-- just something that signifies the boss
local npcIDToBossID = {
	-- Shrine of the Storm
	[134056] = 2153, -- Aqu'sirr
	[134063] = 2154, -- Tidesage Council
	[134058] = 2154, -- Tidesage Council
	[134060] = 2155, -- Lord Stormsong
	[134069] = 2156, -- Vol'zith the Whisperer

	-- The Eternal Palace
	[155899] = 2353, -- Radiance of Azshara
	[155900] = 2353, -- Radiance of Azshara
	[155859] = 2353, -- Radiance of Azshara
	[152364] = 2353, -- Radiance of Azshara

    [152236] = 2354, -- Lady Ashvane
    
    -- Sanguine Depths
    [162100] = 2388, -- Kryxis the Voracious
    [162103] = 2415, -- Executor Tarvold
    [162102] = 2421, -- Grand Proctor Beryllia
    [162099] = 2407, -- General Kaal

    -- Halls of Atonement
    [165408] = 2406, -- Halkias, the Sin-Stained Goliath
    [164185] = 2387, -- Echelon

    -- Castle Nathria
    [172145] = 2393, -- Shriekwing
    [165066] = 2429, -- Huntsman Altimor
    [164261] = 2428, -- Hungering Destroyer
    [174733] = 2394, -- Sludgefist
    [165318] = 2425, -- Stone Legion Generals
    [167406] = 2424, -- Sire Denathrius

    -- Sanctum of Domination
    [152253] = 2435, -- The Tarragrue
    [175611] = 2435, -- The Tarragrue
    [175725] = 2442, -- The Eye of the Jailer
    [180018] = 2442, -- The Eye of the Jailer
    [177094] = 2439, -- The Nine
    [178738] = 2439, -- The Nine
    [175726] = 2439, -- The Nine
    [175729] = 2444, -- Remnant of Ner'zhul
    [175727] = 2445, -- Soulrender Dormazain
    [176523] = 2443, -- Painsmith Raznal
    [175731] = 2446, -- Guardian of the First Ones
    [175730] = 2447, -- Fatescribe Roh-Kalo
    [179390] = 2447, -- Fatescribe Roh-Kalo
    [175559] = 2440, -- Kel'Thuzad
    [175732] = 2441, -- Sylvanas Windrunner
    [180828] = 2441, -- Sylvanas Windrunner
    
    -- Sepulcher of the First Ones
    [184522] = 2458, -- Vigilant Guardian (Vigilant Custodian)
    [181395] = 2465, -- Skolex, the Insatiable Ravener
    [183501] = 2470, -- Artificer Xy'mox
    [181224] = 2459, -- Dausegne, the Fallen Oracle
    [181546] = 2460, -- Prototype Pantheon
    [181548] = 2460, -- Prototype Pantheon
    [181549] = 2460, -- Prototype Pantheon
    [181551] = 2460, -- Prototype Pantheon
    [182169] = 2461, -- Lihuvim, Principal Architect
    [180906] = 2463, -- Halondrus the Reclaimer
    [181954] = 2469, -- Anduin Wrynn
    [181398] = 2457, -- Lords of Dread
    [181399] = 2457, -- Lords of Dread
    [182777] = 2467, -- Rygelon
    [180990] = 2464, -- The Jailer, Zovaal

    --Dragonflight
    -- Vault of the Incarnates
    [184972] = 2480, -- Eranog
    [190496] = 2500, -- Terros
    [187768] = 2486, -- The Primal Council
    [187767] = 2486, -- The Primal Council
    [187771] = 2486, -- The Primal Council
    [187772] = 2486, -- The Primal Council
    [187967] = 2482, -- Sennarth, The Cold Breath
    [189813] = 2502, -- Dathea, Ascended
    [184986] = 2491, -- Kurog Grimtotem
    [190245] = 2493, -- Broodkeeper Diurna
    [189492] = 2499, -- Raszageth the Storm-Eater

    -- Aberrus, the Shadowed Crucible
    [201261] = 2522, -- Kazzara, the Hellforged
    [200912] = 2530, -- The Forgotten Experiments
    [200918] = 2530, -- The Forgotten Experiments
    [200913] = 2530, -- The Forgotten Experiments
    [201320] = 2525, -- Rashok, the Elder
    [202375] = 2532, -- The Vigilant Steward, Zskarn
    [201579] = 2527, -- Magmorax

    -- Amirdrassil, the Dream's Hope
    [209333] = 2564, -- Gnarlroot
    [200926] = 2554, -- Igira the Cruel
    [208478] = 2557, -- Volcoross
    [208445] = 2553, -- Larodar, Keeper of the Flame
    [208363] = 2555, -- Council of Dreams
    [208365] = 2555, -- Council of Dreams
    [208367] = 2555, -- Council of Dreams
    [206172] = 2556, -- Nymue, Weaver of the Cycle
    [200927] = 2563, -- Smolderon
    [209090] = 2565, -- Tindral Sageswift, Seer of the Flame
    -- [204931] = 2519, -- Fyrakk the Blazing

    --The War Within
    -- Nerub-ar Palace
    [215657] = 2607, -- Ulgrax the Devourer
    [214502] = 2611, -- The Bloodbound Horror
    [214503] = 2599, -- Sikran, Captain of the Sureki
    [214504] = 2609, -- Rasha'nan
    [214506] = 2612, -- Broodtwister Ovi'nax
    [217748] = 2601, -- Nexus-Princess Ky'veza
    [217489] = 2608, -- The Silken Court
    [217491] = 2608, -- The Silken Court
    [218370] = 2602, -- Queen Ansurek

    -- Liberation of Undermine
    [225821] = 2639, -- Vexie and the Geargrinders
    [229181] = 2640, -- Cauldron of Carnage
    [229177] = 2640, -- Cauldron of Carnage
    [228648] = 2641, -- Rik Reverb
    [230322] = 2642, -- Stix Bunkjunker
    [230583] = 2653, -- Sprocketmonger Lockenstock
    [228458] = 2644, -- The One-Armed Bandit
    [229953] = 2645, -- Mug'Zee, Heads of Security
    -- [] = 2646, -- Chrome King Gallywix
};
-- Although area ids are unique we map them with instance ids so we can translate
-- area names by instance. We translate them because we cant get the area id where
-- the player is so we map area names to area ids and compare with the minimap text
local InstanceAreaIDToBossID = {
	[1822] = {
		[9984] = 2132,
	},
	[2097] = { -- Operation: Mechagon
		[11389] = 2358, -- Gunker
		[11388] = 2357, -- King Gobbamak
		[11387] = 2360, -- Trixie & Naeno
		[11390] = 2355, -- HK-8 Aerial Oppression Unit
		[10497] = 2336, -- Tussle Tonks
		-- [] = 2339, -- K.U.-J.0.
		-- [] = 2348, -- Machinist's Garden
		-- [] = 2331, -- King Mechagon
	},
	[1754] = { -- Freehold
		[9640] = 2102, -- Skycap'n Kragg
		[10039] = 2093, -- Council o' Captains
		[9639] = 2094, -- Ring of Booty
		[10040] = 2095, -- Harlan Sweete
	},
	[2217] = { -- Ny'alotha
		[12879] = 2365, -- Maut
		[12880] = 2369, -- The Prophet Skitra
		[12895] = 2366, -- Carapace of N'Zoth
		[12896] = 2375, -- N'Zoth the Corruptor
	},

	[2286] = { -- The Necrotic Wake
		[13471] = 2395, -- Blightbone
		[13473] = 2391, -- Amarth, The Harvester
	},
	[2289] = { -- Plaguefall
		[13423] = 2419, -- Globgrog
		[13421] = 2403, -- Doctor Ickus
		[13422] = 2423, -- Domina Venomblade
    },
    
	[2287] = { -- Halls of Atonement
    },
    [2284] = { -- Sanguine Depths
    },
    [2285] = { -- Spires of Ascension
        [13511] = 2399, -- Kin-Tara
        [13513] = 2416, -- Ventunax
    },
    [2293] = { -- Theater of Pain
    },
    [2290] = { -- Mists of Tirna Scithe
        [13429] = 2400, -- Ingra Maloch
        [13430] = 2402, -- Mistcaller
        [13431] = 2405, -- Tred'ova
    },
    [2296] = { -- Castle Nathria
        [13435] = 2424, -- Sire Denathrius
    },
    [2481] = { -- Sepulcher of the First Ones
        [13957] = 2458, -- Vigilant Guardian
        [13962] = 2465, -- Skolex, the Insatiable Ravener
        [13963] = 2470, -- Artificer Xy'mox
        [13958] = 2459, -- Dausegne, the Fallen Oracle
        [13959] = 2460, -- Prototype Pantheon
        [13960] = 2461, -- Lihuvim, Principal Architect
        [13964] = 2463, -- Halondrus the Reclaimer
        [13965] = 2469, -- Anduin Wrynn
        -- [] = 2457, -- Lords of Dread
        -- [] = 2467, -- Rygelon
        -- [] = 2464, -- The Jailer, Zovaal
    },
    [2549] = { -- Amirdrassil, the Dream's Hope
        [15049] = 2557, -- Volcoross
    },
    [2769] = { -- ALiberation of Undermine
        [15646] = 2639, -- Vexie and the Geargrinders
        [15652] = 2640, -- Cauldron of Carnage
        [15654] = 2641, -- Rik Reverb
        [15647] = 2642, -- Stix Bunkjunker
        [15648] = 2653, -- Sprocketmonger Lockenstock
    },
};
-- This is for bosses that have their own unique world map
local uiMapIDToBossID = {
    -- Classic
    -- Blackfathom Deeps
    [ 223] =  447, -- Guardian of the Deep
    -- Lower Blackrock Spire
    [ 252] =  388, -- Highlord Omokk
    [ 250] =  390, -- War Master Voone
    [ 253] =  392, -- Urok Doomhowl
    [ 255] =  396, -- Overlord Wyrmthalak
    -- Dire Maul
    [ 239] =  404, -- Lethtendris
    [ 237] =  408, -- Magister Kalendris
    -- Gnomeregan
    [ 226] =  419, -- Grubbis
    [ 228] =  418, -- Crowd Pummeler 9-60
    [ 229] =  422, -- Mekgineer Thermaplugg
    -- Uldaman
    [ 231] =  473, -- Archaedas
    -- Temple of Ahn'Qiraj
    [ 320] = 1543, -- The Prophet Skeram
    [ 321] = 1551, -- C'Thun

    -- The Burning Crusade
    -- Sethekk Halls
    [ 258] =  541, -- Darkweaver Syth
    -- The Arcatraz
    [ 269] =  548, -- Zereketh the Unbound
    [ 271] =  551, -- Harbinger Skyriss
    -- The Mechanar
    [ 267] =  563, -- Mechano-Lord Capacitus
    -- Karazhan
    [ 352] = 1554, -- Moroes
    [ 358] = 1557, -- The Curator
    [ 359] = 1559, -- Shade of Aran
    [ 360] = 1560, -- Terestian Illhoof
    [ 362] = 1561, -- Netherspite
    [ 366] = 1563, -- Prince Malchezaar
    -- Magtheridon's Lair
    [ 331] = 1566, -- Magtheridon
    -- Black Temple
    [ 340] = 1582, -- High Warlord Naj'entus
    [ 339] = 1583, -- Supremus
    [ 341] = 1584, -- Shade of Akama
    [ 343] = 1585, -- Teron Gorefiend
    [ 344] = 1588, -- Mother Shahraz
    [ 345] = 1589, -- The Illidari Council
    [ 346] = 1590, -- Illidan Stormrage

    -- Wrath of the Lich King
    -- Azjol-Nerub
    [ 159] =  585, -- Krik'thir the Gatewatcher
    [ 158] =  586, -- Hadronox
    [ 157] =  587, -- Anub'arak
    -- Drak'Tharon Keep
    [ 161] =  591, -- The Prophet Tharon'ja
    -- Halls of Lightning
    [ 138] =  597, -- General Bjarngrim
    -- The Oculus
    [ 143] =  622, -- Drakos the Interrogator
    [ 144] =  623, -- Varos Cloudstrider
    [ 145] =  624, -- Mage-Lord Urom
    [ 146] =  625, -- Ley-Guardian Eregos
    -- Utgarde Keep
    [ 133] =  638, -- Prince Keleseth
    [ 134] =  639, -- Skarvald & Dalronn
    [ 135] =  640, -- Ingvar the Plunderer
    -- Utgarde Pinnacle
    [ 136] =  641, -- Svala Sorrowgrave
    -- The Obsidian Sanctum
    [ 155] = 1616, -- Sartharion
    -- The Eye of Eternity
    [ 141] = 1617, -- Malygos
    -- Trial of the Crusader
    [ 173] = 1623, -- Anub'arak
    -- Icecrown Citadel
    [ 188] = 1628, -- Deathbringer Saurfang
    [ 191] = 1633, -- Blood-Queen Lana'thel
    [ 189] = 1635, -- Sindragosa
    [ 192] = 1636, -- The Lich King
    -- Ulduar
    [ 151] = 1647, -- Mimiron
    -- Onyxia's Lair
    [ 248] = 1651, -- Onyxia
    -- The Ruby Sanctum
    [ 200] = 1652, -- Halion

    -- Cataclysm
    -- Blackrock Caverns
    [ 283] =  105, -- Rom'ogg Bonecrusher
    -- Halls of Origination
    [ 298] =  125, -- Earthrager Ptah
    -- End Time
    [ 404] =  340, -- Echo of Baine
    [ 402] =  285, -- Echo of Jaina
    [ 403] =  323, -- Echo of Sylvanas
    [ 405] =  283, -- Echo of Tyrande
    [ 406] =  289, -- Murozond
    -- Hour of Twilight
    [ 400] =  341, -- Archbishop Benedictus
    -- The Bastion of Twilight
    [ 296] =  168, -- Sinestra
    -- Dragon Soul
    [ 410] =  324, -- Warlord Zon'ozz
    [ 411] =  325, -- Yor'sahj the Unsleeping
    [ 412] =  317, -- Hagara the Stormbinder
    [ 413] =  332, -- Warmaster Blackhorn
    [ 414] =  318, -- Spine of Deathwing
    [ 415] =  333, -- Madness of Deathwing

    -- Mists of Pandaria
    -- Stormstout Brewery
    [ 440] =  668, -- Ook-Ook
    [ 441] =  669, -- Hoptallus
    [ 442] =  670, -- Yan-Zhu the Uncasked
    -- Mogu'shan Palace
    [ 453] =  708, -- Trial of the King
    [ 454] =  690, -- Gekkan
    [ 455] =  698, -- Xin the Weaponmaster
    -- Gate of the Setting Sun
    [ 438] =  675, -- Striker Ga'dok
    -- Siege of Niuzao Temple
    [ 458] =  693, -- Vizier Jin'bak
    -- Throne of Thunder
    [ 508] =  827, -- Jin'rokh the Breaker
    [ 511] =  828, -- Ji-Kun
    [ 514] =  832, -- Lei Shen
    [ 515] =  831, -- Ra-den
    -- Siege of Orgrimmar
    [ 557] =  852, -- Immerseus
    [ 556] =  849, -- The Fallen Protectors
    [ 560] =  856, -- Kor'kron Dark Shaman
    [ 562] =  850, -- General Nazgrim
    [ 563] =  846, -- Malkorok
    [ 565] =  865, -- Siegecrafter Blackfuse
    [ 566] =  853, -- Paragons of the Klaxxi
    [ 567] =  869, -- Garrosh Hellscream

    -- Warlords of Draenor
    -- Skyreach
    [ 602] =  968, -- High Sage Viryx
    -- Grimrail Depot
    [ 606] = 1138, -- Rocketspark and Borka
    -- Shadowmoon Burial Grounds
    [ 575] = 1140, -- Bonemaw
    [ 576] = 1160, -- Ner'zhul
    -- The Everbloom
    [ 621] = 1210, -- Yalnu
    -- Blackrock Foundry
    [ 600] =  959, -- Blackhand
    -- Highmaul
    [ 612] = 1128, -- Kargath Bladefist
    [ 615] = 1197, -- Imperator Mar'gok
    -- Draenor
    [ 542] = 1262, -- Rukhmar
    [ 534] = 1452, -- Supreme Lord Kazzak
    -- Hellfire Citadel
    [ 664] = 1392, -- Kormrok
    [ 662] = 1372, -- Gorefiend
    [ 667] = 1447, -- Xhul'horac
    [ 669] = 1395, -- Mannoroth
    [ 670] = 1438, -- Archimonde

    -- Legion
    -- Vault of the Wardens
    [ 710] = 1467, -- Tirathon Saltheril
    [ 712] = 1470, -- Cordana Felsong
    -- Halls of Valor
    [ 703] = 1487, -- Fenryr
    -- Maw of Souls
    [ 706] = 1502, -- Ymiron, the Fallen King
    -- Black Rook Hold
    [ 751] = 1518, -- The Amalgam of Souls
    [ 752] = 1653, -- Illysanna Ravencrest
    [ 754] = 1664, -- Smashspite the Hateful
    [ 756] = 1672, -- Lord Kur'talos Ravencrest
    -- Court of Stars
    [ 763] = 1720, -- Advisor Melandrus
    -- Return to Karazhan
    [ 811] = 1837, -- Moroes
    [ 809] = 1835, -- Attumen the Huntsman
    [ 817] = 1836, -- The Curator
    [ 818] = 1817, -- Shade of Medivh
    [ 819] = 1818, -- Mana Devourer
    [ 822] = 1838, -- Viz'aduum the Watcher
    -- Cathedral of Eternal Night
    [ 846] = 1905, -- Agronox
    [ 847] = 1906, -- Thrashbite the Scornful
    -- The Emerald Nightmare
    [ 777] = 1703, -- Nythendra
    [ 780] = 1738, -- Il'gynoth, Heart of Corruption
    [ 779] = 1744, -- Elerethe Renferal
    [ 786] = 1667, -- Ursoc
    [ 781] = 1704, -- Dragons of Nightmare
    [ 787] = 1750, -- Cenarius
    [ 788] = 1726, -- Xavius
    -- The Nighthold
    [ 768] = 1762, -- Tichondrius
    [ 767] = 1761, -- High Botanist Tel'arn
    [ 769] = 1732, -- Star Augur Etraeus
    [ 772] = 1737, -- Gul'dan
    -- Trial of Valor
    [ 807] = 1819, -- Odyn
    -- Tomb of Sargeras
    [ 853] = 1897, -- Maiden of Vigilance
    [ 854] = 1873, -- Fallen Avatar
    [ 856] = 1898, -- Kil'jaeden
    -- Antorus, the Burning Throne
    [ 910] = 1997, -- Antoran High Command
    [ 911] = 1985, -- Portal Keeper Hasabel
    [ 913] = 2025, -- Eonar the Life-Binder
    [ 916] = 1983, -- Varimathras
    [ 915] = 1986, -- The Coven of Shivarra
    [ 917] = 1984, -- Aggramar
    [ 918] = 2031, -- Argus the Unmaker

    -- Battle for Azeroth
    -- Atal'Dazar
    [ 935] = 2083, -- Rezan
    -- Tol Dagor
    [ 974] = 2097, -- The Sand Queen
    [ 977] = 2098, -- Jes Howlis
    [ 979] = 2099, -- Knight Captain Valyri
    [ 980] = 2096, -- Overseer Korgus
    -- Waycrest Manor
    [1018] = 2128, -- Lord and Lady Waycrest
    [1029] = 2129, -- Gorak Tul
    -- The Underrot
    [1042] = 2158, -- Unbound Abomination
    -- Temple of Sethraliss
    [1043] = 2145, -- Avatar of Sethraliss
    -- Operation: Mechagon
    [1491] = 2336, -- Tussle Tonks
    [1494] = 2339, -- K.U.-J.0.
    -- Uldir
    [1148] = 2168, -- Taloc
    [1149] = 2167, -- MOTHER
    [1151] = 2169, -- Zek'voz, Herald of N'Zoth
    [1153] = 2146, -- Fetid Devourer
    [1152] = 2166, -- Vectis
    [1154] = 2195, -- Zul, Reborn
    -- Battle of Dazar'alor
    [1353] = 2342, -- Opulence
    [1354] = 2330, -- Conclave of the Chosen
    [1357] = 2335, -- King Rastakhan
    [1364] = 2343, -- Lady Jaina Proudmoore
    -- Crucible of Storms
    [1345] = 2328, -- The Restless Cabal
    [1346] = 2332, -- Uu'nat, Harbinger of the Void
    -- The Eternal Palace
    [1512] = 2352, -- Abyssal Commander Sivara
    [1514] = 2347, -- Blackwater Behemoth
    [1517] = 2351, -- Orgozoa
    [1518] = 2359, -- The Queen's Court
    [1519] = 2349, -- Za'qul, Harbinger of Ny'alotha
    [1520] = 2361, -- Queen Azshara
    -- Ny'alotha, the Waking City
    [1580] = 2368, -- Wrathion, the Black Emperor
    [1592] = 2377, -- Dark Inquisitor Xanesh
    [1590] = 2372, -- The Hivemind
    [1594] = 2367, -- Shad'har the Insatiable
    [1595] = 2373, -- Drest'agath
    [1596] = 2374, -- Il'gynoth, Corruption Reborn
    [1593] = 2370, -- Vexiona
    [1591] = 2364, -- Ra-den the Despoiled

    -- Shadowlands
    -- The Necrotic Wake
    [1667] = 2392, -- Surgeon Stitchflesh
    [1668] = 2396, -- Nalthor the Rimebinder
    -- Plaguefall
    [1697] = 2404, -- Margrave Stradama
    -- Halls of Atonement
    [1664] = 2411, -- High Adjudicator Aleez
    [1665] = 2413, -- Lord Chamberlain
    -- Spires of Ascension
    [1694] = 2414, -- Oryphrion
    [1695] = 2412, -- Devos, Paragon of Doubt
    -- Theater of Pain
    [1683] = {2397, 2417}, -- An Affront of Challengers, and Mordretha, the Endless Empress
    [1687] = 2401, -- Gorechop
    [1684] = 2390, -- Xav the Unfallen
    [1685] = 2389, -- Kul'tharok
    -- De Other Side
    [1679] = 2408, -- Hakkar the Soulflayer
    [1678] = 2409, -- The Manastorms
    [1677] = 2398, -- Dealer Xy'exa
    [1680] = 2410, -- Mueh'zala
    -- Tazavesh, the Veiled Market
    [1990] = 2454, -- The Grand Menagerie
    [1991] = 2436, -- Mailroom Mayhem
    [1992] = 2452, -- Myza's Oasis
    [1997] = 2448, -- Hylbrande
    [1995] = 2448, -- Hylbrande
    [1996] = 2449, -- Timecap'n Hooktail
    [1993] = 2455, -- So'leah
    -- Castle Nathria
    [1746] = 2422, -- Sun King's Salvation
    [1745] = 2418, -- Artificer Xy'mox
    [1744] = 2420, -- Lady Inerva Darkvein
    [1750] = 2426, -- The Council of Blood
    [1748] = 2424, -- Sire Denathrius
    -- Sanctum of Domination
    [1998] = 2435, -- The Tarragrue
    [2002] = 2441, -- Sylvanas Windrunner
    -- Sepulcher of the First Ones
    [2047] = 2458, -- Vigilant Guardian
    [2048] = 2459, -- Dausegne, the Fallen Oracle
    [2050] = 2469, -- Anduin Wrynn
    [2051] = 2464, -- The Jailer

    -- Dragonflight
    -- Brackenhide Hollow
    [2106] = 2474, -- Decatriarch Wratheye
    -- Uldaman: Legacy of Tyr
    [2072] = 2479, -- Chrono-Lord Deios
    -- Neltharus
    [2081] = 2489, -- Forgemaster Gorek
    -- Algeth'ar Academy
    [2098] = 2495, -- Crawth
    [2099] = 2514, -- Echo of Doragosa
    -- The Azure Vault
    [2073] = 2492, -- Leymor
    [2075] = 2505, -- Azureblade
    [2076] = 2483, -- Telash Greywing
    [2077] = 2508, -- Umbrelskul
    -- Ruby Life Pools
    [2095] = 2488, -- Melidrussa Chillworn
    -- Halls of Infusion
    [2082] = 2504, -- Watcher Irideus
    -- Dawn of the Infinite
    [2190] = 2521, -- Chronikar
    [2191] = 2528, -- Manifested Timeways
    [2195] = 2526, -- Tyr, the Infinite Keeper
    [2196] = 2536, -- Morchie
    -- Vault of the Incarnates
    [2119] = 2480, -- Eranog
    [2120] = 2486, -- The Primal Council
    [2121] = 2502, -- Dathea, Ascended
    [2122] = {2500, 2482}, -- Terros, Sennarth, the Cold Breath
    [2124] = 2491, -- Kurog Grimtotem
    [2126] = 2493, -- Broodkeeper Diurna
    [2125] = 2499, -- Raszageth the Storm-Eater
    -- Aberrus, the Shadowed Crucible
    [2167] = 2529, -- The Amalgamation Chamber
    [2168] = 2524, -- Assault of the Zaqali
    [2169] = 2523, -- Echo of Neltharion
    [2170] = 2520, -- Scalecommander Sarkareth
    -- Amirdrassil, the Dream's Hope
    [2232] = {2564, 2554}, -- Gnarlroot, Igira the Cruel
    [2244] = {2557, 2557}, -- Volcoross, Larodar, Keeper of the Flame
    [2240] = {2555, 2556}, -- Council of Dreams, Nymue, Weaver of the Cycle
    [2233] = 2563, -- Smolderon
    [2234] = 2565, -- Tindral Sageswift, Seer of the Flame
    [2237] = 2565, -- Tindral Sageswift, Seer of the Flame
    [2238] = 2519, -- Fyrakk the Blazing

    -- The War Within
    -- The Rookery
    [2316] = 2566, -- Kyrioss
    [2319] = 2567, -- Stormguard Gorren
    [2320] = 2568, -- Voidstone Monstrosity
    -- Priory of the Sacred Flame
    [2308] = 2571, -- Captain Dailcry
    -- Ara-Kara, City of Echoes
    [2358] = 2585, -- Ki'katal the Harvester
    -- Operation: Floodgate
    [2388] = 2651, -- Geezle Gigazap
    -- Nerub-ar Palace
    [2291] = 2611, -- The Bloodbound Horror
    [2293] = 2599, -- Sikran, Captain of the Sureki
    [2295] = 2602, -- Queen Ansurek
    -- Liberation of Undermine
    [2408] = 2644, -- The One-Armed Bandit
    [2411] = 2645, -- Mug'Zee, Heads of Security
    [2409] = 2646, -- Chrome King Gallywix
}
Internal.instanceDifficulties = instanceDifficulties;
Internal.dungeonInfo = dungeonInfo;
Internal.raidInfo = raidInfo;
Internal.scenarioInfo = scenarioInfo;
Internal.battlegroundInfo = battlegroundInfo;
Internal.instanceBosses = instanceBosses;
Internal.npcIDToBossID = npcIDToBossID;
Internal.InstanceAreaIDToBossID = InstanceAreaIDToBossID;
Internal.uiMapIDToBossID = uiMapIDToBossID;

-- AffixesID type: bit shifted and or'd affix ids
-- (level 2 affix) | (level 4 affix << 8) | (level 7 affix << 16) | (level 10 affix << 24)
-- This will be fine aslong as Blizz keeps ids below 255, right now seasonal affixes (except infested)
-- are 117+, infested is 16, everything else is below
-- Affixes are also handled as masks, this ignores the 4th (seasonal) affix and bit shifts 1 by id
-- This might end up falling apart if blizzard goes beyond 32 affixes

local affixLevels = {2, 4, 7, 10}
function Internal.AffixesLevels()
	return ipairs(affixLevels)
end
local affixesByLevel

if Internal.IsBattleForAzerothSeason1 then
    affixesByLevel = {
        [2] = {10, 9},
        [4] = {7, 6, 8, 5, 11},
        [7] = {12, 13, 3, 2, 4, 14},
        [10] = {120},
    }
elseif Internal.IsShadowlandsSeason1 then
    affixesByLevel = {
        [2] = {10, 9},
        [4] = {11, 8, 122, 6, 123, 7},
        [7] = {124, 12, 13, 14, 3, 4},
        [10] = {121},
    }
elseif Internal.IsShadowlandsSeason2 then
    affixesByLevel = {
        [2] = {10, 9},
        [4] = {11, 8, 122, 6, 123, 7},
        [7] = {124, 12, 13, 14, 3, 4},
        [10] = {128},
    }
elseif Internal.IsShadowlandsSeason3 then
    affixesByLevel = {
        [2] = {10, 9},
        [4] = {11, 8, 122, 6, 123, 7},
        [7] = {124, 12, 13, 14, 3, 4},
        [10] = {130},
    }
elseif Internal.IsShadowlandsSeason4 then
    affixesByLevel = {
        [2] = {10, 9},
        [4] = {11, 8, 122, 6, 123, 7},
        [7] = {124, 12, 13, 14, 3, 4},
        [10] = {131},
    }
elseif Internal.IsDragonflightSeason1 then
    affixesByLevel = {
        [2] = {10, 9},
        [4] = {7, 11, 6, 8, 123},
        [7] = {13, 12, 14, 124, 3},
        [10] = {132},
    }
elseif Internal.IsDragonflightSeason4 then
    -- For DF season 4 these levels are incorrect but they dont really need to be correct
    affixesByLevel = {
        [2] = {10, 9},
        [4] = {7, 11, 6, 8, 123},
        [7] = {135, 136, 134, 124, 3},
        [10] = {},
    }
elseif Internal.IsTheWarWithinSeason1 then
    affixesByLevel = {
        [2] = {148, 158, 159, 160, 147},
        [4] = {10, 9},
        [7] = {152},
        [10] = {},
    }
else -- if Internal.IsTheWarWithinSeason2 then
    affixesByLevel = {
        [2] = {148, 158, 162, 160, 147},
        [4] = {10, 9},
        [7] = {152},
        [10] = {},
    }
end
function Internal.Affixes(level)
	level = tonumber(level)
	if level >= 10 then
		return ipairs(affixesByLevel[10])
	elseif level >= 7 then
		return ipairs(affixesByLevel[7])
	elseif level >= 4 then
		return ipairs(affixesByLevel[4])
	elseif level >= 2 then
		return ipairs(affixesByLevel[2])
	end
end

-- A list of affixesIDs along with the mask of available affixes for other levels excludes seasonal affixes,
-- built from affixRotation later
local affixesMask = {};
local function AffixBOR(r, value)
    if value >= 96 then
        r[4] = bit.bor(r[4] or 0, bit.lshift(1, value))
    elseif value >= 64 then
        r[3] = bit.bor(r[3] or 0, bit.lshift(1, value))
    elseif value >= 32 then
        r[2] = bit.bor(r[2] or 0, bit.lshift(1, value))
    else
        r[1] = bit.bor(r[1] or 0, bit.lshift(1, value))
    end
end
local function PushAffixMask(a, b)
    affixesMask[a] = affixesMask[a] or {}
    for i=1,4 do
        affixesMask[a][i] = bit.bor(affixesMask[a][i] or 0, b[i] or 0)
    end
end
function Internal.GetExclusiveAffixes(affixesID)
	affixesID = bit.band(affixesID or 0, 0xffffff)
	return affixesMask[affixesID] or {0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff};
end
function Internal.CompareAffixMasks(a, b)
    return bit.band(a[1] or 0, b[1] or 0) == (a[1] or 0) and
           bit.band(a[2] or 0, b[2] or 0) == (a[2] or 0) and
           bit.band(a[3] or 0, b[3] or 0) == (a[3] or 0) and
           bit.band(a[4] or 0, b[4] or 0) == (a[4] or 0)
end

function Internal.GetAffixesName(affixesID)
	local names = {};
	local icons = {};
	local id = affixesID
	local mask = {}
	local i = 1
	while affixesID > 0 do
		local affixID = bit.band(affixesID, 0xFF);
		affixesID = bit.rshift(affixesID, 8);

		if affixID ~= 0 then
			local name, _, icon = GetAffixInfo(affixID);
            if not name then
                error(format("Unknown affix %d", affixID))
            end
			names[#names+1] = name;
			icons[#icons+1] = format("|T%d:18:18:0:0|t %s", icon, name);

            if affixID ~= 121 then -- Prideful
                AffixBOR(mask, affixID)
            end
		end
		i = i + 1
	end

	return id, table.concat(names, " "), table.concat(icons, ", "), mask
end
local function GetAffixesInfo(...)
	local id = 0;
	local mask = {};
	local names = {};
	local icons = {};
	for i=1,select('#', ...) do
		local affixID = select(i, ...);
		local name, _, icon = GetAffixInfo(affixID);

		if i < 4 then
            AffixBOR(mask, affixID)
		end
		id = bit.bor(bit.rshift(id, 8), bit.lshift(affixID, 24));
		names[#names+1] = name;
		icons[#icons+1] = format("|T%d:18:18:0:0|t %s", icon, name);
	end
	return {
		id = id,
		mask = mask,
		name = table.concat(names, ", "),
		fullName = table.concat(icons, ", "),
	};
end
Internal.GetAffixesInfo = GetAffixesInfo;
local function GetAffixesForID(id)
	return bit.band(id, 0xff), bit.band(bit.rshift(id, 8), 0xff), bit.band(bit.rshift(id, 16), 0xff), bit.band(bit.rshift(id, 24), 0xff)
end
Internal.GetAffixesForID = GetAffixesForID
local affixRotation
if Internal.IsDragonflight then
    affixRotation = {}
elseif Internal.IsShadowlands then
    affixRotation = {
        GetAffixesInfo(10, 11, 124, 121),   -- Fortified, 	Bursting,   Storming,	Prideful
        GetAffixesInfo(9, 8, 12, 121),      -- Tyrannical, 	Sanguine,   Grievous,	Prideful
        GetAffixesInfo(10, 122, 13, 121),   -- Fortified, 	Inspiring,	Explosive, 	Prideful
        GetAffixesInfo(9, 6, 14, 121), 	    -- Tyrannical, 	Raging, 	Quaking, 	Prideful
        GetAffixesInfo(10, 11, 3, 121),	    -- Fortified, 	Bursting, 	Grievous, 	Prideful
        GetAffixesInfo(9, 123, 12, 121),    -- Tyrannical, 	Spiteful, 	Quaking, 	Prideful
        GetAffixesInfo(10, 7, 124, 121),    -- Fortified, 	Bolstering, Storming,	Prideful
        GetAffixesInfo(9, 122, 4, 121),     -- Tyrannical, 	Inspiring,	Necrotic, 	Prideful
        GetAffixesInfo(10, 8, 14, 121),	    -- Fortified, 	Sanguine, 	Quaking, 	Prideful
        GetAffixesInfo(9, 6, 13, 121), 	    -- Tyrannical, 	Raging, 	Explosive, 	Prideful
        GetAffixesInfo(10, 123, 3, 121),	-- Fortified, 	Spiteful, 	Volcanic, 	Prideful
        GetAffixesInfo(9, 7, 4, 121), 	    -- Tyrannical, 	Bolstering, Necrotic, 	Prideful
    };
else
    affixRotation = {
        GetAffixesInfo(10, 7, 12, 120), -- Fortified, 	Bolstering, Grievous, 	Awakened
        GetAffixesInfo(9, 6, 13, 120), 	-- Tyrannical, 	Raging, 	Explosive, 	Awakened
        GetAffixesInfo(10, 8, 12, 120), -- Fortified, 	Sanguine, 	Grievous, 	Awakened
        GetAffixesInfo(9, 5, 3, 120), 	-- Tyrannical, 	Teeming, 	Volcanic, 	Awakened
        GetAffixesInfo(10, 7, 2, 120), 	-- Fortified, 	Bolstering, Skittish, 	Awakened
        GetAffixesInfo(9, 11, 4, 120), 	-- Tyrannical, 	Bursting, 	Necrotic, 	Awakened
        GetAffixesInfo(10, 8, 14, 120),	-- Fortified, 	Sanguine, 	Quaking, 	Awakened
        GetAffixesInfo(9, 7, 13, 120), 	-- Tyrannical, 	Bolstering, Explosive, 	Awakened
        GetAffixesInfo(10, 11, 3, 120),	-- Fortified, 	Bursting, 	Volcanic, 	Awakened
        GetAffixesInfo(9, 6, 4, 120),	-- Tyrannical, 	Raging, 	Necrotic, 	Awakened
        GetAffixesInfo(10, 5, 14, 120),	-- Fortified, 	Teeming, 	Quaking, 	Awakened
        GetAffixesInfo(9, 11, 2, 120),	-- Tyrannical, 	Bursting, 	Skittish, 	Awakened
    };
end
function Internal.AffixRotation()
	return ipairs(affixRotation)
end
-- Fill affixes mask based on Affix Rotation
for _,affixes in Internal.AffixRotation() do
	local ma, mb, mc = bit.band(affixes.id, 0xff), bit.band(affixes.id, 0xff00), bit.band(affixes.id, 0xff0000)
    local a, b, c = ma, bit.rshift(mb, 8), bit.rshift(mc, 16)
    
    local r = {}
    AffixBOR(r, a)
    AffixBOR(r, b)
    AffixBOR(r, c)

	PushAffixMask(ma, r)
	PushAffixMask(mb, r)
	PushAffixMask(mc, r)

	PushAffixMask(bit.bor(ma, mb), r)
	PushAffixMask(bit.bor(mb, mc), r)
	PushAffixMask(bit.bor(ma, mc), r)

	PushAffixMask(bit.band(affixes.id, 0xffffff), r)
end

local areaNameToIDMap = {};
Internal.areaNameToIDMap = areaNameToIDMap;

-- Updates areaNameToIDMap with localized area name to area id
function Internal.UpdateAreaMap()
	local instanceID = select(8, GetInstanceInfo());
	if instanceID and InstanceAreaIDToBossID[instanceID] then
		areaNameToIDMap[instanceID] = areaNameToIDMap[instanceID] or {};
		local map = areaNameToIDMap[instanceID];
		for areaID in pairs(InstanceAreaIDToBossID[instanceID]) do
			local areaName = GetAreaInfo(areaID);
			if areaName then
				map[areaName] = areaID;
			end
		end
	end
end

-- This is only useful when you can go to the bosses room but cant pull it
-- until other bosses are dead, see Lady Ashvane in The Eternal Palace

-- Which bosses have to be dead for the other boss to be available
-- JournalInstanceID to JournalInstanceID[]
local bossRequirements = {
	[2354] = {2347, 2353}, -- Lady Ashvane, requires Blackwater Behemoth and Radiance of Azshara
	[2370] = {2377}, -- Vexiona, requires Dark Inquisitor Xanesh
	[2364] = {2372}, -- Ra-den the Despoiled, requires The Hivemind

    [2417] = {2401, 2390, 2389}, -- Mordretha, the Endless Empress, requires Gorechop, Xav the Unfallen, Kul'tharok
    [2410] = {2408, 2409, 2398}, -- Mueh'zala, requires Hakkar the Soulflayer, The Manastorms, and Dealer Xy'exa

    [2482] = {2500}, -- Sennarth, the Cold Breath, requires Terros
    [2491] = {2500, 2482}, -- Kurog Grimtotem, requires Terros and Sennarth, the Cold Breath

    [2554] = {2564}, -- Igira the Cruel, requires Gnarlroot
    [2557] = {2557}, -- Larodar, Keeper of the Flame, requires Volcoross
    [2556] = {2555}, -- Nymue, Weaver of the Cycle, requires Council of Dreams
}
function Internal.BossAvailable(bossID)
	if IsEncounterComplete(bossID) then
		return false
	end

	local requiredBossIDs = bossRequirements[bossID]
	if requiredBossIDs then
		for _,requiredBossID in ipairs(requiredBossIDs) do
			if not IsEncounterComplete(requiredBossID) then
				return false
			end
		end
	end

	return true
end

function Internal.GetCurrentBoss(unitId)
	local bossID = nil
	local _, instanceType, difficultyID, _, _, _, _, instanceID = GetInstanceInfo();
	if instanceType == "party" or instanceType == "raid" then
		local uiMapID = C_Map.GetBestMapForUnit("player");
        if uiMapID then
            if type(uiMapIDToBossID[uiMapID]) == "table" then
                for _,mapBossID in ipairs(uiMapIDToBossID[uiMapID]) do
                    if Internal.BossAvailable(mapBossID) then
                        bossID = mapBossID or bossID;
                        break
                    end
                end
            else
                bossID = uiMapIDToBossID[uiMapID] or bossID;
            end
        end
		local areaID = instanceID and areaNameToIDMap[instanceID] and areaNameToIDMap[instanceID][GetSubZoneText()] or nil;
		if areaID then
			bossID = InstanceAreaIDToBossID[instanceID][areaID] or bossID;
        end
		if unitId then
			local unitGUID = UnitGUID(unitId);
			if unitGUID and not UnitIsDead(unitId) then
				local type, zero, serverId, instanceId, zone_uid, npcId, spawn_uid = strsplit("-", unitGUID);
				if (type == "Creature" or type == "Vehicle") and tonumber(npcId) then
					bossID = npcIDToBossID[tonumber(npcId)] or bossID;
				end
			end
		end
	end

	return bossID
end
