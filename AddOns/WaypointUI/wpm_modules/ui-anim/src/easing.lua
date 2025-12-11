local env = select(2, ...)

local sin = math.sin
local cos = math.cos
local sqrt = math.sqrt
local pi = math.pi
local HALF_PI = pi * 0.5

local UIAnim_Easing = env.WPM:New("wpm_modules/ui-anim/easing")


do -- Linear
    function UIAnim_Easing.Linear(t)
        return t
    end
end

do -- Sine
    function UIAnim_Easing.SineIn(t)
        return 1 - cos(t * HALF_PI)
    end

    function UIAnim_Easing.SineOut(t)
        return sin(t * HALF_PI)
    end

    function UIAnim_Easing.SineInOut(t)
        return 0.5 * (1 - cos(pi * t))
    end
end

do -- Quadratic
    function UIAnim_Easing.QuadIn(t)
        return t * t
    end

    function UIAnim_Easing.QuadOut(t)
        return t * (2 - t)
    end

    function UIAnim_Easing.QuadInOut(t)
        if t < 0.5 then
            return 2 * t * t
        end
        local u = -2 * t + 2
        return 1 - (u * u) * 0.5
    end
end

do -- Cubic
    function UIAnim_Easing.CubicIn(t)
        return t * t * t
    end

    function UIAnim_Easing.CubicOut(t)
        local u = 1 - t
        return 1 - u * u * u
    end

    function UIAnim_Easing.CubicInOut(t)
        if t < 0.5 then
            return 4 * t * t * t
        end
        local u = -2 * t + 2
        return 1 - (u * u * u) * 0.5
    end
end

do -- Quartic
    function UIAnim_Easing.QuartIn(t)
        local t2 = t * t
        return t2 * t2
    end

    function UIAnim_Easing.QuartOut(t)
        local u = 1 - t
        local u2 = u * u
        return 1 - u2 * u2
    end

    function UIAnim_Easing.QuartInOut(t)
        if t < 0.5 then
            local x = 2 * t
            local x2 = x * x
            return 0.5 * x2 * x2
        end
        local u = -2 * t + 2
        local u2 = u * u
        return 1 - 0.5 * u2 * u2
    end
end

do -- Quintic
    function UIAnim_Easing.QuintIn(t)
        local t2 = t * t
        return t2 * t2 * t
    end

    function UIAnim_Easing.QuintOut(t)
        local u = 1 - t
        local u2 = u * u
        return 1 - u2 * u2 * u
    end

    function UIAnim_Easing.QuintInOut(t)
        if t < 0.5 then
            local x = 2 * t
            local x2 = x * x
            return 0.5 * x2 * x2 * x
        end
        local u = -2 * t + 2
        local u2 = u * u
        return 1 - 0.5 * u2 * u2 * u
    end
end

do -- Exponential
    function UIAnim_Easing.ExpoIn(t)
        if t <= 0 then return 0 end
        return 2 ^ (10 * t - 10)
    end

    function UIAnim_Easing.ExpoOut(t)
        if t >= 1 then return 1 end
        return 1 - 2 ^ (-10 * t)
    end

    function UIAnim_Easing.ExpoInOut(t)
        if t <= 0 then return 0 end
        if t >= 1 then return 1 end
        if t < 0.5 then
            return 0.5 * (2 ^ (20 * t - 10))
        end
        return 1 - 0.5 * (2 ^ (-20 * t + 10))
    end
end

do -- Circular
    function UIAnim_Easing.CircIn(t)
        return 1 - sqrt(1 - t * t)
    end

    function UIAnim_Easing.CircOut(t)
        local u = t - 1
        return sqrt(1 - u * u)
    end

    function UIAnim_Easing.CircInOut(t)
        if t < 0.5 then
            local x = 2 * t
            return 0.5 * (1 - sqrt(1 - x * x))
        end
        local u = -2 * t + 2
        return 0.5 * (sqrt(1 - u * u) + 1)
    end
end

do -- Back (overshoot)
    local c1 = 1.70158
    local c2 = c1 * 1.525
    function UIAnim_Easing.BackIn(t)
        return (c1 + 1) * t * t * t - c1 * t * t
    end

    function UIAnim_Easing.BackOut(t)
        local u = t - 1
        return 1 + (c1 + 1) * u * u * u + c1 * u * u
    end

    function UIAnim_Easing.BackInOut(t)
        if t < 0.5 then
            local x = 2 * t
            return 0.5 * (x * x * ((c2 + 1) * x - c2))
        end
        local x = 2 * t - 2
        return 0.5 * (x * x * ((c2 + 1) * x + c2) + 2)
    end
end

do -- Elastic
    local c4 = (2 * pi) / 3
    local c5 = (2 * pi) / 4.5
    function UIAnim_Easing.ElasticIn(t)
        if t <= 0 then return 0 end
        if t >= 1 then return 1 end
        return -(2 ^ (10 * t - 10)) * sin((t * 10 - 10.75) * c4)
    end

    function UIAnim_Easing.ElasticOut(t)
        if t <= 0 then return 0 end
        if t >= 1 then return 1 end
        return (2 ^ (-10 * t)) * sin((t * 10 - 0.75) * c4) + 1
    end

    function UIAnim_Easing.ElasticInOut(t)
        if t <= 0 then return 0 end
        if t >= 1 then return 1 end
        if t < 0.5 then
            return -0.5 * (2 ^ (20 * t - 10)) * sin((20 * t - 11.125) * c5)
        end
        return 0.5 * (2 ^ (-20 * t + 10)) * sin((20 * t - 11.125) * c5) + 1
    end
end

do -- Bounce
    local function bounceOut(t)
        --Robert Penner's Bounce ease out
        if t < 1 / 2.75 then
            return 7.5625 * t * t
        elseif t < 2 / 2.75 then
            t = t - (1.5 / 2.75)
            return 7.5625 * t * t + 0.75
        elseif t < 2.5 / 2.75 then
            t = t - (2.25 / 2.75)
            return 7.5625 * t * t + 0.9375
        else
            t = t - (2.625 / 2.75)
            return 7.5625 * t * t + 0.984375
        end
    end

    function UIAnim_Easing.BounceOut(t)
        return bounceOut(t)
    end

    function UIAnim_Easing.BounceIn(t)
        return 1 - bounceOut(1 - t)
    end

    function UIAnim_Easing.BounceInOut(t)
        if t < 0.5 then
            return 0.5 * (1 - bounceOut(1 - 2 * t))
        end
        return 0.5 * bounceOut(2 * t - 1) + 0.5
    end
end

do -- Smooth step variants
    function UIAnim_Easing.SmoothStep(t)
        return t * t * (3 - 2 * t)
    end

    function UIAnim_Easing.SmootherStep(t)
        local t2 = t * t
        local t3 = t2 * t
        local t4 = t3 * t
        local t5 = t4 * t
        return 6 * t5 - 15 * t4 + 10 * t3
    end
end
