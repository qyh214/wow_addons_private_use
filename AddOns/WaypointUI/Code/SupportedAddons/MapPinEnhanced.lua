local env = select(2, ...)
local SupportedAddons = env.modules:Import("@\\SupportedAddons")
local SupportedAddons_MapPinEnhanced = env.modules:New("@\\SupportedAddons\\MapPinEnhanced")

local MPE_TRACKER_FRAME = MapPinEnhancedSuperTrackedPin
local MPE_DATABASE = MapPinEnhancedDB
local CreateFrame = CreateFrame

function SupportedAddons_MapPinEnhanced.SetupEvents()
    MPE_TRACKER_FRAME:HookScript("OnShow", function()
        MPE_TRACKER_FRAME:Hide()
    end)
end

function SupportedAddons_MapPinEnhanced.GetReferences()
    if MPE_TRACKER_FRAME and MPE_DATABASE then return end
    MPE_TRACKER_FRAME = MapPinEnhancedSuperTrackedPin
    MPE_DATABASE = MapPinEnhancedDB
end

--[[
	function NS:GetSets()
		for set, setContent in pairs(MPE_DATABASE.sets) do
			for pin, pinContent in pairs(setContent.pins) do
				-- Pin content
			end
		end
	end
]]

local function OnAddonLoad()
    local f = CreateFrame("Frame")
    f:RegisterEvent("SUPER_TRACKING_CHANGED")
    f:SetScript("OnEvent", function(self, event)
        if event == "SUPER_TRACKING_CHANGED" then
            SupportedAddons_MapPinEnhanced.GetReferences()
            SupportedAddons_MapPinEnhanced.SetupEvents()

            f:Hide()
        end
    end)
end

SupportedAddons.Add("MapPinEnhanced", OnAddonLoad)
