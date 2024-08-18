local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

function ns.LoadClassicContinentInfo(self)
local db = ns.Addon.db.profile
local nodes = ns.nodes

    --#####################################################################################################
    --##########################        function to hide all nodes below         ##########################
    --#####################################################################################################
    if not db.activate.HideMapNote then


        --##################################################################################################
        --####################################         Continent         ###################################
        --##################################################################################################
		if db.activate.Continent then
            
            
            --###################
            --##### Kalimdor ####
            --###################
            
			if self.db.profile.showContinentKalimdor then


            -- Raids

                if self.db.profile.showContinentRaids then

                    nodes[1414][40808546] = { mnID = 1451, showOnContinent = true, showInZone = false, showOnMinimap = false, name = L["Temple of Ahn'Qiraj"] .. " " .. "[" .. LEVEL .. ": " .. "60+]", type = "Raid" }
    				nodes[1414][42408638] = { mnID = 1451, showOnContinent = true, showInZone = false, showOnMinimap = false, name = DUNGEON_FLOOR_RUINSOFAHNQIRAJ1 .. " " .. "[" .. LEVEL .. ": " .. "60+]", type = "Raid" }
    			    nodes[1414][56327161] = { mnID = 1445, showOnContinent = true, showInZone = false, showOnMinimap = false, name = DUNGEON_FLOOR_ONYXIASLAIR1 .. " " .. "[" .. LEVEL .. ": " .. "60+]", type = "Raid" }

                end


            -- Dungeons

                if self.db.profile.showContinentDungeons then

                    nodes[1414][43763504] = { mnID = 1440, showOnContinent = true, showInZone = false, showOnMinimap = false, name = L["Blackfathom Deeps"] .. " " .. "[" .. LEVEL .. ": " .. "24-32]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "15", type = "Dungeon" }
    			    nodes[1414][42537013] = { mnID = 1444, showOnContinent = true, showInZone = false, showOnMinimap = false, name = L["Dire Maul"] .. " " .. "[" .. LEVEL .. ": " .. "55-60]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "45", type = "Dungeon" }
                    nodes[1414][45976847] = { mnID = 1444, showOnContinent = true, showInZone = false, showOnMinimap = false, name = L["Dire Maul"] .. " " .. "[" .. LEVEL .. ": " .. "55-60]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "45", type = "Dungeon" }
                    nodes[1414][38225775] = { mnID = 1443, showOnContinent = true, showInZone = false, showOnMinimap = false, name = DUNGEON_FLOOR_MARAUDON1 .. " " .. "[" .. LEVEL .. ": " .. "46-55]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "30", type = "Dungeon" }
    			    nodes[1414][52757105] = { mnID = 1413, showOnContinent = true, showInZone = false, showOnMinimap = false, name = DUNGEON_FLOOR_RAZORFENDOWNS1 .. " " .. "[" .. LEVEL .. ": " .. "37-46]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "35", type = "Dungeon" }
                    nodes[1414][50657013] = { mnID = 1413, showOnContinent = true, showInZone = false, showOnMinimap = false, name = DUNGEON_FLOOR_RAZORFENKRAUL1 .. " " .. "[" .. LEVEL .. ": " .. "29-38]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "25", type = "Dungeon" }
    			    nodes[1414][51885554] = { mnID = 1413, showOnContinent = true, showInZone = false, showOnMinimap = false, name = DUNGEON_FLOOR_WAILINGCAVERNS1 .. " " .. "[" .. LEVEL .. ": " .. "17-24]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "10", type = "Dungeon" }
                    nodes[1414][54107955] = { mnID = 1446, showOnContinent = true, showInZone = false, showOnMinimap = false, name = DUNGEON_FLOOR_ZULFARRAK .. " " .. "[" .. LEVEL .. ": " .. "42-56", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "35", type = "Dungeon" }
    			    --nodes[1414][58164464] = { mnID = 1454, showOnContinent = true, showInZone = false, showOnMinimap = false, name = DUNGEON_FLOOR_RAGEFIRE1 .. " " .. "[" .. LEVEL .. ": " .. "13-18]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "8", type = "Dungeon" }
    			    
                end


            -- Blizz Pois

                if self.db.profile.activate.RemoveBlizzPOIs then

                    if self.faction == "Alliance" or db.activate.EnemyFaction then
                    
                        nodes[1414][39941176] = { mnID = 1457, showOnContinent = true, showInZone = false, showOnMinimap = false, name = "", type = "AIcon" , TransportName = L["Darnassus"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " => " .. L["Rut'theran"] } 
                    
                    end

                    if self.faction == "Horde" or db.activate.EnemyFaction then
                        nodes[1414][58164464] = { mnID = 1454, showOnContinent = true, showInZone = false, showOnMinimap = false, name = "", type = "HIcon" , TransportName = DUNGEON_FLOOR_ORGRIMMAR0 .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. CALENDAR_TYPE_DUNGEON .. "\n" .. " => " .. DUNGEON_FLOOR_RAGEFIRE1 } 
                        nodes[1414][46965720] = { mnID = 1456, showOnContinent = true, showInZone = false, showOnMinimap = false, name = "", type = "HIcon" , TransportName = L["Thunder Bluff"] .. " - " .. FACTION_HORDE } 
                    end

                end


            -- Dungeons and not Blizz for Ragefire

                if self.db.profile.showContinentDungeons and not self.db.profile.activate.RemoveBlizzPOIs then
                
                    if self.db.profile.showContinentDungeons then
                        nodes[1414][58164464] = { mnID = 1454, showOnContinent = true, showInZone = false, showOnMinimap = false, name = DUNGEON_FLOOR_RAGEFIRE1 .. " " .. "[" .. LEVEL .. ": " .. "13-18]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "8", type = "Dungeon" }
                    end
                end

            -- Zeppelin
                if self.db.profile.showContinentZeppelins then   

                    if self.faction == "Horde" or db.activate.EnemyFaction then
                        nodes[1414][59154686] = { mnID = 1411, showOnContinent = true, showInZone = false, showOnMinimap = false, name = "", type = "HZeppelin" , TransportName = L["Durotar"] .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Zeppelin"] .. "\n" .. " => " .. L["Grom'gol, Stranglethorn Vale"] .. "\n" .. " => " .. L["Tirisfal Glades"] .. " - " .. L["Undercity"] }
                    end
                    
                end


            -- Ships
                if self.db.profile.showContinentShips then

                    nodes[1414][57305757] = { mnID = 1413, showOnContinent = true, showInZone = false, showOnMinimap = false, name = "", type = "Ship" , TransportName = L["Ratchet"] .. " - " .. FACTION_NEUTRAL .. "\n" .. "\n" .. L["Ship"] .. "\n" .. " => " .. POSTMASTER_LETTER_STRANGLETHORNVALE } -- Ship from Booty Bay to Ratchet
                

                    if self.faction == "Alliance" or db.activate.EnemyFaction then

                        nodes[1414][44132395] = { mnID = 1439, showOnContinent = true, showInZone = false, showOnMinimap = false, name = "", type = "AShip" , TransportName = L["Auberdine"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Ship"] .. "\n" .. " => " .. L["Teldrassil"] .. "\n" .. " => " .. POSTMASTER_LETTER_WETLANDS } -- Ship from Booty Bay to Ratchet
                        nodes[1414][43761657] = { mnID = 1438, showOnContinent = true, showInZone = false, showOnMinimap = false, name = "", type = "AShip" , TransportName = L["Teldrassil"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Ship"] .. "\n" .. " => " .. L["Auberdine"] } -- Ship from Booty Bay to Ratchet
                        nodes[1414][59036699] = { mnID = 1445, showOnContinent = true, showInZone = false, showOnMinimap = false, name = "", type = "AShip" , TransportName = L["Theramore Isle"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Ship"] .. "\n" .. " => " .. POSTMASTER_LETTER_WETLANDS } -- Ship from Dustwallow Marsh to Menethil Harbor

                    end

                end

            -- Flight Point
                if self.db.profile.showContinentFP then
                    nodes[1414][56535547] = { mnID = 1413, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL"  } -- Barrens
                    nodes[1414][49377682] = { mnID = 1449, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL"  } -- Un'Goro

                    if self.faction == "Horde" or db.activate.EnemyFaction then
                        nodes[1414][58732404] = { mnID = 1452, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH"  } -- Winterquell
                        nodes[1414][52012152] = { mnID = 1450, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH"  } -- Moonglade
                        nodes[1414][47163133] = { mnID = 1448, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH"  } -- Felwood
                        nodes[1414][53174261] = { mnID = 1440, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH"  } -- Ashenvale
                        nodes[1414][43713806] = { mnID = 1440, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH"  } -- Ashenvale
                        nodes[1414][58303690] = { mnID = 1447, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH"  } -- Azshara
                        nodes[1414][43534767] = { mnID = 1442, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH"  } -- Stonetalon Mountains
                        nodes[1414][53505339] = { mnID = 1413, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH"  } -- Barrens
                        nodes[1414][51416133] = { mnID = 1413, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH"  } -- Barrens
                        nodes[1414][45995653] = { mnID = 1412, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH"  } -- Thunder Bluff
                        nodes[1414][37375893] = { mnID = 1443, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH"  } -- Desolace
                        nodes[1414][45746965] = { mnID = 1444, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH"  } -- Feralas
                        nodes[1414][44027925] = { mnID = 1451, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH"  } -- Silithus
                        nodes[1414][54126447] = { mnID = 1445, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH"  } -- Dustwood
                        nodes[1414][52767389] = { mnID = 1441, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH"  } -- Thousend Needles
                        nodes[1414][56468017] = { mnID = 1446, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH"  } -- Tanaris
                    end

                    if self.faction == "Alliance" or db.activate.EnemyFaction then
                        nodes[1414][59412402] = { mnID = 1452, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA"  } -- Winterquell
                        nodes[1414][53252125] = { mnID = 1450, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA"  } -- Moonglade
                        nodes[1414][44632569] = { mnID = 1439, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA"  } -- Auberdine
                        nodes[1414][51652642] = { mnID = 1448, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA"  } -- Felwood
                        nodes[1414][47164028] = { mnID = 1440, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA"  } -- Ashenvale
                        nodes[1414][56894065] = { mnID = 1447, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA"  } -- Azshara
                        nodes[1414][42364083] = { mnID = 1442, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA"  } -- Stonetalon Mountains
                        nodes[1414][42855117] = { mnID = 1443, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA"  } -- Desolace
                        nodes[1414][48497019] = { mnID = 1444, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA"  } -- Feralas
                        nodes[1414][37266966] = { mnID = 1444, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA"  } -- Feralas
                        nodes[1414][44517888] = { mnID = 1451, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA"  } -- Silithus
                        nodes[1414][58676743] = { mnID = 1445, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA"  } -- Dustwood
                        nodes[1414][56468147] = { mnID = 1446, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA"  } -- Tanaris
                        nodes[1414][44141645] = { mnID = 1438, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA"  } -- Teldrassil
                    end

                end

            end


            --##########################
            --##### Eastern Kingdom ####
            --##########################

            if self.db.profile.showContinentEasternKingdom then


            -- Raids            

                if self.db.profile.showContinentRaids then

				    nodes[1415][48756588] = { mnID = 1428, showOnContinent = true, showInZone = false, showOnMinimap = false, name = DUNGEON_FLOOR_MOLTENCORE1 .. " " .. "[" .. LEVEL .. ": " .. "60+]", type = "Raid" }
                    nodes[1415][48878251] = { mnID = 1434, showOnContinent = true, showInZone = false, showOnMinimap = false, name = DUNGEON_FLOOR_ZULGURUB1 .. " " .. "[" .. LEVEL .. ": " .. "60+]", type = "Raid" }
                    nodes[1415][56011841] = { mnID = 1423, showOnContinent = true, showInZone = false, showOnMinimap = false, name = L["Naxxramas"] .. " " .. "[" .. LEVEL .. ": " .. "60+]", type = "Raid" }


                end


            -- Dungeons

                if self.db.profile.showContinentDungeons then

                    nodes[1415][40993282] = { mnID = 1421, showOnContinent = true, showInZone = false, showOnMinimap = false, name = L["Shadowfang Keep"] .. " " .. "[" .. LEVEL .. ": " .. "22-30]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "14", type = "Dungeon" }
				    nodes[1415][52562617] = { mnID = 1422, showOnContinent = true, showInZone = false, showOnMinimap = false, name = L["Scholomance"] .. " " .. "[" .. LEVEL .. ": " .. "58-60]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "48", type = "Dungeon" }
				    nodes[1415][47641934] = { mnID = 1420, showOnContinent = true, showInZone = false, showOnMinimap = false, name = DUNGEON_FLOOR_TIRISFAL13 .. " " .. "[" .. LEVEL .. ": " .. "22-30]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "21", type = "Dungeon" }
				    nodes[1415][54781712] = { mnID = 1423, showOnContinent = true, showInZone = false, showOnMinimap = false, name = DUNGEON_FLOOR_COTSTRATHOLME1 .. " " .. "[" .. LEVEL .. ": " .. "58-60]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "48", type = "Dungeon" }
				    nodes[1415][56267604] = { mnID = 1435, showOnContinent = true, showInZone = false, showOnMinimap = false, name = DUNGEON_FLOOR_THETEMPLEOFATALHAKKAR1 .. " " .. "[" .. LEVEL .. ": " .. "50-56]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "45", type = "Dungeon" }
				    nodes[1415][54415757] = { mnID = 1418, showOnContinent = true, showInZone = false, showOnMinimap = false, name = DUNGEON_FLOOR_BADLANDS18 .. " " .. "[" .. LEVEL .. ": " .. "41-51]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "30", type = "Dungeon" }
				    nodes[1415][55775979] = { mnID = 1418, showOnContinent = true, showInZone = false, showOnMinimap = false, name = DUNGEON_FLOOR_BADLANDS18 .. " " .. "[" .. LEVEL .. ": " .. "41-51]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "30", type = "Dungeon" }
                    nodes[1415][43825369] = { mnID = 1426, showOnContinent = true, showInZone = false, showOnMinimap = false, name = DUNGEON_FLOOR_DUNMOROGH10 .. " " .. "[" .. LEVEL .. ": " .. "29-38]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "19", type = "Dungeon" }
                    nodes[1415][40997918] = { mnID = 1436, showOnContinent = true, showInZone = false, showOnMinimap = false, name = DUNGEON_FLOOR_THEDEADMINES1 .. " " .. "[" .. LEVEL .. ": " .. "17-26]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "10", type = "Dungeon" }
                    --nodes[1415][42966902] = { mnID = 1453, showOnContinent = true, showInZone = false, showOnMinimap = false, name = DUNGEON_FLOOR_THESTOCKADE1 .. " " .. "[" .. LEVEL .. ": " .. "22-30]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "15", type = "Dungeon" }

                end

                if self.db.profile.showContinentMultiple then

				    nodes[1415][48756588] = { mnID = 1428, showOnContinent = true, showInZone = false, showOnMinimap = false, name = "", dnID = DUNGEON_FLOOR_MOLTENCORE1 .. " " .. "[" .. LEVEL .. ": " .. "60+]" .. "\n" .. DUNGEON_FLOOR_BURNINGSTEPPES15 .. " " .. "[" .. LEVEL .. ": " .. "60+]" .. "\n" .. DUNGEON_FLOOR_BURNINGSTEPPES14 .. " " .. "[" .. LEVEL .. ": " .. "55-60]" .. "\n" .. DUNGEON_FLOOR_BURNINGSTEPPES16 .. " " .. "[" .. LEVEL .. ": " .. "52-60]", type = "MultipleM" }

                end


            -- Blizz POIS

                if self.db.profile.activate.RemoveBlizzPOIs then

                    if self.faction == "Horde" or db.activate.EnemyFaction then
                      nodes[1415][43592454] = { mnID = 1458, showOnContinent = true, showInZone = false, showOnMinimap = false, name = "", type = "HIcon" , TransportName = L["Undercity"] .. " - " .. FACTION_HORDE }
                    end
        
                    if self.faction == "Alliance" or db.activate.EnemyFaction then
                      nodes[1415][47765166] = { mnID = 1455, showOnContinent = true, showInZone = false, showOnMinimap = false, name = "", type = "AIcon" , TransportName = L["Ironforge"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. DUNGEON_FLOOR_DEEPRUNTRAM1 .. "\n" .. " => " .. L["Stormwind"] } -- Transport to Ironforge Carriage 
                      nodes[1415][42966902] = { mnID = 1453, showOnContinent = true, showInZone = false, showOnMinimap = false, name = "", type = "AIcon" , TransportName = L["Stormwind"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. DUNGEON_FLOOR_DEEPRUNTRAM1 .. "\n" .. " => " .. L["Ironforge"] .. "\n" .. "\n" .. CALENDAR_TYPE_DUNGEON .. "\n" .. " => " .. DUNGEON_FLOOR_THESTOCKADE1 }
                    end

                end

            -- Dungeons and not Blizz for Stockade

                if self.db.profile.showContinentDungeons and not self.db.profile.activate.RemoveBlizzPOIs then
                
                    if self.db.profile.showContinentDungeons then
                        nodes[1415][42966902] = { mnID = 1453, showOnContinent = true, showInZone = false, showOnMinimap = false, name = DUNGEON_FLOOR_THESTOCKADE1 .. " " .. "[" .. LEVEL .. ": " .. "22-30]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "15", type = "Dungeon" }
                    end
                end


            -- Zeppelin
                if self.db.profile.showContinentZeppelins then   

                    if self.faction == "Horde" or db.activate.EnemyFaction then

                        nodes[1415][43572229] = { mnID = 1420, showOnContinent = true, showInZone = false, showOnMinimap = false, name = "", type = "HZeppelin" , TransportName = L["Tirisfal Glades"] .. " " .. L["Zeppelin"] .. "\n" .. " => " .. L["Grom'gol, Stranglethorn Vale"] .. "\n" .. " => " .. L["Durotar"] }
                        nodes[1415][44818417] = { mnID = 1434, showOnContinent = true, showInZone = false, showOnMinimap = false, name = "", type = "HZeppelin" , TransportName = L["Grom'gol, Stranglethorn Vale"] .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Zeppelin"] .. "\n" .. " => " .. DUNGEON_FLOOR_ORGRIMMAR0.. "\n" .. " => " .. L["Tirisfal Glades"] .. " - " .. L["Undercity"] }
                    
                    end

                end


            -- Continent Eastern Kingdom Transport and not RemoveBlizzPOIs
                if self.db.profile.showContinentTransport and not self.db.profile.activate.RemoveBlizzPOIs then

                    if self.faction == "Alliance" or db.activate.EnemyFaction then

                        nodes[1415][47765351] = { mnID = 1455, showOnContinent = true, showInZone = false, showOnMinimap = false, name = "", type = "Carriage" , TransportName = L["Ironforge"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. DUNGEON_FLOOR_DEEPRUNTRAM1 .. "\n" .. " => " .. L["Stormwind"] } -- Transport to Ironforge Carriage 
                        nodes[1415][45187037] = { mnID = 1429, showOnContinent = true, showInZone = false, showOnMinimap = false, name = "", type = "Carriage" , TransportName = L["Stormwind"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. DUNGEON_FLOOR_DEEPRUNTRAM1 .. "\n" .. " => " .. L["Ironforge"] } -- Transport to Ironforge Carriage 

                    end

                end


            -- Ships
                if self.db.profile.showContinentShips then

                    nodes[1415][41979266] = { mnID = 1434, showOnContinent = true, showInZone = false, showOnMinimap = false, name = "", type = "Ship" , TransportName = POSTMASTER_LETTER_STRANGLETHORNVALE .. " - " .. FACTION_NEUTRAL .. "\n" .. "\n" .. L["Ship"] .. "\n" .. " => " .. L["Ratchet"] } -- Ship from Booty Bay to Ratchet
                    
                    if self.faction == "Alliance" or db.activate.EnemyFaction then
                        nodes[1415][47644723] = { mnID = 1437, showOnContinent = true, showInZone = false, showOnMinimap = false, name = "", type = "AShip" , TransportName = POSTMASTER_LETTER_WETLANDS .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Ships"] .. "\n" .. " => " .. L["Theramore Isle"] .. "\n" .. " => " .. L["Auberdine"] } -- Ship from Menethil Harbor to Howling Fjord and Dustwallow Marsh
                    end

                end


            -- Flight Point
                if self.db.profile.showContinentFP then

                    if self.faction == "Horde" or db.activate.EnemyFaction then
                        nodes[1415][44942457] = { mnID = 1458, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH"  } -- Undercity
                        nodes[1415][60412152] = { mnID = 1423, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH"  } -- Eastern Plaquelands
                        nodes[1415][41052961] = { mnID = 1421, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH"  } -- Silverwood
                        nodes[1415][58733425] = { mnID = 1425, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH"  } -- Hinterlands
                        nodes[1415][55373558] = { mnID = 1417, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH"  } -- Arathi Highlands
                        nodes[1415][47853133] = { mnID = 1424, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH"  } -- Hillsb
                        nodes[1415][48215945] = { mnID = 1427, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH"  } -- Sengende Schlucht
                        nodes[1415][51665985] = { mnID = 1418, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH"  } -- Badlands
                        nodes[1415][51666356] = { mnID = 1428, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH"  } -- Burning Stepps
                        nodes[1415][54757616] = { mnID = 1435, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH"  } -- Swamp of 
                        nodes[1415][45038451] = { mnID = 1434, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH"  } -- Stranglethorn Vale
                        nodes[1415][43969300] = { mnID = 1434, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH"  } -- Stranglethorn Vale
                    end

                    if self.faction == "Alliance" or db.activate.EnemyFaction then
                        --nodes[1415][47475262] = { mnID = 1455, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA"  } -- Ironfrge
                        --nodes[1415][43336816] = { mnID = 1453, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA"  } -- Stormwind
                        nodes[1415][49472771] = { mnID = 1422, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA"  } -- W-Plaquelands
                        nodes[1415][60582201] = { mnID = 1423, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA"  } -- Eastern Plaquelands
                        nodes[1415][51123044] = { mnID = 1425, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA"  } -- Hinterlands
                        nodes[1415][52573700] = { mnID = 1417, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA"  } -- Arathi Highlands
                        nodes[1415][46873477] = { mnID = 1424, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA"  } -- Hillsb
                        nodes[1415][47654791] = { mnID = 1437, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA"  } -- Wetlands
                        nodes[1415][53795482] = { mnID = 1432, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA"  } -- Loch Modan
                        nodes[1415][48875966] = { mnID = 1427, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA"  } -- Sengende Schlucht
                        nodes[1415][53216728] = { mnID = 1428, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA"  } -- Burning Stepps
                        nodes[1415][51817193] = { mnID = 1433, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA"  } -- Redridge Mountains
                        nodes[1415][48937642] = { mnID = 1431, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA"  } -- Dämmerwood
                        nodes[1415][42477682] = { mnID = 1436, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA"  } -- Westfall
                        nodes[1415][55217894] = { mnID = 1419, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA"  } -- Blasted Lands
                        nodes[1415][44079353] = { mnID = 1434, showOnContinent = true, showInZone = false, showOnMinimap = false, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA"  } -- Stranglethorn Vale
                    end

                end

            end
        end
    end
end