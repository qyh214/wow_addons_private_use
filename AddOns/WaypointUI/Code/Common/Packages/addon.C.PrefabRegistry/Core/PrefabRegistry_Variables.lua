---@class addon
local addon = select(2, ...)
local NS = addon.C.PrefabRegistry; addon.C.PrefabRegistry = NS

--------------------------------

NS.Variables = {}

--------------------------------

function NS.Variables:Load()
	--------------------------------
	-- VARIABLES
	--------------------------------

	do -- MAIN
		NS.Variables.Prefabs = {}
		NS.Variables.PrefabVariables = {}
	end

	do -- CONSTANTS

	end
end
