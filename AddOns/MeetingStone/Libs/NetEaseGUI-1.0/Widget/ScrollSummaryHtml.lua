
local WIDGET, VERSION = 'ScrollSummaryHtml', 1

local GUI = LibStub('NetEaseGUI-1.0')
local ScrollSummaryHtml = GUI:NewClass(WIDGET, GUI:GetClass('ScrollFrame'), VERSION)
if not ScrollSummaryHtml then
    return
end

function ScrollSummaryHtml:Constructor(parent)
    if not parent then
        return
    end

    local SummaryHtml = GUI:GetClass('SummaryHtml'):New(self) do
        self:SetScrollChild(SummaryHtml)
    end

    self.SummaryHtml = SummaryHtml
end

local apis = {
    'GetContentHeight',
    'GetFont',
    'GetFontObject',
    'GetHyperlinkFormat',
    'GetHyperlinksEnabled',
    'GetIndentedWordWrap',
    'GetJustifyH',
    'GetJustifyV',
    'GetShadowColor',
    'GetShadowOffset',
    'GetSpacing',
    'GetText',
    'GetTextColor',
    'SetFont',
    'SetFontObject',
    'SetHyperlinkFormat',
    'SetHyperlinksEnabled',
    'SetIndentedWordWrap',
    'SetJustifyH',
    'SetJustifyV',
    'SetShadowColor',
    'SetShadowOffset',
    'SetSpacing',
    'SetText',
    'SetTextColor',
}

for i, v in ipairs(apis) do
    ScrollSummaryHtml[v] = function(self, ...)
        self.SummaryHtml[v](self.SummaryHtml, ...)
    end
end
