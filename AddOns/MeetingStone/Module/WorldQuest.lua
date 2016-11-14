--[[
WorldQuest.lua
@Author  : DengSir (tdaddon@163.com)
@Link    : https://dengsir.github.io
]]

BuildEnv(...)

local WorldQuest = Addon:NewModule('WorldQuest', 'AceEvent-3.0', 'AceHook-3.0')

function WorldQuest:OnInitialize()

    local HelpBox = CreateFrame('Frame', nil, WorldMapPOIFrame, 'GlowBoxTemplate') do
        HelpBox:SetSize(200, 60)
        HelpBox:SetPoint('CENTER')
        HelpBox:SetFrameStrata('DIALOG')
        HelpBox:Hide()

        local CloseButton = CreateFrame('Button', nil, HelpBox, 'UIPanelCloseButton') do
            CloseButton:SetPoint('TOPRIGHT', 6, 6)
            CloseButton:SetScript('OnClick', function()
                self:CloseHelp()
            end)
        end

        local Text = HelpBox:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight') do
            Text:SetPoint('TOPLEFT', 10, -10)
            Text:SetPoint('BOTTOMRIGHT', -10, 10)
            Text:SetText(L['右键快速集合石创建或搜索活动。'])
        end

        local Arrow = CreateFrame('Frame', nil, HelpBox, 'GlowBoxArrowTemplate') do
            Arrow:SetSize(53, 21)
            Arrow:SetPoint('TOP', HelpBox, 'BOTTOM', 0, 4)
        end
    end

    self.HelpBox = HelpBox
end

function WorldQuest:OnEnable()
    self:SecureHook('TaskPOI_OnClick')
    self:SecureHook('ObjectiveTracker_ToggleDropDown')

    if Profile:NeedWorldQuestHelp() then
        self:RegisterEvent('WORLD_MAP_UPDATE')
    end
end

function WorldQuest:CloseHelp()
    self.HelpBox:Hide()
    Profile:ClearWorldQuestHelp()
    self:UnregisterEvent('WORLD_MAP_UPDATE')
end

function WorldQuest:FindWorldQuestPOI()
    local bad
    for i = 1, 100 do
        local button = _G['WorldMapFrameTaskPOI' .. i]
        if not button or not button:IsVisible() then
            break
        end
        if button.worldQuest then
            local y = select(5, button:GetPoint())
            if y and y < -120 then
                bad = button
                if select(5, GetQuestTagInfo(button.questID)) then
                    return button
                end
            end
        end
    end
    return bad
end

function WorldQuest:WORLD_MAP_UPDATE()
    self.HelpBox:Hide()

    local zoneId = GetCurrentMapAreaID()
    local activityCode = ZONE_ACTIVITY_MAP[zoneId]
    if not activityCode then
        return
    end

    local button = self:FindWorldQuestPOI()
    if not button then
        return
    end

    self.HelpBox:ClearAllPoints()
    self.HelpBox:SetPoint('BOTTOM', button, 'TOP', 0, 30)
    self.HelpBox:Show()
end

function WorldQuest:TaskPOI_OnClick(button, click)
    if not button.worldQuest or click ~= 'RightButton' or IsModifierKeyDown() then
        return
    end
    if not HaveQuestData(button.questID) then
        return
    end

    local _, zoneId = C_TaskQuest.GetQuestZoneID(button.questID)
    local activityCode = ZONE_ACTIVITY_MAP[zoneId]
    if not activityCode then
        return
    end

    local title = C_TaskQuest.GetQuestInfoByQuestID(button.questID)

    GUI:ToggleMenu(button, {
        {
            text = title,
            isTitle = true,
        },
        {
            text = L['创建集合石活动'],
            func = function()
                HideUIPanel(WorldMapFrame)
                Addon:ShowModule('MainPanel')
                C_Timer.After(0, function()
                    ToggleCreatePanel(activityCode, title)
                end)
            end
        },
        {
            text = L['搜索集合石活动'],
            func = function()
                HideUIPanel(WorldMapFrame)
                Addon:ShowModule('MainPanel')
                MainPanel:SelectPanel(BrowsePanel)
                BrowsePanel:QuickSearch(activityCode, nil, nil, title)
            end
        },
    })
end

function WorldQuest:ObjectiveTracker_ToggleDropDown(block, init)
    if not block.module.ShowWorldQuests or init ~= BonusObjectiveTracker_OnOpenDropDown then
        return
    end

    local questID = block.TrackedQuest.questID
    local _, zoneId = C_TaskQuest.GetQuestZoneID(questID)
    local activityCode = ZONE_ACTIVITY_MAP[zoneId]
    if not activityCode then
        return
    end

    local title = C_TaskQuest.GetQuestInfoByQuestID(questID)

    CloseDropDownMenus()

    GUI:ToggleMenu(block, {
        {
            text = title,
            isTitle = true,
        },
        {
            text = OBJECTIVES_STOP_TRACKING,
            func = function()
                BonusObjectiveTracker_UntrackWorldQuest(questID)
            end
        },
        {
            text = L['创建集合石活动'],
            func = function()
                Addon:ShowModule('MainPanel')
                C_Timer.After(0, function()
                    ToggleCreatePanel(activityCode, title)
                end)
            end
        },
        {
            text = L['搜索集合石活动'],
            func = function()
                Addon:ShowModule('MainPanel')
                MainPanel:SelectPanel(BrowsePanel)
                BrowsePanel:QuickSearch(activityCode, nil, nil, title)
            end
        },
    }, 'cursor')
end
