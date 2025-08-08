---@class addon
local addon = select(2, ...)
local NS = addon.C.SharedVariables; addon.C.SharedVariables = NS

--------------------------------

NS.Util = {}

--------------------------------
-- VARIABLES
--------------------------------

do  -- MAIN

end

do  -- CONSTANTS

end

--------------------------------
-- FUNCTIONS (TOOLTIP)
--------------------------------

do
	function NS.Util:NewTooltipDivider(width)
		return "\n" .. addon.C.API.Util:InlineIcon(addon.C.AddonInfo.Variables.SharedVariables.PATH_TOOLTIP_DIVIDER, 1, width, 0, 0) .. "\n"
	end
end

--------------------------------
-- EVENTS
--------------------------------

do

end
