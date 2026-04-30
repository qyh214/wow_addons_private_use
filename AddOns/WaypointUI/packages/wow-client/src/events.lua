local addonName, env = ...
local CallbackRegistry = env.modules:Import("packages\\callback-registry")
local WoWClient_Events = env.modules:New("packages\\wow-client\\events")

local CreateFrame = CreateFrame
local GetTime = GetTime

do -- UI Scale Changed
    local lastChangedTime = 0
    local scaleChangeDebounceTime = 0.25

    local awaitScaleEnd = CreateFrame("Frame")
    awaitScaleEnd:SetScript("OnUpdate", function()
        if GetTime() < lastChangedTime + scaleChangeDebounceTime then return end
        awaitScaleEnd:Hide()
        CallbackRegistry.Trigger("WoWClient.OnUIScaleChanged")
    end)

    local f = CreateFrame("Frame")
    f:RegisterEvent("UI_SCALE_CHANGED")
    f:SetScript("OnEvent", function(self, event, ...)
        lastChangedTime = GetTime()
        awaitScaleEnd:Show()
    end)
end

do -- Addon Lifecycle
    local f = CreateFrame("Frame")
    f:RegisterEvent("ADDON_LOADED")
    f:RegisterEvent("PLAYER_LOGIN")
    f:SetScript("OnEvent", function(self, event, ...)
        if event == "ADDON_LOADED" then
            local name = ...
            if name == addonName then
                CallbackRegistry.Trigger("WoWClient.OnAddonLoaded")
            end
        elseif event == "PLAYER_LOGIN" then
            CallbackRegistry.Trigger("WoWClient.OnPlayerLogin")
        end
    end)
end

do -- Mouse
    WoWClient_Events.IsPlayerTurning = false
    WoWClient_Events.IsPlayerLooking = false

    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_STARTED_LOOKING")
    f:RegisterEvent("PLAYER_STOPPED_LOOKING")
    f:RegisterEvent("PLAYER_STARTED_TURNING")
    f:RegisterEvent("PLAYER_STOPPED_TURNING")
    f:SetScript("OnEvent", function(self, event, ...)
        if event == "PLAYER_STARTED_TURNING" or event == "PLAYER_STOPPED_TURNING" then
            WoWClient_Events.IsPlayerTurning = (event == "PLAYER_STARTED_TURNING")
        end
        if event == "PLAYER_STARTED_MOVING" or event == "PLAYER_STOPPED_MOVING" then
            WoWClient_Events.IsPlayerLooking = (event == "PLAYER_STARTED_MOVING")
        end
    end)
end
