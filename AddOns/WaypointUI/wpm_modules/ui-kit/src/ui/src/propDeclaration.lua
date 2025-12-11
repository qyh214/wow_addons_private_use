local env                       = select(2, ...)

local type                      = type
local unpack                    = unpack

local UIKit_TagManager          = env.WPM:Import("wpm_modules/ui-kit/tag-manager")
local UIKit_Renderer            = env.WPM:Import("wpm_modules/ui-kit/renderer")
local UIKit_Utils               = env.WPM:Import("wpm_modules/ui-kit/utils")
local UIKit_Define              = env.WPM:Import("wpm_modules/ui-kit/define")
local UIKit_Enum                = env.WPM:Import("wpm_modules/ui-kit/enum")
local UIKit_Primitives_Frame    = env.WPM:Import("wpm_modules/ui-kit/primitives/frame")
local UIKit_UI_Scanner          = env.WPM:Import("wpm_modules/ui-kit/ui/scanner")
local UIKit_Renderer_Background = env.WPM:Import("wpm_modules/ui-kit/renderer/background")
local React                     = env.WPM:Import("wpm_modules/react")

local FrameProps                = UIKit_Primitives_Frame.FrameProps


-- Shared
--------------------------------

local reactKeyCache = setmetatable({}, {
    __index = function(self, propName)
        local keys = {
            prop  = "uk_prop_REACT_" .. propName,
            args  = "uk_prop_REACT_ARGS_" .. propName,
            index = "uk_prop_REACT_" .. propName .. "_INDEX"
        }
        self[propName] = keys
        return keys
    end
})


-- Helpers
--------------------------------

local function resolveFrameReference(frameOrId, groupID)
    if type(frameOrId) ~= "string" then
        return frameOrId
    end

    if UIKit_TagManager.IsGroupCaptureString(frameOrId) then
        local resolvedId, resolvedGroupId = UIKit_TagManager.ReadGroupCaptureString(frameOrId)
        return UIKit_TagManager.GetElementById(resolvedId, resolvedGroupId)
    end

    return UIKit_TagManager.GetElementById(frameOrId, groupID)
end

local function handleReact(frame, value, propName, argumentIndex)
    local keys = reactKeyCache[propName]
    local keyProp = keys.prop
    local keyArgs = keys.args
    local keyIndex = keys.index

    if React.IsVariable(value) then
        if not frame[keyProp] then
            frame[keyProp] = value

            if argumentIndex then
                frame[keyArgs] = frame[keyArgs] or {}
            end

            local changeIndex = value:OnChange(function(self)
                if argumentIndex then
                    local args = frame[keyArgs] or {}
                    for i = 1, argumentIndex do
                        args[i] = nil
                    end
                    args[argumentIndex] = self
                    frame[propName](unpack(args))
                else
                    frame[propName](frame, value)
                end
            end)

            frame[keyIndex] = changeIndex
        end

        return value:Get()
    end

    local existingReactVar = frame[keyProp]
    if existingReactVar and frame[keyIndex] then
        existingReactVar:OffChange(frame[keyIndex])
    end

    return value
end

local function isColorDefine(color)
    return color == UIKit_Define.Color_RGBA or color == UIKit_Define.Color_HEX
end

local function isTextOrInput(frameType)
    return frameType == "Text" or frameType == "Input"
end

local function isScrollableView(frameType)
    return frameType == "ScrollView" or frameType == "LazyScrollView"
end


-- General
--------------------------------

do
    FrameProps["id"] = function(frame, value, groupID)
        UIKit_TagManager.Id.Add(frame, value, groupID)
    end

    FrameProps["under"] = function(frame, aliasName)
        assert(aliasName, "Invalid variable `aliasName`")
        frame.uk_prop_under = aliasName
    end

    FrameProps["parent"] = function(frame, targetFrame, targetGroupId)
        assert(targetFrame, "Invalid variable `target`")
        targetFrame = resolveFrameReference(targetFrame, targetGroupId)

        local currentParent = frame:GetFrameParent()
        if currentParent == targetFrame then return end

        local actualParent = frame:GetParent()
        if actualParent and actualParent.uk_type then
            actualParent:RemoveFrameChild(frame)
        end

        if targetFrame.uk_type then
            targetFrame:AddFrameChild(frame)
        end

        frame:SetFrameParent(targetFrame)
        frame:SetParent(targetFrame)

        if frame.uk_prop_frameStrata then frame:frameStrata(frame.uk_prop_frameStrata) end
        if frame.uk_prop_frameLevel then frame:frameLevel(frame.uk_prop_frameLevel) end
    end

    FrameProps["frameStrata"] = function(frame, strata, level)
        assert(type(strata) == "string", "Invalid variable `frameStrata`: Must be of type `string`")
        if level then assert(type(level) == "number", "Invalid variable `frameLevel`: Must be of type `number`") end

        frame.uk_prop_frameStrata = strata
        frame:SetFrameStrata(strata)
        if level then frame:frameLevel(level) end
    end

    FrameProps["frameLevel"] = function(frame, level)
        assert(type(level) == "number", "Invalid variable `frameLevel`: Must be of type `number`")
        frame.uk_prop_frameLevel = level
        frame:SetFrameLevel(level)
    end

    -- React
    FrameProps["topLevel"] = function(frame, topLevel)
        topLevel = handleReact(frame, topLevel, "topLevel")
        assert(type(topLevel) == "boolean", "Invalid variable `topLevel`: Must be of type `boolean`")
        frame:SetToplevel(topLevel)
    end

    -- React
    FrameProps["alpha"] = function(frame, opacity)
        opacity = handleReact(frame, opacity, "alpha")
        assert(type(opacity) == "number", "Invalid variable `opacity`: Must be of type `number`")
        frame:SetAlpha(opacity)
    end

    -- React
    FrameProps["scale"] = function(frame, scale)
        scale = handleReact(frame, scale, "scale")
        assert(type(scale) == "number", "Invalid variable `scale`: Must be of type `number`")
        frame:SetScale(scale)
    end

    -- React
    FrameProps["movable"] = function(frame, movable)
        movable = handleReact(frame, movable, "movable")
        assert(type(movable) == "boolean", "Invalid variable `movable`: Must be of type `boolean`")
        frame:SetMovable(movable)
    end

    -- React
    FrameProps["resizable"] = function(frame, resizable)
        resizable = handleReact(frame, resizable, "resizable")
        assert(type(resizable) == "boolean", "Invalid variable `resizable`: Must be of type `boolean`")
        frame:SetResizable(resizable)
    end

    FrameProps["resizeBounds"] = function(frame, minWidth, minHeight, maxWidth, maxHeight)
        assert(not minWidth or type(minWidth) == "number", "Invalid variable `minWidth`: Must be of type `number`")
        assert(not minHeight or type(minHeight) == "number", "Invalid variable `minHeight`: Must be of type `number`")
        assert(not maxWidth or type(maxWidth) == "number", "Invalid variable `maxWidth`: Must be of type `number`")
        assert(not maxHeight or type(maxHeight) == "number", "Invalid variable `maxHeight`: Must be of type `number`")
        frame:SetResizeBounds(minWidth, minHeight, maxWidth, maxHeight)
    end

    -- React
    FrameProps["enableMouse"] = function(frame, enabled)
        enabled = handleReact(frame, enabled, "enableMouse")
        assert(type(enabled) == "boolean", "Invalid variable `enableMouse`: Must be of type `boolean`")
        frame:EnableMouse(enabled)
    end

    -- React
    FrameProps["enableMouseMotion"] = function(frame, enabled)
        enabled = handleReact(frame, enabled, "enableMouseMotion")
        assert(type(enabled) == "boolean", "Invalid variable `enableMouseMotion`: Must be of type `boolean`")
        frame:EnableMouseMotion(enabled)
    end

    FrameProps["enableMouseWheel"] = function(frame, enabled)
        enabled = handleReact(frame, enabled, "enableMouseWheel")
        assert(type(enabled) == "boolean", "Invalid variable `enableMouseWheel`: Must be of type `boolean`")
        frame:EnableMouseWheel(enabled)
    end

    FrameProps["registerForDrag"] = function(frame, leftButton, rightButton)
        assert(not leftButton or type(leftButton) == "boolean", "Invalid variable `leftButton`: Must be of type `boolean`")
        assert(not rightButton or type(rightButton) == "boolean", "Invalid variable `rightButton`: Must be of type `boolean`")
        if leftButton or rightButton then frame:enableMouse(true) end
        if leftButton then frame:RegisterForDrag("LeftButton") end
        if rightButton then frame:RegisterForDrag("RightButton") end
    end

    FrameProps["enableKeyboard"] = function(frame, enabled)
        enabled = handleReact(frame, enabled, "enableKeyboard")
        assert(type(enabled) == "boolean", "Invalid variable `enableKeyboard`: Must be of type `boolean`")
        frame:SetPropagateKeyboardInput(enabled)
    end

    -- React
    FrameProps["clampedToScreen"] = function(frame, clamped)
        clamped = handleReact(frame, clamped, "clampedToScreen")
        assert(type(clamped) == "boolean", "Invalid variable `clampedToScreen`: Must be of type `boolean`")
        frame:SetClampedToScreen(clamped)
    end

    FrameProps["clipsChildren"] = function(frame, clips)
        clips = handleReact(frame, clips, "clipsChildren")
        assert(type(clips) == "boolean", "Invalid variable `clipsChildren`: Must be of type `boolean`")
        frame:SetClipsChildren(clips)
    end

    -- React
    FrameProps["ignoreParentScale"] = function(frame, ignore)
        ignore = handleReact(frame, ignore, "ignoreParentScale")
        assert(type(ignore) == "boolean", "Invalid variable `ignoreParentScale`: Must be of type `boolean`")
        frame:SetIgnoreParentScale(ignore)
    end

    -- React
    FrameProps["ignoreParentAlpha"] = function(frame, ignore)
        ignore = handleReact(frame, ignore, "ignoreParentAlpha")
        assert(type(ignore) == "boolean", "Invalid variable `ignoreParentAlpha`: Must be of type `boolean`")
        frame:SetIgnoreParentAlpha(ignore)
    end

    do
        local function ensureHandleTarget(frame)
            if frame.uk_prop_handleTarget then return end
            local targetId = frame.uk_prop_moveHandle_targetId or frame.uk_prop_resizeHandle_targetId
            local targetGroupId = frame.uk_prop_moveHandle_targetGroupId or frame.uk_prop_resizeHandle_targetGroupId
            frame.uk_prop_handleTarget = UIKit_TagManager.GetElementById(targetId, targetGroupId)
        end

        local function onMoveMouseDown(frame)
            ensureHandleTarget(frame)
            assert(frame.uk_prop_handleTarget, "Invalid variable `handleTarget`")
            frame.uk_prop_handleTarget:StartMoving()
        end

        local function onMoveMouseUp(frame)
            ensureHandleTarget(frame)
            assert(frame.uk_prop_handleTarget, "Invalid variable `handleTarget`")
            frame.uk_prop_handleTarget:StopMovingOrSizing()
        end

        local function onResizeMouseDown(frame)
            ensureHandleTarget(frame)
            assert(frame.uk_prop_handleTarget, "Invalid variable `handleTarget`")
            frame.uk_prop_handleTarget:StartSizing()
        end

        local function onResizeMouseUp(frame)
            ensureHandleTarget(frame)
            assert(frame.uk_prop_handleTarget, "Invalid variable `handleTarget`")
            frame.uk_prop_handleTarget:StopMovingOrSizing()
        end

        FrameProps["moveHandle"] = function(frame, targetId, targetGroupId)
            frame.uk_prop_moveHandle_targetId = targetId
            frame.uk_prop_moveHandle_targetGroupId = targetGroupId
            frame:HookScript("OnMouseDown", onMoveMouseDown)
            frame:HookScript("OnMouseUp", onMoveMouseUp)
        end

        FrameProps["resizeHandle"] = function(frame, targetId, targetGroupId)
            frame.uk_prop_resizeHandle_targetId = targetId
            frame.uk_prop_resizeHandle_targetGroupId = targetGroupId
            frame:HookScript("OnMouseDown", onResizeMouseDown)
            frame:HookScript("OnMouseUp", onResizeMouseUp)
        end
    end

    FrameProps["point"] = function(frame, point, relativePoint)
        frame.uk_prop_point = point
        frame.uk_prop_point_relative = relativePoint
    end

    FrameProps["anchor"] = function(frame, anchorFrame)
        anchorFrame = handleReact(frame, anchorFrame, "anchor")
        anchorFrame = resolveFrameReference(anchorFrame)
        frame.uk_prop_anchor = anchorFrame
    end

    -- React
    FrameProps["x"] = function(frame, xPos)
        xPos = handleReact(frame, xPos, "x")
        assert(xPos == UIKit_Define.Num or xPos == UIKit_Define.Percentage or xPos == UIKit_Define.Fit, "Invalid variable `x`: Must be of type `UIKit.Define.Num`, `UIKit.Define.Percentage` or `UIKit.Define.Fit`")
        frame.uk_prop_x = xPos
    end

    -- React
    FrameProps["y"] = function(frame, yPos)
        yPos = handleReact(frame, yPos, "y")
        assert(yPos == UIKit_Define.Num or yPos == UIKit_Define.Percentage or yPos == UIKit_Define.Fit, "Invalid variable `y`: Must be of type `UIKit.Define.Num`, `UIKit.Define.Percentage` or `UIKit.Define.Fit`")
        frame.uk_prop_y = yPos
    end

    FrameProps["position"] = function(frame, xPos, yPos)
        frame:x(xPos)
        frame:y(yPos)
    end

    -- React
    FrameProps["width"] = function(frame, widthValue)
        widthValue = handleReact(frame, widthValue, "width")
        assert(widthValue == UIKit_Define.Num or widthValue == UIKit_Define.Percentage or widthValue == UIKit_Define.Fit or widthValue == UIKit_Define.Fill, "Invalid variable `width`: Must be of type `UIKit.Define.Num`, `UIKit.Define.Percentage`, `UIKit.Define.Fit` or `UIKit.Define.Fill`")
        frame.uk_prop_width = widthValue
        if widthValue == UIKit_Define.Num then frame:SetWidth(widthValue.value) end
    end

    -- React
    FrameProps["height"] = function(frame, heightValue)
        heightValue = handleReact(frame, heightValue, "height")
        assert(heightValue == UIKit_Define.Num or heightValue == UIKit_Define.Percentage or heightValue == UIKit_Define.Fit or heightValue == UIKit_Define.Fill, "Invalid variable `height`: Must be of type `UIKit.Define.Num`, `UIKit.Define.Percentage`, `UIKit.Define.Fit` or `UIKit.Define.Fill`")
        frame.uk_prop_height = heightValue
        if heightValue == UIKit_Define.Num then frame:SetHeight(heightValue.value) end
    end

    FrameProps["minWidth"] = function(frame, minWidthValue)
        minWidthValue = handleReact(frame, minWidthValue, "minWidth")
        if minWidthValue == nil then
            frame.uk_prop_minWidth = nil
            return
        end
        assert(minWidthValue == UIKit_Define.Num or minWidthValue == UIKit_Define.Percentage, "Invalid variable `minWidth`: Must be of type `UIKit.Define.Num` or `UIKit.Define.Percentage`")
        frame.uk_prop_minWidth = minWidthValue
    end

    -- React
    FrameProps["minHeight"] = function(frame, minHeightValue)
        minHeightValue = handleReact(frame, minHeightValue, "minHeight")
        if minHeightValue == nil then
            frame.uk_prop_minHeight = nil
            return
        end
        assert(minHeightValue == UIKit_Define.Num or minHeightValue == UIKit_Define.Percentage, "Invalid variable `minHeight`: Must be of type `UIKit.Define.Num` or `UIKit.Define.Percentage`")
        frame.uk_prop_minHeight = minHeightValue
    end

    FrameProps["maxWidth"] = function(frame, maxWidthValue)
        maxWidthValue = handleReact(frame, maxWidthValue, "maxWidth")
        if maxWidthValue == nil then
            frame.uk_prop_maxWidth = nil
            return
        end
        assert(maxWidthValue == UIKit_Define.Num or maxWidthValue == UIKit_Define.Percentage, "Invalid variable `maxWidth`: Must be of type `UIKit.Define.Num` or `UIKit.Define.Percentage`")
        frame.uk_prop_maxWidth = maxWidthValue
    end

    -- React
    FrameProps["maxHeight"] = function(frame, maxHeightValue)
        maxHeightValue = handleReact(frame, maxHeightValue, "maxHeight")
        if maxHeightValue == nil then
            frame.uk_prop_maxHeight = nil
            return
        end
        assert(maxHeightValue == UIKit_Define.Num or maxHeightValue == UIKit_Define.Percentage, "Invalid variable `maxHeight`: Must be of type `UIKit.Define.Num` or `UIKit.Define.Percentage`")
        frame.uk_prop_maxHeight = maxHeightValue
    end

    FrameProps["minSize"] = function(frame, widthValue, heightValue)
        if widthValue ~= nil then frame:minWidth(widthValue) end
        if heightValue ~= nil then frame:minHeight(heightValue) end
    end

    -- React
    FrameProps["maxSize"] = function(frame, widthValue, heightValue)
        if widthValue ~= nil then frame:maxWidth(widthValue) end
        if heightValue ~= nil then frame:maxHeight(heightValue) end
    end

    FrameProps["size"] = function(frame, widthValue, heightValue)
        if widthValue == UIKit_Define.Fill then
            frame.uk_prop_fill = widthValue
            return
        end
        frame:width(widthValue)
        frame:height(heightValue)
    end

    local function isValidTexture(texture)
        return texture == UIKit_Define.Texture or texture == UIKit_Define.Texture_NineSlice or texture == UIKit_Define.Texture_Atlas
    end

    FrameProps["background"] = function(frame, backgroundTexture)
        backgroundTexture = handleReact(frame, backgroundTexture, "background")
        assert(isValidTexture(backgroundTexture), "Invalid variable `background`: Must be a `Texture`, `Texture_NineSlice` or `Texture_Atlas`")
        local existingBackground = frame:GetBackground()
        assert(not existingBackground or existingBackground.__isMaskTexture == false, "Error! Failed to set `background`: a mask texture background object already exists")
        frame.uk_prop_background = backgroundTexture
        UIKit_Renderer_Background.SetBackground(frame, false)
    end

    FrameProps["maskBackground"] = function(frame, backgroundTexture)
        backgroundTexture = handleReact(frame, backgroundTexture, "maskBackground")
        assert(isValidTexture(backgroundTexture), "Invalid variable `background`: Must be a `Texture`, `Texture_NineSlice` or `Texture_Atlas`")
        local existingBackground = frame:GetBackground()
        assert(not existingBackground or existingBackground.__isMaskTexture, "Error! Failed to set `maskBackground`: a non-mask texture background object already exists")
        frame.uk_prop_background = backgroundTexture
        UIKit_Renderer_Background.SetBackground(frame, true)
    end

    FrameProps["backdropColor"] = function(frame, bgColor, borderColor)
        assert(isColorDefine(bgColor), "Invalid variable `background`: Must be a `Color_RGBA` or `Color_HEX`")
        assert(isColorDefine(borderColor), "Invalid variable `border`: Must be a `Color_RGBA` or `Color_HEX`")
        frame.uk_prop_backdropColor_background = bgColor
        frame.uk_prop_backdropColor_border = borderColor
        UIKit_Renderer_Background.SetBackdropColor(frame)
    end

    FrameProps["backgroundColor"] = function(frame, color)
        color = handleReact(frame, color, "backgroundColor")
        assert(isColorDefine(color), "Invalid variable `backgroundColor`: Must be a `Color_RGBA` or `Color_HEX`")
        frame.uk_prop_backgroundColor = color
        UIKit_Renderer_Background.SetBackgroundColor(frame)
    end

    FrameProps["backgroundRotation"] = function(frame, radians)
        radians = handleReact(frame, radians, "backgroundRotation")
        assert(type(radians) == "number", "Invalid variable `backgroundRotation`: Must be a number")
        frame.uk_prop_backgroundRotation = radians
        UIKit_Renderer_Background.SetRotation(frame)
    end

    FrameProps["backgroundBlendMode"] = function(frame, blendMode)
        blendMode = handleReact(frame, blendMode, "backgroundBlendMode")
        assert(type(blendMode) == "string", "Invalid variable `backgroundBlendMode`: Must be a string")
        frame.uk_prop_blendMode = blendMode
        UIKit_Renderer_Background.SetBlendMode(frame)
    end

    FrameProps["backgroundDesaturated"] = function(frame, desaturated)
        desaturated = handleReact(frame, desaturated, "backgroundDesaturated")
        assert(type(desaturated) == "boolean", "Invalid variable `backgroundDesaturated`: Must be a boolean")
        frame.uk_prop_desaturated = desaturated
        UIKit_Renderer_Background.SetDesaturated(frame)
    end

    FrameProps["mask"] = function(frame, maskFrame)
        maskFrame = handleReact(frame, maskFrame, "mask")
        maskFrame = resolveFrameReference(maskFrame)
        local maskBg = maskFrame.GetBackground and maskFrame:GetBackground()
        assert(maskFrame == UIKit_Define.Texture or (maskBg and maskBg.__isMaskTexture == true), "Invalid variable `mask`: Must be a `Texture` or a frame with a `maskBackground` object")
        UIKit_Renderer_Background.SetMaskTexture(frame, maskFrame)
    end

    -- React
    FrameProps["_updateMode"] = function(frame, mode)
        frame.uk_flag_updateMode = mode
        local isAllMode = mode == UIKit_Enum.UpdateMode.All

        if isAllMode then
            if frame.uk_ready and frame.uk_type ~= "Input" then
                frame:SetScript("OnSizeChanged", UIKit_UI_Scanner.ScanFrameFromEvent)
            end
        else
            frame:SetScript("OnSizeChanged", nil)
        end

        if not isAllMode and mode ~= UIKit_Enum.UpdateMode.ChildrenVisibilityChanged then
            frame:SetScript("OnShow", nil)
            frame:SetScript("OnHide", nil)
        end
    end

    FrameProps["_renderBreakpoint"] = function(frame)
        frame.uk_flag_renderBreakpoint = true
    end

    FrameProps["_excludeFromCalculations"] = function(frame)
        frame.uk_flag_excludeFromCalculations = true
    end

    FrameProps["_Render"] = function(frame)
        if not frame.uk_prop_rendered then
            frame.uk_prop_rendered = true
            UIKit_UI_Scanner.SetupFrame(frame)
            UIKit_UI_Scanner.SetupFrameRecursive(frame)
        end
        UIKit_Renderer.Scanner.ScanFrame(frame)
    end
end


-- Layout Group
--------------------------------

do
    -- React
    FrameProps["layoutSpacing"] = function(frame, spacingValue)
        spacingValue = handleReact(frame, spacingValue, "layoutSpacing")
        assert(spacingValue == UIKit_Define.Num or spacingValue == UIKit_Define.Percentage, "Invalid variable `spacing`: Must be of type `UIKit.Define.Num` or `UIKit.Define.Percentage`")
        frame.uk_prop_layoutSpacing = spacingValue
    end

    -- React
    FrameProps["layoutAlignmentH"] = function(frame, alignment)
        alignment = handleReact(frame, alignment, "layoutAlignmentH")
        assert(alignment == UIKit_Enum.Direction.Justified or alignment == UIKit_Enum.Direction.Leading or alignment == UIKit_Enum.Direction.Trailing, "Invalid variable `alignment`: Must be of type `UIKit.Enum.Direction.Justified`, `UIKit.Enum.Direction.Leading` or `UIKit.Enum.Direction.Trailing`")
        frame.uk_prop_layoutAlignmentH = alignment
    end

    -- React
    FrameProps["layoutAlignmentV"] = function(frame, alignment)
        alignment = handleReact(frame, alignment, "layoutAlignmentV")
        assert(alignment == UIKit_Enum.Direction.Justified or alignment == UIKit_Enum.Direction.Leading or alignment == UIKit_Enum.Direction.Trailing, "Invalid variable `alignment`: Must be of type `UIKit.Enum.Direction.Justified`, `UIKit.Enum.Direction.Leading` or `UIKit.Enum.Direction.Trailing`")
        frame.uk_prop_layoutAlignmentV = alignment
    end

    -- React
    FrameProps["layoutDirection"] = function(frame, directionValue)
        directionValue = handleReact(frame, directionValue, "layoutDirection")
        assert(directionValue == UIKit_Enum.Direction.Horizontal or directionValue == UIKit_Enum.Direction.Vertical, "Invalid variable `direction`: Must be of type `UIKit.Enum.Direction.Horizontal` or `UIKit.Enum.Direction.Vertical`")
        frame.uk_prop_layoutDirection = directionValue
    end

    -- React
    FrameProps["columns"] = function(frame, columnCount)
        columnCount = handleReact(frame, columnCount, "columns")
        assert(type(columnCount) == "number" and columnCount > 0, "Invalid variable `columns`: Must be a positive number")
        frame.uk_LayoutGridColumns = columnCount
    end

    -- React
    FrameProps["rows"] = function(frame, rowCount)
        rowCount = handleReact(frame, rowCount, "rows")
        assert(type(rowCount) == "number" and rowCount > 0, "Invalid variable `rows`: Must be a positive number")
        frame.uk_LayoutGridRows = rowCount
    end
end


-- Scrolling
--------------------------------

do
    FrameProps["scrollDirection"] = function(frame, scrollDir)
        local frameType = frame.uk_type
        assert(frameType == "ScrollBar" or isScrollableView(frameType), "Invalid variable `scrollDirection`: Must be called on `ScrollBar` or `ScrollView` or `LazyScrollView`")

        local isVertical = scrollDir == "VERTICAL" or scrollDir == "BOTH"
        local isHorizontal = scrollDir == "HORIZONTAL" or scrollDir == "BOTH"

        if frameType == "ScrollBar" then
            frame:SetVertical(isVertical)
        else
            frame:SetDirection(isVertical, isHorizontal)
        end
    end

    FrameProps["scrollBarTarget"] = function(frame, targetFrame, targetGroupId)
        targetFrame = resolveFrameReference(targetFrame, targetGroupId)
        assert(frame.uk_type == "ScrollBar" and targetFrame and isScrollableView(targetFrame.uk_type), "Invalid variable `scrollBarTarget`: Must be called on `ScrollBar` with a `ScrollView` or `LazyScrollView` target")
        frame.uk_prop_scrollBarTarget = targetFrame
        frame:SetTarget(targetFrame)
    end

    -- React
    FrameProps["scrollViewContentWidth"] = function(frame, contentWidth)
        contentWidth = handleReact(frame, contentWidth, "scrollViewContentWidth")
        assert(isScrollableView(frame.uk_type), "Invalid variable `scrollViewContentWidth`: Must be called on `ScrollView` or `LazyScrollView`")
        assert(contentWidth == UIKit_Define.Num or contentWidth == UIKit_Define.Percentage or contentWidth == UIKit_Define.Fit, "Invalid variable `scrollViewContentWidth`: Must be of type `UIKit.Define.Num`, `UIKit.Define.Percentage` or `UIKit.Define.Fit`")
        local contentFrame = frame:GetContentFrame()
        contentFrame.uk_prop_width = contentWidth
        if contentWidth == UIKit_Define.Num then contentFrame:SetWidth(contentWidth.value) end
    end

    -- React
    FrameProps["scrollViewContentHeight"] = function(frame, contentHeight)
        contentHeight = handleReact(frame, contentHeight, "scrollViewContentHeight")
        assert(isScrollableView(frame.uk_type), "Invalid variable `scrollViewContentHeight`: Must be called on `ScrollView` or `LazyScrollView`")
        assert(contentHeight == UIKit_Define.Num or contentHeight == UIKit_Define.Percentage or contentHeight == UIKit_Define.Fit, "Invalid variable `scrollViewContentHeight`: Must be of type `UIKit.Define.Num`, `UIKit.Define.Percentage` or `UIKit.Define.Fit`")
        local contentFrame = frame:GetContentFrame()
        contentFrame.uk_prop_height = contentHeight
        if contentHeight == UIKit_Define.Num then contentFrame:SetHeight(contentHeight.value) end
    end

    -- React
    FrameProps["scrollInterpolation"] = function(frame, interpolationValue)
        interpolationValue = handleReact(frame, interpolationValue, "scrollInterpolation")
        assert(isScrollableView(frame.uk_type), "Invalid variable `scrollInterpolation`: Must be called on `ScrollView` or `LazyScrollView`")
        assert(type(interpolationValue) == "number", "Invalid variable `scrollInterpolation`: Must be a number")
        frame.uk_prop_scrollInterpolation = interpolationValue
        frame:SetSmoothScrolling((interpolationValue ~= nil), interpolationValue)
    end

    -- React
    FrameProps["scrollStepSize"] = function(frame, stepSizeValue)
        stepSizeValue = handleReact(frame, stepSizeValue, "scrollStepSize")
        assert(isScrollableView(frame.uk_type), "Invalid variable `scrollStepSize`: Must be called on `ScrollView` or `LazyScrollView`")
        assert(type(stepSizeValue) == "number", "Invalid variable `scrollStepSize`: Must be a number")
        frame.uk_prop_scrollStepSize = stepSizeValue
        frame:SetStepSize(stepSizeValue)
    end
end


-- Text
--------------------------------

do
    -- React
    FrameProps["text"] = function(frame, textValue)
        textValue = handleReact(frame, textValue, "text")
        assert(isTextOrInput(frame.uk_type), "Invalid variable `text`: Must be called on `Text` or `Input`")
        assert(type(textValue) == "string", "Invalid variable `text`: Must be a string")
        frame:SetText(textValue)
    end

    -- React
    FrameProps["font"] = function(frame, fontPath)
        fontPath = handleReact(frame, fontPath, "font")
        assert(isTextOrInput(frame.uk_type), "Invalid variable `font`: Must be called on `Text` or `Input`")
        assert(type(fontPath) == "string", "Invalid variable `font`: Must be a string")
        frame:SetFont(fontPath)
    end

    -- React
    FrameProps["fontObject"] = function(frame, fontObj)
        fontObj = handleReact(frame, fontObj, "fontObject")
        assert(isTextOrInput(frame.uk_type), "Invalid variable `fontObject`: Must be called on `Text` or `Input`")
        assert(fontObj and fontObj.GetObjectType and fontObj:GetObjectType() == "Font", "Invalid variable `fontObject`: Must be a `Font`")
        frame:SetFontObject(fontObj)
    end

    -- React
    FrameProps["fontSize"] = function(frame, size)
        size = handleReact(frame, size, "fontSize")
        assert(isTextOrInput(frame.uk_type), "Invalid variable `fontSize`: Must be called on `Text` or `Input`")
        assert(type(size) == "number", "Invalid variable `fontSize`: Must be a number")
        frame:SetFontSize(size)
    end

    -- React
    FrameProps["fontFlags"] = function(frame, flags)
        flags = handleReact(frame, flags, "fontFlags")
        assert(isTextOrInput(frame.uk_type), "Invalid variable `fontFlags`: Must be called on `Text` or `Input`")
        assert(type(flags) == "string", "Invalid variable `fontFlags`: Must be a string")
        frame:SetFontFlags(flags)
    end

    -- React
    FrameProps["textJustifyH"] = function(frame, justifyH)
        justifyH = handleReact(frame, justifyH, "justifyH")
        assert(isTextOrInput(frame.uk_type), "Invalid variable `textJustifyH`: Must be called on `Text` or `Input`")
        assert(type(justifyH) == "string", "Invalid variable `textJustifyH`: Must be a string")
        frame:SetJustifyH(justifyH)
    end

    -- React
    FrameProps["textJustifyV"] = function(frame, justifyV)
        justifyV = handleReact(frame, justifyV, "justifyV")
        assert(isTextOrInput(frame.uk_type), "Invalid variable `textJustifyV`: Must be called on `Text` or `Input`")
        assert(type(justifyV) == "string", "Invalid variable `textJustifyV`: Must be a string")
        frame:SetJustifyV(justifyV)
    end

    FrameProps["textAlignment"] = function(frame, justifyH, justifyV)
        assert(isTextOrInput(frame.uk_type), "Invalid variable `textAlignment`: Must be called on `Text` or `Input`")
        if justifyH then frame:textJustifyH(justifyH) end
        if justifyV then frame:textJustifyV(justifyV) end
    end

    -- React
    FrameProps["textVerticalSpacing"] = function(frame, spacingValue)
        spacingValue = handleReact(frame, spacingValue, "textVerticalSpacing")
        assert(isTextOrInput(frame.uk_type), "Invalid variable `textVerticalSpacing`: Must be called on `Text` or `Input`")
        assert(type(spacingValue) == "number", "Invalid variable `textVerticalSpacing`: Must be a number")
        frame:SetSpacing(spacingValue)
    end

    -- React
    FrameProps["textColor"] = function(frame, color)
        color = handleReact(frame, color, "textColor")
        assert(isTextOrInput(frame.uk_type), "Invalid variable `textColor`: Must be called on `Text` or `Input`")
        assert(isColorDefine(color), "Invalid variable `textColor`: Must be a `Color_RGBA` or `Color_HEX`")
        local parsed = UIKit_Utils:ProcessColor(color)
        frame:SetTextColor(parsed.r, parsed.g, parsed.b, parsed.a)
    end

    -- React
    FrameProps["wordWrap"] = function(frame, wrapEnabled)
        wrapEnabled = handleReact(frame, wrapEnabled, "wordWrap")
        assert(isTextOrInput(frame.uk_type), "Invalid variable `wordWrap`: Must be called on `Text` or `Input`")
        assert(type(wrapEnabled) == "boolean", "Invalid variable `wordWrap`: Must be a boolean")
        frame:SetWordWrap(wrapEnabled)
    end

    -- React
    FrameProps["indentedWordWrap"] = function(frame, wrapEnabled)
        wrapEnabled = handleReact(frame, wrapEnabled, "indentedWordWrap")
        assert(isTextOrInput(frame.uk_type), "Invalid variable `indentedWordWrap`: Must be called on `Text` or `Input`")
        assert(type(wrapEnabled) == "boolean", "Invalid variable `indentedWordWrap`: Must be a boolean")
        frame:SetIndentedWordWrap(wrapEnabled)
    end

    -- React
    FrameProps["nonSpaceWordWrap"] = function(frame, wrapEnabled)
        wrapEnabled = handleReact(frame, wrapEnabled, "nonSpaceWordWrap")
        assert(isTextOrInput(frame.uk_type), "Invalid variable `nonSpaceWordWrap`: Must be called on `Text` or `Input`")
        assert(type(wrapEnabled) == "boolean", "Invalid variable `nonSpaceWordWrap`: Must be a boolean")
        frame:SetNonSpaceWrap(wrapEnabled)
    end

    -- React
    FrameProps["maxLines"] = function(frame, lineCount)
        lineCount = handleReact(frame, lineCount, "maxLines")
        assert(isTextOrInput(frame.uk_type), "Invalid variable `maxLines`: Must be called on `Text` or `Input`")
        assert(type(lineCount) == "number", "Invalid variable `maxLines`: Must be a number")
        frame:SetMaxLines(lineCount)
    end

    -- React
    FrameProps["shadowColor"] = function(frame, color)
        color = handleReact(frame, color, "shadowColor")
        assert(isTextOrInput(frame.uk_type), "Invalid variable `shadowColor`: Must be called on `Text` or `Input`")
        assert(isColorDefine(color), "Invalid variable `shadowColor`: Must be a `Color_RGBA` or `Color_HEX`")
        local parsed = UIKit_Utils:ProcessColor(color)
        frame:SetShadowColor(parsed.r, parsed.g, parsed.b, parsed.a)
    end

    -- React
    FrameProps["textHeight"] = function(frame, heightValue)
        heightValue = handleReact(frame, heightValue, "textHeight")
        assert(isTextOrInput(frame.uk_type), "Invalid variable `textHeight`: Must be called on `Text` or `Input`")
        assert(type(heightValue) == "number", "Invalid variable `textHeight`: Must be a number")
        frame:SetTextHeight(heightValue)
    end

    -- React
    FrameProps["textRotation"] = function(frame, radians)
        radians = handleReact(frame, radians, "textRotation")
        assert(isTextOrInput(frame.uk_type), "Invalid variable `textRotation`: Must be called on `Text` or `Input`")
        assert(type(radians) == "number", "`textRotation` must be a number")
        frame:SetRotation(radians)
    end

    FrameProps["alphaGradient"] = function(frame, startPos, gradientLength)
        assert(isTextOrInput(frame.uk_type), "Invalid variable `alphaGradient`: Must be called on `Text` or `Input`")
        assert(type(startPos) == "number", "Invalid variable `alphaGradient start`: Must be a number")
        assert(type(gradientLength) == "number", "Invalid variable `alphaGradient length`: Must be a number")
        frame:SetAlphaGradient(startPos, gradientLength)
    end

    FrameProps["shadowOffset"] = function(frame, offsetX, offsetY)
        assert(isTextOrInput(frame.uk_type), "Invalid variable `shadowOffset`: Must be called on `Text` or `Input`")
        assert(type(offsetX) == "number", "Invalid variable `shadowOffset x`: Must be a number")
        assert(type(offsetY) == "number", "Invalid variable `shadowOffset y`: Must be a number")
        frame:SetShadowOffset(offsetX, offsetY)
    end

    -- React
    FrameProps["placeholder"] = function(frame, placeholderText)
        placeholderText = handleReact(frame, placeholderText, "placeholder")
        assert(frame.uk_type == "Input", "Invalid variable `placeholder`: Must be called on `Input`")
        assert(type(placeholderText) == "string", "Invalid variable `placeholder`: Must be a string")
        frame:SetPlaceholder(placeholderText)
    end

    -- React
    FrameProps["inputCaretWidth"] = function(frame, caretWidth)
        caretWidth = handleReact(frame, caretWidth, "inputCaretWidth")
        assert(frame.uk_type == "Input", "Invalid variable `inputCaretWidth`: Must be called on `Input`")
        assert(type(caretWidth) == "number", "Invalid variable `inputCaretWidth`: Must be a number")
        frame:SetCaretWidth(caretWidth)
    end

    -- React
    FrameProps["inputCaretOffsetX"] = function(frame, caretOffset)
        caretOffset = handleReact(frame, caretOffset, "inputCaretOffsetX")
        assert(frame.uk_type == "Input", "Invalid variable `inputCaretOffsetX`: Must be called on `Input`")
        assert(type(caretOffset) == "number", "Invalid variable `inputCaretOffsetX`: Must be a number")
        frame:SetCaretOffsetX(caretOffset)
    end

    -- React
    FrameProps["inputMultiLine"] = function(frame, isMultiLine)
        isMultiLine = handleReact(frame, isMultiLine, "inputMultiLine")
        assert(frame.uk_type == "Input", "Invalid variable `inputMultiLine`: Must be called on `Input`")
        assert(type(isMultiLine) == "boolean", "Invalid variable `inputMultiLine`: Must be a boolean")
        frame:SetMultiLine(isMultiLine)
    end

    -- React
    FrameProps["inputHighlightColor"] = function(frame, color)
        color = handleReact(frame, color, "inputHighlightColor")
        assert(frame.uk_type == "Input", "Invalid variable `inputHighlightColor`: Must be called on `Input`")
        assert(isColorDefine(color), "`inputHighlightColor` must be a `Color_RGBA` or `Color_HEX`")
        local parsed = UIKit_Utils:ProcessColor(color)
        frame:SetHighlightColor(parsed.r, parsed.g, parsed.b, parsed.a)
    end

    -- React
    FrameProps["inputPlaceholderTextColor"] = function(frame, color)
        color = handleReact(frame, color, "inputPlaceholderTextColor")
        assert(frame.uk_type == "Input", "Invalid variable `inputPlaceholderTextColor`: Must be called on `Input`")
        assert(isColorDefine(color), "Invalid variable `inputPlaceholderTextColor`: Must be a `Color_RGBA` or `Color_HEX`")
        local parsed = UIKit_Utils:ProcessColor(color)
        frame.__Placeholder:SetTextColor(parsed.r, parsed.g, parsed.b, parsed.a)
    end

    -- React
    FrameProps["inputPlaceholderFont"] = function(frame, fontPath)
        fontPath = handleReact(frame, fontPath, "inputPlaceholderFont")
        assert(frame.uk_type == "Input", "Invalid variable `inputPlaceholderFont`: Must be called on `Input`")
        assert(type(fontPath) == "string", "Invalid variable `inputPlaceholderFont`: Must be a string")
        frame:SetPlaceholderFont(fontPath)
    end

    -- React
    FrameProps["inputPlaceholderFontSize"] = function(frame, fontSize)
        fontSize = handleReact(frame, fontSize, "inputPlaceholderFontSize")
        assert(frame.uk_type == "Input", "Invalid variable `inputPlaceholderFontSize`: Must be called on `Input`")
        assert(type(fontSize) == "number", "Invalid variable `inputPlaceholderFontSize`: Must be a number")
        frame:SetPlaceholderFontSize(fontSize)
    end

    -- React
    FrameProps["inputPlaceholderFontFlags"] = function(frame, fontFlags)
        fontFlags = handleReact(frame, fontFlags, "inputPlaceholderFontFlags")
        assert(frame.uk_type == "Input", "Invalid variable `inputPlaceholderFontFlags`: Must be called on `Input`")
        assert(type(fontFlags) == "string", "Invalid variable `inputPlaceholderFontFlags`: Must be a string")
        frame:SetPlaceholderFontFlags(fontFlags)
    end
end


-- Linear Slider
--------------------------------

do
    FrameProps["linearSliderOrientation"] = function(frame, sliderOrientation)
        sliderOrientation = handleReact(frame, sliderOrientation, "linearSliderOrientation")
        assert(frame.uk_type == "LinearSlider", "Invalid variable `linearSliderOrientation`: Must be called on `LinearSlider`")
        assert(sliderOrientation == UIKit_Enum.Orientation.Horizontal or sliderOrientation == UIKit_Enum.Orientation.Vertical, "Invalid variable `linearSliderOrientation`: Must be `HORIZONTAL` or `VERTICAL`")
        frame:SetOrientation(sliderOrientation)
    end

    FrameProps["linearSliderThumbWidth"] = function(frame, thumbWidth)
        thumbWidth = handleReact(frame, thumbWidth, "linearSliderThumbWidth")
        assert(frame.uk_type == "LinearSlider", "Invalid variable `linearSliderThumbWidth`: Must be called on `LinearSlider`")
        assert(thumbWidth and type(thumbWidth) == "number", "Invalid variable `linearSliderThumbWidth`: Must be a number")
        frame.__ThumbAnchor:SetWidth(thumbWidth)
    end

    FrameProps["linearSliderThumbHeight"] = function(frame, thumbHeight)
        thumbHeight = handleReact(frame, thumbHeight, "linearSliderThumbHeight")
        assert(frame.uk_type == "LinearSlider", "Invalid variable `linearSliderThumbHeight`: Must be called on `LinearSlider`")
        assert(thumbHeight and type(thumbHeight) == "number", "Invalid variable `linearSliderThumbHeight`: Must be a number")
        frame.__ThumbAnchor:SetHeight(thumbHeight)
    end

    FrameProps["linearSliderThumbSize"] = function(frame, thumbWidth, thumbHeight)
        assert(frame.uk_type == "LinearSlider", "Invalid variable `linearSliderThumbSize`: Must be called on `LinearSlider`")
        assert(thumbWidth and type(thumbWidth) == "number", "Invalid variable `linearSliderThumbSize`: Must be a number")
        assert(thumbHeight and type(thumbHeight) == "number", "Invalid variable `linearSliderThumbSize`: Must be a number")
        if thumbWidth then frame:linearSliderThumbWidth(thumbWidth) end
        if thumbHeight then frame:linearSliderThumbHeight(thumbHeight) end
    end

    FrameProps["linearSliderThumbPropagateMouse"] = function(frame, propagate)
        assert(frame.uk_type == "LinearSlider", "Invalid variable `linearSliderThumbPropagateMouse`: Must be called on `LinearSlider`")
        assert(type(propagate) == "boolean", "Invalid variable `linearSliderThumbPropagateMouse`: Must be a boolean")
        local thumb = frame:GetThumb()
        thumb:AwaitSetPropagateMouseClicks(propagate)
        thumb:AwaitSetPropagateMouseMotion(propagate)
    end
end


-- Interactive Rect
--------------------------------

do
    FrameProps["onEnter"] = function(frame, callback)
        assert(frame.uk_type == "InteractiveRect", "Invalid variable `onEnter`: Must be called on `InteractiveRect`")
        frame:AddOnEnter(callback)
    end

    FrameProps["onLeave"] = function(frame, callback)
        assert(frame.uk_type == "InteractiveRect", "Invalid variable `onLeave`: Must be called on `InteractiveRect`")
        frame:AddOnLeave(callback)
    end

    FrameProps["onMouseDown"] = function(frame, callback)
        assert(frame.uk_type == "InteractiveRect", "Invalid variable `onMouseDown`: Must be called on `InteractiveRect`")
        frame:AddOnMouseDown(callback)
    end

    FrameProps["onMouseUp"] = function(frame, callback)
        assert(frame.uk_type == "InteractiveRect", "Invalid variable `onMouseUp`: Must be called on `InteractiveRect`")
        frame:AddOnMouseUp(callback)
    end
end


-- Pooling
--------------------------------

do
    local function isPoolableView(frameType)
        return frameType == "List" or frameType == "LazyScrollView"
    end

    FrameProps["poolOnElementUpdate"] = function(frame, updateFunc)
        assert(isPoolableView(frame.uk_type), "Invalid variable `poolOnElementUpdate`: Must be called on `List` or `LazyScrollView`")
        assert(type(updateFunc) == "function", "Invalid variable `func`: Must be a function")
        frame:SetOnElementUpdate(updateFunc)
    end

    FrameProps["poolPrefab"] = function(frame, prefabFunc)
        assert(isPoolableView(frame.uk_type), "Invalid variable `poolPrefab`: Must be called on `List` or `LazyScrollView`")
        assert(type(prefabFunc) == "function" or type(prefabFunc) == "table", "Invalid variable `prefabFunc`: Must be a function or a table")
        frame:SetPrefab(prefabFunc)
    end

    FrameProps["lazyScrollViewElementHeight"] = function(frame, elementHeight)
        assert(frame.uk_type == "LazyScrollView", "Invalid variable `lazyScrollViewElementHeight`: Must be called on `LazyScrollView`")
        assert(type(elementHeight) == "number", "Invalid variable `lazyScrollViewElementHeight`: Must be a number")
        frame:SetElementHeight(elementHeight)
    end
end
