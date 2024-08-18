local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

function ns.LoadCataContinentInfo(self)
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
          nodes[1414][54243572] = { mnID = 198, name = DUNGEON_FLOOR_FIRELANDS0 .. " " .. "[" .. LEVEL .. ": " .. "85]", type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Firelands
          nodes[1414][46059838] = { id = 74, name = "",  dnID = "[" .. LEVEL .. ": " .. "85]", type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Throne of the Four Winds
          nodes[1414][40808546] = { mnID = 1451, name = L["Temple of Ahn'Qiraj"] .. " " .. "[" .. LEVEL .. ": " .. "60+]", type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false }
          nodes[1414][42408638] = { mnID = 1451, name = DUNGEON_FLOOR_RUINSOFAHNQIRAJ1 .. " " .. "[" .. LEVEL .. ": " .. "60+]", type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false }
          nodes[1414][56327161] = { mnID = 1445, name = DUNGEON_FLOOR_ONYXIASLAIR1 .. " " .. "[" .. LEVEL .. ": " .. "60+]", type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false }
          nodes[1414][59038528] = { mnID = 1446, name = DUNGEON_FLOOR_COTMOUNTHYJAL1 .. " " .. "[" .. LEVEL .. ": " .. "70+]" , type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false }
        end

      -- Dungeons
        if self.db.profile.showContinentDungeons then
          nodes[948][51042844] = { id = 67, name = "", dnID = "[" .. LEVEL .. ": " .. "81-85]", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Stonecore
          nodes[1414][49929552] = { id = 69, name = "", dnID = "[" .. LEVEL .. ": " .. "84-85]", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Lost City of Tol'Vir
          nodes[1414][51679349] = { id = 70, name = "", dnID = "[" .. LEVEL .. ": " .. "84-85]", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Halls of Origination
          nodes[1414][52719898] = { id = 68, name = "", dnID = "[" .. LEVEL .. ": " .. "81-85]", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- The Vortex Pinnacle
          nodes[1414][43763504] = { mnID = 1440, name = L["Blackfathom Deeps"] .. " " .. "[" .. LEVEL .. ": " .. "24-32]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "15", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false}
          nodes[1414][42846759] = { mnID = 1444, name = L["Dire Maul"] .. " " .. "[" .. LEVEL .. ": " .. "55-60]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "45", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false}
          nodes[1414][45976847] = { mnID = 1444, name = L["Dire Maul"] .. " " .. "[" .. LEVEL .. ": " .. "55-60]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "45", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false}
          nodes[1414][38225775] = { mnID = 1443, name = DUNGEON_FLOOR_MARAUDON1 .. " " .. "[" .. LEVEL .. ": " .. "46-55]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "30", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false}
          nodes[1414][52397165] = { mnID = 1413, name = DUNGEON_FLOOR_RAZORFENDOWNS1 .. " " .. "[" .. LEVEL .. ": " .. "37-46]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "35", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false}
          nodes[1414][50657013] = { mnID = 1413, name = DUNGEON_FLOOR_RAZORFENKRAUL1 .. " " .. "[" .. LEVEL .. ": " .. "29-38]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "25", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false}
          nodes[1414][51885554] = { mnID = 1413, name = DUNGEON_FLOOR_WAILINGCAVERNS1 .. " " .. "[" .. LEVEL .. ": " .. "17-24]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "10", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false}
          nodes[1414][54107955] = { mnID = 1446, name = DUNGEON_FLOOR_ZULFARRAK .. " " .. "[" .. LEVEL .. ": " .. "42-56", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "35", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false}
        end

      -- Multi
        if self.db.profile.showContinentMultiple then
          nodes[1414][59038528] = { mnID = 1446, name = "", dnID = DUNGEON_FLOOR_DRAGONBLIGHTCHROMIESCENARIO4 .. " " .. "[" .. LEVEL .. ": " .. "85]" .. "\n" .. DUNGEON_FLOOR_COTMOUNTHYJAL1 .. " " .. "[" .. LEVEL .. ": " .. "70+]" .. "\n" .. DUNGEON_FLOOR_COTTHEBLACKMORASS1 .. " " .. "[" .. LEVEL .. ": " .. "70+]" .. "\n" .. L["Old Hillsbrad Foothills"] .. " " .. "[" .. LEVEL .. ": " .. "66-68]" .. "\n" .. L["The Culling of Stratholme"] .. " " .. "[" .. LEVEL .. ": " .. "79-80]" .. "\n" .. DUNGEON_FLOOR_HOUROFTWILIGHT0 .. " " .. "[" .. LEVEL .. ": " .. "85]" .. "\n" .. "Endtime" .. " " .. "[" .. LEVEL .. ": " .. "85]" .. "\n" .. "Dragonsoul" .. " " .. "[" .. LEVEL .. ": " .. "85]", type = "MultipleM", showOnContinent = true, showInZone = false, showOnMinimap = false}
        end

      -- Blizz Pois
        if self.db.profile.activate.RemoveBlizzPOIs then

          if self.faction == "Alliance" or db.activate.EnemyFaction then
            nodes[1414][39941176] = { mnID = 1457, name = "", type = "AIcon", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Darnassus"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " => " .. L["Blasted Lands"] }
            nodes[1414][29842672] = { mnID = 1943, name = "", type = "AIcon", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Exodar"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " => " .. L["Stormwind"] }
          end

          if self.faction == "Horde" or db.activate.EnemyFaction then
            nodes[1414][58164464] = { mnID = 1454, name = "", type = "HIcon", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = DUNGEON_FLOOR_ORGRIMMAR0 .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Portals"] .. "\n" .. " => " .. L["Blasted Lands"] .. "\n" .. " => " .. DUNGEON_FLOOR_TOLBARADWARLOCKSCENARIO0 .. "\n" .. " => " .. L["Uldum"] .. "\n" .. " => " .. L["Twilight Highlands"] .. "\n" .. " => " .. POSTMASTER_LETTER_HYJAL .. "\n" .. " => " .. ARTIFACT_SHAMAN_TITLECARD_DEEPHOLM .. "\n" .. " => " .. L["Vashj'ir"] .. "\n" .. "\n" .. L["Zeppelin"] .. "\n" .. " => " .. L["Grom'gol, Stranglethorn Vale"] .. "\n" .. " => " .. L["Tirisfal Glades"] .. " - " .. L["Undercity"] .. "\n" .. " => " .. POSTMASTER_LETTER_WARSONGHOLD .. "\n" .. " => " .. L["Thunder Bluff"] .. "\n" .. "\n" ..CALENDAR_TYPE_DUNGEON .. "\n" .. " => " .. DUNGEON_FLOOR_RAGEFIRE1 } 
            nodes[1414][46965720] = { mnID = 1456, name = "", type = "HIcon", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Thunder Bluff"] .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " => " .. L["Blasted Lands"] .. "\n" .. "\n" .. L["Zeppelin"] .. "\n" .. " => " .. L["Durotar"] } 
          end
           
        end

      -- Dungeons and not Blizz for Ragefire
        if self.db.profile.showContinentDungeons and not self.db.profile.activate.RemoveBlizzPOIs then
         
          if self.db.profile.showContinentDungeons then
            nodes[1414][58164464] = { mnID = 86, name = DUNGEON_FLOOR_RAGEFIRE1 .. " " .. "[" .. LEVEL .. ": " .. "13-18]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "8", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false}
          end

        end

      -- Zeppelin
        if self.db.profile.showContinentZeppelins then   

          if self.faction == "Horde" or db.activate.EnemyFaction then
            nodes[1414][59154686] = { mnID = 1411, name = "", type = "HZeppelin", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Durotar"] .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Zeppelin"] .. "\n" .. " => " .. L["Grom'gol, Stranglethorn Vale"] .. "\n" .. " => " .. L["Tirisfal Glades"] .. " - " .. L["Undercity"] }
            nodes[1414][57744778] = { mnID = 1411, name = "", type = "HZeppelin", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Zeppelin"] .. " - " .. FACTION_HORDE .. "\n" .. " => " .. POSTMASTER_LETTER_WARSONGHOLD .. "\n" .. " => " .. L["Thunder Bluff"] }
          end
             
        end

      -- Ships
        if self.db.profile.showContinentShips then
            nodes[1414][56955589] = { mnID = 1413, name = "", type = "Ship", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Ratchet"] .. " - " .. FACTION_NEUTRAL .. "\n" .. "\n" .. L["Ship"] .. "\n" .. " => " .. POSTMASTER_LETTER_STRANGLETHORNVALE } -- Ship from Booty Bay to Ratchet
            
            if self.faction == "Alliance" or db.activate.EnemyFaction then
              --nodes[1414][44132395] = { mnID = 1439, name = "", type = "AShip", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Auberdine"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Ships"] .. "\n" .. " => " .. L["Stormwind"] .. "\n" .. " => " .. L["Teldrassil"] .. "\n" .. " => " .. L["Azuremyst Isle"] } -- Ship from Booty Bay to Ratchet
              nodes[1414][43581878] = { mnID = 1438, name = "", type = "AShip", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Teldrassil"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Ship"] .. "\n" .. " => " .. L["Stormwind"] } -- Ship from Booty Bay to Ratchet
              nodes[1414][42701806] = { mnID = 1438, name = "", type = "AShip", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Teldrassil"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Ship"] .. "\n" .. " => " .. L["Azuremyst Isle"] } -- Ship from Booty Bay to Ratchet
              nodes[1414][59036699] = { mnID = 1445, name = "", type = "AShip", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Theramore Isle"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Ship"] .. "\n" .. " => " .. POSTMASTER_LETTER_WETLANDS } -- Ship from Dustwallow Marsh to Menethil Harbor
              nodes[1414][28682746] = { mnID = 1438, name = "", type = "AShip", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Ship"] .. "\n" .. " => " .. L["Rut'theran"] } --
            end
        end

      -- Portal
        if self.db.profile.showContinentPortals then
          nodes[1414][55842967] = { mnID = 198, name = "", type = "Portal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = POSTMASTER_LETTER_HYJAL .. " " .. L["Portals"] .. "\n" .. " => " .. DUNGEON_FLOOR_ORGRIMMAR0 .. "\n" .. " => " .. L["Stormwind"] }
        end

      end


    --##########################
    --##### Eastern Kingdom ####
    --##########################
      if self.db.profile.showContinentEasternKingdom then


      -- Raids            
        if self.db.profile.showContinentRaids then
          nodes[1415][47397031] = { mnID = 1428, name = DUNGEON_FLOOR_MOLTENCORE1 .. " " .. "[" .. LEVEL .. ": " .. "60+]", type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false}
          nodes[1415][54885912] = { id = 72, name ="", dnID = "[" .. LEVEL .. ": " .. "85]", type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false} -- Bastion
          nodes[1415][49678177] = { mnID = 1430, name = L["Karazhan"] .. " " .. "[" .. LEVEL .. ": " .. "70+]", type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false}
          nodes[1415][54470345] = { mnID = 1957, name = DUNGEON_FLOOR_SUNWELLPLATEAU0 .. " " .. "[" .. LEVEL .. ": " .. "70+]", type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false}
          nodes[1415][34885184] = { id = 75, name = "", dnID = "[" .. LEVEL .. ": " .. "85]", type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false}
        end

      -- Dungeons
        if self.db.profile.showContinentDungeons then
          nodes[1415][31416186] = { id = 65, name = "", dnID = "[" .. LEVEL .. ": " .. "80-85]", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Throne of the Tides
          nodes[1415][52975589] = { id = 71, name = "", dnID = "[" .. LEVEL .. ": " .. "84-85]", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false} -- Grim Batol
          nodes[1415][47648454] = { mnID = 1434, name = DUNGEON_FLOOR_ZULGURUB1 .. " " .. "[" .. LEVEL .. ": " .. "60+]", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false}
          nodes[1415][40624150] = { mnID = 1421, name = L["Shadowfang Keep"] .. " " .. "[" .. LEVEL .. ": " .. "22-30]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "14", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false}
          nodes[1415][50843614] = { mnID = 1422, name = L["Scholomance"] .. " " .. "[" .. LEVEL .. ": " .. "58-60]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "48", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false}
          nodes[1415][46413023] = { mnID = 1420, name = DUNGEON_FLOOR_TIRISFAL13 .. " " .. "[" .. LEVEL .. ": " .. "22-30]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "21", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false}
          nodes[1415][53302876] = { mnID = 1423, name = DUNGEON_FLOOR_COTSTRATHOLME1 .. " " .. "[" .. LEVEL .. ": " .. "42-52]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "48", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false}
          nodes[1415][54382928] = { mnID = 1423, name = DUNGEON_FLOOR_COTSTRATHOLME1 .. " " .. "[" .. LEVEL .. ": " .. "46-56]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "48", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false}
          nodes[1415][53927918] = { mnID = 1435, name = DUNGEON_FLOOR_THETEMPLEOFATALHAKKAR1 .. " " .. "[" .. LEVEL .. ": " .. "50-56]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "45", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false}
          nodes[1415][53676514] = { mnID = 1418, name = DUNGEON_FLOOR_BADLANDS18 .. " " .. "[" .. LEVEL .. ": " .. "41-51]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "30", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false}
          nodes[1415][52446311] = { mnID = 1418, name = DUNGEON_FLOOR_BADLANDS18 .. " " .. "[" .. LEVEL .. ": " .. "41-51]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "30", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false}
          nodes[1415][43085997] = { mnID = 1426, name = DUNGEON_FLOOR_DUNMOROGH10 .. " " .. "[" .. LEVEL .. ": " .. "29-38]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "19", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false}
          nodes[1415][40878158] = { mnID = 1436, name = DUNGEON_FLOOR_THEDEADMINES1 .. " " .. "[" .. LEVEL .. ": " .. "17-26]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "10", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false}
          nodes[1415][57922488] = { mnID = 1942, name = DUNGEON_FLOOR_ZULAMAN1 .. " " .. "[" .. LEVEL .. ": " .. "70]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "70", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false}
          nodes[1415][56190253] = { mnID = 1957, name = L["Magisters' Terrace"] .. " " .. "[" .. LEVEL .. ": " .. "70]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "70", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false}

        end

      -- Multi
        if self.db.profile.showContinentMultiple then
          nodes[1415][47397031] = { id = { 73 }, mnID = 1428, showOnContinent = true, showInZone = false, showOnMinimap = false, name = DUNGEON_FLOOR_MOLTENCORE1 .. " " .. "[" .. LEVEL .. ": " .. "60+]" .. "\n" .. DUNGEON_FLOOR_BURNINGSTEPPES15 .. " " .. "[" .. LEVEL .. ": " .. "80-85]" .. "\n" .. DUNGEON_FLOOR_BURNINGSTEPPES14 .. " " .. "[" .. LEVEL .. ": " .. "55-60]" .. "\n" .. DUNGEON_FLOOR_BURNINGSTEPPES16 .. " " .. "[" .. LEVEL .. ": " .. "52-60]", type = "MultipleM" }
        end

      -- Blizz POIS
        if self.db.profile.activate.RemoveBlizzPOIs then

          if self.faction == "Horde" or db.activate.EnemyFaction then
            nodes[1415][43703596] = { mnID = 1458, name = "", type = "HIcon", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Undercity"] .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " => " .. L["Silvermoon City"] }
            nodes[1415][56011398] = { mnID = 1941, name = "", type = "HIcon", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Silvermoon City"] .. " - " .. FACTION_HORDE  .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " => " .. L["Undercity"] .. "\n" .. " => " .. L["Blasted Lands"]  }
          end

          if self.faction == "Alliance" or db.activate.EnemyFaction then
            nodes[1415][46535960] = { mnID = 1455, name = "", type = "AIcon", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Ironforge"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. DUNGEON_FLOOR_DEEPRUNTRAM1 .. "\n" .. " => " .. L["Stormwind"] .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " => " .. L["Blasted Lands"] } -- Transport to Ironforge Carriage 
            nodes[1415][42847309] = { mnID = 1453, name = "", type = "AIcon", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Stormwind"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. DUNGEON_FLOOR_DEEPRUNTRAM1 .. "\n" .. " => " .. L["Ironforge"] .. "\n" .. "\n" .. L["Portals"] .. "\n" .. " => " .. POSTMASTER_LETTER_VALIANCEKEEP .. "\n" .. " => " .. L["Uldum"] .. "\n" .. " => " .. L["Vashj'ir"] .. "\n" .. " => " .. POSTMASTER_LETTER_HYJAL .. "\n" .. " => " .. ARTIFACT_SHAMAN_TITLECARD_DEEPHOLM .. "\n" .. " => " .. L["Twilight Highlands"] .. "\n" .. " => " .. DUNGEON_FLOOR_TOLBARADWARLOCKSCENARIO0 .. "\n" .. "\n" .. L["Ships"] .. "\n" .. " => " .. POSTMASTER_LETTER_VALIANCEKEEP .. "\n" .. " => " .. L["Rut'theran"] .. "\n" .. "\n" ..  CALENDAR_TYPE_DUNGEON .. "\n" .. " => " .. DUNGEON_FLOOR_THESTOCKADE1 }
          end

        end

      -- Dungeons and not Blizz for Stockade
        if self.db.profile.showContinentDungeons and not self.db.profile.activate.RemoveBlizzPOIs then
        
          if self.db.profile.showContinentDungeons then
              nodes[1415][42847309] = { mnID = 1453, showOnContinent = true, showInZone = false, showOnMinimap = false, name = DUNGEON_FLOOR_THESTOCKADE1 .. " " .. "[" .. LEVEL .. ": " .. "22-30]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "15", type = "Dungeon",}
          end

        end

      -- Zeppelin
        if self.db.profile.showContinentZeppelins then   

          if self.faction == "Horde" or db.activate.EnemyFaction then
            nodes[1415][43943263] = { mnID = 1420, name = "", type = "HZeppelin", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Tirisfal Glades"] .. " " .. L["Zeppelin"] .. "\n" .. " => " .. L["Grom'gol, Stranglethorn Vale"] .. "\n" .. " => " .. DUNGEON_FLOOR_ORGRIMMAR0 .. "\n" .. " => " .. L["Howling Fjord"] }
            nodes[1415][44078675] = { mnID = 1434, name = "", type = "HZeppelin", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Grom'gol, Stranglethorn Vale"] .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Zeppelin"] .. "\n" .. " => " .. DUNGEON_FLOOR_ORGRIMMAR0.. "\n" .. " => " .. L["Tirisfal Glades"] .. " - " .. L["Undercity"] }
          end

        end

      -- Continent Eastern Kingdom Transport and not RemoveBlizzPOIs
        if self.db.profile.showContinentTransport and not self.db.profile.activate.RemoveBlizzPOIs then
            
          if self.faction == "Alliance" or db.activate.EnemyFaction then
            nodes[1415][46655942] = { mnID = 1455, name = "", type = "Carriage", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Ironforge"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. DUNGEON_FLOOR_DEEPRUNTRAM1 .. "\n" .. " => " .. L["Stormwind"] } -- Transport to Ironforge Carriage 
            nodes[1415][43827345] = { mnID = 1429, name = "", type = "Carriage", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Stormwind"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. DUNGEON_FLOOR_DEEPRUNTRAM1 .. "\n" .. " => " .. L["Ironforge"] } -- Transport to Ironforge Carriage 
          end

        end

      -- Ships
        if self.db.profile.showContinentShips then

          nodes[1415][43219340] = { mnID = 1434, name = "", type = "Ship", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = POSTMASTER_LETTER_STRANGLETHORNVALE .. " - " .. FACTION_NEUTRAL .. "\n" .. "\n" .. L["Ship"] .. "\n" .. " => " .. L["Ratchet"] } -- Ship from Booty Bay to Ratchet
            
            if self.faction == "Alliance" or db.activate.EnemyFaction then
              nodes[1415][46285480] = { mnID = 1437, name = "", type = "AShip", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = POSTMASTER_LETTER_WETLANDS .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Ship"] .. "\n" .. " => " .. L["Theramore Isle"]  .. "\n" .. " => " .. L["Howling Fjord"] } -- Ship from Menethil Harbor to Howling Fjord and Dustwallow Marsh
            end

        end

      -- Eastern Kingdom Portals
        if self.db.profile.showContinentPortals then
          nodes[1415][52328472] = { mnID = 1419, name = "", type = "Portal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = SPLASH_BASE_90_RIGHT_TITLE .. " => " .. L["Hellfire Peninsula"] }
        end

      end -- if self.db.profile.showContinentEasternKingdom then


    --############################
    --##### Continent Outland ####
    --############################
    
      if self.db.profile.showContinentOutland then
    
      -- Outland Dungeons
        if self.db.profile.showContinentDungeons then
          nodes[1945][44447844] = { mnID = 1952, showOnContinent = true, showInZone = false, showOnMinimap = false, name = L["Auchenai Crypts"] .. " " .. "[" .. LEVEL .. ": " .. "65-67]", type = "Dungeon" } -- Auchenai Crypts 
          nodes[1945][46167604] = { mnID = 1952, showOnContinent = true, showInZone = false, showOnMinimap = false, name = DUNGEON_FLOOR_MANATOMBS1 .. " " .. "[" .. LEVEL .. ": " .. "64-66]", type = "Dungeon" } -- Mana-Tombs 
          nodes[1945][47647863] = { mnID = 1952, showOnContinent = true, showInZone = false, showOnMinimap = false, name = L["Sethekk Halls"] .. " " .. "[" .. LEVEL .. ": " .. "67-69]", type = "Dungeon" } -- Sethekk Halls 
          nodes[1945][46168103] = { mnID = 1952, showOnContinent = true, showInZone = false, showOnMinimap = false, name = DUNGEON_FLOOR_SHADOWLABYRINTH1 .. " " .. "[" .. LEVEL .. ": " .. "69-70]", type = "Dungeon" } -- Shadow Labyrinth 
          nodes[1945][65862008] = { mnID = 1953, showOnContinent = true, showInZone = false, showOnMinimap = false, name = DUNGEON_FLOOR_THEBOTANICA1 .. " " .. "[" .. LEVEL .. ": " .. "70]", type = "Dungeon" } -- The Botanica 
          nodes[1945][65622506] = { mnID = 1953, showOnContinent = true, showInZone = false, showOnMinimap = false, name = DUNGEON_FLOOR_THEMECHANAR1 .. " " .. "[" .. LEVEL .. ": " .. "70]", type = "Dungeon" } -- The Mechanar  
          nodes[1945][66722118] = { mnID = 1953, showOnContinent = true, showInZone = false, showOnMinimap = false, name = L["The Arcatraz"] .. " " .. "[" .. LEVEL .. ": " .. "70]", type = "Dungeon" } -- The Arcatraz
        end
      
      -- Outland Raids
        if self.db.profile.showContinentRaids then
          nodes[1945][66482303] = { mnID = 1953, showOnContinent = true, showInZone = false, showOnMinimap = false, name = DUNGEON_FLOOR_TEMPESTKEEP1 .. " " .. "[" .. LEVEL .. ": " .. "70-72]", type = "Raid" } -- The Eye  
          nodes[1945][72638103] = { mnID = 1948, showOnContinent = true, showInZone = false, showOnMinimap = false, name = L["Black Temple"] .. " " .. "[" .. LEVEL .. ": " .. "70+]", type = "Raid" } -- Black Temple 
          nodes[1945][45421915] = { mnID = 1949, showOnContinent = true, showInZone = false, showOnMinimap = false, name = DUNGEON_FLOOR_GRUULSLAIR1 .. " " .. "[" .. LEVEL .. ": " .. "70+]", type = "Raid" } -- Gruul's Lairend
        end
  
      -- Outland Multiple
        if self.db.profile.showContinentMultiple then
          nodes[1945][56635240] = { mnID = 1944, showOnContinent = true, showInZone = false, showOnMinimap = false, name = "", dnID = DUNGEON_FLOOR_MAGTHERIDONSLAIR1 .. " " .. "[" .. LEVEL .. ": " .. "70+]" .. "\n" .. DUNGEON_FLOOR_THEBLOODFURNACE1 .. " " .. "[" .. LEVEL .. ": " .. "61-63]" .. "\n" .. DUNGEON_FLOOR_HELLFIRERAMPARTS1 .. " " .. "[" .. LEVEL .. ": " .. "60-62]" .. "\n" .. DUNGEON_FLOOR_THESHATTEREDHALLS1 .. " " .. "[" .. LEVEL .. ": " .. "69-70]", type = "MultipleM" } -- Hellfire Ramparts, The Blood Furnace, The Shattered Halls, Magtheridon's Lair 
          nodes[1945][34344538] = { mnID = 1946, showOnContinent = true, showInZone = false, showOnMinimap = false, name = "", dnID = DUNGEON_FLOOR_COILFANGRESERVOIR1 .. " " .. "[" .. LEVEL .. ": " .. "70+]" .. "\n" .. DUNGEON_FLOOR_THESTEAMVAULT1 .. " " .. "[" .. LEVEL .. ": " .. "68-70]" .. "\n" .. DUNGEON_FLOOR_THESLAVEPENS1 .. " " .. "[" .. LEVEL .. ": " .. "62-64]" .. "\n" .. DUNGEON_FLOOR_THEUNDERBOG1 .. " " .. "[" .. LEVEL .. ": " .. "63-65]", type = "MultipleM" } -- Slave Pens, The Steamvault, The Underbog, Serpentshrine Cavern
        end
  
      -- Outland Portals
        if self.db.profile.showContinentPortals then
                   
          nodes[1945][43186573] = { mnID = 1955, showOnContinent = true, showInZone = false, showOnMinimap = false, name = "", type = "Portal", TransportName = L["Shattrath City"] .. "\n" .. "\n" .. L["Portals"] .. "\n" .. " => " .. DUNGEON_FLOOR_ORGRIMMAR0  .. "\n" .. "\n" .. " => " .. L["Stormwind"] .. "\n" .. "\n" .. " => " .. L["Isle of Quel'Danas"] } -- Portal from Shattrath to Orgrimmar
          if self.faction == "Horde" or db.activate.EnemyFaction then
            nodes[1945][69025178] = { mnID = 1944, showOnContinent = true, showInZone = false, showOnMinimap = false, name = "", type = "HPortal", TransportName = L["Hellfire Peninsula"] .. " " .. L["Portal"] .. "\n" .. " => " .. DUNGEON_FLOOR_ORGRIMMAR0 } -- Portal from Hellfire to Orgrimmar 
          end
  
          if self.faction == "Alliance" or db.activate.EnemyFaction then
            nodes[1945][68905259] = { mnID = 1944, showOnContinent = true, showInZone = false, showOnMinimap = false, name = "" , type = "APortal", TransportName = L["Hellfire Peninsula"] .. " " .. L["Portal"] .. "\n" .. " => " .. L["Stormwind"] } -- Portal from Hellfire to Stormwind
          end

        end

      end -- if self.db.profile.showContinentOutland then

      
    --##############################
    --##### Continent Northrend ####
    --##############################
      if self.db.profile.showContinentNorthrend then

      -- Northrend Dungeon
        if self.db.profile.showContinentDungeons then
          nodes[113][79418029] = { mnID = 117, showOnContinent = true, showInZone = false, showOnMinimap = false, name = L["Utgarde Keep"] .. " " .. "[" .. LEVEL .. ": " .. "70-72]", type = "Dungeon" } -- Utgarde Keep, at doorway entrance 
          nodes[113][78917881] = { mnID = 117, showOnContinent = true, showInZone = false, showOnMinimap = false, name = L["Utgarde Pinnacle"] .. " " .. "[" .. LEVEL .. ": " .. "79-80]", type = "Dungeon" } -- Utgarde Pinnacle 
          nodes[113][59461195] = { mnID = 120, showOnContinent = true, showInZone = false, showOnMinimap = false, name = DUNGEON_FLOOR_HALLSOFORIGINATION1 .. " " .. "[" .. LEVEL .. ": " .. "79-80]", type = "Dungeon" } -- Halls of Lightning 
          nodes[113][57241416] = { mnID = 120, showOnContinent = true, showInZone = false, showOnMinimap = false, name = DUNGEON_FLOOR_ULDUAR771 .. " " .. "[" .. LEVEL .. ": " .. "77-79]", type = "Dungeon" } -- Halls of Stone 
          nodes[113][62664963] = { mnID = 121, showOnContinent = true, showInZone = false, showOnMinimap = false, name = L["Drak'Tharon Keep"] .. " " .. "[" .. LEVEL .. ": " .. "74-76]", type = "Dungeon" } -- Drak'Tharon Keep 
          nodes[113][77933300] = { mnID = 121, showOnContinent = true, showInZone = false, showOnMinimap = false, name = DUNGEON_FLOOR_GUNDRAK1 .. " " .. "[" .. LEVEL .. ": " .. "76-78]", type = "Dungeon" } -- Gundrak Left Entrance 
          nodes[113][76583060] = { mnID = 121, showOnContinent = true, showInZone = false, showOnMinimap = false, name = DUNGEON_FLOOR_GUNDRAK1 .. " " .. "[" .. LEVEL .. ": " .. "76-78]", type = "Dungeon" } -- Gundrak Right Entrance 
          nodes[113][48514193] = { mnID = 127, showOnContinent = true, showInZone = false, showOnMinimap = false, name = DUNGEON_FLOOR_VIOLETHOLD1 .. " " .. "[" .. LEVEL .. ": " .. "75-77]", type = "Dungeon" } -- Violet Hold
          nodes[113][41154408] = { mnID = 118, showOnContinent = true, showInZone = false, showOnMinimap = false, name = "", dnID = DUNGEON_FLOOR_THEFORGEOFSOULS1 .. " " .. "[" .. LEVEL .. ": " .. "79-80]" .. "\n" .. DUNGEON_FLOOR_HALLSOFREFLECTION1 .. " " .. "[" .. LEVEL .. ": " .. "79-80]" .. "\n" .. DUNGEON_FLOOR_PITOFSARON1 .. " " .. "[" .. LEVEL .. ": " .. "79-80]", type = "Dungeon" } -- The Forge of Souls, Halls of Reflection, Pit of Saron         
          nodes[113][40005849] = { mnID = 115, showOnContinent = true, showInZone = false, showOnMinimap = false, name = "", dnID = DUNGEON_FLOOR_AHNKAHET1 .. " " .. "[" .. LEVEL .. ": " .. "73-75]" .. "\n" .. L["Azjol-Nerub"] .. " " .. "[" .. LEVEL .. ": " .. "72-74]", type = "Dungeon" } -- Ahn'kahet The Old Kingdom, Azjol-Nerub 
        end

      -- Northrend Raids
        if self.db.profile.showContinentRaids then
          nodes[113][58415888] = { mnID = 115, showOnContinent = true, showInZone = false, showOnMinimap = false, name = L["Naxxramas"] .. " " .. "[" .. LEVEL .. ": " .. "80+]", type = "Raid" } -- Naxxramas 
          nodes[113][40004021] = { mnID = 118, showOnContinent = true, showInZone = false, showOnMinimap = false, name = DUNGEON_FLOOR_ICECROWNCITADELDEATHKNIGHT3 .. " " .. "[" .. LEVEL .. ": " .. "80+]", type = "Raid" } -- Icecrown Citadel 
          nodes[113][58101029] = { mnID = 120, showOnContinent = true, showInZone = false, showOnMinimap = false, name = L["Ulduar"] .. " " .. "[" .. LEVEL .. ": " .. "80+]",type = "Raid" } -- Ulduar
          nodes[113][35694316] = { mnID = 123, showOnContinent = true, showInZone = false, showOnMinimap = false, name = DUNGEON_FLOOR_VAULTOFARCHAVON1  .. " " .. "[" .. LEVEL .. ": " .. "80+]", type = "Raid" } -- Vault of Archavon
          nodes[113][50346038] = { mnID = 115, showOnContinent = true, showInZone = false, showOnMinimap = false, name = "", dnID = DUNGEON_FLOOR_THEOBSIDIANSANCTUM1 .. " " .. "[" .. LEVEL .. ": " .. "80+]" .. "\n" .. L["The Ruby Sanctum"] .. " " .. "[" .. LEVEL .. ": " .. "80+]", type = "Raid" } -- The Ruby Sanctum, The Obsidian Sanctum 
          nodes[113][12425702] = { mnID = 114, showOnContinent = true, showInZone = false, showOnMinimap = false, name = "", dnID = DUNGEON_FLOOR_THEEYEOFETERNITY1 .. " " .. "[" .. LEVEL .. ": " .. "80+]", type = "Raid" } -- The Eye of Eternity, The Nexus, The Oculus
          nodes[113][47521749] = { mnID = 118, showOnContinent = true, showInZone = false, showOnMinimap = false, name = "", dnID = L["Trial of the Crusader"] .. " " .. "[" .. LEVEL .. ": " .. "80+]", type = "Raid" } -- Trial of the Crusader, Trial of the Champion 
        end


      -- Northrend Multiple
        if self.db.profile.showContinentMultiple then
          nodes[113][40005849] = { mnID = 115, showOnContinent = true, showInZone = false, showOnMinimap = false, name = "", dnID = DUNGEON_FLOOR_AHNKAHET1 .. " " .. "[" .. LEVEL .. ": " .. "73-75]" .. "\n" .. L["Azjol-Nerub"] .. " " .. "[" .. LEVEL .. ": " .. "72-74]", type = "MultipleD" } -- Ahn'kahet The Old Kingdom, Azjol-Nerub        
          nodes[113][41154408] = { mnID = 118, showOnContinent = true, showInZone = false, showOnMinimap = false, name = "", dnID = DUNGEON_FLOOR_THEFORGEOFSOULS1 .. " " .. "[" .. LEVEL .. ": " .. "79-80]" .. "\n" .. DUNGEON_FLOOR_HALLSOFREFLECTION1 .. " " .. "[" .. LEVEL .. ": " .. "79-80]" .. "\n" .. DUNGEON_FLOOR_PITOFSARON1 .. " " .. "[" .. LEVEL .. ": " .. "79-80]", type = "MultipleD" } -- The Forge of Souls, Halls of Reflection, Pit of Saron         
          nodes[113][47521749] = { mnID = 118, showOnContinent = true, showInZone = false, showOnMinimap = false, name = "", dnID = L["Trial of the Champion"] .. " " .. "[" .. LEVEL .. ": " .. "79-80]" .. "\n" .. L["Trial of the Crusader"] .. " " .. "[" .. LEVEL .. ": " .. "80+]", type = "MultipleM" } -- Trial of the Crusader, Trial of the Champion 
          nodes[113][12425702] = { mnID = 114, showOnContinent = true, showInZone = false, showOnMinimap = false, name = "", dnID = DUNGEON_FLOOR_THEEYEOFETERNITY1 .. " " .. "[" .. LEVEL .. ": " .. "80+]" .. "\n" .. DUNGEON_FLOOR_THENEXUS1 .. " " .. "[" .. LEVEL .. ": " .. "71-73]" .. "\n" .. L["The Oculus"]  .. " " .. "[" .. LEVEL .. ": " .. "79-80]", type = "MultipleM" } -- The Eye of Eternity, The Nexus, The Oculus
          nodes[113][50346038] = { mnID = 115, showOnContinent = true, showInZone = false, showOnMinimap = false, name = "", dnID = DUNGEON_FLOOR_THEOBSIDIANSANCTUM1 .. " " .. "[" .. LEVEL .. ": " .. "80+]" .. "\n" .. L["The Ruby Sanctum"] .. " " .. "[" .. LEVEL .. ": " .. "80+]", type = "MultipleR" } -- The Ruby Sanctum, The Obsidian Sanctum 
        end


      -- Northrend Portal
        if self.db.profile.showContinentPortals then
          nodes[113][36504679] = { mnID = 123, name = "", type = "Portal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Wintergrasp"] .. " " .. L["Portal"] .. "\n" .. " => " .. DUNGEON_FLOOR_DALARANCITY1 } -- LakeWintergrasp to Dalaran Portal
          nodes[113][47804060] = { mnID = 125, name = "", type = "Portal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = DUNGEON_FLOOR_DALARANCITY1 .. " " .. L["Portals"] .. "\n" ..  "\n" .. " => " .. DUNGEON_FLOOR_ORGRIMMAR0  .. "\n" .. " => " .. L["Stormwind"] } --  Dalaran Portal to Orgrimmar and Stormwind
        end


      -- Northrend Zeppelin
        if self.db.profile.showContinentZeppelins then 

          if self.faction == "Horde" or db.activate.EnemyFaction then
            nodes[113][86057284] = { mnID = 117, name = "", type = "HZeppelin", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Howling Fjord"] .. " " .. L["Zeppelin"] .. "\n" .. " => " .. L["Tirisfal Glades"] .. " - " .. L["Undercity"] } -- Zeppelin from Borean Tundra to Ogrimmar
            nodes[113][18766562] = { mnID = 114, name = "", type = "HZeppelin", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = POSTMASTER_LETTER_WARSONGHOLD .. " " .. L["Zeppelin"] .. "\n" .." => " .. DUNGEON_FLOOR_ORGRIMMAR0 } -- Zeppelin from Borean Tundra to Ogrimmar
          end

        end


      -- Northrend Ships
        if self.db.profile.showContinentShips then

          nodes[113][65218245] = { mnID = 117, name = "", type = "Ship", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = POSTMASTER_LETTER_KAMAGUA .. " " .. L["Ship"] .. "\n" .. " => " .. POSTMASTER_LETTER_MOAKI } -- Ship from Kamagua to Moaki
          nodes[113][47806841] = { mnID = 115, name = "", type = "Ship", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = POSTMASTER_LETTER_MOAKI .. " " .. L["Ship"] .. "\n" .. " => " .. POSTMASTER_LETTER_KAMAGUA } -- Ship from Moaki to Kamagua
          nodes[113][30056677] = { mnID = 114, name = "", type = "Ship", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Borean Tundra"] .. " " .. L["Ship"] .. "\n" .. " => " .. POSTMASTER_LETTER_MOAKI } -- Ship from Unu'pe to Moaki
          nodes[113][46406841] = { mnID = 115, name = "", type = "Ship", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = POSTMASTER_LETTER_MOAKI .. " " .. L["Ship"] .. "\n" .. " => " .. L["Borean Tundra"] } -- Ship from Moaki to Unu'pe

          if self.faction == "Alliance" or db.activate.EnemyFaction then
            nodes[113][25377045] = { mnID = 114, name = "", type = "AShip", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = POSTMASTER_LETTER_VALIANCEKEEP .. " " ..  L["Ship"] .. "\n" .. " => " .. L["Stormwind"] } -- Ship from Borean Tundra to Stormwind
            nodes[113][79788368] = { mnID = 117, name = "", type = "AShip", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Howling Fjord"] .. " " .. L["Ship"] .. "\n" .. " => " .. POSTMASTER_LETTER_WETLANDS } -- Ship from Howling Fjord to Wetlands
          end

        end

      end -- if self.db.profile.showContinentNorthrend then


    end -- if db.activate.Continent then
  end -- if not db.activate.HideMapNote then
end -- function ns.LoadCataContinentInfo(self)