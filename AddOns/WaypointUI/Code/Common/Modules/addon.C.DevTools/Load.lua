---@class addon
local addon = select(2, ...)

--------------------------------

addon.C.DevTools = {}
local NS = addon.C.DevTools; addon.C.DevTools = NS

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
