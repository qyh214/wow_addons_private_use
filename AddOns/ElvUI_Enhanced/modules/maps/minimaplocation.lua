local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local EEL = E:GetModule('ElvuiEnhancedAgain')
local M = E:GetModule('Minimap')
local ML = E:NewModule('MinimapLocation', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0');


local init = false
local cluster, panel, location, xMap, yMap
local mmScale = E.db.general.minimap.scale

local digits ={
	[0] = { .5, '%.0f' },
	[1] = { .2, '%.1f' },
	[2] = { .1, '%.2f' },
}

local function UpdateLocation(self, elapsed)
	--if inRestrictedArea then return; end
	
	location.elapsed = (location.elapsed or 0) + elapsed
	if location.elapsed < digits[E.db.eel.minimap.minimapcords.locationdigits][1] then return end

	if E.MapInfo then
		xMap.text:SetFormattedText(digits[E.db.eel.minimap.minimapcords.locationdigits][2], E.MapInfo.xText or 0)
		yMap.text:SetFormattedText(digits[E.db.eel.minimap.minimapcords.locationdigits][2], E.MapInfo.yText or 0)
	else
		xMap.text:SetText("N/A")
		yMap.text:SetText("N/A")
	end

	location.elapsed = 0
end

local function CreateEnhancedMaplocation()
	cluster = _G['MinimapCluster']

	panel = CreateFrame('Frame', 'EnhancedLocationPanel', _G['MinimapCluster'], 'BackdropTemplate')
	panel:SetFrameStrata("BACKGROUND")
	panel:Point("CENTER", M.MapHolder, "CENTER", 0, 0)
	panel:Size(220, 22)

	xMap = CreateFrame('Frame', "MapCoordinatesX", panel, 'BackdropTemplate')
	xMap:SetTemplate('Transparent')
	xMap:Point('LEFT', panel, 'LEFT', 0, 0)
	xMap:Size(36 , 22 / mmScale)
	
	xMap.text = xMap:CreateFontString(nil, "OVERLAY")
	xMap.text:FontTemplate(E.media.font, 12 / mmScale, "OUTLINE")
	xMap.text:SetAllPoints(xMap)

	location = CreateFrame('Frame', "EnhancedLocationText", panel, 'BackdropTemplate')
	location:SetTemplate('Transparent')
	location:Point('CENTER', panel, 'CENTER', 0, 0)
	location:Size(150, 22 / mmScale)
	
	location.text = location:CreateFontString(nil, "OVERLAY")
	location.text:FontTemplate(E.media.font, 12 / mmScale, "OUTLINE")
	location.text:SetAllPoints(location)

	yMap = CreateFrame('Frame', "MapCoordinatesY", panel, 'BackdropTemplate')
	yMap:SetTemplate('Transparent')
	yMap:Point('RIGHT', panel, 'RIGHT', 0, 0)
	yMap:Size(36, 22 / mmScale)

	yMap.text = yMap:CreateFontString(nil, "OVERLAY")
	yMap.text:FontTemplate(E.media.font, 12 / mmScale, "OUTLINE")
	yMap.text:SetAllPoints(yMap)	
end

local function FadeFrame(frame, direction, startAlpha, endAlpha, time, func)
	UIFrameFade(frame, {
		mode = direction,
		finishedFunc = func,
		startAlpha = startAlpha,
		endAlpha = endAlpha,
		timeToFade = time,
	})
end

local function HideMinimap()
	cluster:Hide()
end

local function FadeInMinimap()
	if not InCombatLockdown() then
		FadeFrame(cluster, "IN", 0, 1, .5, function() if not InCombatLockdown() then cluster:Show() end end)
	end
end

local function ShowMinimap()
	if E.private.general.minimap.fadeindelay == 0 then
		FadeInMinimap()		
	else
		E:Delay(E.private.general.minimap.fadeindelay, FadeInMinimap)
	end
end

function ML:CreateFrame()
	if not init then
		init = true
		CreateEnhancedMaplocation()
	end
	
	if E.private.general.minimap.hideincombat then
		M:RegisterEvent("PLAYER_REGEN_DISABLED", HideMinimap)	
		M:RegisterEvent("PLAYER_REGEN_ENABLED", ShowMinimap)
	else
		M:UnregisterEvent("PLAYER_REGEN_DISABLED")	
		M:UnregisterEvent("PLAYER_REGEN_ENABLED")
	end

	--local holder = _G['MMHolder']
	local holder = M.MapHolder
	panel:SetPoint('BOTTOMLEFT', holder, 'TOPLEFT', 0, 0)
	panel:Size(holder:GetWidth() / mmScale, 22 / mmScale) 
	panel:Show()
	location:Width(panel:GetWidth() - 70)

	local point, relativeTo, relativePoint, xOfs, yOfs = holder:GetPoint()

	if E.db.general.minimap.locationText == 'ABOVE' then
		holder:SetPoint(point, relativeTo, relativePoint, 0, -19)
		holder:Height(holder:GetHeight() + 22)
		panel:SetScript('OnUpdate', UpdateLocation)
		panel:Show()
	else
		holder:SetPoint(point, relativeTo, relativePoint, 0, 0)
		panel:SetScript('OnUpdate', nil)
		panel:Hide()
	end	
end

local function StartHooks()
	hooksecurefunc(M, 'UpdateSettings', function()
		if not E.private.general.minimap.enable then return end
		ML:CreateFrame()
	end)

	hooksecurefunc(M, 'Update_ZoneText', function()
		location.text:SetTextColor(M:GetLocTextColor())
		location.text:SetText(strsub(GetMinimapZoneText(),1,25))
	end)
end

function ML:Initialize()
	if not EEL.initialized or not E.db.eel.minimap.minimapcords.enable or not E.private.general.minimap.enable then return end 
	ML:CreateFrame()
	StartHooks()
	location.text:SetTextColor(M:GetLocTextColor())
	location.text:SetText(strsub(GetMinimapZoneText(),1,25))
end

E:RegisterModule(ML:GetName())


