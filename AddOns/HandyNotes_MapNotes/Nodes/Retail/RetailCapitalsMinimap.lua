local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

function ns.LoadMinimapCapitalsLocationinfo(self)
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
                        minimap[85][55684575] = { name = L["Alchemy"], type = "Alchemy", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                
                    if self.db.profile.showMinimapCapitalsLeatherworking then
                        minimap[85][60595535] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsEngineer then
                        minimap[85][57105622] = { name = L["Engineer"], type = "Engineer", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        minimap[85][37058474] = { name = L["Engineer"], type = "Engineer", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsSkinning then
                        minimap[85][61385421] = { name = L["Skinning"], type = "Skinning", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        minimap[85][39614985] = { name = L["Skinning"], type = "Skinning", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsTailoring then
                        minimap[85][60755912] = { name = L["Tailoring"], type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        minimap[85][38865090] = { name = L["Tailoring"], type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        minimap[85][38228718] = { name = L["Tailoring"], type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsJewelcrafting then
                        minimap[85][72673406] = { name = L["Jewelcrafting"], type = "Jewelcrafting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsBlacksmith then
                        minimap[85][76533451] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        minimap[85][75353400] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        minimap[85][76373707] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        minimap[85][40735007] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        minimap[85][44237719] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsMining then
                        minimap[85][39058556] = { name = L["Mining"], type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        minimap[85][44547839] = { name = L["Mining"], type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        minimap[85][72343537] = { name = L["Mining"], type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsFishing then
                        minimap[85][66434193] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        minimap[85][35196733] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsCooking then
                        minimap[85][56376139] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        minimap[85][41147895] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        minimap[85][32256966] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsArchaeology then
                        minimap[85][49277069] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsHerbalism then
                        minimap[85][54895027] = { name = L["Herbalism"], type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        minimap[85][34836286] = { name = L["Herbalism"], type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        minimap[85][40178060] = { name = L["Herbalism"], type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsEnchanting then
                        minimap[85][53404929] = { name = L["Enchanting"], type = "Enchanting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsInscription then
                        minimap[85][55115586] = { name = INSCRIPTION, type = "Inscription", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                end

            --Transports Orgrimmar
                if self.db.profile.activate.MinimapCapitalsTransporting then

                    if self.db.profile.showMinimapCapitalsPortals then
                        minimap[85][50765561] = { mnID = 18, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Ruins of Lordaeron"] } -- Ruins of Lordaeron 
                        minimap[85][55988822] = { mnID = 110, name = "", type = "HPortalS", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Silvermoon City"] } -- Silvermoon City
                        minimap[85][57098737] = { mnID = 2112, name = "", type = "HPortalS", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Valdrakken"] } --  Valdrakken 
                        minimap[85][58308788] = { mnID = 1670, name = "", type = "HPortalS", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Oribos"] } -- Oribos 
                        minimap[85][58858950] = { mnID = 630, name = "", type = "HPortalS", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Azsuna"] } -- Azsuna 
                        minimap[85][57479217] = { mnID = 862, name = "", type = "HPortalS", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Zuldazar"] } -- Zuldazar  
                        minimap[85][57479225] = { mnID = 371, name = "", type = "HPortalS", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Jade Forest"] } -- The Jade Forest 
                        minimap[85][56219180] = { mnID = 125, name = "", type = "HPortalS", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. DUNGEON_FLOOR_DALARANCITY1 .. " - " .. POSTMASTER_PIPE_NORTHREND} -- Crystalsong Forest (Old Dalaran) Portalroom 
                        minimap[85][57409153] = { mnID = 111, name = L["Shattrath City"], TransportName = L["in the basement"], type = "HPortalS", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Shattrath 
                        minimap[85][57179070] = { mnID = 17, name = "", TransportName = L["The Dark Portal"] .. "\n" .. "( " .. L["talk to"] .. ": " .. L["Thrallmar Mage"] .. " )" .. "\n" ..L["in the basement"], type = "HPortalS", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Blasted Lands
                        minimap[85][56399252] = { mnID = 74, name = DUNGEON_FLOOR_TANARIS18, TransportName = L["in the basement"], type = "HPortalS", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Caverns of Time 
                        minimap[85][55209201] = { mnID = 624, name = L["Warspear"], TransportName = L["in the basement"], type = "HPortalS", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Warspear - Ashran 
                        minimap[85][57878985] = { mnID = 2339, name = L["Dornogal"], TransportName = L["in the basement"], type = "HPortalS", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dornogal
                        minimap[85][47393928] = { mnID = 245, name = "", type = "HPortalS", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. DUNGEON_FLOOR_TOLBARADWARLOCKSCENARIO0 } --  Portal to Tol Barad
                        minimap[85][48863851] = { mnID = 1527, name = "", type = "HPortalS", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Uldum"] } -- Portal to Uldum
                        minimap[85][50243944] = { mnID = 241, name = "", type = "HPortalS", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Twilight Highlands"] } -- Portal to Twilight Highlands
                        minimap[85][51203832] = { mnID = 198, name = "", type = "HPortalS", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. POSTMASTER_LETTER_HYJAL } -- Portal to Hyjal
                        minimap[85][50863628] = { mnID = 207, name = "", type = "HPortalS", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. ARTIFACT_SHAMAN_TITLECARD_DEEPHOLM } -- Portal to Deepholm
                        minimap[85][49203647] = { mnID = 203, name = "", type = "HPortalS", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Vashj'ir"] } -- Portal to Vashjir
                        minimap[85][48236216] = { mnID = 407, name = "", Transportname = L["Transport"] .. " ==> " .. CALENDAR_FILTER_DARKMOON, TransportName = "\n" .. REQUIRES_LABEL .. " " .. CALENDAR_FILTER_DARKMOON .. "\n" .. L["Starting on the first Sunday of each month for one week"], type = "DarkMoon", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][38607586] = { mnID = 680, name = "", type = "HPortalS", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. DUNGEON_FLOOR_SURAMARRAID3 } -- Portal to Night Fortress
                        minimap[85][38167527] = { mnID = 652, name = "", type = "HPortalS", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. POSTMASTER_LETTER_THUNDERTOTEM } -- Portal to Night Fortress
                        minimap[85][37437619] = { mnID = 2322, name = L["Portal"], dnID = "", type = "HPortalS", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hall of Awakening
                    end

                    if self.db.profile.showMinimapCapitalsZeppelins then
                        minimap[85][44496228] = { mnID = 114, name = "", type = "HZeppelin", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Zeppelin"] .. " ==> " .. POSTMASTER_LETTER_WARSONGHOLD } -- Zeppelin from OG to Borean Tundra - Northrend
                        minimap[85][42796534] = { mnID = 88, name = "", type = "HZeppelin", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Zeppelin"] .. " ==> " ..  L["Thunder Bluff"]} -- Zeppelin from OG to Thunder Bluff
                        minimap[85][52275315] = { mnID = 50, name = "", type = "HZeppelin", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Zeppelin"] .. " ==> " .. L["Grom'gol, Stranglethorn Vale"] } -- Zeppelin from OG to Stranglethorn
                    end

                    if self.db.profile.showMinimapCapitalsFP then
                        minimap[85][49705919] = { name = MINIMAP_TRACKING_FLIGHTMASTER, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end
    
                end
    
            --Instances Orgrimmar
                if self.db.profile.activate.MinimapCapitalsInstances then
    
                    if self.db.profile.showMinimapCapitalsDungeons then
                        minimap[86][66715154] = { id = 226, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ragefire - Chasm of shadows
                    end

                    if self.db.profile.showMinimapCapitalsDungeons and db.activate.ClassicIcons then
                        minimap[85][51685850] = { id = 226, TransportName = L["in the basement"], type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ragefire
                    end

                    if self.db.profile.showMinimapCapitalsInstancePassage and not db.activate.ClassicIcons then
                       minimap[85][55895097] = { mnID = 86, id = 226, TransportName = L["Way to the Instance Entrance"], name = "", type = "PassageDungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ragefire   
                       minimap[85][46116716] = { mnID = 86, id = 226, TransportName = L["Way to the Instance Entrance"], name = "", type = "PassageDungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ragefire  
                       minimap[85][42396160] = { mnID = 86, id = 226, TransportName = L["Way to the Instance Entrance"], name = "", type = "PassageDungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ragefire    
                    end

                end

            --General Orgrimmar
                if self.db.profile.activate.MinimapCapitalsGeneral then
    
                    if self.db.profile.showMinimapCapitalsPaths then
                        minimap[85][70583097] = { dnID = L["Entrance"], mnID = 503, name = "", type = "PathRO", showInZone = false, showOnContinent = false, showOnMinimap = true} -- Portal to Shlae'gararena
                        minimap[503][57431229] = { dnID = L["Exit"], mnID = 85, name = "", type = "PathRO", showInZone = false, showOnContinent = false, showOnMinimap = true} -- Portal to Shlae'gararena
                        minimap[85][74800606] = { dnID = L["Exit"], name = "", mnID = 76, type = "PathRO", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                        minimap[85][49529373] = { dnID = L["Exit"], name = "", mnID = 1, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                        minimap[85][20187080] = { dnID = L["Exit"], name = "", mnID = 10, type = "PathLU", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                        minimap[86][78691478] = { dnID = L["Passage"], name = "", mnID = 85, type = "PathR", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                        minimap[86][34209104] = { dnID = L["Passage"], name = "", mnID = 85, type = "PathRU", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                        minimap[86][22856905] = { dnID = L["Passage"], name = "", mnID = 85, type = "PathLO", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                    end

                    if self.db.profile.showMinimapCapitalsInnkeeper then
                        minimap[85][53637877] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][41068007] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][38854865] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][71304995] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsAuctioneer then
                        minimap[85][53957324] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][35847732] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][41674889] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][66623629] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsBank then
                        minimap[85][48748348] = { dnID = BANK .. "\n" .. GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][67615218] = { dnID = BANK .. "\n" .. GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][40104599] = { dnID = BANK .. "\n" .. GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsMapNotes then
                        minimap[85][32916483] = { dnID = MINIMAP_TRACKING_INNKEEPER .. "\n" .. BANK .. "\n" .. BUTTON_LAG_AUCTIONHOUSE .. "\n" .. MINIMAP_TRACKING_MAILBOX .. "\n" .. MINIMAP_TRACKING_STABLEMASTER, name = "", type = "MNL", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsBarber then
                        minimap[85][40336058] = { dnID = MINIMAP_TRACKING_BARBER, name = "", type = "Barber", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsMailbox then
                        minimap[85][49278068] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][50367592] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][52727586] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][41777162] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][36316510] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][60105098] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][58555961] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][67384961] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][67713926] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][73613717] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][51354799] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][39764848] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][49654161] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][71101160] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][67603030] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][65403130] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][55905180] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][45006830] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][42106050] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsPvPVendor then
                        minimap[85][38347131] = { dnID = TRANSMOG_SET_PVP .. " " .. MERCHANT, name = "", type = "PvPVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsTransmogger then
                        minimap[85][58116545] = { dnID = MINIMAP_TRACKING_TRANSMOGRIFIER, name = "", type = "Transmogger", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsPvEVendor then
                        minimap[85][48037056] = { dnID = TRANSMOG_SET_PVE .. " " .. MERCHANT, name = "", TransportName = L["(on the tower)"],  type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsStablemaster then
                        --minimap[85][40808060] = { dnID = MINIMAP_TRACKING_STABLEMASTER, name = "", type = "StablemasterN", showInZone = false, showOnContinent = false, showOnMinimap = true } stablemaster replaced to Herbalism??
                        --minimap[85][32606480] = { dnID = MINIMAP_TRACKING_STABLEMASTER, name = "", type = "StablemasterN", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][39604840] = { dnID = MINIMAP_TRACKING_STABLEMASTER, name = "", type = "StablemasterN", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][62403560] = { dnID = MINIMAP_TRACKING_STABLEMASTER, name = "", type = "StablemasterN", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsTradingPost then
                        minimap[85][48717601] = { dnID = BATTLE_PET_SOURCE_12, name = "",  type = "TradingPost", showInZone = false, showOnContinent = false, showOnMinimap = true }
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

                    if self.db.profileshowMinimapCapitalsBlacksmith then
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
                        minimap[88][45293847] = { name = L["Enchanting"], type = "Enchanting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsInscription then
                        minimap[88][28812071] = { name = INSCRIPTION, type = "Inscription", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        minimap[88][30323012] = { name = L["Passage"] .. " " .. MINIMAP_TRACKING_TRAINER_PROFESSION, type = "PassageLeftL", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName =  INSCRIPTION }
                    end

                end

            --Transports Thunder Bluff
                if self.db.profile.activate.MinimapCapitalsTransporting then
  
                    if self.db.profile.showMinimapCapitalsZeppelins then
                        minimap[88][14292570] = { mnID = 85, name = "", type = "HZeppelin", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Zeppelin"] .. " ==> " .. ORGRIMMAR } -- Zeppelin from Thunder Bluff to OG
                    end

                    if self.db.profile.showMinimapCapitalsFP then
                        minimap[88][46654989] = { name = MINIMAP_TRACKING_FLIGHTMASTER, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end

            --General Thunder Bluff
                if self.db.profile.activate.MinimapCapitalsGeneral then
    
                    if self.db.profile.showMinimapCapitalsPaths then
                        minimap[88][52232561] = { dnID = L["Exit"], name = "", mnID = 7, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[88][54632715] = { dnID = L["Exit"], name = "", mnID = 7, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[88][31716595] = { dnID = L["Exit"], name = "", mnID = 7, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[88][31236257] = { dnID = L["Exit"], name = "", mnID = 7, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsInnkeeper then
                        minimap[88][45856477] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper",  showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsAuctioneer then
                        minimap[88][38875023] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer",  showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[88][40435169] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer",  showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsBank then
                        minimap[88][47175862] = { dnID = BANK, name = "", type = "Bank",  showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsMailbox then
                        minimap[88][45505950] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsStablemaster then
                        minimap[88][45006000] = { dnID = MINIMAP_TRACKING_STABLEMASTER, name = "", type = "StablemasterN", showInZone = false, showOnContinent = false, showOnMinimap = true }
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

                    if self.db.profileshowMinimapCapitalsBlacksmith then
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
                        minimap[110][58511859] = { mnID = 85, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. ORGRIMMAR } -- Portal to Orgrimmar from Silvermoon 
                        minimap[110][49491509] = { mnID = 18, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Ruins of Lordaeron"] } -- Portal to Undercity from Silvermoon 
                    end

                    if self.db.profile.showMinimapCapitalsFP then
                        minimap[110][63159649] = { name = MINIMAP_TRACKING_FLIGHTMASTER, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true }
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
                        minimap[110][92735828] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[110][60726258] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsBank then
                        minimap[110][89714509] = { dnID = BANK .. "\n" .. GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[110][65807788] = { dnID = BANK .. "\n" .. GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsMailbox then
                        minimap[110][58906150] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[110][65705420] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[110][67902950] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[110][75005460] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[110][82604290] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[110][88205040] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[110][83006220] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[110][83206540] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[110][71607550] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[110][71607980] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsStablemaster then
                        minimap[110][83403040] = { dnID = MINIMAP_TRACKING_STABLEMASTER, name = "", type = "StablemasterN", showInZone = false, showOnContinent = false, showOnMinimap = true }
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
                        minimap[90][47757332] = { name = L["Alchemy"], type = "Alchemy", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        minimap[90][52947737] = { name = L["Passage"] .. " " .. MINIMAP_TRACKING_TRAINER_PROFESSION, type = "PassageLeftL", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName =  L["Alchemy"] }
                        minimap[90][44626639] = { name = L["Passage"] .. " " .. MINIMAP_TRACKING_TRAINER_PROFESSION, type = "PassageLeftL", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName =  L["Alchemy"] }
                    end
                
                    if self.db.profile.showMinimapCapitalsLeatherworking then
                        minimap[90][70155740] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsEngineer then
                        minimap[90][76107409] = { name = L["Engineer"], type = "Engineer", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsSkinning then
                        minimap[90][70165922] = { name = L["Skinning"], type = "Skinning", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsTailoring then
                        minimap[90][70763072] = { name = L["Tailoring"], type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsJewelcrafting then
                        minimap[90][56503630] = { name = L["Jewelcrafting"], type = "Jewelcrafting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profileshowMinimapCapitalsBlacksmith then
                        minimap[90][61313061] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsMining then
                        minimap[90][56043744] = { name = L["Mining"], type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsFishing then
                        minimap[90][80693124] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsCooking then
                        minimap[90][62194489] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsArchaeology then
                        minimap[90][75403772] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsHerbalism then
                        minimap[90][54014961] = { name = L["Herbalism"], type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsInscription then
                        minimap[90][61065801] = { name = INSCRIPTION, type = "Inscription", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsEnchanting then
                        minimap[90][61866139] = { name = L["Enchanting"], type = "Enchanting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                end

            --Transports Undercity
                if self.db.profile.activate.MinimapCapitalsTransporting then

                    if self.db.profile.showMinimapCapitalsPortals then
                        minimap[90][85181711] = { mnID = 100, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal from Old Undercity to Hellfire
                    end

                    if self.db.profile.showMinimapCapitalsFP then
                        minimap[90][63084832] = { name = MINIMAP_TRACKING_FLIGHTMASTER, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end

            --General Undercity
                if self.db.profile.activate.MinimapCapitalsGeneral then
    
                    if self.db.profile.showMinimapCapitalsPaths then
                        minimap[90][15003101] = { dnID = L["Exit"], name = "", mnID = 18, type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                        minimap[90][46474406] = { dnID = L["Exit"], name = "", mnID = 18, type = "PathL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                        minimap[90][66110384] = { dnID = L["Exit"] .. " " .. DUNGEON_FLOOR_GILNEAS3, name = "", mnID = 18, type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                        minimap[90][49792975] = { dnID = L["Exit"], name = "", mnID = 18, type = "PathL", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = REQUIRES_LABEL .. " " .. MOUNT_JOURNAL_FILTER_FLYING } -- Passage/Exit 
                        minimap[90][65865202] = { dnID = DUNGEON_FLOOR_GILNEAS3 .. " ==> " .. DUNGEON_FLOOR_GILNEAS2 .. "\n" ..  DUNGEON_FLOOR_GILNEAS2 .. " ==> " .. DUNGEON_FLOOR_GILNEAS3, name = "", type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                        minimap[90][60584399] = { dnID = DUNGEON_FLOOR_GILNEAS3 .. " ==> " .. DUNGEON_FLOOR_GILNEAS2 .. "\n" ..  DUNGEON_FLOOR_GILNEAS2 .. " ==> " .. DUNGEON_FLOOR_GILNEAS3, name = "", type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                        minimap[90][71294410] = { dnID = DUNGEON_FLOOR_GILNEAS3 .. " ==> " .. DUNGEON_FLOOR_GILNEAS2 .. "\n" ..  DUNGEON_FLOOR_GILNEAS2 .. " ==> " .. DUNGEON_FLOOR_GILNEAS3, name = "", type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                    end

                    if self.db.profile.showMinimapCapitalsInnkeeper then
                        minimap[90][67743784] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsAuctioneer then
                        minimap[90][60534156] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[90][64363583] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[90][67663591] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[90][71494189] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[90][71394672] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[90][67545239] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[90][64415242] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[90][60494647] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsBank then
                        minimap[90][66014406] = { dnID = BANK .. "\n" .. GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsBarber then
                        minimap[90][70004653] = { dnID = MINIMAP_TRACKING_BARBER, name = "", type = "Barber", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsPvEVendor then
                        minimap[90][78207564] = { dnID = TRANSMOG_SET_PVE .. " " .. MERCHANT, name = "", TransportName = HEIRLOOMS,  type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end   

                    if self.db.profile.showMinimapCapitalsMailbox then
                        minimap[90][71706150] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[90][62605150] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[90][62603640] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[90][69703600] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[90][69905150] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[90][66505000] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[90][68003850] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsStablemaster then
                        minimap[90][67603800] = { dnID = MINIMAP_TRACKING_STABLEMASTER, name = "", type = "StablemasterN", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end

            end

        end

    --################
    --### Warspear ###
    --################
        if self.db.profile.showMinimapCapitalsWarspear then

        --#############################
        --### Horde or EnemyFaction ###
        --#############################w
            if self.faction == "Horde" or db.activate.MinimapCapitalsEnemyFaction then

            --Instance Warspear / Garrison
                if self.db.profileshowMinimapCapitalsInstances then
    
                    if self.db.profileshowMinimapCapitalsLFR then
                        minimap[590][41364698] = { mnID = 590, name = L["Seer Kazal"] .. " - " .. REQUIRES_LABEL .. " " .. GARRISON_LOCATION_TOOLTIP .. " " .. LEVEL .. " " .. ACTION_SPELL_CAST_START_MASTER .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " ", id = { 477, 457, 669 }, type = "LFR", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end
    
                end

            --Professions Warspear
                if self.db.profile.activate.MinimapCapitalsProfessions then

                    if self.db.profile.showMinimapCapitalsAlchemy then
                        minimap[624][60832652] = { name = L["Alchemy"], type = "Alchemy", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                
                    if self.db.profile.showMinimapCapitalsLeatherworking then
                        minimap[624][49532786] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsEngineer then
                        minimap[624][716840299] = { name = L["Engineer"], type = "Engineer", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profileshowMinimapCapitalsSkinning then
                        minimap[624][48643138] = { name = L["Skinning"], type = "Skinning", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsTailoring then
                        minimap[624][59394278] = { name = L["Tailoring"], type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsJewelcrafting then
                        minimap[624][60203986] = { name = L["Jewelcrafting"], type = "Jewelcrafting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profileshowMinimapCapitalsMiniapBlacksmith then
                        minimap[624][74093712] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsMining then
                        minimap[624][78603676] = { name = L["Mining"], type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsFishing then
                        minimap[624][69161653] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsCooking then
                        minimap[624][45784497] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsArchaeology then
                        minimap[624][73603119] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsHerbalism then
                        minimap[624][62563059] = { name = L["Herbalism"], type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsInscription then
                        minimap[624][77104741] = { name = INSCRIPTION, type = "Inscription", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsEnchanting then
                        minimap[624][78755287] = { name = L["Enchanting"], type = "Enchanting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                end

            --Transports Warspear
                if self.db.profile.activate.MinimapCapitalsTransporting then

                    if self.db.profile.showMinimapCapitalsPortals then
                        minimap[624][53184384] = { mnID = 534, name = L["Vol'mar"], type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal from Ashran to Vol'mar Captive
                        minimap[624][60825159] = { mnID = 85, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. ORGRIMMAR } -- Portal from Garrison to Ashran
                        minimap[590][75184879] = { mnID = 624, name = L["Ashran"], type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal from Garrison to Ashran
                    end

                    if self.db.profile.showMinimapCapitalsFP then
                        minimap[590][45665027] = { name = MINIMAP_TRACKING_FLIGHTMASTER, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[624][44133387] = { name = MINIMAP_TRACKING_FLIGHTMASTER, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end

            --General Warspear
                if self.db.profile.activate.MinimapCapitalsGeneral then
    
                    if self.db.profile.showMinimapCapitalsPaths then
                        minimap[624][55498792] = { dnID = L["Exit"], name = "", mnID = 588, type = "PathR", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                    end

                    if self.db.profile.showMinimapCapitalsInnkeeper then
                        minimap[624][44954321] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsAuctioneer then
                        minimap[624][54692551] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsBank then
                        minimap[624][51766162] = { dnID = BANK .. "\n" .. GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsPvPVendor then
                        minimap[624][49045437] = { dnID = TRANSMOG_SET_PVP .. "" .. SLASH_EQUIP_SET1, name = "", type = "PvPVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsTransmogger then
                        minimap[624][58335187] = { dnID = MINIMAP_TRACKING_TRANSMOGRIFIER, name = "", type = "Transmogger", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsMailbox then
                        minimap[624][51905650] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true}
                        minimap[624][47504450] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true}
                        minimap[624][54503050] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true}
                        minimap[624][65105270] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true}
                        minimap[624][68203930] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true}
                        minimap[624][77805210] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true}
                    end

                    if self.db.profile.showMinimapCapitalsStablemaster then
                        minimap[624][77605900] = { dnID = MINIMAP_TRACKING_STABLEMASTER, name = "", type = "StablemasterN", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end

            end

        end

    --#################
    --### DazarAlor ###
    --#################
        if self.db.profile.showMinimapCapitalsDazarAlor then

        --#############################
        --### Horde or EnemyFaction ###
        --#############################
            if self.faction == "Horde" or db.activate.MinimapCapitalsEnemyFaction then

            --Professions DazarAlor
                if self.db.profile.activate.MinimapCapitalsProfessions then

                    if self.db.profile.showMinimapCapitalsAlchemy then
                        minimap[1165][42223796] = { name = L["Alchemy"], type = "Alchemy", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                
                    if self.db.profile.showMinimapCapitalsLeatherworking then
                        minimap[1165][44103463] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsEngineer then
                        minimap[1165][45144059] = { name = L["Engineer"], type = "Engineer", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsSkinning then
                        minimap[1165][43783469] = { name = L["Skinning"], type = "Skinning", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsTailoring then
                        minimap[1165][44493387] = { name = L["Tailoring"], type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsJewelcrafting then
                        minimap[1165][47053791] = { name = L["Jewelcrafting"], type = "Jewelcrafting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION .. "\n" .. L["in the basement"] }
                    end

                    if self.db.profile.showMinimapCapitalsBlacksmith then
                        minimap[1165][43643827] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsMining then
                        minimap[1165][44123896] = { name = L["Mining"], type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsFishing then
                        minimap[1165][50522337] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsCooking then
                        minimap[1165][52479045] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        minimap[1164][28565017] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }

                    end

                    if self.db.profile.showMinimapCapitalsArchaeology then
                        minimap[1163][32223550] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION .. "\n" .. ERR_USE_OBJECT_MOVING }
                        minimap[1165][48804311] = { mnID = 1165, name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsHerbalism then
                        minimap[1165][42093560] = { name = L["Herbalism"], type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsInscription then
                        minimap[1165][42313974] = { name = INSCRIPTION, type = "Inscription", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        minimap[1164][70563292] = { name = INSCRIPTION, type = "Inscription", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsEnchanting then
                        minimap[1165][47103569] = { name = L["Enchanting"], type = "Enchanting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION .. "\n" .. L["in the basement"] }
                    end
                end

            --Transports DazarAlor
                if self.db.profile.activate.MinimapCapitalsTransporting then

                    if self.db.profile.showMinimapCapitalsPortals then
                        minimap[1165][51424583] = { mnID = 1163, name = L["Portal"], type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Dazar'alor"] .. " " .. L["Portalroom"] .. L["(inside building)"] .. "\n" .. " ==> " .. L["Silvermoon City"] .. "\n" .. " ==> " .. ORGRIMMAR .. "\n" .. " ==> " .. L["Thunder Bluff"] .. "\n" .. " ==> " .. L["Silithus"] .. "\n" .. " ==> " .. L["Nazjatar"] } -- Portalroom from Dazar'alor
                        minimap[1163][73726194] = { mnID = 110, name = L["Portal"], type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portalroom from Dazar'alor
                        minimap[1163][74006974] = { mnID = 85, name = L["Portal"], type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portalroom from Dazar'alor
                        minimap[1163][74027739] = { mnID = 88, name = L["Portal"], type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portalroom from Dazar'alor
                        minimap[1163][73808541] = { mnID = 81, name = L["Portal"], type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portalroom from Dazar'alor
                        minimap[1163][63008553] = { mnID = 1355, name = L["Portal"], type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portalroom from Dazar'alor
                        minimap[1165][52079454] = { mnID = 62, name = L["This Darkshore portal is only active if your faction is currently occupying Bashal'Aran"], type = "HPortalS", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal from Dazar'alor to Arathi or Darkshore
                        minimap[1165][51719454] = { mnID = 14, name = L["This Arathi Highlands portal is only active if your faction is currently occupying Ar'gorok"], type = "HPortalS", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal from Dazar'alor to Arathi or Darkshore         
                    end

                    if self.db.profile.showMinimapCapitalsTransport then
                        minimap[1165][41838761] = { mnID = 1462, name = L["Captain Krooz"] .. " " .. L["Travel"], type = "GoblinF", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Transport from Dazar'alor to Mechagon
                    end

                    if self.db.profile.showMinimapCapitalsFP then
                        minimap[1165][52098994] = { name = MINIMAP_TRACKING_FLIGHTMASTER, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1165][51654120] = { name = MINIMAP_TRACKING_FLIGHTMASTER, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1165][53121928] = { name = MINIMAP_TRACKING_FLIGHTMASTER, type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end

            --Instances DazarAlor
                if self.db.profile.activate.MinimapCapitalsInstances then
    
                    if self.db.profile.showMinimapCapitalsDungeons then
                        minimap[1165][44049256] = { id = 1012, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The MOTHERLODE HORDE
                    end

                    if self.db.profile.showMinimapCapitalsRaids then
                        minimap[1165][38920289] = { id = 1176, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Battle of Dazar Alor
                    end

                    if self.db.profile.showMinimapCapitalsLFR then
                        minimap[1163][76554199] = { mnID = 1164, name = DUNGEON_FLOOR_GILNEAS3  .. "\n" .. " " .. "\n" .. L["Eppu"] .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " ", id = { 1176, 1031, 1179, 1036 }, type = "PassageRaid", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1164][68583002] = { mnID = 1164, name = L["Eppu"] .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " ", id = { 1176, 1031, 1179, 1036 }, type = "LFR", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1165][49914447] = { mnID = 1164, name = L["Eppu"] .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " ", id = { 1176, 1031, 1179, 1036 }, type = "LFR", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end
                end

            --General DazarAlor
                if self.db.profile.activate.MinimapCapitalsGeneral then
    
                    if self.db.profile.showMinimapCapitalsPaths then
                        minimap[1165][49934095] = { name = L["Entrance"], mnID = 1163, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                        minimap[1163][48591752] = { dnID = L["Exit"], name = "", mnID = 1165, type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                        minimap[1165][37238159] = { dnID = L["Exit"], name = "", mnID = 862, type = "PathL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                        minimap[1165][35875990] = { dnID = L["Exit"], name = "", mnID = 862, type = "PathL", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                        minimap[1165][36030716] = { dnID = L["Exit"], name = "", mnID = 862, type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                        minimap[1165][57851053] = { dnID = L["Exit"], name = "", mnID = 862, type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                        minimap[1165][60526367] = { dnID = L["Exit"], name = "", mnID = 862, type = "PathRO", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                        minimap[1165][44423697] = { name = L["Passage"] .. " " .. MINIMAP_TRACKING_TRAINER_PROFESSION, type = "PathR", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName =  L["Jewelcrafting"] .. "\n" .. L["Enchanting"] }
                        minimap[1163][57117058] = { name = "", TransportName = L["Passage"] .. " " .. L["Portalroom"], mnID = 1163, type = "PathR", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                        minimap[1163][20962819] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS3, mnID = 1164, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = PROFESSIONS_COOKING .. INSCRIPTION .. "\n" .. RAID_FINDER } -- Passage/Exit 
                        minimap[1163][76532819] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS3, mnID = 1164, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = PROFESSIONS_COOKING .. INSCRIPTION .. "\n" .. RAID_FINDER } -- Passage/Exit 
                        minimap[1163][43888227] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS3, mnID = 1164, type = "PathL", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = PROFESSIONS_COOKING .. INSCRIPTION .. "\n" .. RAID_FINDER } -- Passage/Exit 
                        minimap[1163][53458227] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS3, mnID = 1164, type = "PathR", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = PROFESSIONS_COOKING .. INSCRIPTION .. "\n" .. RAID_FINDER } -- Passage/Exit 
                        minimap[1163][41524702] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS3, mnID = 1164, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = PROFESSIONS_COOKING .. INSCRIPTION .. "\n" .. RAID_FINDER } -- Passage/Exit 
                        minimap[1163][55184702] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS3, mnID = 1164, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = PROFESSIONS_COOKING .. INSCRIPTION .. "\n" .. RAID_FINDER } -- Passage/Exit 
                        minimap[1164][42158227] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS2, mnID = 1163, type = "PathR", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portals"] .. "\n" .. BANK .. " / " .. GUILD_BANK .."\n" .. MINIMAP_TRACKING_INNKEEPER .."\n" .. INSCRIPTION .."\n" .. PROFESSIONS_ARCHAEOLOGY } -- Passage/Exit 
                        minimap[1164][54398227] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS2, mnID = 1163, type = "PathL", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portals"] .. "\n" .. BANK .. " / " .. GUILD_BANK .."\n" .. MINIMAP_TRACKING_INNKEEPER .."\n" .. INSCRIPTION .."\n" .. PROFESSIONS_ARCHAEOLOGY } -- Passage/Exit 
                        minimap[1164][76683848] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS2, mnID = 1163, type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portals"] .. "\n" .. BANK .. " / " .. GUILD_BANK .."\n" .. MINIMAP_TRACKING_INNKEEPER .."\n" .. INSCRIPTION .."\n" .. PROFESSIONS_ARCHAEOLOGY } -- Passage/Exit 
                        minimap[1164][20803895] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS2, mnID = 1163, type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portals"] .. "\n" .. BANK .. " / " .. GUILD_BANK .."\n" .. MINIMAP_TRACKING_INNKEEPER .."\n" .. INSCRIPTION .."\n" .. PROFESSIONS_ARCHAEOLOGY } -- Passage/Exit 
                        minimap[1164][40905331] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS2, mnID = 1163, type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portals"] .. "\n" .. BANK .. " / " .. GUILD_BANK .."\n" .. MINIMAP_TRACKING_INNKEEPER .."\n" .. INSCRIPTION .."\n" .. PROFESSIONS_ARCHAEOLOGY } -- Passage/Exit 
                        minimap[1164][56435354] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS2, mnID = 1163, type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portals"] .. "\n" .. BANK .. " / " .. GUILD_BANK .."\n" .. MINIMAP_TRACKING_INNKEEPER .."\n" .. INSCRIPTION .."\n" .. PROFESSIONS_ARCHAEOLOGY } -- Passage/Exit 
                        minimap[1164][22677175] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS3, mnID = 1165, type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                        minimap[1164][74017175] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS3, mnID = 1165, type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                    end

                    if self.db.profile.showMinimapCapitalsInnkeeper then
                        minimap[1165][52418494] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1165][49844867] = { mnID = 1163, dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1163][48837200] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsAuctioneer then
                        minimap[1165][44964015] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = REQUIRES_LABEL .. " " .. L["Engineer"] }
                    end

                    if self.db.profile.showMinimapCapitalsBank then
                        minimap[1163][31834692] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1163][30226774] = { dnID = BANK .. "\n" .. GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsBarber then
                        minimap[1165][47358104] = { dnID = MINIMAP_TRACKING_BARBER, name = "", type = "Barber", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsTransmogger then
                        minimap[1165][54508960] = { dnID = MINIMAP_TRACKING_TRANSMOGRIFIER, name = "", type = "Transmogger", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsPvPVendor then
                        minimap[1165][51239509] = { dnID = TRANSMOG_SET_PVP .. "" .. SLASH_EQUIP_SET1, name = "", type = "PvPVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsMailbox then
                        minimap[1165][45209450] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1165][51508550] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1165][50507150] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1165][49604170] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1165][46503510] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1165][43003790] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1165][52901840] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1165][35600920] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1165][41200440] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsStablemaster then
                        minimap[1165][45803620] = { dnID = MINIMAP_TRACKING_STABLEMASTER, name = "", type = "StablemasterN", showInZone = false, showOnContinent = false, showOnMinimap = true }
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
                        minimap[392][72464286] = { mnID = 85, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. ORGRIMMAR } -- Portal from Shrine of Two Moons to Orgrimmar
                        minimap[1530][63720989] = { mnID = 85, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. ORGRIMMAR .. "\n" .. DUNGEON_FLOOR_GILNEAS3 } -- Portal from Shrine of Two Moons to Orgrimmar
                    end

                end

            --General Sot2M
                if self.db.profile.activate.MinimapCapitalsGeneral then
    
                    if self.db.profile.showMinimapCapitalsPaths then
                        minimap[391][26778156] = { name = L["Exit"], mnID = 390, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[391][53618846] = { name = L["Exit"], mnID = 390, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[391][77476963] = { name = L["Exit"], mnID = 390, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[391][78084452] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS3, mnID = 392, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = "\n" .. BANK .. "\n" .. GUILD_BANK .. "\n" .. L["Portal"] .. " ==> " .. ORGRIMMAR }
                        minimap[391][22245623] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS3, mnID = 392, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = "\n" .. BANK .. "\n" .. GUILD_BANK .. "\n" .. L["Portal"] .. " ==> " .. ORGRIMMAR }
                        minimap[391][36972301] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS3, mnID = 392, type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = "\n" .. BANK .. "\n" .. GUILD_BANK .. "\n" .. L["Portal"] .. " ==> " .. ORGRIMMAR }
                        minimap[391][57691948] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS3, mnID = 392, type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = "\n" .. BANK .. "\n" .. GUILD_BANK .. "\n" .. L["Portal"] .. " ==> " .. ORGRIMMAR }
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
                        minimap[1530][61691650] = { dnID = TRANSMOG_SET_PVE .. "" .. SLASH_EQUIP_SET1 .. "\n" .. BANK .. "\n" .. GUILD_BANK .. "\n" .. L["Portal"] .. " ==> " .. ORGRIMMAR .. "\n" .. BUTTON_LAG_AUCTIONHOUSE .. " " .. REQUIRES_LABEL .. " " .. L["Engineer"] .. "\n" .. MINIMAP_TRACKING_INNKEEPER .. "\n" .. L["Engineer"] .. "\n" .. L["Blacksmithing"], name = "", type = "MNL", showInZone = false, showOnContinent = false, showOnMinimap = true }
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
                        minimap[84][51196779] = { id = 238, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Stockade
                    end

                end

            --Transports Stormwind
                if self.db.profile.activate.MinimapCapitalsTransporting then

                    if self.db.profile.showMinimapCapitalsPortals then
                        minimap[84][50710826] = { mnID = 971, name = "", type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Telogrus Rift"] } -- Portal to Telogrus
                        minimap[84][73221836] = { mnID = 245, name = "", type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. DUNGEON_FLOOR_TOLBARADWARLOCKSCENARIO0 } --  Portal to Tol Barad
                        minimap[84][75232055] = { mnID = 1527, name = "", type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Uldum"] } -- Portal to Uldum
                        minimap[84][75351649] = { mnID = 241, name = "", type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Twilight Highlands"] } -- Portal to Twilight Highlands
                        minimap[84][76211869] = { mnID = 198, name = "", type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. POSTMASTER_LETTER_HYJAL } -- Portal to Hyjal
                        minimap[84][73171966] = { mnID = 207, name = "", type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. ARTIFACT_SHAMAN_TITLECARD_DEEPHOLM } -- Portal to Deepholm
                        minimap[84][73301687] = { mnID = 203, name = "", type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Vashj'ir"] } -- Portal to Vashjir
                        minimap[84][49118734] = { mnID = 17, name = "", TransportName = L["The Dark Portal"] .. "\n" .. "( " .. L["talk to"] .. ": " .. L["Honor Hold Mage"] .. " )", type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Blasted Lands
                        minimap[84][43748538] = { mnID = 74, name = "", type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. DUNGEON_FLOOR_TANARIS18} -- Portal to Caverns of Time 
                        minimap[84][44888577] = { mnID = 111, name = "", type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Shattrath City"] } -- Portal to Shattrath 
                        minimap[84][43638719] = { mnID = 103, name = "", type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Exodar"] } -- Portal to Exodar 
                        minimap[84][44388868] = { mnID = 125, name = "", type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. DUNGEON_FLOOR_DALARANCITY1 } -- Portal to Dalaran 
                        minimap[84][45708715] = { mnID = 371, name = "", type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Jade Forest"] } -- Portal to Jade Forest 
                        minimap[84][48099198] = { mnID = 622, name = "", type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. WORLD_PVP } -- Portal to Stormshield 
                        minimap[84][46869339] = { mnID = 630, name = "", type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Azsuna"] } -- Portal to Azsuna 
                        minimap[84][47579495] = { mnID = 1670, name = "", type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Oribos"] } -- Portal to Oribos 
                        minimap[84][48849344] = { mnID = 2112, name = "", type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Valdrakken"] } -- Portal to Valdrakken 
                        minimap[84][48759519] = { mnID = 1161, name = "", type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Boralus, Tiragarde Sound"] } -- Portal to Boralus 
                        minimap[84][43269759] = { mnID = 2239, name = "", type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Bel'ameth, Amirdrassil"] } -- Portal to Bel'ameth, Amirdrassil
                        minimap[84][23865611] = { mnID = 89, name = "", type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Darnassus"] } -- Portal to Darnassus 
                        minimap[84][63197339] = { mnID = 407, name = L["Transport"] .. " ==> " .. CALENDAR_FILTER_DARKMOON, TransportName = "\n" .. REQUIRES_LABEL .. " " .. CALENDAR_FILTER_DARKMOON .. "\n" .. L["Starting on the first Sunday of each month for one week"], type = "DarkMoon", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[84][62043235] = { mnID = 407, name = L["Transport"] .. " ==> " .. CALENDAR_FILTER_DARKMOON, TransportName = "\n" .. REQUIRES_LABEL .. " " .. CALENDAR_FILTER_DARKMOON .. "\n" .. L["Starting on the first Sunday of each month for one week"], type = "DarkMoon", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[84][40819280] = { mnID = 2339, name = L["Dornogal"], type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dornogal
                        minimap[84][51551012] = { mnID = 2322, name = L["Portal"], dnID = "", type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hall of Awakening

                    end
   
                    if self.db.profile.showMinimapCapitalsShips then
                        minimap[84][21225479] = { mnID = 1161, name = "", type = "AShip", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Ship"] .. " ==> " .. L["Boralus, Tiragarde Sound"] } -- Ship from Stormwind to Boralus
                        minimap[84][22035670] = { mnID = 2022, name = "", type = "AShip", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Ship"] .. " ==> " .. L["The Waking Shores, Dragon Isles"] } -- Ship from Stormwind to Waking Shores
                        minimap[84][18122555] = { mnID = 114, name = "", type = "AShip", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Ship"] .. " ==> " .. POSTMASTER_LETTER_VALIANCEKEEP } -- Ship from Stormwind to Valiance Keep
                    end

                    if self.db.profile.showMinimapCapitalsTransport then
                        minimap[84][66783455] = { mnID = 499, name = "", type = "Carriage", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = DUNGEON_FLOOR_DEEPRUNTRAM1 .. " ==> " .. L["Ironforge"] } -- Transport to Ironforge Carriage
                    end

                    if self.db.profile.showMinimapCapitalsFP then
                        minimap[84][71977195] = { name = MINIMAP_TRACKING_FLIGHTMASTER, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end

            --Professions Stormwind
                if self.db.profile.activate.MinimapCapitalsProfessions then

                    if self.db.profile.showMinimapCapitalsAlchemy then
                        minimap[84][55668610] = { name = L["Alchemy"], type = "Alchemy", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                
                    if self.db.profile.showMinimapCapitalsLeatherworking then
                        minimap[84][42596045] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
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

                    if self.db.profileshowMinimapCapitalsBlacksmith then
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
                        minimap[84][40846587] = { name = L["Herbalism"], type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
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
                        minimap[499][89874349] = { dnID = L["Passage"], name = "", mnID = 87, type = "PathR", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                        minimap[499][89876720] = { dnID = L["Passage"], name = "", mnID = 87, type = "PathR", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                        minimap[499][42471587] = { dnID = L["Entrance"], name = "", mnID = 84, type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                        minimap[499][52124649] = { dnID = L["Stormwind"] .. " - " .. DUNGEON_FLOOR_DEEPRUNTRAM1 .. "\n" .. " ==> " .. DUNGEON_FLOOR_DEEPRUNTRAM2, name = "", mnID = 500, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                        minimap[500][72440888] = { dnID = DUNGEON_FLOOR_DEEPRUNTRAM1, name = "", mnID = 499, type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                    end

                    if self.db.profile.showMinimapCapitalsInnkeeper then
                        minimap[84][60407527] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[84][75685411] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[84][49881574] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[84][64943193] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsAuctioneer then
                        minimap[84][61167081] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[84][60233216] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsBank then
                        minimap[84][62887831] = { dnID = BANK .. "\n" .. GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[84][64562883] = { dnID = BANK .. "\n" .. GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsBarber then
                        minimap[84][61316464] = { dnID = MINIMAP_TRACKING_BARBER, name = "", type = "Barber", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsPvPVendor then
                        minimap[84][74486812] = { dnID = TRANSMOG_SET_PVP .. "" .. SLASH_EQUIP_SET1, name = "", type = "PvPVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsTransmogger then
                        minimap[84][50396054] = { dnID = MINIMAP_TRACKING_TRANSMOGRIFIER, name = "", type = "Transmogger", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsPvEVendor then
                        minimap[84][75666652] = { dnID = TRANSMOG_SET_PVE .. "" .. SLASH_EQUIP_SET1, name = "", TransportName = DUNGEON_FLOOR_GILNEAS3,  type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsMailbox then
                        minimap[84][30204950] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[84][30502550] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[84][37803470] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[84][53201550] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[84][62003120] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[84][60805070] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[84][54805740] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[84][54606350] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[84][51007070] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[84][74505560] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[84][75806440] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[84][66806550] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[84][62107050] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[84][57507150] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[84][62507470] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsStablemaster then
                        minimap[84][77806720] = { dnID = MINIMAP_TRACKING_STABLEMASTER, name = "", type = "StablemasterN", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[84][67003760] = { dnID = MINIMAP_TRACKING_STABLEMASTER, name = "", type = "StablemasterN", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsTradingPost then
                        minimap[84][51487192] = { dnID = BATTLE_PET_SOURCE_12, name = "",  type = "TradingPost", showInZone = false, showOnContinent = false, showOnMinimap = true }
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
                        minimap[87][72545022] = { mnID = 84, name = "", type = "Carriage", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = DUNGEON_FLOOR_DEEPRUNTRAM1 .. " ==> " .. STORMWIND } -- Transport to Stormwind Carriage
                    end

                    if self.db.profile.showMinimapCapitalsFP then
                        minimap[87][55884786] = { name = MINIMAP_TRACKING_FLIGHTMASTER, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end

            --Professions ironforge
                if self.db.profile.activate.MinimapCapitalsProfessions then

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

                    if self.db.profileshowMinimapCapitalsBlacksmith then
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
                        minimap[87][25517317] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsBank then
                        minimap[87][35646042] = { dnID = BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[87][33516017] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[87][35386360] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsBarber then
                        minimap[87][25215134] = { dnID = MINIMAP_TRACKING_BARBER, name = "", type = "Barber", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsPvEVendor then
                        minimap[87][74400917] = { dnID = TRANSMOG_SET_PVE .. "" .. SLASH_EQUIP_SET1, name = "", TransportName = HEIRLOOMS,  type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsMailbox then
                        minimap[87][46805900] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[87][61602760] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[87][71207250] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[87][21505310] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[87][33606370] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[87][72504950] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsStablemaster then
                        minimap[87][69008460] = { dnID = MINIMAP_TRACKING_STABLEMASTER, name = "", type = "StablemasterN", showInZone = false, showOnContinent = false, showOnMinimap = true }
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
                    minimap[89][36045019] = { mnID = 57, name = "", type = "Portal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Rut'theran"] } -- Portal To Darnassus from Teldrassil
                end

            end

        --################################
        --### Alliance or EnemyFaction ###
        --################################
            if self.faction == "Alliance" or db.activate.MinimapCapitalsEnemyFaction then

            --General Darnassus
                if self.db.profile.activate.MinimapCapitalsGeneral then
    
                    if self.db.profile.showMinimapCapitalsPaths then
                        minimap[89][79984648] = { dnID = L["Exit"], name = "", mnID = 57, type = "PathR", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit
                    end

                    if self.db.profile.showMinimapCapitalsInnkeeper then
                        minimap[89][62533278] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsAuctioneer then
                        minimap[89][54915837] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsBank then
                        minimap[89][44285140] = { dnID = BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[89][42655247] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsMailbox then
                        minimap[89][62603330] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[89][60707150] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[89][57505990] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[89][54705320] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[89][44905040] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsStablemaster then
                        minimap[89][43602940] = { dnID = MINIMAP_TRACKING_STABLEMASTER, name = "", type = "StablemasterN", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end

            --Transports Darnassus
                if self.db.profile.activate.MinimapCapitalsTransporting then

                    if self.db.profile.showMinimapCapitalsPortals then
                        minimap[89][44127840] = { name = "", type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portals"] .. "\n" .. " ==> " .. L["Exodar"] .. "\n" .. " ==> " .. L["Hellfire Peninsula"] } -- Portal To Darnassus from Teldrassil
                    end

                    if self.db.profile.showMinimapCapitalsFP then
                        minimap[89][36724827] = { name = MINIMAP_TRACKING_FLIGHTMASTER, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end

            --Professions Darnassus
                if self.db.profile.activate.MinimapCapitalsProfessions then

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

                    if self.db.profileshowMinimapCapitalsBlacksmith then
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
                        minimap[103][34947443] = { dnID = L["Exit"], name = "", mnID = 97, type = "PathLO", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit
                        minimap[103][65223478] = { dnID = L["Exit"], name = "", mnID = 97, type = "PathRO", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit
                    end

                    if self.db.profile.showMinimapCapitalsInnkeeper then
                        minimap[103][59511876] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsAuctioneer then
                        minimap[103][61935508] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsBank then
                        minimap[103][49224406] = { dnID = BANK .. "\n" .. GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsMailbox then
                        minimap[103][79606350] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[103][60505190] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[103][51504320] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[103][59302760] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsStablemaster then
                        minimap[103][59402440] = { dnID = MINIMAP_TRACKING_STABLEMASTER, name = "", type = "StablemasterN", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end

            --Transports Exodar
                if self.db.profile.activate.MinimapCapitalsTransporting then

                    if self.db.profile.showMinimapCapitalsPortals then
                        minimap[103][48326264] = { mnID = 84, name = "", type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. STORMWIND } -- Portal Exodar to Stormwind
                    end

                    if self.db.profile.showMinimapCapitalsFP then
                        minimap[103][54383659] = { name = MINIMAP_TRACKING_FLIGHTMASTER, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end

            --Professions Exodar
                if self.db.profile.activate.MinimapCapitalsProfessions then

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

                    if self.db.profileshowMinimapCapitalsBlacksmith then
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

    --##############################
    --### Stormshield / Garrison ###
    --##############################
        if self.db.profile.showMinimapCapitalsStormshield then

        --################################
        --### Alliance or EnemyFaction ###
        --################################
            if self.faction == "Alliance" or db.activate.MinimapCapitalsEnemyFaction then

            --Instance Warspear / Garrison
                if self.db.profile.activate.MinimapCapitalsInstances then
    
                    if self.db.profile.showMinimapCapitalsLFR then
                        minimap[582][33173703] = { mnID = 582, name = L["Seer Kazal"] .. " - " .. REQUIRES_LABEL .. " " .. GARRISON_LOCATION_TOOLTIP .. " " .. LEVEL .. " " .. ACTION_SPELL_CAST_START_MASTER .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " ", id = { 477, 457, 669 }, type = "LFR", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end
    
                end

            --General Stormshield
                if self.db.profile.activate.MinimapCapitalsGeneral then
    
                    if self.db.profile.showMinimapCapitalsPaths then
                        minimap[622][55650794] = { dnID = L["Exit"], name = "", mnID = 588, type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit
                    end

                    if self.db.profile.showMinimapCapitalsInnkeeper then
                        minimap[622][35727790] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsAuctioneer then
                        minimap[622][53966609] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsBank then
                        minimap[622][54394818] = { dnID = BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[622][56135089] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsPvPVendor then
                        minimap[622][54781873] = { dnID = TRANSMOG_SET_PVP .. " " .. MERCHANT, name = "", type = "PvPVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsTransmogger then
                        minimap[622][63133544] = { dnID = MINIMAP_TRACKING_TRANSMOGRIFIER, name = "", type = "Transmogger", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsPvEVendor then
                        minimap[622][49776140] = { dnID = TRANSMOG_SET_PVE .. " " .. MERCHANT, name = "", type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsMailbox then
                        minimap[622][36207260] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[622][43506950] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[622][42103790] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[622][51604450] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[622][63602250] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsStablemaster then
                        minimap[622][34006420] = { dnID = MINIMAP_TRACKING_STABLEMASTER, name = "", type = "StablemasterN", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end

            --Transports Stormshield
                if self.db.profile.activate.MinimapCapitalsTransporting then

                    if self.db.profile.showMinimapCapitalsPortals then
                        minimap[582][69692706] = { mnID = 622, name = L["Ashran"], type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal from Garison to Ashran
                        minimap[622][36234113] = { mnID = 534, name = "", type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. SPLASH_NEW_6_2_FEATURE1_TITLE } -- Portal from Ashran to Lion's Watch
                        minimap[622][60813785] = { mnID = 84,  name = "" , type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. STORMWIND } -- Portal from Ashran to Stormwind
                    end

                    if self.db.profile.showMinimapCapitalsFP then
                        minimap[622][30554842] = { name = MINIMAP_TRACKING_FLIGHTMASTER, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[582][47764933] = { name = MINIMAP_TRACKING_FLIGHTMASTER, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end

            --Professions Stormshield
                if self.db.profile.activate.MinimapCapitalsProfessions then

                    if self.db.profile.showMinimapCapitalsAlchemy then
                        minimap[622][37056882] = { name = L["Alchemy"], type = "Alchemy", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                
                    if self.db.profile.showMinimapCapitalsLeatherworking then
                        minimap[622][52494201] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsEngineer then
                        minimap[622][48004052] = { name = L["Engineer"], type = "Engineer", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsSkinning then
                        minimap[622][52124369] = { name = L["Skinning"], type = "Skinning", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsTailoring then
                        minimap[622][51533716] = { name = L["Tailoring"], type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsJewelcrafting then
                        minimap[622][43513391] = { name = L["Jewelcrafting"], type = "Jewelcrafting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsBlacksmith then
                        minimap[622][49344639] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsMining then
                        minimap[622][47324371] = { name = L["Mining"], type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsFishing then
                        minimap[622][55497849] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsCooking then
                        minimap[622][35137611] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION .. "\n" .. L["in the basement"] }
                    end

                    if self.db.profile.showMinimapCapitalsArchaeology then
                        minimap[622][48993319] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsHerbalism then
                        minimap[622][37616948] = { name = L["Herbalism"], type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsInscription then
                        minimap[622][63163365] = { name = INSCRIPTION, type = "Inscription", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsEnchanting then
                        minimap[622][56706551] = { name = L["Enchanting"], type = "Enchanting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                end

            end

        end

    --###############
    --### Boralus ###
    --###############
        if self.db.profile.showMinimapCapitalsBoralus then

        --################################
        --### Alliance or EnemyFaction ###
        --################################
            if self.faction == "Alliance" or db.activate.MinimapCapitalsEnemyFaction then

            --Instance Boralus
                if self.db.profile.activate.MinimapCapitalsInstances then

                    if self.db.profile.showMinimapCapitalsRaids then
                        minimap[1161][70443555] = { id = 1176, type = "Raid", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Battle of Dazar'alor
                    end

                    if self.db.profile.showMinimapCapitalsDungeons then
                        minimap[1161][71971537] = { id = 1023, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Siege of Boralus
                    end

                    if self.db.profile.showMinimapCapitalsLFR then
                        minimap[1161][74191352] = { mnID = 1161, name = L["Kiku"] .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " ", id = { 1176, 1031, 1179, 1036 }, type = "LFR", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end
    
                end

            --General Boralus
                if self.db.profile.activate.MinimapCapitalsGeneral then
    
                    if self.db.profile.showMinimapCapitalsPaths then
                        minimap[1161][81239058] = { dnID = L["Exit"], name = "", mnID = 895, type = "PathRU", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit
                        minimap[1161][37761547] = { dnID = L["Exit"], name = "", mnID = 895, type = "PathLO", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit
                        minimap[1161][42621359] = { dnID = L["Exit"], name = "", mnID = 895, type = "PathRO", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit
                        minimap[1161][08093855] = { dnID = L["Exit"], name = "", mnID = 895, type = "PathLO", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit
                    end

                    if self.db.profile.showMinimapCapitalsInnkeeper then
                        minimap[1161][74001234] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsAuctioneer then
                        minimap[1161][77271368] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = REQUIRES_LABEL .. " " .. L["Engineer"] }
                    end

                    if self.db.profile.showMinimapCapitalsBank then
                        minimap[1161][75591929] = { dnID = BANK .. "\n" .. GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsBarber then
                        minimap[1161][64752889] = { dnID = MINIMAP_TRACKING_BARBER, name = "", type = "Barber", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsPvPVendor then
                        minimap[1161][55952505] = { dnID = TRANSMOG_SET_PVP .. "" .. SLASH_EQUIP_SET1, name = "", type = "PvPVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsTransmogger then
                        minimap[1161][71621371] = { dnID = MINIMAP_TRACKING_TRANSMOGRIFIER, name = "", type = "Transmogger", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsMailbox then
                        minimap[1161][73606890] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1161][57002690] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1161][67002360] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1161][73801450] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsStablemaster then
                        minimap[1161][69001300] = { dnID = MINIMAP_TRACKING_STABLEMASTER, name = "", type = "StablemasterN", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end

            --Transports Boralus
                if self.db.profile.activate.MinimapCapitalsTransporting then

                    if self.db.profile.showMinimapCapitalsPortals then
                        minimap[1161][69871531] = { mnID = 1355, name = L["Portal"], type = "APortalS", questID = 55175, showWWW = true, wwwLink = "wowhead.com/quest=29824", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Portalroom from Boralus
                        minimap[1161][69641590] = { mnID = 81, name = L["Portal"], type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portalroom from Boralus
                        minimap[1161][70131684] = { mnID = 84, name = L["Portal"] , type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portalroom from Boralus
                        minimap[1161][70381499] = { mnID = 103, name = L["Portal"], type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portalroom from Boralus
                        minimap[1161][70891536] = { mnID = 87, name = L["Portal"], type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portalroom from Boralus
                        minimap[1161][66182474] = { mnID = 14, name = L["This Arathi Highlands portal is only active if your faction is currently occupying Ar'gorok"], type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portalroom from Boralus
                        minimap[1161][66212442] = { mnID = 62, name = L["This Darkshore portal is only active if your faction is currently occupying Bashal'Aran"], type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portalroom from Boralus
                    end

                    if self.db.profile.showMinimapCapitalsTransport then
                        minimap[1161][67952670] = { mnID = 862, mnID2 = 864, mnID3 = 863, name = L["(Grand Admiral Jes-Tereth) will take you to Vol'Dun, Nazmir or Zuldazar"], dnID = " " .. ITEM_REQ_ALLIANCE, type = "GilneanF", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal from Dazar'alor to Mechagon
                    end

                    if self.db.profile.showMinimapCapitalsFP then
                        minimap[1161][47916532] = { name = MINIMAP_TRACKING_FLIGHTMASTER, type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end

            --Professions Boralus
                if self.db.profile.activate.MinimapCapitalsProfessions then

                    if self.db.profileshowMinimapCapitalsAlchemy then
                        minimap[1161][74090670] = { name = L["Alchemy"], type = "Alchemy", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end
                
                    if self.db.profile.showMinimapCapitalsLeatherworking then
                        minimap[1161][75451258] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsEngineer then
                        minimap[1161][77611434] = { name = L["Engineer"], type = "Engineer", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsSkinning then
                        minimap[1161][75661340] = { name = L["Skinning"], type = "Skinning", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsTailoring then
                        minimap[1161][76951116] = { name = L["Tailoring"], type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsJewelcrafting then
                        minimap[1161][75210986] = { name = L["Jewelcrafting"], type = "Jewelcrafting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsBlacksmith then
                        minimap[1161][73470849] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsMining then
                        minimap[1161][75200760] = { name = L["Mining"], type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsFishing then
                        minimap[1161][74160560] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsCooking then
                        minimap[1161][71201068] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsArchaeology then
                        minimap[1161][68340848] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsHerbalism then
                        minimap[1161][70550566] = { name = L["Herbalism"], type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsInscription then
                        minimap[1161][73380637] = { name = INSCRIPTION, type = "Inscription", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsEnchanting then
                        minimap[1161][74031153] = { name = L["Enchanting"], type = "Enchanting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
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
                        minimap[393][70883384] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS3, mnID = 394, type = "PathLO", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = "\n" .. BANK .. "\n" .. GUILD_BANK .. "\n" .. L["Portal"] .. " ==> " .. STORMWIND }
                        minimap[393][54048271] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS3, mnID = 394, type = "PathRU", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = "\n" .. BANK .. "\n" .. GUILD_BANK .. "\n" .. L["Portal"] .. " ==> " .. STORMWIND }
                        minimap[393][67926633] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS3, mnID = 394, type = "PathRU", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = "\n" .. BANK .. "\n" .. GUILD_BANK .. "\n" .. L["Portal"] .. " ==> " .. STORMWIND }
                        minimap[393][32697602] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS3, mnID = 394, type = "PathLO", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = "\n" .. BANK .. "\n" .. GUILD_BANK .. "\n" .. L["Portal"] .. " ==> " .. STORMWIND }
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
                        minimap[394][71563593] = { mnID = 84, name = "", type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName =  L["Portal"] .. " ==> " .. STORMWIND }
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
                    minimap[111][79515778] = { name = L["Exit"], mnID = 108, type = "PathRU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[111][22344989] = { name = L["Exit"], mnID = 107, type = "PathL", showInZone = false, showOnContinent = false, showOnMinimap = true }

                end

                if self.db.profile.showMinimapCapitalsAuctioneer then
                    minimap[111][57066278] = { name = BUTTON_LAG_AUCTIONHOUSE .. " - " .. L["The Scryers"], type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[111][51242693] = { name = BUTTON_LAG_AUCTIONHOUSE .. " - " .. L["The Aldor"], type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsBank then
                    minimap[111][60226036] = { dnID = BANK .. " - " .. L["The Scryers"], name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[111][62245901] = { dnID = GUILD_BANK  .. " - " .. L["The Scryers"], name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[111][47932940] = { dnID = BANK .. " - " .. L["The Aldor"], name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[111][46113106] = { dnID = GUILD_BANK  .. " - " .. L["The Aldor"], name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsPvEVendor then
                    minimap[111][50864226] = { dnID = TRANSMOG_SET_PVE .. "" .. SLASH_EQUIP_SET1, name = "", type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[111][47752581] = { dnID = L["Quartermaster"] .. " - " .. L["The Aldor"], name = "", type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[111][60486423] = { dnID = L["Quartermaster"] .. " - " .. L["The Scryers"], name = "", type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsMailbox then
                    minimap[111][55508050] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[111][28104780] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[111][60006480] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[111][74704840] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[111][73503460] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[111][47002570] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsStablemaster then
                    minimap[111][28604760] = { dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. L["The Aldor"], name = "", type = "StablemasterN", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[111][55808080] = { dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. L["The Scryers"], name = "", type = "StablemasterN", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

            end

        --Transports Shattrath
            if self.db.profile.activate.MinimapCapitalsTransporting then
    
                if self.db.profile.showMinimapCapitalsPortals then
                    minimap[111][48614203] = { mnID = 122, name = "", type = "Portal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal from Shattrath to Quel'Danas 

                    if self.faction == "Horde" or db.activate.MinimapCapitalsEnemyFaction then
                        minimap[111][56784884] = { mnID = 85, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Shattrath City"] .. " " .. L["Portals"] .. "\n" ..  "\n" .. " ==> " .. ORGRIMMAR } -- Portal from Shattrath to Orgrimmar 
                    end

                    if self.faction == "Alliance" or db.activate.MinimapCapitalsEnemyFaction then
                        minimap[111][57214825] = { mnID = 84,  name = "" , type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Shattrath City"] .. " " .. L["Portal"] .. "\n" .. " ==> " .. STORMWIND } -- Portal from Shattrath to Stormwind 
                    end
                end

                if self.db.profile.showMinimapCapitalsFP then
                    minimap[111][63794171] = { name = MINIMAP_TRACKING_FLIGHTMASTER, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

            end

        --Professions Shattrath
            if self.db.profile.activate.MinimapCapitalsProfessions then

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
                    minimap[111][69484332] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
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
                    minimap[125][66166745] = { id = 283, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Violet Hold
                end

                if self.db.profile.showMinimapCapitalsLFR then
                    minimap[125][63885454] = { name = L["Archmage Timear"] .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " ", id = { 875, 786, 768, 861, 946 }, type = "LFR", showInZone = false, showOnContinent = false, showOnMinimap = true }
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
                    minimap[126][25044295] = { name = "", mnID = 125, TransportName = L["Passage"] .. "\n" .. " ==> " .. DUNGEON_FLOOR_DALARAN1, type = "PathR", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[126][66484766] = { name = "", mnID = 125, TransportName = L["Passage"] .. "\n" .. " ==> " .. DUNGEON_FLOOR_DALARAN1, type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[125][35294528] = { name = "", mnID = 126, TransportName = L["Passage"] .. "\n" .. " ==> " .. DUNGEON_FLOOR_DALARAN2, type = "PathL", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[125][60294758] = { name = L["Passage"] .. " ==> " .. DUNGEON_FLOOR_DALARAN2, mnID = 126, TransportName = TRANSMOG_SET_PVP .. "" .. SLASH_EQUIP_SET1, type = "PathRU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[125][48343243] = { name = L["Passage"] .. " ==> " .. DUNGEON_FLOOR_DALARAN2, mnID = 126, TransportName = TRANSMOG_SET_PVP .. "" .. SLASH_EQUIP_SET1, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsAuctioneer then
                    minimap[125][38402502] = { name = BUTTON_LAG_AUCTIONHOUSE, type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }

                    if self.faction == "Horde" or db.activate.MinimapCapitalsEnemyFaction then
                        minimap[125][65522343] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = ITEM_REQ_HORDE}
                    end

                    if self.faction == "Alliance" or db.activate.MinimapCapitalsEnemyFaction then
                        minimap[125][37175488] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = ITEM_REQ_ALLIANCE}
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

                if self.db.profile.showMinimapCapitalsBarber then
                    minimap[125][51763170] = { dnID = MINIMAP_TRACKING_BARBER, name = "", type = "Barber", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsTransmogger then
                    minimap[125][39294161] = { dnID = MINIMAP_TRACKING_TRANSMOGRIFIER, name = "", type = "Transmogger", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsPvEVendor then
                    minimap[125][43744935] = { dnID = TRANSMOG_SET_PVE .. "" .. SLASH_EQUIP_SET1, name = "", TransportName = L["Cloth Armor"], type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[125][51067322] = { dnID = TRANSMOG_SET_PVE .. "" .. SLASH_EQUIP_SET1, name = "", TransportName = L["Leather Armor"] .. "\n" .. L["Heavy Armor"], type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[125][46362680] = { dnID = TRANSMOG_SET_PVE .. "" .. SLASH_EQUIP_SET1, name = "", TransportName = L["Heavy Armor"] .. "\n" .. L["Heavy Armor"], type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    
                    if self.faction == "Horde" or db.activate.MinimapCapitalsEnemyFaction then
                        minimap[125][66362219] = { dnID = L["Quartermaster"] .. " - " .. ITEM_REQ_HORDE, name = "", type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.faction == "Alliance" or db.activate.MinimapCapitalsEnemyFaction then
                        minimap[125][38135483] = { dnID = L["Quartermaster"] .. " - " .. ITEM_REQ_ALLIANCE, name = "", TransportName = DUNGEON_FLOOR_GILNEAS3,  type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end

                if self.db.profile.showMinimapCapitalsPvPVendor then
                    minimap[126][59355799] = { dnID = TRANSMOG_SET_PVP .. "" .. SLASH_EQUIP_SET1, name = "", type = "PvPVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsMailbox then
                    minimap[125][44606850] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[125][44905960] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[125][38504860] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[125][36806040] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[125][40503210] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[125][51505950] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[125][59504850] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[125][65604650] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[125][62503250] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[125][50003750] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[125][45503950] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[125][52502730] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[125][48902540] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsStablemaster then
                    minimap[125][59003860] = { dnID = MINIMAP_TRACKING_STABLEMASTER, name = "", type = "StablemasterN", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

            end

        --Transports Dalaran Northrend
            if self.db.profile.activate.MinimapCapitalsTransporting then
    
                if self.db.profile.showMinimapCapitalsPortals then
                    minimap[125][55904678] = { mnID = 127, name = L["Portal"], type = "Portal", showInZone = false, showOnContinent = false, showOnMinimap = true } 

                    if self.faction == "Horde" or db.activate.MinimapCapitalsEnemyFaction then
                        minimap[125][55322545] = { mnID = 85, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. ORGRIMMAR } -- Dalaran to Orgrimmar Portal 
                    end

                    if self.faction == "Alliance" or db.activate.MinimapCapitalsEnemyFaction then
                        minimap[125][40016276] = { mnID = 84,  name = "" , type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. STORMWIND } -- Dalaran to Stormwind City Portal
                    end
                end

                if self.db.profile.showMinimapCapitalsFP then
                    minimap[125][72164583] = { name = MINIMAP_TRACKING_FLIGHTMASTER, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

            end

        --Professions Dalaran Northrend
            if self.db.profile.activate.MinimapCapitalsProfessions then

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

    --######################
    --### Dalaran Legion ###
    --######################
        if self.db.profile.showMinimapCapitalsDalaranLegion then

        --Instance Dalaran Legion
            if self.db.profile.activate.MinimapCapitalsInstances then

                if self.db.profile.showMinimapCapitalsDungeons then
                    minimap[627][65576738] = { id = 777, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Assault on Violet Hold
                end

                if self.db.profile.showMinimapCapitalsLFR then
                    minimap[627][63535488] = { name = L["Archmage Timear"] .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " ", id = { 875, 786, 768, 861, 946 }, type = "LFR", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

            end

        --General Dalaran Legion
            if self.db.profile.activate.MinimapCapitalsGeneral then
    
                if self.db.profile.showMinimapCapitalsInnkeeper then
                    minimap[627][49784006] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }

                    if self.faction == "Horde" or db.activate.MinimapCapitalsEnemyFaction then
                        minimap[627][65443217] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, TransportName = ITEM_REQ_HORDE, type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.faction == "Alliance" or db.activate.MinimapCapitalsEnemyFaction then
                        minimap[627][44196398] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, TransportName = ITEM_REQ_ALLIANCE, type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end

                if self.db.profile.showMinimapCapitalsPaths then
                    minimap[627][34664554] = { name = "", mnID = 628, TransportName = L["Passage"] .. "\n" .. " ==> " .. DUNGEON_FLOOR_DALARAN2, type = "PathL", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[627][59714771] = { name = "", mnID = 628, TransportName = L["Passage"] .. "\n" .. " ==> " .. DUNGEON_FLOOR_DALARAN2, type = "PathRU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[628][73076461] = { name = "", mnID = 627, TransportName = L["Passage"] .. "\n" .. " ==> " .. DUNGEON_FLOOR_DALARAN1, type = "PathRU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[628][27815332] = { name = "", mnID = 627, TransportName = L["Passage"] .. "\n" .. " ==> " .. DUNGEON_FLOOR_DALARAN1, type = "PathL", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[627][48343243] = { name = L["Passage"] .. " ==> " .. DUNGEON_FLOOR_DALARAN2, mnID = 628, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsAuctioneer then
                    minimap[627][39082599] = { name = BUTTON_LAG_AUCTIONHOUSE, type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = REQUIRES_LABEL .. " " .. L["Engineer"] }
                end

                if self.db.profile.showMinimapCapitalsBank then
                    minimap[627][42708014] = { dnID = BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[627][53181526] = { dnID = BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[627][41217593] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[627][45777890] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[627][50111677] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[627][55681923] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsBarber then
                    minimap[627][51763170] = { dnID = MINIMAP_TRACKING_BARBER, name = "", type = "Barber", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsTransmogger then
                    minimap[627][39294161] = { dnID = MINIMAP_TRACKING_TRANSMOGRIFIER, name = "", type = "Transmogger", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsPvEVendor then
                    minimap[627][37635617] = { dnID = TRANSMOG_SET_PVE .. "" .. SLASH_EQUIP_SET1, name = "", TransportName = L["Cloth Armor"], type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[627][51067322] = { dnID = TRANSMOG_SET_PVE .. "" .. SLASH_EQUIP_SET1, name = "", TransportName = L["Leather Armor"] .. "\n" .. L["Heavy Armor"], type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsMailbox then
                    minimap[627][44606850] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[627][44905960] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[627][38504860] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[627][36806040] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[627][40503210] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[627][51505950] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[627][59504850] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[627][65604650] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[627][62503250] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[627][50003750] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[627][45503950] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[627][52502730] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[627][48902540] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsStablemaster then
                    minimap[627][59003860] = { dnID = MINIMAP_TRACKING_STABLEMASTER, name = "", type = "StablemasterN", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

            end

        --Transports Dalaran Legion
            if self.db.profile.activate.MinimapCapitalsTransporting then
    
                if self.db.profile.showMinimapCapitalsPortals then
                    minimap[629][30798454] = { mnID = 115, name = L["Portal"], type = "PortalS", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[629][28777742] = { mnID = 25, name = L["Portal"], type = "PortalS", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[629][31947153] = { mnID = 42, name = L["Portal"], type = "PortalS", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[629][64752082] = { mnID = 627, name = L["Portal"], type = "PortalS", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[627][49324758] = { mnID = 629, name = L["Portal"], TransportName = DUNGEON_FLOOR_DALARAN7012, type = "Portal", showInZone = false, showOnContinent = false, showOnMinimap = true }

                    if self.faction == "Horde" or db.activate.MinimapCapitalsEnemyFaction then
                        minimap[629][33557905] = { mnID = 971, name = L["Portal"], type = "HPortalS", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[627][55242392] = { mnID = 85, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. ORGRIMMAR } -- Dalaran to Orgrimmar Portal
                    end

                    if self.faction == "Alliance" or db.activate.MinimapCapitalsEnemyFaction then
                        minimap[627][40416378] = { mnID = 84,  name = "" , type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. STORMWIND } --  Dalaran to Stormwind City Portal
                    end
                end

                if self.db.profile.showMinimapCapitalsFP then
                    minimap[627][69825114] = { name = MINIMAP_TRACKING_FLIGHTMASTER, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

            end

        --Professions Dalaran Legion
            if self.db.profile.activate.MinimapCapitalsProfessions then

                if self.db.profile.showMinimapCapitalsAlchemy then
                    minimap[627][42023184] = { name = L["Alchemy"], type = "Alchemy", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end
            
                if self.db.profile.showMinimapCapitalsLeatherworking then
                    minimap[627][35102936] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsEngineer then
                    minimap[627][38552459] = { name = L["Engineer"], type = "Engineer", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsSkinning then
                    minimap[627][36082796] = { name = L["Skinning"], type = "Skinning", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsTailoring then
                    minimap[627][34993457] = { name = L["Tailoring"], type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsJewelcrafting then
                    minimap[627][40043528] = { name = L["Jewelcrafting"], type = "Jewelcrafting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsBlacksmith then
                    minimap[627][45122893] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsMining then
                    minimap[627][46102579] = { name = L["Mining"], type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsFishing then
                    minimap[627][52776559] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsHerbalism then
                    minimap[627][42363394] = { name = L["Herbalism"], type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsInscription then
                    minimap[627][41253707] = { name = INSCRIPTION, type = "Inscription", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsEnchanting then
                    minimap[627][38294031] = { name = L["Enchanting"], type = "Enchanting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsArchaeology then
                    minimap[627][41242630] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.faction == "Horde" or db.activate.MinimapCapitalsEnemyFaction then

                    if self.db.profile.showMinimapCapitalsCooking then
                        minimap[627][69973897] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION .. "\n" .. ITEM_REQ_HORDE }
                    end

                end

                if self.faction == "Alliance" or db.activate.MinimapCapitalsEnemyFaction then

                    if self.db.profile.showMinimapCapitalsCooking then
                        minimap[627][40586680] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION .. "\n" .. ITEM_REQ_ALLIANCE }
                    end

                end

            end

        end

    --##############
    --### Oribos ###
    --##############
        if self.db.profile.showMinimapCapitalsOribos then

        --Instance oribos
            if self.db.profile.activate.MinimapCapitalsInstances then

                if self.db.profile.showMinimapCapitalsLFR then
                    minimap[1670][41377150] = { mnID = 1670, name = L["Ta'elfar"] .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " ", id = { 1190, 1193, 1195 }, type = "LFR", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

            end


        --General Oribos
            if self.db.profile.activate.MinimapCapitalsGeneral then
    
                if self.db.profile.showMinimapCapitalsInnkeeper then
                    minimap[1670][67505031] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsAuctioneer then
                    minimap[1670][38374376] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = REQUIRES_LABEL .. " " .. L["Engineer"] }
                end

                if self.db.profile.showMinimapCapitalsBank then
                    minimap[1670][59502845] = { dnID = BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[1670][65033569] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsBarber then
                    minimap[1670][65096483] = { dnID = MINIMAP_TRACKING_BARBER, name = "", type = "Barber", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsPvPVendor then
                    minimap[1670][35005833] = { dnID = TRANSMOG_SET_PVP .. "" .. SLASH_EQUIP_SET1, name = "", type = "PvPVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsTransmogger then
                    minimap[1670][64416963] = { dnID = MINIMAP_TRACKING_TRANSMOGRIFIER, name = "", type = "Transmogger", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsPvEVendor then
                    minimap[1670][47497544] = { dnID = L["Quartermaster"], name = "", TransportName = GARRISON_TYPE_9_0_LANDING_PAGE_TITLE,  type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsItemUpgrade then
                    minimap[1670][34505598] = { dnID = ITEM_UPGRADE, name = "",  type = "ItemUpgrade", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsMailbox then
                    minimap[1670][30505250] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[1670][74004940] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[1670][58503680] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[1670][63505150] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsStablemaster then
                    minimap[1670][59207500] = { dnID = MINIMAP_TRACKING_STABLEMASTER, name = "", type = "StablemasterN", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

            end

        --Transports Oribos
            if self.db.profile.activate.MinimapCapitalsTransporting then
    
                if self.db.profile.showMinimapCapitalsPortals then
                    minimap[1671][49405127] = { mnID = 1543, name = "", type = "Portal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["The Maw"] } -- Oribos to The Maw
                    minimap[1671][30322269] = { mnID = 1961, name = "", type = "Portal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Korthia"] } -- Oribos to Korthia
                    minimap[1671][49532566] = { mnID = 1970, name = "", type = "Portal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Zereth Mortis"] } -- Oribos to Zereth Morthis

                    if self.faction == "Horde" or db.activate.MinimapCapitalsEnemyFaction then
                        minimap[1670][20805432] = { mnID = 85, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. ORGRIMMAR } -- Oribos to Orgrimmar Portal
                    end

                    if self.faction == "Alliance" or db.activate.MinimapCapitalsEnemyFaction then
                        minimap[1670][20654625] = { mnID = 84,  name = "" , type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. STORMWIND } -- Oribos to Stormwind City Portal
                    end
                end

                if self.db.profile.showMinimapCapitalsTransport then
                    minimap[1670][47065029] = { mnID = 1671, name = "", type = "Tport2", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Transport"] .. " ==> " .. DUNGEON_FLOOR_GILNEAS3  } -- Oribos to The Maw
                    minimap[1670][52094275] = { mnID = 1671, name = "", type = "Tport2", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Transport"] .. " ==> " .. DUNGEON_FLOOR_GILNEAS3  } -- Oribos to The Maw
                    minimap[1670][57125033] = { mnID = 1671, name = "", type = "Tport2", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Transport"] .. " ==> " .. DUNGEON_FLOOR_GILNEAS3  } -- Oribos to The Maw
                    minimap[1670][52085793] = { mnID = 1671, name = "", type = "Tport2", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Transport"] .. " ==> " .. DUNGEON_FLOOR_GILNEAS3  } -- Oribos to The Maw
                    minimap[1671][55665162] = { mnID = 1670, name = "", type = "Tport2", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Transport"] .. " ==> " .. DUNGEON_FLOOR_GILNEAS2  } -- Oribos to The Maw
                    minimap[1671][49536090] = { mnID = 1670, name = "", type = "Tport2", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Transport"] .. " ==> " .. DUNGEON_FLOOR_GILNEAS2  } -- Oribos to The Maw
                    minimap[1671][43415157] = { mnID = 1670, name = "", type = "Tport2", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Transport"] .. " ==> " .. DUNGEON_FLOOR_GILNEAS2  } -- Oribos to The Maw
                    minimap[1671][49554241] = { mnID = 1670, name = "", type = "Tport2", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Transport"] .. " ==> " .. DUNGEON_FLOOR_GILNEAS2  } -- Oribos to The Maw
                end

                if self.db.profile.showMinimapCapitalsFP then
                    minimap[1671][60196756] = { name = MINIMAP_TRACKING_FLIGHTMASTER, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

            end

        --Professions Oribos
            if self.db.profile.activate.MinimapCapitalsProfessions then

                if self.db.profile.showMinimapCapitalsAlchemy then
                    minimap[1670][39284044] = { name = L["Alchemy"], type = "Alchemy", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end
            
                if self.db.profile.showMinimapCapitalsLeatherworking then
                    minimap[1670][42342642] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsEngineer then
                    minimap[1670][38114472] = { name = L["Engineer"], type = "Engineer", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsSkinning then
                    minimap[1670][42072813] = { name = L["Skinning"], type = "Skinning", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsTailoring then
                    minimap[1670][45553182] = { name = L["Tailoring"], type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsJewelcrafting then
                    minimap[1670][35164127] = { name = L["Jewelcrafting"], type = "Jewelcrafting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsBlacksmith then
                    minimap[1670][40563139] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsMining then
                    minimap[1670][39313292] = { name = L["Mining"], type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsFishing then
                    minimap[1670][46162635] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsCooking then
                    minimap[1670][46812266] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsHerbalism then
                    minimap[1670][40303824] = { name = L["Herbalism"], type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsInscription then
                    minimap[1670][36473666] = { name = INSCRIPTION, type = "Inscription", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsEnchanting then
                    minimap[1670][48422949] = { name = L["Enchanting"], type = "Enchanting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

            end

        end

    --##################
    --### Valdrakken ###
    --##################
        if self.db.profile.showMinimapCapitalsValdrakken then

        --General Valdrakken
            if self.db.profile.activate.MinimapCapitalsGeneral then
    
                if self.db.profile.showMinimapCapitalsInnkeeper then
                    minimap[2112][47714635] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsAuctioneer then
                    minimap[2112][42705981] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[2112][16705185] = { dnID = BLACK_MARKET_AUCTION_HOUSE, name = "", type = "BlackMarket", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsBank then
                    minimap[2112][60325544] = { dnID = BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[2112][58275451] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsBarber then
                    minimap[2112][28714859] = { dnID = MINIMAP_TRACKING_BARBER, name = "", type = "Barber", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsMailbox then
                    minimap[2112][45695912] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[2112][48475136] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[2112][35555959] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[2112][14185498] = { dnID = MINIMAP_TRACKING_MAILBOX .. " " .. "(" .. HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_DOWN .. ")", name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsPvPVendor then
                    minimap[2112][44083636] = { dnID = TRANSMOG_SET_PVP .. "" .. SLASH_EQUIP_SET1, name = "", type = "PvPVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsTransmogger then
                    minimap[2112][74575782] = { dnID = MINIMAP_TRACKING_TRANSMOGRIFIER, name = "", type = "Transmogger", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsItemUpgrade then
                    minimap[2112][45753885] = { dnID = ITEM_UPGRADE, name = "",  type = "ItemUpgrade", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[2112][45545624] = { dnID = ITEM_UPGRADE, name = "",  type = "ItemUpgrade", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsDragonFlyTransmog then
                    minimap[2112][25035064] = { dnID = MINIMAP_TRACKING_TRANSMOGRIFIER .. " " .. MOUNT_JOURNAL_FILTER_DRAGONRIDING, name = "",  type = "DragonFlyTransmog", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsStablemaster then
                    minimap[2112][46807880] = { dnID = MINIMAP_TRACKING_STABLEMASTER, name = "", type = "StablemasterN", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsTradingPost then
                    minimap[2339][44645607] = { dnID = BATTLE_PET_SOURCE_12, name = "",  type = "TradingPost", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

            end

        --Transports Valdrakken
            if self.db.profile.activate.MinimapCapitalsTransporting then
    
                if self.db.profile.showMinimapCapitalsPortals then
                    minimap[2112][26104102] = { mnID = 15, name = "", type = "Portal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Badlands"] } --  Portal from Valdrakken to the Badlands
                    minimap[2112][62725732] = { mnID = 2200, name = "", type = "Portal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Emerald Dream"] } --  Portal from Valdrakken to The Emerald Dream

                    if self.faction == "Horde" or db.activate.MinimapCapitalsEnemyFaction then
                        minimap[2112][56593828] = { mnID = 85, name = L["(inside building)"], type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. ORGRIMMAR } -- Valdrakken to Orgrimmar Portal
                    end

                    if self.faction == "Alliance" or db.activate.MinimapCapitalsEnemyFaction then
                        minimap[2112][59804169] = { mnID = 84,  name = L["(inside building)"], type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. STORMWIND } -- Valdrakken to Stormwind City Portal
                    end
                end

                if self.db.profile.showMinimapCapitalsFP then
                    minimap[2112][44476790] = { name = MINIMAP_TRACKING_FLIGHTMASTER, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

            end

        --Professions Valdrakken
            if self.db.profile.activate.MinimapCapitalsProfessions then

                if self.db.profile.showMinimapCapitalsProfessionOrders then
                    minimap[2112][34796252] = { name = PLACE_CRAFTING_ORDERS, type = "ProfessionOrders", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsAlchemy then
                    minimap[2112][36417170] = { name = L["Alchemy"], type = "Alchemy", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end
            
                if self.db.profile.showMinimapCapitalsLeatherworking then
                    minimap[2112][28616157] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsEngineer then
                    minimap[2112][42254861] = { name = L["Engineer"], type = "Engineer", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsSkinning then
                    minimap[2112][28606008] = { name = L["Skinning"], type = "Skinning", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsTailoring then
                    minimap[2112][32026629] = { name = L["Tailoring"], type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsJewelcrafting then
                    minimap[2112][40486141] = { name = L["Jewelcrafting"], type = "Jewelcrafting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsBlacksmith then
                    minimap[2112][36864659] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsMining then
                    minimap[2112][38885143] = { name = L["Mining"], type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsFishing then
                    minimap[2112][44847471] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsCooking then
                    minimap[2112][46494625] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsHerbalism then
                    minimap[2112][337626892] = { name = L["Herbalism"], type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsInscription then
                    minimap[2112][38847338] = { name = INSCRIPTION, type = "Inscription", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsEnchanting then
                    minimap[2112][31076137] = { name = L["Enchanting"], type = "Enchanting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

            end

        end

    --################
    --### Darkmoon ###
    --################
        if self.db.profile.showMinimapCapitalsDarkmoon then

        --General Darkmoon
            if self.db.profile.activate.MinimapCapitalsGeneral then
    
                if self.db.profile.showMinimapCapitalsPvEVendor then
                    minimap[407][48246955] = { dnID = TRANSMOG_SET_PVE .. " " .. MERCHANT .. "\n" .. "\n" .. ACCESSIBILITY_MOUNT_LABEL .. "\n" .. PERKS_VENDOR_CATEGORY_PET, name = "", type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[407][51447510] = { dnID = TRANSMOG_SET_PVE .. " " .. MERCHANT .. "\n" .. "\n" .. PERKS_VENDOR_CATEGORY_TRANSMOG_SET, name = "", type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[407][48096567] = { dnID = TRANSMOG_SET_PVE .. " " .. MERCHANT .. "\n" .. "\n" .. HEIRLOOMS .. "\n" ..  BAG_FILTER_EQUIPMENT .. "\n" .. TOY, name = "", type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

            end

        --Transports Darkmoon
            if self.db.profile.activate.MinimapCapitalsTransporting then

                if self.db.profile.showMinimapCapitalsPortals then

                    if db.activate.MinimapCapitalsEnemyFaction then
                        minimap[407][51412247] = { name = L["Exit"], type = "Portal", mnID = 7, mnID2 = 37, showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = FACTION_HORDE .. " ==> " .. DUNGEON_FLOOR_NIGHTMARERAID3 .. "\n" .. FACTION_ALLIANCE .. " ==> " .. POSTMASTER_LETTER_ELWYNNFOREST}
                        minimap[407][50549077] = { name = L["Exit"], type = "Portal", mnID = 7, mnID2 = 37, showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = FACTION_HORDE .. " ==> " .. DUNGEON_FLOOR_NIGHTMARERAID3 .. "\n" .. FACTION_ALLIANCE .. " ==> " .. POSTMASTER_LETTER_ELWYNNFOREST}
                    end
                
                    if self.faction == "Horde" and not db.activate.MinimapCapitalsEnemyFaction then
                        minimap[407][51412247] = { mnID = 7, name = L["Portal"], type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[407][50549077] = { mnID = 7, name = L["Portal"], type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.faction == "Alliance" and not db.activate.MinimapCapitalsEnemyFaction then
                        minimap[407][51412247] = { mnID = 37, name = L["Portal"], type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[407][50549077] = { mnID = 37, name = L["Portal"], type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end

            end

        --Professions Darkmoon
            if self.db.profile.activate.MinimapCapitalsProfessions then

                if self.db.profile.showMinimapCapitalsProfessionsMixed then
                    
                    if self.db.profile.showMinimapCapitalsMining and self.db.profile.showMinimapCapitalsLeatherworking and not self.db.profile.showMinimapCapitalsEngineer then
                        minimap[407][49256078] = { name = "", dnID = TextIconMining:GetIconString() .. " " .. L["Mining"] .. "\n" .. TextIconLeatherworking:GetIconString() .. " " .. L["Leatherworking"], TransportName = TUTORIAL_TITLE1, type = "ProfessionsMixed", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    elseif self.db.profile.showMinimapCapitalsMining and self.db.profile.showMinimapCapitalsEngineer and not self.db.profile.showMinimapCapitalsLeatherworking then
                        minimap[407][49256078] = { name = "", dnID = TextIconMining:GetIconString() .. " " .. L["Mining"] .. "\n" .. TextIconEngineer:GetIconString() .. " " .. L["Engineer"], TransportName = TUTORIAL_TITLE1, type = "ProfessionsMixed", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    elseif self.db.profile.showMinimapCapitalsLeatherworking and self.db.profile.showMinimapCapitalsEngineer and not self.db.profile.showMinimapCapitalsMining then
                        minimap[407][49256078] = { name = "", dnID = TextIconLeatherworking:GetIconString() .. " " .. L["Leatherworking"] .. "\n" .. TextIconEngineer:GetIconString() .. " " .. L["Engineer"], TransportName = TUTORIAL_TITLE1, type = "ProfessionsMixed", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    elseif self.db.profile.showMinimapCapitalsMining and self.db.profile.showMinimapCapitalsLeatherworking and self.db.profile.showMinimapCapitalsEngineer then
                        minimap[407][49256078] = { name = "", dnID = TextIconMining:GetIconString() .. " " .. L["Mining"] .. "\n" .. TextIconLeatherworking:GetIconString() .. " " .. L["Leatherworking"] .. "\n" .. TextIconEngineer:GetIconString() .. " " .. L["Engineer"], TransportName = TUTORIAL_TITLE1, type = "ProfessionsMixed", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    elseif self.db.profile.showMinimapCapitalsMining and not (self.db.profile.showMinimapCapitalsLeatherworking and self.db.profile.showMinimapCapitalsEngineer) then
                        minimap[407][49446141] = { name = L["Mining"], type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = TUTORIAL_TITLE1 }
                    elseif self.db.profile.showMinimapCapitalsLeatherworking and not (self.db.profile.showMinimapCapitalsMining and self.db.profile.showMinimapCapitalsEngineer) then
                        minimap[407][49406080] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = TUTORIAL_TITLE1 }
                    elseif self.db.profile.showMinimapCapitalsEngineer and not (self.db.profile.showMinimapCapitalsLeatherworking and self.db.profile.showMinimapCapitalsMining) then
                        minimap[407][49406081] = { name = L["Engineer"], type = "Engineer", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = TUTORIAL_TITLE1 }
                    end

                    if self.db.profile.showMinimapCapitalsSkinning and self.db.profile.showMinimapCapitalsHerbalism and not self.db.profile.showMinimapCapitalsJewelcrafting then
                        minimap[407][55007061] = { name = "", dnID = TextIconSkinning:GetIconString() .. " " .. L["Skinning"] .. "\n" .. TextIconHerbalism:GetIconString() .. " " .. L["Herbalism"], TransportName = TUTORIAL_TITLE1, type = "ProfessionsMixed", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    elseif self.db.profile.showMinimapCapitalsSkinning and self.db.profile.showMinimapCapitalsJewelcrafting and not self.db.profile.showMinimapCapitalsHerbalism then
                        minimap[407][55007061] = { name = "", dnID = TextIconSkinning:GetIconString() .. " " .. L["Skinning"] .. "\n" .. TextIconJewelcrafting:GetIconString() .. " " .. L["Jewelcrafting"], TransportName = TUTORIAL_TITLE1, type = "ProfessionsMixed", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    elseif self.db.profile.showMinimapCapitalsJewelcrafting and self.db.profile.showMinimapCapitalsHerbalism and not self.db.profile.showMinimapCapitalsSkinning then
                        minimap[407][55007061] = { name = "", dnID = TextIconJewelcrafting:GetIconString() .. " " .. L["Jewelcrafting"] .. "\n" .. TextIconHerbalism:GetIconString() .. " " .. L["Herbalism"], TransportName = TUTORIAL_TITLE1, type = "ProfessionsMixed", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    elseif self.db.profile.showMinimapCapitalsJewelcrafting and self.db.profile.showMinimapCapitalsHerbalism and self.db.profile.showMinimapCapitalsSkinning then
                        minimap[407][55007061] = { name = "", dnID = TextIconJewelcrafting:GetIconString() .. " " .. L["Jewelcrafting"] .. "\n" .. TextIconHerbalism:GetIconString() .. " " .. L["Herbalism"] .. "\n" .. TextIconSkinning:GetIconString() .. " " .. L["Skinning"], TransportName = TUTORIAL_TITLE1, type = "ProfessionsMixed", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    elseif self.db.profile.showMinimapCapitalsSkinning and not (self.db.profile.showMinimapCapitalsHerbalism and self.db.profile.showMinimapCapitalsJewelcrafting) then
                        minimap[407][55007060] = { name = L["Skinning"], type = "Skinning", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = TUTORIAL_TITLE1 }
                    elseif self.db.profile.showMinimapCapitalsHerbalism and not (self.db.profile.showMinimapCapitalsSkinning and self.db.profile.showMinimapCapitalsJewelcrafting) then
                        minimap[407][55007060] = { name = L["Herbalism"], type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = TUTORIAL_TITLE1 }
                    elseif self.db.profile.showMinimapCapitalsJewelcrafting and not (self.db.profile.showMinimapCapitalsSkinning and self.db.profile.showMinimapCapitalsHerbalism) then
                        minimap[407][55007060] = { name = L["Jewelcrafting"], type = "Jewelcrafting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = TUTORIAL_TITLE1 }
                    end

                    if self.db.profile.showMinimapCapitalsCooking and self.db.profile.showMinimapCapitalsFishing then
                        minimap[407][52606801] = { name = "", dnID = TextIconFishing:GetIconString() .. " " .. PROFESSIONS_FISHING .. "\n" .. TextIconCooking:GetIconString() .. " " .. PROFESSIONS_COOKING, TransportName = TUTORIAL_TITLE1, type = "ProfessionsMixed", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    elseif self.db.profile.showMinimapCapitalsCooking and not self.db.profile.showMinimapCapitalsFishing then
                        minimap[407][52606801] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = TUTORIAL_TITLE1 }
                    elseif self.db.profile.showMinimapCapitalsFishing and not self.db.profile.showMinimapCapitalsCooking then
                        minimap[407][52606801] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = TUTORIAL_TITLE1 }
                    end

                end

                if not self.db.profile.showMinimapCapitalsProfessionsMixed then

                    if self.db.profile.showMinimapCapitalsMining then
                        minimap[407][49446141] = { name = L["Mining"], type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = TUTORIAL_TITLE1 }
                    end

                    if self.db.profile.showMinimapCapitalsLeatherworking then
                        minimap[407][49406080] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = TUTORIAL_TITLE1 }
                    end

                    if self.db.profile.showMinimapCapitalsEngineer  then
                        minimap[407][49406081] = { name = L["Engineer"], type = "Engineer", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = TUTORIAL_TITLE1 }
                    end

                    if self.db.profile.showMinimapCapitalsSkinning then
                        minimap[407][48197805] = { name = L["Skinning"], type = "Skinning", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = TUTORIAL_TITLE1 }
                    end                    

                    if self.db.profile.showMinimapCapitalsJewelcrafting then
                        minimap[407][55007060] = { name = L["Jewelcrafting"], type = "Jewelcrafting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = TUTORIAL_TITLE1 }
                    end   

                    if self.db.profile.showMinimapCapitalsHerbalism then
                        minimap[407][55017052] = { name = L["Herbalism"], type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = TUTORIAL_TITLE1 }
                    end    
                
                    if self.db.profile.showMinimapCapitalsCooking then
                        minimap[407][52606800] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = TUTORIAL_TITLE1 }
                    end

                    if self.db.profile.showMinimapCapitalsFishing then
                        --minimap[407][52608860] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                        minimap[407][52606800] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = TUTORIAL_TITLE1 }
                    end

                end

                if self.db.profile.showMinimapCapitalsAlchemy then
                    minimap[407][50206940] = { name = L["Alchemy"], type = "Alchemy", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = TUTORIAL_TITLE1 }
                end

                if self.db.profile.showMinimapCapitalsTailoring then
                    minimap[407][55805440] = { name = L["Tailoring"], type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = TUTORIAL_TITLE1 }
                end

                if self.db.profile.showMinimapCapitalsBlacksmith then
                    minimap[407][51008180] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = TUTORIAL_TITLE1 }
                end

                if self.db.profile.showMinimapCapitalsInscription then
                    minimap[407][53007580] = { name = INSCRIPTION, type = "Inscription", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = TUTORIAL_TITLE1 }
                end

                if self.db.profile.showMinimapCapitalsEnchanting then
                    minimap[407][53007580] = { name = L["Enchanting"], type = "Enchanting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = TUTORIAL_TITLE1 }
                end

                if self.db.profile.showMinimapCapitalsArchaeology then
                    minimap[407][51836072] = { name = PROFESSIONS_ARCHAEOLOGY, type = "Archaeology", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = TUTORIAL_TITLE1 }
                end

            end

        end

    --################
    --### Dornogal ###
    --################
        if self.db.profile.showMinimapCapitalsDornogal then

        --Instances Orgrimmar
            if self.db.profile.activate.MinimapCapitalsInstances then

                if self.db.profile.showMinimapCapitalsDungeons then
                    minimap[2339][31893565] = { id = 1268, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Rookery
                end

            end

        --General Dornogal
            if self.db.profile.activate.MinimapCapitalsGeneral then

                if self.db.profile.showMinimapCapitalsPaths then
                    minimap[2339][81782819] = { dnID = L["Exit"], name = "", mnID = 2248, type = "PathR", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                    minimap[2339][68588953] = { dnID = L["Exit"], name = "", mnID = 2248, type = "PathRU", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                    minimap[2339][35875875] = { dnID = L["Passage"], name = "", mnID = 2214, type = "PassageCaveDown", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit
                end
    
                if self.db.profile.showMinimapCapitalsInnkeeper then
                    minimap[2339][44754642] = { dnID = MINIMAP_TRACKING_INNKEEPER, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsAuctioneer then
                    minimap[2339][56864704] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[2339][64975294] = { dnID = BLACK_MARKET_AUCTION_HOUSE, name = "", type = "BlackMarket", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsBank then
                    minimap[2339][52924479] = { dnID = BANK .. " / " .. GUILD_BANK , name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsBarber then
                    minimap[2339][58645176] = { dnID = MINIMAP_TRACKING_BARBER, name = "", type = "Barber", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsMailbox then
                    minimap[2339][45384833] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[2339][51584595] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[2339][55645000] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[2339][58125558] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[2339][45766879] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[2339][37644081] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[2339][48422523] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[2339][58153236] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[2339][63584966] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsPvPVendor then
                    minimap[2339][60377017] = { dnID = TRANSMOG_SET_PVP .. " " .. MERCHANT, name = "", TransportName = PVP_LABEL_WAR_MODE, type = "PvPVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[2339][59696906] = { dnID = TRANSMOG_SET_PVP .. " " .. MERCHANT, name = "", TransportName = ELITE .. " " .. L["Quartermaster"],  type = "PvPVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[2339][55677618] = { dnID = TRANSMOG_SET_PVP .. " " .. MERCHANT, name = "", TransportName = PVP_LABEL_WAR_MODE .. " " .. L["Quartermaster"] .. "\n" .. HONOR_POINTS .. " " .. L["Quartermaster"] .. "\n" .. HONOR_POINTS .. " " .. AUCTION_CATEGORY_RECIPES,  type = "PvPVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsPvEVendor then
                    minimap[2339][39092418] = { dnID = L["Merchant for Renown items"], name = L["Council of Dornogal"], type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    --minimap[2339][39092418] = { dnID = L["Merchant for Renown items"], name = "", TransportName = L["Council of Dornogal"] .. "\n" .. L["The Assembly of the Deeps"] .. "\n" .. L["Hallowfall Arathi"], type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[2339][47834448] = { dnID = TRANSMOG_SET_PVE .. " " .. MERCHANT, name = "", TransportName = L["Quartermaster"],  type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsTransmogger then
                    minimap[2339][45835331] = { dnID = MINIMAP_TRACKING_TRANSMOGRIFIER, name = "", TransportName = MERCHANT, type = "Transmogger", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[2339][58644933] = { dnID = MINIMAP_TRACKING_TRANSMOGRIFIER, name = "", type = "Transmogger", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsItemUpgrade then
                    minimap[2339][59627029] = { dnID = ITEM_UPGRADE, name = "",  type = "ItemUpgrade", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[2339][51944206] = { dnID = ITEM_UPGRADE, name = "",  type = "ItemUpgrade", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsDragonFlyTransmog then
                    minimap[2339][47996786] = { dnID = MINIMAP_TRACKING_TRANSMOGRIFIER .. " " .. MOUNT_JOURNAL_FILTER_DRAGONRIDING, name = "",  type = "DragonFlyTransmog", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsCatalyst then
                    minimap[2339][50005430] = { dnID = L["Catalyst"], name = "",  type = "Catalyst", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsStablemaster then
                    minimap[2339][55356711] = { dnID = MINIMAP_TRACKING_STABLEMASTER, name = "", type = "StablemasterN", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

            end

        --Transports Dornogal
            if self.db.profile.activate.MinimapCapitalsTransporting then
    
                if self.db.profile.showMinimapCapitalsPortals then
                    minimap[2266][43564994] = { mnID = 2112, name = "", type = "Portal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Dornogal"] } --  Timeways Portal to Dornogal
                    minimap[2266][64534340] = { mnID = 1565, name = "", type = "WayGateGolden", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Ardenweald"] } --  Timeways Portal to Aredenweald
                    minimap[2266][74524703] = { mnID = 1533, name = "", type = "WayGateGolden", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Bastion"] } --  Timeways Portal to Bastion
                    --minimap[2266][77536180] = { name = "", type = "WayGateGolden", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. UNKNOWN } --  Timeways Portal to Val'sharah
                    minimap[2266][70537306] = { mnID = 895, name = "", type = "WayGateGolden", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Tiragarde Sound"] } --  Timeways Portal to Tiragarde Sound
                    minimap[2266][60506950] = { mnID = 241, name = "", type = "WayGateGolden", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portal"] .. " ==> " .. L["Twilight Highlands"] } --  Timeways Portal to Twilight Highlands
                    minimap[2339][53563873] = { mnID = 2266, name = "", type = "WayGateGolden", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["The Timeways"] .. " " .. L["Portals"] .. "\n" .. "\n" .. " ==> " .. L["Ardenweald"] .. "\n" .. " ==> " .. L["Bastion"] .. "\n" .. " ==> " .. L["Tiragarde Sound"] .. "\n" .. " ==> " .. L["Twilight Highlands"] } --  Portal from Dornogal to the Timeways
                    minimap[2339][63615205] = { mnID = 2255, name = L["Portal"], dnID = "", achievementID = 19559, showWWW = true, wwwName = LOOT_JOURNAL_LEGENDARIES_SOURCE_ACHIEVEMENT .. " " .. REQUIRES_LABEL, wwwLink = "https://www.wowhead.com/achievement=19559/azj-kahet#news", type = "Portal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal from Dornogal to Azj-Kahet if u finished the achievement=19559
                    minimap[2339][29775967] = { mnID = 2367, name = L["Portal"], dnID = "", achievementID = 40725, showWWW = true, wwwName = LOOT_JOURNAL_LEGENDARIES_SOURCE_ACHIEVEMENT .. " " .. REQUIRES_LABEL, wwwLink = "https://wowhead.com/achievement=40725", type = "Portal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Chamber of Memory
                    minimap[2339][52465047] = { mnID = 2346, name = L["Portal"], dnID = "", showWWW = true, wwwName = LOOT_JOURNAL_LEGENDARIES_SOURCE_ACHIEVEMENT .. " " .. REQUIRES_LABEL, wwwLink = "https://wowhead.com/quest=86535/test-run", questID = 86535, type = "Portal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal from Dornogal to Undermine

                    if self.faction == "Horde" or db.activate.MinimapCapitalsEnemyFaction then
                        minimap[2339][38192724] = { mnID = 85, name = L["Portal"], dnID = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dornogal to Orgrimmar
                    end

                    if self.faction == "Alliance" or db.activate.MinimapCapitalsEnemyFaction then
                        minimap[2339][41162271] = { mnID = 84, name = L["Portal"], dnID = "", type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dornogal to Stormwind
                    end
                end

                if self.db.profile.showMinimapCapitalsZeppelins then
                    minimap[2339][73540516] = { mnID = 2369, name = "", type = "Zeppelin", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Zeppelin"] .. " ==> " .. L["Siren Isle"] } -- Zeppelin from OG to Borean Tundra - Northrend
                end

                if self.db.profile.showMinimapCapitalsTransport then
                    minimap[2339][40722239] = { name = "", type = "Tport2", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Transport"] .. " ==> " .. L["(on the tower)"]  } -- Oribos to The Maw
                end

                if self.db.profile.showMinimapCapitalsFP then
                    minimap[2339][44695114] = { name = MINIMAP_TRACKING_FLIGHTMASTER, type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

            end

        --Professions Dornogal
            if self.db.profile.activate.MinimapCapitalsProfessions then

                if self.db.profile.showMinimapCapitalsProfessionOrders then
                    minimap[2339][58015644] = { name = PLACE_CRAFTING_ORDERS, type = "ProfessionOrders", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsAlchemy then
                    minimap[2339][47367039] = { name = L["Alchemy"], type = "Alchemy", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end
            
                if self.db.profile.showMinimapCapitalsLeatherworking then
                    minimap[2339][54455884] = { name = L["Leatherworking"], type = "Leatherworking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsEngineer then
                    minimap[2339][49215630] = { name = L["Engineer"], type = "Engineer", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsSkinning then
                    minimap[2339][54435714] = { name = L["Skinning"], type = "Skinning", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsTailoring then
                    minimap[2339][54786364] = { name = L["Tailoring"], type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsJewelcrafting then
                    minimap[2339][49827116] = { name = L["Jewelcrafting"], type = "Jewelcrafting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsBlacksmith then
                    minimap[2339][49286338] = { name = L["Blacksmithing"], type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsMining then
                    minimap[2339][52635272] = { name = L["Mining"], type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsFishing then
                    minimap[2339][50542691] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsCooking then
                    minimap[2339][44084575] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsHerbalism then
                    minimap[2339][45696965] = { name = L["Herbalism"], type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsInscription then
                    minimap[2339][48757117] = { name = INSCRIPTION, type = "Inscription", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

                if self.db.profile.showMinimapCapitalsEnchanting then
                    minimap[2339][52817116] = { name = L["Enchanting"], type = "Enchanting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = MINIMAP_TRACKING_TRAINER_PROFESSION }
                end

            end

        end

    end
end
end