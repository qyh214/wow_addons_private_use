local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

function ns.LoadMoPContinentInfo(self)
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
          nodes[12][54243572] = { id = 78, mnID = 198, name = DUNGEON_FLOOR_FIRELANDS0 .. " " .. "[" .. LEVEL .. ": " .. "85]", type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Firelands
          nodes[12][46059838] = { id = 74, name = "",  dnID = "[" .. LEVEL .. ": " .. "85]", type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Throne of the Four Winds
          nodes[12][40808546] = { mnID = 81, name = L["Temple of Ahn'Qiraj"] .. " " .. "[" .. LEVEL .. ": " .. "60+]", type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false }
          nodes[12][42408638] = { mnID = 81, name = DUNGEON_FLOOR_RUINSOFAHNQIRAJ1 .. " " .. "[" .. LEVEL .. ": " .. "60+]", type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false }
          nodes[12][56327161] = { imnID = 70, name = DUNGEON_FLOOR_ONYXIASLAIR1 .. " " .. "[" .. LEVEL .. ": " .. "60+]", type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false }
          nodes[12][59038528] = { mnID = 71, name = DUNGEON_FLOOR_COTMOUNTHYJAL1 .. " " .. "[" .. LEVEL .. ": " .. "70+]" , type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false }
        end

      -- Dungeons
        if self.db.profile.showContinentDungeons then
          nodes[948][51042844] = { id = 67, mnID = 207, name = "", dnID = "[" .. LEVEL .. ": " .. "81-85]", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Stonecore
          nodes[12][49929552] = { id = 69, mnID = 249, name = "", dnID = "[" .. LEVEL .. ": " .. "84-85]", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Lost City of Tol'Vir
          nodes[12][51679349] = { id = 70, mnID = 249, name = "", dnID = "[" .. LEVEL .. ": " .. "84-85]", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Halls of Origination
          nodes[12][52719898] = { id = 68, mnID = 249, name = "", dnID = "[" .. LEVEL .. ": " .. "81-85]", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- The Vortex Pinnacle
          nodes[12][43763504] = { id = 227, mnID = 63, name = L["Blackfathom Deeps"] .. " " .. "[" .. LEVEL .. ": " .. "24-32]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "15", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false}
          nodes[12][42846759] = { id = 230, mnID = 69, name = L["Dire Maul"] .. " " .. "[" .. LEVEL .. ": " .. "55-60]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "45", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false}
          nodes[12][45976847] = { id = 230, mnID = 69, name = L["Dire Maul"] .. " " .. "[" .. LEVEL .. ": " .. "55-60]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "45", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false}
          nodes[12][38225775] = { id = 232, mnID = 66, name = DUNGEON_FLOOR_MARAUDON1 .. " " .. "[" .. LEVEL .. ": " .. "46-55]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "30", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false}
          nodes[12][52397165] = { id = 233, mnID = 10, name = DUNGEON_FLOOR_RAZORFENDOWNS1 .. " " .. "[" .. LEVEL .. ": " .. "37-46]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "35", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false}
          nodes[12][50657013] = { id = 234, mnID = 10, name = DUNGEON_FLOOR_RAZORFENKRAUL1 .. " " .. "[" .. LEVEL .. ": " .. "29-38]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "25", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false}
          nodes[12][51885554] = { id = 240, mnID = 10, name = DUNGEON_FLOOR_WAILINGCAVERNS1 .. " " .. "[" .. LEVEL .. ": " .. "17-24]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "10", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false}
          nodes[12][54107955] = { id = 241, mnID = 71, name = DUNGEON_FLOOR_ZULFARRAK .. " " .. "[" .. LEVEL .. ": " .. "42-56", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "35", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false}
        end

      -- Multi
        if self.db.profile.showContinentMultiple then
          nodes[12][59038528] = { mnID = 71, name = "", dnID = DUNGEON_FLOOR_DRAGONBLIGHTCHROMIESCENARIO4 .. " " .. "[" .. LEVEL .. ": " .. "85]" .. "\n" .. DUNGEON_FLOOR_COTMOUNTHYJAL1 .. " " .. "[" .. LEVEL .. ": " .. "70+]" .. "\n" .. DUNGEON_FLOOR_COTTHEBLACKMORASS1 .. " " .. "[" .. LEVEL .. ": " .. "70+]" .. "\n" .. L["Old Hillsbrad Foothills"] .. " " .. "[" .. LEVEL .. ": " .. "66-68]" .. "\n" .. L["The Culling of Stratholme"] .. " " .. "[" .. LEVEL .. ": " .. "79-80]" .. "\n" .. DUNGEON_FLOOR_HOUROFTWILIGHT0 .. " " .. "[" .. LEVEL .. ": " .. "85]" .. "\n" .. "Endtime" .. " " .. "[" .. LEVEL .. ": " .. "85]" .. "\n" .. "Dragonsoul" .. " " .. "[" .. LEVEL .. ": " .. "85]", type = "MultipleM", showOnContinent = true, showInZone = false, showOnMinimap = false}
        end

      -- Blizz Pois
        if self.db.profile.activate.RemoveBlizzPOIs then

          if self.faction == "Alliance" or db.activate.ContinentEnemyFaction then
            nodes[12][39941176] = { mnID = 89, name = "", type = "AIcon", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Darnassus"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " => " .. L["Blasted Lands"] }
            nodes[12][29842672] = { mnID = 97, name = "", type = "AIcon", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Exodar"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " => " .. L["Stormwind"] }
          end

          if self.faction == "Horde" or db.activate.ContinentEnemyFaction then
            nodes[12][58164464] = { mnID = 85, name = "", type = "HIcon", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = DUNGEON_FLOOR_ORGRIMMAR0 .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Portals"] .. "\n" .. " => " .. L["Blasted Lands"] .. "\n" .. " => " .. DUNGEON_FLOOR_TOLBARADWARLOCKSCENARIO0 .. "\n" .. " => " .. L["Uldum"] .. "\n" .. " => " .. L["Twilight Highlands"] .. "\n" .. " => " .. POSTMASTER_LETTER_HYJAL .. "\n" .. " => " .. ARTIFACT_SHAMAN_TITLECARD_DEEPHOLM .. "\n" .. " => " .. L["Vashj'ir"] .. "\n" .. "\n" .. L["Zeppelin"] .. "\n" .. " => " .. L["Grom'gol, Stranglethorn Vale"] .. "\n" .. " => " .. L["Tirisfal Glades"] .. " - " .. L["Undercity"] .. "\n" .. " => " .. POSTMASTER_LETTER_WARSONGHOLD .. "\n" .. " => " .. L["Thunder Bluff"] .. "\n" .. "\n" ..CALENDAR_TYPE_DUNGEON .. "\n" .. " => " .. DUNGEON_FLOOR_RAGEFIRE1 } 
            nodes[12][46965720] = { mnID = 88, name = "", type = "HIcon", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Thunder Bluff"] .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " => " .. L["Blasted Lands"] .. "\n" .. "\n" .. L["Zeppelin"] .. "\n" .. " => " .. L["Durotar"] } 
          end
           
        end

      -- Dungeons and not Blizz for Ragefire
        if self.db.profile.showContinentDungeons and not self.db.profile.activate.RemoveBlizzPOIs then
         
          if self.db.profile.showContinentDungeons then
            nodes[12][58164464] = { mnID = 86, name = DUNGEON_FLOOR_RAGEFIRE1 .. " " .. "[" .. LEVEL .. ": " .. "13-18]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "8", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false}
          end

        end

      -- Ships
        if self.db.profile.showContinentShips then
            nodes[12][56955589] = { mnID = 10, name = "", type = "Ship", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Ratchet"] .. " - " .. FACTION_NEUTRAL .. "\n" .. "\n" .. L["Ship"] .. "\n" .. " => " .. POSTMASTER_LETTER_STRANGLETHORNVALE } -- Ship from Booty Bay to Ratchet
            
            if self.faction == "Alliance" or db.activate.ContinentEnemyFaction then
              --nodes[12][44132395] = { mnID = 1439, name = "", type = "AShip", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Auberdine"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Ships"] .. "\n" .. " => " .. L["Stormwind"] .. "\n" .. " => " .. L["Teldrassil"] .. "\n" .. " => " .. L["Azuremyst Isle"] } -- Ship from Booty Bay to Ratchet
              nodes[12][43581878] = { mnID = 57, name = "", type = "AShip", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Teldrassil"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Ship"] .. "\n" .. " => " .. L["Stormwind"] } -- Ship from Booty Bay to Ratchet
              nodes[12][42701806] = { mnID = 57, name = "", type = "AShip", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Teldrassil"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Ship"] .. "\n" .. " => " .. L["Azuremyst Isle"] } -- Ship from Booty Bay to Ratchet
              nodes[12][59036699] = { mnID = 70, name = "", type = "AShip", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Theramore Isle"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Ship"] .. "\n" .. " => " .. POSTMASTER_LETTER_WETLANDS } -- Ship from Dustwallow Marsh to Menethil Harbor
              nodes[12][28682746] = { mnID = 57, name = "", type = "AShip", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Ship"] .. "\n" .. " => " .. L["Rut'theran"] } --
            end
        end

      -- Portal
        if self.db.profile.showContinentPortals then
          nodes[12][55842967] = { mnID = 198, name = "", type = "Portal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = POSTMASTER_LETTER_HYJAL .. " " .. L["Portals"] .. "\n" .. " => " .. DUNGEON_FLOOR_ORGRIMMAR0 .. "\n" .. " => " .. L["Stormwind"] }
        end

      end


    --##########################
    --##### Eastern Kingdom ####
    --##########################
      if self.db.profile.showContinentEasternKingdom then


      -- Raids            
        if self.db.profile.showContinentRaids then
          nodes[13][47397031] = { id = 73, mnID = 36, name = DUNGEON_FLOOR_MOLTENCORE1 .. " " .. "[" .. LEVEL .. ": " .. "60+]", type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false}
          nodes[13][54885912] = { id = 72, name ="", dnID = "[" .. LEVEL .. ": " .. "85]", type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false} -- The Bastion of Twilight
          nodes[13][49678177] = { mnID = 42, name = L["Karazhan"] .. " " .. "[" .. LEVEL .. ": " .. "70+]", type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false} -- Karazhan Raid
          nodes[13][54470345] = { mnID = 122, name = DUNGEON_FLOOR_SUNWELLPLATEAU0 .. " " .. "[" .. LEVEL .. ": " .. "70+]", type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false} -- Sunwell Plateau 
          nodes[13][34885184] = { id = 75, name = "", dnID = "[" .. LEVEL .. ": " .. "85]", type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false} -- Baradin Hold
        end

      -- Dungeons
        if self.db.profile.showContinentDungeons then
          nodes[13][31416186] = { id = 65, mnID = 204, name = "", dnID = "[" .. LEVEL .. ": " .. "80-85]", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Throne of the Tides
          nodes[13][52975589] = { id = 71, mnID = 241, name = "", dnID = "[" .. LEVEL .. ": " .. "84-85]", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false} -- Grim Batol
          nodes[13][47648454] = { id = 76, mnID = 210, name = DUNGEON_FLOOR_ZULGURUB1 .. " " .. "[" .. LEVEL .. ": " .. "60+]", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false}
          nodes[13][40624150] = { id = 64, mnID = 21, name = L["Shadowfang Keep"] .. " " .. "[" .. LEVEL .. ": " .. "22-30]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "14", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false}
          nodes[13][50843614] = { id = 246, mnID = 22, name = L["Scholomance"] .. " " .. "[" .. LEVEL .. ": " .. "58-60]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "48", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false}
          nodes[13][46413023] = { id = 311, mnID = 18, name = DUNGEON_FLOOR_TIRISFAL13 .. " " .. "[" .. LEVEL .. ": " .. "22-30]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "21", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false}
          nodes[13][53302876] = { id = 236, mnID = 23, name = DUNGEON_FLOOR_COTSTRATHOLME1 .. " " .. "[" .. LEVEL .. ": " .. "42-52]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "48", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false}
          nodes[13][54382928] = { id = 236, mnID = 23, name = DUNGEON_FLOOR_COTSTRATHOLME1 .. " " .. "[" .. LEVEL .. ": " .. "46-56]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "48", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false}
          nodes[13][53927918] = { id = 237, mnID = 51, name = DUNGEON_FLOOR_THETEMPLEOFATALHAKKAR1 .. " " .. "[" .. LEVEL .. ": " .. "50-56]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "45", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false}
          nodes[13][53676514] = { id = 239, mnID = 15, name = DUNGEON_FLOOR_BADLANDS18 .. " " .. "[" .. LEVEL .. ": " .. "41-51]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "30", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false}
          nodes[13][52446311] = { id = 239, mnID = 15, name = DUNGEON_FLOOR_BADLANDS18 .. " " .. "[" .. LEVEL .. ": " .. "41-51]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "30", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false}
          nodes[13][43085997] = { id = 231, mnID = 27, name = DUNGEON_FLOOR_DUNMOROGH10 .. " " .. "[" .. LEVEL .. ": " .. "29-38]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "19", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false}
          nodes[13][40878158] = { id = 63, mnID = 52, name = DUNGEON_FLOOR_THEDEADMINES1 .. " " .. "[" .. LEVEL .. ": " .. "17-26]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "10", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false}
          nodes[13][57922488] = { id = 77, mnID = 95, name = DUNGEON_FLOOR_ZULAMAN1 .. " " .. "[" .. LEVEL .. ": " .. "70]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "70", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false}
          nodes[13][56190253] = { id = 249, mnID = 122, name = L["Magisters' Terrace"] .. " " .. "[" .. LEVEL .. ": " .. "70]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "70", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false}

        end

      -- Multi
        if self.db.profile.showContinentMultiple then
          nodes[13][47397031] = { id = { 73 }, mnID = 36, showOnContinent = true, showInZone = false, showOnMinimap = false, name = DUNGEON_FLOOR_MOLTENCORE1 .. " " .. "[" .. LEVEL .. ": " .. "60+]" .. "\n" .. DUNGEON_FLOOR_BURNINGSTEPPES15 .. " " .. "[" .. LEVEL .. ": " .. "80-85]" .. "\n" .. DUNGEON_FLOOR_BURNINGSTEPPES14 .. " " .. "[" .. LEVEL .. ": " .. "55-60]" .. "\n" .. DUNGEON_FLOOR_BURNINGSTEPPES16 .. " " .. "[" .. LEVEL .. ": " .. "52-60]", type = "MultipleM" }
        end

      -- Blizz POIS
        if self.db.profile.activate.RemoveBlizzPOIs then

          if self.faction == "Horde" or db.activate.ContinentEnemyFaction then
            nodes[13][43703596] = { mnID = 998, name = "", type = "HIcon", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Undercity"] .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " => " .. L["Silvermoon City"] }
            nodes[13][56011398] = { mnID = 110, name = "", type = "HIcon", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Silvermoon City"] .. " - " .. FACTION_HORDE  .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " => " .. L["Undercity"] .. "\n" .. " => " .. L["Blasted Lands"]  }
          end

          if self.faction == "Alliance" or db.activate.ContinentEnemyFaction then
            nodes[13][46535960] = { mnID = 87, name = "", type = "AIcon", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Ironforge"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. DUNGEON_FLOOR_DEEPRUNTRAM1 .. "\n" .. " => " .. L["Stormwind"] .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " => " .. L["Blasted Lands"] } -- Transport to Ironforge Carriage 
            nodes[13][42847309] = { mnID = 84, name = "", type = "AIcon", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Stormwind"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. DUNGEON_FLOOR_DEEPRUNTRAM1 .. "\n" .. " => " .. L["Ironforge"] .. "\n" .. "\n" .. L["Portals"] .. "\n" .. " => " .. POSTMASTER_LETTER_VALIANCEKEEP .. "\n" .. " => " .. L["Uldum"] .. "\n" .. " => " .. L["Vashj'ir"] .. "\n" .. " => " .. POSTMASTER_LETTER_HYJAL .. "\n" .. " => " .. ARTIFACT_SHAMAN_TITLECARD_DEEPHOLM .. "\n" .. " => " .. L["Twilight Highlands"] .. "\n" .. " => " .. DUNGEON_FLOOR_TOLBARADWARLOCKSCENARIO0 .. "\n" .. "\n" .. L["Ships"] .. "\n" .. " => " .. POSTMASTER_LETTER_VALIANCEKEEP .. "\n" .. " => " .. L["Rut'theran"] .. "\n" .. "\n" ..  CALENDAR_TYPE_DUNGEON .. "\n" .. " => " .. DUNGEON_FLOOR_THESTOCKADE1 }
          end

        end

      -- Dungeons and not Blizz for Stockade
        if self.db.profile.showContinentDungeons and not self.db.profile.activate.RemoveBlizzPOIs then
        
          if self.db.profile.showContinentDungeons then
              nodes[13][42847309] = { mnID = 84, showOnContinent = true, showInZone = false, showOnMinimap = false, name = DUNGEON_FLOOR_THESTOCKADE1 .. " " .. "[" .. LEVEL .. ": " .. "22-30]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "15", type = "Dungeon",}
          end

        end

      -- Zeppelin
        if self.db.profile.showContinentZeppelins then   

          if self.faction == "Horde" or db.activate.ContinentEnemyFaction then
            nodes[13][43943263] = { mnID = 18, name = "", type = "HZeppelin", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Tirisfal Glades"] .. " " .. L["Zeppelin"] .. "\n" .. " => " .. L["Grom'gol, Stranglethorn Vale"] .. "\n" .. " => " .. DUNGEON_FLOOR_ORGRIMMAR0 .. "\n" .. " => " .. L["Howling Fjord"] }
            nodes[13][44078675] = { mnID = 210, name = "", type = "HZeppelin", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Grom'gol, Stranglethorn Vale"] .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Zeppelin"] .. "\n" .. " => " .. DUNGEON_FLOOR_ORGRIMMAR0.. "\n" .. " => " .. L["Tirisfal Glades"] .. " - " .. L["Undercity"] }
          end

        end

      -- Continent Eastern Kingdom Transport and not RemoveBlizzPOIs
        if self.db.profile.showContinentTransport and not self.db.profile.activate.RemoveBlizzPOIs then
            
          if self.faction == "Alliance" or db.activate.ContinentEnemyFaction then
            nodes[13][46655942] = { mnID = 87, name = "", type = "Carriage", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Ironforge"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. DUNGEON_FLOOR_DEEPRUNTRAM1 .. "\n" .. " => " .. L["Stormwind"] } -- Transport to Ironforge Carriage 
            nodes[13][43827345] = { mnID = 37, name = "", type = "Carriage", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Stormwind"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. DUNGEON_FLOOR_DEEPRUNTRAM1 .. "\n" .. " => " .. L["Ironforge"] } -- Transport to Ironforge Carriage 
          end

        end

      -- Ships
        if self.db.profile.showContinentShips then

          nodes[13][43219340] = { mnID = 210, name = "", type = "Ship", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = POSTMASTER_LETTER_STRANGLETHORNVALE .. " - " .. FACTION_NEUTRAL .. "\n" .. "\n" .. L["Ship"] .. "\n" .. " => " .. L["Ratchet"] } -- Ship from Booty Bay to Ratchet
            
            if self.faction == "Alliance" or db.activate.ContinentEnemyFaction then
              nodes[13][46285480] = { mnID = 56, name = "", type = "AShip", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = POSTMASTER_LETTER_WETLANDS .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Ship"] .. "\n" .. " => " .. L["Theramore Isle"]  .. "\n" .. " => " .. L["Howling Fjord"] } -- Ship from Menethil Harbor to Howling Fjord and Dustwallow Marsh
            end

        end

      -- Eastern Kingdom Portals
        if self.db.profile.showContinentPortals then
          nodes[13][52328472] = { mnID = 17, name = "", type = "Portal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = SPLASH_BASE_90_RIGHT_TITLE .. " => " .. L["Hellfire Peninsula"] }
        end

      end -- if self.db.profile.showContinentEasternKingdom then


    --############################
    --##### Continent Outland ####
    --############################

      if self.db.profile.showContinentOutland then
    
      -- Outland Dungeons
        if self.db.profile.showContinentDungeons then
          nodes[1467][44447844] = { id = 247, mnID = 108, showOnContinent = true, showInZone = false, showOnMinimap = false, name = L["Auchenai Crypts"] .. " " .. "[" .. LEVEL .. ": " .. "65-67]", type = "Dungeon" } -- Auchenai Crypts 
          nodes[1467][46167604] = { id = 250, mnID = 108, showOnContinent = true, showInZone = false, showOnMinimap = false, name = DUNGEON_FLOOR_MANATOMBS1 .. " " .. "[" .. LEVEL .. ": " .. "64-66]", type = "Dungeon" } -- Mana-Tombs 
          nodes[1467][47647863] = { id = 252, mnID = 108, showOnContinent = true, showInZone = false, showOnMinimap = false, name = L["Sethekk Halls"] .. " " .. "[" .. LEVEL .. ": " .. "67-69]", type = "Dungeon" } -- Sethekk Halls 
          nodes[1467][46168103] = { id = 253, mnID = 108, showOnContinent = true, showInZone = false, showOnMinimap = false, name = DUNGEON_FLOOR_SHADOWLABYRINTH1 .. " " .. "[" .. LEVEL .. ": " .. "69-70]", type = "Dungeon" } -- Shadow Labyrinth 
          nodes[1467][65862008] = { id = 257, mnID = 109, showOnContinent = true, showInZone = false, showOnMinimap = false, name = DUNGEON_FLOOR_THEBOTANICA1 .. " " .. "[" .. LEVEL .. ": " .. "70]", type = "Dungeon" } -- The Botanica 
          nodes[1467][65622506] = { id = 258, mnID = 109, showOnContinent = true, showInZone = false, showOnMinimap = false, name = DUNGEON_FLOOR_THEMECHANAR1 .. " " .. "[" .. LEVEL .. ": " .. "70]", type = "Dungeon" } -- The Mechanar  
          nodes[1467][66722118] = { id = 254, mnID = 109, showOnContinent = true, showInZone = false, showOnMinimap = false, name = L["The Arcatraz"] .. " " .. "[" .. LEVEL .. ": " .. "70]", type = "Dungeon" } -- The Arcatraz
        end
      
      -- Outland Raids
        if self.db.profile.showContinentRaids then
          nodes[1467][66482303] = { mnID = 109, showOnContinent = true, showInZone = false, showOnMinimap = false, name = DUNGEON_FLOOR_TEMPESTKEEP1 .. " " .. "[" .. LEVEL .. ": " .. "70-72]", type = "Raid" } -- The Eye  
          nodes[1467][72638103] = { mnID = 104, showOnContinent = true, showInZone = false, showOnMinimap = false, name = L["Black Temple"] .. " " .. "[" .. LEVEL .. ": " .. "70+]", type = "Raid" } -- Black Temple 
          nodes[1467][45421915] = { mnID = 105, showOnContinent = true, showInZone = false, showOnMinimap = false, name = DUNGEON_FLOOR_GRUULSLAIR1 .. " " .. "[" .. LEVEL .. ": " .. "70+]", type = "Raid" } -- Gruul's Lairend
        end
  
      -- Outland Multiple
        if self.db.profile.showContinentMultiple then
          nodes[1467][56635240] = { mnID = 100, showOnContinent = true, showInZone = false, showOnMinimap = false, name = "", dnID = DUNGEON_FLOOR_MAGTHERIDONSLAIR1 .. " " .. "[" .. LEVEL .. ": " .. "70+]" .. "\n" .. DUNGEON_FLOOR_THEBLOODFURNACE1 .. " " .. "[" .. LEVEL .. ": " .. "61-63]" .. "\n" .. DUNGEON_FLOOR_HELLFIRERAMPARTS1 .. " " .. "[" .. LEVEL .. ": " .. "60-62]" .. "\n" .. DUNGEON_FLOOR_THESHATTEREDHALLS1 .. " " .. "[" .. LEVEL .. ": " .. "69-70]", type = "MultipleM" } -- Hellfire Ramparts, The Blood Furnace, The Shattered Halls, Magtheridon's Lair 
          nodes[1467][34344538] = { mnID = 102, showOnContinent = true, showInZone = false, showOnMinimap = false, name = "", dnID = DUNGEON_FLOOR_COILFANGRESERVOIR1 .. " " .. "[" .. LEVEL .. ": " .. "70+]" .. "\n" .. DUNGEON_FLOOR_THESTEAMVAULT1 .. " " .. "[" .. LEVEL .. ": " .. "68-70]" .. "\n" .. DUNGEON_FLOOR_THESLAVEPENS1 .. " " .. "[" .. LEVEL .. ": " .. "62-64]" .. "\n" .. DUNGEON_FLOOR_THEUNDERBOG1 .. " " .. "[" .. LEVEL .. ": " .. "63-65]", type = "MultipleM" } -- Slave Pens, The Steamvault, The Underbog, Serpentshrine Cavern
        end
  
      -- Outland Portals
        if self.db.profile.showContinentPortals then
                   
          nodes[1467][43186573] = { mnID = 111, showOnContinent = true, showInZone = false, showOnMinimap = false, name = "", type = "Portal", TransportName = L["Shattrath City"] .. "\n" .. "\n" .. L["Portals"] .. "\n" .. " => " .. DUNGEON_FLOOR_ORGRIMMAR0  .. "\n" .. "\n" .. " => " .. L["Stormwind"] .. "\n" .. "\n" .. " => " .. L["Isle of Quel'Danas"] } -- Portal from Shattrath to Orgrimmar
          if self.faction == "Horde" or db.activate.ContinentEnemyFaction then
            nodes[1467][69025178] = { mnID = 100, showOnContinent = true, showInZone = false, showOnMinimap = false, name = "", type = "HPortal", TransportName = L["Hellfire Peninsula"] .. " " .. L["Portal"] .. "\n" .. " => " .. DUNGEON_FLOOR_ORGRIMMAR0 } -- Portal from Hellfire to Orgrimmar 
          end
  
          if self.faction == "Alliance" or db.activate.ContinentEnemyFaction then
            nodes[1467][68905259] = { mnID = 100, showOnContinent = true, showInZone = false, showOnMinimap = false, name = "" , type = "APortal", TransportName = L["Hellfire Peninsula"] .. " " .. L["Portal"] .. "\n" .. " => " .. L["Stormwind"] } -- Portal from Hellfire to Stormwind
          end

        end

      end -- if self.db.profile.showContinentOutland then


    --##############################
    --##### Continent Northrend ####
    --##############################
      if self.db.profile.showContinentNorthrend then

      -- Northrend Dungeon
        if self.db.profile.showContinentDungeons then
          nodes[113][79418029] = { id = 285, mnID = 117, showOnContinent = true, showInZone = false, showOnMinimap = false, name = L["Utgarde Keep"] .. " " .. "[" .. LEVEL .. ": " .. "70-72]", type = "Dungeon" } -- Utgarde Keep, at doorway entrance 
          nodes[113][78917881] = { id = 286, mnID = 117, showOnContinent = true, showInZone = false, showOnMinimap = false, name = L["Utgarde Pinnacle"] .. " " .. "[" .. LEVEL .. ": " .. "79-80]", type = "Dungeon" } -- Utgarde Pinnacle 
          nodes[113][59461195] = { id = 275, mnID = 120, showOnContinent = true, showInZone = false, showOnMinimap = false, name = DUNGEON_FLOOR_HALLSOFORIGINATION1 .. " " .. "[" .. LEVEL .. ": " .. "79-80]", type = "Dungeon" } -- Halls of Lightning 
          nodes[113][57241416] = { id = 277, mnID = 120, showOnContinent = true, showInZone = false, showOnMinimap = false, name = DUNGEON_FLOOR_ULDUAR771 .. " " .. "[" .. LEVEL .. ": " .. "77-79]", type = "Dungeon" } -- Halls of Stone 
          nodes[113][62664963] = { id = 273, mnID = 121, showOnContinent = true, showInZone = false, showOnMinimap = false, name = L["Drak'Tharon Keep"] .. " " .. "[" .. LEVEL .. ": " .. "74-76]", type = "Dungeon" } -- Drak'Tharon Keep 
          nodes[113][77933300] = { id = 274, mnID = 121, showOnContinent = true, showInZone = false, showOnMinimap = false, name = DUNGEON_FLOOR_GUNDRAK1 .. " " .. "[" .. LEVEL .. ": " .. "76-78]", type = "Dungeon" } -- Gundrak Left Entrance 
          nodes[113][76583060] = { id = 274, mnID = 121, showOnContinent = true, showInZone = false, showOnMinimap = false, name = DUNGEON_FLOOR_GUNDRAK1 .. " " .. "[" .. LEVEL .. ": " .. "76-78]", type = "Dungeon" } -- Gundrak Right Entrance 
          nodes[113][48514193] = { id = 283, mnID = 127, showOnContinent = true, showInZone = false, showOnMinimap = false, name = DUNGEON_FLOOR_VIOLETHOLD1 .. " " .. "[" .. LEVEL .. ": " .. "75-77]", type = "Dungeon" } -- Violet Hold
          nodes[113][41154408] = { id = 276, mnID = 118, showOnContinent = true, showInZone = false, showOnMinimap = false, name = "", dnID = DUNGEON_FLOOR_THEFORGEOFSOULS1 .. " " .. "[" .. LEVEL .. ": " .. "79-80]" .. "\n" .. DUNGEON_FLOOR_HALLSOFREFLECTION1 .. " " .. "[" .. LEVEL .. ": " .. "79-80]" .. "\n" .. DUNGEON_FLOOR_PITOFSARON1 .. " " .. "[" .. LEVEL .. ": " .. "79-80]", type = "Dungeon" } -- The Forge of Souls, Halls of Reflection, Pit of Saron         
          nodes[113][40005849] = { id = 271, mnID = 115, showOnContinent = true, showInZone = false, showOnMinimap = false, name = "", dnID = DUNGEON_FLOOR_AHNKAHET1 .. " " .. "[" .. LEVEL .. ": " .. "73-75]" .. "\n" .. L["Azjol-Nerub"] .. " " .. "[" .. LEVEL .. ": " .. "72-74]", type = "Dungeon" } -- Ahn'kahet The Old Kingdom, Azjol-Nerub 
        end

      -- Northrend Raids
        if self.db.profile.showContinentRaids then
          nodes[113][58415888] = { mnID = 115, showOnContinent = true, showInZone = false, showOnMinimap = false, name = L["Naxxramas"] .. " " .. "[" .. LEVEL .. ": " .. "80+]", type = "Raid" } -- Naxxramas 
          nodes[113][40004021] = { mnID = 118, showOnContinent = true, showInZone = false, showOnMinimap = false, name = DUNGEON_FLOOR_ICECROWNCITADELDEATHKNIGHT3 .. " " .. "[" .. LEVEL .. ": " .. "80+]", type = "Raid" } -- Icecrown Citadel 
          nodes[113][57931030] = { mnID = 120, showOnContinent = true, showInZone = false, showOnMinimap = false, name = L["Ulduar"] .. " " .. "[" .. LEVEL .. ": " .. "80+]",type = "Raid" } -- Ulduar
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

          if self.faction == "Horde" or db.activate.ContinentEnemyFaction then
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

          if self.faction == "Alliance" or db.activate.ContinentEnemyFaction then
            nodes[113][25377045] = { mnID = 114, name = "", type = "AShip", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = POSTMASTER_LETTER_VALIANCEKEEP .. " " ..  L["Ship"] .. "\n" .. " => " .. L["Stormwind"] } -- Ship from Borean Tundra to Stormwind
            nodes[113][79788368] = { mnID = 117, name = "", type = "AShip", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Howling Fjord"] .. " " .. L["Ship"] .. "\n" .. " => " .. POSTMASTER_LETTER_WETLANDS } -- Ship from Howling Fjord to Wetlands
          end

        end

      end -- if self.db.profile.showContinentNorthrend then

        --#############################
        --##### Continent Pandaria ####
        --#############################

        if self.db.profile.showContinentPandaria then

        -- Pandaria Dungeons
          if self.db.profile.showContinentDungeons then
            nodes[424][72275515] = { id = 313, mnID = 371, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Temple of the Jade Serpent 
            nodes[424][48117132] = { id = 302, mnID = 376, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Stormstout Brewery
            nodes[424][40002920] = { id = 312, mnID = 379, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Shado-Pan Monastery
            nodes[424][23575057] = { id = 324, mnID = 388, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Siege of Niuzao Temple 
            nodes[424][42975779] = { id = 303, mnID = 390, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Gate of the Setting Sun 
            nodes[424][53745257] = { id = 321, mnID = 390, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Mogu'shan Palace (moved location cause of the LFR position)
          end


        -- Pandaria Raids
          if self.db.profile.showContinentRaids then
            nodes[424][49152606] = { id = 317, mnID = 379, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Mogu'shan Vaults 
            --nodes[424][52355265] = { id = 369, mnID = 390, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Siege of Orgrimmar 
            nodes[424][30076296] = { id = 330, mnID = 422, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Heart of Fear 
            --nodes[424][23100860] = { id = 362, mnID = 504, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Throne of Thunder
            nodes[424][56685529] = { id = 320, mnID = 433, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Terrace of Endless Spring  
          end


        -- Pandaria Portals
          if self.db.profile.showContinentPortals then

            if self.faction == "Horde" or db.activate.ContinentEnemyFaction then
              nodes[424][59733518] = { mnID = 371, name = "", type = "HPortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Jade Forest"] .. " " .. L["Portal"] .. "\n" .. " ==> " .. DUNGEON_FLOOR_ORGRIMMAR0 } -- Portal from Jade Forest to Orgrimmar
              nodes[424][17970919] = { mnID = 504, name = "", type = "HPortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Isle of Thunder"] .. " " .. L["Portals"] .. "\n" ..  "\n" .. " ==> " .. L["Shado-Pan Garrison, Townlong Steppes"] } -- Portal from Isle of Thunder to Shado-Pan Garrison
              nodes[424][29444738] = { mnID = 388, name = "", type = "HPortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Shado-Pan Garrison, Townlong Steppes"] .. " " .. L["Portal"] .. "\n" .. " ==> " .. L["Isle of Thunder"] } -- Portal from Shado-Pan Garrison to Isle of Thunder
              nodes[424][50604810] = { mnID = 392, name = "", type = "HPortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Vale of Eternal Blossoms"] .. " " .. L["Portals"] .. "\n" ..  "\n" .. " ==> " .. DUNGEON_FLOOR_ORGRIMMAR0 } -- Portal from Vale of Eternal Blossoms to Orgrimmar
              nodes[424][40508161] = { mnID = 418, name = "", type = "HPortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Krasarang Wilds"] .. " " .. L["Portal"] .. "\n" ..  "\n" .. " ==> " .. L["Silvermoon City"] } -- Portal to Silvermoon
            end

            if self.faction == "Alliance" or db.activate.ContinentEnemyFaction then
              nodes[424][67806740] = { mnID = 371, name = "", type = "APortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Jade Forest"] .. " " .. L["Portals"] .. "\n" ..  "\n" .. " ==> " .. L["Stormwind"] } -- Portal from Jade Forest to Stormwind
              nodes[424][23891588] = { mnID = 504, name = "", type = "APortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Isle of Thunder"] .. " " .. L["Portals"] .. "\n" ..  "\n" .. " ==> " .. L["Shado-Pan Garrison, Townlong Steppes"] } -- Portal from Isle of Thunder to Shado-Pan Garrison
              nodes[424][28894622] = { mnID = 388, name = "", type = "APortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Shado-Pan Garrison, Townlong Steppes"] .. " " .. L["Portal"] .. "\n" .. " ==> " .. L["Isle of Thunder"] } -- Portal from Shado-Pan Garrison to Isle of Thunder
              nodes[424][54785688] = { mnID = 394, name = "", type = "APortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Vale of Eternal Blossoms"] .. " " .. L["Portals"] .. "\n" ..  "\n" .. " ==> " .. L["Stormwind"] } -- Portal from Vale of Eternal Blossoms to Stormwind
            end
          end

        -- Pandaria PvpandPveVendor
          if self.db.profile.showContinentPvPandPvEVendor then
            nodes[424][24574389] = { name = "", dnID = TRANSMOG_SET_PVE .. " " .. MERCHANT .. "\n" .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. "\n" .. AUCTION_CATEGORY_WEAPONS, mnID = 388, type = "PvEVendor", showInZone = false, showOnContinent = true, showOnMinimap = false }

            if self.faction == "Horde" or db.activate.ContinentEnemyFaction then
              nodes[424][39394352] = { name = "", dnID = TRANSMOG_SET_PVP .. " " .. MERCHANT .. " " .. FACTION_HORDE .. "\n" .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. "\n" .. AUCTION_CATEGORY_WEAPONS, mnID = 379, type = "PvPVendorH", showInZone = false, showOnContinent = true, showOnMinimap = false }
            end

            if self.faction == "Alliance" or db.activate.ContinentEnemyFaction then
              nodes[424][42126238] = { name = "", dnID = TRANSMOG_SET_PVP .. " " .. MERCHANT .. " " .. FACTION_ALLIANCE .. "\n" .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. "\n" .. AUCTION_CATEGORY_WEAPONS, mnID = 376, type = "PvPVendorA", showInZone = false, showOnContinent = true, showOnMinimap = false }
            end
          end

          -- Pandaria Professions
          if self.db.profile.showContinentProfessions then

            nodes[424][71664914] = { name = INSCRIPTION, type = "Inscription", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            nodes[424][58007834] = { name = PROFESSIONS_FISHING, type = "Fishing", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            nodes[424][43257450] = { name = L["Engineer"], type = "Engineer", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            nodes[424][54086932] = { name = L["Tailoring"], type = "Tailoring", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            nodes[424][45135809] = { name = L["Blacksmithing"], type = "Blacksmith", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            nodes[424][51263464] = { name = L["Leatherworking"], type = "Leatherworking", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            nodes[424][35726249] = { name = L["Alchemy"], type = "Alchemy", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            nodes[424][43066713] = { name = L["Skinning"], type = "Skinning", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            nodes[424][67784226] = { name = L["Mining"], type = "Mining", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            nodes[424][52294943] = { dnID = FACTION_NEUTRAL .. " " .. MINIMAP_TRACKING_TRAINER_PROFESSION .. "\n" .. "\n" .. TextIconArchaeology:GetIconString() .. " " .. PROFESSIONS_ARCHAEOLOGY .. "\n" .. TextIconInscription:GetIconString() .. " " .. INSCRIPTION, name = "", type = "ProfessionsMixed", showOnContinent = true, showInZone = false, showOnMinimap = false }
            nodes[424][68524460] = { dnID = FACTION_NEUTRAL .. " " .. MINIMAP_TRACKING_TRAINER_PROFESSION .. "\n" .. "\n" .. TextIconInscription:GetIconString() .. " " .. INSCRIPTION .. "\n" .. TextIconJewelcrafting:GetIconString() .. " " .. L["Jewelcrafting"] .. "\n" .. TextIconBlacksmith:GetIconString() .. " " .. L["Blacksmithing"], name = "", type = "ProfessionsMixed", showOnContinent = true, showInZone = false, showOnMinimap = false }
            --nodes[424][45602694] = { dnID = FACTION_NEUTRAL .. " " .. MINIMAP_TRACKING_TRAINER_PROFESSION .. "\n" .. "\n" .. TextIconInscription:GetIconString() .. " " .. INSCRIPTION .. "\n" .. TextIconHerbalism:GetIconString() .. " " .. L["Herbalism"] .. "\n" .. TextIconLeatherworking:GetIconString() .. " " .. L["Leatherworking"] .. "\n" .. TextIconCooking:GetIconString() .. " " .. PROFESSIONS_COOKING .. "\n" .. TextIconFishing:GetIconString() .. " " .. PROFESSIONS_FISHING .. "\n" .. TextIconMining:GetIconString() .. " " .. L["Mining"] .. "\n" .. TextIconBlacksmith:GetIconString() .. " " .. L["Blacksmithing"], name = "", type = "ProfessionsMixed", showOnContinent = true, showInZone = false, showOnMinimap = false }
            nodes[424][52496674] = { dnID = FACTION_NEUTRAL .. " " .. MINIMAP_TRACKING_TRAINER_PROFESSION .. "\n" .. "\n" .. TextIconHerbalism:GetIconString() .. " " .. L["Herbalism"] .. "\n" .. TextIconCooking:GetIconString() .. " " .. PROFESSIONS_COOKING .. "\n" .. TextIconFishing:GetIconString() .. " " .. PROFESSIONS_FISHING, name = "", type = "ProfessionsMixed", showOnContinent = true, showInZone = false, showOnMinimap = false }
            nodes[424][67524880] = { dnID = FACTION_NEUTRAL .. " " .. MINIMAP_TRACKING_TRAINER_PROFESSION .. "\n" .. "\n" .. TextIconEnchanting:GetIconString() .. " " .. L["Enchanting"] .. "\n" .. TextIconCooking:GetIconString() .. " " .. PROFESSIONS_COOKING, name = "", type = "ProfessionsMixed", showOnContinent = true, showInZone = false, showOnMinimap = false }

            if self.faction == "Horde" then
              nodes[424][59123739] = { dnID = ITEM_REQ_HORDE .. "\n" .. "\n" .. TextIconHerbalism:GetIconString() .. " " .. L["Herbalism"] .. "\n" .. TextIconMining:GetIconString() .. " " .. L["Mining"] .. "\n" .. TextIconSkinning:GetIconString() .. " " .. L["Skinning"], name = "", type = "ProfessionsMixed", showOnContinent = true, showInZone = false, showOnMinimap = false }
              nodes[424][67895590] = { name = L["Herbalism"], type = "Herbalism", questID = 29824, wwwName = REQUIRES_LABEL .. " " .. STORY_PROGRESS, showWWW = true, wwwLink = "wowhead.com/quest=29824", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
              nodes[424][43874801] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
              nodes[424][48314179] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
              nodes[504][33503380] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            end

            if self.faction == "Alliance" then
              nodes[424][66766846] = { dnID = ITEM_REQ_ALLIANCE .. "\n" .. "\n" .. TextIconHerbalism:GetIconString() .. " " .. L["Herbalism"] .. "\n" .. TextIconMining:GetIconString() .. " " .. L["Mining"] .. "\n" .. TextIconSkinning:GetIconString() .. " " .. L["Skinning"], name = "", type = "ProfessionsMixed", showOnContinent = true, showInZone = false, showOnMinimap = false }
            end

          end

        end

    end -- if db.activate.Continent then
  end -- if not db.activate.HideMapNote then
end -- function ns.LoadMoPContinentInfo(self)