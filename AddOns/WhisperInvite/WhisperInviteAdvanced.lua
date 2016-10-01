local ADDONNAME, WIA = ...
local corename = "WhisperInvite"
-- luacheck: globals LibStub
local core = LibStub("AceAddon-3.0"):GetAddon(corename)

LibStub("AceAddon-3.0"):NewAddon(WIA, ADDONNAME, "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceBucket-3.0")

local L = LibStub("AceLocale-3.0"):GetLocale(corename)

--local _G = _G
local GetGuildInfo, BNGetFriendInfo, BNGetFriendIndex, BNGetNumFriendGameAccounts, GetRealmName, BNGetFriendGameAccountInfo =
      GetGuildInfo, BNGetFriendInfo, BNGetFriendIndex, BNGetNumFriendGameAccounts, GetRealmName, BNGetFriendGameAccountInfo
local BNET_CLIENT_WOW = BNET_CLIENT_WOW

local split,    len,    find,    gsub, format    =
      strsplit, strlen, strfind, gsub, format
local type, select, pairs, wipe, tinsert, next, pcall, rawset, string, tonumber =
      type, select, pairs, wipe, tinsert, next, pcall, rawset, string, tonumber
local lower = string.utf8lower or strlower

WIA.LIST_TYPES = {
    BLOCK = 1,      -- L["BLOCK"] = "Block"
    ALLOW = 2,      -- L["ALLOW"] = "Allow"
}
WIA.LIST_ENTRY_TYPES_REMOVE = 0     -- L["LIST_ENTRY_TYPES_REMOVE"] = "Remove Filter"
WIA.LIST_ENTRY_TYPES = {
    PLAYER = 1,         -- L["PLAYER"] = "Player"
    PLAYER_REALM = 2,   -- L["PLAYER_REALM"] = "Player-Realm"
    GUILD = 3,          -- L["GUILD"] = "Guild"
    GUILD_REALM = 4,    -- L["GUILD_REALM"] = "Guild-Realm"
    REALM = 5,          -- L["REALM"] = "Realm"
    BNET_TAG = 6,       -- L["BNET_TAG"] = "Battle.net Tag"
}
WIA.CHANNEL_TYPES = {
    NORMAL = 1,
    BNET = 2,
}
local CT_NORMAL = WIA.CHANNEL_TYPES.NORMAL
local CT_BNET = WIA.CHANNEL_TYPES.BNET

local getTable, delTable
do
    local cache = setmetatable({},{__mode="k"})
    function getTable()
        local t = next(cache)
        if t then
            cache[t] = nil
            return t
        else
            return {}
        end
    end
    function delTable(t)
        wipe(t)
        cache[t] = true
    end
end

local defaults = {
    global = {
        channels = {
            CHAT_MSG_GUILD = true,      -- L["CHAT_MSG_GUILD"] = "Guild"
            CHAT_MSG_OFFICER = true,    -- L["CHAT_MSG_OFFICER"] = "Guild officer"
            CHAT_MSG_WHISPER = true,    -- L["CHAT_MSG_WHISPER"] = "Whisper"
        },
        bnet_channels = {
            CHAT_MSG_BN_CONVERSATION = true,            -- L["CHAT_MSG_BN_CONVERSATION"] = "Chat"
            CHAT_MSG_BN_INLINE_TOAST_BROADCAST = true,  -- L["CHAT_MSG_BN_INLINE_TOAST_BROADCAST"] = "Status"
            CHAT_MSG_BN_WHISPER = true,                 -- L["CHAT_MSG_BN_WHISPER"] = "Whisper"
        },
        cache = {
            ['**'] = { -- name-realm
                name = false,
                realm = false,
                guild = false,
                bnet_tag = false,
                ['*'] = false,
            },
        },
    },
    profile = {
        messageInScheduleTime = 3,
        checkPlayerScheduleTime = 0.1,
        guildRosterUpdateDelay = 30,
        hasGuildListEntrys = false,
        hasBNetListEntrys = false,
        keywords = {
            ['**'] = {-- id
                active = true,
                -- name = "", <-- Original keyword and exist check
                keyword = "",
                caseSensitive = false,
                fullMatch = true,
                plainMatch = true,
                maxGroupSize = 40,
                showInviteBlockMessage = false,
                customBlockMessage = false,
                hasGuildListEntrys = false,
                hasBNetListEntrys = false,
                listType = WIA.LIST_TYPES.BLOCK,
                list = {
                    -- EntryName = WIA.LIST_ENTRY_TYPES.*
                },
                channels = {
                    -- CHAT_MSG_* = true/false
                },
                bnet_channels = {
                    -- CHAT_MSG_BN_* = true/false
                },
            },
        },

    },
}

function WIA:OnInitialize()
    self.db = core:RegisterNamespace("WhisperInviteAdvancedDB", defaults)

    self:SetDBGlobal_cache()

    self:RegisterChatCommand("wia", "CMD", false)
    self:RegisterChatCommand("wiadvanced", "CMD", false)
    self:RegisterChatCommand("whisperinviteadvanced", "CMD", false)

    self:RegisterConfig()
end


function WIA:OnEnable()
    self:CheckGuildCacheStatus()
    self:CheckBattleNetCacheStatus()

    self:RegisterAllChannels()
end

function WIA:OnDisable()
    self:CheckGuildCacheStatus()
    self:CheckBattleNetCacheStatus()

    self:UnregisterAllChannels()
end

function WIA:CheckGuildCacheStatus()
    if self.db.profile.hasGuildListEntrys and self:IsEnabled() then
        self:EnableGuildCaching()
    else
        self:DisableGuildCaching()
    end
end

function WIA:CheckBattleNetCacheStatus()
    if self.db.profile.hasBNetListEntrys and self:IsEnabled() then
        self:RegisterEvent("BN_FRIEND_TOON_ONLINE")
        self:CheckAllOnlineFriends()
    else
        self:UnregisterEvent("BN_FRIEND_TOON_ONLINE")
    end
end

do-- CMD
    local InterfaceOptionsFrameAddOnsListScrollBar, InterfaceOptionsFrame_OpenToCategory =
          InterfaceOptionsFrameAddOnsListScrollBar, InterfaceOptionsFrame_OpenToCategory


    function WIA:CMD(input, editBox)
        local a1, lastPos = self:GetArgs(input, 1, 1)
        a1 = a1 and lower(a1) or nil

        if a1 == "cache" then
            local a2
            a2, lastPos = self:GetArgs(input, 1, lastPos)
            a2 = a2 and lower(a2) or nil

            if a2 == "clean" then
                self:CleanUpCache()
                self:Print(L["Cache has been cleaned."])
            elseif a2 == "reset" then
                self:ResetCache()
                self:Print(L["Cache has been reset."])
            else
                self:Printf(L["Usage: /wia %s"], "cache")
                self:Printf(L["/wia cache clean||reset – Clean-up or reset cache"])
            end
        elseif a1 == "op" or a1 == "option" or a1 == "options" then
            -- Load InterfaceOptionsFrameAddOns frame...
            InterfaceOptionsFrame_OpenToCategory(L["Advanced"])

            -- Let's scroll down, so your page can be open
            local _, max = InterfaceOptionsFrameAddOnsListScrollBar:GetMinMaxValues()
            InterfaceOptionsFrameAddOnsListScrollBar:SetValue(max)
            InterfaceOptionsFrame_OpenToCategory(L["Advanced"])
        else
            self:Printf(L["Usage: /wia %s"], L["<command>"])
            self:Printf(L["/wia cache clean||reset – Clean-up or reset cache"])
            self:Printf(L["/wia op||option – Open WhisperInviteAdvanced Options"])
        end
    end
end

do-- caching
    local GetNumGuildMembers, GetGuildRosterInfo, BNGetNumFriends, BNGetFriendInfoByID =
          GetNumGuildMembers, GetGuildRosterInfo, BNGetNumFriends, BNGetFriendInfoByID

    local LibWho = LibStub("LibWho-2.0")
    local who = LibWho:Library()
    local dash = "-"
    local opts = {
        queue = who.WHOLIB_QUEUE_QUIET,
        --timeout = -1,
        --callback = "",
        --handler = "",
        --flags = "",
    }
    local bucketHandle
    function WIA:EnableGuildCaching()
        if bucketHandle then
            self:UnregisterBucket(bucketHandle)
        end
        bucketHandle = self:RegisterBucketEvent("GUILD_ROSTER_UPDATE", self.db.profile.guildRosterUpdateDelay)
        LibWho.RegisterCallback(self, 'WHOLIB_QUERY_RESULT')

        self:CheckAllRegisteredGuilds()
    end
    function WIA:DisableGuildCaching()
        self:UnregisterBucket(bucketHandle)
        bucketHandle = nil
        LibWho.UnregisterCallback(self, 'WHOLIB_QUERY_RESULT')
    end

    local LET_GUILD = WIA.LIST_ENTRY_TYPES.GUILD
    local LET_REALM = WIA.LIST_ENTRY_TYPES.REALM

    function WIA:CheckAllRegisteredGuilds()
        local isCached = getTable()

        for id, data in pairs(self.db.profile.keywords) do
            if data.hasGuildListEntrys then
                for entryName, entryType in pairs(data.list) do
                    if entryType == LET_GUILD or entryType == LET_REALM then
                        if not isCached[entryName] then
                            isCached[entryName] = true
                            self:UpdatePlayerForGuild(entryName)
                        end
                    end
                end
            end
        end
        delTable(isCached)
    end

    function WIA:UpdateGuildForPlayer(name)
        if type(name) ~= "string" then return end
        opts.queue = who.WHOLIB_QUEUE_QUIET

        -- UserInfo returns *nothing* when name-server is used on a non x-realm, and type(*nothing*) triggers an error.
        -- So we can check whether the call was successful
        local noError = pcall(function() return type(who:UserInfo(name, opts) ) == "nil" end )
        --[===[@debug@
        self:Printf("WhoLib call with %q was %s", find(name, "-", nil, true) and "name-server" or "name", noError and "successful" or "not successful, retry..")
        --@end-debug@]===]
        if not noError then
            --[===[@debug@
            self:Printf("Try again without realm: %s", name)
            --@end-debug@]===]
            name = split(dash, name)
            who:UserInfo(name, opts)
        end
    end

    function WIA:UpdatePlayerForGuild(guild)
        if type(guild) ~= "string" then return end
        opts.queue = who.WHOLIB_QUEUE_SCANNING
        who:Who(guild, opts)
    end

    function WIA:WHOLIB_QUERY_RESULT(event, query, results, complete, info)
        --[===[@debug@
        self:Printf("WhoLib event: %s", event)
        --@end-debug@]===]
        if event == "WHOLIB_QUERY_RESULT" then
            local cache = self.db.global.cache
            for _, result in pairs(results) do
                local id = core:UniformPlayerName(result.Name)
                cache[id].guild = result.Guild or ""
                --[===[@debug@
                self:Printf("Update: %s(%s), Guild: %s", id, result.Name, result.Guild)
                --@end-debug@]===]
                --result.Name
                --result.Guild
                --result.Online
                --result.Class
                --result.Race
                --result.Level
                --result.Zone
            end
        end
    end

    local last_numGuildMembers, last_numOnline = 0,0
    function WIA:GUILD_ROSTER_UPDATE()
        local guildName = GetGuildInfo("player")
        if type(guildName) ~= "string" or len(guildName) < 1 then return end

        local numGuildMembers, numOnline = GetNumGuildMembers()
        if last_numGuildMembers == numGuildMembers and last_numOnline == numOnline then return end
        last_numGuildMembers = numGuildMembers
        last_numOnline = numOnline

        --[===[@debug@
        self:Printf("Update guild cache from %s guild roster", guildName)
        --@end-debug@]===]

        local cache = self.db.global.cache

        local count = 0
        for guildIndex=1, numGuildMembers  do
            local fullName, rank, rankIndex, level, class, zone, note, officernote, online = GetGuildRosterInfo(guildIndex)
            if online then
                count = count + 1
                local name_realm, name, realm = core:UniformPlayerName(fullName)

                cache[name_realm].guild = guildName
                -- not really needed
                --self.db.global.cache[name_realm].realm = realm
                --self.db.global.cache[name_realm].name = name

                if count >= numOnline then
                    break
                end
            end
        end
    end

    local function CheckData(friendIndex, toonIndex, bnet_tag)
        local self = WIA
        local _, toonName, client, realmName = BNGetFriendGameAccountInfo(friendIndex, toonIndex)

        if client == BNET_CLIENT_WOW then
            local name_realm = core:UniformPlayerName(toonName, realmName)
            --[===[@debug@
            self:Printf("Update: N-R: %s, TN: %s, RN: %s, TAG: %s", name_realm, toonName, realmName, bnet_tag)
            --@end-debug@]===]

            local cache_realm_name = self.db.global.cache[name_realm]
            cache_realm_name.name = toonName
            cache_realm_name.realm = realmName
            cache_realm_name.bnet_tag = bnet_tag

            if self.db.profile.hasGuildListEntrys then
                self:UpdateGuildForPlayer(name_realm)
            end
        end
    end

    function WIA:CheckAllOnlineFriends()
        local _, num = BNGetNumFriends()
        --[===[@debug@
        self:Printf("Check %d online Friends.", num)
        --@end-debug@]===]
        for friendIndex=1, num  do
            local presenceID = BNGetFriendInfo(friendIndex)
            self:UpdatePlayersFromPresenceID(presenceID)
        end
    end

    function WIA:UpdatePlayersFromPresenceID(presenceID)
        local friendIndex = BNGetFriendIndex(presenceID)
        local _, _, bnet_tag = BNGetFriendInfoByID(presenceID)

        if friendIndex then
            for toonIndex=1, BNGetNumFriendGameAccounts(friendIndex) do
                CheckData(friendIndex, toonIndex, bnet_tag)
            end
        end
    end

    function WIA:UpdatePlayerFromToonID(toonID)
        if not toonID then return end
        local isBreak = false

        --[===[@debug@
        self:Printf("Search toonID: %s", toonID)
        --@end-debug@]===]

        local _, num = BNGetNumFriends()
        for friendIndex=1, num  do
            for toonIndex=1, BNGetNumFriendGameAccounts(friendIndex) do
                --local toonID2 = select(16, BNGetFriendGameAccountInfo(friendIndex, toonIndex) )
                local _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, toonID2 = BNGetFriendGameAccountInfo(friendIndex, toonIndex)
                if toonID2 == toonID then
                    --[===[@debug@
                    self:Print("Found toon")
                    --@end-debug@]===]
                    local _, _, bnet_tag = BNGetFriendInfo(friendIndex)
                    CheckData(friendIndex, toonIndex, bnet_tag)
                    isBreak = true
                    break
                end
            end
            if isBreak then
                break
            end
        end

    end

    function WIA:BN_FRIEND_TOON_ONLINE(event, toonID)
        self:UpdatePlayerFromToonID(toonID)
    end
end

do-- Channel Registering
    local registeredChannels = {}
    local registeredBNetChannels = {}

    function WIA:RegisterAllChannels()
        if not self:IsEnabled() then return end

        for id, data in pairs(self.db.profile.keywords) do
            if data.active then
                for channel, active in pairs(data.channels) do
                    if active then
                        self:RegisterChannel(channel, CT_NORMAL, id)
                    end
                end
                for channel, active in pairs(data.bnet_channels) do
                    if active then
                        self:RegisterChannel(channel, CT_BNET, id)
                    end
                end
            end
        end
    end

    function WIA:RegisterChannel(channel, channelType, id)
        if not self:IsEnabled() then return end

        self:RegisterEvent(channel, "MessageIn", channelType)

        if channelType == CT_NORMAL then
            registeredChannels[channel] = registeredChannels[channel] or {}
            registeredChannels[channel][id] = true
        elseif channelType == CT_BNET then
            registeredBNetChannels[channel] = registeredBNetChannels[channel] or {}
            registeredBNetChannels[channel][id] = true
        else
            if not next(registeredChannels[channel]) and next(registeredBNetChannels[channel]) then
                self:UnregisterEvent(channel)
            end
        end
    end

    function WIA:UnregisterAllChannels()
        for channel in pairs(registeredChannels) do
            wipe(registeredChannels[channel])
            self:UnregisterChannel(channel)
        end
        for channel in pairs(registeredBNetChannels) do
            wipe(registeredBNetChannels)
            self:UnregisterChannel(channel)
        end
    end

    function WIA:UnregisterChannel(channel, id)
        if id then
            if type(registeredChannels[channel]) == "table" then
                registeredChannels[channel][id] = nil
            elseif type(registeredBNetChannels[channel]) == "table" then
                registeredBNetChannels[channel][id] = nil
            end
        end

        if type(registeredChannels[channel]) == "table" then
            if not next(registeredChannels[channel]) then
                self:UnregisterEvent(channel)
            end
        elseif type(registeredBNetChannels[channel]) == "table" then
            if not next(registeredBNetChannels[channel]) then
                self:UnregisterEvent(channel)
            end
        end
    end
end

--local keywordIDsCache = {}
function WIA:MessageIn(channelType, event, ...)
    if not self:IsEnabled() then return end
    local msg, name = ...
    --local presenceID = select(13, ...)
    local _, _, _, _, _, _, _, _, _, _, _, _, presenceID = ...

    -- if #keywordIDsCache > 0 then
    --     --[===[@debug@
    --     self:Print("Schedule MessageIn")
    --     --@end-debug@]===]
    --     self:ScheduleTimer("MessageIn", self.db.profile.messageInScheduleTime, channelType, event, ...)
    --     return
    -- end
    local keywordIDs = getTable()
    self:GetMatchingKeywordIDs(keywordIDs, msg, channelType, event)

    local profile = self.db.profile
    local checkPlayerScheduleTime = profile.checkPlayerScheduleTime
    local keywords = profile.keywords

    local overrideScheduleTime
    local guildIsAlreadyChecked = false
    for i=1, #keywordIDs do
        local id = keywordIDs[i]
        local data = keywords[id]

        if self:GetGroupSize() < data.maxGroupSize then -- GetGroupSize returns without player
            if next(data.list) then -- check if block/allow entry exits

                if data.hasGuildListEntrys and not overrideScheduleTime and channelType == CT_NORMAL then
                    if not guildIsAlreadyChecked then
                        guildIsAlreadyChecked = true
                        self:UpdateGuildForPlayer(name)
                    end

                    if self:GetCacheValue( core:UniformPlayerName(name), "guild" ) == "" then
                        -- We have no guild data or player is not in a guild so give time to verify if in a guild or not
                        overrideScheduleTime = 5.5 > checkPlayerScheduleTime and 5.5 or checkPlayerScheduleTime
                    end
                end

                self:ScheduleTimer("CheckPlayer", overrideScheduleTime or checkPlayerScheduleTime, data.keyword, name, presenceID, channelType)
            else
                local result, code
                if channelType == CT_NORMAL then
                    result, code = core:InvitePlayer(name)
                elseif channelType == CT_BNET then
                    result, code = core:InviteBNet(presenceID)
                end
                --[===[@debug@
                self:Printf("Invite Sent: %s", result and "OK" or "Error: "..code )
                --@end-debug@]===]
            end
        end
    end

    delTable(keywordIDs)
end

function WIA:GetMatchingKeywordIDs(resultTable, msg, channelType, channel)
    --wipe(resultTable)
    --tinsert(resultTable, false)

    local channelTableName = channelType == CT_NORMAL and "channels" or channelType == CT_BNET and "bnet_channels"

    for id, data in pairs(self.db.profile.keywords) do
        local keyword = data.keyword
        if data.active and channelTableName and data[channelTableName][channel] then
            if not data.caseSensitive then
                msg = lower(msg)
            end

            if data.fullMatch then
                if keyword == msg then
                    tinsert(resultTable, id)
                end
            else
                local plainMatch = data.plainMatch
                if not plainMatch then
                    msg = " "..msg.." "
                end
                if find(msg, keyword, nil, plainMatch) then
                    tinsert(resultTable, id)
                end
            end
        end
    end

    return #resultTable
end

do-- GetGroupSize
    local GetNumGroupMembers = GetNumGroupMembers
    local LE_PARTY_CATEGORY_HOME = LE_PARTY_CATEGORY_HOME

    function WIA:GetGroupSize()
        return GetNumGroupMembers(LE_PARTY_CATEGORY_HOME)
    end
end


do
    local cache

    function WIA:SetDBGlobal_cache()
        cache = self.db.global.cache
    end

    local value = setmetatable({}, {
        __index = function (t, k)
            local f = function(id)
                return cache[id][k] or ""
            end
            rawset(t, k, f)
            return f
        end
    })

    local dash = "-"
    local homeRealm = GetRealmName()

    function value:name(id)
        local name = split(dash, id)
        return name or ""
    end
    function value:realm(id)
        local name, realm = split(dash, id)
        return realm or homeRealm
    end
    function value:guild(id)
        WIA:UpdateGuildForPlayer(id)
        return cache[id].guild or false
    end
    function value:bnet_tag(id)
        local tag = cache[id].bnet_tag
        return tag or ""
    end

    function WIA:UpdateCache(id, ...)
        for i=1, select('#', ...) do
            local valueType = select(i, ...)
            cache[id][valueType] = value[valueType](value, id)
        end
    end

    function WIA:GetCacheValue(id, valueType)
        if cache[id][valueType] then
            return cache[id][valueType]
        else
            self:UpdateCache(id, valueType)
            return cache[id][valueType]
        end
    end
end

function WIA:CleanUpCache()
    local guilds = getTable()
    local guilds_realm = getTable()
    local bnet_tags = getTable()

    for id, data in pairs(self.db.profile.keywords) do
        for entryName, entryType in pairs(data.list) do
            if entryType == self.LIST_ENTRY_TYPES.GUILD then
                guilds[entryName] = true
            elseif entryType == self.LIST_ENTRY_TYPES.GUILD_REALM then
                guilds_realm[entryName] = true
            elseif entryType == self.LIST_ENTRY_TYPES.BNET_TAG then
                bnet_tags[entryName] = true
            end
        end
    end

    for id, data in pairs(self.db.global.cache) do
        local inUse = false

        if bnet_tags[data.bnet_tag] then
            inUse = true
        elseif data.guild then
            if guilds[data.guild] or guilds_realm[data.guild] then
                inUse = true
            else
                local guild_realm, guild = core:UniformGuildName(data.guild, data.realm)
                if guilds[guild] or guilds_realm[guild_realm] then
                    inUse = true
                end
            end
        end

        if not inUse then
            self.db.global.cache[id] = nil
        end
    end
end

function WIA:ResetCache()
    wipe(self.db.global.cache)
end

function WIA:CheckPlayer(keywordID, playerName, presenceID, channelType)
    local keyword = self.db.profile.keywords[keywordID]

    local isBlock = keyword.listType == self.LIST_TYPES.BLOCK
    local isAllow = keyword.listType == self.LIST_TYPES.ALLOW


    if channelType == CT_NORMAL then
        if type(playerName) == "string" then
            local id = core:UniformPlayerName(playerName)
            if self:CheckList(keywordID, id ) then
                local result, code = core:InvitePlayer(playerName)
                --[===[@debug@
                self:Printf("Invite Sent: %s", result and "OK" or "Error: "..code )
                --@end-debug@]===]
            elseif keyword.showInviteBlockMessage then
                self:Printf(L["%s was not invited %s"], playerName, keyword.customBlockMessage or isAllow and L["Is not allowed."] or isBlock and L["Is blocked."] or "")
            end
        end
    elseif channelType == CT_BNET then
        if presenceID then
            local friendIndex = BNGetFriendIndex(presenceID)

            local canInvite = false
            --local inviteIsBlocked = false
            local numToons = BNGetNumFriendGameAccounts(friendIndex)
            for toonIndex=1, numToons do
                local _, toonName, client, realmName = BNGetFriendGameAccountInfo(friendIndex, toonIndex)
                if client == BNET_CLIENT_WOW then
                    local id = core:UniformPlayerName(toonName, realmName)
                    local result = self:CheckList(keywordID, id)
                    if result and isAllow then
                        canInvite = true
                        break
                    elseif result and isBlock then
                        canInvite = true
                    elseif not result and isBlock then
                        canInvite = false
                        break
                    end
                end
            end

            if canInvite then
                local result, code = core:InviteBNet(presenceID, friendIndex)
                --[===[@debug@
                self:Printf("Invite Sent: %s", result and "OK" or "Error: "..code )
                --@end-debug@]===]
            elseif keyword.showInviteBlockMessage then
                local _, name = BNGetFriendInfo(friendIndex)
                self:Printf(L["%s was not invited: %s"], name, keyword.customBlockMessage or isAllow and L["Is not allowed."] or isBlock and L["Is blocked."] or "")
            end
        end
    end
end

function WIA:CheckList(keywordID, id)
    if not keywordID or not id then return false end
    local data = self.db.profile.keywords[keywordID]
    local isBlock = data.listType == self.LIST_TYPES.BLOCK
    local isAllow = data.listType == self.LIST_TYPES.ALLOW

    local canInvite = isBlock and true or false

    --[===[@debug@
    self:Printf("CheckList: [%s]%s -> %s ", keywordID, data.keyword, id)
    --@end-debug@]===]

    for entryName, entryType in pairs(data.list) do
        if entryType == self.LIST_ENTRY_TYPES.PLAYER then
            local _
            local name = self:GetCacheValue(id, "name")
            _, name = core:UniformPlayerName(name)
            if name == entryName then
                if isAllow then
                    canInvite = true
                elseif isBlock then
                    canInvite = false
                end
                break
            end
        elseif entryType == self.LIST_ENTRY_TYPES.PLAYER_REALM then
            local name_realm = core:UniformPlayerName(self:GetCacheValue(id, "name"), self:GetCacheValue(id, "realm") )
            if name_realm == entryName then
                if isAllow then
                    canInvite = true
                elseif isBlock then
                    canInvite = false
                end
                break
            end
        elseif entryType == self.LIST_ENTRY_TYPES.GUILD then
            local _
            local guild = self:GetCacheValue(id, "guild")
            _, guild = core:UniformGuildName(guild)

            if guild == entryName then
                if isAllow then
                    canInvite = true
                elseif isBlock then
                    canInvite = false
                end
                break
            end
        elseif entryType == self.LIST_ENTRY_TYPES.GUILD_REALM then
            local guild = self:GetCacheValue(id, "guild")
            local realm = self:GetCacheValue(id, "realm")
            local guild_realm = core:UniformGuildName(guild, realm)

            if guild_realm == entryName then
                if isAllow then
                    canInvite = true
                elseif isBlock then
                    canInvite = false
                end
                break
            end
        elseif entryType == self.LIST_ENTRY_TYPES.REALM then
            local realm = self:GetCacheValue(id, "realm")
            if realm == entryName then
                if isAllow then
                    canInvite = true
                elseif isBlock then
                    canInvite = false
                end
                break
            end
        elseif entryType == self.LIST_ENTRY_TYPES.BNET_TAG then
            local tag = self:GetCacheValue(id, "bnet_tag")
            if tag == entryName then
                if isAllow then
                    canInvite = true
                elseif isBlock then
                    canInvite = false
                end
                break
            end
        end
    end

    return canInvite
end

function WIA:CheckHasListEntrys(key)
    local valueChanged

    local key_data = self.db.profile.keywords[key]

    if key and key_data.name then
        local hasGuild = false
        local hasBNet = false

        --[===[@debug@
        self:Printf("CheckHasListEntrys(%s)", key)
        --@end-debug@]===]

        for entryName, entryType in pairs(key_data.list ) do
            if entryType == self.LIST_ENTRY_TYPES.GUILD or entryType == self.LIST_ENTRY_TYPES.GUILD_REALM then
                hasGuild = true
            elseif entryType == self.LIST_ENTRY_TYPES.BNET_TAG then
                hasBNet = true
            end
            if hasGuild and hasBNet then
                break
            end
        end

        valueChanged = key_data.hasGuildListEntrys ~= hasGuild or key_data.hasBNetListEntrys ~= hasBNet or false

        key_data.hasGuildListEntrys = hasGuild
        key_data.hasBNetListEntrys = hasBNet
    end

    -- nil ~= false -> true
    if valueChanged ~= false then
        local hasGuild = false
        local hasBNet = false

        --[===[@debug@
        self:Print("CheckHasListEntrys - global")
        --@end-debug@]===]

        for keywordID, keyword in pairs(self.db.profile.keywords) do
            if keyword.hasGuildListEntrys then
                hasGuild = true
            end
            if keyword.hasBNetListEntrys then
                hasBNet = true
            end
            if hasBNet and hasGuild then
                break
            end
        end

        self.db.profile.hasGuildListEntrys = hasGuild
        self.db.profile.hasBNetListEntrys = hasBNet
    end
end


local optionHandler = {}
function optionHandler:Set(info, value, ...)
    local name = info[#info]
    WIA.db.profile[name] = value
end
function optionHandler:Get(info, value, ...)
    local name = info[#info]
    return WIA.db.profile[name]
end
function optionHandler:AddKeyword(info, value)
    local count = 0
    local cleanValue = gsub(value, "[%c\127]", "")
    local keywordID = cleanValue..count

    local keywords = WIA.db.profile.keywords
    while keywords[keywordID].name do
        count = count + 1
        keywordID = cleanValue..count
        --[===[@debug@
        WIA:Printf("Set keywordID to %s", keywordID)
        --@end-debug@]===]
        -- WARN: buffer-overflow check?...
    end

    keywords[keywordID].name = value
    if not keywords[keywordID].caseSensitive then
        keywords[keywordID].keyword = lower(value)
    else
        keywords[keywordID].keyword = value
    end
end
function optionHandler:GetEmptyString(info)
    return ""
end
function optionHandler:IsPlainMatchHidden(info, value)
    local parent = info[#info-1]

    return WIA.db.profile.keywords[parent].fullMatch
end
function optionHandler:IsCustomBlockMessageHidden(info, value)
    local parent = info[#info-1]

    return not WIA.db.profile.keywords[parent].showInviteBlockMessage
end
function optionHandler:KeywordSet(info, value)
    local name = info[#info]
    local parent = info.arg or info[#info-1]

    WIA.db.profile.keywords[parent][name] = value
end
function optionHandler:KeywordGet(info, value)
    local name = info[#info]
    local parent = info.arg or info[#info-1]

    return WIA.db.profile.keywords[parent][name]
end
function optionHandler:DeleteKeyword(info)
    local key = info.args or info[#info-1]

    WIA.db.profile.keywords[key] = nil
end
function optionHandler:SetChannel(info, name, value)
    local parent = info[#info]
    local key = info[#info-1]

    if value then
        local channelTyp = parent == "bnet_channels" and CT_BNET or CT_NORMAL

        WIA:RegisterChannel(name, channelTyp, key)
    else
        WIA:UnregisterChannel(name, key)
    end

    WIA.db.profile.keywords[key][parent][name] = value
end
function optionHandler:GetChannel(info, name, value)
    local parent = info[#info]
    local key = info[#info-1]

    return WIA.db.profile.keywords[key][parent][name]
end
do
    local cacheChanged = {}
    function optionHandler:ChangeMultiselectValues(info, value)
        local name = info[#info]
        local scope = info.arg or "global"

        WIA.db[scope][name][value] = type(WIA.db[scope][name][value]) ~= "nil" and true or nil

        cacheChanged[name] = true
    end

    local cache = {}
    function optionHandler:MultiselectValues(info)
        local name = info[#info]
        local scope = info.arg or "global"

        if not cache[name] or cacheChanged[name] then
            cache[name] = wipe(cache[name] or {} )
            for channel in pairs(WIA.db[scope][name]) do
                cache[name][channel] = L[channel]
            end
            cacheChanged[name] = false
        end

        return cache[name]
    end
end
function optionHandler:SetCaseSensitive(info, value, ...)
    self:KeywordSet(info, value, ...)
    local parent = info.arg or info[#info-1]
    if value then
        WIA.db.profile.keywords[parent].keyword = WIA.db.profile.keywords[parent].name
    else
        WIA.db.profile.keywords[parent].keyword = lower(WIA.db.profile.keywords[parent].name)
    end
end
do
    local UnitName, BNGetInfo =
          UnitName, BNGetInfo

    local cache = {}

    local function getCacheIndex(info, startString, startCount)
        local index = type(startString) == "string" and startString or ""
        startCount = type(startCount) == "number" and startCount or #info

        for i=startCount, 1, -1 do
            index = index..info[i]
        end
        return index
    end

    function optionHandler:SetCache(info, value)
        local index = getCacheIndex(info)

        cache[index] = value
    end
    function optionHandler:GetCache(info)
        local index = getCacheIndex(info)
        if not cache[index] then
            cache[index] = cache[index] or info.arg
        end
        return cache[index]
    end

    local name
    local orgRealm
    local guild
    local bntag
    local bntagIDLen
    local nameRealmUsage
    local guildRealmUsage
    local bntagUsage

    function optionHandler:populateIsValidEntryStrings()
        name = UnitName("player")
        orgRealm = gsub(GetRealmName(), "%s", "")
        guild = GetGuildInfo("player")
        guild = ( type(guild) == "string" and len(guild) > 1 ) and guild or L["Guild Name"]
        bntag = select(2, BNGetInfo() )
        bntag = ( type(bntag) == "string" and len(bntag) > 5 ) and bntag or name.."#1234"
        --bntagIDLen = select(2, ("#"):split(bntag) ):len() or 4
        bntagIDLen = len( select(2, split("#", bntag) ) ) or 4
        nameRealmUsage = format(L["Usage: name-realm e.g: %s-%s"], name, orgRealm)
        guildRealmUsage = format(L["Usage: guild-realm e.g: %s-%s"], guild, orgRealm)
        bntagUsage = format(L["E.g: %s"], bntag)
    end

    function optionHandler:IsValidEntry(info, value)
        local index = getCacheIndex(info, "listEntryType", #info-1)
        local entryType = cache[index] or WIA.LIST_ENTRY_TYPES.PLAYER
        local result = true

        if entryType then
            if len(value) < 1 then
                result = L["No value entered."]
            elseif entryType == WIA.LIST_ENTRY_TYPES.PLAYER then
                if find(value, "-", nil, true) then
                    result = format(L["Use %s entry type."], L["PLAYER_REALM"])
                end
            elseif entryType == WIA.LIST_ENTRY_TYPES.PLAYER_REALM then
                if find(value, "-", nil, true) then
                    local _, realm = split("-", value, 2)
                    if find(realm, "%s") then
                        result = format(L["Realm can't have white-space characters. %s"], nameRealmUsage)
                    elseif len(realm) < 1 then
                        result = format(L["No realm entered. %s"], nameRealmUsage)
                    elseif find(realm, "-", nil, true) then
                        result = format(L["Realm can't have '-' characters. %s"], format(L["E.g: %s"], orgRealm) )
                    end
                else
                    result = format(L["No realm entered. %s"], nameRealmUsage)
                end
            elseif entryType == WIA.LIST_ENTRY_TYPES.GUILD then
                if find(value, "-", nil, true) then
                    result = format(L["Use %s entry type."], L["GUILD_REALM"])
                end
            elseif entryType == WIA.LIST_ENTRY_TYPES.GUILD_REALM then
                if find(value, "-", nil, true) then
                    local _, realm = split("-", value, 2)
                    if find(realm, "%s") then
                        result = format(L["Realm can't have white-space characters. %s"], guildRealmUsage)
                    elseif len(realm) < 1 then
                        result = format(L["No realm entered. %s"], guildRealmUsage)
                    elseif find(realm, "-", nil, true) then
                        result = format(L["Realm can't have '-' characters. %s"], format(L["E.g: %s"], orgRealm) )
                    end
                else
                    result = format(L["No realm entered. %s"], guildRealmUsage)
                end
            elseif entryType == WIA.LIST_ENTRY_TYPES.REALM then
                if find(value, "%s") then
                    result = format(L["Realm can't have white-space characters. %s"], format(L["E.g: %s"], orgRealm))
                elseif find(value, "-", nil, true) then
                    result = format( L["Realm can't have '-' characters. %s"], format(L["E.g: %s"], orgRealm))
                end
            elseif entryType == WIA.LIST_ENTRY_TYPES.BNET_TAG then
                if find(value, "#", nil, true) then
                    local tagName, id = split("#", value)
                    if len(tagName) < 1 or bntagIDLen ~= len(id) then
                        result = format(L["Incorrect Battle.net Tag. %s"], bntagUsage)
                    elseif not tonumber(id) then
                        result = format(L["Incorrect Battle.net Tag. %s"], bntagUsage)
                    end
                else
                    result = format(L["Incorrect Battle.net Tag. %s"], bntagUsage)
                end
            elseif entryType == WIA.LIST_ENTRY_TYPES_REMOVE then
                local pass = 0 -- luacheck: ignore
            else
                result = false
            end
        else
            result = false
        end

        result = result or L["Entry is not valid."]
        if info.uiType == "dialog" and type(result) == "string" then
            -- NOTE: remove this when AceConfigDialog has a implementation
            WIA:Printf("%s: %s", info.option.name or L["Input"], result)
        end
        return result
    end
    function optionHandler:AddListEntry(info, value)
        local key = info.arg or info[#info-1]
        --local name = info[#info]
        local index = getCacheIndex(info, "listEntryType", #info-1)

        if cache[index] == WIA.LIST_ENTRY_TYPES_REMOVE then
            WIA.db.profile.keywords[key].list[value] = nil
        else
            WIA.db.profile.keywords[key].list[value] = cache[index] or WIA.LIST_ENTRY_TYPES.PLAYER
        end

        WIA:CheckHasListEntrys(key)
    end
end


local options = {
    type = "group",
    childGroups = "select",
    inline = true,
    name = L["WisperInvite Advanced Settings"],
    handler = optionHandler,
    set = "Set",
    get = "Get",
    args = {
    },
}

local SELECT_LIST_TYPES = {}
for key, value in pairs(WIA.LIST_TYPES) do
    SELECT_LIST_TYPES[value] = L[key]
end
local SELECT_LIST_ENTRY_TYPES = {}
for key, value in pairs(WIA.LIST_ENTRY_TYPES) do
    SELECT_LIST_ENTRY_TYPES[value] = L[key]
end
SELECT_LIST_ENTRY_TYPES[WIA.LIST_ENTRY_TYPES_REMOVE] = L["LIST_ENTRY_TYPES_REMOVE"]

function WIA:GetKeywordStringID(keywordID)
    local data = self.db.profile.keywords[keywordID]

    local stringID = data.active and L["A "] or ""
    stringID = stringID .. (data.caseSensitive and L["CS "] or "")
    stringID = stringID .. (data.fullMatch and L["FM "] or "")
    stringID = stringID .. ( (not data.fullMatch and data.plainMatch) and L["PF "] or "" )
    stringID = stringID .. format(L["G%s "], data.maxGroupSize)
    if next(data.list) then
        local count = 0
        for k in pairs(data.list) do
            count = count + 1
        end
        if data.listType == self.LIST_TYPES.ALLOW then
            stringID = stringID .. format(L["A%s"], count)
        elseif data.listType == self.LIST_TYPES.BLOCK then
            stringID = stringID .. format(L["B%s"], count)
        end
    end


    return stringID
end

function WIA.GetOptionsTable(uiType, uiName)
    local self = WIA

    --Build up keywords list
    for index, data in pairs(self.db.profile.keywords) do
        options.args[index] = options.args[index] or {}

        options.args[index].type = "group"

        local stringID = self:GetKeywordStringID(index)
        options.args[index].name = format(L["%s - %s"], data.name or data.keyword or index, stringID)
        options.args[index].desc = stringID
        options.args[index].childGroups = "tab"
        options.args[index].set = "KeywordSet"
        options.args[index].get = "KeywordGet"
        options.args[index].args = options.args[index].args or {}


        options.args[index].args.active = options.args[index].args.active or {}
        options.args[index].args.active.type = "toggle"
        options.args[index].args.active.name = L["Active"]
        options.args[index].args.active.desc = L["Is this keyword in use."]
        options.args[index].args.active.order = 0


        options.args[index].args.caseSensitive = options.args[index].args.caseSensitive or {}
        options.args[index].args.caseSensitive.type = "toggle"
        options.args[index].args.caseSensitive.name = L["Case sensitive"]
        options.args[index].args.caseSensitive.desc = L["Case sensitive keyword matching."]
        options.args[index].args.caseSensitive.set = "SetCaseSensitive"
        options.args[index].args.caseSensitive.order = 1


        options.args[index].args.fullMatch = options.args[index].args.fullMatch or {}
        options.args[index].args.fullMatch.type = "toggle"
        options.args[index].args.fullMatch.name = L["Full match"]
        options.args[index].args.fullMatch.desc = L["Message has to exactly match with the keyword."]
        options.args[index].args.fullMatch.order = 2


        options.args[index].args.plainMatch = options.args[index].args.plainMatch or {}
        options.args[index].args.plainMatch.type = "toggle"
        options.args[index].args.plainMatch.name = L["Pattern free matching"]
        options.args[index].args.plainMatch.desc = L["Without pattern matching."]
        options.args[index].args.plainMatch.hidden = "IsPlainMatchHidden"
        options.args[index].args.plainMatch.order = 3


        options.args[index].args.maxGroupSize = options.args[index].args.maxGroupSize or {}
        options.args[index].args.maxGroupSize.type = "range"
        options.args[index].args.maxGroupSize.name = L["Maximal group size"]
        options.args[index].args.maxGroupSize.desc = L["The size the group can reach before this keyword stops to invite."]
        options.args[index].args.maxGroupSize.min = 2
        options.args[index].args.maxGroupSize.max = 40
        options.args[index].args.maxGroupSize.step = 1
        options.args[index].args.maxGroupSize.order = 4


        options.args[index].args.showInviteBlockMessage = options.args[index].args.showInviteBlockMessage or {}
        options.args[index].args.showInviteBlockMessage.type = "toggle"
        options.args[index].args.showInviteBlockMessage.name = L["Show block message"]
        options.args[index].args.showInviteBlockMessage.desc = L["Show a message when a invite is blocked because of filtering."]
        options.args[index].args.showInviteBlockMessage.order = 5


        options.args[index].args.customBlockMessage = options.args[index].args.customBlockMessage or {}
        options.args[index].args.customBlockMessage.type = "input"
        options.args[index].args.customBlockMessage.name = L["Custom block message"]
        options.args[index].args.customBlockMessage.desc = L["Display this custom message when a invite is blocked."]
        options.args[index].args.customBlockMessage.hidden = "IsCustomBlockMessageHidden"
        options.args[index].args.customBlockMessage.order = 6


        options.args[index].args.delete = options.args[index].args.delete or {}
        options.args[index].args.delete.type = "execute"
        options.args[index].args.delete.name = L["Delete"]
        options.args[index].args.delete.desc = L["Remove this keyword."]
        options.args[index].args.delete.func = "DeleteKeyword"
        options.args[index].args.delete.confirm = true
        options.args[index].args.delete.confirmText = format(L["Do you really want to remove the keyword %q?"], data.name or data.keyword or index)
        options.args[index].args.delete.order = 6.5


        options.args[index].args.channels = options.args[index].args.channels or {}
        options.args[index].args.channels.type = "multiselect"
        options.args[index].args.channels.name = L["Channels"]
        options.args[index].args.channels.desc = L["Channels where message will be checked for invite keywords."]
        options.args[index].args.channels.set = "SetChannel"
        options.args[index].args.channels.get = "GetChannel"
        options.args[index].args.channels.values = "MultiselectValues"
        options.args[index].args.channels.order = 8


        options.args[index].args.bnet_channels = options.args[index].args.bnet_channels or {}
        options.args[index].args.bnet_channels.type = "multiselect"
        options.args[index].args.bnet_channels.name = L["Battle.net Channels"]
        options.args[index].args.bnet_channels.desc = L["Battle.net Channels where message will be checked for invite keywords."]
        options.args[index].args.bnet_channels.set = "SetChannel"
        options.args[index].args.bnet_channels.get = "GetChannel"
        options.args[index].args.bnet_channels.values = "MultiselectValues"
        options.args[index].args.bnet_channels.order = 9


        options.args[index].args.filter = options.args[index].args.filter or {}
        options.args[index].args.filter.type = "group"
        options.args[index].args.filter.name = L["Filtering"]
        options.args[index].args.filter.order = 10
        options.args[index].args.filter.args = options.args[index].args.filter.args or {}

        options.args[index].args.filter.args.listType = options.args[index].args.filter.args.listType or {}
        options.args[index].args.filter.args.listType.type = "select"
        options.args[index].args.filter.args.listType.name = L["Filter type"]
        options.args[index].args.filter.args.listType.desc = format(L["Choose which way the filter work.\n|cFF70DBFF%s:|r Allow any where is not on the list\n|cFF70DBFF%s:|r Allow only where is on the list"], L["BLOCK"], L["ALLOW"])
        options.args[index].args.filter.args.listType.arg = index
        options.args[index].args.filter.args.listType.values = SELECT_LIST_TYPES
        options.args[index].args.filter.args.listType.order = 0

        options.args[index].args.filter.args.listEntryType = options.args[index].args.filter.args.listEntryType or {}
        options.args[index].args.filter.args.listEntryType.type = "select"
        options.args[index].args.filter.args.listEntryType.name = L["Entry Type"]
        options.args[index].args.filter.args.listEntryType.desc = format(L["Choose which Type of filter you want to add, all entries are case sensitive.\n\n|cFF70DBFF%s:|r Filter only on playername \n|cFF70DBFF%s:|r Filter on playername and realm\n|cFF70DBFF%s:|r Filter on guild (this will mostly only work with player of your realm)\n|cFF70DBFF%s:|r Filter on guild and realm \n|cFF70DBFF%s:|r Filter player on realm\n|cFF70DBFF%s:|r Filter player on Battle.net Tag (this work only with yours Battle.net friends. This will save Battle.net Tags to your SavedVariables for caching.)\n|cFF70DBFF%s:|r Enter an existing filter to remove."], L["PLAYER"], L["PLAYER_REALM"], L["GUILD"], L["GUILD_REALM"], L["REALM"], L["BNET_TAG"], L["LIST_ENTRY_TYPES_REMOVE"])
        options.args[index].args.filter.args.listEntryType.values = SELECT_LIST_ENTRY_TYPES
        options.args[index].args.filter.args.listEntryType.set = "SetCache"
        options.args[index].args.filter.args.listEntryType.get = "GetCache"
        options.args[index].args.filter.args.listEntryType.arg = WIA.LIST_ENTRY_TYPES.PLAYER
        options.args[index].args.filter.args.listEntryType.order = 1

        options.args[index].args.filter.args.list = options.args[index].args.filter.args.list or {}
        options.args[index].args.filter.args.list.type = "input"
        options.args[index].args.filter.args.list.name = L["Entry"]
        options.args[index].args.filter.args.list.desc = L["All entry are case sensitive."]
        options.args[index].args.filter.args.list.validate = "IsValidEntry"
        options.args[index].args.filter.args.list.set = "AddListEntry"
        options.args[index].args.filter.args.list.get = "GetEmptyString"
        options.args[index].args.filter.args.list.arg = index
        options.args[index].args.filter.args.list.order = 2

        local entryIndexCount = 1
        for entryName, entryType in pairs(data.list) do
            options.args[index].args.filter.args[entryName] = options.args[index].args.filter.args[entryName] or {}
            options.args[index].args.filter.args[entryName].type = "description"
            options.args[index].args.filter.args[entryName].name = format(L["%s Filter: %s"], L[SELECT_LIST_ENTRY_TYPES[entryType]], entryName)
            options.args[index].args.filter.args[entryName].desc = format(L["Type: %s"], L[entryType])
            options.args[index].args.filter.args[entryName].fontSize = "medium"
            options.args[index].args.filter.args[entryName].width = "full"
            options.args[index].args.filter.args[entryName].order = 3+0.1*entryIndexCount

            entryIndexCount = entryIndexCount + 1
        end
        for entryIndex in pairs(options.args[index].args.filter.args) do
            if entryIndex ~= "listType" and entryIndex ~= "listEntryType" and entryIndex ~= "list" then
                if not data.list[entryIndex] then
                    options.args[index].args.filter.args[entryIndex] = nil
                end
            end
        end


        --options.args[index]
    end

    --remove unused keywords
    for index in pairs(options.args) do
        if not self.db.profile.keywords[index].name and index ~= "addKeyword123456" then
            options.args[index] = nil
        end
    end

    options.args.addKeyword123456 = options.args.addKeyword123456 or {}
    options.args.addKeyword123456.type = "input"
    options.args.addKeyword123456.name = L["Add keyword"]
    options.args.addKeyword123456.desc = L["Add a new keyword."]
    options.args.addKeyword123456.set = "AddKeyword"
    options.args.addKeyword123456.get = "GetEmptyString"
    options.args.addKeyword123456.order = 0

    return options
end

function WIA:RegisterConfig()
    local skip = true -- luacheck: ignore
    --[===[@debug@
    skip = false
    --@end-debug@]===]

    optionHandler:populateIsValidEntryStrings()

    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable(ADDONNAME.."Options", WIA.GetOptionsTable, skip)

    core:AddModuleConfig(ADDONNAME.."Options", L["Advanced"])
end

