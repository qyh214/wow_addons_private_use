---@class addon
local addon = select(2, ...)
local CallbackRegistry = addon.C.CallbackRegistry.Script
local PrefabRegistry = addon.C.PrefabRegistry.Script
local TagManager = addon.C.TagManager.Script
local L = addon.C.AddonInfo.Locales

--------------------------------

addon.Query = {}
local NS = addon.Query; addon.Query = NS

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
