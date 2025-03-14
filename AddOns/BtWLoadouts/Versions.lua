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
        [12] = 1713884400,
        [13] = 1725980400,
        [14] = 1741100400,
    },
    [2] = {
        [9] = 1671058800,
        [10] = 1683759600,
        [11] = 1700089200,
        [12] = 1713999600,
        [13] = 1726095600,
        [14] = 1741215600,
    },
    [3] = {
        [9] = 1670990400,
        [10] = 1683691200,
        [11] = 1700020800,
        [12] = 1713931200,
        [13] = 1726027200,
        [14] = 1741147200,
    },
    [4] = {
        [9] = 1671058800,
        [10] = 1683759600,
        [11] = 1700089200,
        [12] = 1713999600,
        [13] = 1726095600,
        [14] = 1741215600,
    },
    [5] = {
        [9] = 1671058800,
        [10] = 1683759600,
        [11] = 1700089200,
        [12] = 1713999600,
        [13] = 1726095600,
        [14] = 1741215600,
    },
    [72] = {
        [9] = 1671058800,
        [10] = 1683759600,
        [11] = 1700089200,
        [12] = 1713999600,
        [13] = 1726095600,
        [14] = 1741215600,
    },
    [90] = {
        [9] = 1671058800,
        [10] = 1683759600,
        [11] = 1700089200,
        [12] = 1713999600,
        [13] = 1726095600,
        [14] = 1741215600,
    },
};
local GetCurrentSeason = C_MythicPlus and C_MythicPlus.GetCurrentSeason or function ()
    return 0
end
local function IsSeason(season)
    -- C_MythicPlus.GetCurrentSeason isnt always available during first login so we fallback to date checking.
    -- In the future it might be worth using something else or delaying season checks
    local current = GetCurrentSeason()
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

Internal.IsDragonflightOrBeyond = IsAtleastBuild(100000)
Internal.IsTheWarWithinOrBeyond = IsAtleastBuild(110000)
Internal.Is100000 = IsBuild(100000)
Internal.Is100002 = IsBuild(100002)
Internal.Is100005 = IsBuild(100005)
Internal.Is100007 = IsBuild(100007)
Internal.Is100100 = IsBuild(100100)
Internal.Is100105 = IsBuild(100105)
Internal.Is100200 = IsBuild(100200)
Internal.Is110000 = IsBuild(110000)
Internal.Is110002 = IsBuild(110002)
Internal.Is110007 = IsBuild(110007)
Internal.Is110100 = IsBuild(110100)

Internal.IsBattleForAzeroth = IsExpansion(LE_EXPANSION_BATTLE_FOR_AZEROTH or 7)
Internal.IsShadowlands = IsExpansion(LE_EXPANSION_SHADOWLANDS or 8)
Internal.IsDragonflight = IsExpansion(LE_EXPANSION_DRAGONFLIGHT or 9)
Internal.IsTheWarWithin = IsExpansion(LE_EXPANSION_WAR_WITHIN or 10)

Internal.IsBattleForAzerothSeason1 = Internal.IsBattleForAzeroth and IsSeason(4)
Internal.IsShadowlandsSeason1 = Internal.IsShadowlands and IsSeason(5)
Internal.IsShadowlandsSeason2 = Internal.IsShadowlands and IsSeason(6)
Internal.IsShadowlandsSeason3 = Internal.IsShadowlands and IsSeason(7)
Internal.IsShadowlandsSeason4 = Internal.IsShadowlands and IsSeason(8)
Internal.IsDragonflightSeason1 = Internal.IsDragonflight and IsSeason(9)
Internal.IsDragonflightSeason2 = Internal.IsDragonflight and IsSeason(10)
Internal.IsDragonflightSeason3 = Internal.IsDragonflight and IsSeason(11)
Internal.IsDragonflightSeason4 = Internal.IsDragonflight and IsSeason(12)
Internal.IsTheWarWithinSeason1 = Internal.IsTheWarWithin and IsSeason(13)
Internal.IsTheWarWithinSeason2 = Internal.IsTheWarWithin -- and IsSeason(14)
