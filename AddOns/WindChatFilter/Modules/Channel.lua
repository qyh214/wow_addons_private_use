local W, F, L = unpack(select(2, ...))
local CORE = W:GetModule("Core")

local next = next
local pairs = pairs
local strfind = strfind

local tradeChannelNames = {
    "^Trade",
    "^交易"
}

local generalChannelNames = {
    "^General",
    "^綜合",
    "^综合"
}

local newcomerChannelNames = {
    "Newcommer Chat",
    "新人频道",
    "新手聊天",
    "新手頻道"
}

local availableConfigKeys = {
    "battleground",
    "emote",
    "general",
    "guild",
    "instance",
    "party",
    "raid",
    "say",
    "trade",
    "whisper",
    "yell"
}

local function getChannelFilter(rule)
    if not rule.channel or not rule.channel.enabled then
        return nil
    end

    local configIsVaild = false
    for _, key in pairs(availableConfigKeys) do
        if rule.channel[key] then
            configIsVaild = true
            break
        end
    end

    if rule.channel.channelNames and next(rule.channel.channelNames) then
        configIsVaild = true
    end

    if not configIsVaild then
        return nil
    end

    return function(data)
        if not data.channel then
            return false
        end

        if rule.channel.say and data.channel == "Say" then
            return true
        end

        if rule.channel.yell and data.channel == "Yell" then
            return true
        end

        if rule.channel.whisper and data.channel == "Whisper" then
            return true
        end

        if rule.channel.emote and data.channel == "Emote" then
            return true
        end

        if rule.channel.guild and data.channel == "Guild" then
            return true
        end

        if rule.channel.party and data.channel == "Party" then
            return true
        end

        if rule.channel.instance and data.channel == "Instance" then
            return true
        end

        if rule.channel.raid and data.channel == "Raid" then
            return true
        end

        if rule.channel.battleground and data.channel == "Battleground" then
            return true
        end

        if rule.channel.trade then
            for _, name in pairs(tradeChannelNames) do
                if strfind(data.channel, name) then
                    return true
                end
            end
        end

        if rule.channel.general then
            for _, name in pairs(generalChannelNames) do
                if strfind(data.channel, name) then
                    return true
                end
            end
        end

        if rule.channel.newcomer then
            for _, name in pairs(newcomerChannelNames) do
                if data.channel == name then
                    return true
                end
            end
        end

        if rule.channel.channelNames then
            for name, _ in pairs(rule.channel.channelNames) do
                if strfind(data.channel, name) then
                    return true
                end
            end
        end

        return false
    end
end

CORE:RegisterRuleParser("Channel", getChannelFilter)
