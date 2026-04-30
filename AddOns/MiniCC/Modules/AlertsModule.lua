---@type string, Addon
local _, addon = ...
local mini = addon.Core.Framework
local wowEx = addon.Utils.WoWEx
local unitWatcher = addon.Core.UnitAuraWatcher
local iconSlotContainer = addon.Core.IconSlotContainer
local moduleUtil = addon.Utils.ModuleUtil
local moduleName = addon.Utils.ModuleName
local units = addon.Utils.Units
local testModeActive = false
local paused = false
local inPrepRoom = false
local eventsFrame
local soundFile
---@type Db
local db

---@type table<number, boolean>
local previousImportantAuras = {}
---@type table<number, boolean>
local previousDefensiveAuras = {}
-- Reused each OnAuraDataChanged call to avoid per-frame allocation
---@type table<number, boolean>
local currentImportantAuras = {}
---@type table<number, boolean>
local currentDefensiveAuras = {}
-- Scratch table reused for every SetSlot call in ProcessWatcherData
local slotOptionsScratch = {}
-- Scratch table reused for every class-color lookup in ProcessWatcherData
local colorScratch = { r = 0, g = 0, b = 0, a = 1 }

local hadImportantAlerts = false
local hadDefensiveAlerts = false
local pendingAuraUpdate = false

local cachedVoiceID
local cachedTTSVolume
local cachedTTSSpeechRate
local cachedTTSImportantEnabled
local cachedTTSDefensiveEnabled
---@type IconSlotContainer
local container
---@type Watcher[]
local arenaWatchers
---@type table<string, Watcher>
local nameplateWatchers = {}
---@type Watcher?
local targetWatcher
---@type Watcher?
local focusWatcher

---@class AlertsModule : IModule
local M = {}
addon.Modules.AlertsModule = M

local function PlaySound(spellType)
	local soundConfig
	if spellType == "important" then
		soundConfig = db.Modules.AlertsModule.Sound.Important
	elseif spellType == "defensive" then
		soundConfig = db.Modules.AlertsModule.Sound.Defensive
	else
		return
	end

	if not soundConfig.Enabled then
		return
	end

	local soundFileName = soundConfig.File or "Sonar.ogg"
	soundFile = addon.Config.MediaLocation .. soundFileName
	PlaySoundFile(soundFile, soundConfig.Channel or "Master")
end

local function AnnounceTTS(spellName, spellType)
	if not db.Modules.AlertsModule.TTS then
		return
	end

	if not spellName then
		return
	end

	local enabled = false
	if spellType == "important" and cachedTTSImportantEnabled then
		enabled = true
	elseif spellType == "defensive" and cachedTTSDefensiveEnabled then
		enabled = true
	end

	if not enabled then
		return
	end

	pcall(function()
		local speechRate = cachedTTSSpeechRate or 0
		C_VoiceChat.SpeakText(cachedVoiceID, spellName, speechRate, cachedTTSVolume, true)
	end)
end

local function ProcessWatcherData(watcher, slot, iconsEnabled, iconsGlow, iconsReverse, colorByClass, includeDefensives, showTooltips)
	local unit = watcher:GetUnit()

	-- when units go stealth, we can't get their aura data anymore
	if not unit or not UnitExists(unit) then
		return slot
	end

	local defensivesData = watcher:GetDefensiveState()
	local importantData = watcher:GetImportantState()

	if #importantData == 0 and #defensivesData == 0 then
		return slot
	end

	local color = nil

	-- Get class color if the option is enabled
	if colorByClass then
		local _, class = UnitClass(unit)
		if class then
			local classColor = RAID_CLASS_COLORS and RAID_CLASS_COLORS[class]
			if classColor then
				colorScratch.r = classColor.r
				colorScratch.g = classColor.g
				colorScratch.b = classColor.b
				colorScratch.a = 1
				color = colorScratch
			end
		end
	end

	local fontScale = db.FontScale

	-- Process important spells
	for _, data in ipairs(importantData) do
		if iconsEnabled and slot < container.Count then
			slot = slot + 1
			slotOptionsScratch.Texture = data.SpellIcon
			slotOptionsScratch.DurationObject = data.DurationObject
			slotOptionsScratch.Alpha = data.IsImportant
			slotOptionsScratch.Glow = iconsGlow
			slotOptionsScratch.ReverseCooldown = iconsReverse
			slotOptionsScratch.Color = color
			slotOptionsScratch.FontScale = fontScale
			slotOptionsScratch.SpellId = showTooltips and data.SpellId or nil
			container:SetSlot(slot, slotOptionsScratch)
		end

		-- Track and announce new important auras
		if data.AuraInstanceID then
			currentImportantAuras[data.AuraInstanceID] = true
			if not previousImportantAuras[data.AuraInstanceID] then
				AnnounceTTS(data.SpellName, "important")
			end
		end
	end

	-- Process defensive spells
	for _, data in ipairs(defensivesData) do
		if includeDefensives and iconsEnabled and slot < container.Count then
			slot = slot + 1
			slotOptionsScratch.Texture = data.SpellIcon
			slotOptionsScratch.DurationObject = data.DurationObject
			slotOptionsScratch.Alpha = data.IsDefensive
			slotOptionsScratch.Glow = iconsGlow
			slotOptionsScratch.ReverseCooldown = iconsReverse
			slotOptionsScratch.Color = color
			slotOptionsScratch.FontScale = fontScale
			slotOptionsScratch.SpellId = showTooltips and data.SpellId or nil
			container:SetSlot(slot, slotOptionsScratch)
		end

		-- Track and announce new defensive auras
		if data.AuraInstanceID then
			currentDefensiveAuras[data.AuraInstanceID] = true
			if not previousDefensiveAuras[data.AuraInstanceID] then
				AnnounceTTS(data.SpellName, "defensive")
			end
		end
	end

	return slot
end

local function OnAuraDataChanged()
	if paused then
		return
	end

	if not moduleUtil:IsModuleEnabled(moduleName.Alerts) then
		return
	end

	if inPrepRoom then
		-- don't know why it picks up garbage in the starting room
		container:ResetAllSlots()
		return
	end

	local iconsEnabled = db.Modules.AlertsModule.Icons.Enabled
	local iconsGlow = db.Modules.AlertsModule.Icons.Glow
	local iconsReverse = db.Modules.AlertsModule.Icons.ReverseCooldown
	local colorByClass = db.Modules.AlertsModule.Icons.ColorByClass
	local includeDefensives = db.Modules.AlertsModule.IncludeDefensives
	local showTooltips = db.Modules.AlertsModule.ShowTooltips ~= false
	local slot = 0
	local hasImportantAlerts
	local hasDefensiveAlerts
	local inInstance, instanceType = IsInInstance()

	wipe(currentImportantAuras)
	wipe(currentDefensiveAuras)

	-- Process arena watchers
	if instanceType == "arena" then
		for _, watcher in ipairs(arenaWatchers) do
			slot = ProcessWatcherData(
				watcher,
				slot,
				(slot < container.Count) and iconsEnabled,
				iconsGlow,
				iconsReverse,
				colorByClass,
				includeDefensives,
				showTooltips
			)
		end
	end

	-- Process watchers for World/BG
	if instanceType == "pvp" or not inInstance then
		local targetFocusOnly = db.Modules.AlertsModule.TargetFocusOnly
		if targetFocusOnly then
			-- Process target/focus watchers
			for _, pair in ipairs({ { targetWatcher, "target" }, { focusWatcher, "focus" } }) do
				local watcher, unit = pair[1], pair[2]
				if watcher and UnitExists(unit) and units:IsEnemy(unit) then
					slot = ProcessWatcherData(
						watcher,
						slot,
						(slot < container.Count) and iconsEnabled,
						iconsGlow,
						iconsReverse,
						colorByClass,
						includeDefensives
					)
				end
			end
		else
			-- Process nameplate watchers
			for _, watcher in pairs(nameplateWatchers) do
				slot = ProcessWatcherData(
					watcher,
					slot,
					(slot < container.Count) and iconsEnabled,
					iconsGlow,
					iconsReverse,
					colorByClass,
					includeDefensives
				)
			end
		end
	end

	-- Check if we have alerts for sound playback
	hasImportantAlerts = next(currentImportantAuras) ~= nil
	hasDefensiveAlerts = next(currentDefensiveAuras) ~= nil

	-- Play sound only when transitioning from no alerts to having alerts for each type
	if hasImportantAlerts and not hadImportantAlerts then
		PlaySound("important")
	end

	if hasDefensiveAlerts and not hadDefensiveAlerts then
		PlaySound("defensive")
	end

	hadImportantAlerts = hasImportantAlerts
	hadDefensiveAlerts = hasDefensiveAlerts

	-- Swap buffers: previous gets this frame's data and current gets the old previous table
	-- (which will be wiped at the top of the next call)
	previousImportantAuras, currentImportantAuras = currentImportantAuras, previousImportantAuras
	previousDefensiveAuras, currentDefensiveAuras = currentDefensiveAuras, previousDefensiveAuras

	-- If icons are disabled, keep sounds/TTS logic but don't show anything.
	if not iconsEnabled then
		container:ResetAllSlots()
		return
	end

	-- advance forward by 1 for clearing
	if slot > 0 then
		slot = slot + 1
	end

	if slot == 0 then
		container:ResetAllSlots()
	else
		-- clear any slots above what we used
		for i = slot, container.Count do
			container:SetSlotUnused(i)
		end
	end
end

local function ScheduleAuraDataUpdate()
	if pendingAuraUpdate then
		return
	end
	pendingAuraUpdate = true
	C_Timer.After(0, function()
		pendingAuraUpdate = false
		OnAuraDataChanged()
	end)
end

local function OnMatchStateChanged()
	local matchState = C_PvP.GetActiveMatchState()

	inPrepRoom = matchState == Enum.PvPMatchState.StartUp

	if not inPrepRoom then
		return
	end

	for _, watcher in ipairs(arenaWatchers) do
		watcher:ClearState(true)
	end

	for _, watcher in pairs(nameplateWatchers) do
		watcher:ClearState(true)
	end

	if targetWatcher then
		targetWatcher:ClearState(true)
	end

	if focusWatcher then
		focusWatcher:ClearState(true)
	end

	container:ResetAllSlots()
	hadImportantAlerts = false
	hadDefensiveAlerts = false
	previousImportantAuras = {}
	previousDefensiveAuras = {}
end

local function RefreshTestAlerts()
	if not db.Modules.AlertsModule.Icons.Enabled then
		container:ResetAllSlots()
		return
	end

	local includeDefensives = db.Modules.AlertsModule.IncludeDefensives

	local testAlertSpells = {
		{ spellId = 190319, class = "MAGE" }, -- Combustion
		{ spellId = 121471, class = "ROGUE" }, -- Shadow Blades
		{ spellId = 107574, class = "WARRIOR" }, -- Avatar
		{ spellId = 47788, class = "PRIEST", defensive = true }, -- Guardian Spirit
		{ spellId = 45438, class = "MAGE", defensive = true }, -- Ice Block
	}

	local testAlertSpellIds = {}
	local testClassColors = {}
	for _, entry in ipairs(testAlertSpells) do
		if not entry.defensive or includeDefensives then
			testAlertSpellIds[#testAlertSpellIds + 1] = entry.spellId
			testClassColors[#testClassColors + 1] = entry.class
		end
	end

	local count = math.min(#testAlertSpellIds, container.Count or #testAlertSpellIds)
	local now = GetTime()
	local colorByClass = db.Modules.AlertsModule.Icons.ColorByClass
	local iconsGlow = db.Modules.AlertsModule.Icons.Glow
	local showTooltips = db.Modules.AlertsModule.ShowTooltips ~= false

	for i = 1, count do
		local spellId = testAlertSpellIds[i]
		local tex = C_Spell.GetSpellTexture(spellId)

		if tex then
			local duration = 12 + (i - 1) * 3
			local startTime = now - (i - 1) * 1.25

			local glowColor = nil
			if colorByClass and testClassColors[i] then
				local classColor = RAID_CLASS_COLORS and RAID_CLASS_COLORS[testClassColors[i]]
				if classColor then
					glowColor = { r = classColor.r, g = classColor.g, b = classColor.b, a = 1 }
				end
			end

			container:SetSlot(i, {
				Texture = tex,
				DurationObject = wowEx:CreateDuration(startTime, duration),
				Alpha = true,
				Glow = iconsGlow,
				ReverseCooldown = db.Modules.AlertsModule.Icons.ReverseCooldown,
				Color = glowColor,
				FontScale = db.FontScale,
				SpellId = showTooltips and spellId or nil,
			})
		end
	end

	-- Clear any unused slots beyond test alert count
	for i = count + 1, container.Count do
		container:SetSlotUnused(i)
	end
end

local function OnNamePlateAdded(unitToken)
	-- Clean up any existing watcher for this unit token
	if nameplateWatchers[unitToken] then
		nameplateWatchers[unitToken]:Dispose()
		nameplateWatchers[unitToken] = nil
	end

	-- Only track enemy nameplates
	if not units:IsEnemy(unitToken) then
		return
	end

	---@type AuraTypeFilter
	local watcherFilter = {
		CC = true,
		Defensives = true,
		Important = true,
	}

	local watcher = unitWatcher:New(unitToken, nil, watcherFilter)
	watcher:RegisterCallback(ScheduleAuraDataUpdate)
	nameplateWatchers[unitToken] = watcher

	-- Initial update
	ScheduleAuraDataUpdate()
end

local function OnNamePlateRemoved(unitToken)
	if nameplateWatchers[unitToken] then
		nameplateWatchers[unitToken]:Dispose()
		nameplateWatchers[unitToken] = nil
		ScheduleAuraDataUpdate()
	end
end

local function ClearNamePlateWatchers()
	for unitToken, watcher in pairs(nameplateWatchers) do
		watcher:Dispose()
		nameplateWatchers[unitToken] = nil
	end
end

local function DisableTargetFocusWatchers()
	if targetWatcher then
		targetWatcher:Disable()
	end

	if focusWatcher then
		focusWatcher:Disable()
	end
end

local function EnableTargetFocusWatchers()
	if targetWatcher then
		targetWatcher:Enable()
	end

	if focusWatcher then
		focusWatcher:Enable()
	end
end

local function RebuildNameplateWatchers()
	-- Build a set of currently active enemy unit tokens
	local activeTokens = {}
	for _, nameplate in pairs(C_NamePlate.GetNamePlates()) do
		local unitToken = nameplate.unitToken
		if unitToken and units:IsEnemy(unitToken) then
			activeTokens[unitToken] = true
		end
	end

	-- Remove watchers for tokens that are no longer active
	for unitToken, watcher in pairs(nameplateWatchers) do
		if not activeTokens[unitToken] then
			watcher:Dispose()
			nameplateWatchers[unitToken] = nil
		end
	end

	-- Add watchers for tokens we don't already track
	for unitToken in pairs(activeTokens) do
		if not nameplateWatchers[unitToken] then
			OnNamePlateAdded(unitToken)
		end
	end
end

local function InitTargetFocusWatchers()
	---@type AuraTypeFilter
	local watcherFilter = {
		CC = true,
		Defensives = true,
		Important = true,
	}

	targetWatcher = unitWatcher:New("target", { "PLAYER_TARGET_CHANGED" }, watcherFilter)
	targetWatcher:RegisterCallback(ScheduleAuraDataUpdate)

	focusWatcher = unitWatcher:New("focus", { "PLAYER_FOCUS_CHANGED" }, watcherFilter)
	focusWatcher:RegisterCallback(ScheduleAuraDataUpdate)
end

local function InitArenaWatchers()
	-- Always create watchers with all types
	local watcherFilter = {
		CC = true,
		Defensives = true,
		Important = true,
	}

	local events = {
		"ARENA_OPPONENT_UPDATE",
	}

	arenaWatchers = {
		unitWatcher:New("arena1", events, watcherFilter),
		unitWatcher:New("arena2", events, watcherFilter),
		unitWatcher:New("arena3", events, watcherFilter),
	}

	for _, watcher in ipairs(arenaWatchers) do
		watcher:RegisterCallback(ScheduleAuraDataUpdate)
	end
end

local function DisableWatchers()
	for _, watcher in ipairs(arenaWatchers) do
		watcher:Disable()
	end

	for _, watcher in pairs(nameplateWatchers) do
		watcher:Disable()
	end

	if targetWatcher then
		targetWatcher:Disable()
	end

	if focusWatcher then
		focusWatcher:Disable()
	end

	if container then
		container:ResetAllSlots()
	end
	hadImportantAlerts = false
	hadDefensiveAlerts = false
	previousImportantAuras = {}
	previousDefensiveAuras = {}
end

local function EnableDisable()
	local options = db.Modules.AlertsModule
	local moduleEnabled = moduleUtil:IsModuleEnabled(moduleName.Alerts)

	if not moduleEnabled then
		DisableWatchers()
		return
	end

	local inInstance, instanceType = IsInInstance()

	if instanceType == "arena" then
		-- Enable arena watchers only if in arena
		for _, watcher in ipairs(arenaWatchers) do
			watcher:Enable()
		end
	else
		-- Disable arena watchers if not in arena
		for _, watcher in ipairs(arenaWatchers) do
			watcher:Disable()
		end
	end

	-- Enable watchers (for World/BG)
	if instanceType == "pvp" or not inInstance then
		local targetFocusOnly = options.TargetFocusOnly
		if targetFocusOnly then
			EnableTargetFocusWatchers()
			ClearNamePlateWatchers()
		else
			DisableTargetFocusWatchers()
			RebuildNameplateWatchers()
		end
	else
		-- Disable nameplate and target/focus watchers if not in world/bg
		ClearNamePlateWatchers()
		DisableTargetFocusWatchers()
	end

	ScheduleAuraDataUpdate()
end

local function Pause()
	paused = true
end

local function Resume()
	paused = false
	ScheduleAuraDataUpdate()
end

function M:StartTesting()
	testModeActive = true
	Pause()
	M:Refresh()

	if not container then
		return
	end

	container.Frame:EnableMouse(true)
	container.Frame:SetMovable(true)
end

function M:StopTesting()
	testModeActive = false

	if not container then
		return
	end

	container:ResetAllSlots()
	Resume()

	container.Frame:EnableMouse(false)
	container.Frame:SetMovable(false)
end

function M:Refresh()
	local options = db.Modules.AlertsModule

	cachedVoiceID = wowEx:ResolveVoiceID(options.TTS and options.TTS.VoiceID)
	cachedTTSVolume = options.TTS and options.TTS.Volume or 100
	cachedTTSSpeechRate = options.TTS and options.TTS.SpeechRate or 0
	cachedTTSImportantEnabled = options.TTS and options.TTS.Important and options.TTS.Important.Enabled or false
	cachedTTSDefensiveEnabled = options.TTS and options.TTS.Defensive and options.TTS.Defensive.Enabled or false

	EnableDisable()

	container.Frame:ClearAllPoints()
	container.Frame:SetPoint(
		options.Point,
		_G[options.RelativeTo] or UIParent,
		options.RelativePoint,
		options.Offset.X,
		options.Offset.Y
	)

	container:SetIconSize(options.Icons.Size)
	container:SetSpacing(db.IconSpacing or 2)
	container:SetCount(options.Icons.MaxIcons or 8)

	if testModeActive and moduleUtil:IsModuleEnabled(moduleName.Alerts) then
		RefreshTestAlerts()
	end
end

function M:Init()
	db = mini:GetSavedVars()

	local options = db.Modules.AlertsModule
	local count = options.Icons.MaxIcons or 8
	local size = options.Icons.Size

	cachedVoiceID = wowEx:ResolveVoiceID(options.TTS and options.TTS.VoiceID)
	cachedTTSVolume = options.TTS and options.TTS.Volume or 100
	cachedTTSSpeechRate = options.TTS and options.TTS.SpeechRate or 0
	cachedTTSImportantEnabled = options.TTS and options.TTS.Important and options.TTS.Important.Enabled or false
	cachedTTSDefensiveEnabled = options.TTS and options.TTS.Defensive and options.TTS.Defensive.Enabled or false

	container = iconSlotContainer:New(UIParent, count, size, db.IconSpacing or 2, "Alerts", nil, "Alerts")

	local initialRelativeTo = _G[options.RelativeTo] or UIParent
	container.Frame:SetPoint(
		options.Point,
		initialRelativeTo,
		options.RelativePoint,
		options.Offset.X,
		options.Offset.Y
	)
	container.Frame:SetFrameLevel((initialRelativeTo:GetFrameLevel() or 0) + 5)
	container.Frame:EnableMouse(false)
	container.Frame:SetMovable(false)
	container.Frame:SetClampedToScreen(true)
	container.Frame:RegisterForDrag("LeftButton")
	container.Frame:SetScript("OnDragStart", function(anchorSelf)
		anchorSelf:StartMoving()
	end)
	container.Frame:SetScript("OnDragStop", function(anchorSelf)
		anchorSelf:StopMovingOrSizing()

		local point, relativeTo, relativePoint, x, y = anchorSelf:GetPoint()
		options.Point = point
		options.RelativePoint = relativePoint
		options.RelativeTo = (relativeTo and relativeTo:GetName()) or "UIParent"
		options.Offset.X = x
		options.Offset.Y = y
	end)
	container.Frame:Show()

	InitArenaWatchers()
	InitTargetFocusWatchers()

	eventsFrame = CreateFrame("Frame")
	eventsFrame:RegisterEvent("PVP_MATCH_STATE_CHANGED")
	eventsFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
	eventsFrame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
	eventsFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	eventsFrame:SetScript("OnEvent", function(_, event, unitToken)
		if event == "PVP_MATCH_STATE_CHANGED" then
			OnMatchStateChanged()
		elseif event == "NAME_PLATE_UNIT_ADDED" then
			local moduleEnabled = moduleUtil:IsModuleEnabled(moduleName.Alerts)
			if moduleEnabled then
				local inInstance, instanceType = IsInInstance()
				if instanceType == "pvp" or not inInstance then
					OnNamePlateAdded(unitToken)
				end
			end
		elseif event == "NAME_PLATE_UNIT_REMOVED" then
			OnNamePlateRemoved(unitToken)
		elseif event == "ZONE_CHANGED_NEW_AREA" then
			EnableDisable()
		end
	end)

	EnableDisable()
end
