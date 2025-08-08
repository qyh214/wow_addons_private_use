local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

function ns.LoadMoPMiniMapInfo(self)
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
                    minimap[198][47167809] = { id = 78, name = DUNGEON_FLOOR_FIRELANDS0 .. " " .. "[" .. LEVEL .. ": " .. "85]", type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Firelands
                    minimap[249][38258048] = { id = 74, name = "", dnID = "[" .. LEVEL .. ": " .. "85]", type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Throne of the Four Winds
                    minimap[81][24228729] = { mnID = 81, name = L["Temple of Ahn'Qiraj"] .. " " .. "[" .. LEVEL .. ": " .. "60+]", type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true }
    				        minimap[81][36489385] = { mnID = 81, name = DUNGEON_FLOOR_RUINSOFAHNQIRAJ1 .. " " .. "[" .. LEVEL .. ": " .. "60+]", type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true }
    			          minimap[70][52877752] = { mnID = 70, name = DUNGEON_FLOOR_ONYXIASLAIR1 .. " " .. "[" .. LEVEL .. ": " .. "60+]", type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[327][46900756] = { mnID = 81, name = L["Temple of Ahn'Qiraj"] .. " " .. "[" .. LEVEL .. ": " .. "60+]", type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true}
                    minimap[327][58761412] = { mnID = 81, name = DUNGEON_FLOOR_RUINSOFAHNQIRAJ1 .. " " .. "[" .. LEVEL .. ": " .. "60+]", type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true}
                end


            -- Dungeons

                if self.db.profile.showMiniMapDungeons then
                    minimap[86][69844921] = { id = 226, name = DUNGEON_FLOOR_RAGEFIRE1 .. " " .. "[" .. LEVEL .. ": " .. "13-18]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "8", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[207][47465196] = { id = 67, name = "", dnID = "[" .. LEVEL .. ": " .. "81-85]", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stonecore
                    minimap[249][60536425] = { id = 69, name = "", dnID = "[" .. LEVEL .. ": " .. "84-85]", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Lost City of Tol'Vir
                    minimap[249][71515208] = { id = 70, name = "", dnID = "[" .. LEVEL .. ": " .. "84-85]", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Halls of Origination
                    minimap[249][76688430] = { id = 68, name = "", dnID = "[" .. LEVEL .. ": " .. "81-85]", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Vortex Pinnacle
                    minimap[63][13961306] = { id = 227, name = L["Blackfathom Deeps"] .. " " .. "[" .. LEVEL .. ": " .. "24-32]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "15", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
    			          minimap[69][60133119] = { id = 230, name = L["Dire Maul"] .. " " .. "[" .. LEVEL .. ": " .. "55-60]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "45", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[69][76883670] = { id = 230, name = L["Dire Maul"] .. " " .. "[" .. LEVEL .. ": " .. "55-60]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "45", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[66][28986219] = { id = 232, name = DUNGEON_FLOOR_MARAUDON1 .. " " .. "[" .. LEVEL .. ": " .. "46-55]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "30", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
    			          minimap[64][41412940] = { id = 233, name = DUNGEON_FLOOR_RAZORFENDOWNS1 .. " " .. "[" .. LEVEL .. ": " .. "37-46]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "35", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[199][40859457] = { id = 234, name = DUNGEON_FLOOR_RAZORFENKRAUL1 .. " " .. "[" .. LEVEL .. ": " .. "29-38]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "25", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
    			          minimap[10][38806902] = { id = 240, name = DUNGEON_FLOOR_WAILINGCAVERNS1 .. " " .. "[" .. LEVEL .. ": " .. "17-24]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "10", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[71][39121973] = { id = 241, name = DUNGEON_FLOOR_ZULFARRAK .. " " .. "[" .. LEVEL .. ": " .. "42-56", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "35", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end


             -- Multi
                if self.db.profile.showMiniMapMultiple then
                    minimap[71][64774996] = { mnID = 71, name = "", dnID = DUNGEON_FLOOR_DRAGONBLIGHTCHROMIESCENARIO4 .. " " .. "[" .. LEVEL .. ": " .. "85]" .. "\n" .. DUNGEON_FLOOR_COTMOUNTHYJAL1 .. " " .. "[" .. LEVEL .. ": " .. "70+]" .. "\n" .. DUNGEON_FLOOR_COTTHEBLACKMORASS1 .. " " .. "[" .. LEVEL .. ": " .. "70+]" .. "\n" .. L["Old Hillsbrad Foothills"] .. " " .. "[" .. LEVEL .. ": " .. "66-68]" .. "\n" .. L["The Culling of Stratholme"] .. " " .. "[" .. LEVEL .. ": " .. "79-80]" .. "\n" .. DUNGEON_FLOOR_HOUROFTWILIGHT0 .. " " .. "[" .. LEVEL .. ": " .. "85]" .. "\n" .. "Endtime" .. " " .. "[" .. LEVEL .. ": " .. "85]" .. "\n" .. "Dragonsoul" .. " " .. "[" .. LEVEL .. ": " .. "85]", type = "MultipleM", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end


            -- Blizz Pois

                if self.db.profile.activate.RemoveBlizzPOIs then

                    if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                        minimap[57][31334778] = { mnID = 89, name = "", type = "AIcon", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Darnassus"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " => " .. L["Blasted Lands"] }
                        minimap[97][24734852] = { mnID = 103, name = "", type = "AIcon", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Exodar"] .. " - " .. FACTION_ALLIANCE  .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " => " .. L["Stormwind"] }
                        minimap[97][34034427] = { mnID = 103, name = "", type = "PassageLeftL", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Exodar"] .. " - " .. FACTION_ALLIANCE  .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " => " .. L["Stormwind"] }
                    end

                    if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                        minimap[1][45600899] = { mnID = 85, name = "", type = "HIcon", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = DUNGEON_FLOOR_ORGRIMMAR0 .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Portals"] .. "\n" .. " => " .. L["Blasted Lands"] .. "\n" .. " => " .. DUNGEON_FLOOR_TOLBARADWARLOCKSCENARIO0 .. "\n" .. " => " .. L["Uldum"] .. "\n" .. " => " .. L["Twilight Highlands"] .. "\n" .. " => " .. POSTMASTER_LETTER_HYJAL .. "\n" .. " => " .. ARTIFACT_SHAMAN_TITLECARD_DEEPHOLM .. "\n" .. " => " .. L["Vashj'ir"] .. "\n" .. "\n" .. L["Zeppelin"] .. "\n" .. " => " .. L["Grom'gol, Stranglethorn Vale"] .. "\n" .. " => " .. L["Tirisfal Glades"] .. " - " .. L["Undercity"] .. "\n" .. " => " .. POSTMASTER_LETTER_WARSONGHOLD .. "\n" .. " => " .. L["Thunder Bluff"] .. "\n" .. "\n" ..CALENDAR_TYPE_DUNGEON .. "\n" .. " => " .. DUNGEON_FLOOR_RAGEFIRE1 } 
                        minimap[7][41112765] = { mnID = 88, name = "", type = "HIcon", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Thunder Bluff"] .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " => " .. L["Blasted Lands"] .. "\n" .. "\n" .. L["Zeppelin"] .. "\n" .. " => " .. DUNGEON_FLOOR_ORGRIMMAR0 } 
                    end

                end


            -- Ships
                if self.db.profile.showMiniMapShips then
                    minimap[10][70557332] = { mnID = 210, name = "", type = "Ship", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Ratchet"] .. " - " .. FACTION_NEUTRAL .. "\n" .. "\n" .. L["Ship"] .. "\n" .. " => " .. POSTMASTER_LETTER_STRANGLETHORNVALE } -- Ship from Booty Bay to Ratchet
                
                    if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                        minimap[57][51938943] = { mnID = 97, name = "", type = "AShip", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Ship"] .. "\n" .. " => " .. L["Azuremyst Isle"] } -- Ship from Booty Bay to Ratchet
                        minimap[57][54969385] = { mnID = 84, name = "", type = "AShip", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Ship"] .. "\n" .. " => " .. L["Stormwind"] } -- Ship from Booty Bay to Ratchet
                        minimap[70][71835683] = { mnID = 56, name = "", type = "AShip", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Ship"] .. "\n" .. " => " .. POSTMASTER_LETTER_WETLANDS } -- Ship from Dustwallow Marsh to Menethil Harbor
                        minimap[97][20065421] = { mnID = 62, name = "", type = "AShip", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Ship"] .. "\n" .. " => " .. L["Rut'theran"] } --
                    end

                end


            -- Portals
                if self.db.profile.showMiniMapPortals then
                    minimap[57][54888788] = { mnID = 89, name = "", type = "Portal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " => " .. L["Darnassus"] }
                    minimap[57][27725076] = { mnID = 89, name = "", type = "Portal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " => " .. L["Darnassus"] }

                    if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                        minimap[198][63472444] = { mnID = 85, name = "", type = "HPortalS", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " => " .. DUNGEON_FLOOR_ORGRIMMAR0 }
                    end

                    if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                        minimap[198][62592313] = { mnID = 84, name = "", type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " => " .. L["Stormwind"] }
                        minimap[57][30935458] = { mnID = 89, name = "", type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " => " .. L["Blasted Lands"] }
                    end

                end

            end -- if self.db.profile.showMiniMapKalimdor then


        --##########################
        --##### Eastern Kingdom ####
        --##########################

            if self.db.profile.showMiniMapEasternKingdom then


            -- Raids            
                if self.db.profile.showMiniMapRaids then
				            minimap[36][20663704] = { id = 73, mnID = 36, name = DUNGEON_FLOOR_MOLTENCORE1 .. " " .. "[" .. LEVEL .. ": " .. "60+]", type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[241][34017786] = { id = 72, name ="", dnID = "[" .. LEVEL .. ": " .. "85]", type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Bastion of Twilight
                    minimap[42][46847438] = { mnID = 42, name = L["Karazhan"] .. " " .. "[" .. LEVEL .. ": " .. "70+]", type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[122][44134538] = { mnID = 122, name = DUNGEON_FLOOR_SUNWELLPLATEAU0 .. " " .. "[" .. LEVEL .. ": " .. "70+]", type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[244][46204766] = { id = 75, name = "", dnID = "[" .. LEVEL .. ": " .. "85]", type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end


            -- Dungeons
                if self.db.profile.showMiniMapDungeons then
                    minimap[204][70772892] = { id = 65, name = "", dnID = "[" .. LEVEL .. ": " .. "80-85]", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Throne of the Tides
                    minimap[203][48994229] = { id = 65, name = "", dnID = "[" .. LEVEL .. ": " .. "80-85]", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Throne of the Tides
                    minimap[50][71883274] = { id = 76, name = DUNGEON_FLOOR_ZULGURUB1 .. " " .. "[" .. LEVEL .. ": " .. "85]", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[224][61782260] = { id = 76, name = DUNGEON_FLOOR_ZULGURUB1 .. " " .. "[" .. LEVEL .. ": " .. "85]", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[241][19155399] = { id = 71, name = "", dnID = "[" .. LEVEL .. ": " .. "84-85]", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Grim Batol
                    minimap[21][44746773] = { id = 64, name = L["Shadowfang Keep"] .. " " .. "[" .. LEVEL .. ": " .. "18-26]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "14", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
				            minimap[22][68887290] = { id = 246, name = L["Scholomance"] .. " " .. "[" .. LEVEL .. ": " .. "58-60]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "48", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
				            minimap[18][82413334] = { id = 311, name = DUNGEON_FLOOR_TIRISFAL13 .. " " .. "[" .. LEVEL .. ": " .. "26-45]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "21", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
				            minimap[23][27591150] = { id = 236, name = DUNGEON_FLOOR_COTSTRATHOLME1 .. " " .. "[" .. LEVEL .. ": " .. "42-52]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "48", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
				            minimap[23][43401925] = { id = 236, name = DUNGEON_FLOOR_COTSTRATHOLME1 .. " " .. "[" .. LEVEL .. ": " .. "46-56]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "48", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[51][69585363] = { id = 237, name = DUNGEON_FLOOR_THETEMPLEOFATALHAKKAR1 .. " " .. "[" .. LEVEL .. ": " .. "50-60]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "45", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
				            minimap[15][41651150] = { id = 239, name = DUNGEON_FLOOR_BADLANDS18 .. " " .. "[" .. LEVEL .. ": " .. "41-51]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "30", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
				            minimap[15][58523704] = { id = 239, name = DUNGEON_FLOOR_BADLANDS18 .. " " .. "[" .. LEVEL .. ": " .. "41-51]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "30", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[27][31093775] = { id = 231, name = DUNGEON_FLOOR_DUNMOROGH10 .. " " .. "[" .. LEVEL .. ": " .. "29-38]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "19", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[52][42407161] = { id = 63, name = DUNGEON_FLOOR_THEDEADMINES1 .. " " .. "[" .. LEVEL .. ": " .. "17-26]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "10", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[95][82156413] = { id = 77, name = DUNGEON_FLOOR_ZULAMAN1 .. " " .. "[" .. LEVEL .. ": " .. "70]", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[122][61243079] = { id = 249,name = L["Magisters' Terrace"] .. " " .. "[" .. LEVEL .. ": " .. "70]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "70", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

            -- Multi    
                if self.db.profile.showMiniMapMultiple then
				          minimap[36][20663704] = { id = { 73 }, mnID = 36, name = DUNGEON_FLOOR_MOLTENCORE1 .. " " .. "[" .. LEVEL .. ": " .. "60+]" .. "\n" .. DUNGEON_FLOOR_BURNINGSTEPPES15 .. " " .. "[" .. LEVEL .. ": " .. "80-85]" .. "\n" .. DUNGEON_FLOOR_BURNINGSTEPPES14 .. " " .. "[" .. LEVEL .. ": " .. "55-60]" .. "\n" .. DUNGEON_FLOOR_BURNINGSTEPPES16 .. " " .. "[" .. LEVEL .. ": " .. "52-60]", type = "MultipleM", showInZone = false, showOnContinent = false, showOnMinimap = true }
				          minimap[32][34818514] = { mnID = 32, name = "", dnID = DUNGEON_FLOOR_MOLTENCORE1 .. " " .. "[" .. LEVEL .. ": " .. "60+]" .. "\n" .. DUNGEON_FLOOR_BURNINGSTEPPES15 .. " " .. "[" .. LEVEL .. ": " .. "60+]" .. "\n" .. DUNGEON_FLOOR_BURNINGSTEPPES14 .. " " .. "[" .. LEVEL .. ": " .. "55-60]" .. "\n" .. DUNGEON_FLOOR_BURNINGSTEPPES16 .. " " .. "[" .. LEVEL .. ": " .. "52-60]", type = "MultipleM", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end


            -- Blizz POIS

                if self.db.profile.activate.RemoveBlizzPOIs then

                    if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                        minimap[94][56564002] = { mnID = 110, name = "", type = "HIcon", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Silvermoon City"] .. " - " .. FACTION_HORDE  .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " => " .. L["Undercity"] .. "\n" .. " => " .. L["Blasted Lands"] }
                        minimap[18][61806939] = { mnID = 90, name = "", type = "HIcon", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Undercity"] .. " - " .. FACTION_HORDE }
                    end
        
                    if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                        minimap[27][59573083] = { mnID = 87, name = "", type = "AIcon", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Ironforge"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. DUNGEON_FLOOR_DEEPRUNTRAM1 .. "\n" .. " => " .. L["Stormwind"] .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " => " .. L["Blasted Lands"] } -- Transport to Ironforge Carriage 
                        minimap[37][24793263] = { mnID = 84, name = "", type = "AIcon", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Stormwind"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. DUNGEON_FLOOR_DEEPRUNTRAM1 .. "\n" .. " => " .. L["Ironforge"] .. "\n" .. "\n" .. L["Portals"] .. "\n" .. " => " .. POSTMASTER_LETTER_VALIANCEKEEP .. "\n" .. " => " .. L["Uldum"] .. "\n" .. " => " .. L["Vashj'ir"] .. "\n" .. " => " .. POSTMASTER_LETTER_HYJAL .. "\n" .. " => " .. ARTIFACT_SHAMAN_TITLECARD_DEEPHOLM .. "\n" .. " => " .. L["Twilight Highlands"] .. "\n" .. " => " .. DUNGEON_FLOOR_TOLBARADWARLOCKSCENARIO0 .. "\n" .. "\n" .. L["Ships"] .. "\n" .. " => " .. POSTMASTER_LETTER_VALIANCEKEEP .. "\n" .. " => " .. L["Rut'theran"] .. "\n" .. "\n" ..  CALENDAR_TYPE_DUNGEON .. "\n" .. " => " .. DUNGEON_FLOOR_THESTOCKADE1 }
                    end

                end

            -- Dungeons and not Blizz for Stockade

                if self.db.profile.showMiniMapDungeons and not self.db.profile.activate.RemoveBlizzPOIs then
                
                    if self.db.profile.showMiniMapDungeons then
                        minimap[37][24793263] = { id = 238, name = DUNGEON_FLOOR_THESTOCKADE1 .. " " .. "[" .. LEVEL .. ": " .. "22-30]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "15", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end
                end


            -- Zeppelin
                if self.db.profile.showMiniMapZeppelins then   

                    if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                        minimap[224][42073346] = { mnID = 50, name = "", type = "HZeppelin", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Grom'gol, Stranglethorn Vale"] .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Zeppelin"] .. "\n" .. " => " .. DUNGEON_FLOOR_ORGRIMMAR0 .. "\n" .. " => " .. L["Tirisfal Glades"] .. " - " .. L["Undercity"]}
                        minimap[18][58845864] = { mnID = 117, name = "", type = "HZeppelin", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Tirisfal Glades"] .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Zeppelin"] .. "\n" .. " => " .. L["Howling Fjord"] }
                        minimap[18][60565871] = { mnID = 85, name = "", type = "HZeppelin", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Tirisfal Glades"] .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Zeppelin"] .. "\n" .. " => " .. DUNGEON_FLOOR_ORGRIMMAR0 }
                        minimap[18][62025913] = { mnID = 50, name = "", type = "HZeppelin", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Tirisfal Glades"] .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Zeppelin"] .. "\n" .. " => " .. L["Grom'gol, Stranglethorn Vale"]}
                        minimap[50][37515098] = { mnID = 18, name = "", type = "HZeppelin", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Grom'gol, Stranglethorn Vale"] .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Zeppelin"] .. "\n" .. " => " .. L["Tirisfal Glades"] .. " - " .. L["Undercity"] }
                        minimap[50][37035237] = { mnID = 1, name = "", type = "HZeppelin", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Grom'gol, Stranglethorn Vale"] .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Zeppelin"] .. "\n" .. " => " .. DUNGEON_FLOOR_ORGRIMMAR0 }
                    end

                end

            -- Ships
                if self.db.profile.showMiniMapShips then
                    minimap[210][38556688] = { mnID = 10, name = "", type = "Ship", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = POSTMASTER_LETTER_STRANGLETHORNVALE .. " - " .. FACTION_NEUTRAL .. "\n" .. "\n" .. L["Ship"] .. "\n" .. " => " .. L["Ratchet"] } -- Ship from Booty Bay to Ratchet
                    minimap[224][36427571] = { mnID = 10, name = "", type = "Ship", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = POSTMASTER_LETTER_STRANGLETHORNVALE .. " - " .. FACTION_NEUTRAL .. "\n" .. "\n" .. L["Ship"] .. "\n" .. " => " .. L["Ratchet"] } -- Ship from Booty Bay to Ratchet

                    if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                        minimap[56][04896341] = { mnID = 70, name = "", type = "AShip", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = POSTMASTER_LETTER_WETLANDS .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Ship"] .. "\n" .. " => " .. L["Theramore Isle"] } -- Ship from Menethil Harbor to Howling Fjord and Dustwallow Marsh
                        minimap[56][04415697] = { mnID = 117, name = "", type = "AShip", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = POSTMASTER_LETTER_WETLANDS .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Ship"] .. "\n" .. " => " .. L["Howling Fjord"] } -- Ship from Menethil Harbor to Howling Fjord and Dustwallow Marsh
                    end

                end


            --Eastern Kingdom Portals
                if self.db.profile.showMiniMapPortals then

                    minimap[17][54885482] = { mnID = 100, name = "", type = "Portal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = SPLASH_BASE_90_RIGHT_TITLE .. " => " .. L["Hellfire Peninsula"] }

                    if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                        minimap[18][59526699] = { mnID = 110, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " => " .. L["Silvermoon City"] } -- Portal to Silvermoon from Tirisfal
                    end

                end

            end -- if self.db.profile.showMiniMapEasternKingdom then


        --###################
        --##### Outland ####
        --###################
            
            if self.db.profile.showMiniMapOutland then
    
            -- Outland Dungeons
                if self.db.profile.showMiniMapDungeons then
                    minimap[108][34306560] = { id = 247, name = L["Auchenai Crypts"] .. " " .. "[" .. LEVEL .. ": " .. "65-67]", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Auchenai Crypts 
                    minimap[108][39705770] = { id = 250, name = DUNGEON_FLOOR_MANATOMBS1 .. " " .. "[" .. LEVEL .. ": " .. "64-66]", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Mana-Tombs 
                    minimap[108][44906560] = { id = 252, name = L["Sethekk Halls"] .. " " .. "[" .. LEVEL .. ": " .. "67-69]", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Sethekk Halls 
                    minimap[108][39607360] = { id = 253, name = DUNGEON_FLOOR_SHADOWLABYRINTH1 .. " " .. "[" .. LEVEL .. ": " .. "69-70]", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Shadow Labyrinth 
                    minimap[109][71705500] = { id = 257, name = DUNGEON_FLOOR_THEBOTANICA1 .. " " .. "[" .. LEVEL .. ": " .. "70]", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Botanica 
                    minimap[109][70606980] = { id = 258, name = DUNGEON_FLOOR_THEMECHANAR1 .. " " .. "[" .. LEVEL .. ": " .. "70]", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Mechanar  
                    minimap[109][74405770] = { id = 254, name = L["The Arcatraz"] .. " " .. "[" .. LEVEL .. ": " .. "70]", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Arcatraz
                    minimap[100][45985183] = { id = 256, name = DUNGEON_FLOOR_THEBLOODFURNACE1 .. " " .. "[" .. LEVEL .. ": " .. "61-63]", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Blood Furnace 
                    minimap[100][47575360] = { id = 248, name = DUNGEON_FLOOR_HELLFIRERAMPARTS1 .. " " .. "[" .. LEVEL .. ": " .. "60-62]", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hellfire Ramoarts
                    minimap[100][47025203] = { id = 259, name = DUNGEON_FLOOR_THESHATTEREDHALLS1 .. " " .. "[" .. LEVEL .. ": " .. "69-70]", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Shattered Halls  
                end

            
            -- Outland Raids
                if self.db.profile.showMiniMapRaids then
                    minimap[109][73806380] = { mnID = 109, name = DUNGEON_FLOOR_TEMPESTKEEP1 .. " " .. "[" .. LEVEL .. ": " .. "70-72]", type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Eye  
                    minimap[104][71004660] = { mnID = 104, name = L["Black Temple"] .. " " .. "[" .. LEVEL .. ": " .. "70+]", type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Black Temple 
                    minimap[105][69302370] = { mnID = 105, name = DUNGEON_FLOOR_GRUULSLAIR1 .. " " .. "[" .. LEVEL .. ": " .. "70+]", type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Gruul's Lairend
                    minimap[100][46555286] = { mnID = 100, name = DUNGEON_FLOOR_MAGTHERIDONSLAIR1 .. " " .. "[" .. LEVEL .. ": " .. "70+]", type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hellfire Ramparts, The Blood Furnace, The Shattered Halls, Magtheridon's Lair 
                end
            
            
                -- Outland Multiple
                if self.db.profile.showMiniMapMultiple then
                    minimap[102][50104095] = { mnID = 102, name = "", dnID = DUNGEON_FLOOR_COILFANGRESERVOIR1 .. " " .. "[" .. LEVEL .. ": " .. "70+]" .. "\n" .. DUNGEON_FLOOR_THESTEAMVAULT1 .. " " .. "[" .. LEVEL .. ": " .. "68-70]" .. "\n" .. DUNGEON_FLOOR_THESLAVEPENS1 .. " " .. "[" .. LEVEL .. ": " .. "62-64]" .. "\n" .. DUNGEON_FLOOR_THEUNDERBOG1 .. " " .. "[" .. LEVEL .. ": " .. "63-65]", type = "MultipleM", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Slave Pens, The Steamvault, The Underbog, Serpentshrine Cavern
                end
            
            
                -- Outland Portals
                  if self.db.profile.showMiniMapPortals then
                    minimap[108][29602266] = { mnID = 111, name = "", type = "Portal", TransportName = L["Shattrath City"] .. "\n" .. "\n" .. L["Portals"] .. "\n" .. " => " .. DUNGEON_FLOOR_ORGRIMMAR0  .. "\n" .. "\n" .. " => " .. L["Stormwind"] .. "\n" .. "\n" .. " => " .. L["Isle of Quel'Danas"], showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal from Shattrath to Orgrimmar

                    if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                        minimap[101][69025178] = { mnID = 85, name = "", type = "HPortal", TransportName = L["Hellfire Peninsula"] .. " " .. L["Portal"] .. "\n" .. " => " .. DUNGEON_FLOOR_ORGRIMMAR0, showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal from Hellfire to Orgrimmar 
                        minimap[100][88574770] = { mnID = 85, name = "", type = "HPortal", TransportName = L["Hellfire Peninsula"] .. " " .. L["Portal"] .. "\n" .. " => " .. DUNGEON_FLOOR_ORGRIMMAR0, showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal from Hellfire to Orgrimmar 
                    end
            
                    if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                        minimap[101][68905259] = { mnID = 84,  name = "" , type = "APortal", TransportName = L["Hellfire Peninsula"] .. " " .. L["Portal"] .. "\n" .. " => " .. L["Stormwind"], showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal from Hellfire to Stormwind
                        minimap[100][88615281] = { mnID = 84,  name = "" , type = "APortal", TransportName = L["Hellfire Peninsula"] .. " " .. L["Portal"] .. "\n" .. " => " .. L["Stormwind"], showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal from Hellfire to Stormwind
                    end

                  end

              end -- if self.db.profile.showMiniMapOutland then


        --##############################
        --##### Continent Northrend ####
        --##############################
            if self.db.profile.showMiniMapNorthrend then


            -- Northrend Dungeon
                if self.db.profile.showMiniMapDungeons then
                    minimap[117][57804981] = { id = 285, showInZone = false, showOnContinent = false, showOnMinimap = true, name = L["Utgarde Keep"] .. " " .. "[" .. LEVEL .. ": " .. "70-72]", type = "Dungeon" } -- Utgarde Keep, at doorway entrance 
                    minimap[117][57064649] = { id = 286, showInZone = false, showOnContinent = false, showOnMinimap = true, name = L["Utgarde Pinnacle"] .. " " .. "[" .. LEVEL .. ": " .. "79-80]", type = "Dungeon" } -- Utgarde Pinnacle 
                    minimap[120][45362137] = { id = 275, showInZone = false, showOnContinent = false, showOnMinimap = true, name = DUNGEON_FLOOR_HALLSOFORIGINATION1 .. " " .. "[" .. LEVEL .. ": " .. "79-80]", type = "Dungeon" } -- Halls of Lightning 
                    minimap[120][39452672] = { id = 277, showInZone = false, showOnContinent = false, showOnMinimap = true, name = DUNGEON_FLOOR_ULDUAR771 .. " " .. "[" .. LEVEL .. ": " .. "77-79]", type = "Dungeon" } -- Halls of Stone 
                    minimap[121][28378694] = { id = 273, showInZone = false, showOnContinent = false, showOnMinimap = true, name = L["Drak'Tharon Keep"] .. " " .. "[" .. LEVEL .. ": " .. "74-76]", type = "Dungeon" } -- Drak'Tharon Keep 
                    minimap[121][76022081] = { id = 274, showInZone = false, showOnContinent = false, showOnMinimap = true, name = DUNGEON_FLOOR_GUNDRAK1 .. " " .. "[" .. LEVEL .. ": " .. "76-78]", type = "Dungeon" } -- Gundrak Left Entrance 
                    minimap[121][81192876] = { id = 274, showInZone = false, showOnContinent = false, showOnMinimap = true, name = DUNGEON_FLOOR_GUNDRAK1 .. " " .. "[" .. LEVEL .. ": " .. "76-78]", type = "Dungeon" } -- Gundrak Right Entrance 
                    minimap[127][28003633] = { id = 283, showInZone = false, showOnContinent = false, showOnMinimap = true, name = DUNGEON_FLOOR_VIOLETHOLD1 .. " " .. "[" .. LEVEL .. ": " .. "75-77]", type = "Dungeon" } -- Violet Hold
                    minimap[118][54359082] = { id = 280, showInZone = false, showOnContinent = false, showOnMinimap = true, name = "", dnID = DUNGEON_FLOOR_THEFORGEOFSOULS1 .. " " .. "[" .. LEVEL .. ": " .. "79-80]" .. "\n" .. DUNGEON_FLOOR_HALLSOFREFLECTION1 .. " " .. "[" .. LEVEL .. ": " .. "79-80]" .. "\n" .. DUNGEON_FLOOR_PITOFSARON1 .. " " .. "[" .. LEVEL .. ": " .. "79-80]", type = "Dungeon" } -- The Forge of Souls, Halls of Reflection, Pit of Saron         
                    minimap[115][28375147] = { id = 271, showInZone = false, showOnContinent = false, showOnMinimap = true, name = "", dnID = DUNGEON_FLOOR_AHNKAHET1 .. " " .. "[" .. LEVEL .. ": " .. "73-75]", type = "Dungeon" } -- Ahn'kahet The Old Kingdom, Azjol-Nerub 
                    minimap[115][25905055] = { id = 272, showInZone = false, showOnContinent = false, showOnMinimap = true, name = "", dnID = L["Azjol-Nerub"] .. " " .. "[" .. LEVEL .. ": " .. "72-74]", type = "Dungeon" } -- Ahn'kahet The Old Kingdom, Azjol-Nerub 
                    minimap[118][74172026] = { id = 284, showInZone = false, showOnContinent = false, showOnMinimap = true, name = "", dnID = L["Trial of the Champion"] .. " " .. "[" .. LEVEL .. ": " .. "79-80]", type = "Dungeon" } -- Trial of the Crusader, Trial of the Champion 
                end
          
                -- Northrend Raids
                if self.db.profile.showMiniMapRaids then
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
                if self.db.profile.showMiniMapMultiple then
                    minimap[118][54359082] = { mnID = 118, showInZone = false, showOnContinent = false, showOnMinimap = true, name = "", dnID = DUNGEON_FLOOR_THEFORGEOFSOULS1 .. " " .. "[" .. LEVEL .. ": " .. "79-80]" .. "\n" .. DUNGEON_FLOOR_HALLSOFREFLECTION1 .. " " .. "[" .. LEVEL .. ": " .. "79-80]" .. "\n" .. DUNGEON_FLOOR_PITOFSARON1 .. " " .. "[" .. LEVEL .. ": " .. "79-80]", type = "MultipleD" } -- The Forge of Souls, Halls of Reflection, Pit of Saron         
                    minimap[114][27502635] = { mnID = 114, showInZone = false, showOnContinent = false, showOnMinimap = true, name = "", dnID = DUNGEON_FLOOR_THEEYEOFETERNITY1 .. " " .. "[" .. LEVEL .. ": " .. "80+]" .. "\n" .. DUNGEON_FLOOR_THENEXUS1 .. " " .. "[" .. LEVEL .. ": " .. "71-73]" .. "\n" .. L["The Oculus"]  .. " " .. "[" .. LEVEL .. ": " .. "79-80]", type = "MultipleM" } -- The Eye of Eternity, The Nexus, The Oculus
                    --minimap[115][60265443] = { mnID = 115, showInZone = false, showOnContinent = false, showOnMinimap = true, name = "", dnID = DUNGEON_FLOOR_THEOBSIDIANSANCTUM1 .. " " .. "[" .. LEVEL .. ": " .. "80+]" .. "\n" .. L["The Ruby Sanctum"] .. " " .. "[" .. LEVEL .. ": " .. "80+]", type = "MultipleR" } -- The Ruby Sanctum, The Obsidian Sanctum 
                end

            -- Northrend Portal
                if self.db.profile.showMiniMapPortals then
                    minimap[127][27744002] = { mnID = 125, name = "", type = "Portal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = DUNGEON_FLOOR_DALARANCITY1 .. " " .. L["Portals"] .. "\n" ..  "\n" .. " => " .. DUNGEON_FLOOR_ORGRIMMAR0  .. "\n" .. " => " .. L["Stormwind"] } -- Portal from Old Dalaran to Orgrimmar and Stormwind
                    minimap[123][49111534] = { mnID = 125, name = "", type = "Portal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " => " .. DUNGEON_FLOOR_DALARANCITY1  } -- LakeWintergrasp to Dalaran Portal 
                    minimap[127][15724250] = { mnID = 125, name = L["Portal"] .. " ==> " .. DUNGEON_FLOOR_DALARANCITY1, questID = 12791, wwwLink = "https://www.wowhead.com/quest=12791", wwwName = BATTLE_PET_SOURCE_2 .. " " .. REQUIRES_LABEL .. " " .. "The Magical Kingdom of Dalaran", type = "Portal", showWWW = true, showInZone = false, showOnContinent = false, showOnMinimap = true } -- LakeWintergrasp to Dalaran Portal  
        
                    if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                        minimap[114][59706926] = { mnID = 84, name = "", type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " => " .. L["Stormwind"] } -- Portal to Stormwind from Borean Tundra
                    end

                end
        
            -- Northrend Zeppelin
                if self.db.profile.showMiniMapZeppelins then 
        
                    if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                        minimap[117][77612820] = { mnID = 18, name = "", type = "HZeppelin", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Zeppelin"] .. " => " .. L["Tirisfal Glades"] .. " - " .. L["Undercity"] }
                        minimap[114][41365356] = { mnID = 1, name = "", type = "HZeppelin", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Zeppelin"] .. " => " .. DUNGEON_FLOOR_ORGRIMMAR0 } -- Zeppelin from Borean Tundra to Ogrimmar
                    end
                end
        
            -- Northrend Ships
                if self.db.profile.showMiniMapShips then
                    minimap[117][23245780] = { mnID = 115, name = "", type = "Ship", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Ship"] .. " => " .. POSTMASTER_LETTER_MOAKI } -- Ship from Kamagua to Moaki
                    minimap[115][49977858] = { mnID = 117, name = "", type = "Ship", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Ship"] .. " => " .. POSTMASTER_LETTER_KAMAGUA } -- Ship from Moaki to Kamagua
                    minimap[115][47597897] = { mnID = 114, name = "", type = "Ship", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Ship"] .. " => " .. L["Borean Tundra"] } -- Ship from Moaki to Unu'pe
                    minimap[114][79075395] = { mnID = 115, name = "", type = "Ship", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Ship"] .. " => " .. POSTMASTER_LETTER_MOAKI } -- Ship from Unu'pe to Moaki

                    if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                        minimap[114][60056959] = { mnID = 84, name = "", type = "AShip", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Ship"] .. " => " .. L["Stormwind"] } -- Ship to Stormwind from Borean Tundra
                        minimap[117][61366271] = { mnID = 56, name = "", type = "AShip", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Ship"] .. " => " .. POSTMASTER_LETTER_WETLANDS } -- Ship to Wetlands from Borean Tundra
                    end

                end

            end -- if self.db.profile.showMiniMapNorthrend then

        --#############################
        --##### Continent Pandaria ####
        --#############################
    
      if self.db.profile.showMiniMapPandaria then

          -- Pandaria Dungeons
          if self.db.profile.showMiniMapDungeons then

          -- Dungeon minimap above Blizzards Icons to make it Clickable for maximized Maps
          minimap[371][56175786] = { id = 313, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Temple of the Jade Serpent
          minimap[371][14504859] = { id = 321, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Mogu'shan Palace
          minimap[418][35931925] = { id = 302, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stormstout Brewery
          minimap[376][36066909] = { id = 302, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stormstout Brewery
          minimap[422][91105965] = { id = 302, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stormstout Brewery
          minimap[422][75842030] = { id = 303, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Gate of the Setting Sun
          minimap[376][15261542] = { id = 303, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Gate of the Setting Sun
          minimap[388][34688151] = { id = 324, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Siege of Niuzao Temple
          minimap[388][78992402] = { id = 312, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Shado-Pan Monastery
          minimap[379][36714746] = { id = 312, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Shado-Pan Monastery
          minimap[390][80603303] = { id = 321, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Mogu'shan Palace
          minimap[390][15837441] = { id = 303, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Gate of the Setting Sun
          minimap[1530][81093057] = { id = 321, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Mogu'shan Palace
          end

          -- Pandaria Raids
          if self.db.profile.showMiniMapRaids then

          -- Raid minimap above Blizzards Icons to make it Clickable for maximized Maps
            minimap[371][21595793] = { id = 320, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Terrace of Endless Spring
            minimap[376][69680536] = { id = 320, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Terrace of Endless Spring
            minimap[433][48456145] = { id = 320, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Terrace of Endless Spring
            --minimap[371][12005202] = { id = 369, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Siege of Orgrimmar
            minimap[422][38923499] = { id = 330, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Heart of Fear            
            minimap[379][59603917] = { id = 317, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Mogu'Shan Vaults
            --minimap[504][63833203] = { id = 362, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Throne of Thunder
            --minimap[390][73714248] = { id = 369, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Siege of Orgrimmar
          end


        if db.activate.ZoneTransporting then

        -- Pandaria Portals
          if self.db.profile.showMiniMapPortals then
    
            if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
              minimap[504][33223269] = { mnID = 388, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Isle of Thunder"] } -- Portal from Isle of Thunder to Shado-Pan Garrison
              minimap[379][85946249] = { mnID = 85, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. DUNGEON_FLOOR_ORGRIMMAR0 } -- Portal from Jade Forest to Orgrimmar
              minimap[388][50657339] = { mnID = 504, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Isle of Thunder"] } -- Portal from Isle of Thunder to  Shado-Pan Garrison
              minimap[390][63371293] = { mnID = 85, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. DUNGEON_FLOOR_ORGRIMMAR0 } -- Portal from Shrine of Two Moons to Orgrimmar
              minimap[418][10315365] = { mnID = 110, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Silvermoon City"] } -- Portal to Silvermoon
              minimap[371][28501401] = { mnID = 85, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. DUNGEON_FLOOR_ORGRIMMAR0 } -- Portal from Jade Forest to Orgrimmar          
            end

            if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
              minimap[504][64707347] = { mnID = 388, name = "", type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Isle of Thunder"] } -- Portal from Isle of Thunder to Shado-Pan Garrison
              minimap[388][49746867] = { mnID = 504, name = "", type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Isle of Thunder"] } -- Portal from Isle of Thunder to  Shado-Pan Garrison
              minimap[390][90596670] = { mnID = 84, name = "", type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Stormwind"] } -- Portal from Shrine of Seven Stars to Stormwind
              minimap[1530][90596670] = { mnID = 84, name = "", type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Stormwind"] } -- Portal from Shrine of Seven Stars to Stormwind
              minimap[371][46248517] = { mnID = 84, name = "", type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Stormwind"] } -- Portal from Jade Forest to Stormwind
            end

          end

        end

        --Professions
        if self.db.profile.showMiniMapProfessions then

          if self.db.profile.showMiniMapAlchemy then
            minimap[422][55623530] = { name = L["Alchemy"], type = "Alchemy", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
          end
      
          if self.db.profile.showMiniMapLeatherworking then
            minimap[379][64606090] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
          end

          if self.db.profile.showMiniMapEngineer then
            minimap[376][16068313] = { name = L["Engineer"], type = "Engineer", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
          end

          if self.db.profile.showMiniMapSkinning then
            minimap[376][15925308] = { name = L["Skinning"], type = "Skinning", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
          end

          if self.db.profile.showMiniMapTailoring then
            minimap[376][59706266] = { name = L["Tailoring"], type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
          end

          if self.db.profile.showMiniMapBlacksmith then
            minimap[390][21827237] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
          end

          if self.db.profile.showMiniMapMining then
            minimap[371][46062940] = { name = L["Mining"], type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
          end

          if self.db.profile.showMiniMapFishing then
            minimap[418][68474349] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            minimap[376][58904700] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
          end

          if self.db.profile.showMiniMapCooking then
            minimap[371][46304520] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
          end

          if self.db.profile.showMiniMapArchaeology then
              minimap[390][83563122] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }

            if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
              minimap[390][21101500] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
              --minimap[379][57207860] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
              minimap[504][33503380] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            end
          end

          if self.db.profile.showMiniMapHerbalism then            
            if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
              minimap[371][46806060] = { name = L["Herbalism"], type = "Herbalism", wwwName = REQUIRES_LABEL .. " " .. STORY_PROGRESS, questID = 29824, showWWW = true, wwwLink = "wowhead.com/quest=29824", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            end

          end

          if self.db.profile.showMiniMapEnchanting then
              minimap[371][46824287] = { name = L["Enchanting"], type = "Enchanting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
          end

          if self.db.profile.showMiniMapInscription then
            minimap[390][81902863] = { name = INSCRIPTION, type = "Inscription", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            minimap[371][55004500] = { name = INSCRIPTION, type = "Inscription", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
          end

          -- not mixed
          if not self.db.profile.showMiniMapProfessionsMixed then

            if self.db.profile.showMiniMapSkinning then

              if self.faction == "Horde" then
                minimap[371][27791536] = { name = L["Skinning"], type = "Skinning", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
              end

              if self.faction == "Alliance" then
                minimap[371][44848553] = { name = L["Skinning"], type = "Skinning", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
              end

            end

            if self.db.profile.showMiniMapInscription then
              minimap[371][47603500] = { name = INSCRIPTION, type = "Inscription", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
              minimap[379][50604230] = { name = INSCRIPTION, type = "Inscription", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            end

            if self.db.profile.showMiniMapCooking then
              minimap[376][52675166] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
              --minimap[379][50604180] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            end

            if self.db.profile.showMiniMapLeatherworking then
              --minimap[379][50604200] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            end

            if self.db.profile.showMiniMapHerbalism then
              minimap[376][53715129] = { name = L["Herbalism"], type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
              --minimap[379][50604230] = { name = L["Herbalism"], type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            end

            if self.db.profile.showMiniMapJewelcrafting then
              minimap[371][48073494] = { name = L["Jewelcrafting"], type = "Jewelcrafting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            end

            if self.db.profile.showMiniMapBlacksmith then
              --minimap[379][48604460] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
              minimap[371][48403690] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            end

            if self.db.profile.showMiniMapMining then
              --minimap[379][48604460] = { name = L["Mining"], type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
  
              if self.faction == "Horde" then
                minimap[371][27801480] = { name = L["Mining"], type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
              end

              if self.faction == "Alliance" then
                minimap[371][45108590] = { name = L["Mining"], type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
              end

            end

            if self.db.profile.showMiniMapMining or self.db.profile.showMiniMapBlacksmith then
              --minimap[379][48604460] = { dnID = FACTION_NEUTRAL .. " " .. MINIMAP_TRACKING_TRAINER_PROFESSION .. "\n" .. "\n" .. TextIconBlacksmith:GetIconString() .. " " .. L["Blacksmithing"] .. "\n" .. TextIconMining:GetIconString() .. " " .. L["Mining"], name = "", type = "ProfessionsMixed", showInZone = false, showOnContinent = false, showOnMinimap = true }
            end

            if self.db.profile.showMiniMapFishing then
              --minimap[379][51004020] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            end

            if self.db.profile.showMiniMapHerbalism then
                
              if self.faction == "Horde" then
                minimap[371][27801563] = { name = L["Herbalism"], type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
              end

              if self.faction == "Alliance" then
                minimap[371][45608600] = { name = L["Herbalism"], type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
              end

            end

          end

          if self.db.profile.showMiniMapProfessionsMixed then
            --minimap[379][48604460] = { dnID = FACTION_NEUTRAL .. " " .. MINIMAP_TRACKING_TRAINER_PROFESSION .. "\n" .. "\n" .. TextIconBlacksmith:GetIconString() .. " " .. L["Blacksmithing"] .. "\n" .. TextIconMining:GetIconString() .. " " .. L["Mining"], name = "", type = "ProfessionsMixed", showInZone = false, showOnContinent = false, showOnMinimap = true }
            --minimap[379][50604230] = { dnID = FACTION_NEUTRAL .. " " .. MINIMAP_TRACKING_TRAINER_PROFESSION .. "\n" .. "\n" .. TextIconInscription:GetIconString() .. " " .. INSCRIPTION .. "\n" .. TextIconHerbalism:GetIconString() .. " " .. L["Herbalism"] .. "\n" .. TextIconLeatherworking:GetIconString() .. " " .. L["Leatherworking"] .. "\n" .. TextIconCooking:GetIconString() .. " " .. PROFESSIONS_COOKING .. "\n" .. TextIconFishing:GetIconString() .. " " .. PROFESSIONS_FISHING, name = "", type = "ProfessionsMixed", showInZone = false, showOnContinent = false, showOnMinimap = true }
            minimap[371][48083510] = { dnID = FACTION_NEUTRAL .. " " .. MINIMAP_TRACKING_TRAINER_PROFESSION .. "\n" .. "\n" .. TextIconInscription:GetIconString() .. " " .. INSCRIPTION .. "\n" .. TextIconJewelcrafting:GetIconString() .. " " .. L["Jewelcrafting"] .. "\n" .. TextIconBlacksmith:GetIconString() .. " " .. L["Blacksmithing"], name = "", type = "ProfessionsMixed", showInZone = false, showOnContinent = false, showOnMinimap = true }
            minimap[376][52675166] = { dnID = FACTION_NEUTRAL .. " " .. MINIMAP_TRACKING_TRAINER_PROFESSION .. "\n" .. "\n" .. TextIconHerbalism:GetIconString() .. " " .. L["Herbalism"] .. "\n" .. TextIconCooking:GetIconString() .. " " .. PROFESSIONS_COOKING, name = "", type = "ProfessionsMixed", showInZone = false, showOnContinent = false, showOnMinimap = true }

            if self.faction == "Horde" then
              minimap[371][27071522] = { dnID = ITEM_REQ_HORDE .. "\n" .. "\n" .. TextIconHerbalism:GetIconString() .. " " .. L["Herbalism"] .. "\n" .. TextIconMining:GetIconString() .. " " .. L["Mining"] .. "\n" .. TextIconSkinning:GetIconString() .. " " .. L["Skinning"], name = "", type = "ProfessionsMixed", showInZone = false, showOnContinent = false, showOnMinimap = true }
            end

            if self.faction == "Alliance" then
              minimap[371][44748643] = { dnID = ITEM_REQ_ALLIANCE .. "\n" .. "\n" .. TextIconHerbalism:GetIconString() .. " " .. L["Herbalism"] .. "\n" .. TextIconMining:GetIconString() .. " " .. L["Mining"] .. "\n" .. TextIconSkinning:GetIconString() .. " " .. L["Skinning"], name = "", type = "ProfessionsMixed", showInZone = false, showOnContinent = false, showOnMinimap = true }
            end

          end

        end

      end

        end -- if db.activate.ZoneMap then
    end -- if not db.activate.HideMapNote then
end -- function ns.LoadMoPZoneInfo(self)