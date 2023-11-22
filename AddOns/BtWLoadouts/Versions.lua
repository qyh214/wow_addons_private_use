local _, Internal = ...;

local current = select(4, GetBuildInfo());
local function IsBuild(build)
    return build == current
end
local function IsAtleastBuild(build)
    return build <= current
end
local function IsExpansion(expansion)
    return expansion == GetExpansionLevel()
end
local seasons = {
    [1] = {
        [9] = 1670943600,
        [10] = 1683644400,
        [11] = 1699974000,
    },
    [2] = {
        [9] = 1671058800,
        [10] = 1683759600,
        [11] = 1700089200,
    },
    [3] = {
        [9] = 1670990400,
        [10] = 1683691200,
        [11] = 1700020800,
    },
    [4] = {
        [9] = 1671058800,
        [10] = 1683759600,
        [11] = 1700089200,
    },
    [5] = {
        [9] = 1671058800,
        [10] = 1683759600,
        [11] = 1700089200,
    },
    [72] = {
        [9] = 1671058800,
        [10] = 1683759600,
        [11] = 1700089200,
    },
};
local function IsSeason(season)
    -- C_MythicPlus.GetCurrentSeason isnt always available during first login sp we fallback to date checking.
    -- In the future it might be worth using something else or delaying season checks
    local current = C_MythicPlus.GetCurrentSeason()
    if current > 0 then
        return season == current
    end

    local time = GetServerTime()
    local region = seasons[GetCurrentRegion()]
    local prev = region[season]
    if not prev or time < prev then
        return false
    end
    if region[season+1] then
        local next = region[season+1]
        if time > next then
            return false
        end
    end
    return true
end

Internal.IsShadowlandsPatch = IsAtleastBuild(90000)
Internal.IsChainsOfDominationPatch = IsAtleastBuild(90100)
Internal.IsEternitysEndPatch = IsAtleastBuild(90200)
Internal.IsDragonflightPatch = IsAtleastBuild(100000)
Internal.Is100000 = IsBuild(100000)
Internal.Is100002 = IsBuild(100002)
Internal.Is100005 = IsBuild(100005)
Internal.Is100007 = IsBuild(100007)
Internal.Is100100 = IsAtleastBuild(100100)
Internal.Is100105 = IsAtleastBuild(100105)

Internal.IsBattleForAzeroth = IsExpansion(LE_EXPANSION_BATTLEFORAZEROTH or 7)
Internal.IsShadowlands = IsExpansion(LE_EXPANSION_SHADOWLANDS or 8)
Internal.IsDragonflight = IsExpansion(LE_EXPANSION_DRAGONFLIGHT or 9)

Internal.IsShadowlandsSeason1 = IsSeason(5)
Internal.IsShadowlandsSeason2 = IsSeason(6)
Internal.IsShadowlandsSeason3 = IsSeason(7)
Internal.IsShadowlandsSeason4 = IsSeason(8)
Internal.IsDragonflightSeason1 = IsSeason(9)
Internal.IsDragonflightSeason2 = IsSeason(10)
Internal.IsDragonflightSeason3 = IsSeason(11)
