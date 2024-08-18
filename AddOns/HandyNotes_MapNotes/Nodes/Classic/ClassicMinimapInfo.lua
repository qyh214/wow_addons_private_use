local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

function ns.LoadClassicMiniMapInfo(self)
local db = ns.Addon.db.profile
local minimap = ns.minimap

    --#####################################################################################################
    --##########################        function to hide all minimap below         ##########################
    --#####################################################################################################
    if not db.activate.HideMapNote then


        --##################################################################################################
        --####################################         MiniMap         ###################################
        --##################################################################################################
		if db.activate.MiniMap then
            
            
            --###################
            --##### Kalimdor ####
            --###################
            
			if self.db.profile.showMiniMapKalimdor then


            -- Raids

                if self.db.profile.showMiniMapRaids then

                    minimap[1451][25239137] = { mnID = 1451, name = L["Temple of Ahn'Qiraj"] .. " " .. "[" .. LEVEL .. ": " .. "60+]", type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true }
    				minimap[1451][29049322] = { mnID = 1451, name = DUNGEON_FLOOR_RUINSOFAHNQIRAJ1 .. " " .. "[" .. LEVEL .. ": " .. "60+]", type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true }
    			    minimap[1445][52877752] = { mnID = 1445, name = DUNGEON_FLOOR_ONYXIASLAIR1 .. " " .. "[" .. LEVEL .. ": " .. "60+]", type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true }

                end


            -- Dungeons

                if self.db.profile.showMiniMapDungeons then
                    minimap[1440][13961306] = { mnID = 1440, name = L["Blackfathom Deeps"] .. " " .. "[" .. LEVEL .. ": " .. "24-32]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "15", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
    			    minimap[1444][59034298] = { mnID = 1444, name = L["Dire Maul"] .. " " .. "[" .. LEVEL .. ": " .. "55-60]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "45", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[1444][76883670] = { mnID = 1444, name = L["Dire Maul"] .. " " .. "[" .. LEVEL .. ": " .. "55-60]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "45", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[1443][28986219] = { mnID = 1443, name = DUNGEON_FLOOR_MARAUDON1 .. " " .. "[" .. LEVEL .. ": " .. "46-55]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "30", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
    			    minimap[1413][49189322] = { mnID = 1413, name = DUNGEON_FLOOR_RAZORFENDOWNS1 .. " " .. "[" .. LEVEL .. ": " .. "37-46]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "35", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[1413][41798934] = { mnID = 1413, name = DUNGEON_FLOOR_RAZORFENKRAUL1 .. " " .. "[" .. LEVEL .. ": " .. "29-38]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "25", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
    			    minimap[1413][45973633] = { mnID = 1413, name = DUNGEON_FLOOR_WAILINGCAVERNS1 .. " " .. "[" .. LEVEL .. ": " .. "17-24]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "10", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[1446][38712008] = { mnID = 1446, name = DUNGEON_FLOOR_ZULFARRAK .. " " .. "[" .. LEVEL .. ": " .. "42-56", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "35", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end


            -- Blizz Pois

                if self.db.profile.activate.RemoveBlizzPOIs then

                    if self.faction == "Alliance" or db.activate.EnemyFaction then
                    
                        minimap[1438][27385702] = { mnID = 1457, name = "", type = "AIcon", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Darnassus"] .. " - " .. FACTION_ALLIANCE }
                    
                    end

                    if self.faction == "Horde" or db.activate.EnemyFaction then
                        minimap[1411][45600899] = { mnID = 1454, name = "", type = "HIcon", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = DUNGEON_FLOOR_ORGRIMMAR0 .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. CALENDAR_TYPE_DUNGEON .. "\n" .. " => " .. DUNGEON_FLOOR_RAGEFIRE1 } 
                    end

                end


            -- Zeppelin
                if self.db.profile.showMiniMapZeppelins then   

                    if self.faction == "Horde" or db.activate.EnemyFaction then
                        minimap[1411][50281195] = { mnID = 1434, name = "", type = "HZeppelin", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Zeppelin"] .. " - " .. FACTION_HORDE .. "\n" .. " => " .. L["Grom'gol, Stranglethorn Vale"] }
                        minimap[1411][50771406] = { mnID = 1420, name = "", type = "HZeppelin", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Zeppelin"] .. " - " .. FACTION_HORDE .. "\n" .. " => " .. L["Tirisfal Glades"] .. " - " .. L["Undercity"] }

                    end
                    
                end


            -- Ships
                if self.db.profile.showMiniMapShips then

                    minimap[1413][63803771] = { mnID = 1434, name = "", type = "Ship", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Ratchet"] .. " - " .. FACTION_NEUTRAL .. "\n" .. "\n" .. L["Ship"] .. "\n" .. " => " .. POSTMASTER_LETTER_STRANGLETHORNVALE } -- Ship from Booty Bay to Ratchet
                

                    if self.faction == "Alliance" or db.activate.EnemyFaction then
                        minimap[1439][33273982] = { mnID = 1438, name = "", type = "AShip", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Auberdine"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Ship"] .. "\n" .. " => " .. L["Teldrassil"] } -- 
                        minimap[1439][32294340] = { mnID = 1437, name = "", type = "AShip", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Auberdine"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Ship"] .. "\n" .. " => " .. POSTMASTER_LETTER_WETLANDS } -- 
                        minimap[1438][55039414] = { mnID = 1439, name = "", type = "AShip", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Teldrassil"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Ship"] .. "\n" .. " => " .. L["Auberdine"] } -- Ship from Booty Bay to Ratchet
                        minimap[1445][71835683] = { mnID = 1437, name = "", type = "AShip", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Theramore Isle"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Ship"] .. "\n" .. " => " .. POSTMASTER_LETTER_WETLANDS } -- Ship from Dustwallow Marsh to Menethil Harbor

                    end

                end

            end


            --##########################
            --##### Eastern Kingdom ####
            --##########################

            if self.db.profile.showMiniMapEasternKingdom then


            -- Raids            

                if self.db.profile.showMiniMapRaids then

				    minimap[1427][34958438] = { mnID = 1428, name = DUNGEON_FLOOR_MOLTENCORE1 .. " " .. "[" .. LEVEL .. ": " .. "60+]", type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true }
				    minimap[1428][29383823] = { mnID = 1428, name = DUNGEON_FLOOR_MOLTENCORE1 .. " " .. "[" .. LEVEL .. ": " .. "60+]", type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[1434][53731730] = { mnID = 1434, name = DUNGEON_FLOOR_ZULGURUB1 .. " " .. "[" .. LEVEL .. ": " .. "60+]", type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[1423][38962562] = { mnID = 1423, name = L["Naxxramas"] .. " " .. "[" .. LEVEL .. ": " .. "60+]", type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true }


                end


            -- Dungeons

                if self.db.profile.showMiniMapDungeons then
                    minimap[1421][44746773] = { mnID = 1421, name = L["Shadowfang Keep"] .. " " .. "[" .. LEVEL .. ": " .. "22-30]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "14", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
				    minimap[1422][68887290] = { mnID = 1422, name = L["Scholomance"] .. " " .. "[" .. LEVEL .. ": " .. "58-60]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "48", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
				    minimap[1420][82603359] = { mnID = 1420, name = DUNGEON_FLOOR_TIRISFAL13 .. " " .. "[" .. LEVEL .. ": " .. "22-30]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "21", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
				    minimap[1423][31231582] = { mnID = 1423, name = DUNGEON_FLOOR_COTSTRATHOLME1 .. " " .. "[" .. LEVEL .. ": " .. "58-60]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "48", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[1423][47942391] = { mnID = 1423, name = DUNGEON_FLOOR_COTSTRATHOLME1 .. " " .. "[" .. LEVEL .. ": " .. "58-60]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "48", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[1435][69195221] = { mnID = 1435, name = DUNGEON_FLOOR_THETEMPLEOFATALHAKKAR1 .. " " .. "[" .. LEVEL .. ": " .. "50-56]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "45", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
				    minimap[1418][44441195] = { mnID = 1418, name = DUNGEON_FLOOR_BADLANDS18 .. " " .. "[" .. LEVEL .. ": " .. "41-51]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "30", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
				    minimap[1418][64884316] = { mnID = 1418, name = DUNGEON_FLOOR_BADLANDS18 .. " " .. "[" .. LEVEL .. ": " .. "41-51]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "30", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[1426][24243984] = { mnID = 1426, name = DUNGEON_FLOOR_DUNMOROGH10 .. " " .. "[" .. LEVEL .. ": " .. "29-38]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "19", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[1436][42407161] = { mnID = 1436, name = DUNGEON_FLOOR_THEDEADMINES1 .. " " .. "[" .. LEVEL .. ": " .. "17-26]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "10", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMiniMapMultiple then
				    minimap[1427][34958438] = { mnID = 1427, name = "", dnID = DUNGEON_FLOOR_MOLTENCORE1 .. " " .. "[" .. LEVEL .. ": " .. "60+]" .. "\n" .. DUNGEON_FLOOR_BURNINGSTEPPES15 .. " " .. "[" .. LEVEL .. ": " .. "60+]" .. "\n" .. DUNGEON_FLOOR_BURNINGSTEPPES14 .. " " .. "[" .. LEVEL .. ": " .. "55-60]" .. "\n" .. DUNGEON_FLOOR_BURNINGSTEPPES16 .. " " .. "[" .. LEVEL .. ": " .. "52-60]", type = "MultipleM", showInZone = false, showOnContinent = false, showOnMinimap = true }
				    minimap[1428][29383823] = { mnID = 1428, name = "", dnID = DUNGEON_FLOOR_MOLTENCORE1 .. " " .. "[" .. LEVEL .. ": " .. "60+]" .. "\n" .. DUNGEON_FLOOR_BURNINGSTEPPES15 .. " " .. "[" .. LEVEL .. ": " .. "60+]" .. "\n" .. DUNGEON_FLOOR_BURNINGSTEPPES14 .. " " .. "[" .. LEVEL .. ": " .. "55-60]" .. "\n" .. DUNGEON_FLOOR_BURNINGSTEPPES16 .. " " .. "[" .. LEVEL .. ": " .. "52-60]", type = "MultipleM", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end


            -- Blizz POIS

                if self.db.profile.activate.RemoveBlizzPOIs then

                    if self.faction == "Horde" or db.activate.EnemyFaction then
                      minimap[1420][61806939] = { mnID = 1458, name = "", type = "HIcon", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Undercity"] .. " - " .. FACTION_HORDE }
                    end
        
                    if self.faction == "Alliance" or db.activate.EnemyFaction then
                      minimap[1426][54353411] = { mnID = 1455, name = "", type = "AIcon", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Ironforge"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. DUNGEON_FLOOR_DEEPRUNTRAM1 .. "\n" .. " => " .. L["Stormwind"] } -- Transport to Ironforge Carriage 
                      minimap[1429][24793263] = { mnID = 1453, name = "", type = "AIcon", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Stormwind"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. DUNGEON_FLOOR_DEEPRUNTRAM1 .. "\n" .. " => " .. L["Ironforge"] .. "\n" .. "\n" .. CALENDAR_TYPE_DUNGEON .. "\n" .. " => " .. DUNGEON_FLOOR_THESTOCKADE1 }
                    end

                end

            -- Dungeons and not Blizz for Stockade

                if self.db.profile.showMiniMapDungeons and not self.db.profile.activate.RemoveBlizzPOIs then
                
                    if self.db.profile.showMiniMapDungeons then
                        minimap[1429][24793263] = { mnID = 1453, name = DUNGEON_FLOOR_THESTOCKADE1 .. " " .. "[" .. LEVEL .. ": " .. "22-30]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "15", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end
                end


            -- Zeppelin
                if self.db.profile.showMiniMapZeppelins then   

                    if self.faction == "Horde" or db.activate.EnemyFaction then

                        minimap[1420][60565871] = { mnID = 1411, name = "", type = "HZeppelin", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Tirisfal Glades"] .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Zeppelin"] .. "\n" .. " => " .. L["Durotar"] }
                        minimap[1420][62025913] = { mnID = 1415, name = "", type = "HZeppelin", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Tirisfal Glades"] .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Zeppelin"] .. "\n" .. " => " .. L["Grom'gol, Stranglethorn Vale"]}
                        minimap[1434][31552891] = { mnID = 1420, name = "", type = "HZeppelin", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Grom'gol, Stranglethorn Vale"] .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Zeppelin"] .. "\n" .. " => " .. L["Tirisfal Glades"] .. " - " .. L["Undercity"] }
                        minimap[1434][31223030] = { mnID = 1411, name = "", type = "HZeppelin", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Grom'gol, Stranglethorn Vale"] .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Zeppelin"] .. "\n" .. " => " .. DUNGEON_FLOOR_ORGRIMMAR0 }

                    end

                end

            -- Ships
                if self.db.profile.showMiniMapShips then

                    minimap[1434][25677301] = { mnID = 1413, name = "", type = "Ship", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = POSTMASTER_LETTER_STRANGLETHORNVALE .. " - " .. FACTION_NEUTRAL .. "\n" .. "\n" .. L["Ship"] .. "\n" .. " => " .. L["Ratchet"] } -- Ship from Booty Bay to Ratchet
                    
                    if self.faction == "Alliance" or db.activate.EnemyFaction then
                        minimap[1437][04896329] = { mnID = 1445, name = "", type = "AShip", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = POSTMASTER_LETTER_WETLANDS .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Ship"] .. "\n" .. " => " .. L["Theramore Isle"] } -- Ship from Menethil Harbor to Howling Fjord and Dustwallow Marsh
                        minimap[1437][04455693] = { mnID = 1445, name = "", type = "AShip", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = POSTMASTER_LETTER_WETLANDS .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Ship"] .. "\n" .. " => " .. L["Auberdine"] } -- Ship from Menethil Harbor to Howling Fjord and Dustwallow Marsh

                    end

                end

            end
        end
    end
end