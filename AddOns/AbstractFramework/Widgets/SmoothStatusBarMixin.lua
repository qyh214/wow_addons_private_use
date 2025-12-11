---@class AbstractFramework
local AF = _G.AbstractFramework

local FrameDeltaLerp = FrameDeltaLerp
local abs = math.abs

local g_updatingBars = {}

local function IsCloseEnough(bar, newValue, targetValue)
    local min, max = bar:GetMinMaxValues()
    local range = max - min
    if range > 0.0 then
        return abs((newValue - targetValue) / range) < 0.00001
    end

    return true
end

local function ProcessSmoothStatusBars()
    for bar, targetValue in pairs(g_updatingBars) do
        local newValue = FrameDeltaLerp(bar:GetValue(), targetValue, 0.25)

        if IsCloseEnough(bar, newValue, targetValue) then
            g_updatingBars[bar] = nil
            bar:SetValue(targetValue)
        else
            bar:SetValue(newValue)
        end
    end
end

C_Timer.NewTicker(0, ProcessSmoothStatusBars)

---@class AF_SmoothStatusBar
AF_SmoothStatusBarMixin = {}

function AF_SmoothStatusBarMixin:ResetSmoothedValue(value) --If nil, tries to set to the last target value
    local targetValue = g_updatingBars[self]
    if targetValue then
        g_updatingBars[self] = nil
        self:SetValue(value or targetValue)
    elseif value then
        self:SetValue(value)
    end
end

function AF_SmoothStatusBarMixin:SetSmoothedValue(value)
    g_updatingBars[self] = value
end

function AF_SmoothStatusBarMixin:SetMinMaxSmoothedValue(min, max)
    self:SetMinMaxValues(min, max)

    local targetValue = g_updatingBars[self]
    if targetValue then
        local ratio = 1
        if max ~= 0 and self.lastSmoothedMax and self.lastSmoothedMax ~= 0 then
            ratio = max / self.lastSmoothedMax
        end

        g_updatingBars[self] = targetValue * ratio
    end

    self.lastSmoothedMin = min
    self.lastSmoothedMax = max
end