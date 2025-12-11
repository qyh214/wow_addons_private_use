local addonName, env      = ...
local DebuggerIntegration = env.WPM:New("wpm_modules/debugger-integration")

-- Variables
--------------------------------

local ENABLE = nil
C_Timer.After(0, function() ENABLE = env.DEBUG_MODE or false end)


-- Connection
--------------------------------

local API = nil

local function attemptToConnect()
    if API then return true end
    API = DebuggerAPI or nil

    if not API then
        return false
    else
        return true
    end
end

-- API
--------------------------------

function DebuggerIntegration.Post(api, name, ...)
    if not ENABLE then return end

    local success = attemptToConnect()
    if not success then return end

    if API and API[api] and API[api][name] then
        if api == "Console" and name == "AddLine" then
            API[api][name](addonName, ...)
        else
            API[api][name](...)
        end
    end
end
