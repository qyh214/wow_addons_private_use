local env               = select(2, ...)

local CreateFrame       = CreateFrame
local InCombatLockdown  = InCombatLockdown

local CallbackRegistry  = env.WPM:Import("wpm_modules/callback-registry")
local LazyTimer         = env.WPM:Import("wpm_modules/lazy-timer")
local WoWClient_Keybind = env.WPM:New("wpm_modules/wow-client/keybind")


-- Events
--------------------------------

local function onKeyDown(self, key)
    CallbackRegistry:Trigger("WoWClient.OnKeyDown", key)
    if key == "ESCAPE" then
        CallbackRegistry:Trigger("WoWClient.OnEscapePressed")
    end
end

local function onKeyUp(self, key)
    CallbackRegistry:Trigger("WoWClient.OnKeyUp", key)
end


local KeybindEvents = CreateFrame("Frame")
KeybindEvents:SetScript("OnKeyDown", onKeyDown)
KeybindEvents:SetScript("OnKeyUp", onKeyUp)

if not InCombatLockdown() then
    KeybindEvents:SetPropagateKeyboardInput(true)
else
    KeybindEvents.awaitingPropagateKeyboardInput = true
    KeybindEvents:RegisterEvent("PLAYER_REGEN_ENABLED")

    KeybindEvents:SetScript("OnEvent", function(self, event)
        if not InCombatLockdown() then
            self.awaitingPropagateKeyboardInput = false
            KeybindEvents:SetPropagateKeyboardInput(true)
            KeybindEvents:UnregisterEvent("PLAYER_REGEN_ENABLED")
        end
    end)
end


-- API
--------------------------------

local function disableKeyPropagation()
    if InCombatLockdown() then return end
    KeybindEvents:SetPropagateKeyboardInput(false)
end

local function enableKeyPropagation()
    if InCombatLockdown() then return end
    KeybindEvents:SetPropagateKeyboardInput(true)
end

local KeyPropagationTimer = LazyTimer.New()
KeyPropagationTimer:SetAction(enableKeyPropagation)

function WoWClient_Keybind.BlockKeyEvent()
    if InCombatLockdown() then return end

    disableKeyPropagation()
    KeyPropagationTimer:Start(0)
end
