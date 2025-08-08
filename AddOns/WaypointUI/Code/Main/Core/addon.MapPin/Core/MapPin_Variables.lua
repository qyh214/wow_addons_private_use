---@class addon
local addon = select(2, ...)
local CallbackRegistry = addon.C.CallbackRegistry.Script
local PrefabRegistry = addon.C.PrefabRegistry.Script
local TagManager = addon.C.TagManager.Script
local L = addon.C.AddonInfo.Locales
local NS = addon.MapPin; addon.MapPin = NS

--------------------------------

NS.Variables = {}

--------------------------------

function NS.Variables:Load()
	--------------------------------
	-- VARIABLES
	--------------------------------

	do -- MAIN
		NS.Variables.Way = {
			["name"] = nil,
			["mapID"] = nil,
			["x"] = nil,
			["y"] = nil,
		}
	end

	do -- CONSTANTS

	end
end
