local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

function ns.LoadCapitalsLocationinfo(self)
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
                        nodes[85][55684575] = { name = L["Alchemy"], type = "Alchemy", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                
                    if self.db.profile.showCapitalsLeatherworking then
                        nodes[85][60595535] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsEngineer then
                        nodes[85][57105622] = { name = L["Engineer"], type = "Engineer", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        nodes[85][37058474] = { name = L["Engineer"], type = "Engineer", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsSkinning then
                        nodes[85][61385421] = { name = L["Skinning"], type = "Skinning", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        nodes[85][39674937] = { name = L["Skinning"], type = "Skinning", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsTailoring then
                        nodes[85][60755912] = { name = L["Tailoring"], type = "Tailoring", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        nodes[85][38575038] = { name = L["Tailoring"], type = "Tailoring", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        nodes[85][38228718] = { name = L["Tailoring"], type = "Tailoring", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsJewelcrafting then
                        nodes[85][72673406] = { name = L["Jewelcrafting"], type = "Jewelcrafting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsBlacksmith then
                        nodes[85][76533451] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        nodes[85][75353400] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        nodes[85][76373707] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        nodes[85][40635086] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        nodes[85][44237719] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsMining then
                        nodes[85][39058556] = { name = L["Mining"], type = "Mining", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        nodes[85][44547839] = { name = L["Mining"], type = "Mining", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        nodes[85][72343537] = { name = L["Mining"], type = "Mining", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsFishing then
                        nodes[85][66434193] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        nodes[85][35196733] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsCooking then
                        nodes[85][56376139] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        nodes[85][41187939] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        nodes[85][32256966] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsArchaeology then
                        nodes[85][49277069] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsHerbalism then
                        nodes[85][54895027] = { name = L["Herbalism"], type = "Herbalism", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        nodes[85][34836286] = { name = L["Herbalism"], type = "Herbalism", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsEnchanting then
                        nodes[85][53404929] = { name = L["Enchanting"], type = "Enchanting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsInscription then
                        nodes[85][55115586] = { name = INSCRIPTION, type = "Inscription", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                end

            --Transports Orgrimmar
                if self.db.profile.activate.CapitalsTransporting then

                    if self.db.profile.showCapitalsPortals then
                        nodes[85][53757658] = { mnID = 627, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. DUNGEON_FLOOR_DALARANCITY1 } -- Portal near AH to Dalaran
                        nodes[85][57278961] = { name = "", type = "PassageHPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portalroom"] .. "\n" .. "\n" .. " ==> " .. L["Silvermoon City"] .. "\n" .. " ==> " .. L["Valdrakken"] .. "\n" .. " ==> " .. L["Oribos"] .. "\n" .. " ==> " .. L["Azsuna"] .. "\n" .. " ==> " .. L["Zuldazar"] .. "\n" .. " ==> " .. DUNGEON_FLOOR_DALARANCITY1 .. " - " .. POSTMASTER_PIPE_NORTHREND .. "\n" .. " ==> " .. POSTMASTER_LETTER_HYJAL .. "\n" .. "\n" .. " ==> " .. DUNGEON_FLOOR_TANARIS18 .. " - " .. L["in the basement"] .. "\n" .. " ==> " .. L["Shattrath City"] .. " - " .. L["in the basement"] .. "\n" .. " ==> " .. L["Warspear"] .. " - " .. L["in the basement"] .. "\n" .. " ==> " .. L["Blasted Lands"] .. " - " .. L["in the basement"] .. "\n" .. "      (" .. L["talk to"] .. ": " .. L["Thrallmar Mage"] .. " )" .. "\n" .. " ==> " .. L["Dornogal"] .. " - " .. L["in the basement"]} -- Portalroom from Orgrimmar
                        nodes[85][50765561] = { mnID = 18, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. L["Ruins of Lordaeron"] } -- Ruins of Lordaeron 
                        nodes[85][47393928] = { mnID = 245, name = "", type = "HPortalS", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. DUNGEON_FLOOR_TOLBARADWARLOCKSCENARIO0 } --  Portal to Tol Barad
                        nodes[85][48863851] = { mnID = 1527, name = "", type = "HPortalS", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. L["Uldum"] } -- Portal to Uldum
                        nodes[85][50243944] = { mnID = 241, name = "", type = "HPortalS", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. L["Twilight Highlands"] } -- Portal to Twilight Highlands
                        nodes[85][51203832] = { mnID = 198, name = "", type = "HPortalS", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. POSTMASTER_LETTER_HYJAL } -- Portal to Hyjal
                        nodes[85][50863628] = { mnID = 207, name = "", type = "HPortalS", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. ARTIFACT_SHAMAN_TITLECARD_DEEPHOLM } -- Portal to Deepholm
                        nodes[85][49203647] = { mnID = 203, name = "", type = "HPortalS", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. L["Vashj'ir"] } -- Portal to Vashjir
                        nodes[85][48236216] = { mnID = 407, name = L["Transport"] .. " ==> " .. CALENDAR_FILTER_DARKMOON, TransportName = "\n" .. REQUIRES_LABEL .. " " .. CALENDAR_FILTER_DARKMOON .. "\n" .. L["Starting on the first Sunday of each month for one week"], type = "DarkMoon", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[85][38607586] = { mnID = 680, name = L["Portal"] .. " ==> " .. DUNGEON_FLOOR_SURAMARRAID3, type = "HPortalS", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal to Night Fortress
                        nodes[85][38167527] = { mnID = 652, name = L["Portal"] .. " ==> " .. POSTMASTER_LETTER_THUNDERTOTEM, type = "HPortalS", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal to Night Fortress
                    end

                    if self.db.profile.showCapitalsZeppelins then
                        nodes[85][44496228] = { mnID = 114, name = "", type = "HZeppelin", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Zeppelin"] .. " ==> " .. POSTMASTER_LETTER_WARSONGHOLD } -- Zeppelin from OG to Borean Tundra - Northrend
                        nodes[85][42796534] = { mnID = 88, name = "", type = "HZeppelin", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Zeppelin"] .. " ==> " ..  L["Thunder Bluff"]} -- Zeppelin from OG to Thunder Bluff
                        nodes[85][52275315] = { mnID = 50, name = "", type = "HZeppelin", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Zeppelin"] .. " ==> " .. L["Grom'gol, Stranglethorn Vale"] } -- Zeppelin from OG to Stranglethorn
                    end

                    if self.db.profile.showCapitalsFP then
                        nodes[85][49705919] = { name = MINIMAP_TRACKING_FLIGHTMASTER, type = "TravelH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end
    
                end
    
            --Instances Orgrimmar
                if self.db.profile.activate.CapitalsInstances then
    
                    if self.db.profile.showCapitalsDungeons then
                        --nodes[85][51685850] = { id = 226, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ragefire
                        nodes[86][66715154] = { id = 226, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ragefire - Chasm of shadows
                    end

                    if self.db.profile.showCapitalsInstancePassage then
                       nodes[85][55895097] = { mnID = 86, id = 226, TransportName = L["Way to the Instance Entrance"], name = "", type = "PassageDungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ragefire   
                       nodes[85][46116716] = { mnID = 86, id = 226, TransportName = L["Way to the Instance Entrance"], name = "", type = "PassageDungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ragefire  
                       nodes[85][42396160] = { mnID = 86, id = 226, TransportName = L["Way to the Instance Entrance"], name = "", type = "PassageDungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Ragefire    
                    end

                end

            --General Orgrimmar
                if self.db.profile.activate.CapitalsGeneral then
    
                    if self.db.profile.showCapitalsPaths then
                        nodes[85][70583097] = { dnID = L["Entrance"], mnID = 503, name = "", type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false} -- Portal to Shlae'gararena
                        nodes[503][57431229] = { dnID = L["Exit"], mnID = 85, name = "", type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false} -- Portal to Shlae'gararena
                        nodes[85][74800606] = { dnID = L["Exit"], name = "", mnID = 76, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit 
                        nodes[85][49529373] = { dnID = L["Exit"], name = "", mnID = 1, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit 
                        nodes[85][20187080] = { dnID = L["Exit"], name = "", mnID = 10, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit 
                        nodes[86][78691478] = { dnID = L["Passage"], name = "", mnID = 85, type = "PathR", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit 
                        nodes[86][34209104] = { dnID = L["Passage"], name = "", mnID = 85, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit 
                        nodes[86][22856905] = { dnID = L["Passage"], name = "", mnID = 85, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit 
                    end

                    if self.db.profile.showCapitalsInnkeeper then
                        nodes[85][53637877] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[85][40977990] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[85][38854865] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[85][71304995] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsAuctioneer then
                        nodes[85][53957324] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[85][35847732] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[85][41674889] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[85][66623629] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsBank then
                        nodes[85][48748348] = { dnID = BANK .. "\n" .. GUILD_BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[85][67615218] = { dnID = BANK .. "\n" .. GUILD_BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[85][40104599] = { dnID = BANK .. "\n" .. GUILD_BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsMapNotes then
                        nodes[85][32916483] = { dnID = MINIMAP_TRACKING_INNKEEPER .. "\n" .. BANK .. "\n" .. BUTTON_LAG_AUCTIONHOUSE .. "\n" .. MINIMAP_TRACKING_MAILBOX, name = "", type = "MNL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsBarber then
                        nodes[85][40336058] = { dnID = MINIMAP_TRACKING_BARBER, name = "", type = "Barber", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsMailbox then
                        nodes[85][49278068] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[85][50367592] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[85][52727586] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[85][41777162] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[85][36316510] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[85][60105098] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[85][58555961] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[85][67384961] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[85][67713926] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[85][73613717] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[85][51354799] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[85][39764848] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[85][49654161] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[85][71101160] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[85][67603030] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[85][65403130] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[85][55905180] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[85][45006830] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[85][42106050] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsPvPVendor then
                        nodes[85][38347131] = { dnID = TRANSMOG_SET_PVP .. "" .. SLASH_EQUIP_SET1, name = "", type = "PvPVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsTransmogger then
                        nodes[85][58116545] = { dnID = MINIMAP_TRACKING_TRANSMOGRIFIER, name = "", type = "Transmogger", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsPvEVendor then
                        nodes[85][48037056] = { dnID = TRANSMOG_SET_PVE .. "" .. SLASH_EQUIP_SET1, name = "", TransportName = L["(on the tower)"],  type = "PvEVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsStablemaster then
                        nodes[85][40808060] = { dnID = MINIMAP_TRACKING_STABLEMASTER, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[85][32606480] = { dnID = MINIMAP_TRACKING_STABLEMASTER, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[85][39604840] = { dnID = MINIMAP_TRACKING_STABLEMASTER, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[85][62403560] = { dnID = MINIMAP_TRACKING_STABLEMASTER, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
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
                        nodes[88][46643317] = { name = L["Alchemy"], type = "Alchemy", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                
                    if self.db.profile.showCapitalsLeatherworking then
                        nodes[88][41514257] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsEngineer then
                        nodes[88][36065961] = { name = L["Engineer"], type = "Engineer", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsSkinning then
                        nodes[88][44424321] = { name = L["Skinning"], type = "Skinning", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsTailoring then
                        nodes[88][44544531] = { name = L["Tailoring"], type = "Tailoring", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsJewelcrafting then
                        nodes[88][34825399] = { name = L["Jewelcrafting"], type = "Jewelcrafting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsBlacksmith then
                        nodes[88][39365510] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsMining then
                        nodes[88][34385790] = { name = L["Mining"], type = "Mining", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsFishing then
                        nodes[88][56144642] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsCooking then
                        nodes[88][50745310] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsArchaeology then
                        nodes[88][75032812] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsHerbalism then
                        nodes[88][49954040] = { name = L["Herbalism"], type = "Herbalism", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsEnchanting then
                        nodes[88][45293847] = { name = L["Enchanting"], type = "Enchanting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsInscription then
                        nodes[88][28812071] = { name = INSCRIPTION, type = "Inscription", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        nodes[88][30323012] = { name = L["Passage"] .. " " .. MINIMAP_TRACKING_TRAINER_PROFESSION, type = "PassageLeftL", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName =  INSCRIPTION }
                    end

                end

            --Transports Thunder Bluff
                if self.db.profile.activate.CapitalsTransporting then
  
                    if self.db.profile.showCapitalsZeppelins then
                        nodes[88][14292570] = { mnID = 85, name = "", type = "HZeppelin", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Zeppelin"] .. " ==> " .. ORGRIMMAR } -- Zeppelin from Thunder Bluff to OG
                    end

                    if self.db.profile.showCapitalsFP then
                        nodes[88][46654989] = { name = MINIMAP_TRACKING_FLIGHTMASTER, type = "TravelH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                end

            --General Thunder Bluff
                if self.db.profile.activate.CapitalsGeneral then
    
                    if self.db.profile.showCapitalsPaths then
                        nodes[88][52232561] = { dnID = L["Exit"], name = "", mnID = 7, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[88][54632715] = { dnID = L["Exit"], name = "", mnID = 7, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[88][31716595] = { dnID = L["Exit"], name = "", mnID = 7, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[88][31236257] = { dnID = L["Exit"], name = "", mnID = 7, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsInnkeeper then
                        nodes[88][45856477] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsAuctioneer then
                        nodes[88][38875023] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[88][40435169] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsBank then
                        nodes[88][47175862] = { dnID = BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsMailbox then
                        nodes[88][45505950] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsStablemaster then
                        nodes[88][45006000] = { dnID = MINIMAP_TRACKING_STABLEMASTER, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
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

                    if self.db.profile.showCapitalsAlchemy then
                        nodes[110][66701673] = { name = L["Alchemy"], type = "Alchemy", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                
                    if self.db.profile.showCapitalsLeatherworking then
                        nodes[110][85008054] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsEngineer then
                        nodes[110][76634110] = { name = L["Engineer"], type = "Engineer", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsSkinning then
                        nodes[110][84997931] = { name = L["Skinning"], type = "Skinning", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsTailoring then
                        nodes[110][57365009] = { name = L["Tailoring"], type = "Tailoring", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsJewelcrafting then
                        nodes[110][91377443] = { name = L["Jewelcrafting"], type = "Jewelcrafting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        nodes[110][90327383] = { name = L["Jewelcrafting"], type = "Jewelcrafting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsBlacksmith then
                        nodes[110][79423869] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsMining then
                        nodes[110][78914322] = { name = L["Mining"], type = "Mining", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsFishing then
                        nodes[110][76246779] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsCooking then
                        nodes[110][69647153] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsArchaeology then
                        nodes[110][75032812] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        nodes[110][81436390] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsHerbalism then
                        nodes[110][67401842] = { name = L["Herbalism"], type = "Herbalism", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsInscription then
                        nodes[110][69322382] = { name = INSCRIPTION, type = "Inscription", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsEnchanting then
                        nodes[110][70012365] = { name = L["Enchanting"], type = "Enchanting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                end

            --Transports Silvermoon
                if self.db.profile.activate.CapitalsTransporting then

                    if self.db.profile.showCapitalsPortals then
                        nodes[110][58511859] = { mnID = 85, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. ORGRIMMAR } -- Portal to Orgrimmar from Silvermoon 
                        nodes[110][49491509] = { mnID = 18, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. L["Ruins of Lordaeron"] } -- Portal to Undercity from Silvermoon 
                    end

                    if self.db.profile.showCapitalsFP then
                        nodes[110][63159649] = { name = MINIMAP_TRACKING_FLIGHTMASTER, type = "TravelH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                end

            --General Silvermoon
                if self.db.profile.activate.CapitalsGeneral then
    
                    if self.db.profile.showCapitalsPaths then
                        nodes[110][72609199] = { dnID = L["Exit"], name = "", mnID = 94, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit 
                    end

                    if self.db.profile.showCapitalsInnkeeper then
                        nodes[110][79465822] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[110][67867288] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsAuctioneer then
                        nodes[110][92735828] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[110][60726258] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsBank then
                        nodes[110][89714509] = { dnID = BANK .. "\n" .. GUILD_BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[110][65807788] = { dnID = BANK .. "\n" .. GUILD_BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsMailbox then
                        nodes[110][58906150] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[110][65705420] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[110][67902950] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[110][75005460] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[110][82604290] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[110][88205040] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[110][83006220] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[110][83206540] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[110][71607550] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[110][71607980] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsStablemaster then
                        nodes[110][83403040] = { dnID = MINIMAP_TRACKING_STABLEMASTER, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
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
                        nodes[90][47757332] = { name = L["Alchemy"], type = "Alchemy", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        nodes[90][52947737] = { name = L["Passage"] .. " " .. MINIMAP_TRACKING_TRAINER_PROFESSION, type = "PassageLeftL", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName =  L["Alchemy"] }
                        nodes[90][44626639] = { name = L["Passage"] .. " " .. MINIMAP_TRACKING_TRAINER_PROFESSION, type = "PassageLeftL", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName =  L["Alchemy"] }
                    end
                
                    if self.db.profile.showCapitalsLeatherworking then
                        nodes[90][70155740] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsEngineer then
                        nodes[90][76107409] = { name = L["Engineer"], type = "Engineer", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsSkinning then
                        nodes[90][70165922] = { name = L["Skinning"], type = "Skinning", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsTailoring then
                        nodes[90][70763072] = { name = L["Tailoring"], type = "Tailoring", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsJewelcrafting then
                        nodes[90][56503630] = { name = L["Jewelcrafting"], type = "Jewelcrafting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsBlacksmith then
                        nodes[90][61313061] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsMining then
                        nodes[90][56043744] = { name = L["Mining"], type = "Mining", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsFishing then
                        nodes[90][80693124] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsCooking then
                        nodes[90][62194489] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsArchaeology then
                        nodes[90][75403772] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsHerbalism then
                        nodes[90][54014961] = { name = L["Herbalism"], type = "Herbalism", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsInscription then
                        nodes[90][61065801] = { name = INSCRIPTION, type = "Inscription", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsEnchanting then
                        nodes[90][61866139] = { name = L["Enchanting"], type = "Enchanting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                end

            --Transports Undercity
                if self.db.profile.activate.CapitalsTransporting then

                    if self.db.profile.showCapitalsPortals then
                        nodes[90][85181711] = { mnID = 100, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal from Old Undercity to Hellfire
                    end

                    if self.db.profile.showCapitalsFP then
                        nodes[90][63084832] = { name = MINIMAP_TRACKING_FLIGHTMASTER, type = "TravelH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                end

            --General Undercity
                if self.db.profile.activate.CapitalsGeneral then
    
                    if self.db.profile.showCapitalsPaths then
                        nodes[90][15003101] = { dnID = L["Exit"], name = "", mnID = 18, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit 
                        nodes[90][46474406] = { dnID = L["Exit"], name = "", mnID = 18, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit 
                        nodes[90][66110384] = { dnID = L["Exit"] .. " " .. DUNGEON_FLOOR_GILNEAS3, name = "", mnID = 18, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit 
                        nodes[90][49792975] = { dnID = L["Exit"], name = "", mnID = 18, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = REQUIRES_LABEL .. " " .. MOUNT_JOURNAL_FILTER_FLYING } -- Passage/Exit 
                        nodes[90][65865202] = { dnID = DUNGEON_FLOOR_GILNEAS3 .. " ==> " .. DUNGEON_FLOOR_GILNEAS2 .. "\n" ..  DUNGEON_FLOOR_GILNEAS2 .. " ==> " .. DUNGEON_FLOOR_GILNEAS3, name = "", type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit 
                        nodes[90][60584399] = { dnID = DUNGEON_FLOOR_GILNEAS3 .. " ==> " .. DUNGEON_FLOOR_GILNEAS2 .. "\n" ..  DUNGEON_FLOOR_GILNEAS2 .. " ==> " .. DUNGEON_FLOOR_GILNEAS3, name = "", type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit 
                        nodes[90][71294410] = { dnID = DUNGEON_FLOOR_GILNEAS3 .. " ==> " .. DUNGEON_FLOOR_GILNEAS2 .. "\n" ..  DUNGEON_FLOOR_GILNEAS2 .. " ==> " .. DUNGEON_FLOOR_GILNEAS3, name = "", type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit 
                    end

                    if self.db.profile.showCapitalsInnkeeper then
                        nodes[90][67743784] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsAuctioneer then
                        nodes[90][60534156] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[90][64363583] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[90][67663591] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[90][71494189] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[90][71394672] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[90][67545239] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[90][64415242] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[90][60494647] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsBank then
                        nodes[90][66014406] = { dnID = BANK .. "\n" .. GUILD_BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsBarber then
                        nodes[90][70004653] = { dnID = MINIMAP_TRACKING_BARBER, name = "", type = "Barber", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsPvEVendor then
                        nodes[90][78207564] = { dnID = TRANSMOG_SET_PVE .. "" .. SLASH_EQUIP_SET1, name = "", TransportName = HEIRLOOMS,  type = "PvEVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsMailbox then
                        nodes[90][71706150] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[90][62605150] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[90][62603640] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[90][69703600] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[90][69905150] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[90][66505000] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[90][68003850] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsStablemaster then
                        nodes[90][67603800] = { dnID = MINIMAP_TRACKING_STABLEMASTER, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                end

            end

        end

    --###########################
    --### Warspear / Garrison ###
    --###########################
        if self.db.profile.showCapitalsWarspear then

        --#############################
        --### Horde or EnemyFaction ###
        --#############################
            if self.faction == "Horde" or db.activate.CapitalsEnemyFaction then

            --Instance Warspear / Garrison
                if self.db.profile.activate.CapitalsInstances then
    
                    if self.db.profile.showCapitalsLFR then
                        nodes[590][41364698] = { mnID = 590, name = L["Seer Kazal"] .. " - " .. REQUIRES_LABEL .. " " .. GARRISON_LOCATION_TOOLTIP .. " " .. LEVEL .. " " .. ACTION_SPELL_CAST_START_MASTER .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " ", id = { 477, 457, 669 }, type = "LFR", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end
    
                end

            --Professions Warspear
                if self.db.profile.activate.CapitalsProfessions then

                    if self.db.profile.showCapitalsAlchemy then
                        nodes[624][60832652] = { name = L["Alchemy"], type = "Alchemy", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                
                    if self.db.profile.showCapitalsLeatherworking then
                        nodes[624][49532786] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsEngineer then
                        nodes[624][716840299] = { name = L["Engineer"], type = "Engineer", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsSkinning then
                        nodes[624][48643138] = { name = L["Skinning"], type = "Skinning", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsTailoring then
                        nodes[624][59394278] = { name = L["Tailoring"], type = "Tailoring", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsJewelcrafting then
                        nodes[624][60203986] = { name = L["Jewelcrafting"], type = "Jewelcrafting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsBlacksmith then
                        nodes[624][74093712] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsMining then
                        nodes[624][78603676] = { name = L["Mining"], type = "Mining", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsFishing then
                        nodes[624][69161653] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsCooking then
                        nodes[624][45784497] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsArchaeology then
                        nodes[624][73603119] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsHerbalism then
                        nodes[624][62563059] = { name = L["Herbalism"], type = "Herbalism", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsInscription then
                        nodes[624][77104741] = { name = INSCRIPTION, type = "Inscription", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsEnchanting then
                        nodes[624][78755287] = { name = L["Enchanting"], type = "Enchanting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                end

            --Transports Warspear
                if self.db.profile.activate.CapitalsTransporting then

                    if self.db.profile.showCapitalsPortals then
                        nodes[624][53184384] = { mnID = 534, name = L["Vol'mar"], type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal from Ashran to Vol'mar Captive
                        nodes[624][60825159] = { mnID = 85, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. ORGRIMMAR } -- Portal from Garrison to Ashran
                        nodes[590][75184879] = { mnID = 624, name = L["Ashran"], type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal from Garrison to Ashran
                    end

                    if self.db.profile.showCapitalsFP then
                        nodes[590][45665027] = { name = MINIMAP_TRACKING_FLIGHTMASTER, type = "TravelH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[624][44133387] = { name = MINIMAP_TRACKING_FLIGHTMASTER, type = "TravelH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                end

            --General Warspear
                if self.db.profile.activate.CapitalsGeneral then
    
                    if self.db.profile.showCapitalsPaths then
                        nodes[624][55498792] = { dnID = L["Exit"], name = "", mnID = 588, type = "PathR", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit 
                    end

                    if self.db.profile.showCapitalsInnkeeper then
                        nodes[624][44954321] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsAuctioneer then
                        nodes[624][54692551] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsBank then
                        nodes[624][51766162] = { dnID = BANK .. "\n" .. GUILD_BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsPvPVendor then
                        nodes[624][49045437] = { dnID = TRANSMOG_SET_PVP .. "" .. SLASH_EQUIP_SET1, name = "", type = "PvPVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsTransmogger then
                        nodes[624][58335187] = { dnID = MINIMAP_TRACKING_TRANSMOGRIFIER, name = "", type = "Transmogger", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsMailbox then
                        nodes[624][51905650] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[624][47504450] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[624][54503050] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[624][65105270] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[624][68203930] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[624][77805210] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsStablemaster then
                        nodes[624][77605900] = { dnID = MINIMAP_TRACKING_STABLEMASTER, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                end

            end

        end

    --#################
    --### DazarAlor ###
    --#################
        if self.db.profile.showCapitalsDazarAlor then

        --#############################
        --### Horde or EnemyFaction ###
        --#############################
            if self.faction == "Horde" or db.activate.CapitalsEnemyFaction then

            --Professions DazarAlor
                if self.db.profile.activate.CapitalsProfessions then

                    if self.db.profile.showCapitalsAlchemy then
                        nodes[1165][42223796] = { name = L["Alchemy"], type = "Alchemy", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                
                    if self.db.profile.showCapitalsLeatherworking then
                        nodes[1165][44103463] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsEngineer then
                        nodes[1165][45144059] = { name = L["Engineer"], type = "Engineer", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsSkinning then
                        nodes[1165][43783469] = { name = L["Skinning"], type = "Skinning", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsTailoring then
                        nodes[1165][44493387] = { name = L["Tailoring"], type = "Tailoring", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsJewelcrafting then
                        nodes[1165][47053791] = { name = L["Jewelcrafting"], type = "Jewelcrafting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION .. "\n" .. L["in the basement"] }
                    end

                    if self.db.profile.showCapitalsBlacksmith then
                        nodes[1165][43643827] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsMining then
                        nodes[1165][44123896] = { name = L["Mining"], type = "Mining", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsFishing then
                        nodes[1165][50522337] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsCooking then
                        nodes[1165][52479045] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        nodes[1164][28565017] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsArchaeology then
                        nodes[1163][32223550] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION .. "\n" .. ERR_USE_OBJECT_MOVING }
                        nodes[1165][48804311] = { mnID = 1163, name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsHerbalism then
                        nodes[1165][42093560] = { name = L["Herbalism"], type = "Herbalism", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsInscription then
                        nodes[1165][42313974] = { name = INSCRIPTION, type = "Inscription", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        nodes[1164][70563292] = { name = INSCRIPTION, type = "Inscription", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsEnchanting then
                        nodes[1165][47103569] = { name = L["Enchanting"], type = "Enchanting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION .. "\n" .. L["in the basement"] }
                    end
                end

            --Transports DazarAlor
                if self.db.profile.activate.CapitalsTransporting then

                    if self.db.profile.showCapitalsPortals then
                        nodes[1165][51424583] = { mnID = 1163, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Dazar'alor"] .. " " .. L["Portalroom"] .. L["(inside building)"] .. "\n" .. " ==> " .. L["Silvermoon City"] .. "\n" .. " ==> " .. ORGRIMMAR .. "\n" .. " ==> " .. L["Thunder Bluff"] .. "\n" .. " ==> " .. L["Silithus"] .. "\n" .. " ==> " .. L["Nazjatar"] } -- Portalroom from Dazar'alor
                        nodes[1163][73726194] = { mnID = 110, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portalroom from Dazar'alor
                        nodes[1163][74006974] = { mnID = 85, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. ORGRIMMAR } -- Portalroom from Dazar'alor
                        nodes[1163][74027739] = { mnID = 88, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portalroom from Dazar'alor
                        nodes[1163][73808541] = { mnID = 81, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portalroom from Dazar'alor
                        nodes[1163][63008553] = { mnID = 1355,  name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portalroom from Dazar'alor
                        nodes[1165][52079454] = { mnID = 62, name = L["This Darkshore portal is only active if your faction is currently occupying Bashal'Aran"], type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal from Dazar'alor to Arathi or Darkshore
                        nodes[1165][51719454] = { mnID = 14, name = L["This Arathi Highlands portal is only active if your faction is currently occupying Ar'gorok"], type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal from Dazar'alor to Arathi or Darkshore         
                    end

                    if self.db.profile.showCapitalsTransport then
                        nodes[1165][41838761] = { mnID = 1462, name = L["Captain Krooz"] .. " " .. L["Travel"], type = "GoblinF", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Transport from Dazar'alor to Mechagon
                    end

                    if self.db.profile.showCapitalsFP then
                        nodes[1165][52098994] = { name = MINIMAP_TRACKING_FLIGHTMASTER, type = "TravelH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1165][51654120] = { name = MINIMAP_TRACKING_FLIGHTMASTER, type = "TravelH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1165][53121928] = { name = MINIMAP_TRACKING_FLIGHTMASTER, type = "TravelH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                end

            --Instances DazarAlor
                if self.db.profile.activate.CapitalsInstances then
    
                    if self.db.profile.showCapitalsDungeons then
                        nodes[1165][44049256] = { id = 1012, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The MOTHERLODE HORDE
                    end

                    if self.db.profile.showCapitalsRaids then
                        nodes[1165][38920289] = { id = 1176, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Battle of Dazar Alor
                    end

                    if self.db.profile.showCapitalsLFR then
                        nodes[1163][76554199] = { mnID = 1164, name = DUNGEON_FLOOR_GILNEAS3  .. "\n" .. " " .. "\n" .. L["Eppu"] .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " ", id = { 1176, 1031, 1179, 1036 }, type = "PassageRaid", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1164][68583002] = { mnID = 1164, name = L["Eppu"] .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " ", id = { 1176, 1031, 1179, 1036 }, type = "LFR", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1165][49914447] = { mnID = 1164, name = L["Eppu"] .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " ", id = { 1176, 1031, 1179, 1036 }, type = "LFR", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end
                end

            --General DazarAlor
                if self.db.profile.activate.CapitalsGeneral then
    
                    if self.db.profile.showCapitalsPaths then
                        nodes[1165][49934095] = { name = L["Entrance"], mnID = 1163, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit 
                        nodes[1163][48591752] = { dnID = L["Exit"], name = "", mnID = 1165, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit 
                        nodes[1165][37238159] = { dnID = L["Exit"], name = "", mnID = 862, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit 
                        nodes[1165][35875990] = { dnID = L["Exit"], name = "", mnID = 862, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit 
                        nodes[1165][36030716] = { dnID = L["Exit"], name = "", mnID = 862, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit 
                        nodes[1165][57851053] = { dnID = L["Exit"], name = "", mnID = 862, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit 
                        nodes[1165][60526367] = { dnID = L["Exit"], name = "", mnID = 862, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit 
                        nodes[1165][44423697] = { name = L["Passage"] .. " " .. MINIMAP_TRACKING_TRAINER_PROFESSION, type = "PathR", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName =  L["Jewelcrafting"] .. "\n" .. L["Enchanting"] }
                        nodes[1163][57117058] = { name = "", TransportName = L["Passage"] .. " " .. L["Portalroom"], mnID = 1163, type = "PathR", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit 
                        nodes[1163][20962819] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS3, mnID = 1164, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = PROFESSIONS_COOKING .. "\n" .. INSCRIPTION .. "\n" .. RAID_FINDER } -- Passage/Exit 
                        nodes[1163][76532819] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS3, mnID = 1164, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = PROFESSIONS_COOKING .. "\n" .. INSCRIPTION .. "\n" .. RAID_FINDER } -- Passage/Exit 
                        nodes[1163][43888227] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS3, mnID = 1164, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = PROFESSIONS_COOKING .. "\n" .. INSCRIPTION .. "\n" .. RAID_FINDER } -- Passage/Exit 
                        nodes[1163][53458227] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS3, mnID = 1164, type = "PathR", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = PROFESSIONS_COOKING .. "\n" .. INSCRIPTION .. "\n" .. RAID_FINDER } -- Passage/Exit 
                        nodes[1163][41524702] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS3, mnID = 1164, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = PROFESSIONS_COOKING .. "\n" .. INSCRIPTION .. "\n" .. RAID_FINDER } -- Passage/Exit 
                        nodes[1163][55184702] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS3, mnID = 1164, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = PROFESSIONS_COOKING .. "\n" .. INSCRIPTION .. "\n" .. RAID_FINDER } -- Passage/Exit 
                        nodes[1164][42158227] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS2, mnID = 1163, type = "PathR", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portals"] .. "\n" .. BANK .. " / " .. GUILD_BANK .."\n" .. MINIMAP_TRACKING_INNKEEPER .."\n" .. INSCRIPTION .."\n" .. PROFESSIONS_ARCHAEOLOGY } -- Passage/Exit 
                        nodes[1164][54398227] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS2, mnID = 1163, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portals"] .. "\n" .. BANK .. " / " .. GUILD_BANK .."\n" .. MINIMAP_TRACKING_INNKEEPER .."\n" .. INSCRIPTION .."\n" .. PROFESSIONS_ARCHAEOLOGY } -- Passage/Exit 
                        nodes[1164][76683848] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS2, mnID = 1163, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portals"] .. "\n" .. BANK .. " / " .. GUILD_BANK .."\n" .. MINIMAP_TRACKING_INNKEEPER .."\n" .. INSCRIPTION .."\n" .. PROFESSIONS_ARCHAEOLOGY } -- Passage/Exit 
                        nodes[1164][20803895] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS2, mnID = 1163, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portals"] .. "\n" .. BANK .. " / " .. GUILD_BANK .."\n" .. MINIMAP_TRACKING_INNKEEPER .."\n" .. INSCRIPTION .."\n" .. PROFESSIONS_ARCHAEOLOGY } -- Passage/Exit 
                        nodes[1164][40905331] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS2, mnID = 1163, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portals"] .. "\n" .. BANK .. " / " .. GUILD_BANK .."\n" .. MINIMAP_TRACKING_INNKEEPER .."\n" .. INSCRIPTION .."\n" .. PROFESSIONS_ARCHAEOLOGY } -- Passage/Exit 
                        nodes[1164][56435354] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS2, mnID = 1163, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portals"] .. "\n" .. BANK .. " / " .. GUILD_BANK .."\n" .. MINIMAP_TRACKING_INNKEEPER .."\n" .. INSCRIPTION .."\n" .. PROFESSIONS_ARCHAEOLOGY } -- Passage/Exit 
                        nodes[1164][22677175] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS3, mnID = 1165, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit 
                        nodes[1164][74017175] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS3, mnID = 1165, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit 
                    end

                    if self.db.profile.showCapitalsInnkeeper then
                        nodes[1165][52418494] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1165][49844867] = { mnID = 1163, dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1163][48837200] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsAuctioneer then
                        nodes[1165][44964015] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = REQUIRES_LABEL .. " " .. L["Engineer"] }
                    end

                    if self.db.profile.showCapitalsBank then
                        nodes[1163][31834692] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1163][30226774] = { dnID = BANK .. "\n" .. GUILD_BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsBarber then
                        nodes[1165][47358104] = { dnID = MINIMAP_TRACKING_BARBER, name = "", type = "Barber", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsTransmogger then
                        nodes[1165][54508960] = { dnID = MINIMAP_TRACKING_TRANSMOGRIFIER, name = "", type = "Transmogger", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsPvPVendor then
                        nodes[1165][51239509] = { dnID = TRANSMOG_SET_PVP .. "" .. SLASH_EQUIP_SET1, name = "", type = "PvPVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsMailbox then
                        nodes[1165][45209450] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1165][51508550] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1165][50507150] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1165][49604170] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1165][46503510] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1165][43003790] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1165][52901840] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1165][35600920] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1165][41200440] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsStablemaster then
                        nodes[1165][45803620] = { dnID = MINIMAP_TRACKING_STABLEMASTER, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                end

            end

        end

    --#############
    --### Sot2M ###
    --#############
        if self.db.profile.showCapitalsSot2M then

        --#############################
        --### Horde or EnemyFaction ###
        --#############################
            if self.faction == "Horde" or db.activate.CapitalsEnemyFaction then

            --Professions Sot2M
                if self.db.profile.activate.CapitalsProfessions then

                    if self.db.profile.showCapitalsEngineer then
                        nodes[391][62374397] = { name = L["Engineer"], type = "Engineer", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsBlacksmith then
                        nodes[391][25844377] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                end

            --Transports Sot2M
                if self.db.profile.activate.CapitalsTransporting then

                    if self.db.profile.showCapitalsPortals then
                        nodes[392][72464286] = { mnID = 85, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. ORGRIMMAR } -- Portal from Shrine of Two Moons to Orgrimmar
                    end

                end

            --General Sot2M
                if self.db.profile.activate.CapitalsGeneral then
    
                    if self.db.profile.showCapitalsPaths then
                        nodes[391][26778156] = { name = L["Exit"], mnID = 390, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[391][53618846] = { name = L["Exit"], mnID = 390, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[391][77476963] = { name = L["Exit"], mnID = 390, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[391][78084452] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS3, mnID = 392, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = "\n" .. BANK .. "\n" .. GUILD_BANK .. "\n" .. L["Portal"] .. " ==> " .. ORGRIMMAR }
                        nodes[391][22245623] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS3, mnID = 392, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = "\n" .. BANK .. "\n" .. GUILD_BANK .. "\n" .. L["Portal"] .. " ==> " .. ORGRIMMAR }
                        nodes[391][36972301] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS3, mnID = 392, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = "\n" .. BANK .. "\n" .. GUILD_BANK .. "\n" .. L["Portal"] .. " ==> " .. ORGRIMMAR }
                        nodes[391][57691948] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS3, mnID = 392, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = "\n" .. BANK .. "\n" .. GUILD_BANK .. "\n" .. L["Portal"] .. " ==> " .. ORGRIMMAR }
                        nodes[392][55653047] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS2, mnID = 391, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = "\n" .. BUTTON_LAG_AUCTIONHOUSE .. " " .. REQUIRES_LABEL .. " " .. L["Engineer"] .. "\n" .. MINIMAP_TRACKING_INNKEEPER .. "\n" .. L["Engineer"] .. "\n" .. L["Blacksmithing"] }
                        nodes[392][37913400] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS2, mnID = 391, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = "\n" .. BUTTON_LAG_AUCTIONHOUSE .. " " .. REQUIRES_LABEL .. " " .. L["Engineer"] .. "\n" .. MINIMAP_TRACKING_INNKEEPER .. "\n" .. L["Engineer"] .. "\n" .. L["Blacksmithing"] }
                        nodes[392][27407968] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS2, mnID = 391, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = "\n" .. BUTTON_LAG_AUCTIONHOUSE .. " " .. REQUIRES_LABEL .. " " .. L["Engineer"] .. "\n" .. MINIMAP_TRACKING_INNKEEPER .. "\n" .. L["Engineer"] .. "\n" .. L["Blacksmithing"] }
                        nodes[392][74176908] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS2, mnID = 391, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = "\n" .. BUTTON_LAG_AUCTIONHOUSE .. " " .. REQUIRES_LABEL .. " " .. L["Engineer"] .. "\n" .. MINIMAP_TRACKING_INNKEEPER .. "\n" .. L["Engineer"] .. "\n" .. L["Blacksmithing"] }
                    end

                    if self.db.profile.showCapitalsInnkeeper then
                        nodes[391][68544760] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[392][60357734] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsAuctioneer then
                        nodes[391][59044226] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = REQUIRES_LABEL .. " " .. L["Engineer"] }
                    end

                    if self.db.profile.showCapitalsBank then
                        nodes[392][27686535] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[392][20935102] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[392][22975452] = { dnID = BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsMapNotes then
                        nodes[1530][61691650] = { dnID = TRANSMOG_SET_PVE .. "" .. SLASH_EQUIP_SET1 .. "\n" .. BANK .. "\n" .. GUILD_BANK .. "\n" .. L["Portal"] .. " ==> " .. ORGRIMMAR .. "\n" .. BUTTON_LAG_AUCTIONHOUSE .. " " .. REQUIRES_LABEL .. " " .. L["Engineer"] .. "\n" .. MINIMAP_TRACKING_INNKEEPER .. "\n" .. L["Engineer"] .. "\n" .. L["Blacksmithing"], name = "", type = "MNL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsPvEVendor then
                        nodes[392][43717734] = { dnID = TRANSMOG_SET_PVE .. "" .. SLASH_EQUIP_SET1, name = "", TransportName = DUNGEON_FLOOR_GILNEAS3,  type = "PvEVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsMailbox then
                        nodes[391][33655993] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[391][59915144] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[391][67405288] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[391][49778240] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[392][39617815] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[392][62397421] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[392][71503000] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[392][24004020] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
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
                        nodes[84][51196779] = { id = 238, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Stockade
                    end

                end

            --Transports Stormwind
                if self.db.profile.activate.CapitalsTransporting then

                    if self.db.profile.showCapitalsPortals then
                        nodes[84][50710826] = { mnID = 971, name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. L["Telogrus Rift"] } -- Portal to Telogrus
                        nodes[84][62186855] = { mnID = 627, name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. DUNGEON_FLOOR_DALARANCITY1 } -- Portal near AH to Dalaran
                        nodes[84][73221836] = { mnID = 245, name = "", type = "APortalS", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. DUNGEON_FLOOR_TOLBARADWARLOCKSCENARIO0 } --  Portal to Tol Barad
                        nodes[84][75232055] = { mnID = 1527, name = "", type = "APortalS", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. L["Uldum"] } -- Portal to Uldum
                        nodes[84][75351649] = { mnID = 241, name = "", type = "APortalS", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. L["Twilight Highlands"] } -- Portal to Twilight Highlands
                        nodes[84][76211869] = { mnID = 198, name = "", type = "APortalS", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. POSTMASTER_LETTER_HYJAL } -- Portal to Hyjal
                        nodes[84][73171966] = { mnID = 207, name = "", type = "APortalS", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. ARTIFACT_SHAMAN_TITLECARD_DEEPHOLM } -- Portal to Deepholm
                        nodes[84][73301687] = { mnID = 203, name = "", type = "APortalS", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. L["Vashj'ir"] } -- Portal to Vashjir
                        nodes[84][48728798] = { name = "", type = "PassageAPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = STORMWIND .. " " .. L["Portalroom"] .. "\n" .. " ==> " .. L["Ashran"] .. "\n" .. " ==> " .. L["Valdrakken"] .. "\n" .. " ==> " .. L["Boralus, Tiragarde Sound"] .. "\n" .. " ==> " .. L["Oribos"] .. "\n" .. " ==> " .. L["Azsuna"] .. "\n" .. " ==> " .. L["Shattrath City"] .. "\n" .. " ==> " .. L["Jade Forest"] .. "\n" .. " ==> " .. DUNGEON_FLOOR_DALARANCITY1 .. "\n" .. " ==> " .. DUNGEON_FLOOR_TANARIS18 .. "\n" .. " ==> " .. L["Exodar"] .. "\n" ..  " ==> " .. L["Bel'ameth, Amirdrassil"] .. "\n" .. " ==> " .. L["Blasted Lands"] .. "\n" .. " ==> " .. L["Dornogal"] } -- Portalroom from Stormwind
                        nodes[84][23865611] = { mnID = 89, name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. L["Darnassus"] } -- Portal to Darnassus 
                        nodes[84][63197339] = { mnID = 407, name = L["Transport"] .. " ==> " .. CALENDAR_FILTER_DARKMOON, TransportName = "\n" .. REQUIRES_LABEL .. " " .. CALENDAR_FILTER_DARKMOON .. "\n" .. L["Starting on the first Sunday of each month for one week"], type = "DarkMoon", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[84][62043235] = { mnID = 407, name = L["Transport"] .. " ==> " .. CALENDAR_FILTER_DARKMOON, TransportName = "\n" .. REQUIRES_LABEL .. " " .. CALENDAR_FILTER_DARKMOON .. "\n" .. L["Starting on the first Sunday of each month for one week"], type = "DarkMoon", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end
   
                    if self.db.profile.showCapitalsShips then
                        nodes[84][21225479] = { mnID = 1161, name = "", type = "AShip", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Ship"] .. " ==> " .. L["Boralus, Tiragarde Sound"] } -- Ship from Stormwind to Boralus
                        nodes[84][22035670] = { mnID = 2022, name = "", type = "AShip", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Ship"] .. " ==> " .. L["The Waking Shores, Dragon Isles"] } -- Ship from Stormwind to Waking Shores
                        nodes[84][18122555] = { mnID = 114, name = "", type = "AShip", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Ship"] .. " ==> " .. POSTMASTER_LETTER_VALIANCEKEEP } -- Ship from Stormwind to Valiance Keep
                    end

                    if self.db.profile.showCapitalsTransport then
                        nodes[84][66783455] = { mnID = 499, name = "", type = "Carriage", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = DUNGEON_FLOOR_DEEPRUNTRAM1 .. " ==> " .. L["Ironforge"] } -- Transport to Ironforge Carriage
                    end

                    if self.db.profile.showCapitalsFP then
                        nodes[84][71977195] = { name = MINIMAP_TRACKING_FLIGHTMASTER, type = "TravelA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                end

            --Professions Stormwind
                if self.db.profile.activate.CapitalsProfessions then

                    if self.db.profile.showCapitalsAlchemy then
                        nodes[84][55668610] = { name = L["Alchemy"], type = "Alchemy", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                
                    if self.db.profile.showCapitalsLeatherworking then
                        nodes[84][42596045] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        nodes[84][71676301] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsEngineer then
                        nodes[84][62863192] = { name = L["Engineer"], type = "Engineer", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsSkinning then
                        nodes[84][72136222] = { name = L["Skinning"], type = "Skinning", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsTailoring then
                        nodes[84][53098136] = { name = L["Tailoring"], type = "Tailoring", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        nodes[84][52011954] = { name = L["Tailoring"], type = "Tailoring", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsJewelcrafting then
                        nodes[84][63486183] = { name = L["Jewelcrafting"], type = "Jewelcrafting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsBlacksmith then
                        nodes[84][63663702] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsMining then
                        nodes[84][59523778] = { name = L["Mining"], type = "Mining", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        nodes[84][49371220] = { name = L["Mining"], type = "Mining", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsFishing then
                        nodes[84][54806960] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsCooking then
                        nodes[84][77285321] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        nodes[84][50657384] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsArchaeology then
                        nodes[84][85812593] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsHerbalism then
                        nodes[84][54298408] = { name = L["Herbalism"], type = "Herbalism", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        nodes[84][40846587] = { name = L["Herbalism"], type = "Herbalism", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsInscription then
                        nodes[84][49827479] = { name = INSCRIPTION, type = "Inscription", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsEnchanting then
                        nodes[84][52907447] = { name = L["Enchanting"], type = "Enchanting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        nodes[84][51211270] = { name = L["Enchanting"], type = "Enchanting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                end

            --General Stormwind
                if self.db.profile.activate.CapitalsGeneral then
    
                    if self.db.profile.showCapitalsPaths then
                        nodes[84][73399051] = { dnID = L["Exit"], name = "", mnID = 37, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit 
                        nodes[499][89874349] = { dnID = L["Passage"], name = "", mnID = 87, type = "PathR", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit 
                        nodes[499][89876720] = { dnID = L["Passage"], name = "", mnID = 87, type = "PathR", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit 
                        nodes[499][42471587] = { dnID = L["Entrance"], name = "", mnID = 84, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit 
                        nodes[499][52124649] = { dnID = L["Stormwind"] .. " - " .. DUNGEON_FLOOR_DEEPRUNTRAM1 .. "\n" .. " ==> " .. DUNGEON_FLOOR_DEEPRUNTRAM2, name = "", mnID = 500, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit 
                        nodes[500][72440888] = { dnID = DUNGEON_FLOOR_DEEPRUNTRAM1, name = "", mnID = 499, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit 
                    end

                    if self.db.profile.showCapitalsInnkeeper then
                        nodes[84][60407527] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[84][75685411] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[84][49881574] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[84][64943193] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsAuctioneer then
                        nodes[84][61167081] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[84][60233216] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsBank then
                        nodes[84][62887831] = { dnID = BANK .. "\n" .. GUILD_BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[84][64562883] = { dnID = BANK .. "\n" .. GUILD_BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsBarber then
                        nodes[84][61316464] = { dnID = MINIMAP_TRACKING_BARBER, name = "", type = "Barber", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsPvPVendor then
                        nodes[84][74486812] = { dnID = TRANSMOG_SET_PVP .. "" .. SLASH_EQUIP_SET1, name = "", type = "PvPVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsTransmogger then
                        nodes[84][50396054] = { dnID = MINIMAP_TRACKING_TRANSMOGRIFIER, name = "", type = "Transmogger", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsPvEVendor then
                        nodes[84][75666652] = { dnID = TRANSMOG_SET_PVE .. "" .. SLASH_EQUIP_SET1, name = "", TransportName = DUNGEON_FLOOR_GILNEAS3,  type = "PvEVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsMailbox then
                        nodes[84][30204950] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[84][30502550] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[84][37803470] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[84][53201550] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[84][62003120] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[84][60805070] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[84][54805740] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[84][54606350] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[84][51007070] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[84][74505560] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[84][75806440] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[84][66806550] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[84][62107050] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[84][57507150] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[84][62507470] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsStablemaster then
                        nodes[84][77806720] = { dnID = MINIMAP_TRACKING_STABLEMASTER, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[84][67003760] = { dnID = MINIMAP_TRACKING_STABLEMASTER, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
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
                        nodes[87][72545022] = { mnID = 84, name = "", type = "Carriage", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = DUNGEON_FLOOR_DEEPRUNTRAM1 .. " ==> " .. STORMWIND } -- Transport to Stormwind Carriage
                    end

                    if self.db.profile.showCapitalsFP then
                        nodes[87][55884786] = { name = MINIMAP_TRACKING_FLIGHTMASTER, type = "TravelA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                end

            --Professions ironforge
                if self.db.profile.activate.CapitalsProfessions then

                    if self.db.profile.showCapitalsAlchemy then
                        nodes[87][66615566] = { name = L["Alchemy"], type = "Alchemy", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                
                    if self.db.profile.showCapitalsLeatherworking then
                        nodes[87][40223365] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsEngineer then
                        nodes[87][68444359] = { name = L["Engineer"], type = "Engineer", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsSkinning then
                        nodes[87][39843248] = { name = L["Skinning"], type = "Skinning", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsTailoring then
                        nodes[87][43132939] = { name = L["Tailoring"], type = "Tailoring", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsJewelcrafting then
                        nodes[87][50192602] = { name = L["Jewelcrafting"], type = "Jewelcrafting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsBlacksmith then
                        nodes[87][50324338] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        nodes[87][52554139] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsMining then
                        nodes[87][50142649] = { name = L["Mining"], type = "Mining", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsFishing then
                        nodes[87][48090763] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsCooking then
                        nodes[87][60073646] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsArchaeology then
                        nodes[87][75611110] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsHerbalism then
                        nodes[87][55865907] = { name = L["Herbalism"], type = "Herbalism", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsInscription then
                        nodes[87][61004516] = { name = INSCRIPTION, type = "Inscription", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsEnchanting then
                        nodes[87][60114533] = { name = L["Enchanting"], type = "Enchanting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                end

            --General Ironforge
                if self.db.profile.activate.CapitalsGeneral then
    
                    if self.db.profile.showCapitalsPaths then
                        nodes[87][14218604] = { dnID = L["Exit"], name = "", mnID = 27, type = "PathLU", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit 
                    end

                    if self.db.profile.showCapitalsInnkeeper then
                        nodes[87][18165147] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsAuctioneer then
                        nodes[87][25517317] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsBank then
                        nodes[87][35646042] = { dnID = BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[87][33516017] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[87][35386360] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsBarber then
                        nodes[87][25215134] = { dnID = MINIMAP_TRACKING_BARBER, name = "", type = "Barber", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsPvEVendor then
                        nodes[87][74400917] = { dnID = TRANSMOG_SET_PVE .. "" .. SLASH_EQUIP_SET1, name = "", TransportName = HEIRLOOMS,  type = "PvEVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsMailbox then
                        nodes[87][46805900] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[87][61602760] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[87][71207250] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[87][21505310] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[87][33606370] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[87][72504950] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsStablemaster then
                        nodes[87][69008460] = { dnID = MINIMAP_TRACKING_STABLEMASTER, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
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
                    nodes[89][36045019] = { mnID = 57, name = "", type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. L["Rut'theran"] } -- Portal To Darnassus from Teldrassil
                end

            end

        --################################
        --### Alliance or EnemyFaction ###
        --################################
            if self.faction == "Alliance" or db.activate.CapitalsEnemyFaction then

            --General Darnassus
                if self.db.profile.activate.CapitalsGeneral then
    
                    if self.db.profile.showCapitalsPaths then
                        nodes[89][79984648] = { dnID = L["Exit"], name = "", mnID = 57, type = "PathR", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit
                    end

                    if self.db.profile.showCapitalsInnkeeper then
                        nodes[89][62533278] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsAuctioneer then
                        nodes[89][54915837] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsBank then
                        nodes[89][44285140] = { dnID = BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[89][42655247] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsMailbox then
                        nodes[89][62603330] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[89][60707150] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[89][57505990] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[89][54705320] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[89][44905040] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsStablemaster then
                        nodes[89][43602940] = { dnID = MINIMAP_TRACKING_STABLEMASTER, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                end

            --Transports Darnassus
                if self.db.profile.activate.CapitalsTransporting then

                    if self.db.profile.showCapitalsPortals then
                        nodes[89][44127840] = { name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portals"] .. "\n" .. " ==> " .. L["Exodar"] .. "\n" .. " ==> " .. L["Hellfire Peninsula"] } -- Portal To Darnassus from Teldrassil
                    end

                    if self.db.profile.showCapitalsFP then
                        nodes[89][36724827] = { name = MINIMAP_TRACKING_FLIGHTMASTER, type = "TravelA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                end

            --Professions Darnassus
                if self.db.profile.activate.CapitalsProfessions then

                    if self.db.profile.showCapitalsAlchemy then
                        nodes[89][53913853] = { name = L["Alchemy"], type = "Alchemy", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                
                    if self.db.profile.showCapitalsLeatherworking then
                        nodes[89][60463683] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsEngineer then
                        nodes[89][49613236] = { name = L["Engineer"], type = "Engineer", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsSkinning then
                        nodes[89][60273733] = { name = L["Skinning"], type = "Skinning", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsTailoring then
                        nodes[89][59783740] = { name = L["Tailoring"], type = "Tailoring", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsJewelcrafting then
                        nodes[89][53993111] = { name = L["Jewelcrafting"], type = "Jewelcrafting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsBlacksmith then
                        nodes[89][56985271] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsMining then
                        nodes[89][50083357] = { name = L["Mining"], type = "Mining", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsFishing then
                        nodes[89][49096098] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsCooking then
                        nodes[89][49893663] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsArchaeology then
                        nodes[89][42658334] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsHerbalism then
                        nodes[89][49146878] = { name = L["Herbalism"], type = "Herbalism", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsInscription then
                        nodes[89][56793163] = { name = INSCRIPTION, type = "Inscription", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsEnchanting then
                        nodes[89][56413101] = { name = L["Enchanting"], type = "Enchanting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
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
                        nodes[103][34947443] = { dnID = L["Exit"], name = "", mnID = 97, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit
                        nodes[103][65223478] = { dnID = L["Exit"], name = "", mnID = 97, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit
                    end

                    if self.db.profile.showCapitalsInnkeeper then
                        nodes[103][59511876] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsAuctioneer then
                        nodes[103][61935508] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsBank then
                        nodes[103][49224406] = { dnID = BANK .. "\n" .. GUILD_BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsMailbox then
                        nodes[103][79606350] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[103][60505190] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[103][51504320] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[103][59302760] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsStablemaster then
                        nodes[103][59402440] = { dnID = MINIMAP_TRACKING_STABLEMASTER, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                end

            --Transports Exodar
                if self.db.profile.activate.CapitalsTransporting then

                    if self.db.profile.showCapitalsPortals then
                        nodes[103][48326264] = { mnID = 84, name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. STORMWIND } -- Portal Exodar to Stormwind
                    end

                    if self.db.profile.showCapitalsFP then
                        nodes[103][54383659] = { name = MINIMAP_TRACKING_FLIGHTMASTER, type = "TravelA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                end

            --Professions Exodar
                if self.db.profile.activate.CapitalsProfessions then

                    if self.db.profile.showCapitalsAlchemy then
                        nodes[103][27766078] = { name = L["Alchemy"], type = "Alchemy", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                
                    if self.db.profile.showCapitalsLeatherworking then
                        nodes[103][67467457] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsEngineer then
                        nodes[103][54139288] = { name = L["Engineer"], type = "Engineer", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsSkinning then
                        nodes[103][65657456] = { name = L["Skinning"], type = "Skinning", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsTailoring then
                        nodes[103][64386894] = { name = L["Tailoring"], type = "Tailoring", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsJewelcrafting then
                        nodes[103][44882424] = { name = L["Jewelcrafting"], type = "Jewelcrafting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsBlacksmith then
                        nodes[103][60609000] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsMining then
                        nodes[103][59698781] = { name = L["Mining"], type = "Mining", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsFishing then
                        nodes[103][31931462] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsCooking then
                        nodes[103][55772672] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsArchaeology then
                        nodes[103][33316569] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsHerbalism then
                        nodes[103][27456281] = { name = L["Herbalism"], type = "Herbalism", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsInscription then
                        nodes[103][39833860] = { name = INSCRIPTION, type = "Inscription", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsEnchanting then
                        nodes[103][40693881] = { name = L["Enchanting"], type = "Enchanting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                end

            end

        end

    --##############################
    --### Stormshield / Garrison ###
    --##############################
        if self.db.profile.showCapitalsStormshield then

        --################################
        --### Alliance or EnemyFaction ###
        --################################
            if self.faction == "Alliance" or db.activate.CapitalsEnemyFaction then

            --Instance Warspear / Garrison
                if self.db.profile.activate.CapitalsInstances then
    
                    if self.db.profile.showCapitalsLFR then
                        nodes[582][33173703] = { mnID = 582, name = L["Seer Kazal"] .. " - " .. REQUIRES_LABEL .. " " .. GARRISON_LOCATION_TOOLTIP .. " " .. LEVEL .. " " .. ACTION_SPELL_CAST_START_MASTER .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " ", id = { 477, 457, 669 }, type = "LFR", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end
    
                end

            --General Stormshield
                if self.db.profile.activate.CapitalsGeneral then
    
                    if self.db.profile.showCapitalsPaths then
                        nodes[622][55650794] = { dnID = L["Exit"], name = "", mnID = 588, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit
                    end

                    if self.db.profile.showCapitalsInnkeeper then
                        nodes[622][35727790] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsAuctioneer then
                        nodes[622][53966609] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsBank then
                        nodes[622][54394818] = { dnID = BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[622][56135089] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsPvPVendor then
                        nodes[622][54781873] = { dnID = TRANSMOG_SET_PVP .. " " .. MERCHANT, name = "", type = "PvPVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsTransmogger then
                        nodes[622][63133544] = { dnID = MINIMAP_TRACKING_TRANSMOGRIFIER, name = "", type = "Transmogger", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsPvEVendor then
                        nodes[622][49776140] = { dnID = TRANSMOG_SET_PVE .. " " .. MERCHANT, name = "", type = "PvEVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsMailbox then
                        nodes[622][36207260] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[622][43506950] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[622][42103790] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[622][51604450] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[622][63602250] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsStablemaster then
                        nodes[622][34006420] = { dnID = MINIMAP_TRACKING_STABLEMASTER, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                end

            --Transports Stormshield
                if self.db.profile.activate.CapitalsTransporting then

                    if self.db.profile.showCapitalsPortals then
                        nodes[582][69692706] = { mnID = 622, name = L["Ashran"], type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal from Garison to Ashran
                        nodes[622][36234113] = { mnID = 534, name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. SPLASH_NEW_6_2_FEATURE1_TITLE } -- Portal from Ashran to Lion's Watch
                        nodes[622][60813785] = { mnID = 84,  name = "" , type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. STORMWIND } -- Portal from Ashran to Stormwind
                    end
                    
                    if self.db.profile.showCapitalsFP then
                        nodes[662][30554842] = { name = MINIMAP_TRACKING_FLIGHTMASTER, type = "TravelA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[582][47764933] = { name = MINIMAP_TRACKING_FLIGHTMASTER, type = "TravelA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                end

            --Professions Stormshield
                if self.db.profile.activate.CapitalsProfessions then

                    if self.db.profile.showCapitalsAlchemy then
                        nodes[622][37056882] = { name = L["Alchemy"], type = "Alchemy", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                
                    if self.db.profile.showCapitalsLeatherworking then
                        nodes[622][52494201] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsEngineer then
                        nodes[622][48004052] = { name = L["Engineer"], type = "Engineer", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsSkinning then
                        nodes[622][52124369] = { name = L["Skinning"], type = "Skinning", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsTailoring then
                        nodes[622][51533716] = { name = L["Tailoring"], type = "Tailoring", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsJewelcrafting then
                        nodes[622][43513391] = { name = L["Jewelcrafting"], type = "Jewelcrafting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsBlacksmith then
                        nodes[622][49344639] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsMining then
                        nodes[622][47324371] = { name = L["Mining"], type = "Mining", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsFishing then
                        nodes[622][55497849] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsCooking then
                        nodes[622][35137611] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION .. "\n" .. L["in the basement"] }
                    end

                    if self.db.profile.showCapitalsArchaeology then
                        nodes[622][48993319] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsHerbalism then
                        nodes[622][37616948] = { name = L["Herbalism"], type = "Herbalism", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsInscription then
                        nodes[622][63163365] = { name = INSCRIPTION, type = "Inscription", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsEnchanting then
                        nodes[622][56706551] = { name = L["Enchanting"], type = "Enchanting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                end

            end

        end

    --###############
    --### Boralus ###
    --###############
        if self.db.profile.showCapitalsBoralus then

        --################################
        --### Alliance or EnemyFaction ###
        --################################
            if self.faction == "Alliance" or db.activate.CapitalsEnemyFaction then

            --Instance Boralus
                if self.db.profile.activate.CapitalsInstances then

                    if self.db.profile.showCapitalsRaids then
                        nodes[1161][70443555] = { id = 1176, type = "Raid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Battle of Dazar'alor
                    end

                    if self.db.profile.showCapitalsDungeons then
                        nodes[1161][71971537] = { id = 1023, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Siege of Boralus
                    end

                    if self.db.profile.showCapitalsLFR then
                        nodes[1161][74191352] = { mnID = 1161, name = L["Kiku"] .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " ", id = { 1176, 1031, 1179, 1036 }, type = "LFR", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end
    
                end

            --General Boralus
                if self.db.profile.activate.CapitalsGeneral then
    
                    if self.db.profile.showCapitalsPaths then
                        nodes[1161][81239058] = { dnID = L["Exit"], name = "", mnID = 895, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit
                        nodes[1161][37761547] = { dnID = L["Exit"], name = "", mnID = 895, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit
                        nodes[1161][42621359] = { dnID = L["Exit"], name = "", mnID = 895, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit
                        nodes[1161][08093855] = { dnID = L["Exit"], name = "", mnID = 895, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit
                    end

                    if self.db.profile.showCapitalsInnkeeper then
                        nodes[1161][74001234] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsAuctioneer then
                        nodes[1161][77271368] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = REQUIRES_LABEL .. " " .. L["Engineer"] }
                    end

                    if self.db.profile.showCapitalsBank then
                        nodes[1161][75591929] = { dnID = BANK .. "\n" .. GUILD_BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsBarber then
                        nodes[1161][64752889] = { dnID = MINIMAP_TRACKING_BARBER, name = "", type = "Barber", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsPvPVendor then
                        nodes[1161][55952505] = { dnID = TRANSMOG_SET_PVP .. "" .. SLASH_EQUIP_SET1, name = "", type = "PvPVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsTransmogger then
                        nodes[1161][71621371] = { dnID = MINIMAP_TRACKING_TRANSMOGRIFIER, name = "", type = "Transmogger", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsMailbox then
                        nodes[1161][73606890] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1161][57002690] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1161][67002360] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[1161][73801450] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsStablemaster then
                        nodes[1161][69001300] = { dnID = MINIMAP_TRACKING_STABLEMASTER, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                end

            --Transports Boralus
                if self.db.profile.activate.CapitalsTransporting then

                    if self.db.profile.showCapitalsPortals then
                        nodes[1161][70351605] = { name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Boralus"] .. " " .. L["Portalroom"] .. "\n" .. " " .. L["(inside building)"] .. "\n" .. " ==> " .. STORMWIND .. "\n" .. " ==> " .. L["Silithus"] .. "\n" .. " ==> " .. L["Exodar"] .. "\n" .. " ==> " .. L["Ironforge"] } -- Portalroom from Boralus
                        nodes[1161][66182474] = { mnID = 14, name = L["This Arathi Highlands portal is only active if your faction is currently occupying Ar'gorok"], type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portalroom from Boralus
                        nodes[1161][66212442] = { mnID = 62, name = L["This Darkshore portal is only active if your faction is currently occupying Bashal'Aran"], type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portalroom from Boralus
                    end

                    if self.db.profile.showCapitalsTransport then
                        nodes[1161][67952670] = { mnID = 862, mnID2 = 864, mnID3 = 863, name = L["(Grand Admiral Jes-Tereth) will take you to Vol'Dun, Nazmir or Zuldazar"], dnID = " " .. ITEM_REQ_ALLIANCE, type = "GilneanF", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal from Dazar'alor to Mechagon
                    end

                    if self.db.profile.showCapitalsFP then
                        nodes[1161][47916532] = { name = MINIMAP_TRACKING_FLIGHTMASTER, type = "TravelA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                end

            --Professions Boralus
                if self.db.profile.activate.CapitalsProfessions then

                    if self.db.profile.showCapitalsAlchemy then
                        nodes[1161][74090670] = { name = L["Alchemy"], type = "Alchemy", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                
                    if self.db.profile.showCapitalsLeatherworking then
                        nodes[1161][75451258] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsEngineer then
                        nodes[1161][77611434] = { name = L["Engineer"], type = "Engineer", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsSkinning then
                        nodes[1161][75661340] = { name = L["Skinning"], type = "Skinning", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsTailoring then
                        nodes[1161][76951116] = { name = L["Tailoring"], type = "Tailoring", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsJewelcrafting then
                        nodes[1161][75210986] = { name = L["Jewelcrafting"], type = "Jewelcrafting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsBlacksmith then
                        nodes[1161][73470849] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsMining then
                        nodes[1161][75200760] = { name = L["Mining"], type = "Mining", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsFishing then
                        nodes[1161][74160560] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsCooking then
                        nodes[1161][71201068] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsArchaeology then
                        nodes[1161][68340848] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsHerbalism then
                        nodes[1161][70550566] = { name = L["Herbalism"], type = "Herbalism", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsInscription then
                        nodes[1161][73380637] = { name = INSCRIPTION, type = "Inscription", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showCapitalsEnchanting then
                        nodes[1161][74031153] = { name = L["Enchanting"], type = "Enchanting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                end

            end

        end

    --#############
    --### Sot7S ###
    --#############
        if self.db.profile.showCapitalsSot7S then

        --################################
        --### Alliance or EnemyFaction ###
        --################################
            if self.faction == "Alliance" or db.activate.CapitalsEnemyFaction then

            --General Sot7S
                if self.db.profile.activate.CapitalsGeneral then
    
                    if self.db.profile.showCapitalsPaths then
                        nodes[393][24265267] = { name = L["Exit"], mnID = 390, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[393][60201547] = { name = L["Exit"], mnID = 390, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[393][37762459] = { name = L["Exit"], mnID = 390, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[393][70883384] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS3, mnID = 394, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = "\n" .. BANK .. "\n" .. GUILD_BANK .. "\n" .. L["Portal"] .. " ==> " .. STORMWIND }
                        nodes[393][54048271] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS3, mnID = 394, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = "\n" .. BANK .. "\n" .. GUILD_BANK .. "\n" .. L["Portal"] .. " ==> " .. STORMWIND }
                        nodes[393][67926633] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS3, mnID = 394, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = "\n" .. BANK .. "\n" .. GUILD_BANK .. "\n" .. L["Portal"] .. " ==> " .. STORMWIND }
                        nodes[393][32697602] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS3, mnID = 394, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = "\n" .. BANK .. "\n" .. GUILD_BANK .. "\n" .. L["Portal"] .. " ==> " .. STORMWIND }
                        nodes[394][55347175] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS2, mnID = 393, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = "\n" .. BUTTON_LAG_AUCTIONHOUSE .. " " .. REQUIRES_LABEL .. " " .. L["Engineer"] .. "\n" .. MINIMAP_TRACKING_INNKEEPER .. "\n" .. L["Blacksmithing"] }
                        nodes[394][67115809] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS2, mnID = 393, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = "\n" .. BUTTON_LAG_AUCTIONHOUSE .. " " .. REQUIRES_LABEL .. " " .. L["Engineer"] .. "\n" .. MINIMAP_TRACKING_INNKEEPER .. "\n" .. L["Blacksmithing"] }
                        nodes[394][31955456] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS2, mnID = 393, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = "\n" .. BUTTON_LAG_AUCTIONHOUSE .. " " .. REQUIRES_LABEL .. " " .. L["Engineer"] .. "\n" .. MINIMAP_TRACKING_INNKEEPER .. "\n" .. L["Blacksmithing"] }
                        nodes[394][63182065] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS2, mnID = 393, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = "\n" .. BUTTON_LAG_AUCTIONHOUSE .. " " .. REQUIRES_LABEL .. " " .. L["Engineer"] .. "\n" .. MINIMAP_TRACKING_INNKEEPER .. "\n" .. L["Blacksmithing"] }
                    end

                    if self.db.profile.showCapitalsInnkeeper then
                        nodes[393][36506610] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsAuctioneer then
                        nodes[393][57045237] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = REQUIRES_LABEL .. " " .. L["Engineer"] }
                    end

                    if self.db.profile.showCapitalsBank then
                        nodes[393][55624688] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[394][48517769] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[394][42608412] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[394][38927502] = { dnID = BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[394][44866826] = { dnID = BANK .. " / " .. GUILD_BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsTransmogger then
                        nodes[394][55598526] = { dnID = MINIMAP_TRACKING_TRANSMOGRIFIER, name = "", type = "Transmogger", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsPvEVendor then
                        nodes[394][42834374] = { dnID = TRANSMOG_SET_PVE .. "" .. SLASH_EQUIP_SET1, name = "",  type = "PvEVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.db.profile.showCapitalsMailbox then
                        nodes[393][61883771] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[393][30356275] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[393][31006220] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[394][74255074] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[394][64703436] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[394][44228360] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[394][39496198] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                end

            --Transports Sot7S
                if self.db.profile.activate.CapitalsTransporting then

                    if self.db.profile.showCapitalsPortals then
                        nodes[394][71563593] = { mnID = 84, name = "", type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName =  L["Portal"] .. " ==> " .. STORMWIND }
                    end

                end

            --Professions Sot7S
                if self.db.profile.activate.CapitalsProfessions then

                    if self.db.profile.showCapitalsBlacksmith then
                        nodes[393][72655225] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
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
                    nodes[111][56278147] = { dnID = MINIMAP_TRACKING_INNKEEPER .. " - " .. L["The Scryers"], name = "", type = "Innkeeper", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[111][28284938] = { dnID = MINIMAP_TRACKING_INNKEEPER .. " - " .. L["The Aldor"], name = "", type = "Innkeeper", showInZone = true, showOnContinent = false, showOnMinimap = false }

                    if self.db.profile.showCapitalsMapNotes then
                        nodes[111][43849031] = { dnID = TUTORIAL_TITLE38 .. " - " .. L["The Scryers"] .. "\n" .. "\n" .. L["Alchemy"] .. "\n" .. L["Engineer"] .. "\n" .. L["Jewelcrafting"] .. "\n" .. L["Leatherworking"] .. "\n" .. L["Blacksmithing"] .. "\n" .. L["Tailoring"] .. "\n" .. L["Skinning"] .. "\n" .. L["Mining"] .. "\n" .. L["Herbalism"] .. "\n" .. L["Enchanting"] .. "\n" .. INSCRIPTION .. "\n" .. PROFESSIONS_FISHING .. "\n" .. PROFESSIONS_COOKING, name = "", type = "MNL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                end

                if self.db.profile.showCapitalsPaths then
                    nodes[111][68936616] = { name = L["Exit"], mnID = 108, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[111][77264326] = { name = L["Exit"], mnID = 108, type = "PathR", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[111][72291901] = { name = L["Exit"], mnID = 108, type = "PathRO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[111][61790952] = { name = L["Exit"], mnID = 108, type = "PathO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[111][79515778] = { name = L["Exit"], mnID = 108, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[111][22344989] = { name = L["Exit"], mnID = 107, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.db.profile.showCapitalsAuctioneer then
                    nodes[111][57066278] = { name = BUTTON_LAG_AUCTIONHOUSE .. " - " .. L["The Scryers"], type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[111][51242693] = { name = BUTTON_LAG_AUCTIONHOUSE .. " - " .. L["The Aldor"], type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.db.profile.showCapitalsBank then
                    nodes[111][60226036] = { dnID = BANK .. " - " .. L["The Scryers"], name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[111][62245901] = { dnID = GUILD_BANK  .. " - " .. L["The Scryers"], name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[111][47932940] = { dnID = BANK .. " - " .. L["The Aldor"], name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[111][46113106] = { dnID = GUILD_BANK  .. " - " .. L["The Aldor"], name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.db.profile.showCapitalsPvEVendor then
                    nodes[111][50864226] = { dnID = TRANSMOG_SET_PVE .. "" .. SLASH_EQUIP_SET1, name = "", type = "PvEVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[111][47752581] = { dnID = L["Quartermaster"] .. " - " .. L["The Aldor"], name = "", type = "PvEVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[111][60486423] = { dnID = L["Quartermaster"] .. " - " .. L["The Scryers"], name = "", type = "PvEVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.db.profile.showCapitalsMailbox then
                    nodes[111][55508050] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[111][28104780] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[111][60006480] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[111][74704840] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[111][73503460] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[111][47002570] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.db.profile.showCapitalsStablemaster then
                    nodes[111][28604760] = { dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. L["The Aldor"], name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[111][55808080] = { dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. L["The Scryers"], name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

            end

        --Transports Shattrath
            if self.db.profile.activate.CapitalsTransporting then
    
                if self.db.profile.showCapitalsPortals then
                    nodes[111][48614203] = { mnID = 122, name = "", type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portal from Shattrath to Quel'Danas 

                    if self.faction == "Horde" or db.activate.CapitalsEnemyFaction then
                        nodes[111][56784884] = { mnID = 85, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Shattrath City"] .. " " .. L["Portals"] .. "\n" ..  "\n" .. " ==> " .. ORGRIMMAR } -- Portal from Shattrath to Orgrimmar 
                    end

                    if self.faction == "Alliance" or db.activate.CapitalsEnemyFaction then
                        nodes[111][57214825] = { mnID = 84,  name = "" , type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Shattrath City"] .. " " .. L["Portal"] .. "\n" .. " ==> " .. STORMWIND } -- Portal from Shattrath to Stormwind 
                    end
                end

                if self.db.profile.showCapitalsFP then
                    nodes[111][63794171] = { name = MINIMAP_TRACKING_FLIGHTMASTER, type = "TravelL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

            end

        --Professions Shattrath
            if self.db.profile.activate.CapitalsProfessions then

                if self.db.profile.showCapitalsAlchemy then
                    nodes[111][37977048] = { name = L["Alchemy"] .. " - " .. L["The Scryers"], type = "Alchemy", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    nodes[111][38892992] = { name = L["Alchemy"] .. " - " .. L["The Aldor"], type = "Alchemy", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    nodes[111][45612149] = { name = L["Alchemy"], type = "Alchemy", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end
            
                if self.db.profile.showCapitalsLeatherworking then
                    nodes[111][41366301] = { name = L["Leatherworking"] .. " - " .. L["The Scryers"], type = "Leatherworking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    nodes[111][37652815] = { name = L["Leatherworking"] .. " - " .. L["The Aldor"], type = "Leatherworking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    nodes[111][67256738] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }

                end

                if self.db.profile.showCapitalsEngineer then
                    nodes[111][43926531] = { name = L["Engineer"] .. " - " .. L["The Scryers"], type = "Engineer", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    nodes[111][37823205] = { name = L["Engineer"] .. " - " .. L["The Aldor"], type = "Engineer", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsSkinning then
                    nodes[111][40626347] = { name = L["Skinning"] .. " - " .. L["The Scryers"], type = "Skinning", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    nodes[111][36972686] = { name = L["Skinning"] .. " - " .. L["The Aldor"], type = "Skinning", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    nodes[111][63946588] = { name = L["Skinning"], type = "Skinning", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsTailoring then
                    nodes[111][41176365] = { name = L["Tailoring"] .. " - " .. L["The Scryers"], type = "Tailoring", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    nodes[111][37812700] = { name = L["Tailoring"] .. " - " .. L["The Aldor"], type = "Tailoring", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsJewelcrafting then
                    nodes[111][58027508] = { name = L["Jewelcrafting"] .. " - " .. L["The Scryers"], type = "Jewelcrafting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    nodes[111][35671956] = { name = L["Jewelcrafting"] .. " - " .. L["The Aldor"], type = "Jewelcrafting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    nodes[111][36024745] = { name = L["Jewelcrafting"] .. " - " .. L["The Aldor"], type = "Jewelcrafting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsBlacksmith then
                    nodes[111][43236492] = { name = L["Blacksmithing"] .. " - " .. L["The Scryers"], type = "Blacksmith", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    nodes[111][37293132] = { name = L["Blacksmithing"] .. " - " .. L["The Aldor"], type = "Blacksmith", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    nodes[111][69484332] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsMining then
                    nodes[111][58917523] = { name = L["Mining"] .. " - " .. L["The Scryers"], type = "Mining", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    nodes[111][36054859] = { name = L["Mining"] .. " - " .. L["The Aldor"], type = "Mining", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsFishing then
                    nodes[111][43439160] = { name = PROFESSIONS_FISHING .. " - " .. L["The Scryers"], type = "Fishing", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsHerbalism then
                    nodes[111][38807156] = { name = L["Herbalism"] .. " - " .. L["The Scryers"], type = "Herbalism", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    nodes[111][38073007] = { name = L["Herbalism"] .. " - " .. L["The Aldor"], type = "Herbalism", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsInscription then
                    nodes[111][55947403] = { name = INSCRIPTION .. " - " .. L["The Scryers"], type = "Inscription", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    nodes[111][36014345] = { name = INSCRIPTION .. " - " .. L["The Aldor"], type = "Inscription", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsEnchanting then
                    nodes[111][55417484] = { name = L["Enchanting"] .. " - " .. L["The Scryers"], type = "Enchanting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    nodes[111][43299253] = { name = L["Enchanting"] .. " - " .. L["The Scryers"], type = "Enchanting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    nodes[111][36514454] = { name = L["Enchanting"] .. " - " .. L["The Aldor"], type = "Enchanting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsArchaeology then
                    nodes[111][62667040] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsCooking then
                    nodes[111][74793084] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    nodes[111][63066835] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
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
                    nodes[125][66166745] = { id = 283, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Violet Hold
                end

                if self.db.profile.showCapitalsLFR then
                    nodes[125][63885454] = { name = L["Archmage Timear"] .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " ", id = { 875, 786, 768, 861, 946 }, type = "LFR", showInZone = true, showOnContinent = false, showOnMinimap = false }
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
                    nodes[126][25044295] = { name = "", mnID = 125, TransportName = L["Passage"] .. "\n" .. " ==> " .. DUNGEON_FLOOR_DALARAN1, type = "PathR", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[126][66484766] = { name = "", mnID = 125, TransportName = L["Passage"] .. "\n" .. " ==> " .. DUNGEON_FLOOR_DALARAN1, type = "PathLO", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[125][35294528] = { name = "", mnID = 126, TransportName = L["Passage"] .. "\n" .. " ==> " .. DUNGEON_FLOOR_DALARAN2, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[125][60294758] = { name = L["Passage"] .. " ==> " .. DUNGEON_FLOOR_DALARAN2, mnID = 126, TransportName = TRANSMOG_SET_PVP .. "" .. SLASH_EQUIP_SET1, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[125][48343243] = { name = L["Passage"] .. " ==> " .. DUNGEON_FLOOR_DALARAN2, mnID = 126, TransportName = TRANSMOG_SET_PVP .. "" .. SLASH_EQUIP_SET1, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.db.profile.showCapitalsAuctioneer then
                    nodes[125][38402502] = { name = BUTTON_LAG_AUCTIONHOUSE, type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = REQUIRES_LABEL .. " " .. L["Engineer"] }

                    if self.faction == "Horde" or db.activate.CapitalsEnemyFaction then
                        nodes[125][65522343] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = ITEM_REQ_HORDE}
                    end

                    if self.faction == "Alliance" or db.activate.CapitalsEnemyFaction then
                        nodes[125][37175488] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = ITEM_REQ_ALLIANCE}
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

                if self.db.profile.showCapitalsBarber then
                    nodes[125][51763170] = { dnID = MINIMAP_TRACKING_BARBER, name = "", type = "Barber", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.db.profile.showCapitalsTransmogger then
                    nodes[125][39294161] = { dnID = MINIMAP_TRACKING_TRANSMOGRIFIER, name = "", type = "Transmogger", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.db.profile.showCapitalsPvEVendor then
                    nodes[125][43744935] = { dnID = TRANSMOG_SET_PVE .. "" .. SLASH_EQUIP_SET1, name = "", TransportName = L["Cloth Armor"], type = "PvEVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[125][51067322] = { dnID = TRANSMOG_SET_PVE .. "" .. SLASH_EQUIP_SET1, name = "", TransportName = L["Leather Armor"] .. "\n" .. L["Heavy Armor"], type = "PvEVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[125][46362680] = { dnID = TRANSMOG_SET_PVE .. "" .. SLASH_EQUIP_SET1, name = "", TransportName = L["Heavy Armor"] .. "\n" .. L["Heavy Armor"], type = "PvEVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    
                    if self.faction == "Horde" or db.activate.CapitalsEnemyFaction then
                        nodes[125][66362219] = { dnID = L["Quartermaster"] .. " - " .. ITEM_REQ_HORDE, name = "", type = "PvEVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.faction == "Alliance" or db.activate.CapitalsEnemyFaction then
                        nodes[125][38135483] = { dnID = L["Quartermaster"] .. " - " .. ITEM_REQ_ALLIANCE, name = "", TransportName = DUNGEON_FLOOR_GILNEAS3,  type = "PvEVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                end

                if self.db.profile.showCapitalsPvPVendor then
                    nodes[126][59355799] = { dnID = TRANSMOG_SET_PVP .. "" .. SLASH_EQUIP_SET1, name = "", type = "PvPVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.db.profile.showCapitalsMailbox then
                    nodes[125][44606850] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[125][44905960] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[125][38504860] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[125][36806040] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[125][40503210] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[125][51505950] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[125][59504850] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[125][65604650] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[125][62503250] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[125][50003750] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[125][45503950] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[125][52502730] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[125][48902540] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.db.profile.showCapitalsStablemaster then
                    nodes[125][59003860] = { dnID = MINIMAP_TRACKING_STABLEMASTER, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

            end

        --Transports Dalaran Northrend
            if self.db.profile.activate.CapitalsTransporting then
    
                if self.db.profile.showCapitalsPortals then
                    nodes[125][55904678] = { mnID = 127, name = L["Portal"], type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false } 

                    if self.faction == "Horde" or db.activate.CapitalsEnemyFaction then
                        nodes[125][55322545] = { mnID = 85, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. ORGRIMMAR } -- Dalaran to Orgrimmar Portal 
                    end

                    if self.faction == "Alliance" or db.activate.CapitalsEnemyFaction then
                        nodes[125][40016276] = { mnID = 84,  name = "" , type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. STORMWIND } -- Dalaran to Stormwind City Portal
                    end
                end

                if self.db.profile.showCapitalsFP then
                    nodes[125][72164583] = { name = MINIMAP_TRACKING_FLIGHTMASTER, type = "TravelL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

            end

        --Professions Dalaran Northrend
            if self.db.profile.activate.CapitalsProfessions then

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

    --######################
    --### Dalaran Legion ###
    --######################
        if self.db.profile.showCapitalsDalaranLegion then

        --Instance Dalaran Legion
            if self.db.profile.activate.CapitalsInstances then

                if self.db.profile.showCapitalsDungeons then
                    nodes[627][65576738] = { id = 777, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Assault on Violet Hold
                end

                if self.db.profile.showCapitalsLFR then
                    nodes[627][63535488] = { name = L["Archmage Timear"] .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " ", id = { 875, 786, 768, 861, 946 }, type = "LFR", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

            end

        --General Dalaran Legion
            if self.db.profile.activate.CapitalsGeneral then
    
                if self.db.profile.showCapitalsInnkeeper then
                    nodes[627][49784006] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = true, showOnContinent = false, showOnMinimap = false }

                    if self.faction == "Horde" or db.activate.CapitalsEnemyFaction then
                        nodes[627][65443217] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, TransportName = ITEM_REQ_HORDE, type = "Innkeeper", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.faction == "Alliance" or db.activate.CapitalsEnemyFaction then
                        nodes[627][44196398] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, TransportName = ITEM_REQ_ALLIANCE, type = "Innkeeper", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                end

                if self.db.profile.showCapitalsPaths then
                    nodes[627][34664554] = { name = "", mnID = 628, TransportName = L["Passage"] .. "\n" .. " ==> " .. DUNGEON_FLOOR_DALARAN2, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[627][59714771] = { name = "", mnID = 628, TransportName = L["Passage"] .. "\n" .. " ==> " .. DUNGEON_FLOOR_DALARAN2, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[628][73076461] = { name = "", mnID = 627, TransportName = L["Passage"] .. "\n" .. " ==> " .. DUNGEON_FLOOR_DALARAN1, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[628][27815332] = { name = "", mnID = 627, TransportName = L["Passage"] .. "\n" .. " ==> " .. DUNGEON_FLOOR_DALARAN1, type = "PathL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[627][48343243] = { name = L["Passage"] .. " ==> " .. DUNGEON_FLOOR_DALARAN2, mnID = 628, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.db.profile.showCapitalsAuctioneer then
                    nodes[627][39082599] = { name = BUTTON_LAG_AUCTIONHOUSE, type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = REQUIRES_LABEL .. " " .. L["Engineer"] }
                end

                if self.db.profile.showCapitalsBank then
                    nodes[627][42708014] = { dnID = BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[627][53181526] = { dnID = BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[627][41217593] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[627][45777890] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[627][50111677] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[627][55681923] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.db.profile.showCapitalsBarber then
                    nodes[627][51763170] = { dnID = MINIMAP_TRACKING_BARBER, name = "", type = "Barber", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.db.profile.showCapitalsTransmogger then
                    nodes[627][39294161] = { dnID = MINIMAP_TRACKING_TRANSMOGRIFIER, name = "", type = "Transmogger", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.db.profile.showCapitalsPvEVendor then
                    nodes[627][37635617] = { dnID = TRANSMOG_SET_PVE .. "" .. SLASH_EQUIP_SET1, name = "", TransportName = L["Cloth Armor"], type = "PvEVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[627][51067322] = { dnID = TRANSMOG_SET_PVE .. "" .. SLASH_EQUIP_SET1, name = "", TransportName = L["Leather Armor"] .. "\n" .. L["Heavy Armor"], type = "PvEVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.db.profile.showCapitalsMailbox then
                    nodes[627][44606850] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[627][44905960] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[627][38504860] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[627][36806040] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[627][40503210] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[627][51505950] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[627][59504850] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[627][65604650] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[627][62503250] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[627][50003750] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[627][45503950] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[627][52502730] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[627][48902540] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.db.profile.showCapitalsStablemaster then
                    nodes[627][59003860] = { dnID = MINIMAP_TRACKING_STABLEMASTER, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

            end

        --Transports Dalaran Legion
            if self.db.profile.activate.CapitalsTransporting then
    
                if self.db.profile.showCapitalsPortals then
                    nodes[629][30798454] = { mnID = 115, name = L["Portal"], type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[629][38937972] = { mnID = 32, name = L["Portal"], type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[629][35768594] = { mnID = 70, name = L["Portal"], type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[629][28777742] = { mnID = 25, name = L["Portal"], type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[629][31947153] = { mnID = 42, name = L["Portal"], type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[629][64752082] = { mnID = 627, name = L["Portal"], type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[627][49324758] = { mnID = 629, name = L["Portal"], TransportName = DUNGEON_FLOOR_DALARAN7012, type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false }

                    if self.faction == "Horde" or db.activate.CapitalsEnemyFaction then
                        nodes[629][33557905] = { mnID = 971, name = L["Portal"], type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[627][55242392] = { mnID = 85, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. ORGRIMMAR } -- Dalaran to Orgrimmar Portal
                    end

                    if self.faction == "Alliance" or db.activate.CapitalsEnemyFaction then
                        nodes[627][40416378] = { mnID = 84,  name = "" , type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. STORMWIND } --  Dalaran to Stormwind City Portal
                    end
                end

                if self.db.profile.showCapitalsFP then
                    nodes[627][69825114] = { name = MINIMAP_TRACKING_FLIGHTMASTER, type = "TravelL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

            end

        --Professions Dalaran Legion
            if self.db.profile.activate.CapitalsProfessions then

                if self.db.profile.showCapitalsAlchemy then
                    nodes[627][42023184] = { name = L["Alchemy"], type = "Alchemy", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end
            
                if self.db.profile.showCapitalsLeatherworking then
                    nodes[627][35102936] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsEngineer then
                    nodes[627][38552459] = { name = L["Engineer"], type = "Engineer", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsSkinning then
                    nodes[627][36082796] = { name = L["Skinning"], type = "Skinning", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsTailoring then
                    nodes[627][34993457] = { name = L["Tailoring"], type = "Tailoring", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsJewelcrafting then
                    nodes[627][40043528] = { name = L["Jewelcrafting"], type = "Jewelcrafting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsBlacksmith then
                    nodes[627][45122893] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsMining then
                    nodes[627][46102579] = { name = L["Mining"], type = "Mining", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsFishing then
                    nodes[627][52776559] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsHerbalism then
                    nodes[627][42363394] = { name = L["Herbalism"], type = "Herbalism", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsInscription then
                    nodes[627][41253707] = { name = INSCRIPTION, type = "Inscription", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsEnchanting then
                    nodes[627][38294031] = { name = L["Enchanting"], type = "Enchanting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsArchaeology then
                    nodes[627][41242630] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.faction == "Horde" or db.activate.CapitalsEnemyFaction then

                    if self.db.profile.showCapitalsCooking then
                        nodes[627][69973897] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION .. "\n" .. ITEM_REQ_HORDE }
                    end

                end

                if self.faction == "Alliance" or db.activate.CapitalsEnemyFaction then

                    if self.db.profile.showCapitalsCooking then
                        nodes[627][40586680] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION .. "\n" .. ITEM_REQ_ALLIANCE }
                    end

                end

            end

        end

    --##############
    --### Oribos ###
    --##############
        if self.db.profile.showCapitalsOribos then

        --Instance oribos
            if self.db.profile.activate.CapitalsInstances then

                if self.db.profile.showCapitalsLFR then
                    nodes[1670][41377150] = { mnID = 1670, name = L["Ta'elfar"] .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " ", id = { 1190, 1193, 1195 }, type = "LFR", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

            end

        --General Oribos
            if self.db.profile.activate.CapitalsGeneral then
    
                if self.db.profile.showCapitalsInnkeeper then
                    nodes[1670][67505031] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.db.profile.showCapitalsAuctioneer then
                    nodes[1670][38374376] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = REQUIRES_LABEL .. " " .. L["Engineer"] }
                end

                if self.db.profile.showCapitalsBank then
                    nodes[1670][59502845] = { dnID = BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1670][65033569] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.db.profile.showCapitalsBarber then
                    nodes[1670][65096483] = { dnID = MINIMAP_TRACKING_BARBER, name = "", type = "Barber", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.db.profile.showCapitalsPvPVendor then
                    nodes[1670][35005833] = { dnID = TRANSMOG_SET_PVP .. "" .. SLASH_EQUIP_SET1, name = "", type = "PvPVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.db.profile.showCapitalsTransmogger then
                    nodes[1670][64416963] = { dnID = MINIMAP_TRACKING_TRANSMOGRIFIER, name = "", type = "Transmogger", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.db.profile.showCapitalsPvEVendor then
                    nodes[1670][47497544] = { dnID = L["Quartermaster"], name = "", TransportName = GARRISON_TYPE_9_0_LANDING_PAGE_TITLE,  type = "PvEVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.db.profile.showCapitalsItemUpgrade then
                    nodes[1670][34505598] = { dnID = ITEM_UPGRADE, name = "",  type = "ItemUpgrade", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.db.profile.showCapitalsMailbox then
                    nodes[1670][30505250] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1670][74004940] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1670][58503680] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1670][63505150] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.db.profile.showCapitalsStablemaster then
                    nodes[1670][59207500] = { dnID = MINIMAP_TRACKING_STABLEMASTER, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

            end

        --Transports Oribos
            if self.db.profile.activate.CapitalsTransporting then
    
                if self.db.profile.showCapitalsPortals then
                    nodes[1671][49405127] = { mnID = 1543, name = "", type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. L["The Maw"] } -- Oribos to The Maw
                    nodes[1671][30322269] = { mnID = 1961, name = "", type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. L["Korthia"] } -- Oribos to Korthia
                    nodes[1671][49532566] = { mnID = 1970, name = "", type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. L["Zereth Mortis"] } -- Oribos to Zereth Morthis

                    if self.faction == "Horde" or db.activate.CapitalsEnemyFaction then
                        nodes[1670][20805432] = { mnID = 85, name = "", type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. ORGRIMMAR } -- Oribos to Orgrimmar Portal
                    end

                    if self.faction == "Alliance" or db.activate.CapitalsEnemyFaction then
                        nodes[1670][20654625] = { mnID = 84,  name = "" , type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. STORMWIND } -- Oribos to Stormwind City Portal
                    end
                end

                if self.db.profile.showCapitalsTransport then
                    nodes[1670][47065029] = { mnID = 1671, name = "", type = "Tport2", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Transport"] .. " ==> " .. DUNGEON_FLOOR_GILNEAS3  } -- Oribos to The Maw
                    nodes[1670][52094275] = { mnID = 1671, name = "", type = "Tport2", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Transport"] .. " ==> " .. DUNGEON_FLOOR_GILNEAS3  } -- Oribos to The Maw
                    nodes[1670][57125033] = { mnID = 1671, name = "", type = "Tport2", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Transport"] .. " ==> " .. DUNGEON_FLOOR_GILNEAS3  } -- Oribos to The Maw
                    nodes[1670][52085793] = { mnID = 1671, name = "", type = "Tport2", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Transport"] .. " ==> " .. DUNGEON_FLOOR_GILNEAS3  } -- Oribos to The Maw
                    nodes[1671][55665162] = { mnID = 1670, name = "", type = "Tport2", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Transport"] .. " ==> " .. DUNGEON_FLOOR_GILNEAS2  } -- Oribos to The Maw
                    nodes[1671][49536090] = { mnID = 1670, name = "", type = "Tport2", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Transport"] .. " ==> " .. DUNGEON_FLOOR_GILNEAS2  } -- Oribos to The Maw
                    nodes[1671][43415157] = { mnID = 1670, name = "", type = "Tport2", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Transport"] .. " ==> " .. DUNGEON_FLOOR_GILNEAS2  } -- Oribos to The Maw
                    nodes[1671][49554241] = { mnID = 1670, name = "", type = "Tport2", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Transport"] .. " ==> " .. DUNGEON_FLOOR_GILNEAS2  } -- Oribos to The Maw
                end

                if self.db.profile.showCapitalsFP then
                    nodes[1671][60196756] = { name = MINIMAP_TRACKING_FLIGHTMASTER, type = "TravelL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

            end

        --Professions Oribos
            if self.db.profile.activate.CapitalsProfessions then

                if self.db.profile.showCapitalsAlchemy then
                    nodes[1670][39284044] = { name = L["Alchemy"], type = "Alchemy", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end
            
                if self.db.profile.showCapitalsLeatherworking then
                    nodes[1670][42342642] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsEngineer then
                    nodes[1670][38114472] = { name = L["Engineer"], type = "Engineer", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsSkinning then
                    nodes[1670][42072813] = { name = L["Skinning"], type = "Skinning", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsTailoring then
                    nodes[1670][45553182] = { name = L["Tailoring"], type = "Tailoring", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsJewelcrafting then
                    nodes[1670][35164127] = { name = L["Jewelcrafting"], type = "Jewelcrafting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsBlacksmith then
                    nodes[1670][40563139] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsMining then
                    nodes[1670][39313292] = { name = L["Mining"], type = "Mining", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsFishing then
                    nodes[1670][46162635] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsCooking then
                    nodes[1670][46812266] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsHerbalism then
                    nodes[1670][40303824] = { name = L["Herbalism"], type = "Herbalism", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsInscription then
                    nodes[1670][36473666] = { name = INSCRIPTION, type = "Inscription", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsEnchanting then
                    nodes[1670][48422949] = { name = L["Enchanting"], type = "Enchanting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

            end

        end

    --##################
    --### Valdrakken ###
    --##################
        if self.db.profile.showCapitalsValdrakken then

        --General Valdrakken
            if self.db.profile.activate.CapitalsGeneral then
    
                if self.db.profile.showCapitalsInnkeeper then
                    nodes[2112][47714635] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.db.profile.showCapitalsAuctioneer then
                    nodes[2112][42705981] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[2112][16705185] = { dnID = BLACK_MARKET_AUCTION_HOUSE, name = "", type = "BlackMarket", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.db.profile.showCapitalsBank then
                    nodes[2112][60325544] = { dnID = BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[2112][58275451] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.db.profile.showCapitalsBarber then
                    nodes[2112][28714859] = { dnID = MINIMAP_TRACKING_BARBER, name = "", type = "Barber", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.db.profile.showCapitalsMailbox then
                    nodes[2112][45695912] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[2112][48475136] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[2112][35555959] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[2112][14185498] = { dnID = MINIMAP_TRACKING_MAILBOX .. " " .. "(" .. HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_DOWN .. ")", name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.db.profile.showCapitalsPvPVendor then
                    nodes[2112][44083636] = { dnID = TRANSMOG_SET_PVP .. "" .. SLASH_EQUIP_SET1, name = "", type = "PvPVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.db.profile.showCapitalsTransmogger then
                    nodes[2112][74575782] = { dnID = MINIMAP_TRACKING_TRANSMOGRIFIER, name = "", type = "Transmogger", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.db.profile.showCapitalsItemUpgrade then
                    nodes[2112][45753885] = { dnID = ITEM_UPGRADE, name = "",  type = "ItemUpgrade", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[2112][45545624] = { dnID = ITEM_UPGRADE, name = "",  type = "ItemUpgrade", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.db.profile.showCapitalsDragonFlyTransmog then
                    nodes[2112][25235034] = { dnID = MINIMAP_TRACKING_TRANSMOGRIFIER .. " " .. MOUNT_JOURNAL_FILTER_DRAGONRIDING, name = "",  type = "DragonFlyTransmog", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.db.profile.showCapitalsStablemaster then
                    nodes[2112][46807880] = { dnID = MINIMAP_TRACKING_STABLEMASTER, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

            end

        --Transports Valdrakken
            if self.db.profile.activate.CapitalsTransporting then
    
                if self.db.profile.showCapitalsPortals then
                    nodes[2112][26104102] = { mnID = 15, name = "", type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. L["Badlands"] } --  Portal from Valdrakken to the Badlands
                    nodes[2112][62725732] = { mnID = 2200, name = "", type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. L["Emerald Dream"] } --  Portal from Valdrakken to The Emerald Dream

                    if self.faction == "Horde" or db.activate.CapitalsEnemyFaction then
                        nodes[2112][56593828] = { mnID = 85, name = L["(inside building)"], type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. ORGRIMMAR } -- Valdrakken to Orgrimmar Portal
                    end

                    if self.faction == "Alliance" or db.activate.CapitalsEnemyFaction then
                        nodes[2112][59804169] = { mnID = 84,  name = L["(inside building)"], type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. STORMWIND } -- Valdrakken to Stormwind City Portal
                    end
                end

                if self.db.profile.showCapitalsFP then
                    nodes[2112][44476790] = { name = MINIMAP_TRACKING_FLIGHTMASTER, type = "TravelL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

            end

        --Professions Valdrakken
            if self.db.profile.activate.CapitalsProfessions then

                if self.db.profile.showCapitalsProfessionOrders then
                    nodes[2112][34796252] = { name = PLACE_CRAFTING_ORDERS, type = "ProfessionOrders", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.db.profile.showCapitalsAlchemy then
                    nodes[2112][36417170] = { name = L["Alchemy"], type = "Alchemy", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end
            
                if self.db.profile.showCapitalsLeatherworking then
                    nodes[2112][28616157] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsEngineer then
                    nodes[2112][42254861] = { name = L["Engineer"], type = "Engineer", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsSkinning then
                    nodes[2112][28606008] = { name = L["Skinning"], type = "Skinning", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsTailoring then
                    nodes[2112][32026629] = { name = L["Tailoring"], type = "Tailoring", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsJewelcrafting then
                    nodes[2112][40486141] = { name = L["Jewelcrafting"], type = "Jewelcrafting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsBlacksmith then
                    nodes[2112][36864659] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsMining then
                    nodes[2112][38885143] = { name = L["Mining"], type = "Mining", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsFishing then
                    nodes[2112][44847471] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsCooking then
                    nodes[2112][46494625] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsHerbalism then
                    nodes[2112][337626892] = { name = L["Herbalism"], type = "Herbalism", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsInscription then
                    nodes[2112][38847338] = { name = INSCRIPTION, type = "Inscription", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsEnchanting then
                    nodes[2112][31076137] = { name = L["Enchanting"], type = "Enchanting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

            end

        end

    --################
    --### Darkmoon ###
    --################
        if self.db.profile.showCapitalsDarkmoon then

        --General Darkmoon
            if self.db.profile.activate.CapitalsGeneral then
    
                if self.db.profile.showCapitalsPvEVendor then
                    nodes[407][48246955] = { dnID = TRANSMOG_SET_PVE .. " " .. MERCHANT, name = "", TransportName = ACCESSIBILITY_MOUNT_LABEL .. "\n" .. PERKS_VENDOR_CATEGORY_PET,  type = "PvEVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[407][51447510] = { dnID = TRANSMOG_SET_PVE .. " " .. MERCHANT, name = "", TransportName = PERKS_VENDOR_CATEGORY_TRANSMOG_SET,  type = "PvEVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[407][48096567] = { dnID = TRANSMOG_SET_PVE .. " " .. MERCHANT, name = "", TransportName = HEIRLOOMS .. "\n" ..  BAG_FILTER_EQUIPMENT .. "\n" .. TOY,  type = "PvEVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

            end

        --Transports Darkmoon
            if self.db.profile.activate.CapitalsTransporting then

                if self.db.profile.showCapitalsPortals then

                    if db.activate.CapitalsEnemyFaction then
                        nodes[407][51412247] = { name = L["Exit"], type = "Portal", mnID = 7, mnID2 = 37, showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = FACTION_HORDE .. " ==> " .. DUNGEON_FLOOR_NIGHTMARERAID3 .. "\n" .. FACTION_ALLIANCE .. " ==> " .. POSTMASTER_LETTER_ELWYNNFOREST }
                        nodes[407][50549077] = { name = L["Exit"], type = "Portal", mnID = 7, mnID2 = 37, showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = FACTION_HORDE .. " ==> " .. DUNGEON_FLOOR_NIGHTMARERAID3 .. "\n" .. FACTION_ALLIANCE .. " ==> " .. POSTMASTER_LETTER_ELWYNNFOREST }
                    end
                
                    if self.faction == "Horde" and not db.activate.CapitalsEnemyFaction then
                        nodes[407][51412247] = { mnID = 7, name = L["Portal"], type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[407][50549077] = { mnID = 7, name = L["Portal"], type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                    if self.faction == "Alliance" and not db.activate.CapitalsEnemyFaction then
                        nodes[407][51412247] = { mnID = 37, name = L["Portal"], type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false }
                        nodes[407][50549077] = { mnID = 37, name = L["Portal"], type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    end

                end

            end

        --Professions Darkmoon
            if self.db.profile.activate.CapitalsProfessions then

                if self.db.profile.showCapitalsAlchemy then
                    nodes[407][50206940] = { name = L["Alchemy"], type = "Alchemy", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = TUTORIAL_TITLE1 }
                end
            
                if self.db.profile.showCapitalsLeatherworking then
                    nodes[407][49406080] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = TUTORIAL_TITLE1 }
                end

                if self.db.profile.showCapitalsEngineer then
                    nodes[407][49406081] = { name = L["Engineer"], type = "Engineer", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = TUTORIAL_TITLE1 }
                end

                if self.db.profile.showCapitalsSkinning then
                    nodes[407][48197805] = { name = L["Skinning"], type = "Skinning", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = TUTORIAL_TITLE1 }
                end

                if self.db.profile.showCapitalsTailoring then
                    nodes[407][55805440] = { name = L["Tailoring"], type = "Tailoring", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = TUTORIAL_TITLE1 }
                end

                if self.db.profile.showCapitalsJewelcrafting then
                    nodes[407][55007060] = { name = L["Jewelcrafting"], type = "Jewelcrafting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = TUTORIAL_TITLE1 }
                end

                if self.db.profile.showCapitalsBlacksmith then
                    nodes[407][51008180] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = TUTORIAL_TITLE1 }
                end

                if self.db.profile.showCapitalsMining then
                    nodes[407][49446141] = { name = L["Mining"], type = "Mining", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = TUTORIAL_TITLE1 }
                end

                if self.db.profile.showCapitalsFishing then
                    nodes[407][52608860] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    nodes[407][52606800] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = TUTORIAL_TITLE1 }
                end

                if self.db.profile.showCapitalsCooking then
                    nodes[407][52606800] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = TUTORIAL_TITLE1 }
                end

                if self.db.profile.showCapitalsHerbalism then
                    nodes[407][55017052] = { name = L["Herbalism"], type = "Herbalism", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = TUTORIAL_TITLE1 }
                end

                if self.db.profile.showCapitalsInscription then
                    nodes[407][53007580] = { name = INSCRIPTION, type = "Inscription", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = TUTORIAL_TITLE1 }
                end

                if self.db.profile.showCapitalsEnchanting then
                    nodes[407][53007580] = { name = L["Enchanting"], type = "Enchanting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = TUTORIAL_TITLE1 }
                end

                if self.db.profile.showCapitalsArchaeology then
                    nodes[407][51836072] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = TUTORIAL_TITLE1 }
                end

            end

        end

    --################
    --### Dornogal ###
    --################
        if self.db.profile.showCapitalsDornogal then

        --Instances Orgrimmar
            if self.db.profile.activate.CapitalsInstances then

                if self.db.profile.showCapitalsDungeons then
                    nodes[2339][31893565] = { id = 1268, type = "Dungeon", showInZone = true, showOnContinent = false, showOnMinimap = false } -- The Rookery
                end

            end

        --General Dornogal
            if self.db.profile.activate.CapitalsGeneral then

                if self.db.profile.showCapitalsPaths then
                    nodes[2339][81782819] = { dnID = L["Exit"], name = "", mnID = 2248, type = "PathR", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit 
                    nodes[2339][68588953] = { dnID = L["Exit"], name = "", mnID = 2248, type = "PathRU", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit
                    nodes[2339][35875875] = { dnID = L["Passage"], name = "", mnID = 2214, type = "PathU", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Passage/Exit
                end
    
                if self.db.profile.showCapitalsInnkeeper then
                    nodes[2339][44754642] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.db.profile.showCapitalsAuctioneer then
                    nodes[2339][56864704] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[2339][64445211] = { dnID = BLACK_MARKET_AUCTION_HOUSE, name = "", type = "BlackMarket", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.db.profile.showCapitalsBank then
                    nodes[2339][52924479] = { dnID = BANK .. " / " .. GUILD_BANK , name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.db.profile.showCapitalsBarber then
                    nodes[2339][58645176] = { dnID = MINIMAP_TRACKING_BARBER, name = "", type = "Barber", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.db.profile.showCapitalsMailbox then
                    nodes[2339][45384833] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[2339][51584595] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[2339][55645000] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.db.profile.showCapitalsPvPVendor then
                    nodes[2339][60377017] = { dnID = TRANSMOG_SET_PVP .. " " .. MERCHANT, name = "", TransportName = PVP_LABEL_WAR_MODE, type = "PvPVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[2339][59696906] = { dnID = TRANSMOG_SET_PVP .. " " .. MERCHANT, name = "", TransportName = ELITE .. " " .. L["Quartermaster"],  type = "PvPVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[2339][55677618] = { dnID = TRANSMOG_SET_PVP .. " " .. MERCHANT, name = "", TransportName = PVP_LABEL_WAR_MODE .. " " .. L["Quartermaster"] .. "\n" .. HONOR_POINTS .. " " .. L["Quartermaster"] .. "\n" .. HONOR_POINTS .. " " .. AUCTION_CATEGORY_RECIPES,  type = "PvPVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.db.profile.showCapitalsPvEVendor then
                    nodes[2339][39092418] = { dnID = L["Merchant for Renown items"], name = "", type = "PvEVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    --nodes[2339][39092418] = { dnID = L["Merchant for Renown items"], name = "", TransportName = L["Council of Dornogal"] .. "\n" .. L["The Assembly of the Deeps"] .. "\n" .. L["Hallowfall Arathi"], type = "PvEVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[2339][47834448] = { dnID = TRANSMOG_SET_PVE .. " " .. MERCHANT, name = "", TransportName = L["Quartermaster"],  type = "PvEVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.db.profile.showCapitalsTransmogger then
                    nodes[2339][45835331] = { dnID = MINIMAP_TRACKING_TRANSMOGRIFIER, name = "", TransportName = MERCHANT, type = "Transmogger", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[2339][58644933] = { dnID = MINIMAP_TRACKING_TRANSMOGRIFIER, name = "", type = "Transmogger", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.db.profile.showCapitalsItemUpgrade then
                    nodes[2339][59627029] = { dnID = ITEM_UPGRADE, name = "",  type = "ItemUpgrade", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[2339][51944206] = { dnID = ITEM_UPGRADE, name = "",  type = "ItemUpgrade", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.db.profile.showCapitalsDragonFlyTransmog then
                    nodes[2339][47996786] = { dnID = MINIMAP_TRACKING_TRANSMOGRIFIER .. " " .. MOUNT_JOURNAL_FILTER_DRAGONRIDING, name = "",  type = "DragonFlyTransmog", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.db.profile.showCapitalsCatalyst then
                    nodes[2339][50005430] = { dnID = L["Catalyst"], name = "",  type = "Catalyst", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

            end

        --Transports Dornogal
            if self.db.profile.activate.CapitalsTransporting then
    
                if self.db.profile.showCapitalsPortals then
                    nodes[2266][43564994] = { mnID = 2339, name = "", type = "Portal", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. L["Dornogal"] } --  Timeways Portal to Vashj'ir
                    nodes[2266][64534340] = { name = "", type = "WayGateGolden", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. UNKNOWN } --  Timeways Portal to Vashj'ir
                    nodes[2266][74524703] = { name = "", type = "WayGateGolden", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. UNKNOWN } --  Timeways Portal to Gorgrond
                    nodes[2266][77536180] = { name = "", type = "WayGateGolden", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. UNKNOWN } --  Timeways Portal to Val'sharah
                    nodes[2266][70537306] = { name = "", type = "WayGateGolden", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. UNKNOWN } --  Timeways Portal to Zuldazar
                    nodes[2266][60506950] = { name = "", type = "WayGateGolden", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Portal"] .. " ==> " .. UNKNOWN } --  Timeways Portal to Drustvar
                    nodes[2339][51194334] = { mnID = 2266, name = "", type = "WayGateGolden", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["The Timeways"] .. " " .. L["Portals"] .. "\n" .. "\n" .. " ==> " .. UNKNOWN .. "\n" .. " ==> " .. UNKNOWN .. "\n" .. " ==> " .. UNKNOWN .. "\n" .. " ==> " .. UNKNOWN .. "\n" .. " ==> " .. UNKNOWN } --  Portal from Valdrakken to the Timeways

                    if self.faction == "Horde" or db.activate.CapitalsEnemyFaction then
                        nodes[2339][38192724] = { mnID = 85, name = L["Portal"], type = "HPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Dornogal to Orgrimmar
                    end

                    if self.faction == "Alliance" or db.activate.CapitalsEnemyFaction then
                        nodes[2339][41162271] = { mnID = 84, name = L["Portal"], type = "APortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Dornogal to Stormwind
                    end
                end

                if self.db.profile.showCapitalsTransport then
                    nodes[2339][40722239] = { mnID = 2339, name = "", type = "Tport2", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = L["Transport"] .. " ==> " .. L["(on the tower)"]  } -- Oribos to The Maw
                end

                if self.db.profile.showCapitalsFP then
                    nodes[2339][44695114] = { name = MINIMAP_TRACKING_FLIGHTMASTER, type = "TravelL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

            end

        --Professions Dornogal
            if self.db.profile.activate.CapitalsProfessions then

                if self.db.profile.showCapitalsProfessionOrders then
                    nodes[2339][58015644] = { name = PLACE_CRAFTING_ORDERS, type = "ProfessionOrders", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.db.profile.showCapitalsAlchemy then
                    nodes[2339][47367039] = { name = L["Alchemy"], type = "Alchemy", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end
            
                if self.db.profile.showCapitalsLeatherworking then
                    nodes[2339][54455884] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsEngineer then
                    nodes[2339][49215630] = { name = L["Engineer"], type = "Engineer", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsSkinning then
                    nodes[2339][54435714] = { name = L["Skinning"], type = "Skinning", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsTailoring then
                    nodes[2339][54786364] = { name = L["Tailoring"], type = "Tailoring", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsJewelcrafting then
                    nodes[2339][49827116] = { name = L["Jewelcrafting"], type = "Jewelcrafting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsBlacksmith then
                    nodes[2339][49286338] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsMining then
                    nodes[2339][52635272] = { name = L["Mining"], type = "Mining", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsFishing then
                    nodes[2339][50542691] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsCooking then
                    nodes[2339][44084575] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsHerbalism then
                    nodes[2339][45696965] = { name = L["Herbalism"], type = "Herbalism", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsInscription then
                    nodes[2339][48757117] = { name = INSCRIPTION, type = "Inscription", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showCapitalsEnchanting then
                    nodes[2339][52817116] = { name = L["Enchanting"], type = "Enchanting", showInZone = true, showOnContinent = false, showOnMinimap = false, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

            end

        end

    end
end
end