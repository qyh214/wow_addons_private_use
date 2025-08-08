local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

function ns.LoadInsideDungeonNodesLocationInfo(self)
local db = ns.Addon.db.profile
local nodes = ns.nodes
ns._currentSourceFile = "RetailInsideDungeonNodesLocation.lua"

--#####################################################################################################
--##########################        function to hide all nodes below         ##########################
--#####################################################################################################
  if not db.activate.HideMapNote then

    --#####################################################################################################
    --##################################           Dungeon Map           ##################################
    --#####################################################################################################
    
    if db.activate.DungeonMap then

        --################################
        --## Inside Dungeon PVE Vendor  ##
        --################################

        if self.db.profile.showDungeonVendor then

          -- IcecrownGlacier
          nodes[186][38202160] = { name = "", dnID = TRANSMOG_SET_PVE .. " " .. MERCHANT .. "\n" .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. "\n" .. AUCTION_CATEGORY_WEAPONS, type = "PvEVendor", showInZone = true }
        
        end
    
    
        --################################
        --##### Inside Dungeon Exits  ####
        --################################
    
          if self.db.profile.showDungeonExit then
    
    
        --#############################
        --#### Kalimdor Exit Notes ####
        --#############################
            nodes[280][62402795] = { mnID = 67, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Maraudon Caverns of Maraudon Orange Crystal
            nodes[280][78676842] = { mnID = 68, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Maraudon Caverns of Maraudon Purple Crystal 
            nodes[324][54089545] = { mnID = 207, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- The Stonecore
            nodes[325][54241642] = { mnID = 1527, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- The Vortex Pinnacle
            nodes[297][50009404] = { mnID = 1527, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Halls of Orientation
            nodes[277][32581995] = { mnID = 1527, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Lost City of the Tol'vir
            nodes[328][47177426] = { mnID = 1527, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Throne of the Four Winds
            nodes[247][61141177] = { mnID = 81, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Ruins of Ahn'Qiraj
            nodes[320][52352694] = { mnID = 81, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Temple of Ahn'Qiraj
            nodes[219][56288980] = { mnID = 71, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Zul'Farrak
            nodes[409][49698368] = { mnID = 75, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Dragon Soul
            nodes[130][86417097] = { mnID = 75, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- The Culling of Stratholme
            nodes[273][49531493] = { mnID = 75, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- The Black Morass
            nodes[274][27084695] = { mnID = 75, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Old Hillsbrad Foothills
            nodes[401][82964460] = { mnID = 75, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- End Time
            nodes[398][28456261] = { mnID = 75, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Well of Eternity
            nodes[399][48001952] = { mnID = 75, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Hour of Twilight
            nodes[248][33992035] = { mnID = 70, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Onyxia Lair
            nodes[300][23471893] = { mnID = 199, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Razorfen Downs
            nodes[301][71358352] = { mnID = 199, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Razorfen Kraul
            nodes[240][28185543] = { mnID = 69, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Dire Maul Warpwood Quarter 
            nodes[235][71829239] = { mnID = 69, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Dire Maul Gordok Commons
            nodes[236][93635048] = { mnID = 69, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Dire Maul Capital Gardens
            nodes[236][93637191] = { mnID = 69, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Dire Maul Capital Gardens
            nodes[239][26778493] = { mnID = 69, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Dire Maul Warpwood Quarter
            nodes[239][92544766] = { mnID = 69, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Dire Maul Warpwood Quarter
            nodes[279][46235920] = { mnID = 10, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Wailing Caverns
            nodes[213][60990723] = { mnID = 86, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true} -- Ragefire Chasm
            nodes[221][45131069] = { mnID = 63, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Blackfathom Deeps
            nodes[367][24579004] = { mnID = 198, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Firelands
            nodes[1580][52648361] = { mnID = 1527, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Ny'Alotha, The Waking City
        --####################################
        --#### Eastern Kingdom Exit Notes ####
        --####################################
            nodes[220][49841022] = { mnID = 51, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Tempel of Atal'hakkar
            nodes[225][50008109] = { mnID = 84, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- The Stockade  
            nodes[226][64132741] = { mnID = 27, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Gnomeregan          
            nodes[230][28506908] = { mnID = 15, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Uldaman
            nodes[230][67897238] = { mnID = 16, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Uldaman
            nodes[232][25832277] = { mnID = 35, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Molten Core
            nodes[242][33207928] = { mnID = 35, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Blackwing Depths
            nodes[253][36814201] = { mnID = 33, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Lower Blackrock Spire
            nodes[252][37854109] = { mnID = 33, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Lower Blackrock Spire
            nodes[282][47969035] = { mnID = 244, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Baradin Hold
            nodes[283][31016916] = { mnID = 34, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Blackwing Caverns      
            nodes[285][46866374] = { mnID = 36, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Blackwing Descent
            nodes[287][52518345] = { mnID = 33, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Blackwing Lair
            nodes[291][29751328] = { mnID = 52, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Deadmines
            nodes[293][07935708] = { mnID = 241, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Grim Batol
            nodes[294][39335449] = { mnID = 241, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- The Bastion of Twilight
            nodes[302][83118250] = { mnID =19, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Old Scarlet Monastery - Graveyard
            nodes[303][13112473] = { mnID =19, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Old Scarlet Monastery - Library
            nodes[304][60849535] = { mnID =19, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Old Scarlet Monastery - Armory
            nodes[305][61999199] = { mnID =19, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Old Scarlet Monastery - Cathedral              
            nodes[306][39146031] = { mnID = 22, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Old Scholomance  
            nodes[310][70406108] = { mnID = 21, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Shadowfang Keep  
            nodes[317][68798791] = { mnID = 23, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Stratholme - Main Gate
            nodes[317][63888791] = { mnID = 23, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Stratholme - Main Gate
            nodes[318][65859058] = { mnID = 23, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Stratholme Service Entrance
            nodes[322][49849388] = { mnID = 203, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Throne of the Tides      
            nodes[333][09195307] = { mnID = 95, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Zul'Aman
            nodes[335][30853659] = { mnID = 122, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Sunwell Plateau
            nodes[337][29124867] = { mnID = 50, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Zul'Gurub
            nodes[349][42629380] = { mnID = 122, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Magisters'Terrace      
            nodes[350][61778163] = { mnID = 42, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Karazhan
            nodes[355][64416079] = { mnID = 42, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Karazhan
            nodes[431][33998886] = { mnID = 18, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Scarlet Halls
            nodes[435][79354554] = { mnID = 18, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Scarlet Monastery
            nodes[476][17827050] = { mnID = 22, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Scholomance      
            nodes[616][37293212] = { mnID = 33, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Upper Blackrock Spire
            nodes[809][61778163] = { mnID = 42, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Return to Karazhan
            nodes[814][64286068] = { mnID = 42, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Return to Karazhan
            nodes[2071][75274137] = { mnID = 15, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Uldaman Legacy of Tyr
        --#############################
        --#### Outland Exit Notes #####
        --#############################
            nodes[340][21756343] = { mnID = 104, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Black Temple exit
            nodes[334][50168768] = { mnID = 109, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- The Eye
            nodes[330][81397732] = { mnID = 108, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Gruul
            nodes[331][60991776] = { mnID = 100, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Magtheridons
            nodes[332][13436343] = { mnID = 102, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Serpentshrine Cavern
            nodes[266][90343942] = { mnID = 109, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Botanica
            nodes[267][49378580] = { mnID = 109, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Mechanar
            nodes[269][41378627] = { mnID = 109, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Arcatraz
            nodes[265][21121328] = { mnID = 102, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Slave Pens
            nodes[263][17353047] = { mnID = 102, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Steamvault
            nodes[347][52207097] = { mnID = 100, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Hellfire Ramparts
            nodes[262][28027003] = { mnID = 102, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- The Underbog
            nodes[261][48439051] = { mnID = 100, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Blood Furnace
            nodes[260][21750952] = { mnID = 108, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Shadow Labyrinth
            nodes[246][61929285] = { mnID = 100, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Shattered Halls
            nodes[258][73393824] = { mnID = 108, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Sethekk Halls
            nodes[272][33361564] = { mnID = 108, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Mana Tombs
            nodes[256][44197716] = { mnID = 108, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Auchenai Crypts
        --#############################
        --#### Northrend Exit Notes ####
        --#############################
            nodes[129][36818875] = { mnID = 114, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- The Nexus
            nodes[132][89717928] = { mnID = 115, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Ahn'kahet
            nodes[132][07155048] = { mnID = 115, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Ahn'kahet
            nodes[133][69787598] = { mnID = 117, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Utgarde Keep
            nodes[137][44511493] = { mnID = 117, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Utgarde Pinnacle
            nodes[138][04175378] = { mnID = 120, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Halls of Lightning
            nodes[140][33993643] = { mnID = 120, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Halls of Stone
            nodes[142][51465242] = { mnID = 114, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- The Oculus
            nodes[143][60834860] = { mnID = 114, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- The Oculus
            nodes[147][52519647] = { mnID = 120, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Ulduar
            nodes[154][36812906] = { mnID = 121, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } --  Gundrak
            nodes[154][56592435] = { mnID = 121, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } --  Gundrak
            nodes[155][63654954] = { mnID = 115, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Sanctum of Obsidian
            nodes[156][49218634] = { mnID = 123, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Vault of Archavon
            nodes[159][12338705] = { mnID = 115, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Azjol Nerub
            nodes[157][88307487] = { mnID = 115, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Azjol Nerub
            nodes[160][27718116] = { mnID = 121, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Drak'Tharon Keep
            --nodes[166][53144954] = { mnID = 115, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Naxxramas
            nodes[168][45929293] = { mnID = 125, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Violet Keep
            nodes[171][65705291] = { mnID = 118, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Trial of the Champion
            nodes[172][65705260] = { mnID = 118, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Trial of the Crusader
            nodes[183][65858917] = { mnID = 118, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- The Forge of Souls
            nodes[184][40607992] = { mnID = 118, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Pit of Saron
            nodes[185][47338069] = { mnID = 118, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Halls of Reflection
            nodes[186][38860982] = { mnID = 118, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- IcecrownGlacier
            nodes[200][49532819] = { mnID = 115, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Sanctum of Ruby
        --#############################
        --#### Pandaria Exit Notes ####
        --#############################
            nodes[429][29594366] = { mnID = 371, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- The Temple of the Jade Serpent
            nodes[456][92544884] = { mnID = 433, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Terrace of Endless Spring
            nodes[557][94264530] = { mnID = 390, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Siege of Orgrimmar
            nodes[453][28181995] = { mnID = 390, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Mogu'shan Palace
            nodes[437][61618815] = { mnID = 390, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Gate of the Setting Sun
            nodes[439][80293902] = { mnID = 376, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Stormstout Brewery
            nodes[474][34159074] = { mnID = 422, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Heart of Fear
            nodes[458][65228587] = { mnID = 388, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Siege of Niuzao Temple
            nodes[444][86415833] = { mnID = 579, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Shado-Pan Monastery
            nodes[471][75437521] = { mnID = 379, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Mogu'shan Vaults
            nodes[508][29592553] = { mnID = 504, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Throne of Thunder
        --#############################
        --#### Draenor Exit Notes #####
        --#############################
            nodes[573][52048698] = { mnID = 525, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Bloodmaul Slag Mines  
            nodes[574][08256955] = { mnID = 539, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Shadowmoon Burial Grounds  
            nodes[593][49849145] = { mnID = 535, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Auchindoun
            nodes[595][29594366] = { mnID = 543, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Iron Docks
            nodes[598][41059246] = { mnID = 543, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Blackrock Foundry
            nodes[601][60362459] = { mnID = 542, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Skyreach
            nodes[606][32422553] = { mnID = 543, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Grimrail Depoot
            nodes[611][26772324] = { mnID = 550, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Highmaul
            nodes[610][65258604] = { mnID = 550, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Highmaul
            nodes[612][57026083] = { mnID = 550, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Highmaul
            nodes[620][72295519] = { mnID = 543, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Everbloom
            nodes[661][72604342] = { mnID = 534, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Hellfire Citadel 
        --#############################
        --##### Legion Exit Notes #####
        --#############################
            nodes[704][47730708] = { mnID = 634, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Halls of Valor  
            nodes[706][46398375] = { mnID = 634, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Maw of Souls
            nodes[710][69317756] = { mnID = 630, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Vault of the Wardens
            nodes[713][49378886] = { mnID = 630, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Eye of Azshara
            nodes[731][89555449] = { mnID = 650, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Neltharion's Lair
            nodes[732][50788086] = { mnID = 627, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Assault on Violet Hold
            nodes[733][36661564] = { mnID = 641, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Darkheart Thicket
            nodes[749][48122160] = { mnID = 680, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- The Arcway
            nodes[751][29120622] = { mnID = 641, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Black Rook Hold
            nodes[761][05476847] = { mnID = 680, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Court of Stars
            nodes[761][41877597] = { mnID = 680, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Court of Stars
            nodes[764][25518846] = { mnID = 680, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- The Nighthold
            nodes[765][34772536] = { mnID = 680, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- The Nighthold
            nodes[777][42315825] = { mnID = 641, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- The Emerald Nightmare
            nodes[807][51570575] = { mnID = 634, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Trial of Valor
            nodes[845][46639166] = { mnID = 646, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Cathedral of Eternal Night
            nodes[850][45139239] = { mnID = 646, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Tomb of Sargeras
            nodes[903][21468879] = { mnID = 882, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Seat of the Triumvirate
            nodes[909][90656704] = { mnID = 885, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Antorus, the Burning Throne
        --######################################
        --#### Battle of Azeroth Exit Notes ####
        --######################################
            nodes[934][79514836] = { mnID = 862, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Atal'Dazar
            nodes[936][70563589] = { mnID = 895, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Freehold
            nodes[974][75275526] = { mnID = 895, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Tol Dagor
            nodes[1004][89874719] = { mnID = 862, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Kings Rest
            nodes[1015][51418674] = { mnID = 896, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Waycrest Manor
            nodes[1038][67899710] = { mnID = 864, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Temple of Sethraliss
            nodes[1039][45760810] = { mnID = 942, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Shrine of the Storm
            nodes[1041][36191611] = { mnID = 863, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- The Underrot      
            nodes[1148][52679428] = { mnID = 863, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Uldir    
            nodes[1010][50639270] = { mnID = 862, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- The Motherlode    
            nodes[1162][76681988] = { mnID = 895, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Siege of Boralus
            nodes[1345][68368768] = { mnID = 942, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Crucible of Storms
            nodes[1490][71683749] = { mnID = 1462, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Operation: Mechagon
            nodes[1512][94264884] = { mnID = 1355, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- The Eternal Palace
            
            if self.faction == "Horde" then
              nodes[1358][23941752] = { mnID = 862, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Battle of Dazar'alor  
            end

            if self.faction == "Alliance" then
              nodes[1358][23941752] = { mnID = 895, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Battle of Dazar'alor 
            end
        --################################
        --#### Shadowlands Exit Notes ####
        --################################
            nodes[1663][89875409] = { mnID = 1525, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Halls of Atonement
            nodes[1666][82863999] = { mnID = 1533, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- The Necrotic Wake
            nodes[1669][93861796] = { mnID = 1565, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Mists of Tirna Scithe
            nodes[1674][29981643] = { mnID = 1536, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Plaguefall
            nodes[1675][09825103] = { mnID = 1525, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Sanguine Depths
            nodes[1680][50581456] = { mnID = 1565, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- De Other Side
            nodes[1683][50498296] = { mnID = 1536, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Theater of Pain
            nodes[1692][40586445] = { mnID = 1533, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Spires of Ascension
            nodes[1735][34468069] = { mnID = 1525, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Castle Nathria
            nodes[1998][29478607] = { mnID = 1543, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Sanctum of Domination
            nodes[1989][90914372] = { mnID = 2472, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Tazavesh, the Veiled Market
            nodes[2047][07465150] = { mnID = 1970, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Sepulcher of the First Ones
            nodes[2051][61467473] = { mnID = 1970, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Sepulcher of the First Ones

        --#################################
        --#### Dragon Isles Exit Notes ####
        --#################################
            nodes[2073][77623071] = { mnID = 2024, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- The Azure Vault
            nodes[2080][52562070] = { mnID = 2022, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Neltharus
            nodes[2082][08403471] = { mnID = 2025, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Halls of Infusion
            nodes[2093][60673862] = { mnID = 2023, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- The Nokhud Offensive
            nodes[2095][42789333] = { mnID = 2022, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Ruby Life Pools
            nodes[2096][06524366] = { mnID = 2024, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Brackenhide Hollow
            nodes[2097][42157591] = { mnID = 2025, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Algeth'ar Academy
            nodes[2190][33202089] = { mnID = 2025, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Dawn of the Infinite
            nodes[2119][63509475] = { mnID = 2025, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Vault of the Incarnates
            nodes[2166][51269498] = { mnID = 2133, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Aberrus, the Shadowed Crucible
            nodes[2232][50789310] = { mnID = 2200, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Amirdrassil, the Dream's Hope
        --###############################
        --#### Khaz Algar Exit Notes ####
        --###############################
            nodes[2315][88524713] = { mnID = 2339, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- The Rookery
            nodes[2335][24825244] = { mnID = 2339, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- The Rookery
            nodes[2359][76357843] = { mnID = 2215, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- The Dawnbreaker
            nodes[2308][79764764] = { mnID = 2215, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Priory of the Sacred Flame
            nodes[2341][53291111] = { mnID = 2214, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- The Stonevault
            nodes[2303][16726791] = { mnID = 2214, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Darkflame Cleft
            nodes[2357][86577850] = { mnID = 2216, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Ara-Kara, City of Echoes
            nodes[2343][46460933] = { mnID = 2256, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- City of Threads
            nodes[2292][72131053] = { mnID = 2256, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", showInZone = true } -- Nerub-ar Palace
            nodes[2460][76760961] = { mnID = 2371, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", leaveDelve = true, showInZone = true } -- Manaforge Omega
            nodes[2449][81785036] = { mnID = 2371, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", leaveDelve = true, showInZone = true } -- Bio Al'dani            
          -- delves
          -- Azj-Kathet
            nodes[2259][52821359] = { mnID = 2255, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", leaveDelve = true, showInZone = true } -- Tak-Rethan-Abyss
            nodes[2299][32112247] = { mnID = 2213, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", leaveDelve = true, showInZone = true } -- The Underkeep
            nodes[2348][86575260] = { mnID = 2213, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", leaveDelve = true, showInZone = true } -- Zekvir's Lair
            nodes[2347][56289404] = { mnID = 2255, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", leaveDelve = true, showInZone = true } -- The Spiral Weave
            -- Hallowfall
            nodes[2312][12643377] = { mnID = 2215, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", leaveDelve = true, showInZone = true } -- Mycomancer Cavern
            nodes[2310][86105637] = { mnID = 2215, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", leaveDelve = true, showInZone = true } -- Skittering Breach
            nodes[2301][52351423] = { mnID = 2215, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", leaveDelve = true, showInZone = true } -- The Sinkhole
            nodes[2277][75902317] = { mnID = 2215, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", leaveDelve = true, showInZone = true } -- Nightfall Sanctum
            -- The Ringing Deeps
            nodes[2251][45450999] = { mnID = 2214, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", leaveDelve = true, showInZone = true } -- The Waterworks
            nodes[2302][25046296] = { mnID = 2214, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", leaveDelve = true, showInZone = true } -- The Waterworks
            nodes[2396][48970399] = { mnID = 2214, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", leaveDelve = true, showInZone = true } -- Rowdy Rifts
            nodes[2387][42751241] = { mnID = 2214, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", leaveDelve = true, showInZone = true } -- Operation: Floodgate
            -- Isle of Dorn
            nodes[2269][45441087] = { mnID = 2248, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", leaveDelve = true, showInZone = true } -- Earthcrawl Mines
            nodes[2249][68888884] = { mnID = 2248, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", leaveDelve = true, showInZone = true } -- Fungal Folly
            nodes[2250][31962673] = { mnID = 2248, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", leaveDelve = true, showInZone = true } -- Kriegval's Rest
            -- Undermine
            nodes[2423][48926758] = { mnID = 2346, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", leaveDelve = true, showInZone = true } -- Sidestreet Sluice
            -- K'aresh
            nodes[2484][53808881] = { mnID = 2472, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", leaveDelve = true, showInZone = true } -- Voidscar Cavern
            nodes[2452][39248845] = { mnID = 2371, name = BATTLEGROUND_INSTANCE .. "-" .. L["Exit"], type = "Exit", leaveDelve = true, showInZone = true } -- Archival Assault
          end
    
    
        --################################
        --#### Inside Dungeon Passage ####
        --################################
          if self.db.profile.showDungeonPassage then

        --##########################
        --#### Kalimdor Passage ####
        --##########################
          --Mauradon
            nodes[280][13585809] = { mnID = 281, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_MARAUDON2, name = "", type = "PassageLeftL", showInZone = true } -- Maraudon passage to Zaetar's Grave
            nodes[281][29120410] = { mnID = 280, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_MARAUDON1, name = "", type = "PassageRightL", showInZone = true } -- Maraudon passage to Zaetar's Grave
          --Blackfathom Deeps
            nodes[221][61467332] = { mnID = 222, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_BLACKFATHOMDEEPS2, name = "", type = "PassageDownL", showInZone = true } -- The Pool of Ask'Ar
            nodes[222][33682913] = { mnID = 221, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_BLACKFATHOMDEEPS1, name = "", type = "PassageLeftL", showInZone = true } -- Moonshrine Sanctum
            nodes[222][45767732] = { mnID = 223, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_BLACKFATHOMDEEPS3, name = "", type = "PassageRightL", showInZone = true } -- Moonshrine Sanctum
            nodes[223][40426226] = { mnID = 222, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_BLACKFATHOMDEEPS2, name = "", type = "PassageLeftL", showInZone = true } -- The Forgotten Pool
          --Firelands
            nodes[367][49532089] = { mnID = 369, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_FIRELANDS2, name = "", type = "PassageUpL", showInZone = true } -- Firelands
            nodes[369][50949145] = { mnID = 367, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_FIRELANDS0, name = "", type = "PassageDownL", showInZone = true } -- Sulfuron Keep
          --The Culling of Stratholme
            nodes[130][47331948] = { mnID = 131, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_COTSTRATHOLME1, name = "", type = "PassageUpL", showInZone = true } -- The Culling of Stratholme
            nodes[131][50477779] = { mnID = 130, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_COTSTRATHOLME0, name = "", type = "PassageDownL", showInZone = true } -- Stratholme City
          --Hour of Twillight
            nodes[399][49847521] = { mnID = 400, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_HOUROFTWILIGHT1, name = "", type = "PassageDownL", showInZone = true } -- Hour of Twillight
            nodes[400][44661477] = { mnID = 399, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_HOUROFTWILIGHT0, name = "", type = "PassageUpL", showInZone = true } -- Wyrmrest Temple
          --Halls of Orientation
            nodes[297][67584914] = { mnID = 299, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_HALLSOFORIGINATION3, name = "", type = "PassageUpL", showInZone = true } -- Hall des Lichts
            nodes[299][47334914] = { mnID = 297, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_HALLSOFORIGINATION1, name = "", type = "PassageDownL", showInZone = true } -- Die Vier Sitze
            nodes[297][90454952] = { mnID = 298, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_HALLSOFORIGINATION2, name = "", type = "PassageRightL", showInZone = true } -- Hall des Lichts
            nodes[298][33204938] = { mnID = 297, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_HALLSOFORIGINATION1, name = "", type = "PassageLeftL", showInZone = true } -- Grab des Erdwüters
          --Ahn'Qiraj
            nodes[320][48906273] = { mnID = 321, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_AHNQIRAJ3, name = "", type = "PassageDownL", showInZone = true } -- Die Tempeltore
            nodes[321][47022819] = { mnID = 320, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_AHNQIRAJ2, name = "", type = "PassageDownL", showInZone = true } -- Höhle von C'Thun
            nodes[321][58794130] = { mnID = 319, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_AHNQIRAJ1, name = "", type = "PassageDownL", showInZone = true } -- Höhle von C'Thun
            nodes[321][45134820] = { mnID = 319, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_AHNQIRAJ1, name = "", type = "PassageDownL", showInZone = true } -- Höhle von C'Thun
            nodes[319][34774507] = { mnID = 321, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_AHNQIRAJ3, name = "", type = "PassageUpL", showInZone = true } -- Untergrund des Schwarmbaus
            nodes[319][31015331] = { mnID = 321, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_AHNQIRAJ3, name = "", type = "PassageUpL", showInZone = true } -- Untergrund des Schwarmbaus
        
        --#################################
        --#### Eastern Kingdom Passage ####
        --#################################
          --Old Scholomance
            nodes[306][66643330] = { mnID = 307, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_SCHOLOMANCE2, name = "", type = "PassageUpL", showInZone = true } -- The Reliquary
            nodes[307][29083252] = { mnID = 308, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_SCHOLOMANCE3, name = "", type = "PassageRightL", showInZone = true } -- Chamber of Summoning
            nodes[307][62092937] = { mnID = 306, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_SCHOLOMANCE1, name = "", type = "PassageDownL", showInZone = true } -- Chamber of Summoning
            nodes[307][29638662] = { mnID = 308, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_SCHOLOMANCE3, name = "", type = "PassageUpL", showInZone = true } -- Chamber of Summoning
            nodes[307][63505338] = { mnID = 308, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_SCHOLOMANCE3, name = "", type = "PassageRightL", showInZone = true } -- Chamber of Summoning
            nodes[307][41058886] = { mnID = 309, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_SCHOLOMANCE4, name = "", type = "PassageLeftL", showInZone = true } -- Chamber of Summoning
            nodes[308][28812372] = { mnID = 307, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_SCHOLOMANCE2, name = "", type = "PassageLeftL", showInZone = true } -- The Upper Study
            nodes[308][28812372] = { mnID = 307, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_SCHOLOMANCE2, name = "", type = "PassageLeftL", showInZone = true } -- The Upper Study
            nodes[308][35408274] = { mnID = 307, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_SCHOLOMANCE2, name = "", type = "PassageUpL", showInZone = true } -- The Upper Study
            nodes[308][58956226] = { mnID = 307, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_SCHOLOMANCE2, name = "", type = "PassageLeftL", showInZone = true } -- The Upper Study
            nodes[309][48275691] = { mnID = 307, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_SCHOLOMANCE2, name = "", type = "PassageUpL", showInZone = true } -- Headmaster's Study                
          --Old Naxxramas
            nodes[162][68327703] = { mnID = 166, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_NAXXRAMAS5, name = "", type = "PassageRightL", showInZone = true }
            nodes[163][30777726] = { mnID = 166, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_NAXXRAMAS5, name = "", type = "PassageLeftL", showInZone = true }
            nodes[164][65602313] = { mnID = 166, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_NAXXRAMAS5, name = "", type = "PassageRightL", showInZone = true }
            nodes[165][33072286] = { mnID = 166, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_NAXXRAMAS5, name = "", type = "PassageLeftL", showInZone = true }
            nodes[166][51054636] = { mnID = 162, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_NAXXRAMAS1, name = "", type = "PassageLeftL", showInZone = true }
            nodes[166][55674647] = { mnID = 163, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_NAXXRAMAS2, name = "", type = "PassageRightL", showInZone = true }
            nodes[166][50905253] = { mnID = 164, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_NAXXRAMAS3, name = "", type = "PassageLeftL", showInZone = true }
            nodes[166][55675253] = { mnID = 165, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_NAXXRAMAS4, name = "", type = "PassageRightL", showInZone = true }
          --Stratholme
            nodes[317][90343235] = { mnID = 318, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_STRATHOLME2, name = "", type = "PassageRightL", showInZone = true }
            nodes[318][58427709] = { mnID = 317, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_STRATHOLME1, name = "", type = "PassageLeftL", showInZone = true }     
          --Sunwell Plateau
            nodes[335][68052583] = { mnID = 336, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_SUNWELLPLATEAU1, name = "", type = "PassageDownL", showInZone = true }
            nodes[336][52961406] = { mnID = 335, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_SUNWELLPLATEAU0, name = "", type = "PassageUpL", showInZone = true }            
          --Magisters'Terrace
            nodes[348][83123808] = { mnID = 349, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_MAGISTERSTERRACE2, name = "", type = "PassageUpL", showInZone = true }
            nodes[349][83124625] = { mnID = 348, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_MAGISTERSTERRACE1, name = "", type = "PassageDownL", showInZone = true }
          --Scarlet Halls
            nodes[431][55491493] = { mnID = 432, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_SCARLETHALLS2, name = "", type = "PassageUpL", showInZone = true }
            nodes[432][47499411] = { mnID = 431, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_SCARLETHALLS1, name = "", type = "PassageDownL", showInZone = true }
          --Scarlet Monastery
            nodes[435][48599270] = { mnID = 436, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_SCARLETCATHEDRAL2, name = "", type = "PassageDownL", showInZone = true }
            nodes[436][49211140] = { mnID = 435, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_SCARLETCATHEDRAL1, name = "", type = "PassageUpL", showInZone = true }
          ----Shadowfang Keep
            nodes[310][38073895] = { mnID = 311, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_SHADOWFANGKEEP2, name = "", type = "PassageDownL", showInZone = true }
            nodes[310][35726720] = { mnID = 316, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_SHADOWFANGKEEP7, name = "", type = "PassageUpL", showInZone = true }
            nodes[310][14848721] = { mnID = 311, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_SHADOWFANGKEEP2, name = "", type = "PassageDownL", showInZone = true }
            nodes[311][27248964] = { mnID = 310, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_SHADOWFANGKEEP1, name = "", type = "PassageUpL", showInZone = true }
            nodes[311][61611265] = { mnID = 310, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_SHADOWFANGKEEP1, name = "", type = "PassageUpL", showInZone = true }
            nodes[316][23477528] = { mnID = 310, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_SHADOWFANGKEEP1, name = "", type = "PassageDownL", showInZone = true }
            nodes[316][44033290] = { mnID = 312, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_SHADOWFANGKEEP3, name = "", type = "PassageUpL", showInZone = true }
            nodes[312][51738957] = { mnID = 313, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_SHADOWFANGKEEP4, name = "", type = "PassageUpL", showInZone = true }
            nodes[312][52966131] = { mnID = 316, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_SHADOWFANGKEEP7, name = "", type = "PassageDownL", showInZone = true }
            nodes[313][52048964] = { mnID = 312, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_SHADOWFANGKEEP3, name = "", type = "PassageDownL", showInZone = true }
            nodes[313][42787410] = { mnID = 314, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_SHADOWFANGKEEP5, name = "", type = "PassageUpL", showInZone = true }
            nodes[314][47337732] = { mnID = 313, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_SHADOWFANGKEEP4, name = "", type = "PassageUpL", showInZone = true }
            nodes[314][42787379] = { mnID = 315, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_SHADOWFANGKEEP6, name = "", type = "PassageDownL", showInZone = true }
            nodes[315][41688493] = { mnID = 314, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_SHADOWFANGKEEP5, name = "", type = "PassageDownL", showInZone = true }
          --Scholomance
            nodes[476][80612388] = { mnID = 477, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_SCHOLOMANCE2, name = "", type = "PassageLeftL", showInZone = true }
            nodes[477][77002654] = { mnID = 476, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_SCHOLOMANCE1, name = "", type = "PassageRightL", showInZone = true }
            nodes[477][57539388] = { mnID = 478, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_SCHOLOMANCE3, name = "", type = "PassageDownL", showInZone = true }
            nodes[478][49531423] = { mnID = 477, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_SCHOLOMANCE2, name = "", type = "PassageUpL", showInZone = true }
            nodes[478][49692718] = { mnID = 479, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_SCHOLOMANCE4, name = "", type = "PassageDownL", showInZone = true }
            nodes[479][50001854] = { mnID = 478, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_SCHOLOMANCE3, name = "", type = "PassageUpL", showInZone = true }
           --Bastion of Twilight 
            nodes[294][53928980] = { mnID = 295, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_THEBASTIONOFTWILIGHT2, name = "", type = "PassageDownL", showInZone = true }
            nodes[295][55021194] = { mnID = 294, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_THEBASTIONOFTWILIGHT1, name = "", type = "PassageUpL", showInZone = true }
            nodes[295][69627598] = { mnID = 296, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_THEBASTIONOFTWILIGHT3, name = "", type = "PassageDownL", showInZone = true }
          --Gnomeregan
            nodes[226][34936437] = { mnID = 227, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_GNOMEREGAN2, name = "", type = "PassageDownL", showInZone = true }
            nodes[226][47498509] = { mnID = 227, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_GNOMEREGAN2, name = "", type = "PassageDownL", showInZone = true }
            nodes[227][42788328] = { mnID = 228, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_GNOMEREGAN3, name = "", type = "PassageDownL", showInZone = true }
            nodes[227][73548093] = { mnID = 226, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_GNOMEREGAN1, name = "", type = "PassageUpL", showInZone = true }
            nodes[227][61306115] = { mnID = 226, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_GNOMEREGAN1, name = "", type = "PassageUpL", showInZone = true }
            nodes[228][44514366] = { mnID = 227, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_GNOMEREGAN3, name = "", type = "PassageUpL", showInZone = true }
            nodes[228][23325001] = { mnID = 229, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_GNOMEREGAN4, name = "", type = "PassageDownL", showInZone = true }
            nodes[229][46555550] = { mnID = 228, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_GNOMEREGAN3, name = "", type = "PassageUpL", showInZone = true }
          --Throne of the Tides
            nodes[322][50003148] = { mnID = 323, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_THRONEOFTIDES2, name = "", type = "PassageUpL", showInZone = true }
            nodes[323][50318368] = { mnID = 322, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_THRONEOFTIDES1, name = "", type = "PassageDownL", showInZone = true }
            nodes[323][51415190] = { mnID = 322, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_THRONEOFTIDES1, name = "", type = "PassageDownL", showInZone = true }
          --Uldaman
            nodes[230][47171328] = { mnID = 231, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_ULDAMAN2, name = "", type = "PassageUpL", showInZone = true }
            nodes[231][64914184] = { mnID = 230, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_ULDAMAN1, name = "", type = "PassageUpL", showInZone = true }
          --Blackrock Caverns
            nodes[283][54242388] = { mnID = 284, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_BLACKWINGDESCENT2, name = "", type = "PassageUpL", showInZone = true }
            nodes[284][33991477] = { mnID = 283, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_BLACKWINGDESCENT1, name = "", type = "PassageUpL", showInZone = true }
          --Blackwing Descent
            nodes[285][47024577] = { mnID = 286, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_BLACKROCKCAVERNS1, name = "", type = "PassageUpL", showInZone = true }
            nodes[286][47499058] = { mnID = 285, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_BLACKROCKCAVERNS2, name = "", type = "PassageDownL", showInZone = true }
          --Blackrock Depths
            nodes[242][54366273] = { mnID = 243, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_BLACKROCKDEPTHS2, name = "", type = "PassageRightL", showInZone = true }
            nodes[242][54853615] = { mnID = 243, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_BLACKROCKDEPTHS2, name = "", type = "PassageDownL", showInZone = true }
            nodes[243][55268973] = { mnID = 242, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_BLACKROCKDEPTHS1, name = "", type = "PassageLeftL", showInZone = true }
            nodes[243][54316569] = { mnID = 242, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_BLACKROCKDEPTHS1, name = "", type = "PassageDownL", showInZone = true }
            --Upper Blackrock Spire
            nodes[616][30221477] = { mnID = 617, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_UPPERBLACKROCKSPIRE2, name = "", type = "PassageUpL", showInZone = true }
            nodes[617][30071658] = { mnID = 616, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_UPPERBLACKROCKSPIRE1, name = "", type = "PassageDownL", showInZone = true }
            nodes[617][28344201] = { mnID = 618, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_UPPERBLACKROCKSPIRE3, name = "", type = "PassageUpL", showInZone = true }
            nodes[618][39294090] = { mnID = 617, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_UPPERBLACKROCKSPIRE2, name = "", type = "PassageDownL", showInZone = true }
          --Lower Blackrock Spire
            nodes[250][59576461] = { mnID = 251, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_BLACKROCKSPIRE2, name = "", type = "PassageUpL", showInZone = true }
            nodes[250][63347003] = { mnID = 251, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_BLACKROCKSPIRE2, name = "", type = "PassageRightL", showInZone = true }
            nodes[251][56755079] = { mnID = 252, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_BLACKROCKSPIRE3, name = "", type = "PassageRightL", showInZone = true }
            nodes[251][59266398] = { mnID = 250, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_BLACKROCKSPIRE1, name = "", type = "PassageDownL", showInZone = true }
            nodes[251][64287070] = { mnID = 250, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_BLACKROCKSPIRE1, name = "", type = "PassageLeftL", showInZone = true }
            nodes[251][51887457] = { mnID = 252, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_BLACKROCKSPIRE3, name = "", type = "PassageLeftL", showInZone = true }
            nodes[252][50474107] = { mnID = 253, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_BLACKROCKSPIRE4, name = "", type = "PassageLeftL", showInZone = true }
            nodes[252][55185072] = { mnID = 251, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_BLACKROCKSPIRE2, name = "", type = "PassageLeftL", showInZone = true }
            nodes[252][39804813] = { mnID = 253, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_BLACKROCKSPIRE4, name = "", type = "PassageRightL", showInZone = true }
            nodes[252][62715425] = { mnID = 251, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_BLACKROCKSPIRE2, name = "", type = "PassageDownL", showInZone = true }
            nodes[252][47026508] = { mnID = 253, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_BLACKROCKSPIRE4, name = "", type = "PassageUpL", showInZone = true }
            nodes[252][49697356] = { mnID = 251, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_BLACKROCKSPIRE2, name = "", type = "PassageRightL", showInZone = true }
            nodes[253][49534083] = { mnID = 252, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_BLACKROCKSPIRE3, name = "", type = "PassageRightL", showInZone = true }
            nodes[253][39174836] = { mnID = 252, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_BLACKROCKSPIRE3, name = "", type = "PassageLeftL", showInZone = true }
            nodes[253][45456414] = { mnID = 252, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_BLACKROCKSPIRE3, name = "", type = "PassageDownL", showInZone = true }
            nodes[253][42627568] = { mnID = 254, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_BLACKROCKSPIRE5, name = "", type = "PassageUpL", showInZone = true }
            nodes[254][42627568] = { mnID = 253, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_BLACKROCKSPIRE4, name = "", type = "PassageDownL", showInZone = true }
            nodes[254][39485990] = { mnID = 255, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_BLACKROCKSPIRE6, name = "", type = "PassageRightL", showInZone = true }
            nodes[255][42316024] = { mnID = 254, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_BLACKROCKSPIRE5, name = "", type = "PassageLeftL", showInZone = true }
          --Blackwing Lair 
            nodes[287][43413031] = { mnID = 288, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_BLACKWINGLAIR2, name = "", type = "PassageUpL", showInZone = true }
            nodes[287][35871312] = { mnID = 288, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_BLACKWINGLAIR2, name = "", type = "PassageUpL", showInZone = true }
            nodes[288][51883283] = { mnID = 287, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_BLACKWINGLAIR1, name = "", type = "PassageDownL", showInZone = true }
            nodes[288][46232011] = { mnID = 287, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_BLACKWINGLAIR1, name = "", type = "PassageDownL", showInZone = true }
            nodes[288][50318274] = { mnID = 289, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_BLACKWINGLAIR3, name = "", type = "PassageUpL", showInZone = true }
            nodes[289][39802089] = { mnID = 290, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_BLACKWINGLAIR4, name = "", type = "PassageUpL", showInZone = true }
            nodes[289][52358728] = { mnID = 288, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_BLACKWINGLAIR2, name = "", type = "PassageDownL", showInZone = true }
            nodes[290][31794813] = { mnID = 289, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_BLACKWINGLAIR3, name = "", type = "PassageDownL", showInZone = true }
            --The Deadmines
            nodes[291][65546861] = { mnID = 292, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_THEDEADMINES2, name = "", type = "PassageDownL", showInZone = true }
            nodes[292][17198328] = { mnID = 291, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_THEDEADMINES1, name = "", type = "PassageUpL", showInZone = true }
          -- Return to Karazhan
            nodes[350][53176335] = { mnID = 352, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_KARAZHAN3, name = "", type = "PassageUpL", showInZone = true }
            nodes[350][39178933] = { mnID = 351, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_KARAZHAN2, name = "", type = "PassageUpL", showInZone = true }
            nodes[350][38541234] = { mnID = 353, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_KARAZHAN4, name = "", type = "PassageRightL", showInZone = true }
            nodes[351][24577457] = { mnID = 350, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_KARAZHAN1, name = "", type = "PassageDownL", showInZone = true }
            nodes[351][74492442] = { mnID = 350, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_KARAZHAN1, name = "", type = "PassageDownL", showInZone = true }
            nodes[351][38540982] = { mnID = 352, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_KARAZHAN3, name = "", type = "PassageUpL", showInZone = true }
            nodes[352][52209216] = { mnID = 350, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_KARAZHAN1, name = "", type = "PassageDownL", showInZone = true }
            nodes[352][39338392] = { mnID = 351, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_KARAZHAN2, name = "", type = "PassageDownL", showInZone = true }
            nodes[352][69783612] = { mnID = 353, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_KARAZHAN4, name = "", type = "PassageLeftL", showInZone = true }
            nodes[353][51738533] = { mnID = 355, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_KARAZHAN6, name = "", type = "PassageDownL", showInZone = true }
            nodes[353][71354366] = { mnID = 352, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_KARAZHAN3, name = "", type = "PassageDownL", showInZone = true }
            nodes[353][45602882] = { mnID = 350, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_KARAZHAN1, name = "", type = "PassageLeftL", showInZone = true }
            nodes[353][22164974] = { mnID = 354, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_KARAZHAN5, name = "", type = "PassageRightL", showInZone = true }
            nodes[354][42788328] = { mnID = 353, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_KARAZHAN4, name = "", type = "PassageLeftL", showInZone = true }
            nodes[354][62712018] = { mnID = 355, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_KARAZHAN6, name = "", type = "PassageUpL", showInZone = true }
            nodes[355][53456908] = { mnID = 353, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_KARAZHAN4, name = "", type = "PassageUpL", showInZone = true }
            nodes[355][65656867] = { mnID = 356, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_KARAZHAN7, name = "", type = "PassageRightL", showInZone = true }
            nodes[355][39481164] = { mnID = 354, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_KARAZHAN5, name = "", type = "PassageDownL", showInZone = true }
            nodes[356][69466492] = { mnID = 355, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_KARAZHAN9, name = "", type = "PassageLeftL", showInZone = true }
            nodes[356][54885976] = { mnID = 357, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_KARAZHAN8, name = "", type = "PassageUpL", showInZone = true }
            nodes[356][50312324] = { mnID = 355, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_KARAZHAN6, name = "", type = "PassageDownL", showInZone = true }
            nodes[357][53925190] = { mnID = 356, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_KARAZHAN7, name = "", type = "PassageUpL", showInZone = true }
            nodes[358][60672018] = { mnID = 357, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_KARAZHAN8, name = "", type = "PassageDownL", showInZone = true }
            nodes[358][30216415] = { mnID = 359, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_KARAZHAN10, name = "", type = "PassageUpL", showInZone = true }
            nodes[359][60885865] = { mnID = 361, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_KARAZHAN12, name = "", type = "PassageRightL", showInZone = true }
            nodes[359][36132076] = { mnID = 360, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_KARAZHAN11, name = "", type = "PassageLeftL", showInZone = true }
            nodes[359][32716295] = { mnID = 358, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_KARAZHAN9, name = "", type = "PassageDownL", showInZone = true }
            nodes[360][66012513] = { mnID = 359, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_KARAZHAN10, name = "", type = "PassageRightL", showInZone = true }
            nodes[361][45925291] = { mnID = 359, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_KARAZHAN10, name = "", type = "PassageLeftL", showInZone = true }
            nodes[361][25126043] = { mnID = 362, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_KARAZHAN13, name = "", type = "PassageLeftL", showInZone = true }
            nodes[361][41081540] = { mnID = 363, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_KARAZHAN14, name = "", type = "PassageRightL", showInZone = true }
            nodes[362][55958239] = { mnID = 361, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_KARAZHAN12, name = "", type = "PassageDownL", showInZone = true }
            nodes[363][18458250] = { mnID = 361, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_KARAZHAN12, name = "", type = "PassageLeftL", showInZone = true }
            nodes[363][82335496] = { mnID = 364, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_KARAZHAN15, name = "", type = "PassageUpL", showInZone = true }
            nodes[363][38541823] = { mnID = 364, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_KARAZHAN15, name = "", type = "PassageLeftL", showInZone = true }
            nodes[364][84597041] = { mnID = 365, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_KARAZHAN16, name = "", type = "PassageUpL", showInZone = true }
            nodes[364][80016899] = { mnID = 363, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_KARAZHAN15, name = "", type = "PassageDownL", showInZone = true }
            nodes[364][29443031] = { mnID = 363, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_KARAZHAN15, name = "", type = "PassageRightL", showInZone = true }
            nodes[365][69937638] = { mnID = 365, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_KARAZHAN15, name = "", type = "PassageDownL", showInZone = true }
            nodes[365][61147332] = { mnID = 366, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_KARAZHAN17, name = "", type = "PassageUpL", showInZone = true }
            nodes[366][52118901] = { mnID = 365, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_KARAZHAN17, name = "", type = "PassageDownL", showInZone = true }
        
         --##########################
        --#### Outland Passage #####
        --##########################
          --Black Temple
            nodes[339][28657991] = { mnID = 340, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_BLACKTEMPLE1, name = "", type = "PassageDownL", showInZone = true } -- 
            nodes[339][76054672] = { mnID = 341, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_BLACKTEMPLE2, name = "", type = "PassageRightL", showInZone = true } --       
            nodes[340][27240693] = { mnID = 339, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_BLACKTEMPLE0, name = "", type = "PassageUpL", showInZone = true } -- 
            nodes[341][61933384] = { mnID = 342, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_BLACKTEMPLE3, name = "", type = "PassageRightL", showInZone = true } -- 
            nodes[341][21124985] = { mnID = 339, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_BLACKTEMPLE0, name = "", type = "PassageLeftL", showInZone = true } -- 
            nodes[341][57859035] = { mnID = 343, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_BLACKTEMPLE4, name = "", type = "PassageLeftL", showInZone = true } -- 
            nodes[341][26302301] = { mnID = 344, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_BLACKTEMPLE5, name = "", type = "PassageDownL", showInZone = true } -- 
            nodes[342][63033918] = { mnID = 341, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_BLACKTEMPLE2, name = "", type = "PassageLeftL", showInZone = true } -- 
            nodes[343][74966845] = { mnID = 341, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_BLACKTEMPLE2, name = "", type = "PassageRightL", showInZone = true } -- 
            nodes[344][08254813] = { mnID = 341, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_BLACKTEMPLE2, name = "", type = "PassageUpL", showInZone = true } -- 
            nodes[344][67275590] = { mnID = 345, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_BLACKTEMPLE6, name = "", type = "PassageDownL", showInZone = true } -- 
            nodes[345][47333054] = { mnID = 346, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_BLACKTEMPLE7, name = "", type = "PassageUpL", showInZone = true }
            nodes[345][69461241] = { mnID = 344, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_BLACKTEMPLE5, name = "", type = "PassageUpL", showInZone = true }
            nodes[346][52821234] = { mnID = 345, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_BLACKTEMPLE6, name = "", type = "PassageUpL", showInZone = true }
          --The Arcatraz
            nodes[269][67872673] = { mnID = 270, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_THEARCATRAZ2, name = "", type = "PassageUpL", showInZone = true }
            nodes[270][85635143] = { mnID = 269, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_THEARCATRAZ1, name = "", type = "PassageDownL", showInZone = true }
            nodes[270][44195708] = { mnID = 271, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_THEARCATRAZ3, name = "", type = "PassageRightL", showInZone = true }
            nodes[271][21348824] = { mnID = 270, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_THEARCATRAZ2, name = "", type = "PassageLeftL", showInZone = true }
          --The Mechanar
            nodes[267][41702083] = { mnID = 268, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_THEMECHANAR2, name = "", type = "PassageUpL", showInZone = true }
            nodes[268][41723445] = { mnID = 267, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_THEMECHANAR1, name = "", type = "PassageDownL", showInZone = true }
          --The Steamvault
            nodes[263][47577798] = { mnID = 264, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_THESTEAMVAULT2, name = "", type = "PassageDownL", showInZone = true }
            nodes[264][47807685] = { mnID = 263, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_THESTEAMVAULT1, name = "", type = "PassageUpL", showInZone = true }
          --Sethekk Halls
            nodes[258][53149134] = { mnID = 259, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_SETHEKKHALLS2, name = "", type = "PassageUpL", showInZone = true }
            nodes[259][49309485] = { mnID = 258, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_SETHEKKHALLS2, name = "", type = "PassageLeftL", showInZone = true }
            nodes[259][49232701] = { mnID = 258, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_SETHEKKHALLS1, name = "", type = "PassageRightL", showInZone = true } 
          --Auchenai Crypts 
            nodes[256][42551715] = { mnID = 257, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_AUCHENAICRYPTS2, name = "", type = "PassageLeftL", showInZone = true }
            nodes[257][24831266] = { mnID = 256, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_AUCHENAICRYPTS1, name = "", type = "PassageRightL", showInZone = true }
        
        --###########################
        --#### Northrend Passage ####
        --###########################
          --Drak'Tharon Keep
            nodes[160][62127171] = { mnID = 161, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_DRAKTHARONKEEP2, name = "", type = "PassageLeftL", showInZone = true }
            nodes[161][50947189] = { mnID = 160, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_DRAKTHARONKEEP1, name = "", type = "PassageDownL", showInZone = true }
            nodes[161][38071776] = { mnID = 160, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_DRAKTHARONKEEP1, name = "", type = "PassageRightL", showInZone = true }
          --Utgarde Pinnacle
            nodes[137][59463342] = { mnID = 136, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_UTGARDEPINNACLE1, name = "", type = "PassageDownL", showInZone = true }
            nodes[137][55665358] = { mnID = 136, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_UTGARDEPINNACLE1, name = "", type = "PassageRightL", showInZone = true }
            nodes[137][43787526] = { mnID = 136, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_UTGARDEPINNACLE1, name = "", type = "PassageRightL", showInZone = true }
            nodes[137][54417922] = { mnID = 136, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_UTGARDEPINNACLE1, name = "", type = "PassageDownL", showInZone = true }
            nodes[136][54191762] = { mnID = 137, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_UTGARDEPINNACLE2, name = "", type = "PassageUpL", showInZone = true }
            nodes[136][40094388] = { mnID = 137, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_UTGARDEPINNACLE2, name = "", type = "PassageLeftL", showInZone = true }
            nodes[136][45918383] = { mnID = 137, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_UTGARDEPINNACLE2, name = "", type = "PassageUpL", showInZone = true }
            nodes[136][28277624] = { mnID = 137, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_UTGARDEPINNACLE2, name = "", type = "PassageUpL", showInZone = true }
          --Utgarde Keep
            nodes[133][47498422] = { mnID = 134, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_UTGARDEKEEP2, name = "", type = "PassageRightL", showInZone = true }
            nodes[134][34516443] = { mnID = 133, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_UTGARDEKEEP1, name = "", type = "PassageRightL", showInZone = true }
            nodes[134][53452160] = { mnID = 135, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_UTGARDEKEEP3, name = "", type = "PassageUpL", showInZone = true }
            nodes[135][33504319] = { mnID = 134, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_UTGARDEKEEP2, name = "", type = "PassageUpL", showInZone = true }
          --Halls of Lightning 
            nodes[138][89605368] = { mnID = 139, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_HALLSOFLIGHTNING2, name = "", type = "PassageRightL", showInZone = true }
            nodes[139][56282082] = { mnID = 138, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_HALLSOFLIGHTNING1, name = "", type = "PassageLeftL", showInZone = true }
          --Ulduar
            nodes[149][51188419] = { mnID = 148, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_ULDUAR1, name = "", type = "PassageDownL", showInZone = true }
          --Trial of the Crusader  
            nodes[172][51194755] = { mnID = 173, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_THEARGENTCOLISEUM2, name = "", type = "PassageDownL", showInZone = true }
          --IcecrownGlacier
            nodes[186][38998338] = { mnID = 187, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_ICECROWNCITADEL2, name = "", type = "PassageUpL", showInZone = true }
            nodes[187][45508467] = { mnID = 186, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_ICECROWNCITADEL1, name = "", type = "PassageDownL", showInZone = true }
            nodes[187][65995501] = { mnID = 188, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_ICECROWNCITADEL3, name = "", type = "PassageRightL", showInZone = true }
            nodes[188][51611678] = { mnID = 190, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_ICECROWNCITADEL5, name = "", type = "PassageUpL", showInZone = true }
            nodes[190][51838303] = { mnID = 188, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_ICECROWNCITADEL2, name = "", type = "PassageDownL", showInZone = true }
            nodes[190][51885378] = { mnID = 192, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_ICECROWNCITADEL1, name = "", type = "PassageUpL", showInZone = true }
            nodes[190][76689428] = { mnID = 189, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_ICECROWNCITADEL4, name = "", type = "PassageDownL", showInZone = true }
            nodes[190][42422010] = { mnID = 191, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_ICECROWNCITADEL6, name = "", type = "PassageDownL", showInZone = true }
            nodes[190][61272032] = { mnID = 191, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_ICECROWNCITADEL6, name = "", type = "PassageDownL", showInZone = true }
            nodes[190][87045354] = { mnID = 189, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_ICECROWNCITADEL6, name = "", type = "PassageDownL", showInZone = true }
            nodes[191][22693377] = { mnID = 190, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_ICECROWNCITADEL5, name = "", type = "PassageUpL", showInZone = true }
            nodes[191][80143306] = { mnID = 190, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_ICECROWNCITADEL5, name = "", type = "PassageUpL", showInZone = true }
            nodes[191][51267309] = { mnID = 190, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_ICECROWNCITADEL5, name = "", type = "PassageDownL", showInZone = true }
            nodes[189][36499219] = { mnID = 190, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_ICECROWNCITADEL5, name = "", type = "PassageUpL", showInZone = true }
            nodes[189][51833323] = { mnID = 190, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_ICECROWNCITADEL5, name = "", type = "PassageUpL", showInZone = true }
          --Azjol-Nerub
            nodes[159][66171948] = { mnID = 158, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_AZJOLNERUB2, name = "", type = "PassageDownL", showInZone = true }
            nodes[158][39012748] = { mnID = 159, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_AZJOLNERUB3, name = "", type = "PassageUpL", showInZone = true }
            nodes[158][49795861] = { mnID = 157, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_AZJOLNERUB1, name = "", type = "PassageDownL", showInZone = true }
          --The Oculus
            nodes[142][49334887] = { mnID = 143, name = "", type = "PassageUpL", showInZone = true }
            nodes[143][49378227] = { mnID = 145, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_NEXUS802, name = "", type = "PassageUpL", showInZone = true }
            nodes[144][51418305] = { mnID = 143, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_NEXUS801, name = "", type = "PassageDownL", showInZone = true }
            nodes[144][47648305] = { mnID = 145, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_NEXUS803, name = "", type = "PassageUpL", showInZone = true }
            nodes[145][46237198] = { mnID = 146, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_NEXUS803, name = "", type = "PassageUpL", showInZone = true }
            nodes[145][52677198] = { mnID = 144, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_NEXUS804, name = "", type = "PassageDownL", showInZone = true }
            nodes[146][47647339] = { mnID = 145, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_NEXUS804, name = "", type = "PassageDownL", showInZone = true }

        --##########################
        --#### Pandaria Passage ####
        --##########################
          --Temple of the Jade Serpent
            nodes[429][26586218] = { mnID = 430, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_EASTTEMPLE2, name = "", type = "PassageLeftL", showInZone = true }
            nodes[429][25856779] = { mnID = 430, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_EASTTEMPLE2, name = "", type = "PassageRightL", showInZone = true }
            nodes[430][44512435] = { mnID = 429, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_EASTTEMPLE1, name = "", type = "PassageRightL", showInZone = true }
            nodes[430][40903871] = { mnID = 429, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_EASTTEMPLE1, name = "", type = "PassageLeftL", showInZone = true }
          --Mogu'shan Palace
            nodes[453][49786821] = { mnID = 454, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_MOGUSHANPALACE2, name = "", type = "PassageDownL", showInZone = true }
            nodes[454][59572701] = { mnID = 453, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_MOGUSHANPALACE1, name = "", type = "PassageDownL", showInZone = true }
            nodes[454][71587640] = { mnID = 455, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_MOGUSHANPALACE3, name = "", type = "PassageUpL", showInZone = true }
            nodes[455][58982436] = { mnID = 454, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_MOGUSHANPALACE2, name = "", type = "PassageDownL", showInZone = true }
          --Gate of the Setting Sun
            nodes[437][46153314] = { mnID = 438, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_THEGREATWALL2, name = "", type = "PassageUpL", showInZone = true }
            nodes[438][49015147] = { mnID = 437, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_THEGREATWALL1, name = "", type = "PassageDownL", showInZone = true }
          --Siege of Orgrimmar  
            nodes[557][11546798] = { mnID = 556, name = "", type = "PassageDownL", showInZone = true }
            nodes[556][42307149] = { mnID = 558, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_ORGRIMMARRAID1, name = "", type = "PassageLeftL", showInZone = true }
            nodes[558][49786821] = { mnID = 556, name = "", type = "PassageRightL", showInZone = true }
            nodes[559][30233311] = { mnID = 560, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_ORGRIMMARRAID4, name = "", type = "PassageUpL", showInZone = true }
            nodes[560][51577834] = { mnID = 559, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_ORGRIMMARRAID3, name = "", type = "PassageDownL", showInZone = true }
            nodes[560][55962819] = { mnID = 561, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_ORGRIMMARRAID5, name = "", type = "PassageLeftL", showInZone = true }
            nodes[561][77471383] = { mnID = 560, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_ORGRIMMARRAID4, name = "", type = "PassageRightL", showInZone = true }
            nodes[561][69464914] = { mnID = 562, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_ORGRIMMARRAID6, name = "", type = "PassageRightL", showInZone = true }
            nodes[562][30852035] = { mnID = 561, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_ORGRIMMARRAID5, name = "", type = "PassageLeftL", showInZone = true }
            nodes[562][75906108] = { mnID = 563, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_ORGRIMMARRAID7, name = "", type = "PassageDownL", showInZone = true }
            nodes[563][12498658] = { mnID = 562, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_ORGRIMMARRAID6, name = "", type = "PassageUpL", showInZone = true }
            nodes[563][78727363] = { mnID = 564, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_ORGRIMMARRAID8, name = "", type = "PassageLeftL", showInZone = true }
            nodes[563][90656186] = { mnID = 565, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_ORGRIMMARRAID9, name = "", type = "PassageRightL", showInZone = true }
            nodes[563][87987528] = { mnID = 566, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_ORGRIMMARRAID10, name = "", type = "PassageDownL", showInZone = true }
            nodes[564][64751634] = { mnID = 563, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_ORGRIMMARRAID7, name = "", type = "PassageRightL", showInZone = true }
            nodes[565][24738038] = { mnID = 563, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_ORGRIMMARRAID7, name = "", type = "PassageLeftL", showInZone = true }
            nodes[566][32421493] = { mnID = 563, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_ORGRIMMARRAID7, name = "", type = "PassageUpL", showInZone = true }
            nodes[566][65229192] = { mnID = 567, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_ORGRIMMARRAID11, name = "", type = "PassageDownL", showInZone = true }
            nodes[567][53611241] = { mnID = 566, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_ORGRIMMARRAID10, name = "", type = "PassageUpL", showInZone = true }
          --Stormstout Brewery
            nodes[439][28026061] = { mnID = 440, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_STORMSTOUTBREWERY2, name = "", type = "PassageRightL", showInZone = true }
            nodes[440][31015997] = { mnID = 439, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_STORMSTOUTBREWERY1, name = "", type = "PassageLeftL", showInZone = true }
            nodes[440][81395880] = { mnID = 441, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_STORMSTOUTBREWERY3, name = "", type = "PassageLeftL", showInZone = true }
            nodes[441][29754907] = { mnID = 440, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_STORMSTOUTBREWERY2, name = "", type = "PassageLeftL", showInZone = true }
            nodes[441][74803353] = { mnID = 442, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_STORMSTOUTBREWERY4, name = "", type = "PassageLeftL", showInZone = true }
            nodes[442][60672934] = { mnID = 441, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_STORMSTOUTBREWERY3, name = "", type = "PassageRightL", showInZone = true }
          --Mogu'shan Vaults
            nodes[471][31951288] = { mnID = 472, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_MOGUSHANVAULTS2, name = "", type = "PassageUpL", showInZone = true }
            nodes[472][77628345] = { mnID = 471, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_MOGUSHANVAULTS1, name = "", type = "PassageUpL", showInZone = true }
            nodes[472][29945168] = { mnID = 473, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_MOGUSHANVAULTS3, name = "", type = "PassageLeftL", showInZone = true }
            nodes[473][64601022] = { mnID = 472, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_MOGUSHANVAULTS2, name = "", type = "PassageRightL", showInZone = true }
          --Shado-Pan Monastery
            nodes[444][25418244] = { mnID = 443, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_SHADOWPANHIDEOUT0, name = "", type = "PassageLeftL", showInZone = true }
            nodes[443][56288651] = { mnID = 444, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_SHADOWPANHIDEOUT1, name = "", type = "PassageRightL", showInZone = true }
            nodes[443][36037991] = { mnID = 445, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_SHADOWPANHIDEOUT2, name = "", type = "PassageLeftL", showInZone = true }
            nodes[443][24576696] = { mnID = 445, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_SHADOWPANHIDEOUT2, name = "", type = "PassageRightL", showInZone = true }
            nodes[443][31633424] = { mnID = 446, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_SHADOWPANHIDEOUT3, name = "", type = "PassageRightL", showInZone = true }
            nodes[443][44353801] = { mnID = 446, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_SHADOWPANHIDEOUT3, name = "", type = "PassageUpL", showInZone = true }
            nodes[445][71357575] = { mnID = 443, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_SHADOWPANHIDEOUT0, name = "", type = "PassageRightL", showInZone = true }
            nodes[445][18291877] = { mnID = 443, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_SHADOWPANHIDEOUT0, name = "", type = "PassageLeftL", showInZone = true }
            nodes[446][19557104] = { mnID = 443, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_SHADOWPANHIDEOUT0, name = "", type = "PassageLeftL", showInZone = true }
            nodes[446][51418046] = { mnID = 443, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_SHADOWPANHIDEOUT0, name = "", type = "PassageDownL", showInZone = true }
          --Heart of Fear  
            nodes[474][31951540] = { mnID = 475, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_HEARTOFFEAR2, name = "", type = "PassageUpL", showInZone = true }
            nodes[475][66432526] = { mnID = 474, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_HEARTOFFEAR1, name = "", type = "PassageDownL", showInZone = true }
          --Siege of Niuzao Temple
            nodes[458][53618109] = { mnID = 459, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_SIEGEOFNIUZAOTEMPLE2, name = "", type = "PassageRightL", showInZone = true }
            nodes[459][55967881] = { mnID = 458, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_SIEGEOFNIUZAOTEMPLE1, name = "", type = "PassageLeftL", showInZone = true }
            nodes[459][22065244] = { mnID = 457, name = "", type = "PassageRightL", showInZone = true }
            nodes[457][48827254] = { mnID = 459, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_SIEGEOFNIUZAOTEMPLE2, name = "", type = "PassageRightL", showInZone = true }
          --Throne of Thunder
            nodes[508][84067924] = { mnID = 509, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_THUNDERKINGRAID2, name = "", type = "PassageRightL", showInZone = true }
            nodes[509][17127885] = { mnID = 508, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_THUNDERKINGRAID1, name = "", type = "PassageLeftL", showInZone = true }
            nodes[509][64541905] = { mnID = 510, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_THUNDERKINGRAID3, name = "", type = "PassageDownL", showInZone = true }
            nodes[510][74605616] = { mnID = 511, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_THUNDERKINGRAID4, name = "", type = "PassageDownL", showInZone = true }
            nodes[511][21281924] = { mnID = 510, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_THUNDERKINGRAID3, name = "", type = "PassageUpL", showInZone = true }
            nodes[511][33725525] = { mnID = 512, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_THUNDERKINGRAID5, name = "", type = "PassageLeftL", showInZone = true }
            nodes[512][77150834] = { mnID = 511, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_THUNDERKINGRAID4, name = "", type = "PassageRightL", showInZone = true }
            nodes[512][46702011] = { mnID = 513, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_THUNDERKINGRAID6, name = "", type = "PassageUpL", showInZone = true }
            nodes[513][88457598] = { mnID = 512, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_THUNDERKINGRAID7, name = "", type = "PassageRightL", showInZone = true }
            nodes[513][20497033] = { mnID = 514, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_THUNDERKINGRAID5, name = "", type = "PassageDownL", showInZone = true }
            nodes[514][46391022] = { mnID = 513, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_THUNDERKINGRAID6, name = "", type = "PassageLeftL", showInZone = true }

        --##########################
        --#### Draenor Passage #####
        --##########################
          --Skyreach
            nodes[601][42546882] = { mnID = 602, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_SPIRESOFARAKDUNGEON2, name = "", type = "PassageRightL", showInZone = true }
            nodes[602][18247372] = { mnID = 601, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_SPIRESOFARAKDUNGEON1, name = "", type = "PassageLeftL", showInZone = true }
          --Shadowmoon Burial Grounds  
            nodes[574][89825168] = { mnID = 575, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_SHADOWMOONDUNGEON2, name = "", type = "PassageRightL", showInZone = true }
            nodes[575][06006355] = { mnID = 574, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_SHADOWMOONDUNGEON1, name = "", type = "PassageDownL", showInZone = true }
            nodes[575][75407336] = { mnID = 576, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_SHADOWMOONDUNGEON3, name = "", type = "PassageDownL", showInZone = true }
          --The Everbloon  
            nodes[620][43633505] = { mnID = 621, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_OVERGROWNOUTPOST1, name = "", type = "PassageLeftL", showInZone = true }
            nodes[621][45049165] = { mnID = 620, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_OVERGROWNOUTPOST0, name = "", type = "PassageDownL", showInZone = true }
          --Highmaul  
            nodes[611][47024695] = { mnID = 612, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_HIGHMAULRAID2, name = "", type = "PassageUpL", showInZone = true }
            nodes[612][25542291] = { mnID = 610, name = "", type = "PassageLeftL", showInZone = true }
            nodes[610][59267869] = { mnID = 612, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_HIGHMAULRAID2, name = "", type = "PassageRightL", showInZone = true }
            nodes[610][12173714] = { mnID = 613, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_HIGHMAULRAID3, name = "", type = "PassageLeftL", showInZone = true }
            nodes[613][83906246] = { mnID = 610, name = "", type = "PassageDownL", showInZone = true }
            nodes[613][29445472] = { mnID = 614, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_HIGHMAULRAID4, name = "", type = "PassageUpL", showInZone = true }
            nodes[614][35856450] = { mnID = 613, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_HIGHMAULRAID3, name = "", type = "PassageRightL", showInZone = true }
          --Hellfire Citadel
            nodes[661][34155095] = { mnID = 662, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_HELLFIRERAID1, name = "", type = "PassageLeftL", showInZone = true }
            nodes[662][92384749] = { mnID = 661, name = "", type = "PassageRightL", showInZone = true }
            nodes[662][72132183] = { mnID = 663, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_HELLFIRERAID2, name = "", type = "PassageUpL", showInZone = true }
            nodes[662][72137410] = { mnID = 665, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_HELLFIRERAID4, name = "", type = "PassageDownL", showInZone = true }
            nodes[662][72137410] = { mnID = 665, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_HELLFIRERAID4, name = "", type = "PassageDownL", showInZone = true }
            nodes[663][67899058] = { mnID = 662, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_HELLFIRERAID1, name = "", type = "PassageDownL", showInZone = true }
            nodes[663][50781901] = { mnID = 664, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_HELLFIRERAID3, name = "", type = "PassageUpL", showInZone = true }
            nodes[664][60998745] = { mnID = 663, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_HELLFIRERAID2, name = "", type = "PassageDownL", showInZone = true }
            nodes[665][81710935] = { mnID = 662, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_HELLFIRERAID3, name = "", type = "PassageUpL", showInZone = true }
            nodes[666][45459451] = { mnID = 668, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_HELLFIRERAID7, name = "", type = "PassageDownL", showInZone = true }
            nodes[666][61938580] = { mnID = 668, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_HELLFIRERAID7, name = "", type = "PassageDownL", showInZone = true }
            nodes[666][87985119] = { mnID = 667, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_HELLFIRERAID6, name = "", type = "PassageRightL", showInZone = true }
            nodes[668][42420768] = { mnID = 666, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_HELLFIRERAID5, name = "", type = "PassageUpL", showInZone = true }
            nodes[668][29071967] = { mnID = 666, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_HELLFIRERAID5, name = "", type = "PassageUpL", showInZone = true } 
            nodes[667][18455103] = { mnID = 666, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_HELLFIRERAID5, name = "", type = "PassageLeftL", showInZone = true }
            nodes[662][72137410] = { mnID = 665, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_HELLFIRERAID4, name = "", type = "PassageDownL", showInZone = true }
            nodes[662][72137410] = { mnID = 665, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_HELLFIRERAID4, name = "", type = "PassageDownL", showInZone = true }
            nodes[662][72137410] = { mnID = 665, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_HELLFIRERAID4, name = "", type = "PassageDownL", showInZone = true }
            nodes[662][72137410] = { mnID = 665, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_HELLFIRERAID4, name = "", type = "PassageDownL", showInZone = true }
            nodes[662][72137410] = { mnID = 665, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_HELLFIRERAID4, name = "", type = "PassageDownL", showInZone = true }
          --Grimrail Depot
            nodes[606][74102608] = { mnID = 607, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_BLACKROCKTRAINDEPOTDUNGEON2, name = "", type = "PassageLeftL", showInZone = true }
            nodes[607][67842591] = { mnID = 606, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_BLACKROCKTRAINDEPOTDUNGEON1, name = "", type = "PassageRightL", showInZone = true }
            nodes[607][70087509] = { mnID = 608, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_BLACKROCKTRAINDEPOTDUNGEON3, name = "", type = "PassageUpL", showInZone = true } 
            nodes[608][08205180] = { mnID = 609, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_BLACKROCKTRAINDEPOTDUNGEON4, name = "", type = "PassageLeftL", showInZone = true }
            nodes[609][90615132] = { mnID = 608, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_BLACKROCKTRAINDEPOTDUNGEON3, name = "", type = "PassageRightL", showInZone = true }
          -- Blackrock Foundry
            nodes[598][50846857] = { mnID = 597, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_FOUNDRYRAID2, name = "", type = "PassageLeftL", showInZone = true }
            nodes[598][28405382] = { mnID = 596, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_FOUNDRYRAID1, name = "", type = "PassageDownL", showInZone = true }
            nodes[598][53454248] = { mnID = 599, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_FOUNDRYRAID4, name = "", type = "PassageRightL", showInZone = true }
            nodes[598][34771540] = { mnID = 600, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_FOUNDRYRAID5, name = "", type = "PassageLeftL", showInZone = true }
            nodes[600][52989216] = { mnID = 598, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_FOUNDRYRAID3, name = "", type = "PassageRightL", showInZone = true }
            nodes[596][46705708] = { mnID = 598, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_FOUNDRYRAID3, name = "", type = "PassageUpL", showInZone = true }
            nodes[597][65185336] = { mnID = 598, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_FOUNDRYRAID3, name = "", type = "PassageLeftL", showInZone = true }
            nodes[599][41058439] = { mnID = 598, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_FOUNDRYRAID3, name = "", type = "PassageLeftL", showInZone = true }
            nodes[599][55024931] = { mnID = 596, TransportName = L["Passage"] .. "\n" .. " ==> ".. DUNGEON_FLOOR_FOUNDRYRAID1, name = "", type = "PassageLeftL", showInZone = true }

        --#######################################
        --#### The war Within Delve Passage #####
        --#######################################

          -- Sidestreet Sluice
            --nodes[2423][50094552] = { mnID = 2420, dnID = L["Passage"], name = "", type = "PassageDownL", showInZone = true }
            --nodes[2420][44234162] = { mnID = 2423, dnID = L["Passage"], name = "", type = "PassageUpL", showInZone = true }

          end


        --##################################
        --#### Inside Dungeon Transport ####
        --##################################
        if self.db.profile.showDungeonTransport then

          --####################################
          --#### Kalimdor Dungeon Transport ####
          --####################################
            --Dragon Soul
              nodes[409][49145903] = { mnID = 410, dnID = DUNGEON_FLOOR_DRAGONSOUL1, name = "", type = "TravelM", showInZone = true } -- Dragon Soul
              nodes[409][51055925] = { mnID = 411, dnID = DUNGEON_FLOOR_DRAGONSOUL2, name = "", type = "TravelM", showInZone = true } -- Dragon Soul
              nodes[409][50145769] = { dnID = HUD_EDIT_MODE_SETTING_BAGS_DIRECTION_UP .. "\n" .. L["Appears first after a certain instance progress\n or requires a certain achievement"], name = "", type = "TravelM", showInZone = true } -- Dragon Soul
          
          --###########################################
          --#### Eastern Kingdom Dungeon Transport ####
          --###########################################
            --Blackrock Depths
              nodes[242][35567887] = { mnID = 243, dnID = DUNGEON_FLOOR_BLACKROCKDEPTHS2 .. "\n" .. DUNGEON_FLOOR_BLACKROCKDEPTHS1, name = "", type = "TravelM", showInZone = true }
              nodes[242][57472697] = { mnID = 243, dnID = "•" .. DUNGEON_FLOOR_BLACKROCKDEPTHS2 .. "\n" .. "•" .. L["Entrance"] .. "/" .. TELEPORT_OUT_OF_DUNGEON, name = "", type = "TravelM", showInZone = true }
              nodes[243][54296944] = { mnID = 242, dnID = DUNGEON_FLOOR_BLACKROCKDEPTHS1, name = "", type = "TravelM", showInZone = true }
          
          --#####################################
          --#### Northrend Dungeon Transport ####
          --#####################################
            --The Oculus
              nodes[143][48676316] = { mnID = 144, dnID = DUNGEON_FLOOR_NEXUS802, name = "", type = "TravelM", showInZone = true }
              nodes[143][40757592] = { mnID = 144, dnID = DUNGEON_FLOOR_NEXUS802, name = "", type = "TravelM", showInZone = true }
              nodes[143][57607522] = { mnID = 144, dnID = DUNGEON_FLOOR_NEXUS802, name = "", type = "TravelM", showInZone = true }
            
            --Icecrown Citadel
              nodes[189][25693280] = { mnID = 190, dnID = DUNGEON_FLOOR_ICECROWNCITADEL5, name = "", type = "Tport2", showInZone = true }
              nodes[190][51717343] = { dnID = "•" .. DUNGEON_FLOOR_ICECROWNCITADEL1 .. "\n" .. "•" .. DUNGEON_FLOOR_ICECROWNCITADEL2 .. "\n" .. "•" ..DUNGEON_FLOOR_ICECROWNCITADEL3 .. "\n" .. "•" ..DUNGEON_FLOOR_ICECROWNCITADEL4, name = "", type = "Tport2", showInZone = true }
  
          
          --####################################
          --#### Pandaria Dungeon Transport ####
          --####################################
  
            --Siege of Orgrimmar
              nodes[556][28150948] = { mnID = 557, dnID = DUNGEON_FLOOR_ORGRIMMARRAID1, name = "", type = "TravelM", showInZone = true }
  
          --####################################
          --#### Legion Dungeon Transport ####
          --####################################
  
            --Hellfire Citadel
              nodes[666][61906477] = { mnID = 661, name = "", type = "TravelM", showInZone = true }
  
            end
  
          --################################
          --#### Inside Dungeon Portals ####
          --################################
            if self.db.profile.showDungeonPortal then
  
          --###################################
          --#### Kalimdor Dungeon Portals #####
          --###################################
            --Dragon Soul
              nodes[411][57698846] = { mnID = 409, dnID = DUNGEON_FLOOR_DRAGONSOUL0, name = "", type = "Portal", showInZone = true } -- to Maw of Shu'ma
              nodes[410][23324020] = { mnID = 409, dnID = DUNGEON_FLOOR_DRAGONSOUL0, name = "", type = "Portal", showInZone = true } -- to Maw of Go'rath
              nodes[412][52181359] = { mnID = 409, dnID = DUNGEON_FLOOR_DRAGONSOUL0, name = "", type = "Portal", showInZone = true } -- to Eye of Eternity
              nodes[409][50606029] = { mnID = 412, dnID = DUNGEON_FLOOR_DRAGONSOUL3, name = "", type = "Portal", showInZone = true } -- Dragon Soul to Eye of Eternity
            --End Time
              nodes[401][79774484] = { mnID = 403, dnID = DUNGEON_FLOOR_ENDTIME0, name = "", type = "Portal", showInZone = true } -- End Time - 
              nodes[403][33054295] = { mnID = 402, dnID = DUNGEON_FLOOR_ENDTIME1, name = "", type = "Portal", showInZone = true } -- End Time - to Ruby Dragonshrine
              nodes[402][41428063] = { mnID = 401, dnID = DUNGEON_FLOOR_ENDTIME2, name = "", type = "Portal", showInZone = true } -- End Time - to Azure Dragonshrine
          
           --##########################################
          --#### Eastern Kingdom Dungeon Portals #####
          --##########################################
            --Old Naxxramas
              nodes[166][55844846] = { mnID = 23, name = L["Secret Portal"] .. " " .. L["(Wards of the Dread Citadel - Achievement)"] , type = "Portal", showInZone = true }
              nodes[162][24531196] = { mnID = 166, dnID = DUNGEON_FLOOR_NAXXRAMAS5, name = "", type = "Portal", showInZone = true }
              nodes[163][72381984] = { mnID = 166, dnID = DUNGEON_FLOOR_NAXXRAMAS5, name = "", type = "Portal", showInZone = true }
              nodes[164][27438096] = { mnID = 166, dnID = DUNGEON_FLOOR_NAXXRAMAS5, name = "", type = "Portal", showInZone = true }
              nodes[165][80352881] = { mnID = 166, dnID = DUNGEON_FLOOR_NAXXRAMAS5, name = "", type = "Portal", showInZone = true }
              nodes[166][53324968] = { mnID = 167, dnID = "•" .. DUNGEON_FLOOR_NAXXRAMAS6 .. "\n" .. "•" .. L["Entrance"] .. "/" .. TELEPORT_OUT_OF_DUNGEON, name = "", type = "Portal", showInZone = true }
              nodes[167][74087267] = { mnID = 166, dnID = DUNGEON_FLOOR_NAXXRAMAS5, name = "", type = "Portal", showInZone = true }
          
          --###################################
          --#### Northrend Dungeon Portals ####
          --###################################  
            --Ulduar 
              nodes[147][48770994] = { mnID = 148, dnID = DUNGEON_FLOOR_ULDUAR1, name = "", type = "Portal", showInZone = true }
            --Trial of the Crusader  
              nodes[173][51335658] = { mnID = 125, name = "", type = "Portal", showInZone = true }
            --Icecrown Citadel
              nodes[186][33692342] = { mnID = 125, name = "", type = "Portal", showInZone = true } -- Portal Dalaran
              nodes[192][56087032] = { mnID = 186, dnID = DUNGEON_FLOOR_ICECROWNCITADEL1, name = "", type = "Portal", showInZone = true } -- IcecrownGlacier
  
          --###################################
          --#### Pandaria Dungeon Portals #####
          --###################################
            --Siege of Orgrimmar
              nodes[558][22988189] = { mnID = 559, dnID = DUNGEON_FLOOR_ICECROWNCITADEL3, name = "", type = "Portal", showInZone = true }
              nodes[558][19465757] = { mnID = 559, dnID = DUNGEON_FLOOR_ICECROWNCITADEL3, name = "", type = "Portal", showInZone = true }
            
          --##################################
          --#### Draenor Dungeon Portals #####
          --##################################
            --Shadowmoon Burial Grounds
              nodes[576][43993847] = { mnID = 574, dnID = DUNGEON_FLOOR_SHADOWMOONDUNGEON1, name = "", type = "Portal", showInZone = true }
            --Highmaul
              nodes[610][29786093] = { mnID = 610, name = "", type = "Portal", showInZone = true }
              nodes[610][09505220] = { mnID = 610, name = "", type = "Portal", showInZone = true }
              nodes[614][44792661] = { mnID = 615, dnID = DUNGEON_FLOOR_HIGHMAULRAID5, name = "", type = "Portal", showInZone = true }
              nodes[615][46972821] = { mnID = 614, dnID = DUNGEON_FLOOR_HIGHMAULRAID4, name = "", type = "Portal", showInZone = true }
              nodes[615][55077584] = { mnID = 610, dnID = DUNGEON_FLOOR_HIGHMAULRAID4, name = "", type = "Portal", showInZone = true }
            --Hellfire Citadel
              nodes[662][22754571] = { mnID = 666, dnID = " " .. L["Appears first after a certain instance progress\n or requires a certain achievement"] .. "\n" .. " " .. "\n" .. "•" .. DUNGEON_FLOOR_HELLFIRERAID5, name = "", type = "Portal", showInZone = true }
              nodes[666][62026040] = { mnID = 669, dnID = " " .. L["Appears first after a certain instance progress\n or requires a certain achievement"] .. "\n" .. " " .. "\n" .. "•" .. DUNGEON_FLOOR_HELLFIRERAID8, name = "", type = "Portal", showInZone = true }
              nodes[669][51463591] = { mnID = 670, dnID = " " .. L["Appears first after a certain instance progress\n or requires a certain achievement"] .. "\n" .. " " .. "\n" .. "•" .. DUNGEON_FLOOR_HELLFIRERAID9, name = "", type = "Portal", showInZone = true }
              nodes[670][37035211] = { mnID = 661, dnID = " " .. L["Appears first after a certain instance progress\n or requires a certain achievement"] .. "\n" .. " " .. "\n" .. "•" .. DUNGEON_FLOOR_HELLFIRERAID0, name = "", type = "Portal", showInZone = true }
              nodes[670][46813594] = { mnID = 661, dnID = " " .. L["Appears first after a certain instance progress\n or requires a certain achievement"] .. "\n" .. " " .. "\n" .. "•" .. DUNGEON_FLOOR_HELLFIRERAID0, name = "", type = "Portal", showInZone = true }
              nodes[670][52833770] = { mnID = 661, dnID = " " .. L["Appears first after a certain instance progress\n or requires a certain achievement"] .. "\n" .. " " .. "\n" .. "•" .. DUNGEON_FLOOR_HELLFIRERAID0, name = "", type = "Portal", showInZone = true }
              nodes[670][56016959] = { mnID = 661, dnID = " " .. L["Appears first after a certain instance progress\n or requires a certain achievement"] .. "\n" .. " " .. "\n" .. "•" .. DUNGEON_FLOOR_HELLFIRERAID0, name = "", type = "Portal", showInZone = true }
              nodes[670][50516959] = { mnID = 661, dnID = " " .. L["Appears first after a certain instance progress\n or requires a certain achievement"] .. "\n" .. " " .. "\n" .. "•" .. DUNGEON_FLOOR_HELLFIRERAID0, name = "", type = "Portal", showInZone = true }
              nodes[661][69123854] = { mnID = 669, dnID = " " .. L["Appears first after a certain instance progress\n or requires a certain achievement"] .. "\n" .. " " .. "\n" .. "•" .. DUNGEON_FLOOR_HELLFIRERAID8, name = "", type = "Portal", showInZone = true }
              nodes[661][69414844] = { mnID = 666, dnID = " " .. L["Appears first after a certain instance progress\n or requires a certain achievement"] .. "\n" .. " " .. "\n" .. "•" .. DUNGEON_FLOOR_HELLFIRERAID5, name = "", type = "Portal", showInZone = true }
              nodes[661][64944492] = { dnID = " " .. L["Appears first after a certain instance progress\n or requires a certain achievement"] .. "\n" .. " " .. "\n" .. "•" .. DUNGEON_FLOOR_HELLFIRERAID1 .. "\n" .. "•" .. DUNGEON_FLOOR_HELLFIRERAID5 .. "\n" .. "•" .. DUNGEON_FLOOR_HELLFIRERAID8 .. "\n" .. "•" .. DUNGEON_FLOOR_HELLFIRERAID9, name = "", type = "Portal", showInZone = true }
            
          --#######################################
          --#### Dragonflight Dungeon Portals #####
          --#######################################
  
          nodes[2238][27716273] = { mnID = 2112, dnID = L["Appears first after a certain instance progress\n or requires a certain achievement"], name = "", type = "Portal", showInZone = true }

          end
        end
  end 

end