local env = select(2, ...)
local React = env.modules:Import("packages\\react")
local UIFont_Enum = env.modules:Import("packages\\ui-font\\enum")
local UIFont_CustomFont = env.modules:Import("packages\\ui-font\\custom-font")
local UIFont_FontUtil = env.modules:Import("packages\\ui-font\\font-util")
local UIFont = env.modules:New("packages\\ui-font")

UIFont.Enum = UIFont_Enum
UIFont.CustomFont = UIFont_CustomFont
UIFont.FontUtil = UIFont_FontUtil

do -- Fonts
    local UI_FONT_SCHEMATIC = {
        8, 10, 11, 12, 13, 14, 16, 18
    }

    local function CreateUIFontObjectNormal(fontHeight)
        local fontObject = UIFont_FontUtil:CreateFontObject()
        fontObject:SetFont(GameFontNormal:GetFont(), fontHeight, "")
        fontObject:SetShadowOffset(1, -1)
        fontObject:SetShadowColor(0, 0, 0, 1)

        return fontObject
    end

    function UIFont.SetNormalFont(fontPath)
        for _, fontHeight in ipairs(UI_FONT_SCHEMATIC) do
            UIFont["UIFontObjectNormal" .. fontHeight]:SetFontFile(fontPath)
        end
    end

    local UIFontNormal = React.New(GameFontNormal:GetFont())
    UIFont.UIFontNormal = UIFontNormal

    for _, fontHeight in ipairs(UI_FONT_SCHEMATIC) do
        UIFont["UIFontObjectNormal" .. fontHeight] = CreateUIFontObjectNormal(fontHeight)
    end
end
