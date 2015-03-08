
BuildEnv(...)

Profile = Addon:NewModule('Profile', 'AceEvent-3.0')

function Profile:OnInitialize()
    local gdb = {
        global = {
            ActivityProfiles = {
                Voice = nil,
                VoiceSoft = nil,
            },
            annData = {},
            serverDatas = {},
            ignoreHash = {},
        }
    }

    local cdb = {
        profile = {
            settings = {
                storage = { point = 'TOP', x = 0, y = -20},
                panel = true,
                panelLock = false,
                sound = true,
                ignore = true,
            },
            minimap = {
                minimapPos = 192.68,
            },
            searchHistoryList = {},
            createHistoryList = {},
            searchInputHistory = {},
        }
    }

    self.ignoreCache = {}
    self.gdb = LibStub('AceDB-3.0'):New('MEETINGSTONE_UI_DB', gdb)
    self.cdb = LibStub('AceDB-3.0'):New('MEETINGSTONE_CHARACTER_DB', cdb)
end

function Profile:OnEnable()
    local settings = {
        'panel',
        'panelLock',
        'sound',
        'ignore',
    }

    for _, key in ipairs(settings) do
        self:SendMessage('MEETINGSTONE_SETTING_CHANGED', key, self.cdb.profile.settings[key])
    end

    self:RefreshIgnoreCache()
end

function Profile:SaveActivityProfile(activity)
    self.gdb.global.ActivityProfiles.Voice = activity:GetActivityVoice()

    self.gdb.global.ActivityProfiles[activity:GetActivityTypeText()] = {
        ActivityItemLevel   = activity:GetActivityItemLevel(),
        ActivitySummary     = activity:GetActivitySummary(),
        MinLevel    = activity:GetMinLevel(),
        MaxLevel    = activity:GetMaxLevel(),
        PvPRating   = activity:GetPvPRating(),
    }
end

function Profile:GetActivityProfile(activityType)
    return self.gdb.global.ActivityProfiles[activityType], self.gdb.global.ActivityProfiles.Voice
end

function Profile:GetGlobalDB()
    return self.gdb
end

function Profile:GetCharacterDB()
    return self.cdb
end

function Profile:GetLastSearchValue()
    return self.cdb.profile.lastSearchValue or '6-0-0-0'
end

function Profile:SetLastSearchValue(searchValue)
    self.cdb.profile.lastSearchValue = searchValue

    self:SaveSearchHistory(searchValue)
end

function Profile:SaveVersion()
    self.gdb.global.version = ADDON_VERSION
end

function Profile:IsNewVersion()
    local pVersion = tonumber(self.gdb.global.version) or 0
    local cVersion = tonumber(ADDON_VERSION) or 0

    return pVersion < cVersion
end

function Profile:SaveSearchHistory(searchValue)
    local list = self.cdb.profile.searchHistoryList

    tDeleteItem(list, searchValue)
    tinsert(list, 1, searchValue)

    RefreshHistoryMenuTable()
end

function Profile:SaveCreateHistory(searchValue)
    local list = self.cdb.profile.createHistoryList

    tDeleteItem(list, searchValue)
    tinsert(list, 1, searchValue)

    RefreshHistoryMenuTable(true)
end

function Profile:GetHistoryList(isCreator)
    if isCreator then
        return self.cdb.profile.createHistoryList
    else
        return self.cdb.profile.searchHistoryList
    end
end

function Profile:ClearHistory()
    wipe(self.cdb.profile.createHistoryList)
    wipe(self.cdb.profile.searchHistoryList)
    wipe(self.cdb.profile.searchInputHistory)

    RefreshHistoryMenuTable(true)
    RefreshHistoryMenuTable(false)
end

function Profile:GetSearchInputHistory(searchValue)
    return self.cdb.profile.searchInputHistory[searchValue]
end

function Profile:SaveSearchInputHistory(searchValue, text)
    self.cdb.profile.searchInputHistory[searchValue] = self.cdb.profile.searchInputHistory[searchValue] or {}

    tDeleteItem(self.cdb.profile.searchInputHistory[searchValue], text)
    tinsert(self.cdb.profile.searchInputHistory[searchValue], 1, text)

    if #self.cdb.profile.searchInputHistory[searchValue] > MAX_SEARCHBOX_HISTORY_LINES then
        tremove(self.cdb.profile.searchInputHistory[searchValue])
    end

    return self.cdb.profile.searchInputHistory[searchValue]
end

function Profile:IsIgnored(name)
    return self.gdb.global.ignoreHash[Ambiguate(name, 'none')]
end

function Profile:AddIgnore(name)
    self.gdb.global.ignoreHash[Ambiguate(name, 'none')] = time()
    self:RefreshIgnoreCache()
end

function Profile:DelIgnore(name)
    self.gdb.global.ignoreHash[Ambiguate(name, 'none')] = nil
    self:RefreshIgnoreCache()
end

function Profile:GetNumIgnores()
    return #self.ignoreCache
end

function Profile:RefreshIgnoreCache()
    wipe(self.ignoreCache)

    for k, v in pairs(self.gdb.global.ignoreHash) do
        tinsert(self.ignoreCache, k)
    end

    sort(self.ignoreCache)
end

function Profile:GetIgnoreName(index)
    return self.ignoreCache[index]
end
