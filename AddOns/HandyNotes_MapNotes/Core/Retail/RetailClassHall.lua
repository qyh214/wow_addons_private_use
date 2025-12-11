-- RetailClassHall.lua (kompakt & bereinigt)
local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

ns.AreaPOI_ClassHallTarget = ns.AreaPOI_ClassHallTarget or {
    [627] = { -- Dalaran (Legion)
        [5102] = 626, -- Rogue -> Hall of Shadows
        [5059] = 726, -- Shaman -> Das Herz der Elemente
        [5058] = 24, -- Paladin -> Kapelle des Hoffnungsvollen Lichts
        [5060] = 695, -- Warrior -> Skyhold
        [5063] = 702, -- Priest -> Netherlight Tempel
    },
    [626] = { -- Dalaran (Legion)
        [5102] = 627, -- Rogue -> Dalaran
    },
    [628] = { -- Dalaran
        [5061] = 717, -- Warlock -> Dreadscar Rift
    },
}

local function ResolvePOI(self)
    local map = self and self.GetMap and self:GetMap()
    local uiMapID = map and map:GetMapID()
    local poiID   = self and (self.areaPoiID or (self.poiInfo and self.poiInfo.areaPoiID))
    return uiMapID, poiID
end

local function GetDest(self)
    local uiMapID, poiID = ResolvePOI(self)
    local t = uiMapID and ns.AreaPOI_ClassHallTarget[uiMapID]
    return (t and poiID and t[poiID]) or nil, uiMapID, poiID
end

local function TooltipHasOurLine(tooltip)
    if not tooltip or not tooltip:IsShown() then return false end
    for i = 1, tooltip:NumLines() do
        local left = _G[tooltip:GetName().."TextLeft"..i]
        local txt = left and left:GetText()
        if txt and txt:find("< Middle Click:") then return true end
    end
    return false
end

local function EnsureTipAndAddLine(self, uiMapID, poiID)
    local tooltip = WorldMapTooltip or GameTooltip
    if not tooltip or not tooltip.SetOwner then return end

    if not tooltip:IsShown() then
        tooltip:SetOwner(self, "ANCHOR_RIGHT")
        tooltip:ClearLines()
        local info = (uiMapID and poiID) and C_AreaPoiInfo.GetAreaPOIInfo(uiMapID, poiID)
        if info and info.name then tooltip:AddLine(info.name, 1, 1, 1, true) end
    end

    if TooltipHasOurLine(tooltip) then return end
    tooltip:AddLine(TextIconMNL4:GetIconString() .. " " .. "|cff00ff00" .. "< " .. KEY_BUTTON3 .. " " .. "to show map" .. " > " .. TextIconMNL4:GetIconString(), nil, nil, false)
    tooltip:Show()
end

EventUtil.ContinueOnAddOnLoaded("Blizzard_WorldMap", function()
    if ns.MN_POI_MixinsHooked then return end
    ns.MN_POI_MixinsHooked = true

    local function ClickHandler(self, button)
        if button ~= "MiddleButton" then return end
        local dest = GetDest(self)
        if dest and not InCombatLockdown() and C_Map.GetMapInfo(dest) then
            ns.MapNotesOpenMap(dest)
        end
    end

    hooksecurefunc(AreaPOIPinMixin, "OnClick", ClickHandler)
    if _G.AreaPOIFramePinMixin then
        hooksecurefunc(AreaPOIFramePinMixin, "OnClick", ClickHandler)
    end

    local function StartStableTooltip(self)
        local dest, uiMapID, poiID = GetDest(self)
        if not dest then return end
        
        if self._mnTtTicker then self._mnTtTicker:Cancel() end
        
        local function tick()
            if not self:IsMouseOver() then
                if self._mnTtTicker then self._mnTtTicker:Cancel(); self._mnTtTicker = nil end
                return
            end
            EnsureTipAndAddLine(self, dest, uiMapID, poiID)
        end
      
        tick()
        self._mnTtTicker = C_Timer.NewTicker(0.2, tick)
    end

    local function StopStableTooltip(self)
        if self._mnTtTicker then self._mnTtTicker:Cancel(); self._mnTtTicker = nil end
    end

    hooksecurefunc(AreaPOIPinMixin, "OnMouseEnter", StartStableTooltip)
    hooksecurefunc(AreaPOIPinMixin, "OnMouseLeave", StopStableTooltip)
    if _G.AreaPOIFramePinMixin then
        hooksecurefunc(AreaPOIFramePinMixin, "OnMouseEnter", StartStableTooltip)
        hooksecurefunc(AreaPOIFramePinMixin, "OnMouseLeave", StopStableTooltip)
    end
end)
