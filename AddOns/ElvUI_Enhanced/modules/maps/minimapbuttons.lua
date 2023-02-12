local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local EEL = E:GetModule('ElvuiEnhancedAgain')
local MB = E:NewModule('MinimapButtons', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0');
local LO = E:GetModule('Layout')
local Skins = E:GetModule('Skins')
local _G = _G

-- Based on Square Minimap Buttons
-- Original authors: Azilroka, Sinaris
-- Updated for WOD/Legion/BFA/Classic/SL by Tevoll

local sub, len, find = string.sub, string.len, string.find

local ignoreButtons = {
	"AsphyxiaUIMinimapHelpButton",
	"AsphyxiaUIMinimapVersionButton",
	"ElvConfigToggle",
	"ElvUIConfigToggle",
	"ElvUI_ConsolidatedBuffs",
	"HelpOpenTicketButton",
	"MMHolder",
	"DroodFocusMinimapButton",
	"QueueStatusMinimapButton",
	"TimeManagerClockButton",
	"MinimapZoneTextButton",
}

local genericIgnores = {
	"Archy",
	"GatherMatePin",
	"GatherNote",
	"GuildInstance",
	"HandyNotesPin",
	"MinimMap",
	"Spy_MapNoteList_mini",
	"ZGVMarker",
	'poiMinimap',
	'GuildMap3Mini',
	'LibRockConfig-1.0_MinimapButton',
	'NauticusMiniIcon',
	'WestPointer',
	'Cork',
	'DugisArrowMinimapPoint',
}

local partialIgnores = {
	"Node",
	"Note",
	"Pin",
	"POI",
	"Questie",
	"TTMinimapButton",
}

local whiteList = {
	"LibDBIcon",
}

local moveButtons = {}
local minimapButtonBarAnchor, minimapButtonBar



local function OnEnter(self)
	if not E.minimapbuttons.db.mouseover or E.minimapbuttons.db.skinStyle == 'NOANCHOR' then return end
	UIFrameFadeIn(MinimapButtonBar, 0.2, MinimapButtonBar:GetAlpha(), 1)
	if self:GetName() ~= 'MinimapButtonBar' then
		self:SetBackdropBorderColor(.7, .7, 0)
	end
end

local function OnLeave(self)
	if not E.minimapbuttons.db.mouseover or E.minimapbuttons.db.skinStyle == 'NOANCHOR' then return end
	UIFrameFadeOut(MinimapButtonBar, 0.2, MinimapButtonBar:GetAlpha(), 0)
	if self:GetName() ~= 'MinimapButtonBar' then
		self:SetBackdropBorderColor(0, 0, 0)
	end
end

function MB:SkinButton(frame)
	if (not frame) or frame.isSkinned then return end
	if (frame:GetObjectType() ~= "Button") or not frame:IsVisible() then return end

	if not E.minimapbuttons.db.mbcalendar then
		table.insert(ignoreButtons, "GameTimeFrame")
	end

	
	
	local name = frame:GetName()
	if not name then return end
	local validIcon = false
	
	for i = 1, #whiteList do
		if sub(name, 1, len(whiteList[i])) == whiteList[i] then validIcon = true break end
	end
	
	if not validIcon then
		for i = 1, #ignoreButtons do
			if name == ignoreButtons[i] then return end
		end
		
		for i = 1, #genericIgnores do
			if sub(name, 1, len(genericIgnores[i])) == genericIgnores[i] then return end
		end
		
		for i = 1, #partialIgnores do
			if find(name, partialIgnores[i]) ~= nil then return end
		end
	end
		
	if not frame.isSkinned then
		Mixin(frame, BackdropTemplateMixin)
		frame:HookScript('OnEnter', OnEnter)
		frame:HookScript('OnLeave', OnLeave)
		frame:HookScript('OnClick', MB.DelayedUpdateLayout)

		for i = 1, frame:GetNumRegions() do
			local region = select(i, frame:GetRegions())
			
			frame.original = {}
			frame.original.Width, frame.original.Height = frame:GetSize()
			frame.original.Point, frame.original.relativeTo, frame.original.relativePoint, frame.original.xOfs, frame.original.yOfs = frame:GetPoint()
			frame.original.Parent = frame:GetParent()
			frame.original.FrameStrata = frame:GetFrameStrata()
			frame.original.FrameLevel = frame:GetFrameLevel()
			frame.original.Scale = frame:GetScale()

			if frame:HasScript("OnDragStart") then
				frame.original.DragStart = frame:GetScript("OnDragStart")
			end
			if frame:HasScript("OnDragStop") then
				frame.original.DragEnd = frame:GetScript("OnDragStop")
			end

			if (region:GetObjectType() == "Texture") then	
				local texture = region.GetTextureFileID and region:GetTextureFileID()
				if not texture then
					texture = strlower(tostring(region:GetTexture()))
				end

				if (texture and (type(texture) == "number" and (texture == 136477 or texture == 136430 or texture == 136467 or texture == 136468 or texture == 130924))) then
					region:SetTexture(nil)
				elseif (texture and (type(texture) ~= "number" and (texture:find("Border") or texture:find("Background") or texture:find("AlphaMask") or texture:find("highlight") or texture:find("interface/characterframe")))) then	
					region:SetTexture(nil)
				else

					if name == "DBMMinimapButton" then frame:SetNormalTexture("Interface\\Icons\\INV_Helmet_87") end
					if name == "SmartBuff_MiniMapButton" then frame:SetNormalTexture(select(3, GetSpellInfo(12051))) end
					if name == "GRM_MinimapButton" then frame.GRM_MinimapButtonBorder:Hide() end

					region:ClearAllPoints()
					region:Point("TOPLEFT", frame, "TOPLEFT", 2, -2)
					region:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 2)
					region:SetTexCoord( 0.1, 0.9, 0.1, 0.9 )
					region:SetDrawLayer( "ARTWORK" )

					region.SetPoint = function() return end
				end
			end
		end
		frame:SetTemplate("Tranparent")

		tinsert(moveButtons, name)
		frame.isSkinned = true
	end
end

function MB:DelayedUpdateLayout()
	if E.minimapbuttons.db.skinStyle ~= 'NOANCHOR' then
		MB:ScheduleTimer("UpdateLayout", .05)
	end
end

function MB:UpdateSkinStyle()
	local doreload = 0
	if E.minimapbuttons.db.skinStyle == 'NOANCHOR' then 
		if E.minimapbuttons.db.mbgarrison then
			E.minimapbuttons.db.mbgarrison = false
			doreload = 1
		end
		if E.minimapbuttons.db.mbcalendar then 
			E.minimapbuttons.db.mbcalendar = false
			doreload = 1
		end
		if doreload == 1 then
			E:StaticPopup_Show("CONFIG_RL")
		else 
			self:UpdateLayout()
		end
	else
		self:UpdateLayout()
	end
end

function MB:UpdateLayout()
	if not E.minimapbuttons then return end
	if InCombatLockdown() then
		MB:RegisterEvent("PLAYER_REGEN_ENABLED", "UpdateLayout")	
		return
	else
		MB:UnregisterEvent("PLAYER_REGEN_ENABLED")
 	end

	local AnchorX, AnchorY, MaxX = 0, 1, E.minimapbuttons.db.buttonsPerRow
	local ButtonsPerRow = E.minimapbuttons.db.buttonsPerRow
	local NumColumns = ceil(#moveButtons / ButtonsPerRow)
	local Spacing, Mult = 2, 1
	local Size = E.minimapbuttons.db.buttonSize
	local ActualButtons, Maxed = 0
	local direction = E.minimapbuttons.db.layoutDirection == 'NORMAL'
	local offset = direction and -2 or 2

	if NumColumns == 1 and ButtonsPerRow > #moveButtons then
		ButtonsPerRow = #moveButtons
	end

	if E.minimapbuttons.db.skinStyle == 'HORIZONTAL' then
		minimapButtonBar:SetPoint(direction and 'LEFT' or 'RIGHT', minimapButtonBarAnchor, direction and 'LEFT' or 'RIGHT', -2, 0)
	else
		minimapButtonBar:SetPoint(direction and 'TOP' or 'BOTTOM', minimapButtonBarAnchor, direction and 'TOP' or 'BOTTOM', -2, 0)
	end
	minimapButtonBar:SetSize(E.minimapbuttons.db.buttonSize + 4, E.minimapbuttons.db.buttonSize + 4)
	
	local lastFrame, anchor1, anchor2, offsetX, offsetY
	
	for i = 1, #moveButtons do
		local frame =	_G[moveButtons[i]]
		AnchorX = AnchorX + 1
		ActualButtons = ActualButtons + 1
		if AnchorX > MaxX then
			AnchorY = AnchorY + 1
			AnchorX = 1
			Maxed = true
		end

		if E.minimapbuttons.db.skinStyle == 'NOANCHOR' then
			frame:SetParent(frame.original.Parent)
			if frame.original.DragStart then
				frame:SetScript("OnDragStart", frame.original.DragStart)
			end
			if frame.original.DragEnd then
				frame:SetScript("OnDragStop", frame.original.DragEnd)
			end
			frame:ClearAllPoints()
			frame:SetSize(frame.original.Width, frame.original.Height)

			if frame.original.Point ~= nil then
				frame:SetPoint(frame.original.Point, frame.original.relativeTo, frame.original.relativePoint, frame.original.xOfs, frame.original.yOfs)
			else
				frame:SetPoint("CENTER", Minimap, "CENTER", -80, -34)
			end
			frame:SetFrameStrata(frame.original.FrameStrata)
			frame:SetFrameLevel(frame.original.FrameLevel)
			frame:SetScale(frame.original.Scale)
			frame:SetMovable(true)
		else
			frame:SetParent(minimapButtonBar)
			frame:SetMovable(false)
			frame:SetIgnoreParentScale(false)
			frame:SetScript("OnDragStart", nil)
			frame:SetScript("OnDragStop", nil)
			
			frame:ClearAllPoints()
			frame:SetFrameStrata("MEDIUM")
			frame:SetFrameLevel(20)
			frame:Size(E.minimapbuttons.db.buttonSize)

			if E.minimapbuttons.db.skinStyle == 'HORIZONTAL' then
				anchor1 = direction and 'TOPLEFT' or 'TOPRIGHT'
				anchor2 = direction and 'TOPRIGHT' or 'TOPLEFT'
				offsetX = direction and (Spacing + ((Size + Spacing) * (AnchorX - 1))) or (- (Spacing + ((Size + Spacing) * (AnchorX - 1))))
				offsetY = (- Spacing - ((Size + Spacing) * (AnchorY - 1)))
			else
				anchor1 = direction and 'BOTTOMRIGHT' or 'TOPRIGHT'
				anchor2 = direction and 'TOPRIGHT' or 'BOTTOMRIGHT'
				offsetX = (- ((Size + Spacing) * (AnchorY - 1)))
				offsetY = direction and (Spacing + ((Size + Spacing) * (AnchorX - 1))) or (- (Spacing + ((Size + Spacing) * (AnchorX - 1))))
			end
			frame:SetPoint(anchor1, minimapButtonBar, anchor1, offsetX, offsetY)
			if Maxed then ActualButtons = ButtonsPerRow end

		end

	end
	
	if E.minimapbuttons.db.skinStyle ~= 'NOANCHOR' and #moveButtons > 0 then
		if E.minimapbuttons.db.skinStyle == "HORIZONTAL" then
			local BarWidth = (Spacing + ((Size * (ActualButtons * Mult)) + ((Spacing * (ActualButtons - 1)) * Mult) + (Spacing * Mult)))
			local BarHeight = (Spacing + ((Size * (AnchorY * Mult)) + ((Spacing * (AnchorY - 1)) * Mult) + (Spacing * Mult)))
			minimapButtonBar:SetSize(BarWidth, BarHeight)
		else
			local BarWidth = (Spacing + ((Size * (AnchorY * Mult)) + ((Spacing * (AnchorY - 1)) * Mult) + (Spacing * Mult)))
			local BarHeight = (Spacing + ((Size * (ActualButtons * Mult)) + ((Spacing * (ActualButtons - 1)) * Mult) + (Spacing * Mult)))
			minimapButtonBar:SetSize(BarWidth, BarHeight)
		end
		minimapButtonBarAnchor:SetSize(minimapButtonBar:GetSize())
		minimapButtonBar:Show()
		RegisterStateDriver(minimapButtonBar, "visibility", '[petbattle]hide;show')
	else
		UnregisterStateDriver(minimapButtonBar, "visibility")
		minimapButtonBar:Hide()
	end
	
	if E.minimapbuttons.db.backdrop then
		minimapButtonBar.backdrop:Show()
	else
		minimapButtonBar.backdrop:Hide()
	end
end

function MB:ChangeMouseOverSetting()
	if E.minimapbuttons.db.mouseover then
		minimapButtonBar:SetAlpha(0)
	else
		minimapButtonBar:SetAlpha(1)
	end
end

function MB:SkinMinimapButtons()
	MB:RegisterEvent("ADDON_LOADED", "StartSkinning")

	if _G['WIM3MinimapButton'] then
		_G['WIM3MinimapButton']:SetParent(Minimap)
	end

	for i = 1, Minimap:GetNumChildren() do
		self:SkinButton(select(i, Minimap:GetChildren()))
	end

	MB:UpdateLayout()
end

function MB:StartSkinning()
	MB:UnregisterEvent("ADDON_LOADED")

	MB:ScheduleTimer("SkinMinimapButtons", 6)
end

function MB:CreateFrames()
	minimapButtonBarAnchor = CreateFrame("Frame", "MinimapButtonBarAnchor", E.UIParent, 'BackdropTemplate')
	minimapButtonBarAnchor:Point('BOTTOM', Minimap, 'BOTTOMRIGHT', 0, -E.mult -54)
	minimapButtonBarAnchor:Size(200, 32)
	minimapButtonBarAnchor:SetFrameStrata("BACKGROUND")

	E:CreateMover(minimapButtonBarAnchor, "MinimapButtonAnchor", L["Minimap Button Bar"], nil, nil, nil, "ALL,ACTIONBARS,ELVUIEHANCED")

	minimapButtonBar = CreateFrame("Frame", "MinimapButtonBar", E.UIParent, 'BackdropTemplate')
	minimapButtonBar:SetFrameStrata('MEDIUM')
	minimapButtonBar:CreateBackdrop('Transparent')
	minimapButtonBar:SetFrameLevel(2)
	minimapButtonBar:ClearAllPoints()
	minimapButtonBar:SetPoint("CENTER", minimapButtonBarAnchor, "CENTER", 0, 0)
	minimapButtonBar:SetScript("OnEnter", OnEnter)
	minimapButtonBar:SetScript("OnLeave", OnLeave)
	minimapButtonBar.backdrop:SetAllPoints()
	self:ChangeMouseOverSetting()
	self:SkinMinimapButtons()
end

function MB:Initialize()
	if not EEL.initialized or not E.db.eel.minimap.minimapbar.enable then return end
	E.minimapbuttons = MB
	E.minimapbuttons.db = E.db.eel.minimap.minimapbar
	
	self:CreateFrames()
end

E:RegisterModule(MB:GetName())
