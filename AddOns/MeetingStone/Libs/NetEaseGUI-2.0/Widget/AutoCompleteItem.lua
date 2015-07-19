
local WIDGET, VERSION = 'AutoCompleteItem', 1

local GUI = LibStub('NetEaseGUI-2.0')
local AutoCompleteItem = GUI:NewClass(WIDGET, GUI:GetClass('ItemButton'), VERSION)
if not AutoCompleteItem then
    return
end

function AutoCompleteItem:Constructor(parent)
    self:SetFrameLevel(parent:GetFrameLevel())
    self:SetNormalTexture([[Interface\Common\Search]])
    self:GetNormalTexture():SetTexCoord(0, 0.5, 0.0078125, 0.21875)

    self:SetPushedTexture([[Interface\Common\Search]])
    self:GetPushedTexture():SetTexCoord(0, 0.5, 0.0078125, 0.21875)

    self:SetHighlightTexture([[Interface\Common\Search]], 'ADD')
    self:GetHighlightTexture():SetTexCoord(0.0078125, 0.9921875, 0.234375, 0.4453125)

    self:SetCheckedTexture([[Interface\Common\Search]])
    self:GetCheckedTexture():SetTexCoord(0.0078125, 0.9921875, 0.4609375, 0.671875)

    local text = self:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight') do
        text:SetPoint('TOPLEFT', 5, 0)
        text:SetPoint('BOTTOMRIGHT')
        text:SetJustifyH('LEFT')
        self:SetFontString(text)
        self:SetNormalFontObject(GameFontHighlightSmall)
        self:SetHighlightFontObject(GameFontHighlightSmall)
        self:SetDisabledFontObject(GameFontDisableSmall)
    end
end