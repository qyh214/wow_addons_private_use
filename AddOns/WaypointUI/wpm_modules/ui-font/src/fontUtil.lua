local env = select(2, ...)
local UIFont_FontUtil = env.WPM:New("wpm_modules/ui-font/font-util")


-- Font
--------------------------------

local FontObjectMixin = {}

function FontObjectMixin:SetFontFile(path)
    local _, height, flags = self:GetFont()
    self:SetFont(path, height, flags)
end

function FontObjectMixin:SetFontHeight(height)
    local path, _, flags = self:GetFont()
    self:SetFont(path, height, flags)
end

function FontObjectMixin:SetFontFlags(flags)
    local path, height, _ = self:GetFont()
    self:SetFont(path, height, flags)
end


local undefinedFontId = 0
function UIFont_FontUtil:CreateFontObject(name)
    if name == nil then
        undefinedFontId = undefinedFontId + 1
        name = "UIFont_" .. undefinedFontId
    end

    local fontObject = CreateFont(name)
    Mixin(fontObject, FontObjectMixin)

    _G[name] = nil
    return fontObject
end
