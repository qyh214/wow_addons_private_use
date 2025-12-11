local env                    = select(2, ...)
local MixinUtil              = env.WPM:Import("wpm_modules/mixin-util")
local Utils_LazyTable        = env.WPM:Import("wpm_modules/utils/lazy-table")
local UIKit_Define           = env.WPM:Import("wpm_modules/ui-kit/define")
local UIKit_FrameCache       = env.WPM:Import("wpm_modules/ui-kit/frame-cache")
local UIKit_Utils            = env.WPM:Import("wpm_modules/ui-kit/utils")
local UIKit_Enum             = env.WPM:Import("wpm_modules/ui-kit/enum")
local UIKit_UI_Scanner       = env.WPM:Await("wpm_modules/ui-kit/ui/scanner")

local Mixin                  = MixinUtil.Mixin
local CreateFrame            = CreateFrame
local math_huge              = math.huge
local type                   = type
local tinsert                = table.insert
local tremove                = table.remove

local UIKit_Primitives_Frame = env.WPM:New("wpm_modules/ui-kit/primitives/frame")


-- Shared
--------------------------------

UIKit_Primitives_Frame.FrameProps = {}

local dummy = CreateFrame("Frame"); dummy:Hide()
local Method_SetSize                   = getmetatable(dummy).__index.SetSize
local Method_SetWidth                  = getmetatable(dummy).__index.SetWidth
local Method_SetHeight                 = getmetatable(dummy).__index.SetHeight
local Method_SetPropagateMouseClicks   = getmetatable(dummy).__index.SetPropagateMouseClicks
local Method_SetPropagateMouseMotion   = getmetatable(dummy).__index.SetPropagateMouseMotion
local Method_SetPropagateKeyboardInput = getmetatable(dummy).__index.SetPropagateKeyboardInput


-- Frame
--------------------------------

local cachedMetas = {}
local sharedHandlers = {}

local FrameMixin = {}
do
    -- Helper
    --------------------------------

    local function getParentSize(frame, axis)
        local parent = frame:GetParent()
        if not parent or not parent.GetWidth then
            parent = UIParent
        end

        return (axis == "width" and parent:GetWidth() or parent:GetHeight()) or 0
    end

    local function resolveBoundValue(frame, boundConfig, axis)
        if not boundConfig then return nil end

        if boundConfig == UIKit_Define.Num then
            local value = boundConfig.value or 0
            local delta = boundConfig.delta or 0
            return value + delta
        end

        if boundConfig == UIKit_Define.Percentage then
            local parentSize = getParentSize(frame, axis)
            if parentSize == 0 then return 0 end
            return UIKit_Utils:CalculateRelativePercentage(parentSize, boundConfig.value or 0, boundConfig.operator, boundConfig.delta)
        end

        return boundConfig
    end


    -- Hierachy
    --------------------------------

    function FrameMixin:SetFrameParent(parent)
        self.uk_parent = parent
    end

    function FrameMixin:GetFrameParent()
        return self.uk_parent
    end


    function FrameMixin:SetFrameChildren(children)
        self.uk_children = children
    end

    function FrameMixin:GetFrameChildren()
        return UIKit_FrameCache.GetFramesInLazyTable(self, "uk_children")
    end

    function FrameMixin:AddFrameChild(frame)
        Utils_LazyTable.Insert(self, "uk_children", frame.uk_id)
    end

    function FrameMixin:RemoveFrameChild(frame)
        local children = self:GetFrameChildren()
        if not children then return end

        for i = 1, #children do
            if children[i] == frame then
                Utils_LazyTable.Remove(children, "uk_children", i)
                return
            end
        end
    end


    -- Accessor
    --------------------------------

    function FrameMixin:GetBackground()
        return self.Background
    end


    -- Attribute
    --------------------------------

    function FrameMixin:GetID()
        return self.uk_id
    end


    -- Get
    --------------------------------

    function FrameMixin:GetSpacing()
        return self.uk_prop_layoutSpacing
    end

    function FrameMixin:GetMaxWidth()
        return resolveBoundValue(self, self.uk_prop_maxWidth, "width")
    end

    function FrameMixin:GetMaxHeight()
        return resolveBoundValue(self, self.uk_prop_maxHeight, "height")
    end

    function FrameMixin:GetMinWidth()
        return resolveBoundValue(self, self.uk_prop_minWidth, "width")
    end

    function FrameMixin:GetMinHeight()
        return resolveBoundValue(self, self.uk_prop_minHeight, "height")
    end


    -- Fit Content
    --------------------------------

    local function clampWithBoundsAndDelta(size, minBound, maxBound, delta)
        if minBound and size < minBound then size = minBound end
        if maxBound and size > maxBound then size = maxBound end

        size = size + delta

        if minBound and size < minBound then size = minBound end
        if maxBound and size > maxBound + delta then size = maxBound + delta end

        return size > 0 and size or 0
    end

    local function getChildBoundsRelativeToParent(parentLeft, parentTop, child)
        local childLeft, childBottom, childWidth, childHeight = child:GetRect()

        if childLeft then
            local relativeLeft = childLeft - parentLeft
            local relativeRight = relativeLeft + childWidth
            local relativeTop = parentTop - (childBottom + childHeight)
            local relativeBottom = relativeTop + childHeight

            if relativeLeft > relativeRight then relativeLeft, relativeRight = relativeRight, relativeLeft end
            if relativeTop > relativeBottom then relativeTop, relativeBottom = relativeBottom, relativeTop end

            return relativeLeft, relativeTop, relativeRight, relativeBottom
        end

        local width, height = child:GetWidth() or 0, child:GetHeight() or 0
        local rawLeft, rawRight = child:GetLeft(), child:GetRight()
        local rawTop, rawBottom = child:GetTop(), child:GetBottom()

        local relativeLeft, relativeRight
        if rawLeft and rawRight then
            relativeLeft = rawLeft - parentLeft
            relativeRight = rawRight - parentLeft
            if relativeLeft > relativeRight then relativeLeft, relativeRight = relativeRight, relativeLeft end
        elseif rawLeft then
            relativeLeft = rawLeft - parentLeft
            relativeRight = relativeLeft + width
        elseif rawRight then
            relativeRight = rawRight - parentLeft
            relativeLeft = relativeRight - width
        else
            relativeLeft, relativeRight = 0, width
        end

        local relativeTop, relativeBottom
        if rawTop and rawBottom then
            relativeTop = parentTop - rawTop
            relativeBottom = parentTop - rawBottom
            if relativeTop > relativeBottom then relativeTop, relativeBottom = relativeBottom, relativeTop end
        elseif rawTop then
            relativeTop = parentTop - rawTop
            relativeBottom = relativeTop + height
        elseif rawBottom then
            relativeBottom = parentTop - rawBottom
            relativeTop = relativeBottom - height
        else
            relativeTop, relativeBottom = 0, height
        end

        return relativeLeft, relativeTop, relativeRight, relativeBottom
    end

    function FrameMixin:ResolveFitSize(axis, measuredSize, sizeProp)
        local minBound, maxBound
        if axis == "width" then
            minBound, maxBound = self:GetMinWidth(), self:GetMaxWidth()
        else
            minBound, maxBound = self:GetMinHeight(), self:GetMaxHeight()
        end
        local delta = (sizeProp == UIKit_Define.Fit and sizeProp.delta) or 0
        return clampWithBoundsAndDelta(measuredSize or 0, minBound, maxBound, delta)
    end

    function FrameMixin:GetFitContent()
        return self.uk_prop_width == UIKit_Define.Fit, self.uk_prop_height == UIKit_Define.Fit
    end

    function FrameMixin:FitContent(shouldFitWidth, shouldFitHeight, childFrames)
        local defaultFitWidth, defaultFitHeight = self:GetFitContent()
        shouldFitWidth = shouldFitWidth == nil and defaultFitWidth or shouldFitWidth
        shouldFitHeight = shouldFitHeight == nil and defaultFitHeight or shouldFitHeight
        if not shouldFitWidth and not shouldFitHeight then return end

        childFrames = childFrames or self:GetFrameChildren()
        if not childFrames then return end

        local boundsMinLeft, boundsMinTop = math_huge, math_huge
        local boundsMaxRight, boundsMaxBottom = -math_huge, -math_huge
        local foundVisibleChild = false
        local parentLeft, parentTop = self:GetLeft(), self:GetTop()

        for i = 1, #childFrames do
            local child = childFrames[i]
            if child and child:IsShown() and not child.uk_flag_excludeFromCalculations then
                local left, top, right, bottom = getChildBoundsRelativeToParent(parentLeft, parentTop, child)
                if left < boundsMinLeft then boundsMinLeft = left end
                if top < boundsMinTop then boundsMinTop = top end
                if right > boundsMaxRight then boundsMaxRight = right end
                if bottom > boundsMaxBottom then boundsMaxBottom = bottom end
                foundVisibleChild = true
            end
        end

        if shouldFitWidth then
            local contentWidth = foundVisibleChild and (boundsMaxRight - boundsMinLeft) or 0
            if contentWidth < 0 then contentWidth = 0 end
            local resolvedWidth = self:ResolveFitSize("width", contentWidth, self.uk_prop_width)
            if self:GetWidth() ~= resolvedWidth then self:SetWidth(resolvedWidth) end
        end

        if shouldFitHeight then
            local contentHeight = foundVisibleChild and (boundsMaxBottom - boundsMinTop) or 0
            if contentHeight < 0 then contentHeight = 0 end
            local resolvedHeight = self:ResolveFitSize("height", contentHeight, self.uk_prop_height)
            if self:GetHeight() ~= resolvedHeight then self:SetHeight(resolvedHeight) end
        end
    end


    -- Alias
    --------------------------------

    function FrameMixin:AddAlias(aliasName, frame)
        if not aliasName or not frame then return end

        local registry = self.uk_aliasRegistry
        if not registry then
            registry = {}
            self.uk_aliasRegistry = registry
        end
        registry[aliasName] = frame
    end

    function FrameMixin:GetAlias(aliasName)
        if not aliasName then return end

        local registry = self.uk_aliasRegistry
        return registry and registry[aliasName]
    end


    -- Events
    --------------------------------

    function FrameMixin:HookEvent(event, func)
        if not event or type(func) ~= "function" then return end

        local eventRegistry = self.uk_eventRegistry
        if not eventRegistry then
            eventRegistry = {}
            self.uk_eventRegistry = eventRegistry
        end

        local registry = eventRegistry[event]
        if not registry then
            registry = {}
            eventRegistry[event] = registry
        end

        for i = 1, #registry do
            if registry[i] == func then return end
        end

        tinsert(registry, func)
    end

    function FrameMixin:UnhookEvent(event, func)
        if not event or not func then return end

        local eventRegistry = self.uk_eventRegistry
        if not eventRegistry then return end

        local registry = eventRegistry[event]
        if not registry then return end

        for i = #registry, 1, -1 do
            if registry[i] == func then
                tremove(registry, i)
            end
        end
    end

    function FrameMixin:TriggerEvent(event, ...)
        if not event then return end

        local eventRegistry = self.uk_eventRegistry
        if not eventRegistry then return end

        local registry = eventRegistry[event]
        if not registry then return end

        for i = 1, #registry do
            registry[i](self, ...)
        end
    end


    -- Override
    --------------------------------

    function FrameMixin:SetSize(...)
        Method_SetSize(self, ...)

        -- If in UserUpdate mode, explicitly trigger layout updates
        if self.uk_flag_updateMode == UIKit_Enum.UpdateMode.UserUpdate then
            UIKit_UI_Scanner.ScanFrame(self)
        end
    end

    function FrameMixin:SetWidth(...)
        Method_SetWidth(self, ...)

        -- If in UserUpdate mode, explicitly trigger layout updates
        if self.uk_flag_updateMode == UIKit_Enum.UpdateMode.UserUpdate then
            UIKit_UI_Scanner.ScanFrame(self)
        end
    end

    function FrameMixin:SetHeight(...)
        Method_SetHeight(self, ...)

        -- If in UserUpdate mode, explicitly trigger layout update
        if self.uk_flag_updateMode == UIKit_Enum.UpdateMode.UserUpdate then
            UIKit_UI_Scanner.ScanFrame(self)
        end
    end

    local function propagateEnableMouseClick(self)
        self:SetPropagateMouseClicks(true)
    end

    local function propagateDisableMouseClick(self)
        self:SetPropagateMouseClicks(false)
    end

    local function propagateEnableMouseMotion(self)
        self:SetPropagateMouseMotion(true)
    end

    local function propagateDisableMouseMotion(self)
        self:SetPropagateMouseMotion(false)
    end

    local function propagateEnableKeyboardInput(self)
        self:SetPropagateKeyboardInput(true)
    end

    local function propagateDisableKeyboardInput(self)
        self:SetPropagateKeyboardInput(false)
    end

    function FrameMixin:AwaitSetPropagateMouseClicks(propagate)
        if propagate then
            UIKit_Utils:AwaitProtectedEvent(propagateEnableMouseClick, self)
        else
            UIKit_Utils:AwaitProtectedEvent(propagateDisableMouseClick, self)
        end
    end

    function FrameMixin:AwaitSetPropagateMouseMotion(propagate)
        if propagate then
            UIKit_Utils:AwaitProtectedEvent(propagateEnableMouseMotion, self)
        else
            UIKit_Utils:AwaitProtectedEvent(propagateDisableMouseMotion, self)
        end
    end

    function FrameMixin:AwaitSetPropagateKeyboardInput(propagate)
        if propagate then
            UIKit_Utils:AwaitProtectedEvent(propagateEnableKeyboardInput, self)
        else
            UIKit_Utils:AwaitProtectedEvent(propagateDisableKeyboardInput, self)
        end
    end

    function FrameMixin:SetPropagateMouseClicks(propagate)
        if InCombatLockdown() then return end
        Method_SetPropagateMouseClicks(self, propagate)
    end

    function FrameMixin:SetPropagateMouseMotion(propagate)
        if InCombatLockdown() then return end
        Method_SetPropagateMouseMotion(self, propagate)
    end

    function FrameMixin:SetPropagateKeyboardInput(propagate)
        if InCombatLockdown() then return end
        Method_SetPropagateKeyboardInput(self, propagate)
    end
end


function UIKit_Primitives_Frame.New(frameType, name, parent, template)
    name = name or "undefined"


    local frame = CreateFrame(frameType, name, parent, template)

    local meta = cachedMetas[frameType]
    if not meta then
        local originalMeta = getmetatable(frame)
        local originalIndex = originalMeta and originalMeta.__index

        meta = {
            __index = function(t, k)
                local propFunc = UIKit_Primitives_Frame.FrameProps[k]
                if propFunc then
                    local handler = sharedHandlers[k]
                    if not handler then
                        handler = function(frame, ...)
                            propFunc(frame, ...)
                            return frame
                        end
                        sharedHandlers[k] = handler
                    end
                    return handler
                end

                if not originalIndex then return nil end
                return type(originalIndex) == "function" and originalIndex(t, k) or originalIndex[k]
            end
        }
        cachedMetas[frameType] = meta
    end

    setmetatable(frame, meta)
    Mixin(frame, FrameMixin)

    if name then _G[name] = nil end
    return frame
end
