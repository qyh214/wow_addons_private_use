local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local buildVersion = GetBuildInfo() -- buildVersion == "11.0.7"
local dataProvider
ns.DelveContinent = CreateFromMixins(AreaPOIDataProviderMixin)

function ns.BlizzardDelvesAddTT()
    hooksecurefunc(DelveEntrancePinMixin, "OnMouseEnter", function(self)
        if not ns.Addon.db.profile.activate.ShiftWorld then 
            GameTooltip:AddDoubleLine(TextIconMNL4:GetIconString() .. " " .. "|cff00ff00" .. "< " .. KEY_BUTTON3 .. " " .. L["to show delve map"] .. " > " .. TextIconMNL4:GetIconString(), nil, nil, false)
        end

        if ns.Addon.db.profile.activate.ShiftWorld then 
            GameTooltip:AddDoubleLine(TextIconMNL4:GetIconString() .. " " .. "|cff00ff00" .. "< " .. SHIFT_KEY_TEXT .. " + " .. KEY_BUTTON3 .. " " .. L["to show delve map"] .. " > " .. TextIconMNL4:GetIconString(), nil, nil, false)
        end
        GameTooltip:Show()
    end)
end

function ns.BlizzardDelvesAddFunction()
    hooksecurefunc(DelveEntrancePinMixin, "OnClick", function(self, button)

    ns.BlizzDelveIDs = ns.BlizzDelveAreaPoisInfoIDs[self.poiInfo.areaPoiID] or ns.BlizzBountifulDelveAreaPoisInfoIDs[self.poiInfo.areaPoiID]

    if button == "MiddleButton" and not ns.Addon.db.profile.activate.ShiftWorld then
        if ns.BlizzDelveIDs then
            WorldMapFrame:SetMapID(ns.BlizzDelveIDs)
        end
    end

    if button == "MiddleButton" and IsShiftKeyDown() and ns.Addon.db.profile.activate.ShiftWorld then
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

    for _, mapInfo in ipairs(C_Map.GetMapChildrenInfo(mapID)) do
		if mapInfo.mapType == 3 then
            self:CoCDelves(mapID, mapInfo)
        end
    end

    local CoC = { [2274] = { 2346 } }
    if CoC[mapID] then
		for _, childID in ipairs(CoC[mapID]) do
			self:CoCDelves(mapID, C_Map.GetMapInfo(childID))
		end
	end
end

function ns.DelveContinent:CoCDelves(mapID, mapInfo)
    if not mapInfo then return end
	for _, delveIDs in ipairs(C_AreaPoiInfo.GetDelvesForMap(mapInfo.mapID)) do
		local info = C_AreaPoiInfo.GetAreaPOIInfo(mapInfo.mapID, delveIDs)    
		local minX, maxX, minY, maxY = C_Map.GetMapRectOnMap(mapInfo.mapID, mapID)
        -- https://warcraft.wiki.gg/wiki/API_C_Map.GetMapRectOnMap 
		if info then
			local x, y = info.position:GetXY()
			local LerpX = Lerp(minX, maxX, x)
			local LerpY = Lerp(minY, maxY, y)
			info.position:SetXY(LerpX, LerpY)
			info.dataProvider = self
            if ns.Addon.db.profile.showContinentDelves and ns.Addon.db.profile.showContinentKhazAlgar then
			    self:GetMap():AcquirePin("ContinentDelvePinTemplate", info)
            end
		end
    end

end

function ns.DelveContinent:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate("ContinentDelvePinTemplate")
end

-- https://warcraft.wiki.gg/wiki/FrameXML_functions
EventUtil.ContinueOnAddOnLoaded("Blizzard_WorldMap", function()
	dataProvider = CreateFromMixins(ns.DelveContinent)
	WorldMapFrame:AddDataProvider(dataProvider)
end)