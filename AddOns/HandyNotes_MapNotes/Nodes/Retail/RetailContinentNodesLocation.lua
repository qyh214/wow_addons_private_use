local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

function ns.LoadContinentNodesLocationinfo(self)
local db = ns.Addon.db.profile
local nodes = ns.nodes

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
            nodes[12][42726722] = { id = 230, lfgid = 36, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Dire Maul - Warpwood Quarter 
            nodes[12][54187774] = { id = 241, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Zul'Farrak
            nodes[12][50916837] = { id = 234, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Razorfen Kraul 
            nodes[12][52519670] = { id = 68, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- The Vortex Pinnacle 
            nodes[12][49699341] = { id = 69, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Lost City of Tol'Vir 
            nodes[12][51579122] = { id = 70, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Halls of Origination
            nodes[948][51102882] = { id = 67, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- The Stonecore
          end


        -- Kalimdor Dungeons hidden if ClassicIcons is activ
          if self.db.profile.showContinentDungeons and not db.activate.ClassicIcons then 
            nodes[12][42856552] = { id = 230, lfgid = 38, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Dire Maul - Gordok Commons - North  
          end
    
    
        --Kalimdor Raids
          if self.db.profile.showContinentRaids then
            nodes[12][45929663] = { id = 74, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Throne of the Four Winds 
            nodes[12][54243397] = { id = 78, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Firelands 
            nodes[12][56526946] = { id = 760, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Onyxia's Lair 
            nodes[12][42068358] = { id = 743, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Ruins of Ahn'Qiraj 
            nodes[12][40678358] = { id = 744, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Temple of Ahn'Qiraj
            nodes[12][49159032] = { id = 1180, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false, dnID = L["Instance Entrance"] .. " " .. L["switches weekly between"] .. " " .. L["Uldum"] .. " (" .. L["Kalimdor"] ..")" .. " & " .. L["Vale of Eternal Blossoms"] .. " (" .. L["Pandaria"] .. ")" } -- Ny'Alotha, The Waking City
          end
    
        --Kalimdor Passage
          if self.db.profile.showContinentPassage and not db.activate.ClassicIcons then
            nodes[12][59228331] = { mnID = 75, hideInfo = true, id = { 187, 750, 279, 255, 251, 184, 185, 186 }, type = "PassageDungeonRaidMulti", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Dragon Soul, The Battle for Mount Hyjal, The Culling of Stratholme, Black Morass, Old Hillsbrad Foothills, End Time, Well of Eternity, Hour of Twilight Heroic
            nodes[12][46106657] = { id = 230, lfgid = 34, type = "PassageDungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Dire Maul - Warpwood Quarter - East above Camp Mojache   
            nodes[12][43906613] = { id = 230, lfgid = 34, type = "PassageDungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Dire Maul - Warpwood Quarter - East above Camp Mojache 
            nodes[12][43913301] = { id = 227, type = "PassageDungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Blackfathom Deeps 
            nodes[12][52215315] = { mnID = 11, dnID = DUNGEON_FLOOR_WAILINGCAVERNS1, name = "", type = "PassageDungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Wailing Caverns  
            nodes[12][38395594] = { id = 232, type = "PassageDungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Maraudon 
            --nodes[12][58324232] = { id = 226, type = "PassageDungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Ragefire 
          end


        --Kalimdor Passage without ClassicIcons and without MapNotesIcons
          if self.db.profile.showContinentPassage and not db.activate.ClassicIcons and not self.db.profile.showContinentMapNotes then
            nodes[12][58324232] = { id = 226, type = "PassageDungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Ragefire 
          end

        --Kalimdor Passage without EnemyFaction and MapNotesIcons
          if not db.activate.EnemyFaction and self.db.profile.showContinentMapNotes then

            if self.faction == "Alliance" or db.activate.EnemyFaction then
              nodes[12][58324232] = { id = 226, type = "PassageDungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Ragefire
            end
          end

        --Kalimdor Passage without EnemyFaction and with MapNotesIcons with ClassicIcons
          if not db.activate.EnemyFaction and self.db.profile.showContinentMapNotes and db.activate.ClassicIcons then
            nodes[12][58324232] = { id = 226, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Ragefire
          end

        --Kalimdor ClassicIcons
         if db.activate.ClassicIcons then

          if self.db.profile.showContinentDungeons then
            --nodes[12][46106657] = { id = 230, lfgid = 34, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Dire Maul - Warpwood Quarter - East above Camp Mojache   
            --nodes[12][43906613] = { id = 230, lfgid = 34, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Dire Maul - Warpwood Quarter - East above Camp Mojache 
            nodes[12][43913301] = { id = 227, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Blackfathom Deeps 
            nodes[12][52215315] = { id = 240, name = "", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Wailing Caverns  
            nodes[12][38395594] = { id = 232, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Maraudon 
          end

        --Kalimdor ClassicIcons without MapNotesIcons
          if db.activate.ClassicIcons and not self.db.profile.showContinentMapNotes then

            if self.db.profile.showContinentDungeons then
              nodes[12][58324232] = { id = 226, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Ragefire 
            end
          end

          
         --Kalimdor Multiple 
          if self.db.profile.showContinentMultiple then
            nodes[12][59228331] = { mnID = 75, hideInfo = true, id = { 187, 750, 279, 255, 251, 184, 185, 186 }, type = "MultipleM", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Dragon Soul, The Battle for Mount Hyjal, The Culling of Stratholme, Black Morass, Old Hillsbrad Foothills, End Time, Well of Eternity, Hour of Twilight Heroic
          end
         end 
    

        -- Kalimdor Portals
          if self.db.profile.showContinentPortals then

            nodes[12][60078511] = { mnID = 74, name = "", type = "Portal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = DUNGEON_FLOOR_TANARIS18 .. " " .. L["Portals"] .. "\n" ..  "\n" .. " ==> " .. ORGRIMMAR .. "\n" .. " ==> " .. STORMWIND } -- Portal from Tanaris to Orgrimmar and Stormwind
            nodes[12][42807881] = { mnID = 81, name = "", type = "Portal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Silithus"] .. " " .. L["Portals"] .. "\n" ..  "\n" .. " ==> " .. L["Boralus, Tiragarde Sound"] .. "\n" .. " ==> " .. L["Zandalar"] } -- Portal from Silithus to Boralus
            nodes[12][56122725] = { mnID = 198, name = "", type = "Portal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = POSTMASTER_LETTER_HYJAL .. " " .. L["Portals"] .. "\n" ..  "\n" .. " ==> " .. ORGRIMMAR .. "\n" .. " ==> " .. STORMWIND } -- Portal To Orgrimmar from Hyjal
            nodes[12][49847481] = { mnID = 78, name = "", type = "Portal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Un'Goro Crater"] .. " " .. L["Portal"] .. "\n" .. " ==> " .. L["Sholazar Basin"] } --  Portal to Sholazar

            if self.faction == "Horde" or db.activate.EnemyFaction then  
              nodes[12][45605762] = { mnID = 7, name = FACTION_HORDE .. " " .. L["Portal"] .. " ==> " .. CALENDAR_FILTER_DARKMOON, showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = "\n" .. REQUIRES_LABEL .. " " .. CALENDAR_FILTER_DARKMOON .. "\n" .. L["Starting on the first Sunday of each month for one week"], type = "DarkMoon" } -- Mulgore Portal to the Darkmoon
              nodes[12][45842223] = { mnID = 62, name = "", type = "HPortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Portal"] .. " " .. L["Darkshore"] .. " ==> " .. L["Zandalar"] .. "\n" .. "\n" .. " " .. L["(its only shown up ingame if your faction\n is currently occupying Bashal'Aran)"] } -- Portal from New Darkshore to Zandalar 
            end

            if self.faction == "Alliance" or db.activate.EnemyFaction then
              nodes[12][47092322] = { mnID = 62, name = "", type = "APortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Portal"] .. " " .. L["Darkshore"] .. " ==> " .. L["Boralus"] .. "\n" .. "\n" .. " " .. L["(its only shown up ingame if your faction\n is currently occupying Bashal'Aran)"] } -- Portal from New Darkshore to Zandalar 
              nodes[12][43491624] = { mnID = 57, name = "", type = "APortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Rut'theran"] .. " " .. L["Portals"] .. "\n" .. " ==> " .. STORMWIND .. "\n" .. " ==> " .. L["Azuremyst Isle"] .. "\n" .. " ==> " .. L["Darnassus"] .. "\n" .. " ==> " .. L["Hellfire Peninsula"] } -- Portal from Teldrassil  
              nodes[12][29062721] = { mnID = 97, name = "", type = "APortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Azuremyst Isle"] .. " " .. L["Portal"] .. "\n" .. " ==> " .. L["Rut'theran"] } -- Portal Exodar to Teldrassil
            end

            if self.faction == "Horde" and not db.activate.EnemyFaction then
              nodes[12][43491624] = { mnID = 57, name = "", type = "Portal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Rut'theran"] .. " " .. L["Portal"] .. "\n" .. " ==> " .. L["Darnassus"] } -- Portal from Teldrassil to Darnassus   
              nodes[12][38990979] = { mnID = 89, name = "", type = "Portal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Darnassus"] .. " " .. L["Portal"] .. "\n" .. " ==> " .. L["Rut'theran"] } -- Portal To Teldrassil from Darnassus
            end
          end
    

          -- Kalimdor Portals without MapNotesIcons
          if self.db.profile.showContinentPortals and not self.db.profile.showContinentMapNotes then

            if self.faction == "Alliance" or db.activate.EnemyFaction then
              nodes[12][38990979] = { mnID = 57, name = "", type = "Portal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. L["Teldrassil"] } -- Portal To Teldrassil from Darnassus
              nodes[12][30752589] = { mnID = 57, name = "", type = "APortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. STORMWIND } -- Portal Exodar to Teldrassil
            end
          end

        -- Kalimdor MapNotesIcons
          if self.db.profile.showContinentMapNotes then

            if self.faction == "Horde" or db.activate.EnemyFaction then
              nodes[12][58214450] = { mnID = 85, name = "", type = "HIcon", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = ORGRIMMAR .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Portalroom"] .. "\n" .. " ==> " .. L["Silvermoon City"] .. "\n" .. " ==> " .. L["Valdrakken"] .. "\n" .. " ==> " .. L["Oribos"] .. "\n" .. " ==> " .. L["Azsuna"] .. "\n" .. " ==> " .. L["Zuldazar"] .. "\n" .. " ==> " .. L["Shattrath City"] .. "\n" .. " ==> " .. DUNGEON_FLOOR_DALARANCITY1 .. "\n" .. " ==> " .. DUNGEON_FLOOR_TANARIS18 .. "\n" .. " ==> " .. L["The Dark Portal"] .. "\n" .. " ==> " .. L["Dornogal"] .. "\n" .. "\n" .. L["Portals"] .. "\n" .. " ==> " .. POSTMASTER_LETTER_HYJAL .. "\n" .. " ==> " .. L["Twilight Highlands"] .. "\n" .. " ==> " .. ARTIFACT_SHAMAN_TITLECARD_DEEPHOLM .. "\n" .. " ==> " .. L["Vashj'ir"] .. "\n" .. " ==> " .. L["Uldum"] .. "\n" .. " ==> " .. DUNGEON_FLOOR_TOLBARADWARLOCKSCENARIO0 .. "\n" .. " ==> " .. DUNGEON_FLOOR_SURAMARRAID3 .. "\n" .. " ==> " .. POSTMASTER_LETTER_THUNDERTOTEM .. "\n" .. "\n" .. L["Zeppelins"] .. "\n" .. " ==> " .. L["Thunder Bluff"] .. "\n" .. " ==> " .. L["Grom'gol, Stranglethorn Vale"] .. "\n" .. " ==> " .. POSTMASTER_LETTER_WARSONGHOLD .. "\n" .. "\n" .. CALENDAR_TYPE_DUNGEON .. "\n" .. " ==> " .. DUNGEON_FLOOR_RAGEFIRE1 } -- Portalroom from Dazar'alor
              nodes[12][46055495] = { mnID = 88, name = "", type = "HIcon", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Thunder Bluff"] .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Zeppelin"] .. "\n" .. " ==> " .. ORGRIMMAR } -- Zeppelin from Thunder Bluff to Orgrimmar
            end

            if self.faction == "Alliance" or db.activate.EnemyFaction then
              nodes[12][38990979] = { mnID = 89, name = "", type = "AIcon", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Darnassus"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Portals"] .. "\n" .. " ==> " .. L["Rut'theran"] .. "\n" .. " ==> " .. L["Exodar"]  .. "\n" .. " ==> " .. L["Hellfire Peninsula"] } -- Portal To Teldrassil from Darnassus
              nodes[12][30752589] = { mnID = 103, name = "", type = "AIcon", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Exodar"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " ==> " .. STORMWIND } -- Portal Exodar to Teldrassil
            end
          end
    

        --Kalimdor Zeppelins
          if self.db.profile.showContinentZeppelins then

            if self.faction == "Horde" or db.activate.EnemyFaction then
              nodes[12][59814453] = { mnID = 1, name = "", type = "HZeppelin", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Zeppelin"] .. " ==> " .. L["The Waking Shores, Dragon Isles"] } -- Zeppelin from Durotar to Waking Shores - Dragonflight
            end
          end
    

        --Kalimdor Zeppelins without MapNotesIcons
          if self.db.profile.showContinentZeppelins and not self.db.profile.showContinentMapNotes then

            if self.faction == "Horde" or db.activate.EnemyFaction then
              nodes[12][45295331] = { mnID = 88, name = "", type = "HZeppelin", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Thunder Bluff"] .. " " .. L["Zeppelin"] .. "\n" .. " ==> " .. ORGRIMMAR } -- Zeppelin from Thunder Bluff to Orgrimmar
              --nodes[12][59814453] = { mnID = 1, name = "", type = "HZeppelin", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Zeppelin"] .. " ==> " .. L["The Waking Shores, Dragon Isles"] } -- Zeppelin from Durotar to Waking Shores - Dragonflight
            end
          end

    
        -- Kalimdor Ships
          if self.db.profile.showContinentShips then
            nodes[12][57735526] = { mnID = 10, name = "", type = "Ship", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Ratchet"] .. " " .. L["Ship"] .. "\n" .. " ==> " .. POSTMASTER_LETTER_STRANGLETHORNVALE } -- Ship from Ratchet to Booty Bay
    
            if self.faction == "Horde" or db.activate.EnemyFaction then
              nodes[12][62985416] = { mnID = 463, name = "", type = "HShip", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Echo Isles, Durotar"] .. " " .. L["Ship"] .. "\n" .. " ==> " .. L["Zandalar"] } -- Ship from Echo Isles to Dazar'alor - Zandalar
            end
    
            if self.faction == "Alliance" or db.activate.EnemyFaction then
              nodes[12][60046602] = { mnID = 70, name = "", type = "AShip", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Theramore Isle"] .. " " .. L["Ship"] .. "\n" .. " ==> " .. POSTMASTER_LETTER_WETLANDS } -- Ship from Dustwallow Marsh to Menethil Harbor
            end
          end


        -- Continent Kalimdor LFR
          if self.db.profile.showContinentLFR then
            nodes[12][60448275] = { mnID = 75, hideInfo = true, id = { 187 }, name = L["Auridormi"] .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " ", showOnContinent = true, showInZone = false, showOnMinimap = false, type = "LFR"}
          end

        -- Kalimdor PvpandPveVendor
          if self.db.profile.showContinentPvPandPvEVendor then
            nodes[12][56607888] = { name = "", dnID = TRANSMOG_SET_PVP .. " " .. MERCHANT .. "\n" .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. "\n" .. AUCTION_CATEGORY_WEAPONS, mnID = 71, type = "PvPVendor", showInZone = false, showOnContinent = true, showOnMinimap = false }
            
            if self.faction == "Horde" or db.activate.EnemyFaction then
              nodes[12][52124561] = { name = "", dnID = TRANSMOG_SET_PVP .. " " .. MERCHANT .. " " .. FACTION_HORDE .. "\n" .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. "\n" .. AUCTION_CATEGORY_WEAPONS, mnID = 10, type = "PvPVendorH", showInZone = false, showOnContinent = true, showOnMinimap = false }
            end
            
            if self.faction == "Alliance" or db.activate.EnemyFaction then
              nodes[12][51524394] = { name = "", dnID = TRANSMOG_SET_PVP .. " " .. MERCHANT .. " " .. FACTION_ALLIANCE .. "\n" .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. "\n" .. AUCTION_CATEGORY_WEAPONS, mnID = 63, type = "PvPVendorA", showInZone = false, showOnContinent = true, showOnMinimap = false }
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
          if self.db.profile.showContinentPassage and not db.activate.ClassicIcons then
            nodes[13][53977927] = { id = 237, type = "PassageDungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- The Temple of Atal'hakkar 
            nodes[13][40808194] = { id = 63, type = "PassageDungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Deadmines
            nodes[13][42915972] = { id = 231, type = "PassageDungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Gnomeregan             
            nodes[13][53646537] = { id = 239, name = "", type = "PassageDungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Uldaman (Secondary Entrance) 
            nodes[13][54412915] = { id = 236, lfgid = 274, type = "PassageDungeon", showOnContinent = true, showInZone = false, showOnMinimap = false }-- Stratholme Service Entrance 
            nodes[13][46886972] = { mnID = 33, hideInfo = true, id = { 741, 742, 66, 228, 229, 559 }, type = "PassageDungeonRaidMulti", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Molten Core, Blackwing Lair, Blackrock Caverns, Blackrock Depths, Lower Blackrock Spire, Upper Blackrock Spire 
          end
    
        --Kalimdor Passage without ClassicIcons and without MapNotesIcons
          if self.db.profile.showContinentDungeons and not db.activate.ClassicIcons and not self.db.profile.showContinentMapNotes then
            nodes[13][42787097] = { id = 238, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- The Stockade  
          end

        --Kalimdor Dungeon without EnemyFaction and MapNotesIcons
          if not db.activate.EnemyFaction and self.db.profile.showContinentMapNotes then
            
            if self.faction == "Horde" or db.activate.EnemyFaction then
              nodes[13][42787097] = { id = 238, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- The Stockade 
            end
          end

        --Eastern Kingdom ClassicIcons

        if db.activate.ClassicIcons then

          if self.db.profile.showContinentDungeons then
            nodes[13][53977927] = { id = 237, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- The Temple of Atal'hakkar 
            nodes[13][40808194] = { id = 63, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Deadmines
            nodes[13][42915972] = { id = 231, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Gnomeregan    
            --nodes[13][53646537] = { id = 239, name = "", type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Uldaman (Secondary Entrance) 
            --nodes[13][54412915] = { id = 236, lfgid = 274, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false }-- Stratholme Service Entrance 
          end

          if self.db.profile.showContinentMultiple then
            nodes[13][46886972] = { mnID = 33, hideInfo = true, id = { 741, 742, 66, 228, 229, 559 }, type = "MultipleM", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Molten Core, Blackwing Lair, Blackrock Caverns, Blackrock Depths, Lower Blackrock Spire, Upper Blackrock Spire 
          end

        end

        --Eastern Kingdom Multiple
          if self.db.profile.showContinentMultiple then
            nodes[13][49428163] = { mnID = 42, hideInfo = true, id = { 745, 860 }, type = "MultipleM", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Karazhan, Return to Karazhan
            nodes[13][46583029] = { mnID = 19, hideInfo = true, id = { 311, 316 }, type = "MultipleD", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Scarlet Halls, Monastery 
            nodes[13][52176317] = { mnID = 15, hideInfo = true, id = { 1197, 239 }, type = "MultipleD", showOnContinent = true, showInZone = false, showOnMinimap = false } --  Legacy of Tyr Dragonflight Dungeon & Vanilla Uldaman 
          end
    
    
        --Eastern Kingdom Portals
          if self.db.profile.showContinentPortals then
    
            nodes[13][52448472] = { mnID = 17, name = "", type = "Portal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["The Dark Portal"] .. "\n" .. "\n" .. FACTION_HORDE .. "\n" .. " ==> " .. L["Warspear"] .. "\n" .. "\n" .. FACTION_ALLIANCE .. "\n" .. " ==> " .. L["Stormshield"] } -- Portal from Tanaris to Orgrimmar 

            if self.faction == "Horde" or db.activate.EnemyFaction then
              nodes[13][49764414] = { mnID = 14, name = "", type = "HPortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. L["Zandalar"] .. "\n" .. " " .. "(" .. L["This Arathi Highlands portal is only active if your faction is currently occupying Ar'gorok"] .. ")" } -- Portal from Arathi to Zandalar 
              nodes[13][33874948] = { mnID = 245, name = "", type = "HPortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = DUNGEON_FLOOR_TOLBARADWARLOCKSCENARIO0 .. " " .. L["Portal"] .. "\n" .. " ==> " .. ORGRIMMAR } -- Portal Tol Barad to Orgrimmar
              nodes[13][60195610] = { mnID = 241, name = "", type = "HPortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Twilight Highlands"] .. " " .. L["Portal"] .. "\n" .. " ==> " .. ORGRIMMAR } -- Portal To Orgrimmar from Twilight Highlands  
              nodes[13][54128434] = { mnID = 17, name = "", type = "HPortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Blasted Lands"] .. " " .. L["Portal"] .. "\n" .. " ==> " .. ORGRIMMAR } -- Portal To Orgrimmar from Blasted Lands
            end
    
            if self.faction == "Alliance" or db.activate.EnemyFaction then
              nodes[13][44357591] = { mnID = 37, name = FACTION_ALLIANCE .. " " .. L["Portal"] .. " ==> " .. CALENDAR_FILTER_DARKMOON, showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = "\n" .. REQUIRES_LABEL .. " " .. CALENDAR_FILTER_DARKMOON .. "\n" .. L["Starting on the first Sunday of each month for one week"], type = "DarkMoon" } -- Elwynn Forest Portal to the Darkmoon
              nodes[13][60805911] = { mnID = 241, name = "", type = "APortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Twilight Highlands"] .. " " .. L["Portal"] .. "\n" .. " ==> " .. STORMWIND } -- Portal To Stormwind from Twilight Highlands  
              nodes[13][53428254] = { mnID = 17, name = "", type = "APortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Blasted Lands"] .. " " .. L["Portal"] .. "\n" .. " ==> " .. STORMWIND } -- Portal to Stormwind from Blasted Lands
              nodes[13][35134883] = { mnID = 245, name = "", type = "APortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = DUNGEON_FLOOR_TOLBARADWARLOCKSCENARIO0 .. " " .. L["Portal"] .. "\n" .. " ==> " .. STORMWIND } -- Portal Tol Barad to Stormwind
              nodes[13][49544708] = { mnID = 14, name = "", type = "APortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. L["Boralus"] .. "\n" .. " " .. "(" .. L["This Arathi Highlands portal is only active if your faction is currently occupying Ar'gorok"] .. ")" } -- Portal from Arathi to Zandalar
            end
          end
    

        --Eastern Kingdom Portals without MapNotesIcons
        if self.db.profile.showContinentPortals and not self.db.profile.showContinentMapNotes then

          if self.faction == "Horde" or db.activate.EnemyFaction then
          nodes[13][43993336] = { mnID = 18, name = "", type = "HPortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Tirisfal Glades"] .. " " .. L["Portal"] .. "\n" .. " ==> " .. ORGRIMMAR .. "\n" .. " ==> " .. L["Grom'gol, Stranglethorn Vale"] .. "\n" .. " ==> " .. L["Howling Fjord"] .. "\n" .. " ==> " .. L["Silvermoon City"] } -- Portal to Orgrimmar, Silvermoon, Howling Fjord and Grom'gol from Tirisfal
          nodes[13][55751269] = { mnID = 110, name = "", type = "HPortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Silvermoon City"] .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " ==> " .. ORGRIMMAR .. "\n" .. " ==> " .. L["Ruins of Lordaeron"] } -- Portal to Orgrimmar, Ruins of Lordaeron from Silvermoon   
          end
        end


        -- Eastern Kingdom Zeppelins without MapNotesIcons
          if self.db.profile.showContinentZeppelins and not self.db.profile.showContinentMapNotes then

            if self.faction == "Horde" or db.activate.EnemyFaction then
              nodes[13][42728658] = { mnID = 50, name = "", type = "HZeppelin", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Grom'gol, Stranglethorn Vale"] .. " " .. L["Zeppelin"] .. "\n" .. " ==> " .. ORGRIMMAR } -- Zeppelin from Stranglethorn Valley to Ogrimmar
            end
          end


        -- Eastern Kingdom MapNotesIcons
          if self.db.profile.showContinentMapNotes then

            if self.faction == "Horde" or db.activate.EnemyFaction then
              nodes[13][43263464] = { mnID = 18, name = "", type = "HIcon", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Undercity"] .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " ==> " .. L["Hellfire Peninsula"] .. "\n" .. "\n" .. L["Ruins of Lordaeron"]  .. " / " .. L["Tirisfal Glades"] .. "\n" .. "\n" .. L["Portals"] .. "\n" ..  " ==> " .. ORGRIMMAR .. "\n" .. " ==> " .. L["Grom'gol, Stranglethorn Vale"] .. "\n" .. " ==> " .. L["Howling Fjord"] .. "\n" .. " ==> " .. L["Silvermoon City"] } -- Portal to Orgrimmar, Silvermoon, Howling Fjord and Grom'gol from Tirisfal
              nodes[13][56471480] = { mnID = 110, name = "", type = "HIcon", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Silvermoon City"] .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Portals"] .. "\n" ..  " ==> " .. ORGRIMMAR .. "\n" .. " ==> " .. L["Ruins of Lordaeron"] } -- Portal to Orgrimmar, Ruins of Lordaeron from Silvermoon
              nodes[13][44168671] = { mnID = 50, name = "", type = "HIcon", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Grom'gol, Stranglethorn Vale"] .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Zeppelin"] .. "\n" .. " ==> " .. ORGRIMMAR .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " ==> " .. L["Ruins of Lordaeron"] } -- Transport from Stranglethorn Valley to Ogrimmar and Ruins of Lordaeron
            end

            if self.faction == "Alliance" or db.activate.EnemyFaction then
              nodes[13][47275888] = { mnID = 87, name = "", type = "AIcon", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Ironforge"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. DUNGEON_FLOOR_DEEPRUNTRAM1 .. "\n" .. " ==> " .. STORMWIND } -- Transport to Ironforge Carriage 
              nodes[13][42937289] = { mnID = 84, name = "", type = "AIcon", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = STORMWIND .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Portalroom"] .. "\n" .. " ==> " .. L["Ashran"] .. "\n" .. " ==> " .. L["Valdrakken"] .. "\n" .. " ==> " .. L["Boralus, Tiragarde Sound"] .. "\n" .. " ==> " .. L["Oribos"] .. "\n" .. " ==> " .. L["Azsuna"] .. "\n" .. " ==> " .. L["Shattrath City"] .. "\n" .. " ==> " .. L["Jade Forest"] .. "\n" .. " ==> " .. DUNGEON_FLOOR_DALARANCITY1 .. "\n" .. " ==> " .. DUNGEON_FLOOR_TANARIS18 .. "\n" .. " ==> " .. L["Exodar"] .. "\n" ..  " ==> " .. L["Bel'ameth, Amirdrassil"] .. "\n" .. " ==> " .. L["The Dark Portal"] .. "\n" .. " ==> " .. L["Dornogal"] .. "\n" .. "\n" .. L["Portals"] .. "\n" ..  "\n" .. " ==> " .. L["Uldum"] .. "\n" .. " ==> " .. L["Vashj'ir"] .. "\n" .. " ==> " .. POSTMASTER_LETTER_HYJAL .. "\n" .. " ==> " .. ARTIFACT_SHAMAN_TITLECARD_DEEPHOLM .. "\n" .. " ==> " .. L["Twilight Highlands"] .. "\n" .. " ==> " .. DUNGEON_FLOOR_TOLBARADWARLOCKSCENARIO0 .. "\n" .. "\n" .. L["Ships"] .. "\n" .. " ==> " .. POSTMASTER_LETTER_VALIANCEKEEP .. "\n" .. " ==> " .. L["Boralus, Tiragarde Sound"] .. "\n" .. " ==> " .. L["The Waking Shores, Dragon Isles"] .. "\n" .. "\n" .. DUNGEON_FLOOR_DEEPRUNTRAM1 .. "\n" .. " ==> " .. L["Ironforge"] .. "\n" .. "\n" .. " ==> " .. CALENDAR_TYPE_DUNGEON .. "\n" .. " ==> " .. DUNGEON_FLOOR_THESTOCKADE1 } -- Portalroom from Stormwind
            end
          end
    

        --Eastern Kingdom Ships
          if self.db.profile.showContinentShips then
            nodes[13][41115043] = { mnID = 217, name = "", type = "Ship", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Ruins of Gilneas"] .. " " .. L["Ship"] .. "\n" .. " ==> " .. L["Bel'ameth, Amirdrassil"] } -- Ship from Gilneas to Bel ameth
            nodes[13][42379354] = { mnID = 210, name = "", type = "Ship", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = POSTMASTER_LETTER_STRANGLETHORNVALE .. " " .. L["Ship"] .. "\n" .. " ==> " .. L["Ratchet"] } -- Ship from Booty Bay to Ratchet
            
            if self.faction == "Alliance" or db.activate.EnemyFaction then
              nodes[13][46665454] = { mnID = 56, name = "", type = "AShip", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = POSTMASTER_LETTER_WETLANDS .." " .. L["Ships"] .. "\n" .. " ==> " .. L["Theramore Isle"] .. "\n" .. " ==> " .. L["Howling Fjord"] } -- Ship from Stormwind to Borean Tundra
            end
          end
    

        -- Eastern Kingdom Ships without MapNotesIcons
          if self.db.profile.showContinentShips and not self.db.profile.showContinentMapNotes then
          
            if self.faction == "Alliance" or db.activate.EnemyFaction then
              nodes[13][40967129] = { mnID = 84, name = "", type = "AShip", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Ship"] .. "\n" .. " " .. STORMWIND .. " ==> " .. POSTMASTER_LETTER_VALIANCEKEEP } -- Ship from Stormwind to Valiance Keep
              nodes[13][41187327] = { mnID = 84, name = "", type = "AShip", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Ship"] .. "\n" .. " " .. STORMWIND .. " ==> " .. L["Boralus, Tiragarde Sound"] } -- Ship from Stormwind to Valiance Keep
            end
          end


        --Eastern Kingdom Zeppelins
          if self.db.profile.showContinentZeppelins then

            if self.faction == "Horde" or db.activate.EnemyFaction then
              --nodes[13][43968695] = { mnID = 50, name = "", type = "HZeppelin", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Zeppelin"] .. " ==> " .. ORGRIMMAR } -- Zeppelin from Stranglethorn Valley to Ogrimmar
            end

          end

        -- Eastern Kingdom Transport and not MapNotesIcons
          if self.db.profile.showContinentTransport and not self.db.profile.showContinentMapNotes then

            nodes[13][47275888] = { mnID = 87, name = "", type = "Carriage", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = DUNGEON_FLOOR_DEEPRUNTRAM1 .. " ==> " .. L["Ironforge"] } -- Transport to Ironforge Carriage 
          end
    
        --Eastern Kingdom ContinentOldVanilla
          if self.db.profile.showContinentOldVanilla then
            nodes[13][54113049] = { mnID = 166, name = L["Secret Entrance"] .. " " .. L["(Wards of the Dread Citadel - Achievement)"] .. " - " .. L["Old Version"], type = "VInstanceR", showOnContinent = true, showInZone = false, showOnMinimap = false }-- Old Naxxramas version - Secret Entrance - Wards of the Dread Citadel 
            nodes[13][46703243] = { mnID = 19, name = L["Use the Old Keyring"], dnID = L["Graveyard"] .. " - " .. L["Old Version"] .. "\n" .. L["Cathedral"] .. " - " .. L["Old Version"] .. "\n" .. L["Library"] .. " - " .. L["Old Version"] .. "\n" .. L["Armory"] .. " - " .. L["Old Version"], type = "MultiVInstanceD", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Scarlet Monastery Key for Old dungeons
            nodes[13][51383556] = { mnID = 306, name = L["Secret Entrance"] .. " " .. L["(Memory of Scholomance - Achievement)"] .. " - " .. L["Old Version"], type = "VInstanceD", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Old Scholomance version - Memory of Scholomance - Secret Entrance Old Scholomance version 
          end

        -- Eastern Kingdom PvpandPveVendor
          if self.db.profile.showContinentPvPandPvEVendor then
            
            if self.faction == "Horde" or db.activate.EnemyFaction then
              nodes[13][53144389] = { name = "", dnID = TRANSMOG_SET_PVP .. " " .. MERCHANT .. " " .. FACTION_HORDE .. "\n" .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. "\n" .. AUCTION_CATEGORY_WEAPONS, mnID = 14, type = "PvPVendorH", showInZone = false, showOnContinent = true, showOnMinimap = false }
              nodes[13][47043956] = { name = "", dnID = TRANSMOG_SET_PVP .. " " .. MERCHANT .. " " .. FACTION_HORDE .. "\n" .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. "\n" .. AUCTION_CATEGORY_WEAPONS, mnID = 25, type = "PvPVendorH", showInZone = false, showOnContinent = true, showOnMinimap = false }
            end
            
            if self.faction == "Alliance" or db.activate.EnemyFaction then
              nodes[13][50474530] = { name = "", dnID = TRANSMOG_SET_PVP .. " " .. MERCHANT .. " " .. FACTION_ALLIANCE .. "\n" .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. "\n" .. AUCTION_CATEGORY_WEAPONS, mnID = 14, type = "PvPVendorA", showInZone = false, showOnContinent = true, showOnMinimap = false }
              nodes[13][45364099] = { name = "", dnID = TRANSMOG_SET_PVP .. " " .. MERCHANT .. " " .. FACTION_ALLIANCE .. "\n" .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. "\n" .. AUCTION_CATEGORY_WEAPONS, mnID = 25, type = "PvPVendorA", showInZone = false, showOnContinent = true, showOnMinimap = false }
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
            nodes[101][56695240] = { mnID = 100, hideInfo = true, id = { 747, 248, 256, 259 }, type = "MultipleM", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Hellfire Ramparts, The Blood Furnace, The Shattered Halls, Magtheridon's Lair 
            nodes[101][34624490] = { mnID = 102, hideInfo = true, id = { 748, 260, 261, 262 }, type = "MultipleM", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Slave Pens, The Steamvault, The Underbog, Serpentshrine Cavern
          end
    
    
        -- Outland Portals
          if self.db.profile.showContinentPortals then
                        
            if self.faction == "Horde" or db.activate.EnemyFaction then
              nodes[101][69025178] = { mnID = 100, name = "", type = "HPortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Hellfire Peninsula"] .. " " .. L["Portal"] .. "\n" .. " ==> " .. ORGRIMMAR } -- Portal from Hellfire to Orgrimmar 

            end
    
            if self.faction == "Alliance" or db.activate.EnemyFaction then
              nodes[101][68905259] = { mnID = 100,  name = "" , type = "APortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Hellfire Peninsula"] .. " " .. L["Portal"] .. "\n" .. " ==> " .. STORMWIND } -- Portal from Hellfire to Stormwind 
            end
          end


        -- Outland Portals
          if self.db.profile.showContinentPortals and not self.db.profile.showContinentMapNotes then
            nodes[101][43186574] = { mnID = 108, name = "", type = "Portal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Shattrath City"] .. " " .. L["Portals"] .. "\n" ..  "\n" .. " ==> " .. ORGRIMMAR .. "\n" .. " ==> " .. STORMWIND .. "\n" .. " ==> " .. L["Isle of Quel'Danas"] } -- Portal from Shattrath to Orgrimmar
          end

        -- Outland MapNotesIcons 
          if self.db.profile.showContinentMapNotes then
            nodes[101][43186573] = { mnID = 108, name = "", type = "MNL", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Shattrath City"] .. "\n" .. "\n" .. L["Portals"] .. "\n" .. " ==> " .. ORGRIMMAR .. "\n" .. " ==> " .. STORMWIND .. "\n" .. " ==> " .. L["Isle of Quel'Danas"] } -- Portal from Shattrath to Orgrimmar
          end

        -- Outland PvpandPveVendor
          if self.db.profile.showContinentPvPandPvEVendor then
            nodes[101][53442348] = { name = "", dnID = TRANSMOG_SET_PVP .. " " .. MERCHANT .. "\n" .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. "\n" .. AUCTION_CATEGORY_WEAPONS, mnID = 109, type = "PvPVendor", showInZone = false, showOnContinent = true, showOnMinimap = false }
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
            nodes[113][40595892] = { mnID = 115, hideInfo = true, id = { 271, 272 }, type = "MultipleD", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Ahn'kahet The Old Kingdom, Azjol-Nerub        
            nodes[113][41154408] = { mnID = 118, hideInfo = true, id = { 276, 278, 280 }, type = "MultipleD", showOnContinent = true, showInZone = false, showOnMinimap = false } -- The Forge of Souls, Halls of Reflection, Pit of Saron         
            nodes[113][47652029] = { mnID = 118, hideInfo = true, id = { 757, 284 }, type = "MultipleM", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Trial of the Crusader, Trial of the Champion 
            nodes[113][14725757] = { mnID = 114, hideInfo = true, id = { 756, 282, 281 }, type = "MultipleM", showOnContinent = true, showInZone = false, showOnMinimap = false } -- The Eye of Eternity, The Nexus, The Oculus
            nodes[113][50346038] = { mnID = 115, hideInfo = true, id = { 755, 761 }, type = "MultipleR", showOnContinent = true, showInZone = false, showOnMinimap = false } -- The Ruby Sanctum, The Obsidian Sanctum 
          end
    
    
        -- Northrend Portal
          if self.db.profile.showContinentPortals then
            nodes[113][36504679] = { mnID = 123, name = "", type = "Portal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Wintergrasp"] .. " " .. L["Portal"] .. "\n" .. " ==> " .. DUNGEON_FLOOR_DALARANCITY1 } -- LakeWintergrasp to Dalaran Portal
            nodes[113][47804060] = { mnID = 125, name = "", type = "Portal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = DUNGEON_FLOOR_DALARANCITY1 .. " " .. L["Portals"] .. "\n" ..  "\n" .. " ==> " .. ORGRIMMAR .. "\n" .. " ==> " .. STORMWIND } --  Dalaran Portal to Orgrimmar and Stormwind
            nodes[113][24264914] = { mnID = 119, name = "", type = "Portal", showOnContinent = true, showInZone = false, showOnMinimap = false,TransportName = L["Sholazar Basin"] .. " " .. L["Portal"] .. "\n" .. " ==> " .. L["Un'Goro Crater"] } --  Portal to Unguro
          end
    
    
        -- Northrend Zeppelin
          if self.db.profile.showContinentZeppelins then 
    
            if self.faction == "Horde" or db.activate.EnemyFaction then
              nodes[113][18766562] = { mnID = 114, name = "", type = "HZeppelin", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = POSTMASTER_LETTER_WARSONGHOLD .. " " .. L["Zeppelin"] .. " ==> " .. ORGRIMMAR } -- Zeppelin from Borean Tundra to Ogrimmar
            end
          end
    
    
        -- Northrend Ships
          if self.db.profile.showContinentShips then
            nodes[113][65218245] = { mnID = 117, name = "", type = "Ship", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = POSTMASTER_LETTER_KAMAGUA .. " " .. L["Ship"] .. "\n" .. " ==> " .. POSTMASTER_LETTER_MOAKI } -- Ship from Kamagua to Moaki
            nodes[113][47806841] = { mnID = 115, name = "", type = "Ship", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = POSTMASTER_LETTER_MOAKI .. " " .. L["Ship"] .. "\n" .. " ==> " .. POSTMASTER_LETTER_KAMAGUA } -- Ship from Moaki to Kamagua
            nodes[113][30056677] = { mnID = 114, name = "", type = "Ship", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Borean Tundra"] .. " " .. L["Ship"] .. "\n" .. " ==> " .. POSTMASTER_LETTER_MOAKI } -- Ship from Unu'pe to Moaki
            nodes[113][46406841] = { mnID = 115, name = "", type = "Ship", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = POSTMASTER_LETTER_MOAKI .. " " .. L["Ship"] .. "\n" .. " ==> " .. L["Borean Tundra"] } -- Ship from Moaki to Unu'pe

            if self.faction == "Alliance" or db.activate.EnemyFaction then
              nodes[113][25377045] = { mnID = 114, name = "", type = "AShip", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = POSTMASTER_LETTER_VALIANCEKEEP .. " " ..  L["Ship"] .. "\n" .. " ==> " .. STORMWIND } -- Ship from Borean Tundra to Stormwind
              nodes[113][79788368] = { mnID = 117, name = "", type = "AShip", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Howling Fjord"] .. " " .. L["Ship"] .. "\n" .. " ==> " .. POSTMASTER_LETTER_WETLANDS } -- Ship from Howling Fjord to Wetlands
            end
          end

        -- Northrend PvpandPveVendor
          if self.db.profile.showContinentPvPandPvEVendor then
            nodes[113][49032027] = { name = "", dnID = TRANSMOG_SET_PVE .. " " .. MERCHANT .. "\n" .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. "\n" .. AUCTION_CATEGORY_WEAPONS, mnID = 118, type = "PvEVendor", showInZone = false, showOnContinent = true, showOnMinimap = false }
            nodes[113][41133952] = { name = "", dnID = TRANSMOG_SET_PVE .. " " .. MERCHANT, mnID = 118, type = "PvEVendor", showInZone = false, showOnContinent = true, showOnMinimap = false }
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
            nodes[424][47015340] = { id = 1180, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false, dnID = L["Instance Entrance"] .. " " .. L["switches weekly between"] .. " " .. L["Uldum"] .. " (" .. L["Kalimdor"] ..")" .. " & " .. L["Vale of Eternal Blossoms"] .. " (" .. L["Pandaria"] .. ")" } -- Ny'Alotha, The Waking City

          end
    
    
        -- Pandaria Portals
          if self.db.profile.showContinentPortals then
    
            if self.faction == "Horde" or db.activate.EnemyFaction then
              nodes[424][59733518] = { mnID = 371, name = "", type = "HPortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Jade Forest"] .. " " .. L["Portal"] .. "\n" .. " ==> " .. ORGRIMMAR } -- Portal from Jade Forest to Orgrimmar
              nodes[424][17970919] = { mnID = 504, name = "", type = "HPortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Isle of Thunder"] .. " " .. L["Portals"] .. "\n" ..  "\n" .. " ==> " .. L["Shado-Pan Garrison, Townlong Steppes"] } -- Portal from Isle of Thunder to Shado-Pan Garrison
              nodes[424][29444738] = { mnID = 388, name = "", type = "HPortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Shado-Pan Garrison, Townlong Steppes"] .. " " .. L["Portal"] .. "\n" .. " ==> " .. L["Isle of Thunder"] } -- Portal from Shado-Pan Garrison to Isle of Thunder
              nodes[424][50604810] = { mnID = 392, name = "", type = "HPortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Vale of Eternal Blossoms"] .. " " .. L["Portals"] .. "\n" ..  "\n" .. " ==> " .. ORGRIMMAR } -- Portal from Vale of Eternal Blossoms to Orgrimmar
              nodes[424][40508161] = { mnID = 418, name = "", type = "HPortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Krasarang Wilds"] .. " " .. L["Portal"] .. "\n" ..  "\n" .. " ==> " .. L["Silvermoon City"] } -- Portal to Silvermoon
            end

            if self.faction == "Alliance" or db.activate.EnemyFaction then
              nodes[424][67806740] = { mnID = 371, name = "", type = "APortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Jade Forest"] .. " " .. L["Portals"] .. "\n" ..  "\n" .. " ==> " .. STORMWIND } -- Portal from Jade Forest to Stormwind
              nodes[424][23891588] = { mnID = 504, name = "", type = "APortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Isle of Thunder"] .. " " .. L["Portals"] .. "\n" ..  "\n" .. " ==> " .. L["Shado-Pan Garrison, Townlong Steppes"] } -- Portal from Isle of Thunder to Shado-Pan Garrison
              nodes[424][28894622] = { mnID = 388, name = "", type = "APortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Shado-Pan Garrison, Townlong Steppes"] .. " " .. L["Portal"] .. "\n" .. " ==> " .. L["Isle of Thunder"] } -- Portal from Shado-Pan Garrison to Isle of Thunder
              nodes[424][54785688] = { mnID = 394, name = "", type = "APortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Vale of Eternal Blossoms"] .. " " .. L["Portals"] .. "\n" ..  "\n" .. " ==> " .. STORMWIND } -- Portal from Vale of Eternal Blossoms to Stormwind
            end
          end


        -- Pandaria LFR
          if self.db.profile.showContinentLFR then
            nodes[424][53805057] = { mnID = 390, hideInfo = true, id = { 317, 330, 362, 320 }, name = L["Lorewalker Han"] .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " ", showOnContinent = true, showInZone = false, showOnMinimap = false , type = "LFR"}
          end

        -- Pandaria PvpandPveVendor
          if self.db.profile.showContinentPvPandPvEVendor then
            nodes[424][24574389] = { name = "", dnID = TRANSMOG_SET_PVE .. " " .. MERCHANT .. "\n" .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. "\n" .. AUCTION_CATEGORY_WEAPONS, mnID = 388, type = "PvEVendor", showInZone = false, showOnContinent = true, showOnMinimap = false }
          
            if self.faction == "Horde" or db.activate.EnemyFaction then
              nodes[424][39394352] = { name = "", dnID = TRANSMOG_SET_PVP .. " " .. MERCHANT .. " " .. FACTION_HORDE .. "\n" .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. "\n" .. AUCTION_CATEGORY_WEAPONS, mnID = 379, type = "PvPVendorH", showInZone = false, showOnContinent = true, showOnMinimap = false }
            end

            if self.faction == "Alliance" or db.activate.EnemyFaction then
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
              nodes[424][67895590] = { name = L["Herbalism"], type = "Herbalism", questID = 29824, wwwName = LFG_LIST_REQUIRE .. " " .. STORY_PROGRESS, showWWW = true, wwwLink = "wowhead.com/quest=29824", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
              nodes[424][43874801] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
              nodes[424][48314179] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
              nodes[504][33503380] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
            end

            if self.faction == "Alliance" then
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
    
            if self.faction == "Horde" or db.activate.EnemyFaction then
              nodes[572][71343912] = { mnID = 624, name = "", type = "HPortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Ashran"] .. " " .. L["Portal"] .. "\n" .. " ==> " .. ORGRIMMAR .. "\n" .. " ==> " .. L["Vol'mar"] } -- Portal from Ashran to Orgrimmar
              nodes[572][60424574] = { mnID = 534, name = "", type = "HPortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Vol'mar"] .. " " .. L["Portal"] .. "\n" .. " ==> " .. L["Ashran"] } -- Portal from Vol'mar to Ashran
              nodes[572][34663659] = { mnID = 590, name = "", type = "HPortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = GARRISON_LOCATION_TOOLTIP .. " " .. L["Portal"] .. "\n" .. " ==> " .. L["Ashran"] } -- Portal from Garrison to Ashran
            end
    
            if self.faction == "Alliance" or db.activate.EnemyFaction then
              nodes[572][59544876] = { mnID = 534, name = "", type = "APortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. L["Ashran"] } -- Portal from Lion's Watch to (Ashran Zone)
              nodes[572][71674912] = { mnID = 622,  name = "" , type = "APortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName =  L["Ashran"] .. " " .. L["Portal"] .. "\n" .. " ==> " .. STORMWIND .. "\n" .. " ==> " .. SPLASH_NEW_6_2_FEATURE1_TITLE } -- Portal from Ashran to Stormwind
              nodes[572][53396082] = { mnID = 582, name = "", type = "APortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = GARRISON_LOCATION_TOOLTIP .. " " .. L["Portal"] .. "\n" .. " ==> " .. L["Ashran"] } -- Portal from Garrison to Ashran
            end
          end

         --Draenor LFR
          if self.db.profile.showContinentLFR then
            
            if self.faction == "Horde" or db.activate.EnemyFaction then
              nodes[572][33793621] = { mnID = 590, hideInfo = true, id = { 477, 457, 669 }, type = "LFR", showOnContinent = true, showInZone = false, showOnMinimap = false, name = L["Seer Kazal"] .. " - " .. REQUIRES_LABEL .. " " .. GARRISON_LOCATION_TOOLTIP .. " " .. LEVEL .. " " .. ACTION_SPELL_CAST_START_MASTER .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " " }
            end
            
            if self.faction == "Alliance" or db.activate.EnemyFaction then
              nodes[572][51886044] = { mnID = 582, hideInfo = true, id = { 477, 457, 669 }, type = "LFR", showOnContinent = true, showInZone = false, showOnMinimap = false, name = L["Seer Kazal"] .. " - " .. REQUIRES_LABEL .. " " .. GARRISON_LOCATION_TOOLTIP .. " " .. LEVEL .. " " .. ACTION_SPELL_CAST_START_MASTER .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " " }
            end
          end

        -- Draenor PvpandPveVendor
          if self.db.profile.showContinentPvPandPvEVendor then

            if self.faction == "Horde" or db.activate.EnemyFaction then
              nodes[572][71454121] = { name = "", dnID = TRANSMOG_SET_PVP .. " " .. MERCHANT .. " " .. FACTION_HORDE .. "\n" .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. "\n" .. AUCTION_CATEGORY_WEAPONS, mnID = 624, type = "PvPVendorH", showInZone = false, showOnContinent = true, showOnMinimap = false }
            end

            if self.faction == "Alliance" or db.activate.EnemyFaction then
              nodes[572][71524649] = { name = "", dnID = TRANSMOG_SET_PVP .. " " .. MERCHANT .. " " .. FACTION_ALLIANCE .. "\n" .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. "\n" .. AUCTION_CATEGORY_WEAPONS, mnID = 622, type = "PvPVendorA", showInZone = false, showOnContinent = true, showOnMinimap = false }
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
            nodes[619][51395567] = { mnID = 860, name = "", type = "Portal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Portal"] .. "\n" .. " ==> " .. ORGRIMMAR .. "\n"  .. " ==> " .. STORMWIND } --  Dalaran to Orgrimmar Portal

            if self.faction == "Horde" or db.activate.EnemyFaction then
              nodes[619][45606186] = { mnID = 627, name = "", type = "HPortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. ORGRIMMAR } --  Dalaran to Orgrimmar Portal
              nodes[619][33715775] = { mnID = 630, name = "", type = "HPortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. ORGRIMMAR } -- Portal to Orgrimmar from Azsuna
            end
    
            if self.faction == "Alliance" or db.activate.EnemyFaction then
              nodes[619][45296767] = { mnID = 627,  name = "" , type = "APortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. STORMWIND } --  Portal from Dalaran to Stormwind
              nodes[619][32905786] = { mnID = 630,  name = "" , type = "APortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. STORMWIND } -- Portal to Stormwind from Azsuna
             end
          end


        -- Broken Isles LFR
          if self.db.profile.showContinentLFR then
            nodes[619][46806495] = { mnID = 627, hideInfo = true, id = { 875, 786, 768, 861, 946 }, name = L["Archmage Timear"] .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " ", type = "LFR", showOnContinent = true, showInZone = false, showOnMinimap = false }
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
          
            if self.faction == "Horde" or db.activate.EnemyFaction then
              nodes[875][57757046] = { id = 1012, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- The MOTHERLODE HORDE
            end
          
            if self.faction == "Alliance" or db.activate.EnemyFaction then
              nodes[875][45457850] = { id = 1012, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- The MOTHERLODE Alliance
            end
          end
    
    
        --Zandalar Raids
          if self.db.profile.showContinentRaids then
            nodes[875][59413469] = { id = 1031, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Uldir
            nodes[875][86731430] = {  id = 1179, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- The Eternal Palace 
            if self.faction == "Horde" or db.activate.EnemyFaction then
            nodes[875][56005350] = { id = 1176, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Battle of Dazar'alor
            end
          end
    
    
        -- Zandalar Portals
          if self.db.profile.showContinentPortals then
    
            if self.faction == "Horde" or db.activate.EnemyFaction then
              nodes[875][58486162] = { mnID = 1163, name = "", type = "HPortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Dazar'alor"] .. "\n" .. "\n" .. L["Portalroom"] .. "\n" .. " ==> " .. L["Silvermoon City"] .. "\n" .. " ==> " .. ORGRIMMAR .. "\n" .. " ==> " .. L["Thunder Bluff"] .. "\n" .. " ==> " .. L["Silithus"] .. "\n" .. " ==> " .. L["Nazjatar"] } -- Portalroom from Dazar'alor
              nodes[875][59107238] = { mnID = 1165, name = "", type = "HPortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Zandalar"] .. " " .. L["Portals"] .. "\n" ..  "\n" .. " ==> " .. L["This Darkshore portal is only active if your faction is currently occupying Bashal'Aran"] .. "\n" .. " ==> " .. L["This Arathi Highlands portal is only active if your faction is currently occupying Ar'gorok"] } -- Portal to Arathi and Darkshore
            end
          end
    

        -- Zandalar MapNotesIcons
          if self.db.profile.showContinentMapNotes then
    
            if self.faction == "Horde" or db.activate.EnemyFaction then
              nodes[875][58486162] = { mnID = 1163, hideInfo = true, id = { 1176, 1031, 1179, 1036 }, type = "HIcon", showOnContinent = true, showInZone = false, showOnMinimap = false, name = L["Dazar'alor"] .. "\n" .. "\n" .. L["Portalroom"] .. "\n" .. " ==> " .. L["Silvermoon City"] .. "\n" .. " ==> " .. ORGRIMMAR .. "\n" .. " ==> " .. L["Thunder Bluff"] .. "\n" .. " ==> " .. L["Silithus"] .. "\n" .. " ==> " .. L["Nazjatar"] .. "\n" .. " " .. "\n" .. L["Eppu"] .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " ",} -- Portalroom from Dazar'alor
            end
          end 

    
        -- Zandalar Ships
          if self.db.profile.showContinentShips then
    
            if self.faction == "Horde" or db.activate.EnemyFaction then
              nodes[875][57957497] = { mnID = 463, name = "", type = "HShip", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Ship"] .. " ==> " .. L["Echo Isles, Durotar"] } -- Ship from Zandalar to Echo Isles 
            end
    
            if self.faction == "Alliance" or db.activate.EnemyFaction then

            end

          end


        -- Zandalar Transport
          if self.db.profile.showContinentTransport then

            if self.faction == "Horde" or db.activate.EnemyFaction then
              nodes[875][56027038] = { mnID = 876, name = L["(Dread-Admiral Tattersail) will take you to Drustvar, Tiragarde Sound or Stormsong Valley"], type = "Travel", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Ship from Dazar'alor to Drustvar, Tiragarde Sound or Stormsong Valley
            end

            if self.faction == "Alliance" or db.activate.EnemyFaction then
              nodes[875][33051846] = { mnID = 864, name = L["Barnard 'The Smasher' Bayswort"] .. " - " .. L["Travel"], type = "KulM", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = " " .. ITEM_REQ_ALLIANCE .. "\n" .. "\n" .. " ==> " .. L["Boralus, Tiragarde Sound"] } -- Transport from Vol'dun to Boralus
              nodes[875][62402600] = { mnID = 863, name = L["Desha Stormwallow"] .. " - " .. L["Travel"], type = "DwarfF", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = " " .. ITEM_REQ_ALLIANCE .. "\n" .. "\n" .. " ==> " .. L["Boralus, Tiragarde Sound"] } -- Transport from Nazmir to Boralus
              nodes[875][47177779] = { mnID = 862, name = L["Daria Smithson"] .. " - " .. L["Travel"] , type = "GilneanF", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = " " .. ITEM_REQ_ALLIANCE .. "\n" .. "\n" .. " ==> " .. L["Boralus, Tiragarde Sound"] } -- Transport from Zuldazar to Boralus 
            end
          end


        -- Zandalar LFR
          if self.db.profile.showContinentLFR then

            if self.faction == "Horde" or db.activate.EnemyFaction then 
              nodes[875][56886153] = { mnID = 1164, hideInfo = true, id = { 1176, 1031, 1179, 1036 }, type = "LFR", showOnContinent = true, showInZone = false, showOnMinimap = false, name = L["Eppu"] .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " " }
            end
          end

        -- Zandalar PvpandPveVendor
          if self.db.profile.showContinentPvPandPvEVendor then

            if self.faction == "Horde" or db.activate.EnemyFaction then 
              nodes[875][54017034] = { name = "", dnID = TRANSMOG_SET_PVP .. " " .. MERCHANT .. " " .. FACTION_HORDE .. "\n" .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. "\n" .. AUCTION_CATEGORY_WEAPONS, mnID = 862, type = "PvPVendorH", showInZone = false, showOnContinent = true, showOnMinimap = false }
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
    
            if self.faction == "Alliance" or db.activate.EnemyFaction then
              nodes[876][61865000] = { id = 1023, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Siege of Boralus
            end
    
            if self.faction == "Horde" or db.activate.EnemyFaction then
              nodes[876][70406468] = { id = 1023, type = "Dungeon", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Siege of Boralus
            end
          end
    
    
        -- Kul Tiras Raids
          if self.db.profile.showContinentRaids then
            nodes[876][68262354] = { id = 1177, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Crucible of Storms
            nodes[876][86261171] = { id = 1179, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- The Eternal Palace
    
            if self.faction == "Alliance" or db.activate.EnemyFaction then
              nodes[876][61645308] = { id = 1176, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Battle of Dazar'alor
            end
          end
    
    
        -- Kul Tiras Portals without MapNotesIcons
          if self.db.profile.showContinentPortals and not self.db.profile.showContinentMapNotes then
    
            if self.faction == "Alliance" or db.activate.EnemyFaction then
              nodes[876][59165485] = { mnID = 1161, name = "", type = "APortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Boralus"] .. " " .. L["Portalroom"] .. "\n" .. "\n" .. " ==> " .. STORMWIND .. "\n" .. " ==> " .. L["Silithus"] .. "\n" .. " ==> " .. L["Exodar"] .. "\n" .. " ==> " .. L["Ironforge"] .. "\n" .. " ==> " .. L["Nazjatar"] .. "\n" .. "\n" .. L["Portals"] .. "\n" ..  "\n" .. " ==> " .. L["Arathi Highlands"] .. "\n" .. " ==> " .. L["Darkshore"] } -- Boralus Portals
            end
          end


        -- Kul Tiras MapNotesIcons
          if self.db.profile.showContinentMapNotes then
    
            if self.faction == "Alliance" or db.activate.EnemyFaction then
              nodes[876][58395547] = { mnID = 1161, hideInfo = true, id = { 1176, 1031, 1179, 1036 }, type = "AIcon", showOnContinent = true, showInZone = false, showOnMinimap = false, name = L["Boralus"] .. " " .. "\n" .. " " .. "\n" .. L["Portalroom"] .. "\n" .. " ==> " .. STORMWIND .. "\n" .. " ==> " .. L["Silithus"] .. "\n" .. " ==> " .. L["Exodar"] .. "\n" .. " ==> " .. L["Ironforge"] .. "\n" .. " ==> " .. L["Nazjatar"] .. "\n" .. " " .. "\n" .. L["Grand Admiral Jes-Tereth"] .. L["Travel"] .. "\n" .. " ==> " .. L["Nazmir"] .. "\n" .. " ==> " .. L["Zuldazar"] .. "\n" .. " ==> " .. L["Vol'dun"] .. "\n" .. " " .. "\n" .. L["Portals"] .. "\n" .. " " .. "\n" .. " ==> " .. L["Arathi Highlands"] .. "\n" .. " ==> " .. L["Darkshore"] .. "\n" .. " " .. "\n" .. L["Ship"] .. "\n" .. " ==> " .. STORMWIND .. "\n" .. " "  .."\n" .. L["Kiku"] .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " "} -- Boralus Transports
            end
          end
    
    
        -- Kul Tiras Ships
          if self.db.profile.showContinentShips then
    
            if self.faction == "Horde" or db.activate.EnemyFaction then

            end
    
            if self.faction == "Alliance" or db.activate.EnemyFaction then

            end
          end

          -- Kul Tiras Transport
          if self.db.profile.showContinentTransport then

            nodes[876][20172422] = { mnID = 1462, name = "", type = "GoblinF", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Captain Krooz"] .. " " .. SPLASH_BATTLEFORAZEROTH_8_2_0_FEATURE1_TITLE .. " " .. L["Travel"] .. "\n" .. "\n" .. " ==> " .. L["Dazar'alor"] } -- Ship from Mechagon to Zuldazar

            if self.faction == "Horde" or db.activate.EnemyFaction then
              nodes[876][25676657] = { mnID = 896, name = L["Swellthrasher"] .. " - " .. L["Travel"], type = "MOrcF", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = " " .. ITEM_REQ_HORDE .. "\n" .. "\n" .. " ==> " .. L["Zuldazar"] } -- Transport from Drustvar to Zuldazar
              nodes[876][54391406] = { mnID = 942, name = L["Grok Seahandler"] .. " - " .. L["Travel"], type = "OrcM", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = " " .. ITEM_REQ_HORDE .. "\n" .. "\n" .. " ==> " .. L["Zuldazar"] } -- Transport from Stormsong Valley to Zuldazar
              nodes[876][68326548] = { mnID = 895, name = L["Erul Dawnbrook"] .. " - " .. L["Travel"] , type = "B11M", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = " " .. ITEM_REQ_HORDE .. "\n" .. "\n" .. " ==> " .. L["Zuldazar"] } -- Transport from Tiragarde Sound to Zuldazar 
            end
          end


        -- Kul Tiras LFR
          if self.db.profile.showContinentLFR then

            if self.faction == "Alliance" or db.activate.EnemyFaction then
              nodes[876][60244960] = { mnID = 895, hideInfo = true, id = { 1176, 1031, 1179, 1036 }, type = "LFR", showOnContinent = true, showInZone = false, showOnMinimap = false, name = L["Kiku"] .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " " }
            end
          end

        -- Kul Tiras PvpandPveVendor
          if self.db.profile.showContinentPvPandPvEVendor then

            if self.faction == "Alliance" or db.activate.EnemyFaction then
              nodes[876][58825106] = { name = "", dnID = TRANSMOG_SET_PVP .. " " .. MERCHANT .. " " .. FACTION_ALLIANCE .. "\n" .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. "\n" .. AUCTION_CATEGORY_WEAPONS, mnID = 1161, type = "PvPVendorA", showInZone = false, showOnContinent = true, showOnMinimap = false }
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
            nodes[1550][46555240] = { mnID = 1670,  name = "" , type = "Portal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Oribos"] .. " " .. L["Portals"] .. "\n" .. "\n" .. " ==> " .. ORGRIMMAR .. "\n" .. " ==> " .. STORMWIND .. "\n" .. " ==> " .. L["Zereth Mortis"] .. "\n" .. " ==> " .. L["The Maw"] .. "\n" .. " ==> " .. L["Korthia"] } -- Oribos to Stormwind City Portal
            nodes[1550][84378297] = { mnID = 1970,  name = "" , type = "Portal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Zereth Mortis"] .. " " .. L["Portal"] .. "\n" .. " ==> " .. L["Oribos"] } -- Zereth Mortis to Oribos
            nodes[1550][23470975] = { mnID = 1543,  name = "" , type = "Portal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["The Maw"] .. " " .. L["Portal"] .. "\n" .. " ==> " .. L["Oribos"] } -- The Maw to Oribos
            nodes[1550][28181988] = { mnID = 1961,  name = "" , type = "Portal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Korthia"] .. " " .. L["Portal"] .. "\n" .. " ==> " .. L["Oribos"] } -- Korthis to Oribos
          end


        -- Shadowlands LFR
          if self.db.profile.showContinentLFR then
            nodes[1550][46704896] = { mnID = 1670, hideInfo = true, id = { 1190, 1193, 1195 }, type = "LFR", showOnContinent = true, showInZone = false, showOnMinimap = false, name = L["Ta'elfar"] .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " " }
          end

        -- Shadowlands PvpandPveVendor
          if self.db.profile.showContinentPvPandPvEVendor then
            nodes[1550][45135011] = { name = "", dnID = TRANSMOG_SET_PVP .. " / " .. TRANSMOG_SET_PVE .. " " .. MERCHANT .. "\n" .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. "\n" .. AUCTION_CATEGORY_WEAPONS, mnID = 1670, type = "PvPVendor", showInZone = false, showOnContinent = true, showOnMinimap = false }
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
            nodes[1978][56264965] = { mnID = 2112, name = "", type = "Portal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Valdrakken"] .. " " .. L["Portals"] .. "\n" ..  "\n" .. " ==> " .. L["Emerald Dream"] .. "\n" .. " ==> " .. L["Badlands"] .. "\n".." ==> " .. STORMWIND .. "\n" .. " ==> " .. ORGRIMMAR } --  Valdrakken Portals
            nodes[1978][30945509] = { mnID = 2200, name = "", type = "WayGateGreen",  showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. L["Emerald Dream"] } -- Portal to The Emerald Dream
    
            if self.faction == "Horde" or db.activate.EnemyFaction then

            end
    
            if self.faction == "Alliance" or db.activate.EnemyFaction then
              nodes[1978][25006083] = { mnID = "2239",  name = "", type = "APortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Portals"] .. "\n" .. " ==> " .. STORMWIND .. "\n" .. " ==> " .. L["Darkshore"] .. "\n" .. " ==> " .. POSTMASTER_LETTER_HYJAL  .. "\n" .. " ==> " .. POSTMASTER_LETTER_LORLATHIL } -- Valdrakken to Stormwind City Portal
            end
          end
    

        -- Dragonflight Passage          
          if self.db.profile.showContinentPassage and not db.activate.ClassicIcons then
            nodes[1978][31065686] = { id = 1207, type = "PassageRaid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Amirdrassil, the Dream's Hope
          end
    

        -- Dragonflight ClassicIcons
          if db.activate.ClassicIcons then

            if self.db.profile.showContinentRaids then
              nodes[1978][31065686] = { id = 1207, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Amirdrassil, the Dream's Hope
            end
          end


        -- Dragonflight Zeppelin
          if self.db.profile.showContinentZeppelins then      
    
            if self.faction == "Horde" or db.activate.EnemyFaction then 
              nodes[1978][59572607] = { mnID = 85, name = "", type = "HZeppelin", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Zeppelin"] .. " ==> " .. ORGRIMMAR } -- Zeppelin from The Waking Shores to Orgrimmar 
            end
          end
    
    
        -- Dragonflight Ships
          if self.db.profile.showContinentShips then
            nodes[1978][24105048] = { mnID = 217, name = "", type = "Ship", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Bel'ameth, Amirdrassil"] .. " " .. L["Ship"] .. "\n" .. " ==> " .. L["Ruins of Gilneas"] } -- Ship from Amirdrassil to Gilneas

            if self.faction == "Alliance" or db.activate.EnemyFaction then
              nodes[1978][59732701] = { mnID = 84, name = "", type = "AShip", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Ship"] .. " ==> " .. STORMWIND } -- Ship from The Waking Shores to Stormwind
            end
          end
        end 


        --#################################
        --##### Continent Khaz Algar ######
        --#################################
    
        if self.db.profile.showContinentKhazAlgar then
    
          -- Khaz Algar Dungeons
            if self.db.profile.showContinentDungeons then
              nodes[2274][57814889] = { id = 1210, type = "Dungeon", showOnContinent = true, showInZone = true, showOnMinimap = false } -- Darkflame Cleft
              nodes[2274][35095289] = { id = 1267, type = "Dungeon", showOnContinent = true, showInZone = true, showOnMinimap = false } -- Priory of the Sacred Flame
              nodes[2274][40465803] = { id = 1270, type = "Dungeon", showOnContinent = true, showInZone = true, showOnMinimap = false } -- The Dawnbreaker
              nodes[2274][53004397] = { id = 1269, type = "Dungeon", showOnContinent = true, showInZone = true, showOnMinimap = false } -- The Stonevault
              nodes[2274][52715561] = { id = 1298, type = "Dungeon", showOnContinent = true, showInZone = true, showOnMinimap = false } -- Operation: Floodgate
              nodes[2274][70301908] = { id = 1268, type = "Dungeon", showOnContinent = true, showInZone = true, showOnMinimap = false } -- The Rookery
              nodes[2274][84362059] = { id = 1272, type = "Dungeon", showOnContinent = true, showInZone = true, showOnMinimap = false } -- Cinderbrew Meadery
              nodes[2274][43337984] = { id = 1274, type = "Dungeon", showOnContinent = true, showInZone = true, showOnMinimap = false } -- City of Threads
              nodes[2274][44338372] = { id = 1271, type = "Dungeon", showOnContinent = true, showInZone = true, showOnMinimap = false } -- Ara-Kara, City of Echoes
            end
      
          -- Khaz Algar Raids
            if self.db.profile.showContinentRaids then
              nodes[2274][42188673] = { id = 1273, type = "Raid"}  -- Nerub-ar Palace
              nodes[2274][41469096] = { id = 1273, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Nerub-ar Palace     
              nodes[2274][82217245] = { id = 1296, type = "Raid", showOnContinent = true, showInZone = false, showOnMinimap = false } -- Liberation of Undermine   
            end

          -- Khaz Algar Delves
            --if self.db.profile.showContinentDelves then
            --  -- Azj-Kathet
            --  nodes[2274][46088109] = { name = "", TransportName = DELVE_LABEL, delveID = 2259, type = "Delves", showOnContinent = true, showInZone = true, showOnMinimap = false } -- Tak-Rethan-Abyss
            --  nodes[2274][45458627] = { name = "", TransportName = DELVE_LABEL, delveID = 2299, type = "Delves", showOnContinent = true, showInZone = true, showOnMinimap = false } -- The Underkeep
            --  nodes[2274][38868203] = { name = "", TransportName = DELVE_LABEL, delveID = 2348, type = "Delves", showOnContinent = true, showInZone = true, showOnMinimap = false } -- Zekvir's Lair
            --  nodes[2274][42946320] = { name = "", TransportName = DELVE_LABEL, delveID = 2347, type = "Delves", showOnContinent = true, showInZone = true, showOnMinimap = false } -- The Spiral Weave
            --  -- Hallowfall
            --  nodes[2274][47174554] = { name = "", TransportName = DELVE_LABEL, delveID = 2312, type = "Delves", showOnContinent = true, showInZone = true, showOnMinimap = false } -- Mycomancer Cavern
            --  nodes[2274][44825825] = { name = "", TransportName = DELVE_LABEL, delveID = 2310, type = "Delves", showOnContinent = true, showInZone = true, showOnMinimap = false } -- Skittering Breach
            --  nodes[2274][39015449] = { name = "", TransportName = DELVE_LABEL, delveID = 2301, type = "Delves", showOnContinent = true, showInZone = true, showOnMinimap = false } -- The Sinkhole
            --  nodes[2274][32425213] = { name = "", TransportName = DELVE_LABEL, delveID = 2277, type = "Delves", showOnContinent = true, showInZone = true, showOnMinimap = false } -- Nightfall Sanctum
            --  -- The Ringing Deeps
            --  nodes[2274][52355778] = { name = "", TransportName = DELVE_LABEL, delveID = 2251, type = "Delves", showOnContinent = true, showInZone = true, showOnMinimap = false } -- The Waterworks
            --  nodes[2274][61935331] = { name = "", TransportName = DELVE_LABEL, delveID = 2302, type = "Delves", showOnContinent = true, showInZone = true, showOnMinimap = false } -- The Dread Pit
            --  -- Isle of Dorn
            --  nodes[2274][67273401] = { name = "", TransportName = DELVE_LABEL, delveID = 2269, type = "Delves", showOnContinent = true, showInZone = true, showOnMinimap = false } -- Earthcrawl Mines
            --  nodes[2274][73383036] = { name = "", TransportName = DELVE_LABEL, delveID = 2249, type = "Delves", showOnContinent = true, showInZone = true, showOnMinimap = false } -- Fungal Folly
            --  nodes[2274][77712035] = { name = "", TransportName = DELVE_LABEL, delveID = 2250, type = "Delves", showOnContinent = true, showInZone = true, showOnMinimap = false } -- Kriegval's Rest
            --end

          -- Khaz Algar MapNotesIcons
            if self.db.profile.showContinentMapNotes then
              nodes[2274][72311951] = { mnID = 2339, name = "", type = "MNL", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Dornogal"] .. " - " .. FACTION_NEUTRAL .. "\n" .. "\n" .. L["Portals"] .. "\n" .. " ==> " .. ORGRIMMAR .. "\n" .. " ==> " .. STORMWIND .. "\n" .. "\n" .. L["The Timeways"] .. " " .. L["Portals"] .. "\n" .. "\n" .. " ==> " .. SPLASH_BATTLEFORAZEROTH_8_2_0_FEATURE1_TITLE .. "\n" .. " ==> " .. L["Maldraxxus"] .. "\n" .. " ==> " .. L["Zuldazar"] .."\n" .. "\n" .. CALENDAR_TYPE_DUNGEON .. "\n" .. " ==> " .. "The Rookery" } -- Dornogal

              if self.faction == "Horde" or db.activate.EnemyFaction then

              end

              if self.faction == "Alliance" or db.activate.EnemyFaction then
              
              end
            end
      
      
          -- Khaz Algar Portals
            if self.db.profile.showContinentPortals then
              nodes[2274][70881758] = { mnID = 2339, name = "", type = "Portal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Portals"] .. "\n" ..  "\n" .. " ==> " .. STORMWIND .. "\n" .. " ==> " .. ORGRIMMAR } --  Isle of Dorn Portals
              
              if self.faction == "Horde" or db.activate.EnemyFaction then
  
              end
      
              if self.faction == "Alliance" or db.activate.EnemyFaction then
                --nodes[1978][25006083] = { mnID = "2239",  name = "", type = "APortal", showOnContinent = true, showInZone = false, showOnMinimap = false, TransportName = L["Portals"] .. "\n" .. " ==> " .. STORMWIND .. "\n" .. " ==> " .. L["Darkshore"] .. "\n" .. " ==> " .. POSTMASTER_LETTER_HYJAL  .. "\n" .. " ==> " .. POSTMASTER_LETTER_LORLATHIL } -- Valdrakken to Stormwind City Portal
              end
            end

          -- Khaz Algar Transport
            if self.db.profile.showContinentTransport then
              nodes[2274][52685213] = { mnID = 2369, name = L["Mole Machine"], dnID = "", type = "MoleMachine", showInZone = false, showOnContinent = true, showOnMinimap = false } -- Mole Machine from Deeps to Sirene Isle
              nodes[2274][64396827] = { mnID = 2346, name = L["Rocket drill"] .. " " .. L["Transport"], dnID = "", type = "RocketDrill", questID = 83151, wwwLink = "wowhead.com/quest=83151", showWWW = true, wwwName = BATTLE_PET_SOURCE_2 .. " " .. REQUIRES_LABEL .. " " .. "Down Undermine", showInZone = false, showOnContinent = true, showOnMinimap = false } -- Mole Machine from Deeps to Undermine
            end

          -- Khaz Algar Zeppelin
            if self.db.profile.showContinentZeppelins then
              nodes[2274][73131599] = { mnID = 2369, name = "", type = "Zeppelin", showInZone = false, showOnContinent = true, showOnMinimap = false, TransportName = L["Zeppelin"] .. " ==> " .. L["Siren Isle"] } -- Zeppelin to Siren Isle from Dornogal
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

        end

      end
  end
end