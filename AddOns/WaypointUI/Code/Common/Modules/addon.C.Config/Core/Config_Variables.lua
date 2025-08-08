---@class addon
local addon = select(2, ...)
local CallbackRegistry = addon.C.CallbackRegistry.Script
local PrefabRegistry = addon.C.PrefabRegistry.Script
local TagManager = addon.C.TagManager.Script
local L = addon.C.AddonInfo.Locales
local NS = addon.C.Config; addon.C.Config = NS

--------------------------------

NS.Variables = {}

--------------------------------

function NS.Variables:Load()
	--------------------------------
	-- VARIABLES
	--------------------------------

	do -- CONSTANTS
		do -- SCALE
			NS.Variables.NAVIGATION_BUTTON_HEIGHT = 35
			NS.Variables.RATIO_REFERENCE = 1000

			--------------------------------

			do -- FUNCTIONS
				function NS.Variables:RATIO(level)
					return NS.Variables.RATIO_REFERENCE / addon.C.Variables:RAW_RATIO(level)
				end
			end
		end

		do -- MAIN
			NS.Variables.PATH = addon.CS:GetCommonPath() .. "Art/Config"

			NS.Variables.FRAME_STRATA = "HIGH"
			NS.Variables.FRAME_LEVEL = 1
			NS.Variables.FRAME_LEVEL_MAX = 999
		end

		do -- PADDING
			NS.Variables.PADDING = NS.Variables:RATIO(8)
		end
	end

	do -- MAIN
		NS.Variables.ConfigReady = false
		NS.Variables.CurrentTab = nil
	end

	do -- REFERENCES
		NS.Variables.Frame = nil
		NS.Variables.Tabs = {}
		NS.Variables.TabButtons = {}
	end

	--------------------------------
	-- EVENTS
	--------------------------------
end
