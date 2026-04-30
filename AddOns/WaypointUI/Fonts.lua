local env = select(2, ...)
local UIFont = env.modules:Import("packages\\ui-font")
local UIFont_FontUtil = env.modules:Import("packages\\ui-font\\font-util")

UIFont.WUIFooterFont = UIFont_FontUtil:CreateFontObject("WUIFooterFont")
UIFont.WUIFooterFont:SetFont(GameFontNormal:GetFont(), 8, "")
UIFont.WUIFooterFont:SetShadowOffset(1, -1)
UIFont.WUIFooterFont:SetShadowColor(0, 0, 0, 1)
