
BuildEnv(...)

debug = neteasedebug or nop

Addon = LibStub('AceAddon-3.0'):NewAddon('MeetingStone', 'AceEvent-3.0', 'LibModule-1.0', 'LibClass-2.0', 'AceHook-3.0')

GUI = LibStub('NetEaseGUI-2.0')

function Addon:OnInitialize()
    self:RawHook('LFGListUtil_OpenBestWindow', 'Toggle', true)

    self:RegisterEvent('LFG_LIST_AVAILABILITY_UPDATE', 'MakeSortOrder')
    self:RegisterMessage('MEETINGSTONE_NEW_VERSION')

    self.mountCache = setmetatable({}, {
        __index = function(t, k)
            for i = 1, C_MountJournal.GetNumMounts() do
                local displayId = C_MountJournal.GetMountInfoExtra(i)
                if displayId == k then
                    t[k] = select(11, C_MountJournal.GetMountInfo(i))
                    return t[k]
                end
            end
        end
    })
    self:RegisterEvent('COMPANION_LEARNED', function()
        wipe(self.mountCache)
    end)
end

function Addon:OnEnable()
    if IsAddOnLoaded('RaidBuilder') then
        DisableAddOn('RaidBuilder')
        GUI:CallWarningDialog(L.FoundRaidBuilder, true, nil, ReloadUI)
        return
    end
end

function Addon:MakeSortOrder()
    wipe(ACTIVITY_ORDER)
    local order = 0

    for _, categoryId in ipairs(C_LFGList.GetAvailableCategories(baseFilter)) do
        for _, activityId in ipairs(C_LFGList.GetAvailableActivities(categoryId)) do
            ACTIVITY_ORDER[activityId] = order

            order = order + 1
        end
    end
end

function Addon:MEETINGSTONE_NEW_VERSION(_, version, url, isSupport, changeLog)
    version = format('%.02f', tonumber(version) or 0)
    if not isSupport then
        self.url = url
        self.changeLog = changeLog

        self:ShowNewVersion(url, changeLog)
    end

    if changeLog then
        System:Logf(L.NewVersionWithChangeLog, version, url, changeLog)
    else
        System:Logf(L.NewVersion, version, url)
    end
end

function Addon:Toggle()
    if Logic:IsSupport() then
        Addon:ToggleModule('MainPanel')

        if C_LFGList.GetActiveEntryInfo() then
            MainPanel:SelectPanel(ManagerPanel)
        elseif DataCache:GetObject('ActivitiesData'):IsNew() then
            MainPanel:SelectPanel(ActivitiesParent)
        end
    else
        self:ShowNewVersion(self.url, self.changeLog)
    end
end

function Addon:ShowNewVersion(url, changeLog)
    if changeLog then
        GUI:CallUrlDialog(url, format(L.NotSupportVersionWithChangeLog, changeLog), 1)
    else
        GUI:CallUrlDialog(url, L.NotSupportVersion, 1)
    end
end

function Addon:FindMount(id)
    return self.mountCache[id]
end