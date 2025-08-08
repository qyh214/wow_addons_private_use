---@class Private
local Private = select(2, ...)

Private.Zones[42] = {
    id = 42,
    name = "Undermine",
    hasMultipleDifficulties = true,
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
    difficultyIconMap = nil,
}

Private.Zones[1033] = {
    id = 1033,
    name = "Dragon Soul",
    hasMultipleDifficulties = true,
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
    difficultyIconMap = nil,
}

Private.Zones[1037] = {
    id = 1037,
    name = "Icecrown Citadel",
    hasMultipleDifficulties = true,
    hasMultipleSizes = true,
    encounters = {
        { id = 50845, },
        { id = 50846, },
        { id = 50847, },
        { id = 50848, },
        { id = 50849, },
        { id = 50850, },
        { id = 50851, },
        { id = 50852, },
        { id = 50853, },
        { id = 50854, },
        { id = 50855, },
        { id = 50856, },
    },
    difficultyIconMap = nil,
}

Private.Zones[2018] = {
    id = 2018,
    name = "Scarlet Enclave",
    hasMultipleDifficulties = false,
    hasMultipleSizes = true,
    encounters = {
        { id = 3185, },
        { id = 3187, },
        { id = 3186, },
        { id = 3197, },
        { id = 3196, },
        { id = 3188, },
        { id = 3190, },
        { id = 3189, },
    },
    difficultyIconMap = nil,
}

Private.Zones[1034] = {
    id = 1034,
    name = "Blackwing Lair",
    hasMultipleDifficulties = false,
    hasMultipleSizes = false,
    encounters = {
        { id = 150610, },
        { id = 150611, },
        { id = 150612, },
        { id = 150613, },
        { id = 150614, },
        { id = 150615, },
        { id = 150631, },
        { id = 150616, },
        { id = 150617, },
    },
    difficultyIconMap = nil,
}

for _, zone in pairs(Private.Zones) do
    for _, encounter in pairs(zone.encounters) do
        Private.EncounterZoneIdMap[encounter.id] = zone.id
    end
end