---@class AbstractFramework
local AF = _G.AbstractFramework

---------------------------------------------------------------------
-- texture
---------------------------------------------------------------------
---@class AF_Texture:Texture
local AF_TextureMixin = {}

---@param color table|string
function AF_TextureMixin:SetColor(color)
    if type(color) == "string" then color = AF.GetColorTable(color) end
    color = color or {1, 1, 1, 1}
    if self:GetTexture() or self:GetAtlas() then
        self:SetVertexColor(AF.UnpackColor(color))
    else
        self:SetColorTexture(AF.UnpackColor(color))
    end
end

---@param texture string|number texture path/fileID or atlas
-- - For path/fileID, "..." are wrapModeHorizontal, wrapModeVertical, filterMode
-- - For atlas, "..." are useAtlasSize, filterMode, resetTexCoords
function AF_TextureMixin:SetTextureOrAtlas(texture, ...)
    if type(texture) == "string" and not texture:find("[/\\]") then
        self:SetAtlas(texture, ...)
    else
        self:SetTexture(texture, ...)
    end
end

---@param parent Frame
---@param texture? string
---@param color? table|string
---@param drawLayer? string default "ARTWORK"
---@param subLevel? number
---@param wrapModeHorizontal? string
---@param wrapModeVertical? string
---@param filterMode? string
---@return AF_Texture tex
function AF.CreateTexture(parent, texture, color, drawLayer, subLevel, wrapModeHorizontal, wrapModeVertical, filterMode)
    local tex = parent:CreateTexture(nil, drawLayer or "ARTWORK", nil, subLevel)
    Mixin(tex, AF_TextureMixin)

    if texture and texture ~= "" then
        if type(texture) == "string" and not texture:find("[/\\]") then
            tex:SetAtlas(texture, nil, filterMode)
        else
            tex:SetTexture(texture, wrapModeHorizontal, wrapModeVertical, filterMode)
        end
    end

    if color then
        tex:SetColor(color)
    end

    AF.AddToPixelUpdater_OnShow(tex)

    return tex
end

---------------------------------------------------------------------
-- default texcoord for blizzard icons
---------------------------------------------------------------------
---@return number left 0.08
---@return number right 0.92
---@return number top 0.08
---@return number bottom 0.92
function AF.GetDefaultTexCoord()
    return 0.08, 0.92, 0.08, 0.92
end

--- 0.08, 0.92, 0.08, 0.92
---@param tex Texture
function AF.ApplyDefaultTexCoord(tex)
    tex:SetTexCoord(AF.GetDefaultTexCoord())
end

---@param tex Texture
function AF.ClearTexCoord(tex)
    tex:SetTexCoord(0, 1, 0, 1)
end

---------------------------------------------------------------------
-- calc texcoord
---------------------------------------------------------------------
---calculates texture coordinates with adjustments for aspect ratio and cropping
---@param crop? number cropping percentage
---@param targetAspectRatio? number target aspect ratio (targetWidth / targetHeight), defaults to 1
---@param originalAspectRatio? number original texture aspect ratio (width/height), defaults to 1
---@return table coordinates {ULx, ULy, LLx, LLy, URx, URy, LRx, LRy}
function AF.CalcTexCoordPreCrop(crop, targetAspectRatio, originalAspectRatio, anchor, unpack)
    crop = crop or 0
    anchor = anchor and anchor:upper() or "CENTER"

    -- apply cropping to initial texCoord
    local texCoord = {
        crop, crop,          -- ULx, ULy
        crop, 1 - crop,      -- LLx, LLy
        1 - crop, crop,      -- URx, URy
        1 - crop, 1 - crop   -- LRx, LRy
    }

    targetAspectRatio = targetAspectRatio or 1
    if originalAspectRatio then
        targetAspectRatio = targetAspectRatio / originalAspectRatio
    else
        -- in most cases, the original aspect ratio is 1
    end

    local xRatio = targetAspectRatio < 1 and targetAspectRatio or 1
    local yRatio = targetAspectRatio > 1 and 1 / targetAspectRatio or 1

    local anchorX, anchorY
    if anchor == "CENTER" then
        anchorX, anchorY = 0.5, 0.5
    elseif anchor == "TOPLEFT" then
        anchorX, anchorY = crop, crop
    elseif anchor == "TOP" then
        anchorX, anchorY = 0.5, crop
    elseif anchor == "TOPRIGHT" then
        anchorX, anchorY = 1 - crop, crop
    elseif anchor == "LEFT" then
        anchorX, anchorY = crop, 0.5
    elseif anchor == "RIGHT" then
        anchorX, anchorY = 1 - crop, 0.5
    elseif anchor == "BOTTOMLEFT" then
        anchorX, anchorY = crop, 1 - crop
    elseif anchor == "BOTTOM" then
        anchorX, anchorY = 0.5, 1 - crop
    elseif anchor == "BOTTOMRIGHT" then
        anchorX, anchorY = 1 - crop, 1 - crop
    end

    for i, coord in next, texCoord do
        local ratio = (i % 2 == 1) and xRatio or yRatio
        local anchorPoint = (i % 2 == 1) and anchorX or anchorY
        texCoord[i] = (coord - anchorPoint) * ratio + anchorPoint
    end

    if unpack then
        return AF.Unpack8(texCoord)
    else
        return texCoord
    end
end

---ccalculates scaling factor to fit a texture to target size while preserving aspect ratio
---@param originalWidth number
---@param originalHeight number
---@param targetWidth number
---@param targetHeight number
---@param crop number crop amount (0-0.5) from each edge
---@return number scale that ensures texture fills at least one dimension
function AF.CalcScale(originalWidth, originalHeight, targetWidth, targetHeight, crop)
    local effectiveWidth = originalWidth * (1 - 2 * crop)
    local effectiveHeight = originalHeight * (1 - 2 * crop)

    local wScale = targetWidth / effectiveWidth
    local hScale = targetHeight / effectiveHeight

    return math.max(wScale, hScale)
end

---------------------------------------------------------------------
-- gradient texture
---------------------------------------------------------------------
---@param orientation "HORIZONTAL"|"VERTICAL"
---@param color1 table|string
---@param color2 table|string
---@return Texture tex
function AF.CreateGradientTexture(parent, orientation, color1, color2, texture, drawLayer, subLevel, filterMode)
    texture = texture or AF.GetPlainTexture()
    if type(color1) == "string" then color1 = AF.GetColorTable(color1) end
    if type(color2) == "string" then color2 = AF.GetColorTable(color2) end
    color1 = color1 or {0, 0, 0, 0}
    color2 = color2 or {0, 0, 0, 0}

    local tex = parent:CreateTexture(nil, drawLayer or "ARTWORK", nil, subLevel)
    tex:SetTexture(texture, nil, nil, filterMode)
    tex:SetGradient(orientation:upper(), CreateColor(unpack(color1)), CreateColor(unpack(color2)))

    AF.AddToPixelUpdater_OnShow(tex)

    return tex
end

---------------------------------------------------------------------
-- line
---------------------------------------------------------------------
local function Separator_UpdatePixels(self)
    AF.ReSize(self)
    AF.RePoint(self)
    if self.shadow then
        AF.ReSize(self.shadow)
        AF.RePoint(self.shadow)
    end
end

---@param parent Frame
---@param size number|nil
---@param thickness number
---@param color table|string
---@param isVertical? boolean
---@param noShadow? boolean
---@return Texture separator
function AF.CreateSeparator(parent, size, thickness, color, isVertical, noShadow)
    if type(color) == "string" then color = AF.GetColorTable(color) end
    color = color or AF.GetAddonAccentColorTable()

    local separator = parent:CreateTexture(nil, "ARTWORK", nil, 0)
    separator:SetColorTexture(AF.UnpackColor(color))
    if isVertical then
        AF.SetSize(separator, thickness, size)
    else
        AF.SetSize(separator, size, thickness)
    end

    if not noShadow then
        local shadow = parent:CreateTexture(nil, "ARTWORK", nil, -1)
        separator.shadow = shadow
        shadow:SetColorTexture(AF.GetColorRGB("black", color[4])) -- use line alpha
        if isVertical then
            AF.SetWidth(shadow, thickness)
            AF.SetPoint(shadow, "TOPLEFT", separator, "TOPRIGHT", 0, -thickness)
            AF.SetPoint(shadow, "BOTTOMLEFT", separator, "BOTTOMRIGHT", 0, -thickness)
        else
            AF.SetHeight(shadow, thickness)
            AF.SetPoint(shadow, "TOPLEFT", separator, "BOTTOMLEFT", thickness, 0)
            AF.SetPoint(shadow, "TOPRIGHT", separator, "BOTTOMRIGHT", thickness, 0)
        end

        hooksecurefunc(separator, "Show", function()
            shadow:Show()
        end)
        hooksecurefunc(separator, "Hide", function()
            shadow:Hide()
        end)
        hooksecurefunc(separator, "SetShown", function(_, shown)
            shadow:SetShown(shown)
        end)
    end

    AF.AddToPixelUpdater_OnShow(separator, nil, Separator_UpdatePixels)

    return separator
end

---------------------------------------------------------------------
-- icon with background
---------------------------------------------------------------------
---@class AF_Icon:Frame,AF_BaseWidgetMixin
local AF_IconMixin = {}

---@param color string|table
function AF_IconMixin:SetBackgroundColor(color)
    if type(color) == "string" then color = AF.GetColorTable(color) end
    color = color or {0, 0, 0, 1}
    self.bg:SetColorTexture(AF.UnpackColor(color))
end

---@param icon string texture path or atlas
---@param isAtlas boolean
function AF_IconMixin:SetIcon(icon, isAtlas)
    if isAtlas then
        self.icon:SetAtlas(icon)
    else
        self.icon:SetTexture(icon)
    end
end

function AF_IconMixin:SetIconTexCoord(left, right, top, bottom)
    self.icon:SetTexCoord(left, right, top, bottom)
end

function AF_IconMixin:UpdatePixels()
    AF.ReSize(self)
    AF.RePoint(self)
    AF.RePoint(self.icon)
end

---@param parent Frame
---@param icon string|nil texture path or atlas
---@param size number|nil default is 16
---@param bgColor string|table|nil background color, defaults to "black"
---@return AF_Icon
function AF.CreateIcon(parent, icon, size, bgColor)
    local frame = CreateFrame("Frame", nil, parent)
    AF.SetSize(frame, size or 16, size or 16)

    Mixin(frame, AF_IconMixin)
    Mixin(frame, AF_BaseWidgetMixin)

    frame.icon = frame:CreateTexture(nil, "ARTWORK")
    AF.ApplyDefaultTexCoord(frame.icon)
    AF.SetOnePixelInside(frame.icon, frame)
    frame:SetIcon(icon or AF.GetIcon("QuestionMark"), (icon and not icon:find("[/\\]") and true or false))

    frame.bg = frame:CreateTexture(nil, "BORDER")
    frame.bg:SetAllPoints(frame)
    frame:SetBackgroundColor(bgColor)

    AF.AddToPixelUpdater_OnShow(frame)

    return frame
end