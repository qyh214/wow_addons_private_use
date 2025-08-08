---@class addon
local addon = select(2, ...)
local NS = addon.C.AddonInfo; addon.C.AddonInfo = NS

--------------------------------

NS.Variables = NS.Variables or {}
NS.Variables.Database = {}

--------------------------------
-- VARIABLES
--------------------------------

do -- MAIN

end

do  -- CONSTANTS
	do -- REFERENCES
		NS.Variables.Database.GLOBAL_REFERENCE = WaypointDB_Global
		NS.Variables.Database.LOCAL_REFERENCE = WaypointDB_Local
		NS.Variables.Database.GLOBAL_PERSISTENT_REFERENCE = WaypointDB_Global_Persistent
		NS.Variables.Database.LOCAL_PERSISTENT_REFERENCE = WaypointDB_Local_Persistent

		NS.Variables.Database.GLOBAL_NAME = "WaypointDB_Global"
		NS.Variables.Database.LOCAL_NAME = "WaypointDB_Local"
		NS.Variables.Database.GLOBAL_PERSISTENT_NAME = "WaypointDB_Global_Persistent"
		NS.Variables.Database.LOCAL_PERSISTENT_NAME = "WaypointDB_Local_Persistent"
	end

	do -- DEFAULTS
		NS.Variables.Database.GLOBAL_DEFAULT = {
			profile = {
				-- Common Framework (Don't delete)
				C_FONT_CUSTOM = {},

				-- WAYPOINT SYSTEM
				WS_TYPE = 1,
				WS_RIGHT_CLICK_TO_CLEAR = true,
				WS_DISTANCE_TRANSITION = 225,
				WS_DISTANCE_HIDE = 25,
				WS_DISTANCE_TEXT_TYPE = 2,
				WS_PINPOINT_INFO = true,
				WS_PINPOINT_INFO_EXTENDED = false,
				WS_NAVIGATOR = true,

				-- APPEARANCE
				APP_WAYPOINT_SCALE = 1,
				APP_WAYPOINT_SCALE_MIN = .25,
				APP_WAYPOINT_SCALE_MAX = 1.5,
				APP_WAYPOINT_BEAM = true,
				APP_WAYPOINT_BEAM_ALPHA = 1,
				APP_WAYPOINT_DISTANCE_TEXT = true,
				APP_WAYPOINT_DISTANCE_TEXT_SCALE = 1,
				APP_WAYPOINT_DISTANCE_TEXT_ALPHA = .5,
				APP_PINPOINT_SCALE = 1,
				APP_NAVIGATOR_SCALE = 1,
				APP_NAVIGATOR_ALPHA = 1,
				APP_NAVIGATOR_DISTANCE = 1,
				APP_COLOR = false,
				APP_COLOR_QUEST_INCOMPLETE_TINT = false,
				APP_COLOR_QUEST_INCOMPLETE = { r = addon.CS:GetSharedColor().RGB_PING_QUEST_NEUTRAL.r, g = addon.CS:GetSharedColor().RGB_PING_QUEST_NEUTRAL.g, b = addon.CS:GetSharedColor().RGB_PING_QUEST_NEUTRAL.b, a = 1 },
				APP_COLOR_QUEST_COMPLETE_TINT = false,
				APP_COLOR_QUEST_COMPLETE = { r = addon.CS:GetSharedColor().RGB_PING_QUEST_NORMAL.r, g = addon.CS:GetSharedColor().RGB_PING_QUEST_NORMAL.g, b = addon.CS:GetSharedColor().RGB_PING_QUEST_NORMAL.b, a = 1 },
				APP_COLOR_QUEST_COMPLETE_REPEATABLE_TINT = false,
				APP_COLOR_QUEST_COMPLETE_REPEATABLE = { r = addon.CS:GetSharedColor().RGB_PING_QUEST_REPEATABLE.r, g = addon.CS:GetSharedColor().RGB_PING_QUEST_REPEATABLE.g, b = addon.CS:GetSharedColor().RGB_PING_QUEST_REPEATABLE.b, a = 1 },
				APP_COLOR_QUEST_COMPLETE_IMPORTANT_TINT = false,
				APP_COLOR_QUEST_COMPLETE_IMPORTANT = { r = addon.CS:GetSharedColor().RGB_PING_QUEST_IMPORTANT.r, g = addon.CS:GetSharedColor().RGB_PING_QUEST_IMPORTANT.g, b = addon.CS:GetSharedColor().RGB_PING_QUEST_IMPORTANT.b, a = 1 },
				APP_COLOR_NEUTRAL_TINT = true,
				APP_COLOR_NEUTRAL = { r = addon.CS:GetSharedColor().RGB_PING_NEUTRAL.r, g = addon.CS:GetSharedColor().RGB_PING_NEUTRAL.g, b = addon.CS:GetSharedColor().RGB_PING_NEUTRAL.b, a = 1 },

				-- AUDIO
				AUDIO_GLOBAL = true,
				AUDIO_CUSTOM = false,
				AUDIO_CUSTOM_WAYPOINT_SHOW = SOUNDKIT.UI_RUNECARVING_OPEN_MAIN_WINDOW,
				AUDIO_CUSTOM_PINPOINT_SHOW = SOUNDKIT.UI_RUNECARVING_CLOSE_MAIN_WINDOW,

				-- PREFERENCES
				PREF_METRIC = false,
			},
		}

		NS.Variables.Database.LOCAL_DEFAULT = {
			profile = {

			}
		}

		NS.Variables.Database.GLOBAL_PERSISTENT_DEFAULT = {
			profile = {

			}
		}

		NS.Variables.Database.LOCAL_PERSISTENT_DEFAULT = {
			profile = {
				SAVED_WAY = nil
			}
		}
	end

	do -- MIGRATION
		--------------------------------
		-- EXAMPLE
		--------------------------------

		-- 	[1] = {
		-- 		from = "KEY_1",
		-- 		to = "KEY_2"
		-- 	}

		NS.Variables.Database.MIGRATION_GLOBAL = {
			-- < 0.0.1 (Beta 9)
			{
				from = "WS_PINPOINT_DETAIL",
				to = "WS_PINPOINT_INFO_EXTENDED"
			},
			-- < 0.0.1 (Beta 8)
			{
				from = "WS_WAYPOINT_SCALE",
				to = "APP_WAYPOINT_SCALE"
			},
			{
				from = "WS_WAYPOINT_MIN_SCALE",
				to = "APP_WAYPOINT_SCALE_MIN"
			},
			{
				from = "WS_WAYPOINT_MAX_SCALE",
				to = "APP_WAYPOINT_SCALE_MAX"
			},
			{
				from = "WS_WAYPOINT_DISTANCE_TEXT_ALPHA",
				to = "APP_WAYPOINT_DISTANCE_TEXT_ALPHA"
			},
			{
				from = "WS_PINPOINT_SCALE",
				to = "APP_PINPOINT_SCALE"
			}
		}

		NS.Variables.Database.MIGRATION_LOCAL = {

		}

		NS.Variables.Database.MIGRATION_GLOBAL_PERSISTENT = {

		}

		NS.Variables.Database.MIGRATION_LOCAL_PERSISTENT = {

		}
	end
end
