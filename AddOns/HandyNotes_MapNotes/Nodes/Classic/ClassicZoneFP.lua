local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

function ns.LoadClassicZoneFPInfo(self)
local db = ns.Addon.db.profile
local nodes = ns.nodes

    --#####################################################################################################
    --##########################        function to hide all nodes below         ##########################
    --#####################################################################################################
    if not db.activate.HideMapNote then


        --##################################################################################################
        --####################################         Zone         ###################################
        --##################################################################################################
		if db.activate.ZoneMap then
            
            
            --###################
            --##### Kalimdor ####
            --###################
            
			if self.db.profile.showZoneKalimdor then

                if self.db.profile.showZoneFP then
                    nodes[1413][63123717] = { mnID = 1413, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Barrens
                    nodes[1449][45100578] = { mnID = 1449, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Un'Goro

                    if self.faction == "Horde" or db.activate.EnemyFaction then
                        nodes[1452][60453633] = { mnID = 1452, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Winterquell
                        nodes[1450][32036661] = { mnID = 1450, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Moonglade
                        nodes[1448][34385393] = { mnID = 1448, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Felwood
                        nodes[1440][73226155] = { mnID = 1440, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ashenvale
                        nodes[1440][12203380] = { mnID = 1440, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ashenvale
                        nodes[1447][21914958] = { mnID = 1447, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Azshara
                        nodes[1442][45075986] = { mnID = 1442, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Stonetalon Mountains
                        nodes[1413][51453038] = { mnID = 1413, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Barrens
                        nodes[1413][44385918] = { mnID = 1413, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Barrens
                        nodes[1412][38662736] = { mnID = 1412, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Thunder Bluff
                        nodes[1443][21607417] = { mnID = 1443, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Desolace
                        nodes[1444][75354447] = { mnID = 1444, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Feralas
                        nodes[1451][48663668] = { mnID = 1451, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Silithus
                        nodes[1445][35543187] = { mnID = 1445, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Dustwood
                        nodes[1441][45114912] = { mnID = 1441, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Thousend Needles
                        nodes[1446][51542547] = { mnID = 1446, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Tanaris
                    end

                    if self.faction == "Alliance" or db.activate.EnemyFaction then
                        nodes[1452][62303664] = { mnID = 1452, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Winterquell
                        nodes[1450][48126741] = { mnID = 1450, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Moonglade
                        nodes[1439][36334568] = { mnID = 1439, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Auberdine
                        nodes[1448][62452417] = { mnID = 1448, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Felwood
                        nodes[1440][34314801] = { mnID = 1440, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ashenvale
                        nodes[1447][11887748] = { mnID = 1447, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Azshara
                        nodes[1442][36370707] = { mnID = 1442, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Stonetalon Mountains
                        nodes[1443][64701048] = { mnID = 1443, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Desolace
                        nodes[1444][89374589] = { mnID = 1444, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Feralas
                        nodes[1444][30084314] = { mnID = 1444, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Feralas
                        nodes[1451][50523455] = { mnID = 1451, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Silithus
                        nodes[1445][67445131] = { mnID = 1445, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Dustwood
                        nodes[1446][50922925] = { mnID = 1446, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Tanaris
                        nodes[1438][58369401] = { mnID = 1438, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Teldrassil
                    end

                end

            end


            --##########################
            --##### Eastern Kingdom ####
            --##########################
            
			if self.db.profile.showZoneEasternKingdom then

                if self.db.profile.showZoneFP then

                    if self.faction == "Horde" or db.activate.EnemyFaction then
                        nodes[1420][63157125] = { mnID = 1420, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Undercity
                        nodes[1423][80135696] = { mnID = 1423, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Eastern Plaquelands
                        nodes[1421][45594263] = { mnID = 1421, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Silverwood
                        nodes[1425][81668183] = { mnID = 1425, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hinterlands
                        nodes[1417][73123277] = { mnID = 1417, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Arathi Highlands
                        nodes[1424][60121855] = { mnID = 1424, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hillsb
                        nodes[1427][34773094] = { mnID = 1427, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Sengende Schlucht
                        nodes[1418][03954472] = { mnID = 1418, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Badlands
                        nodes[1428][65622428] = { mnID = 1428, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Burning Stepps
                        nodes[1435][46145477] = { mnID = 1435, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Swamp of 
                        nodes[1434][32482942] = { mnID = 1434, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Stranglethorn Vale
                        nodes[1434][26897704] = { mnID = 1434, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Stranglethorn Vale
                    end

                    if self.faction == "Alliance" or db.activate.EnemyFaction then
                        nodes[1422][42898507] = { mnID = 1422, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = true, showOnContinent = false, showOnMinimap = false } -- W-Plaquelands
                        nodes[1423][81625931] = { mnID = 1423, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Eastern Plaquelands
                        nodes[1425][11064616] = { mnID = 1425, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hinterlands
                        nodes[1417][45804610] = { mnID = 1417, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Arathi Highlands
                        nodes[1424][49215233] = { mnID = 1424, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hillsb
                        nodes[1437][09485985] = { mnID = 1437, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Wetlands
                        nodes[1432][33895091] = { mnID = 1432, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Loch Modan
                        nodes[1426][53373280] = { mnID = 1426, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Dun Morogh
                        nodes[1427][37893078] = { mnID = 1427, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Sengende Schlucht
                        nodes[1428][84256822] = { mnID = 1428, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Burning Stepps
                        nodes[1429][19663677] = { mnID = 1429, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Elwynn
                        nodes[1433][30585945] = { mnID = 1433, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Redridge Mountains
                        nodes[1431][77304433] = { mnID = 1431, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Dämmerwood
                        nodes[1436][56595263] = { mnID = 1436, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Westfall
                        nodes[1419][65422436] = { mnID = 1419, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Blasted Lands
                        nodes[1434][27397790] = { mnID = 1434, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Stranglethorn Vale
                    end

                end

            end

        end

    end
end