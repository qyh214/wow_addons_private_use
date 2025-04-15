---@class Private
local Private = select(2, ...)

Private.Zones[42] = {
    id = 42,
    name = "Liberation of Undermine",
    hasMultipleSizes = false,
    encounters = {
        { id = 3009, },
        { id = 3010, },
        { id = 3011, },
        { id = 3012, },
        { id = 3013, },
        { id = 3014, },
        { id = 3015, },
        { id = 3016, },
    },
    difficultyIconMap = nil
}

Private.Zones[1033] = {
    id = 1033,
    name = "Dragon Soul",
    hasMultipleSizes = true,
    encounters = {
        { id = 1292, },
        { id = 1294, },
        { id = 1295, },
        { id = 1296, },
        { id = 1297, },
        { id = 1298, },
        { id = 1291, },
        { id = 1299, },
    },
    difficultyIconMap = nil
}

Private.Zones[1032] = {
    id = 1032,
    name = "Trial of the Crusader",
    hasMultipleSizes = true,
    encounters = {
        { id = 50629, },
        { id = 50633, },
        { id = 50637, },
        { id = 50641, },
        { id = 50645, },
    },
    difficultyIconMap = nil
}

Private.Zones[2017] = {
    id = 2017,
    name = "Naxxramas",
    hasMultipleSizes = true,
    encounters = {
        { id = 201118, },
        { id = 201111, },
        { id = 201108, },
        { id = 201120, },
        { id = 201117, },
        { id = 201112, },
        { id = 201115, },
        { id = 201107, },
        { id = 201110, },
        { id = 201116, },
        { id = 201113, },
        { id = 201109, },
        { id = 201121, },
        { id = 201119, },
        { id = 201114, },
    },
    difficultyIconMap = nil
}

for _, zone in pairs(Private.Zones) do
    for _, encounter in pairs(zone.encounters) do
        Private.EncounterZoneIdMap[encounter.id] = zone.id
    end
end