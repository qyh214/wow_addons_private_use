local addonName, env = ...

local CreateFrame = CreateFrame
local GetTime = GetTime

local CallbackRegistry = env.WPM:Import("wpm_modules/callback-registry")
local WoWClient_Events = env.WPM:New("wpm_modules/wow-client/events")


-- Events
--------------------------------

do -- UI Scale Changed
    local lastChangedTime = 0
    local thresholdToClassifyAsEnd = .25

    local awaitScaleEnd = CreateFrame("Frame")
    awaitScaleEnd:SetScript("OnUpdate", function()
        if GetTime() < lastChangedTime + thresholdToClassifyAsEnd then return end
        awaitScaleEnd:Hide()
        CallbackRegistry:Trigger("WoWClient.OnUIScaleChanged")
    end)

    local EL = CreateFrame("Frame")
    EL:RegisterEvent("UI_SCALE_CHANGED")
    EL:SetScript("OnEvent", function(self, event, ...)
        lastChangedTime = GetTime()
        awaitScaleEnd:Show()
    end)
end

do -- Addon Loaded
    local EL = CreateFrame("Frame")
    EL:RegisterEvent("ADDON_LOADED")
    EL:SetScript("OnEvent", function(self, event, ...)
        if event == "ADDON_LOADED" then
            local name = ...
            if name == addonName then
                CallbackRegistry:Trigger("WoWClient.OnAddonLoaded")
            end
        end
    end)
end
