local env = select(2, ...)
local UIKit_Enum = env.modules:Import("packages\\ui-kit\\enum")
local UIKit_Primitives_Frame = env.modules:Import("packages\\ui-kit\\primitives\\frame")
local UIKit_Primitives_ScrollContainerEdge = env.modules:New("packages\\ui-kit\\primitives\\scroll-container-edge")

local Mixin = Mixin
local max = math.max
local min = math.min


local LEADING = UIKit_Enum.ScrollEdgeDirection.Leading
local TRAILING = UIKit_Enum.ScrollEdgeDirection.Trailing

local ScrollContainerEdgeMixin = {}

function ScrollContainerEdgeMixin:SetScrollEdgeMin(value)
    self.__scrollEdgeMin = value or 0
end

function ScrollContainerEdgeMixin:SetScrollEdgeMax(value)
    self.__scrollEdgeMax = value or 0
end

function ScrollContainerEdgeMixin:SetScrollEdgeDirection(direction)
    self.__scrollEdgeDirection = direction or LEADING
end

function ScrollContainerEdgeMixin:SetLinkedScrollContainer(scrollContainer)
    local prevScrollContainer = self.__linkedScrollContainer
    if prevScrollContainer and self.__scrollHandler then
        prevScrollContainer:UnhookEvent("OnVerticalScroll", self.__scrollHandler)
        prevScrollContainer:UnhookEvent("OnHorizontalScroll", self.__scrollHandler)
    end

    self.__linkedScrollContainer = scrollContainer
    if not scrollContainer then return end

    if not self.__scrollHandler then
        self.__scrollHandler = function() self:UpdateAlpha() end
    end

    scrollContainer:HookEvent("OnVerticalScroll", self.__scrollHandler)
    scrollContainer:HookEvent("OnHorizontalScroll", self.__scrollHandler)

    self:UpdateAlpha()
end

function ScrollContainerEdgeMixin:UpdateAlpha()
    local scrollContainer = self.__linkedScrollContainer
    if not scrollContainer then return end

    local scrollFrame = scrollContainer.__ScrollFrame
    local contentFrame = scrollContainer.__ContentFrame
    if not scrollFrame or not contentFrame then return end

    local edgeMin = self.__scrollEdgeMin or 0
    local edgeMax = self.__scrollEdgeMax or 0
    local direction = self.__scrollEdgeDirection or LEADING
    local isVertical = scrollContainer.__isVertical
    local isHorizontal = scrollContainer.__isHorizontal

    local scroll, contentSize, frameSize
    if isVertical then
        scroll = scrollFrame:GetVerticalScroll()
        contentSize = contentFrame:GetHeight()
        frameSize = scrollFrame:GetHeight()
    elseif isHorizontal then
        scroll = scrollFrame:GetHorizontalScroll()
        contentSize = contentFrame:GetWidth()
        frameSize = scrollFrame:GetWidth()
    else
        self:SetAlpha(0)
        return
    end

    local maxScroll = max(0, contentSize - frameSize)
    local alpha = 0

    if direction == TRAILING then
        local distanceFromEnd = maxScroll - scroll
        if distanceFromEnd <= edgeMin then
            alpha = 0
        elseif distanceFromEnd >= edgeMax then
            alpha = 1
        else
            local range = edgeMax - edgeMin
            alpha = range > 0 and (distanceFromEnd - edgeMin) / range or 0
        end
    else
        if scroll <= edgeMin then
            alpha = 0
        elseif scroll >= edgeMax then
            alpha = 1
        else
            local range = edgeMax - edgeMin
            alpha = range > 0 and (scroll - edgeMin) / range or 0
        end
    end

    self:SetAlpha(min(1, max(0, alpha)))
end

function UIKit_Primitives_ScrollContainerEdge.New(name, parent)
    name = name or "undefined"

    local frame = UIKit_Primitives_Frame.New("Frame", name, parent)
    Mixin(frame, ScrollContainerEdgeMixin)

    frame.__scrollEdgeMin = 0
    frame.__scrollEdgeMax = 50
    frame.__scrollEdgeDirection = LEADING

    return frame
end
