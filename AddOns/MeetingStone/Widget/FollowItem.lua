--[[
@Date    : 2016-06-17 15:08:09
@Author  : DengSir (ldz5@qq.com)
@Link    : https://dengsir.github.io
@Version : $Id$
]]

BuildEnv(...)

local FollowItem = Addon:NewClass('FollowItem', GUI:GetClass('ItemButton'))

function FollowItem:Constructor()
    local Name = self:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight') do
        Name:SetFont(Name:GetFont(), 17)
        Name:SetWordWrap(false)
    end

    local Realm = self:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight') do
        Realm:SetFont(Realm:GetFont(), 17)
        Realm:SetTextColor(1, 0.84, 0.55)
        Realm:SetWordWrap(false)
    end

    local FollowStatus = self:CreateTexture(nil, 'ARTWORK') do
        FollowStatus:SetPoint('RIGHT', Name, 'LEFT', -5, 0)
        FollowStatus:SetSize(16, 16)
        FollowStatus:SetTexture([[Interface\COMMON\Indicator-Green]])
    end

    self:SetHighlightTexture([[INTERFACE\QUESTFRAME\UI-QuestTitleHighlight]], 'ADD')

    self.Name = Name
    self.Realm = Realm
    self.FollowStatus = FollowStatus

    self:SetScript('OnSizeChanged', self.OnSizeChanged)
end

function FollowItem:OnSizeChanged()
    x = self:GetWidth() / 4
    self.Name:SetPoint('CENTER', self, 'LEFT', x, 0)
    self.Realm:SetPoint('CENTER', self, 'RIGHT', -x, 0)
end

function FollowItem:SetData(data)
    local name, realm = strsplit('-', data.name)
    self.Name:SetText(name)
    self.Realm:SetText(realm)

    if data.bitfollow then
        self.FollowStatus:SetTexture([[Interface\COMMON\Indicator-Green]])
    else
        self.FollowStatus:SetTexture([[Interface\COMMON\Indicator-Red]])
    end
end
