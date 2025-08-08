---@class addon
local addon = select(2, ...)

--------------------------------

addon.C.TagManager = {}
local NS = addon.C.TagManager; addon.C.TagManager = NS

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
