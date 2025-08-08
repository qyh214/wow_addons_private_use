---@class addon
local addon = select(2, ...)
local CallbackRegistry = addon.C.CallbackRegistry.Script
local PrefabRegistry = addon.C.PrefabRegistry.Script
local TagManager = addon.C.TagManager.Script
local L = addon.C.AddonInfo.Locales

--------------------------------

addon.Support = {}
local NS = addon.Support; addon.Support = NS

--------------------------------

function NS:Load()
	local function Modules()

	end

	--------------------------------

	Modules()
end
