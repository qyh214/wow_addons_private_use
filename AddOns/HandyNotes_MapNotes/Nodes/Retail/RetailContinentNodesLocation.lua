local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

function ns.LoadContinentNodesLocationinfo(self)
local db = ns.Addon.db.profile
local nodes = ns.nodes
ns.currentSourceFile = "RetailContinentNodesLocation.lua"

--#####################################################################################################
--##########################        function to hide all nodes below         ##########################
--#####################################################################################################
  if not db.activate.HideMapNote then
 
    --#####################################################################################################
    --################################         Continent / Zone Map        ################################
    --#####################################################################################################
    
      if db.activate.Continent then
    
    
        --#############################
        --##### Continent Kalimdor ####
        --#############################
    
        if self.db.profile.showContinentKalimdor then
        
        -- Kalimdor Dungeons
            if self.db.profile.showContinentDungeons then
            nodes[12][53146914] = { id = 233, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Razorfen Downs 
            nodes[12][42726722] = { id = 230, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Dire Maul - Capital
            nodes[12][54187774] = { id = 241, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Zul'Farrak
            nodes[12][50916837] = { id = 234, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Razorfen Kraul 
            nodes[12][52519670] = { id = 68, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- The Vortex Pinnacle 
            nodes[12][49699341] = { id = 69, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Lost City of Tol'Vir 
            nodes[12][51579122] = { id = 70, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Halls of Origination
            nodes[948][51102882] = { id = 67, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- The Stonecore
          end

        -- Kalimdor PetBattleDungeons
          if self.db.profile.showContinentPetBattleDungeons then
            nodes[12][51985246] = { npcID = 116781, name = "", mnID = 10, type = "PetBattleDungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Wailing Caverns
          end

        -- Kalimdor Dungeons hidden if noPassages is activ
          if self.db.profile.showContinentDungeons and not db.activate.noPassages then 
            nodes[12][42856552] = { id = 1277, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Dire Maul - Gordok Commons - North  
          end
    
        --Kalimdor Raids
          if self.db.profile.showContinentRaids then
            nodes[12][45929663] = { id = 74, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Throne of the Four Winds 
            nodes[12][54243397] = { id = 78, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Firelands 
            nodes[12][56526946] = { id = 760, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Onyxia's Lair 
            nodes[12][42068358] = { id = 743, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Ruins of Ahn'Qiraj 
            nodes[12][40678358] = { id = 744, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Temple of Ahn'Qiraj
            nodes[12][49159032] = { id = 1180, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false, dnID = L["Instance Entrance"] .. " " .. L["switches weekly between"] .. " " .. ns.Uldum .. " (" .. ns.Kalimdor ..")" .. " & " .. ns.ValeOfEternalBlossoms .. " (" .. ns.Pandaria .. ")" } -- Ny'Alotha, The Waking City
          end
    
        --Kalimdor Passage
          if self.db.profile.showContinentPassage and not db.activate.noPassages then
            nodes[12][59228331] = { mnID = 75, id = { 187, 750, 279, 255, 251, 184, 185, 186 }, type = "PassageDungeonRaidMulti", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Dragon Soul, The Battle for Mount Hyjal, The Culling of Stratholme, Black Morass, Old Hillsbrad Foothills, End Time, Well of Eternity, Hour of Twilight Heroic
            nodes[12][46106657] = { id = 1276, type = "PassageDungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Dire Maul - Warpwood Quarter - East above Camp Mojache   
            nodes[12][43906613] = { id = 1276, type = "PassageDungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Dire Maul - Warpwood Quarter - East above Camp Mojache 
            nodes[12][43913301] = { id = 227, type = "PassageDungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Blackfathom Deeps 
            nodes[12][52215315] = { id = 240, mnID = 11, dnID = ns.WailingCaverns, name = "", type = "PassageDungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Wailing Caverns  
            nodes[12][38395594] = { id = 232, type = "PassageDungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Maraudon 
            --nodes[12][58324232] = { id = 226, type = "PassageDungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Ragefire 
          end

        --Kalimdor Passage without noPassages and without MapNotesIcons
          if self.db.profile.showContinentPassage and not db.activate.noPassages and not self.db.profile.showContinentMapNotes then
            nodes[12][58324232] = { id = 226, type = "PassageDungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Ragefire 
          end

        --Kalimdor Passage without ContinentEnemyFaction and MapNotesIcons
          if not db.activate.ContinentEnemyFaction and self.db.profile.showContinentMapNotes then

            if self.faction == "Alliance" or db.activate.ContinentEnemyFaction then
              nodes[12][58324232] = { id = 226, type = "PassageDungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Ragefire
            end
          end

        --Kalimdor Passage without ContinentEnemyFaction and with MapNotesIcons with noPassages
          if not db.activate.ContinentEnemyFaction and self.db.profile.showContinentMapNotes and db.activate.noPassages then
            --nodes[12][58324232] = { id = 226, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Ragefire
          end

        --Kalimdor noPassages
         if db.activate.noPassages then

          if self.db.profile.showContinentDungeons then
            --nodes[12][46106657] = { id = 1276, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Dire Maul - Warpwood Quarter - East above Camp Mojache   
            --nodes[12][43906613] = { id = 1276, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Dire Maul - Warpwood Quarter - East above Camp Mojache 
            nodes[12][43913301] = { id = 227, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Blackfathom Deeps 
            nodes[12][52215315] = { id = 240, name = "", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Wailing Caverns  
            nodes[12][38395594] = { id = 232, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Maraudon 
          end

        --Kalimdor noPassages without MapNotesIcons
          if db.activate.noPassages and not self.db.profile.showContinentMapNotes then

            if self.db.profile.showContinentDungeons then
              nodes[12][58324232] = { id = 226, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Ragefire 
            end
          end

          
         --Kalimdor Multiple 
          if self.db.profile.showContinentMultiple then
            nodes[12][59228331] = { mnID = 75, id = { 187, 750, 279, 255, 251, 184, 185, 186 }, type = "MultipleM", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Dragon Soul, The Battle for Mount Hyjal, The Culling of Stratholme, Black Morass, Old Hillsbrad Foothills, End Time, Well of Eternity, Hour of Twilight Heroic
          end
         end 
    

        -- Kalimdor Portals
          if self.db.profile.showContinentPortals then

            nodes[12][60078511] = { mnID = 74, name = "", type = "Portal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.CavernsOfTime .. " " .. L["Portals"] .. "\n" ..  "\n" .. " ==> " .. ns.Orgrimmar .. "\n" .. " ==> " .. ns.Stormwind } -- Portal from Tanaris to Orgrimmar and Stormwind
            nodes[12][42807881] = { mnID = 81, name = "", type = "Portal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.Silithus .. " " .. L["Portals"] .. "\n" ..  "\n" .. " ==> " .. ns.Boralus .. "\n" .. " ==> " .. ns.Zandalar } -- Portal from Silithus to Boralus
            nodes[12][56122725] = { mnID = 198, name = "", type = "Portal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.Hyjal .. " " .. L["Portals"] .. "\n" ..  "\n" .. " ==> " .. ns.Orgrimmar .. "\n" .. " ==> " .. ns.Stormwind } -- Portal To Orgrimmar from Hyjal
            nodes[12][49847481] = { mnID = 78, name = "", type = "Portal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.UnGoroCrater .. " " .. L["Portal"] .. "\n" .. " ==> " .. ns.SholazarBasin } --  Portal to Sholazar

            if self.faction == "Horde" or db.activate.ContinentEnemyFaction then  
              nodes[12][45605762] = { mnID = 7, name = FACTION_HORDE .. " " .. L["Portal"] .. " ==> " .. CALENDAR_FILTER_DARKMOON, showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = "\n" .. REQUIRES_LABEL .. " " .. CALENDAR_FILTER_DARKMOON .. "\n" .. L["Starting on the first Sunday of each month for one week"], type = "DarkMoon" } -- Mulgore Portal to the Darkmoon
              nodes[12][45842223] = { mnID = 62, name = "", type = "HPortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Portal"] .. " " .. ns.Darkshore .. " ==> " .. ns.Zandalar .. "\n" .. "\n" .. " " .. L["(its only shown up ingame if your faction\n is currently occupying Bashal'Aran)"] } -- Portal from New Darkshore to Zandalar 
            end

            if self.faction == "Alliance" or db.activate.ContinentEnemyFaction then
              nodes[12][47092322] = { mnID = 62, name = "", type = "APortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Portal"] .. " " .. ns.Darkshore .. " ==> " .. ns.Boralus .. "\n" .. "\n" .. " " .. L["(its only shown up ingame if your faction\n is currently occupying Bashal'Aran)"] } -- Portal from New Darkshore to Zandalar 
              nodes[12][43491624] = { mnID = 57, name = "", type = "APortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.Ruttheran .. " " .. L["Portals"] .. "\n" .. " ==> " .. ns.Stormwind .. "\n" .. " ==> " .. ns.AzuremystIsle .. "\n" .. " ==> " .. ns.Darnassus .. "\n" .. " ==> " .. ns.HellfirePeninsula } -- Portal from Teldrassil  
              nodes[12][29062721] = { mnID = 97, name = "", type = "APortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.AzuremystIsle .. " " .. L["Portal"] .. "\n" .. " ==> " .. ns.Ruttheran } -- Portal Exodar to Teldrassil
            end

            if self.faction == "Horde" and not db.activate.ContinentEnemyFaction then
              nodes[12][43491624] = { mnID = 57, name = "", type = "Portal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.Ruttheran .. " " .. L["Portal"] .. "\n" .. " ==> " .. ns.Darnassus } -- Portal from Teldrassil to Darnassus   
              nodes[12][38990979] = { mnID = 89, name = "", type = "Portal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.Darnassus .. " " .. L["Portal"] .. "\n" .. " ==> " .. ns.Ruttheran } -- Portal To Teldrassil from Darnassus
            end
          end
    

          -- Kalimdor Portals without MapNotesIcons
          if self.db.profile.showContinentPortals and not self.db.profile.showContinentMapNotes then

            if self.faction == "Alliance" or db.activate.ContinentEnemyFaction then
              nodes[12][38990979] = { mnID = 57, name = "", type = "Portal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. ns.Teldrassil } -- Portal To Teldrassil from Darnassus
              nodes[12][30752589] = { mnID = 57, name = "", type = "APortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. ns.Stormwind } -- Portal Exodar to Teldrassil
            end
          end

        -- Kalimdor MapNotesIcons
          if self.db.profile.showContinentMapNotes then

            if self.faction == "Horde" or db.activate.ContinentEnemyFaction then
              nodes[12][58214450] = { mnID = 85, name = "", type = "HIcon", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.Orgrimmar .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Portalroom"] .. "\n" .. " ==> " .. ns.Silvermoon .. "\n" .. " ==> " .. ns.Valdrakken .. "\n" .. " ==> " .. ns.Oribos .. "\n" .. " ==> " .. ns.Azsuna .. "\n" .. " ==> " .. ns.Zuldazar .. "\n" .. " ==> " .. ns.Shattrath .. "\n" .. " ==> " .. ns.Dalaran .. "\n" .. " ==> " .. ns.CavernsOfTime .. "\n" .. " ==> " .. ns.DarkPortal .. "\n" .. " ==> " .. ns.Dornogal .. "\n" .. "\n" .. L["Portals"] .. "\n" .. " ==> " .. ns.Hyjal .. "\n" .. " ==> " .. ns.TwilightHighlands .. "\n" .. " ==> " .. ARTIFACT_SHAMAN_TITLECARD_DEEPHOLM .. "\n" .. " ==> " .. ns.Vashjir .. "\n" .. " ==> " .. ns.Uldum .. "\n" .. " ==> " .. ns.TolBarad .. "\n" .. " ==> " .. DUNGEON_FLOOR_SURAMARRAID3 .. "\n" .. " ==> " .. POSTMASTER_LETTER_THUNDERTOTEM .. "\n" .. "\n" .. L["Zeppelins"] .. "\n" .. " ==> " .. ns.ThunderBluff .. "\n" .. " ==> " .. ns.Gromgol .. "\n" .. " ==> " .. POSTMASTER_LETTER_WARSONGHOLD .. "\n" .. "\n" .. CALENDAR_TYPE_DUNGEON .. "\n" .. " ==> " .. DUNGEON_FLOOR_RAGEFIRE1 } -- Portalroom from Dazar'alor
              nodes[12][46295508] = { mnID = 88, name = "", type = "HIcon", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.ThunderBluff .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Zeppelin"] .. "\n" .. " ==> " .. ns.Orgrimmar } -- Zeppelin from Thunder Bluff to Orgrimmar
            end

            if self.faction == "Alliance" or db.activate.ContinentEnemyFaction then
              nodes[12][38990979] = { mnID = 89, name = "", type = "AIcon", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.Darnassus .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Portals"] .. "\n" .. " ==> " .. ns.Ruttheran .. "\n" .. " ==> " .. ns.Exodar  .. "\n" .. " ==> " .. ns.HellfirePeninsula } -- Portal To Teldrassil from Darnassus
              nodes[12][30752589] = { mnID = 103, name = "", type = "AIcon", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.Exodar .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " ==> " .. ns.Stormwind } -- Portal Exodar to Teldrassil
            end
          end
    

        --Kalimdor Zeppelins
          if self.db.profile.showContinentZeppelins then

            if self.faction == "Horde" or db.activate.ContinentEnemyFaction then
              nodes[12][59814453] = { mnID = 1, name = "", type = "HZeppelin", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Zeppelin"] .. " ==> " .. ns.TheWakingShores } -- Zeppelin from Durotar to Waking Shores - Dragonflight
            end
          end
    

        --Kalimdor Zeppelins without MapNotesIcons
          if self.db.profile.showContinentZeppelins and not self.db.profile.showContinentMapNotes then

            if self.faction == "Horde" or db.activate.ContinentEnemyFaction then
              nodes[12][45295331] = { mnID = 88, name = "", type = "HZeppelin", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.ThunderBluff .. " " .. L["Zeppelin"] .. "\n" .. " ==> " .. ns.Orgrimmar } -- Zeppelin from Thunder Bluff to Orgrimmar
              --nodes[12][59814453] = { mnID = 1, name = "", type = "HZeppelin", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Zeppelin"] .. " ==> " .. ns.TheWakingShores } -- Zeppelin from Durotar to Waking Shores - Dragonflight
            end
          end

    
        -- Kalimdor Ships
          if self.db.profile.showContinentShips then
            nodes[12][57735526] = { mnID = 10, name = "", type = "Ship", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.Ratchet .. " " .. L["Ship"] .. "\n" .. " ==> " .. POSTMASTER_LETTER_STRANGLETHORNVALE } -- Ship from Ratchet to Booty Bay
    
            if self.faction == "Horde" or db.activate.ContinentEnemyFaction then
              nodes[12][62985416] = { mnID = 463, name = "", type = "HShip", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.EchoIsles .. " " .. L["Ship"] .. "\n" .. " ==> " .. ns.Zandalar } -- Ship from Echo Isles to Dazar'alor - Zandalar
            end
    
            if self.faction == "Alliance" or db.activate.ContinentEnemyFaction then
              nodes[12][60046602] = { mnID = 70, name = "", type = "AShip", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.TheramoreIsle .. " " .. L["Ship"] .. "\n" .. " ==> " .. POSTMASTER_LETTER_WETLANDS } -- Ship from Dustwallow Marsh to Menethil Harbor
            end
          end


        -- Continent Kalimdor LFR
          if self.db.profile.showContinentLFR then
            nodes[12][60448275] = { mnID = 75, id = { 187 }, name = ns.Auridormi .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " ", showOnContinent = true, showInZone = false, showOnMinimap = false, type = "LFR"}
          end

        -- Kalimdor PvpandPveVendor
          if self.db.profile.showContinentPvPandPvEVendor then
            nodes[12][56607888] = { name = "", dnID = TRANSMOG_SET_PVP .. " " .. MERCHANT .. "\n" .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. "\n" .. AUCTION_CATEGORY_WEAPONS, mnID = 71, type = "PvPVendor", hideTTmnID = true, showOnContinent = true, showInZone = false, showOnMinimap = false }
            
            if self.faction == "Horde" or db.activate.ContinentEnemyFaction then
              nodes[12][52124561] = { name = "", dnID = TRANSMOG_SET_PVP .. " " .. MERCHANT .. " " .. FACTION_HORDE .. "\n" .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. "\n" .. AUCTION_CATEGORY_WEAPONS, mnID = 10, type = "ContinentPvPVendorH", hideTTmnID = true, showOnContinent = true, showInZone = false, showOnMinimap = false }
            end
            
            if self.faction == "Alliance" or db.activate.ContinentEnemyFaction then
              nodes[12][51524394] = { name = "", dnID = TRANSMOG_SET_PVP .. " " .. MERCHANT .. " " .. FACTION_ALLIANCE .. "\n" .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. "\n" .. AUCTION_CATEGORY_WEAPONS, mnID = 63, type = "ContinentPvPVendorA", hideTTmnID = true, showOnContinent = true, showInZone = false, showOnMinimap = false }
            end

          end

        end
    
    
        --#####################################
        --##### Continent Eastern  Kingdom ####
        --#####################################
    
        if self.db.profile.showContinentEasternKingdom then
    
        --Eastern  Kingdom Dungeons
          if self.db.profile.showContinentDungeons then
            nodes[13][56740242] = { id = 249, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Magisters' Terrace 
            nodes[13][58572466] = { id = 77, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Zul'Aman 
            nodes[13][31796256] = { id = 65, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Throne of Tides 
            nodes[13][47448471] = { id = 76, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Zul'Gurub 
            nodes[13][40764187] = { id = 64, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Shadowfang Keep 
            nodes[13][50573677] = { id = 246, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Scholomance
            nodes[13][52712836] = { id = 236, lfgid = 40, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Stratholme 
            nodes[13][53135585] = { id = 71, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Grim Batol
          end

          -- Eastern Kingdom PetBattleDungeons
          if self.db.profile.showContinentPetBattleDungeons then
            nodes[13][53972930] = { npcID = 150987, name = "", mnID = 23, type = "PetBattleDungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Stratholme
            nodes[13][42426011] = { npcID = 147070, name = "", mnID = 30, type = "PetBattleDungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Gnomeregan
            nodes[13][47216795] = { npcID = 161782, name = "", mnID = 35, type = "PetBattleDungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Blackrock Deeps
            nodes[13][46886972] = { npcID = 161782, name = "", mnID = 35, type = "PetBattleDungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Blackrock Deeps
            nodes[13][40468127] = { npcID = 119390, name = "", mnID = 52, type = "PetBattleDungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Deadmines
          end

        --Eastern  Kingdom Dungeons without MapNotesIcons
          if self.db.profile.showContinentDungeons and not self.db.profile.showContinentMapNotes then
            nodes[13][42787097] = { id = 238, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- The Stockade 
          end
    
    
        --Eastern  Kingdom Raids
          if self.db.profile.showContinentRaids then
            nodes[13][55160370] = { id = 752, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Sunwell Plateau 
            nodes[13][47536894] = { id = 73, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Blackwind Descent 
            nodes[13][54905899] = { id = 72, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- The Bastion of Twilight 
            nodes[13][35565150] = { id = 75, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Baradin Hold
          end


        --Eastern  Kingdom Passage
          if self.db.profile.showContinentPassage and not db.activate.noPassages then
            nodes[13][53977927] = { id = 237, type = "PassageDungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- The Temple of Atal'hakkar 
            nodes[13][40808194] = { id = 63, type = "PassageDungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Deadmines
            nodes[13][42915972] = { id = 231, type = "PassageDungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Gnomeregan             
            nodes[13][53646537] = { id = 239, name = "", type = "PassageDungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Uldaman (Secondary Entrance) 
            nodes[13][54412915] = { id = 1292, type = "PassageDungeon", showOnContinent = true, showInZone = false, showOnMinimap = false }-- Stratholme Service Entrance 
            nodes[13][47216795] = { mnID = 33, name = TOOLTIP_BATTLE_PET .. " " .. LFG_TYPE_DUNGEON, id = { 741, 742, 66, 228, 229, 559 }, type = "PassageDungeonRaidMulti", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Molten Core, Blackwing Lair, Blackrock Caverns, Blackrock Depths, Lower Blackrock Spire, Upper Blackrock Spire 
            nodes[13][46886972] = { mnID = 33, name = TOOLTIP_BATTLE_PET .. " " .. LFG_TYPE_DUNGEON, id = { 741, 742, 66, 228, 229, 559 }, type = "PassageDungeonRaidMulti", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Molten Core, Blackwing Lair, Blackrock Caverns, Blackrock Depths, Lower Blackrock Spire, Upper Blackrock Spire 
          end
    
        --Kalimdor Passage without noPassages and without MapNotesIcons
          if self.db.profile.showContinentDungeons and not db.activate.noPassages and not self.db.profile.showContinentMapNotes then
            nodes[13][42787097] = { id = 238, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- The Stockade  
          end

        --Kalimdor Dungeon without ContinentEnemyFaction and MapNotesIcons
          if not db.activate.ContinentEnemyFaction and self.db.profile.showContinentMapNotes then
            
            if self.faction == "Horde" or db.activate.ContinentEnemyFaction then
              nodes[13][42787097] = { id = 238, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- The Stockade 
            end
          end

        --Eastern Kingdom noPassages

        if db.activate.noPassages then

          if self.db.profile.showContinentDungeons then
            nodes[13][53977927] = { id = 237, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- The Temple of Atal'hakkar 
            nodes[13][40808194] = { id = 63, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Deadmines
            nodes[13][42915972] = { id = 231, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Gnomeregan    
            --nodes[13][53646537] = { id = 239, name = "", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Uldaman (Secondary Entrance) 
            --nodes[13][54412915] = { id = 236, lfgid = 274, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false }-- Stratholme Service Entrance 
          end

          if self.db.profile.showContinentMultiple then
            nodes[13][47216795] = { mnID = 33, name = TOOLTIP_BATTLE_PET .. " " .. LFG_TYPE_DUNGEON, id = { 741, 742, 66, 228, 229, 559 }, type = "MultipleM", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Molten Core, Blackwing Lair, Blackrock Caverns, Blackrock Depths, Lower Blackrock Spire, Upper Blackrock Spire 
            nodes[13][46886972] = { mnID = 33, name = TOOLTIP_BATTLE_PET .. " " .. LFG_TYPE_DUNGEON, id = { 741, 742, 66, 228, 229, 559 }, type = "MultipleM", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Molten Core, Blackwing Lair, Blackrock Caverns, Blackrock Depths, Lower Blackrock Spire, Upper Blackrock Spire 
          end

        end

        --Eastern Kingdom Multiple
          if self.db.profile.showContinentMultiple then
            nodes[13][49428163] = { mnID = 42, id = { 745, 860 }, type = "MultipleM", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Karazhan, Return to Karazhan
            nodes[13][46583029] = { mnID = 19, id = { 311, 316 }, type = "MultipleD", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Scarlet Halls, Monastery 
            nodes[13][52176317] = { mnID = 15, id = { 1197, 239 }, type = "MultipleD", showOnContinent = true, showInZone = false, showOnMinimap = false } --  Legacy of Tyr Dragonflight Dungeon & Vanilla Uldaman 
          end
    
    
        --Eastern Kingdom Portals
          if self.db.profile.showContinentPortals then
    
            nodes[13][52448472] = { mnID = 17, name = "", type = "Portal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.DarkPortal .. "\n" .. "\n" .. FACTION_HORDE .. "\n" .. " ==> " .. ns.Warspear .. "\n" .. "\n" .. FACTION_ALLIANCE .. "\n" .. " ==> " .. ns.Stormshield } -- Portal from Tanaris to Orgrimmar 

            if self.faction == "Horde" or db.activate.ContinentEnemyFaction then
              nodes[13][49764414] = { mnID = 14, name = "", type = "HPortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. ns.Zandalar .. "\n" .. " " .. "(" .. L["This Arathi Highlands portal is only active if your faction is currently occupying Ar'gorok"] .. ")" } -- Portal from Arathi to Zandalar 
              nodes[13][33874948] = { mnID = 245, name = "", type = "HPortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.TolBarad .. " " .. L["Portal"] .. "\n" .. " ==> " .. ns.Orgrimmar } -- Portal Tol Barad to Orgrimmar
              nodes[13][60195610] = { mnID = 241, name = "", type = "HPortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.TwilightHighlands .. " " .. L["Portal"] .. "\n" .. " ==> " .. ns.Orgrimmar } -- Portal To Orgrimmar from Twilight Highlands  
              nodes[13][54128434] = { mnID = 17, name = "", type = "HPortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.BlastedLands .. " " .. L["Portal"] .. "\n" .. " ==> " .. ns.Orgrimmar } -- Portal To Orgrimmar from Blasted Lands
            end
    
            if self.faction == "Alliance" or db.activate.ContinentEnemyFaction then
              nodes[13][44357591] = { mnID = 37, name = FACTION_ALLIANCE .. " " .. L["Portal"] .. " ==> " .. CALENDAR_FILTER_DARKMOON, showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = "\n" .. REQUIRES_LABEL .. " " .. CALENDAR_FILTER_DARKMOON .. "\n" .. L["Starting on the first Sunday of each month for one week"], type = "DarkMoon" } -- Elwynn Forest Portal to the Darkmoon
              nodes[13][60805911] = { mnID = 241, name = "", type = "APortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.TwilightHighlands .. " " .. L["Portal"] .. "\n" .. " ==> " .. ns.Stormwind } -- Portal To Stormwind from Twilight Highlands  
              nodes[13][53428254] = { mnID = 17, name = "", type = "APortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.BlastedLands .. " " .. L["Portal"] .. "\n" .. " ==> " .. ns.Stormwind } -- Portal to Stormwind from Blasted Lands
              nodes[13][35134883] = { mnID = 245, name = "", type = "APortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.TolBarad .. " " .. L["Portal"] .. "\n" .. " ==> " .. ns.Stormwind } -- Portal Tol Barad to Stormwind
              nodes[13][49544708] = { mnID = 14, name = "", type = "APortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. ns.Boralus .. "\n" .. " " .. "(" .. L["This Arathi Highlands portal is only active if your faction is currently occupying Ar'gorok"] .. ")" } -- Portal from Arathi to Zandalar
            end
          end
    

        --Eastern Kingdom Portals without MapNotesIcons
        if self.db.profile.showContinentPortals and not self.db.profile.showContinentMapNotes then

          if self.faction == "Horde" or db.activate.ContinentEnemyFaction then
          nodes[13][43993336] = { mnID = 18, name = "", type = "HPortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.TirisfalGlades .. " " .. L["Portal"] .. "\n" .. " ==> " .. ns.Orgrimmar .. "\n" .. " ==> " .. ns.Gromgol .. "\n" .. " ==> " .. ns.HowlingFjord .. "\n" .. " ==> " .. ns.Silvermoon } -- Portal to Orgrimmar, Silvermoon, Howling Fjord and Grom'gol from Tirisfal
          nodes[13][55751269] = { mnID = 110, name = "", type = "HPortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.Silvermoon .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " ==> " .. ns.Orgrimmar .. "\n" .. " ==> " .. ns.RuinsofLordaeron } -- Portal to Orgrimmar, Ruins of Lordaeron from Silvermoon   
          end
        end


        -- Eastern Kingdom Zeppelins without MapNotesIcons
          if self.db.profile.showContinentZeppelins and not self.db.profile.showContinentMapNotes then

            if self.faction == "Horde" or db.activate.ContinentEnemyFaction then
              nodes[13][42728658] = { mnID = 50, name = "", type = "HZeppelin", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.Gromgol .. " " .. L["Zeppelin"] .. "\n" .. " ==> " .. ns.Orgrimmar } -- Zeppelin from Stranglethorn Valley to Ogrimmar
            end
          end


        -- Eastern Kingdom MapNotesIcons
          if self.db.profile.showContinentMapNotes then

            if self.faction == "Horde" or db.activate.ContinentEnemyFaction then
              nodes[13][43263464] = { mnID = 18, name = "", type = "HIcon", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.Undercity .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " ==> " .. ns.HellfirePeninsula .. "\n" .. "\n" .. ns.RuinsofLordaeron  .. " / " .. ns.TirisfalGlades .. "\n" .. "\n" .. L["Portals"] .. "\n" ..  " ==> " .. ns.Orgrimmar .. "\n" .. " ==> " .. ns.Gromgol .. "\n" .. " ==> " .. ns.HowlingFjord .. "\n" .. " ==> " .. ns.Silvermoon } -- Portal to Orgrimmar, Silvermoon, Howling Fjord and Grom'gol from Tirisfal
              nodes[13][56471480] = { mnID = 110, name = "", type = "HIcon", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.Silvermoon .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Portals"] .. "\n" ..  " ==> " .. ns.Orgrimmar .. "\n" .. " ==> " .. ns.RuinsofLordaeron } -- Portal to Orgrimmar, Ruins of Lordaeron from Silvermoon
              nodes[13][44168671] = { mnID = 50, name = "", type = "HIcon", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.Gromgol .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Zeppelin"] .. "\n" .. " ==> " .. ns.Orgrimmar .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " ==> " .. ns.RuinsofLordaeron } -- Transport from Stranglethorn Valley to Ogrimmar and Ruins of Lordaeron
            end

            if self.faction == "Alliance" or db.activate.ContinentEnemyFaction then
              nodes[13][47275888] = { mnID = 87, name = "", type = "AIcon", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.Ironforge .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. DUNGEON_FLOOR_DEEPRUNTRAM1 .. "\n" .. " ==> " .. ns.Stormwind } -- Transport to Ironforge Carriage 
              nodes[13][42817313] = { mnID = 84, name = "", type = "AIcon", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.Stormwind .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Portalroom"] .. "\n" .. " ==> " .. ns.Ashran .. "\n" .. " ==> " .. ns.Valdrakken .. "\n" .. " ==> " .. ns.Boralus .. "\n" .. " ==> " .. ns.Oribos .. "\n" .. " ==> " .. ns.Azsuna .. "\n" .. " ==> " .. ns.Shattrath .. "\n" .. " ==> " .. ns.JadeForest .. "\n" .. " ==> " .. ns.Dalaran .. "\n" .. " ==> " .. ns.CavernsOfTime .. "\n" .. " ==> " .. ns.Exodar .. "\n" ..  " ==> " .. ns.Amirdrassil .. "\n" .. " ==> " .. ns.DarkPortal .. "\n" .. " ==> " .. ns.Dornogal .. "\n" .. "\n" .. L["Portals"] .. "\n" ..  "\n" .. " ==> " .. ns.Uldum .. "\n" .. " ==> " .. ns.Vashjir .. "\n" .. " ==> " .. ns.Hyjal .. "\n" .. " ==> " .. ARTIFACT_SHAMAN_TITLECARD_DEEPHOLM .. "\n" .. " ==> " .. ns.TwilightHighlands .. "\n" .. " ==> " .. ns.TolBarad .. "\n" .. "\n" .. L["Ships"] .. "\n" .. " ==> " .. POSTMASTER_LETTER_VALIANCEKEEP .. "\n" .. " ==> " .. ns.Boralus .. "\n" .. " ==> " .. ns.TheWakingShores .. "\n" .. "\n" .. DUNGEON_FLOOR_DEEPRUNTRAM1 .. "\n" .. " ==> " .. ns.Ironforge .. "\n" .. "\n" .. " ==> " .. CALENDAR_TYPE_DUNGEON .. "\n" .. " ==> " .. DUNGEON_FLOOR_THESTOCKADE1 } -- Portalroom from Stormwind
            end
          end
    

        --Eastern Kingdom Ships
          if self.db.profile.showContinentShips then
            nodes[13][41115043] = { mnID = 217, name = "", type = "Ship", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.RuinsofGilneas .. " " .. L["Ship"] .. "\n" .. " ==> " .. ns.Amirdrassil } -- Ship from Gilneas to Bel ameth
            nodes[13][42379354] = { mnID = 210, name = "", type = "Ship", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = POSTMASTER_LETTER_STRANGLETHORNVALE .. " " .. L["Ship"] .. "\n" .. " ==> " .. ns.Ratchet } -- Ship from Booty Bay to Ratchet
            
            if self.faction == "Alliance" or db.activate.ContinentEnemyFaction then
              nodes[13][46665454] = { mnID = 56, name = "", type = "AShip", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = POSTMASTER_LETTER_WETLANDS .." " .. L["Ships"] .. "\n" .. " ==> " .. ns.TheramoreIsle .. "\n" .. " ==> " .. ns.HowlingFjord } -- Ship from Stormwind to Borean Tundra
            end
          end
    

        -- Eastern Kingdom Ships without MapNotesIcons
          if self.db.profile.showContinentShips and not self.db.profile.showContinentMapNotes then
          
            if self.faction == "Alliance" or db.activate.ContinentEnemyFaction then
              nodes[13][40967129] = { mnID = 84, name = "", type = "AShip", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Ship"] .. "\n" .. " " .. ns.Stormwind .. " ==> " .. POSTMASTER_LETTER_VALIANCEKEEP } -- Ship from Stormwind to Valiance Keep
              nodes[13][41187327] = { mnID = 84, name = "", type = "AShip", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Ship"] .. "\n" .. " " .. ns.Stormwind .. " ==> " .. ns.Boralus } -- Ship from Stormwind to Valiance Keep
            end
          end


        --Eastern Kingdom Zeppelins
          if self.db.profile.showContinentZeppelins then

            if self.faction == "Horde" or db.activate.ContinentEnemyFaction then
              --nodes[13][43968695] = { mnID = 50, name = "", type = "HZeppelin", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Zeppelin"] .. " ==> " .. ns.Orgrimmar } -- Zeppelin from Stranglethorn Valley to Ogrimmar
            end

          end

        -- Eastern Kingdom Transport and not MapNotesIcons
          if self.db.profile.showContinentTransport and not self.db.profile.showContinentMapNotes then

            nodes[13][47275888] = { mnID = 87, name = "", type = "Carriage", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = DUNGEON_FLOOR_DEEPRUNTRAM1 .. " ==> " .. ns.Ironforge } -- Transport to Ironforge Carriage 
          end
    
        --Eastern Kingdom ContinentOldVanilla
          if self.db.profile.showContinentOldVanilla then
            nodes[13][54113049] = { mnID = 166, name = L["Secret Entrance"] .. " " .. L["(Wards of the Dread Citadel - Achievement)"] .. " - " .. L["Old Version"], type = "VInstanceR", showOnContinent = true, showInZone = false, showOnMinimap = false }-- Old Naxxramas version - Secret Entrance - Wards of the Dread Citadel 
            nodes[13][46703243] = { mnID = 19, name = L["Use the Old Keyring"], dnID = L["Graveyard"] .. " - " .. L["Old Version"] .. "\n" .. L["Cathedral"] .. " - " .. L["Old Version"] .. "\n" .. L["Library"] .. " - " .. L["Old Version"] .. "\n" .. L["Armory"] .. " - " .. L["Old Version"], type = "MultiVInstanceD", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Scarlet Monastery Key for Old dungeons
            nodes[13][51383556] = { mnID = 306, name = L["Secret Entrance"] .. " " .. L["(Memory of Scholomance - Achievement)"] .. " - " .. L["Old Version"], type = "VInstanceD", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Old Scholomance version - Memory of Scholomance - Secret Entrance Old Scholomance version 
          end

        -- Eastern Kingdom PvpandPveVendor
          if self.db.profile.showContinentPvPandPvEVendor then
            
            if self.faction == "Horde" or db.activate.ContinentEnemyFaction then
              nodes[13][53144389] = { name = "", dnID = TRANSMOG_SET_PVP .. " " .. MERCHANT .. " " .. FACTION_HORDE .. "\n" .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. "\n" .. AUCTION_CATEGORY_WEAPONS, mnID = 14, type = "ContinentPvPVendorH", hideTTmnID = true, showOnContinent = true, showInZone = false, showOnMinimap = false }
              nodes[13][47043956] = { name = "", dnID = TRANSMOG_SET_PVP .. " " .. MERCHANT .. " " .. FACTION_HORDE .. "\n" .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. "\n" .. AUCTION_CATEGORY_WEAPONS, mnID = 25, type = "ContinentPvPVendorH", hideTTmnID = true, showOnContinent = true, showInZone = false, showOnMinimap = false }
            end
            
            if self.faction == "Alliance" or db.activate.ContinentEnemyFaction then
              nodes[13][50474530] = { name = "", dnID = TRANSMOG_SET_PVP .. " " .. MERCHANT .. " " .. FACTION_ALLIANCE .. "\n" .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. "\n" .. AUCTION_CATEGORY_WEAPONS, mnID = 14, type = "ContinentPvPVendorA", hideTTmnID = true, showOnContinent = true, showInZone = false, showOnMinimap = false }
              nodes[13][45364099] = { name = "", dnID = TRANSMOG_SET_PVP .. " " .. MERCHANT .. " " .. FACTION_ALLIANCE .. "\n" .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. "\n" .. AUCTION_CATEGORY_WEAPONS, mnID = 25, type = "ContinentPvPVendorA", hideTTmnID = true, showOnContinent = true, showInZone = false, showOnMinimap = false }
            end

          end
        end
    
    
        --############################
        --##### Continent Outland ####
        --############################
    
        if self.db.profile.showContinentOutland then
    
        -- Outland Dungeons
          if self.db.profile.showContinentDungeons then
            nodes[101][44487857] = { id = 247, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Auchenai Crypts 
            nodes[101][46027626] = { id = 250, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Mana-Tombs 
            nodes[101][47577861] = { id = 252, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Sethekk Halls 
            nodes[101][46028099] = { id = 253, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Shadow Labyrinth 
            nodes[101][65842044] = { id = 257, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- The Botanica 
            nodes[101][65542528] = { id = 258, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- The Mechanar  
            nodes[101][66722143] = { id = 254, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- The Arcatraz
          end
    
    
        -- Outland Raids
          if self.db.profile.showContinentRaids then
            nodes[101][66452335] = { id = 749, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- The Eye  
            nodes[101][72298069] = { id = 751, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Black Temple 
            nodes[101][45131901] = { id = 746, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Gruul's Lairend
          end
    
    
        -- Outland Multiple
          if self.db.profile.showContinentMultiple then
            nodes[101][56695240] = { mnID = 100, id = { 747, 248, 256, 259 }, type = "MultipleM", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Hellfire Ramparts, The Blood Furnace, The Shattered Halls, Magtheridon's Lair 
            nodes[101][34624490] = { mnID = 102, id = { 748, 260, 261, 262 }, type = "MultipleM", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Slave Pens, The Steamvault, The Underbog, Serpentshrine Cavern
          end
    
    
        -- Outland Portals
          if self.db.profile.showContinentPortals then
                        
            if self.faction == "Horde" or db.activate.ContinentEnemyFaction then
              nodes[101][69025178] = { mnID = 100, name = "", type = "HPortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.HellfirePeninsula .. " " .. L["Portal"] .. "\n" .. " ==> " .. ns.Orgrimmar } -- Portal from Hellfire to Orgrimmar 

            end
    
            if self.faction == "Alliance" or db.activate.ContinentEnemyFaction then
              nodes[101][68905259] = { mnID = 100,  name = "" , type = "APortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.HellfirePeninsula .. " " .. L["Portal"] .. "\n" .. " ==> " .. ns.Stormwind } -- Portal from Hellfire to Stormwind 
            end
          end


        -- Outland Portals
          if self.db.profile.showContinentPortals and not self.db.profile.showContinentMapNotes then
            nodes[101][43186574] = { mnID = 108, name = "", type = "Portal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.Shattrath .. " " .. L["Portals"] .. "\n" ..  "\n" .. " ==> " .. ns.Orgrimmar .. "\n" .. " ==> " .. ns.Stormwind .. "\n" .. " ==> " .. ns.IsleOfQuelDanas } -- Portal from Shattrath to Orgrimmar
          end

        -- Outland MapNotesIcons 
          if self.db.profile.showContinentMapNotes then
            nodes[101][43186573] = { mnID = 108, name = "", type = "MNL", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.Shattrath .. "\n" .. "\n" .. L["Portals"] .. "\n" .. " ==> " .. ns.Orgrimmar .. "\n" .. " ==> " .. ns.Stormwind .. "\n" .. " ==> " .. ns.IsleOfQuelDanas } -- Portal from Shattrath to Orgrimmar
          end

        -- Outland PvpandPveVendor
          if self.db.profile.showContinentPvPandPvEVendor then
            nodes[101][53442348] = { name = "", dnID = TRANSMOG_SET_PVP .. " " .. MERCHANT .. "\n" .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. "\n" .. AUCTION_CATEGORY_WEAPONS, mnID = 109, type = "PvPVendor", hideTTmnID = true, showOnContinent = true, showInZone = false, showOnMinimap = false }
          end

        -- Outland RenownQuartermaster
          if self.db.profile.showContinentRenownQuartermaster then
            nodes[101][56751336] = { npcID = 20242, mnID = 109, name = "", type = "RenownQuartermaster", hideTTmnID = true, showOnContinent = true, showInZone = false, showOnMinimap = false }
            nodes[101][32582984] = { npcID = 23428, mnID = 105, name = "", type = "RenownQuartermaster", hideTTmnID = true, showOnContinent = true, showInZone = false, showOnMinimap = false }
            nodes[101][42785103] = { npcID = 17904, mnID = 102, name = "", type = "RenownQuartermaster", hideTTmnID = true, showOnContinent = true, showInZone = false, showOnMinimap = false }
            nodes[101][53617857] = { npcID = 23367, mnID = 108, name = "", type = "RenownQuartermaster", hideTTmnID = true, showOnContinent = true, showInZone = false, showOnMinimap = false }
            nodes[101][41246456] = { npcIDs1 = 19321, npcIDs2 = 21432, npcIDs3 = 19331, mnID = 111, name = "", type = "RenownQuartermaster", hideTTmnID = true, showOnContinent = true, showInZone = false, showOnMinimap = false }

            if self.faction == "Horde" or db.activate.ContinentEnemyFaction then
              nodes[101][58894830] = { npcID = 17585, mnID = 100, name = "", type = "ContinentRenownQuartermasterH", hideTTmnID = true, showOnContinent = true, showInZone = false, showOnMinimap = false }
              nodes[101][32116091] = { npcID = 20241, mnID = 107, name = "", type = "ContinentRenownQuartermasterH", hideTTmnID = true, showOnContinent = true, showInZone = false, showOnMinimap = false }
            end

            if self.faction == "Alliance" or db.activate.ContinentEnemyFaction then
              nodes[101][59455568] = { npcID = 17657, mnID = 100, name = "", type = "ContinentRenownQuartermasterA", hideTTmnID = true, showOnContinent = true, showInZone = false, showOnMinimap = false }
              nodes[101][32707332] = { npcID = 20240, mnID = 107, name = "", type = "ContinentRenownQuartermasterA", hideTTmnID = true, showOnContinent = true, showInZone = false, showOnMinimap = false }
            end

          end

        end
    
    
        --##############################
        --##### Continent Northrend ####
        --##############################
    
        if self.db.profile.showContinentNorthrend then
    
          -- Northrend Dungeon
          if self.db.profile.showContinentDungeons then
            nodes[113][77707945] = { id = 285, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Utgarde Keep, at doorway entrance 
            nodes[113][77557824] = { id = 286, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Utgarde Pinnacle 
            nodes[113][59091507] = { id = 275, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Halls of Lightning 
            nodes[113][56911729] = { id = 277, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Halls of Stone 
            nodes[113][62405001] = { id = 273, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Drak'Tharon Keep 
            nodes[113][75113259] = { id = 274, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Gundrak Left Entrance 
            nodes[113][76533471] = { id = 274, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Gundrak Right Entrance 
            nodes[113][49134292] = { id = 283, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Violet Hold
          end
    
          -- Northrend Raids
          if self.db.profile.showContinentRaids then
            nodes[113][58415888] = { id = 754, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Naxxramas 
            nodes[113][40794199] = { id = 758, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Icecrown Citadel 
            nodes[113][57721389] = { id = 759, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Ulduar
            nodes[113][36624457] = { id = 753, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Vault of Archavon
          end
    
    
        -- Northrend Multiple
          if self.db.profile.showContinentMultiple then
            nodes[113][40595892] = { mnID = 115, id = { 271, 272 }, type = "MultipleD", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Ahn'kahet The Old Kingdom, Azjol-Nerub        
            nodes[113][41154408] = { mnID = 118, id = { 276, 278, 280 }, type = "MultipleD", showOnContinent = true, showInZone = false, showOnMinimap = false } -- The Forge of Souls, Halls of Reflection, Pit of Saron         
            nodes[113][47652029] = { mnID = 118, id = { 757, 284 }, type = "MultipleM", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Trial of the Crusader, Trial of the Champion 
            nodes[113][14725757] = { mnID = 114, id = { 756, 282, 281 }, type = "MultipleM", showOnContinent = true, showInZone = false, showOnMinimap = false } -- The Eye of Eternity, The Nexus, The Oculus
            nodes[113][50346038] = { mnID = 115, id = { 755, 761 }, type = "MultipleR", showOnContinent = true, showInZone = false, showOnMinimap = false } -- The Ruby Sanctum, The Obsidian Sanctum 
          end
    
    
        -- Northrend Portal
          if self.db.profile.showContinentPortals then
            nodes[113][36504679] = { mnID = 123, name = "", type = "Portal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.Wintergrasp .. " " .. L["Portal"] .. "\n" .. " ==> " .. ns.Dalaran } -- LakeWintergrasp to Dalaran Portal
            nodes[113][47804060] = { mnID = 125, name = "", type = "Portal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.Dalaran .. " " .. L["Portals"] .. "\n" ..  "\n" .. " ==> " .. ns.Orgrimmar .. "\n" .. " ==> " .. ns.Stormwind } --  Dalaran Portal to Orgrimmar and Stormwind
            nodes[113][24264914] = { mnID = 119, name = "", type = "Portal", showOnContinent = true, showInZone = false, showOnMinimap = false,TransportName = ns.SholazarBasin .. " " .. L["Portal"] .. "\n" .. " ==> " .. ns.UnGoroCrater } --  Portal to Unguro
          end
    
    
        -- Northrend Zeppelin
          if self.db.profile.showContinentZeppelins then 
    
            if self.faction == "Horde" or db.activate.ContinentEnemyFaction then
              nodes[113][18766562] = { mnID = 114, name = "", type = "HZeppelin", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = POSTMASTER_LETTER_WARSONGHOLD .. " " .. L["Zeppelin"] .. " ==> " .. ns.Orgrimmar } -- Zeppelin from Borean Tundra to Ogrimmar
            end
          end
    
    
        -- Northrend Ships
          if self.db.profile.showContinentShips then
            nodes[113][65218245] = { mnID = 117, name = "", type = "Ship", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = POSTMASTER_LETTER_KAMAGUA .. " " .. L["Ship"] .. "\n" .. " ==> " .. POSTMASTER_LETTER_MOAKI } -- Ship from Kamagua to Moaki
            nodes[113][47806841] = { mnID = 115, name = "", type = "Ship", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = POSTMASTER_LETTER_MOAKI .. " " .. L["Ship"] .. "\n" .. " ==> " .. POSTMASTER_LETTER_KAMAGUA } -- Ship from Moaki to Kamagua
            nodes[113][30056677] = { mnID = 114, name = "", type = "Ship", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.BoreanTundra .. " " .. L["Ship"] .. "\n" .. " ==> " .. POSTMASTER_LETTER_MOAKI } -- Ship from Unu'pe to Moaki
            nodes[113][46406841] = { mnID = 115, name = "", type = "Ship", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = POSTMASTER_LETTER_MOAKI .. " " .. L["Ship"] .. "\n" .. " ==> " .. ns.BoreanTundra } -- Ship from Moaki to Unu'pe

            if self.faction == "Alliance" or db.activate.ContinentEnemyFaction then
              nodes[113][25377045] = { mnID = 114, name = "", type = "AShip", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = POSTMASTER_LETTER_VALIANCEKEEP .. " " ..  L["Ship"] .. "\n" .. " ==> " .. ns.Stormwind } -- Ship from Borean Tundra to Stormwind
              nodes[113][79788368] = { mnID = 117, name = "", type = "AShip", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.HowlingFjord .. " " .. L["Ship"] .. "\n" .. " ==> " .. POSTMASTER_LETTER_WETLANDS } -- Ship from Howling Fjord to Wetlands
            end
          end

        -- Northrend PvpandPveVendor
          if self.db.profile.showContinentPvPandPvEVendor then
            --nodes[113][41133952] = { name = "", dnID = TRANSMOG_SET_PVE .. " " .. MERCHANT, mnID = 118, type = "PvEVendor", showOnContinent = true, showInZone = false, showOnMinimap = false }
            
            if self.faction == "Horde" then
                nodes[113][49032027] = { npcIDs1 = 35574, npcIDs2 = 35576, npcIDs3 = 35578, npcIDs4 = 35580, name = TRANSMOG_SET_PVE .. " " .. MERCHANT, mnID = 118, type = "ContinentPvEVendorH", hideTTmnID = true, showOnContinent = true, showInZone = false, showOnMinimap = false }
            end
            
            if self.faction == "Alliance" then
                nodes[118][49032027] = { npcIDs1 = 35573, npcIDs2 = 35575, npcIDs3 = 35577, npcIDs4 = 35579, name = TRANSMOG_SET_PVE .. " " .. MERCHANT, mnID = 118, type = "ContinentPvEVendorA", hideTTmnID = true, showOnContinent = true, showInZone = false, showOnMinimap = false }
            end
            
          end

        -- Northrend RenownQuartermaster
          if self.db.profile.showContinentRenownQuartermaster then
            nodes[113][37041885] = { npcID = 32538, mnID = 118, name = "", type = "RenownQuartermaster", hideTTmnID = true, showOnContinent = true, showInZone = false, showOnMinimap = false }
            nodes[113][45602042] = { npcIDs1 = 173791, npcIDs2 = 34885, mnID = 118, name = "", type = "RenownQuartermaster", hideTTmnID = true, showOnContinent = true, showInZone = false, showOnMinimap = false }
            nodes[113][66953007] = { npcID = 32540, mnID = 120, name = "", type = "RenownQuartermaster", hideTTmnID = true, showOnContinent = true, showInZone = false, showOnMinimap = false }
            nodes[113][66298110] = { npcID = 31916, mnID = 117, name = "", type = "RenownQuartermaster", hideTTmnID = true, showOnContinent = true, showInZone = false, showOnMinimap = false }
            nodes[113][50335869] = { npcID = 32533, mnID = 115, name = "", type = "RenownQuartermaster", hideTTmnID = true, showOnContinent = true, showInZone = false, showOnMinimap = false }
            nodes[113][46096700] = { npcID = 32763, mnID = 115, name = "", type = "RenownQuartermaster", hideTTmnID = true, showOnContinent = true, showInZone = false, showOnMinimap = false }
            
            if self.faction == "Horde" or db.activate.ContinentEnemyFaction then
                nodes[113][19676549] = { npcID = 32565, mnID = 114, name = "", type = "ContinentRenownQuartermasterH", hideTTmnID = true, showOnContinent = true, showInZone = false, showOnMinimap = false }
            end

            if self.faction == "Alliance" or db.activate.ContinentEnemyFaction then
                nodes[113][23946927] = { npcID = 32564, mnID = 114, name = "", type = "ContinentRenownQuartermasterA", hideTTmnID = true, showOnContinent = true, showInZone = false, showOnMinimap = false }
            end
          end

        end
    
    
        --#############################
        --##### Continent Pandaria ####
        --#############################
    
        if self.db.profile.showContinentPandaria then
    
        -- Pandaria Dungeons
          if self.db.profile.showContinentDungeons then
            nodes[424][72275515] = { id = 313, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Temple of the Jade Serpent 
            nodes[424][48117132] = { id = 302, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Stormstout Brewery
            nodes[424][40002920] = { id = 312, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Shado-Pan Monastery
            nodes[424][23575057] = { id = 324, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Siege of Niuzao Temple 
            nodes[424][42975779] = { id = 303, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Gate of the Setting Sun 
            nodes[424][53745257] = { id = 321, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Mogu'shan Palace (moved location cause of the LFR position)
          end
    
    
        -- Pandaria Raids
          if self.db.profile.showContinentRaids then
            nodes[424][49152606] = { id = 317, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Mogu'shan Vaults 
            nodes[424][52355265] = { id = 369, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Siege of Orgrimmar 
            nodes[424][30076296] = { id = 330, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Heart of Fear 
            nodes[424][23100860] = { id = 362, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Throne of Thunder
            nodes[424][56685529] = { id = 320, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Terrace of Endless Spring  
            nodes[424][47015340] = { id = 1180, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false, dnID = L["Instance Entrance"] .. " " .. L["switches weekly between"] .. " " .. ns.Uldum .. " (" .. ns.Kalimdor ..")" .. " & " .. ns.ValeOfEternalBlossoms .. " (" .. ns.Pandaria .. ")" } -- Ny'Alotha, The Waking City
          end
    
    
        -- Pandaria Portals
          if self.db.profile.showContinentPortals then
    
            if self.faction == "Horde" or db.activate.ContinentEnemyFaction then
              nodes[424][59733518] = { mnID = 371, name = "", type = "HPortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.JadeForest .. " " .. L["Portal"] .. "\n" .. " ==> " .. ns.Orgrimmar } -- Portal from Jade Forest to Orgrimmar
              nodes[424][17970919] = { mnID = 504, name = "", type = "HPortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.IsleOfThunder .. " " .. L["Portals"] .. "\n" ..  "\n" .. " ==> " .. ns.ShadoPanGarison } -- Portal from Isle of Thunder to Shado-Pan Garrison
              nodes[424][29444738] = { mnID = 388, name = "", type = "HPortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.ShadoPanGarison .. " " .. L["Portal"] .. "\n" .. " ==> " .. ns.IsleOfThunder } -- Portal from Shado-Pan Garrison to Isle of Thunder
              nodes[424][50604810] = { mnID = 392, name = "", type = "HPortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.Shrine2Moons .. " " .. L["Portal"] .. "\n" ..  "\n" .. " ==> " .. ns.Orgrimmar } -- Portal from Vale of Eternal Blossoms to Orgrimmar
              nodes[424][40508161] = { mnID = 418, name = "", type = "HPortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.KrasarangWilds .. " " .. L["Portal"] .. "\n" ..  "\n" .. " ==> " .. ns.Silvermoon } -- Portal to Silvermoon
            end

            if self.faction == "Alliance" or db.activate.ContinentEnemyFaction then
              nodes[424][67806740] = { mnID = 371, name = "", type = "APortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.JadeForest .. " " .. L["Portals"] .. "\n" ..  "\n" .. " ==> " .. ns.Stormwind } -- Portal from Jade Forest to Stormwind
              nodes[424][23891588] = { mnID = 504, name = "", type = "APortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.IsleOfThunder .. " " .. L["Portals"] .. "\n" ..  "\n" .. " ==> " .. ns.ShadoPanGarison } -- Portal from Isle of Thunder to Shado-Pan Garrison
              nodes[424][28894622] = { mnID = 388, name = "", type = "APortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.ShadoPanGarison .. " " .. L["Portal"] .. "\n" .. " ==> " .. ns.IsleOfThunder } -- Portal from Shado-Pan Garrison to Isle of Thunder
              nodes[424][54785688] = { mnID = 394, name = "", type = "APortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.Shrine7Stars .. " " .. L["Portal"] .. "\n" ..  "\n" .. " ==> " .. ns.Stormwind } -- Portal from Vale of Eternal Blossoms to Stormwind
            end
          end


        -- Pandaria LFR
          if self.db.profile.showContinentLFR then
            nodes[424][53805057] = { mnID = 390, id = { 317, 330, 362, 320 }, name = ns.LorewalkerHan .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " ", showOnContinent = true, showInZone = false, showOnMinimap = false , type = "LFR"}
          end

        -- Pandaria PvpandPveVendor
          if self.db.profile.showContinentPvPandPvEVendor then
            nodes[424][24574389] = { name = "", dnID = TRANSMOG_SET_PVE .. " " .. MERCHANT .. "\n" .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. "\n" .. AUCTION_CATEGORY_WEAPONS, mnID = 388, type = "PvEVendor", hideTTmnID = true, showOnContinent = true, showInZone = false, showOnMinimap = false }
          
            if self.faction == "Horde" or db.activate.ContinentEnemyFaction then
              nodes[424][39394352] = { name = "", dnID = TRANSMOG_SET_PVP .. " " .. MERCHANT .. " " .. FACTION_HORDE .. "\n" .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. "\n" .. AUCTION_CATEGORY_WEAPONS, mnID = 379, type = "ContinentPvPVendorH", hideTTmnID = true, showOnContinent = true, showInZone = false, showOnMinimap = false }
            end

            if self.faction == "Alliance" or db.activate.ContinentEnemyFaction then
              nodes[424][42126238] = { name = "", dnID = TRANSMOG_SET_PVP .. " " .. MERCHANT .. " " .. FACTION_ALLIANCE .. "\n" .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. "\n" .. AUCTION_CATEGORY_WEAPONS, mnID = 376, type = "ContinentPvPVendorA", hideTTmnID = true, showOnContinent = true, showInZone = false, showOnMinimap = false }
            end
          end

          -- Pandaria Professions
          if self.db.profile.showContinentProfessions then

            nodes[424][71664914] = { name = INSCRIPTION, type = "Inscription", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            nodes[424][58007834] = { name = PROFESSIONS_FISHING, type = "Fishing", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            nodes[424][43257450] = { name = L["Engineer"], type = "Engineer", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            nodes[424][54966877] = { name = L["Tailoring"], type = "Tailoring", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            nodes[424][45135809] = { name = L["Blacksmithing"], type = "Blacksmith", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            nodes[424][51263464] = { name = L["Leatherworking"], type = "Leatherworking", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            nodes[424][35726249] = { name = L["Alchemy"], type = "Alchemy", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            nodes[424][42067423] = { name = L["Skinning"], type = "Skinning", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            nodes[424][67784226] = { name = L["Mining"], type = "Mining", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            nodes[424][52294943] = { dnID = FACTION_NEUTRAL .. " " .. MINIMAP_TRACKING_TRAINER_PROFESSION .. "\n" .. "\n" .. TextIconArchaeology:GetIconString() .. " " .. PROFESSIONS_ARCHAEOLOGY .. "\n" .. TextIconInscription:GetIconString() .. " " .. INSCRIPTION, name = "", type = "ProfessionsMixed", showOnContinent = true, showInZone = false, showOnMinimap = false }
            nodes[424][68524460] = { dnID = FACTION_NEUTRAL .. " " .. MINIMAP_TRACKING_TRAINER_PROFESSION .. "\n" .. "\n" .. TextIconInscription:GetIconString() .. " " .. INSCRIPTION .. "\n" .. TextIconJewelcrafting:GetIconString() .. " " .. L["Jewelcrafting"] .. "\n" .. TextIconBlacksmith:GetIconString() .. " " .. L["Blacksmithing"], name = "", type = "ProfessionsMixed", showOnContinent = true, showInZone = false, showOnMinimap = false }
            --nodes[424][45602694] = { dnID = FACTION_NEUTRAL .. " " .. MINIMAP_TRACKING_TRAINER_PROFESSION .. "\n" .. "\n" .. TextIconInscription:GetIconString() .. " " .. INSCRIPTION .. "\n" .. TextIconHerbalism:GetIconString() .. " " .. L["Herbalism"] .. "\n" .. TextIconLeatherworking:GetIconString() .. " " .. L["Leatherworking"] .. "\n" .. TextIconCooking:GetIconString() .. " " .. PROFESSIONS_COOKING .. "\n" .. TextIconFishing:GetIconString() .. " " .. PROFESSIONS_FISHING .. "\n" .. TextIconMining:GetIconString() .. " " .. L["Mining"] .. "\n" .. TextIconBlacksmith:GetIconString() .. " " .. L["Blacksmithing"], name = "", type = "ProfessionsMixed", showOnContinent = true, showInZone = false, showOnMinimap = false }
            nodes[424][52496674] = { dnID = FACTION_NEUTRAL .. " " .. MINIMAP_TRACKING_TRAINER_PROFESSION .. "\n" .. "\n" .. TextIconHerbalism:GetIconString() .. " " .. L["Herbalism"] .. "\n" .. TextIconCooking:GetIconString() .. " " .. PROFESSIONS_COOKING .. "\n" .. TextIconFishing:GetIconString() .. " " .. PROFESSIONS_FISHING, name = "", type = "ProfessionsMixed", showOnContinent = true, showInZone = false, showOnMinimap = false }
            nodes[424][67524880] = { dnID = FACTION_NEUTRAL .. " " .. MINIMAP_TRACKING_TRAINER_PROFESSION .. "\n" .. "\n" .. TextIconEnchanting:GetIconString() .. " " .. L["Enchanting"] .. "\n" .. TextIconCooking:GetIconString() .. " " .. PROFESSIONS_COOKING, name = "", type = "ProfessionsMixed", showOnContinent = true, showInZone = false, showOnMinimap = false }
            
            if self.faction == "Horde" or db.activate.ContinentEnemyFaction then
              nodes[424][59123739] = { dnID = ITEM_REQ_HORDE .. "\n" .. "\n" .. TextIconHerbalism:GetIconString() .. " " .. L["Herbalism"] .. "\n" .. TextIconMining:GetIconString() .. " " .. L["Mining"] .. "\n" .. TextIconSkinning:GetIconString() .. " " .. L["Skinning"], name = "", type = "ProfessionsMixed", showOnContinent = true, showInZone = false, showOnMinimap = false }
              nodes[424][54715128] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
              nodes[424][19240970] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            end

            if self.faction == "Alliance" or db.activate.ContinentEnemyFaction then
              nodes[424][66766846] = { dnID = ITEM_REQ_ALLIANCE .. "\n" .. "\n" .. TextIconHerbalism:GetIconString() .. " " .. L["Herbalism"] .. "\n" .. TextIconMining:GetIconString() .. " " .. L["Mining"] .. "\n" .. TextIconSkinning:GetIconString() .. " " .. L["Skinning"], name = "", type = "ProfessionsMixed", showOnContinent = true, showInZone = false, showOnMinimap = false }
            end

          end

        end
    
    
        --############################
        --##### Continent Draenor ####
        --############################
    
        if self.db.profile.showContinentDraenor then
    
    
        -- Draenor Dungeons
          if self.db.profile.showContinentDungeons then
            nodes[572][34102566] = { id = 385, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Bloodmaul Slag Mines
            nodes[572][51322183] = { id = 536, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Grimrail Depot
            nodes[572][52932678] = { id = 556, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- The Everbloom
            nodes[572][47961477] = { id = 558, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Iron Docks
            nodes[572][53196866] = { id = 537, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Shadowmoon Burial Grounds
            nodes[572][42607342] = { id = 476, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Skyreach
            nodes[572][40256374] = { id = 547, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Auchindoun
          end
    
    
        --Draenor Raids
          if self.db.profile.showContinentRaids then
            nodes[572][56854685] = { id = 669, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Hellfire Citadel
            nodes[572][49992014] = { id = 457, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Blackrock Foundry
            nodes[572][21125032] = { id = 477, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Highmaul
          end
    
    
        --Draenor Garrison Transport
          if self.db.profile.showContinentTransport then
    
            if self.faction == "Horde" then
              nodes[572][52442304] = { mnID = 590, name = L["Ogre Waygate to Garrison"], type = "OgreWaygate", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Ogre Waygate Gorgrond
              nodes[572][36803224] = { mnID = 590, name = L["Ogre Waygate to Garrison"], type = "OgreWaygate", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Ogre Waygate FrostfireRidge
              nodes[572][20835300] = { mnID = 590, name = L["Ogre Waygate to Garrison"], type = "OgreWaygate", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Ogre Waygate Nagrand
              nodes[572][42665730] = { mnID = 590, name = L["Ogre Waygate to Garrison"], type = "OgreWaygate", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Ogre Waygate Talador
              nodes[572][47817859] = { mnID = 590, name = L["Ogre Waygate to Garrison"], type = "OgreWaygate", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Ogre Waygate SpiresOfArak
              nodes[572][58706681] = { mnID = 590, name = L["Ogre Waygate to Garrison"], type = "OgreWaygate", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Ogre Waygate Shadowmoon Valley
            end
    
            if self.faction == "Alliance" then
              nodes[572][52442304] = { mnID = 582, name = L["Ogre Waygate to Garrison"], type = "OgreWaygate", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Ogre Waygate Gorgrond
              nodes[572][36803224] = { mnID = 582, name = L["Ogre Waygate to Garrison"], type = "OgreWaygate", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Ogre Waygate FrostfireRidge
              nodes[572][20835300] = { mnID = 582, name = L["Ogre Waygate to Garrison"], type = "OgreWaygate", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Ogre Waygate Nagrand
              nodes[572][42665730] = { mnID = 582, name = L["Ogre Waygate to Garrison"], type = "OgreWaygate", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Ogre Waygate Talador
              nodes[572][47817859] = { mnID = 582, name = L["Ogre Waygate to Garrison"], type = "OgreWaygate", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Ogre Waygate SpiresOfArak
              nodes[572][58706681] = { mnID = 582, name = L["Ogre Waygate to Garrison"], type = "OgreWaygate", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Ogre Waygate Shadowmoon Valley
              end
          end
    
    
        --Draenor Portals
          if self.db.profile.showContinentPortals then
    
            if self.faction == "Horde" or db.activate.ContinentEnemyFaction then
              nodes[572][71343912] = { mnID = 624, name = "", type = "HPortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.Ashran .. " " .. L["Portal"] .. "\n" .. " ==> " .. ns.Orgrimmar .. "\n" .. " ==> " .. ns.Volmar } -- Portal from Ashran to Orgrimmar
              nodes[572][60424574] = { mnID = 534, name = "", type = "HPortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.Volmar .. " " .. L["Portal"] .. "\n" .. " ==> " .. ns.Ashran } -- Portal from Vol'mar to Ashran
              nodes[572][34663659] = { mnID = 590, name = "", type = "HPortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = GARRISON_LOCATION_TOOLTIP .. " " .. L["Portal"] .. "\n" .. " ==> " .. ns.Ashran } -- Portal from Garrison to Ashran
            end
    
            if self.faction == "Alliance" or db.activate.ContinentEnemyFaction then
              nodes[572][59544876] = { mnID = 534, name = "", type = "APortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. ns.Ashran } -- Portal from Lion's Watch to (Ashran Zone)
              nodes[572][71674912] = { mnID = 622,  name = "" , type = "APortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName =  ns.Ashran .. " " .. L["Portal"] .. "\n" .. " ==> " .. ns.Stormwind .. "\n" .. " ==> " .. ns.TanaanJungle } -- Portal from Ashran to Stormwind
              nodes[572][53396082] = { mnID = 582, name = "", type = "APortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = GARRISON_LOCATION_TOOLTIP .. " " .. L["Portal"] .. "\n" .. " ==> " .. ns.Ashran } -- Portal from Garrison to Ashran
            end
          end

         --Draenor LFR
          if self.db.profile.showContinentLFR then
            
            if self.faction == "Horde" or db.activate.ContinentEnemyFaction then
              nodes[572][33793621] = { mnID = 590, id = { 477, 457, 669 }, type = "LFR", showOnContinent = true, showInZone = false, showOnMinimap = false, name = ns.SeerKazal .. " - " .. REQUIRES_LABEL .. " " .. GARRISON_LOCATION_TOOLTIP .. " " .. LEVEL .. " " .. ACTION_SPELL_CAST_START_MASTER .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " " }
            end
            
            if self.faction == "Alliance" or db.activate.ContinentEnemyFaction then
              nodes[572][51886044] = { mnID = 582, id = { 477, 457, 669 }, type = "LFR", showOnContinent = true, showInZone = false, showOnMinimap = false, name = ns.SeerKazal .. " - " .. REQUIRES_LABEL .. " " .. GARRISON_LOCATION_TOOLTIP .. " " .. LEVEL .. " " .. ACTION_SPELL_CAST_START_MASTER .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " " }
            end
          end

        -- Draenor PvpandPveVendor
          if self.db.profile.showContinentPvPandPvEVendor then

            if self.faction == "Horde" or db.activate.ContinentEnemyFaction then
              nodes[572][71454121] = { name = "", dnID = TRANSMOG_SET_PVP .. " " .. MERCHANT .. " " .. FACTION_HORDE .. "\n" .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. "\n" .. AUCTION_CATEGORY_WEAPONS, mnID = 624, type = "ContinentPvPVendorH", hideTTmnID = true, showOnContinent = true, showInZone = false, showOnMinimap = false }
            end

            if self.faction == "Alliance" or db.activate.ContinentEnemyFaction then
              nodes[572][71524649] = { name = "", dnID = TRANSMOG_SET_PVP .. " " .. MERCHANT .. " " .. FACTION_ALLIANCE .. "\n" .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. "\n" .. AUCTION_CATEGORY_WEAPONS, mnID = 622, type = "ContinentPvPVendorA", hideTTmnID = true, showOnContinent = true, showInZone = false, showOnMinimap = false }
            end

          end

        end
    
    
        --#################################
        --##### Continent Broken Isles ####
        --#################################
    
        if self.db.profile.showContinentBrokenIsles then
    
        --Broken Isles Dungeons
          if self.db.profile.showContinentDungeons then
            nodes[619][47076690] = { id = 777, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Assault on Violet Hold
            nodes[619][38805780] = { id = 716, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Eye of Azshara
            nodes[619][34207210] = { id = 707, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Vault of the Wardens
            nodes[619][89551352] = { id = 945, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- The Seat of the Triumvirate
            nodes[619][29403300] = { id = 740, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Black Rook Hold
            nodes[619][59003060] = { id = 727, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Maw of Souls
            nodes[619][47302810] = { id = 767, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Neltharion's Lair
            nodes[619][49104970] = { id = 800, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Court of Stars
            nodes[619][46004883] = { id = 726, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- The Arcway
            nodes[619][56416109] = { id = 900, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Cathedral of the Night
            nodes[619][65573821] = { id = 721, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Halls of Valor
            nodes[619][35792725] = { id = 762, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Darkheart Thicket
            nodes[905][52513071] = { id = 945, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- The Seat of the Triumvirate
          end
    
    
        --Broken Isles Raids
          if self.db.profile.showContinentRaids then
            nodes[619][86262011] = { id = 946, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Antorus, the Burning Throne
            nodes[619][46864732] = { id = 786, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- The Nighthold
            nodes[619][56506240] = { id = 875, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Tomb of Sargeras
            nodes[619][64553903] = { id = 861, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Trial of Valor
            nodes[619][34982901] = { id = 768, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- The Emerald Nightmare
            nodes[905][32896084] = { id = 946, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Antorus, the Burning Throne
          end
    
    
        --Broken Isles Portals
          if self.db.profile.showContinentPortals then
            nodes[619][51395567] = { mnID = 860, name = "", type = "Portal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Portal"] .. "\n" .. " ==> " .. ns.Orgrimmar .. "\n"  .. " ==> " .. ns.Stormwind } --  Dalaran to Orgrimmar Portal
            nodes[619][45246482] = { npcID = 121602, mnID = 627, name = "", dnID = "\n" .. TOOLTIP_BATTLE_PET .. " " .. CALENDAR_TYPE_DUNGEON .. " " .. L["Portals"] .. ":\n" .. " ", type = "PortalPetBattleDungeon", showOnContinent = true, showInZone = false, showOnMinimap = false, 
                                        showWWW = true, wwwName = BATTLE_PET_SOURCE_2 .. " " .. REQUIRES_LABEL,
                                        mnIDs1 = 11, questIDs1 = 45423, wwwNames1 = "Wailing Critters", wwwLinks1 = "https://www.wowhead.com/quest=45423",
                                        mnIDs2 = 52, questIDs2 = 46291, wwwNames2 = "The Deadmines strike back", wwwLinks2 = "https://www.wowhead.com/quest=46291", 
                                        mnIDs3 = 30, questIDs3 = 54185, wwwNames3 = "Gnomeregans new Guardians", wwwLinks3 = "https://www.wowhead.com/quest=54185",
                                        mnIDs4 = 23, questIDs4 = 56491, wwwNames4 = "Tiny Terrors of Stratholme", wwwLinks4 = "https://www.wowhead.com/quest=56491", 
                                        mnIDs5 = 35, questIDs5 = 58457, wwwNames5 = "Shadows of Blackrock", wwwLinks5 = "https://www.wowhead.com/quest=58457" } -- Portal Manapuff

            if self.faction == "Horde" or db.activate.ContinentEnemyFaction then
              nodes[619][45606186] = { mnID = 627, name = "", type = "HPortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. ns.Orgrimmar } --  Dalaran to Orgrimmar Portal
              nodes[619][33715775] = { mnID = 630, name = "", type = "HPortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. ns.Orgrimmar } -- Portal to Orgrimmar from Azsuna
            end
    
            if self.faction == "Alliance" or db.activate.ContinentEnemyFaction then
              nodes[619][45296767] = { mnID = 627,  name = "" , type = "APortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. ns.Stormwind } --  Portal from Dalaran to Stormwind
              nodes[619][32905786] = { mnID = 630,  name = "" , type = "APortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. ns.Stormwind } -- Portal to Stormwind from Azsuna
             end
          end


        -- Broken Isles LFR
          if self.db.profile.showContinentLFR then
            nodes[619][46806495] = { mnID = 627, id = { 875, 786, 768, 861, 946 }, name = ns.ArchmageTimear .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " ", type = "LFR", showOnContinent = true, showInZone = false, showOnMinimap = false }
          end
        end
    
    
        --#############################
        --##### Continent Zandalar ####
        --#############################
    
        if self.db.profile.showContinentZandalar then
    
        --Zandalar Dungeons
          if self.db.profile.showContinentDungeons then
            nodes[875][48865880] = { id = 968, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Atal'Dazar
            nodes[875][45205880] = { id = 1041, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Kings' Rest
            nodes[875][58243603] = { id = 1022, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- The Underrot
            nodes[875][40781425] = { id = 1030, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Temple of Sethraliss
          
            if self.faction == "Horde" or db.activate.ContinentEnemyFaction then
              nodes[875][57757046] = { id = 1012, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- The MOTHERLODE HORDE
            end
          
            if self.faction == "Alliance" or db.activate.ContinentEnemyFaction then
              nodes[875][45457850] = { id = 1012, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- The MOTHERLODE Alliance
            end
          end
    
    
        --Zandalar Raids
          if self.db.profile.showContinentRaids then
            nodes[875][59413469] = { id = 1031, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Uldir
            nodes[875][86731430] = {  id = 1179, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- The Eternal Palace 
            if self.faction == "Horde" or db.activate.ContinentEnemyFaction then
            nodes[875][56005350] = { id = 1176, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Battle of Dazar'alor
            end
          end
    
    
        -- Zandalar Portals
          if self.db.profile.showContinentPortals then
    
            if self.faction == "Horde" or db.activate.ContinentEnemyFaction then
              nodes[875][58486162] = { mnID = 1163, name = "", type = "HPortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.Dazaralor .. "\n" .. "\n" .. L["Portalroom"] .. "\n" .. " ==> " .. ns.Silvermoon .. "\n" .. " ==> " .. ns.Orgrimmar .. "\n" .. " ==> " .. ns.ThunderBluff .. "\n" .. " ==> " .. ns.Silithus .. "\n" .. " ==> " .. ns.Nazjatar } -- Portalroom from Dazar'alor
              nodes[875][59107238] = { mnID = 1165, name = "", type = "HPortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.Zandalar .. " " .. L["Portals"] .. "\n" ..  "\n" .. " ==> " .. L["This Darkshore portal is only active if your faction is currently occupying Bashal'Aran"] .. "\n" .. " ==> " .. L["This Arathi Highlands portal is only active if your faction is currently occupying Ar'gorok"] } -- Portal to Arathi and Darkshore
              nodes[875][59265802] = { npcID = 147642, mnID = 862, name = "", dnID = "\n" .. TOOLTIP_BATTLE_PET .. " " .. CALENDAR_TYPE_DUNGEON .. " " .. L["Portals"] .. ":\n" .. " ", type = "PortalHPetBattleDungeon", showOnContinent = true, showInZone = false, showOnMinimap = false,
                                        showWWW = true, wwwName = BATTLE_PET_SOURCE_2 .. " " .. REQUIRES_LABEL,
                                        mnIDs1 = 11, questIDs1 = 45423, wwwNames1 = "Wailing Critters", wwwLinks1 = "https://www.wowhead.com/quest=45423",
                                        mnIDs2 = 52, questIDs2 = 46291, wwwNames2 = "The Deadmines strike back", wwwLinks2 = "https://www.wowhead.com/quest=46291", 
                                        mnIDs3 = 30, questIDs3 = 54185, wwwNames3 = "Gnomeregans new Guardians", wwwLinks3 = "https://www.wowhead.com/quest=54185",
                                        mnIDs4 = 23, questIDs4 = 56491, wwwNames4 = "Tiny Terrors of Stratholme", wwwLinks4 = "https://www.wowhead.com/quest=56491", 
                                        mnIDs5 = 35, questIDs5 = 58457, wwwNames5 = "Shadows of Blackrock", wwwLinks5 = "https://www.wowhead.com/quest=58457" } -- Portal Manapuff
            end
          end
    

        -- Zandalar MapNotesIcons
          if self.db.profile.showContinentMapNotes then
    
            if self.faction == "Horde" or db.activate.ContinentEnemyFaction then
              nodes[875][58486162] = { mnID = 1163, id = { 1176, 1031, 1179, 1036 }, type = "HIcon", showOnContinent = true, showInZone = false, showOnMinimap = false, name = ns.Dazaralor .. "\n" .. "\n" .. L["Portalroom"] .. "\n" .. " ==> " .. ns.Silvermoon .. "\n" .. " ==> " .. ns.Orgrimmar .. "\n" .. " ==> " .. ns.ThunderBluff .. "\n" .. " ==> " .. ns.Silithus .. "\n" .. " ==> " .. ns.Nazjatar .. "\n" .. " " .. "\n" .. ns.Eppu .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " ",} -- Portalroom from Dazar'alor
            end
          end 

    
        -- Zandalar Ships
          if self.db.profile.showContinentShips then
    
            if self.faction == "Horde" or db.activate.ContinentEnemyFaction then
              nodes[875][57957497] = { mnID = 463, name = "", type = "HShip", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Ship"] .. " ==> " .. ns.EchoIsles } -- Ship from Zandalar to Echo Isles 
            end
    
            if self.faction == "Alliance" or db.activate.ContinentEnemyFaction then

            end

          end


        -- Zandalar Transport
          if self.db.profile.showContinentTransport then

            if self.faction == "Horde" or db.activate.ContinentEnemyFaction then
              nodes[875][58267339] = { mnID = 876, name = L["(Dread-Admiral Tattersail) will take you to Drustvar, Tiragarde Sound or Stormsong Valley"], type = "UndeadF", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Ship from Dazar'alor to Drustvar, Tiragarde Sound or Stormsong Valley
              nodes[875][56307038] = { npcID = 152506, mnID = 876, name = "", dnID = "(" .. ITEM_REQ_HORDE ..")", type = "GoblinF", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Transport from Dazar'alor to Mechagon 
            end

            if self.faction == "Alliance" or db.activate.ContinentEnemyFaction then
              nodes[875][33051846] = { mnID = 864, name = L["Barnard 'The Smasher' Bayswort"] .. " - " .. L["Travel"], type = "KulM", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = " " .. ITEM_REQ_ALLIANCE .. "\n" .. "\n" .. " ==> " .. ns.Boralus } -- Transport from Vol'dun to Boralus
              nodes[875][62402600] = { mnID = 863, name = L["Desha Stormwallow"] .. " - " .. L["Travel"], type = "DwarfF", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = " " .. ITEM_REQ_ALLIANCE .. "\n" .. "\n" .. " ==> " .. ns.Boralus } -- Transport from Nazmir to Boralus
              nodes[875][47177779] = { mnID = 862, name = L["Daria Smithson"] .. " - " .. L["Travel"] , type = "GilneanF", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = " " .. ITEM_REQ_ALLIANCE .. "\n" .. "\n" .. " ==> " .. ns.Boralus } -- Transport from Zuldazar to Boralus 
            end
          end


        -- Zandalar LFR
          if self.db.profile.showContinentLFR then

            if self.faction == "Horde" or db.activate.ContinentEnemyFaction then 
              nodes[875][56886153] = { mnID = 1164, id = { 1176, 1031, 1179, 1036 }, type = "LFR", showOnContinent = true, showInZone = false, showOnMinimap = false, name = ns.Eppu .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " " }
            end
          end

        -- Zandalar PvpandPveVendor
          if self.db.profile.showContinentPvPandPvEVendor then

            if self.faction == "Horde" or db.activate.ContinentEnemyFaction then 
              nodes[875][54017034] = { name = "", dnID = TRANSMOG_SET_PVP .. " " .. MERCHANT .. " " .. FACTION_HORDE .. "\n" .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. "\n" .. AUCTION_CATEGORY_WEAPONS, mnID = 862, type = "ContinentPvPVendorH", hideTTmnID = true, showOnContinent = true, showInZone = false, showOnMinimap = false }
            end

          end

        end
    
    
        --##############################
        --##### Continent Kul Tiras ####
        --##############################
    
        if self.db.profile.showContinentKulTiras then 
    
        -- Kul Tiras Dungeons
          if self.db.profile.showContinentDungeons then
            nodes[876][19872697] = { id = 1178, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Operation: Mechagon 
            nodes[876][67018056] = { id = 1001, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Freehold 
            nodes[876][31675333] = { id = 1021, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Waycrest Manor 
            nodes[876][66051501] = { id = 1036, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Shrine of Storm 
            nodes[876][77566206] = { id = 1002, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Tol Dagor
    
            if self.faction == "Alliance" or db.activate.ContinentEnemyFaction then
              nodes[876][61865000] = { id = 1023, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Siege of Boralus
            end
    
            if self.faction == "Horde" or db.activate.ContinentEnemyFaction then
              nodes[876][70406468] = { id = 1023, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Siege of Boralus
            end
          end
    
    
        -- Kul Tiras Raids
          if self.db.profile.showContinentRaids then
            nodes[876][68262354] = { id = 1177, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Crucible of Storms
            nodes[876][86261171] = { id = 1179, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- The Eternal Palace
    
            if self.faction == "Alliance" or db.activate.ContinentEnemyFaction then
              nodes[876][61645308] = { id = 1176, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Battle of Dazar'alor
            end
          end

        -- Kul Tiras Portals
          if self.db.profile.showContinentPortals then
            if self.faction == "Alliance" or db.activate.ContinentEnemyFaction then
              nodes[876][58615357] = { npcID = 147666, mnID = 895, name = "", dnID = "\n" .. TOOLTIP_BATTLE_PET .. " " .. CALENDAR_TYPE_DUNGEON .. " " .. L["Portals"] .. ":\n" .. " ", type = "PortalAPetBattleDungeon", showOnContinent = true, showInZone = false, showOnMinimap = false, 
                                       showWWW = true, wwwName = BATTLE_PET_SOURCE_2 .. " " .. REQUIRES_LABEL,
                                       mnIDs1 = 11, questIDs1 = 45423, wwwNames1 = "Wailing Critters", wwwLinks1 = "https://www.wowhead.com/quest=45423",
                                       mnIDs2 = 52, questIDs2 = 46291, wwwNames2 = "The Deadmines strike back", wwwLinks2 = "https://www.wowhead.com/quest=46291", 
                                       mnIDs3 = 30, questIDs3 = 54185, wwwNames3 = "Gnomeregans new Guardians", wwwLinks3 = "https://www.wowhead.com/quest=54185",
                                       mnIDs4 = 23, questIDs4 = 56491, wwwNames4 = "Tiny Terrors of Stratholme", wwwLinks4 = "https://www.wowhead.com/quest=56491", 
                                       mnIDs5 = 35, questIDs5 = 58457, wwwNames5 = "Shadows of Blackrock", wwwLinks5 = "https://www.wowhead.com/quest=58457" } -- Portal Manapuff
            end
          end
    
    
        -- Kul Tiras Portals without MapNotesIcons
          if self.db.profile.showContinentPortals and not self.db.profile.showContinentMapNotes then
    
            if self.faction == "Alliance" or db.activate.ContinentEnemyFaction then
              nodes[876][59165485] = { mnID = 1161, name = "", type = "APortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.Boralus .. " " .. L["Portalroom"] .. "\n" .. "\n" .. " ==> " .. ns.Stormwind .. "\n" .. " ==> " .. ns.Silithus .. "\n" .. " ==> " .. ns.Exodar .. "\n" .. " ==> " .. ns.Ironforge .. "\n" .. " ==> " .. ns.Nazjatar .. "\n" .. "\n" .. L["Portals"] .. "\n" ..  "\n" .. " ==> " .. ns.ArathiHighlands .. "\n" .. " ==> " .. ns.Darkshore } -- Boralus Portals
            end
          end


        -- Kul Tiras MapNotesIcons
          if self.db.profile.showContinentMapNotes then
    
            if self.faction == "Alliance" or db.activate.ContinentEnemyFaction then
              nodes[876][58395547] = { mnID = 1161, id = { 1176, 1031, 1179, 1036 }, type = "AIcon", showOnContinent = true, showInZone = false, showOnMinimap = false, name = ns.Boralus .. " " .. "\n" .. " " .. "\n" .. L["Portalroom"] .. "\n" .. " ==> " .. ns.Stormwind .. "\n" .. " ==> " .. ns.Silithus .. "\n" .. " ==> " .. ns.Exodar .. "\n" .. " ==> " .. ns.Ironforge .. "\n" .. " ==> " .. ns.Nazjatar .. "\n" .. " " .. "\n" .. ns.GrandAdmiralJesTereth .. L["Travel"] .. "\n" .. " ==> " .. ns.Nazmir .. "\n" .. " ==> " .. ns.Zuldazar .. "\n" .. " ==> " .. ns.Voldun .. "\n" .. " " .. "\n" .. L["Portals"] .. "\n" .. " " .. "\n" .. " ==> " .. ns.ArathiHighlands .. "\n" .. " ==> " .. ns.Darkshore .. "\n" .. " " .. "\n" .. L["Ship"] .. "\n" .. " ==> " .. ns.Stormwind .. "\n" .. " "  .."\n" .. ns.Kiku .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " "} -- Boralus Transports
            end
          end
    
    
        -- Kul Tiras Ships
          if self.db.profile.showContinentShips then
    
            if self.faction == "Horde" or db.activate.ContinentEnemyFaction then

            end
    
            if self.faction == "Alliance" or db.activate.ContinentEnemyFaction then

            end
          end

          -- Kul Tiras Transport
          if self.db.profile.showContinentTransport then

            nodes[876][20172422] = { mnID = 1462, name = "", type = "GoblinF", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.CaptainKrooz .. " " .. SPLASH_BATTLEFORAZEROTH_8_2_0_FEATURE1_TITLE .. " " .. L["Travel"] .. "\n" .. "\n" .. " ==> " .. ns.Dazaralor } -- Ship from Mechagon to Zuldazar

            if self.faction == "Horde" or db.activate.ContinentEnemyFaction then
              nodes[876][25676657] = { mnID = 896, name = ns.Swellthrasher .. " - " .. L["Travel"], type = "MOrcF", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = " " .. ITEM_REQ_HORDE .. "\n" .. "\n" .. " ==> " .. ns.Zuldazar } -- Transport from Drustvar to Zuldazar
              nodes[876][54391406] = { mnID = 942, name = ns.GrokSeahandler .. " - " .. L["Travel"], type = "OrcM", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = " " .. ITEM_REQ_HORDE .. "\n" .. "\n" .. " ==> " .. ns.Zuldazar } -- Transport from Stormsong Valley to Zuldazar
              nodes[876][68326548] = { mnID = 895, name = ns.ErulDawnbrook .. " - " .. L["Travel"] , type = "B11M", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = " " .. ITEM_REQ_HORDE .. "\n" .. "\n" .. " ==> " .. ns.Zuldazar } -- Transport from Tiragarde Sound to Zuldazar 
            end
          end


        -- Kul Tiras LFR
          if self.db.profile.showContinentLFR then

            if self.faction == "Alliance" or db.activate.ContinentEnemyFaction then
              nodes[876][60244960] = { mnID = 895, id = { 1176, 1031, 1179, 1036 }, type = "LFR", showOnContinent = true, showInZone = false, showOnMinimap = false, name = ns.Kiku .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " " }
            end
          end

        -- Kul Tiras PvpandPveVendor
          if self.db.profile.showContinentPvPandPvEVendor then

            if self.faction == "Alliance" or db.activate.ContinentEnemyFaction then
              nodes[876][58825106] = { name = "", dnID = TRANSMOG_SET_PVP .. " " .. MERCHANT .. " " .. FACTION_ALLIANCE .. "\n" .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. "\n" .. AUCTION_CATEGORY_WEAPONS, mnID = 1161, type = "ContinentPvPVendorA", hideTTmnID = true, showOnContinent = true, showInZone = false, showOnMinimap = false }
            end

          end

        end
    
    
        --################################
        --##### Continent Shadowlands ####
        --################################
    
        if self.db.profile.showContinentShadowlands then
    
        -- Shadowlands Dungeons
          if self.db.profile.showContinentDungeons then
            nodes[1550][69025977] = { id = 1182, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- The Necrotic Wake
            nodes[1550][74085251] = { id = 1186, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Spires of Ascension
            nodes[1550][64912620] = { id = 1183, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Plaguefall
            nodes[1550][63372312] = { id = 1187, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Theater of Pain
            nodes[1550][44698228] = { id = 1184, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Mists of Tirna Scithe
            nodes[1550][54378591] = { id = 1188, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- De Other Side
            nodes[1550][31335274] = { id = 1185, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Halls of Atonement
            nodes[1550][24984833] = { id = 1189, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Sanguine Depths
            nodes[1550][31957638] = { id = 1194, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Tazavesh, the Veiled Market
          end
    
    
        -- Shadowlands Raids
          if self.db.profile.showContinentRaids then
            nodes[1550][89067983] = { id = 1195, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Sepulcher of the First Ones
            nodes[1550][27081359] = { id = 1193, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Sanctum of Domination
            nodes[1550][23795072] = { id = 1190, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Castle Nathria
          end
    
    
        -- Shadowlands Portals
          if self.db.profile.showContinentPortals then
            nodes[1550][46555240] = { mnID = 1670,  name = "" , type = "Portal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.Oribos .. " " .. L["Portals"] .. "\n" .. "\n" .. " ==> " .. ns.Orgrimmar .. "\n" .. " ==> " .. ns.Stormwind .. "\n" .. " ==> " .. ns.ZerethMortis .. "\n" .. " ==> " .. ns.TheMaw .. "\n" .. " ==> " .. ns.Korthia } -- Oribos to Stormwind City Portal
            nodes[1550][84378297] = { mnID = 1970,  name = "" , type = "Portal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.ZerethMortis .. " " .. L["Portal"] .. "\n" .. " ==> " .. ns.Oribos } -- Zereth Mortis to Oribos
            nodes[1550][23470975] = { mnID = 1543,  name = "" , type = "Portal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.TheMaw .. " " .. L["Portal"] .. "\n" .. " ==> " .. ns.Oribos } -- The Maw to Oribos
            nodes[1550][28181988] = { mnID = 1961,  name = "" , type = "Portal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.Korthia .. " " .. L["Portal"] .. "\n" .. " ==> " .. ns.Oribos } -- Korthis to Oribos
          end


        -- Shadowlands LFR
          if self.db.profile.showContinentLFR then
            nodes[1550][46704896] = { mnID = 1670, id = { 1190, 1193, 1195 }, type = "LFR", showOnContinent = true, showInZone = false, showOnMinimap = false, name = ns.Taelfar .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " " }
          end

        -- Shadowlands PvpandPveVendor
          if self.db.profile.showContinentPvPandPvEVendor then
            nodes[1550][45135011] = { name = "", dnID = TRANSMOG_SET_PVP .. " / " .. TRANSMOG_SET_PVE .. " " .. MERCHANT .. "\n" .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. "\n" .. AUCTION_CATEGORY_WEAPONS, mnID = 1670, type = "PvPVendor", hideTTmnID = true, showOnContinent = true, showInZone = false, showOnMinimap = false }
          end
          
        end
    
    
        --#################################
        --##### Continent Dragon Isles ####
        --#################################
    
        if self.db.profile.showContinentDragonIsles then
    
        -- Dragonflight Dungeons
          if self.db.profile.showContinentDungeons then
            nodes[1978][52884168] = { id = 1202, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Ruby Life Pools
            nodes[1978][42163601] = { id = 1199, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Neltharus
            nodes[1978][43635285] = { id = 1198, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- The Nokhud Offensive
            nodes[1978][35407585] = { id = 1196, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Brackenhide Hollow
            nodes[1978][47408261] = { id = 1203, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- The Azure Vault
            nodes[1978][63114151] = { id = 1201, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Algeth'ar Academy
            nodes[1978][63614887] = { id = 1204, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Halls of Infusion
            nodes[1978][64415841] = { id = 1209, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Dawn of the Infinite
          end
    
    
        -- Dragonflight Raids
          if self.db.profile.showContinentRaids then
            nodes[1978][69074677] = { id = 1200, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Vault of the Incarnates
            nodes[1978][86737309] = { id = 1208, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Aberrus, the Shadowed Crucible
            --nodes[1978][82052929] = { id = 1207, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Amirdrassil, the Dream's Hope --node for worlquestracker map
          end
    
    
        -- Dragonflight Portals
          if self.db.profile.showContinentPortals then
            nodes[1978][56264965] = { mnID = 2112, name = "", type = "Portal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.Valdrakken .. " " .. L["Portals"] .. "\n" ..  "\n" .. " ==> " .. ns.EmeraldDream .. "\n" .. " ==> " .. ns.Badlands .. "\n".." ==> " .. ns.Stormwind .. "\n" .. " ==> " .. ns.Orgrimmar } --  Valdrakken Portals
            nodes[1978][30945509] = { mnID = 2200, name = "", type = "WayGateGreen",  showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. ns.EmeraldDream } -- Portal to The Emerald Dream
    
            if self.faction == "Horde" or db.activate.ContinentEnemyFaction then

            end
    
            if self.faction == "Alliance" or db.activate.ContinentEnemyFaction then
              nodes[1978][25006083] = { mnID = "2239",  name = "", type = "APortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Portals"] .. "\n" .. " ==> " .. ns.Stormwind .. "\n" .. " ==> " .. ns.Darkshore .. "\n" .. " ==> " .. ns.Hyjal  .. "\n" .. " ==> " .. POSTMASTER_LETTER_LORLATHIL } -- Valdrakken to Stormwind City Portal
            end
          end
    

        -- Dragonflight Passage          
          if self.db.profile.showContinentPassage and not db.activate.noPassages then
            nodes[1978][31065686] = { id = 1207, type = "PassageRaid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Amirdrassil, the Dream's Hope
          end
    

        -- Dragonflight noPassages
          if db.activate.noPassages then

            if self.db.profile.showContinentRaids then
              nodes[1978][31065686] = { id = 1207, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Amirdrassil, the Dream's Hope
            end
          end


        -- Dragonflight Zeppelin
          if self.db.profile.showContinentZeppelins then      
    
            if self.faction == "Horde" or db.activate.ContinentEnemyFaction then 
              nodes[1978][59572607] = { mnID = 85, name = "", type = "HZeppelin", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Zeppelin"] .. " ==> " .. ns.Orgrimmar } -- Zeppelin from The Waking Shores to Orgrimmar 
            end
          end
    
    
        -- Dragonflight Ships
          if self.db.profile.showContinentShips then
            nodes[1978][24105048] = { mnID = 217, name = "", type = "Ship", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.Amirdrassil .. " " .. L["Ship"] .. "\n" .. " ==> " .. ns.RuinsofGilneas } -- Ship from Amirdrassil to Gilneas

            if self.faction == "Alliance" or db.activate.ContinentEnemyFaction then
              nodes[1978][59732701] = { mnID = 84, name = "", type = "AShip", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Ship"] .. " ==> " .. ns.Stormwind } -- Ship from The Waking Shores to Stormwind
            end
          end
        end 


        --#################################
        --##### Continent Khaz Algar ######
        --#################################
    
        if self.db.profile.showContinentKhazAlgar then

          -- missing Blizzard Delves on zone maps  
          if ns.Addon.db.profile.showContinentDelves then
            nodes[2274][37838637] = { name = "", TransportName = DELVE_LABEL, delveID = 2348, type = "Delves", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Zekvir's Lair
          end
    
        -- Khaz Algar Dungeons
          if self.db.profile.showContinentDungeons then
            nodes[2274][57814889] = { id = 1210, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Darkflame Cleft
            nodes[2274][35095289] = { id = 1267, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Priory of the Sacred Flame
            nodes[2274][40465803] = { id = 1270, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- The Dawnbreaker
            nodes[2274][53004397] = { id = 1269, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- The Stonevault
            nodes[2274][52715561] = { id = 1298, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Operation: Floodgate
            nodes[2274][70301908] = { id = 1268, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- The Rookery
            nodes[2274][84362059] = { id = 1272, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Cinderbrew Meadery
            nodes[2274][43337984] = { id = 1274, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- City of Threads
            nodes[2274][44338372] = { id = 1271, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Ara-Kara, City of Echoes
            nodes[2274][24392389] = { id = 1303, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Eco-Dome Al'dani
            nodes[2274][24391549] = { id = 1194, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Tazavesh, the Veiled Market
          end
    
        -- Khaz Algar Raids
          if self.db.profile.showContinentRaids then
            nodes[2274][41469096] = { id = 1273, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Nerub-ar Palace     
            nodes[2274][81917514] = { id = 1296, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Liberation of Undermine  
            nodes[2274][17931205] = { id = 1302, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Manaforge Omega
          end

        -- Khaz Algar MapNotesIcons
          if self.db.profile.showContinentMapNotes then
            nodes[2274][72311951] = { mnID = 2339, name = "", type = "MNL", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ns.Dornogal .. " - " .. FACTION_NEUTRAL .. "\n" .. "\n" .. L["Portals"] .. "\n" .. " ==> " .. ns.Orgrimmar .. "\n" .. " ==> " .. ns.Stormwind .. "\n" .. "\n" .. L["The Timeways"] .. " " .. L["Portals"] .. "\n" .. "\n" .. " ==> " .. ns.Tazavesh .. "\n" .. " ==> " .. ns.Revendreth .."\n" .. "\n" .. CALENDAR_TYPE_DUNGEON .. "\n" .. " ==> " .. ns.Rookery } -- Dornogal
          end
    
        -- Khaz Algar Portals
          if self.db.profile.showContinentPortals then
            --nodes[2274][70881758] = { mnID = 2339, name = "", type = "Portal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Portals"] .. "\n" ..  "\n" .. " ==> " .. ns.Stormwind .. "\n" .. " ==> " .. ns.Orgrimmar } --  Isle of Dorn Portals
    
            if self.faction == "Alliance" or db.activate.ContinentEnemyFaction then
              --nodes[1978][25006083] = { mnID = "2239",  name = "", type = "APortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Portals"] .. "\n" .. " ==> " .. ns.Stormwind .. "\n" .. " ==> " .. ns.Darkshore .. "\n" .. " ==> " .. ns.Hyjal  .. "\n" .. " ==> " .. POSTMASTER_LETTER_LORLATHIL } -- Valdrakken to Stormwind City Portal
            end
          end

        -- Khaz Algar Transport
          if self.db.profile.showContinentTransport then
            nodes[2274][52675173] = { mnID = 2369, name = L["Mole Machine"], dnID = "", type = "MoleMachine", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Mole Machine from Deeps to Sirene Isle
            nodes[2274][64396827] = { mnID = 2346, name = L["Rocket drill"] .. " " .. L["Transport"], dnID = "", type = "RocketDrill", questID = 83151, wwwLink = "wowhead.com/quest=83151", showWWW = true, wwwName = BATTLE_PET_SOURCE_2 .. " " .. REQUIRES_LABEL .. " " .. "Down Undermine", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Mole Machine from Deeps to Undermine
          end

        -- Khaz Algar Zeppelin
          if self.db.profile.showContinentZeppelins then
            nodes[2274][73131599] = { mnID = 2369, name = "", type = "Zeppelin", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Zeppelin"] .. " ==> " .. L["Siren Isle"] } -- Zeppelin to Siren Isle from Dornogal
          end

        -- Khaz Algar Paths
          if self.db.profile.showContinentPaths then
            nodes[2274][46397339] = { mnID = 2339, name = L["Passage"], dnID = "", showWWW = true, wwwName = LOOT_JOURNAL_LEGENDARIES_SOURCE_ACHIEVEMENT .. " " .. REQUIRES_LABEL, wwwLink = "https://wowhead.com/achievement=19559", achievementID = 19559, type = "PassageCaveUp", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Portal from Azj-Kahet to Dornogal if u finished the achievement=19559
            nodes[2274][60306969] = { mnID = 2248, name = L["Passage"], dnID = "", showWWW = true, wwwName = LOOT_JOURNAL_LEGENDARIES_SOURCE_ACHIEVEMENT .. " " .. REQUIRES_LABEL, wwwLink = "https://wowhead.com/achievement=19560", achievementID = 19560, type = "PassageCaveUp", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Portal from Ringing Deeps to Isle of Dornogal
            nodes[2274][55475781] = { mnID = 2248, name = L["Passage"], dnID = "", showWWW = true, wwwName = LOOT_JOURNAL_LEGENDARIES_SOURCE_ACHIEVEMENT .. " " .. REQUIRES_LABEL, wwwLink = "https://wowhead.com/achievement=19560", achievementID = 19560, type = "PassageCaveUp", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Portal from Ringing Deeps to Isle of Dornogal
            nodes[2274][65383353] = { mnID = 2214, name = L["Passage"], dnID = "", showWWW = true, wwwName = LOOT_JOURNAL_LEGENDARIES_SOURCE_ACHIEVEMENT .. " " .. REQUIRES_LABEL, wwwLink = "https://wowhead.com/achievement=19560", achievementID = 19560, type = "PassageCaveDown", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Portal from Isle of Dornogal to Ringing Deeps
            nodes[2274][79661540] = { mnID = 2214, name = L["Passage"], dnID = "", showWWW = true, wwwName = LOOT_JOURNAL_LEGENDARIES_SOURCE_ACHIEVEMENT .. " " .. REQUIRES_LABEL, wwwLink = "https://wowhead.com/achievement=19560", achievementID = 19560, type = "PassageCaveDown", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Portal from Isle of Dornogal to Ringing Deeps
            nodes[2274][70402160] = { mnID = 2214, name = L["Passage"], dnID = "", type = "PassageCaveDown", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Portal from Isle of Dornogal to Ringing Deeps
          end

          -- Khaz Algar RenownQuartermaster
          if self.db.profile.showContinentRenownQuartermaster then
            nodes[2274][45227346] = { npcID = 223750, mnID = 2255, name = "", type = "RenownQuartermaster", hideTTmnID = true, showOnContinent = true, showInZone = false, showOnMinimap = false }
            nodes[2274][34165593] = { npcID = 213145, mnID = 2215, name = "", type = "RenownQuartermaster", hideTTmnID = true, showOnContinent = true, showInZone = false, showOnMinimap = false }
            nodes[2274][53595332] = { npcID = 221390, mnID = 2214, name = "", type = "RenownQuartermaster", hideTTmnID = true, showOnContinent = true, showInZone = false, showOnMinimap = false }
            nodes[2274][80067008] = { npcID = 231396, mnID = 2346, name = "", type = "RenownQuartermaster", hideTTmnID = true, showOnContinent = true, showInZone = false, showOnMinimap = false }
            nodes[2274][70881758] = { npcID = 223728, mnID = 2339, name = "", type = "RenownQuartermaster", hideTTmnID = true, showOnContinent = true, showInZone = false, showOnMinimap = false }
            nodes[2274][11221549] = { npcID = 235252, mnID = 2472, name = "", type = "RenownQuartermaster", hideTTmnID = true, showOnContinent = true, showInZone = false, showOnMinimap = false }
          end

          -- Khaz Algar PvpandPveVendor
          if self.db.profile.showContinentPvPandPvEVendor then
            nodes[2274][46338419] = { npcIDs1 = 224270, npcIDs2 = 224267, name = TRANSMOG_SET_PVP .. " / " .. TRANSMOG_SET_PVE .. " " .. MERCHANT, mnID = 2213, type = "PvEVendor", hideTTmnID = true, showOnContinent = true, showInZone = false, showOnMinimap = false }
          end

        end

      end
  end

end