local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

function ns.LoadCataCapitalsLocationinfo(self)
local db = ns.Addon.db.profile
local nodes = ns.nodes

--#####################################################################################################
--##########################        function to hide all nodes below         ##########################
--#####################################################################################################
if not db.activate.HideMapNote then

    --########################################################################################
    --################################         Capitals       ################################
    --########################################################################################
    if db.activate.Capitals then


    --###########################################################################################
    --################################         Horde Cities       ###############################
    --###########################################################################################


    --################
    --### Ogrimmar ###   
    --################
        if self.db.profile.showCapitalsOrgrimmar then

        --#############################
        --### Horde or EnemyFaction ###
        --#############################
            if self.faction == "Horde" or db.activate.CapitalsEnemyFaction then

            --Professions Orgrimmar
                if self.db.profile.activate.CapitalsProfessions then

                    if self.db.profile.showCapitalsFirstAid then
                        nodes[1454][37608720] = { name = PROFESSIONS_FIRST_AID, type = "FirstAid", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        nodes[1454][34008440] = { name = PROFESSIONS_FIRST_AID, type = "FirstAid", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsAlchemy then
                        nodes[1454][55684575] = { name = L["Alchemy"], type = "Alchemy", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                
                    if self.db.profile.showCapitalsLeatherworking then
                        nodes[1454][60745506] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsEngineer then
                        nodes[1454][56915635] = { name = L["Engineer"], type = "Engineer", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        nodes[1454][36578657] = { name = L["Engineer"], type = "Engineer", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsSkinning then
                        nodes[1454][39284964] = { name = L["Skinning"], type = "Skinning", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        nodes[1454][61195463] = { name = L["Skinning"], type = "Skinning", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsTailoring then
                        nodes[1454][38715060] = { name = L["Tailoring"], type = "Tailoring", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        nodes[1454][60755912] = { name = L["Tailoring"], type = "Tailoring", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        nodes[1454][41257982] = { name = L["Tailoring"], type = "Tailoring", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsJewelcrafting then
                        nodes[1454][72493435] = { name = L["Jewelcrafting"], type = "Jewelcrafting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsBlacksmith then
                        nodes[1454][75423394] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        nodes[1454][76163727] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        nodes[1454][40565021] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        nodes[1454][44337697] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        nodes[1454][35798333] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsMining then
                        nodes[1454][72363520] = { name = L["Mining"], type = "Mining", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        nodes[1454][44577872] = { name = L["Mining"], type = "Mining", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        nodes[1454][36178231] = { name = L["Mining"], type = "Mining", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsFishing then
                        nodes[1454][66434193] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        nodes[1454][35036706] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsCooking then
                        nodes[1454][56176171] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        nodes[1454][39108613] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        nodes[1454][32266958] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsArchaeology then
                        nodes[1454][49077056] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsHerbalism then
                        nodes[1454][54895027] = { name = L["Herbalism"], type = "Herbalism", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        nodes[1454][34816288] = { name = L["Herbalism"], type = "Herbalism", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsInscription then
                        nodes[1454][55185579] = { name = INSCRIPTION, type = "Inscription", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsEnchanting then
                        nodes[1454][53464937] = { name = L["Enchanting"], type = "Enchanting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                end

            --Transports Orgrimmar
                if self.db.profile.activate.CapitalsTransporting then

                    if self.db.profile.showCapitalsPortals then
                        nodes[86][44756784] = { mnID = 1419, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " => " .. L["Blasted Lands"] }
                        nodes[1454][47393928] = { mnID = 245, name = "", type = "HPortalS", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " => " .. DUNGEON_FLOOR_TOLBARADWARLOCKSCENARIO0 } --  Portal to Tol Barad
                        nodes[1454][48863851] = { mnID = 249, name = "", type = "HPortalS", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " => " .. L["Uldum"] } -- Portal to Uldum
                        nodes[1454][50243944] = { mnID = 241, name = "", type = "HPortalS", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " => " .. L["Twilight Highlands"] } -- Portal to Twilight Highlands
                        nodes[1454][51203832] = { mnID = 198, name = "", type = "HPortalS", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " => " .. POSTMASTER_LETTER_HYJAL } -- Portal to Hyjal
                        nodes[1454][50863628] = { mnID = 207, name = "", type = "HPortalS", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " => " .. ARTIFACT_SHAMAN_TITLECARD_DEEPHOLM } -- Portal to Deepholm
                        nodes[1454][49203647] = { mnID = 203, name = "", type = "HPortalS", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " => " .. L["Vashj'ir"] } -- Portal to Vashjir
                        nodes[1454][45856689] = { mnID = 86, name = "", type = "PassageHPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " => " .. L["Blasted Lands"] .. "\n" .. "(" .. DUNGEON_FLOOR_ORGRIMMAR1 .. ")" }
                        nodes[1454][41966110] = { mnID = 86, name = "", type = "PassageHPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " => " .. L["Blasted Lands"] .. "\n" .. "(" .. DUNGEON_FLOOR_ORGRIMMAR1 .. ")" }
                        nodes[1454][39725075] = { mnID = 198, name = "", type = "HPortalS", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " => " .. POSTMASTER_LETTER_HYJAL } -- Portal to Hyjal
                        nodes[1454][35526913] = { mnID = 86, name = "", type = "PassageHPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " => " .. L["Blasted Lands"] }
                    end

                    if self.db.profile.showCapitalsZeppelins then
                        nodes[1454][52175279] = { mnID = 1434, name = "", type = "HZeppelin", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Zeppelin"] .. " - " .. FACTION_HORDE .. "\n" .. " => " .. L["Grom'gol, Stranglethorn Vale"] }
                        nodes[1454][50905566] = { mnID = 1420, name = "", type = "HZeppelin", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Zeppelin"] .. " - " .. FACTION_HORDE .. "\n" .. " => " .. L["Tirisfal Glades"] .. " - " .. L["Undercity"] }
                        nodes[1454][44696222] = { mnID = 114, name = "", type = "HZeppelin", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Zeppelin"] .. " - " .. FACTION_HORDE .. "\n" .. " => " .. POSTMASTER_LETTER_WARSONGHOLD }
                        nodes[1454][42946497] = { mnID = 1456, name = "", type = "HZeppelin", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Zeppelin"] .. " - " .. FACTION_HORDE .. "\n" .. " => " .. L["Thunder Bluff"] }
                    end

                    if self.db.profile.showCapitalsFP then
                        nodes[1454][49615924] = { mnID = 1454, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Orgrimmar
                    end
    
                end
    
            --Instances Orgrimmar
                if self.db.profile.activate.CapitalsInstances then
    
                    if self.db.profile.showCapitalsDungeons then
                        nodes[1454][56615109] = { mnID = 86, name = DUNGEON_FLOOR_RAGEFIRE1 .. " " .. "[" .. LEVEL .. ": " .. "13-18]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "8", type = "PassageDungeon", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                end

            --General Orgrimmar
                if self.db.profile.activate.CapitalsGeneral then
    
                    if self.db.profile.showCapitalsPaths then
                        nodes[1454][74800606] = { dnID = L["Exit"], name = "", mnID = 1447, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit 
                        nodes[1454][49529373] = { dnID = L["Exit"], name = "", mnID = 1411, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit 
                        nodes[1454][23636814] = { dnID = L["Exit"], name = "", mnID = 1413, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit 
                        nodes[86][78691478] = { dnID = L["Passage"], name = "", mnID = 1454, type = "PathR", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit 
                        nodes[86][34209104] = { dnID = L["Passage"], name = "", mnID = 1454, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit 
                        nodes[86][22856905] = { dnID = L["Passage"], name = "", mnID = 1454, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit 
                    end

                    if self.db.profile.showCapitalsInnkeeper then
                        nodes[1454][70504917] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1454][53637877] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1454][39658116] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1454][38874864] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsAuctioneer then
                        nodes[1454][66643627] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1454][53957324] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1454][37307860] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1454][41644880] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsBank then
                        nodes[1454][48748348] = { dnID = BANK .. "\n" .. GUILD_BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1454][67615218] = { dnID = BANK .. "\n" .. GUILD_BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1454][39904626] = { dnID = BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1454][40634599] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1454][38457887] = { dnID = BANK .. "\n" .. GUILD_BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsMapNotes then
                        nodes[1454][32916483] = { dnID = MINIMAP_TRACKING_INNKEEPER .. "\n" .. BANK .. "\n" .. MINIMAP_TRACKING_AUCTIONEER, name = "", type = "MNL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsTransmogger then
                        nodes[1454][58116545] = { dnID = MINIMAP_TRACKING_TRANSMOGRIFIER .. "\n" .. L["Reforge"], name = "", type = "Transmogger", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                end

            end
        end

    --#####################
    --### Thunder Bluff ###
    --#####################
        if self.db.profile.showCapitalsThunderBluff then

        --#############################
        --### Horde or EnemyFaction ###
        --#############################
            if self.faction == "Horde" or db.activate.CapitalsEnemyFaction then

            --Professions Thunder Bluff
                if self.db.profile.activate.CapitalsProfessions then

                    if self.db.profile.showCapitalsFirstAid then
                        nodes[1456][29602160] = { name = PROFESSIONS_FIRST_AID, type = "FirstAid", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsAlchemy then
                        nodes[1456][46643317] = { name = L["Alchemy"], type = "Alchemy", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                
                    if self.db.profile.showCapitalsLeatherworking then
                        nodes[1456][41514257] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsEngineer then
                        nodes[1456][36065961] = { name = L["Engineer"], type = "Engineer", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsSkinning then
                        nodes[1456][44424321] = { name = L["Skinning"], type = "Skinning", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsTailoring then
                        nodes[1456][44544531] = { name = L["Tailoring"], type = "Tailoring", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsJewelcrafting then
                        nodes[1456][34825399] = { name = L["Jewelcrafting"], type = "Jewelcrafting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsBlacksmith then
                        nodes[1456][39365510] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsMining then
                        nodes[1456][34385790] = { name = L["Mining"], type = "Mining", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsFishing then
                        nodes[1456][56144642] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsCooking then
                        nodes[1456][50745310] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsArchaeology then
                        nodes[1456][75032812] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsHerbalism then
                        nodes[1456][49954040] = { name = L["Herbalism"], type = "Herbalism", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsEnchanting then
                        nodes[1456][45283847] = { name = L["Enchanting"], type = "Enchanting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsInscription then
                        nodes[1456][28722088] = { name = L["Enchanting"], type = "Enchanting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        nodes[1456][30323012] = { name = L["Passage"] .. " " .. MINIMAP_TRACKING_TRAINER_PROFESSION, type = "PassageLeftL", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName =  INSCRIPTION }
                    end

                end

            --Transports Thunder Bluff
                if self.db.profile.activate.CapitalsTransporting then
  
                    if self.db.profile.showCapitalsZeppelins then
                        nodes[1456][14292570] = { mnID = 1454, name = "", type = "HZeppelin", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Zeppelin"] .. " => " .. DUNGEON_FLOOR_ORGRIMMAR0 } -- Zeppelin from Thunder Bluff to OG
                    end

                    if self.db.profile.showCapitalsPortals then
                        nodes[1456][23121355] = { mnID = 1419, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " => " .. L["Blasted Lands"] }

                    end

                    if self.db.profile.showCapitalsFP then
                        nodes[1456][46974977] = { mnID = 1456, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Thunder Bluff
                    end

                end

            --General Thunder Bluff
                if self.db.profile.activate.CapitalsGeneral then
    
                    if self.db.profile.showCapitalsPaths then
                        nodes[1456][52232561] = { dnID = L["Exit"], name = "", mnID = 1412, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1456][54632715] = { dnID = L["Exit"], name = "", mnID = 1412, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1456][31886595] = { dnID = L["Exit"], name = "", mnID = 1412, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1456][31456256] = { dnID = L["Exit"], name = "", mnID = 1412, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsInnkeeper then
                        nodes[1456][45856477] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsAuctioneer then
                        nodes[1456][38875023] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1456][40435169] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    
                    if self.db.profile.showCapitalsBank then
                        nodes[1456][47175862] = { dnID = BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                end

            end    
        end

    --##################
    --### Silvermoon ###
    --##################
        if self.db.profile.showCapitalsSilvermoon then

        --#############################
        --### Horde or EnemyFaction ###
        --#############################
            if self.faction == "Horde" or db.activate.CapitalsEnemyFaction then

            --Professions Silvermoon
                if self.db.profile.activate.CapitalsProfessions then

                    if self.db.profile.showCapitalsFirstAid then
                        nodes[1954][78007040] = { name = PROFESSIONS_FIRST_AID, type = "FirstAid", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsAlchemy then
                        nodes[1954][66701673] = { name = L["Alchemy"], type = "Alchemy", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                
                    if self.db.profile.showCapitalsLeatherworking then
                        nodes[1954][85008054] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsEngineer then
                        nodes[1954][76634110] = { name = L["Engineer"], type = "Engineer", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsSkinning then
                        nodes[1954][84997931] = { name = L["Skinning"], type = "Skinning", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsTailoring then
                        nodes[1954][57365009] = { name = L["Tailoring"], type = "Tailoring", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsJewelcrafting then
                        nodes[1954][91377443] = { name = L["Jewelcrafting"], type = "Jewelcrafting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        nodes[1954][90327383] = { name = L["Jewelcrafting"], type = "Jewelcrafting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsBlacksmith then
                        nodes[1954][79423869] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsMining then
                        nodes[1954][78914322] = { name = L["Mining"], type = "Mining", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsFishing then
                        nodes[1954][76246779] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsCooking then
                        nodes[1954][69647153] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsArchaeology then
                        nodes[1954][75032812] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        nodes[1954][81436390] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsHerbalism then
                        nodes[1954][67401842] = { name = L["Herbalism"], type = "Herbalism", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsInscription then
                        nodes[1954][69322382] = { name = INSCRIPTION, type = "Inscription", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsEnchanting then
                        nodes[1954][70012365] = { name = L["Enchanting"], type = "Enchanting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                end

            --Transports Silvermoon
                if self.db.profile.activate.CapitalsTransporting then

                    if self.db.profile.showCapitalsPortals then
                        nodes[1954][49401484] = { mnID = 1458, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " => " .. L["Undercity"] } -- Portal to Undercity
                        nodes[1954][58412106] = { mnID = 1458, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " => " .. L["Blasted Lands"] } -- Portal from TB
                    end

                end

            --General Silvermoon
                if self.db.profile.activate.CapitalsGeneral then
    
                    if self.db.profile.showCapitalsPaths then
                        nodes[1954][72609199] = { dnID = L["Exit"], name = "", mnID = 1941, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit 
                    end

                    if self.db.profile.showCapitalsInnkeeper then
                        nodes[1954][79465822] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1954][67867288] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsAuctioneer then
                        nodes[1954][92735828] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1954][60726258] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsBank then
                        nodes[1954][89714509] = { dnID = BANK .. "\n" .. GUILD_BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1954][65807788] = { dnID = BANK .. "\n" .. GUILD_BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                end

            end

        end

    --#################
    --### Undercity ###
    --#################
        if self.db.profile.showCapitalsUndercity then

        --#############################
        --### Horde or EnemyFaction ###
        --#############################
            if self.faction == "Horde" or db.activate.CapitalsEnemyFaction then

            --Professions Undercity
                if self.db.profile.activate.CapitalsProfessions then

                    if self.db.profile.showCapitalsFirstAid then
                        nodes[1458][73605560] = { name = PROFESSIONS_FIRST_AID, type = "FirstAid", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsAlchemy then
                        nodes[1458][47757332] = { name = L["Alchemy"], type = "Alchemy", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        nodes[1458][52947737] = { name = L["Passage"] .. " " .. MINIMAP_TRACKING_TRAINER_PROFESSION, type = "PassageLeftL", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName =  L["Alchemy"] }
                        nodes[1458][44626639] = { name = L["Passage"] .. " " .. MINIMAP_TRACKING_TRAINER_PROFESSION, type = "PassageLeftL", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName =  L["Alchemy"] }
                    end
                
                    if self.db.profile.showCapitalsLeatherworking then
                        nodes[1458][70155740] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsEngineer then
                        nodes[1458][76107409] = { name = L["Engineer"], type = "Engineer", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsSkinning then
                        nodes[1458][70165922] = { name = L["Skinning"], type = "Skinning", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsTailoring then
                        nodes[1458][70763072] = { name = L["Tailoring"], type = "Tailoring", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsJewelcrafting then
                        nodes[1458][56503630] = { name = L["Jewelcrafting"], type = "Jewelcrafting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsBlacksmith then
                        nodes[1458][61313061] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsMining then
                        nodes[1458][56043744] = { name = L["Mining"], type = "Mining", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsFishing then
                        nodes[1458][80693124] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsCooking then
                        nodes[1458][62194489] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsArchaeology then
                        nodes[1458][75403772] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsHerbalism then
                        nodes[1458][54014961] = { name = L["Herbalism"], type = "Herbalism", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsInscription then
                        nodes[1458][61065801] = { name = INSCRIPTION, type = "Inscription", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsEnchanting then
                        nodes[1458][61866139] = { name = L["Enchanting"], type = "Enchanting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                end

            --Transports Undercity
                if self.db.profile.activate.CapitalsTransporting then

                    if self.db.profile.showCapitalsPortals then
                        nodes[1458][55011129] = { mnID = 1954, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " => " .. L["Silvermoon City"] .. "\n" .. "(" .. DUNGEON_FLOOR_GILNEAS3 .. ")" } -- Portal to Silvermoon from Tirisfal
                        nodes[1458][85191687] = { mnID = 1419, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " => " .. L["Blasted Lands"] } -- Portal to Silvermoon 
                    end

                    if self.db.profile.showCapitalsFP then
                        nodes[1458][63164844] = { mnID = 1458, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Undercity
                    end

                end

            --General Undercity
                if self.db.profile.activate.CapitalsGeneral then
    
                    if self.db.profile.showCapitalsPaths then
                        nodes[1458][15003101] = { dnID = L["Exit"], name = "", mnID = 1420, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit 
                        nodes[1458][46474406] = { dnID = L["Exit"], name = "", mnID = 1420, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit 
                        nodes[1458][66110384] = { dnID = L["Exit"] .. " " .. DUNGEON_FLOOR_GILNEAS3, name = "", mnID = 1420, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit 
                        nodes[1458][49792975] = { dnID = L["Exit"], name = "", mnID = 1420, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = REQUIRES_LABEL .. " " .. MOUNT_JOURNAL_FILTER_FLYING } -- Passage/Exit 
                        nodes[1458][65865202] = { dnID = DUNGEON_FLOOR_GILNEAS3 .. " => " .. DUNGEON_FLOOR_GILNEAS2 .. "\n" ..  DUNGEON_FLOOR_GILNEAS2 .. " => " .. DUNGEON_FLOOR_GILNEAS3, name = "", type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit 
                        nodes[1458][60584399] = { dnID = DUNGEON_FLOOR_GILNEAS3 .. " => " .. DUNGEON_FLOOR_GILNEAS2 .. "\n" ..  DUNGEON_FLOOR_GILNEAS2 .. " => " .. DUNGEON_FLOOR_GILNEAS3, name = "", type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit 
                        nodes[1458][71294410] = { dnID = DUNGEON_FLOOR_GILNEAS3 .. " => " .. DUNGEON_FLOOR_GILNEAS2 .. "\n" ..  DUNGEON_FLOOR_GILNEAS2 .. " => " .. DUNGEON_FLOOR_GILNEAS3, name = "", type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit 
                    end

                    if self.db.profile.showCapitalsInnkeeper then
                        nodes[1458][67743784] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsAuctioneer then
                        nodes[1458][60534156] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1458][64363583] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1458][67663591] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1458][71494189] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1458][71394672] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1458][67545239] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1458][64415242] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1458][60494647] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsBank then
                        nodes[1458][66014406] = { dnID = BANK .. "\n" .. GUILD_BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsGhost then
                        nodes[1458][67851396] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Undercity
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
        if self.db.profile.showCapitalsStormwind then

        --################################
        --### Alliance or EnemyFaction ###
        --################################
            if self.faction == "Alliance" or db.activate.CapitalsEnemyFaction then

            --Instances Stormwind
                if self.db.profile.activate.CapitalsInstances then
    
                    if self.db.profile.showCapitalsDungeons then
                        nodes[1453][50356644] = { mnID = 1453, name = DUNGEON_FLOOR_THESTOCKADE1 .. " " .. "[" .. LEVEL .. ": " .. "22-30]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "15", type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                end

            --Transports Stormwind
                if self.db.profile.activate.CapitalsTransporting then

                    if self.db.profile.showCapitalsPortals then
                        nodes[1453][82512804] = { mnID = 198, name = "", type = "APortalS", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " => " .. POSTMASTER_LETTER_HYJAL } -- Portal to Hyjal
                        nodes[1453][18472650] = { mnID = 114, name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. "\n" .. " => " .. POSTMASTER_LETTER_VALIANCEKEEP } -- 
                        nodes[1453][22575571] = { mnID = 114, name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. "\n" .. " => " .. POSTMASTER_LETTER_VALIANCEKEEP } -- 
                        nodes[1453][73221836] = { mnID = 245, name = "", type = "APortalS", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " => " .. DUNGEON_FLOOR_TOLBARADWARLOCKSCENARIO0 } --  Portal to Tol Barad
                        nodes[1453][75232055] = { mnID = 249, name = "", type = "APortalS", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " => " .. L["Uldum"] } -- Portal to Uldum
                        nodes[1453][75351649] = { mnID = 241, name = "", type = "APortalS", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " => " .. L["Twilight Highlands"] } -- Portal to Twilight Highlands
                        nodes[1453][76211869] = { mnID = 198, name = "", type = "APortalS", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " => " .. POSTMASTER_LETTER_HYJAL } -- Portal to Hyjal
                        nodes[1453][73171966] = { mnID = 207, name = "", type = "APortalS", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " => " .. ARTIFACT_SHAMAN_TITLECARD_DEEPHOLM } -- Portal to Deepholm
                        nodes[1453][73301687] = { mnID = 203, name = "", type = "APortalS", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " => " .. L["Vashj'ir"] } -- Portal to Vashjir
                        nodes[1453][48838705] = { mnID = 1458, name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " => " .. L["Blasted Lands"] } 
                        nodes[1453][18142463] = { mnID = 203, name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " => " .. L["Vashj'ir"] } -- Portal to Vashjir
                    end
   
                    if self.db.profile.showCapitalsShips then
                        nodes[1453][20675628] = { mnID = 1439, name = "", type = "AShip", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Ship"] .. "\n" .. " => " .. L["Rut'theran"] } --
                        nodes[1453][16732506] = { mnID = 114, name = "", type = "AShip", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Ship"] .. "\n" .. " => " .. POSTMASTER_LETTER_VALIANCEKEEP } --
                    end

                    if self.db.profile.showCapitalsTransport then
                        nodes[1453][66723356] = { mnID = 1455, name = "", type = "Carriage", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Stormwind"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. DUNGEON_FLOOR_DEEPRUNTRAM1 .. "\n" .. " => " .. L["Ironforge"] } -- Transport to Ironforge Carriage 
                    end

                    if self.db.profile.showCapitalsFP then
                        nodes[1453][70777249] = { mnID = 1453, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Stormwind
                    end

                end

            --Professions Stormwind
                if self.db.profile.activate.CapitalsProfessions then

                    if self.db.profile.showCapitalsFirstAid then
                        nodes[1453][52204560] = { name = PROFESSIONS_FIRST_AID, type = "FirstAid", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        nodes[1453][52804480] = { name = PROFESSIONS_FIRST_AID, type = "FirstAid", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsAlchemy then
                        nodes[1453][55668610] = { name = L["Alchemy"], type = "Alchemy", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                
                    if self.db.profile.showCapitalsLeatherworking then
                        nodes[1453][71676301] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsEngineer then
                        nodes[1453][62863192] = { name = L["Engineer"], type = "Engineer", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsSkinning then
                        nodes[1453][72136222] = { name = L["Skinning"], type = "Skinning", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsTailoring then
                        nodes[1453][53098136] = { name = L["Tailoring"], type = "Tailoring", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        nodes[1453][52011954] = { name = L["Tailoring"], type = "Tailoring", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsJewelcrafting then
                        nodes[1453][63486183] = { name = L["Jewelcrafting"], type = "Jewelcrafting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsBlacksmith then
                        nodes[1453][63663702] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsMining then
                        nodes[1453][59523778] = { name = L["Mining"], type = "Mining", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        nodes[1453][49371220] = { name = L["Mining"], type = "Mining", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsFishing then
                        nodes[1453][54806960] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsCooking then
                        nodes[1453][77285321] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        nodes[1453][50657384] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsArchaeology then
                        nodes[1453][85812593] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsHerbalism then
                        nodes[1453][54298408] = { name = L["Herbalism"], type = "Herbalism", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsInscription then
                        nodes[1453][49827479] = { name = INSCRIPTION, type = "Inscription", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsEnchanting then
                        nodes[1453][52907447] = { name = L["Enchanting"], type = "Enchanting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        nodes[1453][51211270] = { name = L["Enchanting"], type = "Enchanting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                end

            --General Stormwind
                if self.db.profile.activate.CapitalsGeneral then
    
                    if self.db.profile.showCapitalsPaths then
                        nodes[1453][73399051] = { dnID = L["Exit"], name = "", mnID = 1429, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit 
                    end

                    if self.db.profile.showCapitalsInnkeeper then
                        nodes[1453][60407527] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1453][75685411] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1453][49881574] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1453][64943193] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsAuctioneer then
                        nodes[1453][61167081] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1453][60233216] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsBank then
                        nodes[1453][62887831] = { dnID = BANK .. "\n" .. GUILD_BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1453][64562883] = { dnID = BANK .. "\n" .. GUILD_BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsTransmogger then
                        nodes[1453][50396054] = { dnID = MINIMAP_TRACKING_TRANSMOGRIFIER .. "\n" .. L["Reforge"], name = "", type = "Transmogger", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                end

            end

        end

    --#################
    --### Ironforge ###
    --#################
        if self.db.profile.showCapitalsIronforge then

        --################################
        --### Alliance or EnemyFaction ###
        --################################
            if self.faction == "Alliance" or db.activate.CapitalsEnemyFaction then

            --Transports Ironforge
                if self.db.profile.activate.CapitalsTransporting then

                    if self.db.profile.showCapitalsTransport then
                        nodes[1455][73375055] = { mnID = 1453, name = "", type = "Carriage", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Ironforge"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. DUNGEON_FLOOR_DEEPRUNTRAM1 .. "\n" .. " => " .. L["Stormwind"] } -- Transport to Ironforge Carriage 
                    end

                    if self.db.profile.showCapitalsPortals then
                        nodes[1455][27030696] = { mnID = 1458, name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " => " .. L["Blasted Lands"] } 
                    end

                    if self.db.profile.showCapitalsFP then
                        nodes[1455][55384778] = { mnID = 1455, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ironfrge
                    end

                end

            --Professions ironforge
                if self.db.profile.activate.CapitalsProfessions then

                    if self.db.profile.showCapitalsFirstAid then
                        nodes[1455][54805860] = { name = PROFESSIONS_FIRST_AID, type = "FirstAid", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsAlchemy then
                        nodes[1455][66615566] = { name = L["Alchemy"], type = "Alchemy", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                
                    if self.db.profile.showCapitalsLeatherworking then
                        nodes[1455][40223365] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsEngineer then
                        nodes[1455][68444359] = { name = L["Engineer"], type = "Engineer", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsSkinning then
                        nodes[1455][39843248] = { name = L["Skinning"], type = "Skinning", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsTailoring then
                        nodes[1455][43132939] = { name = L["Tailoring"], type = "Tailoring", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsJewelcrafting then
                        nodes[1455][50192602] = { name = L["Jewelcrafting"], type = "Jewelcrafting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsBlacksmith then
                        nodes[1455][50324338] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        nodes[1455][52554139] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsMining then
                        nodes[1455][50142649] = { name = L["Mining"], type = "Mining", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsFishing then
                        nodes[1455][48090763] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsCooking then
                        nodes[1455][60073646] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsArchaeology then
                        nodes[1455][75611110] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsHerbalism then
                        nodes[1455][55865907] = { name = L["Herbalism"], type = "Herbalism", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsInscription then
                        nodes[1455][61004516] = { name = INSCRIPTION, type = "Inscription", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsEnchanting then
                        nodes[1455][60114533] = { name = L["Enchanting"], type = "Enchanting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                end

            --General Ironforge
                if self.db.profile.activate.CapitalsGeneral then
    
                    if self.db.profile.showCapitalsPaths then
                        nodes[1455][14218604] = { dnID = L["Exit"], name = "", mnID = 1426, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit 
                    end

                    if self.db.profile.showCapitalsInnkeeper then
                        nodes[1455][18165147] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsAuctioneer then
                        nodes[1455][25517317] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsBank then
                        nodes[1455][35646042] = { dnID = BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1455][33516017] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1455][35386360] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                end

            end

        end

    --#################
    --### Darnassus ###
    --#################
        if self.db.profile.showCapitalsDarnassus then

        --##########################
        --### Horde and Alliance ###
        --##########################
        --Transports Darnassus
            if self.db.profile.activate.CapitalsTransporting then

                if self.db.profile.showCapitalsPortals then
                    nodes[1457][36045019] = { mnID = 1438, name = "", type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " => " .. L["Rut'theran"] } -- Portal To Darnassus from Teldrassil
                end

            end

        --################################
        --### Alliance or EnemyFaction ###
        --################################
            if self.faction == "Alliance" or db.activate.CapitalsEnemyFaction then

            --General Darnassus
                if self.db.profile.activate.CapitalsGeneral then
    
                    if self.db.profile.showCapitalsPaths then
                        nodes[1457][79984648] = { dnID = L["Exit"], name = "", mnID = 1438, type = "PathR", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit Exodar
                    end

                    if self.db.profile.showCapitalsInnkeeper then
                        nodes[1457][62533278] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsAuctioneer then
                        nodes[1457][54915837] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsBank then
                        nodes[1457][44285140] = { dnID = BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1457][42655247] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsBank then
                        nodes[1457][77662585] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Darnassus
                    end

                end

            --Transports Darnassus
                if self.db.profile.activate.CapitalsTransporting then

                    if self.db.profile.showCapitalsPortals then
                        nodes[1457][44127840] = { name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portals"] .. "\n" .. " => " .. L["Exodar"] .. "\n" .. " => " .. L["Hellfire Peninsula"] } -- Portal To Darnassus from Teldrassil
                    end

                    if self.db.profile.showCapitalsFP then
                        nodes[1457][36464775] = { mnID = 1457, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Blutmythosinsel
                    end

                end

            --Professions Darnassus
                if self.db.profile.activate.CapitalsProfessions then

                    if self.db.profile.showCapitalsFirstAid then
                        nodes[1457][51601360] = { name = PROFESSIONS_FIRST_AID, type = "FirstAid", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsAlchemy then
                        nodes[1457][53913853] = { name = L["Alchemy"], type = "Alchemy", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                
                    if self.db.profile.showCapitalsLeatherworking then
                        nodes[1457][60463683] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsEngineer then
                        nodes[1457][49613236] = { name = L["Engineer"], type = "Engineer", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsSkinning then
                        nodes[1457][60273733] = { name = L["Skinning"], type = "Skinning", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsTailoring then
                        nodes[1457][59783740] = { name = L["Tailoring"], type = "Tailoring", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsJewelcrafting then
                        nodes[1457][53993111] = { name = L["Jewelcrafting"], type = "Jewelcrafting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsBlacksmith then
                        nodes[1457][56985271] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsMining then
                        nodes[1457][50083357] = { name = L["Mining"], type = "Mining", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsFishing then
                        nodes[1457][49096098] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsCooking then
                        nodes[1457][49893663] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsArchaeology then
                        nodes[1457][42658334] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsHerbalism then
                        nodes[1457][49146878] = { name = L["Herbalism"], type = "Herbalism", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsInscription then
                        nodes[1457][56793163] = { name = INSCRIPTION, type = "Inscription", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsEnchanting then
                        nodes[1457][56413101] = { name = L["Enchanting"], type = "Enchanting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                end

            end

        end

    --##############
    --### Exodar ###
    --##############
        if self.db.profile.showCapitalsExodar then

        --################################
        --### Alliance or EnemyFaction ###
        --################################
            if self.faction == "Alliance" or db.activate.CapitalsEnemyFaction then

            --General Exodar
                if self.db.profile.activate.CapitalsGeneral then
    
                    if self.db.profile.showCapitalsPaths then
                        nodes[1947][34947443] = { dnID = L["Exit"], name = "", mnID = 1943, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit Exodar
                        nodes[1947][65223478] = { dnID = L["Exit"], name = "", mnID = 1943, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit Exodar
                    end

                    if self.db.profile.showCapitalsInnkeeper then
                        nodes[1947][59511876] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsAuctioneer then
                        nodes[1947][61935508] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsBank then
                        nodes[1947][49224406] = { dnID = BANK .. "\n" .. GUILD_BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                end

            --Transports Exodar
                if self.db.profile.activate.CapitalsTransporting then

                    if self.db.profile.showCapitalsPortals then
                        nodes[1947][48106302] = { mnID = 1419, name = "", type = "APortalS", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " => " .. L["Blasted Lands"] }
                        nodes[1947][47596210] = { mnID = 1453, name = "", type = "APortalS", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " => " .. L["Darnassus"] }
                    end

                    if self.db.profile.showCapitalsFP then
                        nodes[1947][54463620] = { mnID = 1947, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Blutmythosinsel
                    end

                end

            --Professions Exodar
                if self.db.profile.activate.CapitalsProfessions then

                    if self.db.profile.showCapitalsFirstAid then
                        nodes[1947][39602260] = { name = PROFESSIONS_FIRST_AID, type = "FirstAid", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION .. "\n" .. ERR_USE_OBJECT_MOVING }
                    end

                    if self.db.profile.showCapitalsAlchemy then
                        nodes[1947][27766078] = { name = L["Alchemy"], type = "Alchemy", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                
                    if self.db.profile.showCapitalsLeatherworking then
                        nodes[1947][67467457] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsEngineer then
                        nodes[1947][54139288] = { name = L["Engineer"], type = "Engineer", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsSkinning then
                        nodes[1947][65657456] = { name = L["Skinning"], type = "Skinning", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsTailoring then
                        nodes[1947][64386894] = { name = L["Tailoring"], type = "Tailoring", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsJewelcrafting then
                        nodes[1947][44882424] = { name = L["Jewelcrafting"], type = "Jewelcrafting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsBlacksmith then
                        nodes[1947][60609000] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsMining then
                        nodes[1947][59698781] = { name = L["Mining"], type = "Mining", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsFishing then
                        nodes[1947][31931462] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsCooking then
                        nodes[1947][55772672] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsArchaeology then
                        nodes[1947][33316569] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsHerbalism then
                        nodes[1947][27456281] = { name = L["Herbalism"], type = "Herbalism", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsInscription then
                        nodes[1947][39833860] = { name = INSCRIPTION, type = "Inscription", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsEnchanting then
                        nodes[1947][40693881] = { name = L["Enchanting"], type = "Enchanting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
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
        if self.db.profile.showCapitalsShattrath then

        --General Shattrath
            if self.db.profile.activate.CapitalsGeneral then
    
                if self.db.profile.showCapitalsInnkeeper then
                    nodes[1955][56278147] = { dnID = MINIMAP_TRACKING_INNKEEPER .. " - " .. L["The Scryers"], name = "", type = "Innkeeper", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1955][28284938] = { dnID = MINIMAP_TRACKING_INNKEEPER .. " - " .. L["The Aldor"], name = "", type = "Innkeeper", showInZone = true, showOnContinent = false, showOnMinimap = false }

                    if self.db.profile.showCapitalsMapNotes then
                        nodes[1955][43849031] = { dnID = TUTORIAL_TITLE38 .. " - " .. L["The Scryers"] .. "\n" .. "\n" .. L["Alchemy"] .. "\n" .. L["Engineer"] .. "\n" .. L["Jewelcrafting"] .. "\n" .. L["Leatherworking"] .. "\n" .. L["Blacksmithing"] .. "\n" .. L["Tailoring"] .. "\n" .. L["Skinning"] .. "\n" .. L["Mining"] .. "\n" .. L["Herbalism"] .. "\n" .. L["Enchanting"] .. "\n" .. INSCRIPTION .. "\n" .. PROFESSIONS_FISHING .. "\n" .. PROFESSIONS_COOKING, name = "", type = "MNL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                end

                if self.db.profile.showCapitalsPaths then
                    nodes[1955][68936616] = { name = L["Exit"], mnID = 1952, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1955][77264326] = { name = L["Exit"], mnID = 1952, type = "PathR", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1955][72291901] = { name = L["Exit"], mnID = 1952, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1955][61790952] = { name = L["Exit"], mnID = 1952, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1955][79515778] = { name = L["Exit"], mnID = 1952, type = "PathR", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1955][22344989] = { name = L["Exit"], mnID = 1951, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.db.profile.showCapitalsAuctioneer then
                    nodes[1955][57066278] = { name = MINIMAP_TRACKING_AUCTIONEER .. " - " .. L["The Scryers"], type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1955][51242693] = { name = MINIMAP_TRACKING_AUCTIONEER .. " - " .. L["The Aldor"], type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.db.profile.showCapitalsBank then
                    nodes[1955][60226036] = { dnID = BANK .. " - " .. L["The Scryers"], name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1955][62245901] = { dnID = GUILD_BANK  .. " - " .. L["The Scryers"], name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1955][47932940] = { dnID = BANK .. " - " .. L["The Aldor"], name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1955][46113106] = { dnID = GUILD_BANK  .. " - " .. L["The Aldor"], name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

            end

        --Transports Shattrath
            if self.db.profile.activate.CapitalsTransporting then
    
                if self.db.profile.showCapitalsPortals then
                    nodes[1955][48624205] = { mnID = 1957, name = "", type = "Portal", TransportName = L["Shattrath City"] .. " " .. L["Portal"] .. "\n" ..  "\n" .. " => " .. L["Isle of Quel'Danas"] , showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal from Shattrath to Orgrimmar

                    if self.faction == "Horde" or db.activate.CapitalsEnemyFaction then
                        nodes[1955][59214836] = { mnID = 1454, name = "", type = "HPortal", TransportName = L["Shattrath City"] .. " " .. L["Portal"] .. "\n" .. " => " .. DUNGEON_FLOOR_ORGRIMMAR0, showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal from Hellfire to Orgrimmar
                    end

                    if self.faction == "Alliance" or db.activate.CapitalsEnemyFaction then
                        nodes[1955][59504662] = { mnID = 1453,  name = "" , type = "APortal", TransportName = L["Shattrath City"] .. " " .. L["Portal"] .. "\n" .. " => " .. L["Stormwind"], showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal from Hellfire to Stormwind
                    end

                end

                if self.db.profile.showCapitalsFP then
                    nodes[1955][64014098] = { mnID = 1955, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Shattrath
                end

            end

        --Professions Shattrath
            if self.db.profile.activate.CapitalsProfessions then

                if self.db.profile.showCapitalsFirstAid then
                    nodes[1955][66601360] = { name = PROFESSIONS_FIRST_AID, type = "FirstAid", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    nodes[1955][43809040] = { name = PROFESSIONS_FIRST_AID .. " - " .. L["The Scryers"], type = "FirstAid", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsAlchemy then
                    nodes[1955][37977048] = { name = L["Alchemy"] .. " - " .. L["The Scryers"], type = "Alchemy", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    nodes[1955][38892992] = { name = L["Alchemy"] .. " - " .. L["The Aldor"], type = "Alchemy", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    nodes[1955][45612149] = { name = L["Alchemy"], type = "Alchemy", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end
            
                if self.db.profile.showCapitalsLeatherworking then
                    nodes[1955][41366301] = { name = L["Leatherworking"] .. " - " .. L["The Scryers"], type = "Leatherworking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    nodes[1955][37652815] = { name = L["Leatherworking"] .. " - " .. L["The Aldor"], type = "Leatherworking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    nodes[1955][67256738] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }

                end

                if self.db.profile.showCapitalsEngineer then
                    nodes[1955][43926531] = { name = L["Engineer"] .. " - " .. L["The Scryers"], type = "Engineer", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    nodes[1955][37823205] = { name = L["Engineer"] .. " - " .. L["The Aldor"], type = "Engineer", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsSkinning then
                    nodes[1955][40626347] = { name = L["Skinning"] .. " - " .. L["The Scryers"], type = "Skinning", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    nodes[1955][36972686] = { name = L["Skinning"] .. " - " .. L["The Aldor"], type = "Skinning", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    nodes[1955][63946588] = { name = L["Skinning"], type = "Skinning", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsTailoring then
                    nodes[1955][41176365] = { name = L["Tailoring"] .. " - " .. L["The Scryers"], type = "Tailoring", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    nodes[1955][37812700] = { name = L["Tailoring"] .. " - " .. L["The Aldor"], type = "Tailoring", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsJewelcrafting then
                    nodes[1955][58027508] = { name = L["Jewelcrafting"] .. " - " .. L["The Scryers"], type = "Jewelcrafting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    nodes[1955][35671956] = { name = L["Jewelcrafting"] .. " - " .. L["The Aldor"], type = "Jewelcrafting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    nodes[1955][36024745] = { name = L["Jewelcrafting"] .. " - " .. L["The Aldor"], type = "Jewelcrafting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsBlacksmith then
                    nodes[1955][43236492] = { name = L["Blacksmithing"] .. " - " .. L["The Scryers"], type = "Blacksmith", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    nodes[1955][37293132] = { name = L["Blacksmithing"] .. " - " .. L["The Aldor"], type = "Blacksmith", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsMining then
                    nodes[1955][58917523] = { name = L["Mining"] .. " - " .. L["The Scryers"], type = "Mining", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    nodes[1955][36054859] = { name = L["Mining"] .. " - " .. L["The Aldor"], type = "Mining", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsFishing then
                    nodes[1955][43439160] = { name = PROFESSIONS_FISHING .. " - " .. L["The Scryers"], type = "Fishing", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsHerbalism then
                    nodes[1955][38807156] = { name = L["Herbalism"] .. " - " .. L["The Scryers"], type = "Herbalism", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    nodes[1955][38073007] = { name = L["Herbalism"] .. " - " .. L["The Aldor"], type = "Herbalism", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsInscription then
                    nodes[1955][55947403] = { name = INSCRIPTION .. " - " .. L["The Scryers"], type = "Inscription", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    nodes[1955][36014345] = { name = INSCRIPTION .. " - " .. L["The Aldor"], type = "Inscription", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsEnchanting then
                    nodes[1955][55417484] = { name = L["Enchanting"] .. " - " .. L["The Scryers"], type = "Enchanting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    nodes[1955][43299253] = { name = L["Enchanting"] .. " - " .. L["The Scryers"], type = "Enchanting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    nodes[1955][36514454] = { name = L["Enchanting"] .. " - " .. L["The Aldor"], type = "Enchanting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsArchaeology then
                    nodes[1955][62667040] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsCooking then
                    nodes[1955][74793084] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    nodes[1955][63066835] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

            end

        end

    --#########################
    --### Dalaran Northrend ###
    --#########################
        if self.db.profile.showCapitalsDalaranNorthrend then

        --Instance Dalaran Northrend
            if self.db.profile.activate.CapitalsInstances then

                if self.db.profile.showCapitalsDungeons then
                    nodes[125][66976828] = { mnID = 125, showInZone = true, showOnContinent = false, showOnMinimap = false, name = DUNGEON_FLOOR_VIOLETHOLD1 .. " " .. "[" .. LEVEL .. ": " .. "75-77]", type = "Dungeon" } -- Violet Hold
                end

            end

        --General Dalaran Northrend
            if self.db.profile.activate.CapitalsGeneral then
    
                if self.db.profile.showCapitalsInnkeeper then
                    nodes[125][50273955] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[126][35425767] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = true, showOnContinent = false, showOnMinimap = false }


                    if self.faction == "Horde" or db.activate.CapitalsEnemyFaction then
                        nodes[125][65613218] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, TransportName = ITEM_REQ_HORDE, type = "Innkeeper", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.faction == "Alliance" or db.activate.CapitalsEnemyFaction then
                        nodes[125][44666336] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, TransportName = ITEM_REQ_ALLIANCE, type = "Innkeeper", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                end

                if self.db.profile.showCapitalsPaths then
                    nodes[126][11648435] = { name = L["Exit"], mnID = 127, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[126][25044295] = { name = "", mnID = 125, TransportName = L["Passage"] .. "\n" .. " => " .. DUNGEON_FLOOR_DALARAN1, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[126][66484766] = { name = "", mnID = 125, TransportName = L["Passage"] .. "\n" .. " => " .. DUNGEON_FLOOR_DALARAN1, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[125][35294528] = { name = "", mnID = 126, TransportName = L["Passage"] .. "\n" .. " => " .. DUNGEON_FLOOR_DALARAN2, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[125][60294758] = { name = "", mnID = 126, TransportName = L["Passage"] .. "\n" .. " => " .. DUNGEON_FLOOR_DALARAN2, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[125][47873232] = { name = "", mnID = 126, TransportName = L["Passage"] .. "\n" .. " => " .. DUNGEON_FLOOR_DALARAN2, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.db.profile.showCapitalsAuctioneer then
                    nodes[125][38402502] = { name = MINIMAP_TRACKING_AUCTIONEER, type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = REQUIRES_LABEL .. " " .. L["Engineer"] }

                    if self.faction == "Horde" or db.activate.CapitalsEnemyFaction then
                        nodes[125][65522343] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = ITEM_REQ_HORDE}
                    end

                    if self.faction == "Alliance" or db.activate.CapitalsEnemyFaction then
                        nodes[125][37175488] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = ITEM_REQ_ALLIANCE}
                    end

                end

                if self.db.profile.showCapitalsBank then
                    nodes[125][43167962] = { dnID = BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[125][53601525] = { dnID = BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[125][46237826] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[125][41747539] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[125][50541677] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[125][55181939] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[126][32705586] = { dnID = BANK .. " / " .. GUILD_BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

            end

        --Transports Dalaran Northrend
            if self.db.profile.activate.CapitalsTransporting then
    
                if self.db.profile.showCapitalsPortals then
                    nodes[125][55814682] = { mnID = 127, name = "", type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " => " .. BINDING_NAME_PITCHDOWN  } -- LakeWintergrasp to Dalaran Portal 

                    if self.faction == "Horde" or db.activate.CapitalsEnemyFaction then
                        nodes[125][55322545] = { mnID = 1454, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. "\n" .. " => " .. DUNGEON_FLOOR_ORGRIMMAR0 } -- Dalaran to Orgrimmar Portal 
                    end

                    if self.faction == "Alliance" or db.activate.CapitalsEnemyFaction then
                        nodes[125][40796326] = { mnID = 1453,  name = "" , type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. "\n" .. " => " .. L["Stormwind"] } -- Dalaran to Stormwind City Portal
                    end
                end

                if self.db.profile.showCapitalsFP then
                    nodes[125][72224575] = { mnID = 125, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_NEUTRAL, type = "TravelL", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Dalaran
                end

            end

        --Professions Dalaran Northrend
            if self.db.profile.activate.CapitalsProfessions then

                if self.db.profile.showCapitalsFirstAid then
                    nodes[125][36803720] = { name = PROFESSIONS_FIRST_AID, type = "FirstAid", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsAlchemy then
                    nodes[125][42633205] = { name = L["Alchemy"], type = "Alchemy", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end
            
                if self.db.profile.showCapitalsLeatherworking then
                    nodes[125][34652896] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    nodes[125][33842922] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsEngineer then
                    nodes[125][39652486] = { name = L["Engineer"], type = "Engineer", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsSkinning then
                    nodes[125][34832786] = { name = L["Skinning"], type = "Skinning", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsTailoring then
                    nodes[125][36133357] = { name = L["Tailoring"], type = "Tailoring", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsJewelcrafting then
                    nodes[125][40693536] = { name = L["Jewelcrafting"], type = "Jewelcrafting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsBlacksmith then
                    nodes[125][45162895] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsMining then
                    nodes[125][41462566] = { name = L["Mining"], type = "Mining", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsFishing then
                    nodes[125][53066493] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsHerbalism then
                    nodes[125][42933408] = { name = L["Herbalism"], type = "Herbalism", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsInscription then
                    nodes[125][41593717] = { name = INSCRIPTION, type = "Inscription", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsEnchanting then
                    nodes[125][39043981] = { name = L["Enchanting"], type = "Enchanting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsArchaeology then
                    nodes[125][48363820] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.faction == "Horde" or db.activate.CapitalsEnemyFaction then

                    if self.db.profile.showCapitalsCooking then
                        nodes[125][69943898] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION .. "\n" .. ITEM_REQ_HORDE }
                    end

                end

                if self.faction == "Alliance" or db.activate.CapitalsEnemyFaction then

                    if self.db.profile.showCapitalsCooking then
                        nodes[125][40486581] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION .. "\n" .. ITEM_REQ_ALLIANCE }
                    end

                end

            end

        end

    end

end
end