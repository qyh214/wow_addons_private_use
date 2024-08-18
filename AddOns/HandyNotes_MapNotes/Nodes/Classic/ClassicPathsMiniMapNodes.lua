local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

function ns.LoadPathsMiniMapLocationinfo(self)
local db = ns.Addon.db.profile
local minimap = ns.minimap

--#####################################################################################################
--##########################        function to hide all minimap below         ##########################
--#####################################################################################################
if not db.activate.HideMapNote then


    --#####################################################################################################
    --################################         Zone Map        ################################
    --#####################################################################################################

    if db.activate.MiniMap then

        --Kalimdor
        if self.db.profile.showMiniMapKalimdor then

            if self.db.profile.showMiniMapPaths then
                minimap[1438][37125450] = { name = "", dnID = L["Entrance"], mnID = 1457, type = "PathL", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1450][35207168] = { name = "", dnID = L["Path"], mnID = 1448, mnID2 = 1452, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1452][21134646] = { name = "", dnID = L["Path"], mnID = 1450, mnID2 = 1448, type = "PathLO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1448][64321012] = { name = "", dnID = L["Path"], mnID = 1452, mnID2 = 1450, type = "PathRO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1411][45601164] = { name = "", dnID = L["Entrance"], mnID = 1454, type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1411][36690869] = { name = "", dnID = L["Path"], mnID = 1413, type = "PathLU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1411][34944229] = { name = "", dnID = L["Path"], mnID = 1413, type = "PathL", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1413][64713381] = { name = "", dnID = L["Path"], mnID = 1411, type = "PathRO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1413][62371867] = { name = "", dnID = L["Path"], mnID = 1411, type = "PathR", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1413][62490241] = { name = "", dnID = L["Entrance"], mnID = 1454, type = "PathRO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1413][48700740] = { name = "", dnID = L["Path"], mnID = 1440, type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1413][34542735] = { name = "", dnID = L["Path"], mnID = 1442, type = "PathL", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1413][41805875] = { name = "", dnID = L["Path"], mnID = 1412, type = "PathL", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1413][51227814] = { name = "", dnID = L["Path"], mnID = 1445, type = "PathR", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1413][43909107] = { name = "", dnID = L["Path"], mnID = 1441, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1412][68896041] = { name = "", dnID = L["Path"], mnID = 1413, type = "PathR", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1412][36973219] = { name = "", dnID = L["Entrance"], mnID = 1456, type = "PathRO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1412][42992151] = { name = "", dnID = L["Entrance"], mnID = 1456, type = "PathLU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1447][10287463] = { name = "", dnID = L["Path"], mnID = 1440, type = "PathLO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1440][93214637] = { name = "", dnID = L["Path"], mnID = 1447, type = "PathRU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1440][55782975] = { name = "", dnID = L["Path"], mnID = 1448, type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1439][39169487] = { name = "", dnID = L["Path"], mnID = 1440, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1439][46059487] = { name = "", dnID = L["Path"], mnID = 1440, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1440][21181102] = { name = "", dnID = L["Path"], mnID = 1439, type = "PathRO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1440][28501313] = { name = "", dnID = L["Path"], mnID = 1439, type = "PathLO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1440][68408719] = { name = "", dnID = L["Path"], mnID = 1413, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1440][42307242] = { name = "", dnID = L["Path"], mnID = 1442, type = "PathLU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1442][77884175] = { name = "", dnID = L["Path"], mnID = 1440, type = "PathRO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1448][55359052] = { name = "", dnID = L["Path"], mnID = 1440, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1442][29377999] = { name = "", dnID = L["Path"], mnID = 1443, type = "PathLU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1442][81089569] = { name = "", dnID = L["Path"], mnID = 1413, type = "PathRU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1443][53250555] = { name = "", dnID = L["Path"], mnID = 1442, type = "PathRO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1443][42489698] = { name = "", dnID = L["Path"], mnID = 1444, type = "PathRU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1444][45870426] = { name = "", dnID = L["Path"], mnID = 1443, type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1444][86874286] = { name = "", dnID = L["Path"], mnID = 1441, type = "PathRU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1441][08061109] = { name = "", dnID = L["Path"], mnID = 1444, type = "PathLO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1441][31832162] = { name = "", dnID = L["Path"], mnID = 1413, type = "PathRO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1441][74879513] = { name = "", dnID = L["Path"], mnID = 1446, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1446][50792181] = { name = "", dnID = L["Path"], mnID = 1441, type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1446][27025567] = { name = "", dnID = L["Path"], mnID = 1449, type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1445][32144637] = { name = "", dnID = L["Path"], mnID = 1413, type = "PathL", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1445][53010925] = { name = "", dnID = L["Path"], mnID = 1413, type = "PathRO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1413][62865893] = { name = "", dnID = L["Path"], mnID = 1445, type = "PathRU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1451][77952162] = { name = "", dnID = L["Path"], mnID = 1449, type = "PathRO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1449][71807754] = { name = "", dnID = L["Path"], mnID = 1446, type = "PathRU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1449][28732185] = { name = "", dnID = L["Path"], mnID = 1451, type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true }
            end

        end

        if self.db.profile.showMiniMapEasternKingdom then

            if self.db.profile.showMiniMapPaths then
                minimap[1423][13487260] = { name = "", dnID = L["Path"], mnID = 1422, type = "PathL", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1423][06834139] = { name = "", dnID = L["Passage"], type = "PathRO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1423][15502906] = { name = "", dnID = L["Passage"], type = "PathLU", mnID = 1422, showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1422][66062181] = { name = "", dnID = L["Path"], mnID = 1423, type = "PathRO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1422][70255007] = { name = "", dnID = L["Path"], mnID = 1423, type = "PathR", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1422][20755616] = { name = "", dnID = L["Path"], mnID = 1420, type = "PathLO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1422][43598848] = { name = "", dnID = L["Path"], mnID = 1416, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1422][65228620] = { name = "", dnID = L["Path"], mnID = 1425, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1420][84287020] = { name = "", dnID = L["Path"], mnID = 1422, type = "PathR", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1420][51017169] = { name = "", dnID = L["Entrance"], mnID = 1458, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1420][54987075] = { name = "", dnID = L["Path"], mnID = 1421, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1420][62006207] = { name = "", dnID = L["Entrance"], mnID = 1458, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1421][67230574] = { name = "", dnID = L["Path"], mnID = 1420, type = "PathRO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1421][67178036] = { name = "", dnID = L["Path"], mnID = 1424, type = "PathR", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1421][67545302] = { name = "", dnID = L["Path"], mnID = 1416, type = "PathR", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1416][09597402] = { name = "", dnID = L["Path"], mnID = 1421, type = "PathLO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1424][14784563] = { name = "", dnID = L["Path"], mnID = 1421, type = "PathL", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1424][54180888] = { name = "", dnID = L["Path"], mnID = 1416, type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1424][27521627] = { name = "", dnID = L["Path"], mnID = 1416, type = "PathLO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1424][82563160] = { name = "", dnID = L["Path"], mnID = 1425, type = "PathRO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1425][09545468] = { name = "", dnID = L["Path"], mnID = 1424, type = "PathLU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1425][23212809] = { name = "", dnID = L["Path"], mnID = 1422, type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1416][63668220] = { name = "", dnID = L["Path"], mnID = 1424, type = "PathRU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1424][80345505] = { name = "", dnID = L["Path"], mnID = 1417, type = "PathRU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1416][53329070] = { name = "", dnID = L["Path"], mnID = 1424, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1424][86874637] = { name = "", dnID = L["Path"], mnID = 1417, type = "PathRU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1416][80593344] = { name = "", dnID = L["Path"], mnID = 1422, type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1417][20813030] = { name = "", dnID = L["Path"], mnID = 1424, type = "PathLO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1417][24692199] = { name = "", dnID = L["Path"], mnID = 1424, type = "PathLO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1417][45378922] = { name = "", dnID = L["Path"], mnID = 1437, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1437][51841036] = { name = "", dnID = L["Path"], mnID = 1417, type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1437][54557149] = { name = "", dnID = L["Path"], mnID = 1432, type = "PathLU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1432][25180962] = { name = "", dnID = L["Path"], mnID = 1437, type = "PathRO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1432][18591645] = { name = "", dnID = L["Path"], mnID = 1426, type = "PathL", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1432][47108202] = { name = "", dnID = L["Path"], mnID = 1418, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1432][20506318] = { name = "", dnID = L["Path"], mnID = 1426, type = "PathLO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1432][17188368] = { name = "", dnID = L["Path"], mnID = 1427, type = "PathLU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1426][52523511] = { name = "", dnID = L["Entrance"], mnID = 1455, type = "PathRO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1426][83923104] = { name = "", dnID = L["Path"], mnID = 1432, type = "PathRO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1426][86935136] = { name = "", dnID = L["Path"], mnID = 1432, type = "PathRO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1418][46970943] = { name = "", dnID = L["Path"], mnID = 1432, type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1418][04495986] = { name = "", dnID = L["Path"], mnID = 1427, type = "PathL", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1427][78371682] = { name = "", dnID = L["Path"], mnID = 1432, type = "PathRO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1427][34548036] = { name = "", dnID = L["Path"], mnID = 1428, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1427][74434175] = { name = "", dnID = L["Path"], mnID = 1418, type = "PathR", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1428][29183991] = { name = "", dnID = L["Path"], mnID = 1427, type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1428][77957556] = { name = "", dnID = L["Path"], mnID = 1433, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1433][45441682] = { name = "", dnID = L["Path"], mnID = 1428, type = "PathRO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1433][04497205] = { name = "", dnID = L["Path"], mnID = 1429, type = "PathLU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1433][09668627] = { name = "", dnID = L["Path"], mnID = 1431, type = "PathLU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1429][93277223] = { name = "", dnID = L["Path"], mnID = 1433, type = "PathRO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1429][83898239] = { name = "", dnID = L["Path"], mnID = 1431, type = "PathLU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1429][20937925] = { name = "", dnID = L["Path"], mnID = 1436, type = "PathLU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1429][32945081] = { name = "", dnID = L["Entrance"], mnID = 1453, type = "PathLO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1429][54498479] = { name = "", dnID = L["Path"], mnID = 1431, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1436][61141848] = { name = "", dnID = L["Path"], mnID = 1429, type = "PathRO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1436][67546263] = { name = "", dnID = L["Path"], mnID = 1431, type = "PathR", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1436][36458848] = { name = "", dnID = L["Path"], mnID = 1434, type = "PathRU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1431][09296355] = { name = "", dnID = L["Path"], mnID = 1436, type = "PathL", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1431][91671368] = { name = "", dnID = L["Path"], mnID = 1429, mnID2 = 1433, type = "PathRO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1431][51651054] = { name = "", dnID = L["Path"], mnID = 1429, type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1431][11882809] = { name = "", dnID = L["Path"], mnID = 1429, mnID2 = 1436, type = "PathLO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1431][44638442] = { name = "", dnID = L["Path"], mnID = 1434, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1434][39220537] = { name = "", dnID = L["Path"], mnID = 1431, type = "PathRO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1434][14221313] = { name = "", dnID = L["Path"], mnID = 1436, type = "PathLO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1431][87734046] = { name = "", dnID = L["Path"], mnID = 1430, type = "PathR", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1430][34663511] = { name = "", dnID = L["Path"], mnID = 1431, type = "PathL", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1430][58804194] = { name = "", dnID = L["Path"], mnID = 1435, type = "PathR", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1435][04436078] = { name = "", dnID = L["Path"], mnID = 1430, type = "PathL", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1435][33377168] = { name = "", dnID = L["Path"], mnID = 1419, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                minimap[1419][51900962] = { name = "", dnID = L["Path"], mnID = 1435, type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true }
            end

        end

    end

end
end