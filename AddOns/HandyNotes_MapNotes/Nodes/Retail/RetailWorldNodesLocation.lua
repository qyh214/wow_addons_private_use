local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

function ns.LoadWorldNodesLocationInfo(self)
local db = ns.Addon.db.profile
local nodes = ns.nodes

--#####################################################################################################
--##########################        function to hide all nodes below         ##########################
--#####################################################################################################
    if not db.activate.HideMapNote then

        if db.activate.CosmosMap then

        --  Shadownlands
            if self.db.profile.showCosmosShadowlands then
                nodes[946][18924083] = { mnID = 1670, id = { 1190, 1193, 1195 }, type = "LFR", showInZone = true, name = L["Ta'elfar"] .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " "} -- LFR
                nodes[946][13274083] = { mnID = 1550, id = { 1195, 1193, 1190 }, type = "Raid", showInZone = true } -- Raids
                nodes[946][16104083] = { mnID = 1550, id = { 1182, 1186, 1183, 1187, 1184, 1188, 1185, 1189, 1194 }, type = "Dungeon", showInZone = true } -- Dungeons
                nodes[946][21504083] = { mnID = 1550, name = "", type = "Portal", showInZone = true, TransportName = L["Oribos"] .. " " .. L["Portals"] .. "\n" .. " ==> " .. ORGRIMMAR .. "\n" .. " ==> " .. STORMWIND .. "\n" .. " ==> " .. L["Zereth Mortis"] .. "\n" .. " ==> " .. L["The Maw"] .. "\n" .. " ==> " .. L["Korthia"] .. "\n" .. "\n" .. L["Zereth Mortis"] .. " " .. L["Portal"] .. "\n" .. " ==> " .. L["Oribos"] .. "\n" .. "\n" .. L["The Maw"] .. " " .. L["Portal"] .. "\n" .. " ==> " .. L["Oribos"] .. "\n" .. "\n" .. L["Korthia"] .. " " .. L["Portal"] .. "\n" .. " ==> " .. L["Oribos"] } -- Portals
            end

        -- Outlands
            if self.db.profile.showCosmosOutland then
                nodes[946][16108980] = { mnID = 101, id = { 749, 749, 751 }, type = "Raid", showInZone = true } -- Raids
                nodes[946][18928980] = { mnID = 101, id = { 247, 250, 252, 253, 254, 257, 258 }, type = "Dungeon", showInZone = true } -- Dungeons
                nodes[946][21508980] = { mnID = 101, name = "", type = "Portal", showInZone = true, TransportName = L["Shattrath City"] .. " " .. L["Portals"] .. "\n" .. " ==> " .. ORGRIMMAR .. "\n" .. " ==> " .. STORMWIND .. "\n" .. " ==> " .. L["Isle of Quel'Danas"] .. "\n" .. "\n" .. L["Hellfire Peninsula"] .. " " .. L["Portal"] .. "\n" .. " ==> " .. ORGRIMMAR .. " / " .. STORMWIND } -- Portals
            end

        -- Draenor
            if self.db.profile.showCosmosDraenor then
                nodes[946][80954389] = { mnID = 572, id = { 457, 477, 669 }, type = "Raid", showInZone = true } -- Raids
                nodes[946][83704389] = { mnID = 572, id = { 385, 536, 556, 558, 537, 476, 547 }, type = "Dungeon", showInZone = true } -- Dungeons
                nodes[946][86454389] = { mnID = 572, id = { 477, 457, 669 }, type = "LFR", showInZone = true, name = L["Seer Kazal"] .. " - " .. REQUIRES_LABEL .. " " .. GARRISON_LOCATION_TOOLTIP .. " " .. LEVEL .. " " .. ACTION_SPELL_CAST_START_MASTER .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " " } -- LFR
                nodes[946][89204389] = { mnID = 572, name = "", type = "Portal", showInZone = true, TransportName = L["Ashran"] .. " " .. L["Portal"] .. "\n" .. " ==> " .. ORGRIMMAR .. "\n" .. " ==> " .. STORMWIND .. "\n" .. " ==> " .. SPLASH_NEW_6_2_FEATURE1_TITLE .. "\n" .. "\n" .. SPLASH_NEW_6_2_FEATURE1_TITLE .. " " .. L["Portal"] .. "\n" .. " ==> " .. L["Ashran"] .. "\n" .. "\n" .. GARRISON_LOCATION_TOOLTIP .. " " .. L["Portal"] .. "\n" .. " ==> " .. L["Ashran"] } -- Portals
            end

        -- Kalimdor
            if self.db.profile.showCosmosKalimdor then
                nodes[946][39006930] = { mnID = 12, name = POSTMASTER_PIPE_KALIMDOR, type = "LKalimdor", showInZone = true } -- Expansion Logo
                nodes[946][39007400] = { mnID = 12, id = { 74, 78, 760, 743, 744, 1180, 187 }, type = "Raid", showInZone = true } -- Raids
                nodes[946][39007850] = { mnID = 12, id = { 233, 230, 241, 234, 68, 69, 70, 67 }, type = "Dungeon", showInZone = true } -- Dungeons
                nodes[946][39008300] = { mnID = 12, name = "", type = "Portal", showInZone = true, TransportName = L["Silithus"] .. "\n" .. " ==> " .. L["Zandalar"] .. "\n" .. " ==> " .. L["Boralus, Tiragarde Sound"] .. "\n" .. "\n" .. DUNGEON_FLOOR_TANARIS18 .. "\n" .. " ==> " .. ORGRIMMAR .. "\n" .. " ==> " .. STORMWIND .. "\n" .. "\n" .. POSTMASTER_LETTER_HYJAL .. "\n" .. " ==> " .. ORGRIMMAR .. "\n" .. " ==> " .. STORMWIND .. "\n" .. "\n" .. L["Darkshore"] .. "\n" .. " ==> " .. L["Zandalar"] .. "\n" .. " ==> " .. L["Boralus, Tiragarde Sound"] .. "\n" .. "\n" .. "\n" .. ORGRIMMAR .. " - " .. FACTION_HORDE .. "\n" .. L["Portalroom"] .. "\n" .. " ==> " .. L["Silvermoon City"] .. "\n" .. " ==> " .. L["Valdrakken"] .. "\n" .. " ==> " .. L["Oribos"] .. "\n" .. " ==> " .. L["Azsuna"] .. "\n" .. " ==> " .. L["Zuldazar"] .. "\n" .. " ==> " .. L["Shattrath City"] .. "\n" .. " ==> " .. DUNGEON_FLOOR_DALARANCITY1 .. "\n" .. " ==> " .. DUNGEON_FLOOR_TANARIS18.. "\n" .. " ==> " .. L["Blasted Lands"] .. "\n" .. " ==> " .. L["Dornogal"] .. "\n" .. "\n" .. L["Portals"] .. "\n" .. " ==> " .. POSTMASTER_LETTER_HYJAL .. "\n" .. " ==> " .. L["Twilight Highlands"] .. "\n" .. " ==> " .. ARTIFACT_SHAMAN_TITLECARD_DEEPHOLM .. "\n" .. " ==> " .. L["Vashj'ir"] .. "\n" .. " ==> " .. L["Uldum"] .. "\n" .. " ==> " .. DUNGEON_FLOOR_TOLBARADWARLOCKSCENARIO0 .. "\n" .. " ==> " .. DUNGEON_FLOOR_SURAMARRAID3 .. "\n" .. " ==> " .. POSTMASTER_LETTER_THUNDERTOTEM .. "\n" .. "\n" .. L["Darnassus"] .. " - " .. FACTION_ALLIANCE .. "\n" .. L["Portals"] .. "\n" .. " ==> " .. L["Rut'theran"] .. "\n" .. " ==> " .. L["Exodar"]  .. "\n" .. " ==> " .. L["Hellfire Peninsula"] .. "\n" .. "\n" .. L["Exodar"] .. "\n" .. " ==> " .. STORMWIND} -- Portals 
                nodes[946][39008750] = { mnID = 75, id = { 187 }, type = "LFR", showInZone = true, name = L["Auridormi"] .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " " } -- LFR
                --nodes[946][39009200] = { mnID = 12, name = "", type = "HZeppelin", showInZone = true, TransportName = L["Thunder Bluff"] .. "\n" .. " ==> " .. ORGRIMMAR .. "\n" .. "\n" .. L["Durotar"] .. "\n" .. " ==> " .. L["The Waking Shores, Dragon Isles"]} -- Zeppelin
                --nodes[946][39009650] = { mnID = 12, name = "", type = "Ship", showInZone = true, TransportName = POSTMASTER_LETTER_BARRENS_SUBTITLE .. "\n" .. " ==> " .. POSTMASTER_LETTER_STRANGLETHORNVALE .. "\n" .. "\n" .. L["Echo Isles, Durotar"] .. "\n" .. " ==> " .. L["Zandalar"] .. "\n" .. "\n" .. L["Dustwallow Marsh"] .. "\n" .. " ==> " .. POSTMASTER_LETTER_WETLANDS} -- Ship
            end


        -- Eastern Kingdom
        if self.db.profile.showCosmosEasternKingdom then
                nodes[946][42606930] = { mnID = 13, name = POSTMASTER_PIPE_EASTERNKINGDOMS, type = "LEK", showInZone = true } -- Expansion Logo
                nodes[946][42607400] = { mnID = 13, id = { 752, 73, 72, 75, 741, 742, 745 }, type = "Raid", showInZone = true } -- Raids
                nodes[946][42607850] = { mnID = 13, id = { 249, 77, 65, 76, 64, 246, 236, 71, 231, 237, 63, 73, 66, 228, 229, 559, 860, 1197, 239, 311, 316, 238 }, type = "Dungeon", showInZone = true } -- Dungeons
                nodes[946][42608300] = { mnID = 1978, name = "", type = "Portal", showInZone = true, TransportName = L["Arathi Highlands"] .. "\n" .. " ==> " .. L["Zandalar"] .. "\n" .. " ==> " .. L["Boralus"] .. "\n" .. "\n" .. DUNGEON_FLOOR_TOLBARADWARLOCKSCENARIO0 .. "\n" .. " ==> " .. ORGRIMMAR .. "\n" .. " ==> " .. STORMWIND .. "\n" .. "\n" .. L["Twilight Highlands"] .. "\n" .. " ==> " .. ORGRIMMAR .. "\n" .. " ==> " .. STORMWIND .. "\n" .. "\n" .. L["Blasted Lands"] .. "\n" .. " ==> " .. ORGRIMMAR .. "\n" .. " ==> " .. STORMWIND .. "\n" .. " ==> " .. L["The Dark Portal"] .. " - " .. L["Ashran"].. "\n" .. "\n" .. "\n" .. L["Undercity"] .. " - " .. FACTION_HORDE .. "\n" .. " ==> " .. L["Hellfire Peninsula"] .. "\n" .. "\n" .. L["Ruins of Lordaeron"]  .. " / " .. L["Tirisfal Glades"] .. "\n" ..  " ==> " .. ORGRIMMAR .. "\n" .. " ==> " .. L["Grom'gol, Stranglethorn Vale"] .. "\n" .. " ==> " .. L["Howling Fjord"] .. "\n" .. " ==> " .. L["Silvermoon City"] .. "\n" .. "\n" .. L["Silvermoon City"] .. "\n" ..  " ==> " .. ORGRIMMAR .. "\n" .. " ==> " .. L["Ruins of Lordaeron"] .. "\n" .. " " .. "\n" .. "\n" .. STORMWIND .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Portalroom"] .. "\n" .. " ==> " .. L["Ashran"] .. "\n" .. " ==> " .. L["Valdrakken"] .. "\n" .. " ==> " .. L["Boralus, Tiragarde Sound"] .. "\n" .. " ==> " .. L["Oribos"] .. "\n" .. " ==> " .. L["Azsuna"] .. "\n" .. " ==> " .. L["Shattrath City"] .. "\n" .. " ==> " .. L["Jade Forest"] .. "\n" .. " ==> " .. DUNGEON_FLOOR_DALARANCITY1 .. "\n" .. " ==> " .. DUNGEON_FLOOR_TANARIS18 .. "\n" .. " ==> " .. L["Exodar"] .. "\n" ..  " ==> " .. L["Bel'ameth, Amirdrassil"] .. "\n" .. " ==> " .. L["Blasted Lands"] .. "\n" .. " ==> " .. L["Dornogal"] .. "\n" .. "\n" .. L["Portals"] .. "\n" .. " ==> " .. L["Uldum"] .. "\n" .. " ==> " .. L["Vashj'ir"] .. "\n" .. " ==> " .. POSTMASTER_LETTER_HYJAL .. "\n" .. " ==> " .. ARTIFACT_SHAMAN_TITLECARD_DEEPHOLM .. "\n" .. " ==> " .. L["Twilight Highlands"] .. "\n" .. " ==> " .. DUNGEON_FLOOR_TOLBARADWARLOCKSCENARIO0 } -- Portals 
                nodes[946][42608750] = { mnID = 13, name = "", TransportName = RAID_MESSAGE .. " / " .. LFG_TYPE_DUNGEON .. " - " .. L["Old Version"] .. "\n" .. " " .. "\n" .. REQUIRES_LABEL .. "\n" .. " " .. "\n" .. L["(Wards of the Dread Citadel - Achievement)"] .. "\n" .. " ==> " .. L["Naxxramas"] .. "\n" .. " " .. "\n" .. L["(Memory of Scholomance - Achievement)"] .. "\n" .. " ==> " .. L["Scholomance"] .. "\n" .. " " .. "\n" .. L["Old Keyring \n You get the Scarlet Key in the \n [Loot-Filled Pumpkin] from [Hallow's End Event] or from the [Auction House] \n now you can activate the [Old Keyring] here \n to activate old dungeonversions from the Scarlet Monastery"] .. "\n" .. " ==> " .. L["Scarlet Instances"], type = "VInstance", showInZone = true } -- Old Raids
                --nodes[946][42609200] = { mnID = 13, name = "", type = "HZeppelin", showInZone = true, TransportName = L["Grom'gol, Stranglethorn Vale"] .. "\n" .. " ==> " .. ORGRIMMAR } -- Zeppelin
                --nodes[946][42609650] = { mnID = 13, name = "", type = "Ship", showInZone = true,TransportName = STORMWIND .. "\n" .. " ==> " .. L["Boralus, Tiragarde Sound"] .. "\n" .. " ==> " .. L["The Waking Shores, Dragon Isles"] .. "\n" .. " ==> " .. POSTMASTER_LETTER_VALIANCEKEEP .. "\n" .. "\n" .. POSTMASTER_LETTER_STRANGLETHORNVALE .. "\n" .. " ==> " .. POSTMASTER_LETTER_BARRENS_SUBTITLE .. "\n" .. "\n" .. POSTMASTER_LETTER_WETLANDS .. "\n" .. " ==> " .. L["Dustwallow Marsh"] .. "\n" .. " ==> " .. L["Howling Fjord"] } -- Ship 
            end

        -- Northrend
            if self.db.profile.showCosmosNorthrend then
                nodes[946][46206930] = { mnID = 113, name = EXPANSION_NAME2, type = "LWotlk", showInZone = true } -- Expansion Logo
                nodes[946][46207400] = { mnID = 113, id = { 754, 758, 759, 753, 755, 761, 756, 757 }, type = "Raid", showInZone = true } -- Raids
                nodes[946][46207850] = { mnID = 113, id = { 285, 286, 275, 277, 273, 274, 283 }, type = "Dungeon", showInZone = true } -- Dungeons
                nodes[946][46208300] = { mnID = 113, name = "", type = "Portal", showInZone = true, TransportName = DUNGEON_FLOOR_DALARANCITY1 .. " " .. L["Portals"] .. "\n" .. " ==> " .. ORGRIMMAR .. "\n" .. " ==> " .. STORMWIND .. "\n" .. "\n" .. L["Wintergrasp"] .. " " .. L["Portal"] .. "\n" .. " ==> " .. DUNGEON_FLOOR_DALARANCITY1 } -- Portals 
                nodes[946][46208750] = { mnID = 627, id = { 875, 786, 768, 861, 946 }, type = "LFR", showInZone = true, name = L["Archmage Timear"] .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " " } -- LFR
                --nodes[946][46209200] = { mnID = 114, name = "", type = "HZeppelin", showInZone = true, TransportName = POSTMASTER_LETTER_WARSONGHOLD .. "\n" .. " ==> " .. ORGRIMMAR } -- Zeppelin
                --nodes[946][46209650] = { mnID = 113, name = "", type = "Ship", showInZone = true, TransportName = POSTMASTER_LETTER_VALIANCEKEEP .. "\n" .. " ==> " .. STORMWIND .. "\n" .. "\n" .. L["Howling Fjord"] .. "\n" .. " ==> " .. POSTMASTER_LETTER_WETLANDS .. "\n" .. "\n" .. L["Borean Tundra"] .. "\n" .. " ==> " .. POSTMASTER_LETTER_MOAKI .. "\n" .. "\n" .. POSTMASTER_LETTER_MOAKI .. "\n" .. " ==> " .. POSTMASTER_LETTER_KAMAGUA .. "\n" .. " ==> " .. L["Borean Tundra"] .. "\n" .. "\n" .. POSTMASTER_LETTER_KAMAGUA .. "\n" .. " ==> " .. POSTMASTER_LETTER_MOAKI} -- Ship
            end

        -- Pandaria
            if self.db.profile.showCosmosPandaria then
                nodes[946][49806930] = { mnID = 424, name = EXPANSION_NAME4, type = "LMOP", showInZone = true } -- Expansion Logo
                nodes[946][49807400] = { mnID = 424, id = { 317, 369, 330, 362, 320, 1180}, type = "Raid", showInZone = true } -- Raids
                nodes[946][49807850] = { mnID = 424, id = { 313, 302, 312, 324, 303, 321 }, type = "Dungeon", showInZone = true } -- Dungeons
                nodes[946][49808300] = { mnID = 424, name = "", type = "Portal", showInZone = true, TransportName = L["Jade Forest"] .. " " .. L["Portals"]  .. "\n" .. " ==> " .. ORGRIMMAR .. "\n" .. " ==> " .. STORMWIND .. "\n" .. "\n" .. L["Vale of Eternal Blossoms"] .. " " .. L["Portals"] .. "\n" .. " ==> " .. ORGRIMMAR .. "\n" .. " ==> " .. STORMWIND .. "\n" .. "\n" .. L["Shado-Pan Garrison, Townlong Steppes"] .. " " .. L["Portal"] .. "\n" .. " ==> " .. L["Isle of Thunder"] .. "\n" .. "\n" .. L["Isle of Thunder"] .. " " .. L["Portals"] .. "\n" .. " ==> " .. L["Shado-Pan Garrison, Townlong Steppes"] } -- Portals 
                nodes[946][49808750] = { mnID = 390, id = { 317, 330, 362, 320 }, type = "LFR", showInZone = true, name = L["Lorewalker Han"] .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " " } -- LFR
            end

        -- Broken Isles
            if self.db.profile.showCosmosBrokenIsles then
                nodes[946][53406930] = { mnID = 619, name = EXPANSION_NAME6, type = "LLG", showInZone = true } -- Expansion Logo
                nodes[946][53407400] = { mnID = 619, id = { 946, 786, 875, 861, 946 }, type = "Raid", showInZone = true } -- Raids
                nodes[946][53407850] = { mnID = 619, id = { 777, 716, 707, 945, 740, 727, 767, 800, 726, 900, 721, 762, 945 }, type = "Dungeon", showInZone = true } -- Dungeons
                nodes[946][53408300] = { mnID = 619, name = "", type = "Portal", showInZone = true, TransportName = DUNGEON_FLOOR_DALARAN7010 .. " " .. L["Portals"] .. "\n" .. " ==> " .. ORGRIMMAR .. "\n" .. " ==> " .. STORMWIND .. "\n" .. "\n" .. L["Azsuna"] .. " " .. L["Portals"] .. "\n" .. " ==> " .. ORGRIMMAR .. "\n" .. " ==> " .. STORMWIND } -- Portals 
                nodes[946][53408750] = { mnID = 627, id = { 875, 786, 768, 861, 946 }, type = "LFR", showInZone = true, name = L["Archmage Timear"] .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " " } -- LFR
            end

        -- Zandalar
            if self.db.profile.showCosmosZandalar then
                nodes[946][57006930] = { mnID = 875, name = SPLASH_BATTLEFORAZEROTH_BOX_RIGHT_TITLE_HORDE, type = "LZ", showInZone = true } -- Expansion Logo
                nodes[946][57007400] = { mnID = 875, id = { 1031, 1179, 1176 }, type = "Raid", showInZone = true } -- Raids
                nodes[946][57007850] = { mnID = 875, id = { 968, 1041, 1022, 1030, 1178 }, type = "Dungeon", showInZone = true } -- Dungeons
                nodes[946][57008300] = { mnID = 875, name = "", type = "Portal", showInZone = true, TransportName = L["Dazar'alor"] .. "\n" .. L["Portalroom"] .. "\n" .. " ==> " .. L["Silvermoon City"] .. "\n" .. " ==> " .. ORGRIMMAR .. "\n" .. " ==> " .. L["Thunder Bluff"] .. "\n" .. " ==> " .. L["Silithus"] .. "\n" .. " ==> " .. L["Nazjatar"] .. "\n" .. "\n" .. L["Portals"] .. "\n" .. " ==> " .. L["Arathi Highlands"] .. "\n" .. " ==> " .. L["Darkshore"] } -- Portals 
                nodes[946][57008750] = { mnID = 1164, id = { 1176, 1031, 1179, 1036 }, type = "LFR", showInZone = true, name = L["Eppu"] .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " " } -- LFR
                --nodes[946][57009200] = { mnID = 875, name = "", type = "Ship", showInZone = true, TransportName = L["Boralus"] .. "\n" .. " ==> " .. STORMWIND .. "\n" .. "\n" .. L["Zandalar"] .. "\n" .. " ==> " .. L["Echo Isles, Durotar"] } -- Ship
                --nodes[946][57009650] = { mnID = 875, name = "", type = "TravelL", showInZone = true, TransportName = L["Captain Krooz"] .. " " .. "\n" .. " " .. SPLASH_BATTLEFORAZEROTH_8_2_0_FEATURE1_TITLE .. " ==> " .. L["Dazar'alor"] .. "\n" .. "\n" .. L["Swellthrasher"] .. "\n" .. " " .. L["Drustvar"] .. " ==> " .. L["Zuldazar"] .. "\n" .. "\n" .. L["Grok Seahandler"] .. "\n" .. " " .. L["Stormsong Valley"] .. " ==> " .. L["Zuldazar"] .. "\n" .. "\n" .. L["Erul Dawnbrook"] .. "\n" .. " " .. L["Tiragarde Sound"] .. " ==> " .. L["Zuldazar"] .. "\n" .. "\n" .. L["Daria Smithson"] .. "\n" .. " " .. L["Zuldazar"] .. " ==> " .. L["Boralus, Tiragarde Sound"] .. "\n" .. "\n" .. L["Barnard 'The Smasher' Bayswort"] .. "\n" .. " " .. L["Vol'dun"] .. " ==> " .. L["Boralus, Tiragarde Sound"] .. "\n" .. "\n" .. L["Daria Smithson"] .. "\n" .. " " .. L["Zuldazar"] .. " ==> " .. L["Boralus, Tiragarde Sound"] } -- Transport
            end

        -- Kul'Tiras
            if self.db.profile.showCosmosKulTiras then
                nodes[946][60606930] = { mnID = 876, name = SPLASH_BATTLEFORAZEROTH_BOX_RIGHT_TITLE_ALLIANCE, type = "LKT", showInZone = true } -- Expansion Logo
                nodes[946][60607400] = { mnID = 876, id = { 1179, 1176, 1177 }, type = "Raid", showInZone = true } -- Raids
                nodes[946][60607850] = { mnID = 876, id = { 1001, 1021, 1036, 1002 ,1178}, type = "Dungeon", showInZone = true } -- Dungeons
                nodes[946][60608300] = { mnID = 876, name = "", type = "Portal", showInZone = true, TransportName = L["Boralus"] .. "\n" .. L["Portalroom"] .. "\n" .. " ==> " .. STORMWIND .. "\n" .. " ==> " .. L["Silithus"] .. "\n" .. " ==> " .. L["Exodar"] .. "\n" .. " ==> " .. L["Ironforge"] .. "\n" .. "\n" .. L["Portals"] .. "\n" .. " ==> " .. L["Arathi Highlands"] .. "\n" .. " ==> " .. L["Darkshore"] } -- Portals 
                nodes[946][60608750] = { mnID = 1161, id = { 1176, 1031, 1179, 1036 }, type = "LFR", showInZone = true, name = L["Kiku"] .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " " } -- LFR
                --nodes[946][61009200] = { mnID = 876, name = "", type = "Ship", showInZone = true, TransportName = L["Boralus"] .. "\n" .. " ==> " .. STORMWIND .. "\n" .. "\n" .. L["Zandalar"] .. "\n" .. " ==> " .. L["Echo Isles, Durotar"] } -- Ship
                --nodes[946][61009650] = { mnID = 876, name = "", type = "TravelL", showInZone = true, TransportName = L["Captain Krooz"] .. " " .. "\n" .. " " .. SPLASH_BATTLEFORAZEROTH_8_2_0_FEATURE1_TITLE .. " ==> " .. L["Dazar'alor"] .. "\n" .. "\n" .. L["Swellthrasher"] .. "\n" .. " " .. L["Drustvar"] .. " ==> " .. L["Zuldazar"] .. "\n" .. "\n" .. L["Grok Seahandler"] .. "\n" .. " " .. L["Stormsong Valley"] .. " ==> " .. L["Zuldazar"] .. "\n" .. "\n" .. L["Erul Dawnbrook"] .. "\n" .. " " .. L["Tiragarde Sound"] .. " ==> " .. L["Zuldazar"] .. "\n" .. "\n" .. L["Daria Smithson"] .. "\n" .. " " .. L["Zuldazar"] .. " ==> " .. L["Boralus, Tiragarde Sound"] .. "\n" .. "\n" .. L["Barnard 'The Smasher' Bayswort"] .. "\n" .. " " .. L["Vol'dun"] .. " ==> " .. L["Boralus, Tiragarde Sound"] .. "\n" .. "\n" .. L["Daria Smithson"] .. "\n" .. " " .. L["Zuldazar"] .. " ==> " .. L["Boralus, Tiragarde Sound"] } -- Transport
            end
            
        -- Dragonflight    
            if self.db.profile.showCosmosDragonIsles then
                nodes[946][64206930] = { mnID = 1978, name = EXPANSION_NAME9, type = "LDF", showInZone = true } -- Expansion Logo
                nodes[946][64207400] = { mnID = 1978, id = { 1200, 1208, 1207 }, type = "Raid", showInZone = true } -- Raids
                nodes[946][64207850] = { mnID = 1978, id = { 1202, 1199, 1198, 1196, 1203, 1201, 1204, 1209 }, type = "Dungeon", showInZone = true } -- Dungeons
                nodes[946][64208300] = { mnID = 1978, name = "", type = "Portal", showInZone = true, TransportName = L["Valdrakken"] .. " " .. L["Portals"] .. "\n" .. " ==> " .. L["Emerald Dream"] .. "\n" .. " ==> " .. L["Badlands"] .. "\n".." ==> " .. STORMWIND .. "\n" .. " ==> " .. ORGRIMMAR .. "\n" .. "\n" .. L["Bel'ameth, Amirdrassil"] .. "\n" .. L["Portals"] .. "\n" .. " ==> " .. STORMWIND .. "\n" .. " ==> " .. L["Darkshore"] .. "\n" .. " ==> " .. POSTMASTER_LETTER_HYJAL  .. "\n" .. " ==> " .. POSTMASTER_LETTER_LORLATHIL} -- Portals 
                --nodes[946][64609200] = { mnID = 2022, name = "", type = "HZeppelin", showInZone = true, TransportName = L["The Waking Shores, Dragon Isles"] .. "\n" .. " ==> " .. ORGRIMMAR } -- Zeppelin
                --nodes[946][64609650] = { mnID = 2022, name = "", type = "AShip", showInZone = true, TransportName = L["The Waking Shores, Dragon Isles"] .. "\n" .. " ==> " .. STORMWIND } -- Ship
            end

        -- The War Within    
            if self.db.profile.showCosmosKhazAlgar then
                nodes[946][67806930] = { mnID = 2274, name = EXPANSION_NAME10, type = "TWW", showInZone = true } -- Expansion Logo
                nodes[946][67807400] = { mnID = 2274, id = { 1273 }, type = "Raid", showInZone = true } -- Raids
                nodes[946][67807850] = { mnID = 2274, id = { 1210, 1267, 1270, 1269, 1268, 1271, 1272, 1274 }, type = "Dungeon", showInZone = true } -- Dungeons
                nodes[946][67808300] = { mnID = 2274, name = "", type = "Portal", showInZone = true, TransportName = L["Dornogal"] .. " " .. L["Portals"] .. "\n" .. " ==> " .. STORMWIND .. "\n" .. " ==> " .. ORGRIMMAR } -- Portals 
            end
            
        end
    end
end