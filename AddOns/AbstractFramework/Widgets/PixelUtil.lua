---@class AbstractFramework
local AF = _G.AbstractFramework

-- Interface\SharedXML\PixelUtil.lua
---------------------------------------------------------------------
-- pixel perfect
---------------------------------------------------------------------
function AF.GetPixelFactor()
    local physicalWidth, physicalHeight = GetPhysicalScreenSize()
    return 768.0 / physicalHeight
end

function AF.GetNearestPixelSize(uiUnitSize, layoutScale, minPixels)
    if uiUnitSize == 0 and (not minPixels or minPixels == 0) then
        return 0
    end

    local uiUnitFactor = AF.GetPixelFactor()
    local numPixels = AF.Round((uiUnitSize * layoutScale) / uiUnitFactor)
    if minPixels then
        if uiUnitSize < 0.0 then
            if numPixels > -minPixels then
                numPixels = -minPixels
            end
        else
            if numPixels < minPixels then
                numPixels = minPixels
            end
        end
    end

    return numPixels * uiUnitFactor / layoutScale
end

-- function AF.ConvertPixels(desiredPixels, layoutScale)
--     return AF.GetNearestPixelSize(desiredPixels, layoutScale)
-- end

function AF.ConvertPixels(desiredPixels)
    return AF.GetNearestPixelSize(desiredPixels, AF.UIParent:GetEffectiveScale())
end

function AF.ConvertPixelsForRegion(desiredPixels, region)
    return AF.GetNearestPixelSize(desiredPixels, region:GetEffectiveScale())
end

---------------------------------------------------------------------
-- 1 pixel
---------------------------------------------------------------------
function AF.GetOnePixelForRegion(region)
    return AF.GetNearestPixelSize(1, region:GetEffectiveScale())
end

---------------------------------------------------------------------
-- size
---------------------------------------------------------------------
function AF.SetWidth(region, width, minPixels)
    -- clear conflicts
    region._size_grid = nil
    region._size_list_h = nil
    -- add new
    region._width = width
    region._minwidth = minPixels
    region:SetWidth(AF.GetNearestPixelSize(width, region:GetEffectiveScale(), minPixels))
end

function AF.SetHeight(region, height, minPixels)
    -- clear conflicts
    region._size_grid = nil
    region._size_list_v = nil
    -- add new
    region._height = height
    region._minheight = minPixels
    region:SetHeight(AF.GetNearestPixelSize(height, region:GetEffectiveScale(), minPixels))
end

---@param region Frame
---@param itemNum number
---@param itemWidth number
---@param itemSpacing number
---@param leftPadding number|nil
---@param rightPadding number|nil
function AF.SetListWidth(region, itemNum, itemWidth, itemSpacing, leftPadding, rightPadding)
    -- clear conflicts
    region._size_grid = nil
    region._width = nil
    region._minwidth = nil

    -- add new
    region._size_list_h = true
    region._itemNumH = itemNum
    region._itemWidth = itemWidth
    region._itemSpacingX = itemSpacing

    leftPadding = leftPadding or 0
    rightPadding = rightPadding or 0
    region._leftPadding = leftPadding
    region._rightPadding = rightPadding

    if itemNum == 0 then
        region:SetWidth(0.001)
    else
        region:SetWidth(AF.GetNearestPixelSize(itemWidth, region:GetEffectiveScale()) * itemNum
            + AF.GetNearestPixelSize(itemSpacing, region:GetEffectiveScale()) * (itemNum - 1)
            + AF.GetNearestPixelSize(leftPadding, region:GetEffectiveScale())
            + AF.GetNearestPixelSize(rightPadding, region:GetEffectiveScale()))
    end
end

---@param region Frame
---@param itemNum number
---@param itemHeight number
---@param itemSpacing number
---@param topPadding number|nil
---@param bottomPadding number|nil
function AF.SetListHeight(region, itemNum, itemHeight, itemSpacing, topPadding, bottomPadding)
    -- clear conflicts
    region._size_grid = nil
    region._height = nil
    region._minheight = nil

    -- add new
    region._size_list_v = true
    region._itemNumV = itemNum
    region._itemHeight = itemHeight
    region._itemSpacingY = itemSpacing

    topPadding = topPadding or 0
    bottomPadding = bottomPadding or 0
    region._topPadding = topPadding
    region._bottomPadding = bottomPadding

    if itemNum == 0 then
        region:SetHeight(0.001)
    else
        region:SetHeight(AF.GetNearestPixelSize(itemHeight, region:GetEffectiveScale()) * itemNum
            + AF.GetNearestPixelSize(itemSpacing, region:GetEffectiveScale()) * (itemNum - 1)
            + AF.GetNearestPixelSize(topPadding, region:GetEffectiveScale())
            + AF.GetNearestPixelSize(bottomPadding, region:GetEffectiveScale()))
    end
end

---@param region Frame
---@param gridWidth number
---@param gridHeight number
---@param gridSpacingX number
---@param gridSpacingY number
---@param columns number
---@param rows number
---@param topPadding number|nil
---@param bottomPadding number|nil
---@param leftPadding number|nil
---@param rightPadding number|nil
function AF.SetGridSize(region, gridWidth, gridHeight, gridSpacingX, gridSpacingY, columns, rows, topPadding, bottomPadding, leftPadding, rightPadding)
    -- clear conflicts
    region._size_list_h = nil
    region._size_list_v = nil

    -- add new
    region._size_grid = true
    region._gridWidth = gridWidth
    region._gridHeight = gridHeight
    region._gridSpacingX = gridSpacingX
    region._gridSpacingY = gridSpacingY
    region._rows = rows
    region._columns = columns

    leftPadding = leftPadding or 0
    rightPadding = rightPadding or 0
    topPadding = topPadding or 0
    bottomPadding = bottomPadding or 0
    region._leftPadding = leftPadding
    region._rightPadding = rightPadding
    region._topPadding = topPadding
    region._bottomPadding = bottomPadding

    if columns == 0 then
        region:SetWidth(0.001)
    elseif gridWidth then
        region:SetWidth(AF.GetNearestPixelSize(gridWidth, region:GetEffectiveScale()) * columns
            + AF.GetNearestPixelSize(gridSpacingX, region:GetEffectiveScale()) * (columns - 1)
            + AF.GetNearestPixelSize(leftPadding, region:GetEffectiveScale())
            + AF.GetNearestPixelSize(rightPadding, region:GetEffectiveScale()))
    end

    if rows == 0 then
        region:SetHeight(0.001)
    elseif gridHeight then
        region:SetHeight(AF.GetNearestPixelSize(gridHeight, region:GetEffectiveScale()) * rows
            + AF.GetNearestPixelSize(gridSpacingY, region:GetEffectiveScale()) * (rows - 1)
            + AF.GetNearestPixelSize(topPadding, region:GetEffectiveScale())
            + AF.GetNearestPixelSize(bottomPadding, region:GetEffectiveScale()))
    end
end

function AF.SetSize(region, width, height)
    -- height = height or width
    if width then AF.SetWidth(region, width) end
    if height then AF.SetHeight(region, height) end
end

---------------------------------------------------------------------
-- point
---------------------------------------------------------------------

function AF.SetPoint(region, ...)
    if not region._points then region._points = {} end
    local point, relativeTo, relativePoint, offsetX, offsetY

    local n = select("#", ...)
    if n == 1 then
        point = ...
    elseif n == 2 then
        if type(select(2, ...)) == "number" then -- "TOPLEFT", 0
            point, offsetX = ...
        else -- "TOPLEFT", AF.UIParent
            point, relativeTo = ...
        end
    elseif n == 3 then
        if type(select(2, ...)) == "number" then -- "TOPLEFT", 0, 0
            point, offsetX, offsetY = ...
        else -- "TOPLEFT", AF.UIParent, "TOPRIGHT"
            point, relativeTo, relativePoint = ...
        end
    elseif n == 4 then
        point, relativeTo, offsetX, offsetY = ...
    else
        point, relativeTo, relativePoint, offsetX, offsetY = ...
    end

    offsetX = offsetX and offsetX or 0
    offsetY = offsetY and offsetY or 0

    local points = {point, relativeTo or region:GetParent(), relativePoint or point, offsetX, offsetY}
    region._points[point] = points

    if region._useOriginalPoints then
        region:SetPoint(points[1], points[2], points[3], points[4], points[5])
    else
        region:SetPoint(points[1], points[2], points[3], AF.GetNearestPixelSize(points[4], region:GetEffectiveScale()), AF.GetNearestPixelSize(points[5], region:GetEffectiveScale()))
    end
end

function AF.SetOnePixelInside(region, relativeTo)
    relativeTo = relativeTo or region:GetParent()
    AF.ClearPoints(region)
    AF.SetPoint(region, "TOPLEFT", relativeTo, "TOPLEFT", 1, -1)
    AF.SetPoint(region, "BOTTOMRIGHT", relativeTo, "BOTTOMRIGHT", -1, 1)
end

function AF.SetOnePixelOutside(region, relativeTo)
    relativeTo = relativeTo or region:GetParent()
    AF.ClearPoints(region)
    AF.SetPoint(region, "TOPLEFT", relativeTo, "TOPLEFT", -1, 1)
    AF.SetPoint(region, "BOTTOMRIGHT", relativeTo, "BOTTOMRIGHT", 1, -1)
end

function AF.SetAllPoints(region, relativeTo)
    AF.SetInside(region, relativeTo, 0)
end

---@param region Frame
---@param relativeTo Frame|nil if not provided, relativeTo = region:GetParent()
---@param offsetX number if not provided, offsetX = 0
---@param offsetY number|nil if not provided, offsetY = offsetX
function AF.SetInside(region, relativeTo, offsetX, offsetY)
    assert(offsetX, "SetInside: offsetX is nil")
    relativeTo = relativeTo or region:GetParent()
    offsetY = offsetY or offsetX
    AF.ClearPoints(region)
    AF.SetPoint(region, "TOPLEFT", relativeTo, "TOPLEFT", offsetX, -offsetY)
    AF.SetPoint(region, "BOTTOMRIGHT", relativeTo, "BOTTOMRIGHT", -offsetX, offsetY)
end

---@param region Frame
---@param relativeTo Frame|nil if not provided, relativeTo = region:GetParent()
---@param offsetX number if not provided, offsetX = 0
---@param offsetY number|nil if not provided, offsetY = offsetX
function AF.SetOutside(region, relativeTo, offsetX, offsetY)
    assert(offsetX, "SetOutside: offsetX is nil")
    relativeTo = relativeTo or region:GetParent()
    offsetY = offsetY or offsetX
    AF.ClearPoints(region)
    AF.SetPoint(region, "TOPLEFT", relativeTo, "TOPLEFT", -offsetX, offsetY)
    AF.SetPoint(region, "BOTTOMRIGHT", relativeTo, "BOTTOMRIGHT", offsetX, -offsetY)
end

---@param region Frame
---@param relativeTo Frame|nil default is region:GetParent()
---@param left? number
---@param right? number
---@param top? number
---@param bottom? number
-- if left/right/top/bottom is not provided, it will be set to 0
-- positive values expand outward, negative values contract inward
function AF.SetOutsets(region, relativeTo, left, right, top, bottom)
    left = left or 0
    right = right or 0
    top = top or 0
    bottom = bottom or 0
    relativeTo = relativeTo or region:GetParent()
    AF.ClearPoints(region)
    AF.SetPoint(region, "TOPLEFT", relativeTo, "TOPLEFT", -left, top)
    AF.SetPoint(region, "BOTTOMRIGHT", relativeTo, "BOTTOMRIGHT", right, -bottom)
end

function AF.ClearPoints(region)
    region:ClearAllPoints()
    if region._points then wipe(region._points) end
end

---------------------------------------------------------------------
-- backdrop
---------------------------------------------------------------------
function AF.SetBackdrop(region, backdropInfo)
    if backdropInfo.edgeSize then
        region._edge_size = backdropInfo.edgeSize
        backdropInfo.edgeSize = AF.ConvertPixelsForRegion(region._edge_size, region)
    end

    if backdropInfo.insets then
        region._insets = AF.Copy(backdropInfo.insets)
        for k, v in pairs(backdropInfo.insets) do
            backdropInfo.insets[k] = AF.ConvertPixelsForRegion(v, region)
        end
    end

    region:SetBackdrop(backdropInfo)
end

function AF.SetBackdropBorderSize(region, borderSize)
    if not region.GetBackdrop then return end
    local backdropInfo = region:GetBackdrop()
    if not backdropInfo then return end

    -- preserve color
    local r, g, b, a = region:GetBackdropColor()
    local br, bg, bb, ba = region:GetBackdropBorderColor()

    if borderSize then
        region._edge_size = borderSize
        backdropInfo.edgeSize = AF.ConvertPixelsForRegion(borderSize, region)
    else
        region._edge_size = nil
        backdropInfo.edgeSize = nil
    end

    region:SetBackdrop(backdropInfo)
    region:SetBackdropColor(r, g, b, a)
    region:SetBackdropBorderColor(br, bg, bb, ba)
end

---------------------------------------------------------------------
-- re-set
---------------------------------------------------------------------
function AF.ReSize(region)
    if region._size_grid then
        AF.SetGridSize(region, region._gridWidth, region._gridHeight, region._gridSpacingX, region._gridSpacingY, region._columns, region._rows,
            region._topPadding, region._bottomPadding, region._leftPadding, region._rightPadding)
    else
        if region._width then
            AF.SetWidth(region, region._width, region._minwidth)
        end
        if region._height then
            AF.SetHeight(region, region._height, region._minheight)
        end
        if region._size_list_h then
            AF.SetListWidth(region, region._itemNumH, region._itemWidth, region._itemSpacingX, region._leftPadding, region._rightPadding)
        end
        if region._size_list_v then
            AF.SetListHeight(region, region._itemNumV, region._itemHeight, region._itemSpacingY, region._topPadding, region._bottomPadding)
        end
    end
end

function AF.RePoint(region)
    if AF.IsEmpty(region._points) then return end
    region:ClearAllPoints()
    for _, t in pairs(region._points) do
        local x, y
        if region._useOriginalPoints then
            x = t[4]
            y = t[5]
        else
            x = AF.ConvertPixelsForRegion(t[4], region)
            y = AF.ConvertPixelsForRegion(t[5], region)
        end
        region:SetPoint(t[1], t[2], t[3], x, y)
    end
end

function AF.ReBorder(region)
    if not region.GetBackdrop then return end
    local backdropInfo = region:GetBackdrop()
    if not backdropInfo then return end

    if not (region._edge_size or region._insets) then return end

    local r, g, b, a = region:GetBackdropColor()
    local br, bg, bb, ba = region:GetBackdropBorderColor()

    if region._edge_size then
        backdropInfo.edgeSize = AF.ConvertPixelsForRegion(region._edge_size, region)
    end

    if region._insets then
        backdropInfo.insets = {}
        for k, v in pairs(region._insets) do
            backdropInfo.insets[k] = AF.ConvertPixelsForRegion(v, region)
        end
    end

    region:SetBackdrop(backdropInfo)
    region:SetBackdropColor(r, g, b, a)
    region:SetBackdropBorderColor(br, bg, bb, ba)
end

---------------------------------------------------------------------
-- pixel updater
---------------------------------------------------------------------
local function DefaultUpdatePixels(self)
    AF.ReSize(self)
    AF.RePoint(self)
    AF.ReBorder(self)
end
AF.DefaultUpdatePixels = DefaultUpdatePixels

local components = {}
AF.PIXEL_PERFECT_COMPONENTS = components
local addonComponents = {}
AF.PIXEL_PERFECT_ADDON_COMPONENTS = addonComponents

---@param fn function
function AF.AddToPixelUpdater(comp, fn)
    comp.UpdatePixels = fn or comp.UpdatePixels or DefaultUpdatePixels
    components[comp] = comp:GetName() or true
    -- addon
    local addon = AF.GetAddon()
    if addon then
        if not addonComponents[addon] then addonComponents[addon] = {} end
        addonComponents[addon][comp] = comp:GetName() or true
    end
end

function AF.RemoveFromPixelUpdater(r)
    components[r] = nil
    -- addon
    local addon = AF.GetAddon()
    if addon and addonComponents[addon] then
        addonComponents[addon][r] = nil
    end
end

function AF.UpdatePixels()
    local start = GetTimePreciseSec()
    AF.Fire("AF_PIXEL_UPDATE_START")
    for r in next, components do
        r:UpdatePixels()
    end
    AF.Fire("AF_PIXEL_UPDATE_END")
    AF.Debug(AF.WrapTextInColor("Pixel update took %.3f seconds", "yellow"):format(GetTimePreciseSec() - start))
end

-- not ideal
function AF.UpdatePixelsForAddon(addon)
    addon = addon or AF.GetAddon()
    if addon and addonComponents[addon] then
        for r in next, addonComponents[addon] do
            r:UpdatePixels()
        end
    end
end

-- some object types are not included in GetChildren(), such as Texture, FontString ...
---@param region Frame
function AF.UpdatePixelsForRegionAndChildren(region)
    if region and not region:IsForbidden() and region.GetChildren then
        -- print(region:GetObjectType())
        if region.UpdatePixels then
            region:UpdatePixels()
        else
            DefaultUpdatePixels(region)
        end

        for _, child in pairs({region:GetChildren()}) do
            AF.UpdatePixelsForRegionAndChildren(child)
        end
    end
end

---------------------------------------------------------------------
-- snap to pixel
---------------------------------------------------------------------
function AF.SnapRegionToPixel(region)
    if region:GetNumPoints() ~= 1 then return end
    local point, relativeTo, relativePoint, offsetX, offsetY = region:GetPoint()
    offsetX = AF.Round(offsetX)
    offsetY = AF.Round(offsetY)
    AF.ClearPoints(region)
    region:SetPoint(point, relativeTo, relativePoint, offsetX, offsetY)
end

---------------------------------------------------------------------
-- update text container size
---------------------------------------------------------------------
function AF.SetSizeToFitText(frame, fontString, padding)
    padding = padding or 0
    local width = ceil(fontString:GetStringWidth() + padding)
    local height = ceil(fontString:GetStringHeight() + padding)
    frame:SetSize(width, height)
end

---------------------------------------------------------------------
-- statusbar
---------------------------------------------------------------------
local ClampedPercentageBetween = ClampedPercentageBetween
function AF.SetStatusBarValue(statusBar, value)
    local width = statusBar:GetWidth()
    if width and width > 0.0 then
        local min, max = statusBar:GetMinMaxValues()
        local percent = ClampedPercentageBetween(value, min, max)
        if percent == 0.0 or percent == 1.0 then
            statusBar:SetValue(value)
        else
            local numPixels = AF.GetNearestPixelSize(statusBar:GetWidth() * percent, statusBar:GetEffectiveScale())
            local roundedValue = Lerp(min, max, numPixels / width)
            statusBar:SetValue(roundedValue)
        end
    else
        statusBar:SetValue(value)
    end
end

---------------------------------------------------------------------
-- load widget position
---------------------------------------------------------------------
function AF.LoadWidgetPosition(widget, pos, relativeTo)
    AF.ClearPoints(widget)
    AF.SetPoint(widget, pos[1], relativeTo or widget:GetParent(), pos[2], pos[3], pos[4])
end

---------------------------------------------------------------------
-- load text position
---------------------------------------------------------------------
function AF.LoadTextPosition(text, pos, relativeTo)
    if strfind(pos[1], "LEFT$") then
        text:SetJustifyH("LEFT")
    elseif strfind(pos[1], "RIGHT$") then
        text:SetJustifyH("RIGHT")
    else
        text:SetJustifyH("CENTER")
    end

    if strfind(pos[1], "^TOP") then
        text:SetJustifyV("TOP")
    elseif strfind(pos[1], "^BOTTOM") then
        text:SetJustifyV("BOTTOM")
    else
        text:SetJustifyV("MIDDLE")
    end

    -- NOTE: text positioning is a pain!
    text._useOriginalPoints = true
    AF.ClearPoints(text)
    AF.SetPoint(text, pos[1], relativeTo or text:GetParent(), pos[2], pos[3], pos[4])
end

---------------------------------------------------------------------
-- get anchor points
---------------------------------------------------------------------
---@return string point, string relativePoint, string newLineRelativePoint, number x, number y, number newLineX, number newLineY, string headerPoint
function AF.GetAnchorPoints_Simple(anchor, orientation, spacingX, spacingY)
    local point, relativePoint, newLineRelativePoint -- normal
    local x, y, newLineX, newLineY -- normal
    local headerPoint

    spacingY = spacingY or spacingX

    if orientation == "left_to_right" then
        if strfind(anchor, "^BOTTOM") then
            point = "BOTTOMLEFT"
            relativePoint = "BOTTOMRIGHT"
            newLineRelativePoint = "TOPLEFT"
            y = 0
            newLineY = spacingY
        else
            point = "TOPLEFT"
            relativePoint = "TOPRIGHT"
            newLineRelativePoint = "BOTTOMLEFT"
            y = 0
            newLineY = -spacingY
        end
        x = spacingX
        newLineX = 0
        headerPoint = "LEFT"

    elseif orientation == "right_to_left" then
        if strfind(anchor, "^BOTTOM") then
            point = "BOTTOMRIGHT"
            relativePoint = "BOTTOMLEFT"
            newLineRelativePoint = "TOPRIGHT"
            y = 0
            newLineY = spacingY
        else
            point = "TOPRIGHT"
            relativePoint = "TOPLEFT"
            newLineRelativePoint = "BOTTOMRIGHT"
            y = 0
            newLineY = -spacingY
        end
        x = -spacingX
        newLineX = 0
        headerPoint = "RIGHT"

    elseif orientation == "top_to_bottom" then
        if strfind(anchor, "RIGHT$") then
            point = "TOPRIGHT"
            relativePoint = "BOTTOMRIGHT"
            newLineRelativePoint = "TOPLEFT"
            x = 0
            newLineX = -spacingX
        else
            point = "TOPLEFT"
            relativePoint = "BOTTOMLEFT"
            newLineRelativePoint = "TOPRIGHT"
            x = 0
            newLineX = spacingX
        end
        y = -spacingY
        newLineY = 0
        headerPoint = "TOP"

    elseif orientation == "bottom_to_top" then
        if strfind(anchor, "RIGHT$") then
            point = "BOTTOMRIGHT"
            relativePoint = "TOPRIGHT"
            newLineRelativePoint = "BOTTOMLEFT"
            x = 0
            newLineX = -spacingX
        else
            point = "BOTTOMLEFT"
            relativePoint = "TOPLEFT"
            newLineRelativePoint = "BOTTOMRIGHT"
            x = 0
            newLineX = spacingX
        end
        y = spacingY
        newLineY = 0
        headerPoint = "BOTTOM"
    end

    return point, relativePoint, newLineRelativePoint, x, y, newLineX, newLineY, headerPoint
end

---@return string point, string relativePoint, string newLineRelativePoint, number x, number y, number newLineX, number newLineY
function AF.GetAnchorPoints_Complex(orientation, spacingX, spacingY)
    local point, relativePoint, newLineRelativePoint
    local x, y, newLineX, newLineY

    if orientation == "bottom_to_top_then_left" then
        point = "BOTTOMRIGHT"
        relativePoint = "TOPRIGHT"
        newLineRelativePoint = "BOTTOMLEFT"
        x = 0
        y = spacingY
        newLineX = -spacingX
        newLineY = 0
    elseif orientation == "bottom_to_top_then_right" then
        point = "BOTTOMLEFT"
        relativePoint = "TOPLEFT"
        newLineRelativePoint = "BOTTOMRIGHT"
        x = 0
        y = spacingY
        newLineX = spacingX
        newLineY = 0
    elseif orientation == "top_to_bottom_then_left" then
        point = "TOPRIGHT"
        relativePoint = "BOTTOMRIGHT"
        newLineRelativePoint = "TOPLEFT"
        x = 0
        y = -spacingY
        newLineX = -spacingX
        newLineY = 0
    elseif orientation == "top_to_bottom_then_right" then
        point = "TOPLEFT"
        relativePoint = "BOTTOMLEFT"
        newLineRelativePoint = "TOPRIGHT"
        x = 0
        y = -spacingY
        newLineX = spacingX
        newLineY = 0
    elseif orientation == "left_to_right_then_bottom" then
        point = "TOPLEFT"
        relativePoint = "TOPRIGHT"
        newLineRelativePoint = "BOTTOMLEFT"
        x = spacingX
        y = 0
        newLineX = 0
        newLineY = -spacingY
    elseif orientation == "left_to_right_then_top" then
        point = "BOTTOMLEFT"
        relativePoint = "BOTTOMRIGHT"
        newLineRelativePoint = "TOPLEFT"
        x = spacingX
        y = 0
        newLineX = 0
        newLineY = spacingY
    elseif orientation == "right_to_left_then_bottom" then
        point = "TOPRIGHT"
        relativePoint = "TOPLEFT"
        newLineRelativePoint = "BOTTOMRIGHT"
        x = -spacingX
        y = 0
        newLineX = 0
        newLineY = -spacingY
    elseif orientation == "right_to_left_then_top" then
        point = "BOTTOMRIGHT"
        relativePoint = "BOTTOMLEFT"
        newLineRelativePoint = "TOPRIGHT"
        x = -spacingX
        y = 0
        newLineX = 0
        newLineY = spacingY
    end

    return point, relativePoint, newLineRelativePoint, x, y, newLineX, newLineY
end

function AF.GetAnchorPoints_GroupHeader(orientation, spacingX, spacingY)
    local point, relativePoint, x, y -- normal
    local headerPoint, columnAnchorPoint, columnSpacing -- SecureGroupHeader

    if orientation == "bottom_to_top_then_left" then
        point = "BOTTOMRIGHT"
        relativePoint = "TOPRIGHT"
        x = 0
        y = spacingY
        columnSpacing = -spacingX
        headerPoint = "BOTTOM"
        columnAnchorPoint = "RIGHT"
    elseif orientation == "bottom_to_top_then_right" then
        point = "BOTTOMLEFT"
        relativePoint = "TOPLEFT"
        x = 0
        y = spacingY
        columnSpacing = spacingX
        headerPoint = "BOTTOM"
        columnAnchorPoint = "LEFT"
    elseif orientation == "top_to_bottom_then_left" then
        point = "TOPRIGHT"
        relativePoint = "BOTTOMRIGHT"
        x = 0
        y = -spacingY
        columnSpacing = -spacingX
        headerPoint = "TOP"
        columnAnchorPoint = "RIGHT"
    elseif orientation == "top_to_bottom_then_right" then
        point = "TOPLEFT"
        relativePoint = "BOTTOMLEFT"
        x = 0
        y = -spacingY
        columnSpacing = spacingX
        headerPoint = "TOP"
        columnAnchorPoint = "LEFT"
    elseif orientation == "left_to_right_then_bottom" then
        point = "TOPLEFT"
        relativePoint = "TOPRIGHT"
        x = spacingX
        y = 0
        columnSpacing = -spacingY
        headerPoint = "LEFT"
        columnAnchorPoint = "TOP"
    elseif orientation == "left_to_right_then_top" then
        point = "BOTTOMLEFT"
        relativePoint = "BOTTOMRIGHT"
        x = spacingX
        y = 0
        columnSpacing = spacingY
        headerPoint = "LEFT"
        columnAnchorPoint = "BOTTOM"
    elseif orientation == "right_to_left_then_bottom" then
        point = "TOPRIGHT"
        relativePoint = "TOPLEFT"
        x = -spacingX
        y = 0
        columnSpacing = -spacingY
        headerPoint = "RIGHT"
        columnAnchorPoint = "TOP"
    elseif orientation == "right_to_left_then_top" then
        point = "BOTTOMRIGHT"
        relativePoint = "BOTTOMLEFT"
        x = -spacingX
        y = 0
        columnSpacing = spacingY
        headerPoint = "RIGHT"
        columnAnchorPoint = "BOTTOM"
    end
    return point, relativePoint, x, y, columnSpacing, headerPoint, columnAnchorPoint
end

---------------------------------------------------------------------
-- load position
---------------------------------------------------------------------
---@param pos table|string {point, x, y} or "point,x,y"
function AF.LoadPosition(region, pos)
    region._useOriginalPoints = true
    AF.ClearPoints(region)
    if type(pos) == "string" then
        pos = string.gsub(pos, " ", "")
        local point, x, y = strsplit(",", pos)
        x = tonumber(x)
        y = tonumber(y)
        AF.SetPoint(region, point, x, y)
    elseif type(pos) == "table" then
        AF.SetPoint(region, unpack(pos))
    end
end

---------------------------------------------------------------------
-- save position
---------------------------------------------------------------------
function AF.SavePositionAsTable(region, t)
    if t then
        wipe(t)
        t[1], t[2], t[3], t[4], t[5] = region:GetPoint()
    else
        return {region:GetPoint()}
    end
end

-- function AF.SavePositionAsString(region, t, i)
--     t[i] = table.concat({region:GetPoint()}, ",")
-- end

---------------------------------------------------------------------
-- pixel perfect (ElvUI)
---------------------------------------------------------------------
local function CheckPixelSnap(region, snap)
    if region and not region:IsForbidden() and region.PixelSnapDisabled and snap then
        region.PixelSnapDisabled = nil
    end
end

local function DisablePixelSnap(region)
    if region and not region:IsForbidden() and not region.PixelSnapDisabled then
        if region.SetSnapToPixelGrid then
            region:SetSnapToPixelGrid(false)
            region:SetTexelSnappingBias(0)
        elseif region.GetStatusBarTexture then
            local texture = region:GetStatusBarTexture()
            if type(texture) == "table" and texture.SetSnapToPixelGrid then
                texture:SetSnapToPixelGrid(false)
                texture:SetTexelSnappingBias(0)
            end
        end
        region.PixelSnapDisabled = true
    end
end

local function UpdateMetatable(obj)
    local t = getmetatable(obj).__index

    if not t.DisabledPixelSnap then
        if t.SetSnapToPixelGrid then hooksecurefunc(t, "SetSnapToPixelGrid", CheckPixelSnap) end
        if t.SetStatusBarTexture then hooksecurefunc(t, "SetStatusBarTexture", DisablePixelSnap) end
        if t.SetColorTexture then hooksecurefunc(t, "SetColorTexture", DisablePixelSnap) end
        if t.SetVertexColor then hooksecurefunc(t, "SetVertexColor", DisablePixelSnap) end
        if t.SetTexCoord then hooksecurefunc(t, "SetTexCoord", DisablePixelSnap) end
        if t.SetTexture then hooksecurefunc(t, "SetTexture", DisablePixelSnap) end
        -- if t.CreateTexture then hooksecurefunc(t, "CreateTexture", DisablePixelSnap) end

        t.DisabledPixelSnap = true
    end
end

local obj = CreateFrame("Frame")
-- UpdateMetatable(obj)
UpdateMetatable(CreateFrame("StatusBar"))
UpdateMetatable(obj:CreateTexture())
UpdateMetatable(obj:CreateMaskTexture())

-- local handled = {
--     Frame = true,
--     Texture = true,
--     MaskTexture = true,
-- }
-- obj = EnumerateFrames()
-- while obj do
--     local objType = obj:GetObjectType()
--     if not obj:IsForbidden() and not handled[objType] then
--         UpdateMetatable(obj)
--         handled[objType] = true
--     end
--     obj = EnumerateFrames(obj)
-- end