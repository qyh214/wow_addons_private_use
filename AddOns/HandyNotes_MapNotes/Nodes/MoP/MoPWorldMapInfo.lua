local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

function ns.LoadMoPWorldMapInfo(self)
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
                    nodes[947][22013936] = { id = 78, mnID = 198, name = DUNGEON_FLOOR_FIRELANDS0 .. " " .. "[" .. LEVEL .. ": " .. "85]", type = "Raid", showInZone = true} -- Firelands
                    nodes[947][16987835] = { id = 74, name = "",  dnID = "[" .. LEVEL .. ": " .. "85]", type = "Raid", showInZone = true} -- Throne of the Four Winds
                    nodes[947][15147194] = { mnID = 81, name = L["Temple of Ahn'Qiraj"] .. " " .. "[" .. LEVEL .. ": " .. "60+]", type = "Raid", showInZone = true}
    				nodes[947][13437065] = { mnID = 81, name = DUNGEON_FLOOR_RUINSOFAHNQIRAJ1 .. " " .. "[" .. LEVEL .. ": " .. "60+]", type = "Raid", showInZone = true}
    			    nodes[947][23366161] = { mnID = 70, name = DUNGEON_FLOOR_ONYXIASLAIR1 .. " " .. "[" .. LEVEL .. ": " .. "60+]", type = "Raid", showInZone = true}
                    nodes[947][25077010] = { mnID = 71, name = DUNGEON_FLOOR_COTMOUNTHYJAL1 .. " " .. "[" .. LEVEL .. ": " .. "70+]", type = "Raid", showInZone = true}
                end

            -- Dungeons
                if self.db.profile.showAzerothDungeons then
                    nodes[947][50084821] = { id = 67, mnID = 207, type = "Dungeon", showInZone = true } -- The Stonecore
                    nodes[947][19197635] = { id = 69, mnID = 249, name = "", dnID = "[" .. LEVEL .. ": " .. "84-85]", type = "Dungeon", showInZone = true} -- Lost City of Tol'Vir
                    nodes[947][20907506] = { id = 70, mnID = 249, name = "", dnID = "[" .. LEVEL .. ": " .. "84-85]", type = "Dungeon", showInZone = true} -- Halls of Origination
                    nodes[947][21157874] = { id = 68, mnID = 249, name = "", dnID = "[" .. LEVEL .. ": " .. "81-85]", type = "Dungeon", showInZone = true} -- The Vortex Pinnacle
                    nodes[947][15633865] = { id = 227, mnID = 63, name = L["Blackfathom Deeps"] .. " " .. "[" .. LEVEL .. ": " .. "24-32]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "15", type = "Dungeon", showInZone = true}
    			    nodes[947][15145888] = { id = 230, mnID = 69, name = L["Dire Maul"] .. " " .. "[" .. LEVEL .. ": " .. "55-60]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "45", type = "Dungeon", showInZone = true}
                    nodes[947][17105961] = { id = 230, mnID = 69, name = L["Dire Maul"] .. " " .. "[" .. LEVEL .. ": " .. "55-60]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "45", type = "Dungeon", showInZone = true}
                    nodes[947][12205281] = { id = 232, mnID = 66, name = DUNGEON_FLOOR_MARAUDON1 .. " " .. "[" .. LEVEL .. ": " .. "46-55]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "30", type = "Dungeon", showInZone = true}
    			    nodes[947][21156164] = { id = 233, mnID = 10, name = DUNGEON_FLOOR_RAZORFENDOWNS1 .. " " .. "[" .. LEVEL .. ": " .. "37-46]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "35", type = "Dungeon", showInZone = true}
                    nodes[947][19926053] = { id = 234, mnID = 10, name = DUNGEON_FLOOR_RAZORFENKRAUL1 .. " " .. "[" .. LEVEL .. ": " .. "29-38]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "25", type = "Dungeon", showInZone = true}
    			    nodes[947][20665152] = { id = 240, mnID = 10, name = DUNGEON_FLOOR_WAILINGCAVERNS1 .. " " .. "[" .. LEVEL .. ": " .. "17-24]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "10", type = "Dungeon", showInZone = true}
                    nodes[947][22136642] = { id = 241, mnID = 71, name = DUNGEON_FLOOR_ZULFARRAK .. " " .. "[" .. LEVEL .. ": " .. "42-56", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "35", type = "Dungeon", showInZone = true}
    			    --nodes[947][26765129] = { mnID = 1454, name = DUNGEON_FLOOR_RAGEFIRE1 .. " " .. "[" .. LEVEL .. ": " .. "13-18]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "8", type = "Dungeon", showInZone = true}
                end

            -- Multi

                if self.db.profile.showAzerothMultiple then
                    nodes[947][25077010] = { mnID = 71, name = "", dnID = DUNGEON_FLOOR_DRAGONBLIGHTCHROMIESCENARIO4 .. " " .. "[" .. LEVEL .. ": " .. "85]" .. "\n" .. DUNGEON_FLOOR_COTMOUNTHYJAL1 .. " " .. "[" .. LEVEL .. ": " .. "70+]" .. "\n" .. DUNGEON_FLOOR_COTTHEBLACKMORASS1 .. " " .. "[" .. LEVEL .. ": " .. "70+]" .. "\n" .. L["Old Hillsbrad Foothills"] .. " " .. "[" .. LEVEL .. ": " .. "66-68]" .. "\n" .. L["The Culling of Stratholme"] .. " " .. "[" .. LEVEL .. ": " .. "79-80]" .. "\n" .. DUNGEON_FLOOR_HOUROFTWILIGHT0 .. " " .. "[" .. LEVEL .. ": " .. "85]" .. "\n" .. "Endtime" .. " " .. "[" .. LEVEL .. ": " .. "85]" .. "\n" .. "Dragonsoul" .. " " .. "[" .. LEVEL .. ": " .. "85]", type = "MultipleM", showInZone = true}
                end

            -- Blizz Pois
                if self.db.profile.activate.RemoveBlizzPOIs then

                    if self.faction == "Alliance" or db.activate.AzerothEnemyFaction then
                        nodes[947][13182412] = { mnID = 89, name = "", type = "AIcon", showInZone = true, TransportName = L["Darnassus"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " => " .. L["Blasted Lands"]}
                        nodes[947][06803350] = { mnID = 97, name = "", type = "AIcon", showInZone = true, TransportName = L["Exodar"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " => " .. L["Stormwind"]}
                    end

                    if self.faction == "Horde" or db.activate.AzerothEnemyFaction then
                        nodes[947][24834472] = { mnID = 85, name = "", type = "HIcon", showInZone = true, TransportName = DUNGEON_FLOOR_ORGRIMMAR0 .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Portals"] .. "\n" .. " => " .. L["Blasted Lands"] .. "\n" .. " => " .. DUNGEON_FLOOR_TOLBARADWARLOCKSCENARIO0 .. "\n" .. " => " .. L["Uldum"] .. "\n" .. " => " .. L["Twilight Highlands"] .. "\n" .. " => " .. POSTMASTER_LETTER_HYJAL .. "\n" .. " => " .. ARTIFACT_SHAMAN_TITLECARD_DEEPHOLM .. "\n" .. " => " .. L["Vashj'ir"] .. "\n" .. "\n" .. L["Zeppelin"] .. "\n" .. " => " .. L["Grom'gol, Stranglethorn Vale"] .. "\n" .. " => " .. L["Tirisfal Glades"] .. " - " .. L["Undercity"] .. "\n" .. " => " .. POSTMASTER_LETTER_WARSONGHOLD .. "\n" .. " => " .. L["Thunder Bluff"] .. "\n" .. "\n" ..CALENDAR_TYPE_DUNGEON .. "\n" .. " => " .. DUNGEON_FLOOR_RAGEFIRE1 } 
                        nodes[947][17595244] = { mnID = 88, name = "", type = "HIcon", showInZone = true, TransportName = L["Thunder Bluff"] .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " => " .. L["Blasted Lands"] .. "\n" .. "\n" .. L["Zeppelin"] .. "\n" .. " => " .. L["Durotar"] } 
                    end

                end


            -- Dungeons and not Blizz for Ragefire
                if self.db.profile.showAzerothDungeons and not self.db.profile.activate.RemoveBlizzPOIs then
                
                    if self.db.profile.showAzerothDungeons then
                        nodes[947][24834472] = { mnID = 86, name = DUNGEON_FLOOR_RAGEFIRE1 .. " " .. "[" .. LEVEL .. ": " .. "13-18]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "8", type = "Dungeon", showInZone = true}
                    end

                end


            -- Ships
                if self.db.profile.showAzerothShips then
                    nodes[947][25205870] = { mnID = 10, name = "", type = "Ship", showInZone = true, TransportName = L["Ratchet"] .. " - " .. FACTION_NEUTRAL .. "\n" .. "\n" .. L["Ship"] .. "\n" .. " => " .. POSTMASTER_LETTER_STRANGLETHORNVALE } -- Ship from Booty Bay to Ratchet
                
                    if self.faction == "Alliance" or db.activate.AzerothEnemyFaction then
                        --nodes[947][16183559] = { mnID = 1439, name = "", type = "AShip", showInZone = true, TransportName = L["Auberdine"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Ships"] .. "\n" .. " => " .. L["Stormwind"] .. "\n" .. " => " .. L["Teldrassil"] .. "\n" .. " => " .. L["Azuremyst Isle"]} -- Ship from Booty Bay to Ratchet
                        nodes[947][15512853] = { mnID = 57, name = "", type = "AShip", showInZone = true, TransportName = L["Teldrassil"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Ships"] .. "\n" .. " => " .. L["Azuremyst Isle"] .. "\n" .. " => " .. L["Stormwind"] } -- Ship from Booty Bay to Ratchet
                        nodes[947][25075870] = { mnID = 70, name = "", type = "AShip", showInZone = true, TransportName = L["Theramore Isle"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Ship"] .. "\n" .. " => " .. POSTMASTER_LETTER_WETLANDS } -- Ship from Dustwallow Marsh to Menethil Harbor
                        nodes[947][05213497] = { mnID = 57, name = "", type = "AShip", showInZone = true, TransportName = L["Ship"] .. "\n" .. " => " .. L["Rut'theran"]  } --
                    end

                end

            -- Portal
                if self.db.profile.showAzerothPortals then
                  nodes[947][22993534] = { mnID = 198, name = "", type = "Portal", showInZone = true, TransportName = POSTMASTER_LETTER_HYJAL .. " " .. L["Portals"] .. "\n" .. " => " .. DUNGEON_FLOOR_ORGRIMMAR0 .. "\n" .. " => " .. L["Stormwind"] }
                end

            end -- if self.db.profile.showAzerothKalimdor then


        --##########################
        --##### Eastern Kingdom ####
        --##########################
            if self.db.profile.showAzerothEasternKingdom then

            -- Raids            
                if self.db.profile.showAzerothRaids then
				    nodes[947][82946182] = { id = 73, mnID = 36, name = DUNGEON_FLOOR_MOLTENCORE1 .. " " .. "[" .. LEVEL .. ": " .. "60+]", type = "Raid", showInZone = true}
                    nodes[947][88461456] = { mnID = 122, name = DUNGEON_FLOOR_SUNWELLPLATEAU0 .. " " .. "[" .. LEVEL .. ": " .. "70+]", type = "Raid", showInZone = true}
                    nodes[947][84546991] = { mnID = 42, name = L["Karazhan"] .. " " .. "[" .. LEVEL .. ": " .. "70+]", type = "Raid", showInZone = true}
                    nodes[947][74244913] = { id = 75, name = "", dnID = "[" .. LEVEL .. ": " .. "85]", type = "Raid", showInZone = true} -- Baradin Hold
                    nodes[947][88215391] = { id = 72, name ="", dnID = "[" .. LEVEL .. ": " .. "85]", type = "Raid", showInZone = true} -- Bastion
                end


            -- Dungeons
                if self.db.profile.showAzerothDungeons then
                    nodes[947][86995171] = { id = 65, mnID = 204, name = "", dnID = "[" .. LEVEL .. ": " .. "84-85]", type = "Dungeon", showInZone = true} -- Grim Batol
                    nodes[947][71665594] = { id = 71, mnID = 241, name = "", dnID = "[" .. LEVEL .. ": " .. "80-85]", type = "Dungeon", showInZone = true} -- Throne of Tides
                    nodes[947][83077230] = { id = 76, mnID = 210, name = DUNGEON_FLOOR_ZULGURUB1 .. " " .. "[" .. LEVEL .. ": " .. "60+]", type = "Dungeon", showInZone = true} -- Zul Gurub
                    nodes[947][78164141] = { id = 64, mnID = 21, name = L["Shadowfang Keep"] .. " " .. "[" .. LEVEL .. ": " .. "22-30]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "14", type = "Dungeon", showInZone = true}
				    nodes[947][85393755] = { id = 246, mnID = 22, name = L["Scholomance"] .. " " .. "[" .. LEVEL .. ": " .. "58-60]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "48", type = "Dungeon", showInZone = true}
				    nodes[947][82083350] = { id = 311, mnID = 18, name = DUNGEON_FLOOR_TIRISFAL13 .. " " .. "[" .. LEVEL .. ": " .. "22-30]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "21", type = "Dungeon", showInZone = true}
				    nodes[947][86993221] = { id = 236, mnID = 23, name = DUNGEON_FLOOR_COTSTRATHOLME1 .. " " .. "[" .. LEVEL .. ": " .. "42-52]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "48", type = "Dungeon", showInZone = true}
                    nodes[947][88463295] = { id = 236, mnID = 23, name = DUNGEON_FLOOR_COTSTRATHOLME1 .. " " .. "[" .. LEVEL .. ": " .. "46-56]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "48", type = "Dungeon", showInZone = true}
                    nodes[947][87606807] = { id = 237, mnID = 51, name = DUNGEON_FLOOR_THETEMPLEOFATALHAKKAR1 .. " " .. "[" .. LEVEL .. ": " .. "50-56]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "45", type = "Dungeon", showInZone = true}
				    nodes[947][87605814] = { id = 239, mnID = 15, name = DUNGEON_FLOOR_BADLANDS18 .. " " .. "[" .. LEVEL .. ": " .. "41-51]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "30", type = "Dungeon", showInZone = true}
				    nodes[947][86625667] = { id = 239, mnID = 15, name = DUNGEON_FLOOR_BADLANDS18 .. " " .. "[" .. LEVEL .. ": " .. "41-51]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "30", type = "Dungeon", showInZone = true}
                    nodes[947][80005447] = { id = 231, mnID = 27, name = DUNGEON_FLOOR_DUNMOROGH10 .. " " .. "[" .. LEVEL .. ": " .. "29-38]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "19", type = "Dungeon", showInZone = true}
                    nodes[947][78287010] = { id = 63, mnID = 52, name = DUNGEON_FLOOR_THEDEADMINES1 .. " " .. "[" .. LEVEL .. ": " .. "17-26]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "10", type = "Dungeon", showInZone = true}
                    nodes[947][90422945] = { id = 77, mnID = 95, name = DUNGEON_FLOOR_ZULAMAN1 .. " " .. "[" .. LEVEL .. ": " .. "70]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "70", type = "Dungeon", showInZone = true}
                    nodes[947][89441345] = { id = 249, mnID = 122, name = L["Magisters' Terrace"] .. " " .. "[" .. LEVEL .. ": " .. "70]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "70", type = "Dungeon", showInZone = true}
                end

            -- Multi

                if self.db.profile.showAzerothMultiple then
				    nodes[947][82946182] = { id = { 73 }, mnID = 36, name = DUNGEON_FLOOR_MOLTENCORE1 .. " " .. "[" .. LEVEL .. ": " .. "60+]" .. "\n" .. DUNGEON_FLOOR_BURNINGSTEPPES15 .. " " .. "[" .. LEVEL .. ": " .. "80-85]" .. "\n" .. DUNGEON_FLOOR_BURNINGSTEPPES14 .. " " .. "[" .. LEVEL .. ": " .. "55-60]" .. "\n" .. DUNGEON_FLOOR_BURNINGSTEPPES16 .. " " .. "[" .. LEVEL .. ": " .. "52-60]", type = "MultipleM", showInZone = true}
                end

            -- Blizz POIS

                if self.db.profile.activate.RemoveBlizzPOIs then

                    if self.faction == "Horde" or db.activate.AzerothEnemyFaction then
                        nodes[947][80373755] = { mnID = 998, name = "", type = "HIcon", showInZone = true, TransportName = L["Undercity"] .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " => " .. L["Silvermoon City"] }
                        nodes[947][89072155] = { mnID = 110, name = "", type = "HIcon", showInZone = true, TransportName = L["Silvermoon City"] .. " - " .. FACTION_HORDE  .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " => " .. L["Undercity"] .. "\n" .. " => " .. L["Blasted Lands"]  }
                    end
        
                    if self.faction == "Alliance" or db.activate.AzerothEnemyFaction then
                        nodes[947][82335428] = { mnID = 87, name = "", type = "AIcon", showInZone = true, TransportName = L["Ironforge"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. DUNGEON_FLOOR_DEEPRUNTRAM1 .. "\n" .. " => " .. L["Stormwind"] .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " => " .. L["Blasted Lands"] } -- Transport to Ironforge Carriage 
                        nodes[947][79636384] = { mnID = 84, name = "", type = "AIcon", showInZone = true, TransportName = L["Stormwind"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. DUNGEON_FLOOR_DEEPRUNTRAM1 .. "\n" .. " => " .. L["Ironforge"] .. "\n" .. "\n" .. L["Portals"] .. "\n" .. " => " .. POSTMASTER_LETTER_VALIANCEKEEP .. "\n" .. " => " .. L["Uldum"] .. "\n" .. " => " .. L["Vashj'ir"] .. "\n" .. " => " .. POSTMASTER_LETTER_HYJAL .. "\n" .. " => " .. ARTIFACT_SHAMAN_TITLECARD_DEEPHOLM .. "\n" .. " => " .. L["Twilight Highlands"] .. "\n" .. " => " .. DUNGEON_FLOOR_TOLBARADWARLOCKSCENARIO0 .. "\n" .. "\n" .. L["Ships"] .. "\n" .. " => " .. POSTMASTER_LETTER_VALIANCEKEEP .. "\n" .. " => " .. L["Rut'theran"] .. "\n" .. "\n" ..  CALENDAR_TYPE_DUNGEON .. "\n" .. " => " .. DUNGEON_FLOOR_THESTOCKADE1 }
                    end

                end

            -- Dungeons and not Blizz for Stockade

                if self.db.profile.showAzerothDungeons and not self.db.profile.activate.RemoveBlizzPOIs then
                
                    if self.db.profile.showAzerothDungeons then
                        nodes[947][79636384] = { mnID = 84, name = DUNGEON_FLOOR_THESTOCKADE1 .. " " .. "[" .. LEVEL .. ": " .. "22-30]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "15", type = "Dungeon", showInZone = true}
                    end

                end


            -- Zeppelin
                if self.db.profile.showAzerothZeppelins then   

                    if self.faction == "Horde" or db.activate.AzerothEnemyFaction then
                        nodes[947][80253516] = { mnID = 18, name = "", type = "HZeppelin", showInZone = true, TransportName = L["Tirisfal Glades"] .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Zeppelin"] .. "\n" .. " => " .. L["Grom'gol, Stranglethorn Vale"] .. "\n" .. " => " .. L["Durotar"] }
                        nodes[947][80747359] = { mnID = 210, name = "", type = "HZeppelin", showInZone = true, TransportName = L["Grom'gol, Stranglethorn Vale"] .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Zeppelin"] .. "\n" .. " => " .. DUNGEON_FLOOR_ORGRIMMAR0.. "\n" .. " => " .. L["Tirisfal Glades"] .. " - " .. L["Undercity"] }
                    end

                end


            -- Azeroth Eastern Kingdom Transport and not RemoveBlizzPOIs
                if self.db.profile.showAzerothTransport and not self.db.profile.activate.RemoveBlizzPOIs then

                    if self.faction == "Alliance" or db.activate.AzerothEnemyFaction then
                        nodes[947][82455428] = { mnID = 87, name = "", type = "Carriage", showInZone = true, TransportName = L["Ironforge"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. DUNGEON_FLOOR_DEEPRUNTRAM1 .. "\n" .. " => " .. L["Stormwind"] } -- Transport to Ironforge Carriage 
                        nodes[947][80616421] = { mnID = 37, name = "", type = "Carriage", showInZone = true, TransportName = L["Stormwind"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. DUNGEON_FLOOR_DEEPRUNTRAM1 .. "\n" .. " => " .. L["Ironforge"] } -- Transport to Ironforge Carriage 
                    end

                end


            -- Ships
                if self.db.profile.showAzerothShips then
                    nodes[947][80007837] = { mnID = 210, name = "", type = "Ship", showInZone = true, TransportName = POSTMASTER_LETTER_STRANGLETHORNVALE .. " - " .. FACTION_NEUTRAL .. "\n" .. "\n" .. L["Ship"] .. "\n" .. " => " .. L["Ratchet"] } -- Ship from Booty Bay to Ratchet
                    
                    if self.faction == "Alliance" or db.activate.AzerothEnemyFaction then
                        nodes[947][82215079] = { mnID = 56, name = "", type = "AShip", showInZone = true, TransportName = POSTMASTER_LETTER_WETLANDS .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Ships"] .. "\n" .. " => " .. L["Theramore Isle"] .. "\n" .. " => " .. L["Howling Fjord"] } -- Ship from Menethil Harbor to Howling Fjord and Dustwallow Marsh
                    end

                end


            -- Portals
                if self.db.profile.showContinentPortals then
                    nodes[947][86507230] = { mnID = 17, name = "", type = "Portal", showInZone = true, TransportName = SPLASH_BASE_90_RIGHT_TITLE .. " => " .. L["Hellfire Peninsula"] }
                end

            end -- if self.db.profile.showAzerothEasternKingdom then


        --############################
        --##### Azeroth Northrend ####
        --############################
            if self.db.profile.showAzerothNorthrend then
    
            -- Azeroth Northrend Dungeons
                if self.db.profile.showAzerothDungeons then
                    nodes[947][61612688] = { id = 286, mnID = 117, showInZone = true, name ="", dnID = L["Utgarde Pinnacle"] .. " " .. "[" .. LEVEL .. ": " .. "79-80]" .. "\n" .. L["Utgarde Keep"] .. " " .. "[" .. LEVEL .. ": " .. "70-72]", type = "Dungeon" } -- Utgarde Pinnacle 
                    nodes[947][56130604] = { id = 275, mnID = 120, showInZone = true, name = DUNGEON_FLOOR_HALLSOFORIGINATION1 .. " " .. "[" .. LEVEL .. ": " .. "79-80]", type = "Dungeon" } -- Halls of Lightning 
                    nodes[947][54160733] = { id = 277, mnID = 120, showInZone = true, name = DUNGEON_FLOOR_ULDUAR771 .. " " .. "[" .. LEVEL .. ": " .. "77-79]", type = "Dungeon" } -- Halls of Stone 
                    nodes[947][56581768] = { id = 273, mnID = 121, showInZone = true, name = L["Drak'Tharon Keep"] .. " " .. "[" .. LEVEL .. ": " .. "74-76]", type = "Dungeon" } -- Drak'Tharon Keep 
                    nodes[947][60751125] = { id = 274, mnID = 121, showInZone = true, name = DUNGEON_FLOOR_GUNDRAK1 .. " " .. "[" .. LEVEL .. ": " .. "76-78]", type = "Dungeon" } -- Gundrak Left Entrance 
                    nodes[947][61611345] = { id = 274, mnID = 121, showInZone = true, name = DUNGEON_FLOOR_GUNDRAK1 .. " " .. "[" .. LEVEL .. ": " .. "76-78]", type = "Dungeon" } -- Gundrak Right Entrance 
                    nodes[947][52321712] = { id = 283, mnID = 127, showInZone = true, name = DUNGEON_FLOOR_VIOLETHOLD1 .. " " .. "[" .. LEVEL .. ": " .. "75-77]", type = "Dungeon" } -- Violet Hold
                    nodes[947][49721603] = { id = 276, mnID = 118, showInZone = true, name = "", dnID = DUNGEON_FLOOR_THEFORGEOFSOULS1 .. " " .. "[" .. LEVEL .. ": " .. "79-80]" .. "\n" .. DUNGEON_FLOOR_HALLSOFREFLECTION1 .. " " .. "[" .. LEVEL .. ": " .. "79-80]" .. "\n" .. DUNGEON_FLOOR_PITOFSARON1 .. " " .. "[" .. LEVEL .. ": " .. "79-80]", type = "Dungeon" } -- The Forge of Souls, Halls of Reflection, Pit of Saron         
                    nodes[947][49352044] = { id = 271, mnID = 115, showInZone = true, name = "", dnID = DUNGEON_FLOOR_AHNKAHET1 .. " " .. "[" .. LEVEL .. ": " .. "73-75]" .. "\n" .. L["Azjol-Nerub"] .. " " .. "[" .. LEVEL .. ": " .. "72-74]", type = "Dungeon" } -- Ahn'kahet The Old Kingdom, Azjol-Nerub 
                end
        
        
            -- Azeroth Northrend Raids
                if self.db.profile.showAzerothRaids then
                    nodes[947][55112044] = { showInZone = true, mnID = 115, name = L["Naxxramas"] .. " " .. "[" .. LEVEL .. ": " .. "80+]", type = "Raid" } -- Naxxramas 
                    nodes[947][49351474] = { showInZone = true, mnID = 118, name = DUNGEON_FLOOR_ICECROWNCITADELDEATHKNIGHT3 .. " " .. "[" .. LEVEL .. ": " .. "80+]", type = "Raid" } -- Icecrown Citadel 
                    nodes[947][54870518] = { showInZone = true, mnID = 120, name = L["Ulduar"] .. " " .. "[" .. LEVEL .. ": " .. "80+]",type = "Raid" } -- Ulduar
                    nodes[947][47881529] = { showInZone = true, mnID = 123, name = DUNGEON_FLOOR_VAULTOFARCHAVON1  .. " " .. "[" .. LEVEL .. ": " .. "80+]", type = "Raid" } -- Vault of Archavon
                    nodes[947][52782063] = { showInZone = true, mnID = 115, name = "", dnID = DUNGEON_FLOOR_THEOBSIDIANSANCTUM1 .. " " .. "[" .. LEVEL .. ": " .. "80+]" .. "\n" .. L["The Ruby Sanctum"] .. " " .. "[" .. LEVEL .. ": " .. "80+]", type = "Raid" } -- The Ruby Sanctum, The Obsidian Sanctum 
                    nodes[947][38222229] = { showInZone = true, mnID = 114, name = "", dnID = DUNGEON_FLOOR_THEEYEOFETERNITY1 .. " " .. "[" .. LEVEL .. ": " .. "80+]", type = "Raid" } -- The Eye of Eternity, The Nexus, The Oculus
                    nodes[947][51560739] = { showInZone = true, mnID = 118, name = "", dnID = L["Trial of the Crusader"] .. " " .. "[" .. LEVEL .. ": " .. "80+]", type = "Raid" } -- Trial of the Crusader, Trial of the Champion 
                end
        
        
            -- Azeroth Northrend Multiple
                if self.db.profile.showAzerothMultiple then
                    nodes[947][61612688] = { showInZone = true, mnID = 117, name ="", dnID = L["Utgarde Pinnacle"] .. " " .. "[" .. LEVEL .. ": " .. "79-80]" .. "\n" .. L["Utgarde Keep"] .. " " .. "[" .. LEVEL .. ": " .. "70-72]", type = "MultipleD" } -- Utgarde Pinnacle 
                    nodes[947][49352044] = { showInZone = true, mnID = 115, name = "", dnID = DUNGEON_FLOOR_AHNKAHET1 .. " " .. "[" .. LEVEL .. ": " .. "73-75]" .. "\n" .. L["Azjol-Nerub"] .. " " .. "[" .. LEVEL .. ": " .. "72-74]", type = "MultipleD" } -- Ahn'kahet The Old Kingdom, Azjol-Nerub        
                    nodes[947][49721603] = { showInZone = true, mnID = 118, name = "", dnID = DUNGEON_FLOOR_THEFORGEOFSOULS1 .. " " .. "[" .. LEVEL .. ": " .. "79-80]" .. "\n" .. DUNGEON_FLOOR_HALLSOFREFLECTION1 .. " " .. "[" .. LEVEL .. ": " .. "79-80]" .. "\n" .. DUNGEON_FLOOR_PITOFSARON1 .. " " .. "[" .. LEVEL .. ": " .. "79-80]", type = "MultipleD" } -- The Forge of Souls, Halls of Reflection, Pit of Saron         
                    nodes[947][51560739] = { showInZone = true, mnID = 118, name = "", dnID = L["Trial of the Champion"] .. " " .. "[" .. LEVEL .. ": " .. "79-80]" .. "\n" .. L["Trial of the Crusader"] .. " " .. "[" .. LEVEL .. ": " .. "80+]", type = "MultipleM" } -- Trial of the Crusader, Trial of the Champion 
                    nodes[947][38222229] = { showInZone = true, mnID = 114, name = "", dnID = DUNGEON_FLOOR_THEEYEOFETERNITY1 .. " " .. "[" .. LEVEL .. ": " .. "80+]" .. "\n" .. DUNGEON_FLOOR_THENEXUS1 .. " " .. "[" .. LEVEL .. ": " .. "71-73]" .. "\n" .. L["The Oculus"]  .. " " .. "[" .. LEVEL .. ": " .. "79-80]", type = "MultipleM" } -- The Eye of Eternity, The Nexus, The Oculus
                    nodes[947][52782063] = { showInZone = true, mnID = 115, name = "", dnID = DUNGEON_FLOOR_THEOBSIDIANSANCTUM1 .. " " .. "[" .. LEVEL .. ": " .. "80+]" .. "\n" .. L["The Ruby Sanctum"] .. " " .. "[" .. LEVEL .. ": " .. "80+]", type = "MultipleR" } -- The Ruby Sanctum, The Obsidian Sanctum 
                end
        
        
            -- Azeroth Northrend Portals
                if self.db.profile.showAzerothPortals then
                    nodes[947][48001676] = { mnID = 123, name = "", type = "Portal", showInZone = true, TransportName = L["Wintergrasp"] .. " " .. L["Portal"] .. "\n" .. " => " .. DUNGEON_FLOOR_DALARANCITY1 } -- LakeWintergrasp to Dalaran Portal
                    nodes[947][51801474] = { mnID = 125, name = "", type = "Portal", showInZone = true, TransportName = DUNGEON_FLOOR_DALARANCITY1 .. " " .. L["Portals"] .. "\n" ..  "\n" .. " => " .. DUNGEON_FLOOR_ORGRIMMAR0  .. "\n" .. " => " .. L["Stormwind"] } -- Portal from Old Dalaran to Orgrimmar and Stormwind
                end
    
            -- Azeroth Northrend Zeppelins
                if self.db.profile.showAzerothZeppelins then
        
                    if self.faction == "Horde" or db.activate.AzerothEnemyFaction then
                        nodes[947][63692486] = { mnID = 117, name = "", type = "HZeppelin", showInZone = true, TransportName = L["Howling Fjord"] .. " " .. L["Zeppelin"] .. "\n" .. " => " .. L["Tirisfal Glades"] .. " - " .. L["Undercity"] } -- Zeppelin from Borean Tundra to Ogrimmar
                        nodes[947][42612247] = { mnID = 114, name = "", type = "HZeppelin", showInZone = true, TransportName = POSTMASTER_LETTER_WARSONGHOLD .. " " .. L["Zeppelin"] .. "\n" .. " => " .. L["Durotar"] } -- Zeppelin from Borean Tundra to Ogrimmar
                    end

                end
        
        
            -- Azeroth Northrend Ships
                if self.db.profile.showAzerothShips then
                    nodes[947][57322798] = { mnID = 117, name = "", type = "Ship", showInZone = true, TransportName = POSTMASTER_LETTER_KAMAGUA .. " " .. L["Ship"] .. "\n" .. " => " .. POSTMASTER_LETTER_MOAKI } -- Ship from Kamagua to Moaki
                    nodes[947][52662375] = { mnID = 115, name = "", type = "Ship", showInZone = true, TransportName = POSTMASTER_LETTER_MOAKI .. " " .. L["Ship"] .. "\n" .. " => " .. POSTMASTER_LETTER_KAMAGUA } -- Ship from Kamagua to Moaki
                    nodes[947][50942339] = { mnID = 115, name = "", type = "Ship", showInZone = true, TransportName = POSTMASTER_LETTER_MOAKI .. " " .. L["Ship"] .. "\n" .. " => " .. POSTMASTER_LETTER_KAMAGUA .. "\n" .. " => " .. L["Borean Tundra"] } -- Ship from Moaki to Kamagua
                    nodes[947][46162302] = { mnID = 114, name = "", type = "Ship", showInZone = true, TransportName = L["Borean Tundra"] .. " " .. L["Ship"] .. "\n" .. " => " .. POSTMASTER_LETTER_MOAKI } -- Ship from Unu'pe to Moaki
                    
                    if self.faction == "Alliance" or db.activate.AzerothEnemyFaction then
                        nodes[947][44082467] = { mnID = 114, name = "", type = "AShip", showInZone = true, TransportName = POSTMASTER_LETTER_VALIANCEKEEP .. " " ..  L["Ship"] .. "\n" .. " => " .. L["Stormwind"] } -- Ship from Borean Tundra to Stormwind
                        nodes[947][61732853] = { mnID = 117, name = "", type = "AShip", showInZone = true, TransportName = L["Howling Fjord"] .. " " .. L["Ship"] .. "\n" .. " => " .. POSTMASTER_LETTER_WETLANDS } -- Ship from Howling Fjord to Wetlands
                    end

                end

            end -- if self.db.profile.showAzerothNorthrend then


        --###########################
        --##### Azeroth Pandaria ####
        --###########################
    
        if self.db.profile.showAzerothPandaria then
    
        -- Azeroth Pandaria Dungeons
          if self.db.profile.showAzerothDungeons then
            nodes[947][58548371] = { id = 313, mnID = 371, type = "Dungeon", showInZone = true } -- Temple of the Jade Serpent
            nodes[947][51568849] = { id = 302, mnID = 376, type = "Dungeon", showInZone = true } -- Stormstout Brewery
            nodes[947][49107617] = { id = 312, mnID = 379, type = "Dungeon", showInZone = true } -- Shado-Pan Monastery
            nodes[947][44328242] = { id = 324, mnID = 388, type = "Dungeon", showInZone = true } -- Siege of Niuzao Temple
            nodes[947][49968463] = { id = 303, mnID = 390, type = "Dungeon", showInZone = true } -- Gate of the Setting Sun
            nodes[947][52658297] = { id = 321, mnID = 390, type = "Dungeon", showInZone = true } -- Mogu'shan Palace
          end
    
    
        -- Azeroth Pandaria Raids
          if self.db.profile.showAzerothRaids then
            nodes[947][47857509] = { id = 317, mnID = 379, type = "Raid", showInZone = true } -- Mogu'shan Vaults
            nodes[947][43598371] = { id = 330, mnID = 422, type = "Raid", showInZone = true } -- Heart of Fear
            --nodes[947][41077005] = { id = 362, mnID = 504, type = "Raid", showInZone = true } -- Throne of Thunder
            nodes[947][49858198] = { id = 320, mnID = 433, type = "Raid", showInZone = true } -- Terrace of Endless Spring 
            --nodes[947][47348150] = { id = 1180, mnID = 390, type = "Raid", showInZone = true, dnID = L["Instance Entrance"] .. " " .. L["switches weekly between"] .. " " .. L["Uldum"] .. " (" .. L["Kalimdor"] ..")" .. " & " .. L["Vale of Eternal Blossoms"] .. " (" .. L["Pandaria"] .. ")"} -- Ny'Alotha, The Waking City
        end
    
    
        -- Azeroth Pandaria Multiple
          if self.db.profile.showAzerothMultiple then
            --nodes[947][52658297] = { mnID = 390, hideInfo = true, id = {369, 321 }, type = "MultipleM", showInZone = true } -- Siege of Orgrimmar, Mogu'shan Palace
          end
    
    
        -- Azeroth Pandaria Portals
          if self.db.profile.showAzerothPortals then

            nodes[947][51808350] = { mnID = 390, name = "", type = "Portal", showInZone = true, TransportName = L["Vale of Eternal Blossoms"] .. " " .. L["Portals"] .. "\n" ..  "\n" .. " ==> " .. DUNGEON_FLOOR_ORGRIMMAR0 .. "\n" .. " ==> " .. L["Stormwind"] } -- Portal from Vale of Eternal Blossoms to Orgrimmar and Stormwind
            nodes[947][45928148] = { mnID = 388, name = "", type = "Portal", showInZone = true, TransportName = L["Shado-Pan Garrison, Townlong Steppes"] .. " " .. L["Portal"] .. "\n" .. " ==> " .. L["Isle of Thunder"] } -- Portal from Shado-Pan Garrison to Isle of Thunder
            nodes[947][43347249] = { mnID = 504, name = "", type = "Portal", showInZone = true, TransportName = L["Isle of Thunder"] .. " " .. L["Portals"] .. "\n" ..  "\n" .. " ==> " .. L["Shado-Pan Garrison, Townlong Steppes"] } -- Portal from Isle of Thunder to Shado-Pan Garrison

            if self.faction == "Horde" or db.activate.AzerothEnemyFaction then
              nodes[947][54997801] = { mnID = 371, name = "", type = "HPortal", showInZone = true, TransportName = L["Jade Forest"] .. " " .. L["Portal"]  .. "\n" .. " ==> " .. DUNGEON_FLOOR_ORGRIMMAR0 } -- Portal from Jade Forest to Orgrimmar
              nodes[947][49109161] = { mnID = 418, name = "", type = "HPortal", showInZone = true, TransportName = L["Krasarang Wilds"] .. " " .. L["Portal"] .. "\n" ..  "\n" .. " ==> " .. L["Silvermoon City"] } -- Portal to Silvermoon
            end

            if self.faction == "Alliance" or db.activate.AzerothEnemyFaction then
              nodes[947][57208739] = { mnID = 371, name = "", type = "APortal", showInZone = true, TransportName = L["Jade Forest"] .. " " .. L["Portal"]  .. "\n" .. " ==> " .. L["Stormwind"] } -- Portal from Jade Forest to Stormwind
            end
          end

        end
    
        end -- if db.activate.Azeroth then
    end -- if not db.activate.HideMapNote then
end -- function ns.LoadMoPWorldMapInfo(self)