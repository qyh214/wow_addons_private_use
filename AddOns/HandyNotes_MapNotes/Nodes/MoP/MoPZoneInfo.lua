local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

function ns.LoadMoPZoneInfo(self)
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


            -- Raids

                if self.db.profile.showZoneRaids then
                    nodes[198][47167809] = { id = 78, name = DUNGEON_FLOOR_FIRELANDS0 .. " " .. "[" .. LEVEL .. ": " .. "85]", type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Firelands
                    nodes[249][38258048] = { id = 74, name = "", dnID = "[" .. LEVEL .. ": " .. "85]", type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Throne of the Four Winds
                    nodes[81][24228729] = { mnID = 81, name = L["Temple of Ahn'Qiraj"] .. " " .. "[" .. LEVEL .. ": " .. "60+]", type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false }
    				        nodes[81][36489385] = { mnID = 81, name = DUNGEON_FLOOR_RUINSOFAHNQIRAJ1 .. " " .. "[" .. LEVEL .. ": " .. "60+]", type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false }
    			          nodes[70][52877752] = { mnID = 70, name = DUNGEON_FLOOR_ONYXIASLAIR1 .. " " .. "[" .. LEVEL .. ": " .. "60+]", type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[327][46900756] = { mnID = 81, name = L["Temple of Ahn'Qiraj"] .. " " .. "[" .. LEVEL .. ": " .. "60+]", type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false}
                    nodes[327][58761412] = { mnID = 81, name = DUNGEON_FLOOR_RUINSOFAHNQIRAJ1 .. " " .. "[" .. LEVEL .. ": " .. "60+]", type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false}
                end


            -- Dungeons

                if self.db.profile.showZoneDungeons then
                    nodes[86][69844921] = { id = 226, name = DUNGEON_FLOOR_RAGEFIRE1 .. " " .. "[" .. LEVEL .. ": " .. "13-18]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "8", type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[207][47465196] = { id = 67, name = "", dnID = "[" .. LEVEL .. ": " .. "81-85]", type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Stonecore
                    nodes[249][60536425] = { id = 69, name = "", dnID = "[" .. LEVEL .. ": " .. "84-85]", type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Lost City of Tol'Vir
                    nodes[249][71515208] = { id = 70, name = "", dnID = "[" .. LEVEL .. ": " .. "84-85]", type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Halls of Origination
                    nodes[249][76688430] = { id = 68, name = "", dnID = "[" .. LEVEL .. ": " .. "81-85]", type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Vortex Pinnacle
                    nodes[63][13961306] = { id = 227, name = L["Blackfathom Deeps"] .. " " .. "[" .. LEVEL .. ": " .. "24-32]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "15", type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false }
    			          nodes[69][60133119] = { id = 230, name = L["Dire Maul"] .. " " .. "[" .. LEVEL .. ": " .. "55-60]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "45", type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[69][76883670] = { id = 230, name = L["Dire Maul"] .. " " .. "[" .. LEVEL .. ": " .. "55-60]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "45", type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[66][28986219] = { id = 232, name = DUNGEON_FLOOR_MARAUDON1 .. " " .. "[" .. LEVEL .. ": " .. "46-55]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "30", type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false }
    			          nodes[64][41412940] = { id = 233, name = DUNGEON_FLOOR_RAZORFENDOWNS1 .. " " .. "[" .. LEVEL .. ": " .. "37-46]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "35", type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[199][40859457] = { id = 234, name = DUNGEON_FLOOR_RAZORFENKRAUL1 .. " " .. "[" .. LEVEL .. ": " .. "29-38]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "25", type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false }
    			          nodes[10][38806902] = { id = 240, name = DUNGEON_FLOOR_WAILINGCAVERNS1 .. " " .. "[" .. LEVEL .. ": " .. "17-24]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "10", type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[71][39121973] = { id = 241, name = DUNGEON_FLOOR_ZULFARRAK .. " " .. "[" .. LEVEL .. ": " .. "42-56", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "35", type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end


             -- Multi
                if self.db.profile.showZoneMultiple then
                    nodes[71][64774996] = { mnID = 71, name = "", dnID = DUNGEON_FLOOR_DRAGONBLIGHTCHROMIESCENARIO4 .. " " .. "[" .. LEVEL .. ": " .. "85]" .. "\n" .. DUNGEON_FLOOR_COTMOUNTHYJAL1 .. " " .. "[" .. LEVEL .. ": " .. "70+]" .. "\n" .. DUNGEON_FLOOR_COTTHEBLACKMORASS1 .. " " .. "[" .. LEVEL .. ": " .. "70+]" .. "\n" .. L["Old Hillsbrad Foothills"] .. " " .. "[" .. LEVEL .. ": " .. "66-68]" .. "\n" .. L["The Culling of Stratholme"] .. " " .. "[" .. LEVEL .. ": " .. "79-80]" .. "\n" .. DUNGEON_FLOOR_HOUROFTWILIGHT0 .. " " .. "[" .. LEVEL .. ": " .. "85]" .. "\n" .. "Endtime" .. " " .. "[" .. LEVEL .. ": " .. "85]" .. "\n" .. "Dragonsoul" .. " " .. "[" .. LEVEL .. ": " .. "85]", type = "MultipleM", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end


            -- Blizz Pois

                if self.db.profile.activate.RemoveBlizzPOIs then

                    if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                        nodes[57][31334778] = { mnID = 89, name = "", type = "AIcon", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Darnassus"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " => " .. L["Blasted Lands"] }
                        nodes[97][24734852] = { mnID = 103, name = "", type = "AIcon", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Exodar"] .. " - " .. FACTION_ALLIANCE  .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " => " .. L["Stormwind"] }
                        nodes[97][34034427] = { mnID = 103, name = "", type = "PassageLeftL", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Exodar"] .. " - " .. FACTION_ALLIANCE  .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " => " .. L["Stormwind"] }
                    end

                    if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                        nodes[1][45600899] = { mnID = 85, name = "", type = "HIcon", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = DUNGEON_FLOOR_ORGRIMMAR0 .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Portals"] .. "\n" .. " => " .. L["Blasted Lands"] .. "\n" .. " => " .. DUNGEON_FLOOR_TOLBARADWARLOCKSCENARIO0 .. "\n" .. " => " .. L["Uldum"] .. "\n" .. " => " .. L["Twilight Highlands"] .. "\n" .. " => " .. POSTMASTER_LETTER_HYJAL .. "\n" .. " => " .. ARTIFACT_SHAMAN_TITLECARD_DEEPHOLM .. "\n" .. " => " .. L["Vashj'ir"] .. "\n" .. "\n" .. L["Zeppelin"] .. "\n" .. " => " .. L["Grom'gol, Stranglethorn Vale"] .. "\n" .. " => " .. L["Tirisfal Glades"] .. " - " .. L["Undercity"] .. "\n" .. " => " .. POSTMASTER_LETTER_WARSONGHOLD .. "\n" .. " => " .. L["Thunder Bluff"] .. "\n" .. "\n" ..CALENDAR_TYPE_DUNGEON .. "\n" .. " => " .. DUNGEON_FLOOR_RAGEFIRE1 } 
                        nodes[7][41112765] = { mnID = 88, name = "", type = "HIcon", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Thunder Bluff"] .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " => " .. L["Blasted Lands"] .. "\n" .. "\n" .. L["Zeppelin"] .. "\n" .. " => " .. DUNGEON_FLOOR_ORGRIMMAR0 } 
                    end

                end


            -- Ships
                if self.db.profile.showZoneShips then
                    nodes[10][70557332] = { mnID = 210, name = "", type = "Ship", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Ratchet"] .. " - " .. FACTION_NEUTRAL .. "\n" .. "\n" .. L["Ship"] .. "\n" .. " => " .. POSTMASTER_LETTER_STRANGLETHORNVALE } -- Ship from Booty Bay to Ratchet
                
                    if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                        nodes[57][51938943] = { mnID = 97, name = "", type = "AShip", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Ship"] .. "\n" .. " => " .. L["Azuremyst Isle"] } -- Ship from Booty Bay to Ratchet
                        nodes[57][54969385] = { mnID = 84, name = "", type = "AShip", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Ship"] .. "\n" .. " => " .. L["Stormwind"] } -- Ship from Booty Bay to Ratchet
                        nodes[70][71835683] = { mnID = 56, name = "", type = "AShip", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Ship"] .. "\n" .. " => " .. POSTMASTER_LETTER_WETLANDS } -- Ship from Dustwallow Marsh to Menethil Harbor
                        nodes[97][20065421] = { mnID = 62, name = "", type = "AShip", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Ship"] .. "\n" .. " => " .. L["Rut'theran"] } --
                    end

                end


            -- Portals
                if self.db.profile.showZonePortals then
                    nodes[57][54888788] = { mnID = 89, name = "", type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " => " .. L["Darnassus"] }
                    nodes[57][27725076] = { mnID = 89, name = "", type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " => " .. L["Darnassus"] }

                    if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                        nodes[198][63472444] = { mnID = 85, name = "", type = "HPortalS", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " => " .. DUNGEON_FLOOR_ORGRIMMAR0 }
                    end

                    if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                        nodes[198][62592313] = { mnID = 84, name = "", type = "APortalS", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " => " .. L["Stormwind"] }
                        nodes[57][30935458] = { mnID = 89, name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " => " .. L["Blasted Lands"] }
                    end

                end

            end -- if self.db.profile.showZoneKalimdor then


        --##########################
        --##### Eastern Kingdom ####
        --##########################

            if self.db.profile.showZoneEasternKingdom then


            -- Raids            
                if self.db.profile.showZoneRaids then
				            nodes[36][20663704] = { id = 73, mnID = 36, name = DUNGEON_FLOOR_MOLTENCORE1 .. " " .. "[" .. LEVEL .. ": " .. "60+]", type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[241][34017786] = { id = 72, name ="", dnID = "[" .. LEVEL .. ": " .. "85]", type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Bastion of Twilight
                    nodes[42][46847438] = { mnID = 42, name = L["Karazhan"] .. " " .. "[" .. LEVEL .. ": " .. "70+]", type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[122][44134538] = { mnID = 122, name = DUNGEON_FLOOR_SUNWELLPLATEAU0 .. " " .. "[" .. LEVEL .. ": " .. "70+]", type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[244][46204766] = { id = 75, name = "", dnID = "[" .. LEVEL .. ": " .. "85]", type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end


            -- Dungeons
                if self.db.profile.showZoneDungeons then
                    nodes[204][70772892] = { id = 65, name = "", dnID = "[" .. LEVEL .. ": " .. "80-85]", type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Throne of the Tides
                    nodes[203][48994229] = { id = 65, name = "", dnID = "[" .. LEVEL .. ": " .. "80-85]", type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Throne of the Tides
                    nodes[50][71883274] = { id = 76, name = DUNGEON_FLOOR_ZULGURUB1 .. " " .. "[" .. LEVEL .. ": " .. "85]", type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[224][61782260] = { id = 76, name = DUNGEON_FLOOR_ZULGURUB1 .. " " .. "[" .. LEVEL .. ": " .. "85]", type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[241][19155399] = { id = 71, name = "", dnID = "[" .. LEVEL .. ": " .. "84-85]", type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Grim Batol
                    nodes[21][44746773] = { id = 64, name = L["Shadowfang Keep"] .. " " .. "[" .. LEVEL .. ": " .. "18-26]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "14", type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false }
				            nodes[22][68887290] = { id = 246, name = L["Scholomance"] .. " " .. "[" .. LEVEL .. ": " .. "58-60]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "48", type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false }
				            nodes[18][82413334] = { id = 311, name = DUNGEON_FLOOR_TIRISFAL13 .. " " .. "[" .. LEVEL .. ": " .. "26-45]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "21", type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false }
				            nodes[23][27591150] = { id = 236, name = DUNGEON_FLOOR_COTSTRATHOLME1 .. " " .. "[" .. LEVEL .. ": " .. "42-52]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "48", type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false }
				            nodes[23][43401925] = { id = 236, name = DUNGEON_FLOOR_COTSTRATHOLME1 .. " " .. "[" .. LEVEL .. ": " .. "46-56]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "48", type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[51][69585363] = { id = 237, name = DUNGEON_FLOOR_THETEMPLEOFATALHAKKAR1 .. " " .. "[" .. LEVEL .. ": " .. "50-60]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "45", type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false }
				            nodes[15][41651150] = { id = 239, name = DUNGEON_FLOOR_BADLANDS18 .. " " .. "[" .. LEVEL .. ": " .. "41-51]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "30", type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false }
				            nodes[15][58523704] = { id = 239, name = DUNGEON_FLOOR_BADLANDS18 .. " " .. "[" .. LEVEL .. ": " .. "41-51]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "30", type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[27][31093775] = { id = 231, name = DUNGEON_FLOOR_DUNMOROGH10 .. " " .. "[" .. LEVEL .. ": " .. "29-38]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "19", type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[52][42407161] = { id = 63, name = DUNGEON_FLOOR_THEDEADMINES1 .. " " .. "[" .. LEVEL .. ": " .. "17-26]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "10", type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[95][82156413] = { id = 77, name = DUNGEON_FLOOR_ZULAMAN1 .. " " .. "[" .. LEVEL .. ": " .. "70]", type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[122][61243079] = { id = 249,name = L["Magisters' Terrace"] .. " " .. "[" .. LEVEL .. ": " .. "70]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "70", type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

            -- Multi    
                if self.db.profile.showZoneMultiple then
				          nodes[36][20663704] = { id = { 73 }, mnID = 36, name = DUNGEON_FLOOR_MOLTENCORE1 .. " " .. "[" .. LEVEL .. ": " .. "60+]" .. "\n" .. DUNGEON_FLOOR_BURNINGSTEPPES15 .. " " .. "[" .. LEVEL .. ": " .. "80-85]" .. "\n" .. DUNGEON_FLOOR_BURNINGSTEPPES14 .. " " .. "[" .. LEVEL .. ": " .. "55-60]" .. "\n" .. DUNGEON_FLOOR_BURNINGSTEPPES16 .. " " .. "[" .. LEVEL .. ": " .. "52-60]", type = "MultipleM", showInZone = true, showOnContinent = false, showOnMinimap = false }
				          nodes[32][34818514] = { mnID = 32, name = "", dnID = DUNGEON_FLOOR_MOLTENCORE1 .. " " .. "[" .. LEVEL .. ": " .. "60+]" .. "\n" .. DUNGEON_FLOOR_BURNINGSTEPPES15 .. " " .. "[" .. LEVEL .. ": " .. "60+]" .. "\n" .. DUNGEON_FLOOR_BURNINGSTEPPES14 .. " " .. "[" .. LEVEL .. ": " .. "55-60]" .. "\n" .. DUNGEON_FLOOR_BURNINGSTEPPES16 .. " " .. "[" .. LEVEL .. ": " .. "52-60]", type = "MultipleM", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end


            -- Blizz POIS

                if self.db.profile.activate.RemoveBlizzPOIs then

                    if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                        nodes[94][56564002] = { mnID = 110, name = "", type = "HIcon", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Silvermoon City"] .. " - " .. FACTION_HORDE  .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " => " .. L["Undercity"] .. "\n" .. " => " .. L["Blasted Lands"] }
                        nodes[18][61806939] = { mnID = 90, name = "", type = "HIcon", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Undercity"] .. " - " .. FACTION_HORDE }
                    end
        
                    if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                        nodes[27][59573083] = { mnID = 87, name = "", type = "AIcon", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Ironforge"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. DUNGEON_FLOOR_DEEPRUNTRAM1 .. "\n" .. " => " .. L["Stormwind"] .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " => " .. L["Blasted Lands"] } -- Transport to Ironforge Carriage 
                        nodes[37][24793263] = { mnID = 84, name = "", type = "AIcon", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Stormwind"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. DUNGEON_FLOOR_DEEPRUNTRAM1 .. "\n" .. " => " .. L["Ironforge"] .. "\n" .. "\n" .. L["Portals"] .. "\n" .. " => " .. POSTMASTER_LETTER_VALIANCEKEEP .. "\n" .. " => " .. L["Uldum"] .. "\n" .. " => " .. L["Vashj'ir"] .. "\n" .. " => " .. POSTMASTER_LETTER_HYJAL .. "\n" .. " => " .. ARTIFACT_SHAMAN_TITLECARD_DEEPHOLM .. "\n" .. " => " .. L["Twilight Highlands"] .. "\n" .. " => " .. DUNGEON_FLOOR_TOLBARADWARLOCKSCENARIO0 .. "\n" .. "\n" .. L["Ships"] .. "\n" .. " => " .. POSTMASTER_LETTER_VALIANCEKEEP .. "\n" .. " => " .. L["Rut'theran"] .. "\n" .. "\n" ..  CALENDAR_TYPE_DUNGEON .. "\n" .. " => " .. DUNGEON_FLOOR_THESTOCKADE1 }
                    end

                end

            -- Dungeons and not Blizz for Stockade

                if self.db.profile.showZoneDungeons and not self.db.profile.activate.RemoveBlizzPOIs then
                
                    if self.db.profile.showZoneDungeons then
                        nodes[37][24793263] = { id = 238, name = DUNGEON_FLOOR_THESTOCKADE1 .. " " .. "[" .. LEVEL .. ": " .. "22-30]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "15", type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end
                end


            -- Zeppelin
                if self.db.profile.showZoneZeppelins then   

                    if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                        nodes[224][42073346] = { mnID = 50, name = "", type = "HZeppelin", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Grom'gol, Stranglethorn Vale"] .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Zeppelin"] .. "\n" .. " => " .. DUNGEON_FLOOR_ORGRIMMAR0 .. "\n" .. " => " .. L["Tirisfal Glades"] .. " - " .. L["Undercity"]}
                        nodes[18][58845864] = { mnID = 117, name = "", type = "HZeppelin", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Tirisfal Glades"] .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Zeppelin"] .. "\n" .. " => " .. L["Howling Fjord"] }
                        nodes[18][60565871] = { mnID = 85, name = "", type = "HZeppelin", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Tirisfal Glades"] .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Zeppelin"] .. "\n" .. " => " .. DUNGEON_FLOOR_ORGRIMMAR0 }
                        nodes[18][62025913] = { mnID = 50, name = "", type = "HZeppelin", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Tirisfal Glades"] .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Zeppelin"] .. "\n" .. " => " .. L["Grom'gol, Stranglethorn Vale"]}
                        nodes[50][37515098] = { mnID = 18, name = "", type = "HZeppelin", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Grom'gol, Stranglethorn Vale"] .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Zeppelin"] .. "\n" .. " => " .. L["Tirisfal Glades"] .. " - " .. L["Undercity"] }
                        nodes[50][37035237] = { mnID = 1, name = "", type = "HZeppelin", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Grom'gol, Stranglethorn Vale"] .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Zeppelin"] .. "\n" .. " => " .. DUNGEON_FLOOR_ORGRIMMAR0 }
                    end

                end

            -- Ships
                if self.db.profile.showZoneShips then
                    nodes[210][38556688] = { mnID = 10, name = "", type = "Ship", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = POSTMASTER_LETTER_STRANGLETHORNVALE .. " - " .. FACTION_NEUTRAL .. "\n" .. "\n" .. L["Ship"] .. "\n" .. " => " .. L["Ratchet"] } -- Ship from Booty Bay to Ratchet
                    nodes[224][36427571] = { mnID = 10, name = "", type = "Ship", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = POSTMASTER_LETTER_STRANGLETHORNVALE .. " - " .. FACTION_NEUTRAL .. "\n" .. "\n" .. L["Ship"] .. "\n" .. " => " .. L["Ratchet"] } -- Ship from Booty Bay to Ratchet

                    if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                        nodes[56][04896341] = { mnID = 70, name = "", type = "AShip", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = POSTMASTER_LETTER_WETLANDS .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Ship"] .. "\n" .. " => " .. L["Theramore Isle"] } -- Ship from Menethil Harbor to Howling Fjord and Dustwallow Marsh
                        nodes[56][04415697] = { mnID = 117, name = "", type = "AShip", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = POSTMASTER_LETTER_WETLANDS .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Ship"] .. "\n" .. " => " .. L["Howling Fjord"] } -- Ship from Menethil Harbor to Howling Fjord and Dustwallow Marsh
                    end

                end


            --Eastern Kingdom Portals
                if self.db.profile.showZonePortals then

                    nodes[17][54885482] = { mnID = 100, name = "", type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = SPLASH_BASE_90_RIGHT_TITLE .. " => " .. L["Hellfire Peninsula"] }

                    if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                        nodes[18][59526699] = { mnID = 110, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " => " .. L["Silvermoon City"] } -- Portal to Silvermoon from Tirisfal
                    end

                end

            end -- if self.db.profile.showZoneEasternKingdom then


        --###################
        --##### Outland ####
        --###################
            
            if self.db.profile.showZoneOutland then
    
            -- Outland Dungeons
                if self.db.profile.showZoneDungeons then
                    nodes[108][34306560] = { id = 247, name = L["Auchenai Crypts"] .. " " .. "[" .. LEVEL .. ": " .. "65-67]", type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Auchenai Crypts 
                    nodes[108][39705770] = { id = 250, name = DUNGEON_FLOOR_MANATOMBS1 .. " " .. "[" .. LEVEL .. ": " .. "64-66]", type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mana-Tombs 
                    nodes[108][44906560] = { id = 252, name = L["Sethekk Halls"] .. " " .. "[" .. LEVEL .. ": " .. "67-69]", type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Sethekk Halls 
                    nodes[108][39607360] = { id = 253, name = DUNGEON_FLOOR_SHADOWLABYRINTH1 .. " " .. "[" .. LEVEL .. ": " .. "69-70]", type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Shadow Labyrinth 
                    nodes[109][71705500] = { id = 257, name = DUNGEON_FLOOR_THEBOTANICA1 .. " " .. "[" .. LEVEL .. ": " .. "70]", type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Botanica 
                    nodes[109][70606980] = { id = 258, name = DUNGEON_FLOOR_THEMECHANAR1 .. " " .. "[" .. LEVEL .. ": " .. "70]", type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Mechanar  
                    nodes[109][74405770] = { id = 254, name = L["The Arcatraz"] .. " " .. "[" .. LEVEL .. ": " .. "70]", type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Arcatraz
                    nodes[100][45985183] = { id = 256, name = DUNGEON_FLOOR_THEBLOODFURNACE1 .. " " .. "[" .. LEVEL .. ": " .. "61-63]", type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Blood Furnace 
                    nodes[100][47575360] = { id = 248, name = DUNGEON_FLOOR_HELLFIRERAMPARTS1 .. " " .. "[" .. LEVEL .. ": " .. "60-62]", type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hellfire Ramoarts
                    nodes[100][47025203] = { id = 259, name = DUNGEON_FLOOR_THESHATTEREDHALLS1 .. " " .. "[" .. LEVEL .. ": " .. "69-70]", type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Shattered Halls  
                end

            
            -- Outland Raids
                if self.db.profile.showZoneRaids then
                    nodes[109][73806380] = { mnID = 109, name = DUNGEON_FLOOR_TEMPESTKEEP1 .. " " .. "[" .. LEVEL .. ": " .. "70-72]", type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Eye  
                    nodes[104][71004660] = { mnID = 104, name = L["Black Temple"] .. " " .. "[" .. LEVEL .. ": " .. "70+]", type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Black Temple 
                    nodes[105][69302370] = { mnID = 105, name = DUNGEON_FLOOR_GRUULSLAIR1 .. " " .. "[" .. LEVEL .. ": " .. "70+]", type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Gruul's Lairend
                    nodes[100][46555286] = { mnID = 100, name = DUNGEON_FLOOR_MAGTHERIDONSLAIR1 .. " " .. "[" .. LEVEL .. ": " .. "70+]", type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hellfire Ramparts, The Blood Furnace, The Shattered Halls, Magtheridon's Lair 
                end
            
            
                -- Outland Multiple
                if self.db.profile.showZoneMultiple then
                    nodes[102][50104095] = { mnID = 102, name = "", dnID = DUNGEON_FLOOR_COILFANGRESERVOIR1 .. " " .. "[" .. LEVEL .. ": " .. "70+]" .. "\n" .. DUNGEON_FLOOR_THESTEAMVAULT1 .. " " .. "[" .. LEVEL .. ": " .. "68-70]" .. "\n" .. DUNGEON_FLOOR_THESLAVEPENS1 .. " " .. "[" .. LEVEL .. ": " .. "62-64]" .. "\n" .. DUNGEON_FLOOR_THEUNDERBOG1 .. " " .. "[" .. LEVEL .. ": " .. "63-65]", type = "MultipleM", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Slave Pens, The Steamvault, The Underbog, Serpentshrine Cavern
                end
            
            
                -- Outland Portals
                  if self.db.profile.showZonePortals then
                    nodes[108][29602266] = { mnID = 111, name = "", type = "Portal", TransportName = L["Shattrath City"] .. "\n" .. "\n" .. L["Portals"] .. "\n" .. " => " .. DUNGEON_FLOOR_ORGRIMMAR0  .. "\n" .. "\n" .. " => " .. L["Stormwind"] .. "\n" .. "\n" .. " => " .. L["Isle of Quel'Danas"], showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal from Shattrath to Orgrimmar

                    if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                        nodes[101][69025178] = { mnID = 85, name = "", type = "HPortal", TransportName = L["Hellfire Peninsula"] .. " " .. L["Portal"] .. "\n" .. " => " .. DUNGEON_FLOOR_ORGRIMMAR0, showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal from Hellfire to Orgrimmar 
                        nodes[100][88574770] = { mnID = 85, name = "", type = "HPortal", TransportName = L["Hellfire Peninsula"] .. " " .. L["Portal"] .. "\n" .. " => " .. DUNGEON_FLOOR_ORGRIMMAR0, showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal from Hellfire to Orgrimmar 
                    end
            
                    if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                        nodes[101][68905259] = { mnID = 84,  name = "" , type = "APortal", TransportName = L["Hellfire Peninsula"] .. " " .. L["Portal"] .. "\n" .. " => " .. L["Stormwind"], showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal from Hellfire to Stormwind
                        nodes[100][88615281] = { mnID = 84,  name = "" , type = "APortal", TransportName = L["Hellfire Peninsula"] .. " " .. L["Portal"] .. "\n" .. " => " .. L["Stormwind"], showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal from Hellfire to Stormwind
                    end

                  end

              end -- if self.db.profile.showZoneOutland then


        --##############################
        --##### Continent Northrend ####
        --##############################
            if self.db.profile.showZoneNorthrend then


            -- Northrend Dungeon
                if self.db.profile.showZoneDungeons then
                    nodes[117][57804981] = { id = 285, showInZone = true, showOnContinent = false, showOnMinimap = false, name = L["Utgarde Keep"] .. " " .. "[" .. LEVEL .. ": " .. "70-72]", type = "Dungeon" } -- Utgarde Keep, at doorway entrance 
                    nodes[117][57064649] = { id = 286, showInZone = true, showOnContinent = false, showOnMinimap = false, name = L["Utgarde Pinnacle"] .. " " .. "[" .. LEVEL .. ": " .. "79-80]", type = "Dungeon" } -- Utgarde Pinnacle 
                    nodes[120][45362137] = { id = 275, showInZone = true, showOnContinent = false, showOnMinimap = false, name = DUNGEON_FLOOR_HALLSOFORIGINATION1 .. " " .. "[" .. LEVEL .. ": " .. "79-80]", type = "Dungeon" } -- Halls of Lightning 
                    nodes[120][39452672] = { id = 277, showInZone = true, showOnContinent = false, showOnMinimap = false, name = DUNGEON_FLOOR_ULDUAR771 .. " " .. "[" .. LEVEL .. ": " .. "77-79]", type = "Dungeon" } -- Halls of Stone 
                    nodes[121][28378694] = { id = 273, showInZone = true, showOnContinent = false, showOnMinimap = false, name = L["Drak'Tharon Keep"] .. " " .. "[" .. LEVEL .. ": " .. "74-76]", type = "Dungeon" } -- Drak'Tharon Keep 
                    nodes[121][76022081] = { id = 274, showInZone = true, showOnContinent = false, showOnMinimap = false, name = DUNGEON_FLOOR_GUNDRAK1 .. " " .. "[" .. LEVEL .. ": " .. "76-78]", type = "Dungeon" } -- Gundrak Left Entrance 
                    nodes[121][81192876] = { id = 274, showInZone = true, showOnContinent = false, showOnMinimap = false, name = DUNGEON_FLOOR_GUNDRAK1 .. " " .. "[" .. LEVEL .. ": " .. "76-78]", type = "Dungeon" } -- Gundrak Right Entrance 
                    nodes[127][28003633] = { id = 283, showInZone = true, showOnContinent = false, showOnMinimap = false, name = DUNGEON_FLOOR_VIOLETHOLD1 .. " " .. "[" .. LEVEL .. ": " .. "75-77]", type = "Dungeon" } -- Violet Hold
                    nodes[118][54359082] = { id = 280, showInZone = true, showOnContinent = false, showOnMinimap = false, name = "", dnID = DUNGEON_FLOOR_THEFORGEOFSOULS1 .. " " .. "[" .. LEVEL .. ": " .. "79-80]" .. "\n" .. DUNGEON_FLOOR_HALLSOFREFLECTION1 .. " " .. "[" .. LEVEL .. ": " .. "79-80]" .. "\n" .. DUNGEON_FLOOR_PITOFSARON1 .. " " .. "[" .. LEVEL .. ": " .. "79-80]", type = "Dungeon" } -- The Forge of Souls, Halls of Reflection, Pit of Saron         
                    nodes[115][28375147] = { id = 271, showInZone = true, showOnContinent = false, showOnMinimap = false, name = "", dnID = DUNGEON_FLOOR_AHNKAHET1 .. " " .. "[" .. LEVEL .. ": " .. "73-75]", type = "Dungeon" } -- Ahn'kahet The Old Kingdom, Azjol-Nerub 
                    nodes[115][25905055] = { id = 272, showInZone = true, showOnContinent = false, showOnMinimap = false, name = "", dnID = L["Azjol-Nerub"] .. " " .. "[" .. LEVEL .. ": " .. "72-74]", type = "Dungeon" } -- Ahn'kahet The Old Kingdom, Azjol-Nerub 
                    nodes[118][74172026] = { id = 284, showInZone = true, showOnContinent = false, showOnMinimap = false, name = "", dnID = L["Trial of the Champion"] .. " " .. "[" .. LEVEL .. ": " .. "79-80]", type = "Dungeon" } -- Trial of the Crusader, Trial of the Champion 
                end
          
                -- Northrend Raids
                if self.db.profile.showZoneRaids then
                    nodes[115][87355092] = { mnID = 115, showInZone = true, showOnContinent = false, showOnMinimap = false, name = L["Naxxramas"] .. " " .. "[" .. LEVEL .. ": " .. "80+]", type = "Raid" } -- Naxxramas 
                    nodes[118][53618694] = { mnID = 118, showInZone = true, showOnContinent = false, showOnMinimap = false, name = DUNGEON_FLOOR_ICECROWNCITADELDEATHKNIGHT3 .. " " .. "[" .. LEVEL .. ": " .. "80+]", type = "Raid" } -- Icecrown Citadel 
                    nodes[120][41291730] = { mnID = 120, showInZone = true, showOnContinent = false, showOnMinimap = false, name = L["Ulduar"] .. " " .. "[" .. LEVEL .. ": " .. "80+]",type = "Raid" } -- Ulduar
                    nodes[123][49911139] = { mnID = 123, showInZone = true, showOnContinent = false, showOnMinimap = false, name = DUNGEON_FLOOR_VAULTOFARCHAVON1  .. " " .. "[" .. LEVEL .. ": " .. "80+]", type = "Raid" } -- Vault of Archavon
                    nodes[115][61355259] = { mnID = 115, showInZone = true, showOnContinent = false, showOnMinimap = false, name = "", dnID = L["The Ruby Sanctum"] .. " " .. "[" .. LEVEL .. ": " .. "80+]", type = "Raid" } -- The Ruby Sanctum, The Obsidian Sanctum 
                    nodes[115][60025701] = { mnID = 115, showInZone = true, showOnContinent = false, showOnMinimap = false, name = "", dnID = DUNGEON_FLOOR_THEOBSIDIANSANCTUM1 .. " " .. "[" .. LEVEL .. ": " .. "80+]", type = "Raid" } -- The Ruby Sanctum, The Obsidian Sanctum 
                    nodes[114][27502635] = { mnID = 114, showInZone = true, showOnContinent = false, showOnMinimap = false, name = "", dnID = DUNGEON_FLOOR_THEEYEOFETERNITY1 .. " " .. "[" .. LEVEL .. ": " .. "80+]", type = "Raid" } -- The Eye of Eternity, The Nexus, The Oculus
                    nodes[118][75162155] = { mnID = 118, showInZone = true, showOnContinent = false, showOnMinimap = false, name = "", dnID = L["Trial of the Crusader"] .. " " .. "[" .. LEVEL .. ": " .. "80+]", type = "Raid" } -- Trial of the Crusader, Trial of the Champion 
                end
          
            -- Northrend Multiple
                if self.db.profile.showZoneMultiple then
                    nodes[118][54359082] = { mnID = 118, showInZone = true, showOnContinent = false, showOnMinimap = false, name = "", dnID = DUNGEON_FLOOR_THEFORGEOFSOULS1 .. " " .. "[" .. LEVEL .. ": " .. "79-80]" .. "\n" .. DUNGEON_FLOOR_HALLSOFREFLECTION1 .. " " .. "[" .. LEVEL .. ": " .. "79-80]" .. "\n" .. DUNGEON_FLOOR_PITOFSARON1 .. " " .. "[" .. LEVEL .. ": " .. "79-80]", type = "MultipleD" } -- The Forge of Souls, Halls of Reflection, Pit of Saron         
                    nodes[114][27502635] = { mnID = 114, showInZone = true, showOnContinent = false, showOnMinimap = false, name = "", dnID = DUNGEON_FLOOR_THEEYEOFETERNITY1 .. " " .. "[" .. LEVEL .. ": " .. "80+]" .. "\n" .. DUNGEON_FLOOR_THENEXUS1 .. " " .. "[" .. LEVEL .. ": " .. "71-73]" .. "\n" .. L["The Oculus"]  .. " " .. "[" .. LEVEL .. ": " .. "79-80]", type = "MultipleM" } -- The Eye of Eternity, The Nexus, The Oculus
                    --nodes[115][60265443] = { mnID = 115, showInZone = true, showOnContinent = false, showOnMinimap = false, name = "", dnID = DUNGEON_FLOOR_THEOBSIDIANSANCTUM1 .. " " .. "[" .. LEVEL .. ": " .. "80+]" .. "\n" .. L["The Ruby Sanctum"] .. " " .. "[" .. LEVEL .. ": " .. "80+]", type = "MultipleR" } -- The Ruby Sanctum, The Obsidian Sanctum 
                end

            -- Northrend Portal
                if self.db.profile.showZonePortals then
                    nodes[127][27744002] = { mnID = 125, name = "", type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = DUNGEON_FLOOR_DALARANCITY1 .. " " .. L["Portals"] .. "\n" ..  "\n" .. " => " .. DUNGEON_FLOOR_ORGRIMMAR0  .. "\n" .. " => " .. L["Stormwind"] } -- Portal from Old Dalaran to Orgrimmar and Stormwind
                    nodes[123][49111534] = { mnID = 125, name = "", type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " => " .. DUNGEON_FLOOR_DALARANCITY1  } -- LakeWintergrasp to Dalaran Portal 
                    nodes[127][15724250] = { mnID = 125, name = L["Portal"] .. " ==> " .. DUNGEON_FLOOR_DALARANCITY1, questID = 12791, wwwLink = "https://www.wowhead.com/quest=12791", wwwName = BATTLE_PET_SOURCE_2 .. " " .. REQUIRES_LABEL .. " " .. "The Magical Kingdom of Dalaran", type = "Portal", showWWW = true, showInZone = true, showOnContinent = false, showOnMinimap = false } -- LakeWintergrasp to Dalaran Portal  
        
                    if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                        nodes[114][59706926] = { mnID = 84, name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " => " .. L["Stormwind"] } -- Portal to Stormwind from Borean Tundra
                    end

                end
        
            -- Northrend Zeppelin
                if self.db.profile.showZoneZeppelins then 
        
                    if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                        nodes[117][77612820] = { mnID = 18, name = "", type = "HZeppelin", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Zeppelin"] .. " => " .. L["Tirisfal Glades"] .. " - " .. L["Undercity"] }
                        nodes[114][41365356] = { mnID = 1, name = "", type = "HZeppelin", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Zeppelin"] .. " => " .. DUNGEON_FLOOR_ORGRIMMAR0 } -- Zeppelin from Borean Tundra to Ogrimmar
                    end
                end
        
            -- Northrend Ships
                if self.db.profile.showZoneShips then
                    nodes[117][23245780] = { mnID = 115, name = "", type = "Ship", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Ship"] .. " => " .. POSTMASTER_LETTER_MOAKI } -- Ship from Kamagua to Moaki
                    nodes[115][49977858] = { mnID = 117, name = "", type = "Ship", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Ship"] .. " => " .. POSTMASTER_LETTER_KAMAGUA } -- Ship from Moaki to Kamagua
                    nodes[115][47597897] = { mnID = 114, name = "", type = "Ship", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Ship"] .. " => " .. L["Borean Tundra"] } -- Ship from Moaki to Unu'pe
                    nodes[114][79075395] = { mnID = 115, name = "", type = "Ship", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Ship"] .. " => " .. POSTMASTER_LETTER_MOAKI } -- Ship from Unu'pe to Moaki

                    if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                        nodes[114][60056959] = { mnID = 84, name = "", type = "AShip", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Ship"] .. " => " .. L["Stormwind"] } -- Ship to Stormwind from Borean Tundra
                        nodes[117][61366271] = { mnID = 56, name = "", type = "AShip", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Ship"] .. " => " .. POSTMASTER_LETTER_WETLANDS } -- Ship to Wetlands from Borean Tundra
                    end

                end

            end -- if self.db.profile.showZoneNorthrend then

        --#############################
        --##### Continent Pandaria ####
        --#############################
    
      if self.db.profile.showZonePandaria then

          -- Pandaria Dungeons
          if self.db.profile.showZoneDungeons then

          -- Dungeon Nodes above Blizzards Icons to make it Clickable for maximized Maps
          nodes[371][56175786] = { id = 313, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Temple of the Jade Serpent
          nodes[371][14504859] = { id = 321, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mogu'shan Palace
          nodes[418][35931925] = { id = 302, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Stormstout Brewery
          nodes[376][36066909] = { id = 302, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Stormstout Brewery
          nodes[422][91105965] = { id = 302, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Stormstout Brewery
          nodes[422][75842030] = { id = 303, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Gate of the Setting Sun
          nodes[376][15261542] = { id = 303, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Gate of the Setting Sun
          nodes[388][34688151] = { id = 324, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Siege of Niuzao Temple
          nodes[388][78992402] = { id = 312, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Shado-Pan Monastery
          nodes[379][36714746] = { id = 312, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Shado-Pan Monastery
          nodes[390][80603303] = { id = 321, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mogu'shan Palace
          nodes[390][15837441] = { id = 303, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Gate of the Setting Sun
          nodes[1530][81093057] = { id = 321, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mogu'shan Palace
          end

          -- Pandaria Raids
          if self.db.profile.showZoneRaids then

          -- Raid Nodes above Blizzards Icons to make it Clickable for maximized Maps
            nodes[371][21595793] = { id = 320, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Terrace of Endless Spring
            nodes[376][69680536] = { id = 320, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Terrace of Endless Spring
            nodes[433][48456145] = { id = 320, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Terrace of Endless Spring
            --nodes[371][12005202] = { id = 369, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Siege of Orgrimmar
            nodes[422][38923499] = { id = 330, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Heart of Fear            
            nodes[379][59603917] = { id = 317, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mogu'Shan Vaults
            --nodes[504][63833203] = { id = 362, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Throne of Thunder
            --nodes[390][73714248] = { id = 369, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Siege of Orgrimmar
          end


        if db.activate.ZoneTransporting then

        -- Pandaria Portals
          if self.db.profile.showZonePortals then
    
            if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
              nodes[504][33223269] = { mnID = 388, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. L["Isle of Thunder"] } -- Portal from Isle of Thunder to Shado-Pan Garrison
              nodes[379][85946249] = { mnID = 85, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. DUNGEON_FLOOR_ORGRIMMAR0 } -- Portal from Jade Forest to Orgrimmar
              nodes[388][50657339] = { mnID = 504, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. L["Isle of Thunder"] } -- Portal from Isle of Thunder to  Shado-Pan Garrison
              nodes[390][63371293] = { mnID = 85, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. DUNGEON_FLOOR_ORGRIMMAR0 } -- Portal from Shrine of Two Moons to Orgrimmar
              nodes[418][10315365] = { mnID = 110, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. L["Silvermoon City"] } -- Portal to Silvermoon
              nodes[371][28501401] = { mnID = 85, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. DUNGEON_FLOOR_ORGRIMMAR0 } -- Portal from Jade Forest to Orgrimmar          
            end

            if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
              nodes[504][64707347] = { mnID = 388, name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. L["Isle of Thunder"] } -- Portal from Isle of Thunder to Shado-Pan Garrison
              nodes[388][49746867] = { mnID = 504, name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. L["Isle of Thunder"] } -- Portal from Isle of Thunder to  Shado-Pan Garrison
              nodes[390][90596670] = { mnID = 84, name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. L["Stormwind"] } -- Portal from Shrine of Seven Stars to Stormwind
              nodes[1530][90596670] = { mnID = 84, name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. L["Stormwind"] } -- Portal from Shrine of Seven Stars to Stormwind
              nodes[371][46248517] = { mnID = 84, name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. L["Stormwind"] } -- Portal from Jade Forest to Stormwind
            end

          end

        end

        --Professions
        if self.db.profile.showZoneProfessions then

          if self.db.profile.showZoneAlchemy then
            nodes[422][55623530] = { name = L["Alchemy"], type = "Alchemy", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
          end
      
          if self.db.profile.showZoneLeatherworking then
            nodes[379][64606090] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
          end

          if self.db.profile.showZoneEngineer then
            nodes[376][16068313] = { name = L["Engineer"], type = "Engineer", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
          end

          if self.db.profile.showZoneSkinning then
            nodes[376][15925308] = { name = L["Skinning"], type = "Skinning", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
          end

          if self.db.profile.showZoneTailoring then
            nodes[376][59706266] = { name = L["Tailoring"], type = "Tailoring", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
          end

          if self.db.profile.showZoneBlacksmith then
            nodes[390][21827237] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
          end

          if self.db.profile.showZoneMining then
            nodes[371][46062940] = { name = L["Mining"], type = "Mining", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
          end

          if self.db.profile.showZoneFishing then
            nodes[418][68474349] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            nodes[376][58904700] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
          end

          if self.db.profile.showZoneCooking then
            nodes[371][46304520] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
          end

          if self.db.profile.showZoneArchaeology then
              nodes[390][83563122] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }

            if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
              nodes[390][21101500] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
              --nodes[379][57207860] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
              nodes[504][33503380] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            end
          end

          if self.db.profile.showZoneHerbalism then            
            if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
              nodes[371][46806060] = { name = L["Herbalism"], type = "Herbalism", wwwName = REQUIRES_LABEL .. " " .. STORY_PROGRESS, questID = 29824, showWWW = true, wwwLink = "wowhead.com/quest=29824", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            end

          end

          if self.db.profile.showZoneEnchanting then
              nodes[371][46824287] = { name = L["Enchanting"], type = "Enchanting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
          end

          if self.db.profile.showZoneInscription then
            nodes[390][81902863] = { name = INSCRIPTION, type = "Inscription", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            nodes[371][55004500] = { name = INSCRIPTION, type = "Inscription", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
          end

          -- not mixed
          if not self.db.profile.showZoneProfessionsMixed then

            if self.db.profile.showZoneSkinning then

              if self.faction == "Horde" then
                nodes[371][27791536] = { name = L["Skinning"], type = "Skinning", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
              end

              if self.faction == "Alliance" then
                nodes[371][44848553] = { name = L["Skinning"], type = "Skinning", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
              end

            end

            if self.db.profile.showZoneInscription then
              nodes[371][47603500] = { name = INSCRIPTION, type = "Inscription", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
              nodes[379][50604230] = { name = INSCRIPTION, type = "Inscription", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            end

            if self.db.profile.showZoneCooking then
              nodes[376][52675166] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
              --nodes[379][50604180] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            end

            if self.db.profile.showZoneLeatherworking then
              --nodes[379][50604200] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            end

            if self.db.profile.showZoneHerbalism then
              nodes[376][53715129] = { name = L["Herbalism"], type = "Herbalism", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
              --nodes[379][50604230] = { name = L["Herbalism"], type = "Herbalism", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            end

            if self.db.profile.showZoneJewelcrafting then
              nodes[371][48073494] = { name = L["Jewelcrafting"], type = "Jewelcrafting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            end

            if self.db.profile.showZoneBlacksmith then
              --nodes[379][48604460] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
              nodes[371][48403690] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            end

            if self.db.profile.showZoneMining then
              --nodes[379][48604460] = { name = L["Mining"], type = "Mining", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
  
              if self.faction == "Horde" then
                nodes[371][27801480] = { name = L["Mining"], type = "Mining", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
              end

              if self.faction == "Alliance" then
                nodes[371][45108590] = { name = L["Mining"], type = "Mining", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
              end

            end

            if self.db.profile.showZoneMining or self.db.profile.showZoneBlacksmith then
              --nodes[379][48604460] = { dnID = FACTION_NEUTRAL .. " " .. MINIMAP_TRACKING_TRAINER_PROFESSION .. "\n" .. "\n" .. TextIconBlacksmith:GetIconString() .. " " .. L["Blacksmithing"] .. "\n" .. TextIconMining:GetIconString() .. " " .. L["Mining"], name = "", type = "ProfessionsMixed", showInZone = true, showOnContinent = false, showOnMinimap = false }
            end

            if self.db.profile.showZoneFishing then
              --nodes[379][51004020] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            end

            if self.db.profile.showZoneHerbalism then
                
              if self.faction == "Horde" then
                nodes[371][27801563] = { name = L["Herbalism"], type = "Herbalism", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
              end

              if self.faction == "Alliance" then
                nodes[371][45608600] = { name = L["Herbalism"], type = "Herbalism", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
              end

            end

          end

          if self.db.profile.showZoneProfessionsMixed then
            --nodes[379][48604460] = { dnID = FACTION_NEUTRAL .. " " .. MINIMAP_TRACKING_TRAINER_PROFESSION .. "\n" .. "\n" .. TextIconBlacksmith:GetIconString() .. " " .. L["Blacksmithing"] .. "\n" .. TextIconMining:GetIconString() .. " " .. L["Mining"], name = "", type = "ProfessionsMixed", showInZone = true, showOnContinent = false, showOnMinimap = false }
            --nodes[379][50604230] = { dnID = FACTION_NEUTRAL .. " " .. MINIMAP_TRACKING_TRAINER_PROFESSION .. "\n" .. "\n" .. TextIconInscription:GetIconString() .. " " .. INSCRIPTION .. "\n" .. TextIconHerbalism:GetIconString() .. " " .. L["Herbalism"] .. "\n" .. TextIconLeatherworking:GetIconString() .. " " .. L["Leatherworking"] .. "\n" .. TextIconCooking:GetIconString() .. " " .. PROFESSIONS_COOKING .. "\n" .. TextIconFishing:GetIconString() .. " " .. PROFESSIONS_FISHING, name = "", type = "ProfessionsMixed", showInZone = true, showOnContinent = false, showOnMinimap = false }
            nodes[371][48083510] = { dnID = FACTION_NEUTRAL .. " " .. MINIMAP_TRACKING_TRAINER_PROFESSION .. "\n" .. "\n" .. TextIconInscription:GetIconString() .. " " .. INSCRIPTION .. "\n" .. TextIconJewelcrafting:GetIconString() .. " " .. L["Jewelcrafting"] .. "\n" .. TextIconBlacksmith:GetIconString() .. " " .. L["Blacksmithing"], name = "", type = "ProfessionsMixed", showInZone = true, showOnContinent = false, showOnMinimap = false }
            nodes[376][52675166] = { dnID = FACTION_NEUTRAL .. " " .. MINIMAP_TRACKING_TRAINER_PROFESSION .. "\n" .. "\n" .. TextIconHerbalism:GetIconString() .. " " .. L["Herbalism"] .. "\n" .. TextIconCooking:GetIconString() .. " " .. PROFESSIONS_COOKING, name = "", type = "ProfessionsMixed", showInZone = true, showOnContinent = false, showOnMinimap = false }

            if self.faction == "Horde" then
              nodes[371][27071522] = { dnID = ITEM_REQ_HORDE .. "\n" .. "\n" .. TextIconHerbalism:GetIconString() .. " " .. L["Herbalism"] .. "\n" .. TextIconMining:GetIconString() .. " " .. L["Mining"] .. "\n" .. TextIconSkinning:GetIconString() .. " " .. L["Skinning"], name = "", type = "ProfessionsMixed", showInZone = true, showOnContinent = false, showOnMinimap = false }
            end

            if self.faction == "Alliance" then
              nodes[371][44748643] = { dnID = ITEM_REQ_ALLIANCE .. "\n" .. "\n" .. TextIconHerbalism:GetIconString() .. " " .. L["Herbalism"] .. "\n" .. TextIconMining:GetIconString() .. " " .. L["Mining"] .. "\n" .. TextIconSkinning:GetIconString() .. " " .. L["Skinning"], name = "", type = "ProfessionsMixed", showInZone = true, showOnContinent = false, showOnMinimap = false }
            end

          end

        end

      end

        end -- if db.activate.ZoneMap then
    end -- if not db.activate.HideMapNote then
end -- function ns.LoadMoPZoneInfo(self)