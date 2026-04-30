local env = select(2, ...)
local Utils_Color = env.modules:Import("packages\\utils\\color")
local UIKit_Define = env.modules:Import("packages\\ui-kit\\define")
local UIKit_Utils = env.modules:New("packages\\ui-kit\\utils")

local tinsert = table.insert
local wipe = wipe

function UIKit_Utils:CalculateRelativePercentage(relativeTo, percentage, operator, delta, frame)
    if type(delta) == "function" then
        delta = delta(frame)
    end
    delta = delta or 0

    local result = relativeTo * (percentage / 100)
    if operator == "+" then
        result = result + delta
    elseif operator == "-" then
        result = result - delta
    elseif operator == "/" then
        result = result / delta
    elseif operator == "*" then
        result = result * delta
    end

    return result
end

function UIKit_Utils:ProcessColor(color)
    if not color.__processed then
        color.__processed = true

        if color == UIKit_Define.Color_RGBA then
            return Utils_Color.ParseRGBA(color)
        elseif color == UIKit_Define.Color_HEX then
            return Utils_Color.ParseHex(color)
        end
    end

    return color
end

do -- Protected event util
    local dirty = {}
    local dirtyFrame = {}

    local function Wash()
        if InCombatLockdown() or not dirty then return end

        for i = 1, #dirty do
            dirty[i](dirtyFrame[i])
        end

        wipe(dirty)
        wipe(dirtyFrame)
    end

    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_REGEN_ENABLED")
    f:SetScript("OnEvent", Wash)

    function UIKit_Utils:AwaitProtectedEvent(func, frame)
        tinsert(dirty, func)
        tinsert(dirtyFrame, frame)
        Wash()
    end
end
