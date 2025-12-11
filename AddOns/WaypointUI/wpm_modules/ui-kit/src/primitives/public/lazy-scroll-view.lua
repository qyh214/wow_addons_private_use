local env                             = select(2, ...)
local MixinUtil                       = env.WPM:Import("wpm_modules/mixin-util")

local Mixin                           = MixinUtil.Mixin
local CreateFrame                     = CreateFrame
local abs                             = math.abs
local max                             = math.max
local min                             = math.min
local exp                             = math.exp
local huge                            = math.huge
local IsShiftKeyDown                  = IsShiftKeyDown
local tinsert                         = table.insert
local assert                          = assert

local UIKit_Primitives_Frame          = env.WPM:Import("wpm_modules/ui-kit/primitives/frame")
local UIKit_Primitives_LazyScrollView = env.WPM:New("wpm_modules/ui-kit/primitives/lazy-scroll-view")


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


-- LazyScrollView
--------------------------------

local LazyScrollViewPoolingMixin = {}
do
    -- Init
    --------------------------------

    function LazyScrollViewPoolingMixin:InitLazyScrollViewPooling()
        self.__elementPool = {}
        self.__data = nil
        self.__prefabConstructorFunc = nil
        self.__onElementUpdateFunc = nil
        self.__elementHeight = 25
        self.__elementWidth = 25
        self.__numVisibleElements = 0
        self.__visibleStartingIndex = nil
        self.__lastUpdateStartingIndex = nil
    end


    -- API
    --------------------------------

    function LazyScrollViewPoolingMixin:UpdateAllVisibleElements()
        if not self.__data or not self.__visibleStartingIndex then return end

        local startingIndex = self.__visibleStartingIndex

        for i = 1, self.__numVisibleElements do
            local dataIndex = startingIndex + i - 1
            local dataValue = self.__data[dataIndex]

            local element = self:GetElement(i)

            if dataIndex > #self.__data then
                element:Hide()
            else
                element:Show()

                if self.__onElementUpdateFunc then
                    self.__onElementUpdateFunc(element, dataIndex, dataValue)
                end
            end
        end
    end

    function LazyScrollViewPoolingMixin:SetPrefab(prefabConstructorFunc)
        self.__prefabConstructorFunc = prefabConstructorFunc
    end

    function LazyScrollViewPoolingMixin:SetOnElementUpdate(func)
        self.__onElementUpdateFunc = func
    end

    function LazyScrollViewPoolingMixin:SetData(data)
        self.__data = data
        self:ResetScrolling()
        self:UpdateContentExtent()
        self:RenderElements()

        C_Timer.After(0, function()
            self:UpdateScrolling()
        end)
    end

    function LazyScrollViewPoolingMixin:SetElementHeight(height)
        self.__elementHeight = height
        self:UpdateAfterSizingChange()
    end

    function LazyScrollViewPoolingMixin:SetElementWidth(width)
        self.__elementWidth = width
        self:UpdateAfterSizingChange()
    end

    function LazyScrollViewPoolingMixin:ScrollToIndex(index)
        if not self.__data then return end

        local elementPosition = self:GetElementPosition(index + 1) - self:GetScrollFrame():GetHeight() / 2
        self:SetVerticalScroll(elementPosition)
    end

    function LazyScrollViewPoolingMixin:GetElementHeight()
        return self.__elementHeight
    end

    function LazyScrollViewPoolingMixin:GetElementWidth()
        return self.__elementWidth
    end

    function LazyScrollViewPoolingMixin:GetElementPosition(index)
        if not self.__data then return end

        local elementSize = self:GetPrimaryElementSize()
        local elementPosition = (index - 1) * elementSize
        return elementPosition
    end

    function LazyScrollViewPoolingMixin:IsHorizontalPrimary()
        return self.__isHorizontal and not self.__isVertical
    end

    function LazyScrollViewPoolingMixin:IsVerticalPrimary()
        return self.__isVertical and not self.__isHorizontal
    end

    function LazyScrollViewPoolingMixin:GetPrimaryElementSize()
        local size
        if self:IsHorizontalPrimary() then
            size = self.__elementWidth
            if (not size or size <= 0) and self.__elementPool and self.__elementPool[1] and self.__elementPool[1].GetWidth then
                size = self.__elementPool[1]:GetWidth()
            end
        else
            size = self.__elementHeight
            if (not size or size <= 0) and self.__elementPool and self.__elementPool[1] and self.__elementPool[1].GetHeight then
                size = self.__elementPool[1]:GetHeight()
            end
        end

        return size and size > 0 and size or 1
    end

    function LazyScrollViewPoolingMixin:GetPoolingContentHeight()
        if not self.__data then return 0 end
        local elementHeight = self.__elementHeight
        if (not elementHeight or elementHeight <= 0) and self.__elementPool and self.__elementPool[1] and self.__elementPool[1].GetHeight then
            elementHeight = self.__elementPool[1]:GetHeight()
        end
        return (elementHeight or 1) * #self.__data
    end

    function LazyScrollViewPoolingMixin:GetPoolingContentWidth()
        if not self.__data then return 0 end
        local elementWidth = self.__elementWidth
        if (not elementWidth or elementWidth <= 0) and self.__elementPool and self.__elementPool[1] and self.__elementPool[1].GetWidth then
            elementWidth = self.__elementPool[1]:GetWidth()
        end
        if (not elementWidth or elementWidth <= 0) and self.__elementPool and self.__elementPool[1] and self.__elementPool[1].GetHeight then
            elementWidth = self.__elementPool[1]:GetHeight()
        end
        return (elementWidth or 1) * #self.__data
    end

    function LazyScrollViewPoolingMixin:GetData()
        return self.__data
    end


    -- Internal
    --------------------------------

    function LazyScrollViewPoolingMixin:GetNumElementsToDisplay()
        local shouldFitWidth, shouldFitHeight = self:GetFitContent()

        local scrollFrame = self:GetScrollFrame()
        local elementSize = self:GetPrimaryElementSize()
        local frameExtent

        if self:IsHorizontalPrimary() then
            frameExtent = scrollFrame:GetWidth()
            if shouldFitWidth then
                local maxWidth = self:GetMaxWidth()
                frameExtent = maxWidth or huge
            end
        else
            frameExtent = scrollFrame:GetHeight()
            if shouldFitHeight then
                local maxHeight = self:GetMaxHeight()
                frameExtent = maxHeight or huge
            end
        end

        return math.ceil(frameExtent / elementSize) + 1
    end

    function LazyScrollViewPoolingMixin:HideElements()
        for k, v in ipairs(self.__elementPool) do
            v:Hide()
        end
    end

    function LazyScrollViewPoolingMixin:NewElement()
        assert(self.__prefabConstructorFunc, "No prefab constructor set!")
        local index = #self.__elementPool + 1
        local name = self:GetDebugName() .. ".Element" .. index
        local element = self.__prefabConstructorFunc(name)

        element:parent(self:GetContentFrame())

        tinsert(self.__elementPool, element)

        return element
    end

    function LazyScrollViewPoolingMixin:GetElement(index)
        local element = nil

        if #self.__elementPool < index then
            element = self:NewElement()
        else
            element = self.__elementPool[index]
        end

        return element
    end

    function LazyScrollViewPoolingMixin:RenderElements()
        self:HideElements()
        if not self.__data then
            self.__numVisibleElements = 0
            self:UpdateContentExtent()
            return
        end

        local numElementsToDisplay = self:GetNumElementsToDisplay()
        local elementsToCreate = math.min(numElementsToDisplay, #self.__data)
        self.__numVisibleElements = math.min(numElementsToDisplay, #self.__data)

        for i = 1, elementsToCreate do
            -- Create elements
            local element = self:GetElement(i)
            element:Show()
        end

        self:UpdateContentExtent()

        -- Update elements
        self:UpdateScrolling()
    end

    function LazyScrollViewPoolingMixin:UpdateContentExtent()
        local contentFrame = self:GetContentFrame()
        if not contentFrame then return end

        local dataCount = self.__data and #self.__data or 0

        local primarySize = self:GetPrimaryElementSize() * dataCount

        local scrollFrame = self:GetScrollFrame()
        if self:IsHorizontalPrimary() then
            contentFrame:SetWidth(primarySize)
            if not self.__isVertical then
                contentFrame:SetHeight(scrollFrame:GetHeight())
            end
        else
            contentFrame:SetHeight(primarySize)
            if not self.__isHorizontal then
                contentFrame:SetWidth(scrollFrame:GetWidth())
            end
        end
    end

    function LazyScrollViewPoolingMixin:UpdateAfterSizingChange()
        self:UpdateContentExtent()
        self:UpdateScrolling()
    end


    -- Positioning
    --------------------------------

    function LazyScrollViewPoolingMixin:ResetScrolling()
        self.__visibleStartingIndex = nil
        self.__lastUpdateStartingIndex = nil
    end

    function LazyScrollViewPoolingMixin:UpdateScrolling()
        if not self.__data then return end

        local scrollFrame = self:GetScrollFrame()
        local elementSize = self:GetPrimaryElementSize()
        local scrollOffset

        local useHorizontal = self:IsHorizontalPrimary()

        if useHorizontal then
            scrollOffset = scrollFrame:GetHorizontalScroll()
        else
            scrollOffset = scrollFrame:GetVerticalScroll()
        end

        self.__visibleStartingIndex = math.floor(scrollOffset / elementSize) + 1

        -- Update index is different
        if self.__lastUpdateStartingIndex ~= self.__visibleStartingIndex then
            self.__lastUpdateStartingIndex = self.__visibleStartingIndex

            -- Update visible elements
            for i = 1, self.__numVisibleElements do
                local element = self:GetElement(i)
                if not element then break end

                element:ClearAllPoints()
                local offset = elementSize * ((i - 1) + (self.__visibleStartingIndex - 1))
                if useHorizontal then
                    element:SetPoint("TOPLEFT", self:GetContentFrame(), "TOPLEFT", offset, 0)
                else
                    element:SetPoint("TOPLEFT", self:GetContentFrame(), "TOPLEFT", 0, -offset)
                end
            end

            -- Update all visible elements, if out of data range; it'll be hidden
            self:UpdateAllVisibleElements()
        end

        -- Update content extent events
        updateContentExtentEvents(self)
    end
end

local LazyScrollViewMixin = {}
do
    -- Init
    --------------------------------

    function LazyScrollViewMixin:Init()
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

    function LazyScrollViewMixin:GetContentFrame()
        return self.__ContentFrame
    end

    function LazyScrollViewMixin:GetScrollFrame()
        return self.__ScrollFrame
    end


    -- Get
    --------------------------------

    function LazyScrollViewMixin:HasContentAbove()
        local verticalScroll = self:GetScrollFrame():GetVerticalScroll()
        return verticalScroll > 1
    end

    function LazyScrollViewMixin:HasContentBelow()
        local scrollFrameHeight = self:GetScrollFrame():GetHeight()
        local contentFrameHeight = self:GetContentFrame():GetHeight()
        local bottomPoint = contentFrameHeight - scrollFrameHeight
        local verticalScroll = self:GetScrollFrame():GetVerticalScroll()

        return verticalScroll < bottomPoint - 1
    end

    function LazyScrollViewMixin:HasContentLeft()
        local horizontalScroll = self:GetScrollFrame():GetHorizontalScroll()
        return horizontalScroll > 1
    end

    function LazyScrollViewMixin:HasContentRight()
        local scrollFrameWidth = self:GetScrollFrame():GetWidth()
        local contentFrameWidth = self:GetContentFrame():GetWidth()
        local rightPoint = contentFrameWidth - scrollFrameWidth
        local horizontalScroll = self:GetScrollFrame():GetHorizontalScroll()
        return horizontalScroll < rightPoint - 1
    end

    function LazyScrollViewMixin:GetContentHeight()
        return self:GetContentFrame():GetHeight()
    end

    function LazyScrollViewMixin:GetContentWidth()
        return self:GetContentFrame():GetWidth()
    end


    -- Set
    --------------------------------

    function LazyScrollViewMixin:SetDirection(vertical, horizontal)
        self.__isVertical = vertical ~= false
        self.__isHorizontal = horizontal == true
    end

    function LazyScrollViewMixin:SetStepSize(size)
        self.__stepSize = size or 150
    end


    -- Fit Content
    --------------------------------

    function LazyScrollViewMixin:CustomFitContent()
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

    function LazyScrollViewMixin:SetSmoothScrolling(enabled, ratio)
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

    function LazyScrollViewMixin:SetVerticalScroll(value, instant)
        setScroll(self, true, value, instant)
    end

    function LazyScrollViewMixin:SetHorizontalScroll(value, instant)
        setScroll(self, false, value, instant)
    end

    function LazyScrollViewMixin:GetVerticalScroll()
        return self.__interpolate and self.__targetVertical or self:GetScrollFrame():GetVerticalScroll()
    end

    function LazyScrollViewMixin:GetHorizontalScroll()
        return self.__interpolate and self.__targetHorizontal or self:GetScrollFrame():GetHorizontalScroll()
    end

    function LazyScrollViewMixin:ScrollToTop()
        self:SetVerticalScroll(0)
    end

    function LazyScrollViewMixin:ScrollToBottom()
        self:SetVerticalScroll(max(0, self:GetContentFrame():GetHeight() - self:GetScrollFrame():GetHeight()))
    end

    function LazyScrollViewMixin:ScrollToLeft()
        self:SetHorizontalScroll(0)
    end

    function LazyScrollViewMixin:ScrollToRight()
        self:SetHorizontalScroll(max(0, self:GetContentFrame():GetWidth() - self:GetScrollFrame():GetWidth()))
    end
end

local LazyScrollViewContentMixin = {}
do
    -- Accessor
    --------------------------------

    function LazyScrollViewContentMixin:GetParent()
        return self.__parentRef
    end


    -- Fit Content
    --------------------------------

    function LazyScrollViewContentMixin:CustomFitContent()
        local shouldFitWidth, shouldFitHeight = self:GetFitContent()
        local parent = self:GetParent()

        if shouldFitHeight and parent.__isVertical then
            self:SetHeight(parent:GetPoolingContentHeight())
        end

        if shouldFitWidth and parent.__isHorizontal then
            self:SetWidth(parent:GetPoolingContentWidth())
        end
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


function UIKit_Primitives_LazyScrollView.New(name, parent)
    name = name or "undefined"


    local lazyScrollView = UIKit_Primitives_Frame.New("Frame", name, parent)
    Mixin(lazyScrollView, LazyScrollViewPoolingMixin)
    Mixin(lazyScrollView, LazyScrollViewMixin)
    lazyScrollView:InitLazyScrollViewPooling()
    lazyScrollView:Init()


    -- Scroll Frame
    --------------------------------

    local scrollFrame = UIKit_Primitives_Frame.New("ScrollFrame", "$parent.ScrollFrame", lazyScrollView)
    scrollFrame:SetAllPoints(lazyScrollView)
    scrollFrame:SetClipsChildren(true)
    scrollFrame:EnableMouseWheel(true)


    -- Content Frame
    --------------------------------

    local contentFrame = UIKit_Primitives_Frame.New("Frame", "$parent.ContentFrame", scrollFrame)
    contentFrame.uk_type = "LazyScrollViewContent"
    contentFrame.__parentRef = lazyScrollView
    Mixin(contentFrame, LazyScrollViewContentMixin)
    scrollFrame:SetScrollChild(contentFrame)


    -- References
    --------------------------------

    lazyScrollView.__ScrollFrame = scrollFrame
    lazyScrollView.__ContentFrame = contentFrame


    -- Events
    --------------------------------

    scrollFrame:SetScript("OnMouseWheel", mouseWheelHandler)

    scrollFrame:HookScript("OnVerticalScroll", function()
        lazyScrollView:TriggerEvent("OnVerticalScroll"); lazyScrollView:UpdateScrolling()
    end)

    scrollFrame:HookScript("OnHorizontalScroll", function()
        lazyScrollView:TriggerEvent("OnHorizontalScroll"); lazyScrollView:UpdateScrolling()
    end)



    return lazyScrollView
end


--[[
local BACKGROUND = UIKit.Define.Texture_NineSlice{ path = Path.Root .. "/wpm_modules/uic-common/resources/InputCaret.png", inset = 128, scale = 1 }

local MyRowPrefab = UIKit.Prefab(function(id, name, children, ...)
    local frame =
        Frame(name, {
            Text(name .. ".Text")
                :id("Text", id)
                :point(UIKit.Enum.Point.Center)
                :size(UIKit.Define.Num{value = 25}, UIKit.Define.Fit{})
                :fontSize(11)
                :textAlignment("LEFT", "MIDDLE")
        })
        :size(UIKit.Define.Num{ value = 25}, UIKit.Define.Percentage{ value = 100 })
        :background(BACKGROUND)
        :backgroundColor(UIKit.Define.Color_RGBA{ r = 255, g = 255, b = 255, a = .5 })

    frame.Text = UIKit.GetElementById("Text", id)
    frame.Background = frame:GetBackground()

    return frame
end)

local function handleOnElementUpdate(element, index, value)
    element.Text:SetText(value)
    element.Background:SetShown(index % 2 == 0)
end

Frame{
    LazyScrollView{

    }
        :id("myLazyScrollView")
        :point(UIKit.Enum.Point.Center)
        :size(UIKit.Define.Fit{}, UIKit.Define.Percentage{value = 100})
        :maxWidth(UIKit.Define.Num{ value = 325 })
        :poolPrefab(MyRowPrefab)
        :poolOnElementUpdate(handleOnElementUpdate)
        :lazyScrollViewElementHeight(25)
        :scrollDirection(UIKit.Enum.Direction.Horizontal)
        :scrollInterpolation(5)
        :scrollStepSize(150)
        :scrollViewContentWidth(UIKit.Define.Fit{})
        :scrollViewContentHeight(UIKit.Define.Percentage{value = 100})
        :background(BACKGROUND)
        :backgroundColor(UIKit.Define.Color_RGBA{ r = 255, g = 255, b = 255, a = .5 })
        :layoutDirection(UIKit.Enum.Direction.Vertical)
        :layoutSpacing(UIKit.Define.Num{value = 7.5})
}
    :id("myFrame")
    :point(UIKit.Enum.Point.Center)
    :size(UIKit.Define.Fit{}, UIKit.Define.Num{ value = 325 })
    :background(BACKGROUND)
    :backgroundColor(UIKit.Define.Color_RGBA{ r = 255, g = 255, b = 255, a = .5 })
    :_Render()

data = { }
for i = 1, 500 do
    table.insert(data, "entry" .. i)
end

myFrame = UIKit.GetElementById("myFrame")
myLazyScrollView = UIKit.GetElementById("myLazyScrollView")
myLazyScrollView:SetData(data)
]]
