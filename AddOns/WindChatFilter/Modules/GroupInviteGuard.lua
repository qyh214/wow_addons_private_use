local W, F, L = unpack(select(2, ...))
local GIG = W:NewModule("GroupInviteGuard", "AceEvent-3.0")
local CORE = W:GetModule("Core")
local C = W.Utilities.Color

local format = format
local gsub = gsub
local pairs = pairs
local strfind = strfind

local Ambiguate = Ambiguate
local IsGuildMember = IsGuildMember
local StaticPopup_Hide = StaticPopup_Hide

local C_BattleNet_GetAccountInfoByGUID = C_BattleNet.GetAccountInfoByGUID
local C_FriendList_IsFriend = C_FriendList.IsFriend

local ERR_INFORM_SUGGEST_INVITE_SS = ERR_INFORM_SUGGEST_INVITE_SS
local ERR_INVITED_ALREADY_IN_GROUP_SS = ERR_INVITED_ALREADY_IN_GROUP_SS
local ERR_REQUESTED_INVITE_TO_GROUP_SS = ERR_REQUESTED_INVITE_TO_GROUP_SS

local smartModeNames = {
    ["打團"] = true,
    ["打团"] = true,
    ["打本"] = true,
    ["打副"] = true,
    ["专车"] = true,
    ["代你"] = true,
    ["代充"] = true,
    ["代刷"] = true,
    ["代打"] = true,
    ["代練"] = true,
    ["代练"] = true,
    ["团木"] = true,
    ["团本"] = true,
    ["团长"] = true,
    ["團木"] = true,
    ["團本"] = true,
    ["團長"] = true,
    ["大密"] = true,
    ["大秘"] = true,
    ["大米"] = true,
    ["完美"] = true,
    ["密境"] = true,
    ["專車"] = true,
    ["带你"] = true,
    ["带刷"] = true,
    ["帶你"] = true,
    ["帶刷"] = true,
    ["找我"] = true,
    ["提升"] = true,
    ["毕业"] = true,
    ["消費"] = true,
    ["消费"] = true,
    ["清水"] = true,
    ["畢業"] = true,
    ["秘境"] = true,
    ["秘境"] = true,
    ["米境"] = true,
    ["装备"] = true,
    ["裝備"] = true,
    ["静思"] = true,
    ["靜思"] = true
}

local suggestInvitePattern = string.gsub(_G.ERR_INFORM_SUGGEST_INVITE_SS, "%%%d$s", "(.+)")
local linkedPlayers = {}
local whisperedTarget = {}
local declinedPlayers = {}

---------------------------------------------------------------
-- author: 艾德帕拉丁
-- copied from https://wago.io/w5brqr3O5

local pattern_normal_invite = ERR_INVITED_TO_GROUP_SS:gsub("|Hplayer:%%s|h%[%%s%]|h", "([^[]+)%]|h")
local pattern_suggest = ERR_INFORM_SUGGEST_INVITE_SS:gsub("%%%d%$s", "(%%S+)")
local pattern_already_in_group = ERR_INVITED_ALREADY_IN_GROUP_SS:gsub("|Hplayer:%%s|h%[%%s%]|h", "([^[]+)%]|h")
local pattern_requested_invite = ERR_REQUESTED_INVITE_TO_GROUP_SS:gsub("|Hplayer:%%s|h%[%%s%]|h", "([^[]+)%]|h")

local already_in_group_sound_ids = {
    540778,
    540579,
    539901,
    539839,
    540984,
    540941,
    1304803,
    1304506,
    540356,
    540287,
    539481,
    539729,
    542176,
    542100,
    541614,
    541541,
    630112,
    636441,
    4758265,
    4758551,
    4758408,
    4758694,
    1733045,
    1732667,
    1731540,
    1731166,
    1902444,
    1901931,
    2492003,
    2531020,
    3107099,
    3107568,
    541298,
    541222,
    542659,
    542585,
    542952,
    542862,
    543174,
    543146,
    539218,
    539307,
    1306400,
    1284665,
    541880,
    541795,
    1732288,
    1731914,
    1730792,
    1730418,
    1950981,
    1950980,
    1903470,
    1902957,
    3106634,
    3106169
}

local function MuteSounds(isAlreadyInGroup)
    if isAlreadyInGroup then
        for _, v in ipairs(already_in_group_sound_ids) do
            MuteSoundFile(v)
        end
    else
        MuteSoundFile(567490)
        MuteSoundFile(567451)
    end
end

local function UnmuteSounds(isAlreadyInGroup)
    if isAlreadyInGroup then
        for _, v in ipairs(already_in_group_sound_ids) do
            UnmuteSoundFile(v)
        end
    else
        UnmuteSoundFile(567490)
        UnmuteSoundFile(567451)
        UnmuteSoundFile(567464)
    end
end
---------------------------------------------------------------

function GIG:Reject(name, type)
    self:Log("debug", "Rejected group invitation from player: " .. name)

    if self.db.displayMessageAfterRejecting and declinedPlayers[name] ~= true then
        local message = format(L["Rejected group invitation from %s."], C.StringByTemplate(name, "info"))
        if self.db.allowWhisperedTarget then
            message =
                message .. " " .. L["You can whisper the player once to add him/her to the whitelist temporarily."]
        end
        F.Print(message)
        declinedPlayers[name] = true
    end

    MuteSoundFile(567464)

    if type == "party" then
        DeclineGroup()
        StaticPopup_Hide("PARTY_INVITE")
    elseif type == "confirmation" then
        StaticPopup_Hide("GROUP_INVITE_CONFIRMATION")
    elseif type == "lfg" and _G.LFGInvitePopup then
        DeclineGroup()
        StaticPopupSpecial_Hide(_G.LFGInvitePopup)
    end

    UnmuteSoundFile(567464)
end

-- merged some logic from https://wago.io/w5brqr3O5
function GIG:RequestHandler(_, name, tank, healer, damage, _, isConfirmation, guid)
    if not self.db.enabled then
        return
    end

    if not guid or guid == "" or guid == W.myGUID then
        return
    end

    local inviteType = "party"
    if isConfirmation then
        inviteType = "confirmation"
    elseif tank or healer or damage then
        inviteType = "lfg"
    end

    local isGuildMember = IsGuildMember(guid)
    local isFriend = C_FriendList_IsFriend(guid)
    local isBNFriend = C_BattleNet_GetAccountInfoByGUID(guid) ~= nil

    local ambiguatedName = Ambiguate(name, "none")
    local playerInfo = F.FetchPlayerInfo(guid)

    if self.db.allowWhisperedTarget then
        if whisperedTarget[ambiguatedName] then
            return
        end
    end

    if self.db.onlyFriendsOrGuildMembers then
        if not (isGuildMember or isFriend or isBNFriend) then
            self:Reject(name, inviteType)
        end
    end

    if self.db.smartMode then
        if not (isGuildMember or isFriend or isBNFriend) then
            local playerInfo = F.FetchPlayerInfo(guid)

            if playerInfo and playerInfo.race == "Pandaren" and playerInfo.class == "DEATHKNIGHT" then
                self:Reject(name, inviteType)
            end

            for namePattern, _ in pairs(smartModeNames) do
                if strfind(name, namePattern) then
                    self:Reject(name, inviteType)
                    break
                end
            end

            if linkedPlayers[name] then
                for linkedName, _ in pairs(linkedPlayers[name]) do
                    for namePattern, _ in pairs(smartModeNames) do
                        if strfind(linkedName, namePattern) then
                            self:Reject(format("%s (%s)", name, linkedName), inviteType)
                            break
                        end
                    end
                end
            end
        end
    end

    if self.db.chatFilterMode then
        local nameForChatFilter = name
        if linkedPlayers[name] then
            for linkedName, _ in pairs(linkedPlayers[name]) do
                nameForChatFilter = nameForChatFilter .. " " .. linkedName
            end
        end

        local result, filterName = W:GetModule("Core"):GetChatFilterResult(nameForChatFilter, guid)
        if result then
            self:Reject(name, inviteType)
        end
    end
end

function GIG:LinkPlayers(_, message)
    local inviter, leader

    gsub(
        message,
        suggestInvitePattern,
        function(...)
            inviter, leader = ...
        end
    )

    if inviter and leader then
        if not linkedPlayers[inviter] then
            linkedPlayers[inviter] = {}
        end

        linkedPlayers[inviter][leader] = true

        if not linkedPlayers[leader] then
            linkedPlayers[leader] = {}
        end

        linkedPlayers[leader][inviter] = true
    end
end

function GIG:RecordWhisperedTarget(_, _, playerName)
    if playerName then
        whisperedTarget[Ambiguate(playerName, "none")] = true
    end
end

function GIG:OnInitialize()
    self.db = W.db.groupInviteGuard

    if not self.db.enabled then
        UnmuteSounds()
        return
    end

    CORE:RegisterBlackList(
        "GroupInviteGuard",
        {
            priority = -1000,
            func = function(data)
                if data.channel and data.channel == "System" then
                    if data.message:match(pattern_normal_invite) then
                        local inviter = data.message:match(pattern_normal_invite)
                        if declinedPlayers[inviter] then
                            return true
                        end
                    elseif data.message:match(pattern_suggest) then
                        local suggester, inviter = data.message:match(pattern_suggest)
                        if declinedPlayers[inviter] or declinedPlayers[suggester] then
                            return true
                        end
                    elseif data.message:match(pattern_already_in_group) then
                        local inviter = data.message:match(pattern_already_in_group)
                        if declinedPlayers[inviter] then
                            return true
                        end
                    elseif data.message:match(pattern_requested_invite) then
                        local inviter = data.message:match(pattern_requested_invite)
                        if declinedPlayers[inviter] then
                            return true
                        end
                    end

                    return false
                end
            end
        }
    )

    MuteSounds()

    if self.db.muteAlreadyInGroupSound then
        MuteSounds(true)
    else
        UnmuteSounds(true)
    end

    self:RegisterEvent("PARTY_INVITE_REQUEST", "RequestHandler")
    self:RegisterEvent(
        "GROUP_INVITE_CONFIRMATION",
        function()
            local _, name, guid = GetInviteConfirmationInfo(GetNextPendingInviteConfirmation())
            self:RequestHandler(nil, name, nil, nil, nil, true, guid)
        end
    )
    self:RegisterEvent("CHAT_MSG_SYSTEM", "LinkPlayers")
    self:RegisterEvent("CHAT_MSG_WHISPER_INFORM", "RecordWhisperedTarget")

    self.initialized = true
end

function GIG:ProfileUpdate()
    self.db = W.db.groupInviteGuard

    if self.db.enabled and not self.initialized then
        return self:OnInitialize()
    end

    if self.db.enabled and self.db.muteAlreadyInGroupSound then
        MuteSounds(true)
    else
        UnmuteSounds(true)
    end
end
