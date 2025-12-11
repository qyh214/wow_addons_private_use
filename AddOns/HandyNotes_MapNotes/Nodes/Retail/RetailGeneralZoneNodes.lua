local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

function ns.LoadGeneralZoneLocationinfo(self)
local db = ns.Addon.db.profile
local nodes = ns.nodes
ns.currentSourceFile = "RetailGeneralZoneNodes.lua"

--#####################################################################################################
--##########################        function to hide all nodes below         ##########################
--#####################################################################################################
    if not db.activate.HideMapNote then


    --#####################################################################################################
    --################################         Zone Map        ################################
    --#####################################################################################################
    if db.activate.ZoneMap then

        if db.activate.ZoneGeneral then

        --Kalimdor
        if self.db.profile.showZoneKalimdor then

            if self.db.profile.showZoneZidormi then
                nodes[62][48862446] = { npcID = 141489, name = "", dnID = L["Travel through time to another point in the history of"] .. " ".. ns.Darkshore, type = "Zidormi", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[81][78922197] = { npcID = 141489, name = "", dnID = L["Travel through time to another point in the history of"] .. " " .. ns.Silithus, type = "Zidormi", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[249][56013514] = { npcID = 141489, mnID = 1527, name = "", dnID = L["Travel through time to another point in the history of"] .. " " .. ns.Uldum, type = "Zidormi", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1527][56013514] = { npcID = 141489, mnID = 249, name = "", dnID = L["Travel through time to another point in the history of"] .. " " .. ns.Uldum, type = "Zidormi", showInZone = true, showOnContinent = false, showOnMinimap = false }
            end

            if self.db.profile.showZoneRenownQuartermaster then
                nodes[249][54053331] = { npcID = 48617, name = "", type = "RenownQuartermaster", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1527][54053331] = { npcID = 48617, name = "", type = "RenownQuartermaster", showInZone = true, showOnContinent = false, showOnMinimap = false }
            end

            if self.db.profile.showZonePvPVendor then
                nodes[71][51552800] = { npcIDs1 = 20278, npcIDs2 = 40216, npcIDs3 = 69323, npcIDs4 = 69322, name = TRANSMOG_SET_PVP .. " " .. MERCHANT, type = "PvPVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
            
                if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                    nodes[10][40151995] = { npcID = 14754, name = TRANSMOG_SET_PVP .. " " .. MERCHANT, type = "ZonePvPVendorH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                    nodes[63][61488388] = { npcID = 14753, name = TRANSMOG_SET_PVP .. " " .. MERCHANT, type = "ZonePvPVendorA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end
            end

            if self.db.profile.showZoneStablemaster then
                nodes[66][57004960] = { npcID = 43877, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[77][44472854] = { npcID = 48216, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[83][58605020] = { npcID = 11119, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[71][52702732] = { npcID = 9985, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[81][53303445] = { npcID = 15722, name = "", dnID = "\n" .. L["If you don't see this icon, it's probably in a different phase. \nChange the phase on Zidormi"], type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[198][63242314] = { npcID = 43408, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[198][19403623] = { npcID = 53780, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[198][41774522] = { npcID = 50069, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1527][54733371] = { npcID = 164249, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1527][26960745] = { npcID = 163250, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[249][54733371] = { npcID = 48887, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[249][26970748] = { npcID = 49408, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[10][67547429] = { npcID = 10063, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }

                if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                    nodes[1][52004180] = { npcID = 9987, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[10][56503993] = { npcID = 43988, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[10][49125748] = { npcID = 9981, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[10][62351688] = { npcID = 43982, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[7][46955976] = { npcID = 10050, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[76][56805000] = { npcID = 43773, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[63][73276068] = { npcID = 15131, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[63][50356601] = { npcID = 43634, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[63][38604240] = { npcID = 43630, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[63][12603380] = { npcID = 43617, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[65][66386398] = { npcID = 41893, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[65][59796322] = { npcID = 10048, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[199][39301986] = { npcID = 44349, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[199][40806962] = { npcID = 44354, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[66][24906867] = { npcID = 11105, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[69][41491565] = { npcID = 44384, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[69][51694796] = { npcID = 44378, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[69][74494327] = { npcID = 9986, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[207][51315023] = { npcID = 45297, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                    nodes[57][56205200] = { npcID = 10051, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[97][48954983] = { npcID = 17485, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[106][55046001] = { npcID = 17666, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[63][36405040] = { npcID = 10052, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[65][58605660] = { npcID = 43021, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[65][39803220] = { npcID = 43017, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[65][31696143] = { npcID = 43019, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[199][65934683] = { npcID = 44348, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[199][48936830] = { npcID = 44347, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[66][65600780] = { npcID = 11104, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[69][51001800] = { npcID = 44382, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[69][46804560] = { npcID = 10059, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[70][65954536] = { npcID = 10047, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[207][47405160] = { npcID = 45298, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

            end

            if self.db.profile.showZoneAuctioneer then
                nodes[71][51883053] = { npcID = 8661, name = "", dnID = FACTION_NEUTRAL, type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[83][59974930] = { npcID = 9857, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
            end

            if self.db.profile.showZoneBank then
                nodes[71][52272970] = { name = "", dnID = BANK .. "\n" .. GUILD_BANK, type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[83][59974903] = { npcID = 13917, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[83][59674910] = { name = "", dnID = GUILD_BANK, type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[10][68367111] = { npcIDs1 = 3496, npcIDs2 = 8119, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }

                if self.faction == "Allianz" or db.activate.ZoneEnemyFaction then
                    nodes[70][67884824] = { npcID = 5083, name = "", dnID = "(" .. FACTION_ALLIANCE .. ")", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end
            end

            if self.db.profile.showZoneMailbox then
                nodes[83][59805090] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[198][63502360] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[198][41904450] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[198][18703740] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[76][66002040] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[76][43002470] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[76][50307420] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[76][29006590] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[66][57204980] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[80][51604050] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[80][55903140] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[70][42007330] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[10][67507420] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[77][44302870] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[64][77707360] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1527][24706470] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1527][54503710] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1527][55803430] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1527][55003390] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[69][46844514] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Alliance but can be used by Horde
                nodes[249][54543355] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[249][26710783] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[81][55503570] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX .. "\n" .. "\n" .. L["If you don't see this icon, it's probably in a different phase. \nChange the phase on Zidormi"], type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[71][52502730] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                
                if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                    nodes[66][24806880] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[69][74904400] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[7][47205970] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[65][50806300] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[10][49605880] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[63][73606090] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[63][50206600] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[63][38704250] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[63][12703400] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[77][44006200] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[76][56805030] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[76][26507890] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1][45401220] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1][51904210] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1][56107450] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[461][42006670] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[462][26802750] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[463][59506350] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[65][66306410] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[70][36603210] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[199][40806950] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[199][39302010] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[64][45905100] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                    nodes[65][58905590] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[70][65904530] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[65][31806000] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[66][65500690] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[69][57005400] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[62][50701930] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX .. "\n" .. "\n" .. L["If you don't see this icon, it's probably in a different phase. \nChange the phase on Zidormi"], type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false } -- other Phase
                    nodes[63][36505020] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[77][61602550] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[97][48905000] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[468][53003650] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[106][55105910] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[57][55805100] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[460][51506660] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end
            end

            if self.db.profile.showZoneInnkeeper then
                nodes[207][49205180] = { npcID = 45300, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[70][41937419] = { npcID = 23995, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1527][54673293] = { npcID = 162938, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1527][26600720] = { npcID = 163252, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[66][56715002] = { npcID = 43872, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[77][45032934] = { npcID = 48215, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[198][63092409] = { npcID = 40843, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[198][18663727] = { npcID = 53779, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[198][42634573] = { npcID = 50068, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[64][76467480] = { npcID = 40832, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[78][55376225] = { npcID = 38488, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[71][52542701] = { npcID = 7733, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[71][55666099] = { npcID = 38714, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[10][67307466] = { npcID = 6791, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[83][59865119] = { npcID = 11118, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[249][54673294] = { npcID = 48886, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[249][21986447] = { npcID = 49528, name = "", dnID = ns.InnkeeperM, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[249][26610725] = { npcID = 49406, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[81][55523676] = { npcID = 15174, name = "", dnID = L["If you don't see this icon, it's probably in a different phase. \nChange the phase on Zidormi"], type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }

                if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                    nodes[65][66486424] = { npcID = 41892, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[65][50406380] = { npcID = 7731, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[199][40746931] = { npcID = 44276, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[199][39202000] = { npcID = 44270, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[70][36903235] = { npcID = 24208, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[63][38604220] = { npcID = 43624, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[63][50436715] = { npcID = 43633, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[63][13003400] = { npcID = 43606, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[63][73996065] = { npcID = 12196, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[76][57005040] = { npcIDs1 = 43771, npcIDs2 = 49882, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[69][41421577] = { npcID = 40467, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[69][51894743] = { npcID = 44376, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[69][74804518] = { npcID = 7737, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[10][56243998] = { npcID = 43946, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[10][62531658] = { npcID = 43945, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[10][49555789] = { npcID = 3934, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1][51514165] = { npcID = 6928, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[66][24086821] = { npcID = 11106, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[7][46826046] = { npcID = 6747, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[77][44006193] = { npcID = 48599, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                    nodes[65][59005640] = { npcID = 40898, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[65][39403280] = { npcID = 41491, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[65][31406060] = { npcID = 44177, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[65][71067908] = { npcID = 41286, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[199][39001100] = { npcID = 44219, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[199][49056855] = { npcID = 44267, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[199][65584656] = { npcID = 44268, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[97][48344914] = { npcID = 16553, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[106][55855980] = { npcID = 17553, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[63][36804940] = { npcID = 6738, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[77][61842677] = { npcID = 47931, name = "", dnID = L["If you don't see this icon, it's probably in a different phase. \nChange the phase on Zidormi"], type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Phase 12608
                    nodes[69][46004520] = { npcID = 44391, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[69][51061794] = { npcID = 40968, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[70][66424532] = { npcID = 6272, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[66][66200660] = { npcID = 11103, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[57][55405220] = { npcID = 6736, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[62][50951853] = { npcID = 43420, name = "", dnID = L["If you don't see this icon, it's probably in a different phase. \nChange the phase on Zidormi"], type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Phase 12608
                end

            end

        end

        -- Eastern Kingdom
        if self.db.profile.showZoneEasternKingdom then

            if self.db.profile.showZonePvEVendor then
                nodes[122][50574078] = { npcID = 25046, name = "", type = "PvEVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
            end

            if self.db.profile.showZoneRenownQuartermaster then
                nodes[122][47253072] = { npcID = 25032, name = "", type = "RenownQuartermaster", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[205][49114218] = { npcID = 50324, name = "", type = "RenownQuartermaster", showInZone = true, showOnContinent = false, showOnMinimap = false }
            end

            if self.db.profile.showZoneZidormi then
                nodes[18][69456280] = { npcID = 141489, mnID = 2070, name = "", dnID = L["Travel through time to another point in the history of"] .. " " .. ns.TirisfalGlades, type = "Zidormi", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[14][38249009] = { npcID = 141489, name = "", dnID = L["Travel through time to another point in the history of"] .. " " .. ns.ArathiHighlands, type = "Zidormi", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[17][48160728] = { npcID = 141489, name = "", dnID = L["Travel through time to another point in the history of"] .. " " .. ns.BlastedLands, type = "Zidormi", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2070][69456280] = { npcID = 141489, mnID = 18, name = "", dnID = L["Travel through time to another point in the history of"] .. " " .. ns.TirisfalGlades, type = "Zidormi", showInZone = true, showOnContinent = false, showOnMinimap = false }
            end

            if self.db.profile.showZoneStablemaster then
                nodes[210][41287364] = { npcID = 10060, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[224][36477993] = { npcID = 10060, name = "", mnID = 210, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[15][65603640] = { npcID = 48055, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[32][40716897] = { npcID = 47934, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[51][72001480] = { npcID = 47337, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[122][50313547] = { npcID = 25037, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[205][49474192] = { npcID = 41903, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[22][47263188] = { npcID = 47761, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }

                if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                    nodes[18][61815218] = { npcID = 10055, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[14][67993509] = { npcID = 144140, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[21][44602080] = { npcID = 45498, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[21][46004260] = { npcID = 9979, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[25][36206160] = { npcID = 49395, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[25][56894701] = { npcID = 10057, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[25][59706475] = { npcID = 49431, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[94][47584734] = { npcID = 16185, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[95][48403120] = { npcID = 16665, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[50][37965148] = { npcID = 16094, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[210][34802760] = { npcID = 44191, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[224][41103221] = { npcID = 16094, name = "", mnID = 50, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }   
                    nodes[224][33055267] = { npcID = 44191, name = "", mnID = 210, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[26][79167953] = { npcID = 14741, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[26][31885738] = { npcID = 43766, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[22][47926409] = { npcID = 47866, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[15][18364245] = { npcID = 10058, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[51][47325550] = { npcID = 10049, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[241][75645266] = { npcID = 49554, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[241][75481683] = { npcID = 49790, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[241][53804300] = { npcID = 49767, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[241][45207640] = { npcID = 49755, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[204][53005920] = { npcID = 43151, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[205][51466280] = { npcID = 42911, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[2070][59255112] = { npcID = 185946, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                    nodes[37][42866593] = { npcID = 6749, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[14][39314791] = { npcID = 141737, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[52][53005300] = { npcID = 10045, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[49][26204300] = { npcID = 9982, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[47][74004620] = { npcID = 10062, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[27][54125098] = { npcID = 9980, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[48][34644809] = { npcID = 9989, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[48][84006280] = { npcID = 43979, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[56][57734032] = { npcID = 43994, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[56][10465965] = { npcID = 10046, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[56][26112604] = { npcID = 44007, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[26][14404520] = { npcID = 10061, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[26][66444523] = { npcID = 43770, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[15][20945645] = { npcID = 48095, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[51][28563314] = { npcID = 47368, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[17][46008540] = { npcID = 44335, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[241][80617746] = { npcID = 49689, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[241][55541480] = { npcID = 49577, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[241][48662938] = { npcID = 49593, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[241][60205800] = { npcID = 49803, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[241][43715726] = { npcID = 49600, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[204][56007300] = { npcID = 42966, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[205][49005760] = { npcID = 42875, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end
            end

            if self.db.profile.showZoneAuctioneer then
                nodes[210][40207220] = { npcID = 15681, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[210][43137153] = { npcID = 15677, name = "", type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[224][37737892] = { npcID = 15681, name = "", mnID = 210, type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[224][39397876] = { npcID = 15677, name = "", mnID = 210, type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
            end

            if self.db.profile.showZoneBank then
                nodes[210][40007240] = { npcIDs1 =  2625, npcIDs2 = 8123, name = "", type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[224][36557887] = { npcIDs1 =  2625, npcIDs2 = 8123, name = "", mnID = 210, type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
            end

            if self.db.profile.showZoneMailbox then
                nodes[241][74701750] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[15][66003650] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[15][90803750] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[51][71901490] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[210][41307400] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[210][40507220] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[205][49204190] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[30][37303860] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[32][39506800] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[23][75305270] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[122][50003501] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[217][59949211] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }

                if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                    nodes[465][51905860] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[95][47803150] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[2070][60715215] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[18][60705220] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[25][56904690] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[94][47804700] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[94][44207070] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[467][61404500] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[26][78908050] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[21][46104230] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[21][44502100] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[14][69003280] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[241][53904300] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[241][75705290] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[15][18104320] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[51][47205530] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[50][38905020] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[210][35202760] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[205][51106300] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[204][51206070] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                    nodes[22][43608450] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[26][66004520] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[56][57604010] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[56][10805970] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[27][54105090] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[427][62603270] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[48][34804780] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[241][49502990] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[241][80307700] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[49][26004300] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[51][29103330] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[17][59901690] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX .. "\n" .. "\n" .. L["If you don't see this icon, it's probably in a different phase. \nChange the phase on Zidormi"], type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[17][66602860] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX .. "\n" .. "\n" .. L["If you don't see this icon, it's probably in a different phase. \nChange the phase on Zidormi"], type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[17][45508630] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[47][73804620] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[37][42906560] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[52][55904850] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[52][53105330] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[425][32805250] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[205][49105700] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[204][55107220] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end
            end

            if self.db.profile.showZoneInnkeeper then
                nodes[122][51193387] = { npcID = 25036, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[205][49134196] = { npcID = 39878, name = "", dnID = ns.InnkeeperM, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[217][60219169] = { npcID = 210940, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[15][65803560] = { npcID = 48054, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[32][39426625] = { npcID = 47942, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[51][71681384] = { npcID = 47334, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[23][75965223] = { npcID = 16256, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[24][44068948] = { npcID = 16256, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false } -- its on the Paladin Class hall map
                nodes[210][40887377] = { npcID = 6807, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[224][37508015] = { npcID = 6807, name = "", mnID = 210, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }

                if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                    nodes[95][48803240] = { npcID = 16542, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[25][57964730] = { npcID = 2388, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[25][60206400] = { npcID = 49430, name = "", dnID = "\n" .. "(" .. ERR_USE_OBJECT_MOVING .. ")", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[25][35806120] = { npcID = 49394, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[204][51206060] = { npcID = 43141, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[17][40421133] = { npcID = 44309, name = "", dnID = "\n\n" .. L["If you don't see this icon, it's probably in a different phase. \nChange the phase on Zidormi"], type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[205][51656260] = { npcID = 42908, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[21][44352031] = { npcID = 45496, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[21][46434270] = { npcID = 6739, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[210][35082717] = { npcID = 44190, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[224][34295176] = { npcID = 44190, name = "", mnID = 210, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[224][42503277] = { npcID = 5814, name = "", mnID = 50, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[26][31805800] = { npcID = 43739, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[26][78148139] = { npcID = 14731, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[18][83087198] = { npcID = 46271, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[18][60875151] = { npcID = 5688, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[2070][60885151] = { npcID = 186012, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[241][53314288] = { npcID = 49762, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[241][75945274] = { npcID = 49498, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[241][75371651] = { npcID = 49783, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[241][45087674] = { npcID = 49747, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[22][48346381] = { npcID = 47857, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[14][69703245] = { npcID = 144139, name = "", dnID = "\n\n" .. L["If you don't see this icon, it's probably in a different phase. \nChange the phase on Zidormi"], type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Phase 11292
                    nodes[15][18314264] = { npcID = 9356, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[94][48164766] = { npcID = 15433, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[94][43677131] = { npcID = 15397, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[50][37375187] = { npcID = 5814, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[51][46955686] = { npcID = 6930, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                    nodes[50][53226693] = { npcID = 44019, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[224][52214319] = { npcID = 44019, name = "", mnID = 50, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[27][54495084] = { npcID = 1247, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[204][54607220] = { npcID = 42963, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[15][20705632] = { npcID = 48093, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[17][44338765] = { npcID = 44334, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[17][60721402] = { npcID = 44325, name = "", dnID = "\n\n" .. L["If you don't see this icon, it's probably in a different phase. \nChange the phase on Zidormi"], type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[205][49695742] = { npcID = 42873, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[51][29003260] = { npcID = 47367, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[26][66174435] = { npcID = 43699, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[26][14144466] = { npcID = 7744, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[241][78977781] = { npcID = 49686, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[241][79377853] = { npcID = 49688, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[241][54601800] = { npcID = 49574, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[241][49553045] = { npcID = 49591, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[241][43625722] = { npcID = 49599, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[241][60405814] = { npcID = 49795, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }  
                    nodes[22][43328458] = { npcID = 46269, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[56][25682606] = { npcID = 44006, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[56][58183911] = { npcID = 43993, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[56][10736085] = { npcID = 1464, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[14][40694803] = { npcID = 141732, name = "", dnID = "\n\n" .. L["If you don't see this icon, it's probably in a different phase. \nChange the phase on Zidormi"], type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Phase 11292
                    nodes[47][73874440] = { npcID = 6790, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[37][43806580] = { npcID = 295, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[48][35534840] = { npcID = 6734, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[48][81916463] = { npcID = 1156, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[52][52875371] = { npcID = 8931, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[49][26384143] = { npcID = 6727, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

            end

            if self.db.profile.showZonePvPVendor then

                if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                    nodes[25][58073359] = { npcID = 13219, name = TRANSMOG_SET_PVP .. " " .. MERCHANT, type = "ZonePvPVendorH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[14][68473035] = { npcID = 144064, name = TRANSMOG_SET_PVP .. " " .. MERCHANT, type = "ZonePvPVendorH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                    nodes[25][44624633] = { npcID = 13217, name = TRANSMOG_SET_PVP .. " " .. MERCHANT, type = "ZonePvPVendorA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[14][40114653] = { npcID = 15127, name = TRANSMOG_SET_PVP .. " " .. MERCHANT, type = "ZonePvPVendorA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

            end

        end

        -- Outland
        if self.db.profile.showZoneOutland then

            if self.db.profile.showZonePvPVendor then
                nodes[109][33006420] = { npcIDs1 = 58152, npcIDs2 = 54648, npcIDs3 = 40209, npcIDs4 = 23396, npcIDs5 = 54649, npcIDs6 = 107619, npcIDs7 = 107610, npcIDs8 = 107599, npcIDs9 = 54650, name = TRANSMOG_SET_PVP .. " " .. MERCHANT, type = "PvPVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
            end

            if self.db.profile.showZoneRenownQuartermaster then
                nodes[109][43663432] = { npcID = 20242, name = "", type = "RenownQuartermaster", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[105][28075874] = { npcID = 23428, name = "", type = "RenownQuartermaster", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[102][79256366] = { npcID = 17904, name = "", type = "RenownQuartermaster", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[108][64306624] = { npcID = 23367, name = "", type = "RenownQuartermaster", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[108][30541823] = { npcIDs1 = 19321, npcIDs2 = 21432, npcIDs3 = 19331, mnID = 111, name = "", type = "RenownQuartermaster", hideTTmnID = true, showInZone = true, showOnContinent = false, showOnMinimap = false }

                if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                    nodes[100][54903780] = { npcID = 17585, name = "", type = "ZoneRenownQuartermasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[107][53463702] = { npcID = 20241, name = "", type = "ZoneRenownQuartermasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                    nodes[100][56706265] = { npcID = 17657, name = "", type = "ZoneRenownQuartermasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[107][54537515] = { npcID = 20240, name = "", type = "ZoneRenownQuartermasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

            end

            if self.db.profile.showZoneStablemaster then
                nodes[102][78736436] = { npcID = 17896, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[105][27595250] = { npcID = 23392, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[109][32006480] = { npcID = 24974, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                
                if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                    nodes[100][54404100] = { npcID = 16586, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[102][31744978] = { npcID = 18244, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[108][49314471] = { npcID = 18984, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[107][56754083] = { npcID = 19018, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[105][75526027] = { npcID = 22468, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[105][53605320] = { npcID = 19476, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[104][29202933] = { npcID = 21336, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                    nodes[100][54406269] = { npcID = 16824, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[102][67624969] = { npcID = 18250, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[108][56805380] = { npcID = 24905, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[107][55807451] = { npcID = 19019, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[105][36086451] = { npcID = 22469, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[104][37515603] = { npcID = 19368, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

            end

            if self.db.profile.showZoneBarber then
                nodes[109][31006680] = { name = "", dnID = MINIMAP_TRACKING_BARBER .. " - " .. FACTION_NEUTRAL, type = "Barber", showInZone = true, showOnContinent = false, showOnMinimap = false }
            end

            if self.db.profile.showZoneBank then
                nodes[109][33006780] = { name = "", dnID = BANK .. " - " .. FACTION_NEUTRAL, type = "Bank", showInZone = true, showOnContinent = false, showOnMinimap = false }
            end

            if self.db.profile.showZoneMailbox then
                nodes[104][56305820] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[104][61402900] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[102][78906370] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[109][32206460] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[109][43603590] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[105][62603850] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[105][27605250] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }

                if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                    nodes[108][49504490] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[107][56473557] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[102][31905010] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[100][26806050] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[100][56503800] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[105][52705570] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[105][75706080] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                    nodes[108][57005370] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[107][54507360] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[102][42102710] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[102][67504920] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[100][23503750] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[100][55006360] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[105][36306430] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[105][60806840] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[104][37205750] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[104][30102840] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end
            end

            if self.db.profile.showZoneInnkeeper then
                nodes[109][43353614] = { npcID = 19531, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[109][31956442] = { npcID = 19571, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[102][78486294] = { npcID = 18907, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[104][66258713] = { npcID = 23143, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[104][56205980] = { npcID = 21744, name = L["The Scryers"], type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[104][61122825] = { npcID = 21746, name = L["The Aldor"], type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[105][62863830] = { npcID = 22922, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }

                if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                    nodes[107][56743451] = { npcID = 18913, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[102][30655093] = { npcID = 18245, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[108][48754505] = { npcID = 18957, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[104][30222775] = { npcID = 19319, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[100][26875954] = { npcID = 18905, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[100][56713746] = { npcID = 16602, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[105][76106030] = { npcID = 21088, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[105][53375541] = { npcID = 19470, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                    nodes[107][54227611] = { npcID = 18914, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[102][67134904] = { npcID = 18251, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[102][41852622] = { npcID = 18908, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[108][56705327] = { npcID = 19296, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[104][37055827] = { npcID = 19352, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[100][23353637] = { npcID = 18906, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[100][54226360] = { npcID = 16826, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[105][35806388] = { npcID = 19495, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[105][60976811] = { npcID = 21110, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end
            end

        end

        --Northrend
        if self.db.profile.showZoneNorthrend then

            if self.db.profile.showZonePvEVendor then
                --nodes[118][53828468] = { name = "", dnID = TRANSMOG_SET_PVE .. " " .. MERCHANT, mnID = 186, type = "PvEVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
            
                if self.faction == "Horde" then
                    nodes[118][76092180] = { npcIDs1 = 35574, npcIDs2 = 35576, npcIDs3 = 35578, npcIDs4 = 35580, name = TRANSMOG_SET_PVE .. " " .. MERCHANT, type = "PvEVendorH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.faction == "Alliance" then
                    nodes[118][76092180] = { npcIDs1 = 35573, npcIDs2 = 35575, npcIDs3 = 35577, npcIDs4 = 35579, name = TRANSMOG_SET_PVE .. " " .. MERCHANT, type = "PvEVendorA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

            end

            if self.db.profile.showZoneRenownQuartermaster then
                nodes[118][43392058] = { npcID = 32538, name = "", type = "RenownQuartermaster", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[118][69442324] = { npcIDs1 = 173791, npcIDs2 = 34885, name = "", type = "RenownQuartermaster", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[120][66176144] = { npcID = 32540, name = "", type = "RenownQuartermaster", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[117][25525871] = { npcID = 31916, name = "", type = "RenownQuartermaster", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[115][59945303] = { npcID = 32533, name = "", type = "RenownQuartermaster", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[115][48487565] = { npcID = 32763, name = "", type = "RenownQuartermaster", showInZone = true, showOnContinent = false, showOnMinimap = false }

                if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                    nodes[114][41425369] = { npcID = 32565, name = "", type = "ZoneRenownQuartermasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                    nodes[114][57736636] = { npcID = 32564, name = "", type = "ZoneRenownQuartermasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

            end

            if self.db.profile.showZoneStablemaster then
                nodes[114][78164905] = { npcID = 27194, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[117][25405900] = { npcID = 27150, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[115][48427471] = { npcID = 27183, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[115][61475336] = { npcID = 27948, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[121][40206520] = { npcID = 28790, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[121][59015776] = { npcID = 30039, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[119][27365940] = { npcID = 28047, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[120][49806600] = { npcID = 30008, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[120][30633688] = { npcID = 29959,name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[120][40968608] = { npcID = 29906, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[118][44252234] = { npcID = 30304, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[118][69682208] = { npcID = 35344, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[118][71512260] = { npcID = 33854, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }

                if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                    nodes[114][40275503] = { npcID = 26044, name = "", dnID = "(" .. ERR_USE_OBJECT_MOVING .. ")", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[114][49781046] = { npcID = 27065, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[114][77033723] = { npcID = 26721, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[117][79063079] = { npcID = 24350, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[117][52046647] = { npcID = 24154, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[117][49461108] = { npcID = 24067, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[115][37084855] = { npcID = 26504, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[115][76806274] = { npcID = 28057, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[116][21646408] = { npcID = 29740, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[116][65014790] = { npcID = 26944, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[116][13848473] = { npcID = 29251, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[120][67405020] = { npcID = 29967, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[118][75722363] = { npcID = 35290, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                    nodes[114][58416852] = { npcID = 27010, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[114][56627306] = { npcID = 27385, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[114][57151907] = { npcID = 26597, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[117][58726309] = { npcID = 23733, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[117][60641605] = { npcID = 24066, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[117][31604140] = { npcID = 29658, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    --nodes[115][77405080] = { name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[115][28875599] = { npcID = 27056, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[116][32605960] = { npcID = 27068, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[116][59002660] = { npcID = 26377, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[116][13808460] = { npcID = 29250, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[120][28657440] = { npcID = 29948, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[118][75942022] = { npcID = 35291, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end
            end

            if self.db.profile.showZoneMailbox then
                nodes[114][78104930] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[117][25205900] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[115][48307450] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[115][60105670] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[115][59505190] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[120][40908590] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[120][30503700] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[118][43702410] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[118][79517232] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[121][40506770] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[121][40906560] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[121][40106640] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[119][26905950] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }

                if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                    nodes[114][42005480] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[114][77003750] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[114][49401030] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[120][67505040] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[118][75902350] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[116][21506500] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[116][65504730] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[117][79003040] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[117][52206650] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[117][49501090] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[115][77006280] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[115][37304670] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                    nodes[114][58506860] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[114][57001910] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[120][28807430] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[118][75802000] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[116][32506050] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[116][59502620] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[117][58606320] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[117][30904210] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[117][60801600] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[115][28905610] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[115][77305090] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end
            end

            if self.db.profile.showZoneInnkeeper then
                nodes[114][78394928] = { npcID = 27187, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[115][48157476] = { npcID = 27174, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[115][59815424] = { npcID = 27950, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[117][25395985] = { npcID = 27148, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[118][43992217] = { npcID = 30308, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[119][26765927] = { npcID = 28038, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[121][40806620] = { npcID = 28791, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[121][59345730] = { npcID = 29583, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[120][41098591] = { npcID = 29904, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[120][48856504] = { npcID = 30005, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[120][30903737] = { npcID = 29963, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }

                if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                    nodes[114][76253718] = { npcID = 26709, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[114][49671017] = { npcID = 27069, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[114][41915448] = { npcID = 25278, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[115][38204600] = { npcID = 26985, name = "", dnID = "(" .. ERR_USE_OBJECT_MOVING .. ")", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[115][76866312] = { npcID = 27027, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[116][65424689] = { npcID = 26680, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[116][20806460] = { npcID = 27125, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[117][49511078] = { npcID = 24033, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[117][79733084] = { npcID = 24342, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[117][52156641] = { npcID = 24149, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[118][76102396] = { npcID = 33971, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[120][37124952] = { npcID = 29944, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[120][67615061] = { npcID = 29971, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                    nodes[114][57121871] = { npcID = 26596, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[114][58296804] = { npcID = 25245, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    --nodes[115][77405160] = { name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[115][28805600] = { npcID = 27052, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[116][59602640] = { npcID = 26375, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[116][31976027] = { npcID = 27066, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[117][60481586] = { npcID = 24057, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[117][30854146] = { npcID = 23937, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[117][58396245] = { npcID = 23731, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[118][76201960] = { npcID = 33970, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[120][28717437] = { npcID = 29926, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

            end

        end

        --Pandaria
        if self.db.profile.showZonePandaria then

            if self.db.profile.showZoneZidormi then
                nodes[390][80483196] = { npcID = 141489, mnID = 1530, name = "", dnID = L["Travel through time to another point in the history of"] .. " " .. ns.ValeOfEternalBlossoms, type = "Zidormi", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1530][80972948] = { npcID = 141489, mnID = 390, name = "", dnID = L["Travel through time to another point in the history of"] .. " " .. ns.ValeOfEternalBlossoms, type = "Zidormi", showInZone = true, showOnContinent = false, showOnMinimap = false }
            end

            if self.db.profile.showZonePvEVendor then
                nodes[388][37956455] = { npcIDs1 = 64606, npcIDs2 = 64607, npcIDs3 = 70346, name = TRANSMOG_SET_PVE .. " " .. MERCHANT, type = "PvEVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[422][55023555] = { npcID = 64599, name = "", type = "PvEVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[379][65406180] = { npcID = 64518, name = "", type = "PvEVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[554][42875522] = { npcIDs1 = 73305, npcIDs2 = 73306, name = "", type = "PvEVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }

                if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                    nodes[418][10835336] = { npcID = 69060, name = "", type = "PvEVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end
            end

            if self.db.profile.showZonePvPVendor then

                if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                    nodes[379][35408340] = { npcIDs1 = 75688, npcIDs2 = 78461, npcIDs3 = 75695, npcIDs4 = 75693, npcIDs5 = 75690, name = TRANSMOG_SET_PVP .. " " .. MERCHANT, type = "ZonePvPVendorH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[388][77476296] = { npcIDs1 = 75688, npcIDs2 = 78461, npcIDs3 = 75695, npcIDs4 = 75693, npcIDs5 = 75690, name = TRANSMOG_SET_PVP .. " " .. MERCHANT, type = "ZonePvPVendorH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                    nodes[376][12003400] = { npcIDs1 = 75692, npcIDs2 = 75694, npcIDs3 = 75689, npcIDs4 = 75691, npcIDs5 = 78456, name = TRANSMOG_SET_PVP .. " " .. MERCHANT, type = "ZonePvPVendorA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[422][73543407] = { npcIDs1 = 75692, npcIDs2 = 75694, npcIDs3 = 75689, npcIDs4 = 75691, npcIDs5 = 78456, name = TRANSMOG_SET_PVP .. " " .. MERCHANT, type = "ZonePvPVendorA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

            end

            if self.db.profile.showZoneStablemaster then
                nodes[371][46554376] = { npcID = 66241, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[371][54856298] = { npcID = 66243, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[376][55264969] = { npcID = 66244, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[433][55697584] = { npcID = 62935, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[379][65356153] = { npcID = 59509, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[379][42246933] = { npcID = 59413, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[388][71405760] = { npcID = 66246, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[388][50177147] = { npcID = 66248, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[422][53673239] = { npcID = 66250, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[422][55876956] = { npcID = 66249, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[390][36017543] = { npcID = 66245, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[554][37324662] = { npcID = 73632, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }

                if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                    nodes[371][27734673] = { npcID = 66717, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[371][28711310] = { npcID = 66230, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[418][59112432] = { npcID = 59310, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[390][60262279] = { npcID = 63986, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1530][60482019] = { npcID = 63986, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[504][32863249] = { npcID = 69252, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                    nodes[371][44608480] = { npcID = 66266, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[418][67203220] = { npcID = 66251, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[390][84606320] = { npcID = 63988, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1530][85186136] = { npcID = 63988, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[504][63267396] = { npcID = 70184, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end
            end

            if self.db.profile.showZoneMailbox then
                nodes[390][35607240] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[418][68004520] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[418][31506370] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[418][13705610] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[418][10605260] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[379][62602970] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[379][67605140] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[379][64506120] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[379][57606020] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[379][72309210] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[371][54806310] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[371][46454395] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[371][28104720] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[371][55602380] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[371][41602350] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[376][83902130] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[376][55604990] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[388][75908280] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[388][48907070] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[388][71105760] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[422][55803220] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[422][55407110] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[433][55907420] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }

                if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                    nodes[371][27801500] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[371][28601330] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[379][62708050] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[379][35908330] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[504][33303300] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[554][22144135] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[418][60702500] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                    nodes[371][59208340] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[371][44908470] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[379][54108290] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[504][63207240] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[376][12303350] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[418][88703440] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[554][24806880] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[418][86803060] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end
            end

            if self.db.profile.showZoneInnkeeper then
                nodes[422][55923232] = { npcID = 65220, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[422][55157111] = { npcID = 63016, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[418][40763451] = { npcID = 62869, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[418][75740721] = { npcID = 62879, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[418][51517716] = { npcID = 62872, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[379][64246138] = { npcID = 59405, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[379][44439031] = { npcID = 62877, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[379][42606960] = { npcID = 60420, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[379][57375999] = { npcID = 59688, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[379][62502878] = { npcID = 60605, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[379][66945103] = { npcID = 61651, name = "", dnID = ns.InnkeeperM,  type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[433][55087239] = { npcID = 62917, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[554][36574684] = { npcID = 73622, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[388][48847083] = { npcID = 62874, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[388][75968291] = { npcID = 62875, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[388][71085792] = { npcID = 62873, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[376][55135050] = { npcID = 59582, name = "", dnID = "(" .. ERR_USE_OBJECT_MOVING .. ")", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[376][19705586] = { npcID = 62878, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[376][83762019] = { npcID = 65528, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[371][41722315] = { npcID = 62867, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[371][55762449] = { npcID = 62868, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[371][45724370] = { npcID = 55809, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[371][45624395] = { npcID = 55233, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[371][54586322] = { npcID = 57313, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }

                if self.raceFile == "Pandaren" then -- only panda

                end

                if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                    nodes[504][33593265] = { npcID = 67668, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[418][60912490] = { npcID = 58184, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[418][28275078] = { npcID = 62967, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[418][10805240] = { npcID = 67775, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[379][62738049] = { npcID = 62883, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[371][28521334] = { npcID = 66236, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[371][27994743] = { npcID = 62975, name = "", dnID = ns.InnkeeperM, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                    nodes[504][64427173] = { npcID = 70182, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[418][88843534] = { npcID = 69088, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[379][54088286] = { npcID = 62882, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[371][44808440] = { npcID = 65907, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[371][59608320] = { npcID = 61599, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

            end

        end

        --Draenor
        if self.db.profile.showZoneDraenor then

            if self.db.profile.showZoneStablemaster then
                nodes[542][60807180] = { npcID = 82553, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }

                if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                    nodes[525][38805200] = { npcID = 77455, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[525][52404020] = { npcID = 78698, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[525][22005620] = { npcID = 77461, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[525][21405460] = { npcID = 77475, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[535][70802960] = { npcID = 80833, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[534][59754548] = { npcID = 90992, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[543][45806987] = { npcID = 82731, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                    nodes[539][25200700] = { npcID = 81830, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[539][59172676] = { npcID = 84730, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[535][69402120] = { npcID = 80854, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end
            end

            if self.db.profile.showZoneMailbox then
                nodes[535][47704160] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[535][50904570] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[535][84903150] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[542][61707300] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[550][54621418] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[542][46514384] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }

                if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                    nodes[525][52604080] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[525][40605220] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[525][21105680] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[525][20004380] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[525][32001030] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[534][60804670] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[542][40404324] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[535][67803590] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[535][71802990] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[535][61901090] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[550][82904530] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[550][48754733] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                    nodes[543][53205990] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[543][47109300] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[534][58005970] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[539][57505730] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[539][45903960] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[539][59802680] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[539][51903290] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[542][40106130] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[535][69704290] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[535][69702160] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[550][63376209] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[550][62104020] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end
            end

            if self.db.profile.showZoneInnkeeper then
                nodes[535][50864450] = { npcID = 86316, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[535][85173195] = { npcID = 80931, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[542][61677352] = { npcID = 82516, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[542][46684402] = { npcID = 86386, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[543][45965468] = { npcID = 84237, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[543][40123636] = { npcID = 85830, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }

                if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                    nodes[534][61474619] = { npcID = 90989, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[535][61811101] = { npcID = 77028, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[535][72003000] = { npcID = 81359, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[550][48524726] = { npcID = 82341, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[550][82574541] = { npcID = 82345, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[543][45986972] = { npcID = 85967, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[543][60602240] = { npcID = 86994, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[525][32001000] = { npcID = 78769, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[525][20925652] = { npcID = 77460, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[525][30003860] = { npcID = 77468, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[525][40685169] = { npcID = 72382, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[525][52203980] = { npcID = 78672, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[525][27003640] = { npcID = 76746, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[526][42914454] = { npcID = 76746, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[527][69376212] = { npcID = 77468, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[542][40414298] = { npcID = 84213, name = "", dnID = ns.InnkeeperM, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                    nodes[534][58606020] = { npcID = 90971, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[535][69602180] = { npcID = 81358, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[535][77165748] = { npcID = 75430, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[539][56875742] = { npcID = 82770, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[539][60012739] = { npcID = 82775, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[539][46704095] = { npcID = 78952, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[550][62164000] = { npcID = 81249, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[550][63606240] = { npcID = 81249, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[543][53205980] = { npcID = 85968, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

            end

        end

        --Broken Isles
        if self.db.profile.showZoneBrokenIsles then

            if self.db.profile.showZoneStablemaster then
                nodes[650][52804520] = { npcID = 97862, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[650][53206400] = { npcID = 97874, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[830][64406260] = { npcID = 126160, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[830][62604760] = { npcID = 127752, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[750][53694597] = { npcID = 97854, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
            end

            if self.db.profile.showZoneMailbox then
                nodes[650][47606150] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[650][52704480] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[650][39503710] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[680][58108700] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[680][33604950] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[680][36504550] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[630][56505930] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[630][46904090] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[630][43504260] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[630][49002610] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[630][40700980] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[641][55007320] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[641][42605950] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[641][56605790] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[641][68805070] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[634][60505070] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[619][41205930] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[646][41255926] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[750][51315314] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[971][26392419] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
            
                if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                    nodes[634][54207210] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                    nodes[634][72106000] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end
            end

            if self.db.profile.showZoneInnkeeper then
                nodes[641][56007340] = { npcID = 93460, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[641][48408180] = { npcID = 92001, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[641][42605960] = { npcID = 92684, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[641][44208260] = { npcID = 112864, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[641][69574942] = { npcID = 95118, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[641][59208480] = { npcID = 109304, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[680][37404580] = { npcID = 113515, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[680][36494583] = { npcID = 115736, name = "", dnID = ns.InnkeeperF, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[680][54306970] = { npcID = 115382, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[680][59238475] = { npcID = 133695, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[634][60605020] = { npcID = 103796, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[650][53004488] = { npcID = 97786, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[650][57402760] = { npcID = 108559, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[650][59808020] = { npcID = 100746, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[659][34606499] = { npcID = 108554, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[650][43602380] = { npcID = 99207, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[650][43602380] = { npcID = 99207, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[650][38206840] = { npcID = 108557, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[650][40005240] = { npcID = 94099, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[630][43004260] = { npcID = 89639, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[630][56665958] = { npcID = 91457, name = "", dnID = ns.InnkeeperM, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[630][47344135] = { npcID = 109372, name = "", dnID = ns.InnkeeperF, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[630][47802332] = { npcID = 89939, name = "", dnID = ns.InnkeeperM, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[646][41005880] = { npcID = 115349, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[750][44395385] = { npcID = 97852, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[971][26282410] = { npcID = 132657, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }

                if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                    nodes[634][54007220] = { npcID = 98106, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[634][36883109] = { npcID = 91535, name = "", dnID = ns.InnkeeperM, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                    nodes[634][71606060] = { npcID = 98112, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

            end

        end

        --Zandalar
        if self.db.profile.showZoneZandalar then

            if self.db.profile.showZoneItemUpgrade then

                if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                    nodes[1355][40005300] = { npcID = 156152, name = "", type = "ItemUpgrade", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                    nodes[1355][49116197] = { npcID = 156151, name = "", type = "ItemUpgrade", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end
            end

            if self.db.profile.showZonePvPVendor then

                if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                    nodes[862][51605820] = { npcID = 143555, name = TRANSMOG_SET_PVP .. " " .. MERCHANT .. " " .. FACTION_HORDE, dnID = WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. "\n" .. AUCTION_CATEGORY_WEAPONS, type = "PvPVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

            end

            if self.db.profile.showZoneStablemaster then
                nodes[864][57314933] = { npcID = 138701, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[864][27005100] = { npcID = 139827, name = "",  type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                
                if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                    nodes[862][51205020] = { npcID = 137333, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[862][53405720] = { npcID = 148168, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[862][76901669] = { npcID = 124455, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[863][39004380] = { npcID = 129795, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }    
                    nodes[863][66804200] = { npcID = 131993, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }                
                    nodes[863][39597970] = { npcID = 135750, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[864][52408960] = { npcID = 139840, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[864][43585988] = { npcID = 123730, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1355][47396198] = { npcID = 151352, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                    nodes[862][44802720] = { npcID = 136064, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[862][55602500] = { npcID = 136092, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[862][64404720] = { npcID = 140057, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[862][77405480] = { npcID = 138850, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[862][44603660] = { npcID = 136004, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[864][38603440] = { npcID = 144121, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1355][39605540] = { npcID = 155941, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end
            end

            if self.db.profile.showZoneMailbox then
                nodes[864][43207620] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[864][27105300] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[864][56804980] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[864][47903550] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[864][61602120] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[862][71602920] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[863][67204220] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }

                if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                    nodes[862][44507210] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[862][51305060] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[862][66704250] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[862][58006270] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[862][35306670] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[862][76801630] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[862][51605830] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[863][39107850] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[863][40304370] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[864][43086096] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[864][52428989] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1355][49106250] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                    nodes[862][40507070] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[862][77605460] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[862][44503660] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[862][55602510] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[862][44802760] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[863][62504120] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[864][39203560] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[864][53613802] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1355][38705510] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end
            end

            if self.db.profile.showZoneInnkeeper then
                nodes[862][71362899] = { npcID = 138488, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[864][26805220] = { npcID = 128693, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[864][43007640] = { npcID = 135655, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[864][56804980] = { npcID = 124108, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[864][61492054] = { npcID = 138917, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }

                if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                    nodes[862][44607180] = { npcID = 124458, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[862][66554235] = { npcID = 123062, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[862][51205120] = { npcID = 137331, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[862][53003280] = { npcID = 126330, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[862][59802220] = { npcID = 121651, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[862][53205700] = { npcID = 148158, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[862][57405840] = { npcID = 120840, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[862][76421608] = { npcID = 124063, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[864][52008980] = { npcID = 128335, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[864][43516021] = { npcID = 129354, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[863][40804360] = { npcID = 128701, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[863][38607860] = { npcID = 121840, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[863][67604180] = { npcID = 131988, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1355][50986534] = { npcID = 151618, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                    nodes[862][44203660] = { npcID = 135993, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[862][64604720] = { npcID = 140103, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[862][44802760] = { npcID = 136057, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[862][77205560] = { npcID = 137624, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[862][40607060] = { npcID = 128042, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[862][55002560] = { npcID = 136079, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[864][53723801] = { npcID = 142561, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[864][36803520] = { npcID = 137319, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[863][34006340] = { npcID = 142426, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[863][62004080] = { npcID = 135082, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[863][51402160] = { npcID = 143884, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1355][37805560] = { npcID = 155940, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

            end

        end

        --Kul Tiras
        if self.db.profile.showZoneKulTiras then

            if self.db.profile.showZoneStablemaster then
                nodes[942][40323637] = { npcID = 138451, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[896][19524360] = { npcID = 136142, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1462][69203060] = { npcID = 150629, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }

                if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                    nodes[895][87535027] = { npcID = 138160, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[942][50973310] = { npcID = 138108, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[942][52607740] = { npcID = 141309, name = "", type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                    nodes[895][75675089] = { npcID = 143463, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[942][31666736] = { npcID = 136674, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[942][58457074] = { npcID = 141349, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[942][35304799] = { npcID = 140551, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[942][43205460] = { npcID = 135386, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[896][38765242] = { npcID = 137010, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[895][51462609] = { npcID = 125035, name = "", type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end
            end

            if self.db.profile.showZoneMailbox then
                nodes[895][85408030] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[896][20134340] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1462][71503600] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }

                if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                    nodes[895][87405020] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[895][72005270] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[895][53306320] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[895][62801400] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[895][39501750] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[942][54107870] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[942][38906690] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[942][53904900] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[942][60702680] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[942][50803310] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[896][62001670] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[896][66505950] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                    nodes[895][75906490] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[895][75705050] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[895][77508430] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[895][57706180] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[895][66502450] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[895][53102820] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[895][42102280] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[895][35302420] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[942][34804750] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[942][64704880] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[942][31106680] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[942][59007050] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[942][43505420] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[942][68806520] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[896][55203520] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[896][37504900] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[896][26607200] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[896][31503010] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end
            end

            if self.db.profile.showZoneInnkeeper then
                nodes[895][85208040] = { npcID = 128233, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[942][40843709] = { npcID = 137668, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[896][21504369] = { npcID = 136138, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1462][71203580] = { npcID = 150628, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }

                if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                    nodes[895][72105245] = { npcID = 144438, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[895][87304991] = { npcID = 138290, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[895][53486336] = { npcID = 140565, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[895][62681426] = { npcID = 139567, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[942][54154730] = { npcID = 141205, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[942][39516848] = { npcID = 141600, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[942][60102508] = { npcID = 141084, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[942][54057903] = { npcID = 141304, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[942][50933370] = { npcID = 138096, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[896][37752549] = { npcID = 138020, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[896][66255973] = { npcID = 140782, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[896][61941675] = { npcID = 140960, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                    nodes[895][35322423] = { npcID = 136465, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[895][70932584] = { npcID = 143560, name = "", dnID = ns.InnkeeperM, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[895][75905066] = { npcID = 136468, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[895][75606460] = { npcID = 136437, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[895][57946208] = { npcID = 136482, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[895][53282827] = { npcID = 136459, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[895][77208400] = { npcID = 136479, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[895][42052286] = { npcID = 129159, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[895][66202420] = { npcID = 133214, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[942][65494830] = { npcID = 142634, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[942][31436733] = { npcID = 143328, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[942][34864710] = { npcID = 138210, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[942][58647024] = { npcID = 138221, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[896][37404860] = { npcID = 136480, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[896][55513428] = { npcID = 129992, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[896][26607240] = { npcID = 131442, name = "", dnID = ns.InnkeeperM, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

            end

        end

        --Shadowlands
        if self.db.profile.showZoneShadowlands then

            if self.db.profile.showZoneItemUpgrade then
                nodes[1961][62602200] = { dnID = ITEM_UPGRADE, name = "",  type = "ItemUpgrade", showInZone = true, showOnContinent = false, showOnMinimap = false }
            end

            if self.db.profile.showZoneStablemaster then
                nodes[1525][49007000] = { npcID = 156234, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1525][70334140] = { npcID = 159000, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1525][41204740] = { npcID = 167819, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1525][60403920] = { npcID = 163163, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1525][31234903] = { npcID = 166092, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1525][63206180] = { npcID = 156291, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1533][44203300] = { npcID = 174578, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1533][35182149] = { npcID = 175444, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1533][52404800] = { npcID = 160178, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1536][67204580] = { npcID = 174664, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1536][55067015] = { npcID = 161677, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1536][49805400] = { npcID = 161712, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1565][51007060] = { npcID = 170924, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1565][49005300] = { npcID = 168082, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1565][62703516] = { npcID = 162434, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1565][60405400] = { npcID = 162433, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1565][51003380] = { npcID = 170571, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1565][64741916] = { npcID = 164724, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1565][37403820] = { npcID = 160353, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1961][60602300] = { npcID = 177157, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
            end

            if self.db.profile.showZoneAuctioneer then
                nodes[1989][75184972] = { name = "", dnID = MINIMAP_TRACKING_AUCTIONEER .. " - " .. FACTION_NEUTRAL, type = "Auctioneer", showInZone = true, showOnContinent = false, showOnMinimap = false }
            end

            if self.db.profile.showZoneMailbox then
                nodes[1536][37902910] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1536][54503060] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1536][67504510] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1536][50605290] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1536][39505540] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1536][52506820] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1536][58107200] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1565][64601960] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1565][62703590] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1565][50803350] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1565][48505120] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1565][51207030] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1565][36105310] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1565][37103730] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1565][60245356] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1525][71804060] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1525][62506320] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1525][47846990] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1525][31104730] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1525][70268142] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1533][48477356] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1533][53204720] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1533][43203280] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1533][65501870] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1961][60702390] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1970][61504950] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1970][35006400] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
            end

            if self.db.profile.showZoneInnkeeper then
                nodes[1565][64601940] = { npcID = 164722, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1565][51736876] = { npcID = 167251, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1816][51354731] = { npcID = 167251, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1565][50693380] = { npcID = 163738, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1565][48405060] = { npcID = 168032, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1565][36803700] = { npcID = 171015, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1565][60485392] = { npcID = 162445, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1565][36375334] = { npcID = 171162, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1565][62603540] = { npcID = 162446, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1533][48007300] = { npcID = 160601, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1533][53204680] = { npcID = 160173, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1533][35482065] = { npcID = 175621, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1533][42923273] = { npcID = 172576, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1536][54323084] = { npcID = 169698, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1536][50805300] = { npcID = 161702, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1536][67604480] = { npcID = 174665, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1536][39605520] = { npcID = 168952, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1525][40804660] = { npcID = 167815, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1525][71538019] = { npcID = 166070, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1525][31204660] = { npcID = 166089, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1525][47407060] = { npcID = 156220, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1525][62066448] = { npcID = 156290, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1525][60203980] = { npcID = 167754, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1525][72323986] = { npcID = 158986, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1961][60792416] = { npcID = 177156, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1970][61404920] = { npcID = 181084, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1970][34806400] = { npcID = 180916, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
            end

        end

        --Dragon Isles
        if self.db.profile.showZoneDragonIsles then

            if self.db.profile.showZonePvEVendor then
                nodes[2022][47108258] = { npcID = 189226, name = TRANSMOG_SET_PVE .. " " .. MERCHANT, type = "PvEVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2133][51992569] = { npcIDs1 = 205675, npcIDs2 = 205676, name = TRANSMOG_SET_PVE .. " " .. MERCHANT, type = "PvEVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2133][56485566] = { npcID = 202468, name = TRANSMOG_SET_PVE .. " " .. MERCHANT, type = "PvEVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2200][50256162] = { npcID = 208156, name = TRANSMOG_SET_PVE .. " " .. MERCHANT, type = "PvEVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2024][13144927] = { npcID = 193006, name = TRANSMOG_SET_PVE .. " " .. MERCHANT, type = "PvEVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
            end

            if self.db.profile.showZoneCatalyst then
                nodes[2025][60715371] = { dnID = L["Catalyst"], name = "",  type = "Catalyst", showInZone = true, showOnContinent = false, showOnMinimap = false }
            end

            if self.db.profile.showZoneItemUpgrade then
                nodes[2133][56555600] = { npcID = 203403, name = "", type = "ItemUpgrade", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2151][35605940] = { npcID = 203341, name = "", type = "ItemUpgrade", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2200][57352745] = { npcID = 211357, name = "", type = "ItemUpgrade", showInZone = true, showOnContinent = false, showOnMinimap = false }
            end

            if self.db.profile.showZoneStablemaster then
                nodes[2133][57705785] = { npcID = 203294, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2133][43288198] = { npcID = 201102, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2022][62807120] = { npcID = 188107, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2022][24648348] = { npcID = 199701, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2022][73805440] = { npcID = 194605, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2022][25805540] = { npcID = 189202, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2022][43186724] = { npcID = 188445, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2022][65935888] = { npcID = 193021, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2022][54003840] = { npcID = 189738, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2023][85253585] = { npcID = 196291, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2023][62004180] = { npcID = 195524, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2023][45674055] = { npcID = 191815, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2023][65632457] = { npcID = 190058, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2023][80665805] = { npcID = 192002, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2023][83922588] = { npcID = 186183, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2023][72127881] = { npcID = 193008, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2023][41826019] = { npcID = 195471, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2024][63205840] = { npcID = 187020, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2024][65271620] = { npcID = 186860, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2024][46964052] = { npcID = 199688, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2024][38006080] = { npcID = 199691, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2024][19052397] = { npcID = 190892, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2024][13804960] = { npcID = 186462, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2025][50546798] = { npcID = 189025, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2025][60298191] = { npcID = 187024, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2025][51064315] = { npcID = 189353, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2200][69625391] = { npcID = 208302, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2200][53072425] = { npcID = 211355, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2200][50206180] = { npcID = 207760, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
            end

            if self.db.profile.showZoneMailbox then
                nodes[2023][85202590] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2023][85403590] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2023][81205910] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2023][72008060] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2023][57007650] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2023][62704080] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2023][59503870] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2023][62203590] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2023][65802470] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2023][46004080] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2023][41906070] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2023][28805920] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2022][76203490] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2022][75905460] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2022][65205801] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2022][57706690] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2022][53823840] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2022][47508280] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2022][42806650] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2022][25905530] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2022][24608270] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2024][65501620] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2024][66002540] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2024][62905800] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2024][46604020] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2024][37906180] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2024][12804950] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2024][18802430] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2133][55905630] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2133][56605670] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2133][56805560] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2133][56305510] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2133][51602650] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2025][35307950] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2025][52306870] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2025][59808260] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2025][50504220] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2200][53002490] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2200][36503320] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2200][49906190] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2026][14506060] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2239][48305510] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2151][34225907] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
            end

            if self.db.profile.showZoneInnkeeper then
                nodes[2133][52202620] = { npcID = 200892, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2133][56425584] = { npcID = 203293, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2022][47808320] = { npcIDs1 = 187399, npcIDs2 = 187408, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2022][46432726] = { npcID = 197849, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2022][81313190] = { npcID = 187412, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2022][25805520] = { npcID = 188351, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2022][24408220] = { npcID = 198190, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2022][76333562] = { npcID = 193393, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2022][53853921] = { npcID = 188284, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2022][76005460] = { npcID = 194432, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2022][43126656] = { npcID = 186317, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2022][65205800] = { npcID = 189400, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2022][58066762] = { npcID = 187389, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2026][33835906] = { npcID = 200560, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2024][12404940] = { npcID = 186448, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2024][18732448] = { npcID = 190315, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2024][46944034] = { npcID = 189147, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2024][65401620] = { npcID = 186744, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2024][62805780] = { npcID = 186851, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2024][37376243] = { npcID = 189460, name = "", dnID = ns.InnkeeperM, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2025][50224254] = { npcID = 186458, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2025][35117924] = { npcID = 194788, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2025][59848265] = { npcID = 186952, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2025][52466961] = { npcID = 188887, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2025][52138152] = { npcID = 203769, name = "", dnID = ns.InnkeeperM, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2023][81335930] = { npcID = 191391, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2023][28576051] = { npcID = 186502, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2023][85873524] = { npcID = 196161, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2023][62804060] = { npcID = 191269, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2023][59603880] = { npcID = 195395, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2023][41936052] = { npcID = 195104, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2023][62203580] = { npcID = 194928, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2023][72158049] = { npcID = 192878, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2023][57207660] = { npcID = 192113, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2023][46114062] = { npcID = 191813, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2023][66392438] = { npcID = 190087, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2023][85102602] = { npcID = 184636, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2151][33835906] = { npcID = 200560, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2200][36603260] = { npcID = 209430, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2200][69535324] = { npcID = 208286, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2200][52492529] = { npcID = 211352, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2200][49806160] = { npcID = 207627, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }

                if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                    nodes[2022][80402780] = { npcID = 187403, name = "", type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                    nodes[2239][48205400] = { npcID = 216280, name = "", type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

            end

        end

        --Khaz Algar
        if self.db.profile.showZoneKhazAlgar then

            if self.db.profile.showZoneItemUpgrade then
                nodes[2472][41102964] = { npcID = 250320, name = "",  type = "ItemUpgrade", questID = 84967, wwwLink = "https://www.wowhead.com/quest=84967", showWWW = true, wwwName = BATTLE_PET_SOURCE_2 .. " " .. REQUIRES_LABEL .. " " .. "The shadowguard shattered", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Tazavesh
            end

            if self.db.profile.showZoneStablemaster then
                nodes[2371][49333688] = { npcID = 245292, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2371][60522835] = { npcID = 238575, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2371][50325919] = { npcID = 245440, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2472][47432690] = { npcID = 235254, name = "", type = "StablemasterN", questID = 84967, wwwLink = "https://www.wowhead.com/quest=84967", showWWW = true, wwwName = BATTLE_PET_SOURCE_2 .. " " .. REQUIRES_LABEL .. " " .. "The shadowguard shattered", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Tazavesh
            end

            if self.db.profile.showZoneTransmogger then
                nodes[2371][49713807] = { npcID = 245282, name = "", type = "Transmogger", showInZone = true, showOnContinent = false, showOnMinimap = false } -- K'aresh
                nodes[2371][53836389] = { npcID = 247938, name = "", type = "Transmogger", showInZone = true, showOnContinent = false, showOnMinimap = false } -- K'aresh
                nodes[2472][43042875] = { npcID = 245284, name = "", type = "Transmogger", questID = 84967, wwwLink = "https://www.wowhead.com/quest=84967", showWWW = true, wwwName = BATTLE_PET_SOURCE_2 .. " " .. REQUIRES_LABEL .. " " .. "The shadowguard shattered", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Tazavesh
            end

            if self.db.profile.showZoneMailbox then
                nodes[2215][52606070] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2369][67623980] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2346][44664933] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Undermine
                nodes[2346][34468464] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Undermine
                nodes[2346][40437171] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Undermine
                nodes[2346][41227397] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Undermine
                nodes[2346][27306472] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Undermine
                nodes[2346][29276240] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Undermine
                nodes[2346][32055742] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Undermine
                nodes[2346][24515749] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Undermine
                nodes[2346][36485725] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Undermine
                nodes[2371][48853809] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false } -- K'aresh
                nodes[2371][60642773] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false } -- K'aresh
                nodes[2371][76663453] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false } -- K'aresh
                nodes[2371][54066370] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false } -- K'aresh
                nodes[2371][49995968] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false } -- K'aresh
                nodes[2472][45942202] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Tazavesh
                nodes[2472][47356225] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Tazavesh
                nodes[2472][41413960] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Tazavesh
                nodes[2472][46056797] = { npcID = 235886, name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Tazavesh
            end

            if self.db.profile.showZoneInnkeeper then
                nodes[2214][59197887] = { npcID = 225067, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2213][57053949] = { npcID = 210055, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2216][57053949] = { npcID = 210055, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2213][49752192] = { npcID = 228134, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2216][49752192] = { npcID = 228134, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2346][43515168] = { npcID = 231045, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2346][36814750] = { npcID = 234461, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2346][39346861] = { npcID = 234778, name = ns.InnkeeperM, type = "InnkeeperN", showWWW = true, wwwName = BATTLE_PET_SOURCE_2 .. " " .. REQUIRES_LABEL .. " " .. "My-hole-in-the-wall", wwwLink = "https://www.wowhead.com/quest=86408/my-hole-in-the-wall#", questID = 86408, showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2371][48693845] = { npcID = 236097, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false } -- K'aresh
                nodes[2371][60722763] = { npcID = 238572, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false } -- K'aresh
                nodes[2371][76733443] = { npcID = 241507, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false } -- K'aresh
                nodes[2371][49985947] = { npcID = 245405, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false } -- K'aresh
                nodes[2472][41132510] = { npcID = 235079, name = "", type = "InnkeeperN", questID = 84967, wwwLink = "https://www.wowhead.com/quest=84967", showWWW = true, wwwName = BATTLE_PET_SOURCE_2 .. " " .. REQUIRES_LABEL .. " " .. "The shadowguard shattered", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Tazavesh
            end

            if self.db.profile.showZoneRenownQuartermaster and not self.db.profile.showZoneMapNotesIcons then
                nodes[2215][42355500] = { npcID = 213145, name = "", dnID = L["Hallowfall Arathi"], type = "RenownQuartermaster", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hallowfall
                nodes[2214][43143293] = { npcID = 221390, name = "", dnID = L["The Assembly of the Deeps"], type = "RenownQuartermaster", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Deeps
                nodes[2255][55334121] = { npcID = 223750, name = "", type = "RenownQuartermaster", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Azj-Kahet
                nodes[2256][55334121] = { npcID = 223750, name = "", type = "RenownQuartermaster", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Azj-Kahet
            end

            if self.db.profile.showZoneRenownQuartermaster then
                nodes[2346][53147272] = { npcID = 231407, name = "", type = "RenownQuartermaster", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Lorenhall
                nodes[2346][27137258] = { npcID = 231408, name = "", type = "RenownQuartermaster", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Lorenhall
                nodes[2346][39152218] = { npcID = 231406, name = "", type = "RenownQuartermaster", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Lorenhall
                nodes[2346][63431672] = { npcID = 231405, name = "", type = "RenownQuartermaster", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Lorenhall                
                nodes[2346][25753812] = { npcID = 234776, name = "", dnID = L["The Cartels of Undermine"], type = "RenownQuartermaster", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Lorenhall
                nodes[2346][30823891] = { npcID = 231396, name = "", type = "RenownQuartermaster", showWWW = true, wwwName = BATTLE_PET_SOURCE_2 .. " " .. REQUIRES_LABEL .. " " .. "Diversified Investments", wwwLink = "https://www.wowhead.com/quest=86961/diversified-investments", questID = 86961, showInZone = true, showOnContinent = false, showOnMinimap = false } -- Lorenhall
                nodes[2472][40272927] = { npcID = 235252, name = "", type = "RenownQuartermaster", questID = 84967, wwwLink = "https://www.wowhead.com/quest=84967", showWWW = true, wwwName = BATTLE_PET_SOURCE_2 .. " " .. REQUIRES_LABEL .. " " .. "The shadowguard shattered", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Tazavesh
            end

            if self.db.profile.showZonePvEVendor then
                nodes[2215][39115763] = { npcID = 226846, name = TRANSMOG_SET_PVE .. " " .. MERCHANT, type = "PvEVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2216][56784582] = { npcID = 224270, name = TRANSMOG_SET_PVE .. " " .. MERCHANT, type = "PvEVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2213][56784582] = { npcID = 224270, name = TRANSMOG_SET_PVE .. " " .. MERCHANT, type = "PvEVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2369][67314164] = { npcIDs1 = 228093, npcIDs2 = 235407, name = TRANSMOG_SET_PVE .. " " .. MERCHANT, type = "PvEVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2369][70014846] = { npcID = 234390, name = TRANSMOG_SET_PVE .. " " .. MERCHANT, type = "PvEVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2369][70784027] = { npcID = 236045, name = TRANSMOG_SET_PVE .. " " .. MERCHANT, type = "PvEVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2346][43934982] = { npcID = 231824, name = TRANSMOG_SET_PVE .. " " .. MERCHANT, type = "PvEVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2472][54515519] = { npcIDs1 = 242306, npcIDs2 = 242307, name = TRANSMOG_SET_PVE .. " " .. MERCHANT, type = "PvEVendor", questID = 84967, wwwLink = "https://www.wowhead.com/quest=84967", showWWW = true, wwwName = BATTLE_PET_SOURCE_2 .. " " .. REQUIRES_LABEL .. " " .. "The shadowguard shattered", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Tazavesh
                nodes[2371][50353632] = { npcIDs1 = 241624, npcIDs2 = 241588, name = TRANSMOG_SET_PVE .. " " .. MERCHANT, type = "PvEVendor", showInZone = true, showOnContinent = false, showOnMinimap = false } -- K'aresh
                nodes[2371][42012225] = { npcIDs1 = 248304, npcIDs2 = 245348, npcIDs3 = 245349, name = TRANSMOG_SET_PVE .. " " .. MERCHANT, type = "PvEVendor", showInZone = true, showOnContinent = false, showOnMinimap = false } -- K'aresh
            end

            if self.db.profile.showZonePvPVendor then
                nodes[2216][57574582] = { npcID = 224267, name = TRANSMOG_SET_PVP .. " " .. MERCHANT, type = "PvPVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2213][57574582] = { npcID = 224267, name = TRANSMOG_SET_PVP .. " " .. MERCHANT, type = "PvPVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
            end

            if self.db.profile.showZonePvPVendor and not self.db.profile.showZoneMapNotesIcons then
                nodes[2255][51408082] = { npcID = 224267, name = TRANSMOG_SET_PVP .. " " .. MERCHANT .. " " .. TRANSMOG_SET_PVP .. " " .. MERCHANT .. "\n" .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. SLASH_EQUIP_SET1, type = "PvPVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2256][51408082] = { npcID = 224267, name = TRANSMOG_SET_PVP .. " " .. MERCHANT .. " " .. TRANSMOG_SET_PVP .. " " .. MERCHANT .. "\n" .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. SLASH_EQUIP_SET1, type = "PvPVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
            end

            if self.db.profile.showZonePvEVendor and not self.db.profile.showZoneMapNotesIcons then
                nodes[2255][51408082] = { npcID = 224270, name = TRANSMOG_SET_PVE .. " " .. MERCHANT .. "\n" .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. SLASH_EQUIP_SET1, type = "PvEVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2256][51408082] = { npcID = 224270, name = TRANSMOG_SET_PVE .. " " .. MERCHANT .. "\n" .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. SLASH_EQUIP_SET1, type = "PvEVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
            end

            if self.db.profile.showZoneMapNotesIcons and (self.db.profile.showZonePvEVendor or self.db.profile.showZonePvPVendor) then
                nodes[2255][51408082] = { name = "", dnID = TRANSMOG_SET_PVE .. " / " .. TRANSMOG_SET_PVP .. " " .. MERCHANT .. "\n" .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. SLASH_EQUIP_SET1, type = "MNL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2256][51408082] = { name = "", dnID = TRANSMOG_SET_PVE .. " / " .. TRANSMOG_SET_PVP .. " " .. MERCHANT .. "\n" .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. SLASH_EQUIP_SET1, type = "MNL", showInZone = true, showOnContinent = false, showOnMinimap = false }
            end

            if self.db.profile.showZoneMailbox and not self.db.profile.showZoneMapNotesIcons then
                nodes[2248][41917335] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2248][58682793] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2215][42485562] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2216][54854224] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2255][56694067] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2255][58821886] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2255][77506252] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2256][56694067] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2256][58821886] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2256][77506252] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2215][49093991] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2215][68974540] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2214][43273231] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2214][57724646] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2214][54576405] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2255][44886632] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2256][44886632] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2369][71263789] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2369][69354651] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2214][72008413] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }

            end

            if self.db.profile.showZoneInnkeeper and not self.db.profile.showZoneMapNotesIcons then
                nodes[2248][41947421] = { npcID = 217440, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2248][58402737] = { npcID = 226507, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2215][42805583] = { npcID = 217642, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2255][77866298] = { npcID = 220760, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2255][56953879] = { npcID = 207476, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2255][58931880] = { npcID = 211722, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2256][77866298] = { npcID = 220760, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2256][56953879] = { npcID = 207476, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2256][58931880] = { npcID = 211722, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2215][49163948] = { npcID = 221776, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2215][69294563] = { npcID = 217611, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2214][43843217] = { npcID = 213840, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2214][57614616] = { npcID = 218390, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2214][54886403] = { npcID = 225018, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2255][44796648] = { npcID = 223355, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2256][44796648] = { npcID = 223355, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2369][71443737] = { npcID = 228106, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2369][69014647] = { npcID = 228390, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2214][72088409] = { npcID = 228092, name = "", type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
            end

            if self.db.profile.showZoneStablemaster and not self.db.profile.showZoneMapNotesIcons then
                nodes[2248][59372796] = { npcID = 226813, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2215][42265654] = { npcID = 217990, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2255][77936461] = { npcID = 224510, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2255][58471923] = { npcID = 224069, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2256][77936461] = { npcID = 224510, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2256][58471923] = { npcID = 224069, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2215][69274392] = { npcID = 217645, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2214][58024604] = { npcID = 218416, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2214][54476559] = { npcID = 225220, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2214][72008316] = { npcID = 228136, name = "", type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
            end

            if self.db.profile.showZoneMapNotesIcons then
                --Innkeeper Mailbox Stabelmaster Merchant
                nodes[2215][42395647] = { name = L["Hallowfall Arathi"], dnID = TextIconPvEVendor:GetIconString() .. " " .. L["Merchant for Renown items"] .. "\n" .. TextIconInnkeeperN:GetIconString() .. " " .. ns.InnkeeperM .. "\n" .. TextIconMailbox:GetIconString() .. " " .. MINIMAP_TRACKING_MAILBOX .. "\n" .. TextIconStablemasterN:GetIconString() .. " " .. ns.StablemasterM, type = "MNL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2214][43433310] = { name = L["The Assembly of the Deeps"], dnID = TextIconPvEVendor:GetIconString() .. " " .. L["Merchant for Renown items"] .. "\n" .. TextIconInnkeeperN:GetIconString() .. " " .. ns.InnkeeperM .. "\n" .. TextIconMailbox:GetIconString() .. " " .. MINIMAP_TRACKING_MAILBOX, type = "MNL", showInZone = true, showOnContinent = false, showOnMinimap = false }                     
                nodes[2255][56773954] = { name = L["The Severed Threads"], dnID = TextIconPvEVendor:GetIconString() .. " " .. L["Merchant for Renown items"] .. "\n" .. TextIconInnkeeperN:GetIconString() .. " " .. ns.InnkeeperM .. "\n" .. TextIconMailbox:GetIconString() .. " " .. MINIMAP_TRACKING_MAILBOX, type = "MNL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2256][56773954] = { name = L["The Severed Threads"], dnID = TextIconPvEVendor:GetIconString() .. " " .. L["Merchant for Renown items"] .. "\n" .. TextIconInnkeeperN:GetIconString() .. " " .. ns.InnkeeperM .. "\n" .. TextIconMailbox:GetIconString() .. " " .. MINIMAP_TRACKING_MAILBOX, type = "MNL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                --Innkeeper Mailbox Stabelmaster
                nodes[2248][58742792] = { name = "", dnID = TextIconInnkeeperN:GetIconString() .. " " .. ns.InnkeeperM .. "\n" .. TextIconMailbox:GetIconString() .. " " .. MINIMAP_TRACKING_MAILBOX .. "\n" .. TextIconStablemasterN:GetIconString() .. " " .. ns.StablemasterM, type = "MNL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2214][57644641] = { name = "", dnID = TextIconInnkeeperN:GetIconString() .. " " .. ns.InnkeeperM .. "\n" .. TextIconMailbox:GetIconString() .. " " .. MINIMAP_TRACKING_MAILBOX .. "\n" .. TextIconStablemasterN:GetIconString() .. " " .. ns.StablemasterM, type = "MNL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2214][54336488] = { name = "", dnID = TextIconInnkeeperN:GetIconString() .. " " .. ns.InnkeeperM .. "\n" .. TextIconMailbox:GetIconString() .. " " .. MINIMAP_TRACKING_MAILBOX .. "\n" .. TextIconStablemasterN:GetIconString() .. " " .. ns.StablemasterM, type = "MNL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2215][68974456] = { name = "", dnID = TextIconInnkeeperN:GetIconString() .. " " .. ns.InnkeeperM .. "\n" .. TextIconMailbox:GetIconString() .. " " .. MINIMAP_TRACKING_MAILBOX .. "\n" .. TextIconStablemasterN:GetIconString() .. " " .. ns.StablemasterM, type = "MNL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2255][58821886] = { name = "", dnID = TextIconInnkeeperN:GetIconString() .. " " .. ns.InnkeeperM .. "\n" .. TextIconMailbox:GetIconString() .. " " .. MINIMAP_TRACKING_MAILBOX .. "\n" .. TextIconStablemasterN:GetIconString() .. " " .. ns.StablemasterM, type = "MNL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2256][58821886] = { name = "", dnID = TextIconInnkeeperN:GetIconString() .. " " .. ns.InnkeeperM .. "\n" .. TextIconMailbox:GetIconString() .. " " .. MINIMAP_TRACKING_MAILBOX .. "\n" .. TextIconStablemasterN:GetIconString() .. " " .. ns.StablemasterM, type = "MNL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2255][77866298] = { name = "", dnID = TextIconInnkeeperN:GetIconString() .. " " .. ns.InnkeeperM .. "\n" .. TextIconMailbox:GetIconString() .. " " .. MINIMAP_TRACKING_MAILBOX .. "\n" .. TextIconStablemasterN:GetIconString() .. " " .. ns.StablemasterM, type = "MNL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2256][77866298] = { name = "", dnID = TextIconInnkeeperN:GetIconString() .. " " .. ns.InnkeeperM .. "\n" .. TextIconMailbox:GetIconString() .. " " .. MINIMAP_TRACKING_MAILBOX .. "\n" .. TextIconStablemasterN:GetIconString() .. " " .. ns.StablemasterM, type = "MNL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                --Innkeeper Mailbox
                nodes[2248][41817377] = { name = "", dnID = TextIconInnkeeperN:GetIconString() .. " " .. ns.InnkeeperM .. "\n" .. TextIconMailbox:GetIconString() .. " " .. MINIMAP_TRACKING_MAILBOX, type = "MNL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2215][49073964] = { name = "", dnID = TextIconInnkeeperN:GetIconString() .. " " .. ns.InnkeeperM .. "\n" .. TextIconMailbox:GetIconString() .. " " .. MINIMAP_TRACKING_MAILBOX, type = "MNL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2255][44796648] = { name = "", dnID = TextIconInnkeeperN:GetIconString() .. " " .. ns.InnkeeperM .. "\n" .. TextIconMailbox:GetIconString() .. " " .. MINIMAP_TRACKING_MAILBOX, type = "MNL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2256][44796648] = { name = "", dnID = TextIconInnkeeperN:GetIconString() .. " " .. ns.InnkeeperM .. "\n" .. TextIconMailbox:GetIconString() .. " " .. MINIMAP_TRACKING_MAILBOX, type = "MNL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2369][71353753] = { name = "", dnID = TextIconInnkeeperN:GetIconString() .. " " .. ns.InnkeeperM .. "\n" .. TextIconMailbox:GetIconString() .. " " .. MINIMAP_TRACKING_MAILBOX, type = "MNL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2369][69014647] = { name = "", dnID = TextIconInnkeeperN:GetIconString() .. " " .. ns.InnkeeperM .. "\n" .. TextIconMailbox:GetIconString() .. " " .. MINIMAP_TRACKING_MAILBOX, type = "MNL", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[2214][72018315] = { name = "", dnID = TextIconInnkeeperN:GetIconString() .. " " .. ns.InnkeeperM .. "\n" .. TextIconMailbox:GetIconString() .. " " .. MINIMAP_TRACKING_MAILBOX .. "\n" .. TextIconStablemasterN:GetIconString() .. " " .. ns.StablemasterM, type = "MNL", showInZone = true, showOnContinent = false, showOnMinimap = false }
            end

            if self.db.profile.showZoneAuctioneer then
                nodes[2346][24554476] = { npcID = 239468, name = "", type = "BlackMarket", showInZone = true, showOnContinent = false, showOnMinimap = false }
            end

        end

        end

    end

    end

end