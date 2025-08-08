---@class addon
local addon = select(2, ...)

--------------------------------

addon.C.Sound = {}
local NS = addon.C.Sound; addon.C.Sound = NS

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
