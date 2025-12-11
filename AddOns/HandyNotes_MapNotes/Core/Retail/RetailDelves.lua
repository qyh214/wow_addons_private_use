local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

ns.DelveContinent = CreateFromMixins(CVarMapCanvasDataProviderMixin, AreaPOIDataProviderMixin)
ns.DelveContinent:Init("showContinentDelvesOnMapNotes")

function ns.BlizzardDelvesAddTT()
    if ns.BlizzDelveTT_Hooked then return end
    ns.BlizzDelveTT_Hooked = true

    hooksecurefunc(DelveEntrancePinMixin, "OnMouseEnter", function(self)
        if not ns.Addon.db.profile.activate.HideMapNote then
            if ns.Addon.db.profile.activate.ToggleMap then
                GameTooltip:AddDoubleLine(TextIconMNL4:GetIconString() .. " " .. "|cff00ff00" .. "< " .. KEY_BUTTON3 .. " " .. L["to show delve map"] .. " > " .. TextIconMNL4:GetIconString(), nil, nil, false)
                GameTooltip:Show()
            else
                if ns.Addon.db.profile.activate.ToggleMapInfo and WorldMapFrame:IsShown() then
                    GameTooltip:AddDoubleLine(TextIconInfo:GetIconString() .. "|cff00ff00 " .. L["Toggle Maps function is disabled"], nil, nil, false)
                    GameTooltip:Show()
                end
            end
        end
    end)
end

function ns.BlizzardDelvesAddFunction()
    if ns.BlizzDelveClick_Hooked then return end
    ns.BlizzDelveClick_Hooked = true

    hooksecurefunc(DelveEntrancePinMixin, "OnClick", function(self, button)
        ns.BlizzDelveIDs = ns.BlizzDelveAreaPoisInfoIDs[self.poiInfo.areaPoiID] or ns.BlizzBountifulDelveAreaPoisInfoIDs[self.poiInfo.areaPoiID]
        if button == "MiddleButton" and not ns.Addon.db.profile.activate.HideMapNote then
            if ns.BlizzDelveIDs then
                ns.MapNotesOpenMap(ns.BlizzDelveIDs)
            end
        end
    end)
end

EventUtil.ContinueOnAddOnLoaded("Blizzard_WorldMap", function()
    pcall(function() ns.BlizzardDelvesAddTT() end)
    pcall(function() ns.BlizzardDelvesAddFunction() end)
end)

function ns.DelveContinent:OnShow()
    if CVarMapCanvasDataProviderMixin.OnShow then
        CVarMapCanvasDataProviderMixin.OnShow(self)
    end
    if AreaPOIDataProviderMixin.OnShow then
        AreaPOIDataProviderMixin.OnShow(self)
    end

    self:RefreshAllData()
end

function ns.DelveContinent:OnHide()
    if CVarMapCanvasDataProviderMixin.OnHide then
        CVarMapCanvasDataProviderMixin.OnHide(self)
    end
    if AreaPOIDataProviderMixin.OnHide then
        AreaPOIDataProviderMixin.OnHide(self)
    end
end

function ns.DelveContinent:OnEvent(event, ...)
    if CVarMapCanvasDataProviderMixin.OnEvent then
        CVarMapCanvasDataProviderMixin.OnEvent(self, event, ...)
    end
    if AreaPOIDataProviderMixin.OnEvent then
        AreaPOIDataProviderMixin.OnEvent(self, event, ...)
    end
end

function ns.DelveContinent:OnMapChanged()
    self:RefreshAllData()
end

local function ConvertMapCoords(fromMapID, toMapID, x, y)
    local minX, maxX, minY, maxY = C_Map.GetMapRectOnMap(fromMapID, toMapID)
    if not minX then return end
    return Lerp(minX, maxX, x), Lerp(minY, maxY, y)
end

function ns.DelveContinent:RemoveAllData()
    local map = self:GetMap()
    if not map then return end
    map:RemoveAllPinsByTemplate("MapNotesContinentDelvePinTemplate")
end

function ns.DelveContinent:RefreshAllData()
    self:RemoveAllData()

    if ns.Addon.db.profile.activate.HideMapNote then
        return
    end

    if not self:IsCVarSet() or InCombatLockdown() then
        return
    end

    local map = self:GetMap()
    if not map then return end

    local mapID = map:GetMapID()
    local mapInfo = C_Map.GetMapInfo(mapID)
    if not (mapInfo and mapInfo.mapType == Enum.UIMapType.Continent) then
        return
    end

    if not (ns.Addon.db.profile.showContinentDelves and ns.Addon.db.profile.showContinentKhazAlgar) then
        return
    end

    for _, child in ipairs(C_Map.GetMapChildrenInfo(mapID, nil, true) or {}) do

        if child and child.mapID then
        local minX = C_Map.GetMapRectOnMap(child.mapID, mapID)
        if minX then
            self:ProjectDelves(mapID, child.mapID)
        end
        end
    end
end

function ns.DelveContinent:IsCVarSet()
    return not ns.Addon.db.profile.activate.HideMapNote and ns.Addon.db.profile.showContinentDelves and ns.Addon.db.profile.showContinentKhazAlgar
end

function ns.DelveContinent:ProjectDelves(parentMapID, zoneMapID)
    local delves = C_AreaPoiInfo.GetDelvesForMap(zoneMapID) or {}
    for _, delveID in ipairs(delves) do
        local info = C_AreaPoiInfo.GetAreaPOIInfo(zoneMapID, delveID)
        if info and info.position then
            local x, y = info.position:GetXY()
            local newX, newY = ConvertMapCoords(zoneMapID, parentMapID, x, y)
            if newX and newY and newX >= 0 and newX <= 1 and newY >= 0 and newY <= 1 then
            info.position:SetXY(newX, newY)
            info.dataProvider = self
            local map = self:GetMap()
                if map then
                    map:AcquirePin("MapNotesContinentDelvePinTemplate", info)
                end
            end
        end
    end
end

EventUtil.ContinueOnAddOnLoaded("Blizzard_WorldMap", function()
    if ns.DelveProviderAdded then return end
    ns.DelveProviderAdded = true

    local provider = CreateFromMixins(ns.DelveContinent)
    WorldMapFrame:AddDataProvider(provider)

    ns.DelveProvider = provider

    if WorldMapFrame:IsShown() and provider.GetMap and provider:GetMap() then
        provider:RefreshAllData()
    end

    if not ns.DelveShowHooked then
        ns.DelveShowHooked = true
        hooksecurefunc(WorldMapFrame, "Show", function(self)
            C_Timer.After(0, function()
                if ns.DelveProvider and ns.DelveProvider.GetMap and ns.DelveProvider:GetMap() and ns.DelveProvider.RefreshAllData then
                    ns.DelveProvider:RefreshAllData()
                end
            end)
        end)
    end
end)

function ns.RefreshContinentDelvesPins(opts)
    if not ns.DelveProvider or not ns.DelveProvider.GetMap then return end
    if not ns.DelveProvider:GetMap() then return end

    if opts and opts.remove then
        ns.DelveProvider:RemoveAllData()
    else
        ns.DelveProvider:RefreshAllData()
    end
end