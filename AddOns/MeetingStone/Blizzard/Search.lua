
BuildEnv(...)

local LFGSearchOptimize = Addon:NewModule('LFGSearchOptimize', 'AceEvent-3.0', 'AceHook-3.0')

function LFGSearchOptimize:OnInitialize()
    self.searchEntries = {}

    self.Tooltip = GUI:GetClass('Tooltip'):New(LFGListFrame)
end

function LFGSearchOptimize:OnEnable()
    self:RawHook('LFGListSearchPanel_UpdateResultList', true)
    self:RawHook('LFGListSearchPanel_SignUp', true)
    self:RawHook('LFGListSearchEntry_OnEnter', true)
    self:SecureHook('LFGListSearchEntry_Update')

    LFGListFrame:UnregisterEvent('LFG_LIST_SEARCH_RESULTS_RECEIVED')
    LFGListFrame:UnregisterEvent('LFG_LIST_SEARCH_FAILED')

    self:RegisterMessage('MEETINGSTONE_ACTIVITIES_RESULT_RECEIVED')
end

function LFGSearchOptimize:OnDisable()
end

function LFGSearchOptimize:MEETINGSTONE_ACTIVITIES_RESULT_RECEIVED(_, isFailed)
    if isFailed then
        LFGListFrame_OnEvent(LFGListFrame, 'LFG_LIST_SEARCH_FAILED')
    else
        LFGListFrame_OnEvent(LFGListFrame, 'LFG_LIST_SEARCH_RESULTS_RECEIVED')
    end
end

function LFGSearchOptimize:LFGListSearchPanel_UpdateResultList(frame)
    local _, results = C_LFGList.GetSearchResults()
    local filtered = {}

    local spamWord = Profile:GetSetting('spamWord')
    local searchText = LFGListFrame.SearchPanel.SearchBox:GetText()

    for _, id in ipairs(results) do
        if not self:FilterResult(id, spamWord, searchText) then
            table.insert(filtered, id)
        end
    end

    frame.totalResults, frame.results = #filtered, filtered
    frame.applications = C_LFGList.GetApplications()
    sort(frame.results, function(a, b)
        return Activity:Get(a):BaseSortHandler() < Activity:Get(b):BaseSortHandler()
    end)
end

function LFGSearchOptimize:FilterResult(id, spamWord, searchText)
    local activity = LfgService:GetActivity(id)
    if not activity then
        return true
    end
    if activity:IsSoloActivity() and searchText ~= activity:GetName() then
        return true
    end
    if spamWord and activity:CheckSpamWord() then
        return true
    end
    if searchText:trim() ~= '' then
        if activity:GetName() and activity:GetName():find(searchText, nil, true) then
            return false
        end
        if activity:GetSummary() and activity:GetSummary():find(searchText, nil, true) then
            return false
        end
        if activity:GetComment() and activity:GetComment():find(searchText, nil, true) then
            return false
        end
        return true
    end
    return false
end

function LFGSearchOptimize:LFGListSearchEntry_Update(button)
    local activity = Activity:Get(button.resultID)

    button.Name:SetText(activity:GetName())
    if activity:IsMeetingStone() then
        button.ActivityName:SetFormattedText([[|TInterface\AddOns\MeetingStone\Media\Mark\0:10|t%s-%s]], activity:GetLootText(), activity:GetModeText())
    else
        button.ActivityName:SetText(activity:GetSummary())
    end

    if not self.searchEntries[button] then
        self:RawHookScript(button, 'OnEnter', 'LFGListSearchEntry_OnEnter')
        self:RawHookScript(button, 'OnLeave', 'LFGListSearchEntry_OnLeave')
        self.searchEntries[button] = true
    end
end

function LFGSearchOptimize:LFGListSearchPanel_SignUp(frame)
    LFGListApplicationDialog.isBlizzard = true
    BrowsePanel:SignUp(Activity:Get(frame.selectedResult))
end

function LFGSearchOptimize:LFGListSearchEntry_OnEnter(button)
    self.Tooltip:SetOwner(button, 'ANCHOR_NONE')
    self.Tooltip:SetPoint('TOPLEFT', LFGListFrame, 'TOPRIGHT', 1, -10)
    MainPanel:OpenActivityTooltip(Activity:Get(button.resultID), self.Tooltip)
end

function LFGSearchOptimize:LFGListSearchEntry_OnLeave()
    self.Tooltip:Hide()
end
