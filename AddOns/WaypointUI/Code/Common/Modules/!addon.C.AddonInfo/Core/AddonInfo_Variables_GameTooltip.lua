---@class addon
local addon = select(2, ...)
local NS = addon.C.AddonInfo; addon.C.AddonInfo = NS

--------------------------------

NS.Variables = NS.Variables or {}
NS.Variables.GameTooltip = {}

--------------------------------
-- VARIABLES
--------------------------------

do -- MAIN

end

do -- CONSTANTS
	NS.Variables.GameTooltip.TOOLTIP_STYLE = {
		["GameTooltip"] = {
			["texture"] = addon.CS:GetCommonPathArt() .. "Tooltip/background-generic.png",
			["modifier"] = .275
		},
		["ShoppingTooltip1"] = {
			["texture"] = addon.CS:GetCommonPathArt() .. "Tooltip/background-generic.png",
			["modifier"] = .175
		},
		["ShoppingTooltip2"] = {
			["texture"] = addon.CS:GetCommonPathArt() .. "Tooltip/background-generic.png",
			["modifier"] = .175
		}
	}
end
