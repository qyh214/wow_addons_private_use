local L = BtWQuests.L;
local MAP_ID = 1355
local CONTINENT_ID = 1355

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN01, {
    name = { -- Welcome to Nazjatar
        type = "achievement",
        id = 13710,
        criteriaId = 45759,
    },
    -- questline = 939,
    questline = 949,
    -- questline = 951,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_NAZJATAR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {120,50},
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN02,
    },
    major = true,
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
        {
            type = "quest",
            ids = {51918, 52450},
            count = 1,
        },
    },
    active = {
        type = "quest",
        id = 56031,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 56350,
    },
    rewards = {
        {
            name = L["BTWQUESTS_WORLD_QUESTS"],
        },
        {
            type = "azessence",
            id = 27,
            rank = 1,
        },
        {
            type = "currency",
            id = 1721,
            amount = 32,
        },
    },
    items = {
        {
            type = "quest",
            id = 56031,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 56043,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55095,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 54969,
            x = 3,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 56640,
            x = 1,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 56641,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 56642,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 56643,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 56644,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55175,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 54972,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_THE_HEART_FORGE_CHAIN01,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 56350,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55361,
            aside = true,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 55362,
            aside = true,
            x = 2,
        },
        {
            type = "quest",
            id = 55363,
            aside = true,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 56156,
            aside = true,
            x = 3,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 56211,
            aside = true,
            x = 1,
        },
        {
            type = "quest",
            id = 54975,
            aside = true,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 57006,
            aside = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN03,
            aside = true,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN02, {
    name = { -- Welcome to Nazjatar
        type = "achievement",
        id = 13709,
        criteriaId = 45756,
    },
    -- questline = 939,
    questline = 886,
    -- questline = 944,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_NAZJATAR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {120,50},
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN01,
    },
    major = true,
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
        {
            type = "quest",
            ids = {51916, 52451},
            count = 1,
        },
    },
    active = {
        type = "quest",
        id = 56030,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 55481,
    },
    rewards = {
        {
            name = L["BTWQUESTS_WORLD_QUESTS"],
        },
        {
            type = "azessence",
            id = 27,
            rank = 1,
        },
        {
            type = "currency",
            id = 1721,
            amount = 32,
        },
    },
    items = {
        {
            type = "quest",
            id = 56030,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 56044,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55054,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 54018,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 54021,
            x = 3,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 56063,
            x = 1,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 54012,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 55092,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 54015,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 56429,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55094,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55053,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_THE_HEART_FORGE_CHAIN01,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55481,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55384,
            aside = true,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55385,
            aside = true,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55500,
            aside = true,
            x = 3,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 56210,
            aside = true,
            x = 1,
        },
        {
            type = "quest",
            id = 56235,
            aside = true,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 57005,
            aside = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN04,
            aside = true,
            x = 3,
        },
    },
})

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN03, {
    name = { -- Secrets in the Seas
        type = "achievement",
        id = 13710,
        criteriaId = 45760,
    },
    questline = 942,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_NAZJATAR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {120,50},
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN04,
    },
    major = true,
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN01,
        },
        {
            type = "quest",
            id = 54975,
        },
    },
    active = {
        type = "quest",
        id = 55593,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 55937,
    },
    rewards = {
        {
            type = "azessence",
            id = 27,
            rank = 2,
        },
        {
            type = "currency",
            id = 1553,
            amount = 1200,
        },
        {
            type = "currency",
            id = 1721,
            amount = 5,
        },
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN01,
            completed = {
                type = "quest",
                id = 54975,
            },
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "npc",
            id = 150101,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55593,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 55595,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 55597,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55598,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55599,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 55600,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 56038,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 56039,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 56037,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 55860,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 55601,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55861,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55937,
            x = 3,
            connections = {
                1, 2,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_CAMPAIGN_8_2,
            aside = true,
            x = 2,
        },
        {
            type = "quest",
            id = 56234,
            aside = true,
            connections = {
                1, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN05,
            aside = true,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN04, {
    name = { -- Secrets in the Seas
        type = "achievement",
        id = 13709,
        criteriaId = 45757,
    },
    questline = 943,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_NAZJATAR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {120,50},
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN03,
    },
    major = true,
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN02,
        },
        {
            type = "quest",
            id = 56235,
        },
    },
    active = {
        type = "quest",
        id = 55862,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 55869,
    },
    rewards = {
        {
            type = "azessence",
            id = 27,
            rank = 2,
        },
        {
            type = "currency",
            id = 1553,
            amount = 1200,
        },
        {
            type = "currency",
            id = 1721,
            amount = 5,
        },
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN02,
            completed = {
                type = "quest",
                id = 56235,
            },
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "npc",
            id = 151848,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55862,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 55863,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 55864,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55865,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55866,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 55967,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 56046,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 56047,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 56045,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 55870,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 55867,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55868,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55869,
            x = 3,
            connections = {
                1, 2,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_CAMPAIGN_8_2,
            aside = true,
            x = 2,
        },
        {
            type = "quest",
            id = 56236,
            aside = true,
            connections = {
                1, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN06,
            aside = true,
            x = 3,
        },
    },
})

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN05, {
    name = { -- Turning the Tide
        type = "achievement",
        id = 13710,
        criteriaId = 45761,
    },
    questline = 975,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_NAZJATAR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {120,50},
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN06,
    },
    major = true,
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN03,
        },
        {
            type = "quest",
            id = 56234,
        },
    },
    active = {
        type = "quest",
        id = 55558,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 56325,
    },
    rewards = {
        {
            type = "currency",
            id = 1553,
            amount = 3750,
        },
        {
            type = "currency",
            id = 1721,
            amount = 25,
        },
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN03,
            completed = {
                type = "quest",
                id = 56234,
            },
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "npc",
            id = 153617,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55558,
            x = 3,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 55560,
            x = 1,
            connections = {
                4, 5, 
            },
        },
        {
            type = "quest",
            id = 55561,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 55694,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 55565,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 55569,
            x = 2,
        },
        {
            type = "quest",
            id = 55570,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 55571,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 55573,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 56739,
            aside = true,
            x = 2,
        },
        {
            type = "quest",
            id = 55574,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 56741,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 56325,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 56358,
            aside = true,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN06, {
    name = { -- Turning the Tide
        type = "achievement",
        id = 13709,
        criteriaId = 45758,
    },
    questline = 938,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_NAZJATAR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {120,50},
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN05,
    },
    major = true,
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN04,
        },
        {
            type = "quest",
            id = 56236,
        },
    },
    active = {
        type = "quest",
        id = 55469,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 55799,
    },
    rewards = {
        {
            type = "currency",
            id = 1553,
            amount = 3750,
        },
        {
            type = "currency",
            id = 1721,
            amount = 25,
        },
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN04,
            completed = {
                type = "quest",
                id = 56236,
            },
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "npc",
            id = 151848,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55469,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55482,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55485,
            x = 3,
            connections = {
                1, 2
            },
        },
        {
            type = "quest",
            id = 55486,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 55488,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55489,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55490,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55799,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 56356,
            x = 3,
        },
    },
})

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN07, {
    name = { -- Ancient Technology
        type = "quest",
        id = 56346,
    },
    questline = 955,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_NAZJATAR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {120,50},
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN08,
    },
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN01,
        },
        {
            type = "quest",
            id = 56156,
        },
    },
    active = {
        type = "quest",
        id = 56346,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 56349,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN01,
            x = 3,
            y = 0,
            completed = {
                type = "quest",
                id = 56156,
            },
            connections = {
                1, 
            },
        },
        {
            type = "object",
            id = 327596,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 56346,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 56347,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 56348,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 56349,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN08, {
    name = { -- Ancient Technology
        type = "quest",
        id = 56354,
    },
    questline = 956,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_NAZJATAR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {120,50},
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN07,
    },
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN02,
        },
        {
            type = "quest",
            id = 55500,
        },
    },
    active = {
        type = "quest",
        id = 56354,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 56351,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN02,
            x = 3,
            y = 0,
            completed = {
                type = "quest",
                id = 55500,
            },
            connections = {
                1, 
            },
        },
        {
            type = "object",
            id = 327596,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 56354,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 56353,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 56352,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 56351,
            x = 3,
        },
    },
})

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN09, {
    name = { -- On Ghostly Wings
        type = "quest",
        id = 56422,
    },
    questline = 948,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_NAZJATAR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {120,50},
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN01,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN02,
        },
        {
            type = "quest",
            id = 56156,
            restrictions = {
                type = "faction",
                id = BTWQUESTS_FACTION_ID_ALLIANCE,
            },
        },
        {
            type = "quest",
            id = 55500,
            restrictions = {
                type = "faction",
                id = BTWQUESTS_FACTION_ID_HORDE,
            },
        },
    },
    active = {
        type = "quest",
        id = 56304,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 56422,
    },
    rewards = {
        {
            name = L["BTWQUESTS_FLIGHT_MASTER_KELYA_MOONFALL"],
        },
        {
            name = L["BTWQUESTS_UNLOCK_FLIGHT_WHISTLE"],
        },
    },
    items = {
        {
            variations = {
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN01,
                    completed = {
                        type = "quest",
                        id = 56156,
                    },
                },
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN02,
                    completed = {
                        type = "quest",
                        id = 55500,
                    },
                },
            },
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "npc",
            id = 154574,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 56304,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 56321,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 56422,
            x = 3,
        },
    },
})

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN10, {
    name = { -- City of Drowned Friends
        type = "quest",
        id = 56309,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_NAZJATAR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {120,50},
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN11,
    },
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN01,
        },
        {
            type = "quest",
            id = 56156,
        },
    },
    active = {
        type = "quest",
        id = 56309,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 56315,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN01,
            completed = {
                type = "quest",
                id = 56156,
            },
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "npc",
            id = 154522,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 56309,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 56311,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 56313,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 56315,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN11, {
    name = { -- City of Drowned Friends
        type = "quest",
        id = 56310,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_NAZJATAR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {120,50},
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN10,
    },
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN02,
        },
        {
            type = "quest",
            id = 55500,
        },
    },
    active = {
        type = "quest",
        id = 56310,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 56316,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN02,
            completed = {
                type = "quest",
                id = 55500,
            },
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "npc",
            id = 154520,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 56310,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 56312,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 56314,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 56316,
            x = 3,
        },
    },
})

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN12, {
    name = { -- Mrrl
        type = "npc",
        id = 152084,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_NAZJATAR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {120,50},
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN13,
    },
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN01,
        },
        {
            type = "quest",
            id = 56156,
        },
    },
    active = {
        type = "quest",
        id = 55983,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 55529,
    },
    rewards = {
        {
            name = L["BTWQUESTS_VENDOR_MRRL"],
        },
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN01,
            completed = {
                type = "quest",
                id = 56156,
            },
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "npc",
            id = 152084,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55983,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55529,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN13, {
    name = { -- Mrrl
        type = "npc",
        id = 152084,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_NAZJATAR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {120,50},
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN12,
    },
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN02,
        },
        {
            type = "quest",
            id = 55500,
        },
    },
    active = {
        type = "quest",
        id = 55530,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 55529,
    },
    rewards = {
        {
            name = L["BTWQUESTS_VENDOR_MRRL"],
        },
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN02,
            completed = {
                type = "quest",
                id = 55500,
            },
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "npc",
            id = 152084,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55530,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55529,
            x = 3,
        },
    },
})

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN14, {
    name = { -- Strange Silver Knife
        type = "quest",
        id = 56239,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_NAZJATAR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {120,50},
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN15,
    },
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN01,
        },
        {
            type = "quest",
            id = 56156,
        },
    },
    active = {
        type = "quest",
        id = 56239,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 56247,
    },
    rewards = {
        {
            name = L["BTWQUESTS_EXTRA_WORLD_QUESTS"],
        },
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN01,
            completed = {
                type = "quest",
                id = 56156,
            },
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "loot",
            id = 326418,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 56239,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 56241,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 56243,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 56246,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 56247,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN15, {
    name = { -- Strange Silver Knife
        type = "quest",
        id = 56240,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_NAZJATAR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {120,50},
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN14,
    },
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN02,
        },
        {
            type = "quest",
            id = 55500,
        },
    },
    active = {
        type = "quest",
        id = 56240,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 56248,
    },
    rewards = {
        {
            name = L["BTWQUESTS_EXTRA_WORLD_QUESTS"],
        },
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN02,
            completed = {
                type = "quest",
                id = 55500,
            },
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "loot",
            id = 326418,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 56240,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 56242,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 56244,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 56245,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 56248,
            x = 3,
        },
    },
})

-- Turtle dude quests
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN16, {
    name = { -- The Fate of Professor Elryna
        type = "quest",
        id = 56143,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_NAZJATAR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {120,50},
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN01,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN02,
        },
        {
            type = "quest",
            id = 56156,
            restrictions = {
                type = "faction",
                id = BTWQUESTS_FACTION_ID_ALLIANCE,
            },
        },
        {
            type = "quest",
            id = 55500,
            restrictions = {
                type = "faction",
                id = BTWQUESTS_FACTION_ID_HORDE,
            },
        },
    },
    active = {
        type = "quest",
        ids = {56095, 56118},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 56143,
    },
    items = {
        {
            variations = {
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN01,
                    completed = {
                        type = "quest",
                        id = 56156,
                    },
                },
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN02,
                    completed = {
                        type = "quest",
                        id = 55500,
                    },
                },
            },
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "npc",
            id = 154143,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 56095,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 56118,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 56143,
            x = 3,
        },
    },
})

-- The Laboratory of Mardivas, Both, Marker Only
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_MARKER_CHAIN01, {
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_NAZJATAR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {120,50},
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN01,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN02,
        },
        {
            type = "quest",
            id = 56156,
            restrictions = {
                type = "faction",
                id = BTWQUESTS_FACTION_ID_ALLIANCE,
            },
        },
        {
            type = "quest",
            id = 55500,
            restrictions = {
                type = "faction",
                id = BTWQUESTS_FACTION_ID_HORDE,
            },
        },
    },
    rewards = {
        {
            type = "currency",
            id = 1721,
            amount = 10,
        },
    },
    items = {
        {
            type = "object",
            id = 322533,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55121,
            x = 3,
        },
    },
})

-- A Curious Discovery, Alliance, Marker Only
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_MARKER_CHAIN02, {
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_NAZJATAR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {120,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN01,
        },
        {
            type = "quest",
            id = 56156,
        },
    },
    items = {
        {
            type = "object",
            id = 329805,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 56561,
            x = 3,
        },
    },
})
-- A Curious Discovery, Horde, Marker Only
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_MARKER_CHAIN03, {
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_NAZJATAR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {120,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN02,
        },
        {
            type = "quest",
            id = 55500,
        },
    },
    items = {
        {
            type = "object",
            id = 329805,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 56560,
            x = 3,
        },
    },
})

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_OTHER_ALLIANCE, {
    name = "Other Alliance",
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_NAZJATAR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {1,50},
    prerequisites = {
        type = "level",
        level = 50,
        visible = false,
    },
    active = false,
    items = {
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_OTHER_HORDE, {
    name = "Other Horde",
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_NAZJATAR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {1,50},
    prerequisites = {
        type = "level",
        level = 50,
        visible = false,
    },
    active = false,
    items = {
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_OTHER_BOTH, {
    name = "Other Both",
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_NAZJATAR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {1,50},
    prerequisites = {
        type = "level",
        level = 50,
        visible = false,
    },
    active = false,
    items = {
    },
})

BtWQuestsDatabase:AddCategory(BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_NAZJATAR, {
    name = BtWQuests_GetMapName(MAP_ID),
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN01,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN02,
        },


        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN03,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN04,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN05,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN06,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN07,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN08,
        },


        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN09,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN10,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN11,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN16,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN14,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN15,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN12,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN13,
        },
    },
})
BtWQuestsDatabase:AddExpansionItems(BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH, {
    {
        type = "category",
        id = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_NAZJATAR,
    },
})

BtWQuestsDatabase:AddMapRecursive(MAP_ID, {
    type = "category",
    id = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_NAZJATAR,
})

BtWQuestsDatabase:AddContinentItems(CONTINENT_ID, {
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_MARKER_CHAIN01,
    },

    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_MARKER_CHAIN03,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_MARKER_CHAIN02,
    },

    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN11,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN10,
    },

    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN13,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN12,
    },

    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN15,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN14,
    },
    
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN16,
    },
})