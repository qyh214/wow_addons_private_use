local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

function ns.LoadClassicCapitalsLocationinfo(self)
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

                    if self.db.profile.showCapitalsAlchemy then
                        nodes[1454][55823288] = { name = L["Alchemy"], type = "Alchemy", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                
                    if self.db.profile.showCapitalsLeatherworking then
                        nodes[1454][63264447] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsEngineer then
                        nodes[1454][75922421] = { name = L["Engineer"], type = "Engineer", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsSkinning then
                        nodes[1454][63484577] = { name = L["Skinning"], type = "Skinning", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsTailoring then
                        nodes[1454][62924927] = { name = L["Tailoring"], type = "Tailoring", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsBlacksmith then
                        nodes[1454][80762367] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        --nodes[1454][81661943] = { name = L["Blacksmithing"] , type = "Blacksmith", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION .. " " .. AUCTION_CATEGORY_WEAPONS}
                    end

                    if self.db.profile.showCapitalsMining then
                        nodes[1454][73112611] = { name = L["Mining"], type = "Mining", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsFishing then
                        nodes[1454][69812918] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsCooking then
                        nodes[1454][57395397] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsHerbalism then
                        nodes[1454][55663939] = { name = L["Herbalism"], type = "Herbalism", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsEnchanting then
                        nodes[1454][53493856] = { name = L["Enchanting"], type = "Enchanting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsFirstAid then
                        nodes[1454][34188458] = { name = PROFESSIONS_FIRST_AID, type = "FirstAid", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                end

            --Transports Orgrimmar
                if self.db.profile.activate.CapitalsTransporting then

                    if self.db.profile.showCapitalsFP then
                        nodes[1454][45036396] = { mnID = 1454, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Orgrimmar
                    end
    
                end
    
            --Instances Orgrimmar
                if self.db.profile.activate.CapitalsInstances then
    
                    if self.db.profile.showCapitalsInstancePassage then
                        nodes[1454][56294119] = { mnID = 1454, name = DUNGEON_FLOOR_RAGEFIRE1 .. " " .. "[" .. LEVEL .. ": " .. "13-18]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "8", type = "PassageDungeon", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1454][39775294] = { mnID = 1454, name = DUNGEON_FLOOR_RAGEFIRE1 .. " " .. "[" .. LEVEL .. ": " .. "13-18]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "8", type = "PassageDungeon", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                end

            --General Orgrimmar
                if self.db.profile.activate.CapitalsGeneral then
    
                    if self.db.profile.showCapitalsPaths then
                        nodes[1454][49529373] = { dnID = L["Exit"], name = "", mnID = 1411, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit 
                        nodes[1454][15456189] = { dnID = L["Exit"], name = "", mnID = 1413, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit 
                    end

                    if self.db.profile.showCapitalsInnkeeper then
                        nodes[1454][54096841] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsAuctioneer then
                        nodes[1454][54486403] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsBank then
                        nodes[1454][49506897] = { dnID = BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsMailbox then
                        nodes[1454][50707037] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1454][62504020] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsWeaponMasters then
                        nodes[1454][81601940] = { dnID = L["Weapon Master"] .. "\n" .. "\n" .. "• " .. L["Bows"] .. "\n" .. "• " .. L["Daggers"] .. "\n" .. "• " .. L["One-Handed Axes"] .. "\n" .. "• " .. L["Fist Weapons"] .. "\n" .. "• " .. L["Thrown"] .. "\n" .. "• " .. L["Two-Handed Axes"] .. "\n" .. "• " .. L["Staves"], name = "", type = "PvPVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                end

            --ClassTrainers Orgrimmar
                if self.db.profile.activate.CapitalsClasses then

                    if self.db.profile.showCapitalsClassHunter then
                        nodes[1454][66601480] = { dnID = L["Hunter"] .. " " .. PET_TYPE_PET .. " " .. TALENT_TRAINER, name = "", type = "Hunter", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1454][67071863] = { dnID = L["Hunter"] .. " " .. TALENT_TRAINER, name = "", type = "Hunter", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsClassMage then
                        nodes[1454][38608580] = { dnID = L["Mage"] .. " " .. L["Portal"] .. " " .. TUTORIAL_TITLE14 .. "\n" .. L["Mage"] .. " " .. TALENT_TRAINER, name = "", type = "Mage", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsClassPriest then
                        nodes[1454][35608760] = { dnID = L["Priest"] .. " " .. TALENT_TRAINER, name = "", type = "Priest", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsClassRogue then
                        nodes[1454][43485290] = { dnID = L["Rogue"] .. " " .. TALENT_TRAINER, name = "", type = "Rogue", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsClassShaman then
                        nodes[1454][37733617] = { dnID = L["Shaman"] .. " " .. TALENT_TRAINER, name = "", type = "Shaman", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsClassWarlock then
                        nodes[1454][48184663] = { dnID = L["Warlock"] .. " " .. TALENT_TRAINER, name = "", type = "Warlock", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsClassWarrior then
                        nodes[1454][79603160] = { dnID = L["Warrior"] .. " " .. TALENT_TRAINER, name = "", type = "Warrior", showInZone = true, showOnContinent = false, showOnMinimap = false }
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

                    if self.db.profile.showCapitalsAlchemy then
                        nodes[1456][46903370] = { name = L["Alchemy"], type = "Alchemy", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                
                    if self.db.profile.showCapitalsLeatherworking then
                        nodes[1456][42064288] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsSkinning then
                        nodes[1456][44454317] = { name = L["Skinning"], type = "Skinning", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsTailoring then
                        nodes[1456][44144498] = { name = L["Tailoring"], type = "Tailoring", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsBlacksmith then
                        nodes[1456][39415501] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsMining then
                        nodes[1456][34415790] = { name = L["Mining"], type = "Mining", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsFishing then
                        nodes[1456][56144642] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsCooking then
                        nodes[1456][50785303] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsHerbalism then
                        nodes[1456][49944027] = { name = L["Herbalism"], type = "Herbalism", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsEnchanting then
                        nodes[1456][44993816] = { name = L["Enchanting"], type = "Enchanting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsFirstAid then
                        nodes[1456][29602160] = { name = PROFESSIONS_FIRST_AID, type = "FirstAid", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                end

            --Transports Thunder Bluff
                if self.db.profile.activate.CapitalsTransporting then
  
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

                    if self.db.profile.showCapitalsGhost then
                        nodes[1456][56621900] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Thunder Bluff
                    end

                    if self.db.profile.showCapitalsMailbox then
                        nodes[1456][45505980] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsWeaponMasters then
                        nodes[1456][41006220] = { dnID = L["Weapon Master"] .. "\n" .. "\n" .. "• " .. L["One-Handed Maces"] .. "\n" .. "• " .. L["Guns"] .. "\n" .. "• " .. L["Staves"] .. "\n" .. "• " .. L["Two-Handed Maces"], name = "", type = "PvPVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                end

            --ClassTrainers Thunder Bluff
                if self.db.profile.activate.CapitalsClasses then

                    if self.db.profile.showCapitalsClassDruid then
                        nodes[1456][76962833] = { dnID = L["Druid"] .. " " .. TALENT_TRAINER, name = "", type = "Druid", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsClassHunter then
                        nodes[1456][58178706] = { dnID = L["Hunter"] .. " " .. TALENT_TRAINER, name = "", type = "Hunter", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsClassMage then
                        nodes[1456][22421684] = { dnID = L["Mage"] .. " " .. L["Portal"] .. " " .. TUTORIAL_TITLE14, name = "", type = "Mage", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1456][25731418] = { dnID = L["Mage"] .. " " .. TALENT_TRAINER, name = "", type = "Mage", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1456][30243002] = { dnID = L["Entrance"] .. " " .. L["Mage"] .. " " .. TALENT_TRAINER, name = "", type = "Mage", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsClassPriest then
                        nodes[1456][25601560] = { dnID = L["Priest"] .. " " .. TALENT_TRAINER, name = "", type = "Priest", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1456][30243002] = { dnID = L["Entrance"] .. " " .. L["Priest"] .. " " .. TALENT_TRAINER, name = "", type = "Priest", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsClassShaman then
                        nodes[1456][22621953] = { dnID = L["Shaman"] .. " " .. TALENT_TRAINER, name = "", type = "Shaman", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsClassWarrior then
                        nodes[1456][58178706] = { dnID = L["Warrior"] .. " " .. TALENT_TRAINER, name = "", type = "Warrior", showInZone = true, showOnContinent = false, showOnMinimap = false }
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

                    if self.db.profile.showCapitalsAlchemy then
                        nodes[1458][46577410] = { name = L["Alchemy"], type = "Alchemy", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
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

                    if self.db.profile.showCapitalsHerbalism then
                        nodes[1458][54014961] = { name = L["Herbalism"], type = "Herbalism", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsEnchanting then
                        nodes[1458][61866139] = { name = L["Enchanting"], type = "Enchanting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsFirstAid then
                        nodes[1458][73605560] = { name = PROFESSIONS_FIRST_AID, type = "FirstAid", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                end

            --Transports Undercity
                if self.db.profile.activate.CapitalsTransporting then

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
                        nodes[1458][66014406] = { dnID = BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsGhost then
                        nodes[1458][67851396] = { name = SPIRIT_HEALER_RELEASE_RED .. "\n" .. DUNGEON_FLOOR_GILNEAS3, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Undercity
                    end

                    if self.db.profile.showCapitalsMailbox then
                        nodes[1458][67903850] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsWeaponMasters then
                        nodes[1458][57803160] = { dnID = L["Weapon Master"] .. "\n" .. "\n" .. "• " .. L["Crossbows"] .. "\n" .. "• " .. L["Daggers"] .. "\n" .. "• " .. L["One-Handed Swords"] .. "\n" .. "• " .. L["Polearms"] .. "\n" .. "• " .. L["Two-Handed Swords"], name = "", type = "PvPVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                end

            --ClassTrainers Undercity
                if self.db.profile.activate.CapitalsClasses then

                    if self.db.profile.showCapitalsClassMage then
                        nodes[1458][84201557] = { dnID = L["Mage"] .. " " .. L["Portal"] .. " " .. TUTORIAL_TITLE14, name = "", type = "Mage", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1458][85111005] = { dnID = L["Mage"] .. " " .. TALENT_TRAINER, name = "", type = "Mage", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1458][86081427] = { dnID = L["Mage"] .. " " .. TALENT_TRAINER, name = "", type = "Mage", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsClassPriest then
                        nodes[1458][49151857] = { dnID = L["Priest"] .. " " .. TALENT_TRAINER, name = "", type = "Priest", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsClassRogue then
                        nodes[1458][84527248] = { dnID = L["Rogue"] .. " " .. TALENT_TRAINER, name = "", type = "Rogue", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsClassWarlock then
                        nodes[1458][88921582] = { dnID = L["Warlock"] .. " " .. TALENT_TRAINER, name = "", type = "Warlock", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1458][86081427] = { dnID = L["Warlock"] .. " " .. TALENT_TRAINER, name = "", type = "Warlock", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsClassWarrior then
                        nodes[1458][47391591] = { dnID = L["Warrior"] .. " " .. TALENT_TRAINER, name = "", type = "Warrior", showInZone = true, showOnContinent = false, showOnMinimap = false }
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
                        nodes[1453][40255517] = { mnID = 1453, name = DUNGEON_FLOOR_THESTOCKADE1 .. " " .. "[" .. LEVEL .. ": " .. "22-30]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "15", type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                end

            --Transports Stormwind
                if self.db.profile.activate.CapitalsTransporting then

                    if self.db.profile.showCapitalsTransport then
                        nodes[1453][60941195] = { mnID = 1455, name = "", type = "Carriage", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Stormwind"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. DUNGEON_FLOOR_DEEPRUNTRAM1 .. "\n" .. " => " .. L["Ironforge"] } -- Transport to Ironforge Carriage 
                    end

                    if self.db.profile.showCapitalsFP then
                        nodes[1453][66346197] = { mnID = 1453, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Stormwind
                    end

                end

            --Professions Stormwind
                if self.db.profile.activate.CapitalsProfessions then

                    if self.db.profile.showCapitalsAlchemy then
                        nodes[1453][46227904] = { name = L["Alchemy"], type = "Alchemy", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                
                    if self.db.profile.showCapitalsLeatherworking then
                        nodes[1453][67644985] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsEngineer then
                        nodes[1453][54590800] = { name = L["Engineer"], type = "Engineer", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsSkinning then
                        nodes[1453][67614846] = { name = L["Skinning"], type = "Skinning", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsTailoring then
                        nodes[1453][43697374] = { name = L["Tailoring"], type = "Tailoring", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsBlacksmith then
                        nodes[1453][57115766] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION .. " " .. AUCTION_CATEGORY_WEAPONS }
                        nodes[1453][57441629] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsMining then
                        nodes[1453][51111733] = { name = L["Mining"], type = "Mining", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsFishing then
                        nodes[1453][45675841] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsCooking then
                        nodes[1453][75583708] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsHerbalism then
                        nodes[1453][15004964] = { name = L["Herbalism"], type = "Herbalism", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsEnchanting then
                        nodes[1453][43116374] = { name = L["Enchanting"], type = "Enchanting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsFirstAid then
                        nodes[1453][42802660] = { name = PROFESSIONS_FIRST_AID, type = "FirstAid", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                end

            --General Stormwind
                if self.db.profile.activate.CapitalsGeneral then
    
                    if self.db.profile.showCapitalsPaths then
                        nodes[1453][73399051] = { dnID = L["Exit"], name = "", mnID = 1429, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit 
                    end

                    if self.db.profile.showCapitalsInnkeeper then
                        nodes[1453][52626566] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsAuctioneer then
                        nodes[1453][54115902] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsBank then
                        nodes[1453][56377117] = { dnID = BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsMailbox then
                        nodes[1453][22205760] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1453][40008420] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1453][54506650] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1453][71004050] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsWeaponMasters then
                        nodes[1453][57005760] = { dnID = L["Weapon Master"] .. "\n" .. "\n" .. "• " .. L["Crossbows"] .. "\n" .. "• " .. L["Daggers"] .. "\n" .. "• " .. L["One-Handed Swords"] .. "\n" .. "• " .. L["Staves"] .. "\n" .. "• " .. L["Polearms"] .. "\n" .. "• " .. L["Two-Handed Swords"], name = "", type = "PvPVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                end

            --ClassTrainers Stormwind
                if self.db.profile.activate.CapitalsClasses then

                    if self.db.profile.showCapitalsClassDruid then
                        nodes[1453][19805280] = { dnID = L["Druid"] .. " " .. TALENT_TRAINER, name = "", type = "Druid", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1453][21005560] = { dnID = L["Druid"] .. " " .. TALENT_TRAINER, name = "", type = "Druid", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1453][21605140] = { dnID = L["Druid"] .. " " .. TALENT_TRAINER, name = "", type = "Druid", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsClassHunter then
                        nodes[1453][61771539] = { dnID = L["Hunter"] .. " " .. PET_TYPE_PET .. " " .. TALENT_TRAINER .. "\n" .. L["Hunter"] .. " " .. TALENT_TRAINER, name = "", type = "Hunter", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsClassMage then
                        nodes[1453][38178075] = { dnID = L["Mage"] .. " " .. L["Portal"] .. " " .. TUTORIAL_TITLE14 .. "\n" .. L["Mage"] .. " " .. TALENT_TRAINER, name = "", type = "Mage", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsClassPaladin then
                        nodes[1453][37703260] = { dnID = L["Paladin"] .. " " .. L["Portal"] .. " " .. TUTORIAL_TITLE14, name = "", type = "Paladin", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsClassPriest then
                        nodes[1453][20685009] = { dnID = L["Priest"] .. " " .. TALENT_TRAINER, name = "", type = "Priest", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1453][38712647] = { dnID = L["Priest"] .. " " .. TALENT_TRAINER, name = "", type = "Priest", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsClassRogue then
                        nodes[1453][74605277] = { dnID = L["Rogue"] .. " " .. TALENT_TRAINER, name = "", type = "Rogue", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1453][78325708] = { dnID = L["Rogue"] .. " " .. TALENT_TRAINER, name = "", type = "Rogue", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsClassWarlock then
                        nodes[1453][27487634] = { dnID = L["Passage"] .. " " .. L["Warlock"] .. " " .. TALENT_TRAINER, name = "", type = "Warlock", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsClassWarrior then
                        nodes[1453][78404661] = { dnID = L["Warrior"] .. " " .. TALENT_TRAINER .. "\n" .. "(" .. DUNGEON_FLOOR_GILNEAS3 .. ")", name = "", type = "Warrior", showInZone = true, showOnContinent = false, showOnMinimap = false }
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

                    if self.db.profile.showCapitalsFP then
                        nodes[1455][55384778] = { mnID = 1455, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ironfrge
                    end

                end

            --Professions ironforge
                if self.db.profile.activate.CapitalsProfessions then

                    if self.db.profile.showCapitalsAlchemy then
                        nodes[1455][66615566] = { name = L["Alchemy"], type = "Alchemy", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                
                    if self.db.profile.showCapitalsLeatherworking then
                        nodes[1455][38843282] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsEngineer then
                        nodes[1455][68444359] = { name = L["Engineer"], type = "Engineer", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsSkinning then
                        nodes[1455][40243214] = { name = L["Skinning"], type = "Skinning", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsTailoring then
                        nodes[1455][43792787] = { name = L["Tailoring"], type = "Tailoring", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsBlacksmith then
                        nodes[1455][52144211] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsMining then
                        nodes[1455][50142649] = { name = L["Mining"], type = "Mining", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsFishing then
                        nodes[1455][48090763] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION .. "\n" .. DUNGEON_FLOOR_GILNEAS2 }
                    end

                    if self.db.profile.showCapitalsCooking then
                        nodes[1455][60073646] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsHerbalism then
                        nodes[1455][55865907] = { name = L["Herbalism"], type = "Herbalism", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsEnchanting then
                        nodes[1455][60114533] = { name = L["Enchanting"], type = "Enchanting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsFirstAid then
                        nodes[1455][57805860] = { name = PROFESSIONS_FIRST_AID, type = "FirstAid", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
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
                        nodes[1455][35486068] = { dnID = BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsMailbox then
                        nodes[1455][21505270] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1455][33506550] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1455][71207140] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1455][72504960] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsWeaponMasters then
                        nodes[1455][61608920] = { dnID = L["Weapon Master"] .. "\n" .. "\n" .. "• " .. L["One-Handed Maces"] .. "\n" .. "• " .. L["One-Handed Axes"] .. "\n" .. "• " .. L["Fist Weapons"] .. "\n" .. "• " .. L["Guns"] .. "\n" .. "• " .. L["Two-Handed Maces"] .. "\n" .. "• " .. L["Two-Handed Axes"] .. "\n" .. "• " .. L["Crossbows"] .. "\n" .. "• " .. L["Daggers"] .. "\n" .. "• " .. L["Thrown"], name = "", type = "PvPVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                end

            --ClassTrainers Ironforge
                if self.db.profile.activate.CapitalsClasses then

                    if self.db.profile.showCapitalsClassHunter then
                        nodes[1455][70558432] = { dnID = L["Hunter"] .. " " .. PET_TYPE_PET .. " " .. TALENT_TRAINER .. "\n" .. L["Hunter"] .. " " .. TALENT_TRAINER, name = "", type = "Hunter", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsClassMage then
                        nodes[1455][26360773] = { dnID = L["Mage"] .. " " .. L["Portal"] .. " " .. TUTORIAL_TITLE14 .. "\n" .. L["Mage"] .. " " .. TALENT_TRAINER, name = "", type = "Mage", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsClassPaladin then
                        nodes[1455][23890551] = { dnID = L["Paladin"] .. " " .. TALENT_TRAINER, name = "", type = "Paladin", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsClassPriest then
                        nodes[1455][24830983] = { dnID = L["Priest"] .. " " .. TALENT_TRAINER, name = "", type = "Priest", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsClassRogue then
                        nodes[1455][51951533] = { dnID = L["Rogue"] .. " " .. TALENT_TRAINER, name = "", type = "Rogue", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsClassWarlock then
                        nodes[1455][50480666] = { dnID = L["Warlock"] .. " " .. TALENT_TRAINER, name = "", type = "Warlock", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsClassWarrior then
                        nodes[1455][66668907] = { dnID = L["Warrior"] .. " " .. TALENT_TRAINER, name = "", type = "Warrior", showInZone = true, showOnContinent = false, showOnMinimap = false }
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
                    nodes[1457][29244009] = { mnID = 1438, name = "", type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " => " .. L["Rut'theran"] } -- Portal To Darnassus from Teldrassil
                end

            end

        --################################
        --### Alliance or EnemyFaction ###
        --################################
            if self.faction == "Alliance" or db.activate.CapitalsEnemyFaction then

            --General Darnassus
                if self.db.profile.activate.CapitalsGeneral then
    
                    if self.db.profile.showCapitalsPaths then
                        nodes[1457][88723511] = { dnID = L["Exit"], name = "", mnID = 1438, type = "PathR", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit Exodar
                    end

                    if self.db.profile.showCapitalsInnkeeper then
                        nodes[1457][67451565] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsAuctioneer then
                        nodes[1457][56255287] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsBank then
                        nodes[1457][44285140] = { dnID = BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsBank then
                        nodes[1457][39964227] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Darnassus
                    end

                    if self.db.profile.showCapitalsMailbox then
                        nodes[1457][41904140] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsWeaponMasters then
                        nodes[1457][57604660] = { dnID = L["Weapon Master"] .. "\n" .. "\n" .. "• " .. L["Bows"] .. "\n" .. "• " .. L["Daggers"] .. "\n" .. "• " .. L["Fist Weapons"] .. "\n" .. "• " .. L["Staves"] .. "\n" .. "• " .. L["Thrown"], name = "", type = "PvPVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                end

            --Transports Darnassus
                if self.db.profile.activate.CapitalsTransporting then

                    if self.db.profile.showCapitalsGhost then
                        nodes[1457][77662585] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Darnassus
                    end

                end

            --Professions Darnassus
                if self.db.profile.activate.CapitalsProfessions then

                    if self.db.profile.showCapitalsAlchemy then
                        nodes[1457][55342267] = { name = L["Alchemy"], type = "Alchemy", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                
                    if self.db.profile.showCapitalsLeatherworking then
                        nodes[1457][64442076] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsSkinning then
                        nodes[1457][64072248] = { name = L["Skinning"], type = "Skinning", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsTailoring then
                        nodes[1457][63532124] = { name = L["Tailoring"], type = "Tailoring", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsFishing then
                        nodes[1457][47905667] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsCooking then
                        nodes[1457][49042124] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsHerbalism then
                        nodes[1457][48006820] = { name = L["Herbalism"], type = "Herbalism", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsEnchanting then
                        nodes[1457][58801277] = { name = L["Enchanting"], type = "Enchanting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsFirstAid then
                        nodes[1457][51601360] = { name = PROFESSIONS_FIRST_AID, type = "FirstAid", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                end

            --ClassTrainers Darnassus
                if self.db.profile.activate.CapitalsClasses then

                    if self.db.profile.showCapitalsClassDruid then
                        nodes[1457][34260862] = { dnID = L["Druid"] .. " " .. TALENT_TRAINER, name = "", type = "Druid", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsClassHunter then
                        nodes[1457][42390804] = { dnID = L["Hunter"] .. " " .. PET_TYPE_PET .. " " .. TALENT_TRAINER .. "\n" .. L["Hunter"] .. " " .. TALENT_TRAINER, name = "", type = "Hunter", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1457][40370855] = { dnID = L["Hunter"] .. " " .. TALENT_TRAINER, name = "", type = "Hunter", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsClassMage then
                        nodes[1457][40608210] = { dnID = L["Mage"] .. " " .. L["Portal"] .. " " .. TUTORIAL_TITLE14, name = "", type = "Mage", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsClassPriest then
                        nodes[1457][37928271] = { dnID = L["Priest"] .. " " .. TALENT_TRAINER, name = "", type = "Priest", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsClassRogue then
                        nodes[1457][32411635] = { dnID = L["Entrance"] .. " " .. L["Rogue"] .. " " .. TALENT_TRAINER, name = "", type = "Rogue", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsClassWarrior then
                        nodes[1457][58613511] = { dnID = L["Warrior"] .. " " .. TALENT_TRAINER, name = "", type = "Warrior", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end
                    
                end

            end

        end

    --###############################################################################################
    --################################         Neutral Cities       #################################
    --###############################################################################################

    end

end
end