---@class addon
local addon = select(2, ...)

--------------------------------
-- VARIABLES
--------------------------------

addon.C.Libraries = {}

--------------------------------
-- LIBRARIES
--------------------------------

do
    addon.C.Libraries.AceTimer = LibStub("AceTimer-3.0")
	addon.C.Libraries.AdaptiveTimer = LibStub("AdaptiveTimer-1.0")
	addon.C.Libraries.LibSerialize = LibStub("LibSerialize")
	addon.C.Libraries.LibDeflate = LibStub("LibDeflate")
end

--------------------------------
-- FUNCTIONS (MAIN)
--------------------------------

do

end
