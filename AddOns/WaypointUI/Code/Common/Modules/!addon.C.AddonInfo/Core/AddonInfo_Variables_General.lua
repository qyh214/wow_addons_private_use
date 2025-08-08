---@class addon
local addon = select(2, ...)
local NS = addon.C.AddonInfo; addon.C.AddonInfo = NS

--------------------------------

NS.Variables = NS.Variables or {}
NS.Variables.General = {}

--------------------------------
-- VARIABLES
--------------------------------

do -- MAIN

end

do -- CONSTANTS
	do -- VERSION
		NS.Variables.General.VERSION_STRING = "0.0.3"
		NS.Variables.General.VERSION_NUMBER = 00000300 -- XX.XX.XX.XX
	end

	do -- GENERAL
		NS.Variables.General.NAME = "Waypoint UI"
		NS.Variables.General.IDENTIFIER = "WaypointUI"
		NS.Variables.General.REGISTRY_NAME = "WaypointUI"
		NS.Variables.General.ADDON_FRAME_NAME = "WaypointFrame"
		NS.Variables.General.ADDON_ICON = "Interface/AddOns/" .. NS.Variables.General.REGISTRY_NAME .. "/Art/Icons/logo-flat-light.png"
		NS.Variables.General.ADDON_ICON_ALT = "Interface/AddOns/" .. NS.Variables.General.REGISTRY_NAME .. "/Art/Icons/logo-flat-light.png"

		NS.Variables.General.ADDON_PATH = "Interface/AddOns/" .. NS.Variables.General.REGISTRY_NAME .. "/"
		NS.Variables.General.ADDON_PATH_FONT = "Interface/AddOns/" .. NS.Variables.General.REGISTRY_NAME .. "/Art/Fonts/"
		NS.Variables.General.ADDON_PATH_ELEMENT = "Interface/AddOns/" .. NS.Variables.General.REGISTRY_NAME .. "/Art/Elements/"
		NS.Variables.General.ADDON_PATH_SOUND = "Interface/AddOns/" .. NS.Variables.General.REGISTRY_NAME .. "/Art/Sounds/"
		NS.Variables.General.COMMON_PATH = "Interface/AddOns/" .. NS.Variables.General.REGISTRY_NAME .. "/Code/Common/"
		NS.Variables.General.COMMON_PATH_ART = "Interface/AddOns/" .. NS.Variables.General.REGISTRY_NAME .. "/Code/Common/Art/"

		NS.Variables.General.ADDON_FRAME = nil
		NS.Variables.General.COMMON_FRAME = nil
		NS.Variables.General.UI_SCALE = .75
	end

	do -- DEVELOPMENT
		NS.Variables.General.IS_DEVELOPER_MODE = false
	end
end
