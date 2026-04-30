---@class Private
local Private = select(2, ...)

Private.Zones[46] = {
    id = 46,
    name = "VS / DR / MQD",
    hasMultipleDifficulties = true,
    hasMultipleSizes = false,
    encounters = {
        { id = 3176, },
        { id = 3177, },
        { id = 3179, },
        { id = 3178, },
        { id = 3180, },
        { id = 3181, },
        { id = 3306, },
        { id = 3182, },
        { id = 3183, },
    },
    difficultyIconMap = nil,
}

Private.Zones[1046] = {
    id = 1046,
    name = "Throne of Thunder",
    hasMultipleDifficulties = true,
    hasMultipleSizes = true,
    encounters = {
        { id = 51577, },
        { id = 51575, },
        { id = 51570, },
        { id = 51565, },
        { id = 51578, },
        { id = 51573, },
        { id = 51572, },
        { id = 51574, },
        { id = 51576, },
        { id = 51559, },
        { id = 51560, },
        { id = 51579, },
        { id = 51580, },
    },
    difficultyIconMap = nil,
}

Private.Zones[1051] = {
    id = 1051,
    name = "HoF / ToES",
    hasMultipleDifficulties = true,
    hasMultipleSizes = true,
    encounters = {
        { id = 51507, },
        { id = 51504, },
        { id = 51463, },
        { id = 51498, },
        { id = 51499, },
        { id = 51501, },
        { id = 51409, },
        { id = 51505, },
        { id = 51506, },
        { id = 51431, },
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

Private.Zones[1053] = {
    id = 1053,
    name = "Naxx / Sarth / Maly",
    hasMultipleDifficulties = false,
    hasMultipleSizes = false,
    encounters = {
        { id = 301118, },
        { id = 301111, },
        { id = 301108, },
        { id = 301120, },
        { id = 301117, },
        { id = 301112, },
        { id = 301115, },
        { id = 301107, },
        { id = 301110, },
        { id = 301116, },
        { id = 301113, },
        { id = 301109, },
        { id = 301121, },
        { id = 301119, },
        { id = 301114, },
        { id = 100742, },
        { id = 100734, },
    },
    difficultyIconMap = nil,
}

Private.Zones[1048] = {
    id = 1048,
    name = "Gruul / Magtheridon",
    hasMultipleDifficulties = false,
    hasMultipleSizes = false,
    encounters = {
        { id = 50649, },
        { id = 50650, },
        { id = 50651, },
    },
    difficultyIconMap = nil,
}

for _, zone in pairs(Private.Zones) do
    for _, encounter in pairs(zone.encounters) do
        Private.EncounterZoneIdMap[encounter.id] = zone.id
    end
end