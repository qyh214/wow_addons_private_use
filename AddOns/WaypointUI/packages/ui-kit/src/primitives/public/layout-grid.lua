local env = select(2, ...)
local UIKit_Enum = env.modules:Import("packages\\ui-kit\\enum")
local UIKit_Define = env.modules:Import("packages\\ui-kit\\define")
local UIKit_Utils = env.modules:Import("packages\\ui-kit\\utils")
local UIKit_Primitives_Frame = env.modules:Import("packages\\ui-kit\\primitives\\frame")
local UIKit_Primitives_LayoutGrid = env.modules:New("packages\\ui-kit\\primitives\\layout-grid")

local Mixin = Mixin
local tonumber = tonumber
local type = type
local UIKit_Enum_Direction_Leading = UIKit_Enum.Direction.Leading
local UIKit_Enum_Direction_Justified = UIKit_Enum.Direction.Justified
local UIKit_Enum_Direction_Trailing = UIKit_Enum.Direction.Trailing
local UIKit_Define_Percentage = UIKit_Define.Percentage


local LayoutGridMixin = {}

function LayoutGridMixin:OnLoad()
    self.__visibleChildren = {}
    self.__columnWidths = {}
    self.__rowHeights = {}
    self.__columnOffsets = {}
    self.__rowOffsets = {}
    self.__cachedWidths = {}
    self.__cachedHeights = {}
    self.__visibleCount = 0
end

local function ResolveSpacing(spacingSetting, referenceSize)
    if not spacingSetting then return 0 end
    if type(spacingSetting) == "number" then
        return spacingSetting
    end
    if spacingSetting == UIKit_Define_Percentage then
        return UIKit_Utils:CalculateRelativePercentage(referenceSize, spacingSetting.value or 0, spacingSetting.operator, spacingSetting.delta)
    end
    return 0
end

function LayoutGridMixin:RenderElements()
    local allChildren = self:GetFrameChildren()
    if not allChildren then return end

    local visibleChildren = self.__visibleChildren
    local prevCount = self.__visibleCount or 0

    local visibleChildCount = 0
    for childIndex = 1, #allChildren do
        local child = allChildren[childIndex]
        local isLayoutChild = child and child:IsShown() and not child.uk_flag_excludeFromCalculations and child.uk_type ~= "List"
        if isLayoutChild then
            visibleChildCount = visibleChildCount + 1
            visibleChildren[visibleChildCount] = child
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

    local spacingH = self:GetSpacingH() or self:GetSpacing()
    local spacingV = self:GetSpacingV() or self:GetSpacing()
    local horizontalSpacing = ResolveSpacing(spacingH, containerWidth)
    local verticalSpacing = ResolveSpacing(spacingV, containerHeight)
    local horizontalAlignment = self.uk_prop_layoutAlignmentH or UIKit_Enum_Direction_Leading
    local verticalAlignment = self.uk_prop_layoutAlignmentV or UIKit_Enum_Direction_Leading

    local cachedWidths = self.__cachedWidths
    local cachedHeights = self.__cachedHeights
    local rowHeights = self.__rowHeights
    local columnWidths = self.__columnWidths

    local currentRowIndex = 1
    local currentRowWidth = 0
    local currentRowMaxHeight = 0

    for childIndex = 1, visibleChildCount do
        local child = visibleChildren[childIndex]
        local childWidth, childHeight = child:GetSize()
        childWidth, childHeight = childWidth or 0, childHeight or 0

        cachedWidths[childIndex] = childWidth
        cachedHeights[childIndex] = childHeight
        columnWidths[childIndex] = currentRowIndex

        local requiredWidth = currentRowWidth + childWidth
        if currentRowWidth > 0 then requiredWidth = requiredWidth + horizontalSpacing end

        if currentRowWidth > 0 and requiredWidth > containerWidth then
            rowHeights[currentRowIndex] = currentRowMaxHeight
            currentRowIndex = currentRowIndex + 1
            currentRowWidth = childWidth
            currentRowMaxHeight = childHeight
            columnWidths[childIndex] = currentRowIndex
        else
            currentRowWidth = requiredWidth
            if childHeight > currentRowMaxHeight then currentRowMaxHeight = childHeight end
        end
    end
    rowHeights[currentRowIndex] = currentRowMaxHeight

    local rowCount = currentRowIndex
    local contentHeight = 0
    for rowIndex = 1, rowCount do
        contentHeight = contentHeight + rowHeights[rowIndex]
    end
    contentHeight = contentHeight + (rowCount - 1) * verticalSpacing

    local shouldFitWidth, shouldFitHeight = self:GetFitContent()
    if shouldFitHeight then
        containerHeight = self:ResolveFitSize("height", contentHeight, self.uk_prop_height)
        self:SetHeight(containerHeight)
    end

    local gridStartY = verticalAlignment == UIKit_Enum_Direction_Justified and (containerHeight - contentHeight) * 0.5
        or verticalAlignment == UIKit_Enum_Direction_Trailing and (containerHeight - contentHeight)
        or 0

    local rowOffsets = self.__rowOffsets
    local accumulatedY = gridStartY
    for rowIndex = 1, rowCount do
        rowOffsets[rowIndex] = accumulatedY
        accumulatedY = accumulatedY + rowHeights[rowIndex] + verticalSpacing
    end

    local columnOffsets = self.__columnOffsets
    for rowIndex = 1, rowCount do columnOffsets[rowIndex] = 0 end

    currentRowIndex = 1
    local currentRowContentWidth = 0

    for childIndex = 1, visibleChildCount do
        local childWidth = cachedWidths[childIndex]
        local rowIndex = columnWidths[childIndex]

        if rowIndex ~= currentRowIndex then
            columnOffsets[currentRowIndex] = currentRowContentWidth
            currentRowIndex = rowIndex
            currentRowContentWidth = childWidth
        else
            if currentRowContentWidth > 0 then currentRowContentWidth = currentRowContentWidth + horizontalSpacing end
            currentRowContentWidth = currentRowContentWidth + childWidth
        end
    end
    columnOffsets[currentRowIndex] = currentRowContentWidth

    currentRowIndex = 1
    local currentRowXOffset = 0

    for childIndex = 1, visibleChildCount do
        local childWidth = cachedWidths[childIndex]
        local childHeight = cachedHeights[childIndex]
        local rowIndex = columnWidths[childIndex]

        if rowIndex ~= currentRowIndex then
            currentRowIndex = rowIndex
            currentRowXOffset = 0
        end

        local rowHeight = rowHeights[rowIndex]
        local rowOffsetY = rowOffsets[rowIndex]
        local rowContentWidth = columnOffsets[rowIndex]

        local gridStartX = horizontalAlignment == UIKit_Enum_Direction_Justified and (containerWidth - rowContentWidth) * 0.5
            or horizontalAlignment == UIKit_Enum_Direction_Trailing and (containerWidth - rowContentWidth)
            or 0

        local cellOffsetY = verticalAlignment == UIKit_Enum_Direction_Justified and (rowHeight - childHeight) * 0.5
            or verticalAlignment == UIKit_Enum_Direction_Trailing and (rowHeight - childHeight)
            or 0

        if cellOffsetY < 0 then cellOffsetY = 0 end

        local child = visibleChildren[childIndex]
        child:ClearAllPoints()
        child:SetPoint("TOPLEFT", self, "TOPLEFT", gridStartX + currentRowXOffset, -(rowOffsetY + cellOffsetY))

        currentRowXOffset = currentRowXOffset + childWidth + horizontalSpacing
    end
end

function LayoutGridMixin:GetAlignmentH()
    return self.uk_prop_layoutAlignmentH or UIKit_Enum_Direction_Leading
end

function LayoutGridMixin:SetAlignmentH(layoutAlignmentH)
    self.uk_prop_layoutAlignmentH = layoutAlignmentH
    self:RenderElements()
end

function LayoutGridMixin:GetAlignmentV()
    return self.uk_prop_layoutAlignmentV or UIKit_Enum_Direction_Leading
end

function LayoutGridMixin:SetAlignmentV(layoutAlignmentV)
    self.uk_prop_layoutAlignmentV = layoutAlignmentV
    self:RenderElements()
end

function LayoutGridMixin:GetColumns()
    return self.uk_LayoutGridColumns
end

function LayoutGridMixin:SetColumns(columns)
    self.uk_LayoutGridColumns = tonumber(columns)
    self:RenderElements()
end

function LayoutGridMixin:GetRows()
    return self.uk_LayoutGridRows
end

function LayoutGridMixin:SetRows(rows)
    self.uk_LayoutGridRows = tonumber(rows)
    self:RenderElements()
end

function UIKit_Primitives_LayoutGrid.New(name, parent)
    name = name or "undefined"

    local frame = UIKit_Primitives_Frame.New("Frame", name, parent)
    Mixin(frame, LayoutGridMixin)
    frame:OnLoad()

    return frame
end
