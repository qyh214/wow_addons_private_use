local ADDON_NAME, ns = ...
local HandyNotes = LibStub("AceAddon-3.0"):GetAddon("HandyNotes", true)
local AceTimer = LibStub("AceTimer-3.0")

local ProfessionDetection = CreateFrame("Frame")
function OnEvent(self, event, ...)
    Text = CHAT_MSG_SKILL    
    if event == "CHAT_MSG_SKILL" then
        ns.AutomaticProfessionDetection()
    end
end
ProfessionDetection:SetScript("OnEvent", OnEvent)
ProfessionDetection:RegisterEvent("CHAT_MSG_SKILL")

function ns.AutomaticProfessionDetection()

    local alchemy = IsSpellKnown(3101)
            or IsSpellKnown(3464)
            or IsSpellKnown(11611)
            or IsSpellKnown(2259) -- Vanilla
            or IsSpellKnown(265787) -- Zandalari
            or IsSpellKnown(309822) -- Shadowlands
            or IsSpellKnown(264245) -- Pandaria     
            or IsSpellKnown(264213) -- Outland   
            or IsSpellKnown(264220) -- Northrend            
            or IsSpellKnown(264250) -- Legion
            or IsSpellKnown(264255) -- Kul Tiran
            or IsSpellKnown(423321) -- Khaz Algar    
            or IsSpellKnown(366261) -- Dragon Isle            
            or IsSpellKnown(264247) -- Draenor
            or IsSpellKnown(264243) -- Cataclysm

    local blacksmith = IsSpellKnown(3100) or IsSpellKnown(3538) or IsSpellKnown(9785)
            or IsSpellKnown(2018) -- Vanilla
            or IsSpellKnown(265803) -- Zandalari
            or IsSpellKnown(309827) -- Shadowlands
            or IsSpellKnown(264442) -- Pandaria
            or IsSpellKnown(264436) -- Outland
            or IsSpellKnown(264438) -- Northrend
            or IsSpellKnown(264446) -- Legion
            or IsSpellKnown(264448) -- Kul Tiran
            or IsSpellKnown(423332) -- Khaz Algar
            or IsSpellKnown(365677) -- Dragon Isle
            or IsSpellKnown(264444) -- Draenor
            or IsSpellKnown(264440) -- Cataclysm

    local enchanting = IsSpellKnown(13262) -- Disenchant

    local engineer = IsSpellKnown(4037) or IsSpellKnown(4038) or IsSpellKnown(12656)
            or IsSpellKnown(4036) -- Vanilla
            or IsSpellKnown(265807) -- Zandalari
            or IsSpellKnown(310542) -- Shadowlands
            or IsSpellKnown(264485) -- Pandaria
            or IsSpellKnown(264479) -- Outland
            or IsSpellKnown(264481) -- Northrend
            or IsSpellKnown(264490) -- Legion
            or IsSpellKnown(264492) -- Kul Tiran
            or IsSpellKnown(423335) -- Khaz Algar
            or IsSpellKnown(366254) -- Dragon Isle
            or IsSpellKnown(264487) -- Draenor
            or IsSpellKnown(264483) -- Cataclysm
            or IsSpellKnown(20222) -- Goblin
            or IsSpellKnown(20219) -- Gnomish

    local herbalism = IsSpellKnown(2366) -- Herb Gathering
            or IsSpellKnown(193290) -- Vanilla

    local inscription = IsSpellKnown(45358)
            or IsSpellKnown(45357) -- Vanilla
            or IsSpellKnown(265809) -- Zandalari
            or IsSpellKnown(309805) -- Shadowlands
            or IsSpellKnown(264502) -- Pandaria
            or IsSpellKnown(264496) -- Outland
            or IsSpellKnown(264498) -- Northrend
            or IsSpellKnown(264506) -- Legion
            or IsSpellKnown(264508) -- Kul Tiran
            or IsSpellKnown(423338) -- Khaz Algar
            or IsSpellKnown(366251) -- Dragon Isle
            or IsSpellKnown(264504) -- Draenor
            or IsSpellKnown(264500) -- Cataclysm

    local jewelcrafting = IsSpellKnown(25230)
            or IsSpellKnown(25229) -- Vanilla
            or IsSpellKnown(265811) -- Zandalari
            or IsSpellKnown(311967) -- Shadowlands
            or IsSpellKnown(264542) -- Pandaria
            or IsSpellKnown(264534) -- Outland
            or IsSpellKnown(264537) -- Northrend
            or IsSpellKnown(264546) -- Legion
            or IsSpellKnown(264548) -- Kul Tiran
            or IsSpellKnown(423339) -- Khaz Algar
            or IsSpellKnown(366250) -- Dragon Isle
            or IsSpellKnown(264544) -- Draenor
            or IsSpellKnown(264539) -- Cataclysm

    local mining = IsSpellKnown(2575) or IsSpellKnown(2576) or IsSpellKnown(3564) or IsSpellKnown(10248) or IsSpellKnown(2656)

    local leatherworking = IsSpellKnown(3104) or IsSpellKnown(3811) or IsSpellKnown(10662)
            or IsSpellKnown(2108) -- Vanilla
            or IsSpellKnown(265813) -- Zandalari
            or IsSpellKnown(309038) -- Shadowlands
            or IsSpellKnown(264585) -- Pandaria
            or IsSpellKnown(264579) -- Outland
            or IsSpellKnown(264581) -- Northrend
            or IsSpellKnown(264590) -- Legion
            or IsSpellKnown(264592) -- Kul Tiran
            or IsSpellKnown(423340) -- Khaz Algar
            or IsSpellKnown(366249) -- Dragon Isle
            or IsSpellKnown(264588) -- Draenor
            or IsSpellKnown(264583) -- Cataclysm

    local skinning = IsSpellKnown(8613) or IsSpellKnown(8617) or IsSpellKnown(8618) or IsSpellKnown(10768) or IsSpellKnown(194174) -- Vanilla

    local tailoring = IsSpellKnown(3909) or IsSpellKnown(3910) or IsSpellKnown(12180)
            or IsSpellKnown(3908) -- Vanilla
            or IsSpellKnown(265815) -- Zandalari
            or IsSpellKnown(310949) -- Shadowlands
            or IsSpellKnown(264624) -- Pandaria
            or IsSpellKnown(264618) -- Outland
            or IsSpellKnown(264620) -- Northrend
            or IsSpellKnown(264628) -- Legion
            or IsSpellKnown(264630) -- Kul Tiran
            or IsSpellKnown(423343) -- Khaz Algar
            or IsSpellKnown(366258) -- Dragon Isle
            or IsSpellKnown(264626) -- Draenor
            or IsSpellKnown(264622) -- Cataclysm

    local archaeology = IsSpellKnown(80451) -- Survey

    local cooking = IsSpellKnown(818) -- Cooking fire 
            or IsSpellKnown(2550) -- Vanilla

    local firstAid = IsSpellKnown(3273) or IsSpellKnown(3274) or IsSpellKnown(7924) or IsSpellKnown(10846) or IsSpellKnown(27028) or IsSpellKnown(45542)

    local fishing = IsSpellKnown(7620) or IsSpellKnown(7731) or IsSpellKnown(7732) or IsSpellKnown(18248) or IsSpellKnown(131474)
            or IsSpellKnown(271990) -- Vanilla
            or IsSpellKnown(271677) -- Zandalari
            or IsSpellKnown(310675) -- Shadowlands
            or IsSpellKnown(271662) -- Pandaria
            or IsSpellKnown(271656) -- Outland
            or IsSpellKnown(271658) -- Northrend
            or IsSpellKnown(271672) -- Legion
            or IsSpellKnown(271675) -- Kul Tiran
            or IsSpellKnown(423336) -- Khaz Algar
            or IsSpellKnown(366253) -- Dragon Isle
            or IsSpellKnown(271664) -- Draenor
            or IsSpellKnown(271660) -- Cataclysm

    if ns.Addon.db.profile.showCapitalsProfessionDetection then

        if alchemy and ns.Addon.db.profile.showCapitalsAlchemy == false then
            ns.Addon.db.profile.showCapitalsAlchemy = true
        end
        if not alchemy then
            ns.Addon.db.profile.showCapitalsAlchemy = false
        end

        if archaeology and ns.Addon.db.profile.showCapitalsArchaeology == false then
            ns.Addon.db.profile.showCapitalsArchaeology = true
        end
        if not archaeology then
            ns.Addon.db.profile.showCapitalsArchaeology = false
        end

        if blacksmith and ns.Addon.db.profile.showCapitalsBlacksmith == false then
            ns.Addon.db.profile.showCapitalsBlacksmith = true
        end
        if not blacksmith then
            ns.Addon.db.profile.showCapitalsBlacksmith = false
        end

        if enchanting and ns.Addon.db.profile.showCapitalsEnchanting == false then
            ns.Addon.db.profile.showCapitalsEnchanting = true
        end
        if not enchanting then
            ns.Addon.db.profile.showCapitalsEnchanting = false
        end

        if engineer and ns.Addon.db.profile.showCapitalsEngineer == false then
            ns.Addon.db.profile.showCapitalsEngineer = true
        end
        if not engineer then
            ns.Addon.db.profile.showCapitalsEngineer = false
        end

        if herbalism and ns.Addon.db.profile.showCapitalsHerbalism == false then
            ns.Addon.db.profile.showCapitalsHerbalism = true
        end
        if not herbalism then
            ns.Addon.db.profile.showCapitalsHerbalism = false
        end

        if inscription and ns.Addon.db.profile.showCapitalsInscription == false then
            ns.Addon.db.profile.showCapitalsInscription = true
        end
        if not inscription then
            ns.Addon.db.profile.showCapitalsInscription = false
        end

        if jewelcrafting and ns.Addon.db.profile.showCapitalsJewelcrafting == false then
            ns.Addon.db.profile.showCapitalsJewelcrafting = true
        end
        if not jewelcrafting then
            ns.Addon.db.profile.showCapitalsJewelcrafting = false
        end

        if mining and ns.Addon.db.profile.showCapitalsMining == false then
            ns.Addon.db.profile.showCapitalsMining = true
        end
        if not mining then
            ns.Addon.db.profile.showCapitalsMining = false
        end

        if leatherworking and ns.Addon.db.profile.showCapitalsLeatherworking == false then
            ns.Addon.db.profile.showCapitalsLeatherworking = true
        end
        if not leatherworking then
            ns.Addon.db.profile.showCapitalsLeatherworking = false
        end

        if skinning and ns.Addon.db.profile.showCapitalsSkinning == false then
            ns.Addon.db.profile.showCapitalsSkinning = true
        end
        if not skinning then
            ns.Addon.db.profile.showCapitalsSkinning = false
        end

        if tailoring and ns.Addon.db.profile.showCapitalsTailoring == false then
            ns.Addon.db.profile.showCapitalsTailoring = true
        end
        if not tailoring then
            ns.Addon.db.profile.showCapitalsTailoring = false
        end

        if cooking and ns.Addon.db.profile.showCapitalsCooking == false then
            ns.Addon.db.profile.showCapitalsCooking = true
        end
        if not cooking then
            ns.Addon.db.profile.showCapitalsCooking = false
        end

        if firstAid and ns.Addon.db.profile.showCapitalsFirstAid == false then
            ns.Addon.db.profile.showCapitalsFirstAid = true
        end
        if not firstAid then
            ns.Addon.db.profile.showCapitalsFirstAid = false
        end

        if fishing and ns.Addon.db.profile.showCapitalsFishing == false then
            ns.Addon.db.profile.showCapitalsFishing = true
        end
        if not fishing then
            ns.Addon.db.profile.showCapitalsFishing = false
        end

    end


    if ns.Addon.db.profile.showMinimapCapitalsProfessionDetection then

        if alchemy and ns.Addon.db.profile.showMinimapCapitalsAlchemy == false then
            ns.Addon.db.profile.showMinimapCapitalsAlchemy = true
        end
        if not alchemy then
            ns.Addon.db.profile.showMinimapCapitalsAlchemy = false
        end

        if archaeology and ns.Addon.db.profile.showMinimapCapitalsArchaeology == false then
            ns.Addon.db.profile.showMinimapCapitalsArchaeology = true
        end
        if not archaeology then
            ns.Addon.db.profile.showMinimapCapitalsArchaeology = false
        end

        if blacksmith and ns.Addon.db.profile.showMinimapCapitalsBlacksmith == false then
            ns.Addon.db.profile.showMinimapCapitalsBlacksmith = true
        end
        if not blacksmith then
            ns.Addon.db.profile.showMinimapCapitalsBlacksmith = false
        end

        if enchanting and ns.Addon.db.profile.showMinimapCapitalsEnchanting == false then
            ns.Addon.db.profile.showMinimapCapitalsEnchanting = true
        end
        if not enchanting then
            ns.Addon.db.profile.showMinimapCapitalsEnchanting = false
        end

        if engineer and ns.Addon.db.profile.showMinimapCapitalsEngineer == false then
            ns.Addon.db.profile.showMinimapCapitalsEngineer = true
        end
        if not engineer then
            ns.Addon.db.profile.showMinimapCapitalsEngineer = false
        end

        if herbalism and ns.Addon.db.profile.showMinimapCapitalsHerbalism == false then
            ns.Addon.db.profile.showMinimapCapitalsHerbalism = true
        end
        if not herbalism then
            ns.Addon.db.profile.showMinimapCapitalsHerbalism = false
        end

        if inscription and ns.Addon.db.profile.showMinimapCapitalsInscription == false then
            ns.Addon.db.profile.showMinimapCapitalsInscription = true
        end
        if not inscription then
            ns.Addon.db.profile.showMinimapCapitalsInscription = false
        end

        if jewelcrafting and ns.Addon.db.profile.showMinimapCapitalsJewelcrafting == false then
            ns.Addon.db.profile.showMinimapCapitalsJewelcrafting = true
        end
        if not jewelcrafting then
            ns.Addon.db.profile.showMinimapCapitalsJewelcrafting = false
        end

        if mining and ns.Addon.db.profile.showMinimapCapitalsMining == false then
            ns.Addon.db.profile.showMinimapCapitalsMining = true
        end
        if not mining then
            ns.Addon.db.profile.showMinimapCapitalsMining = false
        end

        if leatherworking and ns.Addon.db.profile.showMinimapCapitalsLeatherworking == false then
            ns.Addon.db.profile.showMinimapCapitalsLeatherworking = true
        end
        if not leatherworking then
            ns.Addon.db.profile.showMinimapCapitalsLeatherworking = false
        end

        if skinning and ns.Addon.db.profile.showMinimapCapitalsSkinning == false then
            ns.Addon.db.profile.showMinimapCapitalsSkinning = true
        end
        if not skinning then
            ns.Addon.db.profile.showMinimapCapitalsSkinning = false
        end

        if tailoring and ns.Addon.db.profile.showMinimapCapitalsTailoring == false then
            ns.Addon.db.profile.showMinimapCapitalsTailoring = true
        end
        if not tailoring then
            ns.Addon.db.profile.showMinimapCapitalsTailoring = false
        end


        if cooking and ns.Addon.db.profile.showMinimapCapitalsCooking == false then
            ns.Addon.db.profile.showMinimapCapitalsCooking = true
        end
        if not cooking then
            ns.Addon.db.profile.showMinimapCapitalsCooking = false
        end


        if firstAid and ns.Addon.db.profile.showMinimapCapitalsFirstAid == false then
            ns.Addon.db.profile.showMinimapCapitalsFirstAid = true
        end
        if not firstAid then
            ns.Addon.db.profile.showMinimapCapitalsFirstAid = false
        end


        if fishing and ns.Addon.db.profile.showMinimapCapitalsFishing == false then
            ns.Addon.db.profile.showMinimapCapitalsFishing = true
        end
        if not fishing then
            ns.Addon.db.profile.showMinimapCapitalsFishing = false
        end
        
    end

    if ns.Addon.db.profile.showZoneProfessionDetection then
        
        if alchemy and ns.Addon.db.profile.showZoneAlchemy == false then
            ns.Addon.db.profile.showZoneAlchemy = true
        end
        if not alchemy then
            ns.Addon.db.profile.showZoneAlchemy = false
        end

        if archaeology and ns.Addon.db.profile.showZoneArchaeology == false then
            ns.Addon.db.profile.showZoneArchaeology = true
        end
        if not archaeology then
            ns.Addon.db.profile.showZoneArchaeology = false
        end

        if blacksmith and ns.Addon.db.profile.showZoneBlacksmith == false then
            ns.Addon.db.profile.showZoneBlacksmith = true
        end
        if not blacksmith then
            ns.Addon.db.profile.showZoneBlacksmith = false
        end

        if enchanting and ns.Addon.db.profile.showZoneEnchanting == false then
            ns.Addon.db.profile.showZoneEnchanting = true
        end
        if not enchanting then
            ns.Addon.db.profile.showZoneEnchanting = false
        end

        if engineer and ns.Addon.db.profile.showZoneEngineer == false then
            ns.Addon.db.profile.showZoneEngineer = true
        end
        if not engineer then
            ns.Addon.db.profile.showZoneEngineer = false
        end

        if herbalism and ns.Addon.db.profile.showZoneHerbalism == false then
            ns.Addon.db.profile.showZoneHerbalism = true
        end
        if not herbalism then
            ns.Addon.db.profile.showZoneHerbalism = false
        end

        if inscription and ns.Addon.db.profile.showZoneInscription == false then
            ns.Addon.db.profile.showZoneInscription = true
        end
        if not inscription then
            ns.Addon.db.profile.showZoneInscription = false
        end

        if jewelcrafting and ns.Addon.db.profile.showZoneJewelcrafting == false then
            ns.Addon.db.profile.showZoneJewelcrafting = true
        end
        if not jewelcrafting then
            ns.Addon.db.profile.showZoneJewelcrafting = false
        end

        if mining and ns.Addon.db.profile.showZoneMining == false then
            ns.Addon.db.profile.showZoneMining = true
        end
        if not mining then
            ns.Addon.db.profile.showZoneMining = false
        end

        if leatherworking and ns.Addon.db.profile.showZoneLeatherworking == false then
            ns.Addon.db.profile.showZoneLeatherworking = true
        end
        if not leatherworking then
            ns.Addon.db.profile.showZoneLeatherworking = false
        end

        if skinning and ns.Addon.db.profile.showZoneSkinning == false then
            ns.Addon.db.profile.showZoneSkinning = true
        end
        if not skinning then
            ns.Addon.db.profile.showZoneSkinning = false
        end

        if tailoring and ns.Addon.db.profile.showZoneTailoring == false then
            ns.Addon.db.profile.showZoneTailoring = true
        end
        if not tailoring then
            ns.Addon.db.profile.showZoneTailoring = false
        end

        if cooking and ns.Addon.db.profile.showZoneCooking == false then
            ns.Addon.db.profile.showZoneCooking = true
        end
        if not cooking then
            ns.Addon.db.profile.showZoneCooking = false
        end

        if firstAid and ns.Addon.db.profile.showZoneFirstAid == false then
            ns.Addon.db.profile.showZoneFirstAid = true
        end
        if not firstAid then
            ns.Addon.db.profile.showZoneFirstAid = false
        end

        if fishing and ns.Addon.db.profile.showZoneFishing == false then
            ns.Addon.db.profile.showZoneFishing = true
        end
        if not fishing then
            ns.Addon.db.profile.showZoneFishing = false
        end

    end

    if ns.Addon.db.profile.showMiniMapProfessionDetection then
        
        if alchemy and ns.Addon.db.profile.showMiniMapAlchemy == false then
            ns.Addon.db.profile.showMiniMapAlchemy = true
        end
        if not alchemy then
            ns.Addon.db.profile.showMiniMapAlchemy = false
        end

        if archaeology and ns.Addon.db.profile.showMiniMapArchaeology == false then
            ns.Addon.db.profile.showMiniMapArchaeology = true
        end
        if not archaeology then
            ns.Addon.db.profile.showMiniMapArchaeology = false
        end

        if blacksmith and ns.Addon.db.profile.showMiniMapBlacksmith == false then
            ns.Addon.db.profile.showMiniMapBlacksmith = true
        end
        if not blacksmith then
            ns.Addon.db.profile.showMiniMapBlacksmith = false
        end

        if enchanting and ns.Addon.db.profile.showMiniMapEnchanting == false then
            ns.Addon.db.profile.showMiniMapEnchanting = true
        end
        if not enchanting then
            ns.Addon.db.profile.showMiniMapEnchanting = false
        end

        if engineer and ns.Addon.db.profile.showMiniMapEngineer == false then
            ns.Addon.db.profile.showMiniMapEngineer = true
        end
        if not engineer then
            ns.Addon.db.profile.showMiniMapEngineer = false
        end

        if herbalism and ns.Addon.db.profile.showMiniMapHerbalism == false then
            ns.Addon.db.profile.showMiniMapHerbalism = true
        end
        if not herbalism then
            ns.Addon.db.profile.showMiniMapHerbalism = false
        end

        if inscription and ns.Addon.db.profile.showMiniMapInscription == false then
            ns.Addon.db.profile.showMiniMapInscription = true
        end
        if not inscription then
            ns.Addon.db.profile.showMiniMapInscription = false
        end

        if jewelcrafting and ns.Addon.db.profile.showMiniMapJewelcrafting == false then
            ns.Addon.db.profile.showMiniMapJewelcrafting = true
        end
        if not jewelcrafting then
            ns.Addon.db.profile.showMiniMapJewelcrafting = false
        end

        if mining and ns.Addon.db.profile.showMiniMapMining == false then
            ns.Addon.db.profile.showMiniMapMining = true
        end
        if not mining then
            ns.Addon.db.profile.showMiniMapMining = false
        end

        if leatherworking and ns.Addon.db.profile.showMiniMapLeatherworking == false then
            ns.Addon.db.profile.showMiniMapLeatherworking = true
        end
        if not leatherworking then
            ns.Addon.db.profile.showMiniMapLeatherworking = false
        end

        if skinning and ns.Addon.db.profile.showMiniMapSkinning == false then
            ns.Addon.db.profile.showMiniMapSkinning = true
        end
        if not skinning then
            ns.Addon.db.profile.showMiniMapSkinning = false
        end

        if tailoring and ns.Addon.db.profile.showMiniMapTailoring == false then
            ns.Addon.db.profile.showMiniMapTailoring = true
        end
        if not tailoring then
            ns.Addon.db.profile.showMiniMapTailoring = false
        end

        if cooking and ns.Addon.db.profile.showMiniMapCooking == false then
            ns.Addon.db.profile.showMiniMapCooking = true
        end
        if not cooking then
            ns.Addon.db.profile.showMiniMapCooking = false
        end

        if firstAid and ns.Addon.db.profile.showMiniMapFirstAid == false then
            ns.Addon.db.profile.showMiniMapFirstAid = true
        end
        if not firstAid then
            ns.Addon.db.profile.showMiniMapFirstAid = false
        end

        if fishing and ns.Addon.db.profile.showMiniMapFishing == false then
            ns.Addon.db.profile.showMiniMapFishing = true
        end
        if not fishing then
            ns.Addon.db.profile.showMiniMapFishing = false
        end

    end

    if not ns.Addon.db.profile.showZoneProfessionDetection then
        ns.Addon.db.profile.showZoneAlchemy = true
        ns.Addon.db.profile.showZoneArchaeology = true
        ns.Addon.db.profile.showZoneBlacksmith = true
        ns.Addon.db.profile.showZoneEnchanting = true
        ns.Addon.db.profile.showZoneEngineer = true
        ns.Addon.db.profile.showZoneHerbalism = true
        ns.Addon.db.profile.showZoneInscription = true
        ns.Addon.db.profile.showZoneJewelcrafting = true
        ns.Addon.db.profile.showZoneMining = true
        ns.Addon.db.profile.showZoneLeatherworking = true
        ns.Addon.db.profile.showZoneSkinning = true
        ns.Addon.db.profile.showZoneTailoring = true
        ns.Addon.db.profile.showZoneCooking = true
        ns.Addon.db.profile.showZoneFirstAid = true
        ns.Addon.db.profile.showZoneFishing = true
    end

    ns.Addon:FullUpdate()
    HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
end


local function ProfessionDetectionHook()
    AceTimer:ScheduleTimer(ns.AutomaticProfessionDetection, 0.2)
 end
hooksecurefunc("AbandonSkill", ProfessionDetectionHook)