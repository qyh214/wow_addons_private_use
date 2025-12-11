---@class AbstractFramework
local AF = _G.AbstractFramework

local next = next
local abs, min, max = math.abs, math.min, math.max

-----------------------------------------------------------------------------
--                        manager based animations                         --
-----------------------------------------------------------------------------
local ANIMATION_INTERVAL = 0.02

---------------------------------------------------------------------
-- alpha - inspired by ElvUI
---------------------------------------------------------------------
local FADEFRAMES, FADEMANAGER = {}, CreateFrame("FRAME")

local function Fading(_, elapsed)
    FADEMANAGER.timer = (FADEMANAGER.timer or 0) + elapsed

    if FADEMANAGER.timer > ANIMATION_INTERVAL then
        FADEMANAGER.timer = 0

        for frame, info in next, FADEFRAMES do
            if frame:IsVisible() then
                info.fadeTimer = (info.fadeTimer or 0) + (elapsed + ANIMATION_INTERVAL)
            else -- faster for hidden frames
                info.fadeTimer = info.timeToFade + 1
            end

            if info.fadeTimer < info.timeToFade then
                if info.mode == "IN" then
                    frame:SetAlpha((info.fadeTimer / info.timeToFade) * info.diffAlpha + info.startAlpha)
                else -- OUT
                    frame:SetAlpha(((info.timeToFade - info.fadeTimer) / info.timeToFade) * info.diffAlpha + info.endAlpha)
                end
            else
                frame:SetAlpha(info.endAlpha)
                if info.hideAfterFade and not frame:IsProtected() then
                    frame:Hide()
                end
                if frame and FADEFRAMES[frame] then
                    if frame._fade then
                        frame._fade.fadeTimer = nil
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

---@param timeToFade number|nil default is 0.25
---@param startAlpha number|nil default is current alpha
---@param endAlpha number|nil default is 1
function AF.FrameFadeIn(frame, timeToFade, startAlpha, endAlpha)
    if frame._fade then
        frame._fade.fadeTimer = nil
    else
        frame._fade = {}
    end

    frame._fade.mode = "IN"
    frame._fade.timeToFade = timeToFade or 0.25
    frame._fade.startAlpha = startAlpha or frame:GetAlpha()
    frame._fade.endAlpha = endAlpha or 1
    frame._fade.diffAlpha = frame._fade.endAlpha - frame._fade.startAlpha
    frame._fade.hideAfterFade = nil

    if frame._fade.startAlpha ~= frame._fade.endAlpha then
        FrameFade(frame, frame._fade)
    elseif not frame:IsProtected() then
        frame:Show()
    end
end

---@param timeToFade number|nil default is 0.25
---@param startAlpha number|nil default is current alpha
---@param endAlpha number|nil default is 0
---@param hideAfterFade boolean|nil
function AF.FrameFadeOut(frame, timeToFade, startAlpha, endAlpha, hideAfterFade)
    if frame._fade then
        frame._fade.fadeTimer = nil
    else
        frame._fade = {}
    end

    frame._fade.mode = "OUT"
    frame._fade.timeToFade = timeToFade or 0.25
    frame._fade.startAlpha = startAlpha or frame:GetAlpha()
    frame._fade.endAlpha = endAlpha or 0
    frame._fade.diffAlpha = frame._fade.startAlpha - frame._fade.endAlpha
    frame._fade.hideAfterFade = hideAfterFade

    if frame._fade.startAlpha ~= frame._fade.endAlpha then
        FrameFade(frame, frame._fade)
    elseif hideAfterFade and not frame:IsProtected() then
        frame:Hide()
    end
end

---------------------------------------------------------------------
-- continual fade in and out
---------------------------------------------------------------------
local CONTINUAL_FADEFRAMES, CONTINUAL_FADEMANAGER = {}, CreateFrame("FRAME")

local function ContinualFading(_, elapsed)
    CONTINUAL_FADEMANAGER.timer = (CONTINUAL_FADEMANAGER.timer or 0) + elapsed

    if CONTINUAL_FADEMANAGER.timer > ANIMATION_INTERVAL then
        CONTINUAL_FADEMANAGER.timer = 0

        for frame, info in next, CONTINUAL_FADEFRAMES do
            info.fadeTimer = (info.fadeTimer or 0) + ANIMATION_INTERVAL

            if info.phase == "IN" then
                if info.fadeTimer < info.timeToFade then
                    frame:SetAlpha((info.fadeTimer / info.timeToFade) * (1 - info.startAlpha) + info.startAlpha)
                else
                    frame:SetAlpha(1)
                    info.phase = "HOLD"
                    info.fadeTimer = 0
                end
            elseif info.phase == "HOLD" then
                if info.fadeTimer >= info.holdTime then
                    info.phase = "OUT"
                    info.fadeTimer = 0
                end
            elseif info.phase == "OUT" then
                if info.fadeTimer < info.timeToFade then
                    frame:SetAlpha(1 - (info.fadeTimer / info.timeToFade))
                else
                    frame:SetAlpha(0)
                    if not frame:IsProtected() then
                        frame:Hide()
                    end
                    if frame and CONTINUAL_FADEFRAMES[frame] then
                        CONTINUAL_FADEFRAMES[frame] = nil
                        if frame._continualFade then frame._continualFade.fadeTimer = nil end
                    end
                end
            end
        end

        if not next(CONTINUAL_FADEFRAMES) then
            CONTINUAL_FADEMANAGER:SetScript("OnUpdate", nil)
        end
    end
end

local function FrameFadeInOut(frame, info)
    frame:SetAlpha(info.startAlpha)

    if not frame:IsProtected() then
        frame:Show()
    end

    CONTINUAL_FADEFRAMES[frame] = info
    CONTINUAL_FADEMANAGER:SetScript("OnUpdate", ContinualFading)
end

---@param timeToFade number|nil default is 0.25
---@param holdTime number|nil default is 0.5
---@param startFromCurrentAlpha boolean|nil if true, start from current alpha, otherwise start from 0, default is false
function AF.FrameFadeInOut(frame, timeToFade, holdTime, startFromCurrentAlpha)
    if frame._continualFade then
        frame._continualFade.fadeTimer = nil
    else
        frame._continualFade = {}
    end

    local info = frame._continualFade
    info.timeToFade = timeToFade or 0.25
    info.holdTime = holdTime or 0.5
    info.phase = "IN"
    info.fadeTimer = 0
    info.startAlpha = startFromCurrentAlpha and frame:GetAlpha() or 0

    FrameFadeInOut(frame, info)
end

---------------------------------------------------------------------
-- zoom
---------------------------------------------------------------------
local ZOOMFRAMES, ZOOMMANAGER = {}, CreateFrame("FRAME")

local function Zooming(_, elapsed)
    ZOOMMANAGER.timer = (ZOOMMANAGER.timer or 0) + elapsed

    if ZOOMMANAGER.timer > ANIMATION_INTERVAL then
        ZOOMMANAGER.timer = 0

        for frame, info in next, ZOOMFRAMES do
            if frame:IsVisible() then
                info.zoomTimer = (info.zoomTimer or 0) + (elapsed + ANIMATION_INTERVAL)
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
                    if frame._zoom then
                        frame._zoom.zoomTimer = nil
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

local function FrameZoom(frame, info)
    frame:SetScale(info.startScale)

    if not frame:IsProtected() then
        frame:Show()
    end

    if not ZOOMFRAMES[frame] then
        ZOOMFRAMES[frame] = info
        ZOOMMANAGER:SetScript("OnUpdate", Zooming)
    else
        ZOOMFRAMES[frame] = info
    end
end

function AF.FrameZoomIn(frame, timeToZoom, startScale, endScale)
    if frame._zoom then
        frame._zoom.zoomTimer = nil
    else
        frame._zoom = {}
    end

    frame._zoom.mode = "IN"
    frame._zoom.timeToZoom = timeToZoom or 0.25
    frame._zoom.startScale = startScale or frame:GetScale()
    frame._zoom.endScale = endScale or 1
    frame._zoom.diffScale = frame._zoom.endScale - frame._zoom.startScale

    FrameZoom(frame, frame._zoom)
end

function AF.FrameZoomOut(frame, timeToZoom, startScale, endScale)
    if frame._zoom then
        frame._zoom.zoomTimer = nil
    else
        frame._zoom = {}
    end

    frame._zoom.mode = "OUT"
    frame._zoom.timeToZoom = timeToZoom or 0.25
    frame._zoom.startScale = startScale or frame:GetScale()
    frame._zoom.endScale = endScale or 0
    frame._zoom.diffScale = frame._zoom.startScale - frame._zoom.endScale

    FrameZoom(frame, frame._zoom)
end

function AF.FrameZoomTo(frame, timeToZoom, endScale)
    if frame._zoom then
        frame._zoom.zoomTimer = nil
    else
        frame._zoom = {}
    end

    frame._zoom.timeToZoom = timeToZoom or 0.25
    frame._zoom.startScale = frame:GetScale()
    frame._zoom.endScale = endScale
    frame._zoom.diffScale = abs(frame._zoom.startScale - frame._zoom.endScale)

    if frame._zoom.startScale > frame._zoom.endScale then
        frame._zoom.mode = "OUT"
        FrameZoom(frame, frame._zoom)
    elseif frame._zoom.startScale < frame._zoom.endScale then
        frame._zoom.mode = "IN"
        FrameZoom(frame, frame._zoom)
    end
end

---------------------------------------------------------------------
-- size
---------------------------------------------------------------------
local SIZEFRAMES, SIZEMANAGER = {}, CreateFrame("FRAME")

local function Sizing(_, elapsed)
    SIZEMANAGER.timer = (SIZEMANAGER.timer or 0) + elapsed

    if SIZEMANAGER.timer > ANIMATION_INTERVAL then
        SIZEMANAGER.timer = 0

        for frame, info in next, SIZEFRAMES do
            if frame:IsVisible() then
                info.sizeTimer = (info.sizeTimer or 0) + (elapsed + ANIMATION_INTERVAL)
            else -- faster for hidden frames
                info.sizeTimer = info.timeToSize + 1
            end

            if info.sizeTimer < info.timeToSize then
                local progress = info.sizeTimer / info.timeToSize
                local currentWidth = info.startWidth + info.diffWidth * progress
                local currentHeight = info.startHeight + info.diffHeight * progress

                frame:SetSize(currentWidth, currentHeight)
            else
                frame:SetSize(info.endWidth, info.endHeight)
                -- NOTE: remove from SIZEFRAMES
                if frame and SIZEFRAMES[frame] then
                    if frame._size then
                        frame._size.sizeTimer = nil
                    end
                    SIZEFRAMES[frame] = nil
                end
            end
        end

        if not next(SIZEFRAMES) then
            SIZEMANAGER:SetScript("OnUpdate", nil)
        end
    end
end

local function FrameSize(frame, info)
    frame:SetSize(info.startWidth, info.startHeight)

    if not frame:IsProtected() then
        frame:Show()
    end

    if not SIZEFRAMES[frame] then
        SIZEFRAMES[frame] = info
        SIZEMANAGER:SetScript("OnUpdate", Sizing)
    else
        SIZEFRAMES[frame] = info
    end
end

local function FixZero(n)
    if n == 0 then
        return 0.001
    end
    return n
end

---@param timeToSize number|nil default is 0.25
---@param startWidth number|nil default is current width
---@param startHeight number|nil default is current height
---@param endWidth number|nil default is current width
---@param endHeight number|nil default is current height
function AF.FrameResizeTo(frame, timeToSize, startWidth, startHeight, endWidth, endHeight)
    if frame._size then
        frame._size.sizeTimer = nil
    else
        frame._size = {}
    end

    frame._size.timeToSize = timeToSize or 0.25
    frame._size.startWidth = FixZero(startWidth or frame:GetWidth())
    frame._size.startHeight = FixZero(startHeight or frame:GetHeight())
    frame._size.endWidth = FixZero(endWidth or frame:GetWidth())
    frame._size.endHeight = FixZero(endHeight or frame:GetHeight())
    frame._size.diffWidth = frame._size.endWidth - frame._size.startWidth
    frame._size.diffHeight = frame._size.endHeight - frame._size.startHeight

    if frame._size.startWidth ~= frame._size.endWidth or frame._size.startHeight ~= frame._size.endHeight then
        FrameSize(frame, frame._size)
    end
end

---@param timeToSize number|nil default is 0.25
---@param startWidth number|nil default is current width
---@param endWidth number|nil default is current width
function AF.FrameResizeWidth(frame, timeToSize, startWidth, endWidth)
    local currentHeight = frame:GetHeight()
    AF.FrameResizeTo(frame, timeToSize, startWidth, currentHeight, endWidth, currentHeight)
end

---@param timeToSize number|nil default is 0.25
---@param startHeight number|nil default is current height
---@param endHeight number|nil default is current height
function AF.FrameResizeHeight(frame, timeToSize, startHeight, endHeight)
    local currentWidth = frame:GetWidth()
    AF.FrameResizeTo(frame, timeToSize, currentWidth, startHeight, currentWidth, endHeight)
end

---------------------------------------------------------------------
-- flash (optimization of UIFrameFlash & UIFrameFlashStop)
---------------------------------------------------------------------
local FLASHFRAMES, FLASHMANAGER = {}, CreateFrame("FRAME")
local FlashTimers = {}
local FlashTimerRefCount = {}

local function Flashing(_, elapsed)
    FLASHMANAGER.timer = (FLASHMANAGER.timer or 0) + elapsed

    if FLASHMANAGER.timer > ANIMATION_INTERVAL then
        FLASHMANAGER.timer = 0

        -- Update timers for all synced frames
        for syncId, timer in next, FlashTimers do
            FlashTimers[syncId] = timer + (elapsed + ANIMATION_INTERVAL)
        end

        local flashTime

        for frame, info in next, FLASHFRAMES do
            info.flashTimer = (info.flashTimer or 0) + (elapsed + ANIMATION_INTERVAL)

            if info.flashTimer < info.flashDuration or info.flashDuration == -1 then
                flashTime = info.flashTimer

                -- Use sync timer if syncId is set
                if info.syncId then
                    flashTime = FlashTimers[info.syncId] or flashTime
                end

                flashTime = flashTime % (info.fadeInTime + info.fadeOutTime + info.flashInHoldTime + info.flashOutHoldTime)

                local alpha
                if flashTime < info.fadeInTime then
                    frame:SetAlpha(flashTime / info.fadeInTime)
                elseif flashTime < info.fadeInTime + info.flashInHoldTime then
                    frame:SetAlpha(1)
                elseif flashTime < info.fadeInTime + info.flashInHoldTime + info.fadeOutTime then
                    frame:SetAlpha(1 - ((flashTime - info.fadeInTime - info.flashInHoldTime) / info.fadeOutTime))
                else
                    frame:SetAlpha(0)
                end
            else
                frame:SetAlpha(1.0)
                if info.showWhenDone then
                    if not frame:IsProtected() then frame:Show() end
                else
                    if not frame:IsProtected() then frame:Hide() end
                end

                -- NOTE: remove from FLASHFRAMES and cleanup sync
                if frame and FLASHFRAMES[frame] then
                    if info.syncId then
                        FlashTimerRefCount[info.syncId] = FlashTimerRefCount[info.syncId] - 1
                        if FlashTimerRefCount[info.syncId] <= 0 then
                            FlashTimers[info.syncId] = nil
                            FlashTimerRefCount[info.syncId] = nil
                        end
                    end
                    if frame._flash then
                        frame._flash.flashTimer = nil
                    end
                    FLASHFRAMES[frame] = nil
                end
            end
        end

        if not next(FLASHFRAMES) then
            FLASHMANAGER:SetScript("OnUpdate", nil)
        end
    end
end

local function FrameFlash(frame, info)
    if not frame:IsProtected() then
        frame:Show()
    end

    if not FLASHFRAMES[frame] then
        FLASHFRAMES[frame] = info
        FLASHMANAGER:SetScript("OnUpdate", Flashing)
    else
        FLASHFRAMES[frame] = info
    end
end

---@param fadeInTime number|nil time it takes to fade in, default is 0.5
---@param fadeOutTime number|nil time it takes to fade out, default is fadeInTime
---@param flashDuration number|nil how long to keep flashing, -1 means forever, default is -1
---@param showWhenDone boolean|nil show the frame when flash ends
---@param flashInHoldTime number|nil how long to hold the faded in state
---@param flashOutHoldTime number|nil how long to hold the faded out state
---@param syncId string|nil synchronization id for multiple frames
function AF.FrameFlashStart(frame, fadeInTime, fadeOutTime, flashDuration, showWhenDone, flashInHoldTime, flashOutHoldTime, syncId)
    if frame._flash then
        -- Clean up old sync if exists
        if frame._flash.syncId then
            FlashTimerRefCount[frame._flash.syncId] = FlashTimerRefCount[frame._flash.syncId] - 1
            if FlashTimerRefCount[frame._flash.syncId] <= 0 then
                FlashTimers[frame._flash.syncId] = nil
                FlashTimerRefCount[frame._flash.syncId] = nil
            end
        end
        frame._flash.flashTimer = nil
    else
        frame._flash = {}
    end

    frame._flash.fadeInTime = fadeInTime or 0.5
    frame._flash.fadeOutTime = fadeOutTime or frame._flash.fadeInTime
    frame._flash.flashDuration = flashDuration or -1
    frame._flash.showWhenDone = showWhenDone
    frame._flash.flashTimer = 0
    frame._flash.flashInHoldTime = flashInHoldTime or 0
    frame._flash.flashOutHoldTime = flashOutHoldTime or 0
    frame._flash.syncId = syncId

    -- Setup sync timer if syncId is provided
    if syncId then
        if not FlashTimers[syncId] then
            FlashTimers[syncId] = 0
            FlashTimerRefCount[syncId] = 0
        end
        FlashTimerRefCount[syncId] = FlashTimerRefCount[syncId] + 1
    end

    FrameFlash(frame, frame._flash)
end

---@param forceVisible boolean|nil if true, show the frame when stopping flash, if false, hide the frame, if nil, show or hide according to showWhenDone
function AF.FrameFlashStop(frame, forceVisible)
    if frame._flash then
        -- Clean up sync if exists
        if frame._flash.syncId then
            FlashTimerRefCount[frame._flash.syncId] = FlashTimerRefCount[frame._flash.syncId] - 1
            if FlashTimerRefCount[frame._flash.syncId] <= 0 then
                FlashTimers[frame._flash.syncId] = nil
                FlashTimerRefCount[frame._flash.syncId] = nil
            end
            frame._flash.syncId = nil
        end
        frame._flash.flashTimer = nil
    end

    if FLASHFRAMES[frame] then
        FLASHFRAMES[frame] = nil
    end

    frame:SetAlpha(1.0)

    if frame:IsProtected() then return end

    if forceVisible == true then
        frame:Show()
    elseif forceVisible == false then
        frame:Hide()
    elseif frame._flash then
        if frame._flash.showWhenDone then
            frame:Show()
        else
            frame:Hide()
        end
    end
end





-----------------------------------------------------------------------------
--                         self managed animations                         --
-----------------------------------------------------------------------------
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
---@param region Region
---@param duration number|nil default is 0.5
---@param enableShowHideHook boolean|nil whether to hook OnShow/OnHide to control the animation
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
        local left = AF.Round(frame:GetLeft())
        local right = AF.Round(frame:GetRight())
        local top = AF.Round(frame:GetTop())
        local bottom = AF.Round(frame:GetBottom())

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

    local currentHeight = frame:GetHeight()
    local currentWidth = frame:GetWidth()
    targetWidth = targetWidth or currentWidth
    targetHeight = targetHeight or currentHeight

    local diffW = (targetWidth - currentWidth) / steps
    local diffH = (targetHeight - currentHeight) / steps

    frame._animatedResizeTimer = C_Timer.NewTicker(frequency, function()
        if not AF.ApproxZero(diffW) then
            if diffW > 0 then
                currentWidth = min(currentWidth + diffW, targetWidth)
            else
                currentWidth = max(currentWidth + diffW, targetWidth)
            end
            frame:SetWidth(currentWidth)
        end

        if not AF.ApproxZero(diffH) then
            if diffH > 0 then
                currentHeight = min(currentHeight + diffH, targetHeight)
            else
                currentHeight = max(currentHeight + diffH, targetHeight)
            end
            frame:SetHeight(currentHeight)
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