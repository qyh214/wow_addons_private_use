local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

function ns.LoadMinimapCapitalsLocationinfo(self)
local db = ns.Addon.db.profile
local minimap = ns.minimap
ns.currentSourceFile = "RetailCapitalsMinimap.lua"

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
                        minimap[85][55684575] = { npcID = 3347, name = "", type = "Alchemy", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end
                
                    if self.db.profile.showMinimapCapitalsLeatherworking then
                        minimap[85][60595535] = { npcID = 3365, name = "", type = "Leatherworking", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsEngineer then
                        minimap[85][57105622] = { npcID = 11017, name = "", type = "Engineer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][37058474] = { npcID = 45545, name = "", type = "Engineer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsSkinning then
                        minimap[85][61385421] = { npcID = 3365, name = "", type = "Skinning", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][39614985] = { npcID = 44782, name = "", type = "Skinning", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsTailoring then
                        minimap[85][60755912] = { npcID = 3363, name = "", type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true  }
                        minimap[85][38865090] = { npcID = 44783, name = "", type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][38228718] = { npcIDs1 = 133239, npcIDs2 = 133109, name = "", type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsJewelcrafting then
                        minimap[85][72673406] = { npcID = 46675, name = "", type = "Jewelcrafting", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsBlacksmith then
                        minimap[85][76523449] = { npcID = 3355, name = "", type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][75893361] = { npcID = 11178, name = "", type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][76413710] = { npcID = 7231, name = "", type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][75813716] = { npcID = 7230, name = "", type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][75313403] = { npcID = 11177, name = "", type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][40735007] = { npcID = 44781, name = "", type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][44237719] = { npcID = 37072, name = "", type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsMining then
                        minimap[85][39058556] = { npcID = 133236, name = "", type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][44547839] = { npcID = 46357, name = "", type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][72343537] = { npcID = 3357, name = "", type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsFishing then
                        minimap[85][66434193] = { npcID = 3332, name = "", type = "Fishing", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][35196733] = { npcID = 44975, name = "", type = "Fishing", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsCooking then
                        minimap[85][56376139] = { npcID = 46709, name = "", type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][41147895] = { npcID = 133261, name = "", type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][32256966] = { npcID = 3399, name = "", type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsArchaeology then
                        minimap[85][49277069] = { npcID = 47571, name = "", type = "Archaeology", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsHerbalism then
                        minimap[85][54895027] = { npcID = 46741, name = "", type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][34836286] = { npcID = 29143, name = "", type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][40178060] = { npcID = 133104, name = "", type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsEnchanting then
                        minimap[85][53404929] = { npcID = 3345, name = "", type = "Enchanting", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsInscription then
                        minimap[85][55115586] = { npcID = 46716, name = "", type = "Inscription", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end

            --Transports Orgrimmar
                if self.db.profile.activate.MinimapCapitalsTransporting then

                    if self.db.profile.showMinimapCapitalsPortals then
                        minimap[85][54589038] = { mnID = 110, name = "", TransportName = ns.Silvermoon .. " (" .. L["Portal"] .. ")\n(" .. L["in the basement"] .. ")", type = "HPortalSGray", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Silvermoon City
                        minimap[85][57268817] = { mnID = 630, name = "", TransportName = ns.Azsuna .. " (" .. L["Portal"] .. ")\n(" .. L["in the basement"] .. ")", type = "HPortalSGray", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Azsuna 
                        minimap[85][57878982] = { mnID = 862, name = "", TransportName = ns.Zuldazar .. " (" .. L["Portal"] .. ")\n(" .. L["in the basement"] .. ")", type = "HPortalSGray", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Zuldazar  
                        minimap[85][57519166] = { mnID = 111, name = "", TransportName = ns.Shattrath .. " (" .. L["Portal"] .. ")\n(" .. L["in the basement"] .. ")", type = "HPortalSGray", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Shattrath 
                        minimap[85][56419258] = { mnID = 74, name = "", TransportName = ns.CavernsOfTime .. " (" .. L["Portal"] .. ")\n(" .. L["in the basement"] .. ")", type = "HPortalSGray", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Caverns of Time 
                        minimap[85][55189204] = { mnID = 624, name = "", TransportName = ns.Warspear .. " (" .. L["Portal"] .. ")\n(" .. L["in the basement"] .. ")", type = "HPortalSGray", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Warspear - Ashran 
                        minimap[85][57179070] = { npcID = 150131, mnID = 17, name = "", TransportName = ns.DarkPortal .. " (" .. L["Portal"] .. ")\n(" .. L["in the basement"] .. ")", type = "HPortalSGray", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Blasted Lands

                        minimap[85][57108729] = { mnID = 2112, name = "", type = "HPortalS", showInZone = false, showOnContinent = false, showOnMinimap = true } --  Valdrakken 
                        minimap[85][58308788] = { mnID = 1670, name = "", type = "HPortalS", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Oribos 
                        minimap[85][58968953] = { mnID = 2351, name = "", type = "HPortalS", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Razorwind 
                        minimap[85][58599135] = { mnID = 2339, name = "", type = "HPortalS", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dornogal
                        minimap[85][57479225] = { mnID = 371, name = "", type = "HPortalS", showInZone = false, showOnContinent = false, showOnMinimap = true } -- The Jade Forest 
                        minimap[85][56219180] = { mnID = 125, name = "", TransportName = ns.Dalaran .. " (" .. ns.Northrend .. " " .. L["Portal"] ..")", type = "HPortalS", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Crystalsong Forest (Old Dalaran) Portalroom 
                        
                        minimap[85][50765561] = { mnID = 18, name = "", TransportName = ns.RuinsofLordaeron .. " (" .. L["Portal"] ..")", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ruins of Lordaeron 
                        minimap[85][47393928] = { mnID = 245, name = "", type = "HPortalS", showInZone = false, showOnContinent = false, showOnMinimap = true } --  Portal to Tol Barad
                        minimap[85][48863851] = { mnID = 1527, name = "", type = "HPortalS", showInZone = false, showOnContinent = false, showOnMinimap = true} -- Portal to Uldum
                        minimap[85][50243944] = { mnID = 241, name = "", type = "HPortalS", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal to Twilight Highlands
                        minimap[85][51203832] = { mnID = 198, name = "", type = "HPortalS", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal to Hyjal
                        minimap[85][50863628] = { mnID = 207, name = "", type = "HPortalS", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal to Deepholm
                        minimap[85][49203647] = { mnID = 203, name = "", type = "HPortalS", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal to Vashjir
                        minimap[85][48236216] = { npcID = 55382, mnID = 7, name = "", TransportName = CALENDAR_FILTER_DARKMOON .. " (" .. L["Transport"] .. " / " .. L["Portal"] .. ")\n\n" .. REQUIRES_LABEL .. " " .. CALENDAR_FILTER_DARKMOON .. "\n" .. L["Starting on the first Sunday of each month for one week"], type = "DarkMoon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal Darkmoon
                        minimap[85][38607586] = { mnID = 680, name ="", type = "HPortalS", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal to Night Fortress
                        minimap[85][38167527] = { mnID = 652, name ="", type = "HPortalS", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal to Thundertotem
                        minimap[85][37437619] = { mnID = 2322, name = "", type = "HPortalS", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hall of Awakening
                    end

                    if self.db.profile.showMinimapCapitalsZeppelins then
                        minimap[85][44496228] = { mnID = 114, name = "", TransportName = POSTMASTER_LETTER_WARSONGHOLD .. " (" .. L["Zeppelin"] ..")", type = "HZeppelin", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Zeppelin from OG to Borean Tundra - Northrend
                        minimap[85][42796534] = { mnID = 88, name = "", type = "HZeppelin", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Zeppelin from OG to Thunder Bluff
                        minimap[85][52275315] = { mnID = 50, name = "", TransportName = ns.Gromgol .. " (" .. L["Zeppelin"] ..")", type = "HZeppelin", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Zeppelin from OG to Stranglethorn
                    end

                    if self.db.profile.showMinimapCapitalsFP then
                        minimap[85][49705919] = { npcID = 3310, name = "", type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end
    
                end
    
            --Instances Orgrimmar
                if self.db.profile.activate.MinimapCapitalsInstances then
    
                    if self.db.profile.showMinimapCapitalsDungeons then
                        minimap[86][66715154] = { id = 226, type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ragefire - Chasm of shadows
                    end

                    if self.db.profile.showMinimapCapitalsDungeons and db.activate.noPassages then
                        minimap[85][51685850] = { id = 226, TransportName = L["in the basement"], type = "Dungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ragefire
                    end

                    if self.db.profile.showMinimapCapitalsInstancePassage and not db.activate.noPassages then
                       minimap[85][55895097] = { mnID = 86, id = 226, TransportName = L["Way to the Instance Entrance"], name = "", type = "PassageDungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ragefire   
                       minimap[85][46116716] = { mnID = 86, id = 226, TransportName = L["Way to the Instance Entrance"], name = "", type = "PassageDungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ragefire  
                       minimap[85][42396160] = { mnID = 86, id = 226, TransportName = L["Way to the Instance Entrance"], name = "", type = "PassageDungeon", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ragefire    
                    end

                end

            --General Orgrimmar
                if self.db.profile.activate.MinimapCapitalsGeneral then

                    if self.db.profile.showMinimapCapitalsInnkeeper or self.db.profile.showMinimapCapitalsAuctioneer or self.db.profile.showMinimapCapitalsMailbox or self.db.profile.showMinimapCapitalsStablemaster or self.db.profile.showMinimapCapitalsBank then
                        minimap[85][32916483] = { npcIDs1 = 45086, npcIDs2 = 9988, npcIDs3 = 45081, npcIDs10 = 45082, dnID = BUTTON_LAG_AUCTIONHOUSE .. "\n" .. "\n" .. MINIMAP_TRACKING_MAILBOX, name = "",  type = "MNL", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

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
                        minimap[85][53637877] = { npcID = 6929, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][41068007.01] = { npcID = 45563, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][38854865] = { npcID = 44785, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][71304995] = { npcID = 46642, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsAuctioneer then
                        minimap[85][53957324] = { npcIDs1 = 44865, npcIDs2 = 44867, npcIDs3 = 44866, npcIDs4 = 44868, name = BUTTON_LAG_AUCTIONHOUSE, type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][35847732] = { npcID = 45659, name = BUTTON_LAG_AUCTIONHOUSE, type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][41674889] = { npcID = 44787, name = BUTTON_LAG_AUCTIONHOUSE, type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][66623629] = { npcIDs1 = 46639, npcIDs2 = 46637, npcIDs3 = 46640, npcIDs4 = 46638, name = BUTTON_LAG_AUCTIONHOUSE, type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsBank then
                        minimap[85][48748348] = { dnID = BANK .. "\n" .. GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][67615218] = { dnID = BANK .. "\n" .. GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][40104599] = { dnID = BANK .. "\n" .. GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsBarber then
                        minimap[85][40336058] = { npcID = 29143, name = "", type = "Barber", showInZone = false, showOnContinent = false, showOnMinimap = true }
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
                        minimap[85][38347131] = { npcIDs1 = 12794, npcIDs2 = 12795, npcIDs3 = 12793, npcIDs4 = 52036, npcIDs5 = 52033, npcIDs6 = 54657, npcIDs7 = 69977, npcIDs8 = 69978, npcIDs9 = 175050, npcIDs10 = 146626, name = TRANSMOG_SET_PVP .. " " .. MERCHANT, type = "PvPVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsTransmogger then
                        minimap[85][58116545] = { npcID = 54473, name = "", type = "Transmogger", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][47797449] = { npcID = 201314, name = "", type = "Transmogger", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsPvEVendor then
                        minimap[85][48037056] = { npcIDs1 = 58155, npcIDs2 = 46555, npcIDs3 = 46556, name = TRANSMOG_SET_PVE .. " " .. MERCHANT .. " " .. L["(on the tower)"], type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[503][50632907] = { npcID = 145695, name = TRANSMOG_SET_PVE .. " " .. MERCHANT, type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsStablemaster then
                        minimap[85][39604840.01] = { npcID = 44788, name = "", type = "StablemasterN", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][62403560] = { npcID = 47764, name = "", type = "StablemasterN", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsTradingPost then
                        minimap[85][48717601] = { npcIDs1 = 185472, npcIDs2 = 185473, name = "",  type = "TradingPost", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsMountMerchent then
                        minimap[85][69824115] = { npcID = 66022, name = PERKS_VENDOR_CATEGORY_MOUNT .. " " .. MERCHANT, type = "MountMerchant", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][48005870] = { npcID = 44918, name = PERKS_VENDOR_CATEGORY_MOUNT .. " " .. MERCHANT, type = "MountMerchant", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][38057803] = { npcID = 48510, name = PERKS_VENDOR_CATEGORY_MOUNT .. " " .. MERCHANT, type = "MountMerchant", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[85][41807298] = { npcIDs1 = 12796, npcIDs2 = 73151, name = TRANSMOG_SET_PVP .. " " .. PERKS_VENDOR_CATEGORY_MOUNT .. " " .. MERCHANT, type = "MountMerchant", showInZone = false, showOnContinent = false, showOnMinimap = true }
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
                        minimap[88][46643317] = { npcID = 3009, name = "", type = "Alchemy", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end
                
                    if self.db.profile.showMinimapCapitalsLeatherworking then
                        minimap[88][41514257] = { npcID = 3007, name = "", type = "Leatherworking", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsEngineer then
                        minimap[88][36065961] = { npcID = 52651, name = "", type = "Engineer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsSkinning then
                        minimap[88][44424321] = { npcID = 7089, name = "", type = "Skinning", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsTailoring then
                        minimap[88][44544531] = { npcID = 3004, name = "", type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsJewelcrafting then
                        minimap[88][34825399] = { npcID = 52657, name = "", type = "Jewelcrafting", showInZone = false, showOnContinent = false, showOnMinimap = true}
                    end

                    if self.db.profile.showMinimapCapitalsBlacksmith then
                        minimap[88][39365510] = { npcID = 2998, name = "", type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsMining then
                        minimap[88][34385790] = { npcID = 3001, name = "", type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsFishing then
                        minimap[88][56144642] = { npcID = 3028, name = "", type = "Fishing", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsCooking then
                        minimap[88][50745310] = { npcID = 3026, name = "", type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsArchaeology then
                        minimap[88][75032812] = { npcID = 47572, name = "", type = "Archaeology", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsHerbalism then
                        minimap[88][49954040] = { npcID = 3013, name = "", type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsEnchanting then
                        minimap[88][45293847] = { npcID = 3011, name = "", type = "Enchanting", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsInscription then
                        minimap[88][28812071] = { npcID = 30709, name = "", type = "Inscription", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[88][30323012] = { npcID = 30709, name = L["Passage"],  type = "PassageLeftL", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end

            --Transports Thunder Bluff
                if self.db.profile.activate.MinimapCapitalsTransporting then
  
                    if self.db.profile.showMinimapCapitalsZeppelins then
                        minimap[88][14292570] = { mnID = 85, name = "", type = "HZeppelin", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Zeppelin from Thunder Bluff to OG
                    end

                    if self.db.profile.showMinimapCapitalsFP then
                        minimap[88][46654989] = { npcID = 2995, name = "", type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true }
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
                        minimap[88][45856477] = { npcID = 6746, name = "", type = "Innkeeper",  showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsAuctioneer then
                        minimap[88][38875023] = { npcID = 8722, name = BUTTON_LAG_AUCTIONHOUSE, type = "Auctioneer",  showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[88][40435169] = { npcID = 8674, name = BUTTON_LAG_AUCTIONHOUSE, type = "Auctioneer",  showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsBank then
                        minimap[88][47175862] = { dnID = BANK, name = "", type = "Bank",  showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsMailbox then
                        minimap[88][45505950] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsStablemaster then
                        minimap[88][45006000] = { npcID = 10054, name = "", type = "StablemasterN", showInZone = false, showOnContinent = false, showOnMinimap = true }
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
                        minimap[110][66701673] = { npcID = 16642, name = "", type = "Alchemy", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end
                
                    if self.db.profile.showMinimapCapitalsLeatherworking then
                        minimap[110][85008054] = { npcID = 16688, name = "", type = "Leatherworking", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsEngineer then
                        minimap[110][76634110] = { npcID = 16667, name = "", type = "Engineer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsSkinning then
                        minimap[110][84997931] = { npcID = 16692, name = "", type = "Skinning", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsTailoring then
                        minimap[110][57365009] = { npcID = 16640, name = "", type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsJewelcrafting then
                        minimap[110][90767437] = { npcIDs1 = 19775, npcIDs2 = 16703, name = "", type = "Jewelcrafting", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsBlacksmith then
                        minimap[110][79423869] = { npcID = 16669, name = "", type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsMining then
                        minimap[110][78914322] = { npcID = 16663, name = "", type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsFishing then
                        minimap[110][76246779] = { npcID = 16780, name = "", type = "Fishing", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsCooking then
                        minimap[110][69647153] = { npcID = 16676, name = "", type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsArchaeology then
                        minimap[110][81436390] = { npcID = 47346, name = "", type = "Archaeology", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsHerbalism then
                        minimap[110][67401842] = { npcID = 16644, name = "", type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsInscription then
                        minimap[110][69322382] = { npcID = 30710, name = "", type = "Inscription", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsEnchanting then
                        minimap[110][70012365] = { npcID = 16633, name = "", type = "Enchanting", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end

            --Transports Silvermoon
                if self.db.profile.activate.MinimapCapitalsTransporting then

                    if self.db.profile.showMinimapCapitalsPortals then
                        minimap[110][58511859] = { mnID = 85, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, } -- Portal to Orgrimmar from Silvermoon 
                        minimap[110][49491509] = { mnID = 18, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = ns.RuinsofLordaeron .. " (" .. L["Portal"] ..")" } -- Portal to Undercity from Silvermoon 
                    end

                    if self.db.profile.showMinimapCapitalsFP then
                        minimap[110][63159649] = { npcID = 16192, name = "", type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[110][30237978] = { npcID = 44244, name = "", type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end

            --General Silvermoon
                if self.db.profile.activate.MinimapCapitalsGeneral then
    
                    if self.db.profile.showMinimapCapitalsPaths then
                        minimap[110][72609199] = { dnID = L["Exit"], name = "", mnID = 94, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                    end

                    if self.db.profile.showMinimapCapitalsInnkeeper then
                        minimap[110][79465822] = { npcID = 16618, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[110][67867288] = { npcID = 17630, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsAuctioneer then
                        minimap[110][92735828] = { npcIDs1 = 16627, npcIDs2 = 16629, npcIDs3 = 16628, name = BUTTON_LAG_AUCTIONHOUSE, type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[110][60726258] = { npcIDs1 = 17629, npcIDs2 = 17628, npcIDs3 = 17627, npcIDs4 = 18761, name = BUTTON_LAG_AUCTIONHOUSE, type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
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
                        minimap[110][83403040] = { npcID = 16656, name = "", type = "StablemasterN", showInZone = false, showOnContinent = false, showOnMinimap = true }
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
                        minimap[90][47757332] = { npcID = 4611, name = "", type = "Alchemy", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[90][52947737] = { npcID = 4611, name = L["Passage"], type = "PassageLeftL", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[90][44626639] = { npcID = 4611, name = L["Passage"], type = "PassageLeftL", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end
                
                    if self.db.profile.showMinimapCapitalsLeatherworking then
                        minimap[90][70155740] = { npcID = 4588, name = "", type = "Leatherworking", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsEngineer then
                        minimap[90][76107409] = { npcID = 11031, name = "", type = "Engineer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsSkinning then
                        minimap[90][70165922] = { npcID = 7087, name = "", type = "Skinning", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsTailoring then
                        minimap[90][70763072] = { npcID = 4576, name = "", type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsJewelcrafting then
                        minimap[90][56503630] = { npcID = 52587, name = "", type = "Jewelcrafting", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsBlacksmith then
                        minimap[90][61313061] = { npcID = 4596, name = "", type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsMining then
                        minimap[90][56043744] = { npcID = 4598, name = "", type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsFishing then
                        minimap[90][80693124] = { npcID = 4573, name = "", type = "Fishing", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsCooking then
                        minimap[90][62194489] = { npcID = 4552, name = "", type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsArchaeology then
                        minimap[90][75403772] = { npcID = 47382, name = "", type = "Archaeology", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsHerbalism then
                        minimap[90][54014961] = { npcID = 4614, name = "", type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsInscription then
                        minimap[90][61065801] = { npcID = 30711, name = "", type = "Inscription", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsEnchanting then
                        minimap[90][61866139] = { npcID = 4616, name = "", type = "Enchanting", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end
                end

            --Transports Undercity
                if self.db.profile.activate.MinimapCapitalsTransporting then

                    if self.db.profile.showMinimapCapitalsPortals then
                        minimap[90][85181711] = { mnID = 100, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal from Old Undercity to Hellfire
                    end

                    if self.db.profile.showMinimapCapitalsFP then
                        minimap[90][63084832] = { npcID = 4551, name = "", type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true }
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
                        minimap[90][67743784] = { npcID = 6741, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsAuctioneer then
                        minimap[90][60534156] = { npcID = 15684, name = BUTTON_LAG_AUCTIONHOUSE, type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[90][64363583] = { npcID = 15683, name = BUTTON_LAG_AUCTIONHOUSE, type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[90][67663591] = { npcID = 15682, name = BUTTON_LAG_AUCTIONHOUSE, type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[90][71494189] = { npcID = 15676, name = BUTTON_LAG_AUCTIONHOUSE, type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[90][71394672] = { npcID = 15675, name = BUTTON_LAG_AUCTIONHOUSE, type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[90][67545239] = { npcID = 8672, name = BUTTON_LAG_AUCTIONHOUSE, type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[90][64415242] = { npcID = 8721, name = BUTTON_LAG_AUCTIONHOUSE, type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[90][60494647] = { npcID = 15686, name = BUTTON_LAG_AUCTIONHOUSE, type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsBank then
                        minimap[90][66014406] = { dnID = BANK .. "\n" .. GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsBarber then
                        minimap[90][70004653] = { npcID = 29139, name = "", type = "Barber", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsPvEVendor then
                        minimap[90][78207564] = { npcID = 6566, name = TRANSMOG_SET_PVE .. " " .. MERCHANT, type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
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
                        minimap[90][67603800] = { npcID = 10053, name = "", type = "StablemasterN", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end

            end

        end

    --###########################
    --### Warspear / Garrison ###
    --###########################
        if self.db.profile.showMinimapCapitalsWarspear then

        --#############################
        --### Horde or EnemyFaction ###
        --#############################w
            if self.faction == "Horde" or db.activate.MinimapCapitalsEnemyFaction then

            --Instance Warspear / Garrison
                if self.db.profile.activate.MinimapCapitalsInstances then
    
                    if self.db.profile.showMinimapCapitalsLFR then
                        minimap[590][41364698] = { npcID = 94870, mnID = 590, name = ns.SeerKazal .. " - " .. REQUIRES_LABEL .. " " .. GARRISON_LOCATION_TOOLTIP .. " " .. LEVEL .. " " .. ACTION_SPELL_CAST_START_MASTER .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " ", id = { 477, 457, 669 }, type = "LFR", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end
    
                end

            --Professions Warspear
                if self.db.profile.activate.MinimapCapitalsProfessions then

                    if self.db.profile.showMinimapCapitalsAlchemy then
                        minimap[624][60832652] = { npcID = 86009, name = "", type = "Alchemy", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end
                
                    if self.db.profile.showMinimapCapitalsLeatherworking then
                        minimap[624][49532786] = { npcID = 86032, name = "", type = "Leatherworking", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsEngineer then
                        minimap[624][71684029] = { npcID = 86012, name = "", type = "Engineer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsSkinning then
                        minimap[624][48643138] = { npcID = 86028, name = "", type = "Skinning", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsTailoring then
                        minimap[624][59394278] = { npcID = 86004, name = "", type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsJewelcrafting then
                        minimap[624][60203986] = { npcID = 86010, name = "", type = "Jewelcrafting", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsBlacksmith then
                        minimap[624][74093712] = { npcID = 86048, name = "", type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsMining then
                        minimap[624][78603676] = { npcID = 86014, name = "", type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsFishing then
                        minimap[624][69161653] = { npcID = 86628, name = "", type = "Fishing", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[590][38317223] = { npcID = 79892, name = "", type = "Fishing", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsCooking then
                        minimap[624][45784497] = { npcID = 86029, name = "", type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsArchaeology then
                        minimap[624][73603119] = { npcID = 86033, name = "", type = "Archaeology", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsHerbalism then
                        minimap[624][62563059] = { npcID = 86006, name = "", type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsInscription then
                        minimap[624][77104741] = { npcID = 86015, name = "", type = "Inscription", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsEnchanting then
                        minimap[624][78755287] = { npcID = 86027, name = "", type = "Enchanting", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end
                end

            --Transports Warspear
                if self.db.profile.activate.MinimapCapitalsTransporting then

                    if self.db.profile.showMinimapCapitalsPortals then
                        minimap[624][53184384] = { mnID = 534, name = ns.Volmar, type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal from Ashran to Vol'mar Captive
                        minimap[624][60825159] = { mnID = 85, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal from Garrison to Ashran
                        minimap[590][75184879] = { mnID = 624, name = ns.Ashran, type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal from Garrison to Ashran
                    end

                    if self.db.profile.showMinimapCapitalsFP then
                        minimap[590][45665027] = { npcID = 79407, name = "", type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[624][44133387] = { npcID = 86049, name = "", type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end

            --General Warspear
                if self.db.profile.activate.MinimapCapitalsGeneral then
    
                    if self.db.profile.showMinimapCapitalsPaths then
                        minimap[624][55498792] = { dnID = L["Exit"], name = "", mnID = 588, type = "PathR", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                    end

                    if self.db.profile.showMinimapCapitalsInnkeeper then
                        minimap[624][44954321] = { npcID = 86307, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsAuctioneer then
                        minimap[624][54692551] = { npcIDs1 = 88128, npcIDs2 = 86635, npcIDs3 = 88130, name = BUTTON_LAG_AUCTIONHOUSE, type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsBank then
                        minimap[624][51766162] = { dnID = BANK .. "\n" .. GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsPvPVendor then
                        minimap[624][48565658] = { npcIDs1 = 128759, npcIDs2 = 93908, npcIDs3 = 93909, npcIDs4 = 93916, npcIDs5 = 93917, npcIDs6 = 88569, npcIDs7 = 87774, name = TRANSMOG_SET_PVP .. " " .. MERCHANT, type = "PvPVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsTransmogger then
                        minimap[624][58335187] = { npcID = 86395, name = "", type = "Transmogger", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsMailbox then
                        minimap[624][51905650] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true}
                        minimap[624][47504450] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true}
                        minimap[624][54503050] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true}
                        minimap[624][65105270] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true}
                        minimap[624][68203930] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true}
                        minimap[624][77805210] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true}
                        minimap[590][44854959] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true}
                    end

                    if self.db.profile.showMinimapCapitalsStablemaster then
                        minimap[624][77605900] = { npcID = 86052, name = "", type = "StablemasterN", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsPvEVendor then
                        minimap[624][65896343] = { npcIDs1 = 86382, npcIDs2 = 91322, npcIDs3 = 86379, npcIDs4 = 86376, npcIDs5 = 86378, npcIDs6 = 92503, npcIDs7 = 88161, name = TRANSMOG_SET_PVE .. " " .. MERCHANT, type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[590][38524907] = { npcID = 79619, name = "", type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[590][32883954] = { npcID = 94516, name = "", type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[590][43804757] = { npcID = 79774, name = "", type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
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
                        minimap[1165][42223796] = { npcID = 122703, name = "", type = "Alchemy", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end
                
                    if self.db.profile.showMinimapCapitalsLeatherworking then
                        minimap[1165][44103463] = { npcID = 122698, name = "", type = "Leatherworking", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsEngineer then
                        minimap[1165][45144059] = { npcID = 131840, name = "", type = "Engineer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsSkinning then
                        minimap[1165][43783469] = { npcID = 122699, name = "", type = "Skinning", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsTailoring then
                        minimap[1165][44493387] = { npcID = 122700, name = "", type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsJewelcrafting then
                        minimap[1165][47053791] = { npcID = 122695, name = "", type = "Jewelcrafting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = "(" .. L["in the basement"] .. ")" }
                    end

                    if self.db.profile.showMinimapCapitalsBlacksmith then
                        minimap[1165][43643827] = { npcID = 127112, name = "", type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsMining then
                        minimap[1165][44123896] = { npcID = 122694, name = "", type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsFishing then
                        minimap[1165][50522337] = { npcID = 122705, name = "", type = "Fishing", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsCooking then
                        minimap[1165][52479045] = { npcID = 141906, name = "", type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1164][28565017] = { npcID = 141549, name = "", type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true }

                    end

                    if self.db.profile.showMinimapCapitalsArchaeology then
                        minimap[1163][32223550] = { npcID = 122701, name = "", type = "Archaeology", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1165][48804311] = { npcID = 122701, name = "", mnID = 1165, dnID = L["(inside building)"], type = "Archaeology", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsHerbalism then
                        minimap[1165][42093560] = { npcID = 122704, name = "", type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsInscription then
                        minimap[1165][42313974] = { npcID = 130901, name = "", type = "Inscription", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1164][70563292] = { npcID = 132264, name = "", type = "Inscription", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsEnchanting then
                        minimap[1165][47103569] = { npcID = 122702, name = "", type = "Enchanting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = "(" .. L["in the basement"] .. ")" }
                    end
                end

            --Transports DazarAlor
                if self.db.profile.activate.MinimapCapitalsTransporting then

                    if self.db.profile.showMinimapCapitalsPortals then
                        minimap[1165][51424583] = { mnID = 1163, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = ns.Dazaralor .. " " .. L["Portalroom"] .. "\n" .. L["(inside building)"] .. "\n" .. "\n" .. " ==> " .. ns.Silvermoon .. "\n" .. " ==> " .. ns.Orgrimmar .. "\n" .. " ==> " .. ns.ThunderBluff .. "\n" .. " ==> " .. ns.Silithus .. "\n" .. " ==> " .. ns.Nazjatar } -- Portalroom from Dazar'alor
                        minimap[1163][73726194] = { mnID = 110, name = L["Portal"], type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portalroom from Dazar'alor
                        minimap[1163][74006974] = { mnID = 85, name = L["Portal"], type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portalroom from Dazar'alor
                        minimap[1163][74027739] = { mnID = 88, name = L["Portal"], type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portalroom from Dazar'alor
                        minimap[1163][73808541] = { mnID = 81, name = L["Portal"], type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portalroom from Dazar'alor
                        minimap[1163][63008553] = { mnID = 1355, name = L["Portal"], type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portalroom from Dazar'alor
                        minimap[1165][52079454] = { mnID = 62, name = L["This Darkshore portal is only active if your faction is currently occupying Bashal'Aran"], type = "HPortalS", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal from Dazar'alor to Arathi or Darkshore
                        minimap[1165][51719454] = { mnID = 14, name = L["This Arathi Highlands portal is only active if your faction is currently occupying Ar'gorok"], type = "HPortalS", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal from Dazar'alor to Arathi or Darkshore         
                        minimap[1165][56323078] = { npcID = 147642, name = "", dnID = "\n" .. TOOLTIP_BATTLE_PET .. " " .. CALENDAR_TYPE_DUNGEON .. " " .. L["Portals"] .. ":\n" .. " ", type = "PortalHPetBattleDungeon", showInZone = false, showOnContinent = false, showOnMinimap = true,
                                                    showWWW = true, wwwName = BATTLE_PET_SOURCE_2 .. " " .. REQUIRES_LABEL,
                                                    mnIDs1 = 11, questIDs1 = 45423, wwwLinks1 = "https://www.wowhead.com/quest=45423",
                                                    mnIDs2 = 52, questIDs2 = 46291, wwwLinks2 = "https://www.wowhead.com/quest=46291", 
                                                    mnIDs3 = 30, questIDs3 = 54185, wwwLinks3 = "https://www.wowhead.com/quest=54185",
                                                    mnIDs4 = 23, questIDs4 = 56491, wwwLinks4 = "https://www.wowhead.com/quest=56491", 
                                                    mnIDs5 = 35, questIDs5 = 58457, wwwLinks5 = "https://www.wowhead.com/quest=58457" } -- Portal Manapuff
                    end

                    if self.db.profile.showMinimapCapitalsTransport then
                        minimap[1165][41838761] = { npcID = 152506, name = "", mnID = 1462, type = "GoblinF", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Transport from Dazar'alor to Mechagon
                    end

                    if self.db.profile.showMinimapCapitalsFP then
                        minimap[1165][52098994] = { npcID = 121252, name = "", type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1165][51654120] = { npcID = 122689, name = "", type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1165][53121928] = { npcID = 133242, name = "", type = "TravelH", showInZone = false, showOnContinent = false, showOnMinimap = true }
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
                        minimap[1163][76554199] = { mnID = 1164, name = DUNGEON_FLOOR_GILNEAS3  .. "\n" .. " " .. "\n" .. ns.Eppu .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " ", id = { 1176, 1031, 1179, 1036 }, type = "PassageLFR", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1164][68583002] = { mnID = 1164, name = ns.Eppu .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " ", id = { 1176, 1031, 1179, 1036 }, type = "LFR", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1165][49914447] = { mnID = 1164, name = ns.Eppu .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. L["(inside building)"] .. "\n" .. " ", id = { 1176, 1031, 1179, 1036 }, type = "LFR", showInZone = false, showOnContinent = false, showOnMinimap = true }
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
                        minimap[1165][34741160] = { npcID = 126330, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1165][52418494] = { npcID = 120840, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1165][49844867] = { npcID = 122690, name = "", mnID = 1163, dnID = L["(inside building)"], type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1163][48837200] = { npcID = 122690, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsAuctioneer then
                        minimap[1165][44964015] = { npcID = 35607, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = REQUIRES_LABEL .. " " .. L["Engineer"] }
                    end

                    if self.db.profile.showMinimapCapitalsBank then
                        minimap[1163][31834692] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1163][30226774] = { dnID = BANK .. "\n" .. GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsBarber then
                        minimap[1165][47358104] = { npcID = 132364, name = "", type = "Barber", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsTransmogger then
                        minimap[1165][54508960] = { npcID = 131470, name = "", type = "Transmogger", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsPvEVendor then
                        minimap[1164][67337133] = { npcIDs1 = 131287, name = TRANSMOG_SET_PVE .. " " .. MERCHANT, type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsPvPVendor then
                        minimap[1165][51239509] = { npcID = 148924, name = TRANSMOG_SET_PVP .. " " .. MERCHANT, type = "PvPVendor", showInZone = false, showOnContinent = false, showOnMinimap = true}
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
                        minimap[1165][45803620] = { npcID = 122696, name = "", type = "StablemasterN", showInZone = false, showOnContinent = false, showOnMinimap = true }
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
                        minimap[391][62374397] = { npcID = 64924, name = "", type = "Engineer", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Engineer"] .. " " .. MINIMAP_TRACKING_TRAINER_PROFESSION }
                        minimap[1530][62361153] = { npcID = 64924, name = "", type = "Engineer", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Engineer"] .. " " .. MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                    if self.db.profile.showMinimapCapitalsBlacksmith then
                        minimap[391][25844377] = { npcID = 64058, name = "", type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Blacksmithing"] .. " " .. MINIMAP_TRACKING_TRAINER_PROFESSION }
                        minimap[1530][59181165] = { npcID = 64058, name = "", type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Blacksmithing"] .. " " .. MINIMAP_TRACKING_TRAINER_PROFESSION }
                    end

                end

            --Transports Sot2M
                if self.db.profile.activate.MinimapCapitalsTransporting then

                    if self.db.profile.showMinimapCapitalsPortals then
                        minimap[392][72464286] = { mnID = 85, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal from Shrine of Two Moons to Orgrimmar
                        minimap[1530][63720989] = { mnID = 85, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = ns.Orgrimmar .. " (" .. L["Portal"] ..")\n" .. DUNGEON_FLOOR_GILNEAS3 } -- Portal from Shrine of Two Moons to Orgrimmar
                    end

                end

            --General Sot2M
                if self.db.profile.activate.MinimapCapitalsGeneral then
    
                    if self.db.profile.showMinimapCapitalsPaths then
                        minimap[391][26778156] = { name = L["Exit"], mnID = 390, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[391][53618846] = { name = L["Exit"], mnID = 390, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[391][77476963] = { name = L["Exit"], mnID = 390, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[391][78084452] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS3, mnID = 392, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = "\n" .. BANK .. "\n" .. GUILD_BANK .. "\n" .. ns.Orgrimmar .. " (" .. L["Portal"] ..")" }
                        minimap[391][22245623] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS3, mnID = 392, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = "\n" .. BANK .. "\n" .. GUILD_BANK .. "\n" .. ns.Orgrimmar .. " (" .. L["Portal"] ..")" }
                        minimap[391][36972301] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS3, mnID = 392, type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = "\n" .. BANK .. "\n" .. GUILD_BANK .. "\n" .. ns.Orgrimmar .. " (" .. L["Portal"] ..")" }
                        minimap[391][57691948] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS3, mnID = 392, type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = "\n" .. BANK .. "\n" .. GUILD_BANK .. "\n" .. ns.Orgrimmar .. " (" .. L["Portal"] ..")" }
                        minimap[392][55653047] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS2, mnID = 391, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = "\n" .. BUTTON_LAG_AUCTIONHOUSE .. " " .. REQUIRES_LABEL .. " " .. L["Engineer"] .. "\n" .. MINIMAP_TRACKING_INNKEEPER .. "\n" .. L["Engineer"] .. "\n" .. L["Blacksmithing"] }
                        minimap[392][37913400] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS2, mnID = 391, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = "\n" .. BUTTON_LAG_AUCTIONHOUSE .. " " .. REQUIRES_LABEL .. " " .. L["Engineer"] .. "\n" .. MINIMAP_TRACKING_INNKEEPER .. "\n" .. L["Engineer"] .. "\n" .. L["Blacksmithing"] }
                        minimap[392][27407968] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS2, mnID = 391, type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = "\n" .. BUTTON_LAG_AUCTIONHOUSE .. " " .. REQUIRES_LABEL .. " " .. L["Engineer"] .. "\n" .. MINIMAP_TRACKING_INNKEEPER .. "\n" .. L["Engineer"] .. "\n" .. L["Blacksmithing"] }
                        minimap[392][74176908] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS2, mnID = 391, type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = "\n" .. BUTTON_LAG_AUCTIONHOUSE .. " " .. REQUIRES_LABEL .. " " .. L["Engineer"] .. "\n" .. MINIMAP_TRACKING_INNKEEPER .. "\n" .. L["Engineer"] .. "\n" .. L["Blacksmithing"] }
                    end

                    if self.db.profile.showMinimapCapitalsInnkeeper then
                        minimap[391][68544760] = { npcID = 62996, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[392][60357734] = { npcID = 63008, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1530][62921195] = { npcID = 62996, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsAuctioneer then
                        minimap[391][59044226] = { npcID = 67130, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = REQUIRES_LABEL .. " " .. L["Engineer"] }
                        minimap[1530][62071153] = { npcID = 67130, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = REQUIRES_LABEL .. " " .. L["Engineer"] }

                    end

                    if self.db.profile.showMinimapCapitalsBank then
                        minimap[392][27686535] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[392][19584309] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[392][22975452] = { dnID = BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1530][58511114] = { dnID = BANK .. " / " .. GUILD_BANK, TransportName = DUNGEON_FLOOR_GILNEAS3, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsMapNotes then
                        minimap[1530][61691650] = { dnID = TRANSMOG_SET_PVE .. " " .. MERCHANT .. "\n" .. BANK .. "\n" .. GUILD_BANK .. "\n" .. ns.Orgrimmar .. " (" .. L["Portal"] ..")" .. "\n" .. BUTTON_LAG_AUCTIONHOUSE .. " " .. REQUIRES_LABEL .. " " .. L["Engineer"] .. "\n" .. MINIMAP_TRACKING_INNKEEPER .. "\n" .. L["Engineer"] .. "\n" .. L["Blacksmithing"], name = "", type = "MNL", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsPvEVendor then
                        minimap[1530][60601347] = { npcIDs1 = 73674, npcIDs2 = 74010, npcIDs3 = 74012, npcIDs4 = 74019, name = TRANSMOG_SET_PVE .. " " .. MERCHANT, TransportName = DUNGEON_FLOOR_GILNEAS3,  type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[392][43717734] = { npcIDs1 = 73674, npcIDs2 = 74010, npcIDs3 = 74012, npcIDs4 = 74019, name = TRANSMOG_SET_PVE .. " " .. MERCHANT, type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsTransmogger then
                        minimap[392][59171972] = { npcID = 67014, name = "", type = "Transmogger", showInZone = false, showOnContinent = false, showOnMinimap = true }
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
                        minimap[84][50710826] = { mnID = 971, name = "", type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal to Telogrus
                        minimap[84][73221836] = { mnID = 245, name = "", type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true} --  Portal to Tol Barad
                        minimap[84][75232055] = { mnID = 1527, name = "", type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal to Uldum
                        minimap[84][75351649] = { mnID = 241, name = "", type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal to Twilight Highlands
                        minimap[84][76211869] = { mnID = 198, name = "", type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal to Hyjal
                        minimap[84][73171966] = { mnID = 207, name = "", type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal to Deepholm
                        minimap[84][73301687] = { mnID = 203, name = "", type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal to Vashjir
                        minimap[84][49118734] = { mnID = 17, name = "", TransportName = ns.DarkPortal .. "\n" .. "( " .. L["talk to"] .. ": " .. ns.HonorHoldMage .. " )", type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Blasted Lands
                        minimap[84][23865611] = { mnID = 89, name = "",  type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal to Darnassus 
                        minimap[84][41338985] = { mnID = 622, name = "", type = "APortalS",  showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal to Stormshield 
                        minimap[84][42079135] = { mnID = 630, name = "", type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal to Azsuna                         
                        minimap[84][43269759] = { mnID = 2239, name = "", type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal to Bel'ameth, Amirdrassil
                        minimap[84][48119195] = { mnID = 2339, name = "", type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal to Dornogal                        
                        minimap[84][48849344] = { mnID = 2112, name = "", type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal to Valdrakken                         
                        minimap[84][48759519] = { mnID = 1161, name = "", type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal to Boralus 
                        minimap[84][47579495] = { mnID = 1670, name = "", type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal to Oribos 
                        minimap[84][46909335] = { mnID = 2352, name = "", type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal to Founder's Point Housing
                        minimap[84][43748538] = { mnID = 74, name = "", type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal to Caverns of Time 
                        minimap[84][44888577] = { mnID = 111, name = "", type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal to Shattrath 
                        minimap[84][43638719] = { mnID = 103, name = "", type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal to Exodar 
                        minimap[84][44388868] = { mnID = 125, name = "", type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal to Dalaran 
                        minimap[84][45708715] = { mnID = 371, name = "", type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal to Jade Forest 
                        minimap[84][63197339] = { npcID = 54334, mnID = 407, name = "", TransportName = CALENDAR_FILTER_DARKMOON .. " (" .. L["Transport"] .. " / " .. L["Portal"] .. ")\n\n" .. REQUIRES_LABEL .. " " .. CALENDAR_FILTER_DARKMOON .. "\n" .. L["Starting on the first Sunday of each month for one week"], type = "DarkMoon", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[84][62043235] = { npcID = 54334, mnID = 407, name = "", TransportName = CALENDAR_FILTER_DARKMOON .. " (" .. L["Transport"] .. " / " .. L["Portal"] .. ")\n\n" .. REQUIRES_LABEL .. " " .. CALENDAR_FILTER_DARKMOON .. "\n" .. L["Starting on the first Sunday of each month for one week"], type = "DarkMoon", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[84][51551012] = { mnID = 2322, name = "", type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Hall of Awakening
                    end
  
                    if self.db.profile.showMinimapCapitalsShips then
                        minimap[84][21225479] = { mnID = 1161, name = "", type = "AShip", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ship from Stormwind to Boralus
                        minimap[84][22035670] = { mnID = 2022, name = "", type = "AShip", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ship from Stormwind to Waking Shores
                        minimap[84][18122555] = { mnID = 114, name = "", type = "AShip", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = POSTMASTER_LETTER_VALIANCEKEEP .. " (" .. L["Ship"] ..")" } -- Ship from Stormwind to Valiance Keep
                    end

                    if self.db.profile.showMinimapCapitalsTransport then
                        minimap[84][66783455] = { mnID = 499, name = "", type = "Carriage", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = ns.Deepruntram .. " - " .. ns.Ironforge } -- Transport to Ironforge Carriage
                    end

                    if self.db.profile.showMinimapCapitalsFP then
                        minimap[84][71977195] = { npcID = 352, name = "", type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end

            --Professions Stormwind
                if self.db.profile.activate.MinimapCapitalsProfessions then

                    if self.db.profile.showMinimapCapitalsAlchemy then
                        minimap[84][55668610] = { npcID = 5499, name = "", type = "Alchemy", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end
                
                    if self.db.profile.showMinimapCapitalsLeatherworking then
                        minimap[84][42596045] = { npcID = 151287, name = "", type = "Leatherworking", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[84][71676301] = { npcID = 5564, name = "", type = "Leatherworking", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsEngineer then
                        minimap[84][62863192] = { npcID = 5518, name = "", type = "Engineer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsSkinning then
                        minimap[84][72136222] = { npcID = 1292, name = "", type = "Skinning", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsTailoring then
                        minimap[84][53098136] = { npcID = 1346, name = "", type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[84][52011954] = { npcIDs1 = 133363, npcIDs2 = 133396, name = "", type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsJewelcrafting then
                        minimap[84][63486183] = { npcID = 44582, name = "", type = "Jewelcrafting", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsBlacksmith then
                        minimap[84][63663702] = { npcID = 5511, name = "", type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsMining then
                        minimap[84][59523778] = { npcID = 5513, name = "", type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[84][49371220] = { npcID = 133369, name = "", type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsFishing then
                        minimap[84][54806960] = { npcID = 5493, name = "", type = "Fishing", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsCooking then
                        minimap[84][77285321] = { npcID = 5482, name = "", type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[84][50657384] = { npcID = 42288, name = "", type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsArchaeology then
                        minimap[84][85812593] = { npcID = 44238, name = "", type = "Archaeology", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsHerbalism then
                        minimap[84][54298408] = { npcID = 5566, name = "", type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[84][40846587] = { npcID = 5502, name = "", type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsInscription then
                        minimap[84][49827479] = { npcID = 30713, name = "", type = "Inscription", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsEnchanting then
                        minimap[84][52907447] = { npcID = 1317, name = "", type = "Enchanting", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[84][51211270] = { npcID = 133394, name = "", type = "Enchanting", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end
                end

            --General Stormwind
                if self.db.profile.activate.MinimapCapitalsGeneral then
    
                    if self.db.profile.showMinimapCapitalsPaths then
                        minimap[84][73399051] = { dnID = L["Exit"], name = "", mnID = 37, type = "PathRU", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                        minimap[499][89874349] = { dnID = L["Passage"], name = "", mnID = 87, type = "PathR", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                        minimap[499][89876720] = { dnID = L["Passage"], name = "", mnID = 87, type = "PathR", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                        minimap[499][42471587] = { dnID = L["Entrance"], name = "", mnID = 84, type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                        minimap[499][52124649] = { dnID = ns.Stormwind .. " - " .. ns.Deepruntram .. "\n" .. " ==> " .. DUNGEON_FLOOR_DEEPRUNTRAM2, name = "", mnID = 500, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                        minimap[500][72440888] = { dnID = ns.Deepruntram, name = "", mnID = 499, type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                    end

                    if self.db.profile.showMinimapCapitalsInnkeeper then
                        minimap[84][60407527] = { npcID = 6740, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[84][75685411] = { npcID = 44237, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[84][49881574] = { npcID = 129679, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[84][64943193] = { npcID = 44235, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
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
                        minimap[84][61316464] = { npcID = 29142, name = "", type = "Barber", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsPvPVendor then
                        minimap[84][74486812] = { npcIDs1 = 69975, npcIDs2 = 146633, npcIDs3 = 52029, npcIDs4 = 52030, npcIDs5 = 69974, npcIDs6 = 175051, npcIDs7 = 54660, npcIDs8 = 12784, npcIDs9 = 12785, name = TRANSMOG_SET_PVP .. " " .. MERCHANT, type = "PvPVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsTransmogger then
                        minimap[84][50396054] = { npcID = 54442, name = "", type = "Transmogger", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[84][50117252] = { npcID = 201312, name = "", type = "Transmogger", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsPvEVendor then
                        minimap[84][75666652] = { npcIDs1 = 44245, npcIDs2 = 58154, npcIDs3 = 44246, name = TRANSMOG_SET_PVE .. " " .. MERCHANT, TransportName = DUNGEON_FLOOR_GILNEAS3, type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[500][54222496] = { npcID = 68363, name = TRANSMOG_SET_PVE .. " " .. MERCHANT, type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsMountMerchent then
                        --minimap[84][76126538] = { npcID = 12783, name = PERKS_VENDOR_CATEGORY_MOUNT .. " " .. MERCHANT, type = "MountMerchant", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[84][76736533] = { npcIDs1 = 12783, npcIDs2 = 73190, name = TRANSMOG_SET_PVP .. " " .. PERKS_VENDOR_CATEGORY_MOUNT .. " " .. MERCHANT, type = "MountMerchant", showInZone = false, showOnContinent = false, showOnMinimap = true }
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
                        minimap[84][77806720] = { npcID = 44252, name = "", type = "StablemasterN", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[84][67003760] = { npcID = 11069, name = "", type = "StablemasterN", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[84][42366059] = { npcID = 9977, name = "", type = "StablemasterN", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsTradingPost then
                        minimap[84][51487192] = { npcIDs1 = 185467, npcIDs2 = 185468, name = "", type = "TradingPost", showInZone = false, showOnContinent = false, showOnMinimap = true }
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
                        minimap[87][75865097] = { mnID = 84, name = "", type = "Carriage", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = ns.Deepruntram .. " ==> " .. ns.Stormwind } -- Transport to Stormwind Carriage
                    end

                    if self.db.profile.showMinimapCapitalsFP then
                        minimap[87][55884786] = { npcID = 1573, name = "", type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end

            --Professions ironforge
                if self.db.profile.activate.MinimapCapitalsProfessions then

                    if self.db.profile.showMinimapCapitalsAlchemy then
                        minimap[87][66615566] = { npcID = 5177, name = "", type = "Alchemy", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end
                
                    if self.db.profile.showMinimapCapitalsLeatherworking then
                        minimap[87][40223365] = { npcID = 5127, name = "", type = "Leatherworking", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsEngineer then
                        minimap[87][68444359] = { npcID = 5174, name = "", type = "Engineer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsSkinning then
                        minimap[87][39843248] = { npcID = 6291, name = "", type = "Skinning", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsTailoring then
                        minimap[87][43132939] = { npcID = 5153, name = "", type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsJewelcrafting then
                        minimap[87][50192602] = { npcID = 52586, name = "", type = "Jewelcrafting", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsBlacksmith then
                        minimap[87][50324338] = { npcID = 10276, name = "", type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[87][52554139] = { npcID = 4258, name = "", type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsMining then
                        minimap[87][50142649] = { npcID = 4254, name = "", type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsFishing then
                        minimap[87][48090763] = { npcID = 5161, name = "", type = "Fishing", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsCooking then
                        minimap[87][60073646] = { npcID = 5159, name = "", type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsArchaeology then
                        minimap[87][75611110] = { npcID = 39718, name = "", type = "Archaeology", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsHerbalism then
                        minimap[87][55865907] = { npcID = 5137, name = "", type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsInscription then
                        minimap[87][61004516] = { npcID = 30717, name = "", type = "Inscription", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsEnchanting then
                        minimap[87][60114533] = { npcID = 5157, name = "", type = "Enchanting", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end
                end

            --General Ironforge
                if self.db.profile.activate.MinimapCapitalsGeneral then
    
                    if self.db.profile.showMinimapCapitalsPaths then
                        minimap[87][14218604] = { dnID = L["Exit"], name = "", mnID = 27, type = "PathLU", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit 
                    end

                    if self.db.profile.showMinimapCapitalsInnkeeper then
                        minimap[87][18165147] = { npcID = 5111, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
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
                        minimap[87][25215134] = { npcID = 29141, name = "", type = "Barber", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsPvEVendor then
                        minimap[87][74400917] = { npcID = 6294, name = TRANSMOG_SET_PVE .. " " .. MERCHANT, type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
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
                        minimap[87][69008460] = { npcID = 9984, name = "", type = "StablemasterN", showInZone = false, showOnContinent = false, showOnMinimap = true }
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
                    minimap[89][36045019] = { mnID = 57, name = "", type = "Portal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = ns.Ruttheran .. " (" .. L["Portal"] ..")" } -- Portal To Darnassus from Teldrassil
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
                        minimap[89][62533278] = { npcID = 6735, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsAuctioneer then
                        minimap[89][54915837] = { npcIDs1 = 8723, npcIDs2 = 8669, npcIDs3 = 15678, npcIDs4 = 15679, name = BUTTON_LAG_AUCTIONHOUSE, type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
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
                        minimap[89][43602940] = { npcID = 10056, name = "", type = "StablemasterN", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end

            --Transports Darnassus
                if self.db.profile.activate.MinimapCapitalsTransporting then

                    if self.db.profile.showMinimapCapitalsPortals then
                        minimap[89][44127840] = { name = "", type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Portals"] .. "\n" .. " ==> " .. ns.Exodar .. "\n" .. " ==> " .. ns.HellfirePeninsula } -- Portal To Darnassus from Teldrassil
                    end

                    if self.db.profile.showMinimapCapitalsFP then
                        minimap[89][36724827] = { npcID = 40552, name = "", type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end

            --Professions Darnassus
                if self.db.profile.activate.MinimapCapitalsProfessions then

                    if self.db.profile.showMinimapCapitalsAlchemy then
                        minimap[89][53913853] = { npcID = 4160, name = "", type = "Alchemy", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end
                
                    if self.db.profile.showMinimapCapitalsLeatherworking then
                        minimap[89][60463683] = { npcID = 4212, name = "", type = "Leatherworking", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsEngineer then
                        minimap[89][49613236] = { npcID = 52636, name = "", type = "Engineer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsSkinning then
                        minimap[89][60273733] = { npcID = 6292, name = "", type = "Skinning", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsTailoring then
                        minimap[89][59783740] = { npcID = 4159, name = "", type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsJewelcrafting then
                        minimap[89][53993111] = { npcID = 52645, name = "", type = "Jewelcrafting", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsBlacksmith then
                        minimap[89][56985271] = { npcID = 52640, name = "", type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsMining then
                        minimap[89][50083357] = { npcID = 52642, name = "", type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsFishing then
                        minimap[89][49096098] = { npcID = 4156, name = "", type = "Fishing", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsCooking then
                        minimap[89][49893663] = { npcID = 4210, name = "", type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsArchaeology then
                        minimap[89][42658334] = { npcID = 47569, name = "", type = "Archaeology", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsHerbalism then
                        minimap[89][49146878] = { npcID = 4204, name = "", type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsInscription then
                        minimap[89][56793163] = { npcID = 30715, name = "", type = "Inscription", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsEnchanting then
                        minimap[89][56413101] = { npcID = 4213, name = "", type = "Enchanting", showInZone = false, showOnContinent = false, showOnMinimap = true }
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
                        minimap[103][59511876] = { npcID = 16739, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
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
                        minimap[103][59402440] = { npcID = 16764, name = "", type = "StablemasterN", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end

            --Transports Exodar
                if self.db.profile.activate.MinimapCapitalsTransporting then

                    if self.db.profile.showMinimapCapitalsPortals then
                        minimap[103][48326264] = { mnID = 84, name = "", type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal Exodar to Stormwind
                    end

                    if self.db.profile.showMinimapCapitalsFP then
                        minimap[103][54383659] = { npcID = 17555, name = "", type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end

            --Professions Exodar
                if self.db.profile.activate.MinimapCapitalsProfessions then

                    if self.db.profile.showMinimapCapitalsAlchemy then
                        minimap[103][27766078] = { npcID = 16723, name = "", type = "Alchemy", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end
                
                    if self.db.profile.showMinimapCapitalsLeatherworking then
                        minimap[103][67467457] = { npcID = 16728, name = "", type = "Leatherworking", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsEngineer then
                        minimap[103][54139288] = { npcID = 16726, name = "", type = "Engineer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsSkinning then
                        minimap[103][65657456] = { npcID = 16763, name = "", type = "Skinning", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsTailoring then
                        minimap[103][64386894] = { npcID = 16729, name = "", type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[103][39322223] = { npcID = 16731, name = "", type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsJewelcrafting then
                        minimap[103][44882424] = { npcID = 19778, name = "", type = "Jewelcrafting", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsBlacksmith then
                        minimap[103][60609000] = { npcID = 16724, name = "", type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsMining then
                        minimap[103][59698781] = { npcID = 16752, name = "", type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsFishing then
                        minimap[103][31931462] = { npcID = 16774, name = "", type = "Fishing", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsCooking then
                        minimap[103][55772672] = { npcID = 16719, name = "", type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsArchaeology then
                        minimap[103][33316569] = { npcID = 47570, name = "", type = "Archaeology", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsHerbalism then
                        minimap[103][27456281] = { npcID = 16736, name = "", type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsInscription then
                        minimap[103][39833860] = { npcID = 30716, name = "", type = "Inscription", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsEnchanting then
                        minimap[103][40693881] = { npcID = 16725, name = "", type = "Enchanting", showInZone = false, showOnContinent = false, showOnMinimap = true }
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
                        minimap[582][33173703] = { npcID = 94870, mnID = 582, name = ns.SeerKazal .. " - " .. REQUIRES_LABEL .. " " .. GARRISON_LOCATION_TOOLTIP .. " " .. LEVEL .. " " .. ACTION_SPELL_CAST_START_MASTER .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " ", id = { 477, 457, 669 }, type = "LFR", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end
    
                end

            --General Stormshield
                if self.db.profile.activate.MinimapCapitalsGeneral then
    
                    if self.db.profile.showMinimapCapitalsPaths then
                        minimap[622][55650794] = { dnID = L["Exit"], name = "", mnID = 588, type = "PathO", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Passage/Exit
                    end

                    if self.db.profile.showMinimapCapitalsInnkeeper then
                        minimap[622][35727790] = { npcID = 85956, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsAuctioneer then
                        minimap[622][53966609] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsBank then
                        minimap[622][54394818] = { dnID = BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[622][56135089] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsPvPVendor then
                        minimap[622][54781873] = { npcIDs1 = 86175, npcIDs2 = 86176, npcIDs3 = 93915, npcIDs4 = 93914, npcIDs5 = 93906, npcIDs6 = 93907, name = TRANSMOG_SET_PVP .. " " .. MERCHANT, type = "PvPVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsPvEVendor then
                        minimap[582][29173863] = { npcID = 94512, name = TRANSMOG_SET_PVE .. " " .. MERCHANT, type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[582][38473153] = { npcID = 78564, name = TRANSMOG_SET_PVE .. " " .. MERCHANT, type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[582][29613260] = { npcID = 85839, name = TRANSMOG_SET_PVE .. " " .. MERCHANT, type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[622][29665290] = { npcID = 85849, name = TRANSMOG_SET_PVE .. " " .. MERCHANT, type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[622][49776140] = { npcIDs1 = 86390, npcIDs2 = 91321, npcIDs3 = 86389, npcIDs4 = 86387, npcIDs5 = 86391, npcIDs6 = 92501, name = TRANSMOG_SET_PVE .. " " .. MERCHANT, type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsTransmogger then
                        minimap[622][63133544] = { npcID = 85961, name = "", type = "Transmogger", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsMailbox then
                        minimap[622][36207260] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[622][43506950] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[622][42103790] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[622][51604450] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[622][63602250] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsStablemaster then
                        minimap[622][34006420] = { npcID = 85963, name = "", type = "StablemasterN", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end

            --Transports Stormshield
                if self.db.profile.activate.MinimapCapitalsTransporting then

                    if self.db.profile.showMinimapCapitalsPortals then
                        minimap[582][69692706] = { mnID = 622, name = ns.Ashran, type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal from Garison to Ashran
                        minimap[622][36234113] = { mnID = 534, name = "", type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = ns.LionsWatch .. " (" .. L["Portal"] ..")" } -- Portal from Ashran to Lion's Watch
                        minimap[622][60813785] = { mnID = 84,  name = "" , type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal from Ashran to Stormwind
                    end

                    if self.db.profile.showMinimapCapitalsFP then
                        minimap[622][30554842] = { npcID = 85959, name = "", type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[582][47764933] = { npcID = 81103, name = "", type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end

            --Professions Stormshield
                if self.db.profile.activate.MinimapCapitalsProfessions then

                    if self.db.profile.showMinimapCapitalsAlchemy then
                        minimap[622][37056882] = { npcID = 85905, name = "", type = "Alchemy", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end
                
                    if self.db.profile.showMinimapCapitalsLeatherworking then
                        minimap[622][52494201] = { npcID = 85920, name = "", type = "Leatherworking", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsEngineer then
                        minimap[622][48004052] = { npcID = 85918, name = "", type = "Engineer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsSkinning then
                        minimap[622][52124369] = { npcID = 85923, name = "", type = "Skinning", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsTailoring then
                        minimap[622][51533716] = { npcID = 85910, name = "", type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsJewelcrafting then
                        minimap[622][43513391] = { npcID = 85916, name = "", type = "Jewelcrafting", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsBlacksmith then
                        minimap[622][49344639] = { npcID = 85917, name = "", type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsMining then
                        minimap[622][47324371] = { npcID = 85919, name = "", type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsFishing then
                        minimap[582][53991494] = { npcID = 77733, name = "", type = "Fishing", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[622][55497849] = { npcID = 85926, name = "", type = "Fishing", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsCooking then
                        minimap[622][35137611] = { npcID = 85925, name = "", type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["in the basement"] }
                    end

                    if self.db.profile.showMinimapCapitalsArchaeology then
                        minimap[622][48993319] = { npcID = 85927, name = "", type = "Archaeology", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsHerbalism then
                        minimap[622][37616948] = { npcID = 85921, name = "", type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsInscription then
                        minimap[622][63163365] = { npcID = 85911, name = "", type = "Inscription", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsEnchanting then
                        minimap[622][56706551] = { npcID = 85914, name = "", type = "Enchanting", showInZone = false, showOnContinent = false, showOnMinimap = true }
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
                        minimap[1161][74191352] = { npcID = 177193, mnID = 1161, name = ns.Kiku .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " ", id = { 1176, 1031, 1179, 1036 }, type = "LFR", showInZone = false, showOnContinent = false, showOnMinimap = true }
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
                        minimap[1161][56232565] = { npcID = 143560, name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1161][74001234] = { npcID = 135153, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsAuctioneer then
                        minimap[1161][77271368] = { dnID = BUTTON_LAG_AUCTIONHOUSE, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = REQUIRES_LABEL .. " " .. L["Engineer"] }
                    end

                    if self.db.profile.showMinimapCapitalsBank then
                        minimap[1161][75591929] = { dnID = BANK .. "\n" .. GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsBarber then
                        minimap[1161][64612817] = { npcID = 142089, name = "", type = "Barber", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsPvPVendor then
                        minimap[1161][56382709] = { npcID = 145838, name = TRANSMOG_SET_PVP .. " " .. MERCHANT, type = "PvPVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsTransmogger then
                        minimap[1161][71851338] = { npcID = 136052, name = "", type = "Transmogger", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsMailbox then
                        minimap[1161][73606890] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1161][57002690] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1161][67002360] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1161][73801450] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsStablemaster then
                        minimap[1161][69621314] = { npcID = 142073, name = "", type = "StablemasterN", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end

            --Transports Boralus
                if self.db.profile.activate.MinimapCapitalsTransporting then

                    if self.db.profile.showMinimapCapitalsPortals then
                        minimap[1161][69871531] = { mnID = 1355, name = "", type = "APortalS", questID = 55175, showWWW = true, wwwLink = "wowhead.com/quest=29824", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portalroom from Boralus
                        minimap[1161][69641590] = { mnID = 81, name = "", type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portalroom from Boralus
                        minimap[1161][70131684] = { mnID = 84, name = "", type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portalroom from Boralus
                        minimap[1161][70381499] = { mnID = 103, name = "", type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portalroom from Boralus
                        minimap[1161][70891536] = { mnID = 87, name = "", type = "APortalS", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portalroom from Boralus
                        minimap[1161][66182474] = { mnID = 14, name = "", type = "APortalS", TransportName = L["This Arathi Highlands portal is only active if your faction is currently occupying Ar'gorok"], showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portalroom from Boralus
                        minimap[1161][66212442] = { mnID = 62, name = "", type = "APortalS", TransportName = L["This Darkshore portal is only active if your faction is currently occupying Bashal'Aran"], showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portalroom from Boralus
                        minimap[1161][50044667] = { npcID = 147666, name = "", dnID = "\n" .. TOOLTIP_BATTLE_PET .. " " .. CALENDAR_TYPE_DUNGEON .. " " .. L["Portals"] .. ":\n" .. " ", type = "PortalAPetBattleDungeon", showInZone = false, showOnContinent = false, showOnMinimap = true,
                                                    showWWW = true, wwwName = BATTLE_PET_SOURCE_2 .. " " .. REQUIRES_LABEL,
                                                    mnIDs1 = 11, questIDs1 = 45423, wwwLinks1 = "https://www.wowhead.com/quest=45423",
                                                    mnIDs2 = 52, questIDs2 = 46291, wwwLinks2 = "https://www.wowhead.com/quest=46291", 
                                                    mnIDs3 = 30, questIDs3 = 54185, wwwLinks3 = "https://www.wowhead.com/quest=54185",
                                                    mnIDs4 = 23, questIDs4 = 56491, wwwLinks4 = "https://www.wowhead.com/quest=56491", 
                                                    mnIDs5 = 35, questIDs5 = 58457, wwwLinks5 = "https://www.wowhead.com/quest=58457" } -- Portal Manapuff
                    end

                    if self.db.profile.showMinimapCapitalsTransport then
                        minimap[1161][67952670] = { npcID = 143535, mnID = 862, mnID2 = 864, mnID3 = 863, name = L["(Grand Admiral Jes-Tereth) will take you to Vol'Dun, Nazmir or Zuldazar"], dnID = " " .. ITEM_REQ_ALLIANCE, type = "GilneanF", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal from Dazar'alor to Mechagon
                    end

                    if self.db.profile.showMinimapCapitalsFP then
                        minimap[1161][47916532] = { npcID = 143535, name = "", type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1161][76707255] = { npcID = 143547, name = "", type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1161][39541386] = { npcID = 133210, name = "", type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[1161][67101507] = { npcID = 124725, name = "", type = "TravelA", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsShips then
                        minimap[1161][78232675] = { mnID = 84, name = "", type = "AShip", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Ship from Boralus to Stormwind
                    end

                end

            --Professions Boralus
                if self.db.profile.activate.MinimapCapitalsProfessions then

                    if self.db.profile.showMinimapCapitalsAlchemy then
                        minimap[1161][74090670] = { npcID = 132228, name = "", type = "Alchemy", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end
                
                    if self.db.profile.showMinimapCapitalsLeatherworking then
                        minimap[1161][75451258] = { npcID = 136063, name = "", type = "Leatherworking", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsEngineer then
                        minimap[1161][77611434] = { npcID = 136059, name = "", type = "Engineer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsSkinning then
                        minimap[1161][75661340] = { npcID = 136061, name = "", type = "Skinning", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsTailoring then
                        minimap[1161][76951116] = { npcID = 136071, name = "", type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsJewelcrafting then
                        minimap[1161][75210986] = { npcID = 130368, name = "", type = "Jewelcrafting", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsBlacksmith then
                        minimap[1161][73470849] = { npcID = 133536, name = "", type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsMining then
                        minimap[1161][75200760] = { npcID = 136091, name = "", type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsFishing then
                        minimap[1161][74160560] = { npcID = 136102, name = "", type = "Fishing", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsCooking then
                        minimap[1161][71201068] = { npcID = 136052, name = "", type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsArchaeology then
                        minimap[1161][68340848] = { npcID = 136106, name = "", type = "Archaeology", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsHerbalism then
                        minimap[1161][70550566] = { npcID = 136096, name = "", type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsInscription then
                        minimap[1161][73380637] = { npcID = 130399, name = "", type = "Inscription", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsEnchanting then
                        minimap[1161][74031153] = { npcID = 136041, name = "", type = "Enchanting", showInZone = false, showOnContinent = false, showOnMinimap = true }
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
                        minimap[393][70883384] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS3, mnID = 394, type = "PathLO", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = "\n" .. BANK .. "\n" .. GUILD_BANK .. "\n" .. ns.Stormwind .. " (" .. L["Portal"] ..")" }
                        minimap[393][54048271] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS3, mnID = 394, type = "PathRU", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = "\n" .. BANK .. "\n" .. GUILD_BANK .. "\n" .. ns.Stormwind .. " (" .. L["Portal"] ..")" }
                        minimap[393][67926633] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS3, mnID = 394, type = "PathRU", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = "\n" .. BANK .. "\n" .. GUILD_BANK .. "\n" .. ns.Stormwind .. " (" .. L["Portal"] ..")" }
                        minimap[393][32697602] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS3, mnID = 394, type = "PathLO", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = "\n" .. BANK .. "\n" .. GUILD_BANK .. "\n" .. ns.Stormwind .. " (" .. L["Portal"] ..")" }
                        minimap[394][55347175] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS2, mnID = 393, type = "PathLO", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = "\n" .. BUTTON_LAG_AUCTIONHOUSE .. " " .. REQUIRES_LABEL .. " " .. L["Engineer"] .. "\n" .. MINIMAP_TRACKING_INNKEEPER .. "\n" .. L["Blacksmithing"] }
                        minimap[394][67115809] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS2, mnID = 393, type = "PathLO", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = "\n" .. BUTTON_LAG_AUCTIONHOUSE .. " " .. REQUIRES_LABEL .. " " .. L["Engineer"] .. "\n" .. MINIMAP_TRACKING_INNKEEPER .. "\n" .. L["Blacksmithing"] }
                        minimap[394][31955456] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS2, mnID = 393, type = "PathRU", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = "\n" .. BUTTON_LAG_AUCTIONHOUSE .. " " .. REQUIRES_LABEL .. " " .. L["Engineer"] .. "\n" .. MINIMAP_TRACKING_INNKEEPER .. "\n" .. L["Blacksmithing"] }
                        minimap[394][63182065] = { name = L["Passage"] .. " " .. DUNGEON_FLOOR_GILNEAS2, mnID = 393, type = "PathRU", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = "\n" .. BUTTON_LAG_AUCTIONHOUSE .. " " .. REQUIRES_LABEL .. " " .. L["Engineer"] .. "\n" .. MINIMAP_TRACKING_INNKEEPER .. "\n" .. L["Blacksmithing"] }
                    end

                    if self.db.profile.showMinimapCapitalsInnkeeper then
                        minimap[393][36506610] = { npcID = 64149, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsAuctioneer then
                        minimap[393][57045237] = { npcID = 65599, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = REQUIRES_LABEL .. " " .. L["Engineer"] }
                    end

                    if self.db.profile.showMinimapCapitalsBank then
                        minimap[393][55624688] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[394][48517769] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[394][42608412] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[394][38927502] = { dnID = BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[394][44866826] = { dnID = BANK .. " / " .. GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsTransmogger then
                        minimap[394][55598526] = { npcID = 64573, name = "", type = "Transmogger", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsPvEVendor then
                        minimap[394][42834374] = { npcIDs1 = 74020, npcIDs2 = 74022, npcIDs3 = 74021, npcIDs4 = 74027, name = TRANSMOG_SET_PVE .. " " .. MERCHANT, type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsMailbox then
                        minimap[393][61883771] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[393][30356275] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[394][74255074] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[394][64703436] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[394][44228360] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[394][39496198] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end

            --Transports Sot7S
                if self.db.profile.activate.MinimapCapitalsTransporting then

                    if self.db.profile.showMinimapCapitalsPortals then
                        minimap[394][71563593] = { mnID = 84, name = "", type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end

            --Professions Sot7S
                if self.db.profile.activate.MinimapCapitalsProfessions then

                    if self.db.profile.showMinimapCapitalsBlacksmith then
                        minimap[393][72655225] = { npcID = 64085, name = "", type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.db.profile.showMinimapCapitalsTailoring then
                        minimap[393][45826273] = { npcID = 64482, name = "", type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end

            end

        end


    --###############################################################################################
    --################################         Neutral Cities       #################################
    --###############################################################################################

    --################
    --### Darkmoon ###
    --################
        if self.db.profile.showMinimapCapitalsDarkmoon then

        --General Darkmoon
            if self.db.profile.activate.MinimapCapitalsGeneral then
    
                if self.db.profile.showMinimapCapitalsPvEVendor then
                    minimap[407][48246955] = { npcID = 14846, name = "", type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[407][51447510] = { npcID = 85484, name = "", type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[407][48096567] = { npcIDs1 = 56335, npcIDs2 = 55072, npcIDs3 = 14828, name = "", type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
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
                        minimap[407][51412247] = { mnID = 7, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[407][50549077] = { mnID = 7, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.faction == "Alliance" and not db.activate.MinimapCapitalsEnemyFaction then
                        minimap[407][51412247] = { mnID = 37, name = "", type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[407][50549077] = { mnID = 37, name = "", type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end

            end

        --Professions Darkmoon
            if self.db.profile.activate.MinimapCapitalsProfessions then

                if self.db.profile.showMinimapCapitalsProfessionsMixed then
                    
                    if self.db.profile.showMinimapCapitalsMining and self.db.profile.showMinimapCapitalsLeatherworking and not self.db.profile.showMinimapCapitalsEngineer then
                        minimap[407][49256078] = { npcID = 14841, name = "", dnID = TextIconMining:GetIconString() .. " " .. L["Mining"] .. "\n" .. TextIconLeatherworking:GetIconString() .. " " .. L["Leatherworking"], TransportName = TUTORIAL_TITLE1, type = "ProfessionsMixed", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    elseif self.db.profile.showMinimapCapitalsMining and self.db.profile.showMinimapCapitalsEngineer and not self.db.profile.showMinimapCapitalsLeatherworking then
                        minimap[407][49256078] = { npcID = 14841, name = "", dnID = TextIconMining:GetIconString() .. " " .. L["Mining"] .. "\n" .. TextIconEngineer:GetIconString() .. " " .. L["Engineer"], TransportName = TUTORIAL_TITLE1, type = "ProfessionsMixed", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    elseif self.db.profile.showMinimapCapitalsLeatherworking and self.db.profile.showMinimapCapitalsEngineer and not self.db.profile.showMinimapCapitalsMining then
                        minimap[407][49256078] = { npcID = 14841, name = "", dnID = TextIconLeatherworking:GetIconString() .. " " .. L["Leatherworking"] .. "\n" .. TextIconEngineer:GetIconString() .. " " .. L["Engineer"], TransportName = TUTORIAL_TITLE1, type = "ProfessionsMixed", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    elseif self.db.profile.showMinimapCapitalsMining and self.db.profile.showMinimapCapitalsLeatherworking and self.db.profile.showMinimapCapitalsEngineer then
                        minimap[407][49256078] = { npcID = 14841, name = "", dnID = TextIconMining:GetIconString() .. " " .. L["Mining"] .. "\n" .. TextIconLeatherworking:GetIconString() .. " " .. L["Leatherworking"] .. "\n" .. TextIconEngineer:GetIconString() .. " " .. L["Engineer"], TransportName = TUTORIAL_TITLE1, type = "ProfessionsMixed", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    elseif self.db.profile.showMinimapCapitalsMining and not (self.db.profile.showMinimapCapitalsLeatherworking and self.db.profile.showMinimapCapitalsEngineer) then
                        minimap[407][49446141] = { npcID = 14841, name = L["Mining"], type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = TUTORIAL_TITLE1 }
                    elseif self.db.profile.showMinimapCapitalsLeatherworking and not (self.db.profile.showMinimapCapitalsMining and self.db.profile.showMinimapCapitalsEngineer) then
                        minimap[407][49406080] = { npcID = 14841, name = L["Leatherworking"], type = "Leatherworking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = TUTORIAL_TITLE1 }
                    elseif self.db.profile.showMinimapCapitalsEngineer and not (self.db.profile.showMinimapCapitalsLeatherworking and self.db.profile.showMinimapCapitalsMining) then
                        minimap[407][49406081] = { npcID = 14841, name = L["Engineer"], type = "Engineer", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = TUTORIAL_TITLE1 }
                    end

                    if self.db.profile.showMinimapCapitalsSkinning and self.db.profile.showMinimapCapitalsHerbalism and not self.db.profile.showMinimapCapitalsJewelcrafting then
                        minimap[407][55007061] = { npcID = 14833, name = "", dnID = TextIconSkinning:GetIconString() .. " " .. L["Skinning"] .. "\n" .. TextIconHerbalism:GetIconString() .. " " .. L["Herbalism"], TransportName = TUTORIAL_TITLE1, type = "ProfessionsMixed", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    elseif self.db.profile.showMinimapCapitalsSkinning and self.db.profile.showMinimapCapitalsJewelcrafting and not self.db.profile.showMinimapCapitalsHerbalism then
                        minimap[407][55007061] = { npcID = 14833, name = "", dnID = TextIconSkinning:GetIconString() .. " " .. L["Skinning"] .. "\n" .. TextIconJewelcrafting:GetIconString() .. " " .. L["Jewelcrafting"], TransportName = TUTORIAL_TITLE1, type = "ProfessionsMixed", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    elseif self.db.profile.showMinimapCapitalsJewelcrafting and self.db.profile.showMinimapCapitalsHerbalism and not self.db.profile.showMinimapCapitalsSkinning then
                        minimap[407][55007061] = { npcID = 14833, name = "", dnID = TextIconJewelcrafting:GetIconString() .. " " .. L["Jewelcrafting"] .. "\n" .. TextIconHerbalism:GetIconString() .. " " .. L["Herbalism"], TransportName = TUTORIAL_TITLE1, type = "ProfessionsMixed", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    elseif self.db.profile.showMinimapCapitalsJewelcrafting and self.db.profile.showMinimapCapitalsHerbalism and self.db.profile.showMinimapCapitalsSkinning then
                        minimap[407][55007061] = { npcID = 14833, name = "", dnID = TextIconJewelcrafting:GetIconString() .. " " .. L["Jewelcrafting"] .. "\n" .. TextIconHerbalism:GetIconString() .. " " .. L["Herbalism"] .. "\n" .. TextIconSkinning:GetIconString() .. " " .. L["Skinning"], TransportName = TUTORIAL_TITLE1, type = "ProfessionsMixed", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    elseif self.db.profile.showMinimapCapitalsSkinning and not (self.db.profile.showMinimapCapitalsHerbalism and self.db.profile.showMinimapCapitalsJewelcrafting) then
                        minimap[407][55007060] = { npcID = 14833, name = "", type = "Skinning", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Skinning"] .. " " .. TUTORIAL_TITLE1 }
                    elseif self.db.profile.showMinimapCapitalsHerbalism and not (self.db.profile.showMinimapCapitalsSkinning and self.db.profile.showMinimapCapitalsJewelcrafting) then
                        minimap[407][55007060] = { npcID = 14833, name = "", type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Herbalism"] .. " " .. TUTORIAL_TITLE1 }
                    elseif self.db.profile.showMinimapCapitalsJewelcrafting and not (self.db.profile.showMinimapCapitalsSkinning and self.db.profile.showMinimapCapitalsHerbalism) then
                        minimap[407][55007060] = { npcID = 14833, name = "", type = "Jewelcrafting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Jewelcrafting"] .. " " .. TUTORIAL_TITLE1 }
                    end

                    if self.db.profile.showMinimapCapitalsCooking and self.db.profile.showMinimapCapitalsFishing then
                        minimap[407][52606801] = { name = "", dnID = TextIconFishing:GetIconString() .. " " .. PROFESSIONS_FISHING .. "\n" .. TextIconCooking:GetIconString() .. " " .. PROFESSIONS_COOKING, TransportName = TUTORIAL_TITLE1, type = "ProfessionsMixed", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    elseif self.db.profile.showMinimapCapitalsCooking and not self.db.profile.showMinimapCapitalsFishing then
                        minimap[407][52606801] = { name = PROFESSIONS_COOKING, type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = TUTORIAL_TITLE1 }
                    elseif self.db.profile.showMinimapCapitalsFishing and not self.db.profile.showMinimapCapitalsCooking then
                        minimap[407][52606801] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = TUTORIAL_TITLE1 }
                    end

                    if self.db.profile.showMinimapCapitalsInscription and self.db.profile.showMinimapCapitalsEnchanting then
                        minimap[407][53007580] = { npcID = 14822, name = "", dnID = TextIconInscription:GetIconString() .. " " .. INSCRIPTION .. "\n" .. TextIconEnchanting:GetIconString() .. " " .. L["Enchanting"], TransportName = TUTORIAL_TITLE1, type = "ProfessionsMixed", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    elseif self.db.profile.showMinimapCapitalsInscription and not self.db.profile.showMinimapCapitalsEnchanting then
                        minimap[407][53007580] = { npcID = 14822, name = "", type = "Inscription", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = INSCRIPTION .. " " .. TUTORIAL_TITLE1 }
                    elseif self.db.profile.showMinimapCapitalsEnchanting and not self.db.profile.showMinimapCapitalsInscription then
                        minimap[407][53007580] = { npcID = 14822, name = "", type = "Enchanting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Enchanting"] .. " " .. TUTORIAL_TITLE1 }
                    end

                end

                if not self.db.profile.showMinimapCapitalsProfessionsMixed then

                    if self.db.profile.showMinimapCapitalsMining then
                        minimap[407][49446141] = { npcID = 14841, name = "" , type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Mining"] .. " " .. TUTORIAL_TITLE1 }
                    end

                    if self.db.profile.showMinimapCapitalsLeatherworking then
                        minimap[407][49406080] = { npcID = 14841, name = "", type = "Leatherworking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Leatherworking"] .. " " .. TUTORIAL_TITLE1 }
                    end

                    if self.db.profile.showMinimapCapitalsEngineer  then
                        minimap[407][49406081] = { npcID = 14841, name = "", type = "Engineer", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Engineer"] .. " " .. TUTORIAL_TITLE1 }
                    end

                    if self.db.profile.showMinimapCapitalsSkinning then
                        minimap[407][48197805] = { npcID = 14833, name = "", type = "Skinning", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Skinning"] .. " " .. TUTORIAL_TITLE1 }
                    end                    

                    if self.db.profile.showMinimapCapitalsJewelcrafting then
                        minimap[407][55007060] = { npcID = 14833, name = "", type = "Jewelcrafting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Jewelcrafting"] .. " " .. TUTORIAL_TITLE1 }
                    end   

                    if self.db.profile.showMinimapCapitalsHerbalism then
                        minimap[407][55017052] = { npcID = 14833, name = "", type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Herbalism"] .. " " .. TUTORIAL_TITLE1 }
                    end    
                
                    if self.db.profile.showMinimapCapitalsCooking then
                        minimap[407][52606800] = { npcID = 14845, name = "", type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = PROFESSIONS_COOKING .. " " .. TUTORIAL_TITLE1 }
                    end

                    if self.db.profile.showMinimapCapitalsFishing then
                        --minimap[407][52608860] = { name = PROFESSIONS_FISHING, type = "Fishing", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[407][52606800] = { npcID = 14845, name = "", type = "Fishing", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = PROFESSIONS_FISHING .. " " .. TUTORIAL_TITLE1 }
                    end

                    if self.db.profile.showMinimapCapitalsInscription then
                        minimap[407][53007580] = { npcID = 14822, name = "", type = "Inscription", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = INSCRIPTION .. " " .. TUTORIAL_TITLE1 }
                    end

                    if self.db.profile.showMinimapCapitalsEnchanting then
                        minimap[407][53007580] = { npcID = 14822, name = "", type = "Enchanting", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Enchanting"] .. " " .. TUTORIAL_TITLE1 }
                    end

                end

                if self.db.profile.showMinimapCapitalsAlchemy then
                    minimap[407][50206940] = { npcID = 14844, name = "", type = "Alchemy", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Alchemy"] .. " " .. TUTORIAL_TITLE1 }
                end

                if self.db.profile.showMinimapCapitalsTailoring then
                    minimap[407][55805440] = { npcID = 10445, name = "", type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Tailoring"] .. " " .. TUTORIAL_TITLE1 }
                end

                if self.db.profile.showMinimapCapitalsBlacksmith then
                    minimap[407][51008180] = { npcID = 14829, name = "", type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Blacksmithing"] .. " " .. TUTORIAL_TITLE1 }
                end

                if self.db.profile.showMinimapCapitalsArchaeology then
                    minimap[407][51836072] = { npcID = 14847, name = "", type = "Archaeology", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = PROFESSIONS_ARCHAEOLOGY .. " " .. TUTORIAL_TITLE1 }
                end

            end

        end

    --#################
    --### Shattrath ###
    --#################
        if self.db.profile.showMinimapCapitalsShattrath then

        --General Shattrath
            if self.db.profile.activate.MinimapCapitalsGeneral then
    
                if self.db.profile.showMinimapCapitalsInnkeeper then
                    minimap[111][56278147] = { npcID = 19232, name =  L["The Scryers"], type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[111][28284938] = { npcID = 19046, name =  L["The Aldor"], type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
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
                    minimap[111][57066278] = { npcIDs1 = 50139, npcIDs2 = 50140, name = L["The Scryers"], type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[111][51242693] = { npcIDs1 = 50143, npcIDs2 = 50145, name = L["The Aldor"], type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsBank then
                    minimap[111][60226036] = { dnID = BANK .. " - " .. L["The Scryers"], name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[111][62245901] = { dnID = GUILD_BANK  .. " - " .. L["The Scryers"], name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[111][47932940] = { dnID = BANK .. " - " .. L["The Aldor"], name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[111][46113106] = { dnID = GUILD_BANK  .. " - " .. L["The Aldor"], name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsPvEVendor then
                    minimap[111][50834228] = { npcID = 18525, name = TRANSMOG_SET_PVE .. " " .. MERCHANT, type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsRenownQuartermaster then
                    minimap[111][50994171] = { npcID = 21432, name = "", type = "RenownQuartermaster", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[111][60486423] = { npcID = 19331, name = "", type = "RenownQuartermaster", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[111][47752581] = { npcID = 19321, name = "", type = "RenownQuartermaster", showInZone = false, showOnContinent = false, showOnMinimap = true }
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
                    minimap[111][28604760] = { npcID = 21518, name = L["The Aldor"], type = "StablemasterN", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[111][55808080] = { npcID = 21517, name = L["The Scryers"], type = "StablemasterN", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

            end

        --Transports Shattrath
            if self.db.profile.activate.MinimapCapitalsTransporting then
    
                if self.db.profile.showMinimapCapitalsPortals then
                    minimap[111][48614203] = { mnID = 122, name = "", type = "Portal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal from Shattrath to Quel'Danas 

                    if self.faction == "Horde" or db.activate.MinimapCapitalsEnemyFaction then
                        minimap[111][56784884] = { mnID = 85, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal from Shattrath to Orgrimmar 
                    end

                    if self.faction == "Alliance" or db.activate.MinimapCapitalsEnemyFaction then
                        minimap[111][57214825] = { mnID = 84,  name = "" , type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal from Shattrath to Stormwind 
                    end
                end

                if self.db.profile.showMinimapCapitalsFP then
                    minimap[111][63794171] = { npcID = 18940, name = "", type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

            end

        --Professions Shattrath
            if self.db.profile.activate.MinimapCapitalsProfessions then

                if self.db.profile.showMinimapCapitalsAlchemy or self.db.profile.showMinimapCapitalsLeatherworking  or self.db.profile.showMinimapCapitalsEngineer or self.db.profile.showMinimapCapitalsSkinning or self.db.profile.showMinimapCapitalsTailoring or self.db.profile.showMinimapCapitalsJewelcrafting or self.db.profile.showMinimapCapitalsBlacksmith or self.db.profile.showMinimapCapitalsMining or self.db.profile.showMinimapCapitalsFishing or self.db.profile.showMinimapCapitalsHerbalism or self.db.profile.showMinimapCapitalsInscription or self.db.profile.showMinimapCapitalsEnchanting or self.db.profile.showMinimapCapitalsCooking then
                    minimap[111][43709093] = { dnID = TUTORIAL_TITLE38 .. " - " .. L["The Scryers"] .. "\n" .. "\n" .. L["Alchemy"] .. "\n" .. L["Engineer"] .. "\n" .. L["Jewelcrafting"] .. "\n" .. L["Leatherworking"] .. "\n" .. L["Blacksmithing"] .. "\n" .. L["Tailoring"] .. "\n" .. L["Skinning"] .. "\n" .. L["Mining"] .. "\n" .. L["Herbalism"] .. "\n" .. L["Enchanting"] .. "\n" .. INSCRIPTION .. "\n" .. PROFESSIONS_FISHING .. "\n" .. PROFESSIONS_COOKING, name = "", type = "ProfessionsMixed", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsAlchemy then
                    minimap[111][37977048] = { npcID = 33630, name = L["The Scryers"], type = "Alchemy", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[111][38892992] = { npcID = 33674, name = L["The Aldor"], type = "Alchemy", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[111][45612149] = { npcID = 19052, name = "", type = "Alchemy", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end
            
                if self.db.profile.showMinimapCapitalsLeatherworking then
                    minimap[111][41366301] = { npcID = 33635, name = L["The Scryers"], type = "Leatherworking", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[111][37652815] = { npcID = 33681, name = L["The Aldor"], type = "Leatherworking", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[111][67256738] = { npcID = 19187, name = "", type = "Leatherworking", showInZone = false, showOnContinent = false, showOnMinimap = true }

                end

                if self.db.profile.showMinimapCapitalsEngineer then
                    minimap[111][43926531] = { npcID = 33634, name = L["The Scryers"], type = "Engineer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[111][37823205] = { npcID = 33677, name = L["The Aldor"], type = "Engineer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsSkinning then
                    minimap[111][40626347] = { npcID = 33641, name = L["The Scryers"], type = "Skinning", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[111][36972686] = { npcID = 33683, name = L["The Aldor"], type = "Skinning", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[111][63946588] = { npcID = 19180, name = "", type = "Skinning", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsTailoring then
                    minimap[111][41176365] = { npcID = 33636, name = L["The Scryers"], type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[111][37812700] = { npcID = 33684, name = L["The Aldor"], type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsJewelcrafting then
                    minimap[111][58027508] = { npcID = 33637, name =  L["The Scryers"], type = "Jewelcrafting", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[111][35671956] = { npcID = 19065, name = L["The Aldor"], type = "Jewelcrafting", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[111][36024745] = { npcID = 33680, name = L["The Aldor"], type = "Jewelcrafting", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsBlacksmith then
                    minimap[111][43236492] = { npcID = 33631, name = L["The Scryers"], type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[111][37293132] = { npcID = 33675, name = L["The Aldor"], type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[111][69484332] = { npcID = 20124, name = "", type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsMining then
                    minimap[111][58917523] = { npcID = 33640, name = L["The Scryers"], type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[111][36054859] = { npcID = 33682, name = L["The Aldor"], type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsFishing then
                    --minimap[111][43439160] = { name = PROFESSIONS_FISHING .. " - " .. L["The Scryers"], type = "Fishing", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsHerbalism then
                    minimap[111][38807156] = { npcID = 33639, name = L["The Scryers"], type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[111][38073007] = { npcID = 33678, name = L["The Aldor"], type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsInscription then
                    minimap[111][55947403] = { npcID = 33638, name = L["The Scryers"], type = "Inscription", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[111][36014345] = { npcID = 33679, name = L["The Aldor"], type = "Inscription", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsEnchanting then
                    minimap[111][55417484] = { npcID = 33633, name = L["The Scryers"], type = "Enchanting", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[111][36514454] = { npcID = 33676, name = L["The Aldor"], type = "Enchanting", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsArchaeology then
                    minimap[111][62667040] = { npcID = 47575, name = "", type = "Archaeology", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsCooking then
                    minimap[111][74793084] = { npcID = 19186, name = "", type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[111][63066835] = { npcID = 19185, name = "", type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true }
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
                    minimap[125][63885454] = { npcID = 31439, mnID = 125, name = ns.ArchmageTimear .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " ", id = { 875, 786, 768, 861, 946 }, type = "LFR", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

            end

        --General Dalaran Northrend
            if self.db.profile.activate.MinimapCapitalsGeneral then
    
                if self.db.profile.showMinimapCapitalsInnkeeper then
                    minimap[125][50273955] = { npcID = 28687, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[126][35425767] = { npcID = 29532, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }


                    if self.faction == "Horde" or db.activate.MinimapCapitalsEnemyFaction then
                        minimap[125][65613218] = { npcID = 31557, name = "", TransportName = ITEM_REQ_HORDE, type = "InnkeeperH", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.faction == "Alliance" or db.activate.MinimapCapitalsEnemyFaction then
                        minimap[125][44666336] = { npcID = 32413, name = "", TransportName = ITEM_REQ_ALLIANCE, type = "InnkeeperA", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end

                if self.db.profile.showMinimapCapitalsPaths then
                    minimap[126][11648435] = { name = L["Exit"], mnID = 127, type = "PathLU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[126][25044295] = { name = "", mnID = 125, TransportName = L["Passage"] .. " - " .. DUNGEON_FLOOR_DALARAN1, type = "PathR", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[126][66694845] = { name = "", mnID = 125, TransportName = L["Passage"] .. " - " .. DUNGEON_FLOOR_DALARAN1, type = "PathLO", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[125][35294528] = { name = "", mnID = 126, TransportName = L["Passage"] .. " - " .. DUNGEON_FLOOR_DALARAN2, type = "PathL", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[125][60294758] = { name = "", mnID = 126, TransportName = L["Passage"] .. " - " .. DUNGEON_FLOOR_DALARAN2, TransportName = TRANSMOG_SET_PVP .. " " .. MERCHANT, type = "PathRU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[125][48343243] = { name = "", mnID = 126, TransportName = L["Passage"] .. " - " .. DUNGEON_FLOOR_DALARAN2, TransportName = TRANSMOG_SET_PVP .. " " .. MERCHANT, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsAuctioneer then
                    minimap[125][38402502] = { name = BUTTON_LAG_AUCTIONHOUSE, type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }

                    if self.faction == "Horde" or db.activate.MinimapCapitalsEnemyFaction then
                        minimap[125][65522343] = { npcID = 35607, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = ITEM_REQ_HORDE}
                    end

                    if self.faction == "Alliance" or db.activate.MinimapCapitalsEnemyFaction then
                        minimap[125][37175488] = { npcID = 35594, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = ITEM_REQ_ALLIANCE}
                    end

                end

                if self.db.profile.showMinimapCapitalsBank then
                    minimap[125][43167962] = { dnID = BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[125][53601525] = { dnID = BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[125][46237826] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[125][41747539] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[125][50541677] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[125][55181939] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[126][32705586] = { dnID = BANK .. "\n" .. GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsBarber then
                    minimap[125][51763170] = { npcID = 28708, name = "", type = "Barber", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsPvEVendor then
                    minimap[125][43744935] = { npcIDs1 = 28995, npcIDs2 = 35496, npcIDs3 = 29491, npcIDs4= 29495, npcIDs5 = 29703, npcIDs6 = 29702, name = TRANSMOG_SET_PVE .. " " .. MERCHANT, type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[125][51827196] = { npcIDs1 = 35497, npcIDs2 = 28992, npcIDs3 = 35500, npcIDs4 = 29523, name = TRANSMOG_SET_PVE .. " " .. MERCHANT, type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[125][49147380] = { npcIDs1 = 28994, npcIDs2 = 29494, name = TRANSMOG_SET_PVE .. " " .. MERCHANT, type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[125][46362680] = { npcIDs1 = 34252, npcIDs2 = 28997, npcIDs3 = 35498, npcIDs4 = 28990, name = TRANSMOG_SET_PVE .. " " .. MERCHANT, type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[126][60021149] = { npcID = 29538, name = TRANSMOG_SET_PVE .. " " .. MERCHANT, type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }

                    if self.faction == "Horde" or db.activate.MinimapCapitalsEnemyFaction then
                        minimap[125][66362219] = { npcIDs1 = 35495, npcIDs2 = 31582, npcIDs3 = 37941, npcIDs4 = 31581, npcIDs5 = 33963, name = TRANSMOG_SET_PVE .. " " .. MERCHANT .. " - " .. ITEM_REQ_HORDE, type = "PvEVendorH", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.faction == "Alliance" or db.activate.MinimapCapitalsEnemyFaction then
                        minimap[125][38135483] = { npcIDs1 = 31580, npcIDs2 = 31579, npcIDs3 = 35494, npcIDs4 = 37942, npcIDs5 = 33964, name = TRANSMOG_SET_PVE .. " " .. MERCHANT .. " - " .. ITEM_REQ_ALLIANCE .. " (" .. DUNGEON_FLOOR_GILNEAS3 .. ")", type = "PvEVendorA", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end

                if self.db.profile.showMinimapCapitalsPvPVendor then
                    minimap[126][59355799] = { npcIDs1 = 40212, npcIDs2 = 30885, npcIDs3 = 69321, npcIDs4 = 69318, npcIDs5 = 69973, npcIDs6 = 69971, name = TRANSMOG_SET_PVP .. " " .. MERCHANT, type = "PvPVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
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
                    minimap[126][33595607] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsStablemaster then
                    minimap[125][59003860] = { npcID = 28690, name = "", type = "StablemasterN", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsMountMerchent then
                    minimap[125][57604205] = { npcID = 32216, name = PERKS_VENDOR_CATEGORY_MOUNT .. " " .. MERCHANT, type = "MountMerchant", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

            end

        --Transports Dalaran Northrend
            if self.db.profile.activate.MinimapCapitalsTransporting then
    
                if self.db.profile.showMinimapCapitalsPortals then
                    minimap[125][55904678] = { mnID = 127, name = "", type = "Portal", showInZone = false, showOnContinent = false, showOnMinimap = true } 

                    if self.faction == "Horde" or db.activate.MinimapCapitalsEnemyFaction then
                        minimap[125][55322545] = { mnID = 85, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dalaran to Orgrimmar Portal 
                    end

                    if self.faction == "Alliance" or db.activate.MinimapCapitalsEnemyFaction then
                        minimap[125][40016276] = { mnID = 84,  name = "" , type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dalaran to Stormwind City Portal
                    end
                end

                if self.db.profile.showMinimapCapitalsFP then
                    minimap[125][72164583] = { npcID = 28674, name = "", type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

            end

        --Professions Dalaran Northrend
            if self.db.profile.activate.MinimapCapitalsProfessions then

                if self.db.profile.showMinimapCapitalsAlchemy then
                    minimap[125][42633205] = { npcID = 28703, name = "", type = "Alchemy", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end
            
                if self.db.profile.showMinimapCapitalsLeatherworking then
                    minimap[125][34412919] = { npcIDs1 = 28700, npcIDs2 = 29507, npcIDs3 = 29508, npcIDs4 = 29509, name = "", type = "Leatherworking", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsEngineer then
                    minimap[125][39652486] = { npcID = 29513, name = "", type = "Engineer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsSkinning then
                    minimap[125][34832786] = { npcID = 28696, name = "", type = "Skinning", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsTailoring then
                    minimap[125][36133357] = { npcID = 28699, name = "", type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsJewelcrafting then
                    minimap[125][40693536] = { npcID = 28701, name = "", type = "Jewelcrafting", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsBlacksmith then
                    minimap[125][45162895] = { npcID = 29505, name = "", type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsMining then
                    minimap[125][41462566] = { npcID = 28698, name = "", type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsFishing then
                    minimap[125][53066493] = { npcID = 28742, name = "", type = "Fishing", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsHerbalism then
                    minimap[125][42933408] = { npcID = 28704, name = "", type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsInscription then
                    minimap[125][41593717] = { npcID = 28702, name = "", type = "Inscription", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsEnchanting then
                    minimap[125][39043981] = { npcID = 28693, name = "", type = "Enchanting", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsArchaeology then
                    minimap[125][48363820] = { npcID = 47579, name = "", type = "Archaeology", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.faction == "Horde" or db.activate.MinimapCapitalsEnemyFaction then

                    if self.db.profile.showMinimapCapitalsCooking then
                        minimap[125][69943898] = { npcID = 29631, name = "", type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = "("..ITEM_REQ_HORDE..")" }
                    end

                end

                if self.faction == "Alliance" or db.activate.MinimapCapitalsEnemyFaction then

                    if self.db.profile.showMinimapCapitalsCooking then
                        minimap[125][40486581] = { npcID = 28705, name = "", type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = "("..ITEM_REQ_ALLIANCE..")" }
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
                    minimap[627][63535488] = { npcID = 111246, mnID = 627, name = ns.ArchmageTimear .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " ", id = { 875, 786, 768, 861, 946 }, type = "LFR", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

            end

        --General Dalaran Legion
            if self.db.profile.activate.MinimapCapitalsGeneral then
    
                if self.db.profile.showMinimapCapitalsInnkeeper then
                    minimap[627][49784006] = { npcID = 96806, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[831][50027563] = { npcID = 123395, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }

                    if self.faction == "Horde" or db.activate.MinimapCapitalsEnemyFaction then
                        minimap[627][65443217] = { npcID = 96796, name = "", TransportName = "("..ITEM_REQ_HORDE..")", type = "InnkeeperH", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                    if self.faction == "Alliance" or db.activate.MinimapCapitalsEnemyFaction then
                        minimap[627][44196398] = { npcID = 96790, name = "", TransportName = ITEM_REQ_ALLIANCE, type = "InnkeeperA", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    end

                end

                if self.db.profile.showMinimapCapitalsPaths then
                    minimap[627][34664554] = { name = "", mnID = 628, TransportName = L["Passage"] .. " - " .. DUNGEON_FLOOR_DALARAN2, type = "PathL", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[627][59714771] = { name = "", mnID = 628, TransportName = L["Passage"] .. " - " .. DUNGEON_FLOOR_DALARAN2, type = "PathRU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[628][73076461] = { name = "", mnID = 627, TransportName = L["Passage"] .. " - " .. DUNGEON_FLOOR_DALARAN1, type = "PathRU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[628][27815332] = { name = "", mnID = 627, TransportName = L["Passage"] .. " - " .. DUNGEON_FLOOR_DALARAN1, type = "PathL", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[627][48343243] = { name = "", mnID = 628, TransportName = L["Passage"] .. " - " .. DUNGEON_FLOOR_DALARAN2, type = "PathU", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsAuctioneer then
                    minimap[627][39082599] = { npcID = 35607, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = REQUIRES_LABEL .. " " .. L["Engineer"] }
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
                    minimap[627][51763170] = { npcID = 96781, name = "", type = "Barber", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsTransmogger then
                    minimap[627][39294161] = { npcID = 99867, name = "", type = "Transmogger", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsPvEVendor then
                    minimap[627][37635617] = { npcIDs1 = 97342, npcIDs2 = 96975, npcIDs3 = 96976, npcIDs4 = 96987, npcIDs5 = 97332, name = TRANSMOG_SET_PVE .. " " .. MERCHANT, type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[627][51067322] = { npcIDs1 = 96978, npcIDs2 = 96977, npcIDs3 = 96980, npcIDs4 = 96979, name = TRANSMOG_SET_PVE .. " " .. MERCHANT, type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[831][68275675] = { npcID = 127151, name = TRANSMOG_SET_PVE .. " " .. MERCHANT, type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Vindikaar
                    minimap[831][43257451] = { npcID = 127120, name = TRANSMOG_SET_PVE .. " " .. MERCHANT, type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Vindikaar
                    minimap[832][46517167] = { npcID = 121589, name = TRANSMOG_SET_PVE .. " " .. MERCHANT, type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Vindikaar
                end

                if self.db.profile.showMinimapCapitalsMountMerchent then
                    minimap[627][57604205] = { npcID = 92489, name = PERKS_VENDOR_CATEGORY_MOUNT .. " " .. MERCHANT, type = "MountMerchant", showInZone = false, showOnContinent = false, showOnMinimap = true }
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
                    minimap[627][59003860] = { npcID = 96507, name = "", type = "StablemasterN", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[831][46937568] = { npcID = 96507, name = "", type = "StablemasterN", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

            end

        --Transports Dalaran Legion
            if self.db.profile.activate.MinimapCapitalsTransporting then
    
                if self.db.profile.showMinimapCapitalsPortals then
                    minimap[629][30798454] = { mnID = 115, name = "", type = "PortalS", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[629][28777742] = { mnID = 25, name ="", type = "PortalS", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[629][31947153] = { mnID = 42, name ="", type = "PortalS", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[629][64752082] = { mnID = 627, name = "", type = "PortalS", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[627][49324758] = { mnID = 629, name = "", TransportName = DUNGEON_FLOOR_DALARAN7012, type = "Portal", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[832][43432516] = { mnID = 627, name = "", type = "Portal", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[627][56323078] = { npcID = 121602, name = "", dnID = "\n" .. TOOLTIP_BATTLE_PET .. " " .. CALENDAR_TYPE_DUNGEON .. " " .. L["Portals"] .. ":\n" .. " ", type = "PortalAPetBattleDungeon", showInZone = false, showOnContinent = false, showOnMinimap = true,
                                               showWWW = true, wwwName = BATTLE_PET_SOURCE_2 .. " " .. REQUIRES_LABEL,
                                               mnIDs1 = 11, questIDs1 = 45423, wwwLinks1 = "https://www.wowhead.com/quest=45423",
                                               mnIDs2 = 52, questIDs2 = 46291, wwwLinks2 = "https://www.wowhead.com/quest=46291", 
                                               mnIDs3 = 30, questIDs3 = 54185, wwwLinks3 = "https://www.wowhead.com/quest=54185",
                                               mnIDs4 = 23, questIDs4 = 56491, wwwLinks4 = "https://www.wowhead.com/quest=56491", 
                                               mnIDs5 = 35, questIDs5 = 58457, wwwLinks5 = "https://www.wowhead.com/quest=58457" } -- Portal Manapuff
                    

                    if self.faction == "Horde" or db.activate.MinimapCapitalsEnemyFaction then
                        minimap[629][33557905] = { mnID = 971, name = "", type = "HPortalS", showInZone = false, showOnContinent = false, showOnMinimap = true }
                        minimap[627][55242392] = { mnID = 85, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dalaran to Orgrimmar Portal
                    end

                    if self.faction == "Alliance" or db.activate.MinimapCapitalsEnemyFaction then
                        minimap[627][40416378] = { mnID = 84,  name = "" , type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true } --  Dalaran to Stormwind City Portal
                    end
                end

                if self.db.profile.showMinimapCapitalsFP then
                    minimap[627][69825114] = { npcID = 96813, name = "", type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

            end

        --Professions Dalaran Legion
            if self.db.profile.activate.MinimapCapitalsProfessions then

                if self.db.profile.showMinimapCapitalsAlchemy then
                    minimap[627][42023184] = { npcID = 92456, name = "", type = "Alchemy", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end
            
                if self.db.profile.showMinimapCapitalsLeatherworking then
                    minimap[627][35102936] = { npcID = 93523, name = "", type = "Leatherworking", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsEngineer then
                    minimap[627][38552459] = { npcID = 93520, name = "", type = "Engineer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsSkinning then
                    minimap[627][36082796] = { npcID = 93541, name = "", type = "Skinning", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsTailoring then
                    minimap[627][34993457] = { npcID = 93542, name = "", type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsJewelcrafting then
                    minimap[627][40043528] = { npcID = 93527, name = "", type = "Jewelcrafting", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsBlacksmith then
                    minimap[627][44122870] = { npcID = 92183, name = "", type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsMining then
                    minimap[627][46102579] = { npcID = 93189, name = "", type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsFishing then
                    minimap[627][52776559] = { npcID = 95844, name = "", type = "Fishing", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsHerbalism then
                    minimap[627][42363394] = { npcID = 92464, name = "", type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsInscription then
                    minimap[627][41253707] = { npcID = 92195, name = "", type = "Inscription", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsEnchanting then
                    minimap[627][38294031] = { npcID = 93531, name = "", type = "Enchanting", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsArchaeology then
                    minimap[627][41242630] = { npcID = 93538, name = "", type = "Archaeology", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.faction == "Horde" or db.activate.MinimapCapitalsEnemyFaction then

                    if self.db.profile.showMinimapCapitalsCooking then
                        minimap[627][69973897] = { npcID = 93536, name = "", type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = "("..ITEM_REQ_HORDE..")" }
                    end

                end

                if self.faction == "Alliance" or db.activate.MinimapCapitalsEnemyFaction then

                    if self.db.profile.showMinimapCapitalsCooking then
                        minimap[627][40586680] = { npcID = 93534, name = "", type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = "("..ITEM_REQ_ALLIANCE..")"}
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
                    minimap[1670][41377150] = { npcID = 205959, name = ns.Taelfar .. "\n" .. L["Registrant"] .. " - " .. RAID_FINDER .. "\n" .. " ", mnID = 1670, id = { 1190, 1193, 1195 }, type = "LFR", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

            end


        --General Oribos
            if self.db.profile.activate.MinimapCapitalsGeneral then
    
                if self.db.profile.showMinimapCapitalsInnkeeper then
                    minimap[1670][67505031] = { npcID = 156688, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsAuctioneer then
                    minimap[1670][38374376] = { npcID = 173571, name = "", type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = REQUIRES_LABEL .. " " .. L["Engineer"] }
                end

                if self.db.profile.showMinimapCapitalsBank then
                    minimap[1670][59502845] = { dnID = BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[1670][65033569] = { dnID = GUILD_BANK, name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsBarber then
                    minimap[1670][65096483] = { dnID = MINIMAP_TRACKING_BARBER, name = "", type = "Barber", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsPvPVendor then
                    minimap[1670][35005833] = { npcIDs1 = 164095, npcIDs2 = 168011, name = TRANSMOG_SET_PVP .. " " .. MERCHANT,  type = "PvPVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsTransmogger then
                    minimap[1670][64416963] = { npcID = 156663, name = "", type = "Transmogger", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsRenownQuartermaster then
                    minimap[1670][47217766] = { npcIDs1 = 176067, npcIDs2 = 176064, npcIDs3 = 176065, npcIDs4 = 176066, npcIDs5 = 176368, name = TRANSMOG_SET_PVE .. " " .. MERCHANT, type = "RenownQuartermaster", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsItemUpgrade then
                    minimap[1670][34505598] = { npcID = 164096, name = "", type = "ItemUpgrade", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsMailbox then
                    minimap[1670][30505250] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[1670][74004940] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[1670][58503680] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[1670][63505150] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsStablemaster then
                    minimap[1670][59207500] = { npcID = 156791, name = "", type = "StablemasterN", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

            end

        --Transports Oribos
            if self.db.profile.activate.MinimapCapitalsTransporting then
    
                if self.db.profile.showMinimapCapitalsPortals then
                    minimap[1671][49405127] = { mnID = 1543, name = "", type = "Portal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Oribos to The Maw
                    minimap[1671][30322269] = { mnID = 1961, name = "", type = "Portal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Oribos to Korthia
                    minimap[1671][49532566] = { mnID = 1970, name = "", type = "Portal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Oribos to Zereth Morthis

                    if self.faction == "Horde" or db.activate.MinimapCapitalsEnemyFaction then
                        minimap[1670][20805432] = { mnID = 85, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Oribos to Orgrimmar Portal
                    end

                    if self.faction == "Alliance" or db.activate.MinimapCapitalsEnemyFaction then
                        minimap[1670][20654625] = { mnID = 84,  name = "" , type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Oribos to Stormwind City Portal
                    end
                end

                if self.db.profile.showMinimapCapitalsTransport then
                    minimap[1670][47065029] = { mnID = 1671, name = "", type = "Tport2", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = DUNGEON_FLOOR_GILNEAS3 .. " (" .. L["Transport"] ..")" } -- Oribos to The Maw
                    minimap[1670][52094275] = { mnID = 1671, name = "", type = "Tport2", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = DUNGEON_FLOOR_GILNEAS3 .. " (" .. L["Transport"] ..")" } -- Oribos to The Maw
                    minimap[1670][57125033] = { mnID = 1671, name = "", type = "Tport2", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = DUNGEON_FLOOR_GILNEAS3 .. " (" .. L["Transport"] ..")" } -- Oribos to The Maw
                    minimap[1670][52085793] = { mnID = 1671, name = "", type = "Tport2", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = DUNGEON_FLOOR_GILNEAS3 .. " (" .. L["Transport"] ..")" } -- Oribos to The Maw
                    minimap[1671][55665162] = { mnID = 1670, name = "", type = "Tport2", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = DUNGEON_FLOOR_GILNEAS2 .. " (" .. L["Transport"] ..")" } -- Oribos to The Maw
                    minimap[1671][49536090] = { mnID = 1670, name = "", type = "Tport2", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = DUNGEON_FLOOR_GILNEAS2 .. " (" .. L["Transport"] ..")" } -- Oribos to The Maw
                    minimap[1671][43415157] = { mnID = 1670, name = "", type = "Tport2", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = DUNGEON_FLOOR_GILNEAS2 .. " (" .. L["Transport"] ..")" } -- Oribos to The Maw
                    minimap[1671][49554241] = { mnID = 1670, name = "", type = "Tport2", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = DUNGEON_FLOOR_GILNEAS2 .. " (" .. L["Transport"] ..")" } -- Oribos to The Maw
                end

                if self.db.profile.showMinimapCapitalsFP then
                    minimap[1671][60196756] = { npcID = 162666, name = "", type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

            end

        --Professions Oribos
            if self.db.profile.activate.MinimapCapitalsProfessions then

                if self.db.profile.showMinimapCapitalsAlchemy then
                    minimap[1670][39284044] = { npcID = 156687, name = "", type = "Alchemy", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end
            
                if self.db.profile.showMinimapCapitalsLeatherworking then
                    minimap[1670][42342642] = { npcID = 156669, name = "", type = "Leatherworking", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsEngineer then
                    minimap[1670][38114472] = { npcID = 156691, name = "", type = "Engineer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsSkinning then
                    minimap[1670][42072813] = { npcID = 156667, name = "", type = "Skinning", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsTailoring then
                    minimap[1670][45553182] = { npcID = 156681, name = "", type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsJewelcrafting then
                    minimap[1670][35164127] = { npcID = 156670, name = "", type = "Jewelcrafting", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsBlacksmith then
                    minimap[1670][40563139] = { npcID = 156666, name = "", type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsMining then
                    minimap[1670][39313292] = { npcID = 156668, name = "", type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsFishing then
                    minimap[1670][46162635] = { npcID = 156671, name = "", type = "Fishing", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsCooking then
                    minimap[1670][46812266] = { npcID = 156672, name = "", type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsHerbalism then
                    minimap[1670][40303824] = { npcID = 156686, name = "", type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsInscription then
                    minimap[1670][36473666] = { npcID = 156685, name = "", type = "Inscription", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsEnchanting then
                    minimap[1670][48422949] = { npcID = 156683, name = "", type = "Enchanting", showInZone = false, showOnContinent = false, showOnMinimap = true }
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
                    minimap[2112][47714635] = { npcID = 210817, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsAuctioneer then
                    minimap[2112][42705981] = { npcIDs1 = 197911, npcIDs2 = 188661, npcIDs3 = 185714, name = BUTTON_LAG_AUCTIONHOUSE, type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[2112][16705185] = { npcID = 189676, name = "", dnID = BLACK_MARKET_AUCTION_HOUSE, type = "BlackMarket", showInZone = false, showOnContinent = false, showOnMinimap = true }
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
                    minimap[2112][44083636] = { npcIDs1 = 199599, npcIDs2 = 199601, npcIDs3 = 199720, name = "", type = "PvPVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[2112][43074246] = { npcID = 197553, name = "", type = "PvPVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[2112][44844271] = { npcIDs1 = 209377, npcIDs2 = 214682, name = "", type = "PvPVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsTransmogger then
                    minimap[2112][74575782] = { npcID = 185570, name = "", type = "Transmogger", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsItemUpgrade then
                    minimap[2112][45753885] = { npcID = 199603, name = "", type = "ItemUpgrade", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[2112][45545624] = { npcID = 216608, name = "", type = "ItemUpgrade", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsDragonFlyTransmog then
                    minimap[2112][25035064] = { dnID = MINIMAP_TRACKING_TRANSMOGRIFIER .. " " .. MOUNT_JOURNAL_FILTER_DRAGONRIDING, name = "",  type = "DragonFlyTransmog", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsStablemaster then
                    minimap[2112][46807880] = { npcID = 185561, name = "", type = "StablemasterN", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsTradingPost then
                    minimap[2339][44645607] = { npcIDs1 = 219244, npcIDs2 = 219243, name = "", type = "TradingPost", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

            end

        --Transports Valdrakken
            if self.db.profile.activate.MinimapCapitalsTransporting then
    
                if self.db.profile.showMinimapCapitalsPortals then
                    minimap[2112][26104102] = { mnID = 15, name = "", type = "Portal", showInZone = false, showOnContinent = false, showOnMinimap = true } --  Portal from Valdrakken to the Badlands
                    minimap[2112][62725732] = { mnID = 2200, name = "", type = "Portal", showInZone = false, showOnContinent = false, showOnMinimap = true } --  Portal from Valdrakken to The Emerald Dream

                    if self.faction == "Horde" or db.activate.MinimapCapitalsEnemyFaction then
                        minimap[2112][56593828] = { mnID = 85, name = L["(inside building)"], type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Valdrakken to Orgrimmar Portal
                    end

                    if self.faction == "Alliance" or db.activate.MinimapCapitalsEnemyFaction then
                        minimap[2112][59804169] = { mnID = 84,  name = L["(inside building)"], type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Valdrakken to Stormwind City Portal
                    end
                end

                if self.db.profile.showMinimapCapitalsFP then
                    minimap[2112][44476790] = { npcID = 193321, name = "", type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

            end

        --Professions Valdrakken
            if self.db.profile.activate.MinimapCapitalsProfessions then

                if self.db.profile.showMinimapCapitalsProfessionOrders then
                    minimap[2112][34796252] = { name = PLACE_CRAFTING_ORDERS, type = "ProfessionOrders", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsAlchemy then
                    minimap[2112][36417170] = { npcID = 185545, name = "", type = "Alchemy", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end
            
                if self.db.profile.showMinimapCapitalsLeatherworking then
                    minimap[2112][28616157] = { npcID = 185551, name = "", type = "Leatherworking", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsEngineer then
                    minimap[2112][42254861] = { npcID = 185548, name = "", type = "Engineer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsSkinning then
                    minimap[2112][28606008] = { npcID = 193846, name = "", type = "Skinning", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsTailoring then
                    minimap[2112][32026629] = { npcID = 195850, name = "", type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsJewelcrafting then
                    minimap[2112][40486141] = { npcID = 190094, name = "", type = "Jewelcrafting", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsBlacksmith then
                    minimap[2112][36864659] = { npcID = 185546, name = "", type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsMining then
                    minimap[2112][38885143] = { npcID = 185553, name = "", type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsFishing then
                    minimap[2112][44847471] = { npcID = 185359, name = "", type = "Fishing", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsCooking then
                    minimap[2112][46494625] = { npcID = 185556, name = "", type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsHerbalism then
                    minimap[2112][37626892] = { npcID = 185549, name = "", type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsInscription then
                    minimap[2112][38847338] = { npcID = 185540, name = "", type = "Inscription", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsEnchanting then
                    minimap[2112][31076137] = { npcID = 193744, name = "", type = "Enchanting", showInZone = false, showOnContinent = false, showOnMinimap = true }
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
                    minimap[2339][44754642.01] = { npcID = 212370, name = "", type = "Innkeeper", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsAuctioneer then
                    minimap[2339][56864704] = { npcIDs1 = 219040, npcIDs2 = 219037, npcIDs3 = 219039, name = BUTTON_LAG_AUCTIONHOUSE, type = "Auctioneer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[2339][64975294] = { npcID = 219055, name = "", dnID = BLACK_MARKET_AUCTION_HOUSE, type = "BlackMarket", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsBank then
                    minimap[2339][52924479] = { dnID = BANK .. " / " .. GUILD_BANK , name = "", type = "Bank", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsBarber then
                    minimap[2339][58645176] = { npcID = 219052, name = "", type = "Barber", showInZone = false, showOnContinent = false, showOnMinimap = true }
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
                    minimap[2339][59657127] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[2339][55617524] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "Mailbox", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsPvPVendor then
                    minimap[2339][60377017] = { npcID = 219212, name = "", dnID = TRANSMOG_SET_PVP .. " " .. MERCHANT, type = "PvPVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[2339][59696906] = { npcID = 219216, name = "", dnID = TRANSMOG_SET_PVP .. " " .. MERCHANT, type = "PvPVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[2339][55677618] = { npcIDs1 = 219222, npcIDs2 = 219213, npcIDs3 = 219217, npcIDs4 = 219215, name = TRANSMOG_SET_PVP .. " " .. MERCHANT, type = "PvPVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsRenownQuartermaster then
                    minimap[2339][39092418] = { npcID = 223728, name = "", dnID = L["Council of Dornogal"], type = "RenownQuartermaster", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    --minimap[2339][39092418] = { dnID = L["Merchant for Renown items"], name = "", TransportName = L["Council of Dornogal"] .. "\n" .. L["The Assembly of the Deeps"] .. "\n" .. L["Hallowfall Arathi"], type = "RenownQuartermaster", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsPvEVendor then
                    minimap[2339][47834448] = { npcIDs1 = 226250, npcIDs2 = 208070, name = TRANSMOG_SET_PVE .. " " .. MERCHANT, type = "PvEVendor", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsTransmogger then
                    minimap[2339][45835331] = { npcID = 221848, name = "", TransportName = MERCHANT, type = "Transmogger", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[2339][58644933] = { npcID = 219053, name = "", TransportName = MERCHANT, type = "Transmogger", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsItemUpgrade then
                    minimap[2339][59627029] = { npcID = 219073, name = "", type = "ItemUpgrade", showInZone = false, showOnContinent = false, showOnMinimap = true }
                    minimap[2339][51944206] = { npcID = 219225, name = "", type = "ItemUpgrade", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsDragonFlyTransmog then
                    minimap[2339][47996786] = { dnID = MINIMAP_TRACKING_TRANSMOGRIFIER .. " " .. MOUNT_JOURNAL_FILTER_DRAGONRIDING, name = "",  type = "DragonFlyTransmog", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsCatalyst then
                    minimap[2339][50005430] = { dnID = L["Catalyst"], name = "",  type = "Catalyst", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsStablemaster then
                    minimap[2339][55356711] = { npcID = 219376, name = "", type = "StablemasterN", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

            end

        --Transports Dornogal
            if self.db.profile.activate.MinimapCapitalsTransporting then
    
                if self.db.profile.showMinimapCapitalsPortals then
                    minimap[2266][43564994] = { mnID = 2339, name = "", type = "Portal", showInZone = false, showOnContinent = false, showOnMinimap = true } --  Timeways Portal to Dornogal
                    --minimap[2266][64534340] = { mnID = 1565, name = "", type = "WayGateGolden", showInZone = false, showOnContinent = false, showOnMinimap = true } --  Timeways Portal to 
                    minimap[2266][74524703] = { mnID = 2472, name = "", type = "WayGateGolden", showInZone = false, showOnContinent = false, showOnMinimap = true } --  Timeways Portal to Tazavesh
                    --minimap[2266][77536180] = { mnID = 1536, name = "", type = "WayGateGolden", showInZone = false, showOnContinent = false, showOnMinimap = true } --  Timeways Portal to 
                    minimap[2266][70537306] = { mnID = 1525, name = "", type = "WayGateGolden", showInZone = false, showOnContinent = false, showOnMinimap = true } --  Timeways Portal to Revendreth
                    --minimap[2266][60506950] = { mnID = 241, name = "", type = "WayGateGolden", showInZone = false, showOnContinent = false, showOnMinimap = true } --  Timeways Portal to 
                    minimap[2339][53563873] = { mnID = 2266, name = "", type = "WayGateGolden", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["The Timeways"] .. " " .. L["Portals"] .. "\n" .. "\n" .. " ==> " .. ns.Tazavesh .. "\n" .. " ==> " .. ns.Revendreth  } --  Portal from Dornogal to the Timeways
                    minimap[2339][63615205] = { mnID = 2255, name = "", dnID = "", achievementID = 19559, showWWW = true, wwwLink = "https://www.wowhead.com/achievement=19559", type = "Portal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal from Dornogal to Azj-Kahet if u finished the achievement=19559
                    minimap[2339][29775967] = { mnID = 2367, name = "", dnID = "", achievementID = 40725, showWWW = true, wwwLink = "https://wowhead.com/achievement=40725", type = "Portal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Chamber of Memory
                    minimap[2339][52465047] = { mnID = 2346, name = "", dnID = "", questID = 86535, showWWW = true, wwwLink = "https://wowhead.com/quest=86535/test-run", type = "Portal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal from Dornogal to Undermine
                    minimap[2339][40312267] = { mnID = 2472, name = "", dnID = "", questID = 84957, showWWW = true, wwwLink = "https://wowhead.com/quest=84957/return-to-the-veiled-market", type = "Portal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal from Dornogal to Tazavesh
                    
                    if self.faction == "Horde" or db.activate.MinimapCapitalsEnemyFaction then
                        minimap[2339][38192724] = { mnID = 85, name = "", dnID = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dornogal to Orgrimmar
                    end

                    if self.faction == "Alliance" or db.activate.MinimapCapitalsEnemyFaction then
                        minimap[2339][41162271] = { mnID = 84, name = "", dnID = "", type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Dornogal to Stormwind
                    end
                end

                if self.db.profile.showMinimapCapitalsZeppelins then
                    minimap[2339][73540516] = { npcID = 231541, mnID = 2369, name = "", type = "Zeppelin", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Zeppelin from OG to Borean Tundra - Northrend
                end

                if self.db.profile.showMinimapCapitalsTransport then
                    --minimap[2339][40722239] = { name = "", type = "Tport2", showInZone = false, showOnContinent = false, showOnMinimap = true, TransportName = L["Transport"] .. " - " .. L["(on the tower)"]  } -- Oribos to The Maw
                end

                if self.db.profile.showMinimapCapitalsFP then
                    minimap[2339][44695114] = { npcID = 212369, name = "", type = "TravelL", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

            end

        --Professions Dornogal
            if self.db.profile.activate.MinimapCapitalsProfessions then

                if self.db.profile.showMinimapCapitalsProfessionOrders then
                    minimap[2339][58015644] = { npcID = 215258, name = "", type = "ProfessionOrders", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsAlchemy then
                    minimap[2339][47367039] = { npcID = 219092, name = "", type = "Alchemy", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end
            
                if self.db.profile.showMinimapCapitalsLeatherworking then
                    minimap[2339][54455884] = { npcID = 219080, name = "", type = "Leatherworking", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsEngineer then
                    minimap[2339][49215630] = { npcID = 219099, name = "", type = "Engineer", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsSkinning then
                    minimap[2339][54435714] = { npcID = 219083, name = "", type = "Skinning", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsTailoring then
                    minimap[2339][54786364] = { npcID = 219094, name = "", type = "Tailoring", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsJewelcrafting then
                    minimap[2339][49827116] = { npcID = 219087, name = "", type = "Jewelcrafting", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsBlacksmith then
                    minimap[2339][49286338] = { npcID = 223644, name = "", type = "Blacksmith", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsMining then
                    minimap[2339][52635272] = { npcID = 219097, name = "", type = "Mining", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsFishing then
                    minimap[2339][50542691] = { npcID = 219106, name = "", type = "Fishing", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsHerbalism then
                    minimap[2339][45696965] = { npcID = 219101, name = "", type = "Herbalism", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsInscription then
                    minimap[2339][48757117] = { npcID = 219090, name = "", type = "Inscription", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsEnchanting then
                    minimap[2339][52817116] = { npcID = 219085, name = "", type = "Enchanting", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

                if self.db.profile.showMinimapCapitalsCooking then
                    minimap[2339][44084575] = { npcID = 219104, name = "", type = "Cooking", showInZone = false, showOnContinent = false, showOnMinimap = true }
                end

            end

        end


    --###############
    --### Housing ###
    --###############
        if self.db.profile.showMinimapCapitalsHousing then

        --Transports Dornogal
            if self.db.profile.activate.MinimapCapitalsTransporting then
    
                if self.db.profile.showMinimapCapitalsPortals then

                    if self.faction == "Horde" or db.activate.MinimapCapitalsEnemyFaction then
                        minimap[2351][53924938] = { mnID = 85, name = "", type = "HPortal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal Razorwind Shores to Orgrimmar (Housing map)
                    end

                    if self.faction == "Alliance" or db.activate.MinimapCapitalsEnemyFaction then
                        minimap[2352][57432664] = { mnID = 84, name = "", type = "APortal", showInZone = false, showOnContinent = false, showOnMinimap = true } -- Portal Founder's Point to Stormwind (Housing map)
                    end
                end

            end

        end

    end -- if db.activate.MinimapCapitals then

end --if not db.activate.HideMapNote then

end -- function ns.LoadMinimapCapitalsLocationinfo(self)