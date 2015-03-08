
local WIDGET, VERSION = 'AutoCompleteItem', 1

local GUI = LibStub('NetEaseGUI-1.0')
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

local WIDGET, VERSION = 'AutoCompleteFrame', 1

local AutoCompleteFrame = GUI:NewClass(WIDGET, GUI:GetClass('GridView'), VERSION)
if not AutoCompleteFrame then
    return
end

function AutoCompleteFrame:Constructor(parent)
    if not parent then
        return
    end

    self:SetParent(parent)
    self:SetItemClass(GUI:GetClass('AutoCompleteItem'))
    self:SetItemHeight(22)
    self:SetItemSpacing(0)
    self:SetAutoSize(true)
    self:SetFrameLevel(parent:GetFrameLevel() + 10)

    local bottomLeft = self:CreateTexture(nil, 'ARTWORK') do
        bottomLeft:SetTexture([[Interface\FrameGeneral\UI-Frame]])
        bottomLeft:SetTexCoord(0.00781250, 0.11718750, 0.63281250, 0.74218750)
        bottomLeft:SetPoint('BOTTOMLEFT', -8, -6)
        bottomLeft:SetSize(14, 14)
    end

    local bottomRight = self:CreateTexture(nil, 'ARTWORK') do
        bottomRight:SetTexture([[Interface\FrameGeneral\UI-Frame]])
        bottomRight:SetTexCoord(0.13281250, 0.21875000, 0.89843750, 0.98437500)
        bottomRight:SetPoint('BOTTOMRIGHT', 4, -6)
        bottomRight:SetSize(11, 11)
    end

    local bottom = self:CreateTexture(nil, 'ARTWORK') do
        bottom:SetTexture([[Interface\FrameGeneral\_UI-Frame]])
        bottom:SetTexCoord(0.00000000, 1.00000000, 0.20312500, 0.27343750)
        bottom:SetHorizTile(true)
        bottom:SetPoint('BOTTOMLEFT', bottomLeft, 'BOTTOMRIGHT')
        bottom:SetPoint('BOTTOMRIGHT', bottomRight, 'BOTTOMLEFT')
        bottom:SetHeight(9)
    end

    local left = self:CreateTexture(nil, 'ARTWORK') do
        left:SetTexture([[Interface\FrameGeneral\!UI-Frame]])
        left:SetTexCoord(0.35937500, 0.60937500, 0.00000000, 1.00000000)
        left:SetVertTile(true)
        left:SetPoint('TOPLEFT', -8, 0)
        left:SetPoint('BOTTOMLEFT', bottomLeft, 'TOPLEFT', -8, 0)
        left:SetWidth(16)
    end

    local right = self:CreateTexture(nil, 'ARTWORK') do
        right:SetTexture([[Interface\FrameGeneral\!UI-Frame]])
        right:SetTexCoord(0.17187500, 0.32812500, 0.00000000, 1.00000000)
        right:SetVertTile(true)
        right:SetPoint('TOPRIGHT', 5, 0)
        right:SetPoint('BOTTOMRIGHT', bottomRight, 'TOPRIGHT', 5, 0)
        right:SetWidth(10)
    end
end
