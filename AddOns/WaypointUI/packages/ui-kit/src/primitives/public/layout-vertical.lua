local env = select(2, ...)
local UIKit_Utils = env.modules:Import("packages\\ui-kit\\utils")
local UIKit_Enum = env.modules:Import("packages\\ui-kit\\enum")
local UIKit_Define = env.modules:Import("packages\\ui-kit\\define")
local UIKit_Primitives_Frame = env.modules:Import("packages\\ui-kit\\primitives\\frame")
local UIKit_Primitives_LayoutVertical = env.modules:New("packages\\ui-kit\\primitives\\layout-vertical")

local Mixin = Mixin
local type = type
local UIKit_Enum_Direction_Leading = UIKit_Enum.Direction.Leading
local UIKit_Enum_Direction_Justified = UIKit_Enum.Direction.Justified
local UIKit_Enum_Direction_Trailing = UIKit_Enum.Direction.Trailing
local UIKit_Define_Percentage = UIKit_Define.Percentage


local LayoutVerticalMixin = {}

function LayoutVerticalMixin:OnLoad()
    self.__visibleChildren = {}
    self.__cachedWidths = {}
    self.__cachedHeights = {}
    self.__visibleCount = 0
end

local function ResolveSpacing(spacingSetting, referenceSize)
    if not spacingSetting then return 0 end
    if type(spacingSetting) == "number" then return spacingSetting end
    if spacingSetting == UIKit_Define_Percentage then
        return UIKit_Utils:CalculateRelativePercentage(referenceSize, spacingSetting.value or 0, spacingSetting.operator, spacingSetting.delta)
    end
    return 0
end

function LayoutVerticalMixin:RenderElements()
    local allChildren = self:GetFrameChildren()
    if not allChildren then return end

    local visibleChildren = self.__visibleChildren
    local cachedWidths = self.__cachedWidths
    local cachedHeights = self.__cachedHeights
    local prevCount = self.__visibleCount or 0

    local totalChildrenHeight, maxChildWidth, visibleChildCount, sizedChildCount = 0, 0, 0, 0

    for childIndex = 1, #allChildren do
        local child = allChildren[childIndex]
        local isLayoutChild = child and child:IsShown() and not child.uk_flag_excludeFromCalculations and child.uk_type ~= "List"
        if isLayoutChild then
            visibleChildCount = visibleChildCount + 1
            visibleChildren[visibleChildCount] = child

            local childWidth, childHeight = child:GetSize()
            childWidth, childHeight = childWidth or 0, childHeight or 0

            cachedWidths[visibleChildCount] = childWidth
            cachedHeights[visibleChildCount] = childHeight

            totalChildrenHeight = totalChildrenHeight + childHeight
            if childWidth > maxChildWidth then maxChildWidth = childWidth end
            if childHeight > 0 then sizedChildCount = sizedChildCount + 1 end
        end
    end

    for i = visibleChildCount + 1, prevCount do
        visibleChildren[i] = nil
    end
    self.__visibleCount = visibleChildCount

    if visibleChildCount == 0 then return end

    local parent = self:GetParent()
    local containerWidth, containerHeight = self:GetSize()
    containerWidth = containerWidth or (parent and parent:GetWidth()) or UIParent:GetWidth()
    containerHeight = containerHeight or (parent and parent:GetHeight()) or UIParent:GetHeight()

    local spacing = ResolveSpacing(self:GetSpacing(), containerHeight)
    local spacingGapCount = sizedChildCount > 1 and (sizedChildCount - 1) or 0
    local contentHeight = totalChildrenHeight + spacingGapCount * spacing

    local shouldFitWidth, shouldFitHeight = self:GetFitContent()
    if shouldFitWidth then
        containerWidth = self:ResolveFitSize("width", maxChildWidth, self.uk_prop_width)
        self:SetWidth(containerWidth)
    end
    if shouldFitHeight then
        containerHeight = self:ResolveFitSize("height", contentHeight, self.uk_prop_height)
        self:SetHeight(containerHeight)
    end

    local horizontalAlignment = self.uk_prop_layoutAlignmentH or UIKit_Enum_Direction_Leading
    local verticalAlignment = self.uk_prop_layoutAlignmentV or UIKit_Enum_Direction_Leading

    local currentY = verticalAlignment == UIKit_Enum_Direction_Justified and (containerHeight - contentHeight) * 0.5
        or verticalAlignment == UIKit_Enum_Direction_Trailing and (containerHeight - contentHeight)
        or 0

    local hasPlacedSizedChild = false
    for childIndex = 1, visibleChildCount do
        local child = visibleChildren[childIndex]
        local childWidth = cachedWidths[childIndex]
        local childHeight = cachedHeights[childIndex]

        local horizontalOffset = horizontalAlignment == UIKit_Enum_Direction_Justified and (containerWidth - childWidth) * 0.5
            or horizontalAlignment == UIKit_Enum_Direction_Trailing and (containerWidth - childWidth)
            or 0

        if childHeight > 0 and hasPlacedSizedChild then
            currentY = currentY + spacing
        end

        child:ClearAllPoints()
        child:SetPoint("TOPLEFT", self, "TOPLEFT", horizontalOffset, -currentY)

        currentY = currentY + childHeight
        if childHeight > 0 then hasPlacedSizedChild = true end
    end
end

function LayoutVerticalMixin:GetAlignmentH()
    return self.uk_prop_layoutAlignmentH or UIKit_Enum_Direction_Leading
end

function LayoutVerticalMixin:SetAlignmentH(layoutAlignmentH)
    self.uk_prop_layoutAlignmentH = layoutAlignmentH
    self:RenderElements()
end

function LayoutVerticalMixin:GetAlignmentV()
    return self.uk_prop_layoutAlignmentV or UIKit_Enum_Direction_Leading
end

function LayoutVerticalMixin:SetAlignmentV(layoutAlignmentV)
    self.uk_prop_layoutAlignmentV = layoutAlignmentV
    self:RenderElements()
end

function UIKit_Primitives_LayoutVertical.New(name, parent)
    name = name or "undefined"

    local frame = UIKit_Primitives_Frame.New("Frame", name, parent)
    Mixin(frame, LayoutVerticalMixin)
    frame:OnLoad()

    return frame
end
