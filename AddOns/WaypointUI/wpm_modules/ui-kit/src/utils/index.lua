local env          = select(2, ...)

local tinsert      = table.insert
local wipe         = wipe

local Utils_Color  = env.WPM:Import("wpm_modules/utils/color")
local UIKit_Define = env.WPM:Import("wpm_modules/ui-kit/define")
local UIKit_Utils  = env.WPM:New("wpm_modules/ui-kit/utils")


-- Calculation
--------------------------------

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


-- Protected event
--------------------------------

local dirty = {}
local dirtyFrame = {}

local function wash()
    if InCombatLockdown() or not dirty then return end

    for i = 1, #dirty do
        dirty[i](dirtyFrame[i])
    end

    wipe(dirty)
    wipe(dirtyFrame)
end

local EL = CreateFrame("Frame")
EL:RegisterEvent("PLAYER_REGEN_ENABLED")
EL:SetScript("OnEvent", wash)

function UIKit_Utils:AwaitProtectedEvent(func, frame)
    tinsert(dirty, func)
    tinsert(dirtyFrame, frame)
    wash()
end
