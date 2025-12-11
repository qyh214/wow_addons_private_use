local env                               = select(2, ...)
local MixinUtil                         = env.WPM:Import("wpm_modules/mixin-util")
local UIKit_Utils                       = env.WPM:Import("wpm_modules/ui-kit/utils")
local UIKit_Define                      = env.WPM:Import("wpm_modules/ui-kit/define")

local Mixin                             = MixinUtil.Mixin
local wipe                              = wipe

local UIKit_Primitives_Frame            = env.WPM:Import("wpm_modules/ui-kit/primitives/frame")
local UIKit_Primitives_LayoutHorizontal = env.WPM:New("wpm_modules/ui-kit/primitives/layout-horizontal")


-- Layout (Horizontal)
--------------------------------

local LayoutHorizontalMixin = {}
do
    -- Init
    --------------------------------

    function LayoutHorizontalMixin:Init()
        self.__visibleChildren = {}
        self.__cachedWidths = {}
        self.__cachedHeights = {}
    end


    -- Layout
    --------------------------------

    local function resolveSpacing(spacingSetting, referenceSize)
        if not spacingSetting then return 0 end
        local spacingType = spacingSetting == UIKit_Define.Num and "num"
            or spacingSetting == UIKit_Define.Percentage and "percent"
            or type(spacingSetting) == "number" and "raw"
            or nil
        if spacingType == "raw" then return spacingSetting end
        if spacingType == "num" then return spacingSetting.value or 0 end
        if spacingType == "percent" then
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
        wipe(visibleChildren)

        local totalChildrenWidth, maxChildHeight, visibleChildCount = 0, 0, 0

        for childIndex = 1, #allChildren do
            local child = allChildren[childIndex]
            local isLayoutChild = child and child:IsShown() and not child.uk_flag_excludeFromCalculations and child.uk_type ~= "List"
            if isLayoutChild then
                visibleChildCount = visibleChildCount + 1
                visibleChildren[visibleChildCount] = child

                local childWidth, childHeight = child:GetSize()
                childWidth, childHeight = childWidth or 0, childHeight or 0

                -- Cache sizes for reuse in positioning loop
                cachedWidths[visibleChildCount] = childWidth
                cachedHeights[visibleChildCount] = childHeight

                totalChildrenWidth = totalChildrenWidth + childWidth
                if childHeight > maxChildHeight then maxChildHeight = childHeight end
            end
        end

        if visibleChildCount == 0 then return end

        local parent = self:GetParent()
        local containerWidth, containerHeight = self:GetSize()
        containerWidth = containerWidth or (parent and parent:GetWidth()) or UIParent:GetWidth()
        containerHeight = containerHeight or (parent and parent:GetHeight()) or UIParent:GetHeight()

        local spacing = resolveSpacing(self:GetSpacing(), containerWidth)
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

        local horizontalAlignment = self.uk_prop_layoutAlignmentH or "LEADING"
        local verticalAlignment = self.uk_prop_layoutAlignmentV or "LEADING"

        local currentX = horizontalAlignment == "JUSTIFIED" and (containerWidth - contentWidth) * 0.5
            or horizontalAlignment == "TRAILING" and (containerWidth - contentWidth)
            or 0

        for childIndex = 1, visibleChildCount do
            local child = visibleChildren[childIndex]
            local childWidth = cachedWidths[childIndex]
            local childHeight = cachedHeights[childIndex]

            local verticalOffset = verticalAlignment == "JUSTIFIED" and (containerHeight - childHeight) * 0.5
                or verticalAlignment == "TRAILING" and (containerHeight - childHeight)
                or 0

            child:ClearAllPoints()
            child:SetPoint("TOPLEFT", self, "TOPLEFT", currentX, -verticalOffset)

            currentX = currentX + childWidth + spacing
        end
    end


    -- Property
    --------------------------------

    function LayoutHorizontalMixin:GetAlignmentH()
        return self.uk_prop_layoutAlignmentH or "LEADING"
    end

    function LayoutHorizontalMixin:SetAlignmentH(layoutAlignmentH)
        self.uk_prop_layoutAlignmentH = layoutAlignmentH
        self:RenderElements()
    end

    function LayoutHorizontalMixin:GetAlignmentV()
        return self.uk_prop_layoutAlignmentV or "LEADING"
    end

    function LayoutHorizontalMixin:SetAlignmentV(layoutAlignmentV)
        self.uk_prop_layoutAlignmentV = layoutAlignmentV
        self:RenderElements()
    end
end


function UIKit_Primitives_LayoutHorizontal.New(name, parent)
    name = name or "undefined"


    local LayoutHorizontal = UIKit_Primitives_Frame.New("Frame", name, parent)
    Mixin(LayoutHorizontal, LayoutHorizontalMixin)
    LayoutHorizontal:Init()


    return LayoutHorizontal
end
