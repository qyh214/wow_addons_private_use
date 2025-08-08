---@class addon
local addon = select(2, ...)

--------------------------------

addon.C.WoWClient = {}
local NS = addon.C.WoWClient; addon.C.WoWClient = NS

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
