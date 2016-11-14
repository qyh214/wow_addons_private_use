
BuildEnv(...)

if not ADDON_REGIONSUPPORT then
    return
end

ActivitiesParent = Addon:NewModule(CreateFrame('Frame'), 'ActivitiesParent', 'AceEvent-3.0', 'AceTimer-3.0')
GUI:Embed(ActivitiesParent, 'Refresh', 'TabPanel')

function ActivitiesParent:OnInitialize()
    MainPanel:RegisterPanel(L['最新活动'], self, 3, 20, 1, true)

    local LBackground = self:CreateTexture(nil, 'BORDER') do
        LBackground:SetWidth(209)
        LBackground:SetPoint('TOPLEFT')
        LBackground:SetPoint('BOTTOMLEFT')
        LBackground:SetTexture([[Interface\Common\bluemenu-main]])
        LBackground:SetTexCoord(0.00390625, 0.82421875, 0.18554688, 0.58984375)

        local TLCorner = self:CreateTexture(nil, 'ARTWORK') do
            TLCorner:SetSize(64, 64)
            TLCorner:SetPoint('TOPLEFT', LBackground, 'TOPLEFT')
            TLCorner:SetTexture([[Interface\Common\bluemenu-main]])
            TLCorner:SetTexCoord(0.00390625, 0.25390625, 0.00097656, 0.06347656)
        end

        local TRCorner = self:CreateTexture(nil, 'ARTWORK') do
            TRCorner:SetSize(64, 64)
            TRCorner:SetPoint('TOPRIGHT', LBackground, 'TOPRIGHT')
            TRCorner:SetTexture([[Interface\Common\bluemenu-main]])
            TRCorner:SetTexCoord(0.51953125, 0.76953125, 0.00097656, 0.06347656)
        end

        local BRCorner = self:CreateTexture(nil, 'ARTWORK') do
            BRCorner:SetSize(64, 64)
            BRCorner:SetPoint('BOTTOMRIGHT', LBackground, 'BOTTOMRIGHT')
            BRCorner:SetTexture([[Interface\Common\bluemenu-main]])
            BRCorner:SetTexCoord(0.00390625, 0.25390625, 0.06542969, 0.12792969)
        end

        local BLCorner = self:CreateTexture(nil, 'ARTWORK') do
            BLCorner:SetSize(64, 64)
            BLCorner:SetPoint('BOTTOMLEFT', LBackground, 'BOTTOMLEFT')
            BLCorner:SetTexture([[Interface\Common\bluemenu-main]])
            BLCorner:SetTexCoord(0.26171875, 0.51171875, 0.00097656, 0.06347656)
        end

        local LLine = self:CreateTexture(nil, 'ARTWORK') do
            LLine:SetWidth(43)
            LLine:SetPoint('TOPLEFT', TLCorner, 'BOTTOMLEFT')
            LLine:SetPoint('BOTTOMLEFT', BLCorner, 'TOPLEFT')
            LLine:SetTexture([[Interface\Common\bluemenu-vert]])
            LLine:SetTexCoord(0.06250000, 0.39843750, 0.00000000, 1.00000000)
        end

        local RLine = self:CreateTexture(nil, 'ARTWORK') do
            RLine:SetWidth(43)
            RLine:SetPoint('TOPRIGHT', TRCorner, 'BOTTOMRIGHT')
            RLine:SetPoint('BOTTOMRIGHT', BRCorner, 'TOPRIGHT')
            RLine:SetTexture([[Interface\Common\bluemenu-vert]])
            RLine:SetTexCoord(0.41406250, 0.75000000, 0.00000000, 1.00000000)
        end

        local BLine = self:CreateTexture(nil, 'ARTWORK') do
            BLine:SetHeight(43)
            BLine:SetPoint('BOTTOMLEFT', BLCorner, 'BOTTOMRIGHT')
            BLine:SetPoint('BOTTOMRIGHT', BRCorner, 'BOTTOMLEFT')
            BLine:SetTexture([[Interface\Common\bluemenu-goldborder-horiz]])
            BLine:SetTexCoord(0.00000000, 1.00000000, 0.35937500, 0.69531250)
        end

        local TLine = self:CreateTexture(nil, 'ARTWORK') do
            TLine:SetHeight(43)
            TLine:SetPoint('TOPLEFT', TLCorner, 'TOPRIGHT')
            TLine:SetPoint('TOPRIGHT', TRCorner, 'TOPLEFT')
            TLine:SetTexture([[Interface\Common\bluemenu-goldborder-horiz]])
            TLine:SetTexCoord(0.00000000, 1.00000000, 0.00781250, 0.34375000)
        end

        local TFiligree = self:CreateTexture(nil, 'BORDER') do
            TFiligree:SetSize(185, 55)
            TFiligree:SetPoint('TOP', LBackground, 'TOP', 0, -6)
            TFiligree:SetTexture([[Interface\Common\bluemenu-main]])
            TFiligree:SetTexCoord(0.00390625, 0.72656250, 0.12988281, 0.18359375)
        end

        local BFiligree = self:CreateTexture(nil, 'BORDER') do
            BFiligree:SetSize(185, 55)
            BFiligree:SetPoint('BOTTOM', LBackground, 'BOTTOM', 0, 6)
            BFiligree:SetTexture([[Interface\Common\bluemenu-main]])
            BFiligree:SetTexCoord(0.26171875, 0.98437500, 0.06542969, 0.11914063)
        end

        local HLine = self:CreateTexture(nil, 'ARTWORK') do
            HLine:SetPoint('TOPLEFT', TRCorner, 'TOPRIGHT')
            HLine:SetPoint('BOTTOMLEFT', BRCorner, 'BOTTOMRIGHT')
            HLine:SetWidth(5)
            HLine:SetTexCoord(0.00781250, 0.04687500, 0, 1)
            HLine:SetTexture([[Interface\Common\bluemenu-vert]])
        end
    end

    local Title = self:CreateFontString(nil, 'OVERLAY', 'QuestFont_Super_Huge') do
        Title:SetPoint('TOPLEFT', LBackground, 'TOPRIGHT', 30, -15)
    end

    local TabFrame = GUI:GetClass('TabView'):New(self) do
        TabFrame:SetHeight(1)
        TabFrame:SetPoint('TOPLEFT', LBackground, 'TOPLEFT', -6, -60)
        TabFrame:SetPoint('TOPRIGHT', LBackground, 'TOPRIGHT', -6, -60)
        TabFrame:SetOrientation('VERTICAL', 'LEFT')
        TabFrame:SetItemClass(ActivitiesTabItem)
        TabFrame:EnableMenu(nil)
        TabFrame:SetItemList(self:GetPanelList())
        TabFrame:SetCallback('OnItemFormatted', function(TabFrame, button, data)
            button:SetText(data.name)
            button:SetIcon(data.icon)
        end)
        TabFrame:SetCallback('OnSelectChanged', function(TabFrame, index, data)
            for i, data in ipairs(self:GetPanelList()) do
                data.panel:SetShown(i == index)
            end
            Title:SetText(self:GetPanelList()[index].name)
        end)
    end

    local Inset = CreateFrame('Frame', nil, self, 'InsetFrameTemplate') do
        Inset:SetPoint('BOTTOMRIGHT', 0, 22)
        Inset:SetPoint('TOPLEFT', LBackground, 'TOPRIGHT', 10, -48)
    end

    local ScoreButton = Addon:GetClass('Button'):New(self) do
        ScoreButton:Hide()
        ScoreButton:SetPoint('TOPRIGHT', MainPanel, 'TOPRIGHT', -130, -30)
        ScoreButton:SetText(L['活动点数：'] .. 'NaN')
        ScoreButton:SetIcon([[Interface\ICONS\Racial_Dwarf_FindTreasure]])
        ScoreButton:SetCooldown(SERVER_TIMEOUT)
        ScoreButton:SetTooltip(L['查询活动点数'], L['查询间隔120秒'])
        ScoreButton:SetScript('OnClick', function()
            Activities:QueryPersonInfo()
        end)
        ScoreButton:SetScript('OnShow', function(ScoreButton)
            self.PlayerInfoButton:ClearAllPoints()
            self.PlayerInfoButton:SetPoint('RIGHT', ScoreButton, 'RIGHT', -110, 0)
        end)
        ScoreButton:SetScript('OnHide', function(ScoreButton)
            self.PlayerInfoButton:ClearAllPoints()
            self.PlayerInfoButton:SetPoint('TOPRIGHT', MainPanel, 'TOPRIGHT', -90, -30)
        end)
    end

    local PlayerInfoButton = Addon:GetClass('Button'):New(self) do
        PlayerInfoButton:SetPoint('TOPRIGHT', MainPanel, 'TOPRIGHT', -90, -30)
        PlayerInfoButton:SetText(L['联系方式'])
        PlayerInfoButton:SetIcon([[Interface\ICONS\INV_Letter_05]])
        PlayerInfoButton:SetScript('OnClick', function()
            PlayerInfoDialog:Open(L['填写你的联系方式'], L['联系方式'])
        end)
    end

    local Blocker = MainPanel:NewBlocker('ActivitiesWaitConnect', 3) do
        Blocker:SetParent(self)
        Blocker:Show()
        Blocker:Hide()

        Blocker:SetCallback('OnCheck', function()
            if not Activities:IsConnected() then
                return true
            elseif not Activities:IsReady() then
                return true
            elseif not Activities:GetScore() then
                return true
            elseif Activities:GetBuyingItem() then
                return true
            end
        end)
        Blocker:SetCallback('OnFormat', function(Blocker)
            if not Activities:IsConnected() then
                Blocker:SetText(L['服务器连线中，请稍候'])
            elseif not Activities:IsReady() then
                Blocker:SetText(L['正在获取活动信息，请稍候'])
            elseif not Activities:GetScore() then
                Blocker:SetText(L['正在获取个人信息，请稍候'])
            else
                local item = Activities:GetBuyingItem()
                if item then
                    Blocker:SetText(format(L.ActivitiesBuyingSummary, item.name, item.price))
                end
            end
        end)
        Blocker:SetCallback('OnInit', function(Blocker)
            local Html = GUI:GetClass('SummaryHtml'):New(Blocker) do
                Html:SetPoint('CENTER', 0, 20)
                Html:SetSize(500, 40)
            end

            local Text = Blocker:CreateFontString(nil, 'OVERLAY', 'GameFontNormal') do
                Text:Hide()
                Text:SetWidth(500)
                Text:SetWordWrap(true)
            end

            local Spinner = CreateFrame('Frame', nil, Blocker, 'LoadingSpinnerTemplate') do
                Spinner:SetPoint('BOTTOM', Html, 'TOP', 0, 16)
                Spinner.Anim:Play()
            end

            Blocker.SetText = Addon:GetClass('Cover').SetText
            Blocker.Html = Html
            Blocker.Spinner = Spinner
            Blocker.Text = Text
            Blocker.Icon = Spinner
        end)
    end

    self:RegisterMessage('MEETINGSTONE_ACTIVITIES_PERSONINFO_UPDATE')
    self:RegisterMessage('MEETINGSTONE_ACTIVITIES_DATA_UPDATED')
    self:RegisterMessage('MEETINGSTONE_ACTIVITIES_BUY_TIMEOUT', 'Refresh')
    self:RegisterMessage('MEETINGSTONE_ACTIVITIES_BUY_RESULT', 'Refresh')
    self:RegisterMessage('MEETINGSTONE_ACTIVITIES_BUY_SENDING', 'Refresh')
    self:RegisterMessage('MEETINGSTONE_ACTIVITIES_QUERY_SENDING')
    self:RegisterMessage('MEETINGSTONE_ACTIVITIES_QUERY_TIMEOUT', 'OnShow')
    self:RegisterMessage('MEETINGSTONE_ACTIVITIES_SERVER_CONNECTED', 'OnShow')

    self.Blocker = Blocker
    self.ScoreButton = ScoreButton
    self.PlayerInfoButton = PlayerInfoButton
    self.TabFrame = TabFrame
    self.Inset = Inset
    self:SetScript('OnShow', self.OnShow)
end

function ActivitiesParent:Update()
    self.Blocker:Hide()

    if not self:IsVisible() then
        return
    end
    MainPanel:UpdateBlockers()
end

function ActivitiesParent:MEETINGSTONE_ACTIVITIES_QUERY_SENDING()
    self.ScoreButton:Disable()
    self:Refresh()
end

function ActivitiesParent:OnShow()
    if self:IsVisible() and Activities:IsConnected() and not Activities:GetPersonInfo() then
        Activities:QueryPersonInfo()
    end
    self:Refresh()
    DataCache:GetObject('ActivitiesData'):SetIsNew(false)
end

function ActivitiesParent:MEETINGSTONE_ACTIVITIES_PERSONINFO_UPDATE()
    self.ScoreButton:SetShown(Activities:IsActivityHasScore())
    self.ScoreButton:SetText(L['活动点数：'] .. Activities:GetScore())
    self.queryTimer = nil
    self:SetScript('OnShow', self.Refresh)
    self:UnregisterMessage('MEETINGSTONE_ACTIVITIES_QUERY_TIMEOUT')
    self:UnregisterMessage('MEETINGSTONE_SERVER_STATUS_UPDATED')
    self:Refresh()
end

function ActivitiesParent:MEETINGSTONE_ACTIVITIES_DATA_UPDATED(_, data)
    if data.tabMall then
        if not self:IsPanelRegistered(L['限时秒杀']) then
            self:RegisterPanel(L['限时秒杀'], [[Interface\ICONS\SPELL_HOLY_BORROWEDTIME]], ActivitiesMall, 6)
        end
    else
        self:UnregisterPanel(L['限时秒杀'])
    end
    if data.tabLottery then
        if not self:IsPanelRegistered(L['活动抽奖']) then
            self:RegisterPanel(L['活动抽奖'], [[Interface\ICONS\INV_Misc_Gift_01]], ActivitiesLottery, 6)
        end
    else
        self:UnregisterPanel(L['活动抽奖'])
    end
    self.TabFrame:Refresh()
    self:Refresh()
end

local orig_RegisterPanel = ActivitiesParent.RegisterPanel
function ActivitiesParent:RegisterPanel(name, icon, ...)
    orig_RegisterPanel(self, name, ...).icon = icon
end
