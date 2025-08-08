local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

function ns.LoadMoPMinimapFPInfo(self)
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
                    minimap[10][69067068] = { mnID = 10, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Barrens
                    minimap[78][44144038] = { mnID = 78, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Un'Goro
                    minimap[78][55996413] = { mnID = 78, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Un'Goro
                    minimap[77][44226210] = { mnID = 77, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Felwood
                    minimap[77][51458094] = { mnID = 77, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Felwood
                    minimap[198][62102164] = { mnID = 198, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hyjal
                    minimap[198][71417523] = { mnID = 198, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hyjal
                    minimap[198][41174253] = { mnID = 198, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hyjal
                    minimap[198][19453632] = { mnID = 198, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hyjal
                    minimap[198][27806341] = { mnID = 198, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hyjal
                    minimap[66][70553274] = { mnID = 66, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Desolace
                    minimap[66][57424945] = { mnID = 66, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Desolace
                    minimap[70][42787237] = { mnID = 70, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dustwood
                    minimap[71][55836043] = { mnID = 71, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dustwood
                    minimap[249][56213346] = { mnID = 249, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Uldum
                    minimap[249][26610803] = { mnID = 249, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Uldum
                    minimap[249][22076473] = { mnID = 249, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Uldum

                    if self.faction == "Horde" or db.activate.EnemyFaction then
                        minimap[83][58714832] = { mnID = 83, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Winterquell
                        minimap[80][32036661] = { mnID = 80, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Moonglade
                        minimap[77][56230851] = { mnID = 77, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Felwood
                        minimap[63][73226155] = { mnID = 63, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ashenvale
                        minimap[63][37834217] = { mnID = 63, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ashenvale
                        minimap[76][66342069] = { mnID = 76, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Azshara
                        minimap[76][52814993] = { mnID = 76, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Azshara
                        minimap[76][51387416] = { mnID = 76, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Azshara
                        minimap[76][14066497] = { mnID = 76, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Azshara
                        minimap[1][53054348] = { mnID = 1, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Azshara
                        minimap[1][55437308] = { mnID = 1, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Azshara
                        minimap[65][44853071] = { mnID = 65, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stonetalon Mountains
                        minimap[65][53684014] = { mnID = 65, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stonetalon Mountains
                        minimap[65][48516186] = { mnID = 65, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stonetalon Mountains
                        minimap[65][66346294] = { mnID = 65, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stonetalon Mountains
                        minimap[65][70638931] = { mnID = 65, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stonetalon Mountains
                        minimap[10][48595852] = { mnID = 1413, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- N-Barrens
                        minimap[10][62281699] = { mnID = 1413, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- N-Barrens
                        minimap[199][39602033] = { mnID = 199, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- S-Barrens
                        minimap[199][41514778] = { mnID = 199, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- S-Barrens
                        minimap[199][41117081] = { mnID = 199, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- S-Barrens
                        minimap[7][38662736] = { mnID = 7, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Thunder Bluff
                        minimap[7][47325864] = { mnID = 7, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Thunder Bluff
                        minimap[66][21607417] = { mnID = 66, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Desolace
                        minimap[66][443764] = { mnID = 66, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Desolace
                        minimap[69][75354447] = { mnID = 69, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Feralas
                        minimap[69][41491543] = { mnID = 69, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Feralas
                        minimap[69][50884838] = { mnID = 69, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Feralas
                        minimap[81][52573453] = { mnID = 81, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Silithus
                        minimap[70][35543187] = { mnID = 70, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dustwood
                        minimap[71][52012749] = { mnID = 71, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Tanaris
                        minimap[71][33317750] = { mnID = 71, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Tanaris
                    end

                    if self.faction == "Alliance" or db.activate.EnemyFaction then
                        minimap[83][60944854] = { mnID = 83, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Winterquell
                        minimap[80][48126741] = { mnID = 80, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Moonglade
                        minimap[62][51591746] = { mnID = 62, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Darkshore
                        minimap[62][44277535] = { mnID = 62, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Darkshore
                        minimap[77][60372534] = { mnID = 77, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Felwood
                        minimap[63][34314801] = { mnID = 63, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ashenvale
                        minimap[63][85014324] = { mnID = 63, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ashenvale
                        minimap[63][34887213] = { mnID = 63, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ashenvale
                        minimap[63][18022069] = { mnID = 63, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ashenvale
                        minimap[65][40003190] = { mnID = 65, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stonetalon Mountains
                        minimap[65][48515148] = { mnID = 65, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stonetalon Mountains
                        minimap[65][58785410] = { mnID = 65, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stonetalon Mountains
                        minimap[65][32046162] = { mnID = 65, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stonetalon Mountains
                        minimap[199][38961078] = { mnID = 199, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- S-Barrens
                        minimap[199][48996783] = { mnID = 199, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- S-Barrens
                        minimap[199][66344718] = { mnID = 199, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- S-Barrens
                        minimap[66][64701048] = { mnID = 66, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Desolace
                        minimap[66][38802701] = { mnID = 66, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Desolace
                        minimap[66][36747153] = { mnID = 66, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Desolace
                        minimap[69][50081651] = { mnID = 69, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Feralas
                        minimap[69][57085399] = { mnID = 69, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Feralas
                        minimap[69][77305673] = { mnID = 69, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Feralas
                        minimap[69][46664503] = { mnID = 69, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Feralas
                        minimap[81][54323274] = { mnID = 81, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Silithus
                        minimap[70][67445131] = { mnID = 70, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dustwood
                        minimap[71][51422937] = { mnID = 71, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Tanaris
                        minimap[71][40047751] = { mnID = 71, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Tanaris
                        minimap[57][55438848] = { mnID = 57, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Teldrassil
                        minimap[57][55435052] = { mnID = 57, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Teldrassil
                        minimap[97][49474921] = { mnID = 97, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Azurmythosinsel
                        minimap[106][57665387] = { mnID = 106, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Blutmythosinsel
                    end

                end

            end


            --##########################
            --##### Eastern Kingdom ####
            --##########################
            
			if self.db.profile.showMiniMapEasternKingdom then

                if self.db.profile.showMiniMapFP then
                    minimap[122][48352498] = { mnID = 122, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE .. " / " .. FACTION_ALLIANCE, type = "Travel", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Quel Danas
                    minimap[95][74596699] = { mnID = 95, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Quel Danas
                    minimap[23][75865339] = { mnID = 23, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE .. " / " .. FACTION_ALLIANCE, type = "Travel", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Eastern Plaquelands
                    minimap[23][18412749] = { mnID = 23, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Eastern Plaquelands
                    minimap[23][51122128] = { mnID = 23, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Eastern Plaquelands
                    minimap[23][61544372] = { mnID = 23, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Eastern Plaquelands
                    minimap[23][83825029] = { mnID = 23, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Eastern Plaquelands
                    minimap[23][34886783] = { mnID = 23, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Eastern Plaquelands
                    minimap[23][10146568] = { mnID = 23, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Eastern Plaquelands
                    minimap[23][52815363] = { mnID = 23, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Eastern Plaquelands
                    minimap[22][44611842] = { mnID = 22, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- W-Plaquelands
                    minimap[22][50425219] = { mnID = 22, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- W-Plaquelands
                    minimap[241][28362486] = { mnID = 241, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Shadowhigh Mountans
                    minimap[32][40956867] = { mnID = 32, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Sengende Schlucht
                    minimap[15][64193525] = { mnID = 15, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Badlands Schlucht
                    minimap[36][45954181] = { mnID = 36, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Burning Stepps
                    minimap[36][17545255] = { mnID = 36, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Burning Stepps
                    minimap[51][71881197] = { mnID = 51, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Swamp of 
                    minimap[203][74772236] = { mnID = 201, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Vashj'ir
                    minimap[203][64184978] = { mnID = 205, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Vashj'ir
                    minimap[201][55993107] = { mnID = 201, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Vashj'ir
                    minimap[205][49293978] = { mnID = 205, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Vashj'ir


                    if self.faction == "Horde" or db.activate.EnemyFaction then
                        minimap[94][46184682] = { mnID = 94, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Immersingforest
                        minimap[94][54385088] = { mnID = 94, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Immersingforest
                        minimap[94][43806998] = { mnID = 94, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Immersingforest
                        minimap[95][45393035] = { mnID = 95, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ghostland
                        minimap[18][63157125] = { mnID = 18, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Undercity
                        minimap[18][83367010] = { mnID = 18, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Undercity
                        minimap[18][58785184] = { mnID = 18, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Undercity
                        minimap[22][46446461] = { mnID = 22, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- W-Plaquelands
                        minimap[21][45594263] = { mnID = 21, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Silverwood
                        minimap[21][57660875] = { mnID = 21, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Silverwood
                        minimap[21][45732164] = { mnID = 21, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Silverwood
                        minimap[21][50826365] = { mnID = 21, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Silverwood
                        minimap[26][81668183] = { mnID = 26, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hinterlands
                        minimap[26][32205816] = { mnID = 26, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hinterlands
                        minimap[14][68073334] = { mnID = 14, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Arathi Highlands
                        minimap[14][13163465] = { mnID = 14, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Arathi Highlands
                        minimap[25][58222649] = { mnID = 25, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hillsb
                        minimap[25][56064606] = { mnID = 25, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hillsb
                        minimap[25][49016622] = { mnID = 25, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hillsb
                        minimap[25][29146442] = { mnID = 25, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hillsb
                        minimap[241][73565279] = { mnID = 241, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Shadowhigh Mountans
                        minimap[241][36793775] = { mnID = 241, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Shadowhigh Mountans
                        minimap[241][45877619] = { mnID = 241, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Shadowhigh Mountans
                        minimap[241][75391770] = { mnID = 241, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Shadowhigh Mountans
                        minimap[241][54144217] = { mnID = 241, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Shadowhigh Mountans
                        minimap[32][34773094] = { mnID = 32, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Sengende Schlucht
                        minimap[15][17163990] = { mnID = 15, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Badlands
                        minimap[15][52415088] = { mnID = 15, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Badlands
                        minimap[36][54062403] = { mnID = 36, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Burning Stepps
                        minimap[51][47855530] = { mnID = 51, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Swamp of 
                        minimap[17][43581400] = { mnID = 17, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Blasted Lands
                        minimap[17][50907284] = { mnID = 17, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Blasted Lands
                        minimap[50][38745116] = { mnID = 50, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Jungle
                        minimap[50][62283930] = { mnID = 50, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Jungle
                        minimap[210][40487320] = { mnID = 210, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stranglethorn Vale
                        minimap[210][34832928] = { mnID = 210, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stranglethorn Vale
                        minimap[224][37857929] = { mnID = 210, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stranglethorn Vale
                        minimap[224][57502820] = { mnID = 224, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stranglethorn Vale
                        minimap[224][43023346] = { mnID = 224, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stranglethorn Vale
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
                        minimap[22][42898507] = { mnID = 22, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- W-Plaquelands
                        minimap[22][39286962] = { mnID = 22, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- W-Plaquelands
                        minimap[26][11064616] = { mnID = 26, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hinterlands
                        minimap[26][65784480] = { mnID = 26, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hinterlands
                        minimap[14][39824730] = { mnID = 14, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Arathi Highlands
                        minimap[56][09485985] = { mnID = 56, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Wetlands
                        minimap[56][50001830] = { mnID = 56, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Wetlands
                        minimap[56][56374193] = { mnID = 56, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Wetlands
                        minimap[56][38863883] = { mnID = 56, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Wetlands
                        minimap[56][56957105] = { mnID = 56, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Wetlands
                        minimap[241][56531496] = { mnID = 241, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Shadowhigh Mountans
                        minimap[241][48412820] = { mnID = 241, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Shadowhigh Mountans
                        minimap[241][60195745] = { mnID = 241, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Shadowhigh Mountans
                        minimap[241][43805709] = { mnID = 241, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Shadowhigh Mountans
                        minimap[241][81437690] = { mnID = 241, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Shadowhigh Mountans
                        minimap[48][81776425] = { mnID = 48, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Loch Modan
                        minimap[48][33895091] = { mnID = 48, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Loch Modan
                        minimap[27][53745255] = { mnID = 27, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dun Morogh
                        minimap[27][75945434] = { mnID = 27, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dun Morogh
                        minimap[27][59102749] = { mnID = 27, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dun Morogh
                        minimap[15][21625769] = { mnID = 15, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Badlands
                        minimap[15][48753632] = { mnID = 15, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Badlands
                        minimap[32][37893078] = { mnID = 32, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Sengende Schlucht
                        minimap[36][72126556] = { mnID = 36, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Burning Stepps
                        minimap[37][34674468] = { mnID = 1453, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Elwynn
                        minimap[37][41736461] = { mnID = 37, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Elwynn
                        minimap[37][81836628] = { mnID = 37, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Elwynn
                        minimap[49][29395387] = { mnID = 49, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Redridge Mountains
                        minimap[49][52795470] = { mnID = 49, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Redridge Mountains
                        minimap[49][78016592] = { mnID = 49, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Redridge Mountains
                        minimap[51][30673453] = { mnID = 51, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Swamp of 
                        minimap[51][69983847] = { mnID = 51, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Swamp of 
                        minimap[47][20965661] = { mnID = 47, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dämmerwood
                        minimap[47][77394432] = { mnID = 47, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dämmerwood
                        minimap[52][56534909] = { mnID = 52, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Westfall
                        minimap[52][49681878] = { mnID = 52, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Westfall
                        minimap[52][42056329] = { mnID = 52, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Westfall
                        minimap[17][47088919] = { mnID = 17, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Blasted Lands
                        minimap[17][61282199] = { mnID = 17, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Blasted Lands
                        minimap[50][52656616] = { mnID = 50, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Jungle
                        minimap[50][47701185] = { mnID = 50, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Jungle
                        minimap[210][41517439] = { mnID = 210, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stranglethorn Vale
                        minimap[224][39047953] = { mnID = 210, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stranglethorn Vale
                        minimap[224][50000947] = { mnID = 224, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stranglethorn Vale
                        minimap[224][52554599] = { mnID = 224, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stranglethorn Vale
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
                    minimap[109][65226676] = { mnID = 109, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Netherstorm
                    minimap[109][45093489] = { mnID = 109, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Netherstorm
                    minimap[109][33716413] = { mnID = 109, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Netherstorm
                    minimap[105][61563966] = { mnID = 105, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Schergrat
                    minimap[104][56055792] = { mnID = 104, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Shadowmoon Valey
                    minimap[104][63293035] = { mnID = 104, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Shadowmoon Valey
                    minimap[109][33002307] = { mnID = 109, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Terokkar

                    if self.faction == "Horde" or db.activate.EnemyFaction then
                        minimap[104][30192916] = { mnID = 104, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Shadowmoon Valey
                        minimap[109][49134348] = { mnID = 109, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Terokkar
                        minimap[107][57193537] = { mnID = 107, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Nagrand
                        minimap[102][84565494] = { mnID = 102, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Zangar
                        minimap[102][32845088] = { mnID = 102, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Zangar
                        minimap[105][76286580] = { mnID = 105, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Schergrat
                        minimap[105][51855434] = { mnID = 105, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Schergrat
                        minimap[100][87264814] = { mnID = 100, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hellfire Pe
                        minimap[100][61408120] = { mnID = 100, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hellfire Pe
                        minimap[100][56153620] = { mnID = 100, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hellfire Pe
                        minimap[100][27825995] = { mnID = 100, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hellfire Pe
                    end

                    if self.faction == "Alliance" or db.activate.EnemyFaction then
                        minimap[104][37435530] = { mnID = 104, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Shadowmoon Valey
                        minimap[109][59235518] = { mnID = 109, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Terokkar
                        minimap[107][54007511] = { mnID = 107, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Nagrand
                        minimap[102][67695136] = { mnID = 102, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Zangar
                        minimap[102][41192904] = { mnID = 102, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Zangar
                        minimap[105][60937046] = { mnID = 105, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Schergrat
                        minimap[105][37776139] = { mnID = 105, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Schergrat
                        minimap[100][87425231] = { mnID = 100, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hellfire Pe
                        minimap[100][78353489] = { mnID = 100, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hellfire Pe
                        minimap[100][54566246] = { mnID = 100, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hellfire Pe
                        minimap[100][25123728] = { mnID = 100, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hellfire Pe
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


            --####################
            --##### Pandaria #####
            --####################

            if self.db.profile.showMiniMapPandaria then

                if self.db.profile.showMiniMapFP then
                    minimap[371][43006840] = { mnID = 371, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- TheJadeForest
                    minimap[371][54606160] = { mnID = 371, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- TheJadeForest
                    minimap[371][47004620] = { mnID = 371, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- TheJadeForest
                    minimap[371][57004400] = { mnID = 371, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- TheJadeForest
                    minimap[371][43602460] = { mnID = 371, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- TheJadeForest
                    minimap[371][50802680] = { mnID = 371, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- TheJadeForest
                    minimap[371][55402360] = { mnID = 371, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- TheJadeForest
                    minimap[433][56607580] = { mnID = 433, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Veiles Stairs
                    minimap[418][76800840] = { mnID = 418, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Krasarang Wilds
                    minimap[418][31206320] = { mnID = 418, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Krasarang Wilds
                    minimap[418][52407660] = { mnID = 418, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Krasarang Wilds
                    minimap[379][72409400] = { mnID = 379, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- KunLaiSummit
                    minimap[379][62403020] = { mnID = 379, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- KunLaiSummit
                    minimap[379][43808960] = { mnID = 379, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- KunLaiSummit
                    minimap[379][42806960] = { mnID = 379, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- KunLaiSummit
                    minimap[379][66205060] = { mnID = 379, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- KunLaiSummit
                    minimap[379][57605980] = { mnID = 379, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- KunLaiSummit
                    minimap[379][34605900] = { mnID = 379, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- KunLaiSummit
                    minimap[379][63204020] = { mnID = 379, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- KunLaiSummit
                    minimap[422][50201220] = { mnID = 422, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- DreadWastes
                    minimap[422][42605560] = { mnID = 422, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- DreadWastes
                    minimap[422][55803480] = { mnID = 422, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- DreadWastes
                    minimap[422][56007020] = { mnID = 422, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- DreadWastes
                    minimap[390][14227927] = { mnID = 390, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- ValeofEternalBlossoms
                    minimap[376][56405020] = { mnID = 376, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- ValleyoftheFourWinds
                    minimap[376][70802420] = { mnID = 376, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- ValleyoftheFourWinds
                    minimap[376][20205860] = { mnID = 376, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- ValleyoftheFourWinds
                    minimap[388][50007200] = { mnID = 388, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- TownlongWastes
                    minimap[388][74408160] = { mnID = 388, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- TownlongWastes
                    minimap[388][54207900] = { mnID = 388, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- TownlongWastes
                    minimap[388][71005720] = { mnID = 388, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- TownlongWastes

                    if self.faction == "Horde" or db.activate.EnemyFaction then
                        minimap[371][28001560] = { mnID = 371, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- TheJadeForest
                        minimap[418][59202460] = { mnID = 418, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Krasarang Wilds
                        minimap[418][29005040] = { mnID = 418, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Krasarang Wilds
                        minimap[379][62408060] = { mnID = 379, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- KunLaiSummit
                        minimap[379][36008360] = { mnID = 379, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- KunLaiSummit
                        minimap[390][63111917] = { mnID = 390, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- ValeofEternalBlossoms fehlt noch
                    end

                    if self.faction == "Alliance" or db.activate.EnemyFaction then
                        minimap[371][46008500] = { mnID = 371, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- TheJadeForest
                        minimap[418][67603260] = { mnID = 418, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Krasarang Wilds
                        minimap[418][25203360] = { mnID = 418, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Krasarang Wilds
                        minimap[379][54008420] = { mnID = 379, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- KunLaiSummit
                        minimap[390][84636242] = { mnID = 390, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- ValeofEternalBlossoms fehlt noch
                    end

                end

            end

        end

    end
end