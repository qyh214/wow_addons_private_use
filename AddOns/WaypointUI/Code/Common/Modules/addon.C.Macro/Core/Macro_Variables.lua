---@class addon
local addon = select(2, ...)
local CallbackRegistry = addon.C.CallbackRegistry.Script
local PrefabRegistry = addon.C.PrefabRegistry.Script
local TagManager = addon.C.TagManager.Script
local L = addon.C.AddonInfo.Locales
local NS = addon.C.Macro; addon.C.Macro = NS

--------------------------------

NS.Variables = {}

--------------------------------

function NS.Variables:Load()
	--------------------------------
	-- VARIABLES
	--------------------------------

	do -- MAIN

	end

	do -- CONSTANTS
		NS.Variables.MACRO_INDEX_MIN = 1
		NS.Variables.MACRO_INDEX_MAX = 138
	end
end
