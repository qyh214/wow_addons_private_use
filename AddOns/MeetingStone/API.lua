
BuildEnv(...)

local AceSerializer = LibStub('AceSerializer-3.0')

function GetClassColorText(className, text)
    local color = RAID_CLASS_COLORS[className]
    return format('|c%s%s|r', color.colorStr, text)
end

function IsGroupLeader()
    return  not IsInGroup(LE_PARTY_CATEGORY_HOME) or UnitIsGroupLeader('player', LE_PARTY_CATEGORY_HOME)
end

function IsActivityManager()
    return UnitIsGroupLeader('player', LE_PARTY_CATEGORY_HOME) or (IsInRaid(LE_PARTY_CATEGORY_HOME) and UnitIsGroupAssistant('player', LE_PARTY_CATEGORY_HOME))
end

function ToggleCreatePanel(activityID)
    MainPanel:SelectPanel(ManagerPanel)
    if not CreatePanel:IsActivityCreated() then
        CreatePanel:SelectActivity(activityID)
    end
end

function GetPlayerClass()
    return (select(3, UnitClass('player')))
end

function GetPlayerItemLevel()
    return floor(GetAverageItemLevel())
end

function DecodeCommetData(comment)
    if not comment or comment == '' then
        return nil
    end
    local summary, data = comment:match('^(.*)%((.+)%)$')
    if data then
        return summary, AceSerializer:Deserialize(data)
    else
        return comment
    end
end

function CodeCommentData(activity)
    local activityID = activity:GetActivityID()
    local data = format('(%s)', AceSerializer:Serialize(
        activity:GetActivityType(),
        ADDON_VERSION_SHORT,
        activity:GetActivityMode(),
        activity:GetActivityLoot(),
        GetPlayerClass(),
        GetPlayerItemLevel(),
        GetPlayerRaidProgression(activityID),
        GetPlayerPVPRating(activityID),
        activity:GetMinLevel(),
        activity:GetMaxLevel(),
        activity:GetPvPRating(),
        activity:GetSource(),
        GetPlayerFullName()))

    return data, strlenutf8(data)
end

function GetPlayerFullName()
    return format('%s-%s', UnitName('player'), GetRealmName())
end

function CodeDescriptionData(activity)
    if not activity:IsMeetingStone() then
        return nil, 0
    else
        local activityId = activity:GetActivityID()
        local data = format('(%s)', AceSerializer:Serialize(GetPlayerRaidProgression(activityId), GetPlayerPVPRating(activityId), GetAddonSource()))
        return data, strlenutf8(data)
    end
end

function DecodeDescriptionData(description)
    if not description or description == '' then
        return
    end
    local summary, data = description:match('^(.*)%((.+)%)$')
    if data then
        return summary, AceSerializer:Deserialize(data)
    else
        return description
    end
end

function GetClassColoredText(class, text)
    if not class or not text then
        return text
    end
    local color = RAID_CLASS_COLORS[class]
    if color then
        return format('|c%s%s|r', color.colorStr, text)
    end
    return text
end

function GetActivityCode(activityId, customId, categoryId, groupId)
    if activityId and (not categoryId or not groupId) then
        categoryId, groupId = select(3, C_LFGList.GetActivityInfo(activityId))
    end
    return format('%d-%d-%d-%d', categoryId or 0, groupId or 0, activityId or 0, customId or 0)
end

function GetRaidBossNames(eventCode)
    return _RAID_DATA[eventCode].bossNames
end

local PVP_INDEXS = {
    [6] = 1,
    [7] = 1,
    [8] = 1,
    [19] = 2,
}

function IsHasPVPRating(activityID)
    return PVP_INDEXS[activityID]
end

function GetPlayerPVPRating(activityID)
    local ratingType = PVP_INDEXS[activityID]
    if not ratingType then
        return
    end

    if ratingType == 2 then
        return (GetPersonalRatedInfo(4))
    else
        return max((GetPersonalRatedInfo(1)), (GetPersonalRatedInfo(2)), (GetPersonalRatedInfo(3)))
    end
end

function GetPlayerBattleTag()
    return (select(2, BNGetInfo()))
end

function GetPlayerRaidProgression(activityID)
    local list = RAID_PROGRESSION_LIST[activityID]

    if not list then
        return
    end

    local result = 0
    for i, v in ipairs(list) do
        if tonumber((GetStatistic(v.id))) or (v.id2 and tonumber((GetStatistic(v.id2)))) then
            result = bit.bor(result, bit.lshift(1, i - 1))
        end
    end

    return result
end

function GetProgressionTex(value, bossIndex)
    local killed = bit.band(value, bit.lshift(1, bossIndex-1)) > 0

    return killed and [[|TINTERFACE\FriendsFrame\StatusIcon-Online:16|t]] or [[|TINTERFACE\FriendsFrame\StatusIcon-Offline:16|t]]
end

function GetActivityName(id)
    return ACTIVITY_CUSTOM_NAMES[id] or ACTIVITY_NAME_CACHE[id]
end

function GetAddonSource()
    for line in gmatch('\066\105\103\070\111\111\116\058\049\010\033\033\033\049\054\051\085\073\033\033\033\058\050\010\068\117\111\119\097\110\058\052\010\069\108\118\085\073\058\056', '[^\r\n]+') do
        local n, v = line:match('^(.+):(%d+)$')
        if IsAddOnLoaded(n) then
            return tonumber(v)
        end
    end
    return 0
end

function GetFullVersion(version)
    return version:gsub('(%d)(%d)(%d%d)', '%10%200.%3')
end

function FormatActivitiesSummaryUrl(summary, url)
    return (summary:gsub('{URL([^}]*)}', function(info)
        local path, text = info:match('^(.*):(.+)$')
        if not path then
            path = info
            text = url .. path
        end
        return format('|Hurl:%s%s|h|cff00ffff[%s]|r|h', url, path, text)
    end))
end
