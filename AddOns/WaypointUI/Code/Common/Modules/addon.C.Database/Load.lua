---@class addon
local addon = select(2, ...)
local CallbackRegistry = addon.C.CallbackRegistry.Script
local PrefabRegistry = addon.C.PrefabRegistry.Script
local TagManager = addon.C.TagManager.Script
local L = addon.C.AddonInfo.Locales

--------------------------------

addon.C.Database = {}
local NS = addon.C.Database; addon.C.Database = NS

--------------------------------

function NS:Load()
	local function Variables()
		NS.Variables:Load()
	end

	local function Modules()
		NS.Script:Load()
	end

	local function Submodules()
		NS.Migration:Load()
	end

	--------------------------------

	Variables()
	Modules()
	C_Timer.After(.1, Submodules)
end
