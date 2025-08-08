---@class addon
local addon = select(2, ...)
local NS = addon.C.AddonInfo; addon.C.AddonInfo = NS

--------------------------------

NS.Variables = NS.Variables or {}
NS.Variables.SharedVariables = {}

--------------------------------
-- VARIABLES
--------------------------------

do -- MAIN

end

do -- CONSTANTS
	NS.Variables.SharedVariables.PATH_TOOLTIP_DIVIDER = addon.CS:GetAddonPathElement() .. "background-tooltip-divider.png"
end
