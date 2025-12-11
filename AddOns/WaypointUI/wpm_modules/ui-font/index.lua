local env               = select(2, ...)
local UIKit             = env.WPM:Import("wpm_modules/ui-kit")
local React             = env.WPM:Import("wpm_modules/react")

local UIFont_CustomFont = env.WPM:Import("wpm_modules/ui-font/custom-font")
local UIFont_FontUtil   = env.WPM:Import("wpm_modules/ui-font/font-util")
local UIFont            = env.WPM:New("wpm_modules/ui-font")

-- Predefined Fonts
--------------------------------

local UIFontNormal = React.New(GameFontNormal:GetFont())
UIFont.UIFontNormal = UIFontNormal

local function createUIFontObjectNormal(fontHeight)
    local fontObject = UIFont_FontUtil:CreateFontObject()
    fontObject:SetFont(GameFontNormal:GetFont(), fontHeight, "")
    fontObject:SetShadowOffset(1, -1)
    fontObject:SetShadowColor(0, 0, 0, 1)
    
    return fontObject
end

local UIFontObjectNormal8 = createUIFontObjectNormal(8)
UIFont.UIFontObjectNormal8 = UIFontObjectNormal8

local UIFontObjectNormal10 = createUIFontObjectNormal(10)
UIFont.UIFontObjectNormal10 = UIFontObjectNormal10

local UIFontObjectNormal12 = createUIFontObjectNormal(12)
UIFont.UIFontObjectNormal12 = UIFontObjectNormal12

local UIFontObjectNormal14 = createUIFontObjectNormal(14)
UIFont.UIFontObjectNormal14 = UIFontObjectNormal14

local UIFontObjectNormal16 = createUIFontObjectNormal(16)
UIFont.UIFontObjectNormal16 = UIFontObjectNormal16

local UIFontObjectNormal18 = createUIFontObjectNormal(18)
UIFont.UIFontObjectNormal18 = UIFontObjectNormal18

-- API
--------------------------------

UIFont.CustomFont = UIFont_CustomFont
