---@type string, Addon
local addonName, addon = ...
local mini = addon.Core.Framework
local wowEx = addon.Utils.WoWEx
local unitWatcher = addon.Core.UnitAuraWatcher
local iconSlotContainer = addon.Core.IconSlotContainer
local moduleUtil = addon.Utils.ModuleUtil
local moduleName = addon.Utils.ModuleName
local testModeActive = false
local paused = false
local classHasPrecog
---@type table<number, any>
local auraAlphas = {}
local precogCurve
---@type Db
local db
---@type table
local anchor
---@type IconSlotContainer
local container
---@type Watcher
local watcher
---@type TestSpell
local testSpell

---@class PrecogGuesserModule : IModule
local M = {}
addon.Modules.PrecogGuesserModule = M

local function UpdateAnchorSize()
	if not anchor or not container then
		return
	end

	local options = db.Modules.PrecogGuesserModule
	local iconSize = tonumber(options.Icons.Size) or 40
	anchor:SetSize(iconSize, iconSize)
end

local function ScanAndDisplay()
	if paused then
		return
	end

	local importantState = watcher:GetImportantState()

	if #importantState == 0 then
		container:ResetAllSlots()
		anchor:Hide()
		auraAlphas = {}
		return
	end

	-- Clean up cached alphas for auras that are no longer active
	local activeIds = {}
	for _, entry in ipairs(importantState) do
		activeIds[entry.AuraInstanceID] = true
	end
	for id in pairs(auraAlphas) do
		if not activeIds[id] then
			auraAlphas[id] = nil
		end
	end

	local options = db.Modules.PrecogGuesserModule
	if not options then
		return
	end

	local iconsReverse = options.Icons.ReverseCooldown
	local iconsGlow = options.Icons.Glow

	container:ResetAllSlots()

	for i, entry in ipairs(importantState) do
		if entry.SpellIcon and entry.DurationObject then
			-- Evaluate alpha only once when the aura is first detected,
			-- because we need the total duration at the time of application.
			if auraAlphas[entry.AuraInstanceID] == nil then
				local durationInfo = C_UnitAuras.GetAuraDuration("player", entry.AuraInstanceID)
				auraAlphas[entry.AuraInstanceID] = durationInfo and durationInfo:EvaluateRemainingDuration(precogCurve)
			end

			container:SetSlot(1, {
				Texture = entry.SpellIcon,
				DurationObject = entry.DurationObject,
				Alpha = auraAlphas[entry.AuraInstanceID] or 0,
				ReverseCooldown = iconsReverse,
				Glow = iconsGlow,
				FontScale = db.FontScale,
				Layer = i,
			})
		end
	end

	anchor:Show()
end

local function RefreshTestIcons()
	local options = db.Modules.PrecogGuesserModule
	if not options then
		return
	end

	local texture = C_Spell.GetSpellTexture(testSpell.SpellId)

	if texture then
		container:SetSlot(1, {
			Texture = texture,
			DurationObject = wowEx:CreateDuration(GetTime(), 15),
			Alpha = true,
			ReverseCooldown = options.Icons.ReverseCooldown,
			Glow = options.Icons.Glow,
			FontScale = db.FontScale,
		})
	end
end

local function Pause()
	paused = true
end

local function Resume()
	paused = false
end

function M:StartTesting()
	Pause()
	testModeActive = true

	if anchor then
		anchor:EnableMouse(true)
		anchor:SetMovable(true)
		anchor:Show()
	end

	M:Refresh()
end

function M:StopTesting()
	testModeActive = false
	Resume()
	auraAlphas = {}

	if container then
		container:ResetAllSlots()
	end

	if anchor then
		anchor:EnableMouse(false)
		anchor:SetMovable(false)
		anchor:Hide()
	end
end

function M:Refresh()
	if not anchor or not container then
		return
	end

	local options = db.Modules.PrecogGuesserModule
	if not options then
		return
	end

	local moduleEnabled = moduleUtil:IsModuleEnabled(moduleName.PrecogGuesser) and classHasPrecog

	if moduleEnabled and not watcher:IsEnabled() then
		watcher:Enable()
	elseif not moduleEnabled and watcher:IsEnabled() then
		watcher:Disable()
		watcher:ClearState(true)
	end

	if not moduleEnabled then
		anchor:Hide()
		return
	end

	anchor:ClearAllPoints()
	anchor:SetPoint(
		options.Point,
		_G[options.RelativeTo] or UIParent,
		options.RelativePoint,
		options.Offset.X,
		options.Offset.Y
	)

	local iconSize = tonumber(options.Icons.Size) or 40
	container:SetIconSize(iconSize)
	container:SetCount(1)
	container:SetSpacing(db.IconSpacing or 2)

	UpdateAnchorSize()

	if testModeActive then
		anchor:Show()
		RefreshTestIcons()
	else
		ScanAndDisplay()
	end
end

function M:Init()
	db = mini:GetSavedVars()

	classHasPrecog = not ({
		WARRIOR = true,
		DEATHKNIGHT = true,
		ROGUE = true,
		DEMONHUNTER = true,
		HUNTER = true,
	})[UnitClassBase("player")]

	testSpell = { SpellId = 377360 }

	local options = db.Modules.PrecogGuesserModule

	anchor = CreateFrame("Frame", addonName .. "PrecogGuesser")
	anchor:Hide()
	anchor:EnableMouse(false)
	anchor:SetMovable(false)
	anchor:SetClampedToScreen(true)
	anchor:RegisterForDrag("LeftButton")
	anchor:SetIgnoreParentScale(true)
	anchor:SetScript("OnDragStart", function(anchorSelf)
		anchorSelf:StartMoving()
	end)
	anchor:SetScript("OnDragStop", function(anchorSelf)
		anchorSelf:StopMovingOrSizing()

		local point, relativeTo, relativePoint, x, y = anchorSelf:GetPoint()
		db.Modules.PrecogGuesserModule.Point = point
		db.Modules.PrecogGuesserModule.RelativePoint = relativePoint
		db.Modules.PrecogGuesserModule.RelativeTo = (relativeTo and relativeTo:GetName()) or "UIParent"
		db.Modules.PrecogGuesserModule.Offset.X = x
		db.Modules.PrecogGuesserModule.Offset.Y = y
	end)

	local iconSize = tonumber(options.Icons.Size) or 40
	container = iconSlotContainer:New(anchor, 1, iconSize, db.IconSpacing or 2, "Precognition", nil, "Precognition")
	container.Frame:SetPoint("CENTER", anchor, "CENTER", 0, 0)
	container.Frame:Show()

	precogCurve = C_CurveUtil.CreateCurve()
	precogCurve:SetType(Enum.LuaCurveType.Step)
	precogCurve:AddPoint(0, 0)
	-- precog is 4 seconds
	-- account for some lag, not sure if this is needed though
	precogCurve:AddPoint(3.7, 1)
	precogCurve:AddPoint(4, 1)
	precogCurve:AddPoint(4.1, 0)

	watcher = unitWatcher:New("player", nil, {
		Important = true,
		ImportantFilter = "HELPFUL|IMPORTANT|PLAYER",
	})

	watcher:RegisterCallback(function()
		ScanAndDisplay()
	end)

	M:Refresh()
end

---@class PrecogGuesserModule
---@field Init fun(self: PrecogGuesserModule)
---@field Refresh fun(self: PrecogGuesserModule)
---@field StartTesting fun(self: PrecogGuesserModule)
---@field StopTesting fun(self: PrecogGuesserModule)
