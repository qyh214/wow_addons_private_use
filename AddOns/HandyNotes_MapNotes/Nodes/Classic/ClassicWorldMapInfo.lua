local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

function ns.LoadClassicWorldMapInfo(self)
local db = ns.Addon.db.profile
local nodes = ns.nodes

    --#####################################################################################################
    --##########################        function to hide all nodes below         ##########################
    --#####################################################################################################
    if not db.activate.HideMapNote then

        --##################################################################################################
        --####################################         WorldMap         ####################################
        --##################################################################################################
        if db.activate.Azeroth then
            
            
            --###################
            --##### Kalimdor ####
            --###################
            
            if self.db.profile.showAzerothKalimdor then


            -- Raids

                if self.db.profile.showAzerothRaids then

                    nodes[947][14397641] = { mnID = 1451, name = L["Temple of Ahn'Qiraj"] .. " " .. "[" .. LEVEL .. ": " .. "60+]", type = "Raid", showInZone = true}
    				nodes[947][16247789] = { mnID = 1451, name = DUNGEON_FLOOR_RUINSOFAHNQIRAJ1 .. " " .. "[" .. LEVEL .. ": " .. "60+]", type = "Raid", showInZone = true}
    			    nodes[947][27816514] = { mnID = 1445, name = DUNGEON_FLOOR_ONYXIASLAIR1 .. " " .. "[" .. LEVEL .. ": " .. "60+]", type = "Raid", showInZone = true}

                end


            -- Dungeons

                if self.db.profile.showAzerothDungeons then

                    nodes[947][17723485] = { mnID = 1440, name = L["Blackfathom Deeps"] .. " " .. "[" .. LEVEL .. ": " .. "24-32]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "15", type = "Dungeon", showInZone = true}
    			    nodes[947][16486163] = { mnID = 1444, name = L["Dire Maul"] .. " " .. "[" .. LEVEL .. ": " .. "55-60]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "45", type = "Dungeon", showInZone = true}
                    nodes[947][19136348] = { mnID = 1444, name = L["Dire Maul"] .. " " .. "[" .. LEVEL .. ": " .. "55-60]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "45", type = "Dungeon", showInZone = true}
                    nodes[947][12795369] = { mnID = 1443, name = DUNGEON_FLOOR_MARAUDON1 .. " " .. "[" .. LEVEL .. ": " .. "46-55]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "30", type = "Dungeon", showInZone = true}
    			    nodes[947][25106496] = { mnID = 1413, name = DUNGEON_FLOOR_RAZORFENDOWNS1 .. " " .. "[" .. LEVEL .. ": " .. "37-46]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "35", type = "Dungeon", showInZone = true}
                    nodes[947][22276256] = { mnID = 1413, name = DUNGEON_FLOOR_RAZORFENKRAUL1 .. " " .. "[" .. LEVEL .. ": " .. "29-38]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "25", type = "Dungeon", showInZone = true}
    			    nodes[947][24245147] = { mnID = 1413, name = DUNGEON_FLOOR_WAILINGCAVERNS1 .. " " .. "[" .. LEVEL .. ": " .. "17-24]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "10", type = "Dungeon", showInZone = true}
                    nodes[947][25787179] = { mnID = 1446, name = DUNGEON_FLOOR_ZULFARRAK .. " " .. "[" .. LEVEL .. ": " .. "42-56", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "35", type = "Dungeon", showInZone = true}
    			    --nodes[947][28804279] = { mnID = 1454, name = DUNGEON_FLOOR_RAGEFIRE1 .. " " .. "[" .. LEVEL .. ": " .. "13-18]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "8", type = "Dungeon", showInZone = true}
    			    
                end


            -- Blizz Pois

                if self.db.profile.activate.RemoveBlizzPOIs then

                    if self.faction == "Alliance" or db.activate.EnemyFaction then
                    
                        nodes[947][14331638] = { mnID = 1457, name = "", type = "AIcon", showInZone = true, TransportName = L["Darnassus"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " => " .. L["Rut'theran"] }
                        nodes[947][17442006] = { mnID = 1457, name = "", type = "AIcon", showInZone = true, TransportName = L["Rut'theran"] .. " - " .. FACTION_ALLIANCE  .. "\n" .. "\n" .. L["Ship"] .. "\n" .. " => " .. L["Auberdine"] .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " => " .. L["Teldrassil"] .."\n" .. "\n" .. MINIMAP_TRACKING_FLIGHTMASTER}

                    end

                    if self.faction == "Horde" or db.activate.EnemyFaction then
                        nodes[947][29604279] = { mnID = 1454, name = "", type = "HIcon", showInZone = true, TransportName = DUNGEON_FLOOR_ORGRIMMAR0 .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. CALENDAR_TYPE_DUNGEON .. "\n" .. " => " .. DUNGEON_FLOOR_RAGEFIRE1 .. "\n" .. "\n" .. MINIMAP_TRACKING_FLIGHTMASTER } 
                        nodes[947][20065406] = { mnID = 1456, name = "", type = "HIcon", showInZone = true, TransportName = L["Thunder Bluff"] .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. MINIMAP_TRACKING_FLIGHTMASTER } 
                    end

                end


            -- Dungeons and not Blizz for Ragefire

                if self.db.profile.showAzerothDungeons and not self.db.profile.activate.RemoveBlizzPOIs then
                
                    if self.db.profile.showAzerothDungeons then
                        nodes[947][28804279] = { mnID = 1454, name = DUNGEON_FLOOR_RAGEFIRE1 .. " " .. "[" .. LEVEL .. ": " .. "13-18]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "8", type = "Dungeon", showInZone = true}
                    end
                end

            -- Zeppelin
                if self.db.profile.showAzerothZeppelins then   

                    if self.faction == "Horde" or db.activate.EnemyFaction then
                        nodes[947][30094538] = { mnID = 1411, name = "", type = "HZeppelin", showInZone = true, TransportName = L["Durotar"] .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Zeppelin"] .. "\n" .. " => " .. L["Grom'gol, Stranglethorn Vale"] .. "\n" .. " => " .. L["Tirisfal Glades"] .. " - " .. L["Undercity"] }
                    end
                    
                end


            -- Ships
                if self.db.profile.showAzerothShips then

                    nodes[947][28065406] = { mnID = 1413, name = "", type = "Ship", showInZone = true, TransportName = L["Ratchet"] .. " - " .. FACTION_NEUTRAL .. "\n" .. "\n" .. L["Ship"] .. "\n" .. " => " .. POSTMASTER_LETTER_STRANGLETHORNVALE } -- Ship from Booty Bay to Ratchet
                

                    if self.faction == "Alliance" or db.activate.EnemyFaction then

                        nodes[947][18332672] = { mnID = 1439, name = "", type = "AShip", showInZone = true, TransportName = L["Auberdine"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Ship"] .. "\n" .. " => " .. L["Teldrassil"] .. "\n" .. " => " .. POSTMASTER_LETTER_WETLANDS } -- Ship from Booty Bay to Ratchet
                        nodes[947][29986142] = { mnID = 1445, name = "", type = "AShip", showInZone = true, TransportName = L["Theramore Isle"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Ship"] .. "\n" .. " => " .. POSTMASTER_LETTER_WETLANDS } -- Ship from Dustwallow Marsh to Menethil Harbor

                    end

                end


            -- Ships and not Blizz POIS
                if self.db.profile.showAzerothShips and not self.db.profile.activate.RemoveBlizzPOIs then

                
                    if self.faction == "Alliance" or db.activate.EnemyFaction then

                        nodes[947][17161989] = { mnID = 1438, name = "", type = "AShip", showInZone = true, TransportName = L["Teldrassil"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Ship"] .. "\n" .. " => " .. L["Auberdine"] } -- Ship from Booty Bay to Ratchet

                    end

                end


            -- Flight Point
                if self.db.profile.showAzerothFP then
                    nodes[947][17637112] = { mnID = 1451, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "Travel", showInZone = true } -- Silithus
                    nodes[947][27447284] = { mnID = 1446, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "Travel", showInZone = true } -- Tanaris
                    nodes[947][30012630] = { mnID = 1452, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "Travel", showInZone = true } -- Winterspring
                    nodes[947][24352417] = { mnID = 1450, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "Travel", showInZone = true } -- Moonglade
                    nodes[947][21796953] = { mnID = 1449, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = true } -- Un'Goro

                    if self.faction == "Horde" or db.activate.EnemyFaction then
                        nodes[947][20183226] = { mnID = 1448, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = true } -- Felwood
                        nodes[947][24964141] = { mnID = 1440, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = true } -- Ashenvale
                        nodes[947][17183788] = { mnID = 1440, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = true } -- Ashenvale
                        nodes[947][29113690] = { mnID = 1447, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = true } -- Azshara
                        nodes[947][17094552] = { mnID = 1442, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = true } -- Stonetalon Mountains
                        nodes[947][24874141] = { mnID = 1413, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = true } -- Barrens
                        nodes[947][23455666] = { mnID = 1413, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = true } -- Barrens
                        nodes[947][12055494] = { mnID = 1443, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = true } -- Desolace
                        nodes[947][18596369] = { mnID = 1444, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = true } -- Feralas
                        nodes[947][25755932] = { mnID = 1445, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = true } -- Dustwood
                        nodes[947][24696714] = { mnID = 1441, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = true } -- Thousend Needles
                    end

                    if self.faction == "Alliance" or db.activate.EnemyFaction then
                        nodes[947][17972789] = { mnID = 1439, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = true } -- Auberdine
                        nodes[947][23722828] = { mnID = 1448, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = true } -- Felwood
                        nodes[947][20013956] = { mnID = 1440, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = true } -- Ashenvale
                        nodes[947][27963982] = { mnID = 1447, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = true } -- Azshara
                        nodes[947][16034009] = { mnID = 1442, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = true } -- Stonetalon Mountains
                        nodes[947][16474844] = { mnID = 1443, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = true } -- Desolace
                        nodes[947][11886356] = { mnID = 1444, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = true } -- Feralas
                        nodes[947][21086422] = { mnID = 1444, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = true } -- Feralas
                        nodes[947][29306197] = { mnID = 1445, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = true } -- Dustwood
                    end

                end

            end


            --##########################
            --##### Eastern Kingdom ####
            --##########################

            if self.db.profile.showAzerothEasternKingdom then


            -- Raids            

                if self.db.profile.showAzerothRaids then

				    nodes[947][75475831] = { mnID = 1428, name = DUNGEON_FLOOR_MOLTENCORE1 .. " " .. "[" .. LEVEL .. ": " .. "60+]", type = "Raid", showInZone = true}
                    nodes[947][75657290] = { mnID = 1434, name = DUNGEON_FLOOR_ZULGURUB1 .. " " .. "[" .. LEVEL .. ": " .. "60+]", type = "Raid", showInZone = true}
                    nodes[947][81192266] = { mnID = 1423, name = L["Naxxramas"] .. " " .. "[" .. LEVEL .. ": " .. "60+]", type = "Raid", showInZone = true}


                end


            -- Dungeons

                if self.db.profile.showAzerothDungeons then

                    nodes[947][69253374] = { mnID = 1421, name = L["Shadowfang Keep"] .. " " .. "[" .. LEVEL .. ": " .. "22-30]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "14", type = "Dungeon", showInZone = true}
				    nodes[947][78612876] = { mnID = 1422, name = L["Scholomance"] .. " " .. "[" .. LEVEL .. ": " .. "58-60]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "48", type = "Dungeon", showInZone = true}
				    nodes[947][74912322] = { mnID = 1420, name = DUNGEON_FLOOR_TIRISFAL13 .. " " .. "[" .. LEVEL .. ": " .. "22-30]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "21", type = "Dungeon", showInZone = true}
				    nodes[947][80332100] = { mnID = 1423, name = DUNGEON_FLOOR_COTSTRATHOLME1 .. " " .. "[" .. LEVEL .. ": " .. "58-60]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "48", type = "Dungeon", showInZone = true}
				    nodes[947][81876699] = { mnID = 1435, name = DUNGEON_FLOOR_THETEMPLEOFATALHAKKAR1 .. " " .. "[" .. LEVEL .. ": " .. "50-56]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "45", type = "Dungeon", showInZone = true}
				    nodes[947][81385517] = { mnID = 1418, name = DUNGEON_FLOOR_BADLANDS18 .. " " .. "[" .. LEVEL .. ": " .. "41-51]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "30", type = "Dungeon", showInZone = true}
				    nodes[947][79415295] = { mnID = 1418, name = DUNGEON_FLOOR_BADLANDS18 .. " " .. "[" .. LEVEL .. ": " .. "41-51]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "30", type = "Dungeon", showInZone = true}
                    nodes[947][71034907] = { mnID = 1426, name = DUNGEON_FLOOR_DUNMOROGH10 .. " " .. "[" .. LEVEL .. ": " .. "29-38]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "19", type = "Dungeon", showInZone = true}
                    nodes[947][69626995] = { mnID = 1436, name = DUNGEON_FLOOR_THEDEADMINES1 .. " " .. "[" .. LEVEL .. ": " .. "17-26]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "10", type = "Dungeon", showInZone = true}
                    --nodes[947][71036219] = { mnID = 1453, name = DUNGEON_FLOOR_THESTOCKADE1 .. " " .. "[" .. LEVEL .. ": " .. "22-30]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "15", type = "Dungeon", showInZone = true}

                end

                if self.db.profile.showAzerothMultiple then

				    nodes[947][75475831] = { mnID = 1428, name = "", dnID = DUNGEON_FLOOR_MOLTENCORE1 .. " " .. "[" .. LEVEL .. ": " .. "60+]" .. "\n" .. DUNGEON_FLOOR_BURNINGSTEPPES15 .. " " .. "[" .. LEVEL .. ": " .. "60+]" .. "\n" .. DUNGEON_FLOOR_BURNINGSTEPPES14 .. " " .. "[" .. LEVEL .. ": " .. "55-60]" .. "\n" .. DUNGEON_FLOOR_BURNINGSTEPPES16 .. " " .. "[" .. LEVEL .. ": " .. "52-60]", type = "MultipleM", showInZone = true}

                end


            -- Blizz POIS

                if self.db.profile.activate.RemoveBlizzPOIs then

                    if self.faction == "Horde" or db.activate.EnemyFaction then
                      nodes[947][72142839] = { mnID = 1458, name = "", type = "HIcon", showInZone = true, TransportName = L["Undercity"] .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. MINIMAP_TRACKING_FLIGHTMASTER }
                      nodes[947][72577419] = { mnID = 1434, name = "", type = "HIcon", showInZone = true, TransportName = L["Grom'gol, Stranglethorn Vale"] .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Zeppelin"] .. "\n" .. " => " .. DUNGEON_FLOOR_ORGRIMMAR0 .. "\n" .. " => " .. L["Tirisfal Glades"] .. " - " .. L["Undercity"] .. "\n" .. "\n" .. MINIMAP_TRACKING_FLIGHTMASTER }
                    end
        
                    if self.faction == "Alliance" or db.activate.EnemyFaction then
                      nodes[947][74665055] = { mnID = 1455, name = "", type = "AIcon", showInZone = true, TransportName = L["Ironforge"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. DUNGEON_FLOOR_DEEPRUNTRAM1 .. "\n" .. " => " .. L["Stormwind"] .. "\n" .. "\n" .. MINIMAP_TRACKING_FLIGHTMASTER } -- Transport to Ironforge Carriage 
                      nodes[947][71096219] = { mnID = 1453, name = "", type = "AIcon", showInZone = true, TransportName = L["Stormwind"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. DUNGEON_FLOOR_DEEPRUNTRAM1 .. "\n" .. " => " .. L["Ironforge"] .. "\n" .. "\n" .. CALENDAR_TYPE_DUNGEON .. "\n" .. " => " .. DUNGEON_FLOOR_THESTOCKADE1 .. "\n" .. "\n" .. MINIMAP_TRACKING_FLIGHTMASTER }
                      nodes[947][74544501] = { mnID = 1437, name = "", type = "AIcon", showInZone = true, TransportName = POSTMASTER_LETTER_WETLANDS .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Ships"] .. "\n" .. " => " .. L["Theramore Isle"] .. "\n" .. " => " .. L["Auberdine"] .. "\n" .. "\n" .. MINIMAP_TRACKING_FLIGHTMASTER } -- Ship from Menethil Harbor to Howling Fjord and Dustwallow Marsh

                    end

                end

            -- Dungeons and not Blizz for Stockade

                if self.db.profile.showAzerothDungeons and not self.db.profile.activate.RemoveBlizzPOIs then
                
                    if self.db.profile.showAzerothDungeons then
                        nodes[947][71036219] = { mnID = 1453, name = DUNGEON_FLOOR_THESTOCKADE1 .. " " .. "[" .. LEVEL .. ": " .. "22-30]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "15", type = "Dungeon", showInZone = true}
                    end
                end


            -- Zeppelin
                if self.db.profile.showAzerothZeppelins then   

                    if self.faction == "Horde" or db.activate.EnemyFaction then

                        nodes[947][72452562] = { mnID = 1420, name = "", type = "HZeppelin", showInZone = true, TransportName = L["Tirisfal Glades"] .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Zeppelin"] .. "\n" .. " => " .. L["Grom'gol, Stranglethorn Vale"] .. "\n" .. " => " .. L["Durotar"] }
                    
                    end

                end


            -- Zeppelin
                if self.db.profile.showAzerothZeppelins and not self.db.profile.activate.RemoveBlizzPOIs then

                    if self.faction == "Horde" or db.activate.EnemyFaction then

                        nodes[947][72577419] = { mnID = 1434, name = "", type = "HZeppelin", showInZone = true, TransportName = L["Grom'gol, Stranglethorn Vale"] .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Zeppelin"] .. "\n" .. " => " .. DUNGEON_FLOOR_ORGRIMMAR0 .. "\n" .. " => " .. L["Tirisfal Glades"] .. " - " .. L["Undercity"] }
                    
                    end

                end


            -- Azeroth Eastern Kingdom Transport and not RemoveBlizzPOIs
                if self.db.profile.showAzerothTransport and not self.db.profile.activate.RemoveBlizzPOIs then

                    if self.faction == "Alliance" or db.activate.EnemyFaction then

                        nodes[947][74615129] = { mnID = 1455, name = "", type = "Carriage", showInZone = true, TransportName = L["Ironforge"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. DUNGEON_FLOOR_DEEPRUNTRAM1 .. "\n" .. " => " .. L["Stormwind"] } -- Transport to Ironforge Carriage 
                        nodes[947][72086311] = { mnID = 1429, name = "", type = "Carriage", showInZone = true, TransportName = L["Stormwind"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. DUNGEON_FLOOR_DEEPRUNTRAM1 .. "\n" .. " => " .. L["Ironforge"] } -- Transport to Ironforge Carriage 

                    end

                end


            -- Ships
                if self.db.profile.showAzerothShips then

                    nodes[947][70358084] = { mnID = 1434, name = "", type = "Ship", showInZone = true, TransportName = POSTMASTER_LETTER_STRANGLETHORNVALE .. " - " .. FACTION_NEUTRAL .. "\n" .. "\n" .. L["Ship"] .. "\n" .. " => " .. L["Ratchet"] } -- Ship from Booty Bay to Ratchet
                    
                end


            -- Ships and not Blizz POIS
                if self.db.profile.showAzerothShips and not self.db.profile.activate.RemoveBlizzPOIs then
                   
                    if self.faction == "Alliance" or db.activate.EnemyFaction then
                        nodes[947][74544501] = { mnID = 1437, name = "", type = "AShip", showInZone = true, TransportName = POSTMASTER_LETTER_WETLANDS .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Ships"] .. "\n" .. " => " .. L["Theramore Isle"] .. "\n" .. " => " .. L["Auberdine"]} -- Ship from Menethil Harbor to Howling Fjord and Dustwallow Marsh
                    end

                end


            -- Flight Point
                if self.db.profile.showAzerothFP then
                    nodes[947][71738160] = { mnID = 1434, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE .. " / " .. FACTION_ALLIANCE, type = "Travel", showInZone = true } -- Stranglethorn Vale
                    nodes[947][75545507] = { mnID = 1427, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE .. " / " .. FACTION_ALLIANCE, type = "Travel", showInZone = true } -- Sengende Schlucht
                    nodes[947][84912523] = { mnID = 1423, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE .. " / " .. FACTION_ALLIANCE, type = "Travel", showInZone = true } -- Sengende Schlucht

                    if self.faction == "Horde" or db.activate.EnemyFaction then
                        nodes[947][69433120] = { mnID = 1421, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = true } -- Silverwood
                        nodes[947][83313492] = { mnID = 1425, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = true } -- Hinterlands
                        nodes[947][80573584] = { mnID = 1417, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = true } -- Arathi Highlands
                        nodes[947][74823253] = { mnID = 1424, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = true } -- Hillsb
                        nodes[947][77745507] = { mnID = 1418, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = true } -- Badlands
                        nodes[947][77745786] = { mnID = 1428, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = true } -- Burning Stepps
                        nodes[947][80306794] = { mnID = 1435, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = true } -- Swamp of 
                    end

                    if self.faction == "Alliance" or db.activate.EnemyFaction then
                        nodes[947][75982974] = { mnID = 1422, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = true } -- W-Plaquelands
                        nodes[947][77313187] = { mnID = 1425, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = true } -- Hinterlands
                        nodes[947][78553717] = { mnID = 1417, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = true } -- Arathi Highlands
                        nodes[947][74043531] = { mnID = 1424, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = true } -- Hillsb
                        nodes[947][79435096] = { mnID = 1432, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = true } -- Loch Modan
                        nodes[947][79066078] = { mnID = 1428, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = true } -- Burning Stepps
                        nodes[947][77916462] = { mnID = 1433, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = true } -- Redridge Mountains
                        nodes[947][75706833] = { mnID = 1431, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = true } -- Duskwood
                        nodes[947][70586833] = { mnID = 1436, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = true } -- Westfall
                        nodes[947][80577006] = { mnID = 1419, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = true } -- Blasted Lands
                    end

                end


            -- Flight Point and not Blizz POIS
                if self.db.profile.showAzerothFP and not self.db.profile.activate.RemoveBlizzPOIs then

                    if self.faction == "Horde" or db.activate.EnemyFaction then
                        nodes[947][72142839] = { mnID = 1458, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = true } -- Silverwood

                    end

                end

            end

        end
    end
end