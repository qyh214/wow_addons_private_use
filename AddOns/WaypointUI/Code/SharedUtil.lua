local env = select(2, ...)
local Config = env.Config
local Utils_General = env.modules:Import("packages\\utils\\general")
local SharedUtil = env.modules:New("@\\SharedUtil")

local GetScreenWidth, GetScreenHeight = GetScreenWidth, GetScreenHeight
local BreakUpLargeNumbers = BreakUpLargeNumbers

do -- Screen Position
    function SharedUtil:GetFrameDistanceFromCursor(frame)
        local frameX, frameY = frame:GetCenter()
        if not frameX or not frameY then return end

        local frameScale = frame:GetEffectiveScale()
        frameX, frameY = frameX * frameScale, frameY * frameScale
        local deltaX, deltaY = Utils_General.GetMouseDelta(frameX, frameY)

        local aspectRatio = GetScreenWidth() / GetScreenHeight()
        return (math.abs(deltaX) + math.abs(deltaY)) / aspectRatio
    end

    function SharedUtil:GetFrameDistanceFromScreenCenter(frame)
        local frameX, frameY = frame:GetCenter()
        if not frameX or not frameY then return end

        frameX = frameX * frame:GetEffectiveScale()
        frameY = frameY * frame:GetEffectiveScale()

        local screenCenterX, screenCenterY = GetScreenWidth() * UIParent:GetEffectiveScale() * 0.5, GetScreenHeight() * UIParent:GetEffectiveScale() * 0.5
        return math.abs(frameX - screenCenterX) + math.abs(frameY - screenCenterY)
    end

    function SharedUtil:GetFrameDistanceFromScreenEdge(frame)
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
    function SharedUtil:CalculateDistance(yds)
        if Config.DBGlobal:GetVariable("PrefMetric") then
            return math.ceil(yds * 0.9144)
        else
            return math.ceil(yds)
        end
    end

    function SharedUtil:FormatDistance(yds)
        if Config.DBGlobal:GetVariable("PrefMetric") then
            local m = self:CalculateDistance(yds)
            return m > 1000 and string.format("%0.2f", m / 1000) .. "km" or m .. "m"
        else
            return BreakUpLargeNumbers(math.ceil(yds)) .. " yds"
        end
    end
end
