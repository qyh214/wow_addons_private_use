---@class addon
local addon = select(2, ...)
local NS = addon.C.CallbackRegistry; addon.C.CallbackRegistry = NS

--------------------------------

NS.Variables = {}

--------------------------------

function NS.Variables:Load()
	--------------------------------
	-- VARIABLES
	--------------------------------

	do -- MAIN
		NS.Variables.Callbacks = {}
	end

	do -- CONSTANTS

	end
end
