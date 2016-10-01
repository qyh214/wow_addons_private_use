
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
            spamWord = {},
            searchProfiles = {},
        },
    }

    local cdb = {
        profile = {
            settings = {
                storage = { point = 'TOP', x = 0, y = -20},
                panel = true,
                panelLock = false,
                sound = true,
                ignore = true,
                spamWord = true,
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
    self.gdb = LibStub('AceDB-3.0'):New('MEETINGSTONE_UI_DB', gdb, true)
    self.cdb = LibStub('AceDB-3.0'):New('MEETINGSTONE_CHARACTER_DB', cdb)

    self.cdb.profile.settings.onlyms = nil
end

function Profile:OnEnable()
    local settings = {
        'panel',
        'panelLock',
        'sound',
        'ignore',
        'spamWord',
    }

    for _, key in ipairs(settings) do
        self:SendMessage('MEETINGSTONE_SETTING_CHANGED', key, self.cdb.profile.settings[key])
    end

    self:RefreshIgnoreCache()
    self:ImportDefaultSpamWord()
end

function Profile:SaveActivityProfile(activity)
    self.gdb.global.ActivityProfiles.Voice = activity:GetVoiceChat()

    self.gdb.global.ActivityProfiles[activity:GetName()] = {
        ItemLevel   = activity:GetItemLevel(),
        Summary     = activity:GetSummary(),
        MinLevel    = activity:GetMinLevel(),
        MaxLevel    = activity:GetMaxLevel(),
        PvPRating   = activity:GetPvPRating(),
        HonorLevel  = activity:GetHonorLevel(),
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

-- function Profile:IsOnlyMeetingStoneActivity()
--     return self.cdb.profile.settings.onlyms
-- end

function Profile:GetSpamWordIndex(word)
    for i, v in ipairs(self.gdb.global.spamWord) do
        if v.text == word.text and v.pain == word.pain then
            return i
        end
    end
end

local function sortSpamWord(a, b)
    return a.text < b.text
end

function Profile:SortSpamWord()
    sort(self.gdb.global.spamWord, sortSpamWord)
end

function Profile:AddSpamWord(word, delay)
    if type(word) ~= 'table'  then
        System:Log(L['添加失败，未输入关键字。'])
        return
    end

    if word.pain then
        word.text = word.text:lower():trim()
    end

    if self:GetSpamWordIndex(word) then
        System:Logf(L['添加失败，关键字“%s”已存在。'], word.text)
    else
        tinsert(self.gdb.global.spamWord, word)
        System:Logf(L['添加成功，关键字“%s”已添加。'], word.text)
        if not delay then
            ClearSpamWordCache()
            self:SortSpamWord()
            self:SendMessage('MEETINGSTONE_SPAMWORD_UPDATE', word)
        end
    end
end

function Profile:DelSpamWord(word)
    if type(word) ~= 'table'  then
        System:Log(L['删除失败，未输入关键字。'])
        return
    end

    local index = self:GetSpamWordIndex(word, pain)
    if index then
        ClearSpamWordCache()
        tremove(self.gdb.global.spamWord, index)
        System:Logf(L['删除成功，关键字“%s”已删除。'], word.text)
        self:SendMessage('MEETINGSTONE_SPAMWORD_UPDATE')
    else
        System:Logf(L['删除失败，关键字“%s”不存在。'], word.text)
    end
end

function Profile:GetSpamWords()
    return self.gdb.global.spamWord
end

function Profile:GetSpamWordStatus()
    return self.cdb.profile.settings.spamWord
end

function Profile:SetSpamWordEnabled(enable)
    if self.cdb.profile.settings.spamWord ~= enable then
        self.cdb.profile.settings.spamWord = enable
        self:SendMessage('MEETINGSTONE_SETTING_CHANGED', 'spamWord', enable)
    end
end

function Profile:SaveImportSpamWord(text)
    if type(text) ~= 'string' then
        return
    end

    local list = {('\n'):split(text)}

    if #list == 0 then
        return
    end

    for i, v in ipairs(list) do
        local enable, text = v:match('^([!]*)(.+)$')
        if text then
            enable = enable == '' and true or nil
            local word = { text = text, pain = enable }
            self:AddSpamWord(word, true)
        end
    end

    ClearSpamWordCache()
    self:SortSpamWord()
end

function Profile:ImportDefaultSpamWord()
    if self.gdb.global.spamWord.default then
        return
    end
    self.gdb.global.spamWord.default = true
    self:SaveImportSpamWord(DEFAULT_SPAMWORD)
    self:SendMessage('MEETINGSTONE_SPAMWORD_UPDATE')
end

function Profile:ResetSpamWord()
    wipe(self.gdb.global.spamWord)
    self:ImportDefaultSpamWord()
    System:Log(L['关键字列表已恢复默认'])
end

function Profile:ExportSpamWord()
    local text = {}
    for i, v in ipairs(self.gdb.global.spamWord) do
        if not v.pain then
            tinsert(text, '!' .. v.text)
        else
            tinsert(text, v.text)
        end
    end

    return table.concat(text, '\n')
end

function Profile:ImportSpamWord(text)
    self:SaveImportSpamWord(text)
    self:SendMessage('MEETINGSTONE_SPAMWORD_UPDATE')
    System:Log(L['导入关键字完成'])
end

function Profile:AddSearchProfile(name, profile)
    self.gdb.global.searchProfiles[name] = profile
    self:SendMessage('MEETINGSTONE_SEARCH_PROFILE_UPDATE')
end

function Profile:DeleteSearchProfile(name)
    self.gdb.global.searchProfiles[name] = nil
    self:SendMessage('MEETINGSTONE_SEARCH_PROFILE_UPDATE')
end

function Profile:IterateSearchProfiles()
    return pairs(self.gdb.global.searchProfiles)
end

function Profile:GetSearchProfile(name)
    return self.gdb.global.searchProfiles[name]
end

function Profile:NeedAdvShine()
    return not self.cdb.profile.advShine or self.cdb.profile.advShine < '60200.09'
end

function Profile:ClearAdvShine()
    self.cdb.profile.advShine = ADDON_VERSION
end