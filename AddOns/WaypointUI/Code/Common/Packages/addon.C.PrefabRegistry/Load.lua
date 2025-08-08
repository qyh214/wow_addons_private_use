---@class addon
local addon = select(2, ...)

--------------------------------

addon.C.PrefabRegistry = {}
local NS = addon.C.PrefabRegistry; addon.C.PrefabRegistry = NS

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
