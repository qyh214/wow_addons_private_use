local ADDONNAME, WICB = ...
local corename = "WhisperInvite"
-- luacheck: globals LibStub WhisperInviteBasicDB
local core = LibStub("AceAddon-3.0"):GetAddon(corename)

LibStub("AceAddon-3.0"):NewAddon(WICB, ADDONNAME, "AceConsole-3.0", "AceEvent-3.0")

local L = LibStub("AceLocale-3.0"):GetLocale(corename)

--local _G = _G
local tostring, find,    sub,    join,    gmatch =
      tostring, strfind, strsub, strjoin, string.gmatch
local type, select, pairs, wipe, unpack, tContains =
      type, select, pairs, wipe, unpack, tContains
local lower = string.utf8lower or strlower

local channelTypes = {
    normal = 1,
    bnet = 2,
}

local defaults = {
    global = {
        --channels = {},
        --bnet_channels = {},
    },
    profile = {
        caseSensitive = false,
        fullMatch = true,
        plainMatch = true,
        keywords = {},
        keywordsCaseCache = {},
        channels = {
            CHAT_MSG_GUILD = false,     -- L["CHAT_MSG_GUILD"] = "Guild"
            CHAT_MSG_OFFICER = false,   -- L["CHAT_MSG_OFFICER"] = "Guild officer"
            CHAT_MSG_WHISPER = true,    -- L["CHAT_MSG_WHISPER"] = "Whisper"
        },
        bnet_channels = {
            CHAT_MSG_BN_CONVERSATION = false,           -- L["CHAT_MSG_BN_CONVERSATION"] = "Chat"
            CHAT_MSG_BN_INLINE_TOAST_BROADCAST = false, -- L["CHAT_MSG_BN_INLINE_TOAST_BROADCAST"] = "Status"
            CHAT_MSG_BN_WHISPER = true,                 -- L["CHAT_MSG_BN_WHISPER"] = "Whisper"
        },
    },
}

function WICB:OnInitialize()
    self.db = core:RegisterNamespace("WhisperInviteBasicDB", defaults)

    self.db.RegisterCallback(self, "OnProfileChanged", "ResetCache")
    self.db.RegisterCallback(self, "OnProfileCopied", "ResetCache")

    -- NOTE: remove later
    if type(WhisperInviteBasicDB) == "table" and ( type(WhisperInviteBasicDB.global) == "table" and not WhisperInviteBasicDB.global.imported or true ) then
        local oldProfile = LibStub("AceDB-3.0"):New("WhisperInviteBasicDB", defaults, true).profile
        local profile = self.db.profile

        profile.caseSensitive       = oldProfile.caseSensitive
        profile.fullMatch           = oldProfile.fullMatch
        profile.plainMatch          = oldProfile.plainMatch
        profile.keywords            = oldProfile.keywords
        profile.keywordsCaseCache   = oldProfile.keywordsCaseCache
        profile.channels            = oldProfile.channels
        profile.bnet_channels       = oldProfile.bnet_channels

        WhisperInviteBasicDB.global = WhisperInviteBasicDB.global or {}
        WhisperInviteBasicDB.global.imported = true
    end

    self:RegisterConfig()
end

function WICB:OnEnable()
    self:RegisterAllChannels()
end

function WICB:OnDisable()

    self:UnregisterAllChannels()
end

function WICB:RegisterAllChannels()
    if not self:IsEnabled() then return end

    local profile = self.db.profile

    for channel, active in pairs(profile.channels) do
        if active then
            self:RegisterChannel(channel)
        end
    end
    for channel, active in pairs(profile.bnet_channels) do
        if active then
            self:RegisterBNetChannel(channel)
        end
    end
end

local registeredChannels = {}
function WICB:RegisterChannel(channel)
    if not self:IsEnabled() then return end
    self:RegisterEvent(channel, "MessageIn", channelTypes.normal)
    registeredChannels[lower(channel)] = true
    --[===[@debug@
    self:Printf("RegisterChannel: %s", channel)
    --@end-debug@]===]
end

local registeredBNetChannels = {}
function WICB:RegisterBNetChannel(channel)
    if not self:IsEnabled() then return end
    self:RegisterEvent(channel, "MessageIn", channelTypes.bnet)
    registeredBNetChannels[lower(channel)] = true
    --[===[@debug@
    self:Printf("RegisterBNetChannel: %s", channel)
    --@end-debug@]===]
end

function WICB:UnregisterAllChannels()
    for channel,registered in pairs(registeredChannels) do
        if registered then
            self:UnregisterChannel(channel)
        end
    end
    for channel,registered in pairs(registeredBNetChannels) do
        if registered then
            self:UnregisterBNetChannel(channel)
        end
    end
end

function WICB:UnregisterChannel(channel)
    self:UnregisterEvent(channel)
    registeredChannels[lower(channel)] = false
    --[===[@debug@
    self:Printf("UnregisterChannel: %s", channel)
    --@end-debug@]===]
end

function WICB:UnregisterBNetChannel(channel)
    self:UnregisterEvent(channel)
    registeredBNetChannels[lower(channel)] = false
    --[===[@debug@
    self:Printf("UnregisterBNetChannel: %s", channel)
    --@end-debug@]===]
end

function WICB:MessageIn(channelType, event,  ...)
    if not self:IsEnabled() then return end
    local msg = ...

    --[===[@debug@
    self:Printf("MessageIn: %q->%s", tostring(msg), tostring(channelType) )
    --@end-debug@]===]

    if self:KeywordMatch(msg) then
        local result, code
        if channelType == channelTypes.normal then
            local _, name = ...
            result, code = core:InvitePlayer(name)
        elseif channelType == channelTypes.bnet then
            --local presenceID = select(13, ...)
            local _, _, _, _, _, _, _, _, _, _, _, _, presenceID = ...
            result, code = core:InviteBNet(presenceID)
        end
        --[===[@debug@
        self:Printf("Invite Sent: %s", result and "OK" or "Error: "..code )
        --@end-debug@]===]
    end
end

function WICB:KeywordMatch(msg)
    local profile = self.db.profile
    if not profile.caseSensitive then
        msg = lower(msg)
    end

    if profile.fullMatch then
        -- because false is better as nil^^
        return not not tContains(profile.keywords, msg)
        --return profile.keywords[msg]
    else
        local plainMatch = profile.plainMatch
        if not plainMatch then
            msg = " "..msg.." "
        end
        for _, keyword in pairs(profile.keywords) do
            if find(msg, keyword, nil, plainMatch) then
                return true
            end
        end
    end

    return false
end

local optionHandler = {}
function optionHandler:Set(info, value, ...)
    local name = info[#info]
    WICB.db.profile[name] = value
end

function optionHandler:Get(info, value, ...)
    local name = info[#info]
    return WICB.db.profile[name]
end

function optionHandler:SetCaseSensitive(info, value, ...)
    self:Set(info, value, ...)
    if value then
        for i, keyword in pairs(WICB.db.profile.keywords) do
            WICB.db.profile.keywords[i] = WICB.db.profile.keywordsCaseCache[keyword] or keyword
        end
    else
        for i, keyword in pairs(WICB.db.profile.keywords) do
            local lowerKeyword = lower(keyword)
            WICB.db.profile.keywordsCaseCache[lowerKeyword] = keyword
            WICB.db.profile.keywords[i] = lowerKeyword
        end
    end

end

function optionHandler:IsPlainMatchHidden(info, value)
    return WICB.db.profile.fullMatch
end

do
    local cacheChanged = {}
    function optionHandler:ChangeMultiselectValues(info, value)
        local name = info[#info]

        WICB.db.profile[name][value] = type(WICB.db.profile[name][value]) == nil and true or nil

        cacheChanged[name] = true
    end

    local cache = {}
    function optionHandler:MultiselectValues(info)
        local name = info[#info]

        if not cache[name] or cacheChanged[name] then
            cache[name] = wipe(cache[name] or {} )
            for channel in pairs(WICB.db.profile[name]) do
                cache[name][channel] = L[channel]
            end
            cacheChanged[name] = false
        end

        return cache[name]
    end
end

function optionHandler:GetMultiselect(info, ...)
    local key = select(select('#', ...), ...)
    local name = info[#info]

    return WICB.db.profile[name][key]
end

function optionHandler:SetMultiselect(info, key, ...)
    local value = select(select('#', ...), ...)
    local name = info[#info]

    WICB.db.profile[name][key] = value
end

function optionHandler:SetChannel(info, key, ...)
    self:SetMultiselect(info, key, ...)

    if registeredChannels[lower(key)] then
        WICB:UnregisterChannel(key)
    elseif registeredBNetChannels[lower(key)] then
        WICB:UnregisterBNetChannel(key)
    else
        if lower( sub(key, 0, 12) ) == "chat_msg_bn_" then
            WICB:RegisterBNetChannel(key)
        else
            WICB:RegisterChannel(key)
        end
    end
end

do
    local cacheChanged = {}
    function optionHandler:SetMultilineText(info, value, ...)
        local name = info[#info]

        local profile = WICB.db.profile
        local i = 1
        local n = #profile[name]
        for key in gmatch(value, "[^\n]+") do
            if name == "keywords" and not profile.caseSensitive then
                local orgKey = tostring(key)
                key = lower(orgKey)

                profile.keywordsCaseCache[key] = orgKey
            end
            profile[name][i] = tostring(key)
            i = i+1
        end
        for j=i, n do
            profile[name][j] = nil
        end
        cacheChanged[name] = true
    end

    local cache = {}
    function optionHandler:GetMultilineText(info, ...)
        local name = info[#info]

        if cacheChanged[name] or not cache[name] then
            cache[name] = join("\n", unpack(WICB.db.profile[name]) )
            cacheChanged[name] = false
        end

        return cache[name]
    end

    function WICB:ResetCache()
        wipe(cache)
        wipe(cacheChanged)
    end
end

local options = {
    type = "group",
    name = L["WhisperInvite Basic Settings"],
    handler = optionHandler,
    set = "Set",
    get = "Get",
    args = {
        caseSensitive = {
            type = "toggle",
            name = L["Case sensitive"],
            desc = L["Case sensitive keyword matching."],
            set = "SetCaseSensitive",
            order = 1,
        },
        fullMatch = {
            type = "toggle",
            name = L["Full match"],
            desc = L["Message has to exactly match with the keyword."],
            order = 2,
        },
        plainMatch = {
            type = "toggle",
            name = L["Pattern free matching"],
            desc = L["Without pattern matching."],
            hidden = "IsPlainMatchHidden",
            order = 3,
        },

        keywords = {
            type = "input",
            name = L["Keywords"],
            desc = L["Add here your invite keywords, one per line."],
            multiline = 5,
            set = "SetMultilineText",
            get = "GetMultilineText",
            width = "full",
            order = 4,
        },

        channels = {
            type = "multiselect",
            name = L["Channels"],
            desc = L["Channels where message will be checked for invite keywords."],
            values = "MultiselectValues",
            get = "GetMultiselect",
            set = "SetChannel",
            order = 5.1,
        },
        bnet_channels = {
            type = "multiselect",
            name = L["Battle.net Channels"],
            desc = L["Battle.net Channels where message will be checked for invite keywords."],
            values = "MultiselectValues",
            get = "GetMultiselect",
            set = "SetChannel",
            order = 5.2,
        },
    },
}

function WICB:RegisterConfig()
    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable(ADDONNAME.."Options", options)

    core:AddModuleConfig(ADDONNAME.."Options", L["Basic"])
end



