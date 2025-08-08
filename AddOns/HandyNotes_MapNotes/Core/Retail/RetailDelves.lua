local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local buildVersion = GetBuildInfo() -- buildVersion == "11.0.7"
local dataProvider
ns.DelveContinent = CreateFromMixins(AreaPOIDataProviderMixin)

function ns.BlizzardDelvesAddTT()
    hooksecurefunc(DelveEntrancePinMixin, "OnMouseEnter", function(self)
        if ns.Addon.db.profile.TooltipInformations then
            GameTooltip:AddDoubleLine(TextIconMNL4:GetIconString() .. " " .. "|cff00ff00" .. "< " .. KEY_BUTTON3 .. " " .. L["to show delve map"] .. " > " .. TextIconMNL4:GetIconString(), nil, nil, false)
            GameTooltip:Show()
        end
    end)
end

function ns.BlizzardDelvesAddFunction()
    hooksecurefunc(DelveEntrancePinMixin, "OnClick", function(self, button)

    ns.BlizzDelveIDs = ns.BlizzDelveAreaPoisInfoIDs[self.poiInfo.areaPoiID] or ns.BlizzBountifulDelveAreaPoisInfoIDs[self.poiInfo.areaPoiID]

    if button == "MiddleButton" then
        if ns.BlizzDelveIDs then
            WorldMapFrame:SetMapID(ns.BlizzDelveIDs)
        end
    end

    end)
end

function ns.DelveContinent:RefreshAllData()
    self:RemoveAllData()
    
    local mapID = self:GetMap():GetMapID()
    local mapInfo = C_Map.GetMapInfo(mapID)

    if not (mapInfo and mapInfo.mapType == 2) then
        return
    end

    for _, child in ipairs(C_Map.GetMapChildrenInfo(mapID, nil, true)) do
        if child.mapType == 3 or (child.name and child.name:find("Delve")) then
            self:CoCDelves(mapID, child)
        end
    end
end

function ns.DelveContinent:OnMapChanged()
    self:RefreshAllData()
end

local function ConvertMapCoords(fromMapID, toMapID, x, y)
    local minX, maxX, minY, maxY = C_Map.GetMapRectOnMap(fromMapID, toMapID)
    if not minX then return x, y end
    return Lerp(minX, maxX, x), Lerp(minY, maxY, y)
end

function ns.DelveContinent:CoCDelves(mapID, mapInfo)
    if not mapInfo then return end
    if not (ns.Addon.db.profile.showContinentDelves and ns.Addon.db.profile.showContinentKhazAlgar) then return end
    
    for _, delveID in ipairs(C_AreaPoiInfo.GetDelvesForMap(mapInfo.mapID) or {}) do
        local info = C_AreaPoiInfo.GetAreaPOIInfo(mapInfo.mapID, delveID)
        if info and info.position then
            local x, y = info.position:GetXY()
            local newX, newY = ConvertMapCoords(mapInfo.mapID, mapID, x, y)
            info.position:SetXY(newX, newY)
            info.dataProvider = self
            if newX >= 0 and newX <= 1 and newY >= 0 and newY <= 1 then
                self:GetMap():AcquirePin("MapNotesContinentDelvePinTemplate", info)
            end
        end
    end
end

function ns.DelveContinent:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate("MapNotesContinentDelvePinTemplate")
end

-- https://warcraft.wiki.gg/wiki/FrameXML_functions
EventUtil.ContinueOnAddOnLoaded("Blizzard_WorldMap", function()
	dataProvider = CreateFromMixins(ns.DelveContinent)
	WorldMapFrame:AddDataProvider(dataProvider)
end)