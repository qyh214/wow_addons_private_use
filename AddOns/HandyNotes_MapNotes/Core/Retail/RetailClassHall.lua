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
    local uiMapID = map and map.GetMapID and map:GetMapID()
    local poiID = self and (self.areaPoiID or (self.poiInfo and self.poiInfo.areaPoiID))
    return uiMapID, poiID
end

local function GetDest(self)
    local uiMapID, poiID = ResolvePOI(self)
    local t = uiMapID and ns.AreaPOI_ClassHallTarget[uiMapID]
    return (t and poiID and t[poiID]) or nil, uiMapID, poiID
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
end)