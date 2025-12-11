local env                             = select(2, ...)
local Config                          = env.Config

local GetScreenWidth, GetScreenHeight = GetScreenWidth, GetScreenHeight
local BreakUpLargeNumbers             = BreakUpLargeNumbers

local Utils_General                   = env.WPM:Import("wpm_modules/utils/general")
local LocalUtil                       = env.WPM:New("@/LocalUtil")


do -- Screen Position Calculations
    function LocalUtil:GetFrameDistanceFromCursor(frame)
        assert(frame, "Invalid variable `frame`")
        local frameX, frameY = frame:GetCenter()
        if not frameX or not frameY then return end

        local frameScale = frame:GetEffectiveScale()
        frameX, frameY = frameX * frameScale, frameY * frameScale
        local deltaX, deltaY = Utils_General.GetMouseDelta(frameX, frameY)

        local aspectRatio = GetScreenWidth() / GetScreenHeight()
        return (math.abs(deltaX) + math.abs(deltaY)) / aspectRatio
    end

    function LocalUtil:GetFrameDistanceFromScreenCenter(frame)
        assert(frame, "Invalid variable `frame`")
        local frameX, frameY = frame:GetCenter()
        if not frameX or not frameY then return end

        frameX = frameX * frame:GetEffectiveScale()
        frameY = frameY * frame:GetEffectiveScale()

        local screenCenterX, screenCenterY = GetScreenWidth() * UIParent:GetEffectiveScale() * 0.5, GetScreenHeight() * UIParent:GetEffectiveScale() * 0.5
        return math.abs(frameX - screenCenterX) + math.abs(frameY - screenCenterY)
    end

    function LocalUtil:GetFrameDistanceFromScreenEdge(frame)
        assert(frame, "Invalid variable `frame`")
        local frameX, frameY = frame:GetCenter()
        if not frameX or not frameY then return end

        local screenWidth, screenHeight = GetScreenWidth(), GetScreenHeight()

        local deltaLeft = frameX / screenWidth
        local deltaRight = (screenWidth - frameX) / screenWidth
        local deltaTop = (screenHeight - frameY) / screenHeight
        local deltaBottom = frameY / screenHeight

        return math.min(deltaLeft, deltaRight, deltaTop, deltaBottom)
    end
end

do -- Conversion
    function LocalUtil:CalculateDistance(yds)
        if Config.DBGlobal:GetVariable("PrefMetric") then
            return math.ceil(yds * .9144)
        else
            return math.ceil(yds)
        end
    end

    function LocalUtil:FormatDistance(yds)
        if Config.DBGlobal:GetVariable("PrefMetric") then
            local m = self:CalculateDistance(yds)
            return m > 1000 and string.format("%.2f", m / 1000) .. "km" or m .. "m"
        else
            return BreakUpLargeNumbers(math.ceil(yds)) .. " yds"
        end
    end
end
