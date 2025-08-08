local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

function ns.LoadZoneDungeonMapNodesLocationinfo(self)
local db = ns.Addon.db.profile
local nodes = ns.nodes
ns._currentSourceFile = "RetailZoneDungeonNodesLocation.lua"

--#####################################################################################################
--##########################        function to hide all nodes below         ##########################
--#####################################################################################################
  if not db.activate.HideMapNote then


    --#####################################################################################################
    --################################         Continent / Zone Map        ################################
    --#####################################################################################################

    if db.activate.ZoneMap then

      if db.activate.ZoneInstances then

        --#############################
        --##### Continent Kalimdor ####
        --#############################

        if self.db.profile.showZoneKalimdor then

        -- Kalimdor Dungeons
            if self.db.profile.showZoneDungeons then       
            nodes[11][54916646] = { id = 240, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Wailing Caverns 

            -- Dungeon Nodes above Blizzards Icons to make it Clickable for maximized Maps
            nodes[1][03067458] = { id = 240, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Wailing Caverns
            nodes[1][46200001] = { id = 226, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ragefire
            nodes[10][80190006] = { id = 226, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ragefire
            nodes[76][18729718] = { id = 226, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ragefire
            nodes[62][33009467] = { id = 227, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Blackfathom Deeps 
            nodes[77][15097658] = { id = 227, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Blackfathom Deeps 
            nodes[10][40496868] = { id = 240, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Wailing Caverns
            nodes[7][79421794] = { id = 240, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Wailing Caverns
            nodes[199][46952074] = { id = 240, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Wailing Caverns
            nodes[199][40779446] = { id = 234, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Razorfen Kraul
            nodes[199][51899825] = { id = 233, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Razorfen Downs
            nodes[70][13176945] = { id = 234, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Razorfen Kraul
            nodes[70][28867479] = { id = 233, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Razorfen Downs
            nodes[64][28021695] = { id = 234, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Razorfen Kraul
            nodes[64][46742333] = { id = 233, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Razorfen Downs
            nodes[71][39482205] = { id = 241, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Zul'Farrak
            nodes[78][93073504] = { id = 241, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Zul'Farrak
            nodes[64][56309765] = { id = 241, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Zul'Farrak
            nodes[75][57042578] = { id = 184, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- End Time
            nodes[75][68382951] = { id = 186, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hour of Twilight
            nodes[75][26333279] = { id = 251, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Old Hillsbrad Foothills
            nodes[75][22136381] = { id = 185, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Well of Eternity
            nodes[75][34438489] = { id = 255, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Black Morass
            nodes[75][60118272] = { id = 279, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Culling of Stratholme
            nodes[207][47385205] = { id = 67, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Stonecore
            nodes[249][60526415] = { id = 69, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Lost City of the Tol'vir
            nodes[249][69095283] = { id = 70, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Halls of Origination
            nodes[249][76708435] = { id = 68, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Vortex Pinnacle
            nodes[1527][60526415] = { id = 69, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Lost City of the Tol'vir
            nodes[1527][69095283] = { id = 70, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Halls of Origination
            nodes[71][24619233] = { id = 70, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Halls of Origination
            nodes[1527][76708435] = { id = 68, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Vortex Pinnacle
          end

        -- Kalimdor Dungeons without ClassicIcons is activ
          if self.db.profile.showZoneDungeons and not db.activate.ClassicIcons then
            nodes[69][60323015] = { id = 230, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Dire Maul - Capital Gardens - West left Entrance 
            nodes[69][60303130] = { id = 230, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Dire Maul - Capital Gardens - West right Entrance 
            nodes[69][62502490] = { id = 1277, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Dire Maul - Gordok Commons - North  
            nodes[67][78285518] = { id = 232, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Maraudon Foulspore Cavern 
            nodes[68][52152417] = { id = 232, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Maraudon Foulspore Cavern 
            nodes[68][44517669] = { id = 232, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Maraudon Foulspore Cavern first Entrance
          end

        --Kalimdor Raids
          if self.db.profile.showZoneRaids then
          -- Raid Nodes above Blizzards Icons to make it Clickable for maximized Maps
          nodes[63][79821712] = { id = 78, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Firelands
          nodes[198][46797838] = { id = 78, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Firelands
          nodes[199][68439906] = { id = 760, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Onyxias Lair
          nodes[70][52217593] = { id = 760, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Onyxias Lair
          nodes[64][74612469] = { id = 760, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Onyxias Lair
          nodes[81][36449403] = { id = 743, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ruins of Ahn'Qiraj
          nodes[81][24328729] = { id = 744, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Temple of Ahn'Qiraj
          nodes[327][58941423] = { id = 743, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ruins of Ahn'Qiraj
          nodes[327][46790747] = { id = 744, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Temple of Ahn'Qiraj
          nodes[249][37008143] = { id = 74, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Throne of the Four Winds
          nodes[249][55184395] = { dnID = L["This instance entrance is in a different timeline. Other timeline can be activated at Zidormi"] .. "  => /way 56.01 35.14", id = 1180, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ny'alotha the Waking City
          nodes[1527][15130940] = { id = 743, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ruins of Ahn'Qiraj
          nodes[1527][07180499] = { id = 744, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Temple of Ahn'Qiraj
          nodes[1527][37008143] = { id = 74, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Throne of the Four Winds
          nodes[1527][38238069] = { dnID = L["Position of the real Instance Entrance"], id = 74, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Throne of the Four Winds
          nodes[1527][55184395] = { dnID = L["Instance Entrance"] .. " " .. L["switches weekly between"] .. " " .. L["Uldum"] .. " (" .. L["Kalimdor"] ..")" .. " & " .. L["Vale of Eternal Blossoms"] .. " (" .. L["Pandaria"] .. ")", id = 1180, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ny'alotha the Waking City
          nodes[71][12668471] = { dnID = L["Instance Entrance"] .. " " .. L["switches weekly between"] .. " " .. L["Uldum"] .. " (" .. L["Kalimdor"] ..")" .. " & " .. L["Vale of Eternal Blossoms"] .. " (" .. L["Pandaria"] .. ")", id = 1180, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ny'alotha the Waking City
          nodes[75][39601704] = { id = 750, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Battle of Mount Hyjal
          nodes[75][60872115] = { id = 187, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Dragon Soul
          end

        --Kalimdor Passage without ClassicIcons
          if self.db.profile.showZonePassage and not db.activate.ClassicIcons then
            nodes[199][45089400] = { dnID = L["Way to the Instance Entrance"], id = 233, type = "PassageDungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Razorfen Downs
            nodes[64][41662882] = { dnID = L["Way to the Instance Entrance"], id = 233, type = "PassageDungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Razorfen Downs
            nodes[1527][71755222] = { dnID = L["Way to the Instance Entrance"], id = 70, type = "PassageDungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Halls of Origination
            nodes[10][38916921] = { mnID = 11, id = 240, TransportName = L["Way to the Instance Entrance"], name = "", type = "PassageDungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Wailing Caverns 
            nodes[66][29226253] = { dnID = L["Way to the Instance Entrance"], id = 232, type = "PassageDungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Maraudon Outside
            nodes[63][14161380] = { dnID = L["Way to the Instance Entrance"], id = 227, type = "PassageDungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Blackfathom Deeps 
            nodes[69][65503524] = { dnID = L["Way to the Instance Entrance"], id = 1276, type = "PassageDungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Dire Maul - Warpwood Quarter - East above Camp Mojache   
            nodes[69][77073692] = { dnID = L["Way to the Instance Entrance"], id = 1276, type = "PassageDungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Dire Maul - Warpwood Quarter - East above Camp Mojache   
          end


        --Kalimdor ClassicIcons
          if db.activate.ClassicIcons then  

            if self.db.profile.showZoneDungeons then 
              nodes[199][45089400] = { dnID = L["Way to the Instance Entrance"], id = 233, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Razorfen Downs
              nodes[64][41662882] = { dnID = L["Way to the Instance Entrance"], id = 233, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Razorfen Downs
              nodes[1527][71755222] = { dnID = L["Way to the Instance Entrance"], id = 70, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Halls of Origination
              nodes[63][14161380] = { dnID = L["Way to the Instance Entrance"], id = 227, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Blackfathom Deeps 
              nodes[66][29226253] = { dnID = L["Way to the Instance Entrance"], id = 232, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Maraudon Outside
              --nodes[69][65503524] = { id = 1276, lfgid = 34, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Dire Maul - Warpwood Quarter - East above Camp Mojache   
              --nodes[69][77073692] = { id = 1276, lfgid = 34, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Dire Maul - Warpwood Quarter - East above Camp Mojache   
            end

            if self.db.profile.showZoneMultiple then
              nodes[71][64864997] = { mnID = 75, hideInfo = true, id = { 187, 750, 279, 255, 251, 184, 185, 186, }, type = "MultipleM", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Dragon Soul, The Battle for Mount Hyjal, The Culling of Stratholme, Black Morass, Old Hillsbrad Foothills, End Time, Well of Eternity, Hour of Twilight Heroic
              nodes[74][30857356] = { mnID = 75, hideInfo = true, id = { 187, 750, 279, 255, 251, 184, 185, 186, }, type = "MultipleM", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Dragon Soul, The Battle for Mount Hyjal, The Culling of Stratholme, Black Morass, Old Hillsbrad Foothills, End Time, Well of Eternity, Hour of Twilight Heroic
            end

          end

        --Kalimdor Multiple
          if self.db.profile.showZoneMultiple and not db.activate.ClassicIcons then  
            nodes[71][64864997] = { mnID = 75, hideInfo = true, id = { 187, 750, 279, 255, 251, 184, 185, 186, }, type = "PassageDungeonRaidMulti", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Dragon Soul, The Battle for Mount Hyjal, The Culling of Stratholme, Black Morass, Old Hillsbrad Foothills, End Time, Well of Eternity, Hour of Twilight Heroic
            nodes[74][30857356] = { mnID = 75, hideInfo = true, id = { 187, 750, 279, 255, 251, 184, 185, 186, }, type = "PassageDungeonRaidMulti", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Dragon Soul, The Battle for Mount Hyjal, The Culling of Stratholme, Black Morass, Old Hillsbrad Foothills, End Time, Well of Eternity, Hour of Twilight Heroic
          end


        -- Kalimdor LFR
          if self.db.profile.showZoneLFR then
            nodes[71][64574742] = { mnID = 75, name = L["Auridormi"] .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " ", hideInfo = true, id = { 187 }, type = "LFR", showInZone = true, showOnContinent = false, showOnMinimap = false }
            nodes[75][63122722] = { mnID = 75, name = L["Auridormi"] .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " ", hideInfo = true, id = { 187 }, type = "LFR", showInZone = true, showOnContinent = false, showOnMinimap = false }
          end

        end


        --####################################
        --##### Continent Eastern Kingdom ####
        --####################################

        if self.db.profile.showZoneEasternKingdom then

        -- Eastern Kingdom Dungeons
          if self.db.profile.showZoneDungeons then
            nodes[16][36502765] = { id = 239, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Uldaman (inside cave) 
            nodes[42][46866979] = { id = 860, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Return to Karazhan 
            nodes[55][24735143] = { id = 63, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Deadmines

          -- Dungeon Nodes above Blizzards Icons to make it Clickable for maximized Maps
            nodes[50][72083291] = { id = 76, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Zul'gurub
            nodes[224][63942179] = { id = 76, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Zul'gurub
            nodes[224][22130243] = { id = 63, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false  } -- Deadmines 
            nodes[37][20223635] = { id = 238, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Stockade
            nodes[15][41121030] = { id = 1197, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Uldaman: Legacy of Tyr
            nodes[48][43478705] = { id = 239, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Uldaman
            nodes[241][19205411] = { id = 71, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Grim Batol
            nodes[56][74006930] = { id = 71, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Grim Batol
            nodes[26][26210814] = { id = 246, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Scholomance
            nodes[25][91190689] = { id = 246, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Scholomance
            nodes[22][69797356] = { id = 246, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Scholomance
            nodes[23][07369102] = { id = 246, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Scholomance
            nodes[25][05895291] = { id = 64, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Shadowfang Keep
            nodes[21][44926788] = { id = 64, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Shadowfang Keep
            nodes[18][85323227] = { id = 311, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Scarlet Halls
            nodes[18][84823043] = { id = 316, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Scarlet Monastery
            nodes[19][79146119] = { id = 311, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Scarlet Halls
            nodes[19][68082061] = { id = 316, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Scarlet Monastery
            nodes[22][28811749] = { id = 311, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Scarlet Halls
            nodes[22][28281555] = { id = 316, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Scarlet Monastery
            nodes[23][27071151] = { id = 236, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Stratholme
            nodes[95][81956434] = { id = 77, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Zul'Aman
            nodes[122][60973073] = { id = 249, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Magisters'Terrace
            nodes[203][48174041] = { id = 65, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Throne of the Tides
            nodes[204][70402953] = { id = 65, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Throne of the Tides
            nodes[33][80454193] = { id = 229, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Lower Blackrock Spire
            nodes[33][79033379] = { id = 559, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Upper Blackrock Spire
            nodes[35][39281819] = { id = 228, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Blackrock Depths
            nodes[30][29507480] = { id = 231, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Gnomeregan
            nodes[30][42311288] = { id = 231, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Gnomeregan
            nodes[34][71245337] = { id = 66, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Blackrock Caverns
          end


        -- Eastern Kingdom Raids
          if self.db.profile.showZoneRaids then

            -- Raid Nodes above Blizzards Icons to make it Clickable for maximized Maps
            nodes[224][76080344] = { id = 745, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Karazhan
            nodes[17][22232177] = { id = 745, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Karazhan
            nodes[42][46987490] = { id = 745, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Karazhan
            nodes[36][23132639] = { id = 73, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Blackwing Descent
            nodes[32][39029679] = { id = 73, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Blackwing Descent
            nodes[48][81242207] = { id = 72, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Bastion of Twilight
            nodes[241][34097788] = { id = 72, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Bastion of Twilight
            nodes[122][44264560] = { id = 752, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Sunwell Plateau
            nodes[244][46054793] = { id = 75, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Baradin Hold
            nodes[33][64017153] = { id = 742, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Blackwing Lair
            nodes[35][53778131] = { id = 741, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Molten Core
          end


          -- Eastern Kingdom Passage
          if self.db.profile.showZonePassage and not db.activate.ClassicIcons then  
            nodes[15][42031147] = { dnID = L["Way to the Instance Entrance"], id = 239, type = "PassageDungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Uldaman
            nodes[469][32793702] = { mnID = 30, dnID = L["Way to the Instance Entrance"], id = 231, type = "PassageDungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Gnomeregan
            nodes[27][31393804] = { mnID = 30, dnID = L["Way to the Instance Entrance"], id = 231, type = "PassageDungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Gnomeregan     
            nodes[51][69675353] = { dnID = L["Way to the Instance Entrance"], id = 237, type = "PassageDungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Temple of Atal'hakkar 
            nodes[36][20643322] = { mnID = 33, hideInfo = true, id = { 741, 742, 66, 228, 229, 559 }, name = L["Way to the Instance Entrance"], type = "PassageDungeonRaidMulti", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Molten Core, Blackwing Lair, Blackrock Caverns, Blackrock Depths, Lower Blackrock Spire, Upper Blackrock Spire 
            nodes[32][35268404] = { mnID = 33, name = "", type = "PassageDungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Molten Core, Blackwing Lair, Blackrock Caverns, Blackrock Depths, Lower Blackrock Spire, Upper Blackrock Spire 
            nodes[15][58543698] = { dnID = L["Way to the Instance Entrance"], id = 239, name = "", type = "PassageDungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Uldaman (Secondary Entrance) 
            nodes[23][43251854] = { dnID = L["Way to the Instance Entrance"], id = 1292, type = "PassageDungeon", showInZone = true, showOnContinent = false, showOnMinimap = false }-- Stratholme Service Entrance 
            nodes[33][68635371] = { mnID = 34, hideInfo = true, id = { 66 }, name = L["Way to the Instance Entrance"], type = "PassageDungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Blackrock Caverns
            nodes[33][65896169] = { mnID = 34, hideInfo = true, id = { 66 }, name = L["Way to the Instance Entrance"], type = "PassageDungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Blackrock Caverns
            nodes[33][45004700] = { mnID = 35, hideInfo = true, id = { 741, 228 }, name = L["Way to the Instance Entrance"], type = "PassageRaid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Blackrock Depths
            nodes[34][58792725] = { mnID = 33, dnID = DUNGEON_FLOOR_BURNINGSTEPPES14, name = "", type = "PassageDungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Blackrock Depths
            nodes[35][58168728] = { mnID = 33, dnID = DUNGEON_FLOOR_BURNINGSTEPPES14, name = "", type = "PassageDungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Blackrock Depths

            -- Passage Nodes above Blizzards Icons to make it Clickable for maximized Maps
            nodes[52][42527168] = { dnID = L["Way to the Instance Entrance"], id = 63, type = "PassageDungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Deadmines   
          end


          -- Eastern Kingdom ClassicIcons
          if db.activate.ClassicIcons then

            if self.db.profile.showZoneMultiple then
              nodes[36][20643322] = { mnID = 33, hideInfo = true, id = { 741, 742, 66, 228, 229, 559 }, name = L["Way to the Instance Entrance"], type = "MultipleM", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Molten Core, Blackwing Lair, Blackrock Caverns, Blackrock Depths, Lower Blackrock Spire, Upper Blackrock Spire 
              --nodes[36][20643322] = { mnID = 33, name = "", type = "MultipleM", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Molten Core, Blackwing Lair, Blackrock Caverns, Blackrock Depths, Lower Blackrock Spire, Upper Blackrock Spire 
            end

            if self.db.profile.showZoneDungeons then
              nodes[15][42031147] = { dnID = L["Way to the Instance Entrance"], id = 239, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Uldaman
              nodes[469][32793702] = { dnID = L["Way to the Instance Entrance"], id = 231, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Gnomeregan
              nodes[27][31393804] = { dnID = L["Way to the Instance Entrance"], id = 231, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Gnomeregan
              nodes[51][69675353] = { dnID = L["Way to the Instance Entrance"], id = 237, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Temple of Atal'hakkar 
              nodes[52][42527168] = { dnID = L["Way to the Instance Entrance"], id = 63, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Deadmines 
              nodes[35][58168728] = { mnID = 33, dnID = DUNGEON_FLOOR_BURNINGSTEPPES14, name = "", type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Blackrock Depths
              nodes[32][35268404] = { mnID = 33, name = "", type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Molten Core, Blackwing Lair, Blackrock Caverns, Blackrock Depths, Lower Blackrock Spire, Upper Blackrock Spire 
              --nodes[15][58543698] = { id = 239, name = "", type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Uldaman (Secondary Entrance) 
              --nodes[23][43251854] = { id = 236, lfgid = 274, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false }-- Stratholme Service Entrance 
              nodes[33][75516099] = { id = 66, name = "", type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Blackrock Caverns
            end

            if self.db.profile.showZoneRaids then
              nodes[33][45004700] = { mnID = 35, hideInfo = true, id = { 741, 228 }, name = L["Way to the Instance Entrance"], type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Blackrock Depths
            end

          end

          
        --Eastern Kingdom ContinentOldVanilla
          if self.db.profile.showZoneOldVanilla then
            nodes[23][35722308] = { mnID = 166, name = L["Secret Entrance"] .. " " .. L["(Wards of the Dread Citadel - Achievement)"] .. " - " .. L["Old Version"], type = "VInstanceR", showInZone = true, showOnContinent = false, showOnMinimap = false }-- Old Naxxramas version - Secret Entrance - Wards of the Dread Citadel 
            nodes[19][48275496] = { hideInfo = true, name = L["Old Keyring \n You get the Scarlet Key in the \n [Loot-Filled Pumpkin] from [Hallow's End Event] or from the [Auction House] \n now you can activate the [Old Keyring] here \n to activate old dungeonversions from the Scarlet Monastery"], type = "VKey1", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Scarlet Monastery Key for Old dungeons 
            nodes[2070][83723082] = { hideInfo = true, name = L["Old Keyring \n You get the Scarlet Key in the \n [Loot-Filled Pumpkin] from [Hallow's End Event] or from the [Auction House] \n now you can activate the [Old Keyring] here \n to activate old dungeonversions from the Scarlet Monastery"], type = "VKey1", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Scarlet Monastery Key for Old dungeons 
            nodes[18][82333243] = { mnID = 19, name = L["Use the Old Keyring"], dnID = L["Graveyard"] .. " - " .. L["Old Version"] .. "\n" .. L["Cathedral"] .. " - " .. L["Old Version"] .. "\n" .. L["Library"] .. " - " .. L["Old Version"] .. "\n" .. L["Armory"] .. " - " .. L["Old Version"], type = "MultiVInstanceD", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Scarlet Monastery Key for Old dungeons
            nodes[2070][82333243] = { mnID = 19, name = L["Use the Old Keyring"], dnID = L["Graveyard"] .. " - " .. L["Old Version"] .. "\n" .. L["Cathedral"] .. " - " .. L["Old Version"] .. "\n" .. L["Library"] .. " - " .. L["Old Version"] .. "\n" .. L["Armory"] .. " - " .. L["Old Version"], type = "MultiVInstanceD", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Scarlet Monastery Key for Old dungeons
            nodes[2070][83812772] = { id = 316, name ="", type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Scarlet Monastery
            nodes[2070][85483158] = { id = 311, name ="", type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Scarlet Halls 
            nodes[19][78882223] = { mnID = 304, name = L["Cathedral"] .. " - " .. L["Old Version"] .. " - " .. L["Use the Old Keyring"], type = "VInstanceD", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Scarlet Monastery - Cathedral"
            nodes[19][78255762] = { mnID = 303, name = L["Library"] .. " - " .. L["Old Version"] .. " - " .. L["Use the Old Keyring"], type = "VInstanceD", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Scarlet Monastery -"
            nodes[19][86414766] = { mnID = 304, name = L["Armory"] .. " - " .. L["Old Version"] .. " - " .. L["Use the Old Keyring"], type = "VInstanceD", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Scarlet Mona"
            nodes[19][68832372] = { mnID = 302, name = L["Graveyard"] .. " - " .. L["Old Version"] .. " - " .. L["Use the Old Keyring"], type = "VInstanceD", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Scarlet Monastery - Graveyard  
            nodes[22][69767181] = { mnID = 306, name = L["Secret Entrance"] .. " " .. L["(Memory of Scholomance - Achievement)"] .. " - " .. L["Old Version"], type = "VInstanceD", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Old Scholomance version - Memory of Scholomance - Secret Entrance Old Scholomance version
          end
        end


        --############################
        --##### Continent Outland ####
        --############################

        if self.db.profile.showZoneOutland then

        -- Outland Dungeons
          if self.db.profile.showZoneDungeons then

        -- Dungeon Nodes above Blizzards Icons to make it Clickable for maximized Maps
            nodes[108][39627318] = { id = 253, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Shadow Labyrinth
            nodes[108][44596560] = { id = 252, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Sethekk Halls
            nodes[108][39645806] = { id = 250, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mana Tombs
            nodes[108][34676559] = { id = 247, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Auchenai Crypts
            nodes[107][96898503] = { id = 250, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mana Tombs
            nodes[107][92039239] = { id = 247, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Auchenai Crypts
            nodes[102][48953592] = { id = 260, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Slave Pens
            nodes[102][50473333] = { id = 261, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Steamvault
            nodes[105][35179927] = { id = 261, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Steamvault
            nodes[102][54173443] = { id = 262, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Underbog
            nodes[100][47925342] = { id = 248, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hellfire Ramparts
            nodes[100][48065191] = { id = 259, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Shattered Halls
            nodes[100][46015179] = { id = 256, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Blood Furnace
            nodes[109][71695506] = { id = 257, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Botanica
            nodes[109][74365774] = { id = 254, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Arcatraz
            nodes[109][70536964] = { id = 258, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Mechanar
          end


        -- Outland Raids
          if self.db.profile.showZoneRaids then

          -- Raid Nodes above Blizzards Icons to make it Clickable for maximized Maps
            nodes[104][71054628] = { id = 751, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Black Temple
            nodes[102][51903348] = { id = 748, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Serpentshrine Cavern
            nodes[105][36509941] = { id = 748, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Serpentshrine Cavern
            nodes[100][46575283] = { id = 747, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Magtheridon's Lair
            nodes[105][69062414] = { id = 746, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Gruul's Lair
            nodes[109][06895168] = { id = 746, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Gruul's Lair
            nodes[109][73596372] = { id = 749, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Eye
          end
        end


        --##############################
        --##### Continent Northrend ####
        --##############################

        if self.db.profile.showZoneNorthrend then

          -- Northrend Dungeon
          if self.db.profile.showZoneDungeons then
            nodes[127][34154413] = { id = 283, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Violet Hold

            -- Dungeon Nodes above Blizzards Icons to make it Clickable for maximized Maps
            nodes[117][57884951] = { id = 285, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Utgarde Keep
            nodes[117][57224649] = { id = 286, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Utgarde Pinnacle
            nodes[116][17552120] = { id = 273, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Drak'Tharon Keep
            nodes[121][76432140] = { id = 274, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Gundrak
            nodes[121][80892832] = { id = 274, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Gundrak
            nodes[121][28678693] = { id = 273, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Drak'Tharon Keep
            nodes[115][28385167] = { id = 271, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ahn'kahet: The Old Kingdom
            nodes[115][25995079] = { id = 272, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Azjol-Nerub
            nodes[120][87996837] = { id = 274, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Gundrak
            nodes[120][45322148] = { id = 275, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Halls of Lightning
            nodes[120][39582689] = { id = 277, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Halls of Stone
            nodes[120][14753428] = { id = 284, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Trial of the Champion
            nodes[118][54848985] = { id = 280, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Forge of Souls
            nodes[118][55319084] = { id = 276, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Halls of Reflection
            nodes[118][54729168] = { id = 278, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Pit of Saron
            nodes[118][74172044] = { id = 284, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Trial of the Champion
            nodes[123][78140236] = { id = 280, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Forge of Souls
            nodes[123][79120444] = { id = 276, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Halls of Reflection
            nodes[123][77890620] = { id = 278, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Pit of Saron
            nodes[114][28592772] = { id = 281, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Nexus
            nodes[114][26602746] = { id = 282, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Oculus
          end

          -- Northrend Raids
          if self.db.profile.showZoneRaids then

          -- Raid Nodes above Blizzards Icons to make it Clickable for maximized Maps
            nodes[116][03065282] = { id = 754, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Naxxramas
            nodes[115][87345100] = { id = 754, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Naxxramas
            nodes[115][61345259] = { id = 761, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Ruby Sanctum
            nodes[115][60005701] = { id = 755, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Obsidian Sanctum
            nodes[120][41571779] = { id = 759, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ulduar
            nodes[120][15623548] = { id = 757, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Trial of the Crusader
            nodes[118][53808709] = { id = 758, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- TIcecrown Citadel
            nodes[118][41519428] = { id = 753, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Vault of Archavon
            nodes[118][75162180] = { id = 757, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Trial of the Crusader
            nodes[119][93866206] = { id = 753, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Vault of Archavon
            nodes[123][50041168] = { id = 753, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Vault of Archavon
            nodes[114][27522673] = { id = 756, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Eye of Eternity
          end
        end


        --#############################
        --##### Continent Pandaria ####
        --#############################

        if self.db.profile.showZonePandaria then

        -- Pandaria Dungeons
          if self.db.profile.showZoneDungeons then

          -- Dungeon Nodes above Blizzards Icons to make it Clickable for maximized Maps
          nodes[371][56175786] = { id = 313, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Temple of the Jade Serpent
          nodes[371][14504859] = { id = 321, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mogu'shan Palace
          nodes[418][35931925] = { id = 302, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Stormstout Brewery
          nodes[376][36066909] = { id = 302, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Stormstout Brewery
          nodes[422][91105965] = { id = 302, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Stormstout Brewery
          nodes[422][75842030] = { id = 303, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Gate of the Setting Sun
          nodes[376][15261542] = { id = 303, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Gate of the Setting Sun
          nodes[388][34688151] = { id = 324, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Siege of Niuzao Temple
          nodes[388][78992402] = { id = 312, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Shado-Pan Monastery
          nodes[379][36714746] = { id = 312, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Shado-Pan Monastery
          nodes[390][80603303] = { id = 321, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mogu'shan Palace
          nodes[390][15837441] = { id = 303, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Gate of the Setting Sun
          nodes[1530][81093057] = { id = 321, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mogu'shan Palace
          end


        -- Pandaria Raids
          if self.db.profile.showZoneRaids then

          -- Raid Nodes above Blizzards Icons to make it Clickable for maximized Maps
            nodes[371][21595793] = { id = 320, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Terrace of Endless Spring
            nodes[376][69680536] = { id = 320, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Terrace of Endless Spring
            nodes[433][48456145] = { id = 320, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Terrace of Endless Spring
            nodes[371][12005202] = { id = 369, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Siege of Orgrimmar
            nodes[422][38923499] = { id = 330, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Heart of Fear
            nodes[379][59603917] = { id = 317, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mogu'Shan Vaults
            nodes[504][63833203] = { id = 362, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Throne of Thunder
            nodes[390][73714248] = { id = 369, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Siege of Orgrimmar
            nodes[390][39604763] = { id = 1180, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false, dnID = L["This instance entrance is in a different timeline. Other timeline can be activated at Zidormi"] .. "  => /way 80.47 31.95" } -- Ny'alotha the Waking City
            nodes[1530][40044556] = { id = 1180, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false, dnID = L["Instance Entrance"] .. " " .. L["switches weekly between"] .. " " .. L["Uldum"] .. " (" .. L["Kalimdor"] ..")" .. " & " .. L["Vale of Eternal Blossoms"] .. " (" .. L["Pandaria"] .. ")" } -- Ny'alotha the Waking City
            nodes[1530][74114014] = { id = 369, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Siege of Orgrimmar
            nodes[1530][72684208] = { id = 369, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false, dnID = L["Position of the real Instance Entrance"] } -- Siege of Orgrimmar
          end


        -- Pandaria LFR
          if self.db.profile.showZoneLFR then
            nodes[390][83153063] = { mnID = 390, name = L["Lorewalker Han"] .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " ", hideInfo = true, id = { 317, 330, 362, 320 }, type = "LFR", showInZone = true, showOnContinent = false, showOnMinimap = false }
            nodes[1530][83712804] = { mnID = 390, name = L["Lorewalker Han"] .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " ", hideInfo = true, id = { 317, 330, 362, 320 }, type = "LFR", showInZone = true, showOnContinent = false, showOnMinimap = false }
          end
        end


        --############################
        --##### Continent Draenor ####
        --############################

        if self.db.profile.showZoneDraenor then


        -- Draenor Dungeons
          if self.db.profile.showZoneDungeons then

          -- Raid Nodes above Blizzards Icons to make it Clickable for maximized Maps
            nodes[525][49922480] = { id = 385, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Blackmaul Slag Mines
            nodes[543][07494267] = { id = 385, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Blackmaul Slag Mines
            nodes[543][45411353] = { id = 558, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Iron Docks
            nodes[543][55153173] = { id = 536, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Grimrail Depot
            nodes[543][59574566] = { id = 556, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Everbloom
            nodes[535][46297394] = { id = 547, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Auchindoun
            nodes[539][31864255] = { id = 537, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Shadowmoon Burial Grounds
            nodes[542][35583361] = { id = 476, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Skyreach
            nodes[542][75031543] = { id = 537, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Shadowmoon Burial Grounds
          end


        --Draenor Raids
          if self.db.profile.showZoneRaids then
          
            -- Raid Nodes above Blizzards Icons to make it Clickable for maximized Maps
            nodes[534][46965264] = { id = 669, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hellfire Citadel
            nodes[550][32963837] = { id = 477, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Highmaul
            nodes[543][51562719] = { id = 457, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Blackrock Foundry
          end

          
        --Draenor LFR
          if self.db.profile.showZoneLFR then
            
            if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
              nodes[525][47746482] = { mnID = 590, name = L["Seer Kazal"] .. " - " .. REQUIRES_LABEL .. " " .. GARRISON_LOCATION_TOOLTIP .. " " .. LEVEL .. " " .. ACTION_SPELL_CAST_START_MASTER .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " ", hideInfo = true, id = { 477, 457, 669 }, type = "LFR", showInZone = true, showOnContinent = false, showOnMinimap = false }
            end
            
            if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
              nodes[539][29001638] = { mnID = 582, name = L["Seer Kazal"] .. " - " .. REQUIRES_LABEL .. " " .. GARRISON_LOCATION_TOOLTIP .. " " .. LEVEL .. " " .. ACTION_SPELL_CAST_START_MASTER .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " ", hideInfo = true, id = { 477, 457, 669 }, type = "LFR", showInZone = true, showOnContinent = false, showOnMinimap = false }
            end
          end

        end


        --#################################
        --##### Continent Broken Isles ####
        --#################################

        if self.db.profile.showZoneBrokenIsles then

        --Broken Isles Dungeons
          if self.db.profile.showZoneDungeons then

          -- Raid Nodes above Blizzards Icons to make it Clickable for maximized Maps
            nodes[630][48068212] = { id = 707, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Vault of the Wardens
            nodes[630][61164111] = { id = 716, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Eye of Azshara
            nodes[630][87515684] = { id = 777, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Assault on Violet Hold
            nodes[646][15313666] = { id = 777, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Assault on Violet Hold
            nodes[646][64811675] = { id = 900, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Cathedral of Eternal Night
            nodes[680][50766553] = { id = 800, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Court of Stars
            nodes[680][41166150] = { id = 726, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Arcway
            nodes[641][37215031] = { id = 740, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Black Rook Hold
            nodes[641][59133135] = { id = 762, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Darkheart Thicket
            nodes[650][49566854] = { id = 767, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Neltharion's Lair
            nodes[634][52474544] = { id = 727, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Maw of Souls
            nodes[634][72647049] = { id = 721, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Halls of Valor
            nodes[882][22165661] = { id = 945, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Seat of the Triumvirate
          end

          
        -- Broken Isles Raids
          if self.db.profile.showZoneRaids then

          -- Raid Nodes above Blizzards Icons to make it Clickable for maximized Maps
            nodes[646][64002136] = { id = 875, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Tomb of Sargeras
            nodes[680][44145979] = { id = 786, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Nighthold
            nodes[641][56673747] = { id = 768, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Emerald Nightmare
            nodes[634][71127281] = { id = 861, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Trial of Valor
            nodes[885][54826253] = { id = 946, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Antorus, the Burning Throne
          end


        -- Broken Isles Raids without ClassicIcons
          if self.db.profile.showZonePassage and not db.activate.ClassicIcons then
            nodes[680][43346230] = { name = L["Way to the Instance Entrance"], hideInfo = true, id = { 726, 786 }, type = "PassageDungeonRaidMulti", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Arcway
          end


        -- Broken Isles ClassicIcons
          if db.activate.ClassicIcons then

            if self.db.profile.showZoneMultiple then
              nodes[680][43346230] = { name = L["Way to the Instance Entrance"], hideInfo = true, id = { 726, 786 }, type = "MultipleM", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Arcway
            end
          end

        end


        --#############################
        --##### Continent Zandalar ####
        --#############################

        if self.db.profile.showZoneZandalar then

        --Zandalar Dungeons
          if self.db.profile.showZoneDungeons then

            if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
              nodes[862][56105984] = { id = 1012, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Motherlode
            end

            if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
              nodes[862][39307154] = { id = 1012, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The MOTHERLODe
            end

          -- Dungeon Nodes above Blizzards Icons to make it Clickable for maximized Maps
            nodes[862][37593948] = { id = 1041, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Kings' Rest
            nodes[862][43533948] = { id = 968, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Atal'Dazar
            nodes[863][51256464] = { id = 1022, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Underrot
            nodes[864][51922546] = { id = 1030, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Temple of Sethraliss
          end


        --Zandalar Raids
          if self.db.profile.showZoneRaids then
            nodes[1528][47353182] = {  id = 1179, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Eternal Palace

          -- Raid Nodes above Blizzards Icons to make it Clickable for maximized Maps
            nodes[862][54262993] = { id = 1176, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Battle of Dazar'alor
            nodes[863][54146302] = { id = 1031, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Uldir
          end


        --Zandalar Raids without ClassicIcons
          if self.db.profile.showZonePassage and not db.activate.ClassicIcons then
            nodes[1355][50341233] = {  id = 1179, type = "PassageRaid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Eternal Palace
          end


        --Zandalar ClassicIcons
          if db.activate.ClassicIcons then

            if self.db.profile.showZoneRaids then
              nodes[1355][50341233] = {  id = 1179, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Eternal Palace
            end
          end


        -- Zandalar LFR
          if self.db.profile.showZoneLFR then

            if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
              nodes[862][57304305] = { mnID = 1164, name = L["Eppu"] .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " ", hideInfo = true, id = { 1176, 1031, 1179, 1036 }, type = "LFR", showInZone = true, showOnContinent = false, showOnMinimap = false }
            end
          end

        end


        --##############################
        --##### Continent Kul Tiras ####
        --##############################

        if self.db.profile.showZoneKulTiras then 

        -- Kul Tiras Dungeons
          if self.db.profile.showZoneDungeons then

            -- Dungeon Nodes above Blizzards Icons to make it Clickable for maximized Maps
            nodes[942][78592663] = { id = 1036, type = "Dungeon",  showInZone = true, showOnContinent = false, showOnMinimap = false } -- Shrine of Storm 
            nodes[1462][72933649] = { id = 1178, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Operation: Mechagon 
            nodes[895][84567878] = { id = 1001, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Freehold 
            nodes[896][33671253] = { id = 1021, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Waycrest Manor 
            nodes[1169][38926976] = { id = 1002, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Tol Dagor

            if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
              nodes[895][75632450] = { id = 1023, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Siege of Boralus
            end

            if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
              nodes[895][88285102] = { id = 1023, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Siege of Boralus
            end
          end

        -- Kul Tiras Raids
          if self.db.profile.showZoneRaids then

          -- Raid Nodes above Blizzards Icons to make it Clickable for maximized Maps
            nodes[942][83894693] = { id = 1036, type = "Raid",  showInZone = true, showOnContinent = false, showOnMinimap = false } -- Crucible of Storms

            if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
              nodes[895][74382837] = { id = 1176, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Battle of Dazar'alor
            end
          end


         -- Kul Tiras LFR
          if self.db.profile.showZoneLFR then

            if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
              nodes[895][75112192] = { mnID = 1161, name = L["Kiku"] .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " ", hideInfo = true, id = { 1176, 1031, 1179, 1036 }, type = "LFR", showInZone = true, showOnContinent = false, showOnMinimap = false }
            end
          end
        end


        --################################
        --##### Continent Shadowlands ####
        --################################

        if self.db.profile.showZoneShadowlands then

        -- Shadowlands Dungeons
          if self.db.profile.showZoneDungeons then

          -- Raid Nodes above Blizzards Icons to make it Clickable for maximized Maps
            nodes[1533][40145521] = { id = 1182, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Necrotic Wake
            nodes[1533][58552857] = { id = 1186, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Spires of Ascension
            nodes[1536][59396501] = { id = 1183, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Plaguefall
            nodes[1536][53115291] = { id = 1187, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Theater of Pain
            nodes[1565][35485413] = { id = 1184, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mists of Tirna Scithe
            nodes[1565][68666660] = { id = 1188, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- De Other Side
            nodes[1525][78474907] = { id = 1185, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Halls of Atonement
            nodes[1525][51073012] = { id = 1189, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Sanguine Depths
            nodes[2016][88914392] = { id = 1194, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Tazavesh, the Veiled Market
          end


        -- Shadowlands Raids
          if self.db.profile.showZoneRaids then

          -- Raid Nodes above Blizzards Icons to make it Clickable for maximized Maps
            nodes[1970][80495340] = { id = 1195, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Sepulcher of the First Ones
            nodes[1525][46424149] = { id = 1190, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Castle Nathria
            nodes[1543][69743201] = { id = 1193, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Sanctum of Domination  
          end

        end


        --#################################
        --##### Continent Dragon Isles ####
        --#################################

        if self.db.profile.showZoneDragonIsles then

        -- Dragonflight Dungeons
          if self.db.profile.showZoneDungeons then

          -- Dungeon Nodes above Blizzards Icons to make it Clickable for maximized Maps
            nodes[2023][60843898] = { id = 1198, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Nokhud Offensive
            nodes[2024][38896459] = { id = 1203, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Azure Vault
            nodes[2024][11514885] = { id = 1196, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Brackenhide Hollow
            nodes[2025][61148446] = { id = 1209, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Dawn of the Infinite
            nodes[2025][59216057] = { id = 1204, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Halls of Infusion
            nodes[2025][58274235] = { id = 1201, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Algeth'ar Academy
            nodes[2022][60087571] = { id = 1202, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ruby Life Pools
            nodes[2022][25715631] = { id = 1199, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Neltharus
          end


        -- Dragonflight Raids
          if self.db.profile.showZoneRaids then

          -- Raid Nodes above Blizzards Icons to make it Clickable for maximized Maps
            nodes[2200][27313104] = { id = 1207, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Amirdrassil, the Dream's Hope
            nodes[2025][74855511] = { id = 1200, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Vault of the Incarnates
            nodes[2025][73065567] = { dnID = L["Position of the real Instance Entrance"], id = 1200, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Vault of the Incarnates
            nodes[2133][48451191] = { id = 1208, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Aberrus, the Shadowed Crucible          
          end


        -- Dragonflight Passage
          if self.db.profile.showZonePassage and not db.activate.ClassicIcons then
            nodes[2023][18855124] = { id = 1207, type = "PassageRaid", showInZone = true, showOnContinent = false, showOnMinimap = false }-- Amirdrassil, the Dream's Hope
          end


        -- Dragonflight ClassicIcons
          if db.activate.ClassicIcons then

            if self.db.profile.showZoneRaids then
              nodes[2023][18855124] = { id = 1207, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false }-- Amirdrassil, the Dream's Hope
            end
          end

        end


        --###############################
        --##### Continent Khaz Algar ####
        --###############################

        if self.db.profile.showZoneKhazAlgar then

          -- Khaz Algar Dungeons
            if self.db.profile.showZoneDungeons then

            -- Dungeon Nodes above Blizzards Icons to make it Clickable for maximized Maps
              nodes[2214][55452162] = { id = 1210, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Darkflame Cleft
              nodes[2215][96973883] = { id = 1210, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Priory of the Sacred Flame
              nodes[2215][41324933] = { id = 1267, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Priory of the Sacred Flame
              nodes[2215][54906313] = { id = 1270, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Dawnbreaker
              nodes[2214][42700856] = { id = 1269, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Stonevault
              nodes[2214][42083948] = { id = 1298, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Operation: Floodgate
              nodes[2248][45234108] = { id = 1268, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Rookery
              nodes[2248][76584378] = { id = 1272, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Cinderbrew Meadery
              nodes[2255][46746917] = { id = 1274, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- City of Threads
              nodes[2255][49538100] = { id = 1271, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ara-Kara, City of Echoes
              nodes[2256][46746917] = { id = 1274, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- City of Threads
              nodes[2256][49538100] = { id = 1271, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ara-Kara, City of Echoes
              nodes[2216][52164580] = { id = 1271, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ara-Kara, City of Echoes
              nodes[2213][52164580] = { id = 1271, type = "Dungeon", dnID = DUNGEON_FLOOR_GILNEAS2, showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ara-Kara, City of Echoes
              nodes[2213][44191124] = { id = 1274, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- City of Threads
              nodes[2371][65246841] = { id = 1303, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Eco-Dome Al'dani
              nodes[2371][63587021] = { id = 1194, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Tazavesh, the Veiled Market
              nodes[2472][43860393] = { id = 1303, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Eco-Dome Al'dani
              nodes[2472][36321209] = { id = 1194, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Tazavesh, the Veiled Market
            end

          -- Khaz Algar Raids
            if self.db.profile.showZoneRaids then

            -- Raid Nodes above Blizzards Icons to make it Clickable for maximized Maps
              nodes[2255][43559029] = { id = 1273, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Nerub-ar Palace
              nodes[2256][43559029] = { id = 1273, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Nerub-ar Palace
              nodes[2213][35047242] = { id = 1273, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Nerub-ar Palace       
              nodes[2216][35047242] = { id = 1273, type = "Raid", dnID = DUNGEON_FLOOR_GILNEAS3, showInZone = true, showOnContinent = false, showOnMinimap = false } -- Nerub-ar Palace
              nodes[2346][42045031] = { id = 1296, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Liberation of Undermine
              nodes[2371][41662152] = { id = 1302, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Manaforge Omega
            end

        end

      end

    end
  end

end