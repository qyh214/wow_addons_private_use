local env                         = select(2, ...)
local MixinUtil                   = env.WPM:Import("wpm_modules/mixin-util")
local UIKit_Define                = env.WPM:Import("wpm_modules/ui-kit/define")
local UIKit_Utils                 = env.WPM:Import("wpm_modules/ui-kit/utils")

local Mixin                       = MixinUtil.Mixin
local wipe                        = wipe
local math                        = math
local tonumber                    = tonumber
local type                        = type

local UIKit_Primitives_Frame      = env.WPM:Import("wpm_modules/ui-kit/primitives/frame")
local UIKit_Primitives_LayoutGrid = env.WPM:New("wpm_modules/ui-kit/primitives/layout-grid")


-- Layout (Grid)
--------------------------------

local LayoutGridMixin = {}
do
    -- Init
    --------------------------------

    function LayoutGridMixin:Init()
        self.__visibleChildren = {}
        self.__columnWidths    = {}
        self.__rowHeights      = {}
        self.__columnOffsets   = {}
        self.__rowOffsets      = {}
        self.__cachedWidths    = {}
        self.__cachedHeights   = {}
    end


    -- Layout
    --------------------------------

    local function resolveSpacing(spacingSetting, refWidth, refHeight)
        if not spacingSetting then return 0, 0 end
        local spacingType = spacingSetting == UIKit_Define.Num and "num"
            or spacingSetting == UIKit_Define.Percentage and "percent"
            or type(spacingSetting) == "number" and "raw"
            or nil
        if spacingType == "raw" then
            return spacingSetting, spacingSetting
        elseif spacingType == "num" then
            local val = spacingSetting.value or 0
            return val, val
        elseif spacingType == "percent" then
            local pctVal, op, delta = spacingSetting.value or 0, spacingSetting.operator, spacingSetting.delta
            return UIKit_Utils:CalculateRelativePercentage(refWidth, pctVal, op, delta),
                UIKit_Utils:CalculateRelativePercentage(refHeight, pctVal, op, delta)
        end
        return 0, 0
    end

    local function computeGridDimensions(visibleChildCount, requestedColumns, requestedRows)
        local columnCount, rowCount

        if requestedColumns and requestedColumns > 0 then
            columnCount = requestedColumns
            rowCount = math.ceil(visibleChildCount / columnCount)
        elseif requestedRows and requestedRows > 0 then
            rowCount = requestedRows
            columnCount = math.ceil(visibleChildCount / rowCount)
        else
            columnCount = math.max(1, math.floor(math.sqrt(visibleChildCount)))
            rowCount = math.ceil(visibleChildCount / columnCount)
        end

        return math.max(1, columnCount), math.max(1, rowCount)
    end

    function LayoutGridMixin:RenderElements()
        local allChildren = self:GetFrameChildren()
        if not allChildren then return end

        local visibleChildren = self.__visibleChildren
        wipe(visibleChildren)

        local visibleChildCount = 0
        for childIndex = 1, #allChildren do
            local child = allChildren[childIndex]
            local isLayoutChild = child and child:IsShown() and not child.uk_flag_excludeFromCalculations and child.uk_type ~= "List"
            if isLayoutChild then
                visibleChildCount = visibleChildCount + 1
                visibleChildren[visibleChildCount] = child
            end
        end

        if visibleChildCount == 0 then return end

        local parent = self:GetParent()
        local containerWidth, containerHeight = self:GetSize()
        containerWidth = containerWidth or (parent and parent:GetWidth()) or UIParent:GetWidth()
        containerHeight = containerHeight or (parent and parent:GetHeight()) or UIParent:GetHeight()

        local columnCount, rowCount = computeGridDimensions(
            visibleChildCount,
            tonumber(self.uk_LayoutGridColumns),
            tonumber(self.uk_LayoutGridRows)
        )

        local columnWidths, rowHeights = self.__columnWidths, self.__rowHeights
        for columnIndex = 1, columnCount do columnWidths[columnIndex] = 0 end
        for rowIndex = 1, rowCount do rowHeights[rowIndex] = 0 end

        local cachedWidths = self.__cachedWidths
        local cachedHeights = self.__cachedHeights

        for childIndex = 1, visibleChildCount do
            local child = visibleChildren[childIndex]
            local childWidth, childHeight = child:GetSize()
            childWidth, childHeight = childWidth or 0, childHeight or 0

            -- Cache sizes for reuse in positioning loop
            cachedWidths[childIndex] = childWidth
            cachedHeights[childIndex] = childHeight

            local columnIndex = ((childIndex - 1) % columnCount) + 1
            local rowIndex = math.floor((childIndex - 1) / columnCount) + 1

            if childWidth > columnWidths[columnIndex] then columnWidths[columnIndex] = childWidth end
            if childHeight > rowHeights[rowIndex] then rowHeights[rowIndex] = childHeight end
        end

        local horizontalSpacing, verticalSpacing = resolveSpacing(self:GetSpacing(), containerWidth, containerHeight)

        local contentWidth, contentHeight = 0, 0
        for columnIndex = 1, columnCount do contentWidth = contentWidth + columnWidths[columnIndex] end
        for rowIndex = 1, rowCount do contentHeight = contentHeight + rowHeights[rowIndex] end
        contentWidth = contentWidth + (columnCount - 1) * horizontalSpacing
        contentHeight = contentHeight + (rowCount - 1) * verticalSpacing

        local shouldFitWidth, shouldFitHeight = self:GetFitContent()
        if shouldFitWidth then
            containerWidth = self:ResolveFitSize("width", contentWidth, self.uk_prop_width)
            self:SetWidth(containerWidth)
        end
        if shouldFitHeight then
            containerHeight = self:ResolveFitSize("height", contentHeight, self.uk_prop_height)
            self:SetHeight(containerHeight)
        end

        local horizontalAlignment = self.uk_prop_layoutAlignmentH or "LEADING"
        local verticalAlignment = self.uk_prop_layoutAlignmentV or "LEADING"

        local gridStartX = horizontalAlignment == "JUSTIFIED" and (containerWidth - contentWidth) * 0.5
            or horizontalAlignment == "TRAILING" and (containerWidth - contentWidth)
            or 0
        local gridStartY = verticalAlignment == "JUSTIFIED" and (containerHeight - contentHeight) * 0.5
            or verticalAlignment == "TRAILING" and (containerHeight - contentHeight)
            or 0

        local columnOffsets, rowOffsets = self.__columnOffsets, self.__rowOffsets
        local accumulatedX = gridStartX
        for columnIndex = 1, columnCount do
            columnOffsets[columnIndex] = accumulatedX
            accumulatedX = accumulatedX + columnWidths[columnIndex] + horizontalSpacing
        end
        local accumulatedY = gridStartY
        for rowIndex = 1, rowCount do
            rowOffsets[rowIndex] = accumulatedY
            accumulatedY = accumulatedY + rowHeights[rowIndex] + verticalSpacing
        end

        for childIndex = 1, visibleChildCount do
            local child = visibleChildren[childIndex]
            local childWidth = cachedWidths[childIndex]
            local childHeight = cachedHeights[childIndex]

            local columnIndex = ((childIndex - 1) % columnCount) + 1
            local rowIndex = math.floor((childIndex - 1) / columnCount) + 1

            local cellWidth, cellHeight = columnWidths[columnIndex], rowHeights[rowIndex]

            local cellOffsetX = horizontalAlignment == "JUSTIFIED" and (cellWidth - childWidth) * 0.5
                or horizontalAlignment == "TRAILING" and (cellWidth - childWidth)
                or 0
            local cellOffsetY = verticalAlignment == "JUSTIFIED" and (cellHeight - childHeight) * 0.5
                or verticalAlignment == "TRAILING" and (cellHeight - childHeight)
                or 0

            if cellOffsetX < 0 then cellOffsetX = 0 end
            if cellOffsetY < 0 then cellOffsetY = 0 end

            child:ClearAllPoints()
            child:SetPoint("TOPLEFT", self, "TOPLEFT", columnOffsets[columnIndex] + cellOffsetX, -(rowOffsets[rowIndex] + cellOffsetY))
        end
    end


    -- Property
    --------------------------------

    function LayoutGridMixin:GetAlignmentH()
        return self.uk_prop_layoutAlignmentH or "LEADING"
    end

    function LayoutGridMixin:SetAlignmentH(layoutAlignmentH)
        self.uk_prop_layoutAlignmentH = layoutAlignmentH
        self:RenderElements()
    end

    function LayoutGridMixin:GetAlignmentV()
        return self.uk_prop_layoutAlignmentV or "LEADING"
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
end


function UIKit_Primitives_LayoutGrid.New(name, parent)
    name = name or "undefined"


    local LayoutGrid = UIKit_Primitives_Frame.New("Frame", name, parent)
    Mixin(LayoutGrid, LayoutGridMixin)
    LayoutGrid:Init()


    return LayoutGrid
end
