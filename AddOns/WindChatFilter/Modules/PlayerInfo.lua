local W, F, L = unpack(select(2, ...))
local CORE = W:GetModule("Core")

local next = next
local pairs = pairs
local strfind = strfind

local GetNumClasses = GetNumClasses

local C_CreatureInfo_GetClassInfo = C_CreatureInfo.GetClassInfo

local races = {
    neutral = {
        "Pandaren",
        "Dracthyr"
    },
    alliance = {
        "Human",
        "Dwarf",
        "NightElf",
        "Gnome",
        "Draenei",
        "Worgen",
        "VoidElf",
        "LightforgedDraenei",
        "DarkIronDwarf",
        "KulTiran",
        "Mechagnome"
    },
    horde = {
        "Orc",
        "Scourge",
        "Tauren",
        "Troll",
        "BloodElf",
        "Goblin",
        "Nightborne",
        "HighmountainTauren",
        "MagharOrc",
        "ZandalariTroll",
        "Vulpera"
    }
}

local function getPlayerInfoFilter(rule)
    if not rule.playerInfo or not rule.playerInfo.enabled then
        return nil
    end

    local configIsValid = false
    for _, v in pairs(rule.playerInfo.config) do
        if v then
            configIsValid = true
            break
        end
    end

    if not configIsValid then
        return nil
    end

    local matchClasses = {}
    local matchRaces = {}
    local matchNames = rule.playerInfo.name
    local matchRealms = rule.playerInfo.realm

    for i = 1, GetNumClasses() do
        local classInfo = C_CreatureInfo_GetClassInfo(i)
        local className = classInfo and classInfo.classFile
        if className then
            matchClasses[className] = rule.playerInfo.class and rule.playerInfo.class[className]
        end
    end

    for _, raceName in pairs(races.neutral) do
        matchRaces[raceName] = rule.playerInfo.race and rule.playerInfo.race[raceName] == true
    end

    for _, raceName in pairs(races.alliance) do
        matchRaces[raceName] = rule.playerInfo.race and rule.playerInfo.race[raceName] == true
    end

    for _, raceName in pairs(races.horde) do
        matchRaces[raceName] = rule.playerInfo.race and rule.playerInfo.race[raceName] == true
    end

    if rule.playerInfo.race and rule.playerInfo.race.includeHostileFaction then
        if W.myFaction == "Alliance" then
            for _, raceName in pairs(races.horde) do
                matchRaces[raceName] = true
            end
        elseif W.myFaction == "Horde" then
            for _, raceName in pairs(races.alliance) do
                matchRaces[raceName] = true
            end
        end

        if rule.playerInfo.race.includeNeutral then
            for _, raceName in pairs(races.neutral) do
                matchRaces[raceName] = true
            end
        end
    end

    return function(data)
        if not data.guid then
            return false
        end

        local playerInfo = F.FetchPlayerInfo(data.guid)

        if not playerInfo then
            return false
        end

        if rule.playerInfo.config.class and not matchClasses[playerInfo.class] then
            return false
        end

        if rule.playerInfo.config.race and not matchRaces[playerInfo.race] then
            return false
        end

        if rule.playerInfo.config.realm and matchRealms and next(matchRealms) then
            local matched = false

            for realm, _ in pairs(matchRealms) do
                if strfind(playerInfo.realm, realm) then
                    matched = true
                    break
                end
            end

            if not matched then
                return false
            end
        end

        if rule.playerInfo.config.name and matchNames and next(matchNames) then
            local matched = false

            for name, _ in pairs(matchNames) do
                if strfind(playerInfo.name, name) or strfind(data.sender, name) then
                    matched = true
                    break
                end
            end

            if not matched then
                return false
            end
        end

        return true
    end
end

CORE:RegisterRuleParser("PlayerInfo", getPlayerInfoFilter)
