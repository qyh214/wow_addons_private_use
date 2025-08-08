---@class addon
local addon = select(2, ...)
local NS = addon.C.AddonInfo; addon.C.AddonInfo = NS

--------------------------------

NS.Variables = NS.Variables or {}
NS.Variables.Fonts = {}

--------------------------------
-- VARIABLES
--------------------------------

do -- MAIN

end

do -- CONSTANTS
	do -- FONTS
		NS.Variables.Fonts.FONT_TABLE = {
			["enUS"] = {
				["CONTENT_DEFAULT"] = addon.CS:NewFontInfo("Default", GameFontNormal:GetFont(), 1),
			},
			["deDE"] = {
				["CONTENT_DEFAULT"] = addon.CS:NewFontInfo("Default", GameFontNormal:GetFont(), 1),
			},
			["esES"] = {
				["CONTENT_DEFAULT"] = addon.CS:NewFontInfo("Default", GameFontNormal:GetFont(), 1),
			},
			["esMX"] = {
				["CONTENT_DEFAULT"] = addon.CS:NewFontInfo("Default", GameFontNormal:GetFont(), 1),
			},
			["frFR"] = {
				["CONTENT_DEFAULT"] = addon.CS:NewFontInfo("Default", GameFontNormal:GetFont(), 1),
			},
			["itIT"] = {
				["CONTENT_DEFAULT"] = addon.CS:NewFontInfo("Default", GameFontNormal:GetFont(), 1),
			},
			["koKR"] = {
				["CONTENT_DEFAULT"] = addon.CS:NewFontInfo("Default", GameFontNormal:GetFont(), 1),
			},
			["ptBR"] = {
				["CONTENT_DEFAULT"] = addon.CS:NewFontInfo("Default", GameFontNormal:GetFont(), 1),
			},
			["ruRU"] = {
				["CONTENT_DEFAULT"] = addon.CS:NewFontInfo("Default", GameFontNormal:GetFont(), 1),
			},
			["zhCN"] = {
				["CONTENT_DEFAULT"] = addon.CS:NewFontInfo("Default", GameFontNormal:GetFont(), 1.25),
			},
			["zhTW"] = {
				["CONTENT_DEFAULT"] = addon.CS:NewFontInfo("Default", GameFontNormal:GetFont(), 1.25),
			},
		}
	end
end
