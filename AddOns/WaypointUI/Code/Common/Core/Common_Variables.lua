---@class addon
local addon = select(2, ...)
local NS = addon.C; addon.C = NS

--------------------------------

NS.Variables = {}

--------------------------------
-- VARIABLES
--------------------------------

do -- MAIN

end

do   -- CONSTANTS
	do -- CLIENT
		NS.Variables.IS_WOW_VERSION_RETAIL = (select(4, GetBuildInfo()) > 110000)
		NS.Variables.IS_WOW_VERSION_CLASSIC_PROGRESSION = (select(4, GetBuildInfo()) < 110000 and select(4, GetBuildInfo()) >= 20000)
		NS.Variables.IS_WOW_VERSION_CLASSIC_ERA = (select(4, GetBuildInfo()) < 20000)
		NS.Variables.IS_WOW_VERSION_CLASSIC_ALL = (NS.IS_WOW_VERSION_CLASSIC_PROGRESSION or NS.IS_WOW_VERSION_CLASSIC_ERA)
	end

	do -- INITALIZATION
		NS.Variables.INIT_DELAY_1 = .025
		NS.Variables.INIT_DELAY_2 = .05
		NS.Variables.INIT_DELAY_3 = .075
		NS.Variables.INIT_DELAY_LAST = .1
	end

	do -- MISCELLANEOUS
		NS.Variables.GOLDEN_RATIO = 1.618034

		--------------------------------

		do -- FUNCTIONS
			function NS.Variables:RATIO(base, level)
				return base / (NS.Variables.GOLDEN_RATIO ^ level)
			end

			function NS.Variables:RAW_RATIO(level)
				return NS.Variables.GOLDEN_RATIO ^ level
			end
		end
	end
end
