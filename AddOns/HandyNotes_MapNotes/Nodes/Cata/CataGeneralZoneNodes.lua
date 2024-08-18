local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

function ns.LoadGeneralZoneLocationinfo(self)
local db = ns.Addon.db.profile
local nodes = ns.nodes

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

            if self.db.profile.showZoneStablemaster then
                nodes[1443][57004960] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1448][44402860] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1452][58605020] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1446][52602740] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                --nodes[1451][53203460] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[198][63202300] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[198][19403620] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[198][41804500] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[249][54723371] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[249][26970748] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1413][67607420] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }

                if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                    nodes[1411][52004180] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1413][56403980] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1413][49005760] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1413][62401680] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1412][46985968] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1447][56805000] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1440][73206060] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1440][50206580] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1440][38604240] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1440][12603380] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1442][66206400] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1442][50806300] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1443][24806880] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1444][41401440] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1444][51604800] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1444][74604320] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[207][51205020] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                    nodes[1438][56205200] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1943][49004980] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1950][55005980] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1440][36405040] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1442][58605660] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1442][39803220] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1442][31806160] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1443][65600780] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1444][51001800] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1444][46804560] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1445][65235140] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[207][47405160] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

            end

            if self.db.profile.showZoneMailbox then
                nodes[1452][59805090] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[198][63502360] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[198][41904450] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[198][18703740] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1447][66002040] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1447][43002470] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1447][50307420] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1447][29006590] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1443][57204980] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1450][51604050] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1450][55903140] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1445][42007330] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1413][67507420] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1448][44302870] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1441][77707360] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1444][46844514] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Alliance but can be used by Horde
                nodes[249][54543355] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[249][26710783] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1451][55503570] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1446][52502730] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                
                if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                    nodes[1443][24806880] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1444][74904400] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1412][47205970] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1442][50806300] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1413][49605880] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1440][73606090] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1440][50206600] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1440][38704250] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1440][12703400] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1448][44006200] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1447][56805030] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1447][26507890] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1411][45401220] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1411][51904210] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1411][56107450] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1442][66306410] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1445][36603210] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[199][40806950] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[199][39302010] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1441][45905100] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                    nodes[1442][58905590] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1445][65904530] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1442][31806000] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1443][65500690] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1444][57005400] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1439][50701930] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false } -- other Phase
                    nodes[1440][36505020] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1448][61602550] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1943][48905000] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1950][55105910] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1438][55805100] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end
            end

            if self.db.profile.showZoneInnkeeper then
                nodes[207][49205180] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1445][41807400] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1443][56805000] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1448][44802900] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[198][63002400] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[198][18603720] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[198][42604560] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[198][18603720] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1441][76607480] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1449][55206220] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1446][52602700] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1446][55606080] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1413][67307466] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1452][59805120] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[249][54673294] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[249][21986447] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[249][26610725] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1451][55523676] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }

                if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                    nodes[1442][66406420] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[199][40806920] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[199][39202000] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1445][36803220] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1440][38604220] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1440][50406700] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1440][13003400] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1447][57005040] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1444][41401560] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1444][51804760] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1413][56204000] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1413][62401660] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }    
                    nodes[1440][74006060] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1411][51604160] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1443][24006820] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1444][74804500] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1442][50406380] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1413][49605800] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1412][46806040] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1448][44006193] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                    nodes[1442][59005640] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1442][39403280] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1442][31406060] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1442][71007900] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[199][39001100] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false } 
                    nodes[199][49006860] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[199][65604660] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1943][48404920] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1950][55605960] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1440][36804940] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1448][61802660] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Phase 12608
                    nodes[1444][46004520] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1444][51001780] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1445][66404540] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1443][66200660] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1438][55405220] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1439][50951853] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Phase 12608
                end

            end

        end

        -- Eastern Kingdom
        if self.db.profile.showZoneEasternKingdom then

            if self.db.profile.showZoneStablemaster then
                nodes[1434][41407360] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[224][36477993] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, mnID = 1434, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1418][65603640] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1427][40606860] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1435][72001480] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1957][50203560] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[205][49404200] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1422][47203180] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }

                if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                    nodes[1420][61805200] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1421][44602080] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1421][46004260] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1424][36206160] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1424][56804680] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1424][59606480] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1941][47604720] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1942][48403120] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1434][38005120] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1434][34802760] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[224][41103221] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, mnID = 1434, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }   
                    nodes[224][33055267] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, mnID = 1434, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1417][69003400] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1425][79007960] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1425][32005760] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1422][47806400] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1418][18204220] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1435][47205520] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[241][75605260] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[241][75601680] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[241][53804300] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[241][45207640] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[204][53005920] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[205][51406260] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[2070][59255112] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                    nodes[1429][42806580] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1436][53005300] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1433][26204300] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1431][74004620] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1426][54005100] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1432][34604800] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1432][84006280] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1437][57604020] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1437][10605960] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1437][26202580] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1417][40004900] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1425][14404520] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1425][66404500] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1418][21005660] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1435][28603360] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1419][46008540] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[241][80607740] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[241][55601480] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[241][48602960] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[241][60205800] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[241][43605740] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[204][56007300] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[205][49005760] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end
            end

            if self.db.profile.showZoneMailbox then
                nodes[241][74701750] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1418][66003650] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1418][90803750] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1435][71901490] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1434][41307400] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1434][40507220] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[205][49204190] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1427][39506800] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1423][75305270] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1957][50003501] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[217][59949211] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }

                if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                    nodes[1942][47803150] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[2070][60715215] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1420][60705220] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1424][56904690] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1941][47804700] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1941][44207070] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1425][78908050] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1421][46104230] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1421][44502100] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1417][69003280] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[241][53904300] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[241][75705290] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1418][18104320] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1435][47205530] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1434][38905020] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1434][35202760] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[205][51106300] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[204][51206070] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                    nodes[1422][43608450] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1425][66004520] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1437][57604010] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1437][10805970] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1426][54105090] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[427][62603270] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1432][34804780] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[241][49502990] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[241][80307700] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1433][26004300] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1435][29103330] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1419][59901690] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1419][45508630] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1431][73804620] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1429][42906560] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1436][55904850] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1436][53105330] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[205][49105700] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[204][55107220] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end
            end

            if self.db.profile.showZoneInnkeeper then
                nodes[224][37508015] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, mnID = 1434, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1434][40807380] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[217][60219169] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[224][37508015] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, mnID = 1434, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1418][65803560] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1423][75805220] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1957][51003400] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }

                if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                    nodes[1942][48803240] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1941][48004760] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[205][51606260] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[204][51206060] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1417][68953320] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1424][60206400] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER .. "\n" .. ERR_USE_OBJECT_MOVING, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1424][35806120] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[241][53204280] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[241][75805260] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[241][75401660] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[241][45087674] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[224][34295176] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, mnID = 1434, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[224][42503277] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, mnID = 1434, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1434][35002720] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1419][40601120] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1421][43204120] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1435][45005660] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1418][02804580] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1420][61605200] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1434][31402960] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1434][27007720] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1425][78208120] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1425][31805800] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1422][48206380] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1420][83007180] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                    nodes[205][49605740] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[204][54607220] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[241][79407860] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[241][79007760] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[241][54601800] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[241][49603040] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[241][43605720] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[241][60405800] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }  
                    nodes[224][52214319] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, mnID = 1434, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1431][74004460] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1429][43806580] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1433][27004480] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1425][66204440] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1436][52805360] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1437][58003920] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1425][13804160] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1419][44408760] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1419][60601400] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1434][53206680] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1435][29003260] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1427][39606600] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1418][20605620] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1432][81806420] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1432][35404840] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1426][47205220] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1437][10606080] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1422][43408460] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1417][39844915] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

            end

        end

        -- Outland
        if self.db.profile.showZoneOutland then

            if self.db.profile.showZoneStablemaster then
                nodes[1946][78806420] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1949][27605260] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1953][32006480] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                
                if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                    nodes[1944][54404100] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1946][31804980] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1952][49404460] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1951][56804080] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1949][75606040] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1949][53605320] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1948][29202940] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                    nodes[1944][54402660] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1946][67604960] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1952][56805380] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1951][55807460] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1949][36006460] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1948][37605600] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

            end

            if self.db.profile.showZoneMailbox then
                nodes[1948][56305820] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1948][61402900] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1946][78906370] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1953][32206460] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1953][43603590] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1949][62603850] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1949][27605250] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }

                if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                    nodes[1952][49504490] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1951][56473557] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1946][31905010] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1944][26806050] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1944][56503800] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1949][52705570] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1949][75706080] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                    nodes[1952][57005370] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1951][54507360] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1946][42102710] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1946][67504920] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1944][23503750] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1944][55006360] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1949][36306430] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1949][60806840] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1948][37205750] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1948][30102840] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end
            end

            if self.db.profile.showZoneInnkeeper then
                nodes[1953][43353614] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1953][32006440] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1946][78606300] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1948][66208700] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1948][61002820] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1948][56205980] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[1949][62803820] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }

                if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                    nodes[1951][56603460] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1946][30605080] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1952][48804500] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1948][30202780] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1944][26805960] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1944][56603760] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1949][76006020] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1949][53205540] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                    nodes[1951][54207600] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1946][67204900] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1946][41802620] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1952][56605320] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1948][37005820] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1944][23403660] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1944][54206360] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1949][35806380] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1949][60806820] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end
            end

        end

        --Northrend
        if self.db.profile.showZoneNorthrend then

            if self.db.profile.showZoneStablemaster then
                nodes[114][78004900] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[117][25405900] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[115][48407460] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[115][61605340] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[121][40206520] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[121][59005760] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[119][27205960] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[120][49806600] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[120][30603680] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[120][40808600] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[118][44202240] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[118][69602200] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[118][71602260] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }

                if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                    nodes[114][40205500] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[114][49801060] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[114][77003720] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[117][79003080] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[117][52006660] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[117][49401100] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[115][37004860] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[115][76806260] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[116][21606400] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[116][65004780] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[116][13808480] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[120][67405020] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[118][75602360] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                    nodes[114][56607300] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[114][57001900] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[117][58606300] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[117][60601600] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[117][31604140] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[115][28805600] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[115][77405080] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[116][32605960] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[116][59002660] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[116][13808460] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[120][28607440] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[118][75802020] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
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
                nodes[114][78404920] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[115][48207460] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[115][59805420] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[117][25405980] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[118][44002220] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[119][26805920] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[121][40806620] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[121][59205720] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[120][41008580] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[120][48806500] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[120][30903737] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }

                if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                    nodes[114][76203720] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[114][49601000] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[114][41805460] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[115][38204600] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[115][76866312] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[116][65404700] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[116][20806460] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[117][49401080] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[117][79603080] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[117][52206640] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[118][76002400] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[120][37004960] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[120][67605060] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                    nodes[114][57111864] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[114][58206800] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[144][57001860] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[115][77405160] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[115][28805600] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[116][59602640] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[116][32006020] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[117][60401580] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[117][30804140] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[117][58406260] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[118][76201960] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[120][28607440] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

            end

        end

        end
    end

end
end