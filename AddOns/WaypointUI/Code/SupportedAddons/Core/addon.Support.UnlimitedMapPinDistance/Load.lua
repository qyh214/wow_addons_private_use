---@class addon
local addon = select(2, ...)
local CallbackRegistry = addon.C.CallbackRegistry.Script
local PrefabRegistry = addon.C.PrefabRegistry.Script
local TagManager = addon.C.TagManager.Script
local L = addon.C.AddonInfo.Locales

--------------------------------

addon.Support.UnlimitedMapPinDistance = {}
local NS = addon.Support.UnlimitedMapPinDistance; addon.Support.UnlimitedMapPinDistance = NS

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

C_Timer.After(addon.C.Variables.INIT_DELAY_LAST, function()
	if addon.C.WoWClient.Script:IsAddOnLoaded("UnlimitedMapPinDistance") then
		NS:Load()
	end
end)
