local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

function ns.LoadMiniMapDungeonLocationinfo(self)
local db = ns.Addon.db.profile
local minimap = ns.minimap

--#####################################################################################################
--##########################        function to hide all minimap below         ##########################
--#####################################################################################################
if not db.activate.HideMapNote then


    --#####################################################################################################
    --################################         Continent / Zone Map        ################################
    --#####################################################################################################

      if db.activate.MiniMap then


        --#############################
        --##### Continent Kalimdor ####
        --#############################

        if self.db.profile.showMiniMapKalimdor then

        -- Kalimdor Dungeons
            if self.db.profile.showMiniMapDungeons then       
            minimap[11][54916646] = { id = 240, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Wailing Caverns 
            minimap[948][51102882] = { id = 67, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Stonecore

            -- Dungeon minimap above Blizzards Icons to make it Clickable for maximized Maps
            minimap[1][03067458] = { id = 240, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Wailing Caverns
            minimap[1][46200001] = { id = 226, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ragefire
            minimap[10][80190006] = { id = 226, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ragefire
            minimap[76][18729718] = { id = 226, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ragefire
            minimap[62][33009467] = { id = 227, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Blackfathom Deeps 
            minimap[77][15097658] = { id = 227, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Blackfathom Deeps 
            minimap[10][40496868] = { id = 240, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Wailing Caverns
            minimap[7][79421794] = { id = 240, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Wailing Caverns
            minimap[199][46952074] = { id = 240, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Wailing Caverns
            minimap[199][40779446] = { id = 234, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Razorfen Kraul
            minimap[199][51899825] = { id = 233, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Razorfen Downs
            minimap[70][13176945] = { id = 234, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Razorfen Kraul
            minimap[70][28867479] = { id = 233, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Razorfen Downs
            minimap[64][28021695] = { id = 234, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Razorfen Kraul
            minimap[64][46742333] = { id = 233, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Razorfen Downs
            minimap[71][39482205] = { id = 241, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Zul'Farrak
            minimap[78][93073504] = { id = 241, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Zul'Farrak
            minimap[64][56309765] = { id = 241, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Zul'Farrak
            minimap[75][57042578] = { id = 184, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- End Time
            minimap[75][68382951] = { id = 186, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hour of Twilight
            minimap[75][26333279] = { id = 251, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Old Hillsbrad Foothills
            minimap[75][22136381] = { id = 185, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Well of Eternity
            minimap[75][34438489] = { id = 255, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Black Morass
            minimap[75][60118272] = { id = 279, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Culling of Stratholme
            minimap[207][47385205] = { id = 67, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Stonecore
            minimap[249][60526415] = { id = 69, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Lost City of the Tol'vir
            minimap[249][69095283] = { id = 70, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Halls of Origination
            minimap[249][76708435] = { id = 68, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Vortex Pinnacle
            minimap[1527][60526415] = { id = 69, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Lost City of the Tol'vir
            minimap[1527][69095283] = { id = 70, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Halls of Origination
            minimap[71][24619233] = { id = 70, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Halls of Origination
            minimap[1527][76708435] = { id = 68, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Vortex Pinnacle
            minimap[69][76453593] = { id = 230, lfgid = 34, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dire Maul - Warpwood Quarter - East above Camp Mojache -- only Minimap
            minimap[69][66773483] = { id = 230, lfgid = 34, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dire Maul - Warpwood Quarter - East above Camp Mojache -- only Minimap

          end

        -- Kalimdor Dungeons without ClassicIcons is activ
          if self.db.profile.showMiniMapDungeons and not db.activate.ClassicIcons then
            minimap[69][60323015] = { id = 230, lfgid = 36, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dire Maul - Capital Gardens - West left Entrance 
            minimap[69][60303130] = { id = 230, lfgid = 36, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dire Maul - Capital Gardens - West right Entrance 
            minimap[69][62502490] = { id = 230, lfgid = 38, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dire Maul - Gordok Commons - North  
            minimap[67][78285518] = { id = 232, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Maraudon Foulspore Cavern 
            minimap[68][52152417] = { id = 232, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Maraudon Foulspore Cavern 
            minimap[68][44517669] = { id = 232, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Maraudon Foulspore Cavern first Entrance
          end

        --Kalimdor Raids
          if self.db.profile.showMiniMapRaids then
          -- Raid minimap above Blizzards Icons to make it Clickable for maximized Maps
          minimap[63][79821712] = { id = 78, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Firelands
          minimap[198][46797838] = { id = 78, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Firelands
          minimap[199][68439906] = { id = 760, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Onyxias Lair
          minimap[70][52217593] = { id = 760, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Onyxias Lair
          minimap[64][74612469] = { id = 760, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Onyxias Lair
          minimap[81][36449403] = { id = 743, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ruins of Ahn'Qiraj
          minimap[81][24328729] = { id = 744, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Temple of Ahn'Qiraj
          minimap[327][58941423] = { id = 743, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ruins of Ahn'Qiraj
          minimap[327][46790747] = { id = 744, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Temple of Ahn'Qiraj
          minimap[249][37008143] = { id = 74, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Throne of the Four Winds
          minimap[249][55184395] = { dnID = L["This instance entrance is in a different timeline. Other timeline can be activated at Zidormi"] .. "  => /way 56.01 35.14", id = 1180, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ny'alotha the Waking City
          minimap[1527][15130940] = { id = 743, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ruins of Ahn'Qiraj
          minimap[1527][07180499] = { id = 744, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Temple of Ahn'Qiraj
          minimap[1527][37008143] = { id = 74, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Throne of the Four Winds
          minimap[1527][38238069] = { dnID = L["Position of the real Instance Entrance"], id = 74, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Throne of the Four Winds
          minimap[1527][55184395] = { dnID = L["Instance Entrance"] .. " " .. L["switches weekly between"] .. " " .. L["Uldum"] .. " (" .. L["Kalimdor"] ..")" .. " & " .. L["Vale of Eternal Blossoms"] .. " (" .. L["Pandaria"] .. ")", id = 1180, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ny'alotha the Waking City
          minimap[71][12668471] = { dnID = L["Instance Entrance"] .. " " .. L["switches weekly between"] .. " " .. L["Uldum"] .. " (" .. L["Kalimdor"] ..")" .. " & " .. L["Vale of Eternal Blossoms"] .. " (" .. L["Pandaria"] .. ")", id = 1180, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ny'alotha the Waking City
          minimap[75][39601704] = { id = 750, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Battle of Mount Hyjal
          minimap[75][60872115] = { id = 187, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dragon Soul

          end

        --Kalimdor Passage without ClassicIcons
          if self.db.profile.showMiniMapPassage and not db.activate.ClassicIcons then
            minimap[199][45089400] = { dnID = L["Way to the Instance Entrance"], id = 233, type = "PassageDungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Razorfen Downs
            minimap[64][41662882] = { dnID = L["Way to the Instance Entrance"], id = 233, type = "PassageDungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Razorfen Downs
            minimap[1527][71755222] = { dnID = L["Way to the Instance Entrance"], id = 70, type = "PassageDungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Halls of Origination  
            minimap[10][38916921] = { mnID = 11, id = 240, TransportName = L["Way to the Instance Entrance"], name = "", type = "PassageDungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Wailing Caverns 
            minimap[66][29226253] = { dnID = L["Way to the Instance Entrance"], id = 232, type = "PassageDungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Maraudon Outside
            minimap[63][14161380] = { dnID = L["Way to the Instance Entrance"], id = 227, type = "PassageDungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Blackfathom Deeps 
            minimap[69][65503524] = { dnID = L["Way to the Instance Entrance"], id = 230, lfgid = 34, type = "PassageDungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dire Maul - Warpwood Quarter - East above Camp Mojache   
            minimap[69][77073692] = { dnID = L["Way to the Instance Entrance"], id = 230, lfgid = 34, type = "PassageDungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dire Maul - Warpwood Quarter - East above Camp Mojache   
          end


        --Kalimdor ClassicIcons
          if db.activate.ClassicIcons then  

            if self.db.profile.showMiniMapDungeons then 
              minimap[199][45089400] = { dnID = L["Way to the Instance Entrance"], id = 233, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Razorfen Downs
              minimap[64][41662882] = { dnID = L["Way to the Instance Entrance"], id = 233, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Razorfen Downs
              minimap[1527][71755222] = { dnID = L["Way to the Instance Entrance"], id = 70, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Halls of Origination
              minimap[63][14161380] = { dnID = L["Way to the Instance Entrance"], id = 227, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Blackfathom Deeps 
              minimap[66][29226253] = { dnID = L["Way to the Instance Entrance"], id = 232, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Maraudon Outside
              --minimap[69][65503524] = { id = 230, lfgid = 34, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dire Maul - Warpwood Quarter - East above Camp Mojache   
              --minimap[69][77073692] = { id = 230, lfgid = 34, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dire Maul - Warpwood Quarter - East above Camp Mojache   
            end

            if self.db.profile.showMiniMapMultiple then
              minimap[71][64864997] = { mnID = 75, hideInfo = true, id = { 187, 750, 279, 255, 251, 184, 185, 186, }, type = "MultipleM", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dragon Soul, The Battle for Mount Hyjal, The Culling of Stratholme, Black Morass, Old Hillsbrad Foothills, End Time, Well of Eternity, Hour of Twilight Heroic
              minimap[74][30857356] = { mnID = 75, hideInfo = true, id = { 187, 750, 279, 255, 251, 184, 185, 186, }, type = "MultipleM", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dragon Soul, The Battle for Mount Hyjal, The Culling of Stratholme, Black Morass, Old Hillsbrad Foothills, End Time, Well of Eternity, Hour of Twilight Heroic
            end

          end

        --Kalimdor Multiple
          if self.db.profile.showMiniMapMultiple and not db.activate.ClassicIcons then  
            minimap[71][64864997] = { mnID = 75, hideInfo = true, id = { 187, 750, 279, 255, 251, 184, 185, 186, }, type = "PassageDungeonRaidMulti", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dragon Soul, The Battle for Mount Hyjal, The Culling of Stratholme, Black Morass, Old Hillsbrad Foothills, End Time, Well of Eternity, Hour of Twilight Heroic
            minimap[74][30857356] = { mnID = 75, hideInfo = true, id = { 187, 750, 279, 255, 251, 184, 185, 186, }, type = "PassageDungeonRaidMulti", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dragon Soul, The Battle for Mount Hyjal, The Culling of Stratholme, Black Morass, Old Hillsbrad Foothills, End Time, Well of Eternity, Hour of Twilight Heroic
          end


        -- Kalimdor LFR
          if self.db.profile.showMiniMapLFR then
            minimap[75][63122722] = { hideInfo = true, id = { 187 }, name = L["Auridormi"] .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " ", type = "LFR", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal from Garrison to Ashran
          end

        end


        --####################################
        --##### Continent Eastern Kingdom ####
        --####################################

        if self.db.profile.showMiniMapEasternKingdom then

        -- Eastern Kingdom Dungeons
          if self.db.profile.showMiniMapDungeons then
            minimap[122][61303090] = { id = 249, type = "Dungeon", showOnContinent = false } -- Magisters' Terrace 
            minimap[95][85206430] = { id = 77, type = "Dungeon", showOnContinent = false } -- Zul'Aman 
            minimap[16][36502765] = { id = 239, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Uldaman (inside cave) 
            minimap[42][46866979] = { id = 860, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Return to Karazhan 
            minimap[55][24735143] = { id = 63, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Deadmines

          -- Dungeon minimap above Blizzards Icons to make it Clickable for maximized Maps
            minimap[50][72083291] = { id = 76, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Zul'gurub
            minimap[224][63942179] = { id = 76, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Zul'gurub
            minimap[224][22130243] = { id = 63, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true  } -- Deadmines 
            minimap[37][20223635] = { id = 238, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Stockade
            minimap[15][41121030] = { id = 1197, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Uldaman: Legacy of Tyr
            minimap[48][43478705] = { id = 239, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Uldaman
            minimap[241][19205411] = { id = 71, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Grim Batol
            minimap[56][74006930] = { id = 71, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Grim Batol
            minimap[26][26210814] = { id = 246, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Scholomance
            minimap[25][91190689] = { id = 246, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Scholomance
            minimap[22][69797356] = { id = 246, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Scholomance
            minimap[23][07369102] = { id = 246, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Scholomance
            minimap[25][05895291] = { id = 64, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Shadowfang Keep
            minimap[21][44926788] = { id = 64, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Shadowfang Keep
            minimap[18][85323227] = { id = 311, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Scarlet Halls
            minimap[18][84823043] = { id = 316, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Scarlet Monastery
            minimap[18][85263295] = { id = 311, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Scarlet Halls
            minimap[18][84542943] = { id = 316, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Scarlet Monastery
            minimap[19][79146119] = { id = 311, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Scarlet Halls
            minimap[19][68082061] = { id = 316, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Scarlet Monastery
            minimap[22][28811749] = { id = 311, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Scarlet Halls
            minimap[22][28281555] = { id = 316, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Scarlet Monastery
            minimap[23][27071151] = { id = 236, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stratholme
            minimap[95][81956434] = { id = 77, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Zul'Aman
            minimap[122][60973073] = { id = 249, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Magisters'Terrace
            minimap[203][48174041] = { id = 65, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Throne of the Tides
            minimap[204][70402953] = { id = 65, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Throne of the Tides
            minimap[33][80454193] = { id = 229, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Lower Blackrock Spire
            minimap[33][79033379] = { id = 559, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Upper Blackrock Spire
            minimap[35][39281819] = { id = 228, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Blackrock Depths
            minimap[30][29507480] = { id = 231, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Gnomeregan
            minimap[30][42311288] = { id = 231, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Gnomeregan
            minimap[30][71245337] = { id = 66, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Blackrock Caverns
          end


        -- Eastern Kingdom Raids
          if self.db.profile.showMiniMapRaids then

            -- Raid minimap above Blizzards Icons to make it Clickable for maximized Maps
            minimap[224][76080344] = { id = 745, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Karazhan
            minimap[17][22232177] = { id = 745, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Karazhan
            minimap[42][46987490] = { id = 745, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Karazhan
            minimap[36][23132639] = { id = 73, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Blackwing Descent
            minimap[32][39029679] = { id = 73, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Blackwing Descent
            minimap[48][81242207] = { id = 72, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Bastion of Twilight
            minimap[241][34097788] = { id = 72, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Bastion of Twilight
            minimap[122][44264560] = { id = 752, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Sunwell Plateau
            minimap[244][46054793] = { id = 75, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Baradin Hold
            minimap[33][64017153] = { id = 742, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Blackwing Lair
            minimap[35][53778131] = { id = 741, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Molten Core
          end


          -- Eastern Kingdom Passage
          if self.db.profile.showMiniMapPassage and not db.activate.ClassicIcons then  
            minimap[15][42031147] = { dnID = L["Way to the Instance Entrance"], id = 239, type = "PassageDungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Uldaman
            minimap[469][32793702] = { mnID = 30, dnID = L["Way to the Instance Entrance"], id = 231, type = "PassageDungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Gnomeregan
            minimap[27][31393804] = { mnID = 30, dnID = L["Way to the Instance Entrance"], id = 231, type = "PassageDungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Gnomeregan     
            minimap[51][69675353] = { dnID = L["Way to the Instance Entrance"], id = 237, type = "PassageDungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Temple of Atal'hakkar 
            minimap[36][20643322] = { mnID = 33, hideInfo = true, id = { 741, 742, 66, 228, 229, 559 }, name = L["Way to the Instance Entrance"], type = "PassageDungeonRaidMulti", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Molten Core, Blackwing Lair, Blackrock Caverns, Blackrock Depths, Lower Blackrock Spire, Upper Blackrock Spire 
            minimap[32][35268404] = { mnID = 33, name = "", type = "PassageDungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Molten Core, Blackwing Lair, Blackrock Caverns, Blackrock Depths, Lower Blackrock Spire, Upper Blackrock Spire 
            minimap[15][58543698] = { dnID = L["Way to the Instance Entrance"], id = 239, name = "", type = "PassageDungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Uldaman (Secondary Entrance) 
            minimap[23][43251854] = { dnID = L["Way to the Instance Entrance"], id = 236, lfgid = 274, type = "PassageDungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }-- Stratholme Service Entrance 
            minimap[33][68635371] = { mnID = 34, hideInfo = true, id = { 66 }, name = L["Way to the Instance Entrance"], type = "PassageDungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Blackrock Caverns
            minimap[33][65896169] = { mnID = 34, hideInfo = true, id = { 66 }, name = L["Way to the Instance Entrance"], type = "PassageDungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Blackrock Caverns
            minimap[33][45004700] = { mnID = 35, hideInfo = true, id = { 741, 228 }, name = L["Way to the Instance Entrance"], type = "PassageRaid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Blackrock Depths
            minimap[34][58792725] = { mnID = 33, dnID = DUNGEON_FLOOR_BURNINGSTEPPES14, name = "", type = "PassageDungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Blackrock Depths
            minimap[35][58168728] = { mnID = 33, dnID = DUNGEON_FLOOR_BURNINGSTEPPES14, name = "", type = "PassageDungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Blackrock Depths

            -- Passage minimap above Blizzards Icons to make it Clickable for maximized Maps
            minimap[52][42527168] = { dnID = L["Way to the Instance Entrance"], id = 63, type = "PassageDungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Deadmines   
          end


          -- Eastern Kingdom ClassicIcons
          if db.activate.ClassicIcons then

            if self.db.profile.showMiniMapMultiple then
              minimap[36][20643322] = { mnID = 33, hideInfo = true, id = { 741, 742, 66, 228, 229, 559 }, name = L["Way to the Instance Entrance"], type = "MultipleM", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Molten Core, Blackwing Lair, Blackrock Caverns, Blackrock Depths, Lower Blackrock Spire, Upper Blackrock Spire 
              --minimap[36][20643322] = { mnID = 33, name = "", type = "MultipleM", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Molten Core, Blackwing Lair, Blackrock Caverns, Blackrock Depths, Lower Blackrock Spire, Upper Blackrock Spire 
            end

            if self.db.profile.showMiniMapDungeons then
              minimap[15][42031147] = { dnID = L["Way to the Instance Entrance"], id = 239, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Uldaman
              minimap[469][32793702] = { dnID = L["Way to the Instance Entrance"], id = 231, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Gnomeregan
              minimap[27][31393804] = { dnID = L["Way to the Instance Entrance"], id = 231, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Gnomeregan
              minimap[51][69675353] = { dnID = L["Way to the Instance Entrance"], id = 237, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Temple of Atal'hakkar 
              minimap[52][42527168] = { dnID = L["Way to the Instance Entrance"], id = 63, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Deadmines 
              minimap[35][58168728] = { mnID = 33, dnID = DUNGEON_FLOOR_BURNINGSTEPPES14, name = "", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Blackrock Depths
              minimap[32][35268404] = { mnID = 33, name = "", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Molten Core, Blackwing Lair, Blackrock Caverns, Blackrock Depths, Lower Blackrock Spire, Upper Blackrock Spire 
              --minimap[15][58543698] = { id = 239, name = "", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Uldaman (Secondary Entrance) 
              --minimap[23][43251854] = { id = 236, lfgid = 274, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }-- Stratholme Service Entrance 
              minimap[33][75516099] = { id = 66, name = "", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Blackrock Caverns
            end

            if self.db.profile.showMiniMapRaids then
              minimap[33][45004700] = { mnID = 35, hideInfo = true, id = { 741, 228 }, name = L["Way to the Instance Entrance"], type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Blackrock Depths
            end

          end

          
        --Eastern Kingdom ContinentOldVanilla
          if self.db.profile.showMiniMapOldVanilla then
            minimap[23][35722308] = { mnID = 166, name = L["Secret Entrance"] .. " " .. L["(Wards of the Dread Citadel - Achievement)"] .. " - " .. L["Old Version"], type = "VInstanceR", showInZone = false, showOnContinent = false, showOnMinimap = true }-- Old Naxxramas version - Secret Entrance - Wards of the Dread Citadel 
            minimap[19][48275496] = { name = L["Old Keyring \n You get the Scarlet Key in the \n [Loot-Filled Pumpkin] from [Hallow's End Event] or from the [Auction House] \n now you can activate the [Old Keyring] here \n to activate old dungeonversions from the Scarlet Monastery"], type = "VKey1", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Scarlet Monastery Key for Old dungeons 
            minimap[2070][83723082] = { name = L["Old Keyring \n You get the Scarlet Key in the \n [Loot-Filled Pumpkin] from [Hallow's End Event] or from the [Auction House] \n now you can activate the [Old Keyring] here \n to activate old dungeonversions from the Scarlet Monastery"], type = "VKey1", showInZone = false, showOnContinent = false, showOnMinimap = true  } -- Scarlet Monastery Key for Old dungeons 
            minimap[18][82333243] = { mnID = 19, name = L["Use the Old Keyring"], dnID = L["Graveyard"] .. " - " .. L["Old Version"] .. "\n" .. L["Cathedral"] .. " - " .. L["Old Version"] .. "\n" .. L["Library"] .. " - " .. L["Old Version"] .. "\n" .. L["Armory"] .. " - " .. L["Old Version"], type = "MultiVInstanceD", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Scarlet Monastery Key for Old dungeons
            minimap[2070][82333243] = { mnID = 19, name = L["Use the Old Keyring"], dnID = L["Graveyard"] .. " - " .. L["Old Version"] .. "\n" .. L["Cathedral"] .. " - " .. L["Old Version"] .. "\n" .. L["Library"] .. " - " .. L["Old Version"] .. "\n" .. L["Armory"] .. " - " .. L["Old Version"], type = "MultiVInstanceD", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Scarlet Monastery Key for Old dungeons
            minimap[2070][83812772] = { id = 316, name ="", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Scarlet Monastery
            minimap[2070][85483158] = { id = 311, name ="", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Scarlet Halls 
            minimap[18][85353028] = { mnID = 304, name = L["Cathedral"] .. " - " .. L["Old Version"] .. " - " .. L["Use the Old Keyring"], type = "VInstanceD", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Scarlet Monastery - Cathedral 
            minimap[19][78882223] = { mnID = 304, name = L["Cathedral"] .. " - " .. L["Old Version"] .. " - " .. L["Use the Old Keyring"], type = "VInstanceD", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Scarlet Monastery - Cathedral"
            minimap[18][85153180] = { mnID = 303, name = L["Library"] .. " - " .. L["Old Version"] .. " - " .. L["Use the Old Keyring"], type = "VInstanceD", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Scarlet Monastery - Library 
            minimap[19][78255762] = { mnID = 303, name = L["Library"] .. " - " .. L["Old Version"] .. " - " .. L["Use the Old Keyring"], type = "VInstanceD", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Scarlet Monastery -"
            minimap[18][85573138] = { mnID = 304, name = L["Armory"] .. " - " .. L["Old Version"] .. " - " .. L["Use the Old Keyring"], type = "VInstanceD", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Scarlet Monastery - Armory
            minimap[19][86414766] = { mnID = 304, name = L["Armory"] .. " - " .. L["Old Version"] .. " - " .. L["Use the Old Keyring"], type = "VInstanceD", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Scarlet Mona"
            minimap[18][84763039] = { mnID = 302, name = L["Graveyard"] .. " - " .. L["Old Version"] .. " - " .. L["Use the Old Keyring"], type = "VInstanceD", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Scarlet Monastery - Graveyard 
            minimap[19][68832372] = { mnID = 302, name = L["Graveyard"] .. " - " .. L["Old Version"] .. " - " .. L["Use the Old Keyring"], type = "VInstanceD", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Scarlet Monastery - Graveyard  
            minimap[22][69767181] = { mnID = 306, name = L["Secret Entrance"] .. " " .. L["(Memory of Scholomance - Achievement)"] .. " - " .. L["Old Version"], type = "VInstanceD", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Old Scholomance version - Memory of Scholomance - Secret Entrance Old Scholomance version
          end
        end


        --############################
        --##### Continent Outland ####
        --############################

        if self.db.profile.showMiniMapOutland then

        -- Outland Dungeons
          if self.db.profile.showMiniMapDungeons then

        -- Dungeon minimap above Blizzards Icons to make it Clickable for maximized Maps
            minimap[108][39627318] = { id = 253, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Shadow Labyrinth
            minimap[108][44596560] = { id = 252, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Sethekk Halls
            minimap[108][39645806] = { id = 250, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Mana Tombs
            minimap[108][34676559] = { id = 247, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Auchenai Crypts
            minimap[107][96898503] = { id = 250, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Mana Tombs
            minimap[107][92039239] = { id = 247, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Auchenai Crypts
            minimap[102][48953592] = { id = 260, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Slave Pens
            minimap[102][50473333] = { id = 261, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Steamvault
            minimap[105][35179927] = { id = 261, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Steamvault
            minimap[102][54173443] = { id = 262, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Underbog
            minimap[100][47925342] = { id = 248, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hellfire Ramparts
            minimap[100][48065191] = { id = 259, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Shattered Halls
            minimap[100][46015179] = { id = 256, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Blood Furnace
            minimap[109][71695506] = { id = 257, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Botanica
            minimap[109][74365774] = { id = 254, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Arcatraz
            minimap[109][70536964] = { id = 258, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Mechanar
          end


        -- Outland Raids
          if self.db.profile.showMiniMapRaids then

          -- Raid minimap above Blizzards Icons to make it Clickable for maximized Maps
            minimap[104][71054628] = { id = 751, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Black Temple
            minimap[102][51903348] = { id = 748, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Serpentshrine Cavern
            minimap[105][36509941] = { id = 748, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Serpentshrine Cavern
            minimap[100][46575283] = { id = 747, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Magtheridon's Lair
            minimap[105][69062414] = { id = 746, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Gruul's Lair
            minimap[109][06895168] = { id = 746, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Gruul's Lair
            minimap[109][73596372] = { id = 746, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Eye
          end
        end


        --##############################
        --##### Continent Northrend ####
        --##############################

        if self.db.profile.showMiniMapNorthrend then

          -- Northrend Dungeon
          if self.db.profile.showMiniMapDungeons then
            minimap[127][34154413] = { id = 283, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Violet Hold

            -- Dungeon minimap above Blizzards Icons to make it Clickable for maximized Maps
            minimap[117][57884951] = { id = 285, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Utgarde Keep
            minimap[117][57224649] = { id = 286, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Utgarde Pinnacle
            minimap[116][17552120] = { id = 273, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Drak'Tharon Keep
            minimap[121][76432140] = { id = 274, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Gundrak
            minimap[121][80892832] = { id = 274, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Gundrak
            minimap[121][28678693] = { id = 273, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Drak'Tharon Keep
            minimap[115][28385167] = { id = 271, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ahn'kahet: The Old Kingdom
            minimap[115][25995079] = { id = 272, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Azjol-Nerub
            minimap[120][87996837] = { id = 274, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Gundrak
            minimap[120][45322148] = { id = 275, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Halls of Lightning
            minimap[120][39582689] = { id = 277, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Halls of Stone
            minimap[120][14753428] = { id = 284, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Trial of the Champion
            minimap[118][54848985] = { id = 280, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Forge of Souls
            minimap[118][55319084] = { id = 276, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Halls of Reflection
            minimap[118][54729168] = { id = 278, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Pit of Saron
            minimap[118][74172044] = { id = 284, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Trial of the Champion
            minimap[123][78140236] = { id = 280, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Forge of Souls
            minimap[123][79120444] = { id = 276, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Halls of Reflection
            minimap[123][77890620] = { id = 278, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Pit of Saron
            minimap[114][28592772] = { id = 281, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Nexus
            minimap[114][26602746] = { id = 282, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Oculus
          end

          -- Northrend Raids
          if self.db.profile.showMiniMapRaids then

          -- Raid minimap above Blizzards Icons to make it Clickable for maximized Maps
            minimap[116][03065282] = { id = 754, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Naxxramas
            minimap[115][87345100] = { id = 754, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Naxxramas
            minimap[115][61345259] = { id = 761, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Ruby Sanctum
            minimap[115][60005701] = { id = 755, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Obsidian Sanctum
            minimap[120][41571779] = { id = 759, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ulduar
            minimap[120][15623548] = { id = 757, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Trial of the Crusader
            minimap[118][53808709] = { id = 758, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- TIcecrown Citadel
            minimap[118][41519428] = { id = 753, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Vault of Archavon
            minimap[118][75162180] = { id = 757, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Trial of the Crusader
            minimap[119][93866206] = { id = 753, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Vault of Archavon
            minimap[123][50041168] = { id = 753, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Vault of Archavon
            minimap[114][27522673] = { id = 756, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Eye of Eternity
          end
        end


        --#############################
        --##### Continent Pandaria ####
        --#############################

        if self.db.profile.showMiniMapPandaria then

        -- Pandaria Dungeons
          if self.db.profile.showMiniMapDungeons then

          -- Dungeon minimap above Blizzards Icons to make it Clickable for maximized Maps
          minimap[371][56175786] = { id = 313, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Temple of the Jade Serpent
          minimap[371][14504859] = { id = 321, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Mogu'shan Palace
          minimap[418][35931925] = { id = 302, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stormstout Brewery
          minimap[376][36066909] = { id = 302, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stormstout Brewery
          minimap[422][91105965] = { id = 302, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stormstout Brewery
          minimap[422][75842030] = { id = 303, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Gate of the Setting Sun
          minimap[376][15261542] = { id = 303, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Gate of the Setting Sun
          minimap[388][34688151] = { id = 324, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Siege of Niuzao Temple
          minimap[388][78992402] = { id = 312, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Shado-Pan Monastery
          minimap[379][36714746] = { id = 312, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Shado-Pan Monastery
          minimap[390][80603303] = { id = 321, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Mogu'shan Palace
          minimap[390][15837441] = { id = 303, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Gate of the Setting Sun
          minimap[1530][81093057] = { id = 321, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Mogu'shan Palace
          end


        -- Pandaria Raids
          if self.db.profile.showMiniMapRaids then

          -- Raid minimap above Blizzards Icons to make it Clickable for maximized Maps
            minimap[371][21595793] = { id = 320, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Terrace of Endless Spring
            minimap[376][69680536] = { id = 320, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Terrace of Endless Spring
            minimap[433][48456145] = { id = 320, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Terrace of Endless Spring
            minimap[371][12005202] = { id = 369, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Siege of Orgrimmar
            minimap[422][38923499] = { id = 330, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Heart of Fear
            minimap[379][59603917] = { id = 317, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Mogu'Shan Vaults
            minimap[504][63833203] = { id = 362, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Throne of Thunder
            minimap[390][73714248] = { id = 369, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Siege of Orgrimmar
            minimap[390][39604763] = { dnID = L["This instance entrance is in a different timeline. Other timeline can be activated at Zidormi"] .. "  => /way 80.47 31.95", id = 1180, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ny'alotha the Waking City
            minimap[1530][40044556] = { dnID = L["Instance Entrance"] .. " " .. L["switches weekly between"] .. " " .. L["Uldum"] .. " (" .. L["Kalimdor"] ..")" .. " & " .. L["Vale of Eternal Blossoms"] .. " (" .. L["Pandaria"] .. ")", id = 1180, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ny'alotha the Waking City
            minimap[1530][74114014] = { id = 369, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Siege of Orgrimmar
            minimap[1530][72684208] = { dnID = L["Position of the real Instance Entrance"], id = 369, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Siege of Orgrimmar
          end


        -- Pandaria LFR
          if self.db.profile.showMiniMapLFR then
            minimap[390][83153063] = { hideInfo = true, id = { 317, 330, 362, 320 }, name = L["Lorewalker Han"] .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " ", type = "LFR", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal from Garrison to Ashran
            minimap[1530][83712804] = { hideInfo = true, id = { 317, 330, 362, 320 }, name = L["Lorewalker Han"] .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " ", type = "LFR", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal from Garrison to Ashran
          end
        end


        --############################
        --##### Continent Draenor ####
        --############################

        if self.db.profile.showMiniMapDraenor then


        -- Draenor Dungeons
          if self.db.profile.showMiniMapDungeons then

          -- Raid minimap above Blizzards Icons to make it Clickable for maximized Maps
            minimap[525][49922480] = { id = 385, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Blackmaul Slag Mines
            minimap[543][07494267] = { id = 385, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Blackmaul Slag Mines
            minimap[543][45411353] = { id = 558, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Iron Docks
            minimap[543][55153173] = { id = 536, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Grimrail Depot
            minimap[543][59574566] = { id = 556, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Everbloom
            minimap[535][46297394] = { id = 547, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Auchindoun
            minimap[539][31864255] = { id = 537, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Shadowmoon Burial Grounds
            minimap[542][35583361] = { id = 476, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Skyreach
            minimap[542][75031543] = { id = 537, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Shadowmoon Burial Grounds
          end


        --Draenor Raids
          if self.db.profile.showMiniMapRaids then
          
            -- Raid minimap above Blizzards Icons to make it Clickable for maximized Maps
            minimap[534][46965264] = { id = 669, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hellfire Citadel
            minimap[550][32963837] = { id = 477, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Highmaul
            minimap[543][51562719] = { id = 457, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Blackrock Foundry
          end
        
        end


        --#################################
        --##### Continent Broken Isles ####
        --#################################

        if self.db.profile.showMiniMapBrokenIsles then

        --Broken Isles Dungeons
          if self.db.profile.showMiniMapDungeons then

          -- Raid minimap above Blizzards Icons to make it Clickable for maximized Maps
            minimap[630][48068212] = { id = 707, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Vault of the Wardens
            minimap[630][61164111] = { id = 716, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Eye of Azshara
            minimap[630][87515684] = { id = 777, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Assault on Violet Hold
            minimap[646][15313666] = { id = 777, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Assault on Violet Hold
            minimap[646][64811675] = { id = 900, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Cathedral of Eternal Night
            minimap[680][50766553] = { id = 800, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Court of Stars
            minimap[680][41166150] = { id = 726, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Arcway
            minimap[641][37215031] = { id = 740, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Black Rook Hold
            minimap[641][59133135] = { id = 762, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Darkheart Thicket
            minimap[650][49566854] = { id = 767, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Neltharion's Lair
            minimap[634][52474544] = { id = 727, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Maw of Souls
            minimap[634][72647049] = { id = 721, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Halls of Valor
            minimap[882][22165661] = { id = 945, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Seat of the Triumvirate
          end

          
        --Broken Isles Raids
          if self.db.profile.showMiniMapRaids then

          -- Raid minimap above Blizzards Icons to make it Clickable for maximized Maps
            minimap[646][64002136] = { id = 875, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Tomb of Sargeras
            minimap[680][44145979] = { id = 786, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Nighthold
            minimap[641][56673747] = { id = 768, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Emerald Nightmare
            minimap[634][71127281] = { id = 861, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Trial of Valor
            minimap[885][54826253] = { id = 946, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Antorus, the Burning Throne
          end


        --Broken Isles Raids without ClassicIcons
          if self.db.profile.showMiniMapPassage and not db.activate.ClassicIcons then
            minimap[680][43346230] = { name = L["Way to the Instance Entrance"], hideInfo = true, id = { 726, 786 }, type = "PassageDungeonRaidMulti", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Arcway
          end


        --Broken Isles ClassicIcons
          if db.activate.ClassicIcons then

            if self.db.profile.showMiniMapMultiple then
              minimap[680][43346230] = { name = L["Way to the Instance Entrance"], hideInfo = true, id = { 726, 786 }, type = "MultipleM", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Arcway
            end
          end

        end


        --#############################
        --##### Continent Zandalar ####
        --#############################

        if self.db.profile.showMiniMapZandalar then

        --Zandalar Dungeons
          if self.db.profile.showMiniMapDungeons then

            if self.faction == "Alliance" or db.activate.MiniMapEnemyFaction then
              minimap[862][39307154] = { id = 1012, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The MOTHERLODe
            end

          -- Dungeon minimap above Blizzards Icons to make it Clickable for maximized Maps
            minimap[862][37593948] = { id = 1041, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Kings' Rest
            minimap[862][43533948] = { id = 968, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Atal'Dazar
            minimap[863][51256464] = { id = 1022, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Underrot
            minimap[864][51922546] = { id = 1030, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Temple of Sethraliss
          end


        --Zandalar Raids
          if self.db.profile.showMiniMapRaids then
            minimap[1528][47353182] = {  id = 1179, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Eternal Palace

          -- Raid minimap above Blizzards Icons to make it Clickable for maximized Maps
            minimap[862][54262993] = { id = 1176, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Battle of Dazar'alor
            minimap[863][54146302] = { id = 1031, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Uldir
          end


        --Zandalar Raids without ClassicIcons
          if self.db.profile.showMiniMapPassage and not db.activate.ClassicIcons then
            minimap[1355][50341233] = {  id = 1179, type = "PassageRaid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Eternal Palace
          end


        --Zandalar ClassicIcons
          if db.activate.ClassicIcons then

            if self.db.profile.showMiniMapRaids then
              minimap[1355][50341233] = {  id = 1179, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Eternal Palace
            end
          end

        end


        --##############################
        --##### Continent Kul Tiras ####
        --##############################

        if self.db.profile.showMiniMapKulTiras then 

        -- Kul Tiras Dungeons
          if self.db.profile.showMiniMapDungeons then

            -- Dungeon minimap above Blizzards Icons to make it Clickable for maximized Maps
            minimap[942][78592663] = { id = 1036, type = "Dungeon",  showInZone = false, showOnContinent = false, showOnMinimap = true } -- Shrine of Storm 
            minimap[1462][72933649] = { id = 1178, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Operation: Mechagon 
            minimap[895][84567878] = { id = 1001, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Freehold 
            minimap[896][33671253] = { id = 1021, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Waycrest Manor 
            minimap[1169][38926976] = { id = 1002, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Tol Dagor

            if self.faction == "Alliance" or db.activate.MiniMapEnemyFaction then
              minimap[895][75632450] = { id = 1023, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Siege of Boralus
            end

            if self.faction == "Horde" or db.activate.MiniMapEnemyFaction then
              minimap[895][88285102] = { id = 1023, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true  } -- Siege of Boralus
            end
          end

        -- Kul Tiras Raids
          if self.db.profile.showMiniMapRaids then

          -- Raid minimap above Blizzards Icons to make it Clickable for maximized Maps
            minimap[942][83894693] = { id = 1036, type = "Raid",  showInZone = false, showOnContinent = false, showOnMinimap = true } -- Crucible of Storms

            if self.faction == "Alliance" or db.activate.MiniMapEnemyFaction then
              minimap[895][74382837] = { id = 1176, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Battle of Dazar'alor
            end
          end


        -- Kul Tiras LFR
          if self.db.profile.showMiniMapLFR then

            if self.faction == "Horde" or db.activate.MiniMapEnemyFaction then
              minimap[895][75112192] = { mnID = 1161, name = L["Kiku"] .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " ", hideInfo = true, id = { 1176, 1031, 1179, 1036 }, type = "LFR", showInZone = false, showOnContinent = false, showOnMinimap = true }
            end
          end

        end


        --################################
        --##### Continent Shadowlands ####
        --################################

        if self.db.profile.showMiniMapShadowlands then

        -- Shadowlands Dungeons
          if self.db.profile.showMiniMapDungeons then

          -- Raid minimap above Blizzards Icons to make it Clickable for maximized Maps
            minimap[1533][40145521] = { id = 1182, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Necrotic Wake
            minimap[1533][58552857] = { id = 1186, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Spires of Ascension
            minimap[1536][59396501] = { id = 1183, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Plaguefall
            minimap[1536][53115291] = { id = 1187, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Theater of Pain
            minimap[1565][35485413] = { id = 1184, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Mists of Tirna Scithe
            minimap[1565][68666660] = { id = 1188, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- De Other Side
            minimap[1525][78474907] = { id = 1185, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Halls of Atonement
            minimap[1525][51073012] = { id = 1189, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Sanguine Depths
            minimap[2016][88914392] = { id = 1194, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Tazavesh, the Veiled Market
          end


        -- Shadowlands Raids
          if self.db.profile.showMiniMapRaids then

          -- Raid minimap above Blizzards Icons to make it Clickable for maximized Maps
            minimap[1970][80495340] = { id = 1195, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Sepulcher of the First Ones
            minimap[1525][46424149] = { id = 1190, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Castle Nathria
            minimap[1543][69743201] = { id = 1193, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Sanctum of Domination  
          end

        end


        --#################################
        --##### Continent Dragon Isles ####
        --#################################

        if self.db.profile.showMiniMapDragonIsles then

        -- Dragonflight Dungeons
          if self.db.profile.showMiniMapDungeons then

          -- Dungeon minimap above Blizzards Icons to make it Clickable for maximized Maps
            minimap[2023][60843898] = { id = 1198, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Nokhud Offensive
            minimap[2024][38896459] = { id = 1203, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Azure Vault
            minimap[2024][11514885] = { id = 1196, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Brackenhide Hollow
            minimap[2025][61148446] = { id = 1209, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dawn of the Infinite
            minimap[2025][59216057] = { id = 1204, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Halls of Infusion
            minimap[2025][58274235] = { id = 1201, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Algeth'ar Academy
            minimap[2022][60087571] = { id = 1202, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ruby Life Pools
            minimap[2022][25715631] = { id = 1199, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Neltharus
          end


        -- Dragonflight Raids
          if self.db.profile.showMiniMapRaids then

          -- Raid minimap above Blizzards Icons to make it Clickable for maximized Maps
            minimap[2200][27313104] = { id = 1207, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Amirdrassil, the Dream's Hope
            minimap[2025][74855511] = { id = 1200, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Vault of the Incarnates
            minimap[2025][73065567] = { dnID = L["Position of the real Instance Entrance"], id = 1200, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Vault of the Incarnates
            minimap[2133][48451191] = { id = 1208, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Aberrus, the Shadowed Crucible          
          end


        -- Dragonflight Passage
          if self.db.profile.showMiniMapPassage and not db.activate.ClassicIcons then
            minimap[2023][18855124] = { id = 1207, type = "PassageRaid", showInZone = false, showOnContinent = false, showOnMinimap = true }-- Amirdrassil, the Dream's Hope
          end


        -- Dragonflight ClassicIcons
          if db.activate.ClassicIcons then

            if self.db.profile.showMiniMapRaids then
              minimap[2023][18855124] = { id = 1207, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true }-- Amirdrassil, the Dream's Hope
            end
          end

        end


        --##################################
        --##### Continent Khaz Algar #######
        --##################################

        if self.db.profile.showMiniMapKhazAlgar then

          -- Khaz Algar Dungeons
            if self.db.profile.showMiniMapDungeons then
  
              -- Dungeon minimap above Blizzards Icons to make it Clickable for maximized Maps
              minimap[2214][55452162] = { id = 1210, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Darkflame Cleft
              minimap[2215][41324933] = { id = 1267, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Priory of the Sacred Flame
              minimap[2215][54906313] = { id = 1270, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Dawnbreaker
              minimap[2214][42700856] = { id = 1269, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Stonevault
              minimap[2214][42083948] = { id = 1298, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Operation: Floodgate
              minimap[2248][45234108] = { id = 1268, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Rookery
              minimap[2248][76584378] = { id = 1272, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Cinderbrew Meadery
              minimap[2255][46746917] = { id = 1274, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- City of Threads
              minimap[2255][49538100] = { id = 1271, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ara-Kara, City of Echoes
              minimap[2256][46746917] = { id = 1274, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- City of Threads
              minimap[2256][49538100] = { id = 1271, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ara-Kara, City of Echoes
              minimap[2216][49538100] = { id = 1271, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ara-Kara, City of Echoes
              minimap[2213][49538100] = { id = 1271, type = "Dungeon", dnID = DUNGEON_FLOOR_GILNEAS2, showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ara-Kara, City of Echoes
              minimap[2213][44191124] = { id = 1274, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- City of Threads
            end


          -- Khaz Algar Raids
            if self.db.profile.showMiniMapRaids then

            -- Raid minimap above Blizzards Icons to make it Clickable for maximized Maps
              minimap[2255][43559029] = { id = 1273, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Nerub-ar Palace
              minimap[2256][43559029] = { id = 1273, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Nerub-ar Palace
              minimap[2213][35047242] = { id = 1273, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Nerub-ar Palace              
              minimap[2216][35047242] = { id = 1273, type = "Raid", dnID = DUNGEON_FLOOR_GILNEAS3, showInZone = false, showOnContinent = false, showOnMinimap = true } -- Nerub-ar Palace
              minimap[2346][41554877] = { id = 1296, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Liberation of Undermine
            end

          -- Khaz Algar Delves
            if self.db.profile.showMiniMapPassage then 
              -- Azj-Kathet
              minimap[2255][54917231] = { name = "", TransportName = L["Way to the Instance Entrance"], delveID = 2259, type = "DelvesPassage", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Tak-Rethan-Abyss
              minimap[2255][51858822] = { name = "", TransportName = L["Way to the Instance Entrance"], delveID = 2299, type = "DelvesPassage", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Underkeep
              minimap[2255][32757683] = { name = "", TransportName = L["Way to the Instance Entrance"], delveID = 2348, type = "DelvesPassage", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Zekvir's Lair
              minimap[2255][45732253] = { name = "", TransportName = L["Way to the Instance Entrance"], delveID = 2347, type = "DelvesPassage", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Spiral Weave
              minimap[2213][10023383] = { name = "", TransportName = L["Way to the Instance Entrance"], delveID = 2348, type = "DelvesPassage", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Zekvir's Lair
              minimap[2213][56576350] = { name = "", TransportName = L["Way to the Instance Entrance"], delveID = 2299, type = "DelvesPassage", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Underkeep
              minimap[2213][67272122] = { name = "", TransportName = L["Way to the Instance Entrance"], delveID = 2259, type = "DelvesPassage", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Tak-Rethan-Abyss
              minimap[2216][67272122] = { name = "", TransportName = L["Way to the Instance Entrance"], delveID = 2259, type = "DelvesPassage", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Tak-Rethan-Abyss
              -- Hallowfall
              minimap[2215][70643095] = { name = "", TransportName = L["Way to the Instance Entrance"], delveID = 2312, type = "DelvesPassage", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Mycomancer Cavern
              minimap[2215][66716170] = { name = "", TransportName = L["Way to the Instance Entrance"], delveID = 2310, type = "DelvesPassage", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Skittering Breach
              minimap[2215][50715050] = { name = "", TransportName = L["Way to the Instance Entrance"], delveID = 2301, type = "DelvesPassage", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Sinkhole
              minimap[2215][35324593] = { name = "", TransportName = L["Way to the Instance Entrance"], delveID = 2277, type = "DelvesPassage", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Nightfall Sanctum
              -- The Ringing Deeps
              minimap[2214][46114791] = { name = "", TransportName = L["Way to the Instance Entrance"], delveID = 2251, type = "DelvesPassage", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Waterworks
              minimap[2214][69403862] = { name = "", TransportName = L["Way to the Instance Entrance"], delveID = 2302, type = "DelvesPassage", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Dread Pit
              minimap[2214][76859810] = { name = "", TransportName = L["Way to the Instance Entrance"], delveID = 2396, type = "DelvesPassage", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Excavation Site 9
              -- Isle of Dorn
              minimap[2248][38907328] = { name = "", TransportName = L["Way to the Instance Entrance"], delveID = 2269, type = "DelvesPassage", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Earthcrawl Mines
              minimap[2248][52526626] = { name = "", TransportName = L["Way to the Instance Entrance"], delveID = 2249, type = "DelvesPassage", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Fungal Folly
              minimap[2248][61644271] = { name = "", TransportName = L["Way to the Instance Entrance"], delveID = 2396, type = "DelvesPassage", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Kriegval's Rest
              -- Undermine
              minimap[2346][53870930] = { name = "", TransportName = L["Way to the Instance Entrance"], delveID = 2425, type = "DelvesPassage", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Kriegval's Rest

            end

        end


      end
  end
end