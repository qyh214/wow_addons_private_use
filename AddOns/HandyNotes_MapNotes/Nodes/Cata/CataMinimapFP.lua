local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

function ns.LoadCataMinimapFPInfo(self)
local db = ns.Addon.db.profile
local minimap = ns.minimap

    --#####################################################################################################
    --##########################        function to hide all minimap below         ##########################
    --#####################################################################################################
    if not db.activate.HideMapNote then


        --##################################################################################################
        --####################################         Zone         ###################################
        --##################################################################################################
		if db.activate.MiniMap then
            
            
            --###################
            --##### Kalimdor ####
            --###################
            
			if self.db.profile.showMiniMapKalimdor then

                if self.db.profile.showMiniMapFP then
                    minimap[1413][69067068] = { mnID = 1413, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Barrens
                    minimap[1449][44144038] = { mnID = 1449, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Un'Goro
                    minimap[1449][55996413] = { mnID = 1449, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Un'Goro
                    minimap[1448][44226210] = { mnID = 1448, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Felwood
                    minimap[1448][51458094] = { mnID = 1448, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Felwood
                    minimap[198][62102164] = { mnID = 198, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hyjal
                    minimap[198][71417523] = { mnID = 198, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hyjal
                    minimap[198][41174253] = { mnID = 198, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hyjal
                    minimap[198][19453632] = { mnID = 198, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hyjal
                    minimap[198][27806341] = { mnID = 198, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hyjal
                    minimap[1443][70553274] = { mnID = 1443, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Desolace
                    minimap[1443][57424945] = { mnID = 1443, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Desolace
                    minimap[1445][42787237] = { mnID = 1445, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dustwood
                    minimap[1446][55836043] = { mnID = 1446, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dustwood
                    minimap[249][56213346] = { mnID = 249, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Uldum
                    minimap[249][26610803] = { mnID = 249, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Uldum
                    minimap[249][22076473] = { mnID = 249, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Uldum

                    if self.faction == "Horde" or db.activate.EnemyFaction then
                        minimap[1452][58714832] = { mnID = 1452, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Winterquell
                        minimap[1450][32036661] = { mnID = 1450, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Moonglade
                        minimap[1448][56230851] = { mnID = 1448, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Felwood
                        minimap[1440][73226155] = { mnID = 1440, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ashenvale
                        minimap[1440][37834217] = { mnID = 1440, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ashenvale
                        minimap[1447][66342069] = { mnID = 1447, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Azshara
                        minimap[1447][52814993] = { mnID = 1447, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Azshara
                        minimap[1447][51387416] = { mnID = 1447, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Azshara
                        minimap[1447][14066497] = { mnID = 1447, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Azshara
                        minimap[1411][53054348] = { mnID = 1411, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Azshara
                        minimap[1411][55437308] = { mnID = 1411, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Azshara
                        minimap[1442][44853071] = { mnID = 1442, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stonetalon Mountains
                        minimap[1442][53684014] = { mnID = 1442, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stonetalon Mountains
                        minimap[1442][48516186] = { mnID = 1442, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stonetalon Mountains
                        minimap[1442][66346294] = { mnID = 1442, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stonetalon Mountains
                        minimap[1442][70638931] = { mnID = 1442, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stonetalon Mountains
                        minimap[1413][48595852] = { mnID = 1413, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- N-Barrens
                        minimap[1413][62281699] = { mnID = 1413, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- N-Barrens
                        minimap[199][39602033] = { mnID = 199, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- S-Barrens
                        minimap[199][41514778] = { mnID = 199, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- S-Barrens
                        minimap[199][41117081] = { mnID = 199, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- S-Barrens
                        minimap[1412][38662736] = { mnID = 1412, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Thunder Bluff
                        minimap[1412][47325864] = { mnID = 1412, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Thunder Bluff
                        minimap[1443][21607417] = { mnID = 1443, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Desolace
                        minimap[1443][44142964] = { mnID = 1443, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Desolace
                        minimap[1444][75354447] = { mnID = 1444, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Feralas
                        minimap[1444][41491543] = { mnID = 1444, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Feralas
                        minimap[1444][50884838] = { mnID = 1444, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Feralas
                        minimap[1451][52573453] = { mnID = 1451, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Silithus
                        minimap[1445][35543187] = { mnID = 1445, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dustwood
                        minimap[1446][52012749] = { mnID = 1446, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Tanaris
                        minimap[1446][33317750] = { mnID = 1446, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Tanaris
                    end

                    if self.faction == "Alliance" or db.activate.EnemyFaction then
                        minimap[1452][60944854] = { mnID = 1452, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Winterquell
                        minimap[1450][48126741] = { mnID = 1450, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Moonglade
                        minimap[1439][51591746] = { mnID = 1439, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Darkshore
                        minimap[1439][44277535] = { mnID = 1439, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Darkshore
                        minimap[1448][60372534] = { mnID = 1448, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Felwood
                        minimap[1440][34314801] = { mnID = 1440, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ashenvale
                        minimap[1440][85014324] = { mnID = 1440, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ashenvale
                        minimap[1440][34887213] = { mnID = 1440, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ashenvale
                        minimap[1440][18022069] = { mnID = 1440, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ashenvale
                        minimap[1442][40003190] = { mnID = 1442, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stonetalon Mountains
                        minimap[1442][48515148] = { mnID = 1442, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stonetalon Mountains
                        minimap[1442][58785410] = { mnID = 1442, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stonetalon Mountains
                        minimap[1442][32046162] = { mnID = 1442, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stonetalon Mountains
                        minimap[199][38961078] = { mnID = 199, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- S-Barrens
                        minimap[199][48996783] = { mnID = 199, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- S-Barrens
                        minimap[199][66344718] = { mnID = 199, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- S-Barrens
                        minimap[1443][64701048] = { mnID = 1443, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Desolace
                        minimap[1443][38802701] = { mnID = 1443, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Desolace
                        minimap[1443][36747153] = { mnID = 1443, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Desolace
                        minimap[1444][50081651] = { mnID = 1444, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Feralas
                        minimap[1444][57085399] = { mnID = 1444, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Feralas
                        minimap[1444][77305673] = { mnID = 1444, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Feralas
                        minimap[1444][46664503] = { mnID = 1444, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Feralas
                        minimap[1451][54323274] = { mnID = 1451, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Silithus
                        minimap[1445][67445131] = { mnID = 1445, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dustwood
                        minimap[1446][51422937] = { mnID = 1446, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Tanaris
                        minimap[1446][40047751] = { mnID = 1446, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Tanaris
                        minimap[1438][55438848] = { mnID = 1438, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Teldrassil
                        minimap[1438][55435052] = { mnID = 1438, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Teldrassil
                        minimap[1943][49474921] = { mnID = 1943, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Azurmythosinsel
                        minimap[1950][57665387] = { mnID = 1950, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Blutmythosinsel
                    end

                end

            end


            --##########################
            --##### Eastern Kingdom ####
            --##########################
            
			if self.db.profile.showMiniMapEasternKingdom then

                if self.db.profile.showMiniMapFP then
                    minimap[1957][48352498] = { mnID = 1957, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE .. " / " .. FACTION_ALLIANCE, type = "Travel", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Quel Danas
                    minimap[1942][74596699] = { mnID = 1942, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Quel Danas
                    minimap[1423][75865339] = { mnID = 1423, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE .. " / " .. FACTION_ALLIANCE, type = "Travel", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Eastern Plaquelands
                    minimap[1423][18412749] = { mnID = 1423, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Eastern Plaquelands
                    minimap[1423][51122128] = { mnID = 1423, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Eastern Plaquelands
                    minimap[1423][61544372] = { mnID = 1423, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Eastern Plaquelands
                    minimap[1423][83825029] = { mnID = 1423, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Eastern Plaquelands
                    minimap[1423][34886783] = { mnID = 1423, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Eastern Plaquelands
                    minimap[1423][10146568] = { mnID = 1423, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Eastern Plaquelands
                    minimap[1423][52815363] = { mnID = 1423, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Eastern Plaquelands
                    minimap[1422][44611842] = { mnID = 1422, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- W-Plaquelands
                    minimap[1422][50425219] = { mnID = 1422, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- W-Plaquelands
                    minimap[241][28362486] = { mnID = 241, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Shadowhigh Mountans
                    minimap[1427][40956867] = { mnID = 1427, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Sengende Schlucht
                    minimap[1418][64193525] = { mnID = 1418, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Badlands Schlucht
                    minimap[1428][45954181] = { mnID = 1428, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Burning Stepps
                    minimap[1428][17545255] = { mnID = 1428, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Burning Stepps
                    minimap[1435][71881197] = { mnID = 1435, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Swamp of 
                    minimap[203][74772236] = { mnID = 201, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Vashj'ir
                    minimap[203][64184978] = { mnID = 205, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Vashj'ir
                    minimap[201][55993107] = { mnID = 201, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Vashj'ir
                    minimap[205][49293978] = { mnID = 205, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Vashj'ir


                    if self.faction == "Horde" or db.activate.EnemyFaction then
                        minimap[1941][46184682] = { mnID = 1941, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Immersingforest
                        minimap[1941][54385088] = { mnID = 1941, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Immersingforest
                        minimap[1941][43806998] = { mnID = 1941, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Immersingforest
                        minimap[1942][45393035] = { mnID = 1942, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ghostland
                        minimap[1420][63157125] = { mnID = 1458, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Undercity
                        minimap[1420][83367010] = { mnID = 1420, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Undercity
                        minimap[1420][58785184] = { mnID = 1420, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Undercity
                        minimap[1422][46446461] = { mnID = 1422, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- W-Plaquelands
                        minimap[1421][45594263] = { mnID = 1421, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Silverwood
                        minimap[1421][57660875] = { mnID = 1421, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Silverwood
                        minimap[1421][45732164] = { mnID = 1421, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Silverwood
                        minimap[1421][50826365] = { mnID = 1421, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Silverwood
                        minimap[1425][81668183] = { mnID = 1425, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hinterlands
                        minimap[1425][32205816] = { mnID = 1425, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hinterlands
                        minimap[1417][68073334] = { mnID = 1417, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Arathi Highlands
                        minimap[1417][13163465] = { mnID = 1417, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Arathi Highlands
                        minimap[1424][58202618] = { mnID = 1424, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hillsb
                        minimap[1424][56054599] = { mnID = 1424, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hillsb
                        minimap[1424][59476318] = { mnID = 1424, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hillsb
                        minimap[1424][48976616] = { mnID = 1424, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hillsb
                        minimap[1424][29086425] = { mnID = 1424, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hillsb
                        minimap[241][73565279] = { mnID = 241, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Shadowhigh Mountans
                        minimap[241][36793775] = { mnID = 241, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Shadowhigh Mountans
                        minimap[241][45877619] = { mnID = 241, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Shadowhigh Mountans
                        minimap[241][75391770] = { mnID = 241, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Shadowhigh Mountans
                        minimap[241][54144217] = { mnID = 241, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Shadowhigh Mountans
                        minimap[1427][34773094] = { mnID = 1427, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Sengende Schlucht
                        minimap[1418][17163990] = { mnID = 1418, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Badlands
                        minimap[1418][52415088] = { mnID = 1418, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Badlands
                        minimap[1428][54062403] = { mnID = 1428, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Burning Stepps
                        minimap[1435][47855530] = { mnID = 1435, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Swamp of 
                        minimap[1419][43581400] = { mnID = 1419, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Blasted Lands
                        minimap[1419][50907284] = { mnID = 1419, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Blasted Lands
                        minimap[1434][38745116] = { mnID = 1434, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stranglethorn Vale
                        minimap[1434][62283930] = { mnID = 1434, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stranglethorn Vale
                        minimap[210][40487320] = { mnID = 210, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stranglethorn Vale
                        minimap[210][34832928] = { mnID = 210, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stranglethorn Vale
                        minimap[224][37857929] = { mnID = 210, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stranglethorn Vale
                        minimap[224][57502820] = { mnID = 1434, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stranglethorn Vale
                        minimap[224][43023346] = { mnID = 1434, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stranglethorn Vale
                        minimap[224][34175375] = { mnID = 210, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stranglethorn Vale
                        minimap[203][45735733] = { mnID = 204, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Vashj'ir
                        minimap[203][64666950] = { mnID = 205, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Vashj'ir
                        minimap[203][68806807] = { mnID = 205, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Vashj'ir
                        minimap[203][72304169] = { mnID = 205, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Vashj'ir
                        minimap[204][53665948] = { mnID = 204, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Vashj'ir
                        minimap[205][60772832] = { mnID = 205, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Vashj'ir
                        minimap[205][53926509] = { mnID = 205, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Vashj'ir
                        minimap[205][50266592] = { mnID = 205, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Vashj'ir

                    end

                    if self.faction == "Alliance" or db.activate.EnemyFaction then
                        minimap[1422][42898507] = { mnID = 1422, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- W-Plaquelands
                        minimap[1422][39286962] = { mnID = 1422, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- W-Plaquelands
                        minimap[1425][11064616] = { mnID = 1425, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hinterlands
                        minimap[1425][65784480] = { mnID = 1425, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hinterlands
                        minimap[1417][39824730] = { mnID = 1417, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Arathi Highlands
                        minimap[1437][09485985] = { mnID = 1437, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Wetlands
                        minimap[1437][50001830] = { mnID = 1437, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Wetlands
                        minimap[1437][56374193] = { mnID = 1437, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Wetlands
                        minimap[1437][38863883] = { mnID = 1437, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Wetlands
                        minimap[1437][56957105] = { mnID = 1437, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Wetlands
                        minimap[241][56531496] = { mnID = 241, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Shadowhigh Mountans
                        minimap[241][48412820] = { mnID = 241, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Shadowhigh Mountans
                        minimap[241][60195745] = { mnID = 241, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Shadowhigh Mountans
                        minimap[241][43805709] = { mnID = 241, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Shadowhigh Mountans
                        minimap[241][81437690] = { mnID = 241, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Shadowhigh Mountans
                        minimap[1432][81776425] = { mnID = 1432, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Loch Modan
                        minimap[1432][33895091] = { mnID = 1432, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Loch Modan
                        minimap[1426][53745255] = { mnID = 1426, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dun Morogh
                        minimap[1426][75945434] = { mnID = 1426, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dun Morogh
                        minimap[1426][59102749] = { mnID = 1426, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dun Morogh
                        minimap[1418][21625769] = { mnID = 1418, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Badlands
                        minimap[1418][48753632] = { mnID = 1418, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Badlands
                        minimap[1427][37893078] = { mnID = 1427, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Sengende Schlucht
                        minimap[1428][72126556] = { mnID = 1428, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Burning Stepps
                        minimap[1429][34674468] = { mnID = 1453, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Elwynn
                        minimap[1429][41736461] = { mnID = 1429, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Elwynn
                        minimap[1429][81836628] = { mnID = 1429, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Elwynn
                        minimap[1433][29395387] = { mnID = 1433, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Redridge Mountains
                        minimap[1433][52795470] = { mnID = 1433, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Redridge Mountains
                        minimap[1433][78016592] = { mnID = 1433, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Redridge Mountains
                        minimap[1435][30673453] = { mnID = 1435, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Swamp of 
                        minimap[1435][69983847] = { mnID = 1435, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Swamp of 
                        minimap[1431][20965661] = { mnID = 1431, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dämmerwood
                        minimap[1431][77394432] = { mnID = 1431, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dämmerwood
                        minimap[1436][56534909] = { mnID = 1436, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Westfall
                        minimap[1436][49681878] = { mnID = 1436, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Westfall
                        minimap[1436][42056329] = { mnID = 1436, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Westfall
                        minimap[1419][47088919] = { mnID = 1419, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Blasted Lands
                        minimap[1419][61282199] = { mnID = 1419, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Blasted Lands
                        minimap[1434][52656616] = { mnID = 1434, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stranglethorn Vale
                        minimap[1434][47701185] = { mnID = 1434, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stranglethorn Vale
                        minimap[210][41517439] = { mnID = 210, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stranglethorn Vale
                        minimap[224][39047953] = { mnID = 210, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stranglethorn Vale
                        minimap[224][50000947] = { mnID = 1434, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stranglethorn Vale
                        minimap[224][52554599] = { mnID = 1434, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stranglethorn Vale
                        minimap[203][42317392] = { mnID = 204, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Vashj'ir
                        minimap[203][69447523] = { mnID = 205, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Vashj'ir
                        minimap[203][64036258] = { mnID = 205, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Vashj'ir
                        minimap[203][69523405] = { mnID = 205, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Vashj'ir
                        minimap[204][56617535] = { mnID = 204, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Vashj'ir
                        minimap[205][57011663] = { mnID = 205, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Vashj'ir
                        minimap[205][48815697] = { mnID = 205, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Vashj'ir
                        minimap[205][56297523] = { mnID = 205, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Vashj'ir
                    end

                end

            end


            --###################
            --##### Outland #####
            --###################
            
            if self.db.profile.showMiniMapOutland then

                if self.db.profile.showMiniMapFP then
                    minimap[1953][65226676] = { mnID = 1953, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Netherstorm
                    minimap[1953][45093489] = { mnID = 1953, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Netherstorm
                    minimap[1953][33716413] = { mnID = 1953, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Netherstorm
                    minimap[1949][61563966] = { mnID = 1949, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Schergrat
                    minimap[1948][56055792] = { mnID = 1948, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Shadowmoon Valey
                    minimap[1948][63293035] = { mnID = 1948, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Shadowmoon Valey
                    minimap[1952][33002307] = { mnID = 1955, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Terokkar

                    if self.faction == "Horde" or db.activate.EnemyFaction then
                        minimap[1948][30192916] = { mnID = 1948, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Shadowmoon Valey
                        minimap[1952][49134348] = { mnID = 1952, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Terokkar
                        minimap[1951][57193537] = { mnID = 1951, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Nagrand
                        minimap[1946][84565494] = { mnID = 1946, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Zangar
                        minimap[1946][32845088] = { mnID = 1946, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Zangar
                        minimap[1949][76286580] = { mnID = 1949, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Schergrat
                        minimap[1949][51855434] = { mnID = 1949, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Schergrat
                        minimap[1944][87264814] = { mnID = 1944, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hellfire Pe
                        minimap[1944][61408120] = { mnID = 1944, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hellfire Pe
                        minimap[1944][56153620] = { mnID = 1944, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hellfire Pe
                        minimap[1944][27825995] = { mnID = 1944, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hellfire Pe
                    end

                    if self.faction == "Alliance" or db.activate.EnemyFaction then
                        minimap[1948][37435530] = { mnID = 1948, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Shadowmoon Valey
                        minimap[1952][59235518] = { mnID = 1952, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Terokkar
                        minimap[1951][54007511] = { mnID = 1951, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Nagrand
                        minimap[1946][67695136] = { mnID = 1946, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Zangar
                        minimap[1946][41192904] = { mnID = 1946, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Zangar
                        minimap[1949][60937046] = { mnID = 1949, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Schergrat
                        minimap[1949][37776139] = { mnID = 1949, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Schergrat
                        minimap[1944][87425231] = { mnID = 1944, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hellfire Pe
                        minimap[1944][78353489] = { mnID = 1944, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hellfire Pe
                        minimap[1944][54566246] = { mnID = 1944, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hellfire Pe
                        minimap[1944][25123728] = { mnID = 1944, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hellfire Pe
                    end

                end

            end
                    

            --####################
            --##### Northrend ####
            --####################

            if self.db.profile.showMiniMapNorthrend then

                if self.db.profile.showMiniMapFP then
                    minimap[114][33003441] = { mnID = 114, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Borean Thundra
                    minimap[114][45173465] = { mnID = 114, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Borean Thundra
                    minimap[114][78355160] = { mnID = 114, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Borean Thundra
                    minimap[119][50026127] = { mnID = 119, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Sholazarbecken
                    minimap[119][25045852] = { mnID = 119, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Sholazarbecken
                    minimap[118][19234814] = { mnID = 118, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Icecrown
                    minimap[118][43742427] = { mnID = 118, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Icecrown
                    minimap[118][72462283] = { mnID = 118, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Icecrown
                    minimap[118][79237225] = { mnID = 118, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Icecrown
                    minimap[118][87667809] = { mnID = 118, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Icecrown
                    minimap[120][30353620] = { mnID = 120, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Sturmgipfel
                    minimap[120][44352820] = { mnID = 120, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Sturmgipfel
                    minimap[120][62506103] = { mnID = 120, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Sturmgipfel
                    minimap[120][40618442] = { mnID = 120, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Sturmgipfel
                    minimap[121][70452331] = { mnID = 121, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Zul'Drak
                    minimap[121][59955673] = { mnID = 121, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Zul'Drak
                    minimap[121][41416437] = { mnID = 121, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Zul'Drak
                    minimap[121][32187439] = { mnID = 121, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Zul'Drak
                    minimap[121][13887356] = { mnID = 121, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Zul'Drak
                    minimap[117][24625804] = { mnID = 117, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Howling Fjord
                    minimap[115][48497439] = { mnID = 115, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Drachenöde
                    minimap[115][60195184] = { mnID = 115, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Drachenöde

                    if self.faction == "Horde" or db.activate.EnemyFaction then
                        minimap[114][40345146] = { mnID = 114, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Borean Thundra
                        minimap[114][49471090] = { mnID = 114, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Borean Thundra
                        minimap[114][77713775] = { mnID = 114, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Borean Thundra
                        minimap[123][21543501] = { mnID = 123, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Thousand Winter
                        minimap[120][36104933] = { mnID = 120, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Sturmgipfel
                        minimap[120][65225064] = { mnID = 120, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Sturmgipfel
                        minimap[127][78515029] = { mnID = 127, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Crystallsangforest
                        minimap[115][43881710] = { mnID = 115, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Drachenöde
                        minimap[115][76426222] = { mnID = 115, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Drachenöde
                        minimap[115][37354563] = { mnID = 115, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Drachenöde
                        minimap[116][64964694] = { mnID = 116, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Grizzlyhills
                        minimap[116][21926437] = { mnID = 116, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Grizzlyhills
                        minimap[117][25892522] = { mnID = 117, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Howling Fjord
                        minimap[117][49451150] = { mnID = 117, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Howling Fjord
                        minimap[117][78892940] = { mnID = 117, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Howling Fjord
                        minimap[117][51996735] = { mnID = 117, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Howling Fjord

                    end

                    if self.faction == "Alliance" or db.activate.EnemyFaction then
                        minimap[114][58706819] = { mnID = 114, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Borean Thundra
                        minimap[114][56552009] = { mnID = 114, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Borean Thundra
                        minimap[123][71993083] = { mnID = 123, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Thousand Winter
                        minimap[120][29427439] = { mnID = 120, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Sturmgipfel
                        minimap[127][72228108] = { mnID = 127, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Crystallsangforest
                        minimap[115][29165518] = { mnID = 115, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Drachenöde
                        minimap[115][39342582] = { mnID = 115, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Drachenöde
                        minimap[115][77064969] = { mnID = 115, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Drachenöde
                        minimap[116][31225912] = { mnID = 116, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Grizzlyhills
                        minimap[116][59712677] = { mnID = 116, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Grizzlyhills
                        minimap[117][31094396] = { mnID = 117, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Howling Fjord
                        minimap[117][59656318] = { mnID = 117, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Howling Fjord
                        minimap[117][59891615] = { mnID = 117, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Howling Fjord

                    end

                end

            end

        end

    end
end