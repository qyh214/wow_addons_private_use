-- $Id: Constants.lua 70 2017-07-02 14:53:21Z arith $
-----------------------------------------------------------------------
-- Upvalued Lua API.
-----------------------------------------------------------------------
-- Functions
local _G = getfenv(0)
-- Libraries
-- ----------------------------------------------------------------------------
-- AddOn namespace.
-- ----------------------------------------------------------------------------
local FOLDER_NAME, private = ...
private.addon_name = "HandyNotes_BrokenShore"

local LibStub = _G.LibStub
local L = LibStub("AceLocale-3.0"):GetLocale(private.addon_name)
private.descName = L["HandyNotes - Broken Shore"]
private.description = L["Shows the POIs in Broken Shore"]
private.pluginName = L["Broken Shore"]

local constants = {}
private.constants = constants

constants.defaults = {
	profile = {
		icon_scale = 1.5,
		icon_alpha = 1.0,
		query_server = true,
		show_entrance = true,
		show_ramp = true,
		show_rare = true,
		show_others = true, 
		show_note = true,
		show_treasure = true,
		show_shrine = true,
		show_infernalCores = true,
		show_tamer = true,
		show_netherPortals = true,
		ignore_InOutDoor = false,
		hide_completed = true,
		show_coords = false,
		showNodesOnContinentMap = false,
	},
	char = {
		hidden = {
			['*'] = {},
		},
	},
}

local OBJECTICONS = "Interface\\AddOns\\HandyNotes_BrokenShore\\Images\\OBJECTICONS"

constants.icon_texture = {
	flight 		= "Interface\\MINIMAP\\TRACKING\\FlightMaster",
	entrance 	= "Interface\\MINIMAP\\Suramar_Door_Icon",
	ramp 		= "Interface\\MINIMAP\\MiniMap-VignetteArrow",
	greenButton 	= { 
		icon = OBJECTICONS,
		tCoordLeft = 0.5, tCoordRight = 0.625, tCoordTop = 0, tCoordBottom = 0.125,
	},
	blueButton 	= {
		icon = OBJECTICONS,
		tCoordLeft = 0.125, tCoordRight = 0.25, tCoordTop = 0, tCoordBottom = 0.125,
	},
	redButton 	= {
		icon = OBJECTICONS,
		tCoordLeft = 0.25, tCoordRight = 0.375, tCoordTop = 0, tCoordBottom = 0.125,
	},
	yellowButton 	= {
		icon = OBJECTICONS,
		tCoordLeft = 0.125, tCoordRight = 0.25, tCoordTop = 0.5, tCoordBottom = 0.625,
	},
	portal 		= {
		icon = OBJECTICONS,
		tCoordLeft = 0.125, tCoordRight = 0.25, tCoordTop = 0.875, tCoordBottom = 1,
	},
	rare 		= {
		icon = OBJECTICONS,
		tCoordLeft = 0.875, tCoordRight = 1, tCoordTop = 0.75, tCoordBottom = 0.875,
	},
	treasure	= {
		icon = OBJECTICONS,
		tCoordLeft = 0.25, tCoordRight = 0.375, tCoordTop = 0.625, tCoordBottom = 0.75,
	},
	netherPortal	= {
		icon = OBJECTICONS,
		tCoordLeft = 0.5, tCoordRight = 0.625, tCoordTop = 0.75, tCoordBottom = 0.875,
	},
}

-- Define the default icon here
constants.defaultIcon = constants.icon_texture["entrance"]

constants.events = {
	"ZONE_CHANGED",
	"ZONE_CHANGED_INDOORS",
	-- Fires when stepping off of a world map object. 
	-- Appears to fire whenever the player has moved off of a structure 
	-- such as a bridge or building and onto terrain or another object.
	"NEW_WMO_CHUNK",
	"ENCOUNTER_LOOT_RECEIVED",
	"CLOSE_WORLD_MAP",
}
