--- Kaliel's Tracker
--- Copyright (c) 2012-2016, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

local addonName, KT = ...
local M = KT:NewModule(addonName.."_AddonPetTracker")
KT.AddonPetTracker = M

local _DBG = function(...) if _DBG then _DBG("KT", ...) end end

-- Lua API
local floor = math.floor
local round = function(n) return floor(n + 0.5) end

local paddingBottom = 15

local db
local OTF = ObjectiveTrackerFrame

local eventFrame

--------------
-- Internal --
--------------

local function SetHooks()
	PetTracker.Objectives.Header:SetParent(OTF.BlocksFrame)
	PetTracker.Objectives.Anchor:SetParent(OTF.BlocksFrame)
	PetTracker.Objectives.Anchor:SetPoint("TOPLEFT", PetTracker.Objectives.Header, "BOTTOMLEFT", -1, -10)

	local LPJ = LibStub("LibPetJournal-2.0")
	LPJ.RegisterCallback(PetTracker.Objectives, "PetListUpdated", function()
		local numPets = C_PetJournal.GetNumPets()
		if numPets > 0 then
			ObjectiveTracker_Update()
			LPJ.UnregisterCallback(PetTracker.Objectives, "PetListUpdated")
		end
	end)

	local bck_PetTracker_Objectives_TrackingChanged = PetTracker.Objectives.TrackingChanged
	function PetTracker.Objectives:TrackingChanged()
		if not PetTracker.Sets.HideTracker then
			_DBG(" - PT Update ... "..self.maxEntries)
			self.maxEntries = 100
			bck_PetTracker_Objectives_TrackingChanged(self)
			self.maxEntries = self:Count()
			self.maxEntries = self.maxEntries > 0 and self.maxEntries + 1 or 0
			_DBG("    maxEntries = "..self.maxEntries)
			self.Header:SetShown(self.Anchor:IsShown())
		end
	end
	
	-- Replace original function!
	function PetTracker.Objectives:GetUsedHeight()
		local mod = KT:IsTrackerEmpty(true) and 0 or paddingBottom + 1
		-- Bonus objectives - problem with order of events
		if KT.animTask or KT.activeTask > 0 then
			mod = mod + BONUS_OBJECTIVE_TRACKER_MODULE.blockPadding
		end
		return OTF.BlocksFrame.contentsHeight + mod
	end
	
	-- Replace original function!
	function PetTracker.Tracker:AddSpecie(specie, quality, level)
		local Journal = PetTracker.Journal
		local sourceIcon = Journal:GetSourceIcon(specie)
		if sourceIcon then
			-- original code
			local name, icon = Journal:GetInfo(specie)
			local r,g,b = self:GetColor(quality)
			local line = self:NewLine()
			line.Text:SetText(name .. (level > 0 and format(' (%s)', level) or ''))
			line.Text:SetWidth(self.Anchor:GetWidth())
			line.SubIcon:SetTexture(sourceIcon)
			line.Icon:SetTexture(icon)
			line:SetScript('OnClick', function()
				Journal:Display(specie)
			end)
			line:SetScript('OnEnter', function()
				line.Text:SetTextColor(r, g, b)
			end)
			line:SetScript('OnLeave', function()
				line.Text:SetTextColor(r-.2, g-.2, b-.2)
			end)
			line:GetScript('OnLeave')(line)
			-- added code
			line.Text:SetFont(KT.font, db.fontSize, db.fontFlag)
			line.Text:SetShadowColor(0, 0, 0, db.fontShadow)
			line.Text:ClearAllPoints()
			line.Text:SetPoint("LEFT", line.Icon, "RIGHT", 10, 0)
			line:SetParent(OTF.BlocksFrame)
		end
	end

	hooksecurefunc(PetTracker, "ForAllModules", function(self, event, ...)
		if event == "TrackingChanged" then
			if ACHIEVEMENT_TRACKER_MODULE.hasSkippedBlocks then		-- fix - init achievements only
				ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_MODULE_ACHIEVEMENT)
			else
				KT:SetSize()
			end
			KT:ToggleEmptyTracker()
		end				
	end)
	
	-- Disable DropDown (it's moved to filters menu)
	PetTracker.Tracker.ShowOptions = function() end
	
	-- Sushi Lib - hack - revert back DropDownMenu
	-- Replace original functions!
	if SushiDropFrame then
		local Drop = CreateFrame("Frame", "SushiDropDownFrameFix", nil, "UIDropDownMenuTemplate")
		function Drop:AddLine(data)
			UIDropDownMenu_AddButton(data)
		end
		function SushiDropFrame:Toggle(...)
			local n = select("#", ...)
			if n < 4 then
				Drop.relativeTo = ...
			else
				Drop.point, Drop.relativeTo, Drop.relativePoint, Drop.xOffset, Drop.yOffset = ...
				if Drop.yOffset < 0 then
					Drop.yOffset = Drop.yOffset + 10
				else
					Drop.yOffset = Drop.yOffset - 10
				end
			end
			Drop.initialize = select(n, ...)
			Drop.displayMode = "MENU"
			if self.target ~= Drop.relativeTo then
				CloseDropDownMenus()
			end
			self.target = Drop.relativeTo
			ToggleDropDownMenu(1, nil, Drop)
		end
		function SushiDropFrame:Display(...)
			self.target = nil
			self:Toggle(...)
		end
		SushiDropFrame.CloseAll = function() end
	end
end

local function SetHooks_PetTracker_Journal()
	if not db.addonPetTracker and PetTracker then
		PetTrackerTrackToggle:Disable()
		PetTrackerTrackToggle.Text:SetTextColor(0.5, 0.5, 0.5)
		local infoFrame = CreateFrame("Frame", nil, PetJournal)
		infoFrame:SetPoint("TOPLEFT", PetTrackerTrackToggle, 0, 0)
		infoFrame:SetPoint("BOTTOMRIGHT", PetTrackerTrackToggle, PetTrackerTrackToggle.Text:GetWidth() + 3, 3)
		infoFrame:SetFrameLevel(PetTrackerTrackToggle:GetFrameLevel() + 1)
		infoFrame:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
			GameTooltip:AddLine(PetTracker.Locals.ZoneTracker, 1, 1, 1)
			GameTooltip:AddLine("Support can be enabled in addon "..KT.title, 1, 0, 0, true)
			GameTooltip:Show()
		end)
		infoFrame:SetScript("OnLeave", function(self)
			GameTooltip:Hide()
		end)
	else
		PetTrackerTrackToggle:HookScript("OnClick", function()
			if db.collapsed and not PetTracker.Sets.HideTracker then
				ObjectiveTracker_MinimizeButton_OnClick()
			end
		end)

		CollectionsJournal:HookScript("OnHide", function()
			SetMapToCurrentZone()
		end)
	end
end

local function SetHooks_DisabledPetTracker()
	if not db.addonPetTracker and PetTracker then
		PetTracker.Objectives.Startup = function() end
		if IsAddOnLoaded("PetTracker_Journal") then
			SetHooks_PetTracker_Journal()
		end
	end
end

local function SetFrames()
	-- Event frame
	if not eventFrame then
		eventFrame = CreateFrame("Frame")
		eventFrame:SetScript("OnEvent", function(self, event, arg1)
			_DBG("Event - "..event.." - "..(arg1 or ""), true)
			if event == "ADDON_LOADED" and arg1 == "PetTracker_Journal" then
				SetHooks_PetTracker_Journal()
				self:UnregisterEvent(event)
			elseif event == "PLAYER_ENTERING_WORLD" then
				SetHooks()
				KT:SaveHeader(PetTracker.Objectives)
				self:RegisterEvent("PET_JOURNAL_LIST_UPDATE")
				self:UnregisterEvent(event)
			elseif event == "PET_JOURNAL_LIST_UPDATE" then
				M:SetPetsHeaderText()
			end
		end)
	end
	if not IsAddOnLoaded("PetTracker_Journal") then
		eventFrame:RegisterEvent("ADDON_LOADED")
	end
end

--------------
-- External --
--------------

function M:SetPetsHeaderText(reset)
	if self.isLoaded and db.hdrPetTrackerTitleAppend then
		local _, numPetsOwned = C_PetJournal.GetNumPets()
		KT:SetHeaderText(PetTracker.Objectives, numPetsOwned)
	elseif reset then
		KT:SetHeaderText(PetTracker.Objectives)
	end
end

function M:OnInitialize()
	_DBG("|cffffff00Init|r - "..self:GetName(), true)
	db = KT.db.profile
	self.isLoaded = (KT:CheckAddOn("PetTracker", "7.0.1") and db.addonPetTracker)
	SetHooks_DisabledPetTracker()
	SetFrames()
end

function M:OnEnable()
	_DBG("|cff00ff00Enable|r - "..self:GetName(), true)
	eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function M:IsShown()
	return (self.isLoaded and
		not PetTracker.Sets.HideTracker and
		PetTracker.Objectives:IsShown())
end