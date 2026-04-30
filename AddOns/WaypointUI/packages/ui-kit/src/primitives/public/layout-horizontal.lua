local env = select(2, ...)
local UIKit_Utils = env.modules:Import("packages\\ui-kit\\utils")
local UIKit_Enum = env.modules:Import("packages\\ui-kit\\enum")
local UIKit_Define = env.modules:Import("packages\\ui-kit\\define")
local UIKit_Primitives_Frame = env.modules:Import("packages\\ui-kit\\primitives\\frame")
local UIKit_Primitives_LayoutHorizontal = env.modules:New("packages\\ui-kit\\primitives\\layout-horizontal")

local Mixin = Mixin
local type = type
local UIKit_Enum_Direction_Leading = UIKit_Enum.Direction.Leading
local UIKit_Enum_Direction_Justified = UIKit_Enum.Direction.Justified
local UIKit_Enum_Direction_Trailing = UIKit_Enum.Direction.Trailing
local UIKit_Define_Percentage = UIKit_Define.Percentage


local LayoutHorizontalMixin = {}

function LayoutHorizontalMixin:OnLoad()
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

function LayoutHorizontalMixin:RenderElements()
    local allChildren = self:GetFrameChildren()
    if not allChildren then return end

    local visibleChildren = self.__visibleChildren
    local cachedWidths = self.__cachedWidths
    local cachedHeights = self.__cachedHeights
    local prevCount = self.__visibleCount or 0

    local totalChildrenWidth, maxChildHeight, visibleChildCount = 0, 0, 0

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

            totalChildrenWidth = totalChildrenWidth + childWidth
            if childHeight > maxChildHeight then maxChildHeight = childHeight end
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

    local spacing = ResolveSpacing(self:GetSpacing(), containerWidth)
    local contentWidth = totalChildrenWidth + (visibleChildCount - 1) * spacing

    local shouldFitWidth, shouldFitHeight = self:GetFitContent()
    if shouldFitWidth then
        containerWidth = self:ResolveFitSize("width", contentWidth, self.uk_prop_width)
        self:SetWidth(containerWidth)
    end
    if shouldFitHeight then
        containerHeight = self:ResolveFitSize("height", maxChildHeight, self.uk_prop_height)
        self:SetHeight(containerHeight)
    end

    local horizontalAlignment = self.uk_prop_layoutAlignmentH or UIKit_Enum_Direction_Leading
    local verticalAlignment = self.uk_prop_layoutAlignmentV or UIKit_Enum_Direction_Leading

    local currentX = horizontalAlignment == UIKit_Enum_Direction_Justified and (containerWidth - contentWidth) * 0.5
        or horizontalAlignment == UIKit_Enum_Direction_Trailing and (containerWidth - contentWidth)
        or 0

    for childIndex = 1, visibleChildCount do
        local child = visibleChildren[childIndex]
        local childWidth = cachedWidths[childIndex]
        local childHeight = cachedHeights[childIndex]

        local verticalOffset = verticalAlignment == UIKit_Enum_Direction_Justified and (containerHeight - childHeight) * 0.5
            or verticalAlignment == UIKit_Enum_Direction_Trailing and (containerHeight - childHeight)
            or 0

        child:ClearAllPoints()
        child:SetPoint("TOPLEFT", self, "TOPLEFT", currentX, -verticalOffset)

        currentX = currentX + childWidth + spacing
    end
end

function LayoutHorizontalMixin:GetAlignmentH()
    return self.uk_prop_layoutAlignmentH or UIKit_Enum_Direction_Leading
end

function LayoutHorizontalMixin:SetAlignmentH(layoutAlignmentH)
    self.uk_prop_layoutAlignmentH = layoutAlignmentH
    self:RenderElements()
end

function LayoutHorizontalMixin:GetAlignmentV()
    return self.uk_prop_layoutAlignmentV or UIKit_Enum_Direction_Leading
end

function LayoutHorizontalMixin:SetAlignmentV(layoutAlignmentV)
    self.uk_prop_layoutAlignmentV = layoutAlignmentV
    self:RenderElements()
end

function UIKit_Primitives_LayoutHorizontal.New(name, parent)
    name = name or "undefined"

    local frame = UIKit_Primitives_Frame.New("Frame", name, parent)
    Mixin(frame, LayoutHorizontalMixin)
    frame:OnLoad()

    return frame
end
