---@class addon
local addon = select(2, ...)

--------------------------------

addon.C.Initializer = {}
local NS = addon.C.Initializer; addon.C.Initializer = NS

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
