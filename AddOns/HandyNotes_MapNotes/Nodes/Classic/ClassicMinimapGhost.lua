local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

function ns.LoadClassicMinimapGhostInfo(self)
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
            --##### Kalimdor ####s
            --###################
            
			if self.db.profile.showMiniMapKalimdor then

                if self.db.profile.showMiniMapGhost then
                    minimap[1438][58684228] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Teldrassil
                    minimap[1438][56176321] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Teldrassil
                    minimap[1438][34335401] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Teldrassil
                    minimap[1452][61503538] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Winterspring
                    minimap[1450][62156999] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Moonglade
                    minimap[1439][41783654] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Darkshore
                    minimap[1439][43599237] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Darkshore
                    minimap[1448][49483105] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Felwood
                    minimap[1448][56758693] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Felwood
                    minimap[1440][93204220] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ashenvale
                    minimap[1440][84205680] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ashenvale
                    minimap[1440][80605800] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ashenvale
                    minimap[1440][51606320] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ashenvale
                    minimap[1440][40205300] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ashenvale
                    minimap[1440][22202820] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ashenvale
                    minimap[1440][17801100] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ashenvale
                    minimap[1447][70411606] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Azshara
                    minimap[1447][54297142] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Azshara
                    minimap[1447][14007852] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Azshara
                    minimap[1442][57606200] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stone Mountains
                    minimap[1413][60163963] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Barrens
                    minimap[1413][50663257] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Barrens
                    minimap[1413][45286093] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Barrens
                    minimap[1411][47051758] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Durotar
                    minimap[1411][53424433] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Durotar
                    minimap[1411][44146926] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Durotar
                    minimap[1411][57147311] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Durotar
                    minimap[1412][46495549] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Mulgore
                    minimap[1412][42577805] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Mulgore
                    minimap[1412][41312073] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Mulgore
                    minimap[1443][50386290] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Desolace
                    minimap[1445][63594221] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dustwood
                    minimap[1445][39463120] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dustwood
                    minimap[1444][72994449] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Feralas
                    minimap[1444][54824809] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Feralas
                    minimap[1444][31794822] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Feralas
                    minimap[1444][44000740] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Feralas
                    minimap[1444][50401340] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Feralas
                    minimap[1441][30562293] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Thausend Needles
                    minimap[1441][68665323] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Thausend Needles
                    minimap[1446][54002860] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Tanaris
                    minimap[1449][80275026] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Un'Goro
                    minimap[1451][81142078] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Silithus
                    minimap[1451][47173727] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Silithus
                    minimap[1451][28198699] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Silithus
                end

            end


            --##########################
            --##### Eastern Kingdom ####
            --##########################
            
			if self.db.profile.showMiniMapEasternKingdom then

                if self.db.profile.showMiniMapGhost then
                    minimap[1420][78984075] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Tirisfal
                    minimap[1420][56204938] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Tirisfal
                    minimap[1420][30756490] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Tirisfal
                    minimap[1420][62266691] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Tirisfal
                    minimap[1420][81976956] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Tirisfal
                    minimap[1422][65807418] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- W-Plaquelands
                    minimap[1422][45008592] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- W-Plaquelands
                    minimap[1423][47264481] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Eastern Plaquelands
                    minimap[1423][80376522] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Eastern Plaquelands
                    minimap[1423][37747005] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Eastern Plaquelands
                    minimap[1423][39179361] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Eastern Plaquelands
                    minimap[1425][73096817] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Hinterlands
                    minimap[1425][16824433] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Hinterlands
                    minimap[1425][62002680] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Hinterlands
                    minimap[1425][60603860] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Hinterlands
                    minimap[1424][64481953] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hillsbrad
                    minimap[1424][51745229] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hillsbrad
                    minimap[1421][44074244] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Silverpine Forest
                    minimap[1417][48755534] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Arathi Highlands
                    minimap[1437][49304172] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Wetlands
                    minimap[1437][11004376] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Wetlands
                    minimap[1426][54343915] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dun Morogh
                    minimap[1426][47275452] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dun Morogh
                    minimap[1426][30006941] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dun Morogh
                    minimap[1432][32554694] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Loch Modan
                    minimap[1418][56672362] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Badlands
                    minimap[1418][08345521] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Badlands
                    minimap[1427][35472277] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Searing Gorge
                    minimap[1428][64042403] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Burning Stepps
                    minimap[1429][83606978] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Elwynn Forest
                    minimap[1429][49654245] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Elwynn Forest
                    minimap[1429][39486042] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Elwynn Forest
                    minimap[1433][20805640] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Redridge Mountains
                    minimap[1435][50246223] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Swamp of 
                    minimap[1430][39917404] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Deadwing Pass
                    minimap[1431][75005892] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Duskwood
                    minimap[1431][19924911] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Duskwood
                    minimap[1431][47804560] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Duskwood
                    minimap[1431][45006720] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Duskwood
                    minimap[1436][51664950] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Westfall
                    minimap[1419][51041197] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Blasted Lands
                    minimap[1434][38310892] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stranglethorn Valey
                    minimap[1434][30357311] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stranglethorn Valey
                end

            end

        end

    end
end