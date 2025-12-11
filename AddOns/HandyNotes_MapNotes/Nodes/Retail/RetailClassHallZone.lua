local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

function ns.LoadClassHallZoneLocationinfo(self)
local db = ns.Addon.db.profile
local nodes = ns.nodes
ns.currentSourceFile = "RetailClassHallZone.lua"

--#####################################################################################################
--##########################        function to hide all nodes below         ##########################
--#####################################################################################################
    if not db.activate.HideMapNote then

    --########################################################################################
    --################################         Capitals       ################################
    --########################################################################################
        if db.activate.Capitals then

        --######################
        --### Dalaran Legion ###
        --######################
            if self.db.profile.showCapitalsDalaranLegion then

            --General Dalaran Legion
                if self.db.profile.activate.CapitalsClassHall then

                    if self.db.profile.showCapitalsClassHallEntrance then
                        nodes[627][98096938] = { mnID = 720, name = "", TransportName = ORDER_HALL_DEMONHUNTER .. "\n" .. L["Class Hall"] .. " " .. L["Entrance"] .. " " .. SPLASH_LEGION_BOX_FEATURE1_TITLE, type = "CHDemonhunter", showInZone = true, showOnContinent = false, showOnMinimap = false } -- DH
                        nodes[627][67054820] = { mnID = 726, name = "", TransportName = ORDER_HALL_SHAMAN .. "\n" .. L["Class Hall"] .. " " .. L["Entrance"] .. " " .. L["Shaman"], type = "CHShaman", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Shaman
                        nodes[627][46592575] = { mnID = 626, name = "", TransportName = ORDER_HALL_ROGUE .. "\n" .. L["Class Hall"] .. " " .. L["Entrance"] .. " " .. L["Rogue"] .. "\n\n" .. "(" .. L["talk to"] .. ": " .. ns.Mongar .. ")", type = "CHRogue", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Rogue
                        nodes[627][54323277] = { mnID = 626, name = "", TransportName = ORDER_HALL_ROGUE .. "\n" .. L["Class Hall"] .. " " .. L["Entrance"] .. " " .. L["Rogue"] .. "\n\n" .. "(" .. L["talk to"] .. ": " .. ns.LucianTrias .. ")", type = "CHRogue", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Rogue
                        nodes[627][52707032] = { mnID = 626, name = "", TransportName = ORDER_HALL_ROGUE .. "\n" .. L["Class Hall"] .. " " .. L["Entrance"] .. " " .. L["Rogue"] .. "\n\n" .. "(" .. L["talk to"] .. ": " .. ns.JackFindel .. ")", type = "CHRogue", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Rogue
                        nodes[627][61891355] = { mnID = 24, name = "", TransportName = ORDER_HALL_PALADIN .. "\n" .. L["Class Hall"] .. " " .. L["Entrance"] .. " " .. L["Paladin"], type = "CHPaladin", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Paladin
                        nodes[627][74974754] = { mnID = 695, name = "", TransportName = ORDER_HALL_WARRIOR .. "\n" .. L["Class Hall"] .. " " .. L["Entrance"] .. " " .. L["Warrior"] .. "\n\n" .. ITEM_SPELL_TRIGGER_ONUSE .. " " .. ns.JumpToSkyhold .. "\n(" .. ENCOUNTER_JOURNAL_ABILITY .. ")", type = "CHWarrior", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Warrior
                        nodes[627][62851763] = { mnID = 702, name = "", TransportName = ORDER_HALL_PRIEST .. "\n" .. L["Class Hall"] .. " " .. L["Entrance"] .. " " .. L["Priest"], type = "CHPriest", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Priest
                        nodes[628][27574455] = { mnID = 717, name = "", TransportName = ORDER_HALL_WARLOCK .. "\n" .. L["Class Hall"] .. " " .. L["Entrance"] .. " " .. L["Warlock"], type = "CHWarlock", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Warlock


                        if self.db.profile.showZoneEasternKingdom then    
                            nodes[23][75345252] = { mnID = 24, name = "", TransportName = ORDER_HALL_PALADIN .. "\n" .. L["Class Hall"] .. " " .. L["Entrance"] .. " " .. L["Paladin"], type = "CHPaladin", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Paladin - Eastern Plaqelands
                        end

                        if self.db.profile.showZoneBrokenIsles then
                            nodes[641][42642587] = { mnID = 747, name = "", TransportName = ORDER_HALL_DRUID .. "\n" .. L["Class Hall"] .. " " .. L["Entrance"] .. " " .. L["Druid"], type = "CHDruid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Druid
                            nodes[650][35174553] = { mnID = 739, name = "", TransportName = ORDER_HALL_HUNTER .. "\n" .. L["Class Hall"] .. " " .. L["Entrance"] .. " " .. L["Hunter"], type = "CHHunter", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hunter
                            nodes[646][98715868] = { mnID = 648, name = "", TransportName = ORDER_HALL_DEATHKNIGHT .. "\n" .. L["Class Hall"] .. " " .. L["Entrance"] .. " " .. L["Death Knight"], type = "CHDeathknight", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Deathknight
                        end

                    end

                    if self.db.profile.showCapitalsClassHallPortals and self.db.profile.showCapitalsPortals then

                    end

                    if self.db.profile.showCapitalsClassHallPortals then
                        nodes[24][37606406] = { mnID = 627, name = "", dnID = L["Portal"], type = "CHPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Paladin - Dalaran
                        nodes[747][55542115] = { mnID = 715, name = "", dnID = L["Portal"], type = "CHPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Druid
                        nodes[747][56664308] = { mnID = 627, name = "", dnID = L["Portal"], type = "CHPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Druid
                        nodes[720][59279191] = { mnID = 627, name = "", dnID = L["Portal"], type = "CHPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- DH - Dalaran
                        nodes[720][58361631] = { mnID = 627, name = "", dnID = L["Portal"], type = "CHPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- DH - Dalaran
                        nodes[726][29805198] = { mnID = 627, name = "", dnID = L["Portal"], type = "CHPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Shaman - Dalaran
                        nodes[726][26804137] = { mnID = 325, name = "", dnID = L["Portal"], type = "CHPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Shaman - Vortexgipfel - Instance
                        nodes[726][31126076] = { mnID = 367, name = "", dnID = L["Portal"], type = "CHPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Shaman - Feuerlande - Instance
                        nodes[739][48624354] = { mnID = 627, name = "", dnID = L["Portal"], type = "CHPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hunter - Dalaran
                        nodes[734][57349054] = { mnID = 627, name = "", dnID = L["Portal"], type = "CHPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mage - Dalaran
                        nodes[734][55033957] = { mnID = 630, name = "", dnID = L["Portal"], type = "CHPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mage - Azsuna
                        nodes[734][54674462] = { mnID = 650, name = "", dnID = L["Portal"], type = "CHPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mage - Highmountans
                        nodes[734][60285195] = { mnID = 680, name = "", dnID = L["Portal"] .. "\n(" .. DUNGEON_FLOOR_GILNEAS2 .. ")", type = "CHPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mage - Suramar
                        nodes[734][67124161] = { mnID = 634, name = "", dnID = L["Portal"], type = "CHPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mage - Stormheim
                        nodes[734][66764669] = { mnID = 641, name = "", dnID = L["Portal"], type = "CHPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mage - Val'sharah
                        nodes[702][49758073] = { mnID = 627, name = "", dnID = L["Portal"], type = "CHPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Priest - Dalaran
                        nodes[648][24683374] = { mnID = 627, name = "", dnID = L["Portal"], type = "CHPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Deathknight - Dalaran
                        nodes[717][75793679] = { mnID = 627, name = "", dnID = L["Portal"], type = "CHPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Warlock - Dalaran
                        nodes[709][52405715] = { mnID = 627, name = "", dnID = L["Portal"], type = "CHPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Monk - Dalaran
                        nodes[709][50055442] = { mnID = 379, name = "", dnID = L["Portal"] .. " " .. DUNGEON_FLOOR_KUNLAISUMMITSCENARIO0, type = "CHPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Monk - Kun-Lai
                    end

                    if self.db.profile.showCapitalsClassHallPaths and self.db.profile.showCapitalsPaths then
                        nodes[627][77594788] = { name = "", TransportName = L["Class Hall"] .. " " .. L["Passage"] .. "\n ==> " .. SPLASH_LEGION_BOX_FEATURE1_TITLE, type = "RedPathRU", showInZone = true, showOnContinent = false, showOnMinimap = false } -- DH
                        nodes[627][34664554] = { name = "", mnID = 628, TransportName = L["Passage"] .. "\n ==> " .. L["Class Hall"] .. " " .. L["Warlock"] .. "\n ==> " .. DUNGEON_FLOOR_DALARAN2, type = "RedPathL", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Warlock
                        nodes[627][59714771] = { name = "", mnID = 628, TransportName = L["Passage"] .. "\n ==> " .. L["Class Hall"] .. " " .. L["Warlock"] .. "\n ==> " .. DUNGEON_FLOOR_DALARAN2, type = "RedPathRU", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Warlock
                        nodes[627][48343243] = { name = "", mnID = 628, TransportName = L["Passage"] .. "\n ==> " .. L["Class Hall"] .. " " .. L["Warlock"] .. "\n ==> " .. DUNGEON_FLOOR_DALARAN2, type = "RedPathU", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Warlock
                    end

                    if self.db.profile.showCapitalsClassHallPaths then
                        nodes[24][39579315] = { mnID = 23, name = L["Exit"], type = "RedPathLU", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Paladin
                        nodes[626][29572185] = { mnID = 627, name = L["Passage"], type = "RedPathRO", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Rogue
                        nodes[626][39652153] = { mnID = 627, name = L["Passage"], type = "RedPathLO", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Rogue
                        nodes[626][85397396] = { mnID = 627, name = L["Passage"], type = "RedPathRU", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Rogue
                        nodes[626][32583995] = { mnID = 619, name = L["Exit"], type = "RedPathLU", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Rogue
                        nodes[747][76219388] = { mnID = 641, name = L["Exit"], type = "RedPathRU", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Druid
                        nodes[721][49545406] = { mnID = 720, name = L["Passage"], type = "RedPathL", showInZone = true, showOnContinent = false, showOnMinimap = false } -- DH
                        nodes[721][68245395] = { mnID = 720, name = L["Passage"], type = "RedPathR", showInZone = true, showOnContinent = false, showOnMinimap = false } -- DH
                        nodes[720][69805381] = { mnID = 721, name = L["Passage"], type = "RedPathL", showInZone = true, showOnContinent = false, showOnMinimap = false } -- DH
                        nodes[720][47675427] = { mnID = 721, name = L["Passage"], type = "RedPathR", showInZone = true, showOnContinent = false, showOnMinimap = false } -- DH
                        nodes[735][69407757] = { mnID = 734, name = L["Passage"], type = "RedPathRU", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mage
                        nodes[735][44867427] = { mnID = 734, name = L["Passage"], type = "RedPathLU", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mage
                        nodes[735][58016763] = { mnID = 734, name = L["Passage"], type = "RedPathU", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mage
                        nodes[734][59795949] = { mnID = 735, name = L["Passage"], type = "RedPathO", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mage
                        nodes[734][46485455] = { mnID = 735, name = L["Passage"], type = "RedPathRU", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mage
                        nodes[734][73335924] = { mnID = 735, name = L["Passage"], type = "RedPathLU", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mage
                        nodes[739][46020484] = { mnID = 650, name = L["Passage"], type = "RedPathRO", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hunter
                        nodes[647][33373550] = { mnID = 648, name = L["Passage"], TransportName = DUNGEON_FLOOR_GILNEAS2, type = "RedPathU", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Deathknight - Upstairs
                        nodes[648][34703682] = { mnID = 647, name = L["Passage"], TransportName = DUNGEON_FLOOR_GILNEAS3, type = "RedPathO", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Deathknight - Downstairs
                    end

                    if self.db.profile.showCapitalsClassHallVendor and self.db.profile.showCapitalsPvEVendor then
                        nodes[627][45232906] = { npcID = 106655, name = ns.WakeningEssence .. " " .. MERCHANT, type = "CHVendor", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Vendor Dalaran
                    end

                    if self.db.profile.showCapitalsClassHallVendor then
                        nodes[24][41316114] = { npcID = 100196, name = "", type = "CHVendor", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Paladin
                        nodes[24][53864948] = { npcID = 110434, name = "", type = "CHVendor", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Paladin
                        nodes[747][40731865] = { npcID = 112323, name = "", dnID = ns.QuartermasterF, type = "CHVendor", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Druid
                        nodes[720][58674315] = { npcIDs1 = 112407, npcIDs2 = 116621, npcIDs3 = 110433, name = ns.QuartermasterF, type = "CHVendor", showInZone = true, showOnContinent = false, showOnMinimap = false } -- DH
                        nodes[626][26893693] = { npcID = 105986, name = "", type = "CHVendor", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Rogue
                        nodes[626][45542759] = { npcID = 103792, name = "", dnID = TRANSMOG_SET_PVE .. " " .. MERCHANT .. "\n" .. TUTORIAL_TITLE1, type = "CHVendor", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Rogue
                        nodes[626][54354093] = { npcID = 99863, name = "", dnID = TRANSMOG_SET_PVE .. " " .. MERCHANT, type = "CHVendor", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Rogue
                        nodes[626][74495419] = { npcID = 106054, name = "", type = "CHVendor", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Rogue
                        nodes[626][64614421] = { npcID = 105982, name = "", type = "CHVendor", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Rogue
                        nodes[726][30306069] = { npcID = 112318, name = "", type = "CHVendor", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Shaman
                        nodes[739][44574881] = { npcID = 103693, name = "", dnID = ns.QuartermasterM, type = "CHVendor", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hunter
                        nodes[739][58584847] = { npcID = 110412, name = "", type = "CHVendor", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hunter
                        nodes[735][44705795] = { npcID = 112440, name = "", type = "CHVendor", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mage
                        nodes[734][82875666] = { npcID = 110427, name = "", type = "CHVendor", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mage
                        nodes[734][57006695] = { npcID = 103169, name = "", dnID = TOY .. " " .. MERCHANT, type = "CHVendor", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mage
                        nodes[695][55782619] = { npcID = 112392, name = "", type = "CHVendor", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Warrior
                        nodes[695][62402594] = { npcID = 110437, name = "", type = "CHVendor", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Warrior
                        nodes[702][38652375] = { npcID = 112401, name = "", dnID = ns.QuartermasterF, type = "CHVendor", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Priest
                        nodes[702][45382628] = { npcID = 110595, name = "", type = "CHVendor", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Priest
                        nodes[647][43903801] = { npcID = 93550, name = "", dnID = ns.QuartermasterM, type = "CHVendor", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Deathknight
                        nodes[647][51673215] = { npcID = 110410, name = "", type = "CHVendor", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Deathknight
                        nodes[717][58843257] = { npcID = 112434, name = "", type = "CHVendor", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Warlock
                        nodes[717][57235238] = { npcID = 110408, name = "", dnID = ns.WeaponsSupplierM, type = "CHVendor", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Warlock
                        nodes[709][50345912] = { npcID = 112338, name = "", dnID = ns.QuartermasterF, type = "CHVendor", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Monk
                    end

                    if self.db.profile.showCapitalsClassHallScoutingMap then
                        nodes[24][53447863] = { npcID = 93787, name = ns.ScoutingMap, type = "CHScoutingMap", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Paladin
                        nodes[626][37664439] = { npcID = 98093, name = ns.ScoutingMap, type = "CHScoutingMap", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Rogue
                        nodes[747][52705108] = { npcID = 98000, name = ns.ScoutingMap, type = "CHScoutingMap", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Druid
                        nodes[720][58915379] = { npcID = 98613, name = ns.ScoutingMap, type = "CHScoutingMap", showInZone = true, showOnContinent = false, showOnMinimap = false } -- DH
                        nodes[726][33495937] = { npcID = 99428, name = ns.ScoutingMap, type = "CHScoutingMap", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Shaman
                        nodes[739][42484662] = { npcID = 102669, name = ns.ScoutingMap, type = "CHScoutingMap", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hunter
                        nodes[734][81906140] = { npcID = 98695, name = ns.ScoutingMap, type = "CHScoutingMap", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mage
                        nodes[695][59171345] = { npcID = 97389, name = ns.ScoutingMap, type = "CHScoutingMap", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Warrior
                        nodes[702][49754714] = { npcID = 102589, name = ns.ScoutingMap, type = "CHScoutingMap", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Priest
                        nodes[648][50265081] = { npcID = 97379, name = ns.ScoutingMap, type = "CHScoutingMap", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Deathknight
                        nodes[717][66694802] = { npcID = 97379, name = ns.ScoutingMap, type = "CHScoutingMap", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Warlock
                        nodes[709][52926044] = { npcID = 99041, name = ns.ScoutingMap, type = "CHScoutingMap", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Monk
                    end

                    if self.db.profile.showCapitalsClassHallArtifactForge then
                        nodes[24][72472397] = { name = L["Artifact Forge"], type = "ArtifactForge", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Paladin
                        nodes[721][58542712] = { name = L["Artifact Forge"], type = "ArtifactForge", showInZone = true, showOnContinent = false, showOnMinimap = false } -- DH
                        nodes[626][27406178] = { name = L["Artifact Forge"], type = "ArtifactForge", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Rogue
                        nodes[747][30865365] = { name = L["Artifact Forge"], type = "ArtifactForge", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Druid
                        nodes[726][37184574] = { name = L["Artifact Forge"], type = "ArtifactForge", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Shaman
                        nodes[739][47815361] = { name = L["Artifact Forge"], type = "ArtifactForge", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hunter
                        nodes[735][59814367] = { name = L["Artifact Forge"], type = "ArtifactForge", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mage
                        nodes[695][39903569] = { name = L["Artifact Forge"], type = "ArtifactForge", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Warrior
                        nodes[702][49732169] = { name = L["Artifact Forge"], type = "ArtifactForge", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Priest
                        nodes[647][60316010] = { name = L["Artifact Forge"], type = "ArtifactForge", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Deathknight
                        nodes[717][34212855] = { name = L["Artifact Forge"], type = "ArtifactForge", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Warlock
                        nodes[709][51474811] = { name = L["Artifact Forge"], type = "ArtifactForge", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Monk
                    end

                    if self.db.profile.showCapitalsClassHallRecruit then
                        nodes[24][53305619] = { npcID = 106447, name = "", type = "Recruit", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Paladin
                        nodes[24][58913899] = { npcID = 106448, name = "", type = "Recruit", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Paladin                        
                        nodes[747][36332540] = { npcID = 108393, name = "", type = "Recruit", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Druid
                        nodes[747][43276316] = { npcID = 111786, name = "", dnID = ns.RecruitM, type = "Recruit", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Druid
                        nodes[747][38623423] = { npcID = 106442, name = "", type = "Recruit", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Druid
                        nodes[747][29834275] = { npcID = 108391, name = "", type = "Recruit", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Druid
                        nodes[626][31962667] = { npcID = 105979, name = "", dnID = ns.RecruitF, type = "Recruit", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Rogue
                        nodes[626][48244122] = { npcID = 106083, name = "", dnID = ns.RecruitM, type = "Recruit", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Rogue
                        nodes[626][45837776] = { npcID = 120162, name = "", type = "Recruit", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Rogue
                        nodes[720][56185422] = { npcID = 103025, name = "", dnID = ns.RecruitM, type = "Recruit", showInZone = true, showOnContinent = false, showOnMinimap = false } -- DH
                        nodes[720][58683885] = { npcID = 103760, name = "", dnID = ns.RecruitM, type = "Recruit", showInZone = true, showOnContinent = false, showOnMinimap = false } -- DH
                        nodes[720][56147458] = { npcID = 120140, name = "", type = "Recruit", showInZone = true, showOnContinent = false, showOnMinimap = false } -- DH
                        nodes[726][30525877] = { npcID = 106457, name = "", dnID = ns.RecruitM, type = "Recruit", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Shaman
                        nodes[726][31825148] = { npcID = 109829, name = "", dnID = ns.RecruitM, type = "Recruit", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Shaman
                        nodes[726][29274281] = { npcID = 112208, name = "", type = "Recruit", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Shaman
                        nodes[739][42833769] = { npcID = 106444, name = "", type = "Recruit", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hunter
                        nodes[739][57703265] = { npcID = 106446, name = "", type = "Recruit", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hunter
                        nodes[739][50903138] = { npcID = 106445, name = "", type = "Recruit", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hunter
                        nodes[734][47753215] = { npcID = 106433, name = "", type = "Recruit", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mage
                        nodes[734][87864745] = { npcID = 106377, name = "", type = "Recruit", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mage
                        nodes[734][81192809] = { npcID = 106434, name = "", type = "Recruit", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mage
                        nodes[695][62351503] = { npcID = 106459, name = "", type = "Recruit", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Warrior
                        nodes[695][55991502] = { npcID = 106460, name = "", type = "Recruit", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Warrior
                        nodes[702][40855398] = { npcID = 106451, name = "", type = "Recruit", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Priest
                        nodes[702][40902747] = { npcID = 106450, name = "", type = "Recruit", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Priest
                        nodes[702][57205498] = { npcID = 120160, name = "", type = "Recruit", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Priest
                        nodes[648][40897387] = { npcID = 106435, name = "", type = "Recruit", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Deathknight
                        nodes[647][53316838] = { npcID = 106436, name = "", type = "Recruit", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Deathknight
                        nodes[717][61545167] = { npcID = 106217, name = "", type = "Recruit", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Warlock
                        nodes[717][66603011] = { npcID = 106216, name = "", type = "Recruit", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Warlock
                        nodes[717][52962219] = { npcID = 120166, name = "", dnID = ns.RecruitM, type = "Recruit", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Warlock
                        nodes[709][51665537] = { npcID = 120145, name = "", type = "Recruit", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Monk
                        nodes[709][53335974] = { npcID = 105015, name = "", dnID = ns.RecruitM, type = "Recruit", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Monk
                    end

                    if self.db.profile.showCapitalsClassHallUpgrade then
                        nodes[24][39845649] = { npcID = 109901, name = "", type = "CHUpgrade", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Paladin
                        nodes[721][55256271] = { npcID = 108527, name = "", type = "CHUpgrade", showInZone = true, showOnContinent = false, showOnMinimap = false } -- DH
                        nodes[626][45966916] = { npcID = 105998, name = "", dnID = ns.Upgrade, type = "CHUpgrade", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Rogue
                        nodes[747][32862934] = { npcID = 97989, name = "", dnID = ns.Upgrade, type = "CHUpgrade", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Druid
                        nodes[726][33385816] = { npcID = 112199, name = "", type = "CHUpgrade", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Shaman
                        nodes[739][58695119] = { npcID = 108050, name = "", type = "CHUpgrade", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hunter
                        nodes[734][74942896] = { npcID = 108331, name = "", type = "CHUpgrade", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mage
                        nodes[695][46512886] = { npcID = 107994, name = "", type = "CHUpgrade", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Warrior
                        nodes[702][56044062] = { npcID = 110725, name = "", type = "CHUpgrade", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Priest
                        nodes[648][47705370] = { npcID = 97485, name = "", type = "CHUpgrade", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Deathknight
                        nodes[717][55344083] = { npcID = 108018, name = "", type = "CHUpgrade", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Warlock
                        nodes[709][53045977] = { npcID = 98939, name = "", type = "CHUpgrade", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Monk
                    end

                    if self.db.profile.showCapitalsClassHallArchivar then
                        nodes[24][37705720] = { npcID = 91190, name = "", type = "Archivar", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Paladin
                        nodes[747][33903263] = { npcID = 111737, name = ns.Archivar, type = "Archivar", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Druid
                        nodes[721][62047501] = { npcID = 111736, name = ns.Archivar, type = "Archivar", showInZone = true, showOnContinent = false, showOnMinimap = false } -- DH
                        nodes[626][37867008] = { npcID = 102641, name = "", type = "Archivar", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Rogue
                        nodes[726][32594964] = { npcID = 111739, name = "", type = "Archivar", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Shaman
                        nodes[739][52505442] = { npcID = 98737, name = "", type = "Archivar", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hunter
                        nodes[735][64705027] = { npcID = 110624, name = "", type = "Archivar", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mage
                        nodes[695][45102811] = { npcID = 111741, name = "", type = "Archivar", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Warrior
                        nodes[702][59852812] = { npcID = 111738, name = "", type = "Archivar", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Priest
                        nodes[648][49815565] = { npcID = 97111, name = "", type = "Archivar", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Deathknight
                        nodes[717][56954089] = { npcID = 111740, name = "", type = "Archivar", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Warlock
                        nodes[709][46514647] = { npcID = 106942, name = "", type = "Archivar", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Monk
                    end

                    if self.db.profile.showCapitalsClassHallMountMerchent then
                        nodes[626][42498227] = { npcID = 121282, name = PERKS_VENDOR_CATEGORY_MOUNT .. " " .. MERCHANT, type = "CHMountMerchant", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Rogue
                    end

                    if self.db.profile.showCapitalsClassHallMailbox then
                        nodes[747][40442600] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "CHMailbox", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Druid
                        nodes[734][52618324] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "CHMailbox", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mage
                    end

                    if self.db.profile.showCapitalsClassHallFP then
                        nodes[747][61733398] = { npcID = 107457, name = "", type = "CHTravel", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Druid
                        nodes[739][35812762] = { npcID = 98968, name = "", type = "CHTravel", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hunter
                        nodes[739][40072857] = { npcID = 109572, name = "", TransportName = L["Hunter"] .. " " .. L["Class Hall"] .. " " .. MINIMAP_TRACKING_FLIGHTMASTER, type = "CHTravel", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hunter
                        --nodes[627][69825114] = { mnID = 739, npcID = 96813, name = "", TransportName = ORDER_HALL_HUNTER .. "\n" .. L["Class Hall"] .. " " .. L["Hunter"], type = "CHTravel", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hunter
                        nodes[695][58362483] = { npcID = 96679, name = "", type = "CHTravel", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Warrior
                        nodes[648][25562881] = { npcID = 93465, name = "", type = "CHTravel", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Deathknight
                    end

                    if self.db.profile.showCapitalsClassHallStablemaster then
                        nodes[739][58783181] = { npcID = 100661, name = "", type = "CHStablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hunter
                    end

                end
            end
        end
    end
end