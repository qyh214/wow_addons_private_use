local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

function ns.LoadZoneMapNodesLocationinfo(self)
local db = ns.Addon.db.profile
local nodes = ns.nodes
ns.currentSourceFile = "RetailZoneNodesLocation.lua"

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
              nodes[1][45780744] = { mnID = 85, name = "", type = "HIcon", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = ns.Orgrimmar .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Portalroom"] .. "\n" .. " ==> " .. ns.Silvermoon .. "\n" .. " ==> " .. ns.Valdrakken .. "\n" .. " ==> " .. ns.Oribos .. "\n" .. " ==> " .. ns.Azsuna .. "\n" .. " ==> " .. ns.Zuldazar .. "\n" .. " ==> " .. ns.Shattrath .. "\n" .. " ==> " .. ns.Dalaran .. "\n" .. " ==> " .. ns.CavernsOfTime .. "\n" .. " ==> " .. ns.DarkPortal .. "\n" .. " ==> " .. ns.Dornogal .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " ==> " .. ns.Hyjal .. "\n" .. " ==> " .. ns.TwilightHighlands .. "\n" .. " ==> " .. ARTIFACT_SHAMAN_TITLECARD_DEEPHOLM .. "\n" .. " ==> " .. ns.Vashjir .. "\n" .. " ==> " .. ns.Uldum .. "\n" .. " ==> " .. ns.TolBarad .. "\n" .. "\n" .. L["Zeppelins"] .. "\n" .. " ==> " .. ns.ThunderBluff .. "\n" .. " ==> " .. ns.Gromgol .. "\n" .. " ==> " .. POSTMASTER_LETTER_WARSONGHOLD .. "\n" .. "\n" .. CALENDAR_TYPE_DUNGEON .. "\n" .. " ==> " .. DUNGEON_FLOOR_RAGEFIRE1 } -- Portalroom from Dazar'alor
              nodes[76][21288964] = { mnID = 85, name = "", type = "HIcon", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = ns.Orgrimmar .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Portalroom"] .. "\n" .. " ==> " .. ns.Silvermoon .. "\n" .. " ==> " .. ns.Valdrakken .. "\n" .. " ==> " .. ns.Oribos .. "\n" .. " ==> " .. ns.Azsuna .. "\n" .. " ==> " .. ns.Zuldazar .. "\n" .. " ==> " .. ns.Shattrath .. "\n" .. " ==> " .. ns.Dalaran .. "\n" .. " ==> " .. ns.CavernsOfTime .. "\n" .. " ==> " .. ns.DarkPortal .. "\n" .. " ==> " .. ns.Dornogal .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " ==> " .. ns.Hyjal .. "\n" .. " ==> " .. ns.TwilightHighlands .. "\n" .. " ==> " .. ARTIFACT_SHAMAN_TITLECARD_DEEPHOLM .. "\n" .. " ==> " .. ns.Vashjir .. "\n" .. " ==> " .. ns.Uldum .. "\n" .. " ==> " .. ns.TolBarad .. "\n" .. "\n" .. L["Zeppelins"] .. "\n" .. " ==> " .. ns.ThunderBluff .. "\n" .. " ==> " .. ns.Gromgol .. "\n" .. " ==> " .. POSTMASTER_LETTER_WARSONGHOLD .. "\n" .. "\n" .. CALENDAR_TYPE_DUNGEON .. "\n" .. " ==> " .. DUNGEON_FLOOR_RAGEFIRE1 } -- Portalroom from Dazar'alor
              nodes[10][80450975] = { mnID = 85, name = "", type = "HIcon", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = ns.Orgrimmar .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Portalroom"] .. "\n" .. " ==> " .. ns.Silvermoon .. "\n" .. " ==> " .. ns.Valdrakken .. "\n" .. " ==> " .. ns.Oribos .. "\n" .. " ==> " .. ns.Azsuna .. "\n" .. " ==> " .. ns.Zuldazar .. "\n" .. " ==> " .. ns.Shattrath .. "\n" .. " ==> " .. ns.Dalaran .. "\n" .. " ==> " .. ns.CavernsOfTime .. "\n" .. " ==> " .. ns.DarkPortal .. "\n" .. " ==> " .. ns.Dornogal .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " ==> " .. ns.Hyjal .. "\n" .. " ==> " .. ns.TwilightHighlands .. "\n" .. " ==> " .. ARTIFACT_SHAMAN_TITLECARD_DEEPHOLM .. "\n" .. " ==> " .. ns.Vashjir .. "\n" .. " ==> " .. ns.Uldum .. "\n" .. " ==> " .. ns.TolBarad .. "\n" .. "\n" .. L["Zeppelins"] .. "\n" .. " ==> " .. ns.ThunderBluff .. "\n" .. " ==> " .. ns.Gromgol .. "\n" .. " ==> " .. POSTMASTER_LETTER_WARSONGHOLD .. "\n" .. "\n" .. CALENDAR_TYPE_DUNGEON .. "\n" .. " ==> " .. DUNGEON_FLOOR_RAGEFIRE1 } -- Portalroom from Dazar'alor
            end

            if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
              nodes[97][27243965] = { mnID = 103, name = "", type = "AIcon", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = ns.Exodar .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " ==> " .. ns.Stormwind } -- Portal Exodar to Teldrassil
            end

          end          

        if db.activate.ZoneTransporting then

        -- Kalimdor Darkmoon
          if self.db.profile.showZoneDarkmoon then

            if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
              nodes[7][36003600] = { mnID = 407, name = FACTION_HORDE .. " " .. CALENDAR_FILTER_DARKMOON .. " (" .. L["Portal"] ..")", TransportName = "\n" .. REQUIRES_LABEL .. " " .. CALENDAR_FILTER_DARKMOON .. "\n" .. L["Starting on the first Sunday of each month for one week"], type = "DarkMoon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mulgore Portal to the Darkmoon
            end

          end
          
        -- Kalimdor Portals
          if self.db.profile.showZonePortals then

            nodes[57][26305072] = { mnID = 89, name = "", type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = ns.Ruttheran .. " (" .. L["Portal"] ..")" } -- Portal To Teldrassil from Darnassus
            nodes[57][54998820] = { mnID = 89, name = "", type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal To Darnassus from Teldrassil
            nodes[78][50560773] = { mnID = 119, name = "", type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal Unguro to Sholazar
            nodes[74][58142669] = { mnID = 85, mnID2 = 84, name = "", type = "PortalS", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portals"] .. "\n" .. "\n" .. FACTION_HORDE .. "\n" .. " ==> " .. ns.Orgrimmar .. "\n" .. "\n" .. FACTION_ALLIANCE .. "\n" .. " ==> " .. ns.Stormwind } -- Portal from Tanaris to Orgrimmar or Stormwind
            nodes[71][65984960] = { mnID = 85, mnID2 = 84, name = "", type = "PortalS", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portals"] .. "\n" .. "\n" .. FACTION_HORDE .. "\n" .. " ==> " .. ns.Orgrimmar .. "\n" .. "\n" .. FACTION_ALLIANCE .. "\n" .. " ==> " .. ns.Stormwind } -- Portal from Tanaris to Orgrimmar or Stormwind
            nodes[81][41614520] = { mnID = 862, mnID2 = 1161, name = "", dnID = L["Portals"] .. "\n" .. "\n" .. FACTION_HORDE .. "\n" .. " ==> " .. ns.Zandalar .. "\n" .. "\n" .. FACTION_ALLIANCE .. "\n" .. " ==> " .. ns.Boralus .. "\n\n" .. L["If you don't see this icon, it's probably in a different phase. \nChange the phase on Zidormi"], type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal from Silithus to Zandalar or Boralus 

            if self.faction == "Horde" or db.activate.ZoneEnemyFaction then  
              nodes[62][46243511] = { mnID = 862, name = "", TransportName = ns.Zuldazar .. " (" .. L["Portal"] ..")\n\n" .. L["(its only shown up ingame if your faction\n is currently occupying Bashal'Aran)"], type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal from New Darkshore to Zandalar 
              nodes[207][50945311] = { mnID = 85, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal To Orgrimmar from Deepholm
              nodes[198][63482447] = { mnID = 85, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal To Orgrimmar from Hyjal
            end
  
            if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
              nodes[57][26305072] = { mnID = 89, name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portals"] .. "\n" .. " ==> " .. ns.Ruttheran .. "\n" .. " ==> " .. ns.Exodar  .. "\n" .. " ==> " .. ns.HellfirePeninsula } -- Portal To Teldrassil from Darnassus
              nodes[97][20235409] = { mnID = 57, name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = ns.Ruttheran .. " (" .. L["Portal"] ..")" } -- Portal Exodar to Teldrassil
              nodes[62][53731873] = { mnID = 2239, name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal from New Darkshore to Bel'ameth, Amirdrassil
              nodes[62][48023628] = { mnID = 1161, name = "", TransportName = ns.Boralus .. " (" .. L["Portal"] ..")\n\n" .. L["(its only shown up ingame if your faction\n is currently occupying Bashal'Aran)"], type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal from New Darkshore to Zandalar
              nodes[198][62602315] = { mnID = 84,  name = "" , type = "APortalS", showInZone = true, showOnContinent = false, showOnMinimap = false} -- Portal To Stormwind from Hyjal
              nodes[207][48525385] = { mnID = 84, name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false} -- Portal To Stormwind
              nodes[57][55039371] = { mnID = 84, name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal To Stormwind from Teldrassil
              nodes[57][52278948] = { mnID = 97, name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal To Exodar from Teldrassil
            end
          end
    
        --Kalimdor Zeppelins
          if self.db.profile.showZoneZeppelins then
            nodes[1][55941320] = { mnID = 2022, name = "", type = "HZeppelin", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Zeppelin from Orgrimmar to Waking Shores
            nodes[7][33422231] = { mnID = 85, name = "", type = "HZeppelin", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Zeppelin from Thunder Bluff to Orgrimmar
          end
    
        -- Kalimdor Ships
          if self.db.profile.showZoneShips then

            nodes[1][35217941] = { mnID = 210, name = "", type = "Ship", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = POSTMASTER_LETTER_STRANGLETHORNVALE .. " (" .. L["Ship"] ..")" } -- Ship from Ratchet to Booty Bay Ship
            nodes[10][70237341] = { mnID = 210, name = "", type = "Ship", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = POSTMASTER_LETTER_STRANGLETHORNVALE .. " (" .. L["Ship"] ..")" } -- Ship from Ratchet to Booty Bay Ship

            if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
              nodes[463][71903797] = { mnID = 862, name = "", type = "HShip", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ship from Echo Isles to Zuldazar  
              nodes[1][72257893] = { mnID = 862, name = "", type = "HShip", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ship from Echo Isles to Zuldazar            
            end
    
            if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
              nodes[70][71545615] = { mnID = 56, name = "", type = "AShip", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ship from Dustwallow Marsh to Wetlands
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
              nodes[224][42073378] = { mnID = 50, name = "", type = "HIcon", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = ns.Gromgol .. " " .. "\n" .. "\n" .. L["Zeppelin"] .. "\n" .. " ==> " .. ns.Orgrimmar .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " ==> " .. ns.RuinsofLordaeron } -- Transport from Stranglethorn Valley to Ogrimmar and Ruins of Lordaeron
              nodes[18][62167276] = { mnID = 90, name = "", type = "HIcon", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = ns.Undercity .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " ==> " .. ns.HellfirePeninsula } -- Portalroom from Dazar'alor
              nodes[94][56593942] = { mnID = 110, name = "", type = "HIcon", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = ns.Silvermoon .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " ==> " .. ns.Orgrimmar .. "\n" .. " ==> " .. ns.RuinsofLordaeron } -- Portal to Orgrimmar, Ruins of Lordaeron from Silvermoon   
            end

            if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                nodes[57][26305072] = { mnID = 89, name = "", type = "AIcon", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = ns.Darnassus .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Portals"] .. "\n" .. " ==> " .. ns.Ruttheran .. "\n" .. " ==> " .. ns.Exodar  .. "\n" .. " ==> " .. ns.HellfirePeninsula } -- Portal To Teldrassil from Darnassus
                nodes[27][59732929] = { mnID = 87, name = "", type = "AIcon", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = ns.Ironforge .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. ns.Stormwind .. " " .. ns.Deepruntram  } -- Carriage To Stormwind
                nodes[37][32894742] = { mnID = 84, name = "", type = "AIcon", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = ns.Stormwind .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Portalroom"] .. "\n" .. " ==> " .. ns.Ashran .. "\n" .. " ==> " .. ns.Valdrakken .. "\n" .. " ==> " .. ns.Boralus .. "\n" .. " ==> " .. ns.Oribos .. "\n" .. " ==> " .. ns.Azsuna .. "\n" .. " ==> " .. ns.Shattrath .. "\n" .. " ==> " .. ns.JadeForest .. "\n" .. " ==> " .. ns.Dalaran .. "\n" .. " ==> " .. ns.CavernsOfTime .. "\n" .. " ==> " .. ns.Exodar .. "\n" ..  " ==> " .. ns.Amirdrassil .. "\n" .. " ==> " .. ns.DarkPortal .. "\n" .. " ==> " .. ns.Dornogal .. "\n" .. "\n" .. L["Portals"] .. "\n" ..  "\n" .. " ==> " .. ns.Uldum .. "\n" .. " ==> " .. ns.Vashjir .. "\n" .. " ==> " .. ns.Hyjal .. "\n" .. " ==> " .. ARTIFACT_SHAMAN_TITLECARD_DEEPHOLM .. "\n" .. " ==> " .. ns.TwilightHighlands .. "\n" .. " ==> " .. ns.TolBarad .. "\n" .. "\n" .. L["Ships"] .. "\n" .. " ==> " .. POSTMASTER_LETTER_VALIANCEKEEP .. "\n" .. " ==> " .. ns.Boralus .. "\n" .. " ==> " .. ns.TheWakingShores .. "\n" .. "\n" .. ns.Deepruntram .. "\n" .. " ==> " .. ns.Ironforge .. "\n" .. "\n" .. " ==> " .. CALENDAR_TYPE_DUNGEON .. "\n" .. " ==> " .. DUNGEON_FLOOR_THESTOCKADE1 }
            end
          end

        if db.activate.ZoneTransporting then

        -- Eastern Kingdom Darkmoon  
          if self.db.profile.showZoneDarkmoon then
            
            if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
              nodes[37][41786951] = { mnID = 407, name = FACTION_ALLIANCE .. " " .. CALENDAR_FILTER_DARKMOON .. " (" .. L["Portal"] ..")", TransportName = "\n" .. REQUIRES_LABEL .. " " .. CALENDAR_FILTER_DARKMOON .. "\n" .. L["Starting on the first Sunday of each month for one week"], type = "DarkMoon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Elwynn Forest Portal to the Darkmoon
            end
          end

        --Eastern Kingdom Portals
          if self.db.profile.showZonePortals then

            nodes[244][47135189] = { mnID = 85, name = "", type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .."\n" .."\n" .. " ==> " .. ns.Orgrimmar .. "\n" .. " " .. JUST_OR .. "\n" .. " ==> " .. ns.Stormwind } -- Portal Tol Orgrimmar or Stormwind from Baradinhold Tol Barad pvp Area
            nodes[17][55005418] = { mnID = 624, mnID2 = 622, name = "", type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = ns.DarkPortal .. "\n" .. "\n" .. FACTION_HORDE .. "\n" .. " ==> " .. ns.Warspear .. "\n" .. "\n" .. FACTION_ALLIANCE .. "\n" .. " ==> " .. ns.Stormshield } -- Portal from Tanaris to Orgrimmar 

            if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
              nodes[18][62167276] = { mnID = 90, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = ns.HellfirePeninsula .. " (" .. L["Portal"] ..")" } -- Portalroom from Dazar'alor
              nodes[17][72694917] = { mnID = 85, name = "" , type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = ns.Orgrimmar .. " (" .. L["Portal"] ..")\n\n" .. L["If you don't see this icon, it's probably in a different phase. \nChange the phase on Zidormi"] } -- Portal Blasted Lands to Orgrimmar 
              nodes[18][60735867] = { mnID = 85, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal to Orgrimmar from Tirisfal
              nodes[18][61905899] = { mnID = 50, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = ns.Gromgol .. " (" .. L["Portal"] ..")" } -- Portal to Stranglethorn from Tirisfal
              nodes[18][59085891] = { mnID = 117, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal to Howling Fjord from Tirisfal
              nodes[18][59416744] = { mnID = 110, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal to Silvermoon from Tirisfal
              nodes[2070][59506694] = { mnID = 85, name = "", type = "HPortalS", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal to Orgrimmar from Tirisfal
              nodes[2070][59506797] = { mnID = 50, name = "", type = "HPortalS", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = ns.Gromgol .. " (" .. L["Portal"] ..")" } -- Portal to Stranglethorn from Tirisfal
              nodes[2070][60126689] = { mnID = 117, name = "", type = "HPortalS", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal to Howling Fjord from Tirisfal
              nodes[2070][59406743] = { mnID = 110, name = "", type = "HPortalS", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal to Silvermoon from Tirisfal
              nodes[50][37545100] = { mnID = 18, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = ns.RuinsofLordaeron .. " (" .. L["Portal"] ..")" } -- Portal to Undercity from Grom'gol
              --nodes[94][54552795] = { mnID = 85, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false} -- Portal to Orgrimmar from Silvermoon 
              --nodes[94][51262623] = { mnID = 18, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = ns.RuinsofLordaeron .. " (" .. L["Portal"] ..")" } -- Portal to Ruins of Lordaeron from Silvermoon 
              nodes[14][27442938] = { mnID = 862, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = ns.Zandalar.. " (" .. L["Portal"] ..")\n\n(" .. L["This Arathi Highlands portal is only active if your faction is currently occupying Ar'gorok"] .. ")" }
              nodes[245][56397967] = { mnID = 85, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal Tol Bard to Orgimmar  
              nodes[241][73595355] = { mnID = 85, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal Tol Orgrimmar from Twilight Highlands  
            end
    
            if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
              nodes[14][22246515] = { mnID = 1161, name = "", type = "APortal", showInZone = true,  showOnContinent = false, TransportName = ns.Boralus.. " (" .. L["Portal"] ..")\n\n(" .. L["This Arathi Highlands portal is only active if your faction is currently occupying Ar'gorok"] .. ")" } -- Portal from Arathi to Zandalar
              nodes[37][29592388] = { mnID = 84, name = "", type = "Carriage", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = ns.Ironforge .. " " .. ns.Deepruntram } -- Deeprun Stormwind to Ironforge
              nodes[37][33521611] = { mnID = 84, name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = ns.Stormwind .. " " .. L["Portals"] .. "\n" ..  "\n" .. " ==> " .. ns.Uldum .. "\n" .. " ==> " .. ns.Vashjir .. "\n" .. " ==> " .. ns.Hyjal .. "\n" .. " ==> " .. ARTIFACT_SHAMAN_TITLECARD_DEEPHOLM .. "\n" .. " ==> " .. ns.TwilightHighlands .. "\n" .. " ==> " .. ns.TolBarad } -- Portalroom from Stormwind
              nodes[37][15153165] = { mnID = 84, name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = ns.Stormwind .. " " .. L["Portalroom"] .. "\n" .. " ==> " .. ns.Ashran .. "\n" .. " ==> " .. ns.Valdrakken .. "\n" .. " ==> " .. ns.Boralus .. "\n" .. " ==> " .. ns.Oribos .. "\n" .. " ==> " .. ns.Azsuna .. "\n" .. " ==> " .. ns.Shattrath .. "\n" .. " ==> " .. ns.JadeForest .. "\n" .. " ==> " .. ns.Dalaran .. "\n" .. " ==> " .. ns.CavernsOfTime .. "\n" .. " ==> " .. ns.Exodar .. "\n" ..  " ==> " .. ns.Amirdrassil } -- Portalroom from Stormwind
              nodes[17][66382798] = { mnID = 84, name = "" , type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = ns.Stormwind .. " (" .. L["Portal"] ..")\n\n" .. L["If you don't see this icon, it's probably in a different phase. \nChange the phase on Zidormi"] } -- Portal to Stormwind 
              nodes[245][75235887] = { mnID = 84, name = "" , type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal Tol Bard to Stormwind
              nodes[241][79447784] = { mnID = 84, name = "" , type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal Twilight Highlands to Stormwind   
            end
          end


        --Eastern Kingdom Portals without MapNotesIcons
          if self.db.profile.showZonePortals and not self.db.profile.showZoneHordeAllyIcons then
            nodes[224][42233253] = { mnID = 18, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = ns.RuinsofLordaeron .. " (" .. L["Portal"] ..")" } -- Portal to Undercity from Grom'gol
          end



    
        --Eastern Kingdom Zeppelins
          if self.db.profile.showZoneZeppelins then

            if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
              nodes[50][36955279] = { mnID = 85, name = "", type = "HZeppelin", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ship from Booty Bay to Ratchet
            end
          end


          --Eastern Kingdom Zeppelins without MapNotesIcons
          if self.db.profile.showZonePortals and not self.db.profile.showZoneHordeAllyIcons then
            nodes[224][41993471] = { mnID = 85, name = "", type = "HZeppelin", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ship from Booty Bay to Ratchet
          end

    
        --Eastern Kingdom Ships
          if self.db.profile.showZoneShips then
            nodes[217][63659592] = { mnID = 2239, name = "", type = "Ship", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ship from Gilneas to Bel ameth
            nodes[224][36947582] = { mnID = 210, name = "", type = "Ship", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = ns.Ratchet .. " (" .. L["Ship"] ..")" } -- Ship from Booty Bay to Ratchet
            nodes[210][39336720] = { mnID = 10, name = "", type = "Ship", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = ns.Ratchet .. " (" .. L["Ship"] ..")" } -- Ship from Booty Bay to Ratchet

            if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
              nodes[37][08722976] = { mnID = 1161, name = "", type = "AShip", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Ships"] .. "\n" .. " ==> " .. ns.Boralus .. "\n".. " ==> " .. ns.TheWakingShores } -- Ship from Stormwind to Boralus
              nodes[37][07622435] = { mnID = 114, name = "", type = "AShip", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = POSTMASTER_LETTER_VALIANCEKEEP .. " (" .. L["Ship"] ..")" } -- Ship from Stormwind to Valiance Keep
              nodes[56][04175637] = { mnID = 117, name = "", type = "AShip", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ship from Wettlands to Howling Fjord
              nodes[56][06366226] = { mnID = 70, name = "", type = "AShip", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = ns.TheramoreIsle .. " (" .. L["Ship"] ..")" } -- Ship from Wettlands to Dustwallow Marsh
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
            nodes[108][28652247] = { mnID = 111, name = "", type = "MNL", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = ns.Shattrath .. "\n" .. "\n" .. L["Portals"] .. "\n" .. " ==> " .. ns.Orgrimmar .. "\n" .. " ==> " .. ns.Stormwind .. "\n" .. " ==> " .. ns.IsleOfQuelDanas } -- Portal from Shattrath to Orgrimmar
          end

        if db.activate.ZoneTransporting then

          --Draenor Toy Transport
          if self.db.profile.showZoneMirror then
            nodes[107][41275904] = { mnID = 550, name = "1. " .. ns.Nagrand .. " " .. L["Portal"], TransportName = " ==> " .. ns.Nagrand .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 1 <=" .. " (" .. SPLASH_NEW_RIGHT_TITLE .. ")" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Nagrand (Draenor) Oshugun Spirit Woods 50.35 57.21 to Nagrand (Outland) Oshugun Spirit Fields 41.27 59.04
            nodes[107][60362556] = { mnID = 550, name = "2. " .. ns.Nagrand .. " " .. L["Portal"], TransportName = " ==> " .. ns.Nagrand .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 2 <=" .. " (" .. SPLASH_NEW_RIGHT_TITLE .. ")" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Nagrand (Draenor) Throne of the Elements 71.41 21.94 to Nagrand (Outland) Throne of the Elements 60.36 25.56
            nodes[102][68208846] = { mnID = 550, name = "1. " .. ns.Zangarmarsh .. " " .. L["Portal"], TransportName = " ==> " .. ns.Nagrand .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 3 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Nagrand (Draenor) Zangar Shore 88.30 22.84 to Zangarmarsh (Outland) Entrance to Nagrand 68.2 88.46
            nodes[102][49195537] = { mnID = 550, name = "2. " .. ns.Zangarmarsh .. " " .. L["Portal"], TransportName = " ==> " .. ns.Nagrand .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 4 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Zangar Sea (Draenor) 'North-East coast of Nagrand, under water, top a mushroom' 81.24 8.98 to Zangarmarsh (Outland) Twinspire Ruins 'top a mushroom' 49.19 55.37
            nodes[102][82596613] = { mnID = 535, name = "3. " .. ns.Zangarmarsh .. " " .. L["Portal"], TransportName = " ==> " .. ns.Talador .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 3 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Talador (Draenor) 'Path of Glory' 68.42 9.32 to Zangarmarsh/Hellfire Peninsula (Outland) Boarder between Hellfire and Zangarmarsh 82.59 66.13
            nodes[105][66192634] = { mnID = 543, name = "1. " .. ns.BladesEdgeMountains .. " " .. L["Portal"], TransportName = " ==> " .. ns.Gorgrond .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 1 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Gorgrond (Draenor) Outside BRF 50.82 31.43 to Blade's Edge Mountains (Outand) Gruul's Lair 50.82 31.43
            nodes[105][59117166] = { mnID = 543, name = "2. " .. ns.BladesEdgeMountains .. " " .. L["Portal"], TransportName = " ==> " .. ns.Gorgrond .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 2 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Gorgrond (Draenor) Razor Bloom 49.41 73.66 to Blade's Edge Mountains (Outland) Razor Ridge 59.11 71.69
            nodes[105][46386404] = { mnID = 525, name = "3. " .. ns.BladesEdgeMountains .. " " .. L["Portal"], TransportName = " ==> " .. ns.FrostfireRidge .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 1 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Frostfire Ridge (Draenor) Gormaul Tower 21.82 45.31 to Blade's Edge Mountains (Outland) Bloodmaul Ravine 46.4 64.66
            nodes[105][39637739] = { mnID = 525, name = "4. " .. ns.BladesEdgeMountains .. " " .. L["Portal"], TransportName = " ==> " .. ns.FrostfireRidge .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 2 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Frostfire Ridge (Draenor) The Burning Glacier 37.53 60.71 to Blade's Edge Mountains (Outland) Bloodmaul Ravine 39.63 77.39
            nodes[100][80385106] = { mnID = 534, name = "1. " .. ns.HellfirePeninsula .. " " .. L["Portal"], TransportName = " ==> " .. ns.TanaanJungle .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 1 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Tanaan Jungle (Draenor) 'Path of Glory' Dark Portal 70.3 54.53 to Hellfire Peninsula (Outland) The Path of Glory Dark Portal 80.38 51.6
            nodes[100][54974809] = { mnID = 534, name = "2. " .. ns.HellfirePeninsula .. " " .. L["Portal"], TransportName = " ==> " .. ns.TanaanJungle .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 2 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Tanaan Jungle (Draenor) 'Path of Glory' HFC 49.56 50.73 to Hellfire Peninsula (Outland) The Path of Glory HFC 54.97 48.9
            nodes[100][64042173] = { mnID = 534, name = "3. " .. ns.HellfirePeninsula .. " " .. L["Portal"], TransportName = " ==> " .. ns.TanaanJungle .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 3 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Tanaan Jungle (Draenor) Throne of Kil'jaeden 'New' 56.31 26.83 to Hellfire Peninsula (Outland) Throne of Kil'jaeden 'OId' 64.04 21.73
            nodes[104][61534607] = { mnID = 539, name = "1. " .. ns.ShadowmoonValley .. " " .. L["Portal"], TransportName = " ==> " .. ns.ShadowmoonValley .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 1 <=" .. " (" .. SPLASH_NEW_RIGHT_TITLE .. ")" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Shadowmoon Valley (Draenor) Path of Light 'Crossroad' 60.02 48.37 to Shadowmoon Valley (Outland) The Warden's Cage 61.53 46.07
            nodes[104][27103336] = { mnID = 539, name = "2. " .. ns.ShadowmoonValley .. " " .. L["Portal"], TransportName = " ==> " .. ns.ShadowmoonValley .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 2 <=" .. " (" .. SPLASH_NEW_RIGHT_TITLE .. ")" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Shadowmoon Valley (Draenor) Moonflower Valley 'Crossroad near Alliance garrison' 32.33 28.76 to Shadowmoon Valley (Outland) Legion Hold 'Crossroad' 27.1 33.36
            nodes[108][45374753] = { mnID = 535, name = "1. " .. ns.TerokkarForest .. " " .. L["Portal"], TransportName = " ==> " .. ns.Talador .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 1 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Talador (Draenor) Deathweb Hollow 57.85 80.53 to Terokkar Forest (Outland) The Bone Wastes 45.37 47.53
            nodes[108][35271251] = { mnID = 535, name = "2. " .. ns.TerokkarForest .. " " .. L["Portal"], TransportName = " ==> " .. ns.Talador .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 2 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Talador (Draenor) Shattrath City 'New' 50.41 35.19 to Terokkar Forest (Outland) Shattrath City 'Old' 35.27 12.51
            nodes[108][70787588] = { mnID = 542, name = "4. " .. ns.TerokkarForest .. " " .. L["Portal"], TransportName = " ==> " .. ns.SpiresOfArak .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 1 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Spires of Arak (Draenor) 'Ridge on the boarder with Talador' 47.4 12.45 to Terokkar Forest (Outland) Skettis 70.78 75.88
          end

        -- Outland Portals
          if self.db.profile.showZonePortals then
              nodes[108][31332481] = { mnID = 111, name = "", type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = ns.Shattrath .. " " .. L["Portals"] .. "\n" ..  "\n" .. " ==> " .. ns.Orgrimmar .. "\n" .. " ==> " .. ns.Stormwind .. "\n" .. " ==> " .. ns.IsleOfQuelDanas } -- Portal from Shattrath to Orgrimmar

            if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
              nodes[100][88574770] = { mnID = 85, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = ns.HellfirePeninsula .. " " .. L["Portal"] .. "\n" .. " ==> " .. ns.Orgrimmar } -- Portal from Hellfire to Orgrimmar 
              nodes[100][89234945] = { mnID = 85, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = ns.HellfirePeninsula .. " " .. L["Portal"] .. "\n" .. " ==> " .. ns.Orgrimmar } -- Portal from Hellfire to Orgrimmar 
            end
    
            if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
              nodes[100][88635281] = { mnID = 84,  name = "" , type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = ns.HellfirePeninsula .. " " .. L["Portal"] .. "\n" .. " ==> " .. ns.Stormwind } -- Portal from Hellfire to Stormwind 
              nodes[100][89215101] = { mnID = 84,  name = "" , type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = ns.HellfirePeninsula .. " " .. L["Portal"] .. "\n" .. " ==> " .. ns.Stormwind } -- Portal from Hellfire to Stormwind 
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

            nodes[123][49111534] = { mnID = 125, name = "", type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- LakeWintergrasp to Dalaran Portal 
            nodes[127][15724250] = { mnID = 125, name = "", questID = 12791, wwwLink = "https://www.wowhead.com/quest=12791", wwwName = BATTLE_PET_SOURCE_2 .. " " .. REQUIRES_LABEL .. " " .. "The Magical Kingdom of Dalaran", type = "Portal", showWWW = true, showInZone = true, showOnContinent = false, showOnMinimap = false } -- LakeWintergrasp to Dalaran Portal 
            nodes[119][40328303] = { mnID = 78, name = "", type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false, dnID = L["Portal"] } -- Portal Sholazar to Unguro

            if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
              nodes[127][31103140] = { mnID = 85, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } --  Dalaran to Orgrimmar Portal
              nodes[117][77712829] = { mnID = 18, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = ns.RuinsofLordaeron .. " (" .. L["Portal"] ..")" } -- Fjord to Ruins of Lordaeron
            end
    
            if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
              nodes[127][26614271] = { mnID = 84,  name = "" , type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false } --  Dalaran to Stormwind City Portal
            end
          end
    
    
        -- Northrend Zeppelin
          if self.db.profile.showZoneZeppelins then 
    
            if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
              nodes[114][41205333] = { mnID = 85, name = "", type = "HZeppelin", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Zeppelin from Borean Tundra to Ogrimmar
            end
          end
    
    
        -- Northrend Ships
          if self.db.profile.showZoneShips then
    
            nodes[117][23245780] = { mnID = 115, name = "", type = "Ship", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = POSTMASTER_LETTER_MOAKI .. " (" .. L["Ship"] ..")" } -- Ship from Kamagua to Moaki
            nodes[115][49977858] = { mnID = 117, name = "", type = "Ship", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = POSTMASTER_LETTER_KAMAGUA .. " (" .. L["Ship"] ..")" } -- Ship from Moaki to Kamagua
            nodes[115][47597897] = { mnID = 114, name = "", type = "Ship", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ship from Moaki to Unu'pe
            nodes[114][79075395] = { mnID = 115, name = "", type = "Ship", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = POSTMASTER_LETTER_MOAKI .. " (" .. L["Ship"] ..")" } -- Ship from Unu'pe to Moaki

            if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
              nodes[114][59636916] = { mnID = 84, name = "", type = "AShip", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ship to Stormwind from Borean Tundra
              nodes[117][61366271] = { mnID = 56, name = "", type = "AShip", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ship to Wetlands from Borean Tundra
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
              nodes[504][33223269] = { mnID = 388, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = ns.ShadoPanGarison .. " (" .. L["Portal"] ..")" } -- Portal from Isle of Thunder to Shado-Pan Garrison
              nodes[379][85946249] = { mnID = 85, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal from Jade Forest to Orgrimmar
              nodes[388][50657339] = { mnID = 504, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal from Isle of Thunder to  Shado-Pan Garrison
              nodes[390][63371293] = { mnID = 85, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false} -- Portal from Shrine of Two Moons to Orgrimmar
              nodes[418][10315365] = { mnID = 110, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal to Silvermoon
              nodes[371][28501401] = { mnID = 85, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal from Jade Forest to Orgrimmar          
            end

            if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
              nodes[504][64707347] = { mnID = 388, name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = ns.ShadoPanGarison .. " (" .. L["Portal"] ..")" } -- Portal from Isle of Thunder to Shado-Pan Garrison
              nodes[388][49746867] = { mnID = 504, name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal from Isle of Thunder to  Shado-Pan Garrison
              nodes[390][90596670] = { mnID = 84, name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal from Shrine of Seven Stars to Stormwind
              nodes[1530][90596670] = { mnID = 84, name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal from Shrine of Seven Stars to Stormwind
              nodes[371][46248517] = { mnID = 84, name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal from Jade Forest to ns.Stormwind
            end

          end

        end

        --Professions
        if self.db.profile.activate.ZoneProfessions then

          if self.db.profile.showZoneAlchemy then
            nodes[422][55623530] = { npcID = 65186, name = "", type = "Alchemy", showInZone = true, showOnContinent = false, showOnMinimap = false }
          end
      
          if self.db.profile.showZoneLeatherworking then
            nodes[379][64606090] = { npcID = 65121, name = "", type = "Leatherworking", showInZone = true, showOnContinent = false, showOnMinimap = false }
          end

          if self.db.profile.showZoneEngineer then
            nodes[376][16068313] = { npcID = 55143, name = "", type = "Engineer", showInZone = true, showOnContinent = false, showOnMinimap = false }
          end

          if self.db.profile.showZoneSkinning then
            nodes[376][15948311] = { npcID = 63825, name = "", dnID = ns.SkinningM, type = "Skinning", showInZone = true, showOnContinent = false, showOnMinimap = false }
          end

          if self.db.profile.showZoneTailoring then
            nodes[376][62685975] = { npcID = 57405, name = "", dnID = ns.TailoringM, type = "Tailoring", showInZone = true, showOnContinent = false, showOnMinimap = false }
          end

          if self.db.profile.showZoneBlacksmith then
            nodes[390][21827237] = { npcID = 65129, name = "", type = "Blacksmith", showInZone = true, showOnContinent = false, showOnMinimap = false }
          end

          if self.db.profile.showZoneMining then
            nodes[371][46062940] = { npcID = 65092, name = "", type = "Mining", showInZone = true, showOnContinent = false, showOnMinimap = false }
          end

          if self.db.profile.showZoneFishing then
            nodes[418][68474349] = { npcID = 63721, name = "", dnID = ns.FishingM, type = "Fishing", showInZone = true, showOnContinent = false, showOnMinimap = false }
            nodes[376][58904700] = { npcID = 70398, name = "", type = "Fishing", showInZone = true, showOnContinent = false, showOnMinimap = false }
          end

          if self.db.profile.showZoneCooking then
            nodes[371][46274547] = { npcID = 56707, name = "", dnID = ns.CookingM, type = "Cooking", showInZone = true, showOnContinent = false, showOnMinimap = false }
          end

          if self.db.profile.showZoneArchaeology then
              nodes[390][83593103] = { npcID = 64922, name = "", type = "Archaeology", showInZone = true, showOnContinent = false, showOnMinimap = false }

            if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
              nodes[504][33873361] = { npcID = 67586, name = "", type = "Archaeology", showInZone = true, showOnContinent = false, showOnMinimap = false }
            end
          end

          if self.db.profile.showZoneEnchanting then
              nodes[371][46854294] = { npcID = 65127, name = "", type = "Enchanting", showInZone = true, showOnContinent = false, showOnMinimap = false }
          end

          if self.db.profile.showZoneInscription then
            nodes[390][81902930] = { npcID = 64691, name = "", type = "Inscription", showInZone = true, showOnContinent = false, showOnMinimap = false }
            nodes[371][55004500] = { npcID = 56065, name = "", dnID = ERR_USE_OBJECT_MOVING, type = "Inscription", showInZone = true, showOnContinent = false, showOnMinimap = false }
          end

          -- not mixed
          if not self.db.profile.ZoneProfessionsMixed then

            if self.db.profile.showZoneSkinning then

              if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                nodes[371][27791536] = { npcID = 66981, name = "", type = "Skinning", showInZone = true, showOnContinent = false, showOnMinimap = false }
              end

              if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                nodes[371][44848553] = { npcID = 67026, name = "", type = "Skinning", showInZone = true, showOnContinent = false, showOnMinimap = false }
              end

            end

            if self.db.profile.showZoneInscription then
              nodes[371][47683511] = { npcID = 62327, name = "", type = "Inscription", showInZone = true, showOnContinent = false, showOnMinimap = false }
            end

            if self.db.profile.showZoneCooking then
              nodes[376][52675166] = { npcID = 58715, name = "", dnID = ns.CookingM, type = "Cooking", showInZone = true, showOnContinent = false, showOnMinimap = false }
            end

            if self.db.profile.showZoneHerbalism then
              nodes[376][53715129] = { npcID = 65877, name = "", type = "Herbalism", showInZone = true, showOnContinent = false, showOnMinimap = false }
            end

            if self.db.profile.showZoneJewelcrafting then
              nodes[371][48073494] = { npcID = 65098, name = "", type = "Jewelcrafting", showInZone = true, showOnContinent = false, showOnMinimap = false }
            end

            if self.db.profile.showZoneBlacksmith then
              nodes[371][48403690] = { npcID = 65114, name = "", type = "Blacksmith", showInZone = true, showOnContinent = false, showOnMinimap = false }
            end

            if self.db.profile.showZoneMining then
  
              if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                nodes[371][27801480] = { npcID = 66979, name = "", type = "Mining", showInZone = true, showOnContinent = false, showOnMinimap = false }
              end

              if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                nodes[371][45108590] = { npcID = 67024, name = "", type = "Mining", showInZone = true, showOnContinent = false, showOnMinimap = false }
              end

            end

            if self.db.profile.showZoneHerbalism then
                
              if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                nodes[371][27801563] = { npcID = 66980, name = "", type = "Herbalism", showInZone = true, showOnContinent = false, showOnMinimap = false }
              end

              if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                nodes[371][45608600] = { npcID = 67025, name = "", type = "Herbalism", showInZone = true, showOnContinent = false, showOnMinimap = false }
              end

            end

          end

          if self.db.profile.ZoneProfessionsMixed then
            nodes[371][48083510] = { dnID = FACTION_NEUTRAL .. " " .. MINIMAP_TRACKING_TRAINER_PROFESSION .. "\n" .. "\n" .. TextIconInscription:GetIconString() .. " " .. INSCRIPTION .. "\n" .. TextIconJewelcrafting:GetIconString() .. " " .. L["Jewelcrafting"] .. "\n" .. TextIconBlacksmith:GetIconString() .. " " .. L["Blacksmithing"], name = "", type = "ProfessionsMixed", showInZone = true, showOnContinent = false, showOnMinimap = false }
            nodes[376][52675166] = { dnID = FACTION_NEUTRAL .. " " .. MINIMAP_TRACKING_TRAINER_PROFESSION .. "\n" .. "\n" .. TextIconHerbalism:GetIconString() .. " " .. L["Herbalism"] .. "\n" .. TextIconCooking:GetIconString() .. " " .. PROFESSIONS_COOKING, name = "", type = "ProfessionsMixed", showInZone = true, showOnContinent = false, showOnMinimap = false }

            if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
              nodes[371][27071522] = { dnID = ITEM_REQ_HORDE .. "\n" .. "\n" .. TextIconHerbalism:GetIconString() .. " " .. L["Herbalism"] .. "\n" .. TextIconMining:GetIconString() .. " " .. L["Mining"] .. "\n" .. TextIconSkinning:GetIconString() .. " " .. L["Skinning"], name = "", type = "ProfessionsMixed", showInZone = true, showOnContinent = false, showOnMinimap = false }
            end

            if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
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
            nodes[550][50355721] = { mnID = 107, name = "1. " .. ns.Nagrand .. " " .. L["Portal"], TransportName = " ==> " .. ns.Nagrand .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 1 <=" .. " (" .. POSTMASTER_PIPE_OUTLAND .. ")" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Nagrand (Draenor) Oshugun Spirit Woods 50.35 57.21 to Nagrand (Outland) Oshugun Spirit Fields 41.27 59.04
            nodes[550][71412194] = { mnID = 107, name = "2. " .. ns.Nagrand .. " " .. L["Portal"], TransportName = " ==> " .. ns.Nagrand .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 2 <=" .. " (" .. POSTMASTER_PIPE_OUTLAND .. ")" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Nagrand (Draenor) Throne of the Elements 71.41 21.94 to Nagrand (Outland) Throne of the Elements 60.36 25.56
            nodes[550][88302284] = { mnID = 102, name = "3. " .. ns.Nagrand .. " " .. L["Portal"], TransportName = " ==> " .. ns.Zangarmarsh .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 1 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Nagrand (Draenor) Zangar Shore 88.30 22.84 to Zangarmarsh (Outland) Entrance to Nagrand 68.2 88.46
            nodes[550][81240898] = { mnID = 102, name = "4. " .. ns.Nagrand .. " " .. L["Portal"], TransportName = " ==> " .. ns.Zangarmarsh .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 2 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Zangar Sea (Draenor) 'North-East coast of Nagrand, under water, top a mushroom' 81.24 8.98 to Zangarmarsh (Outland) Twinspire Ruins 'top a mushroom' 49.19 55.37
            nodes[543][50823143] = { mnID = 105, name = "1. " .. ns.Gorgrond .. " " .. L["Portal"], TransportName = " ==> " .. ns.BladesEdgeMountains .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 1 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Gorgrond (Draenor) Outside BRF 50.82 31.43 to Blade's Edge Mountains (Outand) Gruul's Lair 50.82 31.43
            nodes[543][49417366] = { mnID = 105, name = "2. " .. ns.Gorgrond .. " " .. L["Portal"], TransportName = " ==> " .. ns.BladesEdgeMountains .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 2 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Gorgrond (Draenor) Razor Bloom 49.41 73.66 to Blade's Edge Mountains (Outland) Razor Ridge 59.11 71.69
            nodes[525][21824531] = { mnID = 105, name = "1. " .. ns.FrostfireRidge .. " " .. L["Portal"], TransportName = " ==> " .. ns.BladesEdgeMountains .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 3 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Frostfire Ridge (Draenor) Gormaul Tower 21.82 45.31 to Blade's Edge Mountains (Outland) Bloodmaul Ravine 46.4 64.66
            nodes[525][37536071] = { mnID = 105, name = "2. " .. ns.FrostfireRidge .. " " .. L["Portal"], TransportName = " ==> " .. ns.BladesEdgeMountains .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 4 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Frostfire Ridge (Draenor) The Burning Glacier 37.53 60.71 to Blade's Edge Mountains (Outland) Bloodmaul Ravine 39.63 77.39
            nodes[534][70305453] = { mnID = 100, name = "1. " .. ns.TanaanJungle .. " " .. L["Portal"], TransportName = " ==> " .. ns.HellfirePeninsula .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 1 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Tanaan Jungle (Draenor) 'Path of Glory' Dark Portal 70.3 54.53 to Hellfire Peninsula (Outland) The Path of Glory Dark Portal 80.38 51.6
            nodes[534][49565073] = { mnID = 100, name = "2. " .. ns.TanaanJungle .. " " .. L["Portal"], TransportName = " ==> " .. ns.HellfirePeninsula .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 2 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Tanaan Jungle (Draenor) 'Path of Glory' HFC 49.56 50.73 to Hellfire Peninsula (Outland) The Path of Glory HFC 54.97 48.9
            nodes[534][56312683] = { mnID = 100, name = "3. " .. ns.TanaanJungle .. " " .. L["Portal"], TransportName = " ==> " .. ns.HellfirePeninsula .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 3 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Tanaan Jungle (Draenor) Throne of Kil'jaeden 'New' 56.31 26.83 to Hellfire Peninsula (Outland) Throne of Kil'jaeden 'OId' 64.04 21.73
            nodes[539][60024837] = { mnID = 104, name = "1. " .. ns.ShadowmoonValley .. " " .. L["Portal"], TransportName = " ==> " .. ns.ShadowmoonValley .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 1 <=" .. " (" .. POSTMASTER_PIPE_OUTLAND .. ")" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Shadowmoon Valley (Draenor) Path of Light 'Crossroad' 60.02 48.37 to Shadowmoon Valley (Outland) The Warden's Cage 61.53 46.07
            nodes[539][32332876] = { mnID = 104, name = "2. " .. ns.ShadowmoonValley .. " " .. L["Portal"], TransportName = " ==> " .. ns.ShadowmoonValley .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 2 <=" .. " (" .. POSTMASTER_PIPE_OUTLAND .. ")" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Shadowmoon Valley (Draenor) Moonflower Valley 'Crossroad near Alliance garrison' 32.33 28.76 to Shadowmoon Valley (Outland) Legion Hold 'Crossroad' 27.1 33.36
            nodes[535][57858053] = { mnID = 108, name = "1. " .. ns.Talador .. " " .. L["Portal"], TransportName = " ==> " .. ns.TerokkarForest .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 1 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Talador (Draenor) Deathweb Hollow 57.85 80.53 to Terokkar Forest (Outland) The Bone Wastes 45.37 47.53
            nodes[535][50413519] = { mnID = 108, name = "2. " .. ns.Talador .. " " .. L["Portal"], TransportName = " ==> " .. ns.TerokkarForest .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 2 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Talador (Draenor) Shattrath City 'New' 50.41 35.19 to Terokkar Forest (Outland) Shattrath City 'Old' 35.27 12.51
            nodes[535][68420932] = { mnID = 102, name = "3. " .. ns.Talador .. " " .. L["Portal"], TransportName = " ==> " .. ns.TerokkarForest .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 3 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Talador (Draenor) 'Path of Glory' 68.42 9.32 to Zangarmarsh/Hellfire Peninsula (Outland) Boarder between Hellfire and Zangarmarsh 82.59 66.13
            nodes[542][47401245] = { mnID = 108, name = "1. " .. ns.SpiresOfArak .. " " .. L["Portal"], TransportName = " ==> " .. ns.TerokkarForest .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 4 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"], type = "Mirror", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mirror from Spires of Arak (Draenor) 'Ridge on the boarder with Talador' 47.4 12.45 to Terokkar Forest (Outland) Skettis 70.78 75.88
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
              nodes[534][61024735] = { mnID = 624, name = ns.Ashran, type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal from Vol'mar to Ashran
              nodes[525][51416484] = { mnID = 624, name = ns.Ashran, type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal from Garrison to Ashran
              nodes[588][45001476] = { mnID = 85, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal from Garrison to Ashran (Ashran Zone)
              nodes[588][42911275] = { mnID = 534, name = ns.Volmar, type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = ns.Volmar .. " (" .. L["Portal"] ..")" } -- Portal from Ashran to Vol'mar Captive (Ashran Zone)
            end
    
            if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
              nodes[588][43848830] = { mnID = 84,  name = "" , type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal from Ashran to Stormwind
              nodes[539][32471561] = { mnID = 622, name = ns.Ashran, type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal from Garison to Ashran
              nodes[588][38328897] = { mnID = 534, name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = ns.LionsWatch .. " (" .. L["Portal"] ..")" } -- Portal from Ashran to Lion's Watch
              nodes[534][57426032] = { mnID = 622, name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal from Lion's Watch to (Ashran Zone)
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

            nodes[630][46674136] = { name = "", type = "Portal", mnID = 85, mnID2 = 84, showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. "\n" .. " ==> " .. ns.Orgrimmar .. "\n" .. " ==> " .. ns.Stormwind} -- Portal to Orgrimmar from Azsuna
            nodes[971][24952789] = { name = "", type = "Portal", mnID = 629, showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal to Dalaran
            nodes[715][44872367] = { mnID = 747, name = "", type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Druid Emerald Dreamway 
            nodes[715][53215181] = { mnID = 198, name = "", type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Druid Emerald Dreamway - Hyjal
            nodes[715][49036358] = { mnID = 26, name = "", type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Druid Emerald Dreamway - The Hinterlands
            nodes[715][39347014] = { mnID = 47, name = "", type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Druid Emerald Dreamway - Duskwood
            nodes[715][31612524] = { mnID = 116, name = "", type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Druid Emerald Dreamway - Grizzly Hills
            nodes[715][22593943] = { mnID = 69, name = "", type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Druid Emerald Dreamway - Feralas
            nodes[715][26168213] = { mnID = 80, name = "", type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Druid Emerald Dreamway - Moonglade

            if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
              nodes[652][46176383] = { mnID = 85, name = "" , type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Thundertotem to Orgrimmar
              nodes[680][58188734] = { mnID = 85, name = "" , type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Thundertotem to Orgrimmar
            end

            if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
              nodes[971][27992149] = { mnID = 629, name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal to Stormwind
              nodes[941][43092506] = { mnID = 84, name = "" , type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false} --  Portal from Krokuun - Vindikaar to Stormwind
              nodes[680][58678764] = { mnID = 84, name = "" , type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false} --  Portal from Krokuun - Vindikaar to Stormwind
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
              nodes[862][58474432] = { mnID = 1163, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Dazar'alor"] .. " " .. L["Portalroom"] .. L["(inside building)"] .. "\n" .. " ==> " .. ns.Silvermoon .. "\n" .. " ==> " .. ns.Orgrimmar .. "\n" .. " ==> " .. ns.ThunderBluff .. "\n" .. " ==> " .. ns.Silithus .. "\n" .. " ==> " .. ns.Nazjatar } -- Portalroom from Dazar'alor
              nodes[862][59265920] = { mnID = 1165, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = ns.Zandalar .. " " .. L["Portals"] .. "\n" ..  "\n" .. " ==> " .. L["This Darkshore portal is only active if your faction is currently occupying Bashal'Aran"] .. "\n" .. " ==> " .. L["This Arathi Highlands portal is only active if your faction is currently occupying Ar'gorok"] } -- Portal to Arathi and Darkshore
              nodes[1355][47276279] = { mnID = 1163, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portalroom to Dazar'alor from NewHome
              nodes[862][60043895] = { npcID = 147642, mnID = 1165, name = "", dnID = "\n" .. TOOLTIP_BATTLE_PET .. " " .. CALENDAR_TYPE_DUNGEON .. " " .. L["Portals"] .. ":\n" .. " ", type = "PortalHPetBattleDungeon", showInZone = true, showOnContinent = false, showOnMinimap = false, 
                                       showWWW = true, wwwName = BATTLE_PET_SOURCE_2 .. " " .. REQUIRES_LABEL,
                                       mnIDs1 = 11, questIDs1 = 45423, wwwNames1 = "Wailing Critters", wwwLinks1 = "https://www.wowhead.com/quest=45423",
                                       mnIDs2 = 52, questIDs2 = 46291, wwwNames2 = "The Deadmines strike back", wwwLinks2 = "https://www.wowhead.com/quest=46291", 
                                       mnIDs3 = 30, questIDs3 = 54185, wwwNames3 = "Gnomeregans new Guardians", wwwLinks3 = "https://www.wowhead.com/quest=54185",
                                       mnIDs4 = 23, questIDs4 = 56491, wwwNames4 = "Tiny Terrors of Stratholme", wwwLinks4 = "https://www.wowhead.com/quest=56491", 
                                       mnIDs5 = 35, questIDs5 = 58457, wwwNames5 = "Shadows of Blackrock", wwwLinks5 = "https://www.wowhead.com/quest=58457" } -- Portal Manapuff
            end

            if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
              nodes[1355][39975256] = { mnID = 1161, name = "", type = "APortal", questID = 55175, showWWW = true, wwwLink = "wowhead.com/quest=29824", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portalroom to Boralus from Mezzamere
            end

          end
    
        -- Zandalar Ships
          if self.db.profile.showZoneShips then
    
            if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
              nodes[862][58046505] = { mnID = 463, name = "", type = "HShip", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ship from Zandalar to Echo Isles 
            end
    
          end

        -- Zandalar Transport
          if self.db.profile.showZoneTravel then

            if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
              nodes[862][58466298] = { npcID = 135690, mnID = 896, mnID2 = 895, mnID3 = 942, name = "", dnID = L["(Dread-Admiral Tattersail) will take you to Drustvar, Tiragarde Sound or Stormsong Valley"] .. "\n(" .. ITEM_REQ_HORDE .. ")", type = "UndeadF", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ship from Dazar'alor to Drustvar, Tiragarde Sound or Stormsong Valley
              nodes[862][55325808] = { npcID = 152506, mnID = 1462, name = "", dnID = "(" .. ITEM_REQ_HORDE ..")", type = "GoblinF", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Transport from Dazar'alor to Mechagon 
            end

            if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
              nodes[864][36693428] = { npcID = 135383, mnID = 1161, name = "", dnID =  "(" .. ITEM_REQ_ALLIANCE .. ")", type = "KulM", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Transport from Vol'dun to Boralus
              nodes[863][62064008] = { npcID = 139620, mnID = 1161, name = "", dnID =  "(" .. ITEM_REQ_ALLIANCE .. ")", type = "DwarfF", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Transport from Nazmir to Boralus
              nodes[862][40457103] = { npcID = 143334, mnID = 1161, name = "", dnID =  "(" .. ITEM_REQ_ALLIANCE .. ")", type = "GilneanF", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Transport from Zuldazar to Boralus 
            end
          end

          -- Zandalar Transport
          if self.db.profile.showMiniMapTransport then
            nodes[862][22555406] = { mnID = 2346, name = "", type = "RocketDrill", questID = 83933, wwwLink = "https://www.wowhead.com/quest=83933/the-kajacoast", showWWW = true, wwwName = BATTLE_PET_SOURCE_2 .. " " .. REQUIRES_LABEL .. " " .. "The Kaja'Coast", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Rocket Drill from Zandalar to Undermine
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
            nodes[895][71533261] = { mnID = 1161, id = { 1176, 1031, 1179, 1036 }, type = "AIcon", showInZone = true, showOnContinent = false, showOnMinimap = false, name = ns.Boralus .. " " .. "\n" .. " " .. "\n" .. L["Portalroom"] .. "\n" .. " ==> " .. ns.Stormwind .. "\n" .. " ==> " .. ns.Silithus .. "\n" .. " ==> " .. ns.Exodar .. "\n" .. " ==> " .. ns.Ironforge .. "\n" .. " " .. "\n" .. ns.GrandAdmiralJesTereth .. L["Travel"] .. "\n" .. " ==> " .. ns.Nazmir .. "\n" .. " ==> " .. ns.Zuldazar .. "\n" .. " ==> " .. ns.Voldun .. "\n" .. " " .. "\n" .. L["Portals"] .. "\n" .. " " .. "\n" .. " ==> " .. ns.ArathiHighlands .. "\n" .. " ==> " .. ns.Darkshore .. "\n" .. " " .. "\n" .. L["Ship"] .. "\n" .. " ==> " .. ns.Stormwind .. "\n" .. " "  .."\n" .. ns.Kiku .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " "} -- Boralus Transports
          end

        end

        if db.activate.ZoneTransporting then

        -- Kul Tiras Transport
          if self.db.profile.showZoneTravel then

            if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
              nodes[1462][75522266] = { npcID = 152506, mnID = 862, name = "", dnID = "(" .. ITEM_REQ_HORDE ..")", type = "GoblinF", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Transport from Mechagon to Zuldazar
              nodes[896][20614336] = { npcID = 139519, mnID = 862, name = "", dnID =  "(" .. ITEM_REQ_HORDE .. ")", type = "MOrcF", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Transport from Drustvar to Zuldazar
              nodes[942][51902432] = { npcID = 143282, mnID = 862, name = "", dnID =  "(" .. ITEM_REQ_HORDE .. ")", type = "OrcM", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Transport from Stormsong Valley to Zuldazar
              nodes[895][87855119] = { npcID = 139524, mnID = 862, name = "", dnID =  "(" .. ITEM_REQ_HORDE .. ")", type = "B11M", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Transport from Tiragarde Sound to Zuldazar 
            end

          end
    

        -- Kul Tiras Portals
          if self.db.profile.showZonePortals then
    
            if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
              nodes[895][74072427] = { mnID = 1161, name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = ns.Boralus .. " " .. L["Portalroom"] .. "\n" .. " " .. L["(inside building)"] .. "\n" .. " ==> " .. ns.Stormwind .. "\n" .. " ==> " .. ns.Silithus .. "\n" .. " ==> " .. ns.Exodar .. "\n" .. " ==> " .. ns.Ironforge .. "\n" .. " ==> " .. ns.Nazjatar } -- Portalroom from Boralus } -- Portalroom from Boralus
              nodes[895][69153054] = { npcID = 147666, mnID = 1161, name = "", dnID = "\n" .. TOOLTIP_BATTLE_PET .. " " .. CALENDAR_TYPE_DUNGEON .. " " .. L["Portals"] .. ":\n" .. " ", type = "PortalAPetBattleDungeon", showInZone = true, showOnContinent = false, showOnMinimap = false, 
                                        showWWW = true, wwwName = BATTLE_PET_SOURCE_2 .. " " .. REQUIRES_LABEL,
                                        mnIDs1 = 11, questIDs1 = 45423, wwwNames1 = "Wailing Critters", wwwLinks1 = "https://www.wowhead.com/quest=45423",
                                        mnIDs2 = 52, questIDs2 = 46291, wwwNames2 = "The Deadmines strike back", wwwLinks2 = "https://www.wowhead.com/quest=46291", 
                                        mnIDs3 = 30, questIDs3 = 54185, wwwNames3 = "Gnomeregans new Guardians", wwwLinks3 = "https://www.wowhead.com/quest=54185",
                                        mnIDs4 = 23, questIDs4 = 56491, wwwNames4 = "Tiny Terrors of Stratholme", wwwLinks4 = "https://www.wowhead.com/quest=56491", 
                                        mnIDs5 = 35, questIDs5 = 58457, wwwNames5 = "Shadows of Blackrock", wwwLinks5 = "https://www.wowhead.com/quest=58457" } -- Portal Manapuff
            end
          end


        -- Kul Tiras Ships
          if self.db.profile.showZoneShips then
    
            if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
              nodes[895][78162702] = { mnID = 84, name = "", type = "AShip", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ship from Boralus to Stormwind
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

            nodes[1543][42424210] = { mnID = 1670, name = "", type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = ns.Oribos .. " (" .. L["Portal"] ..")" } -- the Maw
            nodes[1961][64472406] = { mnID = 1671, name = "", type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = ns.Oribos .. " (" .. L["Portal"] ..")" } -- Korthia to Oribos
            nodes[1970][32956973] = { mnID = 1671, name = "", type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = ns.Oribos .. " (" .. L["Portal"] ..")" } -- Zereth Morthis to Oribos
            nodes[1543][48133902] = { mnID = 1911, name = "", type = "TorghastUp", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Maw to Torghast
            nodes[1911][10454655] = { mnID = 1543, name = "", type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Torghast to Maw
            nodes[1911][15946014] = { mnID = 1912, name = "", type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Torghast to Maw
            nodes[1912][50168375] = { mnID = 1911, name = "", type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Torghast to Maw
          end


        -- Shadowlands Transporter
          if self.db.profile.showZoneTransport then
            nodes[1543][47344340] = { mnID = 1961, name = "", type = "TravelM", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = ns.Korthia .. " (" .. L["Transport"] ..")" } -- Maw to Korthia
            nodes[1961][65062339] = { mnID = 1543, name = "", type = "TravelM", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = ns.TheMaw .. " (" .. L["Transport"] ..")"} -- Korthia to the Maw
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
            nodes[2239][89643770] = { mnID = 2200,  name = "", type = "WayGateGreen", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Bel'ameth, Amirdrassil to Emerald Dream
            nodes[2025][40516283] = { mnID = 2112, name = "", type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = ns.Valdrakken .. " " .. L["Portals"] .. "\n" ..  "\n" .. " ==> " .. ns.EmeraldDream .. "\n" .. " ==> " .. ns.Badlands .. "\n".." ==> " .. ns.Stormwind .. "\n" .. " ==> " .. ns.Orgrimmar } --  Valdrakken Portals
            nodes[2200][73065245] = { mnID = 2023, name = "", type = "WayGateGreen", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal The Emerald Dream to Ohn'ahran Plains
            nodes[2023][18295226] = { mnID = 2200, name = "", type = "WayGateGreen", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal to The Emerald Dream
    
            if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
              nodes[2239][55466365] = { mnID = 84,  name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Valdrakken to Stormwind City Portal
              nodes[2239][55326472] = { name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portals"] .. "\n" .. " ==> " .. ns.Darkshore .. "\n" .. " ==> " .. ns.Hyjal  .. "\n" .. " ==> " .. POSTMASTER_LETTER_LORLATHIL } -- Valdrakken to Stormwind City Portal
            end
          end
    
    
        -- Dragonflight Zeppelin
          if self.db.profile.showZoneZeppelins then      
    
            if self.faction == "Horde" or db.activate.ZoneEnemyFaction then 
              nodes[2022][81632788] = { mnID = 85, name = "", type = "HZeppelin", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Zeppelin from The Waking Shores to Orgrimmar 
            end
          end
    
    
        -- Dragonflight Ships
          if self.db.profile.showZoneShips then
            nodes[2239][49530434] = { mnID = 217, name = "", type = "Ship", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ship from Amirdrassil to Gilneas
       
            if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
              nodes[2022][82243070] = { mnID = 84, name = "", type = "AShip", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ship from The Waking Shores to Stormwind
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
            nodes[2255][57344184] = { mnID = 2339, name = "", showWWW = true, wwwName = LOOT_JOURNAL_LEGENDARIES_SOURCE_ACHIEVEMENT .. " " .. REQUIRES_LABEL, wwwLink = "https://wowhead.com/achievement=19559", achievementID = 19559, type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal from Azj-Kahet to Dornogal if u finished the achievement=19559
            nodes[2256][57344184] = { mnID = 2339, name = "", showWWW = true, wwwName = LOOT_JOURNAL_LEGENDARIES_SOURCE_ACHIEVEMENT .. " " .. REQUIRES_LABEL, wwwLink = "https://wowhead.com/achievement=19559", achievementID = 19559, type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal from Azj-Kahet to Dornogal if u finished the achievement=19559
            nodes[2367][49953591] = { mnID = 2339, name = "", showWWW = true, wwwName = LOOT_JOURNAL_LEGENDARIES_SOURCE_ACHIEVEMENT .. " " .. REQUIRES_LABEL, wwwLink = "https://wowhead.com/achievement=40725", achievementID = 40725, type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Chamber of Memory
            nodes[2248][53024511] = { mnID = 2339, name = "", showWWW = true, wwwName = LOOT_JOURNAL_LEGENDARIES_SOURCE_ACHIEVEMENT .. " " .. REQUIRES_LABEL, wwwLink = "https://wowhead.com/achievement=19559", achievementID = 19559, type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal from Dornogal to Azj-Kahet if u finished the achievement=19559
            nodes[2248][50554183] = { mnID = 2266, name = "", type = "WayGateGolden", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["The Timeways"] .. " " .. L["Portals"] .. "\n" .. "\n" .. " ==> " .. C_Map.GetMapInfo(2472).name .. "\n" .. " ==> " .. C_Map.GetMapInfo(1525).name } --  Portal from Dornogal to the Timeways
            nodes[2248][44634679] = { mnID = 2367, name = "", showWWW = true, wwwName = LOOT_JOURNAL_LEGENDARIES_SOURCE_ACHIEVEMENT .. " " .. REQUIRES_LABEL, wwwLink = "https://wowhead.com/achievement=40725", achievementID = 40725, type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Chamber of Memory
            nodes[2346][27805398] = { mnID = 2339, name = "", showWWW = true, wwwName = LOOT_JOURNAL_LEGENDARIES_SOURCE_ACHIEVEMENT .. " " .. REQUIRES_LABEL, wwwLink = "https://wowhead.com//quest=86535/test-run", questID = 86535, type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal from Undermine to Dornogal
            nodes[2472][62549423] = { mnID = 2339, name = "", type = "Portal", questID = 84957, showWWW = true, wwwName = BATTLE_PET_SOURCE_2 .. " " .. REQUIRES_LABEL, wwwLink = "https://wowhead.com/quest=84957/return-to-the-veiled-market", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal from Tazavesh to Dornogal
            nodes[2371][69358829] = { mnID = 2339, name = "", type = "Portal", questID = 84957, showWWW = true, wwwName = BATTLE_PET_SOURCE_2 .. " " .. REQUIRES_LABEL, wwwLink = "https://wowhead.com/quest=84957/return-to-the-veiled-market", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal from Tazavesh to Dornogal
            nodes[2371][66417176] = { mnID = 2339, name = "", type = "Portal", questID = 84967, wwwLink = "https://www.wowhead.com/quest=84967", showWWW = true, wwwName = BATTLE_PET_SOURCE_2 .. " " .. REQUIRES_LABEL .. " " .. "The shadowguard shattered", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal Tazavesh to Dornogal
            nodes[2472][49441971] = { mnID = 2339, name = "", type = "Portal", questID = 84967, wwwLink = "https://www.wowhead.com/quest=84967", showWWW = true, wwwName = BATTLE_PET_SOURCE_2 .. " " .. REQUIRES_LABEL .. " " .. "The shadowguard shattered", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal Tazavesh to Dornogal

            if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
              nodes[2248][46913872] = { mnID = 2339, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Dornogal to Orgrimmar
              nodes[2322][07105283] = { mnID = 85, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hall of Awakening
            end
   
            if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
              nodes[2248][47043781] = { mnID = 2339, name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Dornogal to Stormwind
              nodes[2322][07184634] = { mnID = 84, name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hall of Awakening
            end
          end

          -- Khaz Algar Transport
          if self.db.profile.showZoneTransport then
            nodes[2369][67613901] = { mnID = 2214, name = "", type = "MoleMachine", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mole Machine from Sirene Isle to Deeps
            nodes[2214][41993030] = { mnID = 2369, name = "", type = "MoleMachine", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mole Machine from Deeps to Sirene Isle
            nodes[2214][72957320] = { npcID = 229022, mnID = 2346, name = "", type = "RocketDrill", questID = 83151, wwwLink = "wowhead.com/quest=83151", showWWW = true, wwwName = BATTLE_PET_SOURCE_2 .. " " .. REQUIRES_LABEL .. " " .. "Down Undermine", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Rocket Drill Deeps to Undermine
            nodes[2346][17285075] = { npcID = 233626, mnID = 2214, name = "", type = "RocketDrill", questID = 83151, wwwLink = "wowhead.com/quest=83151", showWWW = true, wwwName = BATTLE_PET_SOURCE_2 .. " " .. REQUIRES_LABEL .. " " .. "Down Undermine", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Rocket Drill from Undermine to Deeps
            nodes[2346][18795225] = { npcID = 233625, mnID = 862, name = "", type = "RocketDrill", questID = 83933, wwwLink = "https://www.wowhead.com/quest=83933/the-kajacoast", showWWW = true, wwwName = BATTLE_PET_SOURCE_2 .. " " .. REQUIRES_LABEL .. " " .. "The Kaja'Coast", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Rocket Drill from Undermine to Zandalar
            nodes[2472][34741004] = { npcID = 234692, mnID = 2472, name = "", type = "TravelM", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Tazavesh Flightmaster
            nodes[2214][49194459] = { mnID = 2248, name = L["Elevator"], type = "PassageElevatorUp", questID = 82195, wwwLink = "https://https://www.wowhead.com/quest=82195/rust-and-redemption", showWWW = true, wwwName = BATTLE_PET_SOURCE_2 .. " " .. REQUIRES_LABEL .. " " .. "Rust and Redemption", showInZone = true, showOnContinent = false, showOnMinimap = false }
            nodes[2214][61547692] = { mnID = 2248, name = L["Elevator"], type = "PassageElevatorUp", questID = 84220, wwwLink = "https://www.wowhead.com/quest=84220/passage-to-the-ringing-deeps", showWWW = true, wwwName = BATTLE_PET_SOURCE_2 .. " " .. REQUIRES_LABEL .. " " .. "Passage to the ringing deeps", showInZone = true, showOnContinent = false, showOnMinimap = false }
            nodes[2248][67333102] = { mnID = 2214, name = L["Elevator"], type = "PassageElevatorDown", questID = 82195, wwwLink = "https://https://www.wowhead.com/quest=82195/rust-and-redemption", showWWW = true, wwwName = BATTLE_PET_SOURCE_2 .. " " .. REQUIRES_LABEL .. " " .. "Rust and Redemption", showInZone = true, showOnContinent = false, showOnMinimap = false }
            nodes[2248][37427287] = { mnID = 2214, name = L["Elevator"], type = "PassageElevatorDown", questID = 84220, wwwLink = "https://www.wowhead.com/quest=84220/passage-to-the-ringing-deeps", showWWW = true, wwwName = BATTLE_PET_SOURCE_2 .. " " .. REQUIRES_LABEL .. " " .. "Passage to the ringing deeps", showInZone = true, showOnContinent = false, showOnMinimap = false }
          end
    
        -- Khaz Algar Zeppelin
          if self.db.profile.showZoneZeppelins then

            nodes[2369][70725350] = { npcID = 231541, mnID = 2339, name = "", type = "Zeppelin", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Zeppelin from Siren Isle to Dornogal
            nodes[2248][55453363] = { npcID = 231541, mnID = 2369, name = "", type = "Zeppelin", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Zeppelin to Siren Isle from Dornogal

            if self.faction == "Horde" or db.activate.ZoneEnemyFaction then 
              --nodes[2022][81632788] = { mnID = 85, name = "", type = "HZeppelin", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Zeppelin from The Waking Shores to Orgrimmar 
            end
          end
    
    
        -- Khaz Algar Ships
          if self.db.profile.showZoneShips then
            if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
              --nodes[2022][82243070] = { mnID = 84, name = "", type = "AShip", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ship from The Waking Shores to Stormwind
            end
          end

        end

        --Professions
        if self.db.profile.activate.ZoneProfessions then

          if self.db.profile.showZoneAlchemy then
            nodes[2216][45411357] = { npcID = 218171, name = "", type = "Alchemy", showInZone = true, showOnContinent = false, showOnMinimap = false }
            nodes[2213][45411357] = { npcID = 218171, name = "", type = "Alchemy", showInZone = true, showOnContinent = false, showOnMinimap = false }
            nodes[2216][67423141] = { npcID = 225611, name = "", type = "Alchemy", showInZone = true, showOnContinent = false, showOnMinimap = false, dnID = L["(inside building)"] }
            nodes[2213][67423141] = { npcID = 225611, name = "", type = "Alchemy", showInZone = true, showOnContinent = false, showOnMinimap = false, dnID = L["(inside building)"] }
            nodes[2255][54837585] = { npcID = 225611, name = "", type = "Alchemy", showInZone = true, showOnContinent = false, showOnMinimap = false, dnID = L["(inside building)"] }
            nodes[2256][54837585] = { npcID = 225611, name = "", type = "Alchemy", showInZone = true, showOnContinent = false, showOnMinimap = false, dnID = L["(inside building)"] }
          end
      
          if self.db.profile.showZoneLeatherworking then
            nodes[2216][43771954] = { npcID = 218164, name = "", type = "Leatherworking", showInZone = true, showOnContinent = false, showOnMinimap = false }
            nodes[2213][43771954] = { npcID = 218164, name = "", type = "Leatherworking", showInZone = true, showOnContinent = false, showOnMinimap = false }
          end

          if self.db.profile.showZoneEngineer then
            nodes[2216][57503277] = { npcID = 218186, name = "", type = "Engineer", showInZone = true, showOnContinent = false, showOnMinimap = false }
            nodes[2213][57503277] = { npcID = 218186, name = "", type = "Engineer", showInZone = true, showOnContinent = false, showOnMinimap = false }
            nodes[2255][51387631] = { npcID = 218186, name = "", type = "Engineer", showInZone = true, showOnContinent = false, showOnMinimap = false }
            nodes[2256][51387631] = { npcID = 218186, name = "", type = "Engineer", showInZone = true, showOnContinent = false, showOnMinimap = false }
          end

          if self.db.profile.showZoneSkinning then
            nodes[2216][42602007] = { npcID = 218163, name = "", type = "Skinning", showInZone = true, showOnContinent = false, showOnMinimap = false }
            nodes[2213][42602007] = { npcID = 218163, name = "", type = "Skinning", showInZone = true, showOnContinent = false, showOnMinimap = false }
          end

          if self.db.profile.showZoneTailoring then
            nodes[2216][49711743] = { npcID = 218181, name = "", type = "Tailoring", showInZone = true, showOnContinent = false, showOnMinimap = false }
            nodes[2213][49711743] = { npcID = 218181, name = "", type = "Tailoring", showInZone = true, showOnContinent = false, showOnMinimap = false }
          end

          if self.db.profile.showZoneBlacksmith then
            nodes[2216][46002227] = { npcID = 218167, name = "", type = "Blacksmith", showInZone = true, showOnContinent = false, showOnMinimap = false, dnID = "( " .. ERR_USE_OBJECT_MOVING .. " )" }
            nodes[2213][46002227] = { npcID = 218167, name = "", type = "Blacksmith", showInZone = true, showOnContinent = false, showOnMinimap = false, dnID = "( " .. ERR_USE_OBJECT_MOVING .. " )" }
          end

          if self.db.profile.showZoneMining then
            nodes[2216][46842255] = { npcID = 218167, name = "", type = "Mining", showInZone = true, showOnContinent = false, showOnMinimap = false }
            nodes[2213][46842255] = { npcID = 218167, name = "", type = "Mining", showInZone = true, showOnContinent = false, showOnMinimap = false }
          end

          if self.db.profile.showZoneFishing then
            nodes[2216][51422519] = { npcID = 218175, name = "", type = "Fishing", showInZone = true, showOnContinent = false, showOnMinimap = false }
            nodes[2213][51422519] = { npcID = 218175, name = "", type = "Fishing", showInZone = true, showOnContinent = false, showOnMinimap = false }
            nodes[2371][75503411] = { npcID = 244485, name = "", type = "Fishing", showInZone = true, showOnContinent = false, showOnMinimap = false }
          end

          if self.db.profile.showZoneCooking then
            nodes[2216][47912464] = { npcID = 218173, name = "", type = "Cooking", showInZone = true, showOnContinent = false, showOnMinimap = false }
            nodes[2213][47912464] = { npcID = 218173, name = "", type = "Cooking", showInZone = true, showOnContinent = false, showOnMinimap = false }
            nodes[2472][46061826] = { npcID = 235253, name = "", type = "Cooking", questID = 84967, wwwLink = "https://www.wowhead.com/quest=84967", showWWW = true, wwwName = BATTLE_PET_SOURCE_2 .. " " .. REQUIRES_LABEL .. " " .. "The shadowguard shattered", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Tazavesh
          end

          if self.db.profile.showZoneEnchanting then
            nodes[2216][45573452] = { npcID = 218177, name = "", type = "Enchanting", showInZone = true, showOnContinent = false, showOnMinimap = false, dnID = L["(inside building)"] }
            nodes[2213][45573452] = { npcID = 218177, name = "", type = "Enchanting", showInZone = true, showOnContinent = false, showOnMinimap = false, dnID = L["(inside building)"] }
            nodes[2255][47207694] = { npcID = 218177, name = "", type = "Enchanting", showInZone = true, showOnContinent = false, showOnMinimap = false, dnID = L["(inside building)"] }
            nodes[2256][47207694] = { npcID = 218177, name = "", type = "Enchanting", showInZone = true, showOnContinent = false, showOnMinimap = false, dnID = L["(inside building)"] }
          end

          if self.db.profile.showZoneJewelcrafting then
            nodes[2216][47751925] = { npcID = 218180, name = "", type = "Jewelcrafting", showInZone = true, showOnContinent = false, showOnMinimap = false }
            nodes[2213][47751925] = { npcID = 218180, name = "", type = "Jewelcrafting", showInZone = true, showOnContinent = false, showOnMinimap = false }
          end

          if self.db.profile.showZoneHerbalism then            
            nodes[2216][47271667] = { npcID = 218170, name = "", type = "Herbalism", showInZone = true, showOnContinent = false, showOnMinimap = false }
            nodes[2213][47271667] = { npcID = 218170, name = "", type = "Herbalism", showInZone = true, showOnContinent = false, showOnMinimap = false }
          end

          if self.db.profile.showZoneInscription then
            nodes[2216][41752650] = { npcID = 218178, name = "", type = "Inscription", showInZone = true, showOnContinent = false, showOnMinimap = false, dnID = L["(inside building)"] }
            nodes[2213][41752650] = { npcID = 218178, name = "", type = "Inscription", showInZone = true, showOnContinent = false, showOnMinimap = false, dnID = L["(inside building)"] }
            nodes[2255][45837409] = { npcID = 218178, name = "", type = "Inscription", showInZone = true, showOnContinent = false, showOnMinimap = false, dnID = L["(inside building)"] }
            nodes[2256][45837409] = { npcID = 218178, name = "", type = "Inscription", showInZone = true, showOnContinent = false, showOnMinimap = false, dnID = L["(inside building)"] }
          end

          if self.db.profile.ZoneProfessionsMixed and ( self.db.profile.showZoneAlchemy or self.db.profile.showZoneMining or self.db.profile.showZoneBlacksmith or self.db.profile.showZoneLeatherworking or self.db.profile.showZoneJewelcrafting or self.db.profile.showZoneHerbalism or self.db.profile.showZoneTailoring or self.db.profile.showZoneFishing or self.db.profile.showZoneCooking or self.db.profile.showZoneSkinning ) then
            nodes[2255][47697093] = { name = MINIMAP_TRACKING_TRAINER_PROFESSION, type = "ProfessionsMixed", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = TextIconAlchemy:GetIconString() .. " " .. L["Alchemy"] .. "\n" .. TextIconMining:GetIconString() .. " " .. L["Mining"] .. "\n" .. TextIconBlacksmith:GetIconString() .. " " .. L["Blacksmithing"] .. "\n" .. TextIconLeatherworking:GetIconString() .. " " .. L["Leatherworking"] .. "\n" .. TextIconJewelcrafting:GetIconString() .. " " .. L["Jewelcrafting"] .. "\n" .. TextIconHerbalism:GetIconString() .. " " .. L["Herbalism"] .. "\n" .. TextIconTailoring:GetIconString() .. " " .. L["Tailoring"] .. "\n" .. TextIconLeatherworking:GetIconString() .. " " .. L["Leatherworking"] .. "\n" .. TextIconFishing:GetIconString() .. " " .. PROFESSIONS_FISHING .. "\n" .. TextIconCooking:GetIconString() .. " " .. PROFESSIONS_COOKING } -- City of Fades
            nodes[2256][47697093] = { name = MINIMAP_TRACKING_TRAINER_PROFESSION, type = "ProfessionsMixed", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = TextIconAlchemy:GetIconString() .. " " .. L["Alchemy"] .. "\n" .. TextIconMining:GetIconString() .. " " .. L["Mining"] .. "\n" .. TextIconBlacksmith:GetIconString() .. " " .. L["Blacksmithing"] .. "\n" .. TextIconLeatherworking:GetIconString() .. " " .. L["Leatherworking"] .. "\n" .. TextIconJewelcrafting:GetIconString() .. " " .. L["Jewelcrafting"] .. "\n" .. TextIconHerbalism:GetIconString() .. " " .. L["Herbalism"] .. "\n" .. TextIconTailoring:GetIconString() .. " " .. L["Tailoring"] .. "\n" .. TextIconLeatherworking:GetIconString() .. " " .. L["Leatherworking"] .. "\n" .. TextIconFishing:GetIconString() .. " " .. PROFESSIONS_FISHING .. "\n" .. TextIconCooking:GetIconString() .. " " .. PROFESSIONS_COOKING } -- City of Fades
          end

        end

      end

    end
  end

end