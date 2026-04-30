---@type string, Addon
local _, addon = ...
local mini = addon.Core.Framework
local instanceOptions = addon.Core.InstanceOptions
local frames = addon.Core.Frames
local units = addon.Utils.Units
local iconSlotContainer = addon.Core.IconSlotContainer
local unitAuraWatcher = addon.Core.UnitAuraWatcher
local moduleUtil = addon.Utils.ModuleUtil
local moduleName = addon.Utils.ModuleName
local wowEx = addon.Utils.WoWEx
local eventsFrame
local paused = false
local testModeActive = false
---@type Db
local db

local function GetOptions()
	return instanceOptions:IsRaid() and db.Modules.CCModule.Raid or db.Modules.CCModule.Default
end
---@type table<table, CrowdControlWatchEntry>
local watchers = {}
---@type TestSpell[]
local testSpells = {}

---@class CrowdControlModule : IModule
local M = {}

addon.Modules.CrowdControlModule = M

---@class CrowdControlWatchEntry
---@field Container IconSlotContainer
---@field Watcher Watcher
---@field Anchor table
---@field Unit string

---@param entry CrowdControlWatchEntry
local function UpdateWatcherAuras(entry)
	if not entry or not entry.Watcher or not entry.Container then
		return
	end

	if paused then
		return
	end

	local isPet = units:IsPetOrMinion(entry.Unit)
	local options

	if isPet then
		if not moduleUtil:IsModuleEnabled(moduleName.PetCC) then
			return
		end
		options = db.Modules.PetCCModule
	else
		if not moduleUtil:IsModuleEnabled(moduleName.CrowdControl) then
			return
		end
		options = GetOptions()
	end

	if not options then
		return
	end

	local container = entry.Container
	local ccState = entry.Watcher:GetCcState()
	local slotIndex = 1
	local showTooltips = options.ShowTooltips ~= false

	for _, aura in ipairs(ccState) do
		if slotIndex > container.Count then
			break
		end

		container:SetSlot(slotIndex, {
			Texture = aura.SpellIcon,
			DurationObject = aura.DurationObject,
			Alpha = aura.IsCC,
			ReverseCooldown = options.Icons.ReverseCooldown,
			ShowMilliseconds = options.Icons.ShowMilliseconds,
			Glow = options.Icons.Glow,
			Color = options.Icons.ColorByDispelType and aura.DispelColor,
			FontScale = db.FontScale,
			SpellId = showTooltips and aura.SpellId or nil,
		})
		slotIndex = slotIndex + 1
	end

	for i = slotIndex, container.Count do
		container:SetSlotUnused(i)
	end
end

---@param header IconSlotContainer
---@param anchor table
---@param options CrowdControlInstanceOptions|PetCrowdControlModuleOptions
local function AnchorContainer(header, anchor, options)
	if not options then
		return
	end

	local frame = header.Frame
	frame:ClearAllPoints()
	frame:SetAlpha(1)
	-- plexus frames sit at a MEDIUM frame strata, so we need to be above it
	-- that's the only reason we need this strata code, Blizzard and all other addons don't require this
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
		-- in PvE ignore main tank and assist frames
		-- you can't scan them for auras
		return nil
	end

	local isPet = units:IsPetOrMinion(unit)

	if isPet and not testModeActive and not moduleUtil:IsModuleEnabled(moduleName.PetCC) then
		local existing = watchers[anchor]
		if existing then
			existing.Watcher:Disable()
			existing.Container:ResetAllSlots()
			existing.Container.Frame:Hide()
		end
		return nil
	end

	local memberOptions = GetOptions()
	local petOptions = db.Modules.PetCCModule
	local options = isPet and petOptions or memberOptions

	if not options then
		return
	end

	local entry = watchers[anchor]

	if not entry then
		local count = options.Icons.Count or 5
		local size = tonumber(options.Icons.Size) or (isPet and 24 or 32)
		local spacing = db.IconSpacing or 2
		local container = iconSlotContainer:New(UIParent, count, size, spacing, "CC", nil, "CC")
		local watcher = unitAuraWatcher:New(unit, nil, { CC = true })

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
			entry.Watcher = unitAuraWatcher:New(unit, nil, { CC = true })
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

	frames:ShowHideFrame(entry.Container.Frame, anchor, testModeActive, isPet and false or options.ExcludePlayer)

	return entry
end

local function EnsureWatchers()
	local anchors = frames:GetAll(true, testModeActive)

	for _, anchor in ipairs(anchors) do
		EnsureWatcher(anchor)
	end

	-- Pet frames never appear in GetAll - discover them directly.
	if testModeActive or moduleUtil:IsModuleEnabled(moduleName.PetCC) then
		for i = 1, 6 do
			local frame = _G["CompactPartyFramePet" .. i]
			if frame and (frame:IsVisible() or testModeActive) then
				EnsureWatcher(frame)
			end
		end
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

	local isPet = units:IsPetOrMinion(entry.Unit)

	-- If this is a pet frame and pet CC is disabled, keep it hidden
	if isPet and not moduleUtil:IsModuleEnabled(moduleName.PetCC) then
		entry.Container.Frame:Hide()
		return
	end

	local options = isPet and db.Modules.PetCCModule or GetOptions()

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
		-- wait for frame addons (danders/grid) to update
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

	local moduleEnabled = moduleUtil:IsModuleEnabled(moduleName.CrowdControl)
	local petEnabled = moduleUtil:IsModuleEnabled(moduleName.PetCC)
	local petOptions = db.Modules.PetCCModule

	for anchor, entry in pairs(watchers) do
		local isPet = units:IsPetOrMinion(entry.Unit)
		local entryEnabled
		if isPet then
			entryEnabled = petEnabled
		else
			entryEnabled = moduleEnabled
		end

		if not entryEnabled then
			-- This frame type is disabled - hide and clear it
			entry.Container:ResetAllSlots()
			entry.Container.Frame:Hide()
		else
			local entryOptions = isPet
					and (petOptions or {
						Icons = { ReverseCooldown = false, Glow = false, ColorByDispelType = true },
						Offset = { X = 0, Y = 0 },
						Grow = "CENTER",
					})
				or options
			local container = entry.Container
			local now = GetTime()

			for i, spell in ipairs(testSpells) do
				if i > container.Count then
					break
				end

				local texture = C_Spell.GetSpellTexture(spell.SpellId)

				if texture then
					local duration = 15 + (i - 1) * 3
					local startTime = now - (i - 1) * 0.5

					local showTooltips = entryOptions.ShowTooltips ~= false
					container:SetSlot(i, {
						Texture = texture,
						DurationObject = wowEx:CreateDuration(startTime, duration),
						Alpha = true,
						ReverseCooldown = entryOptions.Icons.ReverseCooldown,
						Glow = entryOptions.Icons.Glow,
						Color = entryOptions.Icons.ColorByDispelType and spell.DispelColor,
						FontScale = db.FontScale,
						SpellId = showTooltips and spell.SpellId or nil,
					})
				end
			end

			for i = #testSpells + 1, container.Count do
				container:SetSlotUnused(i)
			end

			AnchorContainer(container, anchor, entryOptions)
			frames:ShowHideFrame(container.Frame, anchor, true, isPet and false or entryOptions.ExcludePlayer)
		end
	end
end

local function Pause()
	paused = true
end

local function Resume()
	paused = false
end

function M:Hide()
	for _, entry in pairs(watchers) do
		entry.Container.Frame:Hide()
	end
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
	local ccEnabled = moduleUtil:IsModuleEnabled(moduleName.CrowdControl)
	local petEnabled = moduleUtil:IsModuleEnabled(moduleName.PetCC)

	for _, entry in pairs(watchers) do
		if entry.Watcher then
			local isPet = units:IsPetOrMinion(entry.Unit)
			if (isPet and petEnabled) or (not isPet and ccEnabled) then
				entry.Watcher:Enable()
			end
		end
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

function M:Refresh()
	local options = GetOptions()

	if not options then
		return
	end

	local moduleEnabled = moduleUtil:IsModuleEnabled(moduleName.CrowdControl)
	local petEnabled = moduleUtil:IsModuleEnabled(moduleName.PetCC)

	-- If both are off, disable everything and bail early
	if not moduleEnabled and not petEnabled then
		DisableWatchers()
		return
	end

	EnableWatchers()
	EnsureWatchers()

	local petOptions = db.Modules.PetCCModule

	for anchor, entry in pairs(watchers) do
		local isPet = units:IsPetOrMinion(entry.Unit)
		local entryOptions = isPet and petOptions or options
		local entryEnabled

		if isPet then
			-- In test mode always treat pet as enabled so icons show
			entryEnabled = testModeActive or petEnabled
		else
			entryEnabled = moduleEnabled
		end

		if not entryEnabled or not entryOptions then
			-- This entry's feature is toggled off - hide and disable it
			entry.Watcher:Disable()
			entry.Container:ResetAllSlots()
			entry.Container.Frame:Hide()
		else
			local iconSize = tonumber(entryOptions.Icons.Size) or (isPet and 24 or 32)
			local iconCount = entryOptions.Icons.Count or 5

			entry.Container:SetIconSize(iconSize)
			entry.Container:SetCount(iconCount)
			entry.Container:SetSpacing(db.IconSpacing or 2)

			if not testModeActive then
				UpdateWatcherAuras(entry)
			end

			AnchorContainer(entry.Container, anchor, entryOptions)
			frames:ShowHideFrame(
				entry.Container.Frame,
				anchor,
				testModeActive,
				isPet and false or entryOptions.ExcludePlayer
			)
		end
	end

	if testModeActive then
		RefreshTestIcons()
	end
end

function M:Init()
	db = mini:GetSavedVars()

	local kidneyShot = { SpellId = 408, DispelColor = DEBUFF_TYPE_NONE_COLOR }
	local fear = { SpellId = 5782, DispelColor = DEBUFF_TYPE_MAGIC_COLOR }
	local hex = { SpellId = 254412, DispelColor = DEBUFF_TYPE_CURSE_COLOR }
	testSpells = { kidneyShot, fear, hex }

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
		if moduleUtil:IsModuleEnabled(moduleName.CrowdControl) or moduleUtil:IsModuleEnabled(moduleName.PetCC) then
			EnsureWatchers()
		end
	end)

	frames:HookNDuiVisibility(function()
		if moduleUtil:IsModuleEnabled(moduleName.CrowdControl) or moduleUtil:IsModuleEnabled(moduleName.PetCC) then
			EnsureWatchers()
		end
	end)

	local moduleEnabled = moduleUtil:IsModuleEnabled(moduleName.CrowdControl)

	if moduleEnabled then
		EnsureWatchers()
	end
end
