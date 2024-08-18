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
                nodes[1950][65229286] = { name = "", dnID = L["Path"], mnID = 1943, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1943][41990481] = { name = "", dnID = L["Path"], mnID = 1950, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1452][57889118] = { name = "", dnID = L["Path"], mnID = 198, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[198][85134308] = { name = "", dnID = L["Path"], mnID = 1452, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1438][38544741] = { name = "", dnID = L["Entrance"], mnID = 1457, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1450][35207168] = { name = "", dnID = L["Path"], mnID = 1448, mnID2 = 1452, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1452][21134646] = { name = "", dnID = L["Path"], mnID = 1450, mnID2 = 1448, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1448][64321012] = { name = "", dnID = L["Path"], mnID = 1452, mnID2 = 1450, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1411][45601164] = { name = "", dnID = L["Entrance"], mnID = 1454, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1411][36690869] = { name = "", dnID = L["Path"], mnID = 1413, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1411][34944229] = { name = "", dnID = L["Path"], mnID = 1413, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1413][73006595] = { name = "", dnID = L["Path"], mnID = 1411, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1413][68093891] = { name = "", dnID = L["Path"], mnID = 1411, type = "PathR", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1413][69690732] = { name = "", dnID = L["Entrance"], mnID = 1454, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1413][42361490] = { name = "", dnID = L["Path"], mnID = 1440, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1413][35225712] = { name = "", dnID = L["Path"], mnID = 199, mnID2 = 1442, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1413][66129303] = { name = "", dnID = L["Path"], mnID = 1445, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1413][46057770] = { name = "", dnID = L["Path"], mnID = 199, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[199][37921619] = { name = "", dnID = L["Path"], mnID = 1442, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[199][52953336] = { name = "", dnID = L["Path"], mnID = 1413, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[199][53307850] = { name = "", dnID = L["Path"], mnID = 1445, type = "PathR", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[199][43569741] = { name = "", dnID = L["Path"], mnID = 1441, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[199][40015464] = { name = "", dnID = L["Path"], mnID = 1412, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[199][39684803] = { name = "", dnID = L["Path"], mnID = 1412, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[199][70614786] = { name = "", dnID = L["Path"], mnID = 1445, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[199][68853911] = { name = "", dnID = L["Path"], mnID = 1413, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1412][68896041] = { name = "", dnID = L["Path"], mnID = 199, type = "PathR", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1412][36973219] = { name = "", dnID = L["Entrance"], mnID = 1456, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1412][42992151] = { name = "", dnID = L["Entrance"], mnID = 1456, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1447][08497086] = { name = "", dnID = L["Path"], mnID = 1440, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1447][24878084] = { name = "", dnID = L["Path"], mnID = 1454, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1440][93214637] = { name = "", dnID = L["Path"], mnID = 1447, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1440][55782975] = { name = "", dnID = L["Path"], mnID = 1448, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1440][21181102] = { name = "", dnID = L["Path"], mnID = 1439, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1440][28501313] = { name = "", dnID = L["Path"], mnID = 1439, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1440][68408719] = { name = "", dnID = L["Path"], mnID = 1413, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1440][36827493] = { name = "", dnID = L["Path"], mnID = 1442, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1439][39169487] = { name = "", dnID = L["Path"], mnID = 1440, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1439][46059487] = { name = "", dnID = L["Path"], mnID = 1440, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }                
                nodes[1442][73023835] = { name = "", dnID = L["Path"], mnID = 1440, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1448][55359052] = { name = "", dnID = L["Path"], mnID = 1440, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1442][35037954] = { name = "", dnID = L["Path"], mnID = 1443, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1442][78199137] = { name = "", dnID = L["Path"], mnID = 1413, mnID2 = 199, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1443][53250555] = { name = "", dnID = L["Path"], mnID = 1442, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1443][42489698] = { name = "", dnID = L["Path"], mnID = 1444, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1444][45870426] = { name = "", dnID = L["Path"], mnID = 1443, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1444][86874286] = { name = "", dnID = L["Path"], mnID = 1441, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1441][08061109] = { name = "", dnID = L["Path"], mnID = 1444, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1441][31832162] = { name = "", dnID = L["Path"], mnID = 199, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1441][74879513] = { name = "", dnID = L["Path"], mnID = 1446, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1441][66683780] = { name = "", dnID = L["Path"], mnID = 1445, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1446][50792181] = { name = "", dnID = L["Path"], mnID = 1441, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1446][27025567] = { name = "", dnID = L["Path"], mnID = 1449, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1445][28814741] = { name = "", dnID = L["Path"], mnID = 199, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1445][53010925] = { name = "", dnID = L["Path"], mnID = 1413, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1445][46859155] = { name = "", dnID = L["Path"], mnID = 1441, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1451][77952162] = { name = "", dnID = L["Path"], mnID = 1449, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1449][71807754] = { name = "", dnID = L["Path"], mnID = 1446, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1449][28732185] = { name = "", dnID = L["Path"], mnID = 1451, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1446][26966643] = { name = "", dnID = L["Path"], mnID = 249, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[249][69822210] = { name = "", dnID = L["Path"], mnID = 1446, type = "PathR", showInZone = true, showOnContinent = false, showOnMinimap = false }
            end

        end

        --Eastern Kingdom
        if self.db.profile.showZoneEasternKingdom then

            if self.db.profile.showZonePaths then    
                nodes[1423][54420788] = { name = "", dnID = L["Path"], mnID = 1942, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1942][47418416] = { name = "", dnID = L["Path"], mnID = 1423, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1942][48141342] = { name = "", dnID = L["Path"], mnID = 1941, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1941][48519063] = { name = "", dnID = L["Path"], mnID = 1942, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1941][56525073] = { name = "", dnID = L["Entrance"], mnID = 1954, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1423][07946606] = { name = "", dnID = L["Path"], mnID = 1422, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1423][03883558] = { name = "", dnID = L["Passage"], type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1423][11642413] = { name = "", dnID = L["Passage"], type = "PathLU", mnID = 1422, showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1422][66062181] = { name = "", dnID = L["Path"], mnID = 1423, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1422][70255007] = { name = "", dnID = L["Path"], mnID = 1423, type = "PathR", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1422][20755616] = { name = "", dnID = L["Path"], mnID = 1420, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1422][43598848] = { name = "", dnID = L["Path"], mnID = 1422, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1422][65228620] = { name = "", dnID = L["Path"], mnID = 1425, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1420][84287020] = { name = "", dnID = L["Path"], mnID = 1422, type = "PathR", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1420][54987075] = { name = "", dnID = L["Path"], mnID = 1421, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1420][62006207] = { name = "", dnID = L["Entrance"], mnID = 1458, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1420][67546707] = { name = "", dnID = L["Path"], mnID = 1424, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1420][51017169] = { name = "", dnID = L["Entrance"], mnID = 1458, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1421][67230574] = { name = "", dnID = L["Path"], mnID = 1420, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1421][67178036] = { name = "", dnID = L["Path"], mnID = 1424, type = "PathR", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1421][67545302] = { name = "", dnID = L["Path"], mnID = 1424, type = "PathR", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1424][26236329] = { name = "", dnID = L["Path"], mnID = 1421, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1424][68162062] = { name = "", dnID = L["Path"], mnID = 1422, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1424][24503891] = { name = "", dnID = L["Path"], mnID = 1421, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1424][71175479] = { name = "", dnID = L["Path"], mnID = 1425, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1424][41740527] = { name = "", dnID = L["Path"], mnID = 1420, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1425][09545468] = { name = "", dnID = L["Path"], mnID = 1424, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1425][23212809] = { name = "", dnID = L["Path"], mnID = 1422, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1425][26176951] = { name = "", dnID = L["Path"], mnID = 1417, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1424][69827049] = { name = "", dnID = L["Path"], mnID = 1417, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1424][73516384] = { name = "", dnID = L["Path"], mnID = 1417, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1417][36972958] = { name = "", dnID = L["Path"], mnID = 1425, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1417][13303060] = { name = "", dnID = L["Path"], mnID = 1424, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1417][18222155] = { name = "", dnID = L["Path"], mnID = 1424, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1417][39529377] = { name = "", dnID = L["Path"], mnID = 1437, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1437][50361231] = { name = "", dnID = L["Path"], mnID = 1417, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1437][53696957] = { name = "", dnID = L["Path"], mnID = 1432, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1437][80474796] = { name = "", dnID = L["Path"], mnID = 241, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[241][18353688] = { name = "", dnID = L["Path"], mnID = 1437, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1432][25561065] = { name = "", dnID = L["Path"], mnID = 1437, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1432][18591645] = { name = "", dnID = L["Path"], mnID = 1426, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1432][47457345] = { name = "", dnID = L["Path"], mnID = 1418, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1432][20506318] = { name = "", dnID = L["Path"], mnID = 1426, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1432][18128393] = { name = "", dnID = L["Path"], mnID = 1427, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1426][58863355] = { name = "", dnID = L["Entrance"], mnID = 1455, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1426][88404108] = { name = "", dnID = L["Path"], mnID = 1432, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1426][89525165] = { name = "", dnID = L["Path"], mnID = 1432, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1418][45880821] = { name = "", dnID = L["Path"], mnID = 1432, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1418][04495986] = { name = "", dnID = L["Path"], mnID = 1427, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1427][78371682] = { name = "", dnID = L["Path"], mnID = 1432, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1427][34178231] = { name = "", dnID = L["Path"], mnID = 1428, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1427][77175664] = { name = "", dnID = L["Path"], mnID = 1418, type = "PathR", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1428][20813928] = { name = "", dnID = L["Path"], mnID = 1427, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1428][66618139] = { name = "", dnID = L["Path"], mnID = 1433, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1428][84108084] = { name = "", dnID = L["Path"], mnID = 1433, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1433][43101268] = { name = "", dnID = L["Path"], mnID = 1428, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1433][63911213] = { name = "", dnID = L["Path"], mnID = 1428, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1433][89275479] = { name = "", dnID = L["Path"], mnID = 1435, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1433][09976347] = { name = "", dnID = L["Path"], mnID = 1429, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1433][10967696] = { name = "", dnID = L["Path"], mnID = 1431, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1429][93277223] = { name = "", dnID = L["Path"], mnID = 1433, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1429][93588268] = { name = "", dnID = L["Path"], mnID = 1431, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1429][20937925] = { name = "", dnID = L["Path"], mnID = 1436, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1429][32945081] = { name = "", dnID = L["Entrance"], mnID = 1453, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1429][54498479] = { name = "", dnID = L["Path"], mnID = 1431, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1436][61141848] = { name = "", dnID = L["Path"], mnID = 1429, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1436][67546263] = { name = "", dnID = L["Path"], mnID = 1431, type = "PathR", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1436][36458848] = { name = "", dnID = L["Path"], mnID = 1434, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1431][09296355] = { name = "", dnID = L["Path"], mnID = 1436, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1431][91671368] = { name = "", dnID = L["Path"], mnID = 1429, mnID2 = 1433, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1431][51651054] = { name = "", dnID = L["Path"], mnID = 1429, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1431][11882809] = { name = "", dnID = L["Path"], mnID = 1429, mnID2 = 1436, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1431][44638442] = { name = "", dnID = L["Path"], mnID = 1434, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1434][51720662] = { name = "", dnID = L["Path"], mnID = 1431, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1434][10102450] = { name = "", dnID = L["Path"], mnID = 1436, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1434][51597049] = { name = "", dnID = L["Path"], mnID = 210, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[210][58062339] = { name = "", dnID = L["Path"], mnID = 1434, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1431][87734046] = { name = "", dnID = L["Path"], mnID = 1430, type = "PathR", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1430][34663511] = { name = "", dnID = L["Path"], mnID = 1431, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1430][58804194] = { name = "", dnID = L["Path"], mnID = 1435, type = "PathR", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1435][66921231] = { name = "", dnID = L["Path"], mnID = 1433, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1435][09366070] = { name = "", dnID = L["Path"], mnID = 1430, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1435][36457253] = { name = "", dnID = L["Path"], mnID = 1419, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1419][49010806] = { name = "", dnID = L["Path"], mnID = 1435, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[244][41071767] = { name = "", dnID = L["Path"], mnID = 245, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[245][66868158] = { name = "", dnID = L["Path"], mnID = 244, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[217][59891336] = { name = "", dnID = L["Path"], mnID = 1421, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[217][80463751] = { name = "", dnID = L["Path"], mnID = 1424, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[217][52823799] = { name = "", dnID = L["Path"], mnID = 218, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[217][55165978] = { name = "", dnID = L["Path"], mnID = 218, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[217][67976070] = { name = "", dnID = L["Path"], mnID = 218, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[217][69084113] = { name = "", dnID = L["Path"], mnID = 218, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }

                nodes[1424][28147677] = { name = "", dnID = L["Path"], mnID = 217, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1421][45328360] = { name = "", dnID = L["Path"], mnID = 217, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
            end

        end

        --Outland
        if self.db.profile.showZoneOutland then

            if self.db.profile.showZonePaths then
                nodes[1944][08724978] = { name = "", dnID = L["Path"], mnID = 1946, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1944][38078776] = { name = "", dnID = L["Path"], mnID = 1952, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1946][85636485] = { name = "", dnID = L["Path"], mnID = 1944, type = "PathR", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1946][82339239] = { name = "", dnID = L["Path"], mnID = 1952, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1946][66798886] = { name = "", dnID = L["Path"], mnID = 1951, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1946][21287968] = { name = "", dnID = L["Path"], mnID = 1951, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1946][68992913] = { name = "", dnID = L["Path"], mnID = 1949, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1949][51617680] = { name = "", dnID = L["Path"], mnID = 1946, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1949][83592866] = { name = "", dnID = L["Path"], mnID = 1953, type = "PathR", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1949][37018234] = { name = "", dnID = L["Path"], mnID = 1946, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1946][46822505] = { name = "", dnID = L["Path"], mnID = 1949, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1953][21685575] = { name = "", dnID = L["Path"], mnID = 1949, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1951][33831642] = { name = "", dnID = L["Path"], mnID = 1946, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1951][73393525] = { name = "", dnID = L["Path"], mnID = 1946, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1951][77945461] = { name = "", dnID = L["Entrance"], mnID = 1955, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1951][77758299] = { name = "", dnID = L["Path"], mnID = 1952, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1952][20655720] = { name = "", dnID = L["Path"], mnID = 1951, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1952][70865015] = { name = "", dnID = L["Path"], mnID = 1948, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1952][60991736] = { name = "", dnID = L["Path"], mnID = 1944, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1952][34771285] = { name = "", dnID = L["Entrance"], mnID = 1955, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1952][36083207] = { name = "", dnID = L["Entrance"], mnID = 1955, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1952][38092341] = { name = "", dnID = L["Entrance"], mnID = 1955, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1948][22372748] = { name = "", dnID = L["Path"], mnID = 1952, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
            end

        end

        --Northrend
        if self.db.profile.showZoneNorthrend then

            if self.db.profile.showZonePaths then
                nodes[114][94113494] = { name = "", dnID = L["Path"], mnID = 115, type = "PathR", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[114][52270671] = { name = "", dnID = L["Path"], mnID = 119, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[119][31769178] = { name = "", dnID = L["Path"], mnID = 114, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[115][11075449] = { name = "", dnID = L["Path"], mnID = 114, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[115][90656296] = { name = "", dnID = L["Path"], mnID = 116, type = "PathR", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[115][91823061] = { name = "", dnID = L["Path"], mnID = 116, type = "PathR", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[115][59681240] = { name = "", dnID = L["Path"], mnID = 127, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[127][46787064] = { name = "", dnID = L["Path"], mnID = 115, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[127][95055825] = { name = "", dnID = L["Path"], mnID = 121, type = "PathR", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[127][70723078] = { name = "", dnID = L["Path"], mnID = 120, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[127][57853407] = { name = "", dnID = L["Path"], mnID = 118, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[121][11236626] = { name = "", dnID = L["Path"], mnID = 127, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[121][17048604] = { name = "", dnID = L["Path"], mnID = 115, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[121][71507827] = { name = "", dnID = L["Path"], mnID = 116, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[121][55619185] = { name = "", dnID = L["Path"], mnID = 116, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[121][28078433] = { name = "", dnID = L["Path"], mnID = 116, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[120][31639239] = { name = "", dnID = L["Path"], mnID = 127, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[117][24100982] = { name = "", dnID = L["Path"], mnID = 116, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[117][53690502] = { name = "", dnID = L["Path"], mnID = 116, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[117][75110740] = { name = "", dnID = L["Path"], mnID = 116, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[116][09196649] = { name = "", dnID = L["Path"], mnID = 115, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[116][09673162] = { name = "", dnID = L["Path"], mnID = 115, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[116][43372604] = { name = "", dnID = L["Path"], mnID = 121, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[116][59001473] = { name = "", dnID = L["Path"], mnID = 121, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[116][34308422] = { name = "", dnID = L["Path"], mnID = 117, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[116][67117434] = { name = "", dnID = L["Path"], mnID = 117, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[116][86896774] = { name = "", dnID = L["Path"], mnID = 117, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[116][17592817] = { name = "", dnID = L["Path"], mnID = 121, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[118][89008044] = { name = "", dnID = L["Path"], mnID = 127, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false }
            end

        end

    end

end
end