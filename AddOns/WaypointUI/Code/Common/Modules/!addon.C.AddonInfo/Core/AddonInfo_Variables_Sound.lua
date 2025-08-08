---@class addon
local addon = select(2, ...)
local NS = addon.C.AddonInfo; addon.C.AddonInfo = NS

--------------------------------

NS.Variables = NS.Variables or {}
NS.Variables.Sound = {}

--------------------------------
-- VARIABLES
--------------------------------

do -- MAIN

end

do -- CONSTANTS
	NS.Variables.Sound.ENABLE_AUDIO = function()
		return addon.C.Database.Variables.DB_GLOBAL.profile.AUDIO_GLOBAL
	end
end
