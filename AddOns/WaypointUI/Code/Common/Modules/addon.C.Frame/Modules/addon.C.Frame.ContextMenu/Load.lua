---@class addon
local addon = select(2, ...)
local CallbackRegistry = addon.C.CallbackRegistry.Script

--------------------------------

addon.C.Frame.ContextMenu = {}
local NS = addon.C.Frame.ContextMenu; addon.C.Frame.ContextMenu = NS

--------------------------------

function NS:Load()
	local function Variables()
		NS.Variables:Load()
	end

	local function Modules()
		NS.Elements:Load()
		NS.Script:Load()
	end

	local function Prefabs()
		NS.Prefabs:Load()
	end

	--------------------------------

	Variables()
	Prefabs()
	Modules()
end
