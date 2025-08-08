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
                nodes[66][57004960] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[77][44402860] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[83][58605020] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[71][52602740] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                --nodes[81][53203460] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[198][63202300] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[198][19403620] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[198][41804500] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[249][54723371] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[249][26970748] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[10][67607420] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }

                if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                    nodes[1][52004180] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[10][56403980] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[10][49005760] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[10][62401680] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[7][46985968] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[76][56805000] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[63][73206060] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[63][50206580] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[63][38604240] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[63][12603380] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[65][66206400] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[65][50806300] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[66][24806880] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[69][41401440] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[69][51604800] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[69][74604320] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[207][51205020] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                    nodes[57][56205200] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[97][49004980] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[106][55005980] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[63][36405040] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[65][58605660] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[65][39803220] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[65][31806160] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[66][65600780] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[69][51001800] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[69][46804560] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[70][65235140] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[207][47405160] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
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
                nodes[69][46844514] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Alliance but can be used by Horde
                nodes[249][54543355] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[249][26710783] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[81][55503570] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
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
                    nodes[62][50701930] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false } -- other Phase
                    nodes[63][36505020] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[77][61602550] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[97][48905000] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[106][55105910] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[57][55805100] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end
            end

            if self.db.profile.showZoneInnkeeper then
                nodes[207][49205180] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[70][41807400] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[66][56805000] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[77][44802900] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[198][63002400] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[198][18603720] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[198][42604560] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[198][18603720] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[64][76607480] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[78][55206220] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[71][52602700] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[71][55606080] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[10][67307466] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[83][59805120] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[249][54673294] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[249][21986447] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[249][26610725] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[81][55523676] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }

                if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                    nodes[65][66406420] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[199][40806920] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[199][39202000] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[70][36803220] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[63][38604220] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[63][50406700] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[63][13003400] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[76][57005040] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[69][41401560] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[69][51804760] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[10][56204000] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[10][62401660] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }    
                    nodes[63][74006060] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[1][51604160] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[66][24006820] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[69][74804500] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[65][50406380] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[10][49605800] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[7][46806040] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[77][44006193] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                    nodes[65][59005640] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[65][39403280] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[65][31406060] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[65][71007900] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[199][39001100] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false } 
                    nodes[199][49006860] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[199][65604660] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[97][48404920] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[106][55605960] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[63][36804940] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[77][61802660] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Phase 12608
                    nodes[69][46004520] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[69][51001780] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[70][66404540] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[66][66200660] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[57][55405220] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[62][50951853] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Phase 12608
                end

            end

        end

        -- Eastern Kingdom
        if self.db.profile.showZoneEasternKingdom then

            if self.db.profile.showZoneStablemaster then
                nodes[210][41407360] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[224][36477993] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, mnID = 210, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[15][65603640] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[32][40606860] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[51][72001480] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[122][50203560] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[205][49404200] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[22][47203180] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }

                if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                    nodes[18][61805200] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[21][44602080] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[21][46004260] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[25][36206160] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[25][56804680] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[25][59606480] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[94][47604720] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[95][48403120] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[50][38005120] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[210][34802760] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[224][41103221] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, mnID = 210, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }   
                    nodes[224][33055267] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, mnID = 210, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[14][69003400] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[26][79007960] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[26][32005760] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[22][47806400] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[15][18204220] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[51][47205520] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[241][75605260] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[241][75601680] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[241][53804300] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[241][45207640] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[204][53005920] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[205][51406260] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[2070][59255112] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                    nodes[37][42806580] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[52][53005300] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[49][26204300] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[47][74004620] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[27][54005100] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[48][34604800] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[48][84006280] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[56][57604020] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[56][10605960] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[56][26202580] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[14][40004900] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[26][14404520] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[26][66404500] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[15][21005660] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[51][28603360] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[17][46008540] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
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
                nodes[15][66003650] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[15][90803750] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[51][71901490] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[210][41307400] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[210][40507220] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[205][49204190] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[32][39506800] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[23][75305270] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[122][50003501] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[217][59949211] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxN", showInZone = true, showOnContinent = false, showOnMinimap = false }

                if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                    nodes[95][47803150] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[2070][60715215] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[18][60705220] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[25][56904690] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[94][47804700] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[94][44207070] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxH", showInZone = true, showOnContinent = false, showOnMinimap = false }
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
                    nodes[17][59901690] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[17][45508630] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[47][73804620] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[37][42906560] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[52][55904850] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[52][53105330] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[205][49105700] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[204][55107220] = { name = "", dnID = MINIMAP_TRACKING_MAILBOX, type = "MailboxA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end
            end

            if self.db.profile.showZoneInnkeeper then
                nodes[224][37508015] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, mnID = 210, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[210][40807380] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[217][60219169] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[224][37508015] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, mnID = 210, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[15][65803560] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[23][75805220] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[122][51003400] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }

                if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                    nodes[95][48803240] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[94][48004760] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[205][51606260] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[204][51206060] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[14][68953320] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[25][60206400] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER .. "\n" .. ERR_USE_OBJECT_MOVING, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[25][35806120] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[241][53204280] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[241][75805260] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[241][75401660] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[241][45087674] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[224][34295176] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, mnID = 210, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[224][42503277] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, mnID = 210, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[210][35002720] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[17][40601120] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[21][43204120] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[51][45005660] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[15][02804580] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[18][61605200] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[50][31402960] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[50][37375186] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[26][78208120] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[26][31805800] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[22][48206380] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[18][83007180] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
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
                    nodes[224][52214319] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, mnID = 210, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[47][74004460] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[37][43806580] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[49][27004480] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[26][66204440] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[52][52805360] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[56][58003920] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[26][13804160] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[17][44408760] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[17][60601400] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[50][53206692] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[51][29003260] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[32][39606600] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[15][20605620] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[48][81806420] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[48][35404840] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[27][47205220] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[56][10606080] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[22][43408460] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[14][39844915] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

            end

        end

        -- Outland
        if self.db.profile.showZoneOutland then

            if self.db.profile.showZoneStablemaster then
                nodes[102][78806420] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[105][27605260] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[109][32006480] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                
                if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                    nodes[100][54404100] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[102][31804980] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[108][49404460] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[107][56804080] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[105][75606040] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[105][53605320] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[104][29202940] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                    nodes[100][54402660] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[102][67604960] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[108][56805380] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[107][55807460] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[105][36006460] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[104][37605600] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

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
                nodes[109][43353614] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[109][32006440] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[102][78606300] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[104][66208700] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[104][61002820] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[104][56205980] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[105][62803820] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }

                if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                    nodes[107][56603460] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[102][30605080] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[108][48804500] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[104][30202780] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[100][26805960] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[100][56603760] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[105][76006020] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[105][53205540] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                    nodes[107][54207600] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[102][67204900] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[102][41802620] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[108][56605320] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[104][37005820] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[100][23403660] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[100][54206360] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[105][35806380] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[105][60806820] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
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

        --Pandaria
        if self.db.profile.showZonePandaria then

            if self.db.profile.showZoneZidormi then
                --nodes[390][80483196] = { mnID = 1530, name = "|cffffffff" .. L["Zidormi"], TransportName = L["Travel through time to another point in the history of"] .. " " .. L["Vale of Eternal Blossoms"], type = "Zidormi", showInZone = true, showOnContinent = false, showOnMinimap = false }
                --nodes[1530][80972948] = { mnID = 390, name = "|cffffffff" .. L["Zidormi"], TransportName = L["Travel through time to another point in the history of"] .. " " .. L["Vale of Eternal Blossoms"], type = "Zidormi", showInZone = true, showOnContinent = false, showOnMinimap = false }
            end

            if self.db.profile.showZonePvEVendor then
                nodes[388][37806460] = { name = "", dnID = TRANSMOG_SET_PVE .. " " .. MERCHANT .. "\n" .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. "\n" .. AUCTION_CATEGORY_WEAPONS, type = "PvEVendor", showInZone = true, showOnContinent = false, showOnMinimap = false }
            end

            if self.db.profile.showZonePvPVendor then

                if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                    nodes[379][35408340] = { name = "", dnID = TRANSMOG_SET_PVP .. " " .. MERCHANT .. " " .. FACTION_HORDE .. "\n" .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. "\n" .. AUCTION_CATEGORY_WEAPONS, type = "ZonePvPVendorH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[388][77476296] = { name = "", dnID = TRANSMOG_SET_PVP .. " " .. MERCHANT .. " " .. FACTION_HORDE .. "\n" .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. "\n" .. AUCTION_CATEGORY_WEAPONS, type = "ZonePvPVendorH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                    nodes[376][12003400] = { name = "", dnID = TRANSMOG_SET_PVP .. " " .. MERCHANT .. " " .. FACTION_ALLIANCE .. "\n" .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. "\n" .. AUCTION_CATEGORY_WEAPONS, type = "ZonePvPVendorA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[422][73543407] = { name = "", dnID = TRANSMOG_SET_PVP .. " " .. MERCHANT .. " " .. FACTION_ALLIANCE .. "\n" .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. "\n" .. AUCTION_CATEGORY_WEAPONS, type = "ZonePvPVendorA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

            end

            if self.db.profile.showZoneStablemaster then
                nodes[371][46554376] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[371][54806300] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[376][55204960] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[433][55807580] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[379][65406160] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[379][42206920] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[388][71405760] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[388][84808120] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[388][50007140] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[422][53603240] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[422][55806960] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[390][36007520] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[554][37204680] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[371][27804680] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false }

                if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                    nodes[371][28711310] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[418][59202440] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[390][60402260] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[504][32803260] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_HORDE, type = "StablemasterH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                    nodes[371][44608480] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[418][67203220] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[390][84606320] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[504][63207380] = { name = "", dnID = MINIMAP_TRACKING_STABLEMASTER .. " - " .. FACTION_ALLIANCE, type = "StablemasterA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end
            end

            if self.db.profile.showZoneTransmogger then
                nodes[379][65406180] = { name = "", dnID = MINIMAP_TRACKING_TRANSMOGRIFIER .. " - " .. FACTION_NEUTRAL, type = "Transmogger", showInZone = true, showOnContinent = false, showOnMinimap = false }
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
                nodes[422][55803220] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[422][55207100] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[418][40803440] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[418][75800720] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[418][51607720] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[379][64206120] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[379][44409020] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[379][56009160] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[379][42606960] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[379][57406000] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[379][66003280] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[379][62402880] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[379][55802440] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[379][41602320] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[379][48203480] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[379][54606320] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[379][45604380] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[433][54607260] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[554][36404700] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[388][48807080] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[388][75808280] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[388][71005780] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[376][55205060] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[376][19605620] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[376][83602020] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[371][41722315] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[371][55782443] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[371][45724370] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[371][54586322] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }
                nodes[371][27994743] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperN", showInZone = true, showOnContinent = false, showOnMinimap = false }

                if self.faction == "Horde" or db.activate.ZoneEnemyFaction then
                    nodes[504][33603260] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[418][60802480] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[418][28205060] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[418][10805240] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[379][62608060] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[371][28521334] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperH", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

                if self.faction == "Alliance" or db.activate.ZoneEnemyFaction then
                    nodes[504][64807300] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[418][88803520] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[379][54008280] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[371][44808440] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                    nodes[371][59608320] = { name = "", dnID = MINIMAP_TRACKING_INNKEEPER, type = "InnkeeperA", showInZone = true, showOnContinent = false, showOnMinimap = false }
                end

            end

        end

        end
    end

end
end