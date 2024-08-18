local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

function ns.LoadMiniMapLocationinfo(self)
local db = ns.Addon.db.profile
local minimap = ns.minimap

--#####################################################################################################
--##########################        function to hide all minimap below         ##########################
--#####################################################################################################
if not db.activate.HideMapNote then

    
    --#####################################################################################################
    --################################         Continent / Zone Map        ################################
    --#####################################################################################################
    
      if db.activate.MiniMap then
    
    
        --#############################
        --##### Continent Kalimdor ####
        --#############################
    
        if self.db.profile.showMiniMapKalimdor then

        -- Kalimdor RemoveBlizzPOIs
          if db.activate.RemoveBlizzPOIs then

            if self.faction == "Horde" or db.activate.MiniMapEnemyFaction then
              minimap[1][45780744] = { mnID = 85, name = "", type = "HIcon", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = ORGRIMMAR .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Portalroom"] .. "\n" .. " ==> " .. L["Silvermoon City"] .. "\n" .. " ==> " .. L["Valdrakken"] .. "\n" .. " ==> " .. L["Oribos"] .. "\n" .. " ==> " .. L["Azsuna"] .. "\n" .. " ==> " .. L["Zuldazar"] .. "\n" .. " ==> " .. L["Shattrath City"] .. "\n" .. " ==> " .. DUNGEON_FLOOR_DALARANCITY1 .. "\n" .. " ==> " .. DUNGEON_FLOOR_TANARIS18 .. "\n" .. " ==> " .. L["Blasted Lands"] .. "\n" .. " ==> " .. L["Dornogal"] .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " ==> " .. POSTMASTER_LETTER_HYJAL .. "\n" .. " ==> " .. L["Twilight Highlands"] .. "\n" .. " ==> " .. ARTIFACT_SHAMAN_TITLECARD_DEEPHOLM .. "\n" .. " ==> " .. L["Vashj'ir"] .. "\n" .. " ==> " .. L["Uldum"] .. "\n" .. " ==> " .. DUNGEON_FLOOR_TOLBARADWARLOCKSCENARIO0 .. "\n" .. "\n" .. L["Zeppelins"] .. "\n" .. " ==> " .. L["Thunder Bluff"] .. "\n" .. " ==> " .. L["Grom'gol, Stranglethorn Vale"] .. "\n" .. " ==> " .. POSTMASTER_LETTER_WARSONGHOLD .. "\n" .. "\n" .. CALENDAR_TYPE_DUNGEON .. "\n" .. " ==> " .. DUNGEON_FLOOR_RAGEFIRE1 } -- Portalroom from Dazar'alor
              minimap[76][21288964] = { mnID = 85, name = "", type = "HIcon", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = ORGRIMMAR .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Portalroom"] .. "\n" .. " ==> " .. L["Silvermoon City"] .. "\n" .. " ==> " .. L["Valdrakken"] .. "\n" .. " ==> " .. L["Oribos"] .. "\n" .. " ==> " .. L["Azsuna"] .. "\n" .. " ==> " .. L["Zuldazar"] .. "\n" .. " ==> " .. L["Shattrath City"] .. "\n" .. " ==> " .. DUNGEON_FLOOR_DALARANCITY1 .. "\n" .. " ==> " .. DUNGEON_FLOOR_TANARIS18 .. "\n" .. " ==> " .. L["Blasted Lands"] .. "\n" .. " ==> " .. L["Dornogal"] .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " ==> " .. POSTMASTER_LETTER_HYJAL .. "\n" .. " ==> " .. L["Twilight Highlands"] .. "\n" .. " ==> " .. ARTIFACT_SHAMAN_TITLECARD_DEEPHOLM .. "\n" .. " ==> " .. L["Vashj'ir"] .. "\n" .. " ==> " .. L["Uldum"] .. "\n" .. " ==> " .. DUNGEON_FLOOR_TOLBARADWARLOCKSCENARIO0 .. "\n" .. "\n" .. L["Zeppelins"] .. "\n" .. " ==> " .. L["Thunder Bluff"] .. "\n" .. " ==> " .. L["Grom'gol, Stranglethorn Vale"] .. "\n" .. " ==> " .. POSTMASTER_LETTER_WARSONGHOLD .. "\n" .. "\n" .. CALENDAR_TYPE_DUNGEON .. "\n" .. " ==> " .. DUNGEON_FLOOR_RAGEFIRE1 } -- Portalroom from Dazar'alor
              minimap[10][80450975] = { mnID = 85, name = "", type = "HIcon", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = ORGRIMMAR .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Portalroom"] .. "\n" .. " ==> " .. L["Silvermoon City"] .. "\n" .. " ==> " .. L["Valdrakken"] .. "\n" .. " ==> " .. L["Oribos"] .. "\n" .. " ==> " .. L["Azsuna"] .. "\n" .. " ==> " .. L["Zuldazar"] .. "\n" .. " ==> " .. L["Shattrath City"] .. "\n" .. " ==> " .. DUNGEON_FLOOR_DALARANCITY1 .. "\n" .. " ==> " .. DUNGEON_FLOOR_TANARIS18 .. "\n" .. " ==> " .. L["Blasted Lands"] .. "\n" .. " ==> " .. L["Dornogal"] .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " ==> " .. POSTMASTER_LETTER_HYJAL .. "\n" .. " ==> " .. L["Twilight Highlands"] .. "\n" .. " ==> " .. ARTIFACT_SHAMAN_TITLECARD_DEEPHOLM .. "\n" .. " ==> " .. L["Vashj'ir"] .. "\n" .. " ==> " .. L["Uldum"] .. "\n" .. " ==> " .. DUNGEON_FLOOR_TOLBARADWARLOCKSCENARIO0 .. "\n" .. "\n" .. L["Zeppelins"] .. "\n" .. " ==> " .. L["Thunder Bluff"] .. "\n" .. " ==> " .. L["Grom'gol, Stranglethorn Vale"] .. "\n" .. " ==> " .. POSTMASTER_LETTER_WARSONGHOLD .. "\n" .. "\n" .. CALENDAR_TYPE_DUNGEON .. "\n" .. " ==> " .. DUNGEON_FLOOR_RAGEFIRE1 } -- Portalroom from Dazar'alor
            end

            if self.faction == "Alliance" or db.activate.MiniMapEnemyFaction then
              minimap[97][27243965] = { mnID = 103, name = "", type = "AIcon", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Exodar"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " ==> " .. STORMWIND } -- Portal Exodar to Teldrassil
            end
          end     

          -- Kalimdor Transporting 
          if db.activate.MiniMapTransporting then

          -- Kalimdor Portals
            if self.db.profile.showMiniMapPortals then

            --TWW Pre Event Portal nodes
            minimap[70][45745721] = { mnID = 629, name = "", type = "Portal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal To Dalaran
            --------------------------------------------------------------------------------------------------------------------------------------------------------

              minimap[57][26305072] = { mnID = 89, name = "", type = "Portal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Darnassus"] .. " " .. L["Portal"] .. "\n" .. " ==> " .. L["Rut'theran"] } -- Portal To Teldrassil from Darnassus
              minimap[57][54998820] = { mnID = 89, name = "", type = "Portal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Darnassus"] } -- Portal To Darnassus from Teldrassil
              minimap[78][50560773] = { mnID = 119, name = "", type = "Portal", showInZone = false, showOnContinent = false, showOnMinimap = true, dnID = L["Portal"] } -- Portal Unguro to Sholazar

              if self.faction == "Horde" then --was additionally added without the showEnemyFaction option because the two points would be on top of each other when showing EnemyFaction and would therefore not be clickable for one of the two factions
                minimap[81][41614520] = { mnID = 862, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Zandalar"] } -- Portal from Silithus to Zandalar
                minimap[71][65984960] = { mnID = 85, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. ORGRIMMAR } -- Portal from Tanaris to Orgrimmar 
                minimap[74][58152676] = { mnID = 85, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. ORGRIMMAR } -- Portal from Tanaris to Orgrimmar 
              end

              if self.faction == "Alliance" then --was additionally added without the showEnemyFaction option because the two points would be on top of each other when showing EnemyFaction and would therefore not be clickable for one of the two factions
                minimap[81][41614520] = { mnID = 1161, name = "", type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Boralus, Tiragarde Sound"] } -- Portal from Silithus to Boralus
                minimap[71][65984960] = { mnID = 84,  name = "" , type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. STORMWIND } -- Portal from Tanaris to Stormwind City 
                minimap[74][58942680] = { mnID = 84,  name = "" , type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. STORMWIND } -- Portal from Tanaris to Stormwind City 
              end

              if self.faction == "Horde" or db.activate.MiniMapEnemyFaction then  
                minimap[7][36003600] = { mnID = 407, name = FACTION_HORDE .. " " .. L["Portal"] .. " ==> " .. CALENDAR_FILTER_DARKMOON, TransportName = "\n" .. REQUIRES_LABEL .. " " .. CALENDAR_FILTER_DARKMOON .. "\n" .. L["Starting on the first Sunday of each month for one week"], type = "DarkMoon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Mulgore Portal to the Darkmoon
                minimap[62][46243511] = { mnID = 862, name = "", TransportName = L["Portal"] .. " ==> " .. L["Zuldazar"] .. "\n" .. "\n" .. L["(its only shown up ingame if your faction\n is currently occupying Bashal'Aran)"], type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal from New Darkshore to Zandalar 
                minimap[207][50945311] = { mnID = 85, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. ORGRIMMAR } -- Portal To Orgrimmar from Deepholm
                minimap[198][63482447] = { mnID = 85, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. ORGRIMMAR } -- Portal To Orgrimmar from Hyjal
              end

              if self.faction == "Alliance" or db.activate.MiniMapEnemyFaction then
                minimap[57][26305072] = { mnID = 89, name = "", type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Darnassus"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Portals"] .. "\n" .. " ==> " .. L["Rut'theran"] .. "\n" .. " ==> " .. L["Exodar"]  .. "\n" .. " ==> " .. L["Hellfire Peninsula"] } -- Portal To Teldrassil from Darnassus
                minimap[97][20235409] = { mnID = 57, name = "", type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Rut'theran"] } -- Portal Exodar to Teldrassil
                minimap[62][53731873] = { mnID = 2239, name = "", type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Bel'ameth, Amirdrassil"] } -- Portal from New Darkshore to Bel'ameth, Amirdrassil
                minimap[62][48023628] = { mnID = 1161, name = "", TransportName = L["Portal"] .. " ==> " .. L["Boralus"] .. "\n" .. "\n" .. L["(its only shown up ingame if your faction\n is currently occupying Bashal'Aran)"], showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal from New Darkshore to Zandalar
                minimap[198][62602315] = { mnID = 84,  name = "" , type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. STORMWIND } -- Portal To Stormwind from Hyjal
                minimap[207][48525385] = { mnID = 84, name = "", type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. STORMWIND } -- Portal To Stormwind
                minimap[57][55039371] = { mnID = 84, name = "", type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. STORMWIND } -- Portal To Stormwind from Teldrassil
                minimap[57][52278948] = { mnID = 97, name = "", type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Azuremyst Isle"] } -- Portal To Exodar from Teldrassil
              end
            end

          --Kalimdor Zeppelins
            if self.db.profile.showMiniMapZeppelins then
              minimap[1][55941320] = { mnID = 2022, name = "", type = "HZeppelin", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Zeppelin"] .. " ==> " .. L["The Waking Shores, Dragon Isles"] } -- Zeppelin from Orgrimmar to Waking Shores
              minimap[7][33422231] = { mnID = 85, name = "", type = "HZeppelin", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Zeppelin"] .. " ==> " .. ORGRIMMAR } -- Zeppelin from Thunder Bluff to Orgrimmar
              minimap[10][80450975] = { mnID = 85, name = "", type = "HZeppelin", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Zeppelin"] .. " ==> " .. ORGRIMMAR } -- Zeppelin from Thunder Bluff to Orgrimmar
            end

          -- Kalimdor Ships
            if self.db.profile.showMiniMapShips then

              minimap[1][35217941] = { mnID = 210, name = "", type = "Ship", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Ship"] .. " ==> " .. POSTMASTER_LETTER_STRANGLETHORNVALE } -- Ship from Ratchet to Booty Bay Ship
              minimap[10][70237341] = { mnID = 210, name = "", type = "Ship", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Ship"] .. " ==> " .. POSTMASTER_LETTER_STRANGLETHORNVALE } -- Ship from Ratchet to Booty Bay Ship

              if self.faction == "Horde" or db.activate.MiniMapEnemyFaction then
                minimap[463][71903797] = { mnID = 862, name = "", type = "HShip", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Ship"] .. " ==> " .. L["Zuldazar"] } -- Ship from Echo Isles to Zuldazar  
                minimap[1][72257893] = { mnID = 862, name = "", type = "HShip", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Ship"] .. " ==> " .. L["Zuldazar"] } -- Ship from Echo Isles to Zuldazar            
              end
            
              if self.faction == "Alliance" or db.activate.MiniMapEnemyFaction then
                minimap[70][71545615] = { mnID = 56, name = "", type = "AShip", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Ship"] .. " ==> " .. POSTMASTER_LETTER_WETLANDS } -- Ship from Dustwallow Marsh to Wetlands
              end
            end

          end
        end
    
    
        --####################################
        --##### Continent Eastern Kingdom ####
        --####################################
    
        if self.db.profile.showMiniMapEasternKingdom then

        -- Azeroth Eastern Kingdom RemoveBlizzPOIs
          if db.activate.RemoveBlizzPOIs then

            if self.faction == "Horde" or db.activate.MiniMapEnemyFaction then
              minimap[224][42073378] = { mnID = 50, name = "", type = "HIcon", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Grom'gol, Stranglethorn Vale"] .. " " .. "\n" .. "\n" .. L["Zeppelin"] .. "\n" .. " ==> " .. ORGRIMMAR .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " ==> " .. L["Ruins of Lordaeron"] } -- Transport from Stranglethorn Valley to Ogrimmar and Ruins of Lordaeron
              minimap[94][56593942] = { mnID = 110, name = "", type = "HIcon", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Silvermoon City"] .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " ==> " .. ORGRIMMAR .. "\n" .. " ==> " .. L["Ruins of Lordaeron"] } -- Portal to Orgrimmar, Ruins of Lordaeron from Silvermoon   

            end

            if self.faction == "Alliance" or db.activate.MiniMapEnemyFaction then
              minimap[57][26305072] = { mnID = 89, name = "", type = "AIcon", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Darnassus"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Portals"] .. "\n" .. " ==> " .. L["Rut'theran"] .. "\n" .. " ==> " .. L["Exodar"]  .. "\n" .. " ==> " .. L["Hellfire Peninsula"] } -- Portal To Teldrassil from Darnassus
              minimap[27][59732929] = { mnID = 87, name = "", type = "AIcon", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Ironforge"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. DUNGEON_FLOOR_DEEPRUNTRAM1 .. "\n" .. " ==> " .. STORMWIND } -- Carriage To Stormwind
              minimap[37][32894742] = { mnID = 84, name = "", type = "AIcon", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = STORMWIND .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Portalroom"] .. "\n" .. " ==> " .. L["Ashran"] .. "\n" .. " ==> " .. L["Valdrakken"] .. "\n" .. " ==> " .. L["Boralus, Tiragarde Sound"] .. "\n" .. " ==> " .. L["Oribos"] .. "\n" .. " ==> " .. L["Azsuna"] .. "\n" .. " ==> " .. L["Shattrath City"] .. "\n" .. " ==> " .. L["Jade Forest"] .. "\n" .. " ==> " .. DUNGEON_FLOOR_DALARANCITY1 .. "\n" .. " ==> " .. DUNGEON_FLOOR_TANARIS18 .. "\n" .. " ==> " .. L["Exodar"] .. "\n" ..  " ==> " .. L["Bel'ameth, Amirdrassil"] .. "\n" .. " ==> " .. L["Blasted Lands"] .. "\n" .. " ==> " .. L["Dornogal"] .. "\n" .. "\n" .. L["Portals"] .. "\n" ..  "\n" .. " ==> " .. L["Uldum"] .. "\n" .. " ==> " .. L["Vashj'ir"] .. "\n" .. " ==> " .. POSTMASTER_LETTER_HYJAL .. "\n" .. " ==> " .. ARTIFACT_SHAMAN_TITLECARD_DEEPHOLM .. "\n" .. " ==> " .. L["Twilight Highlands"] .. "\n" .. " ==> " .. DUNGEON_FLOOR_TOLBARADWARLOCKSCENARIO0 .. "\n" .. "\n" .. L["Ships"] .. "\n" .. " ==> " .. POSTMASTER_LETTER_VALIANCEKEEP .. "\n" .. " ==> " .. L["Boralus, Tiragarde Sound"] .. "\n" .. " ==> " .. L["The Waking Shores, Dragon Isles"] .. "\n" .. "\n" .. DUNGEON_FLOOR_DEEPRUNTRAM1 .. "\n" .. " ==> " .. L["Ironforge"] .. "\n" .. "\n" .. " ==> " .. CALENDAR_TYPE_DUNGEON .. "\n" .. " ==> " .. DUNGEON_FLOOR_THESTOCKADE1 }
            end
          end

          -- Easten Kingdom Transporting 
          if db.activate.MiniMapTransporting then

          --Eastern Kingdom Portals
            if self.db.profile.showMiniMapPortals then

              --TWW Pre Event Portal nodes
              minimap[32][41736756] = { mnID = 629, name = "", type = "Portal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal To Dalaran
              ------------------------------------------------------------------------------------------------------------------------------------------------------------

              minimap[244][47135189] = { mnID = 85, name = "", type = "Portal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .."\n" .. "\n" .. " ==> " .. ORGRIMMAR .. "\n" .. " " .. JUST_OR .. "\n" .. " ==> " .. STORMWIND } -- Portal Tol Orgrimmar or Stormwind from Baradinhold Tol Barad pvp Area

              if self.faction == "Horde" then
                minimap[17][55005418] = { mnID = 624, name = L["The Dark Portal"] .. " (" .. L["Portal"] .. " - " .. L["Ashran"] ..")", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal from Blasted Lands to Warspear              
              end

              if self.faction == "Alliance" then
                minimap[17][55005418] = { mnID = 622, name = L["The Dark Portal"] .. " (" .. L["Portal"] .. " - " .. L["Ashran"] ..")", type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal from Blasted Lands to Stormshield
              end

              if self.faction == "Horde" or db.activate.MiniMapEnemyFaction then
                minimap[18][62167276] = { mnID = 90, name = "", type = "HIcon", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Undercity"] .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " ==> " .. L["Hellfire Peninsula"] } -- Portalroom from Dazar'alor
                minimap[17][72694917] = { mnID = 85, name = "" , type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. ORGRIMMAR .. "\n" .. "\n" .. L["If you don't see this icon, it's probably in a different phase. \nChange the phase on Zidormi"] } -- Portal Blasted Lands to Orgrimmar 
                minimap[18][60735867] = { mnID = 85, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. ORGRIMMAR } -- Portal to Orgrimmar from Tirisfal
                minimap[18][61905899] = { mnID = 50, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Grom'gol, Stranglethorn Vale"] } -- Portal to Stranglethorn from Tirisfal
                minimap[18][59085891] = { mnID = 117, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Howling Fjord"] } -- Portal to Howling Fjord from Tirisfal
                minimap[18][59416744] = { mnID = 110, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Silvermoon City"] } -- Portal to Silvermoon from Tirisfal
                minimap[2070][59506694] = { mnID = 85, name = "", type = "HPortalS", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. ORGRIMMAR } -- Portal to Orgrimmar from Tirisfal
                minimap[2070][59506797] = { mnID = 50, name = "", type = "HPortalS", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Grom'gol, Stranglethorn Vale"] } -- Portal to Stranglethorn from Tirisfal
                minimap[2070][60126689] = { mnID = 117, name = "", type = "HPortalS", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Howling Fjord"] } -- Portal to Howling Fjord from Tirisfal
                minimap[2070][59406743] = { mnID = 110, name = "", type = "HPortalS", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Silvermoon City"] } -- Portal to Silvermoon from Tirisfal
                minimap[50][37545100] = { mnID = 18, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Ruins of Lordaeron"] } -- Portal to Undercity from Grom'gol
                minimap[94][54552795] = { mnID = 85, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. ORGRIMMAR } -- Portal to Orgrimmar from Silvermoon 
                minimap[94][51262623] = { mnID = 18, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Ruins of Lordaeron"] } -- Portal to Ruins of Lordaeron from Silvermoon 
                minimap[14][27442938] = { mnID = 862, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Zandalar"] .. "\n" .. " " .. "(" .. L["This Arathi Highlands portal is only active if your faction is currently occupying Ar'gorok"] .. ")" }
                minimap[245][56397967] = { mnID = 85, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. ORGRIMMAR } -- Portal Tol Bard to Orgimmar  
                minimap[241][73595355] = { mnID = 85, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. ORGRIMMAR } -- Portal Tol Orgrimmar from Twilight Highlands  
              end
            
              if self.faction == "Alliance" or db.activate.MiniMapEnemyFaction then
                minimap[37][41786951] = { mnID = 407, name = FACTION_ALLIANCE .. " " .. L["Portal"] .. " ==> " .. CALENDAR_FILTER_DARKMOON, TransportName = "\n" .. REQUIRES_LABEL .. " " .. CALENDAR_FILTER_DARKMOON .. "\n" .. L["Starting on the first Sunday of each month for one week"], type = "DarkMoon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Elwynn Forest Portal to the Darkmoon
                minimap[14][22246515] = { mnID = 1161, name = "", type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Boralus"] .. "\n" .. " " .. "(" .. L["This Arathi Highlands portal is only active if your faction is currently occupying Ar'gorok"] .. ")" } -- Portal from Arathi to Zandalar
                minimap[37][29592388] = { mnID = 84, name = "", type = "Carriage", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = DUNGEON_FLOOR_DEEPRUNTRAM1 .. " ==> " .. L["Ironforge"] } -- Deeprun Stormwind to Ironforge
                minimap[37][33521611] = { mnID = 84, name = "", type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = STORMWIND .. " " .. L["Portals"] .. "\n" ..  "\n" .. " ==> " .. L["Uldum"] .. "\n" .. " ==> " .. L["Vashj'ir"] .. "\n" .. " ==> " .. POSTMASTER_LETTER_HYJAL .. "\n" .. " ==> " .. ARTIFACT_SHAMAN_TITLECARD_DEEPHOLM .. "\n" .. " ==> " .. L["Twilight Highlands"] .. "\n" .. " ==> " .. DUNGEON_FLOOR_TOLBARADWARLOCKSCENARIO0 } -- Portalroom from Stormwind
                minimap[37][15153165] = { mnID = 84, name = "", type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = STORMWIND .. " " .. L["Portalroom"] .. "\n" .. " ==> " .. L["Ashran"] .. "\n" .. " ==> " .. L["Valdrakken"] .. "\n" .. " ==> " .. L["Boralus, Tiragarde Sound"] .. "\n" .. " ==> " .. L["Oribos"] .. "\n" .. " ==> " .. L["Azsuna"] .. "\n" .. " ==> " .. L["Shattrath City"] .. "\n" .. " ==> " .. L["Jade Forest"] .. "\n" .. " ==> " .. DUNGEON_FLOOR_DALARANCITY1 .. "\n" .. " ==> " .. DUNGEON_FLOOR_TANARIS18 .. "\n" .. " ==> " .. L["Exodar"] .. "\n" ..  " ==> " .. L["Bel'ameth, Amirdrassil"] } -- Portalroom from Stormwind
                minimap[17][66382798] = { mnID = 84, name = "" , type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. STORMWIND .. "\n" .. "\n" .. L["If you don't see this icon, it's probably in a different phase. \nChange the phase on Zidormi"] } -- Portal to Stormwind 
                minimap[245][75235887] = { mnID = 84, name = "" , type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. STORMWIND } -- Portal Tol Bard to Stormwind
                minimap[241][79447784] = { mnID = 84, name = "" , type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. STORMWIND } -- Portal Twilight Highlands to Stormwind   
              end
            end

          --Eastern Kingdom Portals without RemoveBlizzPOIs
            if self.db.profile.showMiniMapPortals and not db.activate.RemoveBlizzPOIs then
              minimap[224][42233253] = { mnID = 18, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Ruins of Lordaeron"] } -- Portal to Undercity from Grom'gol
            end

          --Eastern Kingdom Zeppelins
            if self.db.profile.showMiniMapZeppelins then

              if self.faction == "Horde" or db.activate.MiniMapEnemyFaction then
              minimap[50][36955279] = { mnID = 85, name = "", type = "HZeppelin", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Zeppelin"] .. " ==> " .. ORGRIMMAR } -- Ship from Booty Bay to Ratchet
              end
            end

            --Eastern Kingdom Zeppelins without RemoveBlizzPOIs
            if self.db.profile.showMiniMapPortals and not db.activate.RemoveBlizzPOIs then
              minimap[224][41993471] = { mnID = 85, name = "", type = "HZeppelin", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Zeppelin"] .. " ==> " .. ORGRIMMAR } -- Ship from Booty Bay to Ratchet
            end

          --Eastern Kingdom Ships
            if self.db.profile.showMiniMapShips then
              minimap[217][63659592] = { mnID = 2239, name = "", type = "Ship", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Ship"] .. " ==> " .. L["Bel'ameth, Amirdrassil"] } -- Ship from Gilneas to Bel ameth
              minimap[224][36947582] = { mnID = 210, name = "", type = "Ship", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Ship"] .. " ==> " .. L["Ratchet"] } -- Ship from Booty Bay to Ratchet
              minimap[210][39336720] = { mnID = 10, name = "", type = "Ship", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Ship"] .. " ==> " .. L["Ratchet"] } -- Ship from Booty Bay to Ratchet

              if self.faction == "Alliance" or db.activate.MiniMapEnemyFaction then
                minimap[37][08722976] = { mnID = 1161, name = "", type = "AShip", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Ships"] .. "\n" .. " ==> " .. L["Boralus, Tiragarde Sound"] .. "\n".. " ==> " .. L["The Waking Shores, Dragon Isles"] } -- Ship from Stormwind to Boralus
                minimap[37][07622435] = { mnID = 114, name = "", type = "AShip", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Ship"] .. " ==> " .. POSTMASTER_LETTER_VALIANCEKEEP } -- Ship from Stormwind to Valiance Keep
                minimap[56][04175637] = { mnID = 117, name = "", type = "AShip", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Ship"] .. " ==> " .. L["Howling Fjord"] } -- Ship from Wettlands to Howling Fjord
                minimap[56][06366226] = { mnID = 70, name = "", type = "AShip", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Ship"] .. " ==> " .. L["Theramore Isle"] } -- Ship from Wettlands to Dustwallow Marsh
              end
            end

          end

        end


        --############################
        --##### Continent Outland ####
        --############################

        if self.db.profile.showMiniMapOutland then

        -- Outland RemoveBlizzPOIs 
          if db.activate.RemoveBlizzPOIs then
            minimap[108][28652247] = { mnID = 111, name = "", type = "MNL", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Shattrath City"] .. "\n" .. "\n" .. L["Portals"] .. "\n" .. " ==> " .. ORGRIMMAR .. "\n" .. " ==> " .. STORMWIND .. "\n" .. " ==> " .. L["Isle of Quel'Danas"] } -- Portal from Shattrath to Orgrimmar
          end

        -- Outland Transporting 
        if db.activate.MiniMapTransporting then

          --Draenor Toy Transport
          if self.db.profile.showMiniMapToyTransport then
            minimap[107][41275904] = { mnID = 550, name = "1. " .. L["Nagrand"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Nagrand"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 1 <=" .. " (" .. SPLASH_NEW_RIGHT_TITLE .. ")" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Mirror from Nagrand (Draenor) Oshugun Spirit Woods 50.35 57.21 to Nagrand (Outland) Oshugun Spirit Fields 41.27 59.04
            minimap[107][60362556] = { mnID = 550, name = "2. " .. L["Nagrand"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Nagrand"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 2 <=" .. " (" .. SPLASH_NEW_RIGHT_TITLE .. ")" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Mirror from Nagrand (Draenor) Throne of the Elements 71.41 21.94 to Nagrand (Outland) Throne of the Elements 60.36 25.56
            minimap[102][68208846] = { mnID = 550, name = "1. " .. L["Zangarmarsh"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Nagrand"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 3 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Mirror from Nagrand (Draenor) Zangar Shore 88.30 22.84 to Zangarmarsh (Outland) Entrance to Nagrand 68.2 88.46
            minimap[102][49195537] = { mnID = 550, name = "2. " .. L["Zangarmarsh"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Nagrand"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 4 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Mirror from Zangar Sea (Draenor) 'North-East coast of Nagrand, under water, top a mushroom' 81.24 8.98 to Zangarmarsh (Outland) Twinspire Ruins 'top a mushroom' 49.19 55.37
            minimap[102][82596613] = { mnID = 535, name = "3. " .. L["Zangarmarsh"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Talador"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 3 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Mirror from Talador (Draenor) 'Path of Glory' 68.42 9.32 to Zangarmarsh/Hellfire Peninsula (Outland) Boarder between Hellfire and Zangarmarsh 82.59 66.13
            minimap[105][50823143] = { mnID = 543, name = "1. " .. L["Blade's Edge Mountains"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Gorgrond"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 1 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Mirror from Gorgrond (Draenor) Outside BRF 50.82 31.43 to Blade's Edge Mountains (Outand) Gruul's Lair 50.82 31.43
            minimap[105][49417366] = { mnID = 543, name = "2. " .. L["Blade's Edge Mountains"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Gorgrond"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 2 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Mirror from Gorgrond (Draenor) Razor Bloom 49.41 73.66 to Blade's Edge Mountains (Outland) Razor Ridge 59.11 71.69
            minimap[105][46406466] = { mnID = 525, name = "3. " .. L["Blade's Edge Mountains"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Frostfire Ridge"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 1 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Mirror from Frostfire Ridge (Draenor) Gormaul Tower 21.82 45.31 to Blade's Edge Mountains (Outland) Bloodmaul Ravine 46.4 64.66
            minimap[105][39637739] = { mnID = 525, name = "4. " .. L["Blade's Edge Mountains"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Frostfire Ridge"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 2 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Mirror from Frostfire Ridge (Draenor) The Burning Glacier 37.53 60.71 to Blade's Edge Mountains (Outland) Bloodmaul Ravine 39.63 77.39
            minimap[100][80385106] = { mnID = 534, name = "1. " .. L["Hellfire Peninsula"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Tanaan Jungle"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 1 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Mirror from Tanaan Jungle (Draenor) 'Path of Glory' Dark Portal 70.3 54.53 to Hellfire Peninsula (Outland) The Path of Glory Dark Portal 80.38 51.6
            minimap[100][54974809] = { mnID = 534, name = "2. " .. L["Hellfire Peninsula"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Tanaan Jungle"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 2 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Mirror from Tanaan Jungle (Draenor) 'Path of Glory' HFC 49.56 50.73 to Hellfire Peninsula (Outland) The Path of Glory HFC 54.97 48.9
            minimap[100][64042173] = { mnID = 534, name = "3. " .. L["Hellfire Peninsula"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Tanaan Jungle"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 3 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Mirror from Tanaan Jungle (Draenor) Throne of Kil'jaeden 'New' 56.31 26.83 to Hellfire Peninsula (Outland) Throne of Kil'jaeden 'OId' 64.04 21.73
            minimap[104][61534607] = { mnID = 539, name = "1. " .. L["Shadowmoon Valley"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Shadowmoon Valley"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 1 <=" .. " (" .. SPLASH_NEW_RIGHT_TITLE .. ")" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Mirror from Shadowmoon Valley (Draenor) Path of Light 'Crossroad' 60.02 48.37 to Shadowmoon Valley (Outland) The Warden's Cage 61.53 46.07
            minimap[104][27103336] = { mnID = 539, name = "2. " .. L["Shadowmoon Valley"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Shadowmoon Valley"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 2 <=" .. " (" .. SPLASH_NEW_RIGHT_TITLE .. ")" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Mirror from Shadowmoon Valley (Draenor) Moonflower Valley 'Crossroad near Alliance garrison' 32.33 28.76 to Shadowmoon Valley (Outland) Legion Hold 'Crossroad' 27.1 33.36
            minimap[108][45374753] = { mnID = 535, name = "1. " .. L["Terokkar Forest"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Talador"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 1 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Mirror from Talador (Draenor) Deathweb Hollow 57.85 80.53 to Terokkar Forest (Outland) The Bone Wastes 45.37 47.53
            minimap[108][35271251] = { mnID = 535, name = "2. " .. L["Terokkar Forest"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Talador"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 2 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Mirror from Talador (Draenor) Shattrath City 'New' 50.41 35.19 to Terokkar Forest (Outland) Shattrath City 'Old' 35.27 12.51
            minimap[108][70787588] = { mnID = 542, name = "4. " .. L["Terokkar Forest"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Spires of Arak"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 1 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Mirror from Spires of Arak (Draenor) 'Ridge on the boarder with Talador' 47.4 12.45 to Terokkar Forest (Outland) Skettis 70.78 75.88
          end

          -- Outland Portals
            if self.db.profile.showMiniMapPortals then
                minimap[108][31332481] = { mnID = 111, name = "", type = "Portal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Shattrath City"] .. " " .. L["Portals"] .. "\n" ..  "\n" .. " ==> " .. ORGRIMMAR .. "\n" .. " ==> " .. STORMWIND .. "\n" .. " ==> " .. L["Isle of Quel'Danas"] } -- Portal from Shattrath to Orgrimmar

              if self.faction == "Horde" or db.activate.MiniMapEnemyFaction then
                minimap[100][88574770] = { mnID = 85, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Hellfire Peninsula"] .. " " .. L["Portal"] .. "\n" .. " ==> " .. ORGRIMMAR } -- Portal from Hellfire to Orgrimmar 
                minimap[100][89234945] = { mnID = 85, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Hellfire Peninsula"] .. " " .. L["Portal"] .. "\n" .. " ==> " .. ORGRIMMAR } -- Portal from Hellfire to Orgrimmar 
              end
            
              if self.faction == "Alliance" or db.activate.MiniMapEnemyFaction then
                minimap[100][88635281] = { mnID = 84,  name = "" , type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Hellfire Peninsula"] .. " " .. L["Portal"] .. "\n" .. " ==> " .. STORMWIND } -- Portal from Hellfire to Stormwind 
                minimap[100][89215101] = { mnID = 84,  name = "" , type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Hellfire Peninsula"] .. " " .. L["Portal"] .. "\n" .. " ==> " .. STORMWIND } -- Portal from Hellfire to Stormwind 
              end
            end

          end

        end


        --##############################
        --##### Continent Northrend ####
        --##############################

        if self.db.profile.showMiniMapNorthrend then

          -- Northrend Transporting 
          if db.activate.MiniMapTransporting then

          -- Northrend Portal
            if self.db.profile.showMiniMapPortals then

              --TWW Pre Event Portal nodes
              minimap[115][59835193] = { mnID = 629, name = "", type = "Portal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal To Dalaran
              --------------------------------------------------------------------------------------------------------------------------------------------------------

              minimap[123][49111534] = { mnID = 125, name = "", type = "Portal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. DUNGEON_FLOOR_DALARANCITY1  } -- LakeWintergrasp to Dalaran Portal 
              minimap[127][15724250] = { mnID = 125, TransportName = BATTLE_PET_SOURCE_2 .. " " .. REQUIRES_LABEL .. " " .. "The Magical Kingdom of Dalaran", type = "Portal", showInZone = false, showOnContinent = false, showOnMinimap = true, name = L["Portal"] .. " ==> " .. DUNGEON_FLOOR_DALARANCITY1, showWWW = true, www = "https://www.wowhead.com/wotlk/quest=12791/the-magical-kingdom-of-dalaran"} -- LakeWintergrasp to Dalaran Portal 
              minimap[119][40328303] = { mnID = 78, name = "", type = "Portal", showInZone = false, showOnContinent = false, showOnMinimap = true, dnID = L["Portal"] } -- Portal Sholazar to Unguro

              if self.faction == "Horde" or db.activate.MiniMapEnemyFaction then
                minimap[127][31103140] = { mnID = 85, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. ORGRIMMAR } --  Dalaran to Orgrimmar Portal
              end

              if self.faction == "Alliance" or db.activate.MiniMapEnemyFaction then
                minimap[127][26614271] = { mnID = 84,  name = "" , type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. STORMWIND } --  Dalaran to Stormwind City Portal
              end
            end

          -- Northrend Zeppelin
            if self.db.profile.showMiniMapZeppelins then 

              if self.faction == "Horde" or db.activate.MiniMapEnemyFaction then
                minimap[114][41365356] = { mnID = 85, name = "", type = "HZeppelin", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Zeppelin"] .. " ==> " .. ORGRIMMAR  } -- Zeppelin from Borean Tundra to Ogrimmar
              end
            end


          -- Northrend Ships
            if self.db.profile.showMiniMapShips then

              minimap[117][23245780] = { mnID = 115, name = "", type = "Ship", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Ship"] .. " ==> " .. POSTMASTER_LETTER_MOAKI } -- Ship from Kamagua to Moaki
              minimap[115][49977858] = { mnID = 117, name = "", type = "Ship", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Ship"] .. " ==> " .. POSTMASTER_LETTER_KAMAGUA } -- Ship from Moaki to Kamagua
              minimap[115][47597897] = { mnID = 114, name = "", type = "Ship", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Ship"] .. " ==> " .. L["Borean Tundra"] } -- Ship from Moaki to Unu'pe
              minimap[114][79075395] = { mnID = 115, name = "", type = "Ship", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Ship"] .. " ==> " .. POSTMASTER_LETTER_MOAKI } -- Ship from Unu'pe to Moaki

              if self.faction == "Alliance" or db.activate.MiniMapEnemyFaction then
                minimap[114][59636916] = { mnID = 84, name = "", type = "AShip", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Ship"] .. " ==> " .. STORMWIND } -- Ship to Stormwind from Borean Tundra
                minimap[117][61366271] = { mnID = 56, name = "", type = "AShip", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Ship"] .. " ==> " .. POSTMASTER_LETTER_WETLANDS } -- Ship to Wetlands from Borean Tundra
              end

            end

          end

        end


        --#############################
        --##### Continent Pandaria ####
        --#############################

        if self.db.profile.showMiniMapPandaria then

          -- Pandaria Transporting 
          if db.activate.MiniMapTransporting then

          -- Pandaria Portals
            if self.db.profile.showMiniMapPortals then

              if self.faction == "Horde" or db.activate.MiniMapEnemyFaction then
                minimap[504][33223269] = { mnID = 388, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Isle of Thunder"] } -- Portal from Isle of Thunder to Shado-Pan Garrison
                minimap[371][28501401] = { mnID = 85, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. ORGRIMMAR } -- Portal from Jade Forest to Orgrimmar
                minimap[379][85946249] = { mnID = 85, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. ORGRIMMAR } -- Portal from Jade Forest to Orgrimmar
                minimap[388][50657339] = { mnID = 504, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Isle of Thunder"] } -- Portal from Isle of Thunder to  Shado-Pan Garrison
                minimap[390][63371293] = { mnID = 85, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. ORGRIMMAR } -- Portal from Shrine of Two Moons to Orgrimmar
                minimap[418][10315365] = { mnID = 85, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Silvermoon City"] } -- Portal to Silvermoon
              end

              if self.faction == "Alliance" or db.activate.MiniMapEnemyFaction then
                minimap[504][64707347] = { mnID = 388, name = "", type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Isle of Thunder"] } -- Portal from Isle of Thunder to Shado-Pan Garrison
                minimap[371][46248517] = { mnID = 84, name = "", type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. STORMWIND } -- Portal from Jade Forest to STORMWIND
                minimap[388][49746867] = { mnID = 504, name = "", type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Isle of Thunder"] } -- Portal from Isle of Thunder to  Shado-Pan Garrison
                minimap[390][90596670] = { mnID = 84, name = "", type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. STORMWIND } -- Portal from Shrine of Seven Stars to Stormwind
                minimap[1530][90596670] = { mnID = 84, name = "", type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. STORMWIND } -- Portal from Shrine of Seven Stars to Stormwind
              end
            end

          end

        end
    
    
        --############################
        --##### Continent Draenor ####
        --############################
    
        if self.db.profile.showMiniMapDraenor then

          -- Draenor Transporting 
          if db.activate.MiniMapTransporting then

            --Draenor Toy Transport
            if self.db.profile.showMiniMapToyTransport then
              minimap[550][50355721] = { mnID = 107, name = "1. " .. L["Nagrand"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Nagrand"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 1 <=" .. " (" .. POSTMASTER_PIPE_OUTLAND .. ")" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Mirror from Nagrand (Draenor) Oshugun Spirit Woods 50.35 57.21 to Nagrand (Outland) Oshugun Spirit Fields 41.27 59.04
              minimap[550][71412194] = { mnID = 107, name = "2. " .. L["Nagrand"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Nagrand"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 2 <=" .. " (" .. POSTMASTER_PIPE_OUTLAND .. ")" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Mirror from Nagrand (Draenor) Throne of the Elements 71.41 21.94 to Nagrand (Outland) Throne of the Elements 60.36 25.56
              minimap[550][88302284] = { mnID = 102, name = "3. " .. L["Nagrand"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Zangarmarsh"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 1 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Mirror from Nagrand (Draenor) Zangar Shore 88.30 22.84 to Zangarmarsh (Outland) Entrance to Nagrand 68.2 88.46
              minimap[550][81240898] = { mnID = 102, name = "4. " .. L["Nagrand"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Zangarmarsh"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 2 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Mirror from Zangar Sea (Draenor) 'North-East coast of Nagrand, under water, top a mushroom' 81.24 8.98 to Zangarmarsh (Outland) Twinspire Ruins 'top a mushroom' 49.19 55.37
              minimap[543][50823143] = { mnID = 105, name = "1. " .. L["Gorgrond"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Blade's Edge Mountains"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 1 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Mirror from Gorgrond (Draenor) Outside BRF 50.82 31.43 to Blade's Edge Mountains (Outand) Gruul's Lair 50.82 31.43
              minimap[543][49417366] = { mnID = 105, name = "2. " .. L["Gorgrond"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Blade's Edge Mountains"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 2 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Mirror from Gorgrond (Draenor) Razor Bloom 49.41 73.66 to Blade's Edge Mountains (Outland) Razor Ridge 59.11 71.69
              minimap[525][21824531] = { mnID = 105, name = "1. " .. L["Frostfire Ridge"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Blade's Edge Mountains"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 3 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Mirror from Frostfire Ridge (Draenor) Gormaul Tower 21.82 45.31 to Blade's Edge Mountains (Outland) Bloodmaul Ravine 46.4 64.66
              minimap[525][37536071] = { mnID = 105, name = "2. " .. L["Frostfire Ridge"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Blade's Edge Mountains"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 4 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Mirror from Frostfire Ridge (Draenor) The Burning Glacier 37.53 60.71 to Blade's Edge Mountains (Outland) Bloodmaul Ravine 39.63 77.39
              minimap[534][70305453] = { mnID = 100, name = "1. " .. L["Tanaan Jungle"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Hellfire Peninsula"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 1 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Mirror from Tanaan Jungle (Draenor) 'Path of Glory' Dark Portal 70.3 54.53 to Hellfire Peninsula (Outland) The Path of Glory Dark Portal 80.38 51.6
              minimap[534][49565073] = { mnID = 100, name = "2. " .. L["Tanaan Jungle"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Hellfire Peninsula"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 2 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Mirror from Tanaan Jungle (Draenor) 'Path of Glory' HFC 49.56 50.73 to Hellfire Peninsula (Outland) The Path of Glory HFC 54.97 48.9
              minimap[534][56312683] = { mnID = 100, name = "3. " .. L["Tanaan Jungle"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Hellfire Peninsula"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 3 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Mirror from Tanaan Jungle (Draenor) Throne of Kil'jaeden 'New' 56.31 26.83 to Hellfire Peninsula (Outland) Throne of Kil'jaeden 'OId' 64.04 21.73
              minimap[539][60024837] = { mnID = 104, name = "1. " .. L["Shadowmoon Valley"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Shadowmoon Valley"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 1 <=" .. " (" .. POSTMASTER_PIPE_OUTLAND .. ")" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Mirror from Shadowmoon Valley (Draenor) Path of Light 'Crossroad' 60.02 48.37 to Shadowmoon Valley (Outland) The Warden's Cage 61.53 46.07
              minimap[539][32332876] = { mnID = 104, name = "2. " .. L["Shadowmoon Valley"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Shadowmoon Valley"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 2 <=" .. " (" .. POSTMASTER_PIPE_OUTLAND .. ")" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Mirror from Shadowmoon Valley (Draenor) Moonflower Valley 'Crossroad near Alliance garrison' 32.33 28.76 to Shadowmoon Valley (Outland) Legion Hold 'Crossroad' 27.1 33.36
              minimap[535][57858053] = { mnID = 108, name = "1. " .. L["Talador"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Terokkar Forest"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 1 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Mirror from Talador (Draenor) Deathweb Hollow 57.85 80.53 to Terokkar Forest (Outland) The Bone Wastes 45.37 47.53
              minimap[535][50413519] = { mnID = 108, name = "2. " .. L["Talador"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Terokkar Forest"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 2 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Mirror from Talador (Draenor) Shattrath City 'New' 50.41 35.19 to Terokkar Forest (Outland) Shattrath City 'Old' 35.27 12.51
              minimap[535][68420932] = { mnID = 102, name = "3. " .. L["Talador"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Terokkar Forest"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 3 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Mirror from Talador (Draenor) 'Path of Glory' 68.42 9.32 to Zangarmarsh/Hellfire Peninsula (Outland) Boarder between Hellfire and Zangarmarsh 82.59 66.13
              minimap[542][47401245] = { mnID = 108, name = "1. " .. L["Spires of Arak"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Terokkar Forest"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 4 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Mirror from Spires of Arak (Draenor) 'Ridge on the boarder with Talador' 47.4 12.45 to Terokkar Forest (Outland) Skettis 70.78 75.88
            end
    
          --Draenor Garrison Transport
            if self.db.profile.showMiniMapOgreWaygate then
            
              if self.faction == "Horde" then
                minimap[543][58033444] = { mnID = 590, name = L["Ogre Waygate to Garrison"], type = "OgreWaygate", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ogre Waygate Gorgrond
                minimap[525][59544752] = { mnID = 590, name = L["Ogre Waygate to Garrison"], type = "OgreWaygate", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ogre Waygate FrostfireRidge
                minimap[550][32164623] = { mnID = 590, name = L["Ogre Waygate to Garrison"], type = "OgreWaygate", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ogre Waygate Nagrand
                minimap[535][55084813] = { mnID = 590, name = L["Ogre Waygate to Garrison"], type = "OgreWaygate", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ogre Waygate Talador
                minimap[542][54625163] = { mnID = 590, name = L["Ogre Waygate to Garrison"], type = "OgreWaygate", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ogre Waygate SpiresOfArak
                minimap[539][50463566] = { mnID = 590, name = L["Ogre Waygate to Garrison"], type = "OgreWaygate", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ogre Waygate Shadowmoon Valley
              end
            
              if self.faction == "Alliance" then
                minimap[543][58033444] = { mnID = 582, name = L["Ogre Waygate to Garrison"], type = "OgreWaygate", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ogre Waygate Gorgrond
                minimap[525][59544752] = { mnID = 582, name = L["Ogre Waygate to Garrison"], type = "OgreWaygate", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ogre Waygate FrostfireRidge
                minimap[550][32164623] = { mnID = 582, name = L["Ogre Waygate to Garrison"], type = "OgreWaygate", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ogre Waygate Nagrand
                minimap[535][55084813] = { mnID = 582, name = L["Ogre Waygate to Garrison"], type = "OgreWaygate", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ogre Waygate Talador
                minimap[542][54625163] = { mnID = 582, name = L["Ogre Waygate to Garrison"], type = "OgreWaygate", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ogre Waygate SpiresOfArak
                minimap[539][50463566] = { mnID = 582, name = L["Ogre Waygate to Garrison"], type = "OgreWaygate", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ogre Waygate Shadowmoon Valley
                end
            end
    
    
          --Draenor Portals
            if self.db.profile.showMiniMapPortals then
            
              if self.faction == "Horde" or db.activate.MiniMapEnemyFaction then
                minimap[534][61024735] = { mnID = 624, name = L["Ashran"], type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal from Vol'mar to Ashran
                minimap[525][51416484] = { mnID = 624, name = L["Ashran"], type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal from Garrison to Ashran
                minimap[588][45001476] = { mnID = 85, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. ORGRIMMAR } -- Portal from Garrison to Ashran (Ashran Zone)
                minimap[588][42911275] = { mnID = 534, name = L["Vol'mar"], type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal from Ashran to Vol'mar Captive (Ashran Zone)
              end
            
              if self.faction == "Alliance" or db.activate.MiniMapEnemyFaction then
                minimap[588][43848830] = { mnID = 84,  name = "" , type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. STORMWIND } -- Portal from Ashran to Stormwind
                minimap[539][32471561] = { mnID = 622, name = L["Ashran"], type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal from Garison to Ashran
                minimap[588][38328897] = { mnID = 534, name = "", type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. SPLASH_NEW_6_2_FEATURE1_TITLE } -- Portal from Ashran to Lion's Watch
                minimap[534][57426032] = { mnID = 622, name = "", type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Ashran"] } -- Portal from Lion's Watch to (Ashran Zone)
              end
            end
          
          end

        end
    
    
        --#################################
        --##### Continent Broken Isles ####
        --#################################
    
        if self.db.profile.showMiniMapBrokenIsles then

          -- Broken Isles Transporting 
          if db.activate.MiniMapTransporting then

          --Broken Isles Portals
            if self.db.profile.showMiniMapPortals then
              minimap[630][46674136] = { name = "", type = "Portal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. "\n" .. " ==> " .. ORGRIMMAR .. "\n" .. " ==> " .. STORMWIND} -- Portal to Orgrimmar from Azsuna
              minimap[971][24952789] = { name = "", type = "Portal", mnID = 629, showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. DUNGEON_FLOOR_DALARANCITY1 } -- Portal to Dalaran
    
              if self.faction == "Horde" or db.activate.MiniMapEnemyFaction then
                minimap[652][46176383] = { mnID = 85, name = "" , type = "HPortal", showInZone = true, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. ORGRIMMAR } -- Thundertotem to Ogrimmar
                minimap[680][58188734] = { mnID = 85, name = "" , type = "HPortal", showInZone = true, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. ORGRIMMAR } -- Thundertotem to Ogrimmar
              end

              if self.faction == "Alliance" or db.activate.MiniMapEnemyFaction then
                minimap[971][27992149] = { name = "", type = "APortal", mnID = 629, showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. STORMWIND } -- Portal to Stormwind
                minimap[941][43092506] = { mnID = 84, name = "" , type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. STORMWIND } --  Portal from Krokuun - Vindikaar to Stormwind
                minimap[680][58678764] = { mnID = 84, name = "" , type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. STORMWIND } --  Portal from Krokuun - Vindikaar to Stormwind
              end
            end

          end

        end
    
    
        --#############################
        --##### Continent Zandalar ####
        --#############################
    
        if self.db.profile.showMiniMapZandalar then

          -- Zandalar Transporting 
          if db.activate.MiniMapTransporting then

          -- Zandalar Portals
            if self.db.profile.showMiniMapPortals then
            
              if self.faction == "Horde" or db.activate.MiniMapEnemyFaction then
                minimap[862][58474432] = { mnID = 1163, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Dazar'alor"] .. " " .. L["Portalroom"] .. L["(inside building)"] .. "\n" .. " ==> " .. L["Silvermoon City"] .. "\n" .. " ==> " .. ORGRIMMAR .. "\n" .. " ==> " .. L["Thunder Bluff"] .. "\n" .. " ==> " .. L["Silithus"] .. "\n" .. " ==> " .. L["Nazjatar"] } -- Portalroom from Dazar'alor
                minimap[862][59265920] = { mnID = 1165, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Zandalar"] .. " " .. L["Portals"] .. "\n" ..  "\n" .. " ==> " .. L["This Darkshore portal is only active if your faction is currently occupying Bashal'Aran"] .. "\n" .. " ==> " .. L["This Arathi Highlands portal is only active if your faction is currently occupying Ar'gorok"] } -- Portal to Arathi and Darkshore
                minimap[1355][52349627] = { mnID = 1165, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal from Newhome to Dazar'alor
              end
            end
    
    
          -- Zandalar Ships
            if self.db.profile.showMiniMapShips then
            
              if self.faction == "Horde" or db.activate.MiniMapEnemyFaction then
                minimap[862][58046505] = { mnID = 463, name = "", type = "HShip", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Ship"] .. " ==> " .. L["Echo Isles, Durotar"] } -- Ship from Zandalar to Echo Isles 
              end

            end


          -- Zandalar Transport
            if self.db.profile.showMiniMapTravel then

              if self.faction == "Horde" or db.activate.MiniMapEnemyFaction then
                minimap[862][58466298] = { mnID = 896, mnID2 = 895, mnID3 = 942, name = L["(Dread-Admiral Tattersail) will take you to Drustvar, Tiragarde Sound or Stormsong Valley"], dnID = " " .. ITEM_REQ_HORDE, type = "UndeadF", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ship from Dazar'alor to Drustvar, Tiragarde Sound or Stormsong Valley
                minimap[862][55325808] = { mnID = 1462, name = L["Captain Krooz"] .. " " .. L["Travel"], dnID = " " .. ITEM_REQ_HORDE, type = "GoblinF", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Transport from Dazar'alor to Mechagon 
              end
  
              if self.faction == "Alliance" or db.activate.MiniMapEnemyFaction then
                minimap[864][36693428] = { mnID = 1161, name = L["Barnard 'The Smasher' Bayswort"] .. " " .. L["Travel"], type = "KulM", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = " " .. ITEM_REQ_ALLIANCE .. "\n" .. " ==> " .. L["Boralus, Tiragarde Sound"] } -- Transport from Vol'dun to Boralus
                minimap[863][62064008] = { mnID = 1161, name = L["Desha Stormwallow"] .. " " .. L["Travel"], type = "DwarfF", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = " " .. ITEM_REQ_ALLIANCE .. "\n" .. " ==> " .. L["Boralus, Tiragarde Sound"] } -- Transport from Nazmir to Boralus
                minimap[862][40457103] = { mnID = 1161, name = L["Daria Smithson"] .. " " .. L["Travel"], type = "GilneanF", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName =  " " .. ITEM_REQ_ALLIANCE .. "\n" .. " ==> " .. L["Boralus, Tiragarde Sound"] } -- Transport from Zuldazar to Boralus 
              end
            end

          end

        end
        
    
        --##############################
        --##### Continent Kul Tiras ####
        --##############################
    
        if self.db.profile.showMiniMapKulTiras then

          -- Kul Tiras RemoveBlizzPOIs
          if db.activate.RemoveBlizzPOIs then

            if self.faction == "Alliance" or db.activate.MiniMapEnemyFaction then
              minimap[895][71533261] = { mnID = 1161, name = "", type = "AIcon", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Boralus"] .. " " .. "\n" .. "\n" .. L["Portalroom"] .. "\n" .. " ==> " .. STORMWIND .. "\n" .. " ==> " .. L["Silithus"] .. "\n" .. " ==> " .. L["Exodar"] .. "\n" .. " ==> " .. L["Ironforge"] .. "\n" .. "\n" .. L["Grand Admiral Jes-Tereth"] .. L["Travel"] .. "\n" .. " ==> " .. L["Nazmir"] .. "\n" .. " ==> " .. L["Zuldazar"] .. "\n" .. " ==> " .. L["Vol'dun"] .. "\n" .. "\n" .. L["Portals"] .. "\n" ..  "\n" .. " ==> " .. L["Arathi Highlands"] .. "\n" .. " ==> " .. L["Darkshore"] .. "\n" .. "\n" .. L["Ship"] .. "\n" .. " ==> " .. STORMWIND } -- Boralus Transports
            end

          end

          -- Kul Tiras Transporting 
          if db.activate.MiniMapTransporting then

          -- Kul Tiras Transport
            if self.db.profile.showMiniMapTravel then

              if self.faction == "Horde" or db.activate.MiniMapEnemyFaction then
                minimap[1462][75522266] = { mnID = 862, name = L["Captain Krooz"] .. " " .. L["Travel"], dnID = " " .. ITEM_REQ_HORDE, type = "GoblinF", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Transport from Mechagon to Zuldazar
                minimap[896][20614336] = { mnID = 862, name = L["Swellthrasher"] .. " " .. L["Travel"], type = "MOrcF", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = " " .. ITEM_REQ_HORDE .. "\n" .. " ==> " .. L["Zuldazar"] } -- Transport from Drustvar to Zuldazar
                minimap[942][51902432] = { mnID = 862, name = L["Grok Seahandler"] .. " " .. L["Travel"], type = "OrcM", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = " " .. ITEM_REQ_HORDE .. "\n" .. " ==> " .. L["Zuldazar"] } -- Transport from Stormsong Valley to Zuldazar
                minimap[895][87725089] = { mnID = 862, name = L["Erul Dawnbrook"] .. " " .. L["Travel"], type = "B11M", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = " " .. ITEM_REQ_HORDE .. "\n" .. " ==> " .. L["Zuldazar"] } -- Transport from Tiragarde Sound to Zuldazar 
              end
            end
          

          -- Kul Tiras Portals
            if self.db.profile.showMiniMapPortals then
            
              if self.faction == "Alliance" or db.activate.MiniMapEnemyFaction then
                minimap[895][74072427] = { mnID = 1161, name ="", type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Boralus"] .. " " .. L["Portalroom"] .. "\n" .. " " .. L["(inside building)"] .. "\n" .. " ==> " .. STORMWIND .. "\n" .. " ==> " .. L["Silithus"] .. "\n" .. " ==> " .. L["Exodar"] .. "\n" .. " ==> " .. L["Ironforge"] } -- Portalroom from Boralus } -- Portalroom from Boralus
              end
            end

          end

        end


        --################################
        --##### Continent Shadowlands ####
        --################################

        if self.db.profile.showMiniMapShadowlands then

          -- Shadowlands Transporting 
          if db.activate.MiniMapTransporting then

          -- Shadowlands Portals
            if self.db.profile.showMiniMapPortals then
              minimap[1543][42424210] = { mnID = 1670, name = "", type = "Portal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Oribos"] .. " " .. DUNGEON_FLOOR_GILNEAS2 } -- the Maw
              minimap[1961][64472406] = { mnID = 1671, name = "", type = "Portal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Oribos"] .. " " .. DUNGEON_FLOOR_GILNEAS3 } -- Korthia to Oribos
              minimap[1970][32956973] = { mnID = 1671, name = "", type = "Portal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Oribos"] .. " " .. DUNGEON_FLOOR_GILNEAS3 } -- Zereth Morthis to Oribos
            end

          -- Shadowlands Transporter
            if self.db.profile.showMiniMapTransport then
              minimap[1543][47294369] = { mnID = 1961, name = "", type = "TravelM", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Transport"] .. " ==> " .. L["Korthia"] } -- Maw to Korthia
              minimap[1961][64962366] = { mnID = 1543, name = "", type = "TravelM", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Transport"] .. " ==> " .. L["The Maw"] } -- Korthia to the Maw
            end

          end

        end
    
    
        --#################################
        --##### Continent Dragon Isles ####
        --#################################
    
        if self.db.profile.showMiniMapDragonIsles then

          -- Dragon Isles Transporting 
          if db.activate.MiniMapTransporting then

            -- Dragonflight Portals
            if self.db.profile.showMiniMapPortals then
              minimap[2239][89643770] = { mnID = 2200,  name = "", type = "WayGateGreen", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " ..L["Emerald Dream"] } -- Bel'ameth, Amirdrassil to Emerald Dream
              minimap[2025][40516283] = { mnID = 2112, name = "", type = "Portal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Valdrakken"] .. " " .. L["Portals"] .. "\n" ..  "\n" .. " ==> " .. L["Emerald Dream"] .. "\n" .. " ==> " .. L["Badlands"] .. "\n".." ==> " .. STORMWIND .. "\n" .. " ==> " .. ORGRIMMAR .. "\n" .. " ==> " .. L["The Timeways"] .. "\n" .. "\n" .. L["The Timeways"] .. " " .. L["Portals"] .. "\n" .. "\n" .. " ==> " .. L["Vashj'ir"] .. "\n" .. " ==> " .. POSTMASTER_LETTER_LORLATHIL .. "\n" .. " ==> " .. L["Zuldazar"] .. "\n" .. " ==> " .. L["Drustvar"] .. "\n" .. " ==> " .. L["Gorgrond"] } --  Valdrakken Portals
              minimap[2200][73065245] = { mnID = 2023, name = "", type = "WayGateGreen", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Ohn'ahran Plains"] } -- Portal The Emerald Dream to Ohn'ahran Plains
              minimap[2023][18295226] = { mnID = 2200, name = "", type = "WayGateGreen", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Emerald Dream"] } -- Portal to The Emerald Dream
            
              if self.faction == "Alliance" or db.activate.MiniMapEnemyFaction then
                minimap[2239][55466365] = { mnID = 84,  name = "", type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. STORMWIND } -- Valdrakken to Stormwind City Portal
                minimap[2239][55326472] = { name = "", type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portals"] .. "\n" .. " ==> " .. L["Darkshore"] .. "\n" .. " ==> " .. POSTMASTER_LETTER_HYJAL  .. "\n" .. " ==> " .. POSTMASTER_LETTER_LORLATHIL } -- Valdrakken to Stormwind City Portal
              end
            end
          
          
          -- Dragonflight Zeppelin
            if self.db.profile.showMiniMapZeppelins then      
            
              if self.faction == "Horde" or db.activate.MiniMapEnemyFaction then 
                minimap[2022][81632788] = { mnID = 85, name = "", type = "HZeppelin", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Zeppelin"] .. " ==> " .. ORGRIMMAR } -- Zeppelin from The Waking Shores to Orgrimmar 
              end
            end
          
          
          -- Dragonflight Ships
            if self.db.profile.showMiniMapShips then
              minimap[2239][49530434] = { mnID = 217, name = L["Ship"], type = "Ship", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ship from Amirdrassil to Gilneas     

              if self.faction == "Alliance" or db.activate.MiniMapEnemyFaction then
                minimap[2022][82243070] = { mnID = 84, name = "", type = "AShip", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Ship"] .. " ==> " .. STORMWIND } -- Ship from The Waking Shores to Stormwind
              end
            end

          end

        end
        

        --#################################
        --##### Continent Khaz Algar ######
        --#################################
    
        if self.db.profile.showMiniMapDragonIsles then

        -- Khaz Algar RemoveBlizzPOIs
          if db.activate.RemoveBlizzPOIs then
            minimap[2248][50004218] = { mnID = 2339, name = "", type = "MNL", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Dornogal"] .. " - " .. FACTION_NEUTRAL .. "\n" .. "\n" .. L["Portals"] .. "\n" .. " ==> " .. ORGRIMMAR .. "\n" .. " ==> " .. STORMWIND .. "\n" .. "\n" .. CALENDAR_TYPE_DUNGEON .. "\n" .. " ==> " .. "The Rookery" } -- Dornogal
          end

          -- Khaz Algar Transporting 
          if db.activate.MiniMapTransporting then

            -- Khaz Algar Portals
            if self.db.profile.showMiniMapPortals then

              if self.faction == "Horde" or db.activate.MiniMapEnemyFaction then
                minimap[2248][46913872] = { mnID = 2339, name = "", type = "HPortal", TransportName = L["Portal"] .. "\n" .. ORGRIMMAR, showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dornogal to Orgrimmar
              end

              if self.faction == "Alliance" or db.activate.MiniMapEnemyFaction then
                minimap[2248][47043781] = { mnID = 2339, name = "", type = "APortal", TransportName = L["Portal"] .. "\n" .. STORMWIND, showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dornogal to Stormwind
              end
            end
    
    
          -- Khaz Algar Zeppelin
            if self.db.profile.showMiniMapZeppelins then      
            
              if self.faction == "Horde" or db.activate.MiniMapEnemyFaction then 
                --minimap[2022][81632788] = { mnID = 85, name = "", type = "HZeppelin", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Zeppelin"] .. " ==> " .. ORGRIMMAR } -- Zeppelin from The Waking Shores to Orgrimmar 
              end
            end
    
    
          -- Khaz Algar Ships
            if self.db.profile.showMiniMapShips then
            
              if self.faction == "Alliance" or db.activate.MiniMapEnemyFaction then
                --minimap[2022][82243070] = { mnID = 84, name = "", type = "AShip", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Ship"] .. " ==> " .. STORMWIND } -- Ship from The Waking Shores to Stormwind
              end
            end

          end

        end
      end
  end
end