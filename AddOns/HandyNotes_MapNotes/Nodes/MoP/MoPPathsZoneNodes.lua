local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

function ns.LoadPathsZoneLocationinfo(self)
local db = ns.Addon.db.profile
local nodes = ns.nodes

--#####################################################################################################
--##########################        function to hide all nodes below         ##########################
--#####################################################################################################
if not db.activate.HideMapNote then


    --#####################################################################################################
    --################################         Zone Map        ################################
    --#####################################################################################################

      if db.activate.ZoneMap then

        --Kalimdor
        if self.db.profile.showZoneKalimdor then

            if self.db.profile.showZonePaths then
                nodes[460][55028792] = { name = "", dnID = "|cffffffff" .. L["Exit"], mnID = 57, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[57][60384385] = { name = "", dnID = "|cffffffff" .. L["Entrance"], mnID = 460, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[106][65229286] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 97, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[97][41990481] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 106, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[97][62375371] = { name = "", dnID = "|cffffffff" .. L["Entrance"], mnID = 468, type = "PathR", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[468][15155338] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 97, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[97][34214552] = { name = "", dnID = "|cffffffff" .. L["Entrance"], mnID = 103, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[97][26734541] = { name = "", dnID = "|cffffffff" .. L["Entrance"], mnID = 103, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[57][39894708] = { name = "", dnID = "|cffffffff" .. L["Entrance"], mnID = 89, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[80][35207168] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 77, mnID2 = 83, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[83][21134646] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 80, mnID2 = 77, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[77][64321012] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 83, mnID2 = 80, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[198][86573831] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 83, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[83][58049127] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 198, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[77][54559364] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 63, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[77][33054978] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 62, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[62][44989270] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 63, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[62][39019357] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 63, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[63][24410740] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 62, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[63][55022364] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 77, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[63][94114695] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 76, type = "PathR", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[63][68689192] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 10, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[63][36667685] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 65, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[76][04486814] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 63, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[76][24268352] = { name = "", dnID = "|cffffffff" .. L["Entrance"], mnID = 85, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[65][72763753] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 63, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[65][36628429] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 66, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[65][78419263] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 199, mnID2 = 10, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[461][70096602] = { name = "", dnID = "|cffffffff" .. L["Exit"], mnID = 1, type = "PathR", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1][45601164] = { name = "", dnID = "|cffffffff" .. L["Entrance"], mnID = 85, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1][34944229] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 10, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1][48146741] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 461, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1][38617209] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 461, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[461][33378129] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 461, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[461][47359195] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 10, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[10][68243905] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 1, type = "PathR", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[10][70260439] = { name = "", dnID = "|cffffffff" .. L["Entrance"], mnID = 85, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[10][42161314] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 63, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[10][45767732] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 199, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[10][28894693] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 65, mnID2 = 199, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[10][70509180] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 199, mnID2 = 70, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[10][73386635] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 461, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[74][52672906] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 71, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[74][33997410] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 75, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[75][75434726] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 74, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[66][53300394] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 65, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[66][41679388] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 69, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[199][37921619] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 65, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[199][52953336] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 10, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[199][53307850] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 70, type = "PathR", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[199][43569741] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 64, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[199][40015464] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 7, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[199][39684803] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 7, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[199][70614786] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 70, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[199][68853911] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 10, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[7][68925486] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 199, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[7][69586410] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 199, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[7][36973219] = { name = "", dnID = "|cffffffff" .. L["Entrance"], mnID = 88, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[7][42992151] = { name = "", dnID = "|cffffffff" .. L["Entrance"], mnID = 88, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[7][44727145] = { name = "", dnID = "|cffffffff" .. L["Entrance"], mnID = 462, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[462][26841797] = { name = "", dnID = "|cffffffff" .. L["Exit"], mnID = 7, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[70][25364695] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 199, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[70][46869122] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 64, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[70][53300865] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 199, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[69][45600504] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 66, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[69][85944184] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 64, type = "PathR", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[64][07931140] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 69, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[64][31952135] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 199, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[64][66173589] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 70, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[64][74649552] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 71, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[71][25366609] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 249, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[71][50912411] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 64, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[71][28085682] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 78, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[78][70728752] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 71, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[78][29281689] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 81, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[81][87672011] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 78, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[249][68612240] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 71, type = "PathR", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[11][22228580] = { name = "", dnID = "|cffffffff" .. L["Exit"], mnID = 10, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[67][23574340] = { name = "", dnID = "|cffffffff" .. L["Exit"], mnID = 66, type = "PathR", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[67][26773535] = { name = "|cffffffff" .. L["Passage"], TransportName = "=> " .. DUNGEON_FLOOR_DESOLACE22, mnID = 68, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[68][49917687] = { name = "|cffffffff" .. L["Passage"], TransportName = "=> " .. DUNGEON_FLOOR_DESOLACE21, mnID = 67, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[68][48528878] = { name = "|cffffffff" .. L["Passage"], TransportName = "=> " .. DUNGEON_FLOOR_DESOLACE21, mnID = 67, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[67][28454260] = { name = "|cffffffff" .. L["Passage"], TransportName = "=> " .. DUNGEON_FLOOR_DESOLACE22, mnID = 68, type = "PathR", showInZone = true, showOnContinent = false, showOnMinimap = false }
            end

        end

            -- Eastern Kingdom
            if self.db.profile.showZoneEasternKingdom then

                if self.db.profile.showZonePaths then
                    nodes[19][25047080] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 18, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[94][56535032] = { name = "", dnID = "|cffffffff" .. L["Entrance"], mnID = 110, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[94][48449155] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 95, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[94][39643054] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 467, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[467][70888297] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 94, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[95][48590888] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 94, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[95][47808870] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 23, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[23][54870622] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 95, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[23][06526555] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 22, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[23][93799027] = { name = "", dnID = "|cffffffff" .. L["Path"] .. " (" .. TIME_LEFT_VERY_LONG .. ")", mnID = 26, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[22][75745008] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 23, type = "PathR", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[22][22855825] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 18, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[21][65540646] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 18, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[25][41950592] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 18, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[22][43569122] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 25, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[22][65688550] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 26, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[25][68371942] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 22, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[25][28916364] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 21, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[25][69937080] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 14, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[25][25723886] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 21, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[25][29757598] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 217, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[25][72135385] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 26, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[26][09815510] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 25, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[26][26017011] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 14, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[26][24153021] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 22, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[26][81564901] = { name = "", dnID = "|cffffffff" .. L["Path"] .. " (" .. TIME_LEFT_VERY_LONG .. ")", mnID = 23, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[21][68057999] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 25, type = "PathR", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[21][45458540] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 217, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[21][66055380] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 25, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[18][87597110] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 22, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[18][47498234] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 21, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[18][37805624] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 465, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[18][67066838] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 21, mnID2 = 25, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[18][62206431] = { name = "", dnID = "|cffffffff" .. L["Entrance"], mnID = 998, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[18][51107073] = { name = "", dnID = "|cffffffff" .. L["Entrance"], mnID = 998, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[465][75431917] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 18, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[2070][87597110] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 22, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[2070][47498234] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 21, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[2070][37805624] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 465, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[2070][67066838] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 21, mnID2 = 25, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[217][59891336] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 21, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[217][80463751] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 25, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[14][39619159] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 56, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[14][13553039] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 25, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[14][18512139] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 25, mnID2 = 26, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[14][36263114] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 26, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[56][51131207] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 14, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[56][82184844] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 241, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[56][53957032] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 48, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[241][24543727] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 56, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[48][25561067] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 56, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[48][18468426] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 32, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[27][91572938] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 48, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[27][89515184] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 48, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[27][58923378] = { name = "", dnID = "|cffffffff" .. L["Entrance"], mnID = 87, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[27][42696414] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 427, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[27][49564541] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 469, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[30][77948422] = { name = "", dnID = "|cffffffff" .. L["Exit"], mnID = 469, type = "PathR", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[28][61301373] = { name = "", dnID = "|cffffffff" .. L["Passage"], mnID = 27, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[28][37609129] = { name = "", dnID = "|cffffffff" .. L["Passage"], mnID = 427, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[427][88414114] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 27, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[469][78885672] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 27, type = "PathR", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[425][23947810] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 37, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[48][19606279] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 27, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[48][47527346] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 15, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[15][45820582] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 48, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[15][08655196] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 32, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[32][78451748] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 48, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[32][71695521] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 15, type = "PathR", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[32][33858156] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 33, mnID2 = 36, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[33][48121241] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 32, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[33][51269310] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 36, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[34][39177968] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 33, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[36][21063844] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 32, mnID2 = 33, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[36][66517431] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 49, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[36][83947621] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 49, mnID2 = 51, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[49][90195831] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 51, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[49][09357975] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 47, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[49][08257669] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 37, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[49][09976374] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 37, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[49][63811069] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 36, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[49][43091117] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 36, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[51][67140932] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 49, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[51][36347339] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 17, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[51][12495691] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 42, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[51][78219172] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 17, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[17][49040560] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 51, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[17][70222565] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 51, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[37][92697214] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 49, type = "PathR", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[37][19798059] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 52, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[37][93758281] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 47, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[37][33525197] = { name = "", dnID = "|cffffffff" .. L["Entrance"], mnID = 84, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[37][45684930] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 425, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[37][52518658] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 47, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[42][61143918] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 51, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[42][23793636] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 47, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[47][90654137] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 42, type = "PathR", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[47][92541194] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 49,type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[47][83591564] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 37, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[47][44518399] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 50, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[47][07936303] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 52, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[47][48431375] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 37, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[47][14212482] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 37, mnID2 = 52, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[52][67746273] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 47, type = "PathR", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[52][61141799] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 37, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[52][39488987] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 50, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[50][51880834] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 47, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[50][51586932] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 210, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[50][09302428] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 52, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[210][57992237] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 50, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[224][51100582] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 47, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[224][24261547] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 52, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[244][40901446] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 245, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[245][66959027] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 244, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

            end

            -- Outland
            if self.db.profile.showZoneOutland then

                if self.db.profile.showZonePaths then
                    nodes[100][08724978] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 102, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[100][38078776] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 108, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[102][85636485] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 100, type = "PathR", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[102][82339239] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 108, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[102][66798886] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 107, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[102][21287968] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 107, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[102][68992913] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 105, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[105][51617680] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 102, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[105][83592866] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 109, type = "PathR", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[105][37018234] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 102, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[102][46822505] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 105, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[109][21685575] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 105, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[107][33831642] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 102, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[107][73393525] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 102, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[107][77945461] = { name = "", dnID = "|cffffffff" .. L["Entrance"], mnID = 111, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[107][77758299] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 108, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[108][20655720] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 107, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[108][70865015] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 104, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[108][60991736] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 100, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[108][34771285] = { name = "", dnID = "|cffffffff" .. L["Entrance"], mnID = 111, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[108][36083207] = { name = "", dnID = "|cffffffff" .. L["Entrance"], mnID = 111, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[108][38092341] = { name = "", dnID = "|cffffffff" .. L["Entrance"], mnID = 111, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[104][22372748] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 108, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

            end

            --Northrend
            if self.db.profile.showZoneNorthrend then

                if self.db.profile.showZonePaths then
                    nodes[114][94113494] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 115, type = "PathR", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[114][52270671] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 119, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[119][31769178] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 114, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[115][89872176] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 121, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[115][11075449] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 114, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[115][90656296] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 116, type = "PathR", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[115][91823061] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 116, type = "PathR", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[115][59681240] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 127, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[127][46787064] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 115, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[127][95055825] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 121, type = "PathR", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[127][70723078] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 120, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[127][57853407] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 118, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[121][11236626] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 127, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[121][17048604] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 115, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[121][71507827] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 116, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[121][55619185] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 116, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[121][28078433] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 116, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[120][31639239] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 127, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[117][24100982] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 116, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[117][53690502] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 116, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[117][75110740] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 116, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[116][09196649] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 115, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[116][09673162] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 115, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[116][43372604] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 121, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[116][59001473] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 121, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[116][34308422] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 117, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[116][67117434] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 117, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[116][86896774] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 117, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[116][17592817] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 121, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[118][89008044] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 127, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

            end

            --Pandaria
            if self.db.profile.showZonePandaria then

                if self.db.profile.showZonePaths then
                    nodes[371][34136352] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 376, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[371][34136352] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 376, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[376][87092083] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 371, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[376][82655143] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 418, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[379][55609165] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 390, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[379][29936362] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 388, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[379][73309428] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 433, mnID2 = 371, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[388][70274335] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 379, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[388][74178564] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 422, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[390][61481920] = { name = "|cffffffff" .. L["Entrance"], mnID = 391, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[390][86696414] = { name = "|cffffffff" .. L["Entrance"], mnID = 393, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[390][44091437] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 379, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[388][59738703] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 422, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[422][45140853] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 379, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[422][63500935] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 388, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[433][53149105] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 376, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[433][59670743] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 371, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[433][50314161] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 379, mnID2 = 371, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[376][69931893] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 433, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[376][13127951] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 418, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[418][75980580] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 376, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[418][13743212] = { name = "", dnID = "|cffffffff" .. L["Path"], mnID = 376, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[434][25511100] = { name = "", dnID = "|cffffffff" .. L["Passage"], mnID = 379, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[434][75743737] = { name = "", dnID = "|cffffffff" .. L["Passage"], mnID = 390, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[434][63188580] = { name = "", dnID = "|cffffffff" .. L["Passage"], mnID = 433, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

            end

    end

end
end