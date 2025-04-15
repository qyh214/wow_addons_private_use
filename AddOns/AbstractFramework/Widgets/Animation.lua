---@class AbstractFramework
local AF = _G.AbstractFramework

---------------------------------------------------------------------
-- forked from ElvUI
---------------------------------------------------------------------
local FADEFRAMES, FADEMANAGER = {}, CreateFrame("FRAME")
FADEMANAGER.interval = 0.025

---------------------------------------------------------------------
-- fade manager onupdate
---------------------------------------------------------------------
local function Fading(_, elapsed)
    FADEMANAGER.timer = (FADEMANAGER.timer or 0) + elapsed

    if FADEMANAGER.timer > FADEMANAGER.interval then
        FADEMANAGER.timer = 0

        for frame, info in next, FADEFRAMES do
            if frame:IsVisible() then
                info.fadeTimer = (info.fadeTimer or 0) + (elapsed + FADEMANAGER.interval)
            else -- faster for hidden frames
                info.fadeTimer = info.timeToFade + 1
            end

            if info.fadeTimer < info.timeToFade then
                if info.mode == "IN" then
                    frame:SetAlpha((info.fadeTimer / info.timeToFade) * info.diffAlpha + info.startAlpha)
                else
                    frame:SetAlpha(((info.timeToFade - info.fadeTimer) / info.timeToFade) * info.diffAlpha + info.endAlpha)
                end
            else
                frame:SetAlpha(info.endAlpha)
                -- NOTE: remove from FADEFRAMES
                if frame and FADEFRAMES[frame] then
                    if frame.fade then
                        frame.fade.fadeTimer = nil
                    end
                    FADEFRAMES[frame] = nil
                end
            end
        end

        if not next(FADEFRAMES) then
            FADEMANAGER:SetScript("OnUpdate", nil)
        end
    end
end

---------------------------------------------------------------------
-- fade
---------------------------------------------------------------------
local function FrameFade(frame, info)
    frame:SetAlpha(info.startAlpha)

    if not frame:IsProtected() then
        frame:Show()
    end

    if not FADEFRAMES[frame] then
        FADEFRAMES[frame] = info
        FADEMANAGER:SetScript("OnUpdate", Fading)
    else
        FADEFRAMES[frame] = info
    end
end

function AF.FrameFadeIn(frame, timeToFade, startAlpha, endAlpha)
    if frame.fade then
        frame.fade.fadeTimer = nil
    else
        frame.fade = {}
    end

    frame.fade.mode = "IN"
    frame.fade.timeToFade = timeToFade
    frame.fade.startAlpha = startAlpha or frame:GetAlpha()
    frame.fade.endAlpha = endAlpha or 1
    frame.fade.diffAlpha = frame.fade.endAlpha - frame.fade.startAlpha

    if frame.fade.startAlpha ~= frame.fade.endAlpha then
        FrameFade(frame, frame.fade)
    end
end

function AF.FrameFadeOut(frame, timeToFade, startAlpha, endAlpha)
    if frame.fade then
        frame.fade.fadeTimer = nil
    else
        frame.fade = {}
    end

    frame.fade.mode = "OUT"
    frame.fade.timeToFade = timeToFade
    frame.fade.startAlpha = startAlpha or frame:GetAlpha()
    frame.fade.endAlpha = endAlpha or 0
    frame.fade.diffAlpha = frame.fade.startAlpha - frame.fade.endAlpha

    if frame.fade.startAlpha ~= frame.fade.endAlpha then
        FrameFade(frame, frame.fade)
    end
end

---------------------------------------------------------------------
-- fade-in/out animation group
---------------------------------------------------------------------
local fade_in_out = {
    FadeIn = function(region)
        if not region.fadeIn:IsPlaying() then
            region.fadeIn:Play()
        end
    end,

    FadeOut = function(region)
        if not region.fadeOut:IsPlaying() then
            region.fadeOut:Play()
        end
    end,

    ShowNow = function(region)
        region.fadeIn:Stop()
        region.fadeOut:Stop()
        region:SetAlpha(1)
        region:Show()
    end,

    HideNow = function(region)
        region.fadeIn:Stop()
        region.fadeOut:Stop()
        region:SetAlpha(0)
        region:Hide()
    end,
}

function AF.CreateFadeInOutAnimation(region, duration, noHide)
    duration = duration or 0.25

    local in_ag = region:CreateAnimationGroup()
    region.fadeIn = in_ag

    local out_ag = region:CreateAnimationGroup()
    region.fadeOut = out_ag

    for k, v in pairs(fade_in_out) do
        region[k] = v
    end

    -- in -----------------------------------------------------------
    local in_a = in_ag:CreateAnimation("Alpha")
    in_ag.alpha = in_a
    in_a:SetFromAlpha(0)
    in_a:SetToAlpha(1)
    in_a:SetDuration(duration)

    in_ag:SetScript("OnPlay", function()
        out_ag:Stop()
        region:Show()
    end)

    in_ag:SetScript("OnFinished", function()
        region:SetAlpha(1)
    end)
    -----------------------------------------------------------------

    -- out ----------------------------------------------------------
    local out_a = out_ag:CreateAnimation("Alpha")
    out_ag.alpha = out_a
    out_a:SetFromAlpha(1)
    out_a:SetToAlpha(0)
    out_a:SetDuration(duration)

    out_ag:SetScript("OnPlay", function()
        in_ag:Stop()
        region:Show()
    end)

    out_ag:SetScript("OnFinished", function()
        region:SetAlpha(0)
        if not noHide then
            region:Hide()
        end
    end)
    -----------------------------------------------------------------
end

function AF.SetFadeInOutAnimationDuration(region, duration)
    if not (duration and region.fadeIn and region.fadeOut) then return end

    region.fadeIn.alpha:SetDuration(duration)
    region.fadeOut.alpha:SetDuration(duration)
end

---------------------------------------------------------------------
-- continual fade-in-out
---------------------------------------------------------------------
local function FadeInOut(region)
    region.fade:Restart()
end

function AF.CreateContinualFadeInOutAnimation(region, duration, delay)
    duration = duration or 0.25
    delay = delay or 1

    region.FadeInOut = FadeInOut

    local ag = region:CreateAnimationGroup()
    region.fade = ag

    -- in -----------------------------------------------------------
    local in_a = ag:CreateAnimation("Alpha")
    ag.fadeIn = in_a
    in_a:SetOrder(1)
    in_a:SetFromAlpha(0)
    in_a:SetToAlpha(1)
    in_a:SetDuration(duration)
    -----------------------------------------------------------------

    -- out ----------------------------------------------------------
    local out_a = ag:CreateAnimation("Alpha")
    ag.fadeOut = out_a
    out_a:SetOrder(2)
    out_a:SetStartDelay(delay)
    out_a:SetFromAlpha(1)
    out_a:SetToAlpha(0)
    out_a:SetDuration(duration)
    -----------------------------------------------------------------

    ag:SetScript("OnPlay", function()
        region:Show()
    end)
    ag:SetScript("OnFinished", function()
        region:Hide()
    end)
end

---------------------------------------------------------------------
-- blink
---------------------------------------------------------------------
function AF.CreateBlinkAnimation(region, duration, enableShowHideHook)
    local blink = region:CreateAnimationGroup()
    region.blink = blink

    local alpha = blink:CreateAnimation("Alpha")
    blink.alpha = alpha
    alpha:SetFromAlpha(0.25)
    alpha:SetToAlpha(1)
    alpha:SetDuration(duration or 0.5)

    blink:SetLooping("BOUNCE")

    if enableShowHideHook then
        region:HookScript("OnShow", function()
            blink:Play()
        end)
        region:HookScript("OnHide", function()
            blink:Stop()
        end)
    else
        blink:Play()
    end
end

---------------------------------------------------------------------
-- resize with animation
---------------------------------------------------------------------
---@param frame Frame
---@param targetWidth? number
---@param targetHeight? number
---@param frequency? number default 0.015
---@param onStart? function called when animation starts
---@param onFinish? function called when animation ends
---@param onChange? function called when size changes, with currentWidth and currentHeight as parameters
---@param steps? number total steps to final size, default 7
---@param anchorPoint? string TOPLEFT|TOPRIGHT|BOTTOMLEFT|BOTTOMRIGHT
function AF.AnimatedResize(frame, targetWidth, targetHeight, frequency, steps, onStart, onFinish, onChange, anchorPoint)
    if frame._animatedResizeTimer then
        frame._animatedResizeTimer:Cancel()
        frame._animatedResizeTimer = nil
    end

    frequency = frequency or 0.015
    steps = steps or 7

    if anchorPoint then
        -- anchorPoint is only for those frames of which the direct parent is UIParent
        assert(frame:GetParent() == AF.UIParent)
        local left = Round(frame:GetLeft())
        local right = Round(frame:GetRight())
        local top = Round(frame:GetTop())
        local bottom = Round(frame:GetBottom())

        AF.ClearPoints(frame)
        if anchorPoint == "TOPLEFT" then
            frame:SetPoint("TOPLEFT", AF.UIParent, "BOTTOMLEFT", left, top)
        elseif anchorPoint == "TOPRIGHT" then
            frame:SetPoint("TOPRIGHT", AF.UIParent, "BOTTOMLEFT", right, top)
        elseif anchorPoint == "BOTTOMLEFT" then
            frame:SetPoint("BOTTOMLEFT", AF.UIParent, "BOTTOMLEFT", left, bottom)
        elseif anchorPoint == "BOTTOMRIGHT" then
            frame:SetPoint("BOTTOMRIGHT", AF.UIParent, "BOTTOMLEFT", right, bottom)
        end
    end

    if onStart then onStart() end

    local currentHeight = frame._height or frame:GetHeight()
    local currentWidth = frame._width or frame:GetWidth()
    targetWidth = targetWidth or currentWidth
    targetHeight = targetHeight or currentHeight

    local diffW = (targetWidth - currentWidth) / steps
    local diffH = (targetHeight - currentHeight) / steps

    frame._animatedResizeTimer = C_Timer.NewTicker(frequency, function()
        if not AF.ApproxZero(diffW) then
            if diffW > 0 then
                currentWidth = math.min(currentWidth + diffW, targetWidth)
            else
                currentWidth = math.max(currentWidth + diffW, targetWidth)
            end
            AF.SetWidth(frame, currentWidth)
        end

        if not AF.ApproxZero(diffH) then
            if diffH > 0 then
                currentHeight = math.min(currentHeight + diffH, targetHeight)
            else
                currentHeight = math.max(currentHeight + diffH, targetHeight)
            end
            AF.SetHeight(frame, currentHeight)
        end

        if onChange then
            onChange(currentWidth, currentHeight)
        end

        if AF.ApproxEqual(currentWidth, targetWidth) and AF.ApproxEqual(currentHeight, targetHeight) then
            frame._animatedResizeTimer:Cancel()
            frame._animatedResizeTimer = nil
            if targetWidth then AF.SetWidth(frame, targetWidth) end
            if targetHeight then AF.SetHeight(frame, targetHeight) end
            if onFinish then onFinish() end
        end
    end)
end

---------------------------------------------------------------------
-- zoom
---------------------------------------------------------------------
local ZOOMFRAMES, ZOOMMANAGER = {}, CreateFrame("FRAME")
ZOOMMANAGER.interval = 0.025

---------------------------------------------------------------------
-- zoom manager onupdate
---------------------------------------------------------------------
local function Fading(_, elapsed)
    ZOOMMANAGER.timer = (ZOOMMANAGER.timer or 0) + elapsed

    if ZOOMMANAGER.timer > ZOOMMANAGER.interval then
        ZOOMMANAGER.timer = 0

        for frame, info in next, ZOOMFRAMES do
            if frame:IsVisible() then
                info.zoomTimer = (info.zoomTimer or 0) + (elapsed + ZOOMMANAGER.interval)
            else -- faster for hidden frames
                info.zoomTimer = info.timeToZoom + 1
            end

            if info.zoomTimer < info.timeToZoom then
                if info.mode == "IN" then
                    frame:SetScale((info.zoomTimer / info.timeToZoom) * info.diffScale + info.startScale)
                else
                    frame:SetScale(((info.timeToZoom - info.zoomTimer) / info.timeToZoom) * info.diffScale + info.endScale)
                end
            else
                frame:SetScale(info.endScale)
                -- NOTE: remove from ZOOMFRAMES
                if frame and ZOOMFRAMES[frame] then
                    if frame.zoom then
                        frame.zoom.zoomTimer = nil
                    end
                    ZOOMFRAMES[frame] = nil
                end
            end
        end

        if not next(ZOOMFRAMES) then
            ZOOMMANAGER:SetScript("OnUpdate", nil)
        end
    end
end

---------------------------------------------------------------------
-- zoom
---------------------------------------------------------------------
local function FrameZoom(frame, info)
    frame:SetScale(info.startScale)

    if not frame:IsProtected() then
        frame:Show()
    end

    if not ZOOMFRAMES[frame] then
        ZOOMFRAMES[frame] = info
        ZOOMMANAGER:SetScript("OnUpdate", Fading)
    else
        ZOOMFRAMES[frame] = info
    end
end

function AF.FrameZoomIn(frame, timeToZoom, startScale, endScale)
    if frame.zoom then
        frame.zoom.zoomTimer = nil
    else
        frame.zoom = {}
    end

    frame.zoom.mode = "IN"
    frame.zoom.timeToZoom = timeToZoom
    frame.zoom.startScale = startScale or frame:GetScale()
    frame.zoom.endScale = endScale or 1
    frame.zoom.diffScale = frame.zoom.endScale - frame.zoom.startScale

    FrameZoom(frame, frame.zoom)
end

function AF.FrameZoomOut(frame, timeToZoom, startScale, endScale)
    if frame.zoom then
        frame.zoom.zoomTimer = nil
    else
        frame.zoom = {}
    end

    frame.zoom.mode = "OUT"
    frame.zoom.timeToZoom = timeToZoom
    frame.zoom.startScale = startScale or frame:GetScale()
    frame.zoom.endScale = endScale or 0
    frame.zoom.diffScale = frame.zoom.startScale - frame.zoom.endScale

    FrameZoom(frame, frame.zoom)
end

function AF.FrameZoomTo(frame, timeToZoom, endScale)
    if frame.zoom then
        frame.zoom.zoomTimer = nil
    else
        frame.zoom = {}
    end

    frame.zoom.timeToZoom = timeToZoom
    frame.zoom.startScale = frame:GetScale()
    frame.zoom.endScale = endScale
    frame.zoom.diffScale = abs(frame.zoom.startScale - frame.zoom.endScale)

    if frame.zoom.startScale > frame.zoom.endScale then
        frame.zoom.mode = "OUT"
        FrameZoom(frame, frame.zoom)
    elseif frame.zoom.startScale < frame.zoom.endScale then
        frame.zoom.mode = "IN"
        FrameZoom(frame, frame.zoom)
    end
end