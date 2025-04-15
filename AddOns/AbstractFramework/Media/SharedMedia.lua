---@class AbstractFramework
local AF = _G.AbstractFramework
local LSM = AF.Libs.LSM

---------------------------------------------------------------------
-- register media
---------------------------------------------------------------------
LSM:Register("font", "Visitor", AF.GetFont("Visitor"), 255)
LSM:Register("font", "Emblem", AF.GetFont("Emblem"), 255)
LSM:Register("font", "Expressway", AF.GetFont("Expressway"), 255)

---------------------------------------------------------------------
-- functions
---------------------------------------------------------------------
local DEFAULT_BAR_TEXTURE = AF.GetPlainTexture()
local DEFAULT_FONT = GameFontNormal:GetFont()

function AF.LSM_GetBarTexture(name)
    if LSM:IsValid("statusbar", name) then
        return LSM:Fetch("statusbar", name)
    end
    return DEFAULT_BAR_TEXTURE
end

function AF.LSM_GetFont(name)
    if LSM:IsValid("font", name) then
        return LSM:Fetch("font", name)
    end
    return DEFAULT_FONT
end

---@param fs FontString|EditBox
function AF.SetFont(fs, font, size, outline, shadow)
    if type(font) == "table" then
        font, size, outline, shadow = unpack(font)
    end

    font = AF.LSM_GetFont(font)

    local flags
    if outline == "none" then
        flags = ""
    elseif outline == "outline" then
        flags = "OUTLINE"
    elseif outline == "monochrome_outline" then
        flags = "OUTLINE,MONOCHROME"
    elseif outline == "monochrome" then
        flags = "MONOCHROME"
    end

    fs:SetFont(font, size, flags)

    if shadow then
        fs:SetShadowOffset(1, -1)
        fs:SetShadowColor(0, 0, 0, 1)
    else
        fs:SetShadowOffset(0, 0)
        fs:SetShadowColor(0, 0, 0, 0)
    end
end