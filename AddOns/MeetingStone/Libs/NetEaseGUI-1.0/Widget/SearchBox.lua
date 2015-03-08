
local WIDGET, VERSION = 'SearchBox', 3

local GUI = LibStub('NetEaseGUI-1.0')
local SearchBox = GUI:NewClass(WIDGET, GUI:GetClass('InputBox'), VERSION)
if not SearchBox then
    return
end

function SearchBox:Constructor(parent)
    local SearchIcon = self:CreateTexture(nil, 'ARTWORK') do
        SearchIcon:SetTexture([[Interface\Common\UI-Searchbox-Icon]])
        SearchIcon:SetPoint('LEFT', 5, -2)
        SearchIcon:SetSize(14, 14)
        SearchIcon:SetVertexColor(0.6, 0.6, 0.6)
    end

    local ClearButton = GUI:GetClass('ClearButton'):New(self) do
        ClearButton:SetPoint('RIGHT', -3, 0)
        ClearButton:SetScript('OnClick', function()
            self:Clear()
        end)
        ClearButton:Hide()
    end

    local AutoComplete = GUI:GetClass('AutoCompleteFrame'):New(self) do
        AutoComplete:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', 7, -2)
        AutoComplete:SetPoint('TOPRIGHT', self, 'BOTTOMRIGHT', -9, -2)
        AutoComplete:SetHeight(110)
        AutoComplete:SetColumnCount(1)
        AutoComplete:Hide()

        AutoComplete:SetCallback('OnItemFormatted', function(_, button, data)
            button:SetText(data)
        end)
        AutoComplete:SetCallback('OnItemClick', function(_, _, data)
            self:SetText(data)
            self:ClearFocus()
        end)
    end

    self.AutoComplete = AutoComplete
    self.SearchIcon = SearchIcon
    self.ClearButton = ClearButton

    self:SetPrompt(SEARCH)
    self:SetTextInsets(21, 20, 0, 0)
    self:SetFontObject('GameFontHighlightSmall')

    self:SetScript('OnEditFocusLost', self.OnEditFocusLost)
    self:SetScript('OnEditFocusGained', self.OnEditFocusGained)
    self:SetScript('OnHide', self.OnHide)

    self.Prompt:ClearAllPoints();
    self.Prompt:SetPoint('TOPLEFT', self, 'TOPLEFT', 21, 0)
    self.Prompt:SetPoint('BOTTOMRIGHT', self, 'BOTTOMRIGHT', -20, 0)
end

function SearchBox:OnEditFocusLost()
    local text = self:GetText()
    self:HighlightText(0, 0)

    if text == '' then
        self.SearchIcon:SetVertexColor(0.6, 0.6, 0.6)
        self.ClearButton:Hide()
    end

    if self:IsAutoCompleteEnabled() then
        self.AutoComplete:Hide()
    end

    self:Fire('OnEditFocusLost', text)
end

function SearchBox:OnEditFocusGained()
    self:HighlightText()
    self.SearchIcon:SetVertexColor(1.0, 1.0, 1.0)
    self.ClearButton:Show()
    self:Fire('OnEditFocusGained')
end

function SearchBox:Clear()
    PlaySound('igMainMenuOptionCheckBoxOn')
    self:SetText('')
    self:ClearFocus()
    self:OnEditFocusLost()
end

function SearchBox:OnHide()
    self:SetText('')
    self.AutoComplete:Hide()
end

function SearchBox:EnableAutoComplete(flag)
    self._enableAutoComplete = flag
end

function SearchBox:IsAutoCompleteEnabled()
    return self._enableAutoComplete
end

function SearchBox:SetAutoComplete(data)
    self.AutoCompleteData = data
    self.AutoComplete:SetItemList(data)
    self.AutoComplete:SetShown(data and #data > 0) 
end

function SearchBox:GetAutoComplete()
    return self.AutoCompleteData
end

function SearchBox:SetMaxHistoryLines(count)
    self.AutoComplete:SetRowCount(count)
end
