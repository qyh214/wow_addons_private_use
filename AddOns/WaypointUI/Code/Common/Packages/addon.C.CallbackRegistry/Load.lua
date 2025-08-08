---@class addon
local addon = select(2, ...)

--------------------------------

addon.C.CallbackRegistry = {}
local NS = addon.C.CallbackRegistry; addon.C.CallbackRegistry = NS

--------------------------------

function NS:Load()
	local function Variables()
		NS.Variables:Load()
	end

	local function Modules()
		NS.Script:Load()
	end

	--------------------------------

	Variables()
	Modules()
end
