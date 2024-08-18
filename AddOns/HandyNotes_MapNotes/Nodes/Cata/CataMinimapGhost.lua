local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

function ns.LoadCataMinimapGhostInfo(self)
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

                if self.db.profile.showMiniMapGhost then
                    minimap[1438][58684228] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Teldrassil
                    minimap[1438][56176321] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Teldrassil
                    minimap[1438][34335401] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Teldrassil
                    minimap[1452][62676127] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Winterspring
                    minimap[1452][29004300] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Winterspring
                    minimap[1452][61503538] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Winterspring
                    minimap[1450][62156999] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Moonglade
                    minimap[1439][41783654] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Darkshore
                    minimap[1439][43599237] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Darkshore
                    minimap[1448][49483105] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Felwood
                    minimap[1448][56758693] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Felwood
                    minimap[1440][40475277] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ashenvale
                    minimap[1440][80635830] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ashenvale
                    minimap[1447][70411606] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Azshara
                    minimap[1447][54297142] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Azshara
                    minimap[1447][14007852] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Azshara
                    minimap[1442][57516122] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stone Mountains
                    minimap[1442][40240552] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stone Mountains
                    minimap[1442][36387512] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stone Mountains
                    minimap[1413][60163963] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- N-Barrens
                    minimap[1413][50663257] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- N-Barrens
                    minimap[1413][45286093] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- N-Barrens
                    minimap[1413][45788260] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- N-Barrens
                    minimap[1413][51001200] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- N-Barrens
                    minimap[1413][42602140] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- N-Barrens
                    minimap[1413][58601980] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- N-Barrens
                    minimap[1413][56005180] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- N-Barrens
                    minimap[1411][47051758] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Durotar
                    minimap[1411][53424433] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Durotar
                    minimap[1411][44146926] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Durotar
                    minimap[1411][57147311] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Durotar
                    minimap[1412][46495549] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Mulgore
                    minimap[1412][42577805] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Mulgore
                    minimap[1412][41312073] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Mulgore
                    minimap[1456][56621900] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Thunder Bluff
                    minimap[1443][50386290] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Desolace
                    minimap[1443][30607440] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Desolace
                    minimap[1445][63594221] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dustwood
                    minimap[1445][39463120] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dustwood
                    minimap[1445][46535693] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dustwood
                    minimap[1445][41147417] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dustwood
                    minimap[1444][72994449] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Feralas
                    minimap[1444][54824809] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Feralas
                    minimap[1444][31794822] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Feralas
                    minimap[1441][30562293] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Thausend Needles
                    minimap[1441][68665323] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Thausend Needles
                    minimap[1441][43804760] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Thausend Needles
                    minimap[1446][53902878] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Tanaris
                    minimap[1446][68964062] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Tanaris
                    minimap[1446][49415890] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Tanaris
                    minimap[1446][63804960] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Tanaris
                    minimap[1449][80275026] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Un'Goro
                    minimap[1449][45300746] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Un'Goro
                    minimap[1449][49985588] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Un'Goro
                    minimap[1451][81142078] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Silithus
                    minimap[1451][47173727] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Silithus
                    minimap[1451][28198699] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Silithus
                    minimap[1943][39201960] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Azurmythosinsel
                    minimap[1943][47805600] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Azurmythosinsel
                    minimap[1943][77604900] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Azurmythosinsel
                    minimap[1950][30604600] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Blutmythosinsel
                    minimap[1950][58405800] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Blutmythosinsel
                    minimap[249][38001900] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Uldum
                    minimap[249][32704770] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Uldum
                    minimap[249][56603170] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Uldum
                    minimap[249][65501870] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Uldum
                    minimap[249][73505380] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Uldum
                    minimap[249][64506520] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Uldum
                    minimap[249][49007670] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Uldum
                    minimap[249][74108360] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Uldum
                    minimap[198][53302750] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hyjal
                    minimap[198][40904440] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hyjal
                    minimap[198][22204380] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hyjal
                    minimap[198][85305490] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hyjal
                    minimap[198][56508700] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hyjal
                    minimap[207][49402400] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Deepholm
                    minimap[207][76405310] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Deepholm
                    minimap[207][67105520] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Deepholm
                    minimap[207][63408490] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Deepholm                    
                    minimap[207][47305710] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Deepholm
                    minimap[207][43707680] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Deepholm
                    minimap[207][30307840] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Deepholm
                    minimap[207][27806910] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Deepholm
                    minimap[207][24006300] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Deepholm
                    minimap[207][27604520] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Deepholm
                end

            end


            --##########################
            --##### Eastern Kingdom ####
            --##########################
            
			if self.db.profile.showMiniMapEasternKingdom then

                if self.db.profile.showMiniMapGhost then
                    minimap[1957][46603260] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Quel'Danas
                    minimap[1941][38201760] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Immersangwald
                    minimap[1941][48004960] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Immersangwald
                    minimap[1941][60006400] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Immersangwald
                    minimap[1941][44207100] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Immersangwald
                    minimap[1942][43802580] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ghostlands
                    minimap[1942][61405700] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ghostlands
                    minimap[1420][78984075] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Tirisfal
                    minimap[1420][56204938] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Tirisfal
                    minimap[1420][30756490] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Tirisfal
                    minimap[1420][62266691] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Tirisfal
                    minimap[1420][81976956] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Tirisfal
                    minimap[1422][59685315] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- W-Plaquelands
                    minimap[1422][65807418] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- W-Plaquelands
                    minimap[1422][45008592] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- W-Plaquelands
                    minimap[1423][23201340] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Eastern Plaquelands
                    minimap[1425][73096817] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Hinterlands
                    minimap[1425][16824433] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Hinterlands
                    minimap[1416][42833788] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Alterac Valey
                    minimap[1424][64481953] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hillsbrad
                    minimap[1424][51745229] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hillsbrad
                    minimap[1421][44074244] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Silverpine Forest
                    minimap[1421][55597316] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Silverpine Forest
                    minimap[1417][48755534] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Arathi Highlands
                    minimap[1417][26425195] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Arathi Highlands
                    minimap[1417][64404920] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Arathi Highlands
                    minimap[1437][49304172] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Wetlands
                    minimap[1437][11004376] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Wetlands
                    minimap[1437][59406660] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Wetlands
                    minimap[1426][35804580] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dun Morogh
                    minimap[1426][54343915] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dun Morogh
                    minimap[1426][47275452] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dun Morogh
                    minimap[1426][30006941] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dun Morogh
                    minimap[1432][32554694] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Loch Modan
                    minimap[1418][56672362] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Badlands
                    minimap[1418][08345521] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Badlands
                    minimap[1427][54345123] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Searing Gorge
                    minimap[1427][35472277] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Searing Gorge
                    minimap[1428][64042403] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Burning Stepps
                    minimap[1428][37004560] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Burning Stepps
                    minimap[1429][83606978] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Elwynn Forest
                    minimap[1429][49654245] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Elwynn Forest
                    minimap[1429][39486042] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Elwynn Forest
                    minimap[1429][61607020] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Elwynn Forest
                    minimap[1433][20805640] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Redridge Mountains
                    minimap[1433][34004260] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Redridge Mountains
                    minimap[1433][66206200] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Redridge Mountains
                    minimap[1435][50246223] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Swamp of 
                    minimap[1430][39917404] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Deadwing Pass
                    minimap[1431][75005892] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Duskwood
                    minimap[1431][19924911] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Duskwood
                    minimap[1436][51664950] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Westfall
                    minimap[1436][36002480] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Westfall
                    minimap[1436][37407800] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Westfall
                    minimap[1419][51041197] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Blasted Lands
                    minimap[1434][38310892] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stranglethorn Valey
                    minimap[1434][30357311] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stranglethorn Valey
                    minimap[1434][32405040] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stranglethorn Valey
                    minimap[1434][44003240] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stranglethorn Valey
                    minimap[1434][28001940] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stranglethorn Valey
                    minimap[224][33635613] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stranglethorn Valey
                    minimap[224][35941340] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stranglethorn Valey
                    minimap[224][45892283] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stranglethorn Valey
                    minimap[224][43100696] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stranglethorn Valey
                    minimap[241][74607150] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Twilight Highlands
                    minimap[241][64708340] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Twilight Highlands
                    minimap[241][71804970] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Twilight Highlands
                    minimap[241][57405810] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Twilight Highlands                    
                    minimap[241][52104430] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Twilight Highlands
                    minimap[241][44305670] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Twilight Highlands
                    minimap[241][46207520] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Twilight Highlands
                    minimap[241][30407070] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Twilight Highlands                    
                    minimap[241][23905680] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Twilight Highlands
                    minimap[241][31502570] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Twilight Highlands
                    minimap[241][60601610] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Twilight Highlands
                    minimap[241][66601610] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Twilight Highlands
                    minimap[203][60406650] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Vashj'ir
                    minimap[244][51305080] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Tol Barad
                    minimap[244][28605140] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Tol Barad
                    minimap[244][71104530] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Tol Barad
                    minimap[244][52408150] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Tol Barad                    
                    minimap[244][45503070] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Tol Barad
                    minimap[244][60902930] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Tol Barad
                    minimap[244][30102490] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Tol Barad
                    minimap[244][71202820] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Tol Barad
                    minimap[244][37407460] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Tol Barad
                    minimap[244][61107260] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Tol Barad
                    minimap[245][39705010] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Tol Barad Pensisula
                    minimap[245][54703190] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Tol Barad Pensisula
                    minimap[245][67706810] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Tol Barad Pensisula
                    minimap[245][58807490] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Tol Barad Pensisula
                    minimap[217][72703130] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ruins of Gilneas
                    minimap[217][57701790] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ruins of Gilneas
                end

            end


            --###################
            --##### Outland #####
            --###################
            
			if self.db.profile.showMiniMapOutland then

                if self.db.profile.showMiniMapGhost then
                    minimap[1949][61401420] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Schergrat
                    minimap[1949][74602660] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Schergrat
                    minimap[1949][62803740] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Schergrat
                    minimap[1949][37202460] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Schergrat
                    minimap[1949][69205860] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Schergrat
                    minimap[1949][60206620] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Schergrat
                    minimap[1949][52006060] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Schergrat
                    minimap[1949][38406780] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Schergrat
                    minimap[1949][33405860] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Schergrat
                    minimap[1953][42602920] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Netherstorm
                    minimap[1953][64806660] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Netherstorm
                    minimap[1953][56608320] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Netherstorm
                    minimap[1953][33806560] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Netherstorm
                    minimap[1944][22803780] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hellfire Pe
                    minimap[1944][27406340] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hellfire Pe
                    minimap[1944][60007980] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hellfire Pe
                    minimap[1944][54806640] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hellfire Pe
                    minimap[1944][57603820] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hellfire Pe
                    minimap[1944][64402260] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hellfire Pe
                    minimap[1944][68602700] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hellfire Pe
                    minimap[1944][87205020] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hellfire Pe
                    minimap[1946][77206400] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Zangar
                    minimap[1946][65005120] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Zangar
                    minimap[1946][47605040] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Zangar
                    minimap[1946][43603160] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Zangar
                    minimap[1946][36804760] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Zangar
                    minimap[1946][17004800] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Zangar
                    minimap[1951][20203580] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Nagrand
                    minimap[1951][32805620] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Nagrand
                    minimap[1951][40203060] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Nagrand
                    minimap[1951][42604620] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Nagrand
                    minimap[1951][63406900] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Nagrand
                    minimap[1952][44607120] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Terokkar
                    minimap[1952][62808160] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Terokkar
                    minimap[1952][59604260] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Terokkar
                    minimap[1952][39802180] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Terokkar
                    minimap[1948][32202860] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Shadowmoon Valey
                    minimap[1948][39605620] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Shadowmoon Valey
                    minimap[1948][57605920] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Shadowmoon Valey
                    minimap[1948][63603220] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Shadowmoon Valey
                    minimap[1948][65604300] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Shadowmoon Valey
                    minimap[1948][65804560] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Shadowmoon Valey
                end

            end


            --##############################
            --##### Continent Northrend ####
            --##############################
            
            if self.db.profile.showMiniMapNorthrend then

                if self.db.profile.showMiniMapGhost then
                    minimap[114][33205340] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Borean Tundra
                    minimap[114][30603340] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Borean Tundra
                    minimap[114][45607520] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Borean Tundra
                    minimap[114][45005360] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Borean Tundra
                    minimap[114][47603480] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Borean Tundra
                    minimap[114][56001760] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Borean Tundra
                    minimap[114][56806280] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Borean Tundra
                    minimap[119][40403580] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Sholazarbecken
                    minimap[119][76606080] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Sholazarbecken
                    minimap[118][27805440] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Icecrown
                    minimap[118][41202960] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Icecrown
                    minimap[118][52405240] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Icecrown
                    minimap[118][53807120] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Icecrown
                    minimap[118][75203680] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Icecrown
                    minimap[118][79602300] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Icecrown
                    minimap[120][42202480] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Sturmgipfel
                    minimap[120][54205000] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Sturmgipfel
                    minimap[120][46006540] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Sturmgipfel
                    minimap[120][42407960] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Sturmgipfel
                    minimap[120][33606860] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Sturmgipfel
                    minimap[121][84003160] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Zul'Drak
                    minimap[121][70006460] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Zul'Drak
                    minimap[121][37405900] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Zul'Drak
                    minimap[121][20206340] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Zul'Drak
                    minimap[116][47603420] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Grizzyhills
                    minimap[116][32807360] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Grizzyhills
                    minimap[116][70604020] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Grizzyhills
                    minimap[117][37802860] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Howling Fjord
                    minimap[117][26205900] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Howling Fjord
                    minimap[117][38007460] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Howling Fjord
                    minimap[117][56004400] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Howling Fjord
                    minimap[117][59204980] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Howling Fjord
                    minimap[117][58406060] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Howling Fjord
                    minimap[117][69603240] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Howling Fjord
                    minimap[117][75802960] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Howling Fjord
                    minimap[117][74005940] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Howling Fjord
                    minimap[117][75207200] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Howling Fjord
                    minimap[115][13805280] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Drachenöde
                    minimap[115][27804740] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Drachenöde
                    minimap[115][27205540] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Drachenöde
                    minimap[115][39204620] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Drachenöde
                    minimap[115][42202960] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Drachenöde
                    minimap[115][46402020] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Drachenöde
                    minimap[115][63602380] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Drachenöde
                    minimap[115][59805440] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Drachenöde
                    minimap[115][46007500] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Drachenöde
                    minimap[115][77206300] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Drachenöde
                    minimap[115][83205100] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Drachenöde
                    minimap[115][87405760] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Drachenöde
                end

            end

        end

    end
end