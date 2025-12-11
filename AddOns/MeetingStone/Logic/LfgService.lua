-- LfgService.lua
-- @Author : DengSir (tdaddon@163.com)
-- @Link   : https://dengsir.github.io/
-- @Date   : 2018-1-17 10:29:00

BuildEnv(...)

LfgService = Addon:NewModule('LfgService', 'AceEvent-3.0', 'AceBucket-3.0', 'AceTimer-3.0', 'AceHook-3.0')

function LfgService:OnInitialize()
    self.activityHash = {}
    self.activityList = {}
    self.activityDealList = {}
    self.activityRemoved = {}

    self:RegisterEvent('LFG_LIST_SEARCH_RESULTS_RECEIVED')
    self:RegisterEvent('LFG_LIST_SEARCH_FAILED', 'LFG_LIST_SEARCH_RESULTS_RECEIVED')
    self:RegisterEvent('LFG_LIST_APPLICATION_STATUS_UPDATED')
    self:RegisterEvent('LFG_LIST_SEARCH_RESULT_UPDATED')

    -- self:RegisterBucketEvent('LFG_LIST_SEARCH_RESULT_UPDATED', 0.1, 'LFG_LIST_SEARCH_RESULT_UPDATED_BUCKET')

    self:SecureHook(C_LFGList, 'Search', 'C_LFGList_Search')
end

function LfgService:C_LFGList_Search()
    self.inSearch = true
    self.dirty = true
end

function LfgService:GetActivity(id)
    return self.activityHash[id]
end

function LfgService:GetActivityCount()
    return #self.activityList
end

function LfgService:GetActivityList()
    return self.activityList
end

function LfgService:GetActivityDealListCount()
    return #self.activityDealList
end

function LfgService:GetActivityDealList()
    return self.activityDealList
end

function LfgService:RemoveActivity(id)
    self.activityRemoved[id] = true

    local activity = self:GetActivity(id)
    if not activity then
        return
    end
    tDeleteItem(self.activityList, activity)
    tDeleteItem(self.activityDealList, activity)
    self.activityHash[id] = nil
end

function LfgService:IsActivityRemoved(id)
    return self.activityRemoved[id]
end

function LfgService:UpdateActivity(id)
    if self:IsActivityRemoved(id) then
        return
    end

    local activity = self:GetActivity(id)
    if not activity then
        self:CacheActivity(id)
        self:SendMessage('MEETINGSTONE_ACTIVITIES_COUNT_UPDATED', #self.activityList)
    else
		--activity:Update()
        --if activity:GetNumMembers() == 5 then
		if not activity:Update() then
            self:RemoveActivity(id)
        end
    end
end

function LfgService:IterateActivities()
    return pairs(self.activityList)
end

function LfgService:CacheActivity(id)
    if not self:_CacheActivity(id) then
        self:RemoveActivity(id)
    end
end

function LfgService:_CacheActivity(id)
    local activity = Activity:New(id)
    if not activity:Update() then
        return
    end

    if self.activityId and activity:GetActivityID() ~= self.activityId then
        return
    end

    if activity:HasInvalidContent() then
        return
    end
    if not activity:IsValidCustomActivity() then
        return
    end
    Logic:InsertServerCQTL(activity:GetLeader())
    Logic:InsertServerCQGLIB(activity:GetLeader())
    local extraAttributesMap = Logic:GetExtraAttributes(activity:GetLeader())
    if extraAttributesMap and extraAttributesMap.GameDealPrice ~= nil and extraAttributesMap.GameLevelingTitleType ~= nil then
      activity:SetExtraAttributes(extraAttributesMap)
      tinsert(self.activityDealList, activity)
    else
      tinsert(self.activityList, activity)
    end

    self.activityHash[id] = activity

    return true
end

function LfgService:LFG_LIST_SEARCH_RESULTS_RECEIVED(event)
    table.wipe(self.activityList)
    table.wipe(self.activityDealList)
    table.wipe(self.activityHash)
    table.wipe(self.activityRemoved)

    self.inSearch = false

    local applications = C_LFGList.GetApplications()

    self.activityApps = self.activityApps or {} --abyui 9.1.5 applications also in SearchResults
    table.wipe(self.activityApps)

    for _, id in ipairs(applications) do
        self.activityApps[id] = true
        self:CacheActivity(id)
    end

    local _, resultList = C_LFGList.GetSearchResults()
    for _, id in ipairs(resultList) do
        if not self.activityApps[id] then
            self:CacheActivity(id)
        end
    end

    self:SendMessage('MEETINGSTONE_ACTIVITIES_COUNT_UPDATED', self:GetActivityCount())
    self:SendMessage('MEETINGSTONE_ACTIVITIES_RESULT_RECEIVED', event == 'LFG_LIST_SEARCH_FAILED')
end

function LfgService:LFG_LIST_SEARCH_RESULT_UPDATED_BUCKET(results)
    for id in pairs(results) do
        self:UpdateActivity(id)
    end
    self:SendMessage('MEETINGSTONE_ACTIVITIES_RESULT_UPDATED')
end

function LfgService:LFG_LIST_APPLICATION_STATUS_UPDATED(_, appID, status)
    if status == "inviteaccepted" then
        C_Timer.After(1, function()
            local activeEntry = C_LFGList.GetActiveEntryInfo()
            if activeEntry then
                print("===== 队伍详细信息 =====")
                print("队伍名称:", activeEntry.name)
                print("描述:", activeEntry.comment)

                -- 获取活动ID的正确方法
                if activeEntry.activityIDs and #activeEntry.activityIDs > 0 then
                    local activityID = activeEntry.activityIDs[1]
                    local activityInfo = C_LFGList.GetActivityInfoTable(activityID)
                    if activityInfo then
                        print("副本名称:", activityInfo.fullName or activityInfo.shortName or "未知")
                    end
                end
            end
        end)
    end
end

function LfgService:LFG_LIST_SEARCH_RESULT_UPDATED(_, id)
    if self.inSearch then
        return
    end
    self:UpdateActivity(id)
    self:SendMessage('MEETINGSTONE_ACTIVITIES_RESULT_UPDATED')
end

function LfgService:Search(categoryId, baseFilter, activityId)
  self.ourSearch = true
  self.activityId = activityId
  local filterVal = 0
  local advFilter
  if categoryId == 2 then
    filterVal = 1
    advFilter = C_LFGList.GetAdvancedFilter()
  end

  -- if activityId then
  --     local activityInfo = C_LFGList.GetActivityInfoTable(activityId);
  --     print(activityInfo.fullName)
  --     print(activityInfo.shortName)
  --     print(activityInfo.groupFinderActivityGroupID)
  -- end

  local languages = C_LFGList.GetLanguageSearchFilter();
  if BrowsePanel.SearchBox:GetText() ~= '' then
  C_LFGList.Search(categoryId, filterVal, baseFilterVal, languages)
  else
  C_LFGList.Search(categoryId, filterVal, baseFilterVal, languages, nil, advFilter)
  end

  self.ourSearch = false
  self.dirty = false
  end

function LfgService:IsDirty()
    return self.dirty
end

function LfgService:GetSearchResultMemberInfo(resultID, memberIndex)
    local info = C_LFGList.GetSearchResultPlayerInfo(resultID, memberIndex)
    if not info then
        return nil
    end

    local isLeaver = false

    if info.isLeaver ~= nil then
        isLeaver = info.isLeaver
    else
        local name = info.name
        if name and IsInGroup() then
            for i = 1, GetNumGroupMembers() do
                local raidName, _, _, _, _, _, _, _, _, _, _, raidIsLeaver = GetRaidRosterInfo(i)
                if raidName == name then
                    isLeaver = raidIsLeaver
                    break
                end
            end
        end
    end

    return info.assignedRole,
           info.classFilename,
           info.className,
           info.specName,
           info.isLeader,
           isLeaver  -- 新增的第6个返回值表示是否为逃亡者
end

