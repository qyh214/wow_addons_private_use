---@type string, Addon
local addonName, addon = ...
local mini = addon.Core.Framework
local wowEx = addon.Utils.WoWEx
local units = addon.Utils.Units
local unitWatcher = addon.Core.UnitAuraWatcher
local iconSlotContainer = addon.Core.IconSlotContainer
local moduleUtil = addon.Utils.ModuleUtil
local moduleName = addon.Utils.ModuleName
local slotDistribution = addon.Utils.SlotDistribution
local mathMin = math.min
local GetTime = GetTime
local C_NamePlate = C_NamePlate
local testModeActive = false
local paused = false
---@type Db
local db
---@type table
local nmModule
---@type table<string, NameplateData>
local nameplateAnchors = {}
---@type table<string, Watcher>
local watchers = {}

local testCcNameplateSpellIds = {
	408, -- kidney shot
	5782, -- fear
}
local testDefensiveNameplateSpellIds = {
	104773, -- warlock wall
	1022, -- bop
}
local testImportantNameplateSpellIds = {
	190319, -- combustion
	121471, -- Shadow Blades
	377362, -- precog
}
-- Pre-computed lengths; these lists never change at runtime so recalculating
-- #list on every test-mode call is pure waste.
local testCcCount = #testCcNameplateSpellIds
local testDefensiveCount = #testDefensiveNameplateSpellIds
local testImportantCount = #testImportantNameplateSpellIds

-- Test spell dispel colors for CC spells
local testCcDispelColors = {
	[408] = DEBUFF_TYPE_NONE_COLOR, -- kidney shot
	[5782] = DEBUFF_TYPE_MAGIC_COLOR, -- fear
}

-- Category colors
local defensiveColor = { r = 0.0, g = 0.8, b = 0.0 } -- Green
local importantColor = { r = 1.0, g = 0.2, b = 0.2 } -- Red

---@class NameplateData
---@field Nameplate table
---@field CcContainer IconSlotContainer?
---@field ImportantContainer IconSlotContainer?
---@field CombinedContainer IconSlotContainer?
---@field UnitToken string

local previousFriendlyEnabled = {
	CC = false,
	Important = false,
	Combined = false,
}
local previousEnemyEnabled = {
	CC = false,
	Important = false,
	Combined = false,
}
local previousPetEnabled = {
	Friendly = false,
	Enemy = false,
}
local previousModuleEnabled = { Always = false, Arena = false, BattleGrounds = false, PvE = false }

-- Reusable scratch table for SetSlot calls.
-- This avoids creating a new table on every aura update for every nameplate slot,
-- which significantly reduces garbage collection pressure.
local layerScratch = {}

---@class NameplatesModule
local M = {}
addon.Modules.NameplatesModule = M

local nameplateCcKey = addonName .. "_CcContainer"
local nameplateImportantKey = addonName .. "_ImportantContainer"
local nameplateCombinedKey = addonName .. "_CombinedContainer"

local function GetCCSortOptions()
	if db.CCNativeOrder then
		return Enum.UnitAuraSortRule.Default, Enum.UnitAuraSortDirection.Normal
	end
	return Enum.UnitAuraSortRule.Unsorted, Enum.UnitAuraSortDirection.Reverse
end

local function GrowToAnchor(grow)
	if grow == "LEFT" then
		return "RIGHT", "LEFT"
	elseif grow == "RIGHT" then
		return "LEFT", "RIGHT"
	elseif grow == "DOWN" then
		return "TOP", "BOTTOM"
	else
		return "CENTER", "CENTER"
	end
end

---@return string point
---@return string relativeToPoint
local function GetAnchorPoint(unitToken, containerType)
	local config = M:GetUnitOptions(unitToken)
	return GrowToAnchor(config[containerType].Grow)
end

---@param container IconSlotContainer?
local function HideAndReset(container)
	if not container then
		return
	end
	container:ResetAllSlots()
	container.Frame:Hide()
end

---@param container IconSlotContainer
---@param nameplate table
---@param anchorPoint string
---@param relativeToPoint string
---@param offsetX number
---@param offsetY number
---Returns the effective anchor frame for a nameplate.
---For ThreatPlates, anchors to TPFrame (or its GetAnchor result) so that
---icons scale and move with TP's target-highlight scaling, not the raw base frame.
local function GetNameplateAnchorFrame(nameplate)
	if nameplate.TPFrame then
		if nameplate.TPFrame.GetAnchor then
			local anchor = nameplate.TPFrame:GetAnchor()
			-- GetAnchor may return a FontString or other non-Frame object that lacks GetFrameLevel
			if anchor and anchor.GetFrameLevel then
				return anchor
			end
		end
		return nameplate.TPFrame
	end
	return nameplate
end

local function SetupContainerFrame(container, nameplate, anchorPoint, relativeToPoint, offsetX, offsetY)
	local anchorFrame = GetNameplateAnchorFrame(nameplate)
	local frame = container.Frame
	frame:ClearAllPoints()
	frame:SetPoint(anchorPoint, anchorFrame, relativeToPoint, offsetX, offsetY)
	frame:SetFrameLevel(anchorFrame:GetFrameLevel() + 10)
	frame:EnableMouse(false)
	frame:SetIgnoreParentScale(not nmModule.ScaleWithNameplate)
	frame:Show()
end

---@param nameplate table
---@param unitToken string
---@param unitOptions table
---@return IconSlotContainer? ccContainer, IconSlotContainer? importantContainer, IconSlotContainer? combinedContainer
local function EnsureContainersForNameplate(nameplate, unitToken, unitOptions)
	-- Combined mode
	if unitOptions.Combined and unitOptions.Combined.Enabled then
		local combinedOptions = unitOptions.Combined
		local size = combinedOptions.Icons.Size or 50
		local maxIcons = combinedOptions.Icons.MaxIcons or 8
		local offsetX = combinedOptions.Offset.X or 0
		local offsetY = combinedOptions.Offset.Y or 0
		local anchorPoint, relativeToPoint = GetAnchorPoint(unitToken, "Combined")

		local combinedContainer = nameplate[nameplateCombinedKey]
		if not combinedContainer then
			combinedContainer = iconSlotContainer:New(nameplate, maxIcons, size, db.IconSpacing or 2, "Nameplates", nil, "Nameplates")
			nameplate[nameplateCombinedKey] = combinedContainer
		else
			combinedContainer:SetIconSize(size)
			combinedContainer:SetCount(maxIcons)
		end

		SetupContainerFrame(combinedContainer, nameplate, anchorPoint, relativeToPoint, offsetX, offsetY)

		-- Hide unused separate containers (keep references)
		HideAndReset(nameplate[nameplateCcKey])
		HideAndReset(nameplate[nameplateImportantKey])

		return nil, nil, combinedContainer
	end

	-- Separate mode
	local ccContainer = nil
	local importantContainer = nil

	-- CC
	local ccOptions = unitOptions.CC
	if ccOptions and ccOptions.Enabled then
		local size = ccOptions.Icons.Size or 20
		local maxIcons = ccOptions.Icons.MaxIcons or 5
		local offsetX = ccOptions.Offset.X or 0
		local offsetY = ccOptions.Offset.Y or 5
		local anchorPoint, relativeToPoint = GetAnchorPoint(unitToken, "CC")

		ccContainer = nameplate[nameplateCcKey]
		if not ccContainer then
			ccContainer = iconSlotContainer:New(nameplate, maxIcons, size, db.IconSpacing or 2, "Nameplates", nil, "Nameplates")
			nameplate[nameplateCcKey] = ccContainer
		else
			ccContainer:SetIconSize(size)
			ccContainer:SetCount(maxIcons)
		end

		SetupContainerFrame(ccContainer, nameplate, anchorPoint, relativeToPoint, offsetX, offsetY)
	else
		HideAndReset(nameplate[nameplateCcKey])
	end

	-- Important
	local importantOptions = unitOptions.Important
	if importantOptions and importantOptions.Enabled then
		local size = importantOptions.Icons.Size or 20
		local maxIcons = importantOptions.Icons.MaxIcons or 5
		local offsetX = importantOptions.Offset.X or 0
		local offsetY = importantOptions.Offset.Y or 5
		local anchorPoint, relativeToPoint = GetAnchorPoint(unitToken, "Important")

		importantContainer = nameplate[nameplateImportantKey]
		if not importantContainer then
			importantContainer = iconSlotContainer:New(nameplate, maxIcons, size, db.IconSpacing or 2, "Nameplates", nil, "Nameplates")
			nameplate[nameplateImportantKey] = importantContainer
		else
			importantContainer:SetIconSize(size)
			importantContainer:SetCount(maxIcons)
		end

		SetupContainerFrame(importantContainer, nameplate, anchorPoint, relativeToPoint, offsetX, offsetY)
	else
		HideAndReset(nameplate[nameplateImportantKey])
	end

	-- Hide combined in separate mode (keep reference)
	HideAndReset(nameplate[nameplateCombinedKey])

	return ccContainer, importantContainer, nil
end

---@param data NameplateData
---@param watcher Watcher
---@param unitOptions table Pre-fetched unit options
local function ApplyCombinedToNameplate(data, watcher, unitOptions)
	local container = data.CombinedContainer
	if not container then
		return
	end

	local combinedOptions = unitOptions and unitOptions.Combined
	if not combinedOptions or not combinedOptions.Enabled then
		return
	end

	local ccData = watcher:GetCcState()
	local defensivesData = watcher:GetDefensiveState()
	local importantData = watcher:GetImportantState()
	local iconsGlow = combinedOptions.Icons.Glow
	local iconsReverse = combinedOptions.Icons.ReverseCooldown
	local colorByCategory = combinedOptions.Icons.ColorByCategory
	local showTooltips = combinedOptions.ShowTooltips ~= false
	local fontScale = db.FontScale

	-- Calculate slot distribution
	local ccSlots, defensiveSlots, importantSlots =
		slotDistribution.Calculate(container.Count, #ccData, #defensivesData, #importantData)

	local slot = 0

	-- Add CC spells (highest priority)
	if ccSlots > 0 then
		for i = 1, mathMin(ccSlots, #ccData) do
			if slot >= container.Count then
				break
			end
			slot = slot + 1
			local entry = ccData[i]
			layerScratch.Texture = entry.SpellIcon
			layerScratch.DurationObject = entry.DurationObject
			layerScratch.Alpha = entry.IsCC
			layerScratch.Glow = iconsGlow
			layerScratch.ReverseCooldown = iconsReverse
			layerScratch.FontScale = fontScale
			layerScratch.Color = colorByCategory and entry.DispelColor or nil
			layerScratch.SpellId = showTooltips and entry.SpellId or nil
			container:SetSlot(slot, layerScratch)
		end
	end

	-- Add Defensive spells (second priority)
	if defensiveSlots > 0 then
		for i = 1, mathMin(defensiveSlots, #defensivesData) do
			if slot >= container.Count then
				break
			end
			slot = slot + 1
			local entry = defensivesData[i]
			layerScratch.Texture = entry.SpellIcon
			layerScratch.DurationObject = entry.DurationObject
			layerScratch.Alpha = entry.IsDefensive
			layerScratch.Glow = iconsGlow
			layerScratch.ReverseCooldown = iconsReverse
			layerScratch.FontScale = fontScale
			layerScratch.Color = colorByCategory and defensiveColor or nil
			layerScratch.SpellId = showTooltips and entry.SpellId or nil
			container:SetSlot(slot, layerScratch)
		end
	end

	-- Add Important spells (third priority)
	if importantSlots > 0 then
		for i = 1, mathMin(importantSlots, #importantData) do
			if slot >= container.Count then
				break
			end
			slot = slot + 1
			local entry = importantData[i]
			layerScratch.Texture = entry.SpellIcon
			layerScratch.DurationObject = entry.DurationObject
			layerScratch.Alpha = entry.IsImportant
			layerScratch.Glow = iconsGlow
			layerScratch.ReverseCooldown = iconsReverse
			layerScratch.FontScale = fontScale
			layerScratch.Color = colorByCategory and importantColor or nil
			layerScratch.SpellId = showTooltips and entry.SpellId or nil
			container:SetSlot(slot, layerScratch)
		end
	end

	-- Clear any unused slots beyond the used count
	for i = slot + 1, container.Count do
		container:SetSlotUnused(i)
	end
end

---@param data NameplateData
---@param watcher Watcher
---@param unitOptions table Pre-fetched unit options
local function ApplyCcToNameplate(data, watcher, unitOptions)
	local container = data.CcContainer
	if not container then
		return
	end

	local options = unitOptions and unitOptions.CC
	if not options or not options.Enabled then
		return
	end

	local ccData = watcher:GetCcState()
	local ccDataCount = #ccData

	if ccDataCount == 0 then
		container:ResetAllSlots()
		return
	end

	local iconsGlow = options.Icons.Glow
	local iconsReverse = options.Icons.ReverseCooldown
	local showMilliseconds = options.Icons.ShowMilliseconds
	local colorByCategory = options.Icons.ColorByCategory
	local showTooltips = options.ShowTooltips ~= false
	local fontScale = db.FontScale
	local limit = mathMin(ccDataCount, container.Count)

	for i = 1, limit do
		local entry = ccData[i]
		layerScratch.Texture = entry.SpellIcon
		layerScratch.DurationObject = entry.DurationObject
		layerScratch.Alpha = entry.IsCC
		layerScratch.Glow = iconsGlow
		layerScratch.ReverseCooldown = iconsReverse
		layerScratch.ShowMilliseconds = showMilliseconds
		layerScratch.FontScale = fontScale
		layerScratch.Color = colorByCategory and entry.DispelColor or nil
		layerScratch.SpellId = showTooltips and entry.SpellId or nil
		container:SetSlot(i, layerScratch)
	end

	-- Clear any unused slots beyond the CC count
	for i = limit + 1, container.Count do
		container:SetSlotUnused(i)
	end
end

---@param data NameplateData
---@param watcher Watcher
---@param unitOptions table Pre-fetched unit options
local function ApplyImportantSpellsToNameplate(data, watcher, unitOptions)
	local container = data.ImportantContainer
	if not container then
		return
	end

	local options = unitOptions and unitOptions.Important
	if not options or not options.Enabled then
		return
	end

	local iconsGlow = options.Icons.Glow
	local iconsReverse = options.Icons.ReverseCooldown
	local colorByCategory = options.Icons.ColorByCategory
	local showTooltips = options.ShowTooltips ~= false
	local fontScale = db.FontScale
	local defensivesData = watcher:GetDefensiveState()
	local importantData = watcher:GetImportantState()

	-- Calculate slot distribution (Important has higher priority than Defensive)
	-- We pass Important as first parameter (CC slot), Defensive as second parameter
	local importantSlots, defensiveSlots, _ =
		slotDistribution.Calculate(container.Count, #importantData, #defensivesData, 0)

	local slot = 0

	-- Add Important spells (highest priority)
	if importantSlots > 0 then
		for i = 1, mathMin(importantSlots, #importantData) do
			if slot >= container.Count then
				break
			end
			slot = slot + 1
			local entry = importantData[i]
			layerScratch.Texture = entry.SpellIcon
			layerScratch.DurationObject = entry.DurationObject
			layerScratch.Alpha = entry.IsImportant
			layerScratch.Glow = iconsGlow
			layerScratch.ReverseCooldown = iconsReverse
			layerScratch.FontScale = fontScale
			layerScratch.Color = colorByCategory and importantColor or nil
			layerScratch.SpellId = showTooltips and entry.SpellId or nil
			container:SetSlot(slot, layerScratch)
		end
	end

	-- Add Defensive spells (second priority)
	if defensiveSlots > 0 then
		for i = 1, mathMin(defensiveSlots, #defensivesData) do
			if slot >= container.Count then
				break
			end
			slot = slot + 1
			local entry = defensivesData[i]
			layerScratch.Texture = entry.SpellIcon
			layerScratch.DurationObject = entry.DurationObject
			layerScratch.Alpha = entry.IsDefensive
			layerScratch.Glow = iconsGlow
			layerScratch.ReverseCooldown = iconsReverse
			layerScratch.FontScale = fontScale
			layerScratch.Color = colorByCategory and defensiveColor or nil
			layerScratch.SpellId = showTooltips and entry.SpellId or nil
			container:SetSlot(slot, layerScratch)
		end
	end

	-- Clear any unused slots beyond the used count
	for i = slot + 1, container.Count do
		container:SetSlotUnused(i)
	end
end

local function OnAuraDataChanged(unitToken)
	if paused or not unitToken then
		return
	end

	local data = nameplateAnchors[unitToken]
	if not data then
		return
	end

	local watcher = watchers[unitToken]
	if not watcher then
		return
	end

	-- Fetch once and pass down to avoid each Apply function re-traversing the db path
	local unitOptions = M:GetUnitOptions(unitToken)

	-- BUGFIX (duels): If GetUnitOptions() switches between Friendly and Enemy for the
	-- same unitToken (e.g. duel starts), the cached container references may be nil
	-- for the now-active options. Rebuild lazily so aura data isn't silently dropped.
	local needRebuild = false
	if unitOptions.Combined and unitOptions.Combined.Enabled then
		if not data.CombinedContainer then needRebuild = true end
	else
		if unitOptions.CC and unitOptions.CC.Enabled and not data.CcContainer then
			needRebuild = true
		end
		if unitOptions.Important and unitOptions.Important.Enabled and not data.ImportantContainer then
			needRebuild = true
		end
	end

	if needRebuild then
		local nameplate = data.Nameplate or C_NamePlate.GetNamePlateForUnit(unitToken)
		if nameplate then
			local ccContainer, importantContainer, combinedContainer =
				EnsureContainersForNameplate(nameplate, unitToken, unitOptions)
			data.CcContainer = ccContainer
			data.ImportantContainer = importantContainer
			data.CombinedContainer = combinedContainer
		end
	end

	if unitOptions.Combined.Enabled then
		ApplyCombinedToNameplate(data, watcher, unitOptions)
	else
		ApplyCcToNameplate(data, watcher, unitOptions)
		ApplyImportantSpellsToNameplate(data, watcher, unitOptions)
	end
end

local function ShowCombinedTestIcons(combinedContainer, combinedOptions, now)
	if not combinedContainer or not combinedOptions then
		return
	end

	-- Calculate slot distribution
	local ccSlots, defensiveSlots, importantSlots =
		slotDistribution.Calculate(combinedContainer.Count, testCcCount, testDefensiveCount, testImportantCount)

	local iconsGlow = combinedOptions.Icons.Glow
	local iconsReverse = combinedOptions.Icons.ReverseCooldown
	local colorByCategory = combinedOptions.Icons.ColorByCategory
	local showTooltips = combinedOptions.ShowTooltips ~= false
	local fontScale = db.FontScale
	local slot = 0

	-- Add CC spells first (highest priority)
	for i = 1, ccSlots do
		if slot >= combinedContainer.Count then
			break
		end
		slot = slot + 1

		local spellId = testCcNameplateSpellIds[i]
		local tex = C_Spell.GetSpellTexture(spellId)
		if tex then
			layerScratch.Texture = tex
			layerScratch.DurationObject = wowEx:CreateDuration(now - (i - 1) * 0.5, 15 + (i - 1) * 3)
			layerScratch.Alpha = true
			layerScratch.Glow = iconsGlow
			layerScratch.ReverseCooldown = iconsReverse
			layerScratch.FontScale = fontScale
			layerScratch.Color = colorByCategory and testCcDispelColors[spellId] or nil
			layerScratch.SpellId = showTooltips and spellId or nil
			combinedContainer:SetSlot(slot, layerScratch)
		end
	end

	-- Add Defensive spells (second priority)
	for i = 1, defensiveSlots do
		if slot >= combinedContainer.Count then
			break
		end
		slot = slot + 1

		local spellId = testDefensiveNameplateSpellIds[i]
		local tex = C_Spell.GetSpellTexture(spellId)
		if tex then
			layerScratch.Texture = tex
			layerScratch.DurationObject = wowEx:CreateDuration(now - (i - 1) * 0.5, 15 + (i - 1) * 3)
			layerScratch.Alpha = true
			layerScratch.Glow = iconsGlow
			layerScratch.ReverseCooldown = iconsReverse
			layerScratch.FontScale = fontScale
			layerScratch.Color = colorByCategory and defensiveColor or nil
			layerScratch.SpellId = showTooltips and spellId or nil
			combinedContainer:SetSlot(slot, layerScratch)
		end
	end

	-- Add Important spells (third priority)
	for i = 1, importantSlots do
		if slot >= combinedContainer.Count then
			break
		end
		slot = slot + 1

		local spellId = testImportantNameplateSpellIds[i]
		local tex = C_Spell.GetSpellTexture(spellId)
		if tex then
			layerScratch.Texture = tex
			layerScratch.DurationObject = wowEx:CreateDuration(now - (i - 1) * 0.5, 15 + (i - 1) * 3)
			layerScratch.Alpha = true
			layerScratch.Glow = iconsGlow
			layerScratch.ReverseCooldown = iconsReverse
			layerScratch.FontScale = fontScale
			layerScratch.Color = colorByCategory and importantColor or nil
			layerScratch.SpellId = showTooltips and spellId or nil
			combinedContainer:SetSlot(slot, layerScratch)
		end
	end

	-- Clear any unused slots beyond what we just set
	for i = slot + 1, combinedContainer.Count do
		combinedContainer:SetSlotUnused(i)
	end
end

local function ShowSeparateModeTestIcons(ccContainer, ccOptions, importantContainer, importantOptions, now)
	if ccContainer and ccOptions then
		local iconsGlow = ccOptions.Icons.Glow
		local iconsReverse = ccOptions.Icons.ReverseCooldown
		local colorByCategory = ccOptions.Icons.ColorByCategory
		local showTooltips = ccOptions.ShowTooltips ~= false
		local fontScale = db.FontScale
		local limit = mathMin(testCcCount, ccContainer.Count)

		-- Show CC test spells (limited to container count)
		for i = 1, limit do
			local spellId = testCcNameplateSpellIds[i]
			local tex = C_Spell.GetSpellTexture(spellId)

			if tex then
				layerScratch.Texture = tex
				layerScratch.DurationObject = wowEx:CreateDuration(now - (i - 1) * 0.5, 15 + (i - 1) * 3)
				layerScratch.Alpha = true
				layerScratch.Glow = iconsGlow
				layerScratch.ReverseCooldown = iconsReverse
				layerScratch.FontScale = fontScale
				layerScratch.Color = colorByCategory and testCcDispelColors[spellId] or nil
				layerScratch.SpellId = showTooltips and spellId or nil
				ccContainer:SetSlot(i, layerScratch)
			end
		end

		-- Clear any unused slots beyond test CC spells
		for i = limit + 1, ccContainer.Count do
			ccContainer:SetSlotUnused(i)
		end
	end

	if importantContainer and importantOptions then
		local iconsGlow = importantOptions.Icons.Glow
		local iconsReverse = importantOptions.Icons.ReverseCooldown
		local colorByCategory = importantOptions.Icons.ColorByCategory
		local showTooltips = importantOptions.ShowTooltips ~= false
		local fontScale = db.FontScale

		-- Calculate slot distribution (Important has higher priority than Defensive)
		local importantSlots, defensiveSlots, _ =
			slotDistribution.Calculate(importantContainer.Count, testImportantCount, testDefensiveCount, 0)

		local slot = 0

		-- Add Important test spells (highest priority)
		if importantSlots > 0 then
			for i = 1, mathMin(importantSlots, testImportantCount) do
				if slot >= importantContainer.Count then
					break
				end
				slot = slot + 1

				local spellId = testImportantNameplateSpellIds[i]
				local tex = C_Spell.GetSpellTexture(spellId)

				if tex then
					layerScratch.Texture = tex
					layerScratch.DurationObject = wowEx:CreateDuration(now - (i - 1) * 0.5, 15 + (i - 1) * 3)
					layerScratch.Alpha = true
					layerScratch.Glow = iconsGlow
					layerScratch.ReverseCooldown = iconsReverse
					layerScratch.FontScale = fontScale
					layerScratch.Color = colorByCategory and importantColor or nil
					layerScratch.SpellId = showTooltips and spellId or nil
					importantContainer:SetSlot(slot, layerScratch)
				end
			end
		end

		-- Add Defensive test spells (second priority)
		if defensiveSlots > 0 then
			for i = 1, mathMin(defensiveSlots, testDefensiveCount) do
				if slot >= importantContainer.Count then
					break
				end
				slot = slot + 1

				local spellId = testDefensiveNameplateSpellIds[i]
				local tex = C_Spell.GetSpellTexture(spellId)

				if tex then
					layerScratch.Texture = tex
					layerScratch.DurationObject = wowEx:CreateDuration(now - (i - 1) * 0.5, 15 + (i - 1) * 3)
					layerScratch.Alpha = true
					layerScratch.Glow = iconsGlow
					layerScratch.ReverseCooldown = iconsReverse
					layerScratch.FontScale = fontScale
					layerScratch.Color = colorByCategory and defensiveColor or nil
					layerScratch.SpellId = showTooltips and spellId or nil
					importantContainer:SetSlot(slot, layerScratch)
				end
			end
		end

		-- Clear any unused slots beyond what we just set
		for i = slot + 1, importantContainer.Count do
			importantContainer:SetSlotUnused(i)
		end
	end
end

local function OnNamePlateRemoved(unitToken)
	local data = nameplateAnchors[unitToken]
	if not data then
		return
	end

	HideAndReset(data.CcContainer)
	HideAndReset(data.ImportantContainer)
	HideAndReset(data.CombinedContainer)

	-- Dispose of watcher
	if watchers[unitToken] then
		watchers[unitToken]:Dispose()
		watchers[unitToken] = nil
	end

	-- Remove all data for this unit token
	nameplateAnchors[unitToken] = nil
end

local function OnNamePlateAdded(unitToken)
	local nameplate = C_NamePlate.GetNamePlateForUnit(unitToken)
	if not nameplate then
		return
	end

	local moduleEnabled = moduleUtil:IsModuleEnabled(moduleName.Nameplates)
	if not moduleEnabled then
		return
	end

	-- Check if we should ignore pets
	local unitOptions = M:GetUnitOptions(unitToken)
	if unitOptions.IgnorePets and units:IsPetOrMinion(unitToken) then
		return
	end

	-- Reuse containers stored on the nameplate; only create if missing
	local ccContainer, importantContainer, combinedContainer =
		EnsureContainersForNameplate(nameplate, unitToken, unitOptions)

	-- BUGFIX (duels): Previously this returned early if no containers were created for
	-- the current options table (e.g. friendly player with Friendly.* all disabled).
	-- That meant `nameplateAnchors[unitToken]` and `watchers[unitToken]` were never
	-- populated, so when the unit later became a duel opponent and GetUnitOptions()
	-- started returning Enemy options, there was no watcher listening to UNIT_AURA and
	-- OnAuraDataChanged would never fire to rebuild containers.
	-- We now also create data+watcher if the *opposite* faction has any mode enabled,
	-- but only in the open world where duels can occur - inside instances this overhead
	-- is unnecessary since friendly units can never become duel opponents there.
	local inInstance = IsInInstance()
	local oppositeOptions = units:IsEnemy(unitToken) and nmModule.Friendly or nmModule.Enemy
	local anyEnabledOpposite = not inInstance
		and ((oppositeOptions.Combined and oppositeOptions.Combined.Enabled)
			or (oppositeOptions.CC and oppositeOptions.CC.Enabled)
			or (oppositeOptions.Important and oppositeOptions.Important.Enabled))

	if not ccContainer and not importantContainer and not combinedContainer and not anyEnabledOpposite then
		return
	end

	-- Create / update nameplate data
	nameplateAnchors[unitToken] = {
		Nameplate = nameplate,
		CcContainer = ccContainer,
		ImportantContainer = importantContainer,
		CombinedContainer = combinedContainer,
		UnitToken = unitToken,
	}

	-- Create new watcher
	local sortRule, sortDirection = GetCCSortOptions()
	watchers[unitToken] = unitWatcher:New(unitToken, nil, nil, sortRule, sortDirection)
	watchers[unitToken]:RegisterCallback(function()
		OnAuraDataChanged(unitToken)
	end)

	-- Initial update
	if testModeActive then
		-- In test mode, show test icons for this specific nameplate
		local now = GetTime()

		if unitOptions.Combined.Enabled then
			if combinedContainer then
				ShowCombinedTestIcons(combinedContainer, unitOptions.Combined, now)
			end
		else
			ShowSeparateModeTestIcons(ccContainer, unitOptions.CC, importantContainer, unitOptions.Important, now)
		end
	end
end

local function ClearNameplate(unitToken)
	local data = nameplateAnchors[unitToken]
	if not data then
		return
	end

	if data.CcContainer then
		data.CcContainer:ResetAllSlots()
	end

	if data.ImportantContainer then
		data.ImportantContainer:ResetAllSlots()
	end

	if data.CombinedContainer then
		data.CombinedContainer:ResetAllSlots()
	end
end

local function DisableWatchers()
	for _, watcher in pairs(watchers) do
		if watcher then
			watcher:Disable()
		end
	end

	for unitToken, _ in pairs(nameplateAnchors) do
		ClearNameplate(unitToken)
	end
end

local function EnableWatchers()
	for _, watcher in pairs(watchers) do
		if watcher then
			watcher:Enable()
		end
	end
end

local function RebuildContainers()
	if not moduleUtil:IsModuleEnabled(moduleName.Nameplates) then
		return
	end

	local count = 0
	for _, nameplate in pairs(C_NamePlate.GetNamePlates()) do
		local unitToken = nameplate.unitToken

		if unitToken then
			OnNamePlateAdded(unitToken)
			count = count + 1
		end
	end
end

local function AnyEnabled()
	return nmModule.Friendly.CC.Enabled
		or nmModule.Friendly.Important.Enabled
		or nmModule.Friendly.Combined.Enabled
		or nmModule.Enemy.CC.Enabled
		or nmModule.Enemy.Important.Enabled
		or nmModule.Enemy.Combined.Enabled
end

local function CacheEnabledModes()
	local enemy = nmModule.Enemy
	local friendly = nmModule.Friendly
	local enabled = nmModule.Enabled

	previousEnemyEnabled.CC = enemy.CC.Enabled
	previousEnemyEnabled.Important = enemy.Important.Enabled
	previousEnemyEnabled.Combined = enemy.Combined.Enabled

	previousFriendlyEnabled.CC = friendly.CC.Enabled
	previousFriendlyEnabled.Important = friendly.Important.Enabled
	previousFriendlyEnabled.Combined = friendly.Combined.Enabled

	previousPetEnabled.Friendly = friendly.IgnorePets
	previousPetEnabled.Enemy = enemy.IgnorePets

	previousModuleEnabled.Always = enabled.Always
	previousModuleEnabled.Arena = enabled.Arena
	previousModuleEnabled.BattleGrounds = enabled.BattleGrounds
	previousModuleEnabled.PvE = enabled.PvE
end

local function HaveModesChanged()
	local enemy = nmModule.Enemy
	local friendly = nmModule.Friendly
	local enabled = nmModule.Enabled

	return previousEnemyEnabled.CC ~= enemy.CC.Enabled
		or previousEnemyEnabled.Important ~= enemy.Important.Enabled
		or previousEnemyEnabled.Combined ~= enemy.Combined.Enabled
		or previousFriendlyEnabled.CC ~= friendly.CC.Enabled
		or previousFriendlyEnabled.Important ~= friendly.Important.Enabled
		or previousFriendlyEnabled.Combined ~= friendly.Combined.Enabled
		or previousPetEnabled.Friendly ~= friendly.IgnorePets
		or previousPetEnabled.Enemy ~= enemy.IgnorePets
		or previousModuleEnabled.Always ~= enabled.Always
		or previousModuleEnabled.Arena ~= enabled.Arena
		or previousModuleEnabled.BattleGrounds ~= enabled.BattleGrounds
		or previousModuleEnabled.PvE ~= enabled.PvE
end

local function ShowTestIcons()
	local now = GetTime()
	for _, container in pairs(nameplateAnchors) do
		local options = M:GetUnitOptions(container.UnitToken)
		local ccOptions = options.CC
		local importantOptions = options.Important
		local ccContainer = container.CcContainer
		local combinedOptions = options.Combined
		local importantContainer = container.ImportantContainer
		local combinedContainer = container.CombinedContainer

		if options.Combined.Enabled then
			if combinedContainer and combinedOptions then
				ShowCombinedTestIcons(combinedContainer, combinedOptions, now)
			end
		else
			ShowSeparateModeTestIcons(ccContainer, ccOptions, importantContainer, importantOptions, now)
		end
	end
end

local function RefreshAnchorsAndSizes()
	local ignoreParentScale = not nmModule.ScaleWithNameplate
	for _, data in pairs(nameplateAnchors) do
		if data.Nameplate and data.UnitToken then
			local unitOptions = M:GetUnitOptions(data.UnitToken)
			local anchorFrame = GetNameplateAnchorFrame(data.Nameplate)

			if unitOptions.Combined.Enabled then
				-- Handle combined container
				local combinedContainer = data.CombinedContainer
				if combinedContainer then
					local combinedOptions = unitOptions.Combined
					if combinedOptions then
						local combinedAnchorPoint, combinedRelativeToPoint = GrowToAnchor(combinedOptions.Grow)
						combinedContainer.Frame:ClearAllPoints()
						combinedContainer.Frame:SetPoint(
							combinedAnchorPoint,
							anchorFrame,
							combinedRelativeToPoint,
							combinedOptions.Offset.X,
							combinedOptions.Offset.Y
						)
						combinedContainer:SetGrowDown(combinedOptions.Grow == "DOWN")
						combinedContainer:SetIconSize(combinedOptions.Icons.Size)
						combinedContainer:SetSpacing(db.IconSpacing or 2)
						combinedContainer:SetCount(combinedOptions.Icons.MaxIcons)
						combinedContainer.Frame:SetFrameLevel(anchorFrame:GetFrameLevel() + 10)
						combinedContainer.Frame:SetIgnoreParentScale(ignoreParentScale)
					end
				end
			else
				-- Handle separate containers
				local ccOptions = unitOptions.CC
				local ccContainer = data.CcContainer

				if ccContainer and ccOptions then
					ccContainer.Frame:ClearAllPoints()

					if ccOptions.Enabled then
						local ccAnchorPoint, ccRelativeToPoint = GrowToAnchor(ccOptions.Grow)
						ccContainer.Frame:SetPoint(
							ccAnchorPoint,
							anchorFrame,
							ccRelativeToPoint,
							ccOptions.Offset.X,
							ccOptions.Offset.Y
						)
						ccContainer:SetGrowDown(ccOptions.Grow == "DOWN")
						ccContainer:SetIconSize(ccOptions.Icons.Size)
						ccContainer:SetSpacing(db.IconSpacing or 2)
						ccContainer:SetCount(ccOptions.Icons.MaxIcons)
						ccContainer.Frame:SetFrameLevel(anchorFrame:GetFrameLevel() + 10)
					end
					ccContainer.Frame:SetIgnoreParentScale(ignoreParentScale)
				end

				local importantOptions = unitOptions.Important
				local importantContainer = data.ImportantContainer

				if importantContainer and importantOptions then
					importantContainer.Frame:ClearAllPoints()

					if importantOptions.Enabled then
						local importantAnchorPoint, importantRelativeToPoint = GrowToAnchor(importantOptions.Grow)
						importantContainer.Frame:SetPoint(
							importantAnchorPoint,
							anchorFrame,
							importantRelativeToPoint,
							importantOptions.Offset.X,
							importantOptions.Offset.Y
						)
						importantContainer:SetGrowDown(importantOptions.Grow == "DOWN")
						importantContainer:SetIconSize(importantOptions.Icons.Size)
						importantContainer:SetSpacing(db.IconSpacing or 2)
						importantContainer:SetCount(importantOptions.Icons.MaxIcons)
						importantContainer.Frame:SetFrameLevel(anchorFrame:GetFrameLevel() + 10)
					end
					importantContainer.Frame:SetIgnoreParentScale(ignoreParentScale)
				end
			end
		end
	end
end

local function ClearAll()
	-- Clean up all existing nameplates
	for unitToken, _ in pairs(nameplateAnchors) do
		ClearNameplate(unitToken)
	end
end

local function Pause()
	paused = true
end

local function Resume()
	paused = false
end

function M:GetUnitOptions(unitToken)
	if units:IsEnemy(unitToken) then
		-- friendly units can also be enemies in a duel
		return nmModule.Enemy
	end

	if units:IsFriend(unitToken) then
		return nmModule.Friendly
	end

	return nmModule.Enemy
end

function M:StartTesting()
	testModeActive = true
	Pause()

	M:Refresh()
end

function M:StopTesting()
	testModeActive = false
	ClearAll()

	Resume()

	-- Refresh all nameplates
	for _, watcher in pairs(watchers) do
		watcher:ForceFullUpdate()
	end
end

local function ApplyBlizzardNameplateSettings()
	local configureEnabled = db.ConfigureBlizzardNameplates
	if configureEnabled == nil then
		configureEnabled = true
	end

	local anyEnemyEnabled = nmModule.Enemy.CC.Enabled
		or nmModule.Enemy.Important.Enabled
		or nmModule.Enemy.Combined.Enabled

	local anyFriendlyEnabled = nmModule.Friendly.CC.Enabled
		or nmModule.Friendly.Important.Enabled
		or nmModule.Friendly.Combined.Enabled

	if configureEnabled and anyEnemyEnabled then
		C_CVar.SetCVarBitfield("nameplateEnemyPlayerAuraDisplay", Enum.NamePlateEnemyPlayerAuraDisplay.LossOfControl, false)
		C_CVar.SetCVarBitfield("nameplateEnemyNpcAuraDisplay", Enum.NamePlateEnemyNpcAuraDisplay.CrowdControl, false)
	end

	if configureEnabled and anyFriendlyEnabled then
		C_CVar.SetCVarBitfield("nameplateFriendlyPlayerAuraDisplay", Enum.NamePlateFriendlyPlayerAuraDisplay.LossOfControl, false)
	end
end

function M:Refresh()
	local moduleEnabled = moduleUtil:IsModuleEnabled(moduleName.Nameplates)

	if not moduleEnabled or not AnyEnabled() then
		DisableWatchers()
		CacheEnabledModes()
		return
	end

	ApplyBlizzardNameplateSettings()

	-- Module is enabled, ensure watchers are enabled
	EnableWatchers()

	-- if the user has enabled/disabled a mode, rebuild the containers
	if HaveModesChanged() then
		RebuildContainers()
	end

	CacheEnabledModes()
	RefreshAnchorsAndSizes()

	local sortRule, sortDirection = GetCCSortOptions()
	for _, watcher in pairs(watchers) do
		watcher:SetSort(sortRule, sortDirection)
	end

	if testModeActive then
		-- update test icons
		ShowTestIcons()
	end
end

function M:Init()
	db = mini:GetSavedVars()
	-- Cache once so all hot-path functions avoid repeatedly traversing db -> Modules -> NameplatesModule
	nmModule = db.Modules.NameplatesModule

	local eventFrame = CreateFrame("Frame")
	eventFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
	eventFrame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
	eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
	eventFrame:SetScript("OnEvent", function(_, event, unitToken)
		if event == "NAME_PLATE_UNIT_ADDED" then
			OnNamePlateAdded(unitToken)
			-- refresh their aura information
			-- important to do it here an not inside of OnNamePlateAdded because that is also called by Refresh
			-- which would cause a significant performance impact
			OnAuraDataChanged(unitToken)
		elseif event == "NAME_PLATE_UNIT_REMOVED" then
			OnNamePlateRemoved(unitToken)
		end
	end)

	local moduleEnabled = moduleUtil:IsModuleEnabled(moduleName.Nameplates)
	if moduleEnabled and AnyEnabled() then
		-- Initialize existing nameplates
		RebuildContainers()
	end

	CacheEnabledModes()
end
