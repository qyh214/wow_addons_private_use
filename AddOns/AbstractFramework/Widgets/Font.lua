---@class AbstractFramework
local AF = _G.AbstractFramework

---------------------------------------------------------------------
-- fonts
---------------------------------------------------------------------
local FONT_TITLE_NAME = "AF_FONT_TITLE"
local FONT_NORMAL_NAME = "AF_FONT_NORMAL"
local FONT_CHAT_NAME = "AF_FONT_CHAT"
local FONT_OUTLINE_NAME = "AF_FONT_OUTLINE"
local FONT_SMALL_NAME = "AF_FONT_SMALL"
local FONT_CHINESE_NAME = "AF_FONT_CHINESE"
local FONT_TOOLTIP_HEADER_NAME = "AF_FONT_TOOLTIP_HEADER"
local FONT_TOOLTIP_NAME = "AF_FONT_TOOLTIP"

local FONT_TITLE_SIZE = 14
local FONT_NORMAL_SIZE = 13
local FONT_CHAT_SIZE = 13
local FONT_OUTLINE_SIZE = 13
local FONT_SMALL_SIZE = 11
local FONT_CHINESE_SIZE = 14
local FONT_TOOLTIP_HEADER_SIZE = 14
local FONT_TOOLTIP_SIZE = 13

local BASE_FONT_NORMAL = GameFontNormal:GetFont()
local BASE_FONT_CHAT = ChatFontNormal:GetFont()
local BASE_FONT_TOOLTIP = GameTooltipText:GetFont()

local font_title = CreateFont(FONT_TITLE_NAME)
font_title:SetFont(BASE_FONT_NORMAL, FONT_TITLE_SIZE, "")
font_title:SetTextColor(1, 1, 1, 1)
font_title:SetShadowColor(0, 0, 0)
font_title:SetShadowOffset(1, -1)
font_title:SetJustifyH("CENTER")

local font_normal = CreateFont(FONT_NORMAL_NAME)
font_normal:SetFont(BASE_FONT_NORMAL, FONT_NORMAL_SIZE, "")
font_normal:SetTextColor(1, 1, 1, 1)
font_normal:SetShadowColor(0, 0, 0)
font_normal:SetShadowOffset(1, -1)
font_normal:SetJustifyH("CENTER")

local font_chat = CreateFont(FONT_CHAT_NAME)
font_chat:SetFont(BASE_FONT_CHAT, FONT_CHAT_SIZE, "")
font_chat:SetTextColor(1, 1, 1, 1)
font_chat:SetShadowColor(0, 0, 0)
font_chat:SetShadowOffset(1, -1)
font_chat:SetJustifyH("CENTER")

local font_outline = CreateFont(FONT_OUTLINE_NAME)
font_outline:SetFont(BASE_FONT_NORMAL, FONT_OUTLINE_SIZE, "OUTLINE")
font_outline:SetTextColor(1, 1, 1, 1)
font_outline:SetShadowColor(0, 0, 0)
font_outline:SetShadowOffset(0, 0)
font_outline:SetJustifyH("CENTER")

local font_small = CreateFont(FONT_SMALL_NAME)
font_small:SetFont(BASE_FONT_NORMAL, FONT_SMALL_SIZE, "")
font_small:SetTextColor(1, 1, 1, 1)
font_small:SetShadowColor(0, 0, 0)
font_small:SetShadowOffset(1, -1)
font_small:SetJustifyH("CENTER")

local font_chinese = CreateFont(FONT_CHINESE_NAME)
font_chinese:SetFont(UNIT_NAME_FONT_CHINESE, FONT_CHINESE_SIZE, "")
font_chinese:SetTextColor(1, 1, 1, 1)
font_chinese:SetShadowColor(0, 0, 0)
font_chinese:SetShadowOffset(1, -1)
font_chinese:SetJustifyH("CENTER")

local font_tooltip_header = CreateFont(FONT_TOOLTIP_HEADER_NAME)
font_tooltip_header:SetFont(BASE_FONT_TOOLTIP, FONT_TOOLTIP_HEADER_SIZE, "")
font_tooltip_header:SetTextColor(1, 1, 1, 1)
font_tooltip_header:SetShadowColor(0, 0, 0)
font_tooltip_header:SetShadowOffset(1, -1)
font_tooltip_header:SetJustifyH("LEFT")

local font_tooltip = CreateFont(FONT_TOOLTIP_NAME)
font_tooltip:SetFont(BASE_FONT_TOOLTIP, FONT_TOOLTIP_SIZE, "")
font_tooltip:SetTextColor(1, 1, 1, 1)
font_tooltip:SetShadowColor(0, 0, 0)
font_tooltip:SetShadowOffset(1, -1)
font_tooltip:SetJustifyH("LEFT")

---------------------------------------------------------------------
-- update base font
---------------------------------------------------------------------
---@param font string|nil font file path, set nil to use default font
function AF.UpdateBaseFont(font)
    BASE_FONT_NORMAL = font or GameFontNormal:GetFont()
    BASE_FONT_CHAT = font or ChatFontNormal:GetFont()
    BASE_FONT_TOOLTIP = font or GameTooltipText:GetFont()

    font_title:SetFont(BASE_FONT_NORMAL, AF.fontSizeDelta + FONT_TITLE_SIZE, "")
    font_normal:SetFont(BASE_FONT_NORMAL, AF.fontSizeDelta + FONT_NORMAL_SIZE, "")
    font_chat:SetFont(BASE_FONT_CHAT, AF.fontSizeDelta + FONT_CHAT_SIZE, "")
    font_outline:SetFont(BASE_FONT_NORMAL, AF.fontSizeDelta + FONT_OUTLINE_SIZE, "OUTLINE")
    font_small:SetFont(BASE_FONT_NORMAL, AF.fontSizeDelta + FONT_SMALL_SIZE, "")
    font_tooltip_header:SetFont(BASE_FONT_TOOLTIP, AF.fontSizeDelta + FONT_TOOLTIP_HEADER_SIZE, "")
    font_tooltip:SetFont(BASE_FONT_TOOLTIP, AF.fontSizeDelta + FONT_TOOLTIP_SIZE, "")
end

---------------------------------------------------------------------
-- update font size
---------------------------------------------------------------------
local fontObjects = {}

---@param fontObj Font|FontString
---@param originalSize number defaults to the current font size of the fontObj
function AF.AddToFontSizeUpdater(fontObj, originalSize)
    originalSize = originalSize or select(2, fontObj:GetFont()) or 13
    fontObjects[fontObj] = originalSize
end

AF.AddToFontSizeUpdater(font_title, FONT_TITLE_SIZE)
AF.AddToFontSizeUpdater(font_normal, FONT_NORMAL_SIZE)
AF.AddToFontSizeUpdater(font_chat, FONT_CHAT_SIZE)
AF.AddToFontSizeUpdater(font_outline, FONT_OUTLINE_SIZE)
AF.AddToFontSizeUpdater(font_small, FONT_SMALL_SIZE)
AF.AddToFontSizeUpdater(font_chinese, FONT_CHINESE_SIZE)
AF.AddToFontSizeUpdater(font_tooltip_header, FONT_TOOLTIP_HEADER_SIZE)
AF.AddToFontSizeUpdater(font_tooltip, FONT_TOOLTIP_SIZE)

AF.fontSizeDelta = 0

---@param delta number
function AF.UpdateFontSize(delta)
    AF.fontSizeDelta = delta
    if AFConfig then
        AFConfig.fontSizeDelta = AF.fontSizeDelta
    end

    -- font_title:SetFont(BASE_FONT_NORMAL, FONT_TITLE_SIZE + delta, "")
    -- font_normal:SetFont(BASE_FONT_NORMAL, FONT_NORMAL_SIZE + delta, "")
    -- font_chat:SetFont(BASE_FONT_CHAT, FONT_CHAT_SIZE + delta, "")
    -- font_outline:SetFont(BASE_FONT_NORMAL, FONT_OUTLINE_SIZE + delta, "OUTLINE")
    -- font_small:SetFont(BASE_FONT_NORMAL, FONT_SMALL_SIZE + delta, "")
    -- font_chinese:SetFont(UNIT_NAME_FONT_CHINESE, FONT_CHINESE_SIZE + delta, "")
    -- font_tooltip_header:SetFont(BASE_FONT_TOOLTIP, FONT_TOOLTIP_HEADER_SIZE + delta, "")
    -- font_tooltip:SetFont(BASE_FONT_TOOLTIP, FONT_TOOLTIP_SIZE + delta, "")

    for fontObj, originalSize in pairs(fontObjects) do
        local f, _, o = fontObj:GetFont()
        fontObj:SetFont(f, originalSize + delta, o)
    end
end

---------------------------------------------------------------------
-- font group
---------------------------------------------------------------------
local LSM = AF.Libs.LSM
local fontGroup = {}

---@param group string
---@param fontObj Font|FontString
---@param originalSize number defaults to the current font size of the fontObj
function AF.AddToFontSizeUpdaterGroup(group, fontObj, originalSize)
    if not fontGroup[group] then
        fontGroup[group] = {}
    end
    originalSize = originalSize or select(2, fontObj:GetFont()) or 13
    fontGroup[group][fontObj] = originalSize
end

---@param group string
---@param delta number
function AF.UpdateFontSizeForGroup(group, delta)
    if not fontGroup[group] then return end

    for fontObj, originalSize in pairs(fontGroup[group]) do
        local f, _, o = fontObj:GetFont()
        fontObj:SetFont(f, originalSize + delta, o)
    end
end

---@param group? string if not provided, font size will change with the global AF font size delta
---@param name string
---@param font? string defaults to GameFontNormal:GetFont()
---@param size? number defaults to 13
---@param flags? string defaults to ""
---@param shadow? boolean defaults to no shadow
---@param color? string|table defaults to "white"
---@param justifyH? string defaults to "CENTER"
---@param justifyV? string defaults to "MIDDLE"
---@return Font|FontString
function AF.CreateFont(group, name, font, size, flags, shadow, color, justifyH, justifyV)
    font = font or BASE_FONT_NORMAL
    color = color or "white"

    if LSM:IsValid("font", font) then
        font = LSM:Fetch("font", font)
    end

    local obj = CreateFont(name)
    obj:SetFont(font, (size or FONT_NORMAL_SIZE) + AF.fontSizeDelta, flags or "")

    obj:SetJustifyH(justifyH or "CENTER")
    obj:SetJustifyV(justifyV or "MIDDLE")

    if shadow then
        obj:SetShadowColor(0, 0, 0, 1)
        obj:SetShadowOffset(1, -1)
    else
        obj:SetShadowColor(0, 0, 0, 0)
        obj:SetShadowOffset(0, 0)
    end

    if type(color) == "string" then
        obj:SetTextColor(AF.GetColorRGB(color))
    elseif type(color) == "table" then
        obj:SetTextColor(AF.UnpackColor(color))
    end

    if group then
        AF.AddToFontSizeUpdaterGroup(group, obj, size or FONT_NORMAL_SIZE)
    else
        AF.AddToFontSizeUpdater(obj, size or FONT_NORMAL_SIZE)
    end

    return obj
end

---------------------------------------------------------------------
-- font props
---------------------------------------------------------------------
-- function AF.GetFontName(font, isDisabled)
--     if font == "title" then
--         return isDisabled and FONT_TITLE_DISABLE_NAME or FONT_TITLE_NAME
--     elseif font == "normal" then
--         return isDisabled and FONT_NORMAL_DISABLE_NAME or FONT_NORMAL_NAME
--     elseif font == "small" then
--         return isDisabled and FONT_SMALL_DISABLE_NAME or FONT_SMALL_NAME
--     elseif font == "accent_title" then
--         return FONT_ACCENT_TITLE_NAME
--     elseif font == "accent_outline" then
--         return FONT_OUTLINE_NAME
--     elseif font == "accent" then
--         return FONT_ACCENT_NAME
--     end
-- end

-- function AF.GetFontObject(font, isDisabled)
--     if font == "title" then
--         return isDisabled and font_title_disable or font_title
--     elseif font == "normal" then
--         return isDisabled and font_normal_disable or font_normal
--     elseif font == "small" then
--         return isDisabled and font_small_disable or font_small
--     elseif font == "accent_title" then
--         return font_accent_title
--     elseif font == "accent_outline" then
--         return font_outline
--     elseif font == "accent" then
--         return font_accent
--     end
-- end

function AF.GetFontProps(font)
    if font == "title" then
        return font_title:GetFont(), FONT_TITLE_SIZE + AF.fontSizeDelta, "", true
    elseif font == "normal" then
        return font_normal:GetFont(), FONT_NORMAL_SIZE + AF.fontSizeDelta, "", true
    elseif font == "chat" then
        return font_chat:GetFont(), FONT_CHAT_SIZE + AF.fontSizeDelta, "", true
    elseif font == "small" then
        return font_small:GetFont(), FONT_SMALL_SIZE + AF.fontSizeDelta, "", true
    elseif font == "outline" then
        return font_outline:GetFont(), FONT_OUTLINE_SIZE + AF.fontSizeDelta, "OUTLINE", false
    else
        return font, FONT_NORMAL_SIZE + AF.fontSizeDelta, "", true
    end
end