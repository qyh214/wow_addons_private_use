---@type string, Addon
local _, addon = ...
local mini = addon.Core.Framework
local instanceOptions = addon.Core.InstanceOptions
local frames = addon.Core.Frames
local units = addon.Utils.Units
local iconSlotContainer = addon.Core.IconSlotContainer
local UnitAuraWatcher = addon.Core.UnitAuraWatcher
local moduleUtil = addon.Utils.ModuleUtil
local moduleName = addon.Utils.ModuleName
local slotDistribution = addon.Utils.SlotDistribution
local wowEx = addon.Utils.WoWEx
local eventsFrame
local paused = false
local testModeActive = false
---@type table<table, FriendlyIndicatorWatchEntry>
local watchers = {}
---@type TestSpell[]
local testDefensiveSpells = {}
---@type TestSpell[]
local testImportantSpells = {}
---@type TestSpell[]
local testCcSpells = {}
---@type Db
local db

local function GetOptions()
	local m = db.Modules.FriendlyIndicatorModule
	if not m then
		return nil
	end
	return instanceOptions:IsRaid() and m.Raid or m.Default
end

---@class FriendlyIndicatorModule : IModule
local M = {}

addon.Modules.FriendlyIndicatorModule = M

---@class FriendlyIndicatorWatchEntry
---@field Container IconSlotContainer
---@field Watcher Watcher
---@field Anchor table
---@field Unit string

---@class FriendlyIndicatorModuleOptions
---@field ShowDefensives boolean
---@field ShowImportant boolean
---@field ShowCC boolean

---@param entry FriendlyIndicatorWatchEntry
local function UpdateWatcherAuras(entry)
	if not entry or not entry.Watcher or not entry.Container then
		return
	end

	if paused then
		return
	end

	if not entry.Unit then
		return
	end

	if not UnitExists(entry.Unit) then
		for i = 1, entry.Container.Count do
			entry.Container:SetSlotUnused(i)
		end
		return
	end

	local options = GetOptions()
	if not options or not moduleUtil:IsModuleEnabled(moduleName.FriendlyIndicator) then
		return
	end

	-- Cache config options for performance
	local iconsReverse = options.Icons.ReverseCooldown
	local iconsGlow = options.Icons.Glow
	local maxIcons = options.Icons.MaxIcons or 1
	local container = entry.Container
	local colorByDispelType = options.Icons.ColorByDispelType
	local showTooltips = options.ShowTooltips ~= false

	-- Get aura states
	local ccState = entry.Watcher:GetCcState()
	local defensiveState = entry.Watcher:GetDefensiveState()
	local importantState = entry.Watcher:GetImportantState()

	-- Count auras per enabled category
	local ccCount = options.ShowCC and #ccState or 0
	local defensiveCount = options.ShowDefensives and #defensiveState or 0
	local importantCount = options.ShowImportant and #importantState or 0

	-- Distribute slots: CC first, then Defensive, then Important
	local ccSlots, defensiveSlots, importantSlots =
		slotDistribution.Calculate(maxIcons, ccCount, defensiveCount, importantCount)

	local slotIndex = 1

	for i = 1, ccSlots do
		if slotIndex > container.Count then
			break
		end
		local aura = ccState[i]
		container:SetSlot(slotIndex, {
			Texture = aura.SpellIcon,
			DurationObject = aura.DurationObject,
			Alpha = aura.IsCC,
			ReverseCooldown = iconsReverse,
			Glow = iconsGlow,
			Color = colorByDispelType and aura.DispelColor,
			FontScale = db.FontScale,
			SpellId = showTooltips and aura.SpellId or nil,
		})
		slotIndex = slotIndex + 1
	end

	for i = 1, defensiveSlots do
		if slotIndex > container.Count then
			break
		end
		local aura = defensiveState[i]
		container:SetSlot(slotIndex, {
			Texture = aura.SpellIcon,
			DurationObject = aura.DurationObject,
			Alpha = aura.IsDefensive,
			ReverseCooldown = iconsReverse,
			Glow = iconsGlow,
			FontScale = db.FontScale,
			SpellId = showTooltips and aura.SpellId or nil,
		})
		slotIndex = slotIndex + 1
	end

	for i = 1, importantSlots do
		if slotIndex > container.Count then
			break
		end
		local aura = importantState[i]
		container:SetSlot(slotIndex, {
			Texture = aura.SpellIcon,
			DurationObject = aura.DurationObject,
			Alpha = aura.IsImportant,
			ReverseCooldown = iconsReverse,
			Glow = iconsGlow,
			FontScale = db.FontScale,
			SpellId = showTooltips and aura.SpellId or nil,
		})
		slotIndex = slotIndex + 1
	end

	-- Clear any unused slots beyond the aura count
	for i = slotIndex, container.Count do
		container:SetSlotUnused(i)
	end
end

---@param header IconSlotContainer
---@param anchor table
---@param options FriendlyIndicatorInstanceOptions
local function AnchorContainer(header, anchor, options)
	if not options then
		return
	end

	local frame = header.Frame
	frame:ClearAllPoints()
	frame:SetAlpha(1)
	frame:SetFrameStrata(frames:GetNextStrata(anchor:GetFrameStrata()))
	frame:SetFrameLevel(anchor:GetFrameLevel() + 1)

	local anchorPoint = "CENTER"
	local relativeToPoint = "CENTER"

	if options.Grow == "LEFT" then
		anchorPoint = "RIGHT"
		relativeToPoint = "LEFT"
	elseif options.Grow == "RIGHT" then
		anchorPoint = "LEFT"
		relativeToPoint = "RIGHT"
	elseif options.Grow == "DOWN" then
		anchorPoint = "TOP"
		relativeToPoint = "BOTTOM"
	end

	header:SetGrowDown(options.Grow == "DOWN")
	header:SetColumns(nil)
	frame:SetPoint(anchorPoint, anchor, relativeToPoint, options.Offset.X, options.Offset.Y)
end

---@param anchor table
---@param unit string?
local function EnsureWatcher(anchor, unit)
	unit = unit or anchor.unit or anchor:GetAttribute("unit")
	if not unit then
		return nil
	end

	if units:IsCompoundUnit(unit) then
		return nil
	end

	if units:IsPetOrMinion(unit) then
		return nil
	end

	local options = GetOptions()

	if not options then
		return
	end

	local entry = watchers[anchor]

	if not entry then
		local maxIcons = tonumber(options.Icons.MaxIcons) or 1
		local size = tonumber(options.Icons.Size) or 32
		local spacing = db.IconSpacing or 2
		local container = iconSlotContainer:New(UIParent, maxIcons, size, spacing, "Friendly Indicators", nil, "Friendly Indicators")
		local watcher = UnitAuraWatcher:New(unit, nil, { Defensives = true, Important = true, CC = true })

		entry = {
			Container = container,
			Watcher = watcher,
			Anchor = anchor,
			Unit = unit,
		}
		watchers[anchor] = entry

		watcher:RegisterCallback(function()
			UpdateWatcherAuras(entry)
		end)
	else
		-- Check if unit has changed
		if entry.Unit ~= unit then
			-- Unit changed, recreate the watcher
			entry.Watcher:Dispose()
			entry.Watcher = UnitAuraWatcher:New(unit, nil, { Defensives = true, Important = true, CC = true })
			entry.Watcher:RegisterCallback(function()
				UpdateWatcherAuras(entry)
			end)
			entry.Unit = unit

			-- Clear the container since it's a different unit now
			entry.Container:ResetAllSlots()

			-- Force immediate refresh for the new unit
			UpdateWatcherAuras(entry)
		end
	end

	UpdateWatcherAuras(entry)
	AnchorContainer(entry.Container, anchor, options)
	frames:ShowHideFrame(entry.Container.Frame, anchor, testModeActive, options.ExcludePlayer)

	return entry
end

local function EnsureWatchers()
	local anchors = frames:GetAll(true, testModeActive)

	for _, anchor in ipairs(anchors) do
		EnsureWatcher(anchor)
	end
end

local function OnCufUpdateVisible(frame)
	if not frame or not frames:IsFriendlyCuf(frame) then
		return
	end

	local entry = watchers[frame]

	if not entry then
		return
	end

	local options = GetOptions()

	if not options then
		return
	end

	frames:ShowHideFrame(entry.Container.Frame, frame, false, options.ExcludePlayer)
end

local function OnCufSetUnit(frame, unit)
	if not frame or not frames:IsFriendlyCuf(frame) then
		return
	end

	if not unit then
		return
	end

	EnsureWatcher(frame, unit)
end

local function OnFrameSortSorted()
	M:Refresh()
end

local function OnEvent(_, event)
	if event == "GROUP_ROSTER_UPDATE" then
		C_Timer.After(0, function()
			M:Refresh()
		end)
	end
end

local function RefreshTestIcons()
	local options = GetOptions()

	if not options then
		return
	end

	-- ensure predictable ordering for showing the test spell icon on visible entries
	local orderedEntries = {}
	for _, entry in pairs(watchers) do
		if entry.Anchor and entry.Anchor:IsShown() then
			table.insert(orderedEntries, entry)
		end
	end

	local ccCount = options.ShowCC and #testCcSpells or 0
	local defensiveCount = options.ShowDefensives and #testDefensiveSpells or 0
	local importantCount = options.ShowImportant and #testImportantSpells or 0

	for _, entry in ipairs(orderedEntries) do
		local container = entry.Container
		local now = GetTime()
		local maxIcons = options.Icons.MaxIcons or 1
		local iconsReverse = options.Icons.ReverseCooldown
		local iconsGlow = options.Icons.Glow
		local colorByDispelType = options.Icons.ColorByDispelType
		local showTooltips = options.ShowTooltips ~= false

		local ccSlots, defensiveSlots, importantSlots =
			slotDistribution.Calculate(maxIcons, ccCount, defensiveCount, importantCount)

		local slotIndex = 1

		for i = 1, ccSlots do
			if slotIndex > container.Count then
				break
			end
			local spell = testCcSpells[i]
			local texture = C_Spell.GetSpellTexture(spell.SpellId)
			if texture then
				container:SetSlot(slotIndex, {
					Texture = texture,
					DurationObject = wowEx:CreateDuration(now, 15),
					Alpha = true,
					ReverseCooldown = iconsReverse,
					Glow = iconsGlow,
					Color = colorByDispelType and spell.DispelColor,
					FontScale = db.FontScale,
					SpellId = showTooltips and spell.SpellId or nil,
				})
				slotIndex = slotIndex + 1
			end
		end

		for i = 1, defensiveSlots do
			if slotIndex > container.Count then
				break
			end
			local spell = testDefensiveSpells[i]
			local texture = C_Spell.GetSpellTexture(spell.SpellId)
			if texture then
				container:SetSlot(slotIndex, {
					Texture = texture,
					DurationObject = wowEx:CreateDuration(now, 15),
					Alpha = true,
					ReverseCooldown = iconsReverse,
					Glow = iconsGlow,
					FontScale = db.FontScale,
					SpellId = showTooltips and spell.SpellId or nil,
				})
				slotIndex = slotIndex + 1
			end
		end

		for i = 1, importantSlots do
			if slotIndex > container.Count then
				break
			end
			local spell = testImportantSpells[i]
			local texture = C_Spell.GetSpellTexture(spell.SpellId)
			if texture then
				container:SetSlot(slotIndex, {
					Texture = texture,
					DurationObject = wowEx:CreateDuration(now, 15),
					Alpha = true,
					ReverseCooldown = iconsReverse,
					Glow = iconsGlow,
					FontScale = db.FontScale,
					SpellId = showTooltips and spell.SpellId or nil,
				})
				slotIndex = slotIndex + 1
			end
		end

		for i = slotIndex, container.Count do
			container:SetSlotUnused(i)
		end

		AnchorContainer(container, entry.Anchor, options)
		frames:ShowHideFrame(container.Frame, entry.Anchor, true, options.ExcludePlayer)
	end
end

local function Pause()
	paused = true
end

local function Resume()
	paused = false
end

local function DisableWatchers()
	for _, entry in pairs(watchers) do
		if entry.Watcher then
			entry.Watcher:Disable()
		end

		if entry.Container then
			entry.Container:ResetAllSlots()
			entry.Container.Frame:Hide()
		end
	end
end

local function EnableWatchers()
	for _, entry in pairs(watchers) do
		if entry.Watcher then
			entry.Watcher:Enable()
		end
	end
end

function M:Refresh()
	local options = GetOptions()

	if not options then
		return
	end

	local moduleEnabled = moduleUtil:IsModuleEnabled(moduleName.FriendlyIndicator)

	-- If disabled, disable watchers and hide everything
	if not moduleEnabled then
		DisableWatchers()
		return
	end

	-- Module is enabled, ensure watchers are enabled
	EnableWatchers()
	EnsureWatchers()

	for anchor, entry in pairs(watchers) do
		local container = entry.Container
		local iconSize = tonumber(options.Icons.Size) or 32
		local maxIcons = tonumber(options.Icons.MaxIcons) or 1
		container:SetIconSize(iconSize)
		container:SetSpacing(db.IconSpacing or 2)
		container:SetCount(maxIcons)

		if not testModeActive then
			UpdateWatcherAuras(entry)
		end

		AnchorContainer(container, anchor, options)
		frames:ShowHideFrame(container.Frame, anchor, testModeActive, options.ExcludePlayer)
	end

	if testModeActive then
		RefreshTestIcons()
	end
end

function M:StartTesting()
	testModeActive = true
	Pause()

	M:Refresh()
end

function M:StopTesting()
	testModeActive = false

	for _, entry in pairs(watchers) do
		entry.Container:ResetAllSlots()
		entry.Container.Frame:Hide()
	end

	Resume()
	M:Refresh()
end

function M:Init()
	db = mini:GetSavedVars()

	local painSupp = { SpellId = 33206 }
	local blessingOfProtection = { SpellId = 1022 }
	local combustion = { SpellId = 190319 }
	local shadowBlades = { SpellId = 121471 }
	local kidneyShot = { SpellId = 408, DispelColor = DEBUFF_TYPE_NONE_COLOR }
	local fear = { SpellId = 5782, DispelColor = DEBUFF_TYPE_MAGIC_COLOR }
	local hex = { SpellId = 254412, DispelColor = DEBUFF_TYPE_CURSE_COLOR }
	testDefensiveSpells = { painSupp, blessingOfProtection }
	testImportantSpells = { combustion, shadowBlades }
	testCcSpells = { kidneyShot, fear, hex }

	eventsFrame = CreateFrame("Frame")
	eventsFrame:SetScript("OnEvent", OnEvent)
	eventsFrame:RegisterEvent("GROUP_ROSTER_UPDATE")

	if not wowEx:IsDandersEnabled() then
		if CompactUnitFrame_SetUnit then
			hooksecurefunc("CompactUnitFrame_SetUnit", OnCufSetUnit)
		end

		if CompactUnitFrame_UpdateVisible then
			hooksecurefunc("CompactUnitFrame_UpdateVisible", OnCufUpdateVisible)
		end
	end

	local fs = FrameSortApi and FrameSortApi.v3
	if fs and fs.Sorting and fs.Sorting.RegisterPostSortCallback then
		fs.Sorting:RegisterPostSortCallback(OnFrameSortSorted)
	end

	if DandersFrames and DandersFrames.RegisterCallback then
		DandersFrames.RegisterCallback(eventsFrame, "OnFramesSorted", function()
			M:Refresh()
		end)
	end

	frames:HookCellSpotlightVisibility(function()
		if moduleUtil:IsModuleEnabled(moduleName.FriendlyIndicator) then
			EnsureWatchers()
		end
	end)

	frames:HookNDuiVisibility(function()
		if moduleUtil:IsModuleEnabled(moduleName.FriendlyIndicator) then
			EnsureWatchers()
		end
	end)

	local moduleEnabled = moduleUtil:IsModuleEnabled(moduleName.FriendlyIndicator)

	if moduleEnabled then
		EnsureWatchers()
	end
end

---@class FriendlyIndicatorModule
---@field Init fun(self: FriendlyIndicatorModule)
---@field Refresh fun(self: FriendlyIndicatorModule)
---@field StartTesting fun(self: FriendlyIndicatorModule)
---@field StopTesting fun(self: FriendlyIndicatorModule)
