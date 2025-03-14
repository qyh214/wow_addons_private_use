local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

function ns.LoadClassicMinimapCapitalsLocationinfo(self)
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

                    if self.db.profile.showMinimapCapitalsAlchemy then
                        minimap[1454][55823288] = { name = L["Alchemy"], type = "Alchemy", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                
                    if self.db.profile.showMinimapCapitalsLeatherworking then
                        minimap[1454][63264447] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsEngineer then
                        minimap[1454][75922421] = { name = L["Engineer"], type = "Engineer", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsSkinning then
                        minimap[1454][63484577] = { name = L["Skinning"], type = "Skinning", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsTailoring then
                        minimap[1454][62924927] = { name = L["Tailoring"], type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsBlacksmith then
                        minimap[1454][80762367] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        --minimap[1454][81661943] = { name = L["Blacksmithing"] , type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION .. " " .. AUCTION_CATEGORY_WEAPONS}
                    end

                    if self.db.profile.showMinimapCapitalsMining then
                        minimap[1454][73112611] = { name = L["Mining"], type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsFishing then
                        minimap[1454][69812918] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsCooking then
                        minimap[1454][57395397] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsHerbalism then
                        minimap[1454][55663939] = { name = L["Herbalism"], type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsEnchanting then
                        minimap[1454][53493856] = { name = L["Enchanting"], type = "Enchanting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsFirstAid then
                        minimap[1454][34188458] = { name = PROFESSIONS_FIRST_AID, type = "FirstAid", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                end

            --Transports Orgrimmar
                if self.db.profile.activate.MinimapCapitalsTransporting then

                    if self.db.profile.showMinimapCapitalsFP then
                        minimap[1454][45036396] = { mnID = 1454, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Orgrimmar
                    end
    
                end
    
            --Instances Orgrimmar
                if self.db.profile.activate.MinimapCapitalsInstances then
    
                    if self.db.profile.showMinimapCapitalsInstancePassage then
                        minimap[1454][56294119] = { mnID = 1454, name = DUNGEON_FLOOR_RAGEFIRE1 .. " " .. "[" .. LEVEL .. ": " .. "13-18]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "8", type = "PassageDungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1454][39775294] = { mnID = 1454, name = DUNGEON_FLOOR_RAGEFIRE1 .. " " .. "[" .. LEVEL .. ": " .. "13-18]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "8", type = "PassageDungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end

            --General Orgrimmar
                if self.db.profile.activate.MinimapCapitalsGeneral then
    
                    if self.db.profile.showMinimapCapitalsPaths then
                        minimap[1454][49529373] = { dnID = L["Exit"], name = "", mnID = 1411, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                        minimap[1454][15456189] = { dnID = L["Exit"], name = "", mnID = 1413, type = "PathLU", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                    end

                    if self.db.profile.showMinimapCapitalsInnkeeper then
                        minimap[1454][54096841] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsAuctioneer then
                        minimap[1454][54486403] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsBank then
                        minimap[1454][49506897] = { dnID = BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsMailbox then
                        minimap[1454][50707037] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1454][62504020] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsWeaponMasters then
                        minimap[1454][81601940] = { dnID = L["Weapon Master"] .. "\n" .. "\n" .. "• " .. L["Bows"] .. "\n" .. "• " .. L["Daggers"] .. "\n" .. "• " .. L["One-Handed Axes"] .. "\n" .. "• " .. L["Fist Weapons"] .. "\n" .. "• " .. L["Thrown"] .. "\n" .. "• " .. L["Two-Handed Axes"] .. "\n" .. "• " .. L["Staves"], name = "", type = "PvPVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end

            --ClassTrainers Orgrimmar
                if self.db.profile.activate.MinimapCapitalsClasses then

                    if self.db.profile.showMinimapCapitalsClassHunter then
                        minimap[1454][66601480] = { dnID = L["Hunter"] .. " " .. PET_TYPE_PET .. " " .. TALENT_TRAINER, name = "", type = "Hunter", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1454][67071863] = { dnID = L["Hunter"] .. " " .. TALENT_TRAINER, name = "", type = "Hunter", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsClassMage then
                        minimap[1454][38608580] = { dnID = L["Mage"] .. " " .. L["Portal"] .. " " .. TUTORIAL_TITLE14 .. "\n" .. L["Mage"] .. " " .. TALENT_TRAINER, name = "", type = "Mage", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsClassPriest then
                        minimap[1454][35608760] = { dnID = L["Priest"] .. " " .. TALENT_TRAINER, name = "", type = "Priest", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsClassRogue then
                        minimap[1454][43485290] = { dnID = L["Rogue"] .. " " .. TALENT_TRAINER, name = "", type = "Rogue", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsClassShaman then
                        minimap[1454][37733617] = { dnID = L["Shaman"] .. " " .. TALENT_TRAINER, name = "", type = "Shaman", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsClassWarlock then
                        minimap[1454][48184663] = { dnID = L["Warlock"] .. " " .. TALENT_TRAINER, name = "", type = "Warlock", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsClassWarrior then
                        minimap[1454][79603160] = { dnID = L["Warrior"] .. " " .. TALENT_TRAINER, name = "", type = "Warrior", showInZone = false, showOnContinent = false, showOnMinimap = true }
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

                    if self.db.profile.showMinimapCapitalsAlchemy then
                        minimap[1456][46903370] = { name = L["Alchemy"], type = "Alchemy", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                
                    if self.db.profile.showMinimapCapitalsLeatherworking then
                        minimap[1456][42064288] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsSkinning then
                        minimap[1456][44454317] = { name = L["Skinning"], type = "Skinning", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsTailoring then
                        minimap[1456][44144498] = { name = L["Tailoring"], type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsBlacksmith then
                        minimap[1456][39415501] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsMining then
                        minimap[1456][34415790] = { name = L["Mining"], type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsFishing then
                        minimap[1456][56144642] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsCooking then
                        minimap[1456][50785303] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsHerbalism then
                        minimap[1456][49944027] = { name = L["Herbalism"], type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsEnchanting then
                        minimap[1456][44993816] = { name = L["Enchanting"], type = "Enchanting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsFirstAid then
                        minimap[1456][29602160] = { name = PROFESSIONS_FIRST_AID, type = "FirstAid", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                end

            --Transports Thunder Bluff
                if self.db.profile.activate.MinimapCapitalsTransporting then

                    if self.db.profile.showMinimapCapitalsFP then
                        minimap[1456][46974977] = { mnID = 1456, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Thunder Bluff
                    end

                end

            --General Thunder Bluff
            if self.db.profile.activate.MinimapCapitalsGeneral then
    
                if self.db.profile.showMinimapCapitalsPaths then
                    minimap[1456][52232561] = { dnID = L["Exit"], name = "", mnID = 1412, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[1456][54632715] = { dnID = L["Exit"], name = "", mnID = 1412, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[1456][31886595] = { dnID = L["Exit"], name = "", mnID = 1412, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[1456][31456256] = { dnID = L["Exit"], name = "", mnID = 1412, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsInnkeeper then
                    minimap[1456][45856477] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper",  showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsAuctioneer then
                    minimap[1456][38875023] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer",  showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[1456][40435169] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer",  showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsBank then
                    minimap[1456][47175862] = { dnID = BANK, name = "", type = "Bank",  showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsGhost then
                    minimap[1456][56621900] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Thunder Bluff
                end

                if self.db.profile.showMinimapCapitalsMailbox then
                    minimap[1456][45505980] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsWeaponMasters then
                    minimap[1456][41006220] = { dnID = L["Weapon Master"] .. "\n" .. "\n" .. "• " .. L["One-Handed Maces"] .. "\n" .. "• " .. L["Guns"] .. "\n" .. "• " .. L["Staves"] .. "\n" .. "• " .. L["Two-Handed Maces"], name = "", type = "PvPVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

            end

            --ClassTrainers Thunder Bluff
                if self.db.profile.activate.MinimapCapitalsClasses then

                    if self.db.profile.showMinimapCapitalsClassDruid then
                        minimap[1456][76962833] = { dnID = L["Druid"] .. " " .. TALENT_TRAINER, name = "", type = "Druid", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsClassHunter then
                        minimap[1456][58178706] = { dnID = L["Hunter"] .. " " .. TALENT_TRAINER, name = "", type = "Hunter", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsClassMage then
                        minimap[1456][22421684] = { dnID = L["Mage"] .. " " .. L["Portal"] .. " " .. TUTORIAL_TITLE14, name = "", type = "Mage", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1456][25731418] = { dnID = L["Mage"] .. " " .. TALENT_TRAINER, name = "", type = "Mage", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1456][30243002] = { dnID = L["Entrance"] .. " " .. L["Mage"] .. " " .. TALENT_TRAINER, name = "", type = "Mage", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsClassPriest then
                        minimap[1456][25601560] = { dnID = L["Priest"] .. " " .. TALENT_TRAINER, name = "", type = "Priest", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1456][30243002] = { dnID = L["Entrance"] .. " " .. L["Priest"] .. " " .. TALENT_TRAINER, name = "", type = "Priest", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsClassShaman then
                        minimap[1456][22621953] = { dnID = L["Shaman"] .. " " .. TALENT_TRAINER, name = "", type = "Shaman", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsClassWarrior then
                        minimap[1456][58178706] = { dnID = L["Warrior"] .. " " .. TALENT_TRAINER, name = "", type = "Warrior", showInZone = false, showOnContinent = false, showOnMinimap = true }
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

                    if self.db.profile.showMinimapCapitalsAlchemy then
                        minimap[1458][46577410] = { name = L["Alchemy"], type = "Alchemy", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        minimap[1458][52947737] = { name = L["Passage"] .. " " .. MINIMAP_TRACKING_TRAINER_PROFESSION, type = "PassageLeftL", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName =  L["Alchemy"] }
                        minimap[1458][44626639] = { name = L["Passage"] .. " " .. MINIMAP_TRACKING_TRAINER_PROFESSION, type = "PassageLeftL", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName =  L["Alchemy"] }
                    end
                
                    if self.db.profile.showMinimapCapitalsLeatherworking then
                        minimap[1458][70155740] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsEngineer then
                        minimap[1458][76107409] = { name = L["Engineer"], type = "Engineer", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsSkinning then
                        minimap[1458][70165922] = { name = L["Skinning"], type = "Skinning", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsTailoring then
                        minimap[1458][70763072] = { name = L["Tailoring"], type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsBlacksmith then
                        minimap[1458][61313061] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsMining then
                        minimap[1458][56043744] = { name = L["Mining"], type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsFishing then
                        minimap[1458][80693124] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsCooking then
                        minimap[1458][62194489] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsHerbalism then
                        minimap[1458][54014961] = { name = L["Herbalism"], type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsEnchanting then
                        minimap[1458][61866139] = { name = L["Enchanting"], type = "Enchanting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsFirstAid then
                        minimap[1458][73605560] = { name = PROFESSIONS_FIRST_AID, type = "FirstAid", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                end

            --Transports Undercity
                if self.db.profile.activate.MinimapCapitalsTransporting then

                    if self.db.profile.showCapitalsFP then
                        minimap[1458][63164844] = { mnID = 1458, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_HORDE, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Undercity
                    end

                end

            --General Undercity
                if self.db.profile.activate.MinimapCapitalsGeneral then
    
                    if self.db.profile.showMinimapCapitalsPaths then
                        minimap[1458][15003101] = { dnID = L["Exit"], name = "", mnID = 1420, type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                        minimap[1458][46474406] = { dnID = L["Exit"], name = "", mnID = 1420, type = "PathL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                        minimap[1458][66110384] = { dnID = L["Exit"] .. " " .. DUNGEON_FLOOR_GILNEAS3, name = "", mnID = 1420, type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                        minimap[1458][65865202] = { dnID = DUNGEON_FLOOR_GILNEAS3 .. " => " .. DUNGEON_FLOOR_GILNEAS2 .. "\n" ..  DUNGEON_FLOOR_GILNEAS2 .. " => " .. DUNGEON_FLOOR_GILNEAS3, name = "", type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                        minimap[1458][60584399] = { dnID = DUNGEON_FLOOR_GILNEAS3 .. " => " .. DUNGEON_FLOOR_GILNEAS2 .. "\n" ..  DUNGEON_FLOOR_GILNEAS2 .. " => " .. DUNGEON_FLOOR_GILNEAS3, name = "", type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                        minimap[1458][71294410] = { dnID = DUNGEON_FLOOR_GILNEAS3 .. " => " .. DUNGEON_FLOOR_GILNEAS2 .. "\n" ..  DUNGEON_FLOOR_GILNEAS2 .. " => " .. DUNGEON_FLOOR_GILNEAS3, name = "", type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                    end

                    if self.db.profile.showMinimapCapitalsInnkeeper then
                        minimap[1458][67743784] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsAuctioneer then
                        minimap[1458][60534156] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1458][64363583] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1458][67663591] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1458][71494189] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1458][71394672] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1458][67545239] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1458][64415242] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1458][60494647] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsBank then
                        minimap[1458][66014406] = { dnID = BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsGhost then
                        minimap[1458][67851396] = { name = SPIRIT_HEALER_RELEASE_RED .. "\n" .. DUNGEON_FLOOR_GILNEAS3, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Undercity
                    end

                    if self.db.profile.showMinimapCapitalsMailbox then
                        minimap[1458][67903850] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsWeaponMasters then
                        minimap[1458][57803160] = { dnID = L["Weapon Master"] .. "\n" .. "\n" .. "• " .. L["Crossbows"] .. "\n" .. "• " .. L["Daggers"] .. "\n" .. "• " .. L["One-Handed Swords"] .. "\n" .. "• " .. L["Polearms"] .. "\n" .. "• " .. L["Two-Handed Swords"], name = "", type = "PvPVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end

            --ClassTrainers Undercity
                if self.db.profile.activate.MinimapCapitalsClasses then

                    if self.db.profile.showMinimapCapitalsClassMage then
                        minimap[1458][84201557] = { dnID = L["Mage"] .. " " .. L["Portal"] .. " " .. TUTORIAL_TITLE14, name = "", type = "Mage", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1458][85111005] = { dnID = L["Mage"] .. " " .. TALENT_TRAINER, name = "", type = "Mage", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1458][86081427] = { dnID = L["Mage"] .. " " .. TALENT_TRAINER, name = "", type = "Mage", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsClassPriest then
                        minimap[1458][49151857] = { dnID = L["Priest"] .. " " .. TALENT_TRAINER, name = "", type = "Priest", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsClassRogue then
                        minimap[1458][84527248] = { dnID = L["Rogue"] .. " " .. TALENT_TRAINER, name = "", type = "Rogue", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsClassWarlock then
                        minimap[1458][88921582] = { dnID = L["Warlock"] .. " " .. TALENT_TRAINER, name = "", type = "Warlock", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1458][86081427] = { dnID = L["Warlock"] .. " " .. TALENT_TRAINER, name = "", type = "Warlock", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsClassWarrior then
                        minimap[1458][47391591] = { dnID = L["Warrior"] .. " " .. TALENT_TRAINER, name = "", type = "Warrior", showInZone = false, showOnContinent = false, showOnMinimap = true }
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
                        minimap[1453][40255517] = { mnID = 1453, name = DUNGEON_FLOOR_THESTOCKADE1 .. " " .. "[" .. LEVEL .. ": " .. "22-30]", dnID = REQUIRES_LABEL .. " " .. MINIMUM .. " " .. LEVEL .. " " .. "15", type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end

            --Transports Stormwind
                if self.db.profile.activate.MinimapCapitalsTransporting then

                    if self.db.profile.showMinimapCapitalsTransport then
                        minimap[1453][60941195] = { mnID = 1455, name = "", type = "Carriage", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Stormwind"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. DUNGEON_FLOOR_DEEPRUNTRAM1 .. "\n" .. " => " .. L["Ironforge"] } -- Transport to Ironforge Carriage 
                    end

                    if self.db.profile.showMinimapCapitalsFP then
                        minimap[1453][66346197] = { mnID = 1453, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Stormwind
                    end

                end

            --Professions Stormwind
                if self.db.profile.activate.MinimapCapitalsProfessions then

                    if self.db.profile.showMinimapCapitalsAlchemy then
                        minimap[1453][46227904] = { name = L["Alchemy"], type = "Alchemy", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                
                    if self.db.profile.showMinimapCapitalsLeatherworking then
                        minimap[1453][67644985] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsEngineer then
                        minimap[1453][54590800] = { name = L["Engineer"], type = "Engineer", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsSkinning then
                        minimap[1453][67614846] = { name = L["Skinning"], type = "Skinning", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsTailoring then
                        minimap[1453][43697374] = { name = L["Tailoring"], type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsBlacksmith then
                        minimap[1453][57115766] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION .. " " .. AUCTION_CATEGORY_WEAPONS }
                        minimap[1453][57441629] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }  
                    end

                    if self.db.profile.showMinimapCapitalsMining then
                        minimap[1453][51111733] = { name = L["Mining"], type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsFishing then
                        minimap[1453][45675841] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsCooking then
                        minimap[1453][75583708] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsHerbalism then
                        minimap[1453][15004964] = { name = L["Herbalism"], type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsEnchanting then
                        minimap[1453][43116374] = { name = L["Enchanting"], type = "Enchanting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsFirstAid then
                        minimap[1453][42802660] = { name = PROFESSIONS_FIRST_AID, type = "FirstAid", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                end

            --General Stormwind
                if self.db.profile.activate.MinimapCapitalsGeneral then
    
                    if self.db.profile.showMinimapCapitalsPaths then
                        minimap[1453][73399051] = { dnID = L["Exit"], name = "", mnID = 1429, type = "PathRU", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                    end

                    if self.db.profile.showMinimapCapitalsInnkeeper then
                        minimap[1453][52626566] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsAuctioneer then
                        minimap[1453][54115902] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsBank then
                        minimap[1453][56377117] = { dnID = BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsMailbox then
                        minimap[1453][22205760] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1453][40008420] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1453][54506650] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1453][71004050] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsWeaponMasters then
                        minimap[1453][57005760] = { dnID = L["Weapon Master"] .. "\n" .. "\n" .. "• " .. L["Crossbows"] .. "\n" .. "• " .. L["Daggers"] .. "\n" .. "• " .. L["One-Handed Swords"] .. "\n" .. "• " .. L["Staves"] .. "\n" .. "• " .. L["Polearms"] .. "\n" .. "• " .. L["Two-Handed Swords"], name = "", type = "PvPVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end

            --ClassTrainers
                if self.db.profile.activate.MinimapCapitalsClasses then

                    if self.db.profile.showMinimapCapitalsClassDruid then
                        minimap[1453][19805280] = { dnID = L["Druid"] .. " " .. TALENT_TRAINER, name = "", type = "Druid", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1453][21005560] = { dnID = L["Druid"] .. " " .. TALENT_TRAINER, name = "", type = "Druid", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1453][21605140] = { dnID = L["Druid"] .. " " .. TALENT_TRAINER, name = "", type = "Druid", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsClassHunter then
                        minimap[1453][61771539] = { dnID = L["Hunter"] .. " " .. PET_TYPE_PET .. " " .. TALENT_TRAINER .. "\n" .. L["Hunter"] .. " " .. TALENT_TRAINER, name = "", type = "Hunter", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsClassMage then
                        minimap[1453][38178075] = { dnID = L["Mage"] .. " " .. L["Portal"] .. " " .. TUTORIAL_TITLE14 .. "\n" .. L["Mage"] .. " " .. TALENT_TRAINER, name = "", type = "Mage", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showCapitalsClassPaladin then
                        minimap[1453][37703260] = { dnID = L["Paladin"] .. " " .. L["Portal"] .. " " .. TUTORIAL_TITLE14, name = "", type = "Paladin", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsClassPriest then
                        minimap[1453][20685009] = { dnID = L["Priest"] .. " " .. TALENT_TRAINER, name = "", type = "Priest", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1453][38712647] = { dnID = L["Priest"] .. " " .. TALENT_TRAINER, name = "", type = "Priest", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsClassRogue then
                        minimap[1453][74605277] = { dnID = L["Rogue"] .. " " .. TALENT_TRAINER, name = "", type = "Rogue", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1453][78325708] = { dnID = L["Rogue"] .. " " .. TALENT_TRAINER, name = "", type = "Rogue", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsClassWarlock then
                        minimap[1453][27487634] = { dnID = L["Passage"] .. " " .. L["Warlock"] .. " " .. TALENT_TRAINER, name = "", type = "Warlock", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsClassWarrior then
                        minimap[1453][78404661] = { dnID = L["Warrior"] .. " " .. TALENT_TRAINER .. "\n" .. "(" .. DUNGEON_FLOOR_GILNEAS3 .. ")", name = "", type = "Warrior", showInZone = false, showOnContinent = false, showOnMinimap = true }
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
                        minimap[1455][73375055] = { mnID = 1455, name = "", type = "Carriage", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Ironforge"] .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. DUNGEON_FLOOR_DEEPRUNTRAM1 .. "\n" .. " => " .. L["Stormwind"] } -- Transport to Ironforge Carriage 
                    end

                    if self.db.profile.showMinimapCapitalsFP then
                        minimap[1455][55384778] = { mnID = 1455, name = MINIMAP_TRACKING_FLIGHTMASTER .. " - " .. FACTION_ALLIANCE, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ironfrge
                    end

                end

            --Professions ironforge
                if self.db.profile.activate.MinimapCapitalsProfessions then

                    if self.db.profile.showMinimapCapitalsAlchemy then
                        minimap[1455][66615566] = { name = L["Alchemy"], type = "Alchemy", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                
                    if self.db.profile.showMinimapCapitalsLeatherworking then
                        minimap[1455][38843282] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsEngineer then
                        minimap[1455][68444359] = { name = L["Engineer"], type = "Engineer", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsSkinning then
                        minimap[1455][40243214] = { name = L["Skinning"], type = "Skinning", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsTailoring then
                        minimap[1455][43792787] = { name = L["Tailoring"], type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsBlacksmith then
                        minimap[1455][52144211] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsMining then
                        minimap[1455][50142649] = { name = L["Mining"], type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsFishing then
                        minimap[1455][48090763] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION .. "\n" .. DUNGEON_FLOOR_GILNEAS2 }
                    end

                    if self.db.profile.showMinimapCapitalsCooking then
                        minimap[1455][60073646] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsHerbalism then
                        minimap[1455][55865907] = { name = L["Herbalism"], type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsEnchanting then
                        minimap[1455][60114533] = { name = L["Enchanting"], type = "Enchanting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsFirstAid then
                        minimap[1455][57805860] = { name = PROFESSIONS_FIRST_AID, type = "FirstAid", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                end

            --General Ironforge
                if self.db.profile.activate.MinimapCapitalsGeneral then
    
                    if self.db.profile.showMinimapCapitalsPaths then
                        minimap[1455][14218604] = { dnID = L["Exit"], name = "", mnID = 1426, type = "PathLU", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                    end

                    if self.db.profile.showMinimapCapitalsInnkeeper then
                        minimap[1455][18165147] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsAuctioneer then
                        minimap[1455][25517317] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsBank then
                        minimap[1455][35486068] = { dnID = BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsMailbox then
                        minimap[1455][21505270] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1455][33506550] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1455][71207140] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1455][72504960] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsWeaponMasters then
                        minimap[1455][61608920] = { dnID = L["Weapon Master"] .. "\n" .. "\n" .. "• " .. L["One-Handed Maces"] .. "\n" .. "• " .. L["One-Handed Axes"] .. "\n" .. "• " .. L["Fist Weapons"] .. "\n" .. "• " .. L["Guns"] .. "\n" .. "• " .. L["Two-Handed Maces"] .. "\n" .. "• " .. L["Two-Handed Axes"] .. "\n" .. "• " .. L["Crossbows"] .. "\n" .. "• " .. L["Daggers"] .. "\n" .. "• " .. L["Thrown"], name = "", type = "PvPVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end

            --ClassTrainers Ironforge
                if self.db.profile.activate.MinimapCapitalsClasses then

                    if self.db.profile.showMinimapCapitalsClassHunter then
                        minimap[1455][70558432] = { dnID = L["Hunter"] .. " " .. PET_TYPE_PET .. " " .. TALENT_TRAINER .. "\n" .. L["Hunter"] .. " " .. TALENT_TRAINER, name = "", type = "Hunter", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsClassMage then
                        minimap[1455][26360773] = { dnID = L["Mage"] .. " " .. L["Portal"] .. " " .. TUTORIAL_TITLE14 .. "\n" .. L["Mage"] .. " " .. TALENT_TRAINER, name = "", type = "Mage", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showCapitalsClassPaladin then
                        minimap[1455][23890551] = { dnID = L["Paladin"] .. " " .. TALENT_TRAINER, name = "", type = "Paladin", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsClassPriest then
                        minimap[1455][24830983] = { dnID = L["Priest"] .. " " .. TALENT_TRAINER, name = "", type = "Priest", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsClassRogue then
                        minimap[1455][51951533] = { dnID = L["Rogue"] .. " " .. TALENT_TRAINER, name = "", type = "Rogue", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsClassWarlock then
                        minimap[1455][50480666] = { dnID = L["Warlock"] .. " " .. TALENT_TRAINER, name = "", type = "Warlock", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsClassWarrior then
                        minimap[1455][66668907] = { dnID = L["Warrior"] .. " " .. TALENT_TRAINER, name = "", type = "Warrior", showInZone = false, showOnContinent = false, showOnMinimap = true }
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
                    minimap[1457][29244009] = { mnID = 1438, name = "", type = "Portal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " => " .. L["Rut'theran"] } -- Portal To Darnassus from Teldrassil
                end

            end

        --################################
        --### Alliance or EnemyFaction ###
        --################################
            if self.faction == "Alliance" or db.activate.MinimapCapitalsEnemyFaction then

            --General Darnassus
                if self.db.profile.activate.MinimapCapitalsGeneral then
    
                    if self.db.profile.showMinimapCapitalsPaths then
                        minimap[1457][88723511] = { dnID = L["Exit"], name = "", mnID = 1438, type = "PathR", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit Exodar
                    end

                    if self.db.profile.showMinimapCapitalsInnkeeper then
                        minimap[1457][67451565] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsAuctioneer then
                        minimap[1457][56255287] = { dnID = MINIMAP_TRACKING_AUCTIONEER, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsBank then
                        minimap[1457][39964227] = { dnID = BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsGhostk then
                        minimap[1457][77662585] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Darnassus
                    end

                    if self.db.profile.showMinimapCapitalsMailbox then
                        minimap[1457][41904140] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsWeaponMasters then
                        minimap[1457][57604660] = { dnID = L["Weapon Master"] .. "\n" .. "\n" .. "• " .. L["Bows"] .. "\n" .. "• " .. L["Daggers"] .. "\n" .. "• " .. L["Fist Weapons"] .. "\n" .. "• " .. L["Staves"] .. "\n" .. "• " .. L["Thrown"], name = "", type = "PvPVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end

            --Transports Darnassus
                if self.db.profile.activate.MinimapCapitalsTransporting then

                    if self.db.profile.showMinimapCapitalsGhost then
                        minimap[1457][77662585] = { name = SPIRIT_HEALER_RELEASE_RED, type = "Ghost", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Darnassus
                    end
                    

                end

            --Professions Darnassus
                if self.db.profile.activate.MinimapCapitalsProfessions then

                    if self.db.profile.showMinimapCapitalsAlchemy then
                        minimap[1457][55342267] = { name = L["Alchemy"], type = "Alchemy", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                
                    if self.db.profile.showMinimapCapitalsLeatherworking then
                        minimap[1457][64442076] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsSkinning then
                        minimap[1457][64072248] = { name = L["Skinning"], type = "Skinning", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsTailoring then
                        minimap[1457][63532124] = { name = L["Tailoring"], type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsFishing then
                        minimap[1457][47905667] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsCooking then
                        minimap[1457][49042124] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsHerbalism then
                        minimap[1457][48006820] = { name = L["Herbalism"], type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsEnchanting then
                        minimap[1457][58801277] = { name = L["Enchanting"], type = "Enchanting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsFirstAid then
                        minimap[1457][51601360] = { name = PROFESSIONS_FIRST_AID, type = "FirstAid", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                end

            --ClassTrainers Darnassus
                if self.db.profile.activate.MinimapCapitalsClasses then

                    if self.db.profile.showMinimapCapitalsClassDruid then
                        minimap[1457][34260862] = { dnID = L["Druid"] .. " " .. TALENT_TRAINER, name = "", type = "Druid", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsClassHunter then
                        minimap[1457][42390804] = { dnID = L["Hunter"] .. " " .. PET_TYPE_PET .. " " .. TALENT_TRAINER .. "\n" .. L["Hunter"] .. " " .. TALENT_TRAINER, name = "", type = "Hunter", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1457][40370855] = { dnID = L["Hunter"] .. " " .. TALENT_TRAINER, name = "", type = "Hunter", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsClassMage then
                        minimap[1457][40608210] = { dnID = L["Mage"] .. " " .. L["Portal"] .. " " .. TUTORIAL_TITLE14, name = "", type = "Mage", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsClassPriest then
                        minimap[1457][37928271] = { dnID = L["Priest"] .. " " .. TALENT_TRAINER, name = "", type = "Priest", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsClassRogue then
                        minimap[1457][32411635] = { dnID = L["Entrance"] .. " " .. L["Rogue"] .. " " .. TALENT_TRAINER, name = "", type = "Rogue", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsClassWarrior then
                        minimap[1457][58613511] = { dnID = L["Warrior"] .. " " .. TALENT_TRAINER, name = "", type = "Warrior", showInZone = false, showOnContinent = false, showOnMinimap = true }
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