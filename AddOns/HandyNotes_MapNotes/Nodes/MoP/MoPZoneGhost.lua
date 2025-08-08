local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

function ns.LoadMoPZoneGhostInfo(self)
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
                    nodes[57][58684228] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Teldrassil
                    nodes[57][56176321] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Teldrassil
                    nodes[57][34335401] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Teldrassil
                    nodes[83][62676127] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Winterspring
                    nodes[83][29004300] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Winterspring
                    nodes[83][61503538] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Winterspring
                    nodes[80][62156999] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Moonglade
                    nodes[62][41783654] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Darkshore
                    nodes[62][43599237] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Darkshore
                    nodes[77][49483105] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Felwood
                    nodes[77][56758693] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Felwood
                    nodes[63][40475277] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ashenvale
                    nodes[63][80635830] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ashenvale
                    nodes[76][70411606] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Azshara
                    nodes[76][54297142] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Azshara
                    nodes[76][14007852] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Azshara
                    nodes[65][57516122] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Stone Mountains
                    nodes[65][40240552] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Stone Mountains
                    nodes[65][36387512] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Stone Mountains
                    nodes[10][60163963] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- N-Barrens
                    nodes[10][50663257] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- N-Barrens
                    nodes[10][45286093] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- N-Barrens
                    nodes[10][45788260] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- N-Barrens
                    nodes[10][51001200] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- N-Barrens
                    nodes[10][42602140] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- N-Barrens
                    nodes[10][58601980] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- N-Barrens
                    nodes[10][56005180] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- N-Barrens
                    nodes[1][47051758] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Durotar
                    nodes[1][53424433] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Durotar
                    nodes[1][44146926] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Durotar
                    nodes[1][57147311] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Durotar
                    nodes[7][46495549] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mulgore
                    nodes[7][42577805] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mulgore
                    nodes[7][41312073] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mulgore
                    nodes[88][56621900] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Thunder Bluff
                    nodes[66][50386290] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Desolace
                    nodes[66][30607440] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Desolace
                    nodes[70][63594221] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Dustwallow
                    nodes[70][39463120] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Dustwallow
                    nodes[70][46535693] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Dustwallow
                    nodes[70][41147417] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Dustwallow
                    nodes[69][72994449] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Feralas
                    nodes[69][54824809] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Feralas
                    nodes[69][31794822] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Feralas
                    nodes[64][30562293] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Thausend Needles
                    nodes[64][68665323] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Thausend Needles
                    nodes[64][43804760] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Thausend Needles
                    nodes[71][53902878] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Tanaris
                    nodes[71][68964062] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Tanaris
                    nodes[71][49415890] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Tanaris
                    nodes[71][63804960] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Tanaris
                    nodes[78][80275026] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Un'Goro
                    nodes[78][45300746] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Un'Goro
                    nodes[78][49985588] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Un'Goro
                    nodes[81][81142078] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Silithus
                    nodes[81][47173727] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Silithus
                    nodes[81][28198699] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Silithus
                    nodes[97][39201960] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Azurmythosinsel
                    nodes[97][47805600] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Azurmythosinsel
                    nodes[97][77604900] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Azurmythosinsel
                    nodes[106][30604600] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Blutmythosinsel
                    nodes[106][58405800] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Blutmythosinsel
                    nodes[249][38001900] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Uldum
                    nodes[249][32704770] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Uldum
                    nodes[249][56603170] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Uldum
                    nodes[249][65501870] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Uldum
                    nodes[249][73505380] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Uldum
                    nodes[249][64506520] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Uldum
                    nodes[249][49007670] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Uldum
                    nodes[249][74108360] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Uldum
                    nodes[198][53302750] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hyjal
                    nodes[198][40904440] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hyjal
                    nodes[198][22204380] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hyjal
                    nodes[198][85305490] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hyjal
                    nodes[198][56508700] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hyjal
                    nodes[207][49402400] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Deepholm
                    nodes[207][76405310] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Deepholm
                    nodes[207][67105520] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Deepholm
                    nodes[207][63408490] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Deepholm                    
                    nodes[207][47305710] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Deepholm
                    nodes[207][43707680] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Deepholm
                    nodes[207][30307840] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Deepholm
                    nodes[207][27806910] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Deepholm
                    nodes[207][24006300] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Deepholm
                    nodes[207][27604520] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Deepholm
                end

            end


            --##########################
            --##### Eastern Kingdom ####
            --##########################
            
			if self.db.profile.showZoneEasternKingdom then

                if self.db.profile.showZoneGhost then
                    nodes[1957][46603260] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Quel'Danas
                    nodes[94][38201760] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Eversong Woods
                    nodes[94][48004960] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Eversong Woods
                    nodes[94][60006400] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Eversong Woods
                    nodes[94][44207100] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Eversong Woods
                    nodes[95][43802580] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ghostlands
                    nodes[95][61405700] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ghostlands
                    nodes[18][78984075] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Tirisfal
                    nodes[18][56204938] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Tirisfal
                    nodes[18][30756490] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Tirisfal
                    nodes[18][62266691] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Tirisfal
                    nodes[18][81976956] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Tirisfal
                    nodes[22][59685315] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- WesternPlaguelands
                    nodes[22][65807418] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- WesternPlaguelands
                    nodes[22][45008592] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- WesternPlaguelands
                    nodes[23][23201340] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- EasternPlagueland
                    nodes[26][73096817] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Hinterlands
                    nodes[26][16824433] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Hinterlands
                    nodes[25][46702130] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hillsbrad
                    nodes[25][58204650] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hillsbrad
                    nodes[25][68507350] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hillsbrad
                    nodes[25][50206800] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hillsbrad
                    nodes[25][35506300] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hillsbrad
                    nodes[25][29508350] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hillsbrad
                    nodes[21][44074244] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Silverpine Forest
                    nodes[21][55597316] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Silverpine Forest
                    nodes[14][48755534] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Arathi Highlands
                    nodes[14][26425195] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Arathi Highlands
                    nodes[14][64404920] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Arathi Highlands
                    nodes[56][49304172] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Wetlands
                    nodes[56][11004376] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Wetlands
                    nodes[56][59406660] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Wetlands
                    nodes[27][35804580] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Dun Morogh
                    nodes[27][54343915] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Dun Morogh
                    nodes[27][47275452] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Dun Morogh
                    nodes[27][30006941] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Dun Morogh
                    nodes[48][32554694] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Loch Modan
                    nodes[15][56672362] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Badlands
                    nodes[15][08345521] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Badlands
                    nodes[32][54345123] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Searing Gorge
                    nodes[32][35472277] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Searing Gorge
                    nodes[36][64042403] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Burning Stepps
                    nodes[36][37004560] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Burning Stepps
                    nodes[37][83606978] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Elwynn Forest
                    nodes[37][49654245] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Elwynn Forest
                    nodes[37][39486042] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Elwynn Forest
                    nodes[37][61607020] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Elwynn Forest
                    nodes[49][20805640] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Redridge Mountains
                    nodes[49][34004260] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Redridge Mountains
                    nodes[49][66206200] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Redridge Mountains
                    nodes[51][50246223] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- SwampOfSorrows 
                    nodes[42][39917404] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Deadwing Pass
                    nodes[47][75005892] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Duskwood
                    nodes[47][19924911] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Duskwood
                    nodes[52][51664950] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Westfall
                    nodes[52][36002480] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Westfall
                    nodes[52][37407800] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Westfall
                    nodes[17][51041197] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Blasted Lands
                    nodes[50][38310892] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Stranglethorn Valey
                    nodes[210][49473030] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Stranglethorn Valey
                    nodes[210][46086718] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Stranglethorn Valey
                    nodes[50][44003240] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Stranglethorn Valey
                    nodes[50][28001940] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Stranglethorn Valey
                    nodes[224][33635613] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Cape of Stranglethorn
                    nodes[224][35941340] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Cape of Stranglethorn
                    nodes[224][45892283] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Cape of Stranglethorn
                    nodes[224][43100696] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Cape of Stranglethorn
                    nodes[241][74607150] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Twilight Highlands
                    nodes[241][64708340] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Twilight Highlands
                    nodes[241][71804970] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Twilight Highlands
                    nodes[241][57405810] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Twilight Highlands                    
                    nodes[241][52104430] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Twilight Highlands
                    nodes[241][44305670] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Twilight Highlands
                    nodes[241][46207520] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Twilight Highlands
                    nodes[241][30407070] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Twilight Highlands                    
                    nodes[241][23905680] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Twilight Highlands
                    nodes[241][31502570] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Twilight Highlands
                    nodes[241][60601610] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Twilight Highlands
                    nodes[241][66601610] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Twilight Highlands
                    nodes[203][60406650] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Vashj'ir
                    nodes[244][51305080] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Tol Barad
                    nodes[244][28605140] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Tol Barad
                    nodes[244][71104530] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Tol Barad
                    nodes[244][52408150] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Tol Barad
                    nodes[244][45503070] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Tol Barad
                    nodes[244][60902930] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Tol Barad
                    nodes[244][30102490] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Tol Barad
                    nodes[244][71202820] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Tol Barad
                    nodes[244][37407460] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Tol Barad
                    nodes[244][61107260] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Tol Barad
                    nodes[245][39705010] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Tol Barad Pensisula
                    nodes[245][54703190] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Tol Barad Pensisula
                    nodes[245][67706810] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Tol Barad Pensisula
                    nodes[245][58807490] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Tol Barad Pensisula
                    nodes[217][72703130] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ruins of Gilneas
                    nodes[217][57701790] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ruins of Gilneas
                end

            end


            --####################
            --##### Outland ######
            --####################
            
			if self.db.profile.showZoneOutland then

                if self.db.profile.showZoneGhost then
                    nodes[105][61401420] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- BladesEdgeMountains
                    nodes[105][74602660] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- BladesEdgeMountains
                    nodes[105][62803740] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- BladesEdgeMountains
                    nodes[105][37202460] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- BladesEdgeMountains
                    nodes[105][69205860] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- BladesEdgeMountains
                    nodes[105][60206620] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- BladesEdgeMountains
                    nodes[105][52006060] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- BladesEdgeMountains
                    nodes[105][38406780] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- BladesEdgeMountains
                    nodes[105][33405860] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- BladesEdgeMountains
                    nodes[109][42602920] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Netherstorm
                    nodes[109][64806660] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Netherstorm
                    nodes[109][56608320] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Netherstorm
                    nodes[109][33806560] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Netherstorm
                    nodes[100][22803780] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hellfire Pe
                    nodes[100][27406340] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hellfire Pe
                    nodes[100][60007980] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hellfire Pe
                    nodes[100][54806640] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hellfire Pe
                    nodes[100][57603820] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hellfire Pe
                    nodes[100][64402260] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hellfire Pe
                    nodes[100][68602700] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hellfire Pe
                    nodes[100][87205020] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hellfire Pe
                    nodes[102][77206400] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Zangar
                    nodes[102][65005120] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Zangar
                    nodes[102][47605040] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Zangar
                    nodes[102][43603160] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Zangar
                    nodes[102][36804760] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Zangar
                    nodes[102][17004800] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Zangar
                    nodes[107][20203580] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Nagrand
                    nodes[107][32805620] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Nagrand
                    nodes[107][40203060] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Nagrand
                    nodes[107][42604620] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Nagrand
                    nodes[107][63406900] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Nagrand
                    nodes[108][44607120] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Terokkar
                    nodes[108][62808160] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Terokkar
                    nodes[108][59604260] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Terokkar
                    nodes[108][39802180] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Terokkar
                    nodes[104][32202860] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Shadowmoon Valey
                    nodes[104][39605620] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Shadowmoon Valey
                    nodes[104][57605920] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Shadowmoon Valey
                    nodes[104][63603220] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Shadowmoon Valey
                    nodes[104][65604300] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Shadowmoon Valey
                    nodes[104][65804560] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Shadowmoon Valey
                end

            end


            --##############################
            --##### Continent Northrend ####
            --##############################
            
            if self.db.profile.showZoneNorthrend then

                if self.db.profile.showZoneGhost then
                    nodes[114][33205340] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Borean Tundra
                    nodes[114][30603340] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Borean Tundra
                    nodes[114][45607520] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Borean Tundra
                    nodes[114][45005360] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Borean Tundra
                    nodes[114][47603480] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Borean Tundra
                    nodes[114][56001760] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Borean Tundra
                    nodes[114][56806280] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Borean Tundra
                    nodes[119][40403580] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Sholazarbecken
                    nodes[119][76606080] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Sholazarbecken
                    nodes[118][27805440] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Icecrown
                    nodes[118][41202960] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Icecrown
                    nodes[118][52405240] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Icecrown
                    nodes[118][53807120] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Icecrown
                    nodes[118][75203680] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Icecrown
                    nodes[118][79602300] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Icecrown
                    nodes[120][42202480] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Sturmgipfel
                    nodes[120][54205000] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Sturmgipfel
                    nodes[120][46006540] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Sturmgipfel
                    nodes[120][42407960] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Sturmgipfel
                    nodes[120][33606860] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Sturmgipfel
                    nodes[121][84003160] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Zul'Drak
                    nodes[121][70006460] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Zul'Drak
                    nodes[121][37405900] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Zul'Drak
                    nodes[121][20206340] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Zul'Drak
                    nodes[116][47603420] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Grizzyhills
                    nodes[116][32807360] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Grizzyhills
                    nodes[116][70604020] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Grizzyhills
                    nodes[117][37802860] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Howling Fjord
                    nodes[117][26205900] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Howling Fjord
                    nodes[117][38007460] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Howling Fjord
                    nodes[117][56004400] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Howling Fjord
                    nodes[117][59204980] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Howling Fjord
                    nodes[117][58406060] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Howling Fjord
                    nodes[117][69603240] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Howling Fjord
                    nodes[117][75802960] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Howling Fjord
                    nodes[117][74005940] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Howling Fjord
                    nodes[117][75207200] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Howling Fjord
                    nodes[115][13805280] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Drachenöde
                    nodes[115][27804740] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Drachenöde
                    nodes[115][27205540] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Drachenöde
                    nodes[115][39204620] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Drachenöde
                    nodes[115][42202960] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Drachenöde
                    nodes[115][46402020] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Drachenöde
                    nodes[115][63602380] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Drachenöde
                    nodes[115][59805440] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Drachenöde
                    nodes[115][46007500] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Drachenöde
                    nodes[115][77206300] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Drachenöde
                    nodes[115][83205100] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Drachenöde
                    nodes[115][87405760] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Drachenöde
                end

            end


            --##############################
            --##### Continent Pandaria #####
            --##############################
            
            if self.db.profile.showZonePandaria then

                if self.db.profile.showZoneGhost then
                    nodes[371][30201460] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Jade Forest
                    nodes[371][28002160] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Jade Forest
                    nodes[371][37402420] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Jade Forest
                    nodes[371][54401940] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Jade Forest
                    nodes[371][27804120] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Jade Forest
                    nodes[371][40206660] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Jade Forest
                    nodes[371][54605640] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Jade Forest
                    nodes[371][45408780] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Jade Forest
                    nodes[371][41809340] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Jade Forest

                    nodes[418][20803960] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Krasarang Wilds
                    nodes[418][44807140] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Krasarang Wilds

                    nodes[376][38403500] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Valley of the Four Winds
                    nodes[376][76603420] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Valley of the Four Winds

                    nodes[422][60202600] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- DreadWastes
                    nodes[422][42005280] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- DreadWastes
                    nodes[422][25008360] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- DreadWastes

                    nodes[388][39205540] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- TownlongWastes
                    nodes[388][64805600] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- TownlongWastes

                    nodes[379][71409040] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Kun-Lai Summit
                    nodes[379][42607100] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Kun-Lai Summit
                    nodes[379][68405940] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Kun-Lai Summit
                    nodes[379][55604900] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Kun-Lai Summit
                    nodes[379][43805100] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Kun-Lai Summit
                    nodes[379][67003340] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Kun-Lai Summit

                    nodes[378][24004960] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Wandering Isle
                    nodes[378][53007740] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Wandering Isle

                end

            end

        end

    end
end