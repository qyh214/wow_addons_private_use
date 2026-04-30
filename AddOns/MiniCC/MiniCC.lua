---@type string, Addon
local _, addon = ...
local mini = addon.Core.Framework
local L = addon.L
local instanceOptions = addon.Core.InstanceOptions
local scheduler = addon.Utils.Scheduler
local frames = addon.Core.Frames
local config = addon.Config
local migrator = addon.Config.Migrator
local testModeManager = addon.Modules.TestModeManager
local modules = {
	addon.Modules.CrowdControlModule,
	addon.Modules.HealerCrowdControlModule,
	addon.Modules.PortraitModule,
	addon.Modules.AlertsModule,
	addon.Modules.NameplatesModule,
	addon.Modules.KickTimerModule,
	addon.Modules.FriendlyIndicatorModule,
	addon.Modules.PrecogGuesserModule,
	addon.Modules.Cooldowns.Talents,
	addon.Core.TrinketsTracker,
	addon.Modules.FriendlyCooldownTrackerModule,
	addon.Modules.EnemyCooldownTrackerModule,
}
local eventsFrame
local db

local function NotifyChanges()
	if db.NotifiedChanges then
		return
	end

	local title = L["MiniCC - What's New?"]
	db.NotifiedChanges = true

	if db.Version == 6 then
		mini:ShowDialog({
			Title = title,
			Text = table.concat(db.WhatsNew, "\n"),
		})
	elseif db.Version == 7 then
		mini:ShowDialog({
			Title = title,
			Text = table.concat({
				"- CC icons in player/target/focus portraits (beta only).",
				"- New option to colour the glow based on the dispel type.",
			}, "\n"),
		})
	elseif db.Version == 8 then
		mini:ShowDialog({
			Title = title,
			Text = table.concat({
				"- Portrait icons now supported in prepatch (was beta only).",
				"- Included important spells (defensives/offensives) in portrait icons, not just CC.",
			}, "\n"),
		})
	elseif db.Version == 9 then
		mini:ShowDialog({
			Title = title,
			Text = "- New spell alerts bar that shows enemy cooldowns.",
		})
	elseif db.Version >= 10 then
		local whatsNew = db.WhatsNew

		if not whatsNew then
			return
		end

		local text = table.concat(whatsNew, "\n")

		if text and text ~= "" then
			mini:ShowDialog({
				Title = title,
				Text = text,
			})
		end
	end

	db.WhatsNew = {}
end

local function OnEvent(_, event)
	if event == "PLAYER_REGEN_DISABLED" then
		if testModeManager:IsActive() then
			testModeManager:StopTesting()
			addon:Refresh()
		end
	elseif event == "PLAYER_LOGIN" then
		if migrator:RunDeferredMigrations(db) then
			local tabController = addon.Config.TabController
			if tabController then
				local ccPanel = tabController:GetContent("CC")
				if ccPanel and ccPanel.MiniRefresh then
					ccPanel:MiniRefresh()
				end
			end
		end
	elseif event == "PLAYER_ENTERING_WORLD" then
		NotifyChanges()
		addon:Refresh()
	end
end

local function OnAddonLoaded()
	local savedVars = MiniCCDB
	L:ApplyLocale(savedVars and savedVars.LocaleOverride or GetLocale())

	config:Init()
	scheduler:Init()
	frames:Init()
	addon.Utils.ModuleUtil:Init()
	addon.Core.ProfileManager:Init()

	for _, module in ipairs(modules) do
		module:Init()
	end

	testModeManager:Init()

	eventsFrame = CreateFrame("Frame")
	eventsFrame:SetScript("OnEvent", OnEvent)
	eventsFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
	eventsFrame:RegisterEvent("PLAYER_LOGIN")
	eventsFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

	db = mini:GetSavedVars()
end

function addon:Refresh()
	if InCombatLockdown() then
		scheduler:RunWhenCombatEnds(function()
			addon:Refresh()
		end, "Refresh")
		return
	end

	for _, module in ipairs(modules) do
		module:Refresh()
	end
end

---@param isRaid boolean?
addon.CurrentTestIsRaid = false

function addon:ToggleTest(isRaid)
	if testModeManager:IsActive() then
		testModeManager:StopTesting()
	else
		testModeManager:StartTesting(isRaid ~= nil and isRaid or self.CurrentTestIsRaid)
	end

	addon:Refresh()
end

---@param isRaid boolean?
function addon:TestWithOptions(isRaid)
	if not testModeManager:IsActive() then
		testModeManager:StartTesting(isRaid)
		return
	end

	instanceOptions:SetTestIsRaid(isRaid)
	addon:Refresh()
end

function addon:IsTestActive()
	return testModeManager:IsActive()
end

mini:WaitForAddonLoad(OnAddonLoaded)

---@class Addon
---@field L Localization
---@field Utils Utils
---@field Core Core
---@field Config Config
---@field Modules Modules
---@field Refresh fun(self: table)
---@field ToggleTest fun(self: table, isRaid: boolean?)
---@field TestWithOptions fun(self: table, isRaid: boolean?)
---@field IsTestActive fun(self: table): boolean

---@class Utils
---@field Scheduler SchedulerUtil
---@field Units UnitUtil
---@field Array ArrayUtil
---@field FontUtil FontUtil
---@field ModuleUtil ModuleUtil
---@field ModuleName ModuleName
---@field WoWEx WoWEx
---@field PvPTalentSync PvPTalentSync

---@class Core
---@field Framework MiniFramework
---@field Frames Frames
---@field UnitAuraWatcher UnitAuraWatcher
---@field Inspector Inspector
---@field IconSlotContainer IconSlotContainer
---@field InstanceOptions InstanceOptions
---@field TrinketsTracker TrinketsTracker

---@class Cooldowns
---@field PvPTalentSync PvPTalentSync
---@field Talents CooldownTalents
---@field Rules CooldownRules
---@field Brain CooldownBrain

---@class FriendlyCooldowns
---@field Observer FriendlyCooldownObserver
---@field Display FriendlyCooldownDisplay
---@field Module FriendlyCooldownTrackerModule

---@class EnemyCooldowns
---@field Observer EnemyCooldownObserver
---@field Display EnemyCooldownDisplay
---@field Module EnemyCooldownTrackerModule

---@class Modules
---@field TestModeManager TestModeManager
---@field PortraitModule PortraitModule
---@field HealerCrowdControlModule HealerCrowdControlModule
---@field NameplatesModule NameplatesModule
---@field KickTimerModule KickTimerModule
---@field AlertsModule AlertsModule
---@field CrowdControlModule CrowdControlModule
---@field FriendlyIndicatorModule FriendlyIndicatorModule
---@field PrecogGuesserModule PrecogGuesserModule
---@field FriendlyCooldownTrackerModule FriendlyCooldownTrackerModule
---@field EnemyCooldownTrackerModule EnemyCooldownTrackerModule
---@field Cooldowns Cooldowns
---@field FriendlyCooldowns FriendlyCooldowns
---@field EnemyCooldowns EnemyCooldowns

---@class IModule
---@field Init fun(self: IModule) Initialises the module to be ready for use.
---@field Refresh fun(self: IModule) Refreshes the module to be in sync with config settings and world state. Must perform the least amount of work possible as this gets called a lot.
