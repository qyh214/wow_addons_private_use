local env                         = select(2, ...)
local MixinUtil                   = env.WPM:Import("wpm_modules/mixin-util")

local Mixin                       = MixinUtil.Mixin
local CreateFrame                 = CreateFrame
local math                        = math
local abs                         = math.abs
local exp                         = math.exp
local max                         = math.max
local min                         = math.min
local IsShiftKeyDown              = IsShiftKeyDown

local UIKit_Primitives_Frame      = env.WPM:Import("wpm_modules/ui-kit/primitives/frame")
local UIKit_Primitives_ScrollView = env.WPM:New("wpm_modules/ui-kit/primitives/scroll-view")


-- Helper
--------------------------------

local function updateContentExtentEvents(frame)
    local hasContentAbove = frame:HasContentAbove()
    local hasContentBelow = frame:HasContentBelow()
    local hasContentLeft = frame:HasContentLeft()
    local hasContentRight = frame:HasContentRight()

    if hasContentAbove ~= frame.__lastHasContentAboveState then
        frame:TriggerEvent("OnContentAboveChanged", hasContentAbove)
    end
    if hasContentBelow ~= frame.__lastHasContentBelowState then
        frame:TriggerEvent("OnContentBelowChanged", hasContentBelow)
    end
    if hasContentLeft ~= frame.__lastHasContentLeftState then
        frame:TriggerEvent("OnContentLeftChanged", hasContentLeft)
    end
    if hasContentRight ~= frame.__lastHasContentRightState then
        frame:TriggerEvent("OnContentRightChanged", hasContentRight)
    end

    frame.__lastHasContentAboveState = hasContentAbove
    frame.__lastHasContentBelowState = hasContentBelow
    frame.__lastHasContentLeftState = hasContentLeft
    frame.__lastHasContentRightState = hasContentRight
end


-- Scroll View
--------------------------------

local ScrollViewMixin = {}
do
    -- Init
    --------------------------------

    function ScrollViewMixin:Init()
        self.__isVertical = true
        self.__isHorizontal = false
        self.__stepSize = 150
        self.__interpolate = false
        self.__interpolateRatio = 8
        self.__targetVertical = 0
        self.__targetHorizontal = 0

        self.__lastHasContentAboveState = nil
        self.__lastHasContentBelowState = nil
        self.__lastHasContentLeftState = nil
        self.__lastHasContentRightState = nil

    end


    -- Accessor
    --------------------------------

    function ScrollViewMixin:GetContentFrame()
        return self.__ContentFrame
    end

    function ScrollViewMixin:GetScrollFrame()
        return self.__ScrollFrame
    end


    -- Get
    --------------------------------

    function ScrollViewMixin:HasContentAbove()
        local verticalScroll = self:GetScrollFrame():GetVerticalScroll()
        return verticalScroll > 1
    end

    function ScrollViewMixin:HasContentBelow()
        local scrollFrameHeight = self:GetScrollFrame():GetHeight()
        local contentFrameHeight = self:GetContentFrame():GetHeight()
        local bottomPoint = contentFrameHeight - scrollFrameHeight
        local verticalScroll = self:GetScrollFrame():GetVerticalScroll()
        return verticalScroll < bottomPoint - 1
    end

    function ScrollViewMixin:HasContentLeft()
        local horizontalScroll = self:GetScrollFrame():GetHorizontalScroll()
        return horizontalScroll > 1
    end

    function ScrollViewMixin:HasContentRight()
        local scrollFrameWidth = self:GetScrollFrame():GetWidth()
        local contentFrameWidth = self:GetContentFrame():GetWidth()
        local rightPoint = contentFrameWidth - scrollFrameWidth
        local horizontalScroll = self:GetScrollFrame():GetHorizontalScroll()
        return horizontalScroll < rightPoint - 1
    end

    function ScrollViewMixin:GetContentHeight()
        return self:GetContentFrame():GetHeight()
    end

    function ScrollViewMixin:GetContentWidth()
        return self:GetContentFrame():GetWidth()
    end


    -- Set
    --------------------------------

    function ScrollViewMixin:SetDirection(vertical, horizontal)
        self.__isVertical = vertical ~= false
        self.__isHorizontal = horizontal == true
    end

    function ScrollViewMixin:SetStepSize(size)
        self.__stepSize = size or 150
    end


    -- Fit Content
    --------------------------------

    function ScrollViewMixin:CustomFitContent()
        local shouldFitWidth, shouldFitHeight = self:GetFitContent()
        self:FitContent(shouldFitWidth, shouldFitHeight, { self:GetContentFrame() })
    end


    -- Smooth Scrolling
    --------------------------------

    local function smoothOnUpdate(frame, elapsed)
        local container = frame:GetParent()
        local scrollFrame = container:GetScrollFrame()
        local speed = container.__interpolateRatio

        local currentV, currentH = scrollFrame:GetVerticalScroll(), scrollFrame:GetHorizontalScroll()
        local targetV, targetH = container.__targetVertical, container.__targetHorizontal
        local deltaV, deltaH = targetV - currentV, targetH - currentH
        local moving = false

        local t = 1 - exp(-speed * elapsed)

        if abs(deltaV) >= 1 then
            scrollFrame:SetVerticalScroll(currentV + deltaV * t)
            moving = true
        elseif deltaV ~= 0 then
            scrollFrame:SetVerticalScroll(targetV)
        end

        if abs(deltaH) >= 1 then
            scrollFrame:SetHorizontalScroll(currentH + deltaH * t)
            moving = true
        elseif deltaH ~= 0 then
            scrollFrame:SetHorizontalScroll(targetH)
        end

        if not moving then
            frame:SetScript("OnUpdate", nil)
        end

        updateContentExtentEvents(container)
    end


    local function setScroll(self, isVertical, value, instant)
        local contentFrame = self:GetContentFrame()
        local scrollFrame = self:GetScrollFrame()
        local contentSize = isVertical and contentFrame:GetHeight() or contentFrame:GetWidth()
        local frameSize = isVertical and scrollFrame:GetHeight() or scrollFrame:GetWidth()
        local maxScrollValue = max(0, contentSize - frameSize)
        local clampedValue = min(maxScrollValue, max(0, value))

        if self.__interpolate and not instant then
            if isVertical then
                self.__targetVertical = clampedValue
            else
                self.__targetHorizontal = clampedValue
            end

            local current = isVertical and scrollFrame:GetVerticalScroll() or scrollFrame:GetHorizontalScroll()
            if abs(current - clampedValue) >= 1 then
                local smooth = self.uk_smoothFrame
                if not smooth then
                    smooth = CreateFrame("Frame", nil, self)
                    self.uk_smoothFrame = smooth
                end
                if not smooth:GetScript("OnUpdate") then
                    smooth:SetScript("OnUpdate", smoothOnUpdate)
                end
            else
                if isVertical then
                    scrollFrame:SetVerticalScroll(clampedValue)
                else
                    scrollFrame:SetHorizontalScroll(clampedValue)
                end
                local smooth = self.uk_smoothFrame
                if smooth then smooth:SetScript("OnUpdate", nil) end
            end
        else
            if self.__interpolate and instant then
                if isVertical then
                    self.__targetVertical = clampedValue
                else
                    self.__targetHorizontal = clampedValue
                end
            end

            if isVertical then
                scrollFrame:SetVerticalScroll(clampedValue)
            else
                scrollFrame:SetHorizontalScroll(clampedValue)
            end

            updateContentExtentEvents(self)
        end
    end

    function ScrollViewMixin:SetSmoothScrolling(enabled, ratio)
        self.__interpolate = enabled
        self.__interpolateRatio = ratio or 8

        if not enabled then
            local smooth = self.uk_smoothFrame
            if smooth then smooth:SetScript("OnUpdate", nil) end
            return
        end

        local scrollFrame = self:GetScrollFrame()
        self.__targetVertical = self.__targetVertical or scrollFrame:GetVerticalScroll()
        self.__targetHorizontal = self.__targetHorizontal or scrollFrame:GetHorizontalScroll()

        local deltaV = abs((self.__targetVertical or 0) - scrollFrame:GetVerticalScroll())
        local deltaH = abs((self.__targetHorizontal or 0) - scrollFrame:GetHorizontalScroll())
        if deltaV >= 1 or deltaH >= 1 then
            local smooth = self.uk_smoothFrame
            if not smooth then
                smooth = CreateFrame("Frame", nil, self)
                self.uk_smoothFrame = smooth
            end
            if not smooth:GetScript("OnUpdate") then
                smooth:SetScript("OnUpdate", smoothOnUpdate)
            end
        end
    end


    -- Scroll
    --------------------------------

    function ScrollViewMixin:SetVerticalScroll(value, instant)
        setScroll(self, true, value, instant)
    end

    function ScrollViewMixin:SetHorizontalScroll(value, instant)
        setScroll(self, false, value, instant)
    end

    function ScrollViewMixin:GetVerticalScroll()
        return self.__interpolate and self.__targetVertical or self:GetScrollFrame():GetVerticalScroll()
    end

    function ScrollViewMixin:GetHorizontalScroll()
        return self.__interpolate and self.__targetHorizontal or self:GetScrollFrame():GetHorizontalScroll()
    end

    function ScrollViewMixin:ScrollToTop()
        self:SetVerticalScroll(0)
    end

    function ScrollViewMixin:ScrollToBottom()
        self:SetVerticalScroll(max(0, self:GetContentFrame():GetHeight() - self:GetScrollFrame():GetHeight()))
    end

    function ScrollViewMixin:ScrollToLeft()
        self:SetHorizontalScroll(0)
    end

    function ScrollViewMixin:ScrollToRight()
        self:SetHorizontalScroll(max(0, self:GetContentFrame():GetWidth() - self:GetScrollFrame():GetWidth()))
    end
end

local ScrollViewContentMixin = {}
do
    -- Accessor
    --------------------------------

    function ScrollViewContentMixin:GetParent()
        return self.__parentRef
    end


    -- Fit Content
    --------------------------------

    function ScrollViewContentMixin:CustomFitContent()
        local shouldFitWidth, shouldFitHeight = self:GetFitContent()
        local children = self.__parentRef:GetFrameChildren()

        self:FitContent(shouldFitWidth, shouldFitHeight, children)
    end
end

local function mouseWheelHandler(self, delta)
    local container = self:GetParent()
    if not container then return end

    local useHorizontal = (IsShiftKeyDown() and container.__isHorizontal) or (not container.__isVertical and container.__isHorizontal)

    if useHorizontal then
        local current = container.__interpolate and container.__targetHorizontal or container:GetHorizontalScroll()
        container:SetHorizontalScroll(current + container.__stepSize * delta)
    elseif container.__isVertical then
        local current = container.__interpolate and container.__targetVertical or container:GetVerticalScroll()
        container:SetVerticalScroll(current - container.__stepSize * delta)
    end
end


function UIKit_Primitives_ScrollView.New(name, parent)
    name = name or "undefined"


    local scrollView = UIKit_Primitives_Frame.New("Frame", name, parent)
    Mixin(scrollView, ScrollViewMixin)
    scrollView:Init()


    -- Scroll Frame
    --------------------------------

    local scrollFrame = UIKit_Primitives_Frame.New("ScrollFrame", "$parent.ScrollFrame", scrollView)
    scrollFrame:SetAllPoints(scrollView)
    scrollFrame:SetClipsChildren(true)
    scrollFrame:EnableMouseWheel(true)


    -- Content Frame
    --------------------------------

    local contentFrame = UIKit_Primitives_Frame.New("Frame", "$parent.ContentFrame", scrollFrame)
    contentFrame.uk_type = "ScrollViewContent"
    contentFrame.__parentRef = scrollView
    Mixin(contentFrame, ScrollViewContentMixin)
    scrollFrame:SetScrollChild(contentFrame)


    -- References
    --------------------------------

    scrollView.__ScrollFrame = scrollFrame
    scrollView.__ContentFrame = contentFrame


    -- Events
    --------------------------------

    scrollFrame:SetScript("OnMouseWheel", mouseWheelHandler)
    scrollFrame:HookScript("OnVerticalScroll", function() scrollView:TriggerEvent("OnVerticalScroll") end)
    scrollFrame:HookScript("OnHorizontalScroll", function() scrollView:TriggerEvent("OnHorizontalScroll") end)


    return scrollView
end
