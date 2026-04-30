local env = select(2, ...)
local UIKit_TagManager = env.modules:Import("packages\\ui-kit\\tag-manager")
local UIKit_Renderer = env.modules:Import("packages\\ui-kit\\renderer")
local UIKit_Utils = env.modules:Import("packages\\ui-kit\\utils")
local UIKit_Define = env.modules:Import("packages\\ui-kit\\define")
local UIKit_Enum = env.modules:Import("packages\\ui-kit\\enum")
local UIKit_Primitives_Frame = env.modules:Import("packages\\ui-kit\\primitives\\frame")
local UIKit_UI_Scanner = env.modules:Import("packages\\ui-kit\\ui\\scanner")
local UIKit_Renderer_Background = env.modules:Import("packages\\ui-kit\\renderer\\background")
local React = env.modules:Import("packages\\react")

local type = type
local unpack = unpack
local FrameProps = UIKit_Primitives_Frame.FrameProps

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

local function ResolveFrameReference(frameOrId)
    if type(frameOrId) ~= "string" then
        return frameOrId
    end

    if UIKit_TagManager.IsGroupCaptureString(frameOrId) then
        local resolvedId, resolvedGroupId = UIKit_TagManager.ReadGroupCaptureString(frameOrId)
        return UIKit_TagManager.GetElementById(resolvedId, resolvedGroupId)
    end

    return UIKit_TagManager.GetElementById(frameOrId)
end

local function HandleReact(frame, value, propName, argumentIndex)
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

local function IsColorDefine(color)
    return color == UIKit_Define.Color_RGBA or color == UIKit_Define.Color_HEX
end

local function IsTextOrInput(frameType)
    return frameType == "Text" or frameType == "Input"
end

local function IsScrollContainer(frameType)
    return frameType == "ScrollContainer" or frameType == "LazyScrollContainer"
end

local function IsScrollContainerExtension(frameType)
    return frameType == "ScrollBar" or frameType == "ScrollContainerEdge"
end

do -- General
    FrameProps["id"] = function(frame, value, groupID)
        UIKit_TagManager.Id.Add(frame, value, groupID)
    end

    FrameProps["as"] = function(frame, aliasName)
        assert(aliasName, "Invalid variable `aliasName`")
        frame.uk_prop_under = aliasName
    end

    FrameProps["parent"] = function(frame, targetFrame)
        assert(targetFrame, "Invalid variable `parent`: target frame is required")
        targetFrame = ResolveFrameReference(targetFrame)

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

    FrameProps["setScript"] = function(frame, hook, callback)
        assert(type(hook) == "string", "Invalid variable `hook`: Must be of type `string`")
        assert(type(callback) == "function", "Invalid variable `callback`: Must be of type `function`")
        frame:SetScript(hook, callback)
    end

    FrameProps["hookScript"] = function(frame, hook, callback)
        assert(type(hook) == "string", "Invalid variable `hook`: Must be of type `string`")
        assert(type(callback) == "function", "Invalid variable `callback`: Must be of type `function`")
        frame:HookScript(hook, callback)
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
        topLevel = HandleReact(frame, topLevel, "topLevel")
        assert(type(topLevel) == "boolean", "Invalid variable `topLevel`: Must be of type `boolean`")
        frame:SetToplevel(topLevel)
    end

    -- React
    FrameProps["alpha"] = function(frame, opacity)
        opacity = HandleReact(frame, opacity, "alpha")
        assert(type(opacity) == "number", "Invalid variable `opacity`: Must be of type `number`")
        frame:SetAlpha(opacity)
    end

    -- React
    FrameProps["scale"] = function(frame, scale)
        scale = HandleReact(frame, scale, "scale")
        assert(type(scale) == "number", "Invalid variable `scale`: Must be of type `number`")
        frame:SetScale(scale)
    end

    -- React
    FrameProps["movable"] = function(frame, movable)
        movable = HandleReact(frame, movable, "movable")
        assert(type(movable) == "boolean", "Invalid variable `movable`: Must be of type `boolean`")
        frame:SetMovable(movable)
    end

    -- React
    FrameProps["resizable"] = function(frame, resizable)
        resizable = HandleReact(frame, resizable, "resizable")
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
        enabled = HandleReact(frame, enabled, "enableMouse")
        assert(type(enabled) == "boolean", "Invalid variable `enableMouse`: Must be of type `boolean`")
        frame:EnableMouse(enabled)
    end

    -- React
    FrameProps["enableMouseMotion"] = function(frame, enabled)
        enabled = HandleReact(frame, enabled, "enableMouseMotion")
        assert(type(enabled) == "boolean", "Invalid variable `enableMouseMotion`: Must be of type `boolean`")
        frame:EnableMouseMotion(enabled)
    end

    FrameProps["enableMouseWheel"] = function(frame, enabled)
        enabled = HandleReact(frame, enabled, "enableMouseWheel")
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
        enabled = HandleReact(frame, enabled, "enableKeyboard")
        assert(type(enabled) == "boolean", "Invalid variable `enableKeyboard`: Must be of type `boolean`")
        frame:SetPropagateKeyboardInput(enabled)
    end

    -- React
    FrameProps["clampedToScreen"] = function(frame, clamped)
        clamped = HandleReact(frame, clamped, "clampedToScreen")
        assert(type(clamped) == "boolean", "Invalid variable `clampedToScreen`: Must be of type `boolean`")
        frame:SetClampedToScreen(clamped)
    end

    FrameProps["clipsChildren"] = function(frame, clips)
        clips = HandleReact(frame, clips, "clipsChildren")
        assert(type(clips) == "boolean", "Invalid variable `clipsChildren`: Must be of type `boolean`")
        frame:SetClipsChildren(clips)
    end

    -- React
    FrameProps["ignoreParentScale"] = function(frame, ignore)
        ignore = HandleReact(frame, ignore, "ignoreParentScale")
        assert(type(ignore) == "boolean", "Invalid variable `ignoreParentScale`: Must be of type `boolean`")
        frame:SetIgnoreParentScale(ignore)
    end

    -- React
    FrameProps["ignoreParentAlpha"] = function(frame, ignore)
        ignore = HandleReact(frame, ignore, "ignoreParentAlpha")
        assert(type(ignore) == "boolean", "Invalid variable `ignoreParentAlpha`: Must be of type `boolean`")
        frame:SetIgnoreParentAlpha(ignore)
    end

    do
        local function EnsureHandleTarget(frame)
            if frame.uk_prop_handleTarget then return end
            local targetId = frame.uk_prop_moveHandle_targetId or frame.uk_prop_resizeHandle_targetId
            frame.uk_prop_handleTarget = ResolveFrameReference(targetId)
        end

        local function OnMoveMouseDown(frame)
            EnsureHandleTarget(frame)
            assert(frame.uk_prop_handleTarget, "Invalid variable `handleTarget`")
            frame.uk_prop_handleTarget:StartMoving()
        end

        local function OnMoveMouseUp(frame)
            EnsureHandleTarget(frame)
            assert(frame.uk_prop_handleTarget, "Invalid variable `handleTarget`")
            frame.uk_prop_handleTarget:StopMovingOrSizing()
        end

        local function OnResizeMouseDown(frame)
            EnsureHandleTarget(frame)
            assert(frame.uk_prop_handleTarget, "Invalid variable `handleTarget`")
            frame.uk_prop_handleTarget:StartSizing()
        end

        local function OnResizeMouseUp(frame)
            EnsureHandleTarget(frame)
            assert(frame.uk_prop_handleTarget, "Invalid variable `handleTarget`")
            frame.uk_prop_handleTarget:StopMovingOrSizing()
        end

        FrameProps["moveHandle"] = function(frame, targetId)
            frame.uk_prop_moveHandle_targetId = targetId
            frame:HookScript("OnMouseDown", OnMoveMouseDown)
            frame:HookScript("OnMouseUp", OnMoveMouseUp)
        end

        FrameProps["resizeHandle"] = function(frame, targetId)
            frame.uk_prop_resizeHandle_targetId = targetId
            frame:HookScript("OnMouseDown", OnResizeMouseDown)
            frame:HookScript("OnMouseUp", OnResizeMouseUp)
        end
    end

    FrameProps["point"] = function(frame, point, relativePoint)
        frame.uk_prop_point = point
        frame.uk_prop_point_relative = relativePoint
    end

    FrameProps["anchor"] = function(frame, anchorFrame)
        anchorFrame = HandleReact(frame, anchorFrame, "anchor")
        anchorFrame = ResolveFrameReference(anchorFrame)
        frame.uk_prop_anchor = anchorFrame
    end

    -- React
    FrameProps["x"] = function(frame, xPos)
        xPos = HandleReact(frame, xPos, "x")
        assert(type(xPos) == "number" or xPos == UIKit_Define.Percentage, "Invalid variable `x`: Must be of type `number` or `UIKit.Define.Percentage`")
        frame.uk_prop_x = xPos
    end

    -- React
    FrameProps["y"] = function(frame, yPos)
        yPos = HandleReact(frame, yPos, "y")
        assert(type(yPos) == "number" or yPos == UIKit_Define.Percentage, "Invalid variable `y`: Must be of type `number` or `UIKit.Define.Percentage`")
        frame.uk_prop_y = yPos
    end

    FrameProps["position"] = function(frame, xPos, yPos)
        frame:x(xPos)
        frame:y(yPos)
    end

    -- React
    FrameProps["width"] = function(frame, widthValue)
        widthValue = HandleReact(frame, widthValue, "width")
        assert(type(widthValue) == "number" or widthValue == UIKit_Define.Percentage or widthValue == UIKit_Define.Fit or widthValue == UIKit_Define.Fill, "Invalid variable `width`: Must be of type `number`, `UIKit.Define.Percentage`, `UIKit.Define.Fit` or `UIKit.Define.Fill`")
        frame.uk_prop_width = widthValue
        if type(widthValue) == "number" then frame:SetWidth(widthValue) end
    end

    -- React
    FrameProps["height"] = function(frame, heightValue)
        heightValue = HandleReact(frame, heightValue, "height")
        assert(type(heightValue) == "number" or heightValue == UIKit_Define.Percentage or heightValue == UIKit_Define.Fit or heightValue == UIKit_Define.Fill, "Invalid variable `height`: Must be of type `number`, `UIKit.Define.Percentage`, `UIKit.Define.Fit` or `UIKit.Define.Fill`")
        frame.uk_prop_height = heightValue
        if type(heightValue) == "number" then frame:SetHeight(heightValue) end
    end

    FrameProps["minWidth"] = function(frame, minWidthValue)
        minWidthValue = HandleReact(frame, minWidthValue, "minWidth")
        if minWidthValue == nil then
            frame.uk_prop_minWidth = nil
            return
        end
        assert(type(minWidthValue) == "number" or minWidthValue == UIKit_Define.Percentage, "Invalid variable `minWidth`: Must be of type `number` or `UIKit.Define.Percentage`")
        frame.uk_prop_minWidth = minWidthValue
    end

    -- React
    FrameProps["minHeight"] = function(frame, minHeightValue)
        minHeightValue = HandleReact(frame, minHeightValue, "minHeight")
        if minHeightValue == nil then
            frame.uk_prop_minHeight = nil
            return
        end
        assert(type(minHeightValue) == "number" or minHeightValue == UIKit_Define.Percentage, "Invalid variable `minHeight`: Must be of type `number` or `UIKit.Define.Percentage`")
        frame.uk_prop_minHeight = minHeightValue
    end

    FrameProps["maxWidth"] = function(frame, maxWidthValue)
        maxWidthValue = HandleReact(frame, maxWidthValue, "maxWidth")
        if maxWidthValue == nil then
            frame.uk_prop_maxWidth = nil
            return
        end
        assert(type(maxWidthValue) == "number" or maxWidthValue == UIKit_Define.Percentage, "Invalid variable `maxWidth`: Must be of type `number` or `UIKit.Define.Percentage`")
        frame.uk_prop_maxWidth = maxWidthValue
    end

    -- React
    FrameProps["maxHeight"] = function(frame, maxHeightValue)
        maxHeightValue = HandleReact(frame, maxHeightValue, "maxHeight")
        if maxHeightValue == nil then
            frame.uk_prop_maxHeight = nil
            return
        end
        assert(type(maxHeightValue) == "number" or maxHeightValue == UIKit_Define.Percentage, "Invalid variable `maxHeight`: Must be of type `number` or `UIKit.Define.Percentage`")
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

    local function IsValidTexture(texture)
        return texture == UIKit_Define.Texture or texture == UIKit_Define.Texture_NineSlice or texture == UIKit_Define.Texture_Atlas
    end

    FrameProps["background"] = function(frame, backgroundTexture)
        backgroundTexture = HandleReact(frame, backgroundTexture, "background")
        assert(IsValidTexture(backgroundTexture), "Invalid variable `backgroundTexture`: Must be a `Texture`, `Texture_NineSlice` or `Texture_Atlas`")
        local existingBackground = frame:GetTextureFrame()
        assert(not existingBackground or existingBackground.__isMaskTexture == false, "Error! Failed to set `backgroundTexture`: a mask texture background object already exists")
        frame.uk_prop_background = backgroundTexture
        UIKit_Renderer_Background.SetBackground(frame, false)
    end

    FrameProps["maskBackground"] = function(frame, backgroundTexture)
        backgroundTexture = HandleReact(frame, backgroundTexture, "maskBackground")
        assert(backgroundTexture == UIKit_Define.Texture, "Invalid variable `backgroundTexture`: Must be a `Texture`")
        local existingBackground = frame:GetTextureFrame()
        assert(not existingBackground or existingBackground.__isMaskTexture, "Error! Failed to set `maskBackground`: a non-mask texture background object already exists")
        frame.uk_prop_background = backgroundTexture
        UIKit_Renderer_Background.SetBackground(frame, true)
    end

    FrameProps["backdropColor"] = function(frame, bgColor, borderColor)
        assert(IsColorDefine(bgColor), "Invalid variable `background`: Must be a `Color_RGBA` or `Color_HEX`")
        assert(IsColorDefine(borderColor), "Invalid variable `border`: Must be a `Color_RGBA` or `Color_HEX`")
        frame.uk_prop_backdropColor_background = bgColor
        frame.uk_prop_backdropColor_border = borderColor
        UIKit_Renderer_Background.SetBackdropColor(frame)
    end

    FrameProps["backgroundColor"] = function(frame, color)
        color = HandleReact(frame, color, "backgroundColor")
        assert(IsColorDefine(color), "Invalid variable `backgroundColor`: Must be a `Color_RGBA` or `Color_HEX`")
        frame.uk_prop_backgroundColor = color
        UIKit_Renderer_Background.SetBackgroundColor(frame)
    end

    FrameProps["backgroundRotation"] = function(frame, radians)
        radians = HandleReact(frame, radians, "backgroundRotation")
        assert(type(radians) == "number", "Invalid variable `backgroundRotation`: Must be a number")
        frame.uk_prop_backgroundRotation = radians
        UIKit_Renderer_Background.SetRotation(frame)
    end

    FrameProps["backgroundBlendMode"] = function(frame, blendMode)
        blendMode = HandleReact(frame, blendMode, "backgroundBlendMode")
        assert(type(blendMode) == "string", "Invalid variable `backgroundBlendMode`: Must be a string")
        frame.uk_prop_blendMode = blendMode
        UIKit_Renderer_Background.SetBlendMode(frame)
    end

    FrameProps["backgroundDesaturated"] = function(frame, desaturated)
        desaturated = HandleReact(frame, desaturated, "backgroundDesaturated")
        assert(type(desaturated) == "boolean", "Invalid variable `backgroundDesaturated`: Must be a boolean")
        frame.uk_prop_desaturated = desaturated
        UIKit_Renderer_Background.SetDesaturated(frame)
    end

    FrameProps["mask"] = function(frame, maskFrame)
        maskFrame = HandleReact(frame, maskFrame, "mask")
        maskFrame = ResolveFrameReference(maskFrame)
        local maskBg = maskFrame.GetTextureFrame and maskFrame:GetTextureFrame()
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

    FrameProps["_excludeFromCalculations"] = function(frame, exclude)
        frame.uk_flag_excludeFromCalculations = (exclude == nil and true) or exclude
    end

    FrameProps["_Render"] = function(frame)
        if not frame.uk_prop_rendered then
            frame.uk_prop_rendered = true
            UIKit_UI_Scanner.SetupFrame(frame)
            UIKit_UI_Scanner.SetupFrameRecursive(frame)
        end
        UIKit_Renderer.Scanner.ScanFrame(frame)
    end

    FrameProps["_Rerender"] = function(frame)
        if not frame.uk_prop_rendered then
            frame.uk_prop_rendered = true
            UIKit_UI_Scanner.SetupFrame(frame)
        end
        UIKit_Renderer.Scanner.ScanFrameOnly(frame)
    end
end

do -- Layout Group
    -- React
    FrameProps["layoutSpacing"] = function(frame, spacingValue)
        spacingValue = HandleReact(frame, spacingValue, "layoutSpacing")
        assert(type(spacingValue) == "number" or spacingValue == UIKit_Define.Percentage, "Invalid variable `layoutSpacing`: Must be of type `number` or `UIKit.Define.Percentage`")
        frame.uk_prop_layoutSpacing = spacingValue
    end

    -- React
    FrameProps["layoutSpacingH"] = function(frame, spacingValue)
        spacingValue = HandleReact(frame, spacingValue, "layoutSpacingH")
        assert(type(spacingValue) == "number" or spacingValue == UIKit_Define.Percentage, "Invalid variable `layoutSpacingH`: Must be of type `number` or `UIKit.Define.Percentage`")
        frame.uk_prop_layoutSpacingH = spacingValue
    end

    -- React
    FrameProps["layoutSpacingV"] = function(frame, spacingValue)
        spacingValue = HandleReact(frame, spacingValue, "layoutSpacingV")
        assert(type(spacingValue) == "number" or spacingValue == UIKit_Define.Percentage, "Invalid variable `layoutSpacingV`: Must be of type `number` or `UIKit.Define.Percentage`")
        frame.uk_prop_layoutSpacingV = spacingValue
    end

    -- React
    FrameProps["layoutAlignmentH"] = function(frame, alignment)
        alignment = HandleReact(frame, alignment, "layoutAlignmentH")
        assert(alignment == UIKit_Enum.Direction.Justified or alignment == UIKit_Enum.Direction.Leading or alignment == UIKit_Enum.Direction.Trailing, "Invalid variable `alignment`: Must be of type `UIKit.Enum.Direction.Justified`, `UIKit.Enum.Direction.Leading` or `UIKit.Enum.Direction.Trailing`")
        frame.uk_prop_layoutAlignmentH = alignment
    end

    -- React
    FrameProps["layoutAlignmentV"] = function(frame, alignment)
        alignment = HandleReact(frame, alignment, "layoutAlignmentV")
        assert(alignment == UIKit_Enum.Direction.Justified or alignment == UIKit_Enum.Direction.Leading or alignment == UIKit_Enum.Direction.Trailing, "Invalid variable `alignment`: Must be of type `UIKit.Enum.Direction.Justified`, `UIKit.Enum.Direction.Leading` or `UIKit.Enum.Direction.Trailing`")
        frame.uk_prop_layoutAlignmentV = alignment
    end

    -- React
    FrameProps["layoutDirection"] = function(frame, directionValue)
        directionValue = HandleReact(frame, directionValue, "layoutDirection")
        assert(directionValue == UIKit_Enum.Direction.Horizontal or directionValue == UIKit_Enum.Direction.Vertical, "Invalid variable `layoutDirection`: Must be of type `UIKit.Enum.Direction.Horizontal` or `UIKit.Enum.Direction.Vertical`")
        frame.uk_prop_layoutDirection = directionValue
    end

    -- React
    FrameProps["columns"] = function(frame, columnCount)
        columnCount = HandleReact(frame, columnCount, "columns")
        assert(type(columnCount) == "number" and columnCount > 0, "Invalid variable `columns`: Must be a positive number")
        frame.uk_LayoutGridColumns = columnCount
    end

    -- React
    FrameProps["rows"] = function(frame, rowCount)
        rowCount = HandleReact(frame, rowCount, "rows")
        assert(type(rowCount) == "number" and rowCount > 0, "Invalid variable `rows`: Must be a positive number")
        frame.uk_LayoutGridRows = rowCount
    end
end

do -- Scrolling
    FrameProps["scrollDirection"] = function(frame, scrollDir)
        local frameType = frame.uk_type
        assert(IsScrollContainerExtension(frameType) or IsScrollContainer(frameType), "Invalid variable `scrollDirection`: Must be called on `ScrollBar` or `ScrollContainerEdge` or `ScrollContainer` or `LazyScrollContainer`")

        local isVertical = scrollDir == "VERTICAL" or scrollDir == "BOTH"
        local isHorizontal = scrollDir == "HORIZONTAL" or scrollDir == "BOTH"

        if frameType == "ScrollBar" then
            frame:SetVertical(isVertical)
        else
            frame:SetDirection(isVertical, isHorizontal)
        end
    end

    FrameProps["linkedScrollContainer"] = function(frame, targetFrame)
        targetFrame = ResolveFrameReference(targetFrame)
        assert(IsScrollContainerExtension(frame.uk_type) and targetFrame and IsScrollContainer(targetFrame.uk_type), "Invalid variable `linkedScrollContainer`: Must be called on `ScrollBar` or `ScrollContainerEdge` with a `ScrollContainer` or `LazyScrollContainer` target")
        frame.uk_prop_linkedScrollContainer = targetFrame
        frame:SetLinkedScrollContainer(targetFrame)
    end

    -- React
    FrameProps["scrollContainerContentWidth"] = function(frame, contentWidth)
        contentWidth = HandleReact(frame, contentWidth, "scrollContainerContentWidth")
        assert(IsScrollContainer(frame.uk_type), "Invalid variable `scrollContainerContentWidth`: Must be called on `ScrollContainer` or `LazyScrollContainer`")
        assert(type(contentWidth) == "number" or contentWidth == UIKit_Define.Percentage or contentWidth == UIKit_Define.Fit, "Invalid variable `scrollContainerContentWidth`: Must be of type `number`, `UIKit.Define.Percentage` or `UIKit.Define.Fit`")
        local contentFrame = frame:GetContentFrame()
        contentFrame.uk_prop_width = contentWidth
        if type(contentWidth) == "number" then contentFrame:SetWidth(contentWidth) end
    end

    -- React
    FrameProps["scrollContainerContentHeight"] = function(frame, contentHeight)
        contentHeight = HandleReact(frame, contentHeight, "scrollContainerContentHeight")
        assert(IsScrollContainer(frame.uk_type), "Invalid variable `scrollContainerContentHeight`: Must be called on `ScrollContainer` or `LazyScrollContainer`")
        assert(type(contentHeight) == "number" or contentHeight == UIKit_Define.Percentage or contentHeight == UIKit_Define.Fit, "Invalid variable `scrollContainerContentHeight`: Must be of type `number`, `UIKit.Define.Percentage` or `UIKit.Define.Fit`")
        local contentFrame = frame:GetContentFrame()
        contentFrame.uk_prop_height = contentHeight
        if type(contentHeight) == "number" then contentFrame:SetHeight(contentHeight) end
    end

    -- React
    FrameProps["scrollInterpolation"] = function(frame, interpolationValue)
        interpolationValue = HandleReact(frame, interpolationValue, "scrollInterpolation")
        assert(IsScrollContainer(frame.uk_type), "Invalid variable `scrollInterpolation`: Must be called on `ScrollContainer` or `LazyScrollContainer`")
        assert(type(interpolationValue) == "number", "Invalid variable `scrollInterpolation`: Must be a number")
        frame.uk_prop_scrollInterpolation = interpolationValue
        frame:SetSmoothScrolling((interpolationValue ~= nil), interpolationValue)
    end

    -- React
    FrameProps["scrollStepSize"] = function(frame, stepSizeValue)
        stepSizeValue = HandleReact(frame, stepSizeValue, "scrollStepSize")
        assert(IsScrollContainer(frame.uk_type), "Invalid variable `scrollStepSize`: Must be called on `ScrollContainer` or `LazyScrollContainer`")
        assert(type(stepSizeValue) == "number", "Invalid variable `scrollStepSize`: Must be a number")
        frame.uk_prop_scrollStepSize = stepSizeValue
        frame:SetStepSize(stepSizeValue)
    end

    FrameProps["scrollEdgeMin"] = function(frame, value)
        assert(frame.uk_type == "ScrollContainerEdge", "Invalid variable `scrollEdgeMin`: Must be called on `ScrollContainerEdge`")
        assert(type(value) == "number", "Invalid variable `scrollEdgeMin`: Must be a number")
        frame:SetScrollEdgeMin(value)
    end

    FrameProps["scrollEdgeMax"] = function(frame, value)
        assert(frame.uk_type == "ScrollContainerEdge", "Invalid variable `scrollEdgeMax`: Must be called on `ScrollContainerEdge`")
        assert(type(value) == "number", "Invalid variable `scrollEdgeMax`: Must be a number")
        frame:SetScrollEdgeMax(value)
    end

    FrameProps["scrollEdgeDirection"] = function(frame, direction)
        assert(frame.uk_type == "ScrollContainerEdge", "Invalid variable `scrollEdgeDirection`: Must be called on `ScrollContainerEdge`")
        assert(direction == UIKit_Enum.ScrollEdgeDirection.Leading or direction == UIKit_Enum.ScrollEdgeDirection.Trailing, "Invalid variable `scrollEdgeDirection`: Must be `Leading` or `Trailing`")
        frame:SetScrollEdgeDirection(direction)
    end

    FrameProps["scrollEdgeLinkedScrollContainer"] = function(frame, targetFrame)
        targetFrame = ResolveFrameReference(targetFrame)
        assert(frame.uk_type == "ScrollContainerEdge", "Invalid variable `scrollEdgeLinkedScrollContainer`: Must be called on `ScrollContainerEdge`")
        assert(targetFrame and IsScrollContainer(targetFrame.uk_type), "Invalid variable `scrollEdgeLinkedScrollContainer`: Target must be `ScrollContainer` or `LazyScrollContainer`")
        frame:SetLinkedScrollContainer(targetFrame)
    end
end

do -- Text
    -- React
    FrameProps["text"] = function(frame, textValue)
        textValue = HandleReact(frame, textValue, "text")
        assert(IsTextOrInput(frame.uk_type), "Invalid variable `text`: Must be called on `Text` or `Input`")
        assert(type(textValue) == "string", "Invalid variable `text`: Must be a string")
        frame:SetText(textValue)
    end

    -- React
    FrameProps["font"] = function(frame, fontPath)
        fontPath = HandleReact(frame, fontPath, "font")
        assert(IsTextOrInput(frame.uk_type), "Invalid variable `font`: Must be called on `Text` or `Input`")
        assert(type(fontPath) == "string", "Invalid variable `font`: Must be a string")
        frame:SetFont(fontPath)
    end

    -- React
    FrameProps["fontObject"] = function(frame, fontObj)
        fontObj = HandleReact(frame, fontObj, "fontObject")
        assert(IsTextOrInput(frame.uk_type), "Invalid variable `fontObject`: Must be called on `Text` or `Input`")
        assert(fontObj and fontObj.GetObjectType and fontObj:GetObjectType() == "Font", "Invalid variable `fontObject`: Must be a `Font`")
        frame:SetFontObject(fontObj)
    end

    -- React
    FrameProps["fontSize"] = function(frame, size)
        size = HandleReact(frame, size, "fontSize")
        assert(IsTextOrInput(frame.uk_type), "Invalid variable `fontSize`: Must be called on `Text` or `Input`")
        assert(type(size) == "number", "Invalid variable `fontSize`: Must be a number")
        frame:SetFontSize(size)
    end

    -- React
    FrameProps["fontFlags"] = function(frame, flags)
        flags = HandleReact(frame, flags, "fontFlags")
        assert(IsTextOrInput(frame.uk_type), "Invalid variable `fontFlags`: Must be called on `Text` or `Input`")
        assert(type(flags) == "string", "Invalid variable `fontFlags`: Must be a string")
        frame:SetFontFlags(flags)
    end

    -- React
    FrameProps["textJustifyH"] = function(frame, justifyH)
        justifyH = HandleReact(frame, justifyH, "justifyH")
        assert(IsTextOrInput(frame.uk_type), "Invalid variable `textJustifyH`: Must be called on `Text` or `Input`")
        assert(type(justifyH) == "string", "Invalid variable `textJustifyH`: Must be a string")
        frame:SetJustifyH(justifyH)
    end

    -- React
    FrameProps["textJustifyV"] = function(frame, justifyV)
        justifyV = HandleReact(frame, justifyV, "justifyV")
        assert(IsTextOrInput(frame.uk_type), "Invalid variable `textJustifyV`: Must be called on `Text` or `Input`")
        assert(type(justifyV) == "string", "Invalid variable `textJustifyV`: Must be a string")
        frame:SetJustifyV(justifyV)
    end

    FrameProps["textAlignment"] = function(frame, justifyH, justifyV)
        assert(IsTextOrInput(frame.uk_type), "Invalid variable `textAlignment`: Must be called on `Text` or `Input`")
        if justifyH then frame:textJustifyH(justifyH) end
        if justifyV then frame:textJustifyV(justifyV) end
    end

    -- React
    FrameProps["textVerticalSpacing"] = function(frame, spacingValue)
        spacingValue = HandleReact(frame, spacingValue, "textVerticalSpacing")
        assert(IsTextOrInput(frame.uk_type), "Invalid variable `textVerticalSpacing`: Must be called on `Text` or `Input`")
        assert(type(spacingValue) == "number", "Invalid variable `textVerticalSpacing`: Must be a number")
        frame:SetSpacing(spacingValue)
    end

    -- React
    FrameProps["textColor"] = function(frame, color)
        color = HandleReact(frame, color, "textColor")
        assert(IsTextOrInput(frame.uk_type), "Invalid variable `textColor`: Must be called on `Text` or `Input`")
        assert(IsColorDefine(color), "Invalid variable `textColor`: Must be a `Color_RGBA` or `Color_HEX`")
        local parsed = UIKit_Utils:ProcessColor(color)
        frame:SetTextColor(parsed.r, parsed.g, parsed.b, parsed.a)
    end

    -- React
    FrameProps["wordWrap"] = function(frame, wrapEnabled)
        wrapEnabled = HandleReact(frame, wrapEnabled, "wordWrap")
        assert(IsTextOrInput(frame.uk_type), "Invalid variable `wordWrap`: Must be called on `Text` or `Input`")
        assert(type(wrapEnabled) == "boolean", "Invalid variable `wordWrap`: Must be a boolean")
        frame:SetWordWrap(wrapEnabled)
    end

    -- React
    FrameProps["indentedWordWrap"] = function(frame, wrapEnabled)
        wrapEnabled = HandleReact(frame, wrapEnabled, "indentedWordWrap")
        assert(IsTextOrInput(frame.uk_type), "Invalid variable `indentedWordWrap`: Must be called on `Text` or `Input`")
        assert(type(wrapEnabled) == "boolean", "Invalid variable `indentedWordWrap`: Must be a boolean")
        frame:SetIndentedWordWrap(wrapEnabled)
    end

    -- React
    FrameProps["nonSpaceWordWrap"] = function(frame, wrapEnabled)
        wrapEnabled = HandleReact(frame, wrapEnabled, "nonSpaceWordWrap")
        assert(IsTextOrInput(frame.uk_type), "Invalid variable `nonSpaceWordWrap`: Must be called on `Text` or `Input`")
        assert(type(wrapEnabled) == "boolean", "Invalid variable `nonSpaceWordWrap`: Must be a boolean")
        frame:SetNonSpaceWrap(wrapEnabled)
    end

    -- React
    FrameProps["maxLines"] = function(frame, lineCount)
        lineCount = HandleReact(frame, lineCount, "maxLines")
        assert(IsTextOrInput(frame.uk_type), "Invalid variable `maxLines`: Must be called on `Text` or `Input`")
        assert(type(lineCount) == "number", "Invalid variable `maxLines`: Must be a number")
        frame:SetMaxLines(lineCount)
    end

    -- React
    FrameProps["shadowColor"] = function(frame, color)
        color = HandleReact(frame, color, "shadowColor")
        assert(IsTextOrInput(frame.uk_type), "Invalid variable `shadowColor`: Must be called on `Text` or `Input`")
        assert(IsColorDefine(color), "Invalid variable `shadowColor`: Must be a `Color_RGBA` or `Color_HEX`")
        local parsed = UIKit_Utils:ProcessColor(color)
        frame:SetShadowColor(parsed.r, parsed.g, parsed.b, parsed.a)
    end

    -- React
    FrameProps["textHeight"] = function(frame, heightValue)
        heightValue = HandleReact(frame, heightValue, "textHeight")
        assert(IsTextOrInput(frame.uk_type), "Invalid variable `textHeight`: Must be called on `Text` or `Input`")
        assert(type(heightValue) == "number", "Invalid variable `textHeight`: Must be a number")
        frame:SetTextHeight(heightValue)
    end

    -- React
    FrameProps["textRotation"] = function(frame, radians)
        radians = HandleReact(frame, radians, "textRotation")
        assert(IsTextOrInput(frame.uk_type), "Invalid variable `textRotation`: Must be called on `Text` or `Input`")
        assert(type(radians) == "number", "`textRotation` must be a number")
        frame:SetRotation(radians)
    end

    FrameProps["alphaGradient"] = function(frame, startPos, gradientLength)
        assert(IsTextOrInput(frame.uk_type), "Invalid variable `alphaGradient`: Must be called on `Text` or `Input`")
        assert(type(startPos) == "number", "Invalid variable `alphaGradient start`: Must be a number")
        assert(type(gradientLength) == "number", "Invalid variable `alphaGradient length`: Must be a number")
        frame:SetAlphaGradient(startPos, gradientLength)
    end

    FrameProps["shadowOffset"] = function(frame, offsetX, offsetY)
        assert(IsTextOrInput(frame.uk_type), "Invalid variable `shadowOffset`: Must be called on `Text` or `Input`")
        assert(type(offsetX) == "number", "Invalid variable `shadowOffset x`: Must be a number")
        assert(type(offsetY) == "number", "Invalid variable `shadowOffset y`: Must be a number")
        frame:SetShadowOffset(offsetX, offsetY)
    end

    -- React
    FrameProps["placeholder"] = function(frame, placeholderText)
        placeholderText = HandleReact(frame, placeholderText, "placeholder")
        assert(frame.uk_type == "Input", "Invalid variable `placeholder`: Must be called on `Input`")
        assert(type(placeholderText) == "string", "Invalid variable `placeholder`: Must be a string")
        frame:SetPlaceholder(placeholderText)
    end

    -- React
    FrameProps["inputCaretWidth"] = function(frame, caretWidth)
        caretWidth = HandleReact(frame, caretWidth, "inputCaretWidth")
        assert(frame.uk_type == "Input", "Invalid variable `inputCaretWidth`: Must be called on `Input`")
        assert(type(caretWidth) == "number", "Invalid variable `inputCaretWidth`: Must be a number")
        frame:SetCaretWidth(caretWidth)
    end

    -- React
    FrameProps["inputCaretOffsetX"] = function(frame, caretOffset)
        caretOffset = HandleReact(frame, caretOffset, "inputCaretOffsetX")
        assert(frame.uk_type == "Input", "Invalid variable `inputCaretOffsetX`: Must be called on `Input`")
        assert(type(caretOffset) == "number", "Invalid variable `inputCaretOffsetX`: Must be a number")
        frame:SetCaretOffsetX(caretOffset)
    end

    -- React
    FrameProps["inputMultiLine"] = function(frame, isMultiLine)
        isMultiLine = HandleReact(frame, isMultiLine, "inputMultiLine")
        assert(frame.uk_type == "Input", "Invalid variable `inputMultiLine`: Must be called on `Input`")
        assert(type(isMultiLine) == "boolean", "Invalid variable `inputMultiLine`: Must be a boolean")
        frame:SetMultiLine(isMultiLine)
    end

    -- React
    FrameProps["inputHighlightColor"] = function(frame, color)
        color = HandleReact(frame, color, "inputHighlightColor")
        assert(frame.uk_type == "Input", "Invalid variable `inputHighlightColor`: Must be called on `Input`")
        assert(IsColorDefine(color), "`inputHighlightColor` must be a `Color_RGBA` or `Color_HEX`")
        local parsed = UIKit_Utils:ProcessColor(color)
        frame:SetHighlightColor(parsed.r, parsed.g, parsed.b, parsed.a)
    end

    -- React
    FrameProps["inputPlaceholderTextColor"] = function(frame, color)
        color = HandleReact(frame, color, "inputPlaceholderTextColor")
        assert(frame.uk_type == "Input", "Invalid variable `inputPlaceholderTextColor`: Must be called on `Input`")
        assert(IsColorDefine(color), "Invalid variable `inputPlaceholderTextColor`: Must be a `Color_RGBA` or `Color_HEX`")
        local parsed = UIKit_Utils:ProcessColor(color)
        frame.__Placeholder:SetTextColor(parsed.r, parsed.g, parsed.b, parsed.a)
    end

    -- React
    FrameProps["inputPlaceholderFont"] = function(frame, fontPath)
        fontPath = HandleReact(frame, fontPath, "inputPlaceholderFont")
        assert(frame.uk_type == "Input", "Invalid variable `inputPlaceholderFont`: Must be called on `Input`")
        assert(type(fontPath) == "string", "Invalid variable `inputPlaceholderFont`: Must be a string")
        frame:SetPlaceholderFont(fontPath)
    end

    -- React
    FrameProps["inputPlaceholderFontSize"] = function(frame, fontSize)
        fontSize = HandleReact(frame, fontSize, "inputPlaceholderFontSize")
        assert(frame.uk_type == "Input", "Invalid variable `inputPlaceholderFontSize`: Must be called on `Input`")
        assert(type(fontSize) == "number", "Invalid variable `inputPlaceholderFontSize`: Must be a number")
        frame:SetPlaceholderFontSize(fontSize)
    end

    -- React
    FrameProps["inputPlaceholderFontFlags"] = function(frame, fontFlags)
        fontFlags = HandleReact(frame, fontFlags, "inputPlaceholderFontFlags")
        assert(frame.uk_type == "Input", "Invalid variable `inputPlaceholderFontFlags`: Must be called on `Input`")
        assert(type(fontFlags) == "string", "Invalid variable `inputPlaceholderFontFlags`: Must be a string")
        frame:SetPlaceholderFontFlags(fontFlags)
    end
end

do -- Linear Slider
    FrameProps["linearSliderOrientation"] = function(frame, sliderOrientation)
        sliderOrientation = HandleReact(frame, sliderOrientation, "linearSliderOrientation")
        assert(frame.uk_type == "LinearSlider", "Invalid variable `linearSliderOrientation`: Must be called on `LinearSlider`")
        assert(sliderOrientation == UIKit_Enum.Orientation.Horizontal or sliderOrientation == UIKit_Enum.Orientation.Vertical, "Invalid variable `linearSliderOrientation`: Must be `HORIZONTAL` or `VERTICAL`")
        frame:SetOrientation(sliderOrientation)
    end

    FrameProps["linearSliderThumbWidth"] = function(frame, thumbWidth)
        thumbWidth = HandleReact(frame, thumbWidth, "linearSliderThumbWidth")
        assert(frame.uk_type == "LinearSlider", "Invalid variable `linearSliderThumbWidth`: Must be called on `LinearSlider`")
        assert(thumbWidth and type(thumbWidth) == "number", "Invalid variable `linearSliderThumbWidth`: Must be a number")
        frame.__ThumbAnchor:SetWidth(thumbWidth)
    end

    FrameProps["linearSliderThumbHeight"] = function(frame, thumbHeight)
        thumbHeight = HandleReact(frame, thumbHeight, "linearSliderThumbHeight")
        assert(frame.uk_type == "LinearSlider", "Invalid variable `linearSliderThumbHeight`: Must be called on `LinearSlider`")
        assert(thumbHeight and type(thumbHeight) == "number", "Invalid variable `linearSliderThumbHeight`: Must be a number")
        frame.__ThumbAnchor:SetHeight(thumbHeight)
    end

    FrameProps["linearSliderThumbSize"] = function(frame, thumbWidth, thumbHeight)
        assert(frame.uk_type == "LinearSlider", "Invalid variable `linearSliderThumbSize`: Must be called on `LinearSlider`")
        assert(thumbWidth and type(thumbWidth) == "number", "Invalid variable `linearSliderThumbWidth`: Must be a number")
        assert(thumbHeight and type(thumbHeight) == "number", "Invalid variable `linearSliderThumbHeight`: Must be a number")
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

do -- HitRect
    FrameProps["onEnter"] = function(frame, callback)
        assert(frame.uk_type == "HitRect", "Invalid variable `onEnter`: Must be called on `HitRect`")
        frame:AddOnEnter(callback)
    end

    FrameProps["onLeave"] = function(frame, callback)
        assert(frame.uk_type == "HitRect", "Invalid variable `onLeave`: Must be called on `HitRect`")
        frame:AddOnLeave(callback)
    end

    FrameProps["onMouseDown"] = function(frame, callback)
        assert(frame.uk_type == "HitRect", "Invalid variable `onMouseDown`: Must be called on `HitRect`")
        frame:AddOnMouseDown(callback)
    end

    FrameProps["onMouseUp"] = function(frame, callback)
        assert(frame.uk_type == "HitRect", "Invalid variable `onMouseUp`: Must be called on `HitRect`")
        frame:AddOnMouseUp(callback)
    end
end

do -- Pooling
    local function IsPoolableView(frameType)
        return frameType == "List" or frameType == "LazyScrollContainer"
    end

    FrameProps["poolElementUpdate"] = function(frame, func)
        assert(IsPoolableView(frame.uk_type), "Invalid variable `poolElementUpdate`: Must be called on `List` or `LazyScrollContainer`")
        assert(type(func) == "function", "Invalid variable `func`: Must be a function")
        frame:SetOnElementUpdate(func)
    end

    FrameProps["poolElementVisibilityChanged"] = function(frame, func)
        assert(IsPoolableView(frame.uk_type), "Invalid variable `poolElementVisibilityChanged`: Must be called on `List` or `LazyScrollContainer`")
        assert(type(func) == "function", "Invalid variable `func`: Must be a function")
        frame:SetOnElementVisibilityChanged(func)
    end

    FrameProps["poolTemplate"] = function(frame, templateFunc)
        assert(IsPoolableView(frame.uk_type), "Invalid variable `poolTemplate`: Must be called on `List` or `LazyScrollContainer`")
        assert(type(templateFunc) == "function" or type(templateFunc) == "table", "Invalid variable `templateFunc`: Must be a function or a table")
        frame:SetTemplate(templateFunc)
    end

    FrameProps["lazyScrollContainerElementHeight"] = function(frame, elementHeight)
        assert(frame.uk_type == "LazyScrollContainer", "Invalid variable `lazyScrollContainerElementHeight`: Must be called on `LazyScrollContainer`")
        assert(type(elementHeight) == "number", "Invalid variable `lazyScrollContainerElementHeight`: Must be a number")
        frame:SetElementHeight(elementHeight)
    end
end
