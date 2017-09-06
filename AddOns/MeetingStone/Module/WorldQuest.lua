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

    self.hookedBlockes = {}
end

function WorldQuest:OnEnable()
    self:SecureHook('TaskPOI_OnClick')
    self:SecureHook('BonusObjectiveTracker_ShowRewardsTooltip', 'HookObjectiveBlock')
    self:RawHook('LFGListUtil_FindQuestGroup', true)

    if Profile:NeedWorldQuestHelp() then
        self:RegisterEvent('WORLD_MAP_UPDATE')
    end
end

local function OnObjectiveBlockClick(block, mouse)
    return WorldQuest:OnObjectiveBlockClick(block, mouse)
end

function WorldQuest:LFGListUtil_FindQuestGroup(questId)
    return self:SearchQuest(questId)
end


function WorldQuest:HookObjectiveBlock(block)
    if self.hookedBlockes[block] then
        return
    end
    self.hookedBlockes[block] = true
    block:HookScript('OnMouseUp', OnObjectiveBlockClick)
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

function WorldQuest:SearchQuest(questId)
    if not HaveQuestData(questId) then
        return
    end
    local _, zoneId = C_TaskQuest.GetQuestZoneID(questId)
    local activityCode = ZONE_ACTIVITY_MAP[zoneId]
    if not activityCode then
        return
    end

    local title = C_TaskQuest.GetQuestInfoByQuestID(questId)

    Addon:ShowModule('MainPanel')
    MainPanel:SelectPanel(BrowsePanel)
    BrowsePanel:QuickSearch(activityCode, nil, nil, title)
end

function WorldQuest:TaskPOI_OnClick(button, mouse)
    if not button.worldQuest or mouse ~= 'RightButton' or IsModifierKeyDown() then
        return
    end
    local questID = button.questID
    if not HaveQuestData(questID) then
        return
    end


    local activityCode = self:GetActivityCodeByQuestID(questID)
    if not activityCode then
        return
    end

    local title = C_TaskQuest.GetQuestInfoByQuestID(questID)

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
        -- {
        --     text = L['快速申请活动'],
        --     func = function()
        --         self:AutoApply(questID, activityCode, title)
        --     end
        -- }
    })
end

function WorldQuest:OnObjectiveBlockClick(block, mouse)
    if mouse ~= 'RightButton' then
        return
    end
    if not block.module.ShowWorldQuests then
        return
    end

    local questID = block.TrackedQuest.questID

    local activityCode = self:GetActivityCodeByQuestID(questID)
    if not activityCode then
        return
    end

    local title = C_TaskQuest.GetQuestInfoByQuestID(questID)

    local menuTable = {
        {
            text = title,
            isTitle = true,
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
        -- {
        --     text = L['快速申请活动'],
        --     func = function()
        --         self:AutoApply(questID, activityCode, title)
        --     end
        -- }
    }

    if IsWorldQuestWatched(questID) then
        tinsert(menuTable, 2, {
            text = OBJECTIVES_STOP_TRACKING,
            func = function()
                BonusObjectiveTracker_UntrackWorldQuest(questID)
            end
        })
    end

    CloseDropDownMenus()
    GUI:ToggleMenu(block, menuTable, 'cursor')
end

-- function WorldQuest:AutoApply(questID, activityCode, title)
--     local _, _, activityId, customId = strsplit('-', activityCode)
--     local apply = Addon:GetClass('WorldQuestApply'):New(tonumber(activityId), tonumber(customId))

--     apply:SetQuestID(questID)
--     apply:SetSearch(title)

--     AutoApply:Add(apply)
--     AutoApply:Start()
-- end


--根据questid获取activitycode
-- questid 任务id
-- return activitycode 活动code
function WorldQuest:GetActivityCodeByQuestID(questId)

    if not questId then
        return
    end

    local activityId = C_LFGList.GetActivityIDForQuestID(questId)
    if not activityId then
        return
    end

    local activityCode = GetActivityCode(activityId)
    if not activityCode then
        return
    end
    return activityCode
end
