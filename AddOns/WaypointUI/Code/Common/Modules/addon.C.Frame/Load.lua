---@class addon
local addon = select(2, ...)

--------------------------------

addon.C.Frame = {}
local NS = addon.C.Frame; addon.C.Frame = NS

--------------------------------

function NS:Load()
	local function Variables()
		NS.Variables:Load()
	end

	local function Modules()
		NS.Elements:Load()
		NS.Script:Load()
	end

	local function Submodules()
		NS.GameTooltip:Load()
		NS.ContextMenu:Load()
	end

	--------------------------------

	Variables()
	Modules()
	C_Timer.After(.1, Submodules)
end
