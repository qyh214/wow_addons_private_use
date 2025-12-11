local env                           = select(2, ...)
local MixinUtil                     = env.WPM:Import("wpm_modules/mixin-util")

local math_min                      = math.min
local math_max                      = math.max
local Mixin                         = MixinUtil.Mixin

local UIKit_Primitives_LinearSlider = env.WPM:Import("wpm_modules/ui-kit/primitives/linear-slider")
local UIKit_Primitives_ScrollBar    = env.WPM:New("wpm_modules/ui-kit/primitives/scroll-bar")


-- Scroll Bar
--------------------------------

local ScrollBarMixin = {}
do
    -- Update
    --------------------------------

    local function clamp(value)
        return math_max(0, math_min(1, value))
    end

    local function getCursorScale(frame)
        local scale = frame:GetEffectiveScale() or 1
        return scale ~= 0 and (1 / scale) or 1
    end

    function ScrollBarMixin:SetThumbVisible(isVisible)
        local thumb = self.__Thumb
        local thumbAnchor = self.__ThumbAnchor
        if thumb then thumb:SetShown(isVisible) end
        if thumbAnchor then thumbAnchor:SetShown(isVisible) end
    end

    function ScrollBarMixin:SetThumbSize()
        local target = self.__target
        local isVertical = self.__isVertical
        if not target or isVertical == nil then return end

        local contentSize = isVertical and (target:GetContentHeight() or 0) or (target:GetContentWidth() or 0)
        local frameSize = isVertical and (target:GetHeight() or 0) or (target:GetWidth() or 0)
        local trackSize = isVertical and (self:GetHeight() or 0) or (self:GetWidth() or 0)

        if contentSize <= frameSize or trackSize <= 0 then
            self:SetThumbVisible(false)
            return
        end

        local thumbAnchor = self.__ThumbAnchor
        local thumbSize = trackSize * math_min(frameSize / contentSize, 1)

        if isVertical then
            local trackWidth = self:GetWidth()
            if thumbAnchor:GetWidth() ~= trackWidth then thumbAnchor:SetWidth(trackWidth) end
            thumbAnchor:SetHeight(thumbSize)
        else
            local trackHeight = self:GetHeight()
            if thumbAnchor:GetHeight() ~= trackHeight then thumbAnchor:SetHeight(trackHeight) end
            thumbAnchor:SetWidth(thumbSize)
        end

        self:SetThumbVisible(true)
    end

    function ScrollBarMixin:SyncValue()
        local target = self.__target
        local isVertical = self.__isVertical
        if not target or isVertical == nil then return end

        local scrollFrame = target.GetScrollFrame and target:GetScrollFrame()
        local contentSize, frameSize, scrollPosition

        if isVertical then
            contentSize = target:GetContentHeight() or 0
            frameSize = target:GetHeight() or 0
            local source = (scrollFrame and scrollFrame.GetVerticalScroll) and scrollFrame or target
            scrollPosition = source:GetVerticalScroll() or 0
        else
            contentSize = target:GetContentWidth() or 0
            frameSize = target:GetWidth() or 0
            local source = (scrollFrame and scrollFrame.GetHorizontalScroll) and scrollFrame or target
            scrollPosition = source:GetHorizontalScroll() or 0
        end

        local scrollableRange = contentSize - frameSize
        local offset = (scrollableRange > 0) and clamp(scrollPosition / scrollableRange) or 0

        self:SetValue(offset)
        self:SetThumbSize()
    end

    function ScrollBarMixin:SetTargetScroll(isInstant)
        local target = self.__target
        local isVertical = self.__isVertical
        if not target or isVertical == nil then return end

        local normalizedOffset = self:GetValue()
        if isVertical then
            local scrollableRange = target:GetContentHeight() - target:GetHeight()
            target:SetVerticalScroll(normalizedOffset * scrollableRange, isInstant)
        else
            local scrollableRange = target:GetContentWidth() - target:GetWidth()
            target:SetHorizontalScroll(normalizedOffset * scrollableRange, isInstant)
        end
    end


    -- Handler
    --------------------------------

    function ScrollBarMixin.OnTrackMouseDown(self, button)
        if self.__thumbDragTravel then
            self:UpdateThumbDrag()
            return
        end

        local isVertical = self.__isVertical
        if isVertical == nil or not self.__ThumbAnchor then return end

        local trackSize = isVertical and (self:GetHeight() or 0) or (self:GetWidth() or 0)
        if trackSize <= 0 then return end

        local trackLeft, trackBottom = self:GetLeft(), self:GetBottom()
        if not trackLeft or not trackBottom then return end

        local cursorX, cursorY = GetCursorPosition()
        local cursorScale = getCursorScale(self)
        local relativePosition

        if isVertical then
            relativePosition = 1 - ((cursorY * cursorScale) - trackBottom) / trackSize
        else
            relativePosition = ((cursorX * cursorScale) - trackLeft) / trackSize
        end

        self:SetValue(clamp(relativePosition))
        self:SetTargetScroll()
    end


    -- Get
    --------------------------------

    function ScrollBarMixin:GetVertical()
        return self.__isVertical
    end

    function ScrollBarMixin:GetTarget()
        return self.__target
    end


    -- Set
    --------------------------------

    function ScrollBarMixin:SetVertical(value)
        self:SetOrientation(value and "VERTICAL" or "HORIZONTAL")
        self.__isVertical = value
    end

    function ScrollBarMixin:SetTarget(scrollTarget)
        local previousTarget = self.__target
        if previousTarget then
            previousTarget:UnhookEvent("OnVerticalScroll", self)
            previousTarget:UnhookEvent("OnHorizontalScroll", self)
        end

        local handler = self.__scrollHandler
        if not handler then
            handler = function() self:SyncValue() end
            self.__scrollHandler = handler
        end

        scrollTarget:HookEvent("OnVerticalScroll", handler)
        scrollTarget:HookEvent("OnHorizontalScroll", handler)
        self.__target = scrollTarget
    end


    -- Thumb Drag
    --------------------------------

    local function onThumbDragUpdate(self)
        local dragTravel = self.__thumbDragTravel
        if not dragTravel then return end

        local cursorX, cursorY = GetCursorPosition()
        local scaledCursor = (self.__isVertical and cursorY or cursorX) * self.__thumbDragCursorScale
        local cursorDelta = (scaledCursor - self.__thumbDragCursorOrigin) * self.__thumbDragDirection
        local newValue = self.__thumbDragValueOrigin + (cursorDelta / dragTravel) * self.__thumbDragRange
        newValue = math_max(self.__thumbDragMin, math_min(self.__thumbDragMax, newValue))

        if newValue ~= self:GetValue() then
            self:SetValue(newValue)
            self:SetTargetScroll(true)
        end
    end

    function ScrollBarMixin:UpdateThumbDrag()
        if self:IsEnabled() then onThumbDragUpdate(self) end
    end

    function ScrollBarMixin:OnThumbMouseDown(button)
        if not self:IsEnabled() or button ~= "LeftButton" then return end

        local thumbAnchor = self.__ThumbAnchor
        local isVertical = self.__isVertical
        if not thumbAnchor or isVertical == nil then return end

        local minValue, maxValue = self:GetMinMaxValues()
        if not minValue or not maxValue or maxValue <= minValue then return end

        local trackSize = isVertical and (self:GetHeight() or 0) or (self:GetWidth() or 0)
        local thumbSize = isVertical and (thumbAnchor:GetHeight() or 0) or (thumbAnchor:GetWidth() or 0)
        local thumbTravel = trackSize - thumbSize
        if thumbTravel <= 0 then return end

        local cursorScale = getCursorScale(self)
        local cursorX, cursorY = GetCursorPosition()

        self.__thumbDragMin = minValue
        self.__thumbDragMax = maxValue
        self.__thumbDragRange = maxValue - minValue
        self.__thumbDragTravel = thumbTravel
        self.__thumbDragCursorScale = cursorScale
        self.__thumbDragCursorOrigin = (isVertical and cursorY or cursorX) * cursorScale
        self.__thumbDragValueOrigin = self:GetValue()
        self.__thumbDragDirection = isVertical and -1 or 1

        self:SetScript("OnUpdate", onThumbDragUpdate)
        self:UpdateThumbDrag()
    end

    function ScrollBarMixin:OnThumbMouseUp(button)
        if not self:IsEnabled() or button ~= "LeftButton" then return end

        self:SetScript("OnUpdate", nil)
        self.__thumbDragTravel = nil
    end
end


function UIKit_Primitives_ScrollBar.New(name, parent)
    name = name or "undefined"


    local scrollBar = UIKit_Primitives_LinearSlider.New(name, parent)
    Mixin(scrollBar, ScrollBarMixin)
    scrollBar:SetMinMaxValues(0, 1)
    scrollBar:SetEnabled(false)


    -- Initialize
    --------------------------------

    scrollBar.__isVertical = true
    scrollBar.__target = nil


    -- Events
    --------------------------------

    scrollBar:HookEvent("OnTrackMouseDown", scrollBar.OnTrackMouseDown)
    scrollBar:HookEvent("OnThumbMouseDown", scrollBar.OnThumbMouseDown)
    scrollBar:HookEvent("OnThumbMouseUp", scrollBar.OnThumbMouseUp)


    return scrollBar
end
