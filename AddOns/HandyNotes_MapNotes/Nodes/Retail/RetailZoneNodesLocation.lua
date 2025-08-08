local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

function ns.LoadZoneMapNodesLocationinfo(self)
local db = ns.Addon.db.profile
local nodes = ns.nodes
ns._currentSourceFile = "RetailZoneNodesLocation.lua"

--#####################################################################################################
--##########################        function to hide all nodes below         ##########################
--#####################################################################################################
  if not db.activate.HideMapNote then
    
    --#####################################################################################################
    --################################         Continent / Zone Map        ################################
    --#####################################################################################################
    
    if db.activate.ZoneMap then
       
        --#############################
        --##### Continent Kalimdor ####
        --#############################
    
      if self.db.profile.showZoneKalimdor then

        -- Kalimdor MapNotesIcons
          if self.db.profile.showZoneHordeAllyIcons then

            if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
              nodes[1][45780744] = { mnID = 85, name = "", type = "HIcon", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = ORGRIMMAR .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Portalroom"] .. "\n" .. " ==> " .. L["Silvermoon City"] .. "\n" .. " ==> " .. L["Valdrakken"] .. "\n" .. " ==> " .. L["Oribos"] .. "\n" .. " ==> " .. L["Azsuna"] .. "\n" .. " ==> " .. L["Zuldazar"] .. "\n" .. " ==> " .. L["Shattrath City"] .. "\n" .. " ==> " .. DUNGEON_FLOOR_DALARANCITY1 .. "\n" .. " ==> " .. DUNGEON_FLOOR_TANARIS18 .. "\n" .. " ==> " .. L["The Dark Portal"] .. "\n" .. " ==> " .. L["Dornogal"] .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " ==> " .. POSTMASTER_LETTER_HYJAL .. "\n" .. " ==> " .. L["Twilight Highlands"] .. "\n" .. " ==> " .. ARTIFACT_SHAMAN_TITLECARD_DEEPHOLM .. "\n" .. " ==> " .. L["Vashj'ir"] .. "\n" .. " ==> " .. L["Uldum"] .. "\n" .. " ==> " .. DUNGEON_FLOOR_TOLBARADWARLOCKSCENARIO0 .. "\n" .. "\n" .. L["Zeppelins"] .. "\n" .. " ==> " .. L["Thunder Bluff"] .. "\n" .. " ==> " .. L["Grom'gol, Stranglethorn Vale"] .. "\n" .. " ==> " .. POSTMASTER_LETTER_WARSONGHOLD .. "\n" .. "\n" .. CALENDAR_TYPE_DUNGEON .. "\n" .. " ==> " .. DUNGEON_FLOOR_RAGEFIRE1 } -- Portalroom from Dazar'alor
              nodes[76][21288964] = { mnID = 85, name = "", type = "HIcon", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = ORGRIMMAR .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Portalroom"] .. "\n" .. " ==> " .. L["Silvermoon City"] .. "\n" .. " ==> " .. L["Valdrakken"] .. "\n" .. " ==> " .. L["Oribos"] .. "\n" .. " ==> " .. L["Azsuna"] .. "\n" .. " ==> " .. L["Zuldazar"] .. "\n" .. " ==> " .. L["Shattrath City"] .. "\n" .. " ==> " .. DUNGEON_FLOOR_DALARANCITY1 .. "\n" .. " ==> " .. DUNGEON_FLOOR_TANARIS18 .. "\n" .. " ==> " .. L["The Dark Portal"] .. "\n" .. " ==> " .. L["Dornogal"] .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " ==> " .. POSTMASTER_LETTER_HYJAL .. "\n" .. " ==> " .. L["Twilight Highlands"] .. "\n" .. " ==> " .. ARTIFACT_SHAMAN_TITLECARD_DEEPHOLM .. "\n" .. " ==> " .. L["Vashj'ir"] .. "\n" .. " ==> " .. L["Uldum"] .. "\n" .. " ==> " .. DUNGEON_FLOOR_TOLBARADWARLOCKSCENARIO0 .. "\n" .. "\n" .. L["Zeppelins"] .. "\n" .. " ==> " .. L["Thunder Bluff"] .. "\n" .. " ==> " .. L["Grom'gol, Stranglethorn Vale"] .. "\n" .. " ==> " .. POSTMASTER_LETTER_WARSONGHOLD .. "\n" .. "\n" .. CALENDAR_TYPE_DUNGEON .. "\n" .. " ==> " .. DUNGEON_FLOOR_RAGEFIRE1 } -- Portalroom from Dazar'alor
              nodes[10][80450975] = { mnID = 85, name = "", type = "HIcon", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = ORGRIMMAR .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Portalroom"] .. "\n" .. " ==> " .. L["Silvermoon City"] .. "\n" .. " ==> " .. L["Valdrakken"] .. "\n" .. " ==> " .. L["Oribos"] .. "\n" .. " ==> " .. L["Azsuna"] .. "\n" .. " ==> " .. L["Zuldazar"] .. "\n" .. " ==> " .. L["Shattrath City"] .. "\n" .. " ==> " .. DUNGEON_FLOOR_DALARANCITY1 .. "\n" .. " ==> " .. DUNGEON_FLOOR_TANARIS18 .. "\n" .. " ==> " .. L["The Dark Portal"] .. "\n" .. " ==> " .. L["Dornogal"] .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " ==> " .. POSTMASTER_LETTER_HYJAL .. "\n" .. " ==> " .. L["Twilight Highlands"] .. "\n" .. " ==> " .. ARTIFACT_SHAMAN_TITLECARD_DEEPHOLM .. "\n" .. " ==> " .. L["Vashj'ir"] .. "\n" .. " ==> " .. L["Uldum"] .. "\n" .. " ==> " .. DUNGEON_FLOOR_TOLBARADWARLOCKSCENARIO0 .. "\n" .. "\n" .. L["Zeppelins"] .. "\n" .. " ==> " .. L["Thunder Bluff"] .. "\n" .. " ==> " .. L["Grom'gol, Stranglethorn Vale"] .. "\n" .. " ==> " .. POSTMASTER_LETTER_WARSONGHOLD .. "\n" .. "\n" .. CALENDAR_TYPE_DUNGEON .. "\n" .. " ==> " .. DUNGEON_FLOOR_RAGEFIRE1 } -- Portalroom from Dazar'alor
            end

            if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
              nodes[97][27243965] = { mnID = 103, name = "", type = "AIcon", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Exodar"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " ==> " .. STORMWIND } -- Portal Exodar to Teldrassil
            end

          end          

        if db.activate.ZoneTransporting then

        -- Kalimdor Darkmoon
          if self.db.profile.showZoneDarkmoon then

            if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
              nodes[7][36003600] = { mnID = 407, name = FACTION_HORDE .. " " .. L["Portal"] .. " ==> " .. CALENDAR_FILTER_DARKMOON, TransportName = "\n" .. REQUIRES_LABEL .. " " .. CALENDAR_FILTER_DARKMOON .. "\n" .. L["Starting on the first Sunday of each month for one week"], type = "DarkMoon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mulgore Portal to the Darkmoon
            end

          end
          
        -- Kalimdor Portals
          if self.db.profile.showZonePortals then

            nodes[57][26305072] = { mnID = 89, name = "", type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Darnassus"] .. " " .. L["Portal"] .. "\n" .. " ==> " .. L["Rut'theran"] } -- Portal To Teldrassil from Darnassus
            nodes[57][54998820] = { mnID = 89, name = "", type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. L["Darnassus"] } -- Portal To Darnassus from Teldrassil
            nodes[78][50560773] = { mnID = 119, name = "", type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false, dnID = L["Portal"] } -- Portal Unguro to Sholazar
            nodes[74][58142669] = { mnID = 85, mnID2 = 84, name = "", type = "PortalS", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portals"] .. "\n" .. "\n" .. FACTION_HORDE .. "\n" .. " ==> " .. ORGRIMMAR .. "\n" .. "\n" .. FACTION_ALLIANCE .. "\n" .. " ==> " .. STORMWIND } -- Portal from Tanaris to Orgrimmar or Stormwind
            nodes[71][65984960] = { mnID = 85, mnID2 = 84, name = "", type = "PortalS", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portals"] .. "\n" .. "\n" .. FACTION_HORDE .. "\n" .. " ==> " .. ORGRIMMAR .. "\n" .. "\n" .. FACTION_ALLIANCE .. "\n" .. " ==> " .. STORMWIND } -- Portal from Tanaris to Orgrimmar or Stormwind
            nodes[81][41614520] = { mnID = 862, mnID2 = 1161, name = "", type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portals"] .. "\n" .. "\n" .. FACTION_HORDE .. "\n" .. " ==> " .. L["Zandalar"] .. "\n" .. "\n" .. FACTION_ALLIANCE .. "\n" .. " ==> " .. L["Boralus, Tiragarde Sound"] } -- Portal from Silithus to Zandalar or Boralus 

            if self.faction == "Horde" or db.activate.ZoneEnemyFaction then  
              nodes[62][46243511] = { mnID = 862, name = "", TransportName = L["Portal"] .. " ==> " .. L["Zuldazar"] .. "\n" .. "\n" .. L["(its only shown up ingame if your faction\n is currently occupying Bashal'Aran)"], type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal from New Darkshore to Zandalar 
              nodes[207][50945311] = { mnID = 85, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. ORGRIMMAR } -- Portal To Orgrimmar from Deepholm
              nodes[198][63482447] = { mnID = 85, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. ORGRIMMAR } -- Portal To Orgrimmar from Hyjal
            end
  
            if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
              nodes[57][26305072] = { mnID = 89, name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portals"] .. "\n" .. " ==> " .. L["Rut'theran"] .. "\n" .. " ==> " .. L["Exodar"]  .. "\n" .. " ==> " .. L["Hellfire Peninsula"] } -- Portal To Teldrassil from Darnassus
              nodes[97][20235409] = { mnID = 57, name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. L["Rut'theran"] } -- Portal Exodar to Teldrassil
              nodes[62][53731873] = { mnID = 2239, name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. L["Bel'ameth, Amirdrassil"] } -- Portal from New Darkshore to Bel'ameth, Amirdrassil
              nodes[62][48023628] = { mnID = 1161, name = "", TransportName = L["Portal"] .. " ==> " .. L["Boralus"] .. "\n" .. "\n" .. L["(its only shown up ingame if your faction\n is currently occupying Bashal'Aran)"], type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal from New Darkshore to Zandalar
              nodes[198][62602315] = { mnID = 84,  name = "" , type = "APortalS", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. STORMWIND } -- Portal To Stormwind from Hyjal
              nodes[207][48525385] = { mnID = 84, name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. STORMWIND } -- Portal To Stormwind
              nodes[57][55039371] = { mnID = 84, name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. STORMWIND } -- Portal To Stormwind from Teldrassil
              nodes[57][52278948] = { mnID = 97, name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. L["Azuremyst Isle"] } -- Portal To Exodar from Teldrassil
            end
          end
    
        --Kalimdor Zeppelins
          if self.db.profile.showZoneZeppelins then
            nodes[1][55941320] = { mnID = 2022, name = "", type = "HZeppelin", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Zeppelin"] .. " ==> " .. L["The Waking Shores, Dragon Isles"] } -- Zeppelin from Orgrimmar to Waking Shores
            nodes[7][33422231] = { mnID = 85, name = "", type = "HZeppelin", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Zeppelin"] .. " ==> " .. ORGRIMMAR } -- Zeppelin from Thunder Bluff to Orgrimmar
          end
    
        -- Kalimdor Ships
          if self.db.profile.showZoneShips then

            nodes[1][35217941] = { mnID = 210, name = "", type = "Ship", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Ship"] .. " ==> " .. POSTMASTER_LETTER_STRANGLETHORNVALE } -- Ship from Ratchet to Booty Bay Ship
            nodes[10][70237341] = { mnID = 210, name = "", type = "Ship", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Ship"] .. " ==> " .. POSTMASTER_LETTER_STRANGLETHORNVALE } -- Ship from Ratchet to Booty Bay Ship

            if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
              nodes[463][71903797] = { mnID = 862, name = "", type = "HShip", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Ship"] .. " ==> " .. L["Zuldazar"] } -- Ship from Echo Isles to Zuldazar  
              nodes[1][72257893] = { mnID = 862, name = "", type = "HShip", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Ship"] .. " ==> " .. L["Zuldazar"] } -- Ship from Echo Isles to Zuldazar            
            end
    
            if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
              nodes[70][71545615] = { mnID = 56, name = "", type = "AShip", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Ship"] .. " ==> " .. POSTMASTER_LETTER_WETLANDS } -- Ship from Dustwallow Marsh to Wetlands
            end
          end

        end

      end
    
    
        --####################################
        --##### Continent Eastern Kingdom ####
        --####################################
    
      if self.db.profile.showZoneEasternKingdom then

        -- Azeroth Eastern Kingdom MapNotesIcons
          if self.db.profile.showZoneHordeAllyIcons then

            if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
              nodes[224][42073378] = { mnID = 50, name = "", type = "HIcon", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Grom'gol, Stranglethorn Vale"] .. " " .. "\n" .. "\n" .. L["Zeppelin"] .. "\n" .. " ==> " .. ORGRIMMAR .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " ==> " .. L["Ruins of Lordaeron"] } -- Transport from Stranglethorn Valley to Ogrimmar and Ruins of Lordaeron
              nodes[18][62167276] = { mnID = 90, name = "", type = "HIcon", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Undercity"] .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " ==> " .. L["Hellfire Peninsula"] } -- Portalroom from Dazar'alor
              nodes[94][56593942] = { mnID = 110, name = "", type = "HIcon", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Silvermoon City"] .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " ==> " .. ORGRIMMAR .. "\n" .. " ==> " .. L["Ruins of Lordaeron"] } -- Portal to Orgrimmar, Ruins of Lordaeron from Silvermoon   
            end

            if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                nodes[57][26305072] = { mnID = 89, name = "", type = "AIcon", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Darnassus"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Portals"] .. "\n" .. " ==> " .. L["Rut'theran"] .. "\n" .. " ==> " .. L["Exodar"]  .. "\n" .. " ==> " .. L["Hellfire Peninsula"] } -- Portal To Teldrassil from Darnassus
                nodes[27][59732929] = { mnID = 87, name = "", type = "AIcon", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Ironforge"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. DUNGEON_FLOOR_DEEPRUNTRAM1 .. "\n" .. " ==> " .. STORMWIND } -- Carriage To Stormwind
                nodes[37][32894742] = { mnID = 84, name = "", type = "AIcon", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = STORMWIND .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Portalroom"] .. "\n" .. " ==> " .. L["Ashran"] .. "\n" .. " ==> " .. L["Valdrakken"] .. "\n" .. " ==> " .. L["Boralus, Tiragarde Sound"] .. "\n" .. " ==> " .. L["Oribos"] .. "\n" .. " ==> " .. L["Azsuna"] .. "\n" .. " ==> " .. L["Shattrath City"] .. "\n" .. " ==> " .. L["Jade Forest"] .. "\n" .. " ==> " .. DUNGEON_FLOOR_DALARANCITY1 .. "\n" .. " ==> " .. DUNGEON_FLOOR_TANARIS18 .. "\n" .. " ==> " .. L["Exodar"] .. "\n" ..  " ==> " .. L["Bel'ameth, Amirdrassil"] .. "\n" .. " ==> " .. L["The Dark Portal"] .. "\n" .. " ==> " .. L["Dornogal"] .. "\n" .. "\n" .. L["Portals"] .. "\n" ..  "\n" .. " ==> " .. L["Uldum"] .. "\n" .. " ==> " .. L["Vashj'ir"] .. "\n" .. " ==> " .. POSTMASTER_LETTER_HYJAL .. "\n" .. " ==> " .. ARTIFACT_SHAMAN_TITLECARD_DEEPHOLM .. "\n" .. " ==> " .. L["Twilight Highlands"] .. "\n" .. " ==> " .. DUNGEON_FLOOR_TOLBARADWARLOCKSCENARIO0 .. "\n" .. "\n" .. L["Ships"] .. "\n" .. " ==> " .. POSTMASTER_LETTER_VALIANCEKEEP .. "\n" .. " ==> " .. L["Boralus, Tiragarde Sound"] .. "\n" .. " ==> " .. L["The Waking Shores, Dragon Isles"] .. "\n" .. "\n" .. DUNGEON_FLOOR_DEEPRUNTRAM1 .. "\n" .. " ==> " .. L["Ironforge"] .. "\n" .. "\n" .. " ==> " .. CALENDAR_TYPE_DUNGEON .. "\n" .. " ==> " .. DUNGEON_FLOOR_THESTOCKADE1 }
            end
          end

        if db.activate.ZoneTransporting then

        -- Eastern Kingdom Darkmoon  
          if self.db.profile.showZoneDarkmoon then
            
            if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
              nodes[37][41786951] = { mnID = 407, name = FACTION_ALLIANCE .. " " .. L["Portal"] .. " ==> " .. CALENDAR_FILTER_DARKMOON, TransportName = "\n" .. REQUIRES_LABEL .. " " .. CALENDAR_FILTER_DARKMOON .. "\n" .. L["Starting on the first Sunday of each month for one week"], type = "DarkMoon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Elwynn Forest Portal to the Darkmoon
            end
          end

        --Eastern Kingdom Portals
          if self.db.profile.showZonePortals then

            nodes[244][47135189] = { mnID = 85, name = "", type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .."\n" .."\n" .. " ==> " .. ORGRIMMAR .. "\n" .. " " .. JUST_OR .. "\n" .. " ==> " .. STORMWIND } -- Portal Tol Orgrimmar or Stormwind from Baradinhold Tol Barad pvp Area
            nodes[17][55005418] = { mnID = 624, mnID2 = 622, name = "", type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["The Dark Portal"] .. "\n" .. "\n" .. FACTION_HORDE .. "\n" .. " ==> " .. L["Warspear"] .. "\n" .. "\n" .. FACTION_ALLIANCE .. "\n" .. " ==> " .. L["Stormshield"] } -- Portal from Tanaris to Orgrimmar 

            if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
              nodes[18][62167276] = { mnID = 90, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. "\n" .. " ==> " .. L["Hellfire Peninsula"] } -- Portalroom from Dazar'alor
              nodes[17][72694917] = { mnID = 85, name = "" , type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. ORGRIMMAR .. "\n" .. "\n" .. L["If you don't see this icon, it's probably in a different phase. \nChange the phase on Zidormi"] } -- Portal Blasted Lands to Orgrimmar 
              nodes[18][60735867] = { mnID = 85, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. ORGRIMMAR } -- Portal to Orgrimmar from Tirisfal
              nodes[18][61905899] = { mnID = 50, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. L["Grom'gol, Stranglethorn Vale"] } -- Portal to Stranglethorn from Tirisfal
              nodes[18][59085891] = { mnID = 117, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. L["Howling Fjord"] } -- Portal to Howling Fjord from Tirisfal
              nodes[18][59416744] = { mnID = 110, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. L["Silvermoon City"] } -- Portal to Silvermoon from Tirisfal
              nodes[2070][59506694] = { mnID = 85, name = "", type = "HPortalS", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. ORGRIMMAR } -- Portal to Orgrimmar from Tirisfal
              nodes[2070][59506797] = { mnID = 50, name = "", type = "HPortalS", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. L["Grom'gol, Stranglethorn Vale"] } -- Portal to Stranglethorn from Tirisfal
              nodes[2070][60126689] = { mnID = 117, name = "", type = "HPortalS", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. L["Howling Fjord"] } -- Portal to Howling Fjord from Tirisfal
              nodes[2070][59406743] = { mnID = 110, name = "", type = "HPortalS", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. L["Silvermoon City"] } -- Portal to Silvermoon from Tirisfal
              nodes[50][37545100] = { mnID = 18, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. L["Ruins of Lordaeron"] } -- Portal to Undercity from Grom'gol
              nodes[94][54552795] = { mnID = 85, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. ORGRIMMAR } -- Portal to Orgrimmar from Silvermoon 
              nodes[94][51262623] = { mnID = 18, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. L["Ruins of Lordaeron"] } -- Portal to Ruins of Lordaeron from Silvermoon 
              nodes[14][27442938] = { mnID = 862, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. L["Zandalar"] .. "\n" .. " " .. "(" .. L["This Arathi Highlands portal is only active if your faction is currently occupying Ar'gorok"] .. ")" }
              nodes[245][56397967] = { mnID = 85, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. ORGRIMMAR } -- Portal Tol Bard to Orgimmar  
              nodes[241][73595355] = { mnID = 85, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. ORGRIMMAR } -- Portal Tol Orgrimmar from Twilight Highlands  
            end
    
            if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
              nodes[14][22246515] = { mnID = 1161, name = "", type = "APortal", showInZone = true,  showOnContinent = false, TransportName = L["Portal"] .. " ==> " .. L["Boralus"] .. "\n" .. " " .. "(" .. L["This Arathi Highlands portal is only active if your faction is currently occupying Ar'gorok"] .. ")" } -- Portal from Arathi to Zandalar
              nodes[37][29592388] = { mnID = 84, name = "", type = "Carriage", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = DUNGEON_FLOOR_DEEPRUNTRAM1 .. " ==> " .. L["Ironforge"] } -- Deeprun Stormwind to Ironforge
              nodes[37][33521611] = { mnID = 84, name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = STORMWIND .. " " .. L["Portals"] .. "\n" ..  "\n" .. " ==> " .. L["Uldum"] .. "\n" .. " ==> " .. L["Vashj'ir"] .. "\n" .. " ==> " .. POSTMASTER_LETTER_HYJAL .. "\n" .. " ==> " .. ARTIFACT_SHAMAN_TITLECARD_DEEPHOLM .. "\n" .. " ==> " .. L["Twilight Highlands"] .. "\n" .. " ==> " .. DUNGEON_FLOOR_TOLBARADWARLOCKSCENARIO0 } -- Portalroom from Stormwind
              nodes[37][15153165] = { mnID = 84, name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = STORMWIND .. " " .. L["Portalroom"] .. "\n" .. " ==> " .. L["Ashran"] .. "\n" .. " ==> " .. L["Valdrakken"] .. "\n" .. " ==> " .. L["Boralus, Tiragarde Sound"] .. "\n" .. " ==> " .. L["Oribos"] .. "\n" .. " ==> " .. L["Azsuna"] .. "\n" .. " ==> " .. L["Shattrath City"] .. "\n" .. " ==> " .. L["Jade Forest"] .. "\n" .. " ==> " .. DUNGEON_FLOOR_DALARANCITY1 .. "\n" .. " ==> " .. DUNGEON_FLOOR_TANARIS18 .. "\n" .. " ==> " .. L["Exodar"] .. "\n" ..  " ==> " .. L["Bel'ameth, Amirdrassil"] } -- Portalroom from Stormwind
              nodes[17][66382798] = { mnID = 84, name = "" , type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. STORMWIND .. "\n" .. "\n" .. L["If you don't see this icon, it's probably in a different phase. \nChange the phase on Zidormi"] } -- Portal to Stormwind 
              nodes[245][75235887] = { mnID = 84, name = "" , type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. STORMWIND } -- Portal Tol Bard to Stormwind
              nodes[241][79447784] = { mnID = 84, name = "" , type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. STORMWIND } -- Portal Twilight Highlands to Stormwind   
            end
          end


        --Eastern Kingdom Portals without MapNotesIcons
          if self.db.profile.showZonePortals and not self.db.profile.showZoneHordeAllyIcons then
            nodes[224][42233253] = { mnID = 18, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. L["Ruins of Lordaeron"] } -- Portal to Undercity from Grom'gol
          end



    
        --Eastern Kingdom Zeppelins
          if self.db.profile.showZoneZeppelins then

            if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
              nodes[50][36955279] = { mnID = 85, name = "", type = "HZeppelin", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Zeppelin"] .. " ==> " .. ORGRIMMAR } -- Ship from Booty Bay to Ratchet
            end
          end


          --Eastern Kingdom Zeppelins without MapNotesIcons
          if self.db.profile.showZonePortals and not self.db.profile.showZoneHordeAllyIcons then
            nodes[224][41993471] = { mnID = 85, name = "", type = "HZeppelin", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Zeppelin"] .. " ==> " .. ORGRIMMAR } -- Ship from Booty Bay to Ratchet
          end

    
        --Eastern Kingdom Ships
          if self.db.profile.showZoneShips then
            nodes[217][63659592] = { mnID = 2239, name = "", type = "Ship", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Ship"] .. " ==> " .. L["Bel'ameth, Amirdrassil"] } -- Ship from Gilneas to Bel ameth
            nodes[224][36947582] = { mnID = 210, name = "", type = "Ship", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Ship"] .. " ==> " .. L["Ratchet"] } -- Ship from Booty Bay to Ratchet
            nodes[210][39336720] = { mnID = 10, name = "", type = "Ship", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Ship"] .. " ==> " .. L["Ratchet"] } -- Ship from Booty Bay to Ratchet

            if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
              nodes[37][08722976] = { mnID = 1161, name = "", type = "AShip", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Ships"] .. "\n" .. " ==> " .. L["Boralus, Tiragarde Sound"] .. "\n".. " ==> " .. L["The Waking Shores, Dragon Isles"] } -- Ship from Stormwind to Boralus
              nodes[37][07622435] = { mnID = 114, name = "", type = "AShip", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Ship"] .. " ==> " .. POSTMASTER_LETTER_VALIANCEKEEP } -- Ship from Stormwind to Valiance Keep
              nodes[56][04175637] = { mnID = 117, name = "", type = "AShip", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Ship"] .. " ==> " .. L["Howling Fjord"] } -- Ship from Wettlands to Howling Fjord
              nodes[56][06366226] = { mnID = 70, name = "", type = "AShip", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Ship"] .. " ==> " .. L["Theramore Isle"] } -- Ship from Wettlands to Dustwallow Marsh
            end
          end

        end
    
      end
    
    
        --############################
        --##### Continent Outland ####
        --############################
    
      if self.db.profile.showZoneOutland then

        -- Outland MapNotesIcons 
          if self.db.profile.showZoneHordeAllyIcons then
            nodes[108][28652247] = { mnID = 111, name = "", type = "MNL", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Shattrath City"] .. "\n" .. "\n" .. L["Portals"] .. "\n" .. " ==> " .. ORGRIMMAR .. "\n" .. " ==> " .. STORMWIND .. "\n" .. " ==> " .. L["Isle of Quel'Danas"] } -- Portal from Shattrath to Orgrimmar
          end

        if db.activate.ZoneTransporting then

          --Draenor Toy Transport
          if self.db.profile.showZoneMirror then
            nodes[107][41275904] = { mnID = 550, name = "1. " .. L["Nagrand"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Nagrand"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 1 <=" .. " (" .. SPLASH_NEW_RIGHT_TITLE .. ")" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Nagrand (Draenor) Oshugun Spirit Woods 50.35 57.21 to Nagrand (Outland) Oshugun Spirit Fields 41.27 59.04
            nodes[107][60362556] = { mnID = 550, name = "2. " .. L["Nagrand"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Nagrand"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 2 <=" .. " (" .. SPLASH_NEW_RIGHT_TITLE .. ")" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Nagrand (Draenor) Throne of the Elements 71.41 21.94 to Nagrand (Outland) Throne of the Elements 60.36 25.56
            nodes[102][68208846] = { mnID = 550, name = "1. " .. L["Zangarmarsh"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Nagrand"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 3 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Nagrand (Draenor) Zangar Shore 88.30 22.84 to Zangarmarsh (Outland) Entrance to Nagrand 68.2 88.46
            nodes[102][49195537] = { mnID = 550, name = "2. " .. L["Zangarmarsh"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Nagrand"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 4 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Zangar Sea (Draenor) 'North-East coast of Nagrand, under water, top a mushroom' 81.24 8.98 to Zangarmarsh (Outland) Twinspire Ruins 'top a mushroom' 49.19 55.37
            nodes[102][82596613] = { mnID = 535, name = "3. " .. L["Zangarmarsh"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Talador"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 3 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Talador (Draenor) 'Path of Glory' 68.42 9.32 to Zangarmarsh/Hellfire Peninsula (Outland) Boarder between Hellfire and Zangarmarsh 82.59 66.13
            nodes[105][66192634] = { mnID = 543, name = "1. " .. L["Blade's Edge Mountains"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Gorgrond"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 1 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Gorgrond (Draenor) Outside BRF 50.82 31.43 to Blade's Edge Mountains (Outand) Gruul's Lair 50.82 31.43
            nodes[105][59117166] = { mnID = 543, name = "2. " .. L["Blade's Edge Mountains"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Gorgrond"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 2 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Gorgrond (Draenor) Razor Bloom 49.41 73.66 to Blade's Edge Mountains (Outland) Razor Ridge 59.11 71.69
            nodes[105][46386404] = { mnID = 525, name = "3. " .. L["Blade's Edge Mountains"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Frostfire Ridge"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 1 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Frostfire Ridge (Draenor) Gormaul Tower 21.82 45.31 to Blade's Edge Mountains (Outland) Bloodmaul Ravine 46.4 64.66
            nodes[105][39637739] = { mnID = 525, name = "4. " .. L["Blade's Edge Mountains"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Frostfire Ridge"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 2 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Frostfire Ridge (Draenor) The Burning Glacier 37.53 60.71 to Blade's Edge Mountains (Outland) Bloodmaul Ravine 39.63 77.39
            nodes[100][80385106] = { mnID = 534, name = "1. " .. L["Hellfire Peninsula"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Tanaan Jungle"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 1 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Tanaan Jungle (Draenor) 'Path of Glory' Dark Portal 70.3 54.53 to Hellfire Peninsula (Outland) The Path of Glory Dark Portal 80.38 51.6
            nodes[100][54974809] = { mnID = 534, name = "2. " .. L["Hellfire Peninsula"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Tanaan Jungle"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 2 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Tanaan Jungle (Draenor) 'Path of Glory' HFC 49.56 50.73 to Hellfire Peninsula (Outland) The Path of Glory HFC 54.97 48.9
            nodes[100][64042173] = { mnID = 534, name = "3. " .. L["Hellfire Peninsula"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Tanaan Jungle"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 3 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Tanaan Jungle (Draenor) Throne of Kil'jaeden 'New' 56.31 26.83 to Hellfire Peninsula (Outland) Throne of Kil'jaeden 'OId' 64.04 21.73
            nodes[104][61534607] = { mnID = 539, name = "1. " .. L["Shadowmoon Valley"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Shadowmoon Valley"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 1 <=" .. " (" .. SPLASH_NEW_RIGHT_TITLE .. ")" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Shadowmoon Valley (Draenor) Path of Light 'Crossroad' 60.02 48.37 to Shadowmoon Valley (Outland) The Warden's Cage 61.53 46.07
            nodes[104][27103336] = { mnID = 539, name = "2. " .. L["Shadowmoon Valley"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Shadowmoon Valley"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 2 <=" .. " (" .. SPLASH_NEW_RIGHT_TITLE .. ")" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Shadowmoon Valley (Draenor) Moonflower Valley 'Crossroad near Alliance garrison' 32.33 28.76 to Shadowmoon Valley (Outland) Legion Hold 'Crossroad' 27.1 33.36
            nodes[108][45374753] = { mnID = 535, name = "1. " .. L["Terokkar Forest"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Talador"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 1 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Talador (Draenor) Deathweb Hollow 57.85 80.53 to Terokkar Forest (Outland) The Bone Wastes 45.37 47.53
            nodes[108][35271251] = { mnID = 535, name = "2. " .. L["Terokkar Forest"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Talador"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 2 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Talador (Draenor) Shattrath City 'New' 50.41 35.19 to Terokkar Forest (Outland) Shattrath City 'Old' 35.27 12.51
            nodes[108][70787588] = { mnID = 542, name = "4. " .. L["Terokkar Forest"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Spires of Arak"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 1 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Spires of Arak (Draenor) 'Ridge on the boarder with Talador' 47.4 12.45 to Terokkar Forest (Outland) Skettis 70.78 75.88
          end

        -- Outland Portals
          if self.db.profile.showZonePortals then
              nodes[108][31332481] = { mnID = 111, name = "", type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Shattrath City"] .. " " .. L["Portals"] .. "\n" ..  "\n" .. " ==> " .. ORGRIMMAR .. "\n" .. " ==> " .. STORMWIND .. "\n" .. " ==> " .. L["Isle of Quel'Danas"] } -- Portal from Shattrath to Orgrimmar

            if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
              nodes[100][88574770] = { mnID = 85, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Hellfire Peninsula"] .. " " .. L["Portal"] .. "\n" .. " ==> " .. ORGRIMMAR } -- Portal from Hellfire to Orgrimmar 
              nodes[100][89234945] = { mnID = 85, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Hellfire Peninsula"] .. " " .. L["Portal"] .. "\n" .. " ==> " .. ORGRIMMAR } -- Portal from Hellfire to Orgrimmar 
            end
    
            if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
              nodes[100][88635281] = { mnID = 84,  name = "" , type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Hellfire Peninsula"] .. " " .. L["Portal"] .. "\n" .. " ==> " .. STORMWIND } -- Portal from Hellfire to Stormwind 
              nodes[100][89215101] = { mnID = 84,  name = "" , type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Hellfire Peninsula"] .. " " .. L["Portal"] .. "\n" .. " ==> " .. STORMWIND } -- Portal from Hellfire to Stormwind 
            end
          end

        end

      end
    
    
        --##############################
        --##### Continent Northrend ####
        --##############################
    
      if self.db.profile.showZoneNorthrend then

        if db.activate.ZoneTransporting then

        -- Northrend Portal
          if self.db.profile.showZonePortals then

            nodes[123][49111534] = { mnID = 125, name = "", type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. DUNGEON_FLOOR_DALARANCITY1  } -- LakeWintergrasp to Dalaran Portal 
            nodes[127][15724250] = { mnID = 125, name = L["Portal"] .. " ==> " .. DUNGEON_FLOOR_DALARANCITY1, questID = 12791, wwwLink = "https://www.wowhead.com/quest=12791", wwwName = BATTLE_PET_SOURCE_2 .. " " .. REQUIRES_LABEL .. " " .. "The Magical Kingdom of Dalaran", type = "Portal", showWWW = true, showInZone = true, showOnContinent = false, showOnMinimap = false } -- LakeWintergrasp to Dalaran Portal 
            nodes[119][40328303] = { mnID = 78, name = "", type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false, dnID = L["Portal"] } -- Portal Sholazar to Unguro

            if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
              nodes[127][31103140] = { mnID = 85, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. ORGRIMMAR } --  Dalaran to Orgrimmar Portal
            end
    
            if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
              nodes[127][26614271] = { mnID = 84,  name = "" , type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. STORMWIND } --  Dalaran to Stormwind City Portal
            end
          end
    
    
        -- Northrend Zeppelin
          if self.db.profile.showZoneZeppelins then 
    
            if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
              nodes[114][41365356] = { mnID = 85, name = "", type = "HZeppelin", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Zeppelin"] .. " ==> " .. ORGRIMMAR  } -- Zeppelin from Borean Tundra to Ogrimmar
            end
          end
    
    
        -- Northrend Ships
          if self.db.profile.showZoneShips then
    
            nodes[117][23245780] = { mnID = 115, name = "", type = "Ship", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Ship"] .. " ==> " .. POSTMASTER_LETTER_MOAKI } -- Ship from Kamagua to Moaki
            nodes[115][49977858] = { mnID = 117, name = "", type = "Ship", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Ship"] .. " ==> " .. POSTMASTER_LETTER_KAMAGUA } -- Ship from Moaki to Kamagua
            nodes[115][47597897] = { mnID = 114, name = "", type = "Ship", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Ship"] .. " ==> " .. L["Borean Tundra"] } -- Ship from Moaki to Unu'pe
            nodes[114][79075395] = { mnID = 115, name = "", type = "Ship", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Ship"] .. " ==> " .. POSTMASTER_LETTER_MOAKI } -- Ship from Unu'pe to Moaki

            if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
              nodes[114][59636916] = { mnID = 84, name = "", type = "AShip", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Ship"] .. " ==> " .. STORMWIND } -- Ship to Stormwind from Borean Tundra
              nodes[117][61366271] = { mnID = 56, name = "", type = "AShip", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Ship"] .. " ==> " .. POSTMASTER_LETTER_WETLANDS } -- Ship to Wetlands from Borean Tundra
            end

          end

        end

      end
    
    
        --#############################
        --##### Continent Pandaria ####
        --#############################
    
      if self.db.profile.showZonePandaria then

        if db.activate.ZoneTransporting then

        -- Pandaria Portals
          if self.db.profile.showZonePortals then
    
            if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
              nodes[504][33223269] = { mnID = 388, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. L["Isle of Thunder"] } -- Portal from Isle of Thunder to Shado-Pan Garrison
              nodes[379][85946249] = { mnID = 85, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. ORGRIMMAR } -- Portal from Jade Forest to Orgrimmar
              nodes[388][50657339] = { mnID = 504, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. L["Isle of Thunder"] } -- Portal from Isle of Thunder to  Shado-Pan Garrison
              nodes[390][63371293] = { mnID = 85, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. ORGRIMMAR } -- Portal from Shrine of Two Moons to Orgrimmar
              nodes[418][10315365] = { mnID = 110, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. L["Silvermoon City"] } -- Portal to Silvermoon
              nodes[371][28501401] = { mnID = 85, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. ORGRIMMAR } -- Portal from Jade Forest to Orgrimmar          
            end

            if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
              nodes[504][64707347] = { mnID = 388, name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. L["Isle of Thunder"] } -- Portal from Isle of Thunder to Shado-Pan Garrison
              nodes[388][49746867] = { mnID = 504, name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. L["Isle of Thunder"] } -- Portal from Isle of Thunder to  Shado-Pan Garrison
              nodes[390][90596670] = { mnID = 84, name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. STORMWIND } -- Portal from Shrine of Seven Stars to Stormwind
              nodes[1530][90596670] = { mnID = 84, name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. STORMWIND } -- Portal from Shrine of Seven Stars to Stormwind
              nodes[371][46248517] = { mnID = 84, name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. STORMWIND } -- Portal from Jade Forest to STORMWIND
            end

          end

        end

        --Professions
        if self.db.profile.activate.ZoneProfessions then

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
              nodes[371][46806060] = { name = L["Herbalism"], type = "Herbalism", wwwName = LFG_LIST_REQUIRE .. " " .. STORY_PROGRESS, questID = 29824, showWWW = true, wwwLink = "wowhead.com/quest=29824", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
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
          if not self.db.profile.ZoneProfessionsMixed then

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

          if self.db.profile.ZoneProfessionsMixed then
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
    
    
        --############################
        --##### Continent Draenor ####
        --############################
    
      if self.db.profile.showZoneDraenor then

        if db.activate.ZoneTransporting then

        --Draenor Toy Transport
          if self.db.profile.showZoneMirror then
            nodes[550][50355721] = { mnID = 107, name = "1. " .. L["Nagrand"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Nagrand"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 1 <=" .. " (" .. POSTMASTER_PIPE_OUTLAND .. ")" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Nagrand (Draenor) Oshugun Spirit Woods 50.35 57.21 to Nagrand (Outland) Oshugun Spirit Fields 41.27 59.04
            nodes[550][71412194] = { mnID = 107, name = "2. " .. L["Nagrand"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Nagrand"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 2 <=" .. " (" .. POSTMASTER_PIPE_OUTLAND .. ")" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Nagrand (Draenor) Throne of the Elements 71.41 21.94 to Nagrand (Outland) Throne of the Elements 60.36 25.56
            nodes[550][88302284] = { mnID = 102, name = "3. " .. L["Nagrand"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Zangarmarsh"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 1 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Nagrand (Draenor) Zangar Shore 88.30 22.84 to Zangarmarsh (Outland) Entrance to Nagrand 68.2 88.46
            nodes[550][81240898] = { mnID = 102, name = "4. " .. L["Nagrand"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Zangarmarsh"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 2 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Zangar Sea (Draenor) 'North-East coast of Nagrand, under water, top a mushroom' 81.24 8.98 to Zangarmarsh (Outland) Twinspire Ruins 'top a mushroom' 49.19 55.37
            nodes[543][50823143] = { mnID = 105, name = "1. " .. L["Gorgrond"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Blade's Edge Mountains"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 1 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Gorgrond (Draenor) Outside BRF 50.82 31.43 to Blade's Edge Mountains (Outand) Gruul's Lair 50.82 31.43
            nodes[543][49417366] = { mnID = 105, name = "2. " .. L["Gorgrond"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Blade's Edge Mountains"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 2 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Gorgrond (Draenor) Razor Bloom 49.41 73.66 to Blade's Edge Mountains (Outland) Razor Ridge 59.11 71.69
            nodes[525][21824531] = { mnID = 105, name = "1. " .. L["Frostfire Ridge"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Blade's Edge Mountains"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 3 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Frostfire Ridge (Draenor) Gormaul Tower 21.82 45.31 to Blade's Edge Mountains (Outland) Bloodmaul Ravine 46.4 64.66
            nodes[525][37536071] = { mnID = 105, name = "2. " .. L["Frostfire Ridge"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Blade's Edge Mountains"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 4 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Frostfire Ridge (Draenor) The Burning Glacier 37.53 60.71 to Blade's Edge Mountains (Outland) Bloodmaul Ravine 39.63 77.39
            nodes[534][70305453] = { mnID = 100, name = "1. " .. L["Tanaan Jungle"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Hellfire Peninsula"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 1 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Tanaan Jungle (Draenor) 'Path of Glory' Dark Portal 70.3 54.53 to Hellfire Peninsula (Outland) The Path of Glory Dark Portal 80.38 51.6
            nodes[534][49565073] = { mnID = 100, name = "2. " .. L["Tanaan Jungle"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Hellfire Peninsula"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 2 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Tanaan Jungle (Draenor) 'Path of Glory' HFC 49.56 50.73 to Hellfire Peninsula (Outland) The Path of Glory HFC 54.97 48.9
            nodes[534][56312683] = { mnID = 100, name = "3. " .. L["Tanaan Jungle"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Hellfire Peninsula"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 3 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Tanaan Jungle (Draenor) Throne of Kil'jaeden 'New' 56.31 26.83 to Hellfire Peninsula (Outland) Throne of Kil'jaeden 'OId' 64.04 21.73
            nodes[539][60024837] = { mnID = 104, name = "1. " .. L["Shadowmoon Valley"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Shadowmoon Valley"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 1 <=" .. " (" .. POSTMASTER_PIPE_OUTLAND .. ")" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Shadowmoon Valley (Draenor) Path of Light 'Crossroad' 60.02 48.37 to Shadowmoon Valley (Outland) The Warden's Cage 61.53 46.07
            nodes[539][32332876] = { mnID = 104, name = "2. " .. L["Shadowmoon Valley"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Shadowmoon Valley"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 2 <=" .. " (" .. POSTMASTER_PIPE_OUTLAND .. ")" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Shadowmoon Valley (Draenor) Moonflower Valley 'Crossroad near Alliance garrison' 32.33 28.76 to Shadowmoon Valley (Outland) Legion Hold 'Crossroad' 27.1 33.36
            nodes[535][57858053] = { mnID = 108, name = "1. " .. L["Talador"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Terokkar Forest"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 1 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Talador (Draenor) Deathweb Hollow 57.85 80.53 to Terokkar Forest (Outland) The Bone Wastes 45.37 47.53
            nodes[535][50413519] = { mnID = 108, name = "2. " .. L["Talador"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Terokkar Forest"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 2 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Talador (Draenor) Shattrath City 'New' 50.41 35.19 to Terokkar Forest (Outland) Shattrath City 'Old' 35.27 12.51
            nodes[535][68420932] = { mnID = 102, name = "3. " .. L["Talador"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Terokkar Forest"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 3 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Talador (Draenor) 'Path of Glory' 68.42 9.32 to Zangarmarsh/Hellfire Peninsula (Outland) Boarder between Hellfire and Zangarmarsh 82.59 66.13
            nodes[542][47401245] = { mnID = 108, name = "1. " .. L["Spires of Arak"] .. " " .. L["Portal"], TransportName = " ==> " .. L["Terokkar Forest"] .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 4 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Spires of Arak (Draenor) 'Ridge on the boarder with Talador' 47.4 12.45 to Terokkar Forest (Outland) Skettis 70.78 75.88
          end
    
        --Draenor Garrison Transport
          if self.db.profile.showZoneOgreWaygate then
    
            if self.faction == "Horde" then
              nodes[543][58033444] = { mnID = 590, name = L["Ogre Waygate to Garrison"], type = "OgreWaygate", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ogre Waygate Gorgrond
              nodes[525][59544752] = { mnID = 590, name = L["Ogre Waygate to Garrison"], type = "OgreWaygate", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ogre Waygate FrostfireRidge
              nodes[550][32164623] = { mnID = 590, name = L["Ogre Waygate to Garrison"], type = "OgreWaygate", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ogre Waygate Nagrand
              nodes[535][55084813] = { mnID = 590, name = L["Ogre Waygate to Garrison"], type = "OgreWaygate", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ogre Waygate Talador
              nodes[542][54625163] = { mnID = 590, name = L["Ogre Waygate to Garrison"], type = "OgreWaygate", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ogre Waygate SpiresOfArak
              nodes[539][50463566] = { mnID = 590, name = L["Ogre Waygate to Garrison"], type = "OgreWaygate", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ogre Waygate Shadowmoon Valley
            end
    
            if self.faction == "Alliance" then
              nodes[543][58033444] = { mnID = 582, name = L["Ogre Waygate to Garrison"], type = "OgreWaygate", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ogre Waygate Gorgrond
              nodes[525][59544752] = { mnID = 582, name = L["Ogre Waygate to Garrison"], type = "OgreWaygate", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ogre Waygate FrostfireRidge
              nodes[550][32164623] = { mnID = 582, name = L["Ogre Waygate to Garrison"], type = "OgreWaygate", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ogre Waygate Nagrand
              nodes[535][55084813] = { mnID = 582, name = L["Ogre Waygate to Garrison"], type = "OgreWaygate", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ogre Waygate Talador
              nodes[542][54625163] = { mnID = 582, name = L["Ogre Waygate to Garrison"], type = "OgreWaygate", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ogre Waygate SpiresOfArak
              nodes[539][50463566] = { mnID = 582, name = L["Ogre Waygate to Garrison"], type = "OgreWaygate", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ogre Waygate Shadowmoon Valley
              end
          end
    
        --Draenor Portals
          if self.db.profile.showZonePortals then
    
            if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
              nodes[534][61024735] = { mnID = 624, name = L["Ashran"], type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal from Vol'mar to Ashran
              nodes[525][51416484] = { mnID = 624, name = L["Ashran"], type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal from Garrison to Ashran
              nodes[588][45001476] = { mnID = 85, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. ORGRIMMAR } -- Portal from Garrison to Ashran (Ashran Zone)
              nodes[588][42911275] = { mnID = 534, name = L["Vol'mar"], type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal from Ashran to Vol'mar Captive (Ashran Zone)
            end
    
            if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
              nodes[588][43848830] = { mnID = 84,  name = "" , type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. STORMWIND } -- Portal from Ashran to Stormwind
              nodes[539][32471561] = { mnID = 622, name = L["Ashran"], type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal from Garison to Ashran
              nodes[588][38328897] = { mnID = 534, name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. SPLASH_NEW_6_2_FEATURE1_TITLE } -- Portal from Ashran to Lion's Watch
              nodes[534][57426032] = { mnID = 622, name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. L["Ashran"] } -- Portal from Lion's Watch to (Ashran Zone)
            end
          end

        end

      end
    
    
        --#################################
        --##### Continent Broken Isles ####
        --#################################
    
      if self.db.profile.showZoneBrokenIsles then

        if db.activate.ZoneTransporting then

        --Broken Isles Portals
          if self.db.profile.showZonePortals then

            nodes[630][46674136] = { name = "", type = "Portal", mnID = 85, mnID2 = 84, showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. "\n" .. " ==> " .. ORGRIMMAR .. "\n" .. " ==> " .. STORMWIND} -- Portal to Orgrimmar from Azsuna
            nodes[971][24952789] = { name = "", type = "Portal", mnID = 629, showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. DUNGEON_FLOOR_DALARANCITY1 } -- Portal to Dalaran
    
            if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
              nodes[652][46176383] = { mnID = 85, name = "" , type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. ORGRIMMAR } -- Thundertotem to Orgrimmar
              nodes[680][58188734] = { mnID = 85, name = "" , type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. ORGRIMMAR } -- Thundertotem to Orgrimmar
            end

            if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
              nodes[971][27992149] = { name = "", type = "APortal", mnID = 629, showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. STORMWIND } -- Portal to Stormwind
              nodes[941][43092506] = { mnID = 84, name = "" , type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. STORMWIND } --  Portal from Krokuun - Vindikaar to Stormwind
              nodes[680][58678764] = { mnID = 84, name = "" , type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. STORMWIND } --  Portal from Krokuun - Vindikaar to Stormwind
            end
          end

        end

      end


        --#############################
        --##### Continent Zandalar ####
        --#############################

      if self.db.profile.showZoneZandalar then

        if db.activate.ZoneTransporting then

        -- Zandalar Portals
          if self.db.profile.showZonePortals then
    
            if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
              nodes[862][58474432] = { mnID = 1163, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Dazar'alor"] .. " " .. L["Portalroom"] .. L["(inside building)"] .. "\n" .. " ==> " .. L["Silvermoon City"] .. "\n" .. " ==> " .. ORGRIMMAR .. "\n" .. " ==> " .. L["Thunder Bluff"] .. "\n" .. " ==> " .. L["Silithus"] .. "\n" .. " ==> " .. L["Nazjatar"] } -- Portalroom from Dazar'alor
              nodes[862][59265920] = { mnID = 1165, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Zandalar"] .. " " .. L["Portals"] .. "\n" ..  "\n" .. " ==> " .. L["This Darkshore portal is only active if your faction is currently occupying Bashal'Aran"] .. "\n" .. " ==> " .. L["This Arathi Highlands portal is only active if your faction is currently occupying Ar'gorok"] } -- Portal to Arathi and Darkshore
              nodes[1355][47276279] = { mnID = 1163, name = L["Portal"], type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portalroom to Dazar'alor from NewHome
            end

          end
    
        -- Zandalar Ships
          if self.db.profile.showZoneShips then
    
            if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
              nodes[862][58046505] = { mnID = 463, name = "", type = "HShip", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Ship"] .. " ==> " .. L["Echo Isles, Durotar"] } -- Ship from Zandalar to Echo Isles 
            end
    
          end

        -- Zandalar Transport
          if self.db.profile.showZoneTravel then

            if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
              nodes[862][58466298] = { mnID = 896, mnID2 = 895, mnID3 = 942, name = L["(Dread-Admiral Tattersail) will take you to Drustvar, Tiragarde Sound or Stormsong Valley"], dnID = " " .. ITEM_REQ_HORDE, type = "UndeadF", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ship from Dazar'alor to Drustvar, Tiragarde Sound or Stormsong Valley
              nodes[862][55325808] = { mnID = 1462, name = L["Captain Krooz"] .. " " .. L["Travel"], dnID = " " .. ITEM_REQ_HORDE, type = "GoblinF", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Transport from Dazar'alor to Mechagon 
            end

            if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
              nodes[864][36693428] = { mnID = 1161, name = L["Barnard 'The Smasher' Bayswort"] .. " " .. L["Travel"], type = "KulM", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = " " .. ITEM_REQ_ALLIANCE .. "\n" .. " ==> " .. L["Boralus, Tiragarde Sound"] } -- Transport from Vol'dun to Boralus
              nodes[863][62064008] = { mnID = 1161, name = L["Desha Stormwallow"] .. " " .. L["Travel"], type = "DwarfF", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = " " .. ITEM_REQ_ALLIANCE .. "\n" .. " ==> " .. L["Boralus, Tiragarde Sound"] } -- Transport from Nazmir to Boralus
              nodes[862][40457103] = { mnID = 1161, name = L["Daria Smithson"] .. " " .. L["Travel"], type = "GilneanF", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName =  " " .. ITEM_REQ_ALLIANCE .. "\n" .. " ==> " .. L["Boralus, Tiragarde Sound"] } -- Transport from Zuldazar to Boralus 
            end
          end

          -- Zandalar Transport
          if self.db.profile.showMiniMapTransport then
            nodes[862][22555406] = { mnID = 2346, name = L["Rocket drill"] .. " " .. L["Transport"], dnID = "", type = "RocketDrill", questID = 83933, wwwLink = "https://www.wowhead.com/quest=83933/the-kajacoast", showWWW = true, wwwName = BATTLE_PET_SOURCE_2 .. " " .. REQUIRES_LABEL .. " " .. "The Kaja'Coast", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mole Machine from Zandalar to Undermine
          end

        end

      end


        --##############################
        --##### Continent Kul Tiras ####
        --##############################
    
      if self.db.profile.showZoneKulTiras then 

        -- Kul Tiras MapNotesIcons
        if self.db.profile.showZoneHordeAllyIcons then

          if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
            nodes[895][71533261] = { mnID = 1161, hideInfo = true, id = { 1176, 1031, 1179, 1036 }, type = "AIcon", showInZone = true, showOnContinent = false, showOnMinimap = false, name = L["Boralus"] .. " " .. "\n" .. " " .. "\n" .. L["Portalroom"] .. "\n" .. " ==> " .. STORMWIND .. "\n" .. " ==> " .. L["Silithus"] .. "\n" .. " ==> " .. L["Exodar"] .. "\n" .. " ==> " .. L["Ironforge"] .. "\n" .. " " .. "\n" .. L["Grand Admiral Jes-Tereth"] .. L["Travel"] .. "\n" .. " ==> " .. L["Nazmir"] .. "\n" .. " ==> " .. L["Zuldazar"] .. "\n" .. " ==> " .. L["Vol'dun"] .. "\n" .. " " .. "\n" .. L["Portals"] .. "\n" .. " " .. "\n" .. " ==> " .. L["Arathi Highlands"] .. "\n" .. " ==> " .. L["Darkshore"] .. "\n" .. " " .. "\n" .. L["Ship"] .. "\n" .. " ==> " .. STORMWIND .. "\n" .. " "  .."\n" .. L["Kiku"] .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " "} -- Boralus Transports
          end

        end

        if db.activate.ZoneTransporting then

        -- Kul Tiras Transport
          if self.db.profile.showZoneTravel then

            if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
              nodes[1462][75522266] = { mnID = 862, name = L["Captain Krooz"] .. " " .. L["Travel"], dnID = " " .. ITEM_REQ_HORDE, type = "GoblinF", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Transport from Mechagon to Zuldazar
              nodes[896][20614336] = { mnID = 862, name = L["Swellthrasher"] .. " " .. L["Travel"], type = "MOrcF", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = " " .. ITEM_REQ_HORDE .. "\n" .. " ==> " .. L["Zuldazar"] } -- Transport from Drustvar to Zuldazar
              nodes[942][51902432] = { mnID = 862, name = L["Grok Seahandler"] .. " " .. L["Travel"], type = "OrcM", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = " " .. ITEM_REQ_HORDE .. "\n" .. " ==> " .. L["Zuldazar"] } -- Transport from Stormsong Valley to Zuldazar
              nodes[895][87725089] = { mnID = 862, name = L["Erul Dawnbrook"] .. " " .. L["Travel"], type = "B11M", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = " " .. ITEM_REQ_HORDE .. "\n" .. " ==> " .. L["Zuldazar"] } -- Transport from Tiragarde Sound to Zuldazar 
            end

          end
    

        -- Kul Tiras Portals
          if self.db.profile.showZonePortals then
    
            if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
              nodes[895][74072427] = { mnID = 1161, name = L["Portal"], type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Boralus"] .. " " .. L["Portalroom"] .. "\n" .. " " .. L["(inside building)"] .. "\n" .. " ==> " .. STORMWIND .. "\n" .. " ==> " .. L["Silithus"] .. "\n" .. " ==> " .. L["Exodar"] .. "\n" .. " ==> " .. L["Ironforge"] .. "\n" .. " ==> " .. L["Nazjatar"] } -- Portalroom from Boralus } -- Portalroom from Boralus
              nodes[1355][39975256] = { mnID = 1161, name = L["Portal"], dnID = "", type = "APortal", questID = 55175, showWWW = true, wwwLink = "wowhead.com/quest=29824", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portalroom to Boralus from Mezzamere
            end
          end
    
    
        -- Kul Tiras Ships
          if self.db.profile.showZoneShips then
    
            if self.faction == "Horde" or db.activate.ZoneEnemyFaction then

            end
    
            if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then

            end
          end

        end

      end
    
    
        --################################
        --##### Continent Shadowlands ####
        --################################
    
      if self.db.profile.showZoneShadowlands then

        if db.activate.ZoneTransporting then

        -- Shadowlands Portals
          if self.db.profile.showZonePortals then

            nodes[1543][42424210] = { mnID = 1670, name = "", type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. L["Oribos"] .. " " .. DUNGEON_FLOOR_GILNEAS2 } -- the Maw
            nodes[1961][64472406] = { mnID = 1671, name = "", type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. L["Oribos"] .. " " .. DUNGEON_FLOOR_GILNEAS3 } -- Korthia to Oribos
            nodes[1970][32956973] = { mnID = 1671, name = "", type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. L["Oribos"] .. " " .. DUNGEON_FLOOR_GILNEAS3 } -- Zereth Morthis to Oribos
            nodes[1543][48133902] = { mnID = 1911, name = "", type = "TorghastUp", showInZone = true, showOnContinent = false, showOnMinimap = false, dnID = L["Portal"]} -- Maw to Torghast
            nodes[1911][10454655] = { mnID = 1543, name = "", type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false, dnID = L["Portal"]} -- Torghast to Maw
            nodes[1911][15946014] = { mnID = 1912, name = "", type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false, dnID = L["Portal"]} -- Torghast to Maw
            nodes[1912][50168375] = { mnID = 1911, name = "", type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false, dnID = L["Portal"]} -- Torghast to Maw
          end


        -- Shadowlands Transporter
          if self.db.profile.showZoneTransport then
            nodes[1543][47344340] = { mnID = 1961, name = "", type = "TravelM", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Transport"] .. " ==> " .. L["Korthia"] } -- Maw to Korthia
            nodes[1961][65062339] = { mnID = 1543, name = "", type = "TravelM", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Transport"] .. " ==> " .. L["The Maw"] } -- Korthia to the Maw
          end

        end

      end
    
    
        --#################################
        --##### Continent Dragon Isles ####
        --#################################
    
      if self.db.profile.showZoneDragonIsles then

        if db.activate.ZoneTransporting then

          -- Dragonflight Portals
          if self.db.profile.showZonePortals then
            nodes[2239][89643770] = { mnID = 2200,  name = "", type = "WayGateGreen", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " ..L["Emerald Dream"] } -- Bel'ameth, Amirdrassil to Emerald Dream
            nodes[2025][40516283] = { mnID = 2112, name = "", type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Valdrakken"] .. " " .. L["Portals"] .. "\n" ..  "\n" .. " ==> " .. L["Emerald Dream"] .. "\n" .. " ==> " .. L["Badlands"] .. "\n".." ==> " .. STORMWIND .. "\n" .. " ==> " .. ORGRIMMAR } --  Valdrakken Portals
            nodes[2200][73065245] = { mnID = 2023, name = "", type = "WayGateGreen", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. L["Ohn'ahran Plains"] } -- Portal The Emerald Dream to Ohn'ahran Plains
            nodes[2023][18295226] = { mnID = 2200, name = "", type = "WayGateGreen", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. L["Emerald Dream"] } -- Portal to The Emerald Dream
    
            if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
              nodes[2239][55466365] = { mnID = 84,  name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. STORMWIND } -- Valdrakken to Stormwind City Portal
              nodes[2239][55326472] = { name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portals"] .. "\n" .. " ==> " .. L["Darkshore"] .. "\n" .. " ==> " .. POSTMASTER_LETTER_HYJAL  .. "\n" .. " ==> " .. POSTMASTER_LETTER_LORLATHIL } -- Valdrakken to Stormwind City Portal
            end
          end
    
    
        -- Dragonflight Zeppelin
          if self.db.profile.showZoneZeppelins then      
    
            if self.faction == "Horde" or db.activate.ZoneEnemyFaction then 
              nodes[2022][81632788] = { mnID = 85, name = "", type = "HZeppelin", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Zeppelin"] .. " ==> " .. ORGRIMMAR } -- Zeppelin from The Waking Shores to Orgrimmar 
            end
          end
    
    
        -- Dragonflight Ships
          if self.db.profile.showZoneShips then
            nodes[2239][49530434] = { mnID = 217, name = L["Ship"], type = "Ship", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ship from Amirdrassil to Gilneas
       
            if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
              nodes[2022][82243070] = { mnID = 84, name = "", type = "AShip", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Ship"] .. " ==> " .. STORMWIND } -- Ship from The Waking Shores to Stormwind
            end
          end

        end

      end


        --#################################
        --##### Continent Khaz Algar ######
        --#################################
    
      if self.db.profile.showZoneKhazAlgar then

        if db.activate.ZoneTransporting then

          -- Khaz Algar Portals
          if self.db.profile.showZonePortals then
            -- nodes[2214][53404459] = { mnID = 2248, name = "", type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal from Ringing Deeps to Isle of Dorn but behind blizzard new portal icon
            nodes[2255][57344184] = { mnID = 2339, name = L["Portal"], dnID = "", showWWW = true, wwwName = LOOT_JOURNAL_LEGENDARIES_SOURCE_ACHIEVEMENT .. " " .. REQUIRES_LABEL, wwwLink = "https://wowhead.com/achievement=19559", achievementID = 19559, type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal from Azj-Kahet to Dornogal if u finished the achievement=19559
            nodes[2367][49953591] = { mnID = 2339, name = L["Portal"], dnID = "", showWWW = true, wwwName = LOOT_JOURNAL_LEGENDARIES_SOURCE_ACHIEVEMENT .. " " .. REQUIRES_LABEL, wwwLink = "https://wowhead.com/achievement=40725", achievementID = 40725, type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Chamber of Memory
            nodes[2248][53024511] = { mnID = 2339, name = L["Portal"], dnID = "", showWWW = true, wwwName = LOOT_JOURNAL_LEGENDARIES_SOURCE_ACHIEVEMENT .. " " .. REQUIRES_LABEL, wwwLink = "https://wowhead.com/achievement=19559", achievementID = 19559, type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal from Dornogal to Azj-Kahet if u finished the achievement=19559
            nodes[2248][50554183] = { mnID = 2266, name = "", type = "WayGateGolden", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["The Timeways"] .. " " .. L["Portals"] .. "\n" .. "\n" .. " ==> " .. "Tazavesh" .. "\n" .. " ==> " .. "Revendreth" } --  Portal from Dornogal to the Timeways
            nodes[2248][44634679] = { mnID = 2367, name = L["Portal"], dnID = "", showWWW = true, wwwName = LOOT_JOURNAL_LEGENDARIES_SOURCE_ACHIEVEMENT .. " " .. REQUIRES_LABEL, wwwLink = "https://wowhead.com/achievement=40725", achievementID = 40725, type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Chamber of Memory
            nodes[2346][27805398] = { mnID = 2339, name = L["Portal"], dnID = "", showWWW = true, wwwName = LOOT_JOURNAL_LEGENDARIES_SOURCE_ACHIEVEMENT .. " " .. REQUIRES_LABEL, wwwLink = "https://wowhead.com//quest=86535/test-run", questID = 86535, type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal from Undermine to Dornogal
            nodes[2472][62549423] = { mnID = 2339, name = L["Portal"], dnID = "", type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal from Tazavesh to Dornogal
            nodes[2371][69358829] = { mnID = 2339, name = L["Portal"], dnID = "", type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal from Tazavesh to Dornogal

            if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
              nodes[2248][46913872] = { mnID = 2339, name = "", type = "HPortal", TransportName = L["Portal"] .. "\n" .. ORGRIMMAR, showInZone = true, showOnContinent = false, showOnMinimap = false } -- Dornogal to Orgrimmar
              nodes[2322][07105283] = { mnID = 85, name = L["Portal"], dnID = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false }
            end
   
            if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
              nodes[2248][47043781] = { mnID = 2339, name = "", type = "APortal", TransportName = L["Portal"] .. "\n" .. STORMWIND, showInZone = true, showOnContinent = false, showOnMinimap = false } -- Dornogal to Stormwind
              nodes[2322][07184634] = { mnID = 84, name = L["Portal"], dnID = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false }
            end
          end

          -- Khaz Algar Transport
          if self.db.profile.showZoneTransport then
            nodes[2369][67613901] = { mnID = 2214, name = L["Mole Machine"], dnID = "", type = "MoleMachine", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mole Machine from Sirene Isle to Deeps
            nodes[2214][41993030] = { mnID = 2369, name = L["Mole Machine"], dnID = "", type = "MoleMachine", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mole Machine from Deeps to Sirene Isle
            nodes[2214][72957320] = { mnID = 2346, name = L["Rocket drill"] .. " " .. L["Transport"], dnID = "", type = "RocketDrill", questID = 83151, wwwLink = "wowhead.com/quest=83151", showWWW = true, wwwName = BATTLE_PET_SOURCE_2 .. " " .. REQUIRES_LABEL .. " " .. "Down Undermine", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mole Machine Deeps to Undermine
            nodes[2346][17285075] = { mnID = 2214, name = L["Rocket drill"] .. " " .. L["Transport"], dnID = "", type = "RocketDrill", questID = 83151, wwwLink = "wowhead.com/quest=83151", showWWW = true, wwwName = BATTLE_PET_SOURCE_2 .. " " .. REQUIRES_LABEL .. " " .. "Down Undermine", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mole Machine from Undermine to Deeps
            nodes[2346][18795225] = { mnID = 862, name = L["Rocket drill"] .. " " .. L["Transport"], dnID = "", type = "RocketDrill", questID = 83933, wwwLink = "https://www.wowhead.com/quest=83933/the-kajacoast", showWWW = true, wwwName = BATTLE_PET_SOURCE_2 .. " " .. REQUIRES_LABEL .. " " .. "The Kaja'Coast", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mole Machine from Undermine to Zandalar
          end
    
        -- Khaz Algar Zeppelin
          if self.db.profile.showZoneZeppelins then

            nodes[2369][70725350] = { mnID = 2339, name = "", type = "Zeppelin", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Zeppelin"] .. " ==> " .. L["Dornogal"] } -- Zeppelin from Siren Isle to Dornogal
            nodes[2248][55453363] = { mnID = 2369, name = "", type = "Zeppelin", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Zeppelin"] .. " ==> " .. L["Siren Isle"] } -- Zeppelin to Siren Isle from Dornogal

            if self.faction == "Horde" or db.activate.ZoneEnemyFaction then 
              --nodes[2022][81632788] = { mnID = 85, name = "", type = "HZeppelin", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Zeppelin"] .. " ==> " .. ORGRIMMAR } -- Zeppelin from The Waking Shores to Orgrimmar 
            end
          end
    
    
        -- Khaz Algar Ships
          if self.db.profile.showZoneShips then
            if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
              --nodes[2022][82243070] = { mnID = 84, name = "", type = "AShip", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Ship"] .. " ==> " .. STORMWIND } -- Ship from The Waking Shores to Stormwind
            end
          end

        end

        --Professions
        if self.db.profile.activate.ZoneProfessions then

          if self.db.profile.showZoneAlchemy then
            nodes[2216][45411357] = { name = L["Alchemy"], type = "Alchemy", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            nodes[2213][45411357] = { name = L["Alchemy"], type = "Alchemy", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            nodes[2216][67423141] = { name = L["Alchemy"], type = "Alchemy", showInZone = true, showOnContinent = false, showOnMinimap = false, dnID = L["(inside building)"], TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            nodes[2213][67423141] = { name = L["Alchemy"], type = "Alchemy", showInZone = true, showOnContinent = false, showOnMinimap = false, dnID = L["(inside building)"], TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            nodes[2255][54837585] = { name = L["Alchemy"], type = "Alchemy", showInZone = true, showOnContinent = false, showOnMinimap = false, dnID = L["(inside building)"], TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
          end
      
          if self.db.profile.showZoneLeatherworking then
            nodes[2216][43771954] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            nodes[2213][43771954] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
          end

          if self.db.profile.showZoneEngineer then
            nodes[2216][57503277] = { name = L["Engineer"], type = "Engineer", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            nodes[2213][57503277] = { name = L["Engineer"], type = "Engineer", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            nodes[2255][51387631] = { name = L["Engineer"], type = "Engineer", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
          end

          if self.db.profile.showZoneSkinning then
            nodes[2216][42602007] = { name = L["Skinning"], type = "Skinning", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            nodes[2213][42602007] = { name = L["Skinning"], type = "Skinning", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
          end

          if self.db.profile.showZoneTailoring then
            nodes[2216][49711743] = { name = L["Tailoring"], type = "Tailoring", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            nodes[2213][49711743] = { name = L["Tailoring"], type = "Tailoring", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
          end

          if self.db.profile.showZoneBlacksmith then
            nodes[2216][46002227] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = true, showOnContinent = false, showOnMinimap = false, dnID = "( " .. ERR_USE_OBJECT_MOVING .. " )", TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            nodes[2213][46002227] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = true, showOnContinent = false, showOnMinimap = false, dnID = "( " .. ERR_USE_OBJECT_MOVING .. " )", TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
          end

          if self.db.profile.showZoneMining then
            nodes[2216][46842255] = { name = L["Mining"], type = "Mining", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            nodes[2213][46842255] = { name = L["Mining"], type = "Mining", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
          end

          if self.db.profile.showZoneFishing then
            nodes[2216][51422519] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            nodes[2213][51422519] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            nodes[2371][75503411] = { npcID = 244485, name = "", type = "Fishing", showInZone = true, showOnContinent = false, showOnMinimap = false }
          end

          if self.db.profile.showZoneCooking then
            nodes[2216][47912464] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            nodes[2213][47912464] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
          end

          if self.db.profile.showZoneEnchanting then
            nodes[2216][45573452] = { name = L["Enchanting"], type = "Enchanting", showInZone = true, showOnContinent = false, showOnMinimap = false, dnID = L["(inside building)"], TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            nodes[2213][45573452] = { name = L["Enchanting"], type = "Enchanting", showInZone = true, showOnContinent = false, showOnMinimap = false, dnID = L["(inside building)"], TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            nodes[2255][47207694] = { name = L["Enchanting"], type = "Enchanting", showInZone = true, showOnContinent = false, showOnMinimap = false, dnID = L["(inside building)"], TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
          end

          if self.db.profile.showZoneJewelcrafting then
            nodes[2216][47751925] = { name = L["Jewelcrafting"], type = "Jewelcrafting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            nodes[2213][47751925] = { name = L["Jewelcrafting"], type = "Jewelcrafting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
          end

          if self.db.profile.showZoneArchaeology then
            nodes[390][83563122] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
          end

          if self.db.profile.showZoneHerbalism then            
            nodes[2216][47271667] = { name = L["Herbalism"], type = "Herbalism", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            nodes[2213][47271667] = { name = L["Herbalism"], type = "Herbalism", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
          end

          if self.db.profile.showZoneInscription then
            nodes[2216][41752650] = { name = INSCRIPTION, type = "Inscription", showInZone = true, showOnContinent = false, showOnMinimap = false, dnID = L["(inside building)"], TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            nodes[2213][41752650] = { name = INSCRIPTION, type = "Inscription", showInZone = true, showOnContinent = false, showOnMinimap = false, dnID = L["(inside building)"], TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            nodes[2255][45837409] = { name = INSCRIPTION, type = "Inscription", showInZone = true, showOnContinent = false, showOnMinimap = false, dnID = L["(inside building)"], TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
          end

          if self.db.profile.ZoneProfessionsMixed and ( self.db.profile.showZoneAlchemy or self.db.profile.showZoneMining or self.db.profile.showZoneBlacksmith or self.db.profile.showZoneLeatherworking or self.db.profile.showZoneJewelcrafting or self.db.profile.showZoneHerbalism or self.db.profile.showZoneTailoring or self.db.profile.showZoneFishing or self.db.profile.showZoneCooking or self.db.profile.showZoneSkinning ) then
            nodes[2255][47697093] = { name = MINIMAP_TRACKING_TRAINER_PROFESSION, type = "ProfessionsMixed", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = TextIconAlchemy:GetIconString() .. " " .. L["Alchemy"] .. "\n" .. TextIconMining:GetIconString() .. " " .. L["Mining"] .. "\n" .. TextIconBlacksmith:GetIconString() .. " " .. L["Blacksmithing"] .. "\n" .. TextIconLeatherworking:GetIconString() .. " " .. L["Leatherworking"] .. "\n" .. TextIconJewelcrafting:GetIconString() .. " " .. L["Jewelcrafting"] .. "\n" .. TextIconHerbalism:GetIconString() .. " " .. L["Herbalism"] .. "\n" .. TextIconTailoring:GetIconString() .. " " .. L["Tailoring"] .. "\n" .. TextIconLeatherworking:GetIconString() .. " " .. L["Leatherworking"] .. "\n" .. TextIconFishing:GetIconString() .. " " .. PROFESSIONS_FISHING .. "\n" .. TextIconCooking:GetIconString() .. " " .. PROFESSIONS_COOKING } -- City of Fades
          end

        end

      end
        
    end
  end

end