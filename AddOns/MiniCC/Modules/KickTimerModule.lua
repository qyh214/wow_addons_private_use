---@type string, Addon
local _, addon = ...
local mini = addon.Core.Framework
local wowEx = addon.Utils.WoWEx
local iconSlotContainer = addon.Core.IconSlotContainer
local paused = false
local testModeActive = false
local enabled = false
---@type Db
local db

-- fallback icon (rogue Kick)
local kickIcon = C_Spell.GetSpellTexture(1766)

---@type { string: boolean }
local kickedByUnits = {}

---@type KickBar
local kickBar = {
	Container = nil, ---@type IconSlotContainer?
	Anchor = nil, ---@type table?
	ActiveSlots = {}, ---@type table<number, {Key: number, Timer: table}>
	MaxSlots = 10,
}

local friendlyUnitsToWatch = {
	"player",
	"party1",
	"party2",
}

---@type { string: table }
local partyUnitsEventsFrames = {}
local matchEventsFrame
local worldEventsFrame
local playerSpecEventsFrame
local minKickCooldown = 15

-- per arena unit computed at arena prep

---@class SpecKickInfo
---@field KickCd number?
---@field IsCaster boolean
---@field IsHealer boolean

---@type table<number, SpecKickInfo>
local specInfoBySpecId = {
	-- Rogue - Kick
	[259] = { KickCd = 15, IsCaster = false, IsHealer = false }, -- Assassination
	[260] = { KickCd = 15, IsCaster = false, IsHealer = false }, -- Outlaw
	[261] = { KickCd = 15, IsCaster = false, IsHealer = false }, -- Subtlety

	-- Warrior - Pummel
	[71] = { KickCd = 15, IsCaster = false, IsHealer = false }, -- Arms
	[72] = { KickCd = 15, IsCaster = false, IsHealer = false }, -- Fury
	[73] = { KickCd = 15, IsCaster = false, IsHealer = false }, -- Protection

	-- Death Knight - Mind Freeze
	[250] = { KickCd = 15, IsCaster = false, IsHealer = false }, -- Blood
	[251] = { KickCd = 15, IsCaster = false, IsHealer = false }, -- Frost
	[252] = { KickCd = 15, IsCaster = false, IsHealer = false }, -- Unholy

	-- Demon Hunter - Disrupt
	[577] = { KickCd = 15, IsCaster = false, IsHealer = false }, -- Havoc
	[581] = { KickCd = 15, IsCaster = false, IsHealer = false }, -- Vengeance
	[1480] = { KickCd = 15, IsCaster = false, IsHealer = false }, -- Devourer

	-- Monk - Spear Hand Strike
	[268] = { KickCd = 15, IsCaster = false, IsHealer = false }, -- Brewmaster
	[269] = { KickCd = 15, IsCaster = false, IsHealer = false }, -- Windwalker
	[270] = { KickCd = nil, IsCaster = false, IsHealer = true }, -- Mistweaver

	-- Paladin - Rebuke
	[65] = { KickCd = nil, IsCaster = false, IsHealer = true }, -- Holy
	[66] = { KickCd = 15, IsCaster = false, IsHealer = false }, -- Protection
	[70] = { KickCd = 15, IsCaster = false, IsHealer = false }, -- Retribution

	-- Druid
	[102] = { KickCd = 60, IsCaster = true, IsHealer = false }, -- Balance (Solar Beam)
	[103] = { KickCd = 15, IsCaster = false, IsHealer = false }, -- Feral (Skull Bash)
	[104] = { KickCd = 15, IsCaster = false, IsHealer = false }, -- Guardian (Skull Bash)
	[105] = { KickCd = nil, IsCaster = false, IsHealer = true }, -- Restoration

	-- Hunter - Counter Shot
	[253] = { KickCd = 24, IsCaster = true, IsHealer = false }, -- Beast Mastery
	[254] = { KickCd = 24, IsCaster = true, IsHealer = false }, -- Marksmanship
	[255] = { KickCd = 15, IsCaster = false, IsHealer = false }, -- Survival

	-- Mage - Counterspell
	[62] = { KickCd = 20, IsCaster = true, IsHealer = false }, -- Arcane
	[63] = { KickCd = 20, IsCaster = true, IsHealer = false }, -- Fire
	[64] = { KickCd = 20, IsCaster = true, IsHealer = false }, -- Frost

	-- Warlock - Spell Lock (Felhunter)
	[265] = { KickCd = 24, IsCaster = true, IsHealer = false }, -- Affliction
	[266] = { KickCd = 30, IsCaster = true, IsHealer = false }, -- Demonology
	[267] = { KickCd = 24, IsCaster = true, IsHealer = false }, -- Destruction

	-- Shaman - Wind Shear
	[262] = { KickCd = 12, IsCaster = true, IsHealer = false }, -- Elemental
	[263] = { KickCd = 12, IsCaster = false, IsHealer = false }, -- Enhancement
	[264] = { KickCd = 30, IsCaster = false, IsHealer = true }, -- Restoration

	-- Evoker - Quell
	[1467] = { KickCd = 20, IsCaster = true, IsHealer = false }, -- Devastation
	[1468] = { KickCd = nil, IsCaster = false, IsHealer = true }, -- Preservation
	[1473] = { KickCd = nil, IsCaster = true, IsHealer = false }, -- Augmentation

	-- Priest
	[256] = { KickCd = nil, IsCaster = false, IsHealer = true }, -- Discipline
	[257] = { KickCd = nil, IsCaster = false, IsHealer = true }, -- Holy
	[258] = { KickCd = 45, IsCaster = true, IsHealer = false }, -- Shadow (Silence)
}

---@class KickTimerModule : IModule
local M = {}
addon.Modules.KickTimerModule = M

local function IsArena()
	local inInstance, instanceType = IsInInstance()

	return inInstance and instanceType == "arena"
end

local function GetPlayerSpecId()
	local specIndex = GetSpecialization()
	if not specIndex then
		return nil
	end
	local specId = GetSpecializationInfo(specIndex)
	if specId and specId > 0 then
		return specId
	end
	return nil
end

local function CreateKickBar()
	local options = db.Modules.KickTimerModule
	local iconOptions = options.Icons
	local size = tonumber(iconOptions.Size) or 50
	local spacing = db.IconSpacing or 2

	local container = iconSlotContainer:New(UIParent, kickBar.MaxSlots, size, spacing, "Kick Timer", nil, "Kick Timer")
	container.Frame:SetClampedToScreen(true)
	container.Frame:SetMovable(false)
	container.Frame:EnableMouse(false)
	container.Frame:SetDontSavePosition(true)
	container.Frame:RegisterForDrag("LeftButton")
	container.Frame:SetScript("OnDragStart", container.Frame.StartMoving)
	container.Frame:SetScript("OnDragStop", function(frameSelf)
		frameSelf:StopMovingOrSizing()

		local point, movedRelativeTo, relativePoint, x, y = frameSelf:GetPoint()
		options.Point = point
		options.RelativePoint = relativePoint
		options.RelativeTo = (movedRelativeTo and movedRelativeTo:GetName()) or "UIParent"
		options.Offset.X = x
		options.Offset.Y = y
	end)

	local relativeTo = _G[options.RelativeTo] or UIParent
	container.Frame:SetPoint(options.Point, relativeTo, options.RelativePoint, options.Offset.X, options.Offset.Y)

	kickBar.Container = container
	kickBar.Anchor = container.Frame
end

local function ApplyKickBarIconOptions()
	local options = db.Modules.KickTimerModule
	local iconOptions = options.Icons
	local size = tonumber(iconOptions.Size) or 50

	if kickBar.Container then
		kickBar.Container:SetIconSize(size)
		kickBar.Container:SetSpacing(db.IconSpacing or 2)
	end

end

local function UpdateKickBarVisibility()
	if not kickBar.Container or not kickBar.Anchor then
		return
	end

	local usedCount = kickBar.Container:GetUsedSlotCount()
	if usedCount == 0 then
		kickBar.Anchor:Hide()
	else
		kickBar.Anchor:Show()
	end
end

local function ClearIcons()
	-- Cancel all active timers
	for _, slotData in pairs(kickBar.ActiveSlots) do
		if slotData.Timer then
			slotData.Timer:Cancel()
		end
	end

	wipe(kickBar.ActiveSlots)

	if kickBar.Container then
		kickBar.Container:ResetAllSlots()
	end

	UpdateKickBarVisibility()
end

local function PositionKickBar()
	local frame = kickBar.Anchor

	if not frame then
		return
	end

	local options = db.Modules.KickTimerModule
	local relativeTo = _G[options.RelativeTo] or UIParent

	frame:ClearAllPoints()
	frame:SetPoint(options.Point, relativeTo, options.RelativePoint, options.Offset.X, options.Offset.Y)
end

local function GetNextAvailableSlot()
	for i = 1, kickBar.MaxSlots do
		if not kickBar.ActiveSlots[i] then
			return i
		end
	end
	return nil
end

local function CreateKickEntry(duration, icon)
	if not kickBar.Container then
		return
	end

	local slotIndex = GetNextAvailableSlot()
	if not slotIndex then
		return
	end

	local key = math.random()
	local iconOptions = db.Modules.KickTimerModule.Icons

	kickBar.Container:SetSlot(slotIndex, {
		Texture = icon,
		DurationObject = wowEx:CreateDuration(GetTime(), duration),
		Alpha = true,
		ReverseCooldown = iconOptions.ReverseCooldown or false,
		Glow = iconOptions.Glow or false,
		FontScale = db.FontScale,
	})

	local timer = not testModeActive and C_Timer.NewTimer(duration, function()
		local slotData = kickBar.ActiveSlots[slotIndex]
		if slotData and slotData.Key == key then
			kickBar.Container:SetSlotUnused(slotIndex)
			kickBar.ActiveSlots[slotIndex] = nil
			UpdateKickBarVisibility()
		end
	end) or nil

	kickBar.ActiveSlots[slotIndex] = {
		Key = key,
		Timer = timer,
	}

	UpdateKickBarVisibility()
end

---@param specId number?
local function KickedBySpec(specId)
	if not specId then
		return
	end

	local specInfo = specInfoBySpecId[specId]

	if not specInfo or not specInfo.KickCd then
		return
	end

	CreateKickEntry(specInfo.KickCd, kickIcon)
end

local function Kicked()
	CreateKickEntry(minKickCooldown, kickIcon)
end

local function OnFriendlyUnitEvent(unit, _, event, ...)
	if paused then
		return
	end

	if event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START" or event == "UNIT_SPELLCAST_EMPOWER_START" then
		kickedByUnits[unit] = false
	elseif event == "UNIT_SPELLCAST_INTERRUPTED" or event == "UNIT_SPELLCAST_CHANNEL_STOP" then
		if kickedByUnits[unit] then
			return
		end

		local kickedBy = select(4, ...)
		if not kickedBy then
			return
		end

		kickedByUnits[unit] = true
		Kicked()
	elseif event == "UNIT_SPELLCAST_EMPOWER_STOP" then
		if kickedByUnits[unit] then
			return
		end

		-- interruptedBy is arg 5 (arg 4 is "complete")
		local kickedBy = select(5, ...)
		if not kickedBy then
			return
		end

		kickedByUnits[unit] = true
		Kicked()
	end
end

local function UpdateMinKickCooldown()
	local minCd = 15
	local found = false

	local specs = GetNumArenaOpponentSpecs()

	for i = 1, specs do
		local specId = GetArenaOpponentSpec(i)
		if specId and specId > 0 then
			local info = specInfoBySpecId[specId]
			local cd = info and info.KickCd
			if cd then
				if not found or cd < minCd then
					minCd = cd
				end
				found = true
			end
		end
	end

	minKickCooldown = found and minCd or 15
end

local function OnArenaPrep()
	UpdateMinKickCooldown()
	ClearIcons()
end

local function Disable()
	if not enabled then
		return
	end

	for _, unit in ipairs(friendlyUnitsToWatch) do
		local frame = partyUnitsEventsFrames[unit]
		if frame then
			frame:UnregisterEvent("UNIT_SPELLCAST_START")
			frame:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTED")
			frame:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_START")
			frame:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
			frame:UnregisterEvent("UNIT_SPELLCAST_EMPOWER_START")
			frame:UnregisterEvent("UNIT_SPELLCAST_EMPOWER_STOP")
			frame:SetScript("OnEvent", nil)
		end
		kickedByUnits[unit] = nil
	end

	ClearIcons()

	if kickBar.Anchor then
		kickBar.Anchor:Hide()
	end

	enabled = false
end

local function Enable()
	if enabled then
		return
	end

	for _, unit in ipairs(friendlyUnitsToWatch) do
		local frame = partyUnitsEventsFrames[unit]
		if frame then
			frame:RegisterUnitEvent("UNIT_SPELLCAST_START", unit)
			frame:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", unit)
			frame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", unit)
			frame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", unit)
			frame:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_START", unit)
			frame:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_STOP", unit)
			frame:SetScript("OnEvent", function(...)
				OnFriendlyUnitEvent(unit, ...)
			end)
		end
	end

	local options = db.Modules.KickTimerModule
	local relativeTo = _G[options.RelativeTo] or UIParent
	kickBar.Anchor:ClearAllPoints()
	kickBar.Anchor:SetPoint(options.Point, relativeTo, options.RelativePoint, options.Offset.X, options.Offset.Y)
	kickBar.Anchor:Show()

	enabled = true
end

local function EnableDisable()
	-- don't do a moduleUtil check here, as we cover that inside IsEnabledForPlayer
	-- and we'd end up with a falsey response as the kick timer has different enabled values
	if not M:IsEnabledForPlayer(db.Modules.KickTimerModule) then
		Disable()
		return
	end

	if not IsArena() then
		Disable()
		return
	end

	Enable()
end

local function OnEnteringWorld()
	EnableDisable()

	-- always prep event if disabled, as they might re-enable before gates open
	if IsArena() then
		OnArenaPrep()
	end
end

local function ShowTestIcons()
	-- Cancel all active timers but don't reset slots yet
	for _, slotData in pairs(kickBar.ActiveSlots) do
		if slotData.Timer then
			slotData.Timer:Cancel()
		end
	end
	wipe(kickBar.ActiveSlots)

	-- Show test kicks: mage, hunter, rogue
	KickedBySpec(62) -- mage
	KickedBySpec(254) -- hunter
	KickedBySpec(259) -- rogue

	-- Clear any unused slots beyond the test icons
	local testIconCount = 3
	if kickBar.Container then
		for i = testIconCount + 1, kickBar.Container.Count do
			kickBar.Container:SetSlotUnused(i)
		end
	end
end

---@param options KickTimerModuleOptions
function M:IsEnabledForPlayer(options)
	if not options or not options.Enabled then
		return false
	end

	-- nothing toggled on
	if not (options.Enabled.Always or options.Enabled.Caster or options.Enabled.Healer) then
		return false
	end

	if options.Enabled.Always then
		return true
	end

	local specId = GetPlayerSpecId()
	if not specId then
		-- no data, just assume enabled in this case
		return true
	end

	local info = specInfoBySpecId[specId]
	if not info then
		return false
	end

	if options.Enabled.Healer and info.IsHealer then
		return true
	end

	if options.Enabled.Caster and info.IsCaster then
		return true
	end

	return false
end

local function Pause()
	paused = true
end

local function Resume()
	paused = false
end

function M:StartTesting()
	testModeActive = true
	Pause()
	M:Refresh()

	local container = kickBar.Anchor

	if not container then
		return
	end

	container:SetMovable(true)
	container:EnableMouse(true)
	container:Show()
end

function M:StopTesting()
	testModeActive = false
	Resume()
	ClearIcons()
	M:Refresh()

	local container = kickBar.Anchor

	if not container then
		return
	end

	container:SetMovable(false)
	container:EnableMouse(false)
	container:Hide()
end

function M:Refresh()
	EnableDisable()

	-- Apply icon options even if already enabled (for config changes)
	ApplyKickBarIconOptions()

	PositionKickBar()

	local container = kickBar.Anchor

	if not container then
		return
	end

	if not M:IsEnabledForPlayer(db.Modules.KickTimerModule) then
		ClearIcons()
		container:Hide()
		return
	end

	if testModeActive then
		ShowTestIcons()
	end
end

function M:Init()
	db = mini:GetSavedVars()

	CreateKickBar()

	for _, unit in ipairs(friendlyUnitsToWatch) do
		partyUnitsEventsFrames[unit] = CreateFrame("Frame")
	end

	-- always populate even if disabled, as they might re-enable during arena
	matchEventsFrame = CreateFrame("Frame")
	matchEventsFrame:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")
	matchEventsFrame:SetScript("OnEvent", OnArenaPrep)

	worldEventsFrame = CreateFrame("Frame")
	worldEventsFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	worldEventsFrame:SetScript("OnEvent", OnEnteringWorld)

	playerSpecEventsFrame = CreateFrame("Frame")
	playerSpecEventsFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
	playerSpecEventsFrame:SetScript("OnEvent", function(_, event, ...)
		if event == "PLAYER_SPECIALIZATION_CHANGED" then
			local unit = ...
			if unit == "player" then
				M:Refresh()
			end
		end
	end)

	M:Refresh()
end

---@class KickBar
---@field Container IconSlotContainer?
---@field Anchor table?
---@field ActiveSlots table<number, {Key: number, Timer: table}>
---@field MaxSlots number