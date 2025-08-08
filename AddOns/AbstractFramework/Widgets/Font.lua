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
font_outline:SetTextColor(AF.GetColorRGB("accent"))
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
-- create
---------------------------------------------------------------------
function AF.CreateFont(name, font, size, flags, shadow, color)
    local obj = CreateFont(name)
    obj:SetFont(font, size, flags or "")
    obj:SetJustifyH("CENTER")

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
    else
        obj:SetTextColor(AF.GetColorRGB("white"))
    end

    AF.AddToFontSizeUpdater(obj, size)
end

---------------------------------------------------------------------
-- update size for all used fonts
---------------------------------------------------------------------
local fontStrings = {}
function AF.AddToFontSizeUpdater(fs, originalSize)
    fs.originalSize = originalSize
    tinsert(fontStrings, fs)
end

AF.fontSizeOffset = 0
function AF.UpdateFontSize(offset)
    AF.fontSizeOffset = offset
    font_title:SetFont(BASE_FONT_NORMAL, FONT_TITLE_SIZE + offset, "")
    font_normal:SetFont(BASE_FONT_NORMAL, FONT_NORMAL_SIZE + offset, "")
    font_chat:SetFont(BASE_FONT_CHAT, FONT_CHAT_SIZE + offset, "")
    font_outline:SetFont(BASE_FONT_NORMAL, FONT_OUTLINE_SIZE + offset, "")
    font_small:SetFont(BASE_FONT_NORMAL, FONT_SMALL_SIZE + offset, "")
    font_chinese:SetFont(UNIT_NAME_FONT_CHINESE, FONT_CHINESE_SIZE + offset, "")
    font_tooltip_header:SetFont(BASE_FONT_TOOLTIP, FONT_TOOLTIP_HEADER_SIZE + offset, "")
    font_tooltip:SetFont(BASE_FONT_TOOLTIP, FONT_TOOLTIP_SIZE + offset, "")

    for _, fs in ipairs(fontStrings) do
        local f, _, o = fs:GetFont()
        fs:SetFont(f, (fs.originalSize or FONT_NORMAL_SIZE) + offset, o)
    end
end

---------------------------------------------------------------------
-- update font
---------------------------------------------------------------------
-- function AF.SetFont(font)
-- end

---------------------------------------------------------------------
-- get font by "type"
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
        return BASE_FONT_NORMAL, FONT_TITLE_SIZE + AF.fontSizeOffset, ""
    elseif font == "normal" then
        return BASE_FONT_NORMAL, FONT_NORMAL_SIZE + AF.fontSizeOffset, ""
    elseif font == "chat" then
        return BASE_FONT_CHAT, FONT_CHAT_SIZE + AF.fontSizeOffset, ""
    elseif font == "small" then
        return BASE_FONT_NORMAL, FONT_SMALL_SIZE + AF.fontSizeOffset, ""
    elseif font == "outline" then
        return BASE_FONT_NORMAL, FONT_OUTLINE_SIZE + AF.fontSizeOffset, "OUTLINE"
    else
        return font, FONT_NORMAL_SIZE + AF.fontSizeOffset, ""
    end
end