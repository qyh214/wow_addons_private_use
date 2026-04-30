local appName, app = ...
---@class AbilityTimeline
local private = app
local CustomGlow = LibStub("LibCustomGlow-1.0")

---@class GlowType
private.GlowTypes = {
    PROC = "PROC",
    PIXEL = "PIXEL",
    AUTOCAST = "AUTOCAST",
    BUTTON = "BUTTON",
}
---Enables a glow on a frame for a given duration
---@param frame frame
---@param type GlowType
---@param duration number
---@param glowColor colorRGBA?
private.EnableGlow = function(frame, type, duration, glowColor)
    if frame.isGlowing and (frame.isGlowing ~= type or frame.glowColor ~= glowColor) then
        private.StopGlow(frame)
    elseif frame.isGlowing and frame.isGlowing == type and frame.glowColor == glowColor then
        return
    end
    local modifiedGlowColor = nil
    frame.glowColor = glowColor
    if glowColor then
        modifiedGlowColor = { glowColor.r, glowColor.g, glowColor.b, glowColor.a }
    end
    if type == private.GlowTypes.PROC then
        CustomGlow.ProcGlow_Start(frame, modifiedGlowColor)
        frame.isGlowing = type
        C_Timer.After(duration, function()
            private.StopGlow(frame)
        end)
    elseif type == private.GlowTypes.PIXEL then
        CustomGlow.PixelGlow_Start(frame, modifiedGlowColor)
        frame.isGlowing = type
        C_Timer.After(duration, function()
            private.StopGlow(frame)
        end)
    elseif type == private.GlowTypes.AUTOCAST then
        CustomGlow.AutoCastGlow_Start(frame, modifiedGlowColor)
        frame.isGlowing = type
        C_Timer.After(duration, function()
            private.StopGlow(frame)
        end)
    elseif type == private.GlowTypes.BUTTON then
        CustomGlow.ButtonGlow_Start(frame, modifiedGlowColor)
        frame.isGlowing = type
        C_Timer.After(duration, function()
            private.StopGlow(frame)
        end)
    end
end

private.StopGlow = function(frame)
    if frame.isGlowing == private.GlowTypes.PROC then
        CustomGlow.ProcGlow_Stop(frame)
    elseif frame.isGlowing == private.GlowTypes.PIXEL then
        CustomGlow.PixelGlow_Stop(frame)
    elseif frame.isGlowing == private.GlowTypes.AUTOCAST then
        CustomGlow.AutoCastGlow_Stop(frame)
    elseif frame.isGlowing == private.GlowTypes.BUTTON then
        CustomGlow.ButtonGlow_Stop(frame)
    end
    frame.isGlowing = false
end
