local env                             = select(2, ...)
local MixinUtil                       = env.WPM:Import("wpm_modules/mixin-util")
local UIKit_Utils                     = env.WPM:Import("wpm_modules/ui-kit/utils")
local UIKit_Define                    = env.WPM:Import("wpm_modules/ui-kit/define")

local Mixin                           = MixinUtil.Mixin
local wipe                            = wipe

local UIKit_Primitives_Frame          = env.WPM:Import("wpm_modules/ui-kit/primitives/frame")
local UIKit_Primitives_LayoutVertical = env.WPM:New("wpm_modules/ui-kit/primitives/layout-vertical")


-- Layout (Vertical)
--------------------------------

local LayoutVerticalMixin = {}
do
    -- Init
    --------------------------------

    function LayoutVerticalMixin:Init()
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


    function LayoutVerticalMixin:RenderElements()
        local allChildren = self:GetFrameChildren()
        if not allChildren then return end

        local visibleChildren = self.__visibleChildren
        local cachedWidths = self.__cachedWidths
        local cachedHeights = self.__cachedHeights
        wipe(visibleChildren)

        local totalChildrenHeight, maxChildWidth, visibleChildCount, sizedChildCount = 0, 0, 0, 0

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

                totalChildrenHeight = totalChildrenHeight + childHeight
                if childWidth > maxChildWidth then maxChildWidth = childWidth end
                if childHeight > 0 then sizedChildCount = sizedChildCount + 1 end
            end
        end

        if visibleChildCount == 0 then return end

        local parent = self:GetParent()
        local containerWidth, containerHeight = self:GetSize()
        containerWidth = containerWidth or (parent and parent:GetWidth()) or UIParent:GetWidth()
        containerHeight = containerHeight or (parent and parent:GetHeight()) or UIParent:GetHeight()

        local spacing = resolveSpacing(self:GetSpacing(), containerHeight)
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

        local horizontalAlignment = self.uk_prop_layoutAlignmentH or "LEADING"
        local verticalAlignment = self.uk_prop_layoutAlignmentV or "LEADING"

        local currentY = verticalAlignment == "JUSTIFIED" and (containerHeight - contentHeight) * 0.5
            or verticalAlignment == "TRAILING" and (containerHeight - contentHeight)
            or 0

        local hasPlacedSizedChild = false
        for childIndex = 1, visibleChildCount do
            local child = visibleChildren[childIndex]
            local childWidth = cachedWidths[childIndex]
            local childHeight = cachedHeights[childIndex]

            local horizontalOffset = horizontalAlignment == "JUSTIFIED" and (containerWidth - childWidth) * 0.5
                or horizontalAlignment == "TRAILING" and (containerWidth - childWidth)
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


    -- Property
    --------------------------------

    function LayoutVerticalMixin:GetAlignmentH()
        return self.uk_prop_layoutAlignmentH or "LEADING"
    end

    function LayoutVerticalMixin:SetAlignmentH(layoutAlignmentH)
        self.uk_prop_layoutAlignmentH = layoutAlignmentH
        self:RenderElements()
    end

    function LayoutVerticalMixin:GetAlignmentV()
        return self.uk_prop_layoutAlignmentV or "LEADING"
    end

    function LayoutVerticalMixin:SetAlignmentV(layoutAlignmentV)
        self.uk_prop_layoutAlignmentV = layoutAlignmentV
        self:RenderElements()
    end
end


function UIKit_Primitives_LayoutVertical.New(name, parent)
    name = name or "undefined"


    local LayoutVertical = UIKit_Primitives_Frame.New("Frame", name, parent)
    Mixin(LayoutVertical, LayoutVerticalMixin)
    LayoutVertical:Init()


    return LayoutVertical
end
