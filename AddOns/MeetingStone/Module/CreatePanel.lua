
BuildEnv(...)

CreatePanel = Addon:NewModule(CreateFrame('Frame', nil, ManagerPanel), 'CreatePanel', 'AceEvent-3.0')

function CreatePanel:OnInitialize()
    GUI:Embed(self, 'Owner', 'Tab', 'Refresh')

    self:SetPoint('TOPLEFT')
    self:SetPoint('BOTTOMLEFT')
    self:SetWidth(219)

    local line = GUI:GetClass('VerticalLine'):New(self) do
        line:SetPoint('TOPLEFT', self, 'TOPRIGHT', -3, 5)
        line:SetPoint('BOTTOMLEFT', self, 'BOTTOMRIGHT', -3, -5)
    end
    -- view board
    local ViewBoardWidget = CreateFrame('Frame', nil, self) do
        ViewBoardWidget:SetAllPoints(true)
        ViewBoardWidget:Hide()
        ViewBoardWidget:SetScript('OnShow', function()
            self:UpdateActivityView()
        end)
    end

    --- frames
    local InfoWidget = CreateFrame('Frame', nil, ViewBoardWidget) do
        InfoWidget:SetPoint('TOPLEFT')
        InfoWidget:SetSize(219, 100)

        local bg = InfoWidget:CreateTexture(nil, 'BACKGROUND', nil, 1)
        bg:SetPoint('TOPLEFT', -2, 2)
        bg:SetPoint('BOTTOMRIGHT', 2, 2)

        local icon = InfoWidget:CreateTexture(nil, 'ARTWORK')
        icon:SetTexture([[INTERFACE\GROUPFRAME\UI-GROUP-MAINTANKICON]])
        icon:SetPoint('TOPLEFT', 10, -8)
        icon:SetSize(16, 16)

        local title = InfoWidget:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLargeLeft')
        title:SetPoint('TOPLEFT', icon, 'TOPRIGHT', 3, 0)
        title:SetPoint('RIGHT', -10, 0)

        local summary = CreateFrame('Frame', nil, InfoWidget)
        summary:SetPoint('TOPLEFT', title, 'BOTTOMLEFT', -5, -3)
        summary:SetPoint('RIGHT', -5, 0)
        summary:SetPoint('BOTTOM', 0, 26)
        summary:EnableMouse(true)
        local summaryLabel = summary:CreateFontString(nil, 'OVERLAY', 'GameFontDisableSmallLeft')
        summaryLabel:SetAllPoints(summary)
        summaryLabel:SetJustifyV('TOP')
        summary:SetScript('OnEnter', function(summary)
            if (summaryLabel:GetStringWidth() or 0) > summaryLabel:GetWidth() then
                GameTooltip:SetOwner(summary, 'ANCHOR_RIGHT')
                GameTooltip:SetText(title:GetText() or '')
                GameTooltip:AddLine(summaryLabel:GetText() or '', GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, true)
                GameTooltip:Show()
            end
        end)
        summary:SetScript('OnLeave', GameTooltip_Hide)

        local mode = InfoWidget:CreateTexture(nil, 'ARTWORK')
        mode:SetTexture([[INTERFACE\GROUPFRAME\UI-GROUP-MAINASSISTICON]])
        mode:SetPoint('BOTTOMLEFT', 10, 10)
        mode:SetSize(16, 16)
        local modeText = InfoWidget:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightLeft')
        modeText:SetPoint('LEFT', mode, 'RIGHT', 3, 0)
        modeText:SetWidth(60)

        local loot = InfoWidget:CreateTexture(nil, 'ARTWORK')
        loot:SetTexture([[INTERFACE\GROUPFRAME\UI-Group-MasterLooter]])
        loot:SetPoint('LEFT', modeText, 'RIGHT', 10, 0)
        loot:SetSize(16, 16)
        local lootText = InfoWidget:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightLeft')
        lootText:SetPoint('LEFT', loot, 'RIGHT', 3, 0)
        lootText:SetWidth(100)

        InfoWidget.Title = title
        InfoWidget.Mode = modeText
        InfoWidget.Loot = lootText
        InfoWidget.Background = bg
        InfoWidget.Summary = summaryLabel
    end

    local MemberWidget = GUI:GetClass('TitleWidget'):New(ViewBoardWidget) do
        MemberWidget:SetPoint('TOPLEFT', InfoWidget, 'BOTTOMLEFT', 2, -3)
        MemberWidget:SetPoint('TOPRIGHT', InfoWidget, 'BOTTOMRIGHT', -2, -3)
        MemberWidget:SetHeight(70)

        local icon = MemberWidget:CreateTexture(nil, 'ARTWORK')
        icon:SetTexture([[INTERFACE\CHATFRAME\UI-ChatConversationIcon]])
        icon:SetPoint('TOPLEFT', 10, -5)
        icon:SetSize(16, 16)
        local text = MemberWidget:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLargeLeft')
        text:SetPoint('LEFT', icon, 'RIGHT', 3, 0)
        text:SetText(L['队伍配置'])

        local member = CreateFrame('Frame', nil, MemberWidget, 'LFGListGroupDataDisplayTemplate')
        member:SetPoint('TOPLEFT', icon, 'BOTTOMLEFT', 10, -10)
        member:SetSize(150, 20)

        MemberWidget.Member = member
        MemberWidget.Member.SetMember = function(self, activity)
            local activityID = activity:GetActivityID()
            if activityID then
                local data = GetGroupMemberCounts()
                data.DAMAGER = data.DAMAGER + data.NOROLE
                LFGListGroupDataDisplay_Update(self, activityID, data)
                return true
            end
        end
    end

    local MiscWidget = GUI:GetClass('TitleWidget'):New(ViewBoardWidget) do
        MiscWidget:SetPoint('TOPLEFT', MemberWidget, 'BOTTOMLEFT', 0, -3)
        MiscWidget:SetPoint('BOTTOMRIGHT', -2, 0)
        MiscWidget:SetHeight(150)

        local icon = MiscWidget:CreateTexture(nil, 'ARTWORK')
        icon:SetTexture([[INTERFACE\CHATFRAME\UI-ChatWhisperIcon]])
        icon:SetPoint('TOPLEFT', 10, -5)
        icon:SetSize(16, 16)
        local text = MiscWidget:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLargeLeft')
        text:SetPoint('LEFT', icon, 'RIGHT', 3, 0)
        text:SetText(L['队伍需求'])

        local pvpRatingLabel = MiscWidget:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLeft')
        pvpRatingLabel:SetPoint('BOTTOMLEFT', 20, 20)
        pvpRatingLabel:SetText(L['PvP 等级：'])
        local pvpRatingText = MiscWidget:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightLeft')
        pvpRatingText:SetPoint('LEFT', pvpRatingLabel, 'RIGHT', 3, 0)

        local lvlLabel = MiscWidget:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLeft')
        lvlLabel:SetPoint('BOTTOMLEFT', pvpRatingLabel, 'TOPLEFT', 0, 10)
        lvlLabel:SetText(L['角色等级：'])
        local lvlText = MiscWidget:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightLeft')
        lvlText:SetPoint('LEFT', lvlLabel, 'RIGHT', 3, 0)

        local voiceLabel = MiscWidget:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLeft')
        voiceLabel:SetPoint('BOTTOMLEFT', lvlLabel, 'TOPLEFT', 0, 10)
        voiceLabel:SetText(L['语音聊天：'])
        local voiceText = MiscWidget:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightLeft')
        voiceText:SetPoint('LEFT', voiceLabel, 'RIGHT', 3, 0)

        local itemLevelLabel = MiscWidget:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLeft')
        itemLevelLabel:SetPoint('BOTTOMLEFT', voiceLabel, 'TOPLEFT', 0, 10)
        itemLevelLabel:SetText(L['最低装等：'])
        local itemLevelText = MiscWidget:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightLeft')
        itemLevelText:SetPoint('LEFT', itemLevelLabel, 'RIGHT', 3, 0)
        itemLevelText:SetText('665')

        MiscWidget.Voice = voiceText
        MiscWidget.ItemLevel = itemLevelText
        MiscWidget.Level = lvlText
        MiscWidget.PvPRating = pvpRatingText
    end

    -- widgets
    local CreateWidget = CreateFrame('Frame', nil, self) do
        CreateWidget:SetAllPoints(true)
        CreateWidget:Hide()
        CreateWidget:SetScript('OnShow', function()
            self:UpdateActivity()
            self:UpdateControlState()
        end)
    end

    --- options
    local ActivityOptions = GUI:GetClass('TitleWidget'):New(CreateWidget) do
        ActivityOptions:SetPoint('TOPLEFT')
        ActivityOptions:SetSize(219, 118)
        ActivityOptions:SetText(L['请选择活动属性'])
    end

    local ActivityType = GUI:GetClass('Dropdown'):New(ActivityOptions) do
        ActivityType:SetPoint('TOP', 0, -25)
        ActivityType:SetSize(170, 26)
        ActivityType:SetDefaultText(L['请选择活动类型'])
        ActivityType:SetMaxItem(20)
        ActivityType:SetCallback('OnSelectChanged', function(_, item)
            self.ActivityMode:SetMenuTable(ACTIVITY_MODE_MENUTABLES[item.categoryId])
            self.ActivityMode:SetValue(DEFAULT_MODE_LIST[item.categoryId] or DEFAULT_MODE_LIST[item.value])
            self.ActivityLoot:SetValue(DEFAULT_LOOT_LIST[item.categoryId] or DEFAULT_LOOT_LIST[item.value])
            self:InitProfile()
            self:UpdateControlState()
        end)
    end

    local ActivityMode = GUI:GetClass('Dropdown'):New(ActivityOptions) do
        ActivityMode:SetPoint('TOP', ActivityType, 'BOTTOM', 0, -5)
        ActivityMode:SetSize(170, 26)
        ActivityMode:SetMenuTable(ACTIVITY_MODE_MENUTABLE)
        ActivityMode:SetDefaultText(L['请选择活动形式'])
        ActivityMode:SetCallback('OnSelectChanged', function()
            self:UpdateControlState()
        end)
    end

    local ActivityLoot = GUI:GetClass('Dropdown'):New(ActivityOptions) do
        ActivityLoot:SetPoint('TOP', ActivityMode, 'BOTTOM', 0, -5)
        ActivityLoot:SetSize(170, 26)
        ActivityLoot:SetMenuTable(ACTIVITY_LOOT_MENUTABLE)
        ActivityLoot:SetDefaultText(L['请选择分配方式'])
        ActivityLoot:SetCallback('OnSelectChanged', function()
            self:UpdateControlState()
        end)
    end

    --- voice and item level
    local VoiceItemLevelWidget = GUI:GetClass('TitleWidget'):New(CreateWidget) do
        VoiceItemLevelWidget:SetPoint('TOPLEFT', ActivityOptions, 'BOTTOMLEFT', 0, -3)
        VoiceItemLevelWidget:SetPoint('TOPRIGHT', ActivityOptions, 'BOTTOMRIGHT', 0, -3)
        VoiceItemLevelWidget:SetSize(225, 125)
    end

    local ItemLevel = GUI:GetClass('NumericBox'):New(VoiceItemLevelWidget) do
        ItemLevel:SetPoint('TOP', VoiceItemLevelWidget, 30, -3)
        ItemLevel:SetSize(108, 23)
        ItemLevel:SetLabel(L['最低装等'])
        ItemLevel:SetValueStep(10)
        self:RegisterInputBox(ItemLevel)
    end

    local HonorLevel = GUI:GetClass('NumericBox'):New(VoiceItemLevelWidget) do
        HonorLevel:SetPoint('TOP', ItemLevel, 'BOTTOM', 0, -1)
        HonorLevel:SetSize(108, 23)
        HonorLevel:SetLabel(L['荣誉等级'])
        HonorLevel:SetValueStep(1)
        self:RegisterInputBox(HonorLevel)
    end

    local PvPRating = GUI:GetClass('NumericBox'):New(VoiceItemLevelWidget) do
        PvPRating:SetPoint('TOPLEFT', HonorLevel, 'BOTTOMLEFT', 0, -1)
        PvPRating:SetSize(108, 23)
        PvPRating:SetLabel(L['PVP 等级'])
        PvPRating:SetMinMaxValues(0, 4000)
        PvPRating:SetValueStep(100)
        self:RegisterInputBox(PvPRating)
    end

    local VoiceBox = GUI:GetClass('InputBox'):New(VoiceItemLevelWidget) do
        VoiceBox:SetPoint('TOP', PvPRating, 'BOTTOM', 0, -1)
        VoiceBox:SetSize(108, 23)
        VoiceBox:SetMaxLetters(31)
        VoiceBox:SetLabel(L['语音聊天'])
        self:RegisterInputBox(VoiceBox)
    end

    local MinLevel = GUI:GetClass('NumericBox'):New(VoiceItemLevelWidget) do
        MinLevel:SetPoint('TOPLEFT', VoiceBox, 'BOTTOMLEFT', 0, -1)
        MinLevel:SetSize(48, 23)
        MinLevel:SetLabel(L['角色等级'])
        MinLevel:SetMinMaxValues(0, MAX_PLAYER_LEVEL)
        MinLevel:SetCallback('OnValueChanged', function(_, value)
            self.MaxLevel:SetMinMaxValues(value or 0, MAX_PLAYER_LEVEL)
        end)
        self:RegisterInputBox(MinLevel)
    end

    local MaxLevel = GUI:GetClass('NumericBox'):New(VoiceItemLevelWidget) do
        MaxLevel:SetPoint('TOPRIGHT', VoiceBox, 'BOTTOMRIGHT', 0, -1)
        MaxLevel:SetSize(48, 23)
        MaxLevel:SetLabel('-', nil, 1)
        self:RegisterInputBox(MaxLevel)
    end


    --- summary
    local SummaryWidget = GUI:GetClass('TitleWidget'):New(CreateWidget) do
        SummaryWidget:SetPoint('TOPRIGHT', VoiceItemLevelWidget, 'BOTTOMRIGHT', 0, -3)
        SummaryWidget:SetPoint('TOPLEFT', VoiceItemLevelWidget, 'BOTTOMLEFT', 0, -3)
        SummaryWidget:SetPoint('BOTTOM')
        SummaryWidget:SetText(L['活动说明'])
    end

    local SummaryBox = GUI:GetClass('EditBox'):New(SummaryWidget) do
        SummaryBox:SetPrompt(L['请在这里输入活动说明'])
        SummaryWidget:SetObject(SummaryBox)
        self:RegisterInputBox(SummaryBox:GetEditBox())
    end

    -- buttons
    local DisbandButton = CreateFrame('Button', nil, self, 'UIPanelButtonTemplate') do
        DisbandButton:SetPoint('BOTTOM', ManagerPanel:GetOwner(), 'BOTTOM', 60, 4)
        DisbandButton:SetSize(120, 22)
        DisbandButton:SetText(L['解散活动'])
        DisbandButton:Disable()
        DisbandButton:SetScript('OnClick', function()
            self:DisbandActivity()
        end)
        MagicButton_OnLoad(DisbandButton)
    end

    local CreateButton = CreateFrame('Button', nil, self, 'UIPanelButtonTemplate') do
        CreateButton:SetPoint('RIGHT', DisbandButton, 'LEFT')
        CreateButton:SetSize(120, 22)
        CreateButton:SetText(L['创建活动'])
        CreateButton:Disable()
        CreateButton:SetScript('OnClick', function(CreateButton)
            self:CreateActivity()
        end)
        MagicButton_OnLoad(CreateButton)
    end
    
    local CreateHelpPlate do
        CreateHelpPlate = {
            FramePos = { x = -10,          y = 55 },
            FrameSize = { width = 830, height = 415 },
            {
                ButtonPos = { x = 755, y = 10 },
                HighLightBox = { x = 735, y = 5, width = 95, height = 35 },
                ToolTipDir = 'DOWN',
                ToolTipText = L.CreateHelpRefresh,
            },
            {
                ButtonPos = { x = 400,  y = -170 },
                HighLightBox = { x = 230, y = -35, width = 600, height = 350 },
                ToolTipDir = 'RIGHT',
                ToolTipText = L.CreateHelpList,
            },
            {
                ButtonPos = { x = 90,  y = -80 },
                HighLightBox = { x = 5, y = -35, width = 220, height = 150 },
                ToolTipDir = 'UP',
                ToolTipText = L.CreateHelpOptions,
            },
            {
                ButtonPos = { x = 90,  y = -220 },
                HighLightBox = { x = 5, y = -190, width = 220, height = 195 },
                ToolTipDir = 'UP',
                ToolTipText = L.CreateHelpSummary,
            },
            {
                ButtonPos = { x = 370,  y = -380 },
                HighLightBox = { x = 280, y = -390, width = 270, height = 28 },
                ToolTipDir = 'UP',
                ToolTipText = L.CreateHelpButtons,
            },
        }
        MainPanel:AddHelpButton(CreateWidget, CreateHelpPlate)
    end

    local ViewHelpPlate do
        ViewHelpPlate = {
            FramePos = { x = -10,          y = 55 },
            FrameSize = { width = 830, height = 415 },
            {
                ButtonPos = { x = 755, y = 10 },
                HighLightBox = { x = 735, y = 5, width = 95, height = 35 },
                ToolTipDir = 'DOWN',
                ToolTipText = L.CreateHelpRefresh,
            },
            {
                ButtonPos = { x = 400,  y = -170 },
                HighLightBox = { x = 230, y = -35, width = 600, height = 350 },
                ToolTipDir = 'RIGHT',
                ToolTipText = L.CreateHelpList,
            },
            {
                ButtonPos = { x = 90,  y = -80 },
                HighLightBox = { x = 5, y = -35, width = 220, height = 120 },
                ToolTipDir = 'UP',
                ToolTipText = L.ViewboardHelpOptions,
            },
            {
                ButtonPos = { x = 90,  y = -220 },
                HighLightBox = { x = 5, y = -160, width = 220, height = 225 },
                ToolTipDir = 'UP',
                ToolTipText = L.ViewboardHelpSummary,
            },
            {
                ButtonPos = { x = 370,  y = -380 },
                HighLightBox = { x = 280, y = -390, width = 270, height = 28 },
                ToolTipDir = 'UP',
                ToolTipText = L.CreateHelpButtons,
            },
        }
        MainPanel:AddHelpButton(ViewBoardWidget, ViewHelpPlate)
    end

    self.VoiceBox = VoiceBox
    self.ItemLevel = ItemLevel
    self.SummaryBox = SummaryBox:GetEditBox()
    self.CreateButton = CreateButton
    self.DisbandButton = DisbandButton
    self.ActivityType = ActivityType
    self.ActivityMode = ActivityMode
    self.ActivityLoot = ActivityLoot
    self.MinLevel = MinLevel
    self.MaxLevel = MaxLevel
    self.PvPRating = PvPRating
    self.HonorLevel = HonorLevel

    self.ViewBoardWidget = ViewBoardWidget
    self.InfoWidget = InfoWidget
    self.MemberWidget = MemberWidget
    self.MiscWidget = MiscWidget
    self.CreateWidget = CreateWidget

    self:RegisterEvent('LFG_LIST_ACTIVE_ENTRY_UPDATE')
    self:RegisterEvent('LFG_LIST_AVAILABILITY_UPDATE')
    self:RegisterEvent('LFG_LIST_ENTRY_CREATION_FAILED')
    self:RegisterEvent('PARTY_LEADER_CHANGED')
    self:RegisterMessage('MEETINGSTONE_PERMISSION_UPDATE', 'ChooseWidget')

    self:SetScript('OnShow', self.ChooseWidget)
end

function CreatePanel:OnEnable()
    self:PARTY_LEADER_CHANGED()
end

function CreatePanel:UpdateControlState()
    if not self.CreateWidget:IsVisible() then
        return
    end

    local activityItem = self.ActivityType:GetItem()
    local mode = self.ActivityMode:GetValue()
    local loot = self.ActivityLoot:GetValue()

    local isSolo = activityItem and IsSoloCustomID(activityItem.customId)
    local isCreated = self:IsActivityCreated()
    local isLeader = IsGroupLeader()
    local enable = activityItem and mode and loot
    local editable = enable and not isSolo

    self.ActivityType:SetEnabled(isLeader and not isCreated)
    self.ActivityMode:SetEnabled(activityItem and (not isCreated and not isSolo or not mode))
    self.ActivityLoot:SetEnabled(activityItem and (not isCreated and not isSolo or not loot))

    self.ItemLevel:SetEnabled(editable)
    self.VoiceBox:SetEnabled(editable)
    self.MinLevel:SetEnabled(editable)
    self.MaxLevel:SetEnabled(editable)
    self.SummaryBox:SetEnabled(editable)
    self.PvPRating:SetEnabled(editable and IsUsePvPRating(activityItem and activityItem.activityId))
    self.HonorLevel:SetEnabled(editable and IsUseHonorLevel(activityItem and activityItem.activityId))

    self.DisbandButton:SetEnabled(isCreated and isLeader)
    self.CreateButton:SetEnabled(enable and isLeader)

    if enable then
        self.ItemLevel:SetMinMaxValues(0, GetPlayerItemLevel())
        self.HonorLevel:SetMinMaxValues(0, UnitHonorLevel('player'))
        self.SummaryBox:SetMaxLetters(GetSafeSummaryLength(activityItem.activityId, activityItem.customId, mode, loot))
    end

    self.CreateButton:SetText(isCreated and L['更新活动'] or L['创建活动'])
end

function CreatePanel:InitProfile()
    local activityItem = self.ActivityType:GetItem()
    if not activityItem then
        return
    end

    local activityId = activityItem.activityId
    local customId = activityItem.customId
    local mode = self.ActivityMode:GetValue()
    local loot = self.ActivityLoot:GetValue()

    local profile, voice = Profile:GetActivityProfile(activityItem.text)
    local iLvl, summary, minLvl, maxLvl, pvpRating, honorLevel = 0, '', 10, MAX_PLAYER_LEVEL, 0, 0

    if IsSoloCustomID(customId) then
        iLvl = min(100, GetPlayerItemLevel())
        summary = L['我只是想要单刷，请不要申请'];
        minLvl = UnitLevel('player')
        maxLvl = minLvl
    elseif profile then
        iLvl = profile.ItemLevel
        summary = profile.Summary
        minLvl = profile.MinLevel
        maxLvl = profile.MaxLevel
        pvpRating = profile.PvPRating
        honorLevel = profile.HonorLevel or 0
    else
        local fullName, shortName, categoryID, groupID, iLevel, filters, minLevel, maxPlayers, displayType = C_LFGList.GetActivityInfo(activityId)
        iLvl = min(iLevel, GetPlayerItemLevel())
        minLvl = minLevel == 0 and MIN_PLAYER_LEVEL or minLevel
        maxLvl = MAX_PLAYER_LEVEL
    end

    self.VoiceBox:SetText(voice)
    self.ItemLevel:SetText(iLvl)
    self.SummaryBox:SetText(summary)
    self.MinLevel:SetText(minLvl)
    self.MaxLevel:SetText(maxLvl)
    self.PvPRating:SetText(pvpRating)
    self.HonorLevel:SetText(honorLevel)
end

function CreatePanel:ChooseWidget()
    local isLeader = IsGroupLeader()
    local isCreated = self:IsActivityCreated()

    self.CreateWidget:Hide()
    self.ViewBoardWidget:Hide()
    self.CreateWidget:SetShown(isLeader or not isCreated)
    self.ViewBoardWidget:SetShown(not isLeader and isCreated)
end

function CreatePanel:CreateActivity()
    if CheckContent(self.SummaryBox:GetText()) then
        System:Error(self:IsActivityCreated() and L['更新活动失败：包含非法关键字。'] or L['创建活动失败，包含非法关键字。'])
        return
    end
    self:ClearInputBoxFocus()

    local activityItem = self.ActivityType:GetItem()

    local activity = CurrentActivity:FromAddon({
        ActivityID = activityItem.activityId,
        CustomID = activityItem.customId or 0,

        Mode = self.ActivityMode:GetValue(),
        Loot = self.ActivityLoot:GetValue(),

        VoiceChat = self.VoiceBox:GetText(),
        ItemLevel = self.ItemLevel:GetNumber(),
        Summary = self.SummaryBox:GetText():gsub('\n', ''),

        MinLevel = self.MinLevel:GetNumber(),
        MaxLevel = self.MaxLevel:GetNumber(),
        PvPRating = self.PvPRating:GetNumber(),
        HonorLevel = self.HonorLevel:GetNumber(),
    })
    if self:Create(activity, true) then
        self.CreateButton:Disable()
    else
        self:ChooseWidget()
    end
end

function CreatePanel:Create(activity, isSelf)
    local isCreated = self:IsActivityCreated()
    local handler = isCreated and C_LFGList.UpdateListing or C_LFGList.CreateListing
    local autoAccept = select(9, C_LFGList.GetActiveEntryInfo())

    if handler(activity:GetCreateArguments(autoAccept)) then
        if isSelf then
            Profile:SaveActivityProfile(activity)
            Profile:SaveCreateHistory(activity:GetCode())
        end
        if isCreated then
            Logic:SEI(activity)
        end
        self:SendMessage('MEETINGSTONE_CREATING_ACTIVITY', true)
        return true
    else
        return false
    end
end

function CreatePanel:IsActivityCreated()
    return C_LFGList.GetActiveEntryInfo()
end

function CreatePanel:ClearAllContent()
    self.VoiceBox:SetText('')
    self.ItemLevel:SetNumber(0)
    self.SummaryBox:SetText('')
    self.MinLevel:SetNumber(10)
    self.MaxLevel:SetNumber(MAX_PLAYER_LEVEL)
    self.PvPRating:SetNumber(0)
    self.HonorLevel:SetNumber(0)
    self.ActivityType:SetValue(nil)
    self.ActivityMode:SetValue(nil)
    self.ActivityLoot:SetValue(nil)
end

function CreatePanel:UpdateActivity()
    if not self.CreateWidget:IsVisible() then
        return
    end

    local activity = self:GetCurrentActivity()
    if not activity then
        return
    end

    self.ActivityType:SetValue(activity:GetCode())
    self.ActivityMode:SetValue(activity:GetMode())
    self.ActivityLoot:SetValue(activity:GetLoot())
    self.ItemLevel:SetText(activity:GetItemLevel())
    self.VoiceBox:SetText(activity:GetVoiceChat())
    self.MinLevel:SetText(activity:GetMinLevel() or '')
    self.MaxLevel:SetText(activity:GetMaxLevel() or '')
    self.PvPRating:SetText(activity:GetPvPRating() or '')
    self.HonorLevel:SetText(activity:GetHonorLevel() or '')
    self.SummaryBox:SetText(activity:GetSummary())
end

function CreatePanel:UpdateActivityView()
    if not self.ViewBoardWidget:IsVisible() then
        return
    end

    local activity = self:GetCurrentActivity()
    if not activity then
        return
    end

    local minLevel = activity:GetMinLevel()
    local maxLevel = activity:GetMaxLevel()

    self.InfoWidget.Title:SetText(activity:GetName())
    self.InfoWidget.Mode:SetText(activity:GetModeText() or UNKNOWN)
    self.InfoWidget.Loot:SetText(activity:GetLootText() or UNKNOWN)
    self.InfoWidget.Summary:SetText(activity:GetSummary() or '')
    self.MemberWidget.Member:SetShown(self.MemberWidget.Member:SetMember(activity))
    self.MiscWidget.Voice:SetText(activity:GetVoiceChat())
    self.MiscWidget.ItemLevel:SetText(activity:GetItemLevel())
    self.MiscWidget.PvPRating:SetText(activity:GetPvPRating())
    self.MiscWidget.Level:SetText(minLevel == maxLevel and minLevel or isMax and '≥' .. minLevel or minLevel .. '-' .. maxLevel)

    local atlasName, suffix do
        local fullName, shortName, categoryID, groupID, iLevel, filters, minLevel, maxPlayers, displayType = C_LFGList.GetActivityInfo(activity:GetActivityID())
        local _, separateRecommended = C_LFGList.GetCategoryInfo(categoryID)
        if separateRecommended and bit.band(filters, LE_LFG_LIST_FILTER_RECOMMENDED) ~= 0 then
            atlasName = 'groupfinder-background-'..(LFG_LIST_CATEGORY_TEXTURES[categoryID] or 'raids')..'-'..LFG_LIST_PER_EXPANSION_TEXTURES[LFGListUtil_GetCurrentExpansion()]
        elseif separateRecommended and bit.band(filters, LE_LFG_LIST_FILTER_NOT_RECOMMENDED) ~= 0 then
            atlasName = 'groupfinder-background-'..(LFG_LIST_CATEGORY_TEXTURES[categoryID] or 'raids')..'-'..LFG_LIST_PER_EXPANSION_TEXTURES[math.max(0,LFGListUtil_GetCurrentExpansion() - 1)]
        else
            atlasName = 'groupfinder-background-'..(LFG_LIST_CATEGORY_TEXTURES[categoryID] or 'questing')
        end

        if bit.band(filters, LE_LFG_LIST_FILTER_PVE) ~= 0 then
            suffix = '-pve'
        elseif bit.band(filters, LE_LFG_LIST_FILTER_PVP) ~= 0 then
            suffix = '-pvp'
        end
    end

    if not self.InfoWidget.Background:SetAtlas(atlasName..suffix, true) then
        self.InfoWidget.Background:SetAtlas(atlasName, true)
    end
end

function CreatePanel:GetCurrentActivity()
    local active, activityId, ilvl, honorLevel, title, comment, voiceChat = C_LFGList.GetActiveEntryInfo()
    if active then
        self.Activity = CurrentActivity:FromSystem(activityId, ilvl, honorLevel, title, comment, voiceChat)
        return self.Activity
    else
        self.Activity = nil
    end
end

function CreatePanel:LFG_LIST_AVAILABILITY_UPDATE()
    self:UpdateMenu()
    self:ChooseWidget()
end

function CreatePanel:LFG_LIST_ACTIVE_ENTRY_UPDATE(_, isCreated)
    if not isCreated then
        self:ClearAllContent()
    end
    self:ChooseWidget()
end

function CreatePanel:PARTY_LEADER_CHANGED()
    if not IsGroupLeader() then
        return
    end

    local activity = self:GetCurrentActivity()
    if not activity or not activity:IsMeetingStone() then
        return
    end

    activity:SetItemLevel(min(activity:GetItemLevel(), GetPlayerItemLevel(activity:IsUseHonorLevel())))
    activity:SetHonorLevel(min(activity:GetHonorLevel(), 0))

    self:Create(activity)
end

function CreatePanel:LFG_LIST_ENTRY_CREATION_FAILED()
    System:Error(L['活动创建失败，请重试。'])
end

function CreatePanel:UpdateMenu()
    self.ActivityType:SetMenuTable(GetActivitesMenuTable(true))
end

function CreatePanel:DisbandActivity()
    if not IsGroupLeader() then
        return
    end
    C_LFGList.RemoveListing()
end

function CreatePanel:SelectActivity(value)
    if not self:IsActivityCreated() then
        self.ActivityType:SetValue(value)
    end
end
