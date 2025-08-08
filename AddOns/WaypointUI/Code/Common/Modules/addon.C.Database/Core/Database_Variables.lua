---@class addon
local addon = select(2, ...)
local CallbackRegistry = addon.C.CallbackRegistry.Script
local PrefabRegistry = addon.C.PrefabRegistry.Script
local TagManager = addon.C.TagManager.Script
local L = addon.C.AddonInfo.Locales
local NS = addon.C.Database; addon.C.Database = NS

--------------------------------

NS.Variables = {}

--------------------------------

function NS.Variables:Load()
	--------------------------------
	-- VARIABLES
	--------------------------------

	do -- MAIN
		NS.Variables.DB_GLOBAL = nil
		NS.Variables.DB_LOCAL = nil
		NS.Variables.DB_GLOBAL_PERSISTENT = nil
		NS.Variables.DB_LOCAL_PERSISTENT = nil
	end

	do -- CONSTANTS

	end
end
