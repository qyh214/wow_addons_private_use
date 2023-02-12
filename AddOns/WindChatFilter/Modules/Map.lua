local W, F, L = unpack(select(2, ...))
local CORE = W:GetModule("Core")

local mainCityMaps = {
    [84] = true, -- Stormwind City
    [85] = true, --	Orgrimmar - Orgrimmar
    [86] = true, --	Orgrimmar - Cleft of Shadow
    [87] = true, --	Ironforge
    [88] = true, --	Thunder Bluff
    [89] = true, --	Darnassus
    [90] = true, --	Undercity
    [2112] = true -- Valdrakken
}

local function getMapFilter(rule)
    if not rule.map or not rule.map.enabled then
        return nil
    end

    if not rule.map.mainCity and (not rule.map.mapIDs or not next(rule.map.mapIDs)) then
        return nil
    end

    return function(data)
        local map = C_Map.GetBestMapForUnit("player")
        if not map then
            return false
        end

        if rule.map.mainCity and mainCityMaps[map] then
            return true
        end

        if rule.map.mapIDs then
            for customMap, _ in pairs(rule.map.mapIDs) do
                if customMap == map then
                    return true
                end
            end
        end

        return false
    end
end

CORE:RegisterRuleParser("Map", getMapFilter)
