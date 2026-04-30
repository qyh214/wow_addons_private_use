local env = select(2, ...)
local UIKit_Primitives_Frame = env.modules:Import("packages\\ui-kit\\primitives\\frame")
local UIKit_Primitives_ScrollBase = env.modules:Import("packages\\ui-kit\\primitives\\scroll-container-base")
local UIKit_Primitives_ScrollContainer = env.modules:New("packages\\ui-kit\\primitives\\scroll-container")

local Mixin = Mixin
local ScrollContainerBaseMixin = UIKit_Primitives_ScrollBase.Mixin
local MouseWheelHandler = UIKit_Primitives_ScrollBase.MouseWheelHandler


local ScrollContainerMixin = {}

function ScrollContainerMixin:CustomFitContent()
    local shouldFitWidth, shouldFitHeight = self:GetFitContent()
    self:FitContent(shouldFitWidth, shouldFitHeight, { self.__ContentFrame })
end


local ScrollContainerContentMixin = {}

function ScrollContainerContentMixin:GetParent()
    return self.__parentRef
end

function ScrollContainerContentMixin:CustomFitContent()
    local shouldFitWidth, shouldFitHeight = self:GetFitContent()
    self:FitContent(shouldFitWidth, shouldFitHeight, self.__parentRef:GetFrameChildren())
end


function UIKit_Primitives_ScrollContainer.New(name, parent)
    name = name or "undefined"

    local frame = UIKit_Primitives_Frame.New("Frame", name, parent)
    Mixin(frame, ScrollContainerBaseMixin)
    Mixin(frame, ScrollContainerMixin)
    frame:InitScrollContainerBase()

    local scrollFrame = UIKit_Primitives_Frame.New("ScrollFrame", "$parent.ScrollFrame", frame)
    scrollFrame:SetAllPoints(frame)
    scrollFrame:SetClipsChildren(true)
    scrollFrame:EnableMouseWheel(true)

    local contentFrame = UIKit_Primitives_Frame.New("Frame", "$parent.ContentFrame", scrollFrame)
    contentFrame.uk_type = "ScrollContainerContent"
    contentFrame.__parentRef = frame
    Mixin(contentFrame, ScrollContainerContentMixin)
    scrollFrame:SetScrollChild(contentFrame)

    frame.__ScrollFrame = scrollFrame
    frame.__ContentFrame = contentFrame

    scrollFrame:SetScript("OnMouseWheel", MouseWheelHandler)
    scrollFrame:HookScript("OnVerticalScroll", function() frame:TriggerEvent("OnVerticalScroll") end)
    scrollFrame:HookScript("OnHorizontalScroll", function() frame:TriggerEvent("OnHorizontalScroll") end)

    return frame
end
