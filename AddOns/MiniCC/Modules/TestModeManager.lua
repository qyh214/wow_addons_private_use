---@type string, Addon
local _, addon = ...
local frames = addon.Core.Frames
local instanceOptions = addon.Core.InstanceOptions
local testModules = {
	addon.Modules.CrowdControlModule,
	addon.Modules.HealerCrowdControlModule,
	addon.Modules.PortraitModule,
	addon.Modules.AlertsModule,
	addon.Modules.NameplatesModule,
	addon.Modules.KickTimerModule,
	addon.Modules.FriendlyIndicatorModule,
	addon.Modules.PrecogGuesserModule,
	addon.Modules.FriendlyCooldownTrackerModule,
	addon.Modules.EnemyCooldownTrackerModule,
}
local active = false

---@class TestModeManager
local M = {}
addon.Modules.TestModeManager = M

function M:IsActive()
	return active
end

function M:StopTesting()
	instanceOptions:SetTestIsRaid(nil)

	-- Hide test party frames
	local testPartyFrames = frames:GetTestFrames()
	if testPartyFrames then
		for _, frame in ipairs(testPartyFrames) do
			frame:Hide()
		end
	end

	local testFramesContainer = frames:GetTestFrameContainer()
	if testFramesContainer then
		testFramesContainer:Hide()
	end

	-- Stop all module test modes
	for _, module in ipairs(testModules) do
		module:StopTesting()
	end

	active = false
end

---@param isRaid boolean?
function M:StartTesting(isRaid)
	if active then
		return
	end

	active = true

	instanceOptions:SetTestIsRaid(isRaid)

	-- Show test party frames if no real frames are visible
	local realFrames = frames:GetAll(true, false) -- Get only real frames
	local hasVisibleRealFrames = false

	for _, frame in ipairs(realFrames) do
		if frame:IsVisible() then
			hasVisibleRealFrames = true
			break
		end
	end

	if not hasVisibleRealFrames then
		-- Show test party frames
		local testPartyFrames = frames:GetTestFrames()
		if testPartyFrames then
			for _, frame in ipairs(testPartyFrames) do
				frame:Show()
			end
		end

		local testFramesContainer = frames:GetTestFrameContainer()
		if testFramesContainer then
			testFramesContainer:Show()
		end
	end

	for _, module in ipairs(testModules) do
		module:StartTesting()
	end
end

function M:Init() end

---@class TestSpell
---@field SpellId number
---@field DispelColor table?
