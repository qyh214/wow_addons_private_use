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
local function IsSeason(season)
    return season == C_MythicPlus.GetCurrentSeason()
end

Internal.IsShadowlandsPatch = IsAtleastBuild(90000)
Internal.IsChainsOfDominationPatch = IsAtleastBuild(90100)
Internal.IsEternitysEndPatch = IsAtleastBuild(90200)
Internal.IsEternitysEndPatch = IsAtleastBuild(90200)
Internal.IsDragonflightPatch = IsAtleastBuild(100000)
Internal.Is100000 = IsBuild(100000)
Internal.Is100002 = IsBuild(100002)
Internal.Is100005 = IsBuild(100005)

Internal.IsBattleForAzeroth = IsExpansion(LE_EXPANSION_BATTLEFORAZEROTH or 7)
Internal.IsShadowlands = IsExpansion(LE_EXPANSION_SHADOWLANDS or 8)
Internal.IsDragonflight = IsExpansion(LE_EXPANSION_DRAGONFLIGHT or 9)

Internal.IsShadowlandsSeason1 = IsSeason(5)
Internal.IsShadowlandsSeason2 = IsSeason(6)
Internal.IsShadowlandsSeason3 = IsSeason(7)
Internal.IsShadowlandsSeason4 = IsSeason(8)
Internal.IsDragonflightSeaosn1 = IsSeason(9)

