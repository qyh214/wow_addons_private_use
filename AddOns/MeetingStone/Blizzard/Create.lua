
BuildEnv(...)

local LFGCreateOptimize = Addon:NewModule('LFGCreateOptimize', 'AceEvent-3.0', 'AceHook-3.0')

local EntryCreation = LFGListFrame.EntryCreation

function LFGCreateOptimize:OnInitialize()
    GUI:Embed(self, 'Tab')

    local ModeLabel = EntryCreation:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLeft') do
        ModeLabel:SetPoint('LEFT', EntryCreation, 'TOPLEFT', 20, -160)
        ModeLabel:SetText('活动形式')
    end

    local ActivityMode = GUI:GetClass('Dropdown'):New(EntryCreation) do
        ActivityMode:SetPoint('TOPLEFT', ModeLabel, 'BOTTOMLEFT', 5, -6)
        ActivityMode:SetSize(143, 26)
        ActivityMode:SetMenuTable(ACTIVITY_MODE_MENUTABLE)
        ActivityMode:SetDefaultText(L['请选择...'])
        ActivityMode:SetCallback('OnSelectChanged', function()
            self:UpdateControlState()
            self:UpdateCreateState()
        end)
    end

    local ActivityLoot = GUI:GetClass('Dropdown'):New(EntryCreation) do
        ActivityLoot:SetPoint('LEFT', ActivityMode, 'RIGHT', 2, 0)
        ActivityLoot:SetSize(143, 26)
        ActivityLoot:SetMenuTable(ACTIVITY_LOOT_MENUTABLE)
        ActivityLoot:SetDefaultText(L['请选择...'])
        ActivityLoot:SetCallback('OnSelectChanged', function()
            self:UpdateControlState()
            self:UpdateCreateState()
        end)
    end

    local MinMaxLevel = CreateFrame('Frame', nil, EntryCreation, 'LFGListRequirementTemplate') do
        MinMaxLevel:SetPoint('TOPLEFT', EntryCreation.VoiceChat, 'BOTTOMLEFT', 0, -5)
        MinMaxLevel.Label:SetText(L['玩家等级范围'])

        local function OnEditFocusLost()
            if MinMaxLevel.EditBox:GetText() == '' and MinMaxLevel.EditBox:GetText() == '' then
                MinMaxLevel.CheckButton:SetChecked(false)
            end
        end

        MinMaxLevel.EditBox:ClearAllPoints()
        MinMaxLevel.EditBox:SetPoint('RIGHT', -75, 0)
        MinMaxLevel.EditBox:SetSize(55, 22)
        MinMaxLevel.EditBox:SetNumeric(true)
        MinMaxLevel.EditBox:SetMaxLetters(3)
        MinMaxLevel.EditBox:SetScript('OnEditFocusLost', OnEditFocusLost)

        MinMaxLevel.EditBox2 = CreateFrame('EditBox', nil, MinMaxLevel, 'LFGListEditBoxTemplate')
        MinMaxLevel.EditBox2:ClearAllPoints()
        MinMaxLevel.EditBox2:SetPoint('RIGHT', -5, 0)
        MinMaxLevel.EditBox2:SetSize(55, 22)
        MinMaxLevel.EditBox2:SetNumeric(true)
        MinMaxLevel.EditBox2:SetMaxLetters(3)
        MinMaxLevel.EditBox2:SetScript('OnTextChanged', MinMaxLevel.EditBox:GetScript('OnTextChanged'))
        MinMaxLevel.EditBox2:SetScript('OnEditFocusLost', OnEditFocusLost)

        MinMaxLevel.CheckButton:HookScript('OnClick', function(self)
            if not self:GetChecked() then
                MinMaxLevel.EditBox2:ClearFocus()
                MinMaxLevel.EditBox2:SetText('')
            end
        end)

        MinMaxLevel.validateFunc = function(frame)
            local minLevel = frame.EditBox:GetNumber()
            local maxLevel = frame.EditBox2:GetNumber()

            if minLevel > MAX_PLAYER_LEVEL or maxLevel > MAX_PLAYER_LEVEL then
                return format(L['你设定角色等级不能大于%d。'], MAX_PLAYER_LEVEL)
            end
            if minLevel > maxLevel and maxLevel ~= 0 then
                return L['你设定的最小等级不能大于最大等级。']
            end
        end
    end

    local PvPRating = CreateFrame('Frame', nil, EntryCreation, 'LFGListRequirementTemplate') do
        PvPRating:SetPoint('TOPLEFT', MinMaxLevel, 'BOTTOMLEFT', 0, -5)
        PvPRating.Label:SetText(L['最低PVP等级'])
        PvPRating.EditBox.Instructions:SetText(L['PVP 等级'])
        PvPRating.EditBox:SetNumeric(true)
        PvPRating.EditBox:SetMaxLetters(4)
    end

    EntryCreation.TypeLabel:SetPoint('LEFT', EntryCreation, 'TOPLEFT', 20, -78)
    EntryCreation.DescriptionLabel:SetPoint('LEFT', EntryCreation, 'TOPLEFT', 20, -215)
    EntryCreation.CategoryDropDown:SetPoint('TOP', 0, -90)
    EntryCreation.Description:SetPoint('TOPLEFT', EntryCreation.Inset, 'TOPLEFT', 26, -171)
    EntryCreation.ItemLevel:SetPoint('TOPLEFT', EntryCreation.Inset, 'TOPLEFT', 20, -230)

    self.ActivityMode = ActivityMode
    self.ActivityLoot = ActivityLoot
    self.MinMaxLevel = MinMaxLevel
    self.PvPRating = PvPRating
    self.VoiceChat = EntryCreation.VoiceChat
    self.ItemLevel = EntryCreation.ItemLevel
    self.HonorLevel = EntryCreation.HonorLevel
    self.SummaryBox = EntryCreation.Description.EditBox
    self.CreateButton = EntryCreation.ListGroupButton

    self.Controls = {
        self.ItemLevel,
        self.HonorLevel,
        self.PvPRating,
        self.VoiceChat,
        self.MinMaxLevel,
    }

    for i, v in ipairs(self.Controls) do
        if v.EditBox then
            self:RegisterInputBox(v.EditBox)
        end
        if v.EditBox2 then
            self:RegisterInputBox(v.EditBox2)
        end
    end
end

function LFGCreateOptimize:OnEnable()
    EntryCreation.NameLabel:Hide()
    EntryCreation.Name:Hide()

    self:RawHook('LFGListEntryCreation_PopulateActivities', true)
    self:RawHook('LFGListEntryCreation_UpdateValidState', 'UpdateCreateState', true)
    self:RawHook('LFGListEntryCreation_GetSanitizedName', true)
    self:RawHook('LFGListEntryCreation_ListGroup', true)

    self:SecureHook('LFGListEntryCreation_Select')
    self:SecureHook('LFGListEntryCreation_SetEditMode')

    self:SecureHookScript(EntryCreation, 'OnShow', 'UpdateControlState')

    LFGListUtil_SetUpDropDown(EntryCreation, EntryCreation.ActivityDropDown, _G.LFGListEntryCreation_PopulateActivities, function(frame, activityId, buttonType, customId)
        frame.selectedCustom = buttonType == 'activity' and customId or nil
        return _G.LFGListEntryCreation_OnActivitySelected(frame, activityId, buttonType, customId)
    end)

    LFGListUtil_SetUpDropDown(EntryCreation, EntryCreation.GroupDropDown,    _G.LFGListEntryCreation_PopulateGroups,     function(frame, ...)
        frame.selectedCustom = nil
        return _G.LFGListEntryCreation_OnGroupSelected(frame, ...)
    end)

    LFGListUtil_SetUpDropDown(EntryCreation, EntryCreation.CategoryDropDown, _G.LFGListEntryCreation_PopulateCategories, function(frame, ...)
        frame.selectedCustom = nil
        return _G.LFGListEntryCreation_OnCategorySelected(frame, ...)
    end)
end

function LFGCreateOptimize:OnDisable()
end

function LFGCreateOptimize:LFGListEntryCreation_PopulateActivities(frame, dropdown, info)
    local useMore = frame.selectedFilters == 0
    local filters = bit.bor(frame.baseFilters, frame.selectedFilters)
    local activities = C_LFGList.GetAvailableActivities(frame.selectedCategory, frame.selectedGroup, filters)

    if useMore then
        if #activities > 5 then
            filters = bit.bor(filters, LE_LFG_LIST_FILTER_RECOMMENDED)
            local recActivities = C_LFGList.GetAvailableActivities(frame.selectedCategory, frame.selectedGroup, filters)

            useMore = #recActivities ~= #activities
            if #recActivities > 0 then
                activities = recActivities
            else
                for i = #activities, 5, -1 do
                    activities[i] = nil
                end
            end
        else
            useMore = false
        end
    end

    for i = 1, #activities do
        local activityId = activities[i]
        local shortName = select(ACTIVITY_RETURN_VALUES.shortName, C_LFGList.GetActivityInfo(activityId))

        info.text = shortName
        info.value = activityId
        info.arg1 = 'activity'
        info.checked = frame.selectedActivity == activityId and frame.selectedCustom == nil
        info.isRadio = true
        UIDropDownMenu_AddButton(info)
    end

    local customData = ACTIVITY_CUSTOM_DATA.G[frame.selectedGroup]
    if customData then
        for i, customId in ipairs(customData) do
            local activityId = ACTIVITY_CUSTOM_IDS[customId]
            info.text = self:GetCustomShortName(customId)
            info.value = activityId
            info.arg1 = 'activity'
            info.arg2 = customId
            info.checked = frame.selectedCustom == customId
            info.isRadio = true
            UIDropDownMenu_AddButton(info)
        end
    end

    local customData = self.selectedActivity and ACTIVITY_CUSTOM_DATA.A[self.selectedActivity]
    if customData then
        for i, customId in ipairs(customData) do
            info.text = self:GetCustomShortName(customId)
            info.value = frame.selectedActivity
            info.arg1 = 'activity'
            info.arg2 = customId
            info.checked = frame.selectedCustom == customId
            info.isRadio = true
            UIDropDownMenu_AddButton(info)
        end
    end

    if useMore then
        info.text = LFG_LIST_MORE
        info.value = nil
        info.arg1 = 'more'
        info.notCheckable = true
        info.checked = false
        info.isRadio = false
        UIDropDownMenu_AddButton(info)
    end
end

function LFGCreateOptimize:LFGListEntryCreation_Select(frame)
    self:InjectCustom(frame)
    self:OnActivitySelected(frame)
end

function LFGCreateOptimize:InjectCustom(frame)
    if frame.selectedActivity == 16 or frame.selectedActivity == 17 then
        frame.ActivityDropDown:Show()
    end
end

function LFGCreateOptimize:OnActivitySelected(frame)
    local activityId = frame.selectedActivity
    local customId = frame.selectedCustom

    if customId and activityId == ACTIVITY_CUSTOM_IDS[customId] then
        UIDropDownMenu_SetText(frame.ActivityDropDown, self:GetCustomShortName(customId))
    else
        customId = nil
        frame.selectedCustom = nil
    end
    if activityId == self.selectedActivity and customId == self.selectedCustom then
        return
    end

    local categoryId = frame.selectedCategory
    local activityCode = GetActivityCode(activityId, customId, categoryId, frame.selectedGroup)

    self.ActivityMode:SetMenuTable(ACTIVITY_MODE_MENUTABLES[frame.selectedCategory])
    self.ActivityMode:SetValue(DEFAULT_MODE_LIST[activityCode] or DEFAULT_MODE_LIST[categoryId])
    self.ActivityLoot:SetValue(DEFAULT_LOOT_LIST[activityCode] or DEFAULT_LOOT_LIST[categoryId])

    self.selectedActivity = activityId
    self.selectedCustom = customId

    self:UpdateControlState()
    self:LayoutControl()
end

function LFGCreateOptimize:LayoutControl()
    local activityId = self.selectedActivity
    local useHonorLevel = IsUseHonorLevel(activityId)

    local spacing = useHonorLevel and 0 or 5

    self.HonorLevel:SetShown(useHonorLevel)
    self.PvPRating:SetShown(useHonorLevel)

    local prevControl
    for i, button in ipairs(self.Controls) do
        if button:IsShown() then
            if prevControl then
                button:SetPoint('TOPLEFT', prevControl, 'BOTTOMLEFT', 0, -spacing)
            end
            prevControl = button
        end
    end
end

function LFGCreateOptimize:GetCustomShortName(id)
    return ACTIVITY_CUSTOM_SHORT_NAMES[id] or ACTIVITY_CUSTOM_NAMES[id]
end

function LFGCreateOptimize:UpdateControlState()
    local editMode = LFGListEntryCreation_IsEditMode(EntryCreation)
    local mode = self.ActivityMode:GetValue()
    local loot = self.ActivityLoot:GetValue()
    local activityId = EntryCreation.selectedActivity
    local customId = EntryCreation.selectedCustom

    local minLevel = self.MinMaxLevel.EditBox:GetNumber()
    local maxLevel = self.MinMaxLevel.EditBox2:GetNumber()

    local enable = mode and loot and activityId
    local solo = IsSoloCustomID(customId)

    self:SetRequirementEnabled(self.ItemLevel, enable and not solo)
    self:SetRequirementEnabled(self.VoiceChat, enable and not solo)
    self:SetRequirementEnabled(self.MinMaxLevel, enable and not solo)
    self:SetRequirementEnabled(self.HonorLevel, enable and not solo and IsUseHonorLevel(activityId))
    self:SetRequirementEnabled(self.PvPRating, enable and not solo and IsUsePvPRating(activityId))
    self.SummaryBox:SetEnabled(enable and not solo)

    self.ActivityMode:SetEnabled(not editMode and not solo)
    self.ActivityLoot:SetEnabled(not editMode and not solo)

    if enable then
        self.SummaryBox:SetMaxLetters(GetSafeSummaryLength(activityId, customId, mode, loot))
    end
end

function LFGCreateOptimize:SetRequirementEnabled(frame, flag)
    frame.CheckButton:SetEnabled(flag)
    frame.EditBox:SetEnabled(flag)
    frame.Label:SetFontObject(flag and 'GameFontHighlightSmall' or 'GameFontDisableSmall')
    if frame.EditBox2 then
        frame.EditBox2:SetEnabled(flag)
    end
end

function LFGCreateOptimize:UpdateCreateState()
    local errorText
    if not self.ActivityMode:GetValue() then
        errorText = L['你必须为你的队伍选择活动形式。']
    elseif not self.ActivityLoot:GetValue() then
        errorText = L['你必须为你的队伍选择拾取方式。']
    end
    local minLevel = self.MinMaxLevel.EditBox:GetNumber()
    local maxLevel = self.MinMaxLevel.EditBox2:GetNumber()
    if minLevel > MAX_PLAYER_LEVEL or maxLevel > MAX_PLAYER_LEVEL or (maxLevel ~= 0 and minLevel > maxLevel) then
        errorText = L['你设定的角色等级范围错误。']
    end

    self.CreateButton:SetEnabled(enable and levelValid)
    if errorText then
        self.CreateButton:SetEnabled(not errorText)
        self.CreateButton.errorText = errorText
    else
        self.hooks.LFGListEntryCreation_UpdateValidState(EntryCreation)
    end
end

function LFGCreateOptimize:LFGListEntryCreation_GetSanitizedName(frame)
    return CodeActivityTitle(EntryCreation.selectedActivity, EntryCreation.selectedCustom, self.ActivityMode:GetValue(), self.ActivityLoot:GetValue())
end

function LFGCreateOptimize:LFGListEntryCreation_ListGroup(frame)
    if CheckContent(self.SummaryBox:GetText()) then
        System:Error(self:IsActivityCreated() and L['更新活动失败：包含非法关键字。'] or L['创建活动失败，包含非法关键字。'])
        return
    end

    local activity = CurrentActivity:FromAddon({
        ActivityID = frame.selectedActivity,
        CustomID = frame.selectedCustom or 0,

        Mode = self.ActivityMode:GetValue(),
        Loot = self.ActivityLoot:GetValue(),

        VoiceChat = self.VoiceChat.EditBox:GetText(),
        ItemLevel = self.ItemLevel.EditBox:GetNumber(),
        Summary = self.SummaryBox:GetText(),

        MinLevel = self.MinMaxLevel.EditBox:GetNumber(),
        MaxLevel = self.MinMaxLevel.EditBox2:GetNumber(),
        PvPRating = self.PvPRating.EditBox:GetNumber(),
        HonorLevel = self.HonorLevel.EditBox:GetNumber(),
    })

    if self:IsActivityCreated() then
        CreatePanel:Create(activity, true)
        LFGListFrame_SetActivePanel(frame:GetParent(), frame:GetParent().ApplicationViewer)
    else
        if CreatePanel:Create(activity, true) then
            frame.WorkingCover:Show()
            LFGListEntryCreation_ClearFocus(frame)
        end
    end
end

function LFGCreateOptimize:IsActivityCreated()
    return CreatePanel:IsActivityCreated()
end

function LFGCreateOptimize:LFGListEntryCreation_SetEditMode(frame, flag)
    local activity = CreatePanel:GetCurrentActivity()
    if activity then
        local isMeetingStone = activity:IsMeetingStone()
        local isLeader = IsGroupLeader()

        frame.selectedCustom = activity:GetCustomID()
        if frame.selectedCustom then
            UIDropDownMenu_SetText(frame.ActivityDropDown, self:GetCustomShortName(frame.selectedCustom))
        end

        self.ActivityMode:SetEnabled(not isMeetingStone and isLeader)
        self.ActivityLoot:SetEnabled(not isMeetingStone and isLeader)

        self.ActivityMode:SetValue(activity:GetMode())
        self.ActivityLoot:SetValue(activity:GetLoot())
        self.SummaryBox:SetText(activity:GetSummary())
        self.MinMaxLevel.EditBox:SetText(self:CheckNumber(activity:GetMinLevel()))
        self.MinMaxLevel.EditBox2:SetText(self:CheckNumber(activity:GetMaxLevel()))
        self.PvPRating.EditBox:SetText(self:CheckNumber(activity:GetPvPRating()))
    end
end

function LFGCreateOptimize:CheckNumber(n)
    return n == 0 and '' or n
end

function LFGCreateOptimize:InitProfile()
    -- body
end
