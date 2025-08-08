---@class addon
local addon = select(2, ...)
local NS = addon.C.SharedVariables; addon.C.SharedVariables = NS

--------------------------------

NS.Color = {}

--------------------------------
-- VARIABLES
--------------------------------

do  -- MAIN

end

do   -- CONSTANTS
	do -- RGB
		NS.Color.RGB_WHITE = { r = 255 / 255, g = 255 / 255, b = 255 / 255 }
		NS.Color.RGB_BLACK = { r = 25 / 255, g = 25 / 255, b = 25 / 255 }
		NS.Color.RGB_ORANGE = { r = 255 / 255, g = 166 / 255, b = 0 / 255 }
		NS.Color.RGB_YELLOW = { r = 255 / 255, g = 204 / 255, b = 26 / 255 }
		NS.Color.RGB_GREEN = { r = 82 / 255, g = 204 / 255, b = 51 / 255 }
		NS.Color.RGB_GREEN_02 = { r = 82 / 255, g = 175 / 255, b = 51 / 255 }
		NS.Color.RGB_RED = { r = 208 / 255, g = 85 / 255, b = 85 / 255 }
		NS.Color.RGB_GRAY = { r = 157 / 255, g = 157 / 255, b = 157 / 255 }
		NS.Color.RGB_LIGHT_GRAY = { r = 205 / 255, g = 205 / 255, b = 205 / 255 }
		NS.Color.RGB_PROGRESS_GREEN = { r = 78 / 255, g = 144 / 255, b = 80 / 255 }
		NS.Color.RGB_PROGRESS_ORANGE = { r = 215 / 255, g = 154 / 255, b = 91 / 255 }
		NS.Color.RGB_PROGRESS_BRONZE = { r = 172 / 255, g = 150 / 255, b = 122 / 255 }

		NS.Color.RGB_STAT_INT = { r = 84 / 255, g = 54 / 255, b = 87 / 255 }
		NS.Color.RGB_STAT_STR = { r = 108 / 255, g = 56 / 255, b = 60 / 255 }
		NS.Color.RGB_STAT_AGL = { r = 100 / 255, g = 88 / 255, b = 75 / 255 }
		NS.Color.RGB_STAT_CRIT = { r = 87 / 255, g = 54 / 255, b = 54 / 255 }
		NS.Color.RGB_STAT_HASTE = { r = 75 / 255, g = 100 / 255, b = 85 / 255 }
		NS.Color.RGB_STAT_MASTERY = { r = 74 / 255, g = 55 / 255, b = 85 / 255 }
		NS.Color.RGB_STAT_VERS = { r = 75 / 255, g = 75 / 255, b = 75 / 255 }

		NS.Color.RGB_PING_NEUTRAL = { r = 255 / 255, g = 241 / 255, b = 180 / 255 }
		NS.Color.RGB_PING_QUEST_NORMAL = { r = 255 / 255, g = 255 / 255, b = 156 / 255 }
		NS.Color.RGB_PING_QUEST_REPEATABLE = { r = 158 / 255, g = 207 / 255, b = 245 / 255 }
		NS.Color.RGB_PING_QUEST_IMPORTANT = { r = 249 / 255, g = 196 / 255, b = 255 / 255 }
		NS.Color.RGB_PING_QUEST_NEUTRAL = { r = 175 / 255, g = 175 / 255, b = 175 / 255 }
	end

	do -- HEX
		NS.Color.RGB_WHITE_HEXCODE = "|cffFFFFFF"
		NS.Color.RGB_BLACK_HEXCODE = "|cff000000"
		NS.Color.RGB_ORANGE_HEXCODE = "|cffFFA500"
		NS.Color.RGB_YELLOW_HEXCODE = "|cffFFCC1A"
		NS.Color.RGB_GREEN_HEXCODE = "|cff54CB34"
		NS.Color.RGB_GREEN_02_HEXCODE = "|cff52AF33"
		NS.Color.RGB_RED_HEXCODE = "|cffD05555"
		NS.Color.RGB_GRAY_HEXCODE = "|cff9D9D9D"
		NS.Color.RGB_LIGHT_GRAY_HEXCODE = "|cffCDCDCD"
		NS.Color.RGB_PROGRESS_GREEN_HEXCODE = "|cff4E9050"
		NS.Color.RGB_PROGRESS_ORANGE_HEXCODE = "|cffD79A5B"
		NS.Color.RGB_PROGRESS_BRONZE_HEXCODE = "|cffAC967A"

		NS.Color.RGB_STAT_INT_HEXCODE = "|cff543657"
		NS.Color.RGB_STAT_STR_HEXCODE = "|cff6C383C"
		NS.Color.RGB_STAT_AGL_HEXCODE = "|cff64584B"
		NS.Color.RGB_STAT_CRIT_HEXCODE = "|cff573636"
		NS.Color.RGB_STAT_HASTE_HEXCODE = "|cff4B6455"
		NS.Color.RGB_STAT_MASTERY_HEXCODE = "|cff4A3755"
		NS.Color.RGB_STAT_VERS_HEXCODE = "|cff4B4B4B"

		NS.Color.RGB_PING_NEUTRAL_HEXCODE = "|cffFFF1B4"
		NS.Color.RGB_PING_QUEST_NORMAL_HEXCODE = "|cffFFEC9C"
		NS.Color.RGB_PING_QUEST_REPEATABLE_HEXCODE = "|cff9ECFF5"
		NS.Color.RGB_PING_QUEST_IMPORTANT_HEXCODE = "|cffF9C4FF"
		NS.Color.RGB_PING_QUEST_NEUTRAL_HEXCODE = "|cffAFAFAF"
	end
end
