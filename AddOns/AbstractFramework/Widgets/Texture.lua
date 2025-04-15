---@class AbstractFramework
local AF = _G.AbstractFramework

---------------------------------------------------------------------
-- texture
---------------------------------------------------------------------
---@class AF_Texture:Texture
local AF_TextureMixin = {}

function AF_TextureMixin:SetColor(color)
    if type(color) == "string" then color = AF.GetColorTable(color) end
    color = color or {1, 1, 1, 1}
    if self._hasTexture then
        self:SetVertexColor(unpack(color))
    else
        self:SetColorTexture(unpack(color))
    end
end

---@param color table|string
---@return AF_TextureMixin tex
function AF.CreateTexture(parent, texture, color, drawLayer, subLevel, wrapModeHorizontal, wrapModeVertical, filterMode)
    local tex = parent:CreateTexture(nil, drawLayer or "ARTWORK", nil, subLevel)
    Mixin(tex, AF_TextureMixin)

    if texture then
        tex._hasTexture = true
        tex:SetTexture(texture, wrapModeHorizontal, wrapModeVertical, filterMode)
    end

    tex:SetColor(color)

    AF.AddToPixelUpdater(tex)

    return tex
end

---------------------------------------------------------------------
-- calc texcoord
---------------------------------------------------------------------

---calculates texture coordinates with adjustments for aspect ratio and cropping
---@param crop? number cropping percentage
---@param targetAspectRatio? number target aspect ratio (targetWidth / targetHeight), defaults to 1
---@param originalAspectRatio? number original texture aspect ratio (width/height), defaults to 1
---@return table coordinates {ULx, ULy, LLx, LLy, URx, URy, LRx, LRy}
function AF.CalcTexCoordPreCrop(crop, targetAspectRatio, originalAspectRatio)
    crop = crop or 0

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

    for i, coord in ipairs(texCoord) do
        local ratio = (i % 2 == 1) and xRatio or yRatio
        texCoord[i] = (coord - 0.5) * ratio + 0.5
    end

    return texCoord
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
---@param orientation string "HORIZONTAL"|"VERTICAL".
---@param color1 table|string
---@param color2 table|string
---@return Texture tex
function AF.CreateGradientTexture(parent, orientation, color1, color2, texture, drawLayer, subLevel)
    texture = texture or AF.GetPlainTexture()
    if type(color1) == "string" then color1 = AF.GetColorTable(color1) end
    if type(color2) == "string" then color2 = AF.GetColorTable(color2) end
    color1 = color1 or {0, 0, 0, 0}
    color2 = color2 or {0, 0, 0, 0}

    local tex = parent:CreateTexture(nil, drawLayer or "ARTWORK", nil, subLevel)
    tex:SetTexture(texture)
    tex:SetGradient(orientation, CreateColor(unpack(color1)), CreateColor(unpack(color2)))

    AF.AddToPixelUpdater(tex)

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
    color = color or AF.GetColorTable("accent")

    local separator = parent:CreateTexture(nil, "ARTWORK", nil, 0)
    separator:SetColorTexture(unpack(color))
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
    end

    AF.AddToPixelUpdater(separator, Separator_UpdatePixels)

    return separator
end