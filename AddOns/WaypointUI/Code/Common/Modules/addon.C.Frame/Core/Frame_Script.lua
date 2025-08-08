---@class addon
local addon = select(2, ...)
local CallbackRegistry = addon.C.CallbackRegistry.Script
local PrefabRegistry = addon.C.PrefabRegistry.Script
local TagManager = addon.C.TagManager.Script
local L = addon.C.AddonInfo.Locales
local NS = addon.C.Frame; addon.C.Frame = NS

--------------------------------

NS.Script = {}

--------------------------------

function NS.Script:Load()
	--------------------------------
	-- REFERENCES
	--------------------------------

	local Frame = addon.C.AddonInfo.Variables.General.ADDON_FRAME
	local Callback = NS.Script; NS.Script = Callback

	--------------------------------
	-- FUNCTIONS (FRAME)
	--------------------------------

	--------------------------------
	-- FUNCTIONS (MAIN)
	--------------------------------

	--------------------------------
	-- FUNCTIONS (ANIMATION)
	--------------------------------

	--------------------------------
	-- EVENTS
	--------------------------------

	do
		CallbackRegistry:Add("EVENT_CINEMATIC_START", function()
			Frame:Hide()
		end)

		CallbackRegistry:Add("EVENT_CINEMATIC_STOP", function()
			Frame:Show()
		end)
	end

	--------------------------------
	-- SETUP
	--------------------------------
end
