local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

function ns.LoadMoPMinimapCapitalsLocationinfo(self)
local db = ns.Addon.db.profile
local minimap = ns.minimap

--#####################################################################################################
--##########################        function to hide all minimap below         ########################
--#####################################################################################################
if not db.activate.HideMapNote then

    --########################################################################################
    --################################         Capitals       ################################
    --########################################################################################
    if db.activate.MinimapCapitals then


    --###########################################################################################
    --################################         Horde Cities       ###############################
    --###########################################################################################


    --################
    --### Ogrimmar ###
    --################
        if self.db.profile.showMinimapCapitalsOrgrimmar then

        --#############################
        --### Horde or EnemyFaction ###
        --#############################
            if self.faction == "Horde" or db.activate.MinimapCapitalsEnemyFaction then

            --Professions Orgrimmar
                if self.db.profile.activate.MinimapCapitalsProfessions then

                    if self.db.profile.showMinimapCapitalsFirstAid then
                        minimap[85][37608720] = { name = PROFESSIONS_FIRST_AID, type = "FirstAid", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        --minimap[85][34008440] = { name = PROFESSIONS_FIRST_AID, type = "FirstAid", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsAlchemy then
                        minimap[85][55684575] = { name = L["Alchemy"], type = "Alchemy", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                
                    if self.db.profile.showMinimapCapitalsLeatherworking then
                        minimap[85][60745506] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsEngineer then
                        minimap[85][56915635] = { name = L["Engineer"], type = "Engineer", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        minimap[85][36578657] = { name = L["Engineer"], type = "Engineer", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsSkinning then
                        minimap[85][39284964] = { name = L["Skinning"], type = "Skinning", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        minimap[85][61195463] = { name = L["Skinning"], type = "Skinning", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsTailoring then
                        minimap[85][38715060] = { name = L["Tailoring"], type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        minimap[85][60755912] = { name = L["Tailoring"], type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        minimap[85][41257982] = { name = L["Tailoring"], type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsJewelcrafting then
                        minimap[85][72493435] = { name = L["Jewelcrafting"], type = "Jewelcrafting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsBlacksmith then
                        minimap[85][75423394] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        minimap[85][76163727] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        minimap[85][40565021] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        minimap[85][44337697] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        minimap[85][35798333] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsMining then
                        minimap[85][72363520] = { name = L["Mining"], type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        minimap[85][44577872] = { name = L["Mining"], type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        minimap[85][36178231] = { name = L["Mining"], type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsFishing then
                        minimap[85][66434193] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        minimap[85][35036706] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsCooking then
                        minimap[85][56176171] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        minimap[85][39108613] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        minimap[85][32266958] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsArchaeology then
                        minimap[85][49077056] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsHerbalism then
                        minimap[85][54895027] = { name = L["Herbalism"], type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        minimap[85][34816288] = { name = L["Herbalism"], type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsInscription then
                        minimap[85][55185579] = { name = INSCRIPTION, type = "Inscription", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsEnchanting then
                        minimap[85][53464937] = { name = L["Enchanting"], type = "Enchanting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                end

            --Transports Orgrimmar
                if self.db.profile.activate.MinimapCapitalsTransporting then

                    if self.db.profile.showMinimapCapitalsPortals then
                        minimap[86][44756784] = { mnID = 17, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " => " .. L["Blasted Lands"] }
                        minimap[85][47393928] = { mnID = 245, name = "", type = "HPortalS", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " => " .. DUNGEON_FLOOR_TOLBARADWARLOCKSCENARIO0 } --  Portal to Tol Barad
                        minimap[85][48863851] = { mnID = 249, name = "", type = "HPortalS", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " => " .. L["Uldum"] } -- Portal to Uldum
                        minimap[85][50243944] = { mnID = 241, name = "", type = "HPortalS", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " => " .. L["Twilight Highlands"] } -- Portal to Twilight Highlands
                        minimap[85][51203832] = { mnID = 198, name = "", type = "HPortalS", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " => " .. POSTMASTER_LETTER_HYJAL } -- Portal to Hyjal
                        minimap[85][50863628] = { mnID = 207, name = "", type = "HPortalS", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " => " .. ARTIFACT_SHAMAN_TITLECARD_DEEPHOLM } -- Portal to Deepholm
                        minimap[85][49203647] = { mnID = 203, name = "", type = "HPortalS", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " => " .. L["Vashj'ir"] } -- Portal to Vashjir
                        minimap[85][45856689] = { mnID = 86, name = "", type = "PassageHPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " => " .. L["Blasted Lands"] .. "\n" .. "(" .. DUNGEON_FLOOR_ORGRIMMAR1 .. ")" }
                        minimap[85][41966110] = { mnID = 86, name = "", type = "PassageHPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " => " .. L["Blasted Lands"] .. "\n" .. "(" .. DUNGEON_FLOOR_ORGRIMMAR1 .. ")" }
                        minimap[85][39725075] = { mnID = 198, name = "", type = "HPortalS", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " => " .. POSTMASTER_LETTER_HYJAL } -- Portal to Hyjal
                        minimap[85][35526913] = { mnID = 86, name = "", type = "PassageHPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " => " .. L["Blasted Lands"] }
                        minimap[85][68594068] = { mnID = 371, name = "", type = "HPortal", showWWW = true, wwwName = BATTLE_PET_SOURCE_2 .. " " .. REQUIRES_LABEL, wwwLink = "https://wowhead.com/mop-classic/quest=29690/into-the-mists", questID = 29690, showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Jade Forest"] } -- The Jade Forest 
                    end

                    if self.db.profile.showMinimapCapitalsZeppelins then
                        minimap[85][52175279] = { mnID = 50, name = "", type = "HZeppelin", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Zeppelin"] .. " - " .. FACTION_HORDE .. "\n" .. " => " .. L["Grom'gol, Stranglethorn Vale"] }
                        minimap[85][50905566] = { mnID = 18, name = "", type = "HZeppelin", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Zeppelin"] .. " - " .. FACTION_HORDE .. "\n" .. " => " .. L["Tirisfal Glades"] .. " - " .. L["Undercity"] }
                        minimap[85][44696222] = { mnID = 114, name = "", type = "HZeppelin", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Zeppelin"] .. " - " .. FACTION_HORDE .. "\n" .. " => " .. POSTMASTER_LETTER_WARSONGHOLD }
                        minimap[85][42946497] = { mnID = 88, name = "", type = "HZeppelin", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Zeppelin"] .. " - " .. FACTION_HORDE .. "\n" .. " => " .. L["Thunder Bluff"] }
                    end

                    if self.db.profile.showMinimapCapitalsFP then
                        minimap[85][49615924] = { mnID = 85, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Orgrimmar
                    end
    
                end
    
            --Instances Orgrimmar
                if self.db.profile.activate.MinimapCapitalsInstances then
    
                    if self.db.profile.showMinimapCapitalsDungeons then
                        minimap[85][56615109] = { mnID = 86, name = DUNGEON_FLOOR_RAGEFIRE1 .. " " .. "[" .. LEVEL .. ": " .. "13-18]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "8", type = "PassageDungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end

            --General Orgrimmar
                if self.db.profile.activate.MinimapCapitalsGeneral then
    
                    if self.db.profile.showMinimapCapitalsPaths then
                        minimap[85][74800606] = { dnID = L["Exit"], name = "", mnID = 76, type = "PathRO", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                        minimap[85][49529373] = { dnID = L["Exit"], name = "", mnID = 1, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                        minimap[85][23636814] = { dnID = L["Exit"], name = "", mnID = 10, type = "PathLU", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit
                        minimap[86][78691478] = { dnID = L["Passage"], name = "", mnID = 85, type = "PathR", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                        minimap[86][34209104] = { dnID = L["Passage"], name = "", mnID = 85, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                        minimap[86][22856905] = { dnID = L["Passage"], name = "", mnID = 85, type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit  
                    end

                    if self.db.profile.showMinimapCapitalsInnkeeper then
                        minimap[85][70504917] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][53637877] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][39658116] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][38874864] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsAuctioneer then
                        minimap[85][66643627] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][53957324] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][37307860] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][41644880] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsBank then
                        minimap[85][48748348] = { dnID = BANK .. "\n" .. GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][67615218] = { dnID = BANK .. "\n" .. GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][39904626] = { dnID = BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][40634599] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][38457887] = { dnID = BANK .. "\n" .. GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsMapNotes then
                        minimap[85][32916483] = { dnID = MINIMAP_TRACKING_INNKEEPER .. "\n" .. BANK .. "\n" .. MINIMAP_TRACKING_AUCTIONEER, name = "", type = "MNL", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsTransmogger then
                        minimap[85][58116545] = { dnID = MINIMAP_TRACKING_TRANSMOGRIFIER .. "\n" .. L["Reforge"], name = "", type = "Transmogger", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end
            end
        end

    --#####################
    --### Thunder Bluff ###
    --#####################
        if self.db.profile.showMinimapCapitalsThunderBluff then

        --#############################
        --### Horde or EnemyFaction ###
        --#############################
            if self.faction == "Horde" or db.activate.MinimapCapitalsEnemyFaction then

            --Professions Thunder Bluff
                if self.db.profile.activate.MinimapCapitalsProfessions then

                    if self.db.profile.showMinimapCapitalsFirstAid then
                        minimap[88][29602160] = { name = PROFESSIONS_FIRST_AID, type = "FirstAid", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsAlchemy then
                        minimap[88][46643317] = { name = L["Alchemy"], type = "Alchemy", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                
                    if self.db.profile.showMinimapCapitalsLeatherworking then
                        minimap[88][41514257] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsEngineer then
                        minimap[88][36065961] = { name = L["Engineer"], type = "Engineer", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsSkinning then
                        minimap[88][44424321] = { name = L["Skinning"], type = "Skinning", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsTailoring then
                        minimap[88][44544531] = { name = L["Tailoring"], type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsJewelcrafting then
                        minimap[88][34825399] = { name = L["Jewelcrafting"], type = "Jewelcrafting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsBlacksmith then
                        minimap[88][39365510] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsMining then
                        minimap[88][34385790] = { name = L["Mining"], type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsFishing then
                        minimap[88][56144642] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsCooking then
                        minimap[88][50745310] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsArchaeology then
                        minimap[88][75032812] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsHerbalism then
                        minimap[88][49954040] = { name = L["Herbalism"], type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsEnchanting then
                        minimap[88][45283847] = { name = L["Enchanting"], type = "Enchanting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsInscription then
                        minimap[88][28722088] = { name = INSCRIPTION, type = "Inscription", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        minimap[88][30323012] = { name = L["Passage"] .. " " .. MINIMAP_TRACKING_TRAINER_PROFESSION, type = "PassageLeftL", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName =  INSCRIPTION }
                    end

                end

            --Transports Thunder Bluff
                if self.db.profile.activate.MinimapCapitalsTransporting then
  
                    if self.db.profile.showMinimapCapitalsZeppelins then
                        minimap[88][14292570] = { mnID = 85, name = "", type = "HZeppelin", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Zeppelin"] .. " => " .. DUNGEON_FLOOR_ORGRIMMAR0 } -- Zeppelin from Thunder Bluff to OG
                    end

                        if self.db.profile.showMinimapCapitalsPortals then
                        minimap[88][23121355] = { mnID = 17, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " => " .. L["Blasted Lands"] }

                    end

                    if self.db.profile.showMinimapCapitalsFP then
                        minimap[88][46974977] = { mnID = 88, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Thunder Bluff
                    end

                end

            --General Thunder Bluff
            if self.db.profile.activate.MinimapCapitalsGeneral then
    
                if self.db.profile.showMinimapCapitalsPaths then
                    minimap[88][52232561] = { dnID = L["Exit"], name = "", mnID = 7, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[88][54632715] = { dnID = L["Exit"], name = "", mnID = 7, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[88][31886595] = { dnID = L["Exit"], name = "", mnID = 7, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[88][31456256] = { dnID = L["Exit"], name = "", mnID = 7, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsInnkeeper then
                    minimap[88][45856477] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper",  showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsAuctioneer then
                    minimap[88][38875023] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer",  showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[88][40435169] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer",  showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                
                if self.db.profile.showMinimapCapitalsBank then
                    minimap[88][47175862] = { dnID = BANK, name = "", type = "Bank",  showInZone = false, showOnContinent = false, showOnMinimap = true }
                end
            end

            end

        end

    --##################
    --### Silvermoon ###
    --##################
        if self.db.profile.showMinimapCapitalsSilvermoon then

        --#############################
        --### Horde or EnemyFaction ###
        --#############################
            if self.faction == "Horde" or db.activate.MinimapCapitalsEnemyFaction then

            --Professions Silvermoon
                if self.db.profile.activate.MinimapCapitalsProfessions then

                    if self.db.profile.showMinimapCapitalsFirstAid then
                        minimap[110][78007040] = { name = PROFESSIONS_FIRST_AID, type = "FirstAid", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsAlchemy then
                        minimap[110][66701673] = { name = L["Alchemy"], type = "Alchemy", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                
                    if self.db.profile.showMinimapCapitalsLeatherworking then
                        minimap[110][85008054] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsEngineer then
                        minimap[110][76634110] = { name = L["Engineer"], type = "Engineer", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsSkinning then
                        minimap[110][84997931] = { name = L["Skinning"], type = "Skinning", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsTailoring then
                        minimap[110][57365009] = { name = L["Tailoring"], type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsJewelcrafting then
                        minimap[110][91377443] = { name = L["Jewelcrafting"], type = "Jewelcrafting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        minimap[110][90327383] = { name = L["Jewelcrafting"], type = "Jewelcrafting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsBlacksmith then
                        minimap[110][79423869] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsMining then
                        minimap[110][78914322] = { name = L["Mining"], type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsFishing then
                        minimap[110][76246779] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsCooking then
                        minimap[110][69647153] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsArchaeology then
                        minimap[110][75032812] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        minimap[110][81436390] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsHerbalism then
                        minimap[110][67401842] = { name = L["Herbalism"], type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsInscription then
                        minimap[110][69322382] = { name = INSCRIPTION, type = "Inscription", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsEnchanting then
                        minimap[110][70012365] = { name = L["Enchanting"], type = "Enchanting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                end

            --Transports Silvermoon
                if self.db.profile.activate.MinimapCapitalsTransporting then

                    if self.db.profile.showMinimapCapitalsPortals then
                        minimap[110][49401484] = { mnID = 998, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " => " .. L["Undercity"] } -- Portal to Undercity
                        minimap[110][58412106] = { mnID = 17, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " => " .. L["Blasted Lands"] }
                    end

                end

            --General Silvermoon
                if self.db.profile.activate.MinimapCapitalsGeneral then
    
                    if self.db.profile.showMinimapCapitalsPaths then
                        minimap[110][72609199] = { dnID = L["Exit"], name = "", mnID = 94, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                    end

                    if self.db.profile.showMinimapCapitalsInnkeeper then
                        minimap[110][79465822] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[110][67867288] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsAuctioneer then
                        minimap[110][92735828] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[110][60726258] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsBank then
                        minimap[110][89714509] = { dnID = BANK .. "\n" .. GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[110][65807788] = { dnID = BANK .. "\n" .. GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end

            end

        end

    --#################
    --### Undercity ###
    --#################
        if self.db.profile.showMinimapCapitalsUndercity then

        --#############################
        --### Horde or EnemyFaction ###
        --#############################
            if self.faction == "Horde" or db.activate.MinimapCapitalsEnemyFaction then

            --Professions Undercity
                if self.db.profile.activate.MinimapCapitalsProfessions then

                    if self.db.profile.showMinimapCapitalsFirstAid then
                        minimap[998][73605560] = { name = PROFESSIONS_FIRST_AID, type = "FirstAid", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsAlchemy then
                        minimap[998][47757332] = { name = L["Alchemy"], type = "Alchemy", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        minimap[998][52947737] = { name = L["Alchemy"], type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Passage"] .. " " .. MINIMAP_TRACKING_TRAINER_PROFESSION }
                        minimap[998][44626639] = { name = L["Alchemy"], type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Passage"] .. " " .. MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                
                    if self.db.profile.showMinimapCapitalsLeatherworking then
                        minimap[998][70155740] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsEngineer then
                        minimap[998][76107409] = { name = L["Engineer"], type = "Engineer", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsSkinning then
                        minimap[998][70165922] = { name = L["Skinning"], type = "Skinning", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsTailoring then
                        minimap[998][70763072] = { name = L["Tailoring"], type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsJewelcrafting then
                        minimap[998][56503630] = { name = L["Jewelcrafting"], type = "Jewelcrafting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsBlacksmith then
                        minimap[998][61313061] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsMining then
                        minimap[998][56043744] = { name = L["Mining"], type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsFishing then
                        minimap[998][80693124] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsCooking then
                        minimap[998][62194489] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsArchaeology then
                        minimap[998][75403772] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsHerbalism then
                        minimap[998][54014961] = { name = L["Herbalism"], type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsInscription then
                        minimap[998][61065801] = { name = INSCRIPTION, type = "Inscription", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsEnchanting then
                        minimap[998][61866139] = { name = L["Enchanting"], type = "Enchanting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                end

            --Transports Undercity
                if self.db.profile.activate.MinimapCapitalsTransporting then

                    if self.db.profile.showMinimapCapitalsPortals then
                        minimap[998][55011129] = { mnID = 110, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " => " .. L["Silvermoon City"] .. "\n" .. "(" .. DUNGEON_FLOOR_GILNEAS3 .. ")" } -- Portal to Silvermoon from Tirisfal
                        minimap[998][85191687] = { mnID = 17, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " => " .. L["Blasted Lands"] } -- Portal to Silvermoon 
                    end

                    if self.db.profile.showCapitalsFP then
                        minimap[998][63164844] = { mnID = 998, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Undercity
                    end

                end

            --General Undercity
                if self.db.profile.activate.MinimapCapitalsGeneral then
    
                    if self.db.profile.showMinimapCapitalsPaths then
                        minimap[998][15003101] = { dnID = L["Exit"], name = "", mnID = 18, type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                        minimap[998][46474406] = { dnID = L["Exit"], name = "", mnID = 18, type = "PathL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                        minimap[998][66110384] = { dnID = L["Exit"] .. " " .. DUNGEON_FLOOR_GILNEAS3, name = "", mnID = 18, type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                        minimap[998][49792975] = { dnID = L["Exit"], name = "", mnID = 18, type = "PathL", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = REQUIRES_LABEL .. " " .. MOUNT_JOURNAL_FILTER_FLYING } -- Passage/Exit 
                        minimap[998][65865202] = { dnID = DUNGEON_FLOOR_GILNEAS3 .. " => " .. DUNGEON_FLOOR_GILNEAS2 .. "\n" ..  DUNGEON_FLOOR_GILNEAS2 .. " => " .. DUNGEON_FLOOR_GILNEAS3, name = "", type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                        minimap[998][60584399] = { dnID = DUNGEON_FLOOR_GILNEAS3 .. " => " .. DUNGEON_FLOOR_GILNEAS2 .. "\n" ..  DUNGEON_FLOOR_GILNEAS2 .. " => " .. DUNGEON_FLOOR_GILNEAS3, name = "", type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                        minimap[998][71294410] = { dnID = DUNGEON_FLOOR_GILNEAS3 .. " => " .. DUNGEON_FLOOR_GILNEAS2 .. "\n" ..  DUNGEON_FLOOR_GILNEAS2 .. " => " .. DUNGEON_FLOOR_GILNEAS3, name = "", type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                    end

                    if self.db.profile.showMinimapCapitalsInnkeeper then
                        minimap[998][67743784] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsAuctioneer then
                        minimap[998][60534156] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[998][64363583] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[998][67663591] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[998][71494189] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[998][71394672] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[998][67545239] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[998][64415242] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[998][60494647] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsBank then
                        minimap[998][66014406] = { dnID = BANK .. "\n" .. GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsGhost then
                        minimap[998][67851396] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Undercity
                    end

                end

            end

        end

    --#############
    --### Sot2M ###
    --#############
        if self.db.profile.showMinimapCapitalsSot2M then

        --#############################
        --### Horde or EnemyFaction ###
        --#############################
            if self.faction == "Horde" or db.activate.CapitalMinimapEnemyFaction then

            --Professions Sot2M
                if self.db.profile.activate.MinimapCapitalsProfessions then

                    if self.db.profile.showMinimapCapitalsEngineer then
                        minimap[391][62374397] = { name = L["Engineer"], type = "Engineer", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        minimap[1530][62361153] = { name = L["Engineer"], type = "Engineer", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsBlacksmith then
                        minimap[391][25844377] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        minimap[1530][59181165] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                end

            --Transports Sot2M
                if self.db.profile.activate.MinimapCapitalsTransporting then

                    if self.db.profile.showMinimapCapitalsPortals then
                        minimap[392][72464286] = { mnID = 85, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. DUNGEON_FLOOR_ORGRIMMAR0 } -- Portal from Shrine of Two Moons to Orgrimmar
                        minimap[1530][63720989] = { mnID = 85, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. DUNGEON_FLOOR_ORGRIMMAR0 .. "\n" .. DUNGEON_FLOOR_GILNEAS3 } -- Portal from Shrine of Two Moons to Orgrimmar
                    end

                end

            --General Sot2M
                if self.db.profile.activate.MinimapCapitalsGeneral then
    
                    if self.db.profile.showMinimapCapitalsPaths then
                        minimap[391][26778156] = { name = L["Exit"], mnID = 390, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[391][53618846] = { name = L["Exit"], mnID = 390, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[391][77476963] = { name = L["Exit"], mnID = 390, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[391][78084452] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS3, mnID = 392, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = "\n" .. BANK .. "\n" .. GUILD_BANK .. "\n" .. L["Portal"] .. " ==> " .. DUNGEON_FLOOR_ORGRIMMAR0 }
                        minimap[391][22245623] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS3, mnID = 392, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = "\n" .. BANK .. "\n" .. GUILD_BANK .. "\n" .. L["Portal"] .. " ==> " .. DUNGEON_FLOOR_ORGRIMMAR0 }
                        minimap[391][36972301] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS3, mnID = 392, type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = "\n" .. BANK .. "\n" .. GUILD_BANK .. "\n" .. L["Portal"] .. " ==> " .. DUNGEON_FLOOR_ORGRIMMAR0 }
                        minimap[391][57691948] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS3, mnID = 392, type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = "\n" .. BANK .. "\n" .. GUILD_BANK .. "\n" .. L["Portal"] .. " ==> " .. DUNGEON_FLOOR_ORGRIMMAR0 }
                        minimap[392][55653047] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS2, mnID = 391, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = "\n" .. BUTTON_LAG_AUCTIONHOUSE .. " " .. REQUIRES_LABEL .. " " .. L["Engineer"] .. "\n" .. MINIMAP_TRACKING_INNKEEPER .. "\n" .. L["Engineer"] .. "\n" .. L["Blacksmithing"] }
                        minimap[392][37913400] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS2, mnID = 391, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = "\n" .. BUTTON_LAG_AUCTIONHOUSE .. " " .. REQUIRES_LABEL .. " " .. L["Engineer"] .. "\n" .. MINIMAP_TRACKING_INNKEEPER .. "\n" .. L["Engineer"] .. "\n" .. L["Blacksmithing"] }
                        minimap[392][27407968] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS2, mnID = 391, type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = "\n" .. BUTTON_LAG_AUCTIONHOUSE .. " " .. REQUIRES_LABEL .. " " .. L["Engineer"] .. "\n" .. MINIMAP_TRACKING_INNKEEPER .. "\n" .. L["Engineer"] .. "\n" .. L["Blacksmithing"] }
                        minimap[392][74176908] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS2, mnID = 391, type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = "\n" .. BUTTON_LAG_AUCTIONHOUSE .. " " .. REQUIRES_LABEL .. " " .. L["Engineer"] .. "\n" .. MINIMAP_TRACKING_INNKEEPER .. "\n" .. L["Engineer"] .. "\n" .. L["Blacksmithing"] }
                    end

                    if self.db.profile.showMinimapCapitalsInnkeeper then
                        minimap[391][68544760] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[392][60357734] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1530][62921195] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsAuctioneer then
                        minimap[391][59044226] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = REQUIRES_LABEL .. " " .. L["Engineer"] }
                        minimap[1530][62071153] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = REQUIRES_LABEL .. " " .. L["Engineer"] }

                    end

                    if self.db.profile.showMinimapCapitalsBank then
                        minimap[392][27686535] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[392][20935102] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[392][22975452] = { dnID = BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1530][58511114] = { dnID = BANK .. " / " .. GUILD_BANK, TransportName = DUNGEON_FLOOR_GILNEAS3, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsMapNotes then
                        minimap[1530][61691650] = { dnID = TRANSMOG_SET_PVE .. "" .. SLASH_EQUIP_SET1 .. "\n" .. BANK .. "\n" .. GUILD_BANK .. "\n" .. L["Portal"] .. " ==> " .. DUNGEON_FLOOR_ORGRIMMAR0 .. "\n" .. BUTTON_LAG_AUCTIONHOUSE .. " " .. REQUIRES_LABEL .. " " .. L["Engineer"] .. "\n" .. MINIMAP_TRACKING_INNKEEPER .. "\n" .. L["Engineer"] .. "\n" .. L["Blacksmithing"], name = "", type = "MNL", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profileshowMinimapCapitalsPvEVendor then
                        minimap[1530][60601347] = { dnID = TRANSMOG_SET_PVE .. "" .. SLASH_EQUIP_SET1, name = "", TransportName = DUNGEON_FLOOR_GILNEAS3,  type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[392][43717734] = { dnID = TRANSMOG_SET_PVE .. "" .. SLASH_EQUIP_SET1, name = "", TransportName = DUNGEON_FLOOR_GILNEAS3,  type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsMailbox then
                        minimap[391][33655993] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[391][59915144] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[391][67405288] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[391][49778240] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[392][39617815] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[392][62397421] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true } 
                        minimap[392][71503000] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[392][24004020] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end

            end

        end


    --###############################################################################################
    --################################         Alliance Cities       ################################
    --###############################################################################################


    --#################
    --### Stormwind ###
    --#################
        if self.db.profile.showMinimapCapitalsStormwind then

        --################################
        --### Alliance or EnemyFaction ###
        --################################
            if self.faction == "Alliance" or db.activate.MinimapCapitalsEnemyFaction then

            --Instances Stormwind
                if self.db.profile.activate.MinimapCapitalsInstances then
    
                    if self.db.profile.showMinimapCapitalsDungeons then
                        minimap[84][50356644] = { mnID = 84, name = DUNGEON_FLOOR_THESTOCKADE1 .. " " .. "[" .. LEVEL .. ": " .. "22-30]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "15", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end

            --Transports Stormwind
                if self.db.profile.activate.MinimapCapitalsTransporting then

                    if self.db.profile.showMinimapCapitalsPortals then
                        minimap[84][82512804] = { mnID = 198, name = "", type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " => " .. POSTMASTER_LETTER_HYJAL } -- Portal to Hyjal
                        minimap[84][18472650] = { mnID = 114, name = "", type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. "\n" .. " => " .. POSTMASTER_LETTER_VALIANCEKEEP } -- 
                        minimap[84][22575571] = { mnID = 114, name = "", type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. "\n" .. " => " .. POSTMASTER_LETTER_VALIANCEKEEP } -- 
                        minimap[84][73221836] = { mnID = 245, name = "", type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " => " .. DUNGEON_FLOOR_TOLBARADWARLOCKSCENARIO0 } --  Portal to Tol Barad
                        minimap[84][75232055] = { mnID = 249, name = "", type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " => " .. L["Uldum"] } -- Portal to Uldum
                        minimap[84][75351649] = { mnID = 241, name = "", type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " => " .. L["Twilight Highlands"] } -- Portal to Twilight Highlands
                        minimap[84][76211869] = { mnID = 198, name = "", type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " => " .. POSTMASTER_LETTER_HYJAL } -- Portal to Hyjal
                        minimap[84][73171966] = { mnID = 207, name = "", type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " => " .. ARTIFACT_SHAMAN_TITLECARD_DEEPHOLM } -- Portal to Deepholm
                        minimap[84][73301687] = { mnID = 203, name = "", type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " => " .. L["Vashj'ir"] } -- Portal to Vashjir
                        minimap[84][48838705] = { mnID = 17, name = "", type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " => " .. L["Blasted Lands"] } 
                        minimap[84][18142463] = { mnID = 203, name = "", type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " => " .. L["Vashj'ir"] } -- Portal to Vashjir
                        minimap[84][68791728] = { mnID = 371, name = "", type = "APortal", showWWW = true, wwwName = BATTLE_PET_SOURCE_2 .. " " .. REQUIRES_LABEL, wwwLink = "https://wowhead.com/mop-classic/quest=29548/the-mission", questID = 29548, showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Jade Forest"] } -- Portal to Jade Forest 
                    end
   
                    if self.db.profile.showMinimapCapitalsShips then
                        minimap[84][20675628] = { mnID = 62, name = "", type = "AShip", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Ship"] .. "\n" .. " => " .. L["Auberdine"] } --
                        minimap[84][16732506] = { mnID = 114, name = "", type = "AShip", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Ship"] .. "\n" .. " => " .. POSTMASTER_LETTER_VALIANCEKEEP } --
                    end

                    if self.db.profile.showMinimapCapitalsTransport then
                        minimap[84][60941195] = { mnID = 87, name = "", type = "Carriage", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Stormwind"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. DUNGEON_FLOOR_DEEPRUNTRAM1 .. "\n" .. " => " .. L["Ironforge"] } -- Transport to Ironforge Carriage 
                    end

                    if self.db.profile.showMinimapCapitalsFP then
                        minimap[84][70777249] = { mnID = 84, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stormwind
                    end

                end

            --Professions Stormwind
                if self.db.profile.activate.MinimapCapitalsProfessions then

                    if self.db.profile.showMinimapCapitalsFirstAid then
                        minimap[84][52204560] = { name = PROFESSIONS_FIRST_AID, type = "FirstAid", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        minimap[84][52804480] = { name = PROFESSIONS_FIRST_AID, type = "FirstAid", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsAlchemy then
                        minimap[84][55668610] = { name = L["Alchemy"], type = "Alchemy", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                
                    if self.db.profile.showMinimapCapitalsLeatherworking then
                        minimap[84][71676301] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsEngineer then
                        minimap[84][62863192] = { name = L["Engineer"], type = "Engineer", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsSkinning then
                        minimap[84][72136222] = { name = L["Skinning"], type = "Skinning", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsTailoring then
                        minimap[84][53098136] = { name = L["Tailoring"], type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        minimap[84][52011954] = { name = L["Tailoring"], type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsJewelcrafting then
                        minimap[84][63486183] = { name = L["Jewelcrafting"], type = "Jewelcrafting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsBlacksmith then
                        minimap[84][63663702] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsMining then
                        minimap[84][59523778] = { name = L["Mining"], type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        minimap[84][49371220] = { name = L["Mining"], type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsFishing then
                        minimap[84][54806960] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsCooking then
                        minimap[84][77285321] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        minimap[84][50657384] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsArchaeology then
                        minimap[84][85812593] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsHerbalism then
                        minimap[84][54298408] = { name = L["Herbalism"], type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsInscription then
                        minimap[84][49827479] = { name = INSCRIPTION, type = "Inscription", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsEnchanting then
                        minimap[84][52907447] = { name = L["Enchanting"], type = "Enchanting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        minimap[84][51211270] = { name = L["Enchanting"], type = "Enchanting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                end

            --General Stormwind
                if self.db.profile.activate.MinimapCapitalsGeneral then
    
                    if self.db.profile.showMinimapCapitalsPaths then
                        minimap[84][73399051] = { dnID = L["Exit"], name = "", mnID = 37, type = "PathRU", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                    end

                    if self.db.profile.showMinimapCapitalsInnkeeper then
                        minimap[84][60407527] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[84][75685411] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[84][49881574] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[84][64943193] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsAuctioneer then
                        minimap[84][61167081] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[84][60233216] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsBank then
                        minimap[84][62887831] = { dnID = BANK .. "\n" .. GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[84][64562883] = { dnID = BANK .. "\n" .. GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsTransmogger then
                        minimap[84][50396054] = { dnID = MINIMAP_TRACKING_TRANSMOGRIFIER .. "\n" .. L["Reforge"], name = "", type = "Transmogger", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end

            end

        end

    --#################
    --### Ironforge ###
    --#################
        if self.db.profile.showMinimapCapitalsIronforge then

        --################################
        --### Alliance or EnemyFaction ###
        --################################
            if self.faction == "Alliance" or db.activate.MinimapCapitalsEnemyFaction then

            --Transports Ironforge
                if self.db.profile.activate.MinimapCapitalsTransporting then

                    if self.db.profile.showMinimapCapitalsTransport then
                        minimap[87][73375055] = { mnID = 84, name = "", type = "Carriage", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Ironforge"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. DUNGEON_FLOOR_DEEPRUNTRAM1 .. "\n" .. " => " .. L["Stormwind"] } -- Transport to Ironforge Carriage 
                    end

                    if self.db.profile.showMinimapCapitalsPortals then
                        minimap[87][27030696] = { mnID = 17, name = "", type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " => " .. L["Blasted Lands"] } 
                    end

                    if self.db.profile.showMinimapCapitalsFP then
                        minimap[87][55384778] = { mnID = 87, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ironfrge
                    end

                end

            --Professions ironforge
                if self.db.profile.activate.MinimapCapitalsProfessions then

                    if self.db.profile.showMiniMapCapitalsFirstAid then
                        minimap[87][54805860] = { name = PROFESSIONS_FIRST_AID, type = "FirstAid", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsAlchemy then
                        minimap[87][66615566] = { name = L["Alchemy"], type = "Alchemy", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                
                    if self.db.profile.showMinimapCapitalsLeatherworking then
                        minimap[87][40223365] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsEngineer then
                        minimap[87][68444359] = { name = L["Engineer"], type = "Engineer", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsSkinning then
                        minimap[87][39843248] = { name = L["Skinning"], type = "Skinning", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsTailoring then
                        minimap[87][43132939] = { name = L["Tailoring"], type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsJewelcrafting then
                        minimap[87][50192602] = { name = L["Jewelcrafting"], type = "Jewelcrafting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsBlacksmith then
                        minimap[87][50324338] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        minimap[87][52554139] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsMining then
                        minimap[87][50142649] = { name = L["Mining"], type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsFishing then
                        minimap[87][48090763] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsCooking then
                        minimap[87][60073646] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsArchaeology then
                        minimap[87][75611110] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsHerbalism then
                        minimap[87][55865907] = { name = L["Herbalism"], type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsInscription then
                        minimap[87][61004516] = { name = INSCRIPTION, type = "Inscription", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsEnchanting then
                        minimap[87][60114533] = { name = L["Enchanting"], type = "Enchanting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                end

            --General Ironforge
                if self.db.profile.activate.MinimapCapitalsGeneral then
    
                    if self.db.profile.showMinimapCapitalsPaths then
                        minimap[87][14218604] = { dnID = L["Exit"], name = "", mnID = 27, type = "PathLU", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                    end

                    if self.db.profile.showMinimapCapitalsInnkeeper then
                        minimap[87][18165147] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsAuctioneer then
                        minimap[87][25517317] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsBank then
                        minimap[87][35646042] = { dnID = BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[87][33516017] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[87][35386360] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end

            end

        end

    --#################
    --### Darnassus ###
    --#################
        if self.db.profile.showMinimapCapitalsDarnassus then

        --##########################
        --### Horde and Alliance ###
        --##########################
        --Transports Darnassus
            if self.db.profile.activate.MinimapCapitalsTransporting then

                if self.db.profile.showMinimapCapitalsPortals then
                    minimap[89][36045019] = { mnID = 57, name = "", type = "Portal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " => " .. L["Rut'theran"] } -- Portal To Darnassus from Teldrassil
                end

            end

        --################################
        --### Alliance or EnemyFaction ###
        --################################
            if self.faction == "Alliance" or db.activate.MinimapCapitalsEnemyFaction then

            --General Darnassus
                if self.db.profile.activate.MinimapCapitalsGeneral then
    
                    if self.db.profile.showMinimapCapitalsPaths then
                        minimap[89][79984648] = { dnID = L["Exit"], name = "", mnID = 57, type = "PathR", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit Exodar
                    end

                    if self.db.profile.showMinimapCapitalsInnkeeper then
                        minimap[89][62533278] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsAuctioneer then
                        minimap[89][54915837] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsBank then
                        minimap[89][44285140] = { dnID = BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[89][42655247] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsGhostk then
                        minimap[89][77662585] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Darnassus
                    end

                end

            --Transports Darnassus
                if self.db.profile.activate.MinimapCapitalsTransporting then

                    if self.db.profile.showMinimapCapitalsPortals then
                        minimap[89][44127840] = { name = "", type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portals"] .. "\n" .. " => " .. L["Exodar"] .. "\n" .. " => " .. L["Hellfire Peninsula"] } -- Portal To Darnassus from Teldrassil
                    end

                    if self.db.profile.showMinimapCapitalsFP then
                        minimap[89][36464775] = { mnID = 89, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Blutmythosinsel
                    end

                end

            --Professions Darnassus
                if self.db.profile.activate.MinimapCapitalsProfessions then

                    if self.db.profile.showMinimapCapitalsFirstAid then
                        minimap[89][51733043] = { name = PROFESSIONS_FIRST_AID, type = "FirstAid", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsAlchemy then
                        minimap[89][53913853] = { name = L["Alchemy"], type = "Alchemy", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                
                    if self.db.profile.showMinimapCapitalsLeatherworking then
                        minimap[89][60463683] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsEngineer then
                        minimap[89][49613236] = { name = L["Engineer"], type = "Engineer", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsSkinning then
                        minimap[89][60273733] = { name = L["Skinning"], type = "Skinning", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsTailoring then
                        minimap[89][59783740] = { name = L["Tailoring"], type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsJewelcrafting then
                        minimap[89][53993111] = { name = L["Jewelcrafting"], type = "Jewelcrafting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsBlacksmith then
                        minimap[89][56985271] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsMining then
                        minimap[89][50083357] = { name = L["Mining"], type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsFishing then
                        minimap[89][49096098] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsCooking then
                        minimap[89][49893663] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsArchaeology then
                        minimap[89][42658334] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsHerbalism then
                        minimap[89][49146878] = { name = L["Herbalism"], type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsInscription then
                        minimap[89][56793163] = { name = INSCRIPTION, type = "Inscription", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsEnchanting then
                        minimap[89][56413101] = { name = L["Enchanting"], type = "Enchanting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                end

            end

        end

    --##############
    --### Exodar ###
    --##############
        if self.db.profile.showMinimapCapitalsExodar then

        --################################
        --### Alliance or EnemyFaction ###
        --################################
            if self.faction == "Alliance" or db.activate.MinimapCapitalsEnemyFaction then

            --General Exodar
                if self.db.profile.activate.MinimapCapitalsGeneral then
    
                    if self.db.profile.showMinimapCapitalsPaths then
                        minimap[103][34947443] = { dnID = L["Exit"], name = "", mnID = 97, type = "PathLO", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit Exodar
                        minimap[103][65223478] = { dnID = L["Exit"], name = "", mnID = 97, type = "PathRO", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit Exodar
                    end

                    if self.db.profile.showMinimapCapitalsInnkeeper then
                        minimap[103][59511876] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsAuctioneer then
                        minimap[103][61935508] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsBank then
                        minimap[103][49224406] = { dnID = BANK .. "\n" .. GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end

            --Transports Exodar
                if self.db.profile.activate.MinimapCapitalsTransporting then

                    if self.db.profile.showMinimapCapitalsPortals then
                        minimap[103][48106302] = { mnID = 17, name = "", type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " => " .. L["Blasted Lands"] }
                        minimap[103][47596210] = { mnID = 84, name = "", type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " => " .. L["Darnassus"] }
                    end

                    if self.db.profile.showMinimapCapitalsFP then
                        minimap[103][54463620] = { mnID = 103, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Blutmythosinsel
                    end

                end

            --Professions Exodar
                if self.db.profile.activate.MinimapCapitalsProfessions then

                    if self.db.profile.showMinimapCapitalsFirstAid then
                        minimap[103][39602260] = { name = PROFESSIONS_FIRST_AID, type = "FirstAid", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION .. "\n" .. ERR_USE_OBJECT_MOVING }
                    end

                    if self.db.profile.showMinimapCapitalsAlchemy then
                        minimap[103][27766078] = { name = L["Alchemy"], type = "Alchemy", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                
                    if self.db.profile.showMinimapCapitalsLeatherworking then
                        minimap[103][67467457] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsEngineer then
                        minimap[103][54139288] = { name = L["Engineer"], type = "Engineer", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsSkinning then
                        minimap[103][65657456] = { name = L["Skinning"], type = "Skinning", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsTailoring then
                        minimap[103][64386894] = { name = L["Tailoring"], type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsJewelcrafting then
                        minimap[103][44882424] = { name = L["Jewelcrafting"], type = "Jewelcrafting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsBlacksmith then
                        minimap[103][60609000] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsMining then
                        minimap[103][59698781] = { name = L["Mining"], type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsFishing then
                        minimap[103][31931462] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsCooking then
                        minimap[103][55772672] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsArchaeology then
                        minimap[103][33316569] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsHerbalism then
                        minimap[103][27456281] = { name = L["Herbalism"], type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsInscription then
                        minimap[103][39833860] = { name = INSCRIPTION, type = "Inscription", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsEnchanting then
                        minimap[103][40693881] = { name = L["Enchanting"], type = "Enchanting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                end

            end

        end

    --#############
    --### Sot7S ###
    --#############
        if self.db.profile.showMinimapCapitalsSot7S then

        --################################
        --### Alliance or EnemyFaction ###
        --################################
            if self.faction == "Alliance" or db.activate.MinimapCapitalsEnemyFaction then

            --General Sot7S
                if self.db.profile.activate.MinimapCapitalsGeneral then
    
                    if self.db.profile.showMinimapCapitalsPaths then
                        minimap[393][24265267] = { name = L["Exit"], mnID = 390, type = "PathLO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[393][60201547] = { name = L["Exit"], mnID = 390, type = "PathLO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[393][37762459] = { name = L["Exit"], mnID = 390, type = "PathLO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[393][70883384] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS3, mnID = 394, type = "PathLO", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = "\n" .. BANK .. "\n" .. GUILD_BANK .. "\n" .. L["Portal"] .. " ==> " .. L["Stormwind"] }
                        minimap[393][54048271] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS3, mnID = 394, type = "PathRU", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = "\n" .. BANK .. "\n" .. GUILD_BANK .. "\n" .. L["Portal"] .. " ==> " .. L["Stormwind"] }
                        minimap[393][67926633] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS3, mnID = 394, type = "PathRU", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = "\n" .. BANK .. "\n" .. GUILD_BANK .. "\n" .. L["Portal"] .. " ==> " .. L["Stormwind"] }
                        minimap[393][32697602] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS3, mnID = 394, type = "PathLO", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = "\n" .. BANK .. "\n" .. GUILD_BANK .. "\n" .. L["Portal"] .. " ==> " .. L["Stormwind"] }
                        minimap[394][55347175] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS2, mnID = 393, type = "PathLO", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = "\n" .. BUTTON_LAG_AUCTIONHOUSE .. " " .. REQUIRES_LABEL .. " " .. L["Engineer"] .. "\n" .. MINIMAP_TRACKING_INNKEEPER .. "\n" .. L["Blacksmithing"] }
                        minimap[394][67115809] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS2, mnID = 393, type = "PathLO", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = "\n" .. BUTTON_LAG_AUCTIONHOUSE .. " " .. REQUIRES_LABEL .. " " .. L["Engineer"] .. "\n" .. MINIMAP_TRACKING_INNKEEPER .. "\n" .. L["Blacksmithing"] }
                        minimap[394][31955456] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS2, mnID = 393, type = "PathRU", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = "\n" .. BUTTON_LAG_AUCTIONHOUSE .. " " .. REQUIRES_LABEL .. " " .. L["Engineer"] .. "\n" .. MINIMAP_TRACKING_INNKEEPER .. "\n" .. L["Blacksmithing"] }
                        minimap[394][63182065] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS2, mnID = 393, type = "PathRU", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = "\n" .. BUTTON_LAG_AUCTIONHOUSE .. " " .. REQUIRES_LABEL .. " " .. L["Engineer"] .. "\n" .. MINIMAP_TRACKING_INNKEEPER .. "\n" .. L["Blacksmithing"] }
                    end

                    if self.db.profile.showMinimapCapitalsInnkeeper then
                        minimap[393][36506610] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsAuctioneer then
                        minimap[393][57045237] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = REQUIRES_LABEL .. " " .. L["Engineer"] }
                    end

                    if self.db.profile.showMinimapCapitalsBank then
                        minimap[393][55624688] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[394][48517769] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[394][42608412] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[394][38927502] = { dnID = BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[394][44866826] = { dnID = BANK .. " / " .. GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsTransmogger then
                        minimap[394][55598526] = { dnID = MINIMAP_TRACKING_TRANSMOGRIFIER, name = "", type = "Transmogger", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsPvEVendor then
                        minimap[394][42834374] = { dnID = TRANSMOG_SET_PVE .. "" .. SLASH_EQUIP_SET1, name = "",  type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsMailbox then
                        minimap[393][61883771] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[393][30356275] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[393][31006220] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[394][74255074] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[394][64703436] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[394][44228360] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[394][39496198] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end

            --Transports Sot7S
                if self.db.profile.activate.MinimapCapitalsTransporting then

                    if self.db.profile.showMinimapCapitalsPortals then
                        minimap[394][71563593] = { mnID = 84, name = "", type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName =  L["Portal"] .. " ==> " .. L["Stormwind"] }
                    end

                end

            --Professions Sot7S
                if self.db.profile.activate.MinimapCapitalsProfessions then

                    if self.db.profile.showMinimapCapitalsBlacksmith then
                        minimap[393][72655225] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                end

            end

        end

    --###############################################################################################
    --################################         Neutral Cities       #################################
    --###############################################################################################

    
    --#################
    --### Shattrath ###
    --#################
        if self.db.profile.showMinimapCapitalsShattrath then

        --General Shattrath
            if self.db.profile.activate.MinimapCapitalsGeneral then
    
                if self.db.profile.showMinimapCapitalsInnkeeper then
                    minimap[111][56278147] = { dnID = MINIMAP_TRACKING_INNKEEPER .. " - " .. L["The Scryers"], name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[111][28284938] = { dnID = MINIMAP_TRACKING_INNKEEPER .. " - " .. L["The Aldor"], name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }

                    if self.db.profile.showMinimapCapitalsMapNotes then
                        minimap[111][43849031] = { dnID = TUTORIAL_TITLE38 .. " - " .. L["The Scryers"] .. "\n" .. "\n" .. L["Alchemy"] .. "\n" .. L["Engineer"] .. "\n" .. L["Jewelcrafting"] .. "\n" .. L["Leatherworking"] .. "\n" .. L["Blacksmithing"] .. "\n" .. L["Tailoring"] .. "\n" .. L["Skinning"] .. "\n" .. L["Mining"] .. "\n" .. L["Herbalism"] .. "\n" .. L["Enchanting"] .. "\n" .. INSCRIPTION .. "\n" .. PROFESSIONS_FISHING .. "\n" .. PROFESSIONS_COOKING, name = "", type = "MNL", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end

                if self.db.profile.showMinimapCapitalsPaths then
                    minimap[111][68936616] = { name = L["Exit"], mnID = 108, type = "PathRU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[111][77264326] = { name = L["Exit"], mnID = 108, type = "PathR", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[111][72291901] = { name = L["Exit"], mnID = 108, type = "PathRO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[111][61790952] = { name = L["Exit"], mnID = 108, type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[111][79515778] = { name = L["Exit"], mnID = 108, type = "PathR", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[111][22344989] = { name = L["Exit"], mnID = 107, type = "PathLU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsAuctioneer then
                    minimap[111][57066278] = { name = MINIMAP_TRACKING_AUCTIONEER .. " - " .. L["The Scryers"], type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[111][51242693] = { name = MINIMAP_TRACKING_AUCTIONEER .. " - " .. L["The Aldor"], type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsBank then
                    minimap[111][60226036] = { dnID = BANK .. " - " .. L["The Scryers"], name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[111][62245901] = { dnID = GUILD_BANK  .. " - " .. L["The Scryers"], name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[111][47932940] = { dnID = BANK .. " - " .. L["The Aldor"], name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[111][46113106] = { dnID = GUILD_BANK  .. " - " .. L["The Aldor"], name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

            end

        --Transports Shattrath
            if self.db.profile.activate.MinimapCapitalsTransporting then
    
                if self.db.profile.showMinimapCapitalsPortals then
                    minimap[111][48624205] = { mnID = 122, name = "", type = "Portal", TransportName = L["Shattrath City"] .. " " .. L["Portal"] .. "\n" ..  "\n" .. " => " .. L["Isle of Quel'Danas"] , showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal from Shattrath to Orgrimmar

                    if self.faction == "Horde" or db.activate.MinimapCapitalsEnemyFaction then
                        minimap[111][59214836] = { mnID = 85, name = "", type = "HPortal", TransportName = L["Shattrath City"] .. " " .. L["Portal"] .. "\n" .. " => " .. DUNGEON_FLOOR_ORGRIMMAR0, showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal from Hellfire to Orgrimmar 
                    end

                    if self.faction == "Alliance" or db.activate.MinimapCapitalsEnemyFaction then
                        minimap[111][59504662] = { mnID = 84,  name = "" , type = "APortal", TransportName = L["Shattrath City"] .. " " .. L["Portal"] .. "\n" .. " => " .. L["Stormwind"], showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal from Hellfire to Stormwind
                    end

                end

                if self.db.profile.showMinimapCapitalsFP then
                    minimap[111][64014098] = { mnID = 111, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Shattrath
                end

            end

        --Professions Shattrath
            if self.db.profile.activate.MinimapCapitalsProfessions then

                if self.db.profile.showMinimapCapitalsFirstAid then
                    minimap[111][66601360] = { name = PROFESSIONS_FIRST_AID, type = "FirstAid", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    minimap[111][43809040] = { name = PROFESSIONS_FIRST_AID .. " - " .. L["The Scryers"], type = "FirstAid", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsAlchemy then
                    minimap[111][37977048] = { name = L["Alchemy"] .. " - " .. L["The Scryers"], type = "Alchemy", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    minimap[111][38892992] = { name = L["Alchemy"] .. " - " .. L["The Aldor"], type = "Alchemy", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    minimap[111][45612149] = { name = L["Alchemy"], type = "Alchemy", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end
            
                if self.db.profile.showMinimapCapitalsLeatherworking then
                    minimap[111][41366301] = { name = L["Leatherworking"] .. " - " .. L["The Scryers"], type = "Leatherworking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    minimap[111][37652815] = { name = L["Leatherworking"] .. " - " .. L["The Aldor"], type = "Leatherworking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    minimap[111][67256738] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }

                end

                if self.db.profile.showMinimapCapitalsEngineer then
                    minimap[111][43926531] = { name = L["Engineer"] .. " - " .. L["The Scryers"], type = "Engineer", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    minimap[111][37823205] = { name = L["Engineer"] .. " - " .. L["The Aldor"], type = "Engineer", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsSkinning then
                    minimap[111][40626347] = { name = L["Skinning"] .. " - " .. L["The Scryers"], type = "Skinning", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    minimap[111][36972686] = { name = L["Skinning"] .. " - " .. L["The Aldor"], type = "Skinning", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    minimap[111][63946588] = { name = L["Skinning"], type = "Skinning", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsTailoring then
                    minimap[111][41176365] = { name = L["Tailoring"] .. " - " .. L["The Scryers"], type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    minimap[111][37812700] = { name = L["Tailoring"] .. " - " .. L["The Aldor"], type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsJewelcrafting then
                    minimap[111][58027508] = { name = L["Jewelcrafting"] .. " - " .. L["The Scryers"], type = "Jewelcrafting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    minimap[111][35671956] = { name = L["Jewelcrafting"] .. " - " .. L["The Aldor"], type = "Jewelcrafting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    minimap[111][36024745] = { name = L["Jewelcrafting"] .. " - " .. L["The Aldor"], type = "Jewelcrafting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsBlacksmith then
                    minimap[111][43236492] = { name = L["Blacksmithing"] .. " - " .. L["The Scryers"], type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    minimap[111][37293132] = { name = L["Blacksmithing"] .. " - " .. L["The Aldor"], type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsMining then
                    minimap[111][58917523] = { name = L["Mining"] .. " - " .. L["The Scryers"], type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    minimap[111][36054859] = { name = L["Mining"] .. " - " .. L["The Aldor"], type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsFishing then
                    minimap[111][43439160] = { name = PROFESSIONS_FISHING .. " - " .. L["The Scryers"], type = "Fishing", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsHerbalism then
                    minimap[111][38807156] = { name = L["Herbalism"] .. " - " .. L["The Scryers"], type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    minimap[111][38073007] = { name = L["Herbalism"] .. " - " .. L["The Aldor"], type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsInscription then
                    minimap[111][55947403] = { name = INSCRIPTION .. " - " .. L["The Scryers"], type = "Inscription", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    minimap[111][36014345] = { name = INSCRIPTION .. " - " .. L["The Aldor"], type = "Inscription", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsEnchanting then
                    minimap[111][55417484] = { name = L["Enchanting"] .. " - " .. L["The Scryers"], type = "Enchanting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    minimap[111][43299253] = { name = L["Enchanting"] .. " - " .. L["The Scryers"], type = "Enchanting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    minimap[111][36514454] = { name = L["Enchanting"] .. " - " .. L["The Aldor"], type = "Enchanting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsArchaeology then
                    minimap[111][62667040] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsCooking then
                    minimap[111][74793084] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    minimap[111][63066835] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

            end

        end

    --#########################
    --### Dalaran Northrend ###
    --#########################
        if self.db.profile.showMinimapCapitalsDalaranNorthrend then

        --Instance Dalaran Northrend
            if self.db.profile.activate.MinimapCapitalsInstances then

                if self.db.profile.showMinimapCapitalsDungeons then
                    minimap[125][66976828] = { mnID = 125, showInZone = false, showOnContinent = false, showOnMinimap = true, name = DUNGEON_FLOOR_VIOLETHOLD1 .. " " .. "[" .. LEVEL .. ": " .. "75-77]", type = "Dungeon" } -- Violet Hold
                end

            end

        --General Dalaran Northrend
            if self.db.profile.activate.MinimapCapitalsGeneral then
    
                if self.db.profile.showMinimapCapitalsInnkeeper then
                    minimap[125][50273955] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[126][35425767] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }


                    if self.faction == "Horde" or db.activate.MinimapCapitalsEnemyFaction then
                        minimap[125][65613218] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, TransportName = ITEM_REQ_HORDE, type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.faction == "Alliance" or db.activate.MinimapCapitalsEnemyFaction then
                        minimap[125][44666336] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, TransportName = ITEM_REQ_ALLIANCE, type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end

                if self.db.profile.showMinimapCapitalsPaths then
                    minimap[126][11648435] = { name = L["Exit"], mnID = 127, type = "PathLU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[126][25044295] = { name = "", mnID = 125, TransportName = L["Passage"] .. "\n" .. " => " .. DUNGEON_FLOOR_DALARAN1, type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[126][66484766] = { name = "", mnID = 125, TransportName = L["Passage"] .. "\n" .. " => " .. DUNGEON_FLOOR_DALARAN1, type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[125][35294528] = { name = "", mnID = 126, TransportName = L["Passage"] .. "\n" .. " => " .. DUNGEON_FLOOR_DALARAN2, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[125][60294758] = { name = "", mnID = 126, TransportName = L["Passage"] .. "\n" .. " => " .. DUNGEON_FLOOR_DALARAN2, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[125][47873232] = { name = "", mnID = 126, TransportName = L["Passage"] .. "\n" .. " => " .. DUNGEON_FLOOR_DALARAN2, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsAuctioneer then
                    minimap[125][38402502] = { name = MINIMAP_TRACKING_AUCTIONEER, type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = REQUIRES_LABEL .. " " .. L["Engineer"] }

                    if self.faction == "Horde" or db.activate.MinimapCapitalsEnemyFaction then
                        minimap[125][65522343] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = ITEM_REQ_HORDE}
                    end

                    if self.faction == "Alliance" or db.activate.MinimapCapitalsEnemyFaction then
                        minimap[125][37175488] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = ITEM_REQ_ALLIANCE}
                    end

                end

                if self.db.profile.showMinimapCapitalsBank then
                    minimap[125][43167962] = { dnID = BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[125][53601525] = { dnID = BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[125][46237826] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[125][41747539] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[125][50541677] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[125][55181939] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[126][32705586] = { dnID = BANK .. " / " .. GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

            end

        --Transports Dalaran Northrend
            if self.db.profile.activate.MinimapCapitalsTransporting then
    
                if self.db.profile.showMinimapCapitalsPortals then
                    minimap[125][55814682] = { mnID = 127, name = "", type = "Portal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " => " .. BINDING_NAME_PITCHDOWN  } -- LakeWintergrasp to Dalaran Portal 

                    if self.faction == "Horde" or db.activate.MinimapCapitalsEnemyFaction then
                        minimap[125][55322545] = { mnID = 85, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. "\n" .. " => " .. DUNGEON_FLOOR_ORGRIMMAR0 } -- Dalaran to Orgrimmar Portal 
                    end

                    if self.faction == "Alliance" or db.activate.MinimapCapitalsEnemyFaction then
                        minimap[125][40796326] = { mnID = 84,  name = "" , type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. "\n" .. " => " .. L["Stormwind"] } -- Dalaran to Stormwind City Portal
                    end
                end

                if self.db.profile.showMinimapCapitalsFP then
                    minimap[125][72224575] = { mnID = 125, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dalaran
                end

            end

        --Professions Dalaran Northrend
            if self.db.profile.activate.MinimapCapitalsProfessions then

                if self.db.profile.showMinimapCapitalsFirstAid then
                    minimap[125][36803720] = { name = PROFESSIONS_FIRST_AID, type = "FirstAid", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsAlchemy then
                    minimap[125][42633205] = { name = L["Alchemy"], type = "Alchemy", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end
            
                if self.db.profile.showMinimapCapitalsLeatherworking then
                    minimap[125][34652896] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    minimap[125][33842922] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsEngineer then
                    minimap[125][39652486] = { name = L["Engineer"], type = "Engineer", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsSkinning then
                    minimap[125][34832786] = { name = L["Skinning"], type = "Skinning", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsTailoring then
                    minimap[125][36133357] = { name = L["Tailoring"], type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsJewelcrafting then
                    minimap[125][40693536] = { name = L["Jewelcrafting"], type = "Jewelcrafting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsBlacksmith then
                    minimap[125][45162895] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsMining then
                    minimap[125][41462566] = { name = L["Mining"], type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsFishing then
                    minimap[125][53066493] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsHerbalism then
                    minimap[125][42933408] = { name = L["Herbalism"], type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsInscription then
                    minimap[125][41593717] = { name = INSCRIPTION, type = "Inscription", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsEnchanting then
                    minimap[125][39043981] = { name = L["Enchanting"], type = "Enchanting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsArchaeology then
                    minimap[125][48363820] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.faction == "Horde" or db.activate.MinimapCapitalsEnemyFaction then

                    if self.db.profile.showMinimapCapitalsCooking then
                        minimap[125][69943898] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION .. "\n" .. ITEM_REQ_HORDE }
                    end

                end

                if self.faction == "Alliance" or db.activate.MinimapCapitalsEnemyFaction then

                    if self.db.profile.showMinimapCapitalsCooking then
                        minimap[125][40486581] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION .. "\n" .. ITEM_REQ_ALLIANCE }
                    end

                end

            end

        end

    end
end
end