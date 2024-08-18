local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

function ns.LoadClassicZoneGhostInfo(self)
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

                if self.db.profile.showZoneGhost then
                    nodes[1438][58684228] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Teldrassil
                    nodes[1438][56176321] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Teldrassil
                    nodes[1438][34335401] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Teldrassil
                    nodes[1452][61503538] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Winterspring
                    nodes[1450][62156999] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Moonglade
                    nodes[1439][41783654] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Darkshore
                    nodes[1439][43599237] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Darkshore
                    nodes[1448][49483105] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Felwood
                    nodes[1448][56758693] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Felwood
                    nodes[1440][93204220] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ashenvale
                    nodes[1440][84205680] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ashenvale
                    nodes[1440][80605800] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ashenvale
                    nodes[1440][51606320] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ashenvale
                    nodes[1440][40205300] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ashenvale
                    nodes[1440][22202820] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ashenvale
                    nodes[1440][17801100] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ashenvale
                    nodes[1447][70411606] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Azshara
                    nodes[1447][54297142] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Azshara
                    nodes[1447][14007852] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Azshara
                    nodes[1442][57606200] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Stone Mountains
                    nodes[1413][60163963] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Barrens
                    nodes[1413][50663257] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Barrens
                    nodes[1413][45286093] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Barrens
                    nodes[1411][47051758] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Durotar
                    nodes[1411][53424433] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Durotar
                    nodes[1411][44146926] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Durotar
                    nodes[1411][57147311] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Durotar
                    nodes[1412][46495549] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mulgore
                    nodes[1412][42577805] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mulgore
                    nodes[1412][41312073] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mulgore
                    nodes[1443][50386290] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Desolace
                    nodes[1445][63594221] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Dustwood
                    nodes[1445][39463120] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Dustwood
                    nodes[1444][72994449] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Feralas
                    nodes[1444][54824809] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Feralas
                    nodes[1444][31794822] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Feralas
                    nodes[1444][44000740] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Feralas
                    nodes[1444][50401340] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Feralas
                    nodes[1441][30562293] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Thausend Needles
                    nodes[1441][68665323] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Thausend Needles
                    nodes[1446][54002860] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Tanaris
                    nodes[1449][80275026] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Un'Goro
                    nodes[1451][81142078] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Silithus
                    nodes[1451][47173727] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Silithus
                    nodes[1451][28198699] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Silithus
                end

            end


            --##########################
            --##### Eastern Kingdom ####
            --##########################
            
			if self.db.profile.showZoneEasternKingdom then

                if self.db.profile.showZoneGhost then
                    nodes[1420][78984075] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Tirisfal
                    nodes[1420][56204938] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Tirisfal
                    nodes[1420][30756490] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Tirisfal
                    nodes[1420][62266691] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Tirisfal
                    nodes[1420][81976956] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Tirisfal
                    nodes[1422][65807418] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- W-Plaquelands
                    nodes[1422][45008592] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- W-Plaquelands
                    nodes[1423][47264481] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Eastern Plaquelands
                    nodes[1423][80376522] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Eastern Plaquelands
                    nodes[1423][37747005] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Eastern Plaquelands
                    nodes[1423][39179361] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Eastern Plaquelands
                    nodes[1425][73096817] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Hinterlands
                    nodes[1425][16824433] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Hinterlands
                    nodes[1425][62002680] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Hinterlands
                    nodes[1425][60603860] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Hinterlands
                    nodes[1424][64481953] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hillsbrad
                    nodes[1424][51745229] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hillsbrad
                    nodes[1421][44074244] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Silverpine Forest
                    nodes[1417][48755534] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Arathi Highlands
                    nodes[1437][49304172] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Wetlands
                    nodes[1437][11004376] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Wetlands
                    nodes[1426][54343915] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Dun Morogh
                    nodes[1426][47275452] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Dun Morogh
                    nodes[1426][30006941] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Dun Morogh
                    nodes[1432][32554694] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Loch Modan
                    nodes[1418][56672362] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Badlands
                    nodes[1418][08345521] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Badlands
                    nodes[1427][35472277] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Searing Gorge
                    nodes[1428][64042403] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Burning Stepps
                    nodes[1429][83606978] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Elwynn Forest
                    nodes[1429][49654245] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Elwynn Forest
                    nodes[1429][39486042] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Elwynn Forest
                    nodes[1433][20805640] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Redridge Mountains
                    nodes[1435][50246223] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Swamp of 
                    nodes[1430][39917404] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Deadwing Pass
                    nodes[1431][75005892] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Duskwood
                    nodes[1431][19924911] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Duskwood
                    nodes[1431][47804560] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Duskwood
                    nodes[1431][45006720] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Duskwood
                    nodes[1436][51664950] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Westfall
                    nodes[1419][51041197] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Blasted Lands
                    nodes[1434][38310892] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Stranglethorn Valey
                    nodes[1434][30357311] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Stranglethorn Valey
                end

            end

        end

    end
end