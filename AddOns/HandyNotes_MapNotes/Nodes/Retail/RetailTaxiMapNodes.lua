local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

function ns.LoadTaxiMapNodesLocationinfo(self)
local db = ns.Addon.db.profile
local nodes = ns.nodes
ns.currentSourceFile = "RetailTaxiMapNodes.lua"

    if not db.activate.HideMapNote then

        if self.db.profile.showTaxiMapNodes then

    -- Vanilla
        -- Kalimdor
            nodes[1209][52345337] = { id = 240, type = "Dungeon", showInZone = true } -- Wailing Caverns
            nodes[1209][58154003] = { id = 226, type = "Dungeon", showInZone = true } -- Ragefire
            nodes[1209][43533230] = { id = 227, type = "Dungeon", showInZone = true } -- Blackfathom Deeps 
            nodes[1209][50756755] = { id = 234, type = "Dungeon", showInZone = true } -- Razorfen Kraul
            nodes[1209][53426972] = { id = 233, type = "Dungeon", showInZone = true } -- Razorfen Downs
            nodes[1209][54247785] = { id = 241, type = "Dungeon", showInZone = true } -- Zul'Farrak
            nodes[1209][49619255] = { id = 69, type = "Dungeon", showInZone = true } -- Lost City of the Tol'vir
            nodes[1209][51019067] = { id = 70, type = "Dungeon", showInZone = true } -- Halls of Origination
            nodes[1209][53019549] = { id = 68, type = "Dungeon", showInZone = true } -- The Vortex Pinnacle
            nodes[1209][38675533] = { id = 232, type = "Dungeon", showInZone = true } -- Maraudon Outside
            nodes[1209][42086744] = { id = 230, type = "Dungeon", showInZone = true } -- Dire Maul - Capital Gardens - West left Entrance 
            nodes[1209][42946530] = { id = 1277, type = "Dungeon", showInZone = true } -- Dire Maul - Gordok Commons - North  
            nodes[1209][45666576] = { id = 1276, type = "Dungeon", showInZone = true } -- Dire Maul - Warpwood Quarter - East above Camp Mojache   
            nodes[1209][43716722] = { id = 1276, type = "Dungeon", showInZone = true } -- Dire Maul - Warpwood Quarter - East above Camp Mojache   
            nodes[1209][53963419] = { id = 78, type = "Raid", showInZone = true } -- Firelands
            nodes[1209][56186970] = { id = 760, type = "Raid", showInZone = true } -- Onyxias Lair
            nodes[1209][42008527] = { id = 743, type = "Raid", showInZone = true } -- Ruins of Ahn'Qiraj
            nodes[1209][40638439] = { id = 744, type = "Raid", showInZone = true } -- Temple of Ahn'Qiraj
            nodes[1209][46839674] = { id = 74, type = "Raid", showInZone = true } -- Throne of the Four Winds
            nodes[1209][49008955] = { id = 1180, type = "Raid", showInZone = true, dnID = L["Instance Entrance"] .. " " .. L["switches weekly between"] .. ":\n• " .. ns.Uldum .. " (" .. ns.Kalimdor ..")" .. "\n• " .. ns.ValeOfEternalBlossoms .. " (" .. ns.Pandaria .. ")" } -- Ny'alotha the Waking City
            nodes[1209][57768408] = { id = { 187, 750, 279, 255, 251, 184, 185, 186, }, type = "MultipleM", showInZone = true } -- Dragon Soul, The Battle for Mount Hyjal, The Culling of Stratholme, Black Morass, Old Hillsbrad Foothills, End Time, Well of Eternity, Hour of Twilight Heroic

        -- Eastern Kingdom
            nodes[1208][53456588] = { id = 239, type = "Dungeon", showInZone = true } -- Uldaman (inside cave) 
            nodes[1208][40738235] = { id = 63, type = "Dungeon", showInZone = true } -- Deadmines
            nodes[1208][47998422] = { id = 76, type = "Dungeon", showInZone = true } -- Zul'gurub
            nodes[1208][42797282] = { id = 238, type = "Dungeon", showInZone = true } -- The Stockade
            nodes[1208][53095635] = { id = 71, type = "Dungeon", showInZone = true } -- Grim Batol
            nodes[1208][50733667] = { id = 246, type = "Dungeon", showInZone = true } -- Scholomance
            nodes[1208][40654277] = { id = 64, type = "Dungeon", showInZone = true } -- Shadowfang Keep
            nodes[1208][52872848] = { id = 236, type = "Dungeon", showInZone = true } -- Stratholme
            nodes[1208][54512929] = { id = 1292, type = "Dungeon", showInZone = true } -- Stratholme Service Entrance 
            nodes[1208][58902435] = { id = 77, type = "Dungeon", showInZone = true } -- Zul'Aman
            nodes[1208][56970333] = { id = 249, type = "Dungeon", showInZone = true } -- Magisters'Terrace
            nodes[1208][30756422] = { id = 65, type = "Dungeon", showInZone = true } -- Throne of the Tides
            nodes[1208][43046006] = { id = 231, type = "Dungeon", showInZone = true } -- Gnomeregan
            nodes[1208][54275818] = { id = 72, type = "Raid", showInZone = true } -- Bastion of Twilight
            nodes[1208][54810415] = { id = 752, type = "Raid", showInZone = true } -- Sunwell Plateau
            nodes[1208][35345158] = { id = 75, type = "Raid", showInZone = true } -- Baradin Hold
            nodes[1276][45914659] = { id = 75, type = "Raid", showInZone = true } -- Baradin Hold            
            nodes[1208][49248149] = { id = { 745, 860 }, type = "MultipleM", showInZone = true } -- Karazhan, Return to Karazhan
            nodes[1208][45793052] = { id = { 311, 316 }, type = "MultipleD", showInZone = true } -- Scarlet Halls, Monastery 
            nodes[1208][52276471] = { id = { 1197, 239 }, type = "MultipleD", showInZone = true } --  Legacy of Tyr Dragonflight Dungeon & Vanilla Uldaman 
            nodes[1208][47556919] = { id = { 741, 742, 66, 228, 229, 559 }, name = L["Way to the Instance Entrance"], type = "MultipleM", showInZone = true } -- Molten Core, Blackwing Lair, Blackrock Caverns, Blackrock Depths, Lower Blackrock Spire, Upper Blackrock Spire 
            nodes[1208][46573128] = { name = ns.ScarletMonastery .. " - " .. L["Old Version"] .. ":\n" .. L["Graveyard"] .. "\n" .. L["Cathedral"] .. "\n" .. L["Library"] .. "\n" .. L["Armory"] .. "\n\n" .. REQUIRES_LABEL .. " (" .. L["Old Keyring \n You get the Scarlet Key in the \n [Loot-Filled Pumpkin] from [Hallow's End Event] or from the [Auction House] \n now you can activate the [Old Keyring] here \n to activate old dungeonversions from the Scarlet Monastery"] .. ")", type = "MultiVInstanceD", showInZone = true } -- Scarlet Monastery Key for Old dungeons
            nodes[1208][51333601] = { name = ns.Scholomance .. " - " .. L["Old Version"] .. "\n" .. L["Secret Entrance"] .. "\n\n" .. REQUIRES_LABEL .. " " .. L["(Memory of Scholomance - Achievement)"], type = "VInstanceD", showInZone = true } -- Old Scholomance version - Memory of Scholomance - Secret Entrance Old Scholomance version            
            nodes[1208][53493061] = { name = ns.Naxxramas .. " - " .. L["Old Version"] .. "\n" .. L["Secret Entrance"] .. "\n\n" .. REQUIRES_LABEL .. " " .. L["(Wards of the Dread Citadel - Achievement)"], type = "VInstanceR", showInZone = true }-- Old Naxxramas version - Secret Entrance - Wards of the Dread Citadel 

    -- Burning Crusade
        -- Outland
            nodes[1467][44487857] = { id = 247, type = "Dungeon", showInZone = true } -- Auchenai Crypts 
            nodes[1467][46027626] = { id = 250, type = "Dungeon", showInZone = true } -- Mana-Tombs 
            nodes[1467][47577861] = { id = 252, type = "Dungeon", showInZone = true } -- Sethekk Halls 
            nodes[1467][46028099] = { id = 253, type = "Dungeon", showInZone = true } -- Shadow Labyrinth 
            nodes[1467][65842044] = { id = 257, type = "Dungeon", showInZone = true } -- The Botanica 
            nodes[1467][65542528] = { id = 258, type = "Dungeon", showInZone = true } -- The Mechanar  
            nodes[1467][66722143] = { id = 254, type = "Dungeon", showInZone = true } -- The Arcatraz
            nodes[1467][66452335] = { id = 749, type = "Raid", showInZone = true } -- The Eye  
            nodes[1467][72298069] = { id = 751, type = "Raid", showInZone = true } -- Black Temple 
            nodes[1467][45131901] = { id = 746, type = "Raid", showInZone = true } -- Gruul's Lairend
            nodes[1467][56695240] = { mnID = 100, id = { 747, 248, 256, 259 }, type = "MultipleM", showInZone = true } -- Hellfire Ramparts, The Blood Furnace, The Shattered Halls, Magtheridon's Lair 
            nodes[1467][34624490] = { mnID = 102, id = { 748, 260, 261, 262 }, type = "MultipleM", showInZone = true } -- Slave Pens, The Steamvault, The Underbog, Serpentshrine Cavern

    -- Wrath of the Lich King
        -- Northrend
            nodes[1384][78637947] = { id = 285, type = "Dungeon", showInZone = true } -- Utgarde Keep, at doorway entrance 
            nodes[1384][78717555] = { id = 286, type = "Dungeon", showInZone = true } -- Utgarde Pinnacle 
            nodes[1384][62335096] = { id = 273, type = "Dungeon", showInZone = true } -- Drak'Tharon Keep 
            nodes[1384][74373542] = { id = 274, type = "Dungeon", showInZone = true } -- Gundrak Left Entrance 
            nodes[1384][75943735] = { id = 274, type = "Dungeon", showInZone = true } -- Gundrak Right Entrance 
            nodes[1384][50534263] = { id = 283, type = "Dungeon", showInZone = true } -- Violet Hold
            nodes[1384][59361542] = { id = 275, type = "Dungeon", showInZone = true } -- Halls of Lightning 
            nodes[1384][56041765] = { id = 277, type = "Dungeon", showInZone = true } -- Halls of Stone 
            nodes[1384][57871384] = { id = 759, type = "Raid", showInZone = true } -- Ulduar
            nodes[1384][57085843] = { id = 754, type = "Raid", showInZone = true } -- Naxxramas 
            nodes[1384][41373922] = { id = 758, type = "Raid", showInZone = true } -- Icecrown Citadel 
            nodes[1384][36724594] = { id = 753, type = "Raid", showInZone = true } -- Vault of Archavon
            nodes[1384][46231988] = { id = { 757, 284 }, type = "MultipleM", showInZone = true } -- Trial of the Crusader, Trial of the Champion 
            nodes[1384][40295799] = { id = { 271, 272 }, type = "MultipleD", showInZone = true } -- Ahn'kahet The Old Kingdom, Azjol-Nerub        
            nodes[1384][41304372] = { id = { 276, 278, 280 }, type = "MultipleD", showInZone = true } -- The Forge of Souls, Halls of Reflection, Pit of Saron         
            nodes[1384][14525732] = { id = { 756, 282, 281 }, type = "MultipleM", showInZone = true } -- The Eye of Eternity, The Nexus, The Oculus
            nodes[1384][50346126] = { id = { 755, 761 }, type = "MultipleR", showInZone = true } -- The Ruby Sanctum, The Obsidian Sanctum 
            nodes[1402][21509445] = { id = 283, type = "Dungeon", showInZone = true } -- Violet Hold
            nodes[1402][87016710] = { id = 274, type = "Dungeon", showInZone = true } -- Gundrak Left Entrance 
            nodes[1402][48792104] = { id = 275, type = "Dungeon", showInZone = true } -- Halls of Lightning 
            nodes[1402][36322997] = { id = 277, type = "Dungeon", showInZone = true } -- Halls of Stone 
            nodes[1402][41281285] = { id = 759, type = "Raid", showInZone = true } -- Ulduar
            nodes[1402][10113533] = { id = { 757, 284 }, type = "MultipleM", showInZone = true } -- Trial of the Crusader, Trial of the Champion 

    -- Mists of Pandaria
        -- Pandaria
            nodes[1923][70965322] = { id = 313, type = "Dungeon", showInZone = true } -- Temple of the Jade Serpent 
            nodes[1923][46737115] = { id = 302, type = "Dungeon", showInZone = true } -- Stormstout Brewery
            nodes[1923][40002920] = { id = 312, type = "Dungeon", showInZone = true } -- Shado-Pan Monastery
            nodes[1923][23915139] = { id = 324, type = "Dungeon", showInZone = true } -- Siege of Niuzao Temple 
            nodes[1923][42975779] = { id = 303, type = "Dungeon", showInZone = true } -- Gate of the Setting Sun 
            nodes[1923][53745257] = { id = 321, type = "Dungeon", showInZone = true } -- Mogu'shan Palace (moved location cause of the LFR position)
            nodes[1923][48672459] = { id = 317, type = "Raid", showInZone = true } -- Mogu'shan Vaults 
            nodes[1923][53095359] = { id = 369, type = "Raid", showInZone = true } -- Siege of Orgrimmar 
            nodes[1923][30356403] = { id = 330, type = "Raid", showInZone = true } -- Heart of Fear 
            nodes[1923][23390858] = { id = 362, type = "Raid", showInZone = true } -- Throne of Thunder
            nodes[1923][57025487] = { id = 320, type = "Raid", showInZone = true } -- Terrace of Endless Spring  
            nodes[1923][47695411] = { id = 1180, type = "Raid", showInZone = true, dnID = L["Instance Entrance"] .. " " .. L["switches weekly between"] .. ":\n• " .. ns.Uldum .. " (" .. ns.Kalimdor ..")" .. "\n• " .. ns.ValeOfEternalBlossoms .. " (" .. ns.Pandaria .. ")" } -- Ny'Alotha, The Waking City

    -- Warlord of Draenor
        -- Draenor
            nodes[1922][34102566] = { id = 385, type = "Dungeon", showInZone = true } -- Bloodmaul Slag Mines
            nodes[1922][51322183] = { id = 536, type = "Dungeon", showInZone = true } -- Grimrail Depot
            nodes[1922][52932678] = { id = 556, type = "Dungeon", showInZone = true } -- The Everbloom
            nodes[1922][47961477] = { id = 558, type = "Dungeon", showInZone = true } -- Iron Docks
            nodes[1922][53196866] = { id = 537, type = "Dungeon", showInZone = true } -- Shadowmoon Burial Grounds
            nodes[1922][42607342] = { id = 476, type = "Dungeon", showInZone = true } -- Skyreach
            nodes[1922][40256374] = { id = 547, type = "Dungeon", showInZone = true } -- Auchindoun
            nodes[1922][56854685] = { id = 669, type = "Raid", showInZone = true } -- Hellfire Citadel
            nodes[1922][49992014] = { id = 457, type = "Raid", showInZone = true } -- Blackrock Foundry
            nodes[1922][21125032] = { id = 477, type = "Raid", showInZone = true } -- Highmaul

    -- BFA
        -- Nazjatar    
            nodes[1504][50381096] = { id = 1179, type = "Raid", showInZone = true } -- The Eternal Palace   

        -- Zandalar
            if self.faction == "Horde" then
              nodes[1011][56747132] = { id = 1012, type = "Dungeon", showInZone = true } -- The Motherlode
            end

            if self.faction == "Alliance" then
              nodes[1011][44787764] = { id = 1012, type = "Dungeon", showInZone = true } -- The MOTHERLODe
            end

            nodes[1011][44905973] = { id = 1041, type = "Dungeon", showInZone = true } -- Kings' Rest
            nodes[1011][47725938] = { id = 968, type = "Dungeon", showInZone = true } -- Atal'Dazar
            nodes[1011][58843678] = { id = 1022, type = "Dungeon", showInZone = true } -- The Underrot
            nodes[1011][40201498] = { id = 1030, type = "Dungeon", showInZone = true } -- Temple of Sethraliss
            nodes[1011][55115456] = { id = 1176, type = "Raid", showInZone = true } -- Battle of Dazar'alor
            nodes[1011][59353484] = { id = 1031, type = "Raid", showInZone = true } -- Uldir

        -- Kul Tiras
            if self.faction == "Alliance" then
              nodes[1014][61575027] = { id = 1023, type = "Dungeon", showInZone = true } -- Siege of Boralus
              nodes[1014][62155489] = { id = 1176, type = "Raid", showInZone = true } -- Battle of Dazar'alor
            end

            if self.faction == "Horde" then
              nodes[1014][70966366] = { id = 1023, type = "Dungeon", showInZone = true } -- Siege of Boralus
            end

            nodes[1014][65831698] = { id = 1036, type = "Dungeon", showInZone = true } -- Shrine of Storm 
            nodes[1014][18342795] = { id = 1178, type = "Dungeon", showInZone = true } -- Operation: Mechagon 
            nodes[1014][67047975] = { id = 1001, type = "Dungeon", showInZone = true } -- Freehold 
            nodes[1014][31445383] = { id = 1021, type = "Dungeon", showInZone = true } -- Waycrest Manor 
            nodes[1014][78616136] = { id = 1002, type = "Dungeon", showInZone = true } -- Tol Dagor
            nodes[1014][67142288] = { id = 1036, type = "Raid", showInZone = true } -- Crucible of Storms

    -- Legion
        -- Broken Isles
            nodes[993][28423416] = { id = 740, type = "Dungeon", showInZone = true } -- Black Rook Hold
            nodes[993][33957188] = { id = 707, type = "Dungeon", showInZone = true } -- Vault of the Wardens
            nodes[993][38285817] = { id = 716, type = "Dungeon", showInZone = true } -- Eye of Azshara
            nodes[993][46296781] = { id = 777, type = "Dungeon", showInZone = true } -- Assault on Violet Hold
            nodes[993][56086098] = { id = 900, type = "Dungeon", showInZone = true } -- Cathedral of Eternal Night
            nodes[993][36492786] = { id = 762, type = "Dungeon", showInZone = true } -- Darkheart Thicket
            nodes[993][49444938] = { id = 800, type = "Dungeon", showInZone = true } -- Court of Stars
            nodes[993][47864933] = { id = 726, type = "Dungeon", showInZone = true } -- The Arcway
            nodes[993][45932857] = { id = 767, type = "Dungeon", showInZone = true } -- Neltharion's Lair
            nodes[993][59243069] = { id = 727, type = "Dungeon", showInZone = true } -- Maw of Souls
            nodes[993][65503711] = { id = 721, type = "Dungeon", showInZone = true } -- Halls of Valor
            nodes[993][55986339] = { id = 875, type = "Raid", showInZone = true } -- Tomb of Sargeras
            nodes[993][48454777] = { id = 786, type = "Raid", showInZone = true } -- The Nighthold
            nodes[993][34752937] = { id = 768, type = "Raid", showInZone = true } -- The Emerald Nightmare
            nodes[993][64083891] = { id = 861, type = "Raid", showInZone = true } -- Trial of Valor
        -- Argus
            nodes[994][33793542] = { id = 945, type = "Dungeon", showInZone = true } -- Seat of the Triumvirate
            nodes[994][22528337] = { id = 946, type = "Raid", showInZone = true } -- Antorus, the Burning Throne
            
    -- Shadowlands
        -- Shadowlands
            nodes[1647][68845981] = { id = 1182, type = "Dungeon", showInZone = true } -- The Necrotic Wake
            nodes[1647][74075232] = { id = 1186, type = "Dungeon", showInZone = true } -- Spires of Ascension
            nodes[1647][65142530] = { id = 1183, type = "Dungeon", showInZone = true } -- Plaguefall
            nodes[1647][63252202] = { id = 1187, type = "Dungeon", showInZone = true } -- Theater of Pain
            nodes[1647][44348287] = { id = 1184, type = "Dungeon", showInZone = true } -- Mists of Tirna Scithe
            nodes[1647][54338521] = { id = 1188, type = "Dungeon", showInZone = true } -- The Other Side
            nodes[1647][30995278] = { id = 1185, type = "Dungeon", showInZone = true } -- Halls of Atonement
            nodes[1647][25224904] = { id = 1189, type = "Dungeon", showInZone = true } -- Sanguine Depths
            nodes[1647][30787741] = { id = 1194, type = "Dungeon", showInZone = true } -- Tazavesh, the Veiled Market
            nodes[1647][23735036] = { id = 1190, type = "Raid", showInZone = true } -- Castle Nathria
            nodes[1647][27910861] = { id = 1193, type = "Raid", showInZone = true } -- Sanctum of Domination
        -- Bastion
            nodes[1569][39715521] = { id = 1182, type = "Dungeon", showInZone = true } -- The Necrotic Wake
            nodes[1569][58562847] = { id = 1186, type = "Dungeon", showInZone = true } -- Spires of Ascension
        -- Maldraxxus
            nodes[1741][57826229] = { id = 1183, type = "Dungeon", showInZone = true } -- Plaguefall
            nodes[1741][53205314] = { id = 1187, type = "Dungeon", showInZone = true } -- Theater of Pain
        -- Ardenweald
            nodes[1740][35625390] = { id = 1184, type = "Dungeon", showInZone = true } -- Mists of Tirna Scithe
            nodes[1740][68166412] = { id = 1188, type = "Dungeon", showInZone = true } -- The Other Side
        -- Revendreth
            nodes[1742][78204871] = { id = 1185, type = "Dungeon", showInZone = true } -- Halls of Atonement
            nodes[1742][51243157] = { id = 1189, type = "Dungeon", showInZone = true } -- Sanguine Depths
            nodes[1742][46944137] = { id = 1190, type = "Raid", showInZone = true } -- Castle Nathria
        -- Zereth Morthis
            nodes[2046][80685337] = { id = 1195, type = "Raid", showInZone = true } -- Sepulcher of the First Ones 

    -- Dragonflight
        -- Dragon Isles
            nodes[2057][43625184] = { id = 1198, type = "Dungeon", showInZone = true } -- The Nokhud Offensive
            nodes[2057][38896459] = { id = 1203, type = "Dungeon", showInZone = true } -- The Azure Vault
            nodes[2057][34667598] = { id = 1196, type = "Dungeon", showInZone = true } -- Brackenhide Hollow
            nodes[2057][63655934] = { id = 1209, type = "Dungeon", showInZone = true } -- Dawn of the Infinite
            nodes[2057][63324926] = { id = 1204, type = "Dungeon", showInZone = true } -- Halls of Infusion
            nodes[2057][62774192] = { id = 1201, type = "Dungeon", showInZone = true } -- Algeth'ar Academy
            nodes[2057][53084176] = { id = 1202, type = "Dungeon", showInZone = true } -- Ruby Life Pools
            nodes[2057][42463449] = { id = 1199, type = "Dungeon", showInZone = true } -- Neltharus
            nodes[2057][31075615] = { id = 1207, type = "Raid", showInZone = true } -- Amirdrassil, the Dream's Hope
            nodes[2057][70534613] = { id = 1200, type = "Raid", showInZone = true } -- Vault of the Incarnates
            nodes[2057][87017348] = { id = 1208, type = "Raid", showInZone = true } -- Aberrus, the Shadowed Crucible    
            nodes[2175][48451191] = { id = 1208, type = "Raid", showInZone = true } -- Aberrus, the Shadowed Crucible    
            nodes[2175][86588282] = { id = { 1207, 1200, 1198, 1203, 1196, 1209, 1204, 1201, 1202, 1199 }, type = "MultipleM", showInZone = true } -- all instances without Aberrus    
            nodes[2241][27123042] = { id = 1207, type = "Raid", showInZone = true } -- Amirdrassil, the Dream's Hope

    -- The war Within
        -- Khaz Algar
            nodes[2276][60244695] = { id = 1210, type = "Dungeon", showInZone = true } -- Darkflame Cleft
            nodes[2276][34935330] = { id = 1267, type = "Dungeon", showInZone = true } -- Priory of the Sacred Flame
            nodes[2276][40845861] = { id = 1270, type = "Dungeon", showInZone = true } -- The Dawnbreaker
            nodes[2276][53244131] = { id = 1269, type = "Dungeon", showInZone = true } -- The Stonevault
            nodes[2276][52735580] = { id = 1298, type = "Dungeon", showInZone = true } -- Operation: Floodgate
            nodes[2276][69881888] = { id = 1268, type = "Dungeon", showInZone = true } -- The Rookery
            nodes[2276][84172009] = { id = 1272, type = "Dungeon", showInZone = true } -- Cinderbrew Meadery
            nodes[2276][43578504] = { id = 1271, type = "Dungeon", showInZone = true } -- Ara-Kara, City of Echoes
            nodes[2276][43408075] = { id = 1274, type = "Dungeon", showInZone = true } -- City of Threads
            nodes[2276][41388856] = { id = 1273, type = "Raid", showInZone = true } -- Nerub-ar Palace
        -- Undermine
            nodes[2374][40295066] = { id = 1296, type = "Raid", showInZone = true } -- Liberation of Undermine
        -- K'aresh
            nodes[2398][65196877] = { id = 1303, type = "Dungeon", showInZone = true } -- Eco-Dome Al'dani
            nodes[2398][63657119] = { id = 1194, type = "Dungeon", showInZone = true } -- Tazavesh, the Veiled Market
            nodes[2398][42402157] = { id = 1302, type = "Raid", showInZone = true } -- Manaforge Omega

        end
    end
end