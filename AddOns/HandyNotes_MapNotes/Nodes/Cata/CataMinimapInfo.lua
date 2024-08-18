local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

function ns.LoadCataMiniMapInfo(self)
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
                    minimap[198][47167809] = { mnID = 198, name = DUNGEON_FLOOR_FIRELANDS0 .. " " .. "[" .. LEVEL .. ": " .. "85]", type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Firelands
                    minimap[249][38258048] = { id = 74, name = "", dnID = "[" .. LEVEL .. ": " .. "85]", type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Throne of the Four Winds
                    minimap[1451][24228729] = { mnID = 1451, name = L["Temple of Ahn'Qiraj"] .. " " .. "[" .. LEVEL .. ": " .. "60+]", type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true }
    				minimap[1451][36489385] = { mnID = 1451, name = DUNGEON_FLOOR_RUINSOFAHNQIRAJ1 .. " " .. "[" .. LEVEL .. ": " .. "60+]", type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true }
    			    minimap[1445][52877752] = { mnID = 1445, name = DUNGEON_FLOOR_ONYXIASLAIR1 .. " " .. "[" .. LEVEL .. ": " .. "60+]", type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[327][46900756] = { mnID = 1451, name = L["Temple of Ahn'Qiraj"] .. " " .. "[" .. LEVEL .. ": " .. "60+]", type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[327][58761412] = { mnID = 1451, name = DUNGEON_FLOOR_RUINSOFAHNQIRAJ1 .. " " .. "[" .. LEVEL .. ": " .. "60+]", type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[1446][57055860] = { mnID = 1446, name = DUNGEON_FLOOR_DRAGONBLIGHTCHROMIESCENARIO4 .. " " .. "[" .. LEVEL .. ": " .. "85]", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[1446][61685175] = { mnID = 1446, name = "Dragonsoul" .. " " .. "[" .. LEVEL .. ": " .. "85]", type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[1446][59475228] = { mnID = 1446, name = DUNGEON_FLOOR_COTMOUNTHYJAL1 .. " " .. "[" .. LEVEL .. ": " .. "70]", type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

            -- Dungeons
                if self.db.profile.showMiniMapDungeons then
                    minimap[86][69844921] = { mnID = 86, name = DUNGEON_FLOOR_RAGEFIRE1 .. " " .. "[" .. LEVEL .. ": " .. "13-18]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "8", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[207][47465196] = { id = 67, name = "", dnID = "[" .. LEVEL .. ": " .. "81-85]", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stonecore
                    minimap[249][60536425] = { id = 69, name = "", dnID = "[" .. LEVEL .. ": " .. "84-85]", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Lost City of Tol'Vir
                    minimap[249][71515208] = { id = 70, name = "", dnID = "[" .. LEVEL .. ": " .. "84-85]", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Halls of Origination
                    minimap[249][76688430] = { id = 68, name = "", dnID = "[" .. LEVEL .. ": " .. "81-85]", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Vortex Pinnacle
                    minimap[1440][13961306] = { mnID = 1440, name = L["Blackfathom Deeps"] .. " " .. "[" .. LEVEL .. ": " .. "24-32]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "15", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
    			    minimap[1444][60133119] = { mnID = 1444, name = L["Dire Maul"] .. " " .. "[" .. LEVEL .. ": " .. "55-60]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "45", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[1444][76883670] = { mnID = 1444, name = L["Dire Maul"] .. " " .. "[" .. LEVEL .. ": " .. "55-60]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "45", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[1443][28986219] = { mnID = 1443, name = DUNGEON_FLOOR_MARAUDON1 .. " " .. "[" .. LEVEL .. ": " .. "46-55]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "30", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
    			    minimap[1441][41412940] = { mnID = 1413, name = DUNGEON_FLOOR_RAZORFENDOWNS1 .. " " .. "[" .. LEVEL .. ": " .. "37-46]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "35", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[199][40859457] = { mnID = 1413, name = DUNGEON_FLOOR_RAZORFENKRAUL1 .. " " .. "[" .. LEVEL .. ": " .. "29-38]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "25", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
    			    minimap[1413][45973633] = { mnID = 1413, name = DUNGEON_FLOOR_WAILINGCAVERNS1 .. " " .. "[" .. LEVEL .. ": " .. "17-24]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "10", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[1446][39121973] = { mnID = 1446, name = DUNGEON_FLOOR_ZULFARRAK .. " " .. "[" .. LEVEL .. ": " .. "42-56", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "35", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[1446][58576063] = { mnID = 1446, name = DUNGEON_FLOOR_COTTHEBLACKMORASS1 .. " " .. "[" .. LEVEL .. ": " .. "70+]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "25", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
    			    minimap[1446][57105594] = { mnID = 1446, name = L["Old Hillsbrad Foothills"] .. " " .. "[" .. LEVEL .. ": " .. "66-68]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "10", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
    			    minimap[1446][60406015] = { mnID = 1446, name = L["The Culling of Stratholme"] .. " " .. "[" .. LEVEL .. ": " .. "79-80]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "8", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[1446][62835245] = { mnID = 1446, name = DUNGEON_FLOOR_HOUROFTWILIGHT0 .. " " .. "[" .. LEVEL .. ": " .. "85]", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[1446][60895232] = { mnID = 1446, name = "Endtime" .. " " .. "[" .. LEVEL .. ": " .. "85]", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }

                end

            -- Multi
                if self.db.profile.showMiniMapMultiple then
                    minimap[1446][64774996] = { mnID = 1446, name = "", dnID = DUNGEON_FLOOR_DRAGONBLIGHTCHROMIESCENARIO4 .. " " .. "[" .. LEVEL .. ": " .. "85]" .. "\n" .. DUNGEON_FLOOR_COTMOUNTHYJAL1 .. " " .. "[" .. LEVEL .. ": " .. "70+]" .. "\n" .. DUNGEON_FLOOR_COTTHEBLACKMORASS1 .. " " .. "[" .. LEVEL .. ": " .. "70+]" .. "\n" .. L["Old Hillsbrad Foothills"] .. " " .. "[" .. LEVEL .. ": " .. "66-68]" .. "\n" .. L["The Culling of Stratholme"] .. " " .. "[" .. LEVEL .. ": " .. "79-80]", type = "MultipleM", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[1446][60485409] = { mnID = 1446, name = "", dnID = "Dragonsoul" .. " " .. "[" .. LEVEL .. ": " .. "85]" .. "\n" .. DUNGEON_FLOOR_HOUROFTWILIGHT0 .. " " .. "[" .. LEVEL .. ": " .. "85]" .. "\n" .. "Endtime" .. " " .. "[" .. LEVEL .. ": " .. "85]", type = "MultipleM", showInZone = false, showOnContinent = false, showOnMinimap = true }

                end

            -- Blizz Pois
                if self.db.profile.activate.RemoveBlizzPOIs then

                    if self.faction == "Alliance" or db.activate.EnemyFaction then
                        minimap[1438][31334778] = { mnID = 1457, name = "", type = "AIcon", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Darnassus"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " => " .. L["Blasted Lands"]}
                        minimap[1943][24734852] = { mnID = 1947, name = "", type = "AIcon", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Exodar"] .. " - " .. FACTION_ALLIANCE  .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " => " .. L["Stormwind"] }
                        minimap[1943][34034427] = { mnID = 1947, name = "", type = "AIcon", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Exodar"] .. " - " .. FACTION_ALLIANCE  .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " => " .. L["Stormwind"] }
                    end

                    if self.faction == "Horde" or db.activate.EnemyFaction then
                        minimap[1411][45600899] = { mnID = 1454, name = "", type = "HIcon", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = DUNGEON_FLOOR_ORGRIMMAR0 .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Portals"] .. "\n" .. " => " .. L["Blasted Lands"] .. "\n" .. " => " .. DUNGEON_FLOOR_TOLBARADWARLOCKSCENARIO0 .. "\n" .. " => " .. L["Uldum"] .. "\n" .. " => " .. L["Twilight Highlands"] .. "\n" .. " => " .. POSTMASTER_LETTER_HYJAL .. "\n" .. " => " .. ARTIFACT_SHAMAN_TITLECARD_DEEPHOLM .. "\n" .. " => " .. L["Vashj'ir"] .. "\n" .. "\n" .. L["Zeppelin"] .. "\n" .. " => " .. L["Grom'gol, Stranglethorn Vale"] .. "\n" .. " => " .. L["Tirisfal Glades"] .. " - " .. L["Undercity"] .. "\n" .. " => " .. POSTMASTER_LETTER_WARSONGHOLD .. "\n" .. " => " .. L["Thunder Bluff"] .. "\n" .. "\n" ..CALENDAR_TYPE_DUNGEON .. "\n" .. " => " .. DUNGEON_FLOOR_RAGEFIRE1 } 
                        minimap[1412][41112765] = { mnID = 1456, name = "", type = "HIcon", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Thunder Bluff"] .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " => " .. L["Blasted Lands"] .. "\n" .. "\n" .. L["Zeppelin"] .. "\n" .. " => " .. DUNGEON_FLOOR_ORGRIMMAR0 } 
                    end

                end


            -- Ships
                if self.db.profile.showMiniMapShips then
                    minimap[1413][70557332] = { mnID = 210, name = "", type = "Ship", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Ratchet"] .. " - " .. FACTION_NEUTRAL .. "\n" .. "\n" .. L["Ship"] .. "\n" .. " => " .. POSTMASTER_LETTER_STRANGLETHORNVALE } -- Ship from Booty Bay to Ratchet

                    if self.faction == "Alliance" or db.activate.EnemyFaction then
                        --minimap[1439][33263980] = { mnID = 1438, name = "", type = "AShip", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Ship"] .. "\n" .. " => " .. L["Teldrassil"] } -- Ship from Booty Bay to Ratchet
                        minimap[1438][51938943] = { mnID = 1943, name = "", type = "AShip", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Ship"] .. "\n" .. " => " .. L["Azuremyst Isle"] } -- Ship from Booty Bay to Ratchet
                        minimap[1438][54969385] = { mnID = 1453, name = "", type = "AShip", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Ship"] .. "\n" .. " => " .. L["Stormwind"] } -- Ship from Booty Bay to Ratchet
                        minimap[1445][71835683] = { mnID = 1437, name = "", type = "AShip", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Ship"] .. "\n" .. " => " .. POSTMASTER_LETTER_WETLANDS } -- Ship from Dustwallow Marsh to Menethil Harbor
                        --minimap[1439][32414383] = { mnID = 1453, name = "", type = "AShip", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Ship"] .. "\n" .. " => " .. L["Stormwind"] } --
                        --minimap[1439][30544094] = { mnID = 1943, name = "", type = "AShip", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Ship"] .. "\n" .. " => " .. L["Azuremyst Isle"] } --
                        minimap[1943][20065421] = { mnID = 1439, name = "", type = "AShip", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Ship"] .. "\n" .. " => " .. L["Rut'theran"] } --
                    end

                end


            -- Portals
                if self.db.profile.showZonePortals then
                    minimap[1438][54888788] = { mnID = 1457, name = "", type = "Portal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " => " .. L["Darnassus"] }
                    minimap[1438][27725076] = { mnID = 1457, name = "", type = "Portal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " => " .. L["Darnassus"] }

                    if self.faction == "Horde" or db.activate.EnemyFaction then
                        minimap[198][63472444] = { mnID = 1454, name = "", type = "HPortalS", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " => " .. DUNGEON_FLOOR_ORGRIMMAR0 }
                    end

                    if self.faction == "Alliance" or db.activate.EnemyFaction then
                        minimap[198][62592313] = { mnID = 1453, name = "", type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " => " .. L["Stormwind"] }
                        minimap[1438][30935458] = { mnID = 1457, name = "", type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " => " .. L["Blasted Lands"] }         
                    end

                end

            end -- if self.db.profile.showMiniMapKalimdor then


        --##########################
        --##### Eastern Kingdom ####
        --##########################

            if self.db.profile.showMiniMapEasternKingdom then


            -- Raids            
                if self.db.profile.showMiniMapRaids then
                    minimap[241][34017786] = { id = 72, name ="", dnID = "[" .. LEVEL .. ": " .. "85]", type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Bastion of Twilight
				    minimap[1428][20663704] = { mnID = 1428, name = DUNGEON_FLOOR_MOLTENCORE1 .. " " .. "[" .. LEVEL .. ": " .. "60+]", type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[1957][44134538] = { mnID = 1957, name = DUNGEON_FLOOR_SUNWELLPLATEAU0 .. " " .. "[" .. LEVEL .. ": " .. "70+]", type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[1430][46847438] = { mnID = 1430, name = L["Karazhan"] .. " " .. "[" .. LEVEL .. ": " .. "70+]", type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[1942][82156413] = { mnID = 1942, name = DUNGEON_FLOOR_ZULAMAN1 .. " " .. "[" .. LEVEL .. ": " .. "70]", type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[244][46204766] = { id = 75, name = "", dnID = "[" .. LEVEL .. ": " .. "85]", type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

            -- Dungeons
                if self.db.profile.showMiniMapDungeons then
                    minimap[203][48994229] = { id = 65, name = "", dnID = "[" .. LEVEL .. ": " .. "80-85]", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Throne of the Tides
                    minimap[1434][71883274] = { mnID = 1434, name = DUNGEON_FLOOR_ZULGURUB1 .. " " .. "[" .. LEVEL .. ": " .. "85]", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[241][19155399] = { id = 71, name = "", dnID = "[" .. LEVEL .. ": " .. "84-85]", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Grim Batol
                    minimap[1421][44746773] = { mnID = 1421, name = L["Shadowfang Keep"] .. " " .. "[" .. LEVEL .. ": " .. "18-26]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "14", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
				    minimap[1422][68887290] = { mnID = 1422, name = L["Scholomance"] .. " " .. "[" .. LEVEL .. ": " .. "58-60]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "48", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
				    minimap[1420][82413334] = { mnID = 1420, name = DUNGEON_FLOOR_TIRISFAL13 .. " " .. "[" .. LEVEL .. ": " .. "26-45]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "21", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
				    minimap[1423][27591150] = { mnID = 1423, name = DUNGEON_FLOOR_COTSTRATHOLME1 .. " " .. "[" .. LEVEL .. ": " .. "42-52]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "48", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
				    minimap[1423][43401925] = { mnID = 1423, name = DUNGEON_FLOOR_COTSTRATHOLME1 .. " " .. "[" .. LEVEL .. ": " .. "46-56]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "48", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[1435][69585363] = { mnID = 1435, name = DUNGEON_FLOOR_THETEMPLEOFATALHAKKAR1 .. " " .. "[" .. LEVEL .. ": " .. "50-60]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "45", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
				    minimap[1418][41651150] = { mnID = 1418, name = DUNGEON_FLOOR_BADLANDS18 .. " " .. "[" .. LEVEL .. ": " .. "41-51]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "30", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
				    minimap[1418][58523704] = { mnID = 1418, name = DUNGEON_FLOOR_BADLANDS18 .. " " .. "[" .. LEVEL .. ": " .. "41-51]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "30", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[1426][31093775] = { mnID = 1426, name = DUNGEON_FLOOR_DUNMOROGH10 .. " " .. "[" .. LEVEL .. ": " .. "29-38]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "19", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[1436][42407161] = { mnID = 1436, name = DUNGEON_FLOOR_THEDEADMINES1 .. " " .. "[" .. LEVEL .. ": " .. "17-26]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "10", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[1957][61243079] = { mnID = 1957, name = L["Magisters' Terrace"] .. " " .. "[" .. LEVEL .. ": " .. "70]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "70", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

            -- Multi
                if self.db.profile.showMiniMapMultiple then
                    minimap[1428][20663704] = { id = { 73 }, mnID = 1428, name = DUNGEON_FLOOR_MOLTENCORE1 .. " " .. "[" .. LEVEL .. ": " .. "60+]" .. "\n" .. DUNGEON_FLOOR_BURNINGSTEPPES15 .. " " .. "[" .. LEVEL .. ": " .. "80-85]" .. "\n" .. DUNGEON_FLOOR_BURNINGSTEPPES14 .. " " .. "[" .. LEVEL .. ": " .. "55-60]" .. "\n" .. DUNGEON_FLOOR_BURNINGSTEPPES16 .. " " .. "[" .. LEVEL .. ": " .. "52-60]", type = "MultipleM", showInZone = false, showOnContinent = false, showOnMinimap = true }
				    minimap[1427][34818514] = { mnID = 1427, name = "", dnID = DUNGEON_FLOOR_MOLTENCORE1 .. " " .. "[" .. LEVEL .. ": " .. "60+]" .. "\n" .. DUNGEON_FLOOR_BURNINGSTEPPES15 .. " " .. "[" .. LEVEL .. ": " .. "60+]" .. "\n" .. DUNGEON_FLOOR_BURNINGSTEPPES14 .. " " .. "[" .. LEVEL .. ": " .. "55-60]" .. "\n" .. DUNGEON_FLOOR_BURNINGSTEPPES16 .. " " .. "[" .. LEVEL .. ": " .. "52-60]", type = "MultipleM", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

            -- Blizz POIS
                if self.db.profile.activate.RemoveBlizzPOIs then

                    if self.faction == "Horde" or db.activate.EnemyFaction then
                      minimap[1420][61806939] = { mnID = 1458, name = "", type = "HIcon", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Undercity"] .. " - " .. FACTION_HORDE }
                    end
        
                    if self.faction == "Alliance" or db.activate.EnemyFaction then
                      minimap[1426][59573083] = { mnID = 1455, name = "", type = "AIcon", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Ironforge"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. DUNGEON_FLOOR_DEEPRUNTRAM1 .. "\n" .. " => " .. L["Stormwind"] .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " => " .. L["Blasted Lands"] } -- Transport to Ironforge Carriage 
                      minimap[1429][24793263] = { mnID = 1453, name = "", type = "AIcon", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Stormwind"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. DUNGEON_FLOOR_DEEPRUNTRAM1 .. "\n" .. " => " .. L["Ironforge"] .. "\n" .. "\n" .. L["Portals"] .. "\n" .. " => " .. POSTMASTER_LETTER_VALIANCEKEEP .. " => " .. L["Uldum"] .. "\n" .. " => " .. L["Vashj'ir"] .. "\n" .. " => " .. POSTMASTER_LETTER_HYJAL .. "\n" .. " => " .. ARTIFACT_SHAMAN_TITLECARD_DEEPHOLM .. "\n" .. " => " .. L["Twilight Highlands"] .. "\n" .. " => " .. DUNGEON_FLOOR_TOLBARADWARLOCKSCENARIO0 .. "\n" .. "\n" .. L["Ships"] .. "\n" .. " => " .. POSTMASTER_LETTER_VALIANCEKEEP .. "\n" .. " => " .. L["Rut'theran"] .. "\n" .. "\n" ..  CALENDAR_TYPE_DUNGEON .. "\n" .. " => " .. DUNGEON_FLOOR_THESTOCKADE1 }
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
                        minimap[224][42073346] = { mnID = 1434, name = "", type = "HZeppelin", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Grom'gol, Stranglethorn Vale"] .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Zeppelin"] .. "\n" .. " => " .. DUNGEON_FLOOR_ORGRIMMAR0 .. "\n" .. " => " .. L["Tirisfal Glades"] .. " - " .. L["Undercity"]}
                        minimap[1420][58845864] = { mnID = 117, name = "", type = "HZeppelin", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Tirisfal Glades"] .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Zeppelin"] .. "\n" .. " => " .. L["Howling Fjord"] }
                        minimap[1420][60565871] = { mnID = 1411, name = "", type = "HZeppelin", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Tirisfal Glades"] .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Zeppelin"] .. "\n" .. " => " .. DUNGEON_FLOOR_ORGRIMMAR0 }
                        minimap[1420][62025913] = { mnID = 1415, name = "", type = "HZeppelin", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Tirisfal Glades"] .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Zeppelin"] .. "\n" .. " => " .. L["Grom'gol, Stranglethorn Vale"]}
                        minimap[1434][37515098] = { mnID = 1420, name = "", type = "HZeppelin", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Grom'gol, Stranglethorn Vale"] .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Zeppelin"] .. "\n" .. " => " .. L["Tirisfal Glades"] .. " - " .. L["Undercity"] }
                        minimap[1434][37035237] = { mnID = 1411, name = "", type = "HZeppelin", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Grom'gol, Stranglethorn Vale"] .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Zeppelin"] .. "\n" .. " => " .. DUNGEON_FLOOR_ORGRIMMAR0 }
                    end

                end

            -- Ships
                if self.db.profile.showMiniMapShips then
                    minimap[210][38556688] = { mnID = 1413, name = "", type = "Ship", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = POSTMASTER_LETTER_STRANGLETHORNVALE .. " - " .. FACTION_NEUTRAL .. "\n" .. "\n" .. L["Ship"] .. "\n" .. " => " .. L["Ratchet"] } -- Ship from Booty Bay to Ratchet
                    minimap[224][36427571] = { mnID = 1413, name = "", type = "Ship", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = POSTMASTER_LETTER_STRANGLETHORNVALE .. " - " .. FACTION_NEUTRAL .. "\n" .. "\n" .. L["Ship"] .. "\n" .. " => " .. L["Ratchet"] } -- Ship from Booty Bay to Ratchet

                    if self.faction == "Alliance" or db.activate.EnemyFaction then
                        minimap[1437][04896341] = { mnID = 1445, name = "", type = "AShip", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = POSTMASTER_LETTER_WETLANDS .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Ship"] .. "\n" .. " => " .. L["Theramore Isle"] } -- Ship from Menethil Harbor to Howling Fjord and Dustwallow Marsh
                        minimap[1437][04415697] = { mnID = 117, name = "", type = "AShip", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = POSTMASTER_LETTER_WETLANDS .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Ship"] .. "\n" .. " => " .. L["Howling Fjord"] } -- Ship from Menethil Harbor to Howling Fjord and Dustwallow Marsh
                    end

                end


            --Eastern Kingdom Portals
                if self.db.profile.showZonePortals then
                    minimap[1419][54885482] = { mnID = 1944, name = "", type = "Portal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = SPLASH_BASE_90_RIGHT_TITLE .. " => " .. L["Hellfire Peninsula"] }

                    if self.faction == "Horde" or db.activate.EnemyFaction then
                        minimap[1420][59526699] = { mnID = 1954, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " => " .. L["Silvermoon City"] } -- Portal to Silvermoon from Tirisfal
                    end
                
                end

            end -- if self.db.profile.showMiniMapEasternKingdom then


        --###################
        --##### Outland ####
        --###################
            
            if self.db.profile.showZoneOutland then
    
            -- Outland Dungeons
                if self.db.profile.showZoneDungeons then
                    minimap[1952][34306560] = { mnID = 1952, name = L["Auchenai Crypts"] .. " " .. "[" .. LEVEL .. ": " .. "65-67]", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Auchenai Crypts 
                    minimap[1952][39705770] = { mnID = 1952, name = DUNGEON_FLOOR_MANATOMBS1 .. " " .. "[" .. LEVEL .. ": " .. "64-66]", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Mana-Tombs 
                    minimap[1952][44906560] = { mnID = 1952, name = L["Sethekk Halls"] .. " " .. "[" .. LEVEL .. ": " .. "67-69]", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Sethekk Halls 
                    minimap[1952][39607360] = { mnID = 1952, name = DUNGEON_FLOOR_SHADOWLABYRINTH1 .. " " .. "[" .. LEVEL .. ": " .. "69-70]", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Shadow Labyrinth 
                    minimap[1953][71705500] = { mnID = 1953, name = DUNGEON_FLOOR_THEBOTANICA1 .. " " .. "[" .. LEVEL .. ": " .. "70]", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Botanica 
                    minimap[1953][70606980] = { mnID = 1953, name = DUNGEON_FLOOR_THEMECHANAR1 .. " " .. "[" .. LEVEL .. ": " .. "70]", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Mechanar  
                    minimap[1953][74405770] = { mnID = 1953, name = L["The Arcatraz"] .. " " .. "[" .. LEVEL .. ": " .. "70]", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Arcatraz
                    minimap[1944][45985183] = { mnID = 1944, name = DUNGEON_FLOOR_THEBLOODFURNACE1 .. " " .. "[" .. LEVEL .. ": " .. "61-63]", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Blood Furnace 
                    minimap[1944][47575360] = { mnID = 1944, name = DUNGEON_FLOOR_HELLFIRERAMPARTS1 .. " " .. "[" .. LEVEL .. ": " .. "60-62]", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hellfire Ramoarts
                    minimap[1944][47025203] = { mnID = 1944, name = DUNGEON_FLOOR_THESHATTEREDHALLS1 .. " " .. "[" .. LEVEL .. ": " .. "69-70]", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Shattered Halls  
                    minimap[1946][48903570] = { mnID = 1946, name = DUNGEON_FLOOR_THESLAVEPENS1 .. " " .. "[" .. LEVEL .. ": " .. "62-64]", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Arcatraz
                    minimap[1946][50303330] = { mnID = 1946, name = DUNGEON_FLOOR_THESTEAMVAULT1 .. " " .. "[" .. LEVEL .. ": " .. "68-70]", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Blood Furnace 
                    minimap[1946][54203450] = { mnID = 1946, name = DUNGEON_FLOOR_THEUNDERBOG1 .. " " .. "[" .. LEVEL .. ": " .. "63-65]", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hellfire Ramoarts
                end
            
            -- Outland Raids
                if self.db.profile.showZoneRaids then
                    minimap[1953][73806380] = { mnID = 1953, name = DUNGEON_FLOOR_TEMPESTKEEP1 .. " " .. "[" .. LEVEL .. ": " .. "70-72]", type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Eye  
                    minimap[1948][71004660] = { mnID = 1948, name = L["Black Temple"] .. " " .. "[" .. LEVEL .. ": " .. "70+]", type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Black Temple 
                    minimap[1949][69302370] = { mnID = 1949, name = DUNGEON_FLOOR_GRUULSLAIR1 .. " " .. "[" .. LEVEL .. ": " .. "70+]", type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Gruul's Lairend
                    minimap[1944][46555286] = { mnID = 1944, name = DUNGEON_FLOOR_MAGTHERIDONSLAIR1 .. " " .. "[" .. LEVEL .. ": " .. "70+]", type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hellfire Ramparts, The Blood Furnace, The Shattered Halls, Magtheridon's Lair 
                    minimap[1946][51903280] = { mnID = 1946, name = DUNGEON_FLOOR_COILFANGRESERVOIR1 .. " " .. "[" .. LEVEL .. ": " .. "70+]", type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Shattered Halls  
                end
            
            
            -- Outland Multiple
                if self.db.profile.showZoneMultiple then
                    minimap[1946][50104095] = { mnID = 1946, name = "", dnID = DUNGEON_FLOOR_COILFANGRESERVOIR1 .. " " .. "[" .. LEVEL .. ": " .. "70+]" .. "\n" .. DUNGEON_FLOOR_THESTEAMVAULT1 .. " " .. "[" .. LEVEL .. ": " .. "68-70]" .. "\n" .. DUNGEON_FLOOR_THESLAVEPENS1 .. " " .. "[" .. LEVEL .. ": " .. "62-64]" .. "\n" .. DUNGEON_FLOOR_THEUNDERBOG1 .. " " .. "[" .. LEVEL .. ": " .. "63-65]", type = "MultipleM", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Slave Pens, The Steamvault, The Underbog, Serpentshrine Cavern
                end
            
            -- Outland Portals
                if self.db.profile.showZonePortals then
                    minimap[1952][29602266] = { mnID = 1955, name = "", type = "Portal", TransportName = L["Shattrath City"] .. "\n" .. "\n" .. L["Portals"] .. "\n" .. " => " .. DUNGEON_FLOOR_ORGRIMMAR0  .. "\n" .. "\n" .. " => " .. L["Stormwind"] .. "\n" .. "\n" .. " => " .. L["Isle of Quel'Danas"], showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal from Shattrath to Orgrimmar

                    if self.faction == "Horde" or db.activate.EnemyFaction then
                        minimap[1945][69025178] = { mnID = 1454, name = "", type = "HPortal", TransportName = L["Hellfire Peninsula"] .. " " .. L["Portal"] .. "\n" .. " => " .. DUNGEON_FLOOR_ORGRIMMAR0, showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal from Hellfire to Orgrimmar 
                        minimap[1944][88574770] = { mnID = 1454, name = "", type = "HPortal", TransportName = L["Hellfire Peninsula"] .. " " .. L["Portal"] .. "\n" .. " => " .. DUNGEON_FLOOR_ORGRIMMAR0, showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal from Hellfire to Orgrimmar 
                    end
            
                    if self.faction == "Alliance" or db.activate.EnemyFaction then
                        minimap[1945][68905259] = { mnID = 1453,  name = "" , type = "APortal", TransportName = L["Hellfire Peninsula"] .. " " .. L["Portal"] .. "\n" .. " => " .. L["Stormwind"], showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal from Hellfire to Stormwind
                        minimap[1944][88615281] = { mnID = 1453,  name = "" , type = "APortal", TransportName = L["Hellfire Peninsula"] .. " " .. L["Portal"] .. "\n" .. " => " .. L["Stormwind"], showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal from Hellfire to Stormwind                   
                    end

                end
        
            end -- if self.db.profile.showZoneOutland then


        --##############################
        --##### Continent Northrend ####
        --##############################
            if self.db.profile.showZoneNorthrend then


            -- Northrend Dungeon
                if self.db.profile.showZoneDungeons then
                    minimap[117][57804981] = { mnID = 117, showInZone = false, showOnContinent = false, showOnMinimap = true, name = L["Utgarde Keep"] .. " " .. "[" .. LEVEL .. ": " .. "70-72]", type = "Dungeon" } -- Utgarde Keep, at doorway entrance 
                    minimap[117][57064649] = { mnID = 117, showInZone = false, showOnContinent = false, showOnMinimap = true, name = L["Utgarde Pinnacle"] .. " " .. "[" .. LEVEL .. ": " .. "79-80]", type = "Dungeon" } -- Utgarde Pinnacle 
                    minimap[120][45362137] = { mnID = 120, showInZone = false, showOnContinent = false, showOnMinimap = true, name = DUNGEON_FLOOR_HALLSOFORIGINATION1 .. " " .. "[" .. LEVEL .. ": " .. "79-80]", type = "Dungeon" } -- Halls of Lightning 
                    minimap[120][39452672] = { mnID = 120, showInZone = false, showOnContinent = false, showOnMinimap = true, name = DUNGEON_FLOOR_ULDUAR771 .. " " .. "[" .. LEVEL .. ": " .. "77-79]", type = "Dungeon" } -- Halls of Stone 
                    minimap[121][28378694] = { mnID = 121, showInZone = false, showOnContinent = false, showOnMinimap = true, name = L["Drak'Tharon Keep"] .. " " .. "[" .. LEVEL .. ": " .. "74-76]", type = "Dungeon" } -- Drak'Tharon Keep 
                    minimap[121][76022081] = { mnID = 121, showInZone = false, showOnContinent = false, showOnMinimap = true, name = DUNGEON_FLOOR_GUNDRAK1 .. " " .. "[" .. LEVEL .. ": " .. "76-78]", type = "Dungeon" } -- Gundrak Left Entrance 
                    minimap[121][81192876] = { mnID = 121, showInZone = false, showOnContinent = false, showOnMinimap = true, name = DUNGEON_FLOOR_GUNDRAK1 .. " " .. "[" .. LEVEL .. ": " .. "76-78]", type = "Dungeon" } -- Gundrak Right Entrance 
                    minimap[127][28003633] = { mnID = 127, showInZone = false, showOnContinent = false, showOnMinimap = true, name = DUNGEON_FLOOR_VIOLETHOLD1 .. " " .. "[" .. LEVEL .. ": " .. "75-77]", type = "Dungeon" } -- Violet Hold
                    minimap[118][54359082] = { mnID = 118, showInZone = false, showOnContinent = false, showOnMinimap = true, name = "", dnID = DUNGEON_FLOOR_THEFORGEOFSOULS1 .. " " .. "[" .. LEVEL .. ": " .. "79-80]" .. "\n" .. DUNGEON_FLOOR_HALLSOFREFLECTION1 .. " " .. "[" .. LEVEL .. ": " .. "79-80]" .. "\n" .. DUNGEON_FLOOR_PITOFSARON1 .. " " .. "[" .. LEVEL .. ": " .. "79-80]", type = "Dungeon" } -- The Forge of Souls, Halls of Reflection, Pit of Saron         
                    minimap[115][28375147] = { mnID = 115, showInZone = false, showOnContinent = false, showOnMinimap = true, name = "", dnID = DUNGEON_FLOOR_AHNKAHET1 .. " " .. "[" .. LEVEL .. ": " .. "73-75]", type = "Dungeon" } -- Ahn'kahet The Old Kingdom, Azjol-Nerub 
                    minimap[115][25905055] = { mnID = 115, showInZone = false, showOnContinent = false, showOnMinimap = true, name = "", dnID = L["Azjol-Nerub"] .. " " .. "[" .. LEVEL .. ": " .. "72-74]", type = "Dungeon" } -- Ahn'kahet The Old Kingdom, Azjol-Nerub 
                    minimap[118][74172026] = { mnID = 118, showInZone = false, showOnContinent = false, showOnMinimap = true, name = "", dnID = L["Trial of the Champion"] .. " " .. "[" .. LEVEL .. ": " .. "79-80]", type = "Dungeon" } -- Trial of the Crusader, Trial of the Champion 
                end
          
            -- Northrend Raids
                if self.db.profile.showZoneRaids then
                    minimap[115][87355092] = { mnID = 115, showInZone = false, showOnContinent = false, showOnMinimap = true, name = L["Naxxramas"] .. " " .. "[" .. LEVEL .. ": " .. "80+]", type = "Raid" } -- Naxxramas 
                    minimap[118][53618694] = { mnID = 118, showInZone = false, showOnContinent = false, showOnMinimap = true, name = DUNGEON_FLOOR_ICECROWNCITADELDEATHKNIGHT3 .. " " .. "[" .. LEVEL .. ": " .. "80+]", type = "Raid" } -- Icecrown Citadel 
                    minimap[120][41291730] = { mnID = 120, showInZone = false, showOnContinent = false, showOnMinimap = true, name = L["Ulduar"] .. " " .. "[" .. LEVEL .. ": " .. "80+]",type = "Raid" } -- Ulduar
                    minimap[123][49911139] = { mnID = 123, showInZone = false, showOnContinent = false, showOnMinimap = true, name = DUNGEON_FLOOR_VAULTOFARCHAVON1  .. " " .. "[" .. LEVEL .. ": " .. "80+]", type = "Raid" } -- Vault of Archavon
                    minimap[115][61355259] = { mnID = 115, showInZone = false, showOnContinent = false, showOnMinimap = true, name = "", dnID = L["The Ruby Sanctum"] .. " " .. "[" .. LEVEL .. ": " .. "80+]", type = "Raid" } -- The Ruby Sanctum, The Obsidian Sanctum 
                    minimap[115][60025701] = { mnID = 115, showInZone = false, showOnContinent = false, showOnMinimap = true, name = "", dnID = DUNGEON_FLOOR_THEOBSIDIANSANCTUM1 .. " " .. "[" .. LEVEL .. ": " .. "80+]", type = "Raid" } -- The Ruby Sanctum, The Obsidian Sanctum 
                    minimap[114][27502635] = { mnID = 114, showInZone = false, showOnContinent = false, showOnMinimap = true, name = "", dnID = DUNGEON_FLOOR_THEEYEOFETERNITY1 .. " " .. "[" .. LEVEL .. ": " .. "80+]", type = "Raid" } -- The Eye of Eternity, The Nexus, The Oculus
                    minimap[118][75162155] = { mnID = 118, showInZone = false, showOnContinent = false, showOnMinimap = true, name = "", dnID = L["Trial of the Crusader"] .. " " .. "[" .. LEVEL .. ": " .. "80+]", type = "Raid" } -- Trial of the Crusader, Trial of the Champion 
                end
          
            -- Northrend Multiple
                if self.db.profile.showZoneMultiple then
                    minimap[118][54359082] = { mnID = 118, showInZone = false, showOnContinent = false, showOnMinimap = true, name = "", dnID = DUNGEON_FLOOR_THEFORGEOFSOULS1 .. " " .. "[" .. LEVEL .. ": " .. "79-80]" .. "\n" .. DUNGEON_FLOOR_HALLSOFREFLECTION1 .. " " .. "[" .. LEVEL .. ": " .. "79-80]" .. "\n" .. DUNGEON_FLOOR_PITOFSARON1 .. " " .. "[" .. LEVEL .. ": " .. "79-80]", type = "MultipleD" } -- The Forge of Souls, Halls of Reflection, Pit of Saron         
                    minimap[114][27502635] = { mnID = 114, showInZone = false, showOnContinent = false, showOnMinimap = true, name = "", dnID = DUNGEON_FLOOR_THEEYEOFETERNITY1 .. " " .. "[" .. LEVEL .. ": " .. "80+]" .. "\n" .. DUNGEON_FLOOR_THENEXUS1 .. " " .. "[" .. LEVEL .. ": " .. "71-73]" .. "\n" .. L["The Oculus"]  .. " " .. "[" .. LEVEL .. ": " .. "79-80]", type = "MultipleM" } -- The Eye of Eternity, The Nexus, The Oculus
                    --minimap[115][60265443] = { mnID = 115, showInZone = false, showOnContinent = false, showOnMinimap = true, name = "", dnID = DUNGEON_FLOOR_THEOBSIDIANSANCTUM1 .. " " .. "[" .. LEVEL .. ": " .. "80+]" .. "\n" .. L["The Ruby Sanctum"] .. " " .. "[" .. LEVEL .. ": " .. "80+]", type = "MultipleR" } -- The Ruby Sanctum, The Obsidian Sanctum 
                end

            -- Northrend Portal
                if self.db.profile.showZonePortals then
                    minimap[127][27744002] = { mnID = 125, name = "", type = "Portal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = DUNGEON_FLOOR_DALARANCITY1 .. " " .. L["Portals"] .. "\n" ..  "\n" .. " => " .. DUNGEON_FLOOR_ORGRIMMAR0  .. "\n" .. " => " .. L["Stormwind"] } -- Portal from Old Dalaran to Orgrimmar and Stormwind
                    minimap[123][49111534] = { mnID = 125, name = "", type = "Portal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " => " .. DUNGEON_FLOOR_DALARANCITY1  } -- LakeWintergrasp to Dalaran Portal 
                    minimap[127][15724250] = { mnID = 127, name = BATTLE_PET_SOURCE_2 .. " " .. REQUIRES_LABEL .. " " .. "The Magical Kingdom of Dalaran", type = "Portal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " => " .. DUNGEON_FLOOR_DALARANCITY1  } -- LakeWintergrasp to Dalaran Portal 
        
                    if self.faction == "Alliance" or db.activate.EnemyFaction then
                        minimap[114][59706926] = { mnID = 1453, name = "", type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " => " .. L["Stormwind"] } -- Portal to Stormwind from Borean Tundra
                    end

                end
        
        
            -- Northrend Zeppelin
                if self.db.profile.showZoneZeppelins then 
        
                    if self.faction == "Horde" or db.activate.EnemyFaction then
                        minimap[117][77612820] = { mnID = 1420, name = "", type = "HZeppelin", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Zeppelin"] .. " => " .. L["Tirisfal Glades"] .. " - " .. L["Undercity"] }
                        minimap[114][41365356] = { mnID = 1411, name = "", type = "HZeppelin", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Zeppelin"] .. " => " .. DUNGEON_FLOOR_ORGRIMMAR0 } -- Zeppelin from Borean Tundra to Ogrimmar
                    end

                end
        
        
            -- Northrend Ships
                if self.db.profile.showZoneShips then
                    minimap[117][23245780] = { mnID = 115, name = "", type = "Ship", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Ship"] .. " => " .. POSTMASTER_LETTER_MOAKI } -- Ship from Kamagua to Moaki
                    minimap[115][49977858] = { mnID = 117, name = "", type = "Ship", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Ship"] .. " => " .. POSTMASTER_LETTER_KAMAGUA } -- Ship from Moaki to Kamagua
                    minimap[115][47597897] = { mnID = 114, name = "", type = "Ship", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Ship"] .. " => " .. L["Borean Tundra"] } -- Ship from Moaki to Unu'pe
                    minimap[114][79075395] = { mnID = 115, name = "", type = "Ship", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Ship"] .. " => " .. POSTMASTER_LETTER_MOAKI } -- Ship from Unu'pe to Moaki
    
                    if self.faction == "Alliance" or db.activate.EnemyFaction then
                        minimap[114][60056959] = { mnID = 1453, name = "", type = "AShip", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Ship"] .. " => " .. L["Stormwind"] } -- Ship to Stormwind from Borean Tundra
                        minimap[117][61366271] = { mnID = 1437, name = "", type = "AShip", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Ship"] .. " => " .. POSTMASTER_LETTER_WETLANDS } -- Ship to Wetlands from Borean Tundra
                    end
    
                end

            end -- if self.db.profile.showZoneNorthrend then

        end -- if db.activate.MiniMap then
    end -- if not db.activate.HideMapNote then
end -- function ns.LoadCataMiniMapInfo(self)