local L = BtWQuests.L;
local MAP_ID = 1462
local CONTINENT_ID = 876

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND_CHAIN01, {
    name = { -- The Legend of Mechagon
        type = "quest",
        id = 54088,
    },
    questline = 940,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {120,50},
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND_CHAIN02,
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
            id = 56156,
        },
    },
    active = {
        type = "quest",
        id = 54088,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 55736,
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
            id = 150208,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 54088,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55040,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 54945,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 54087,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 54946,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 54947,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 54992,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55645,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55729,
            x = 3,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 55730,
            x = 1,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 55995,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 55731,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 55734,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55096,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55736,
            x = 3,
            connections = {
                1, 2, 3, 4, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND_CHAIN03,
            x = 0,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND_CHAIN04,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND_CHAIN05,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND_CHAIN06,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND_CHAIN02, {
    name = { -- The Legend of Mechagon
        type = "quest",
        id = 55646,
    },
    questline = 941,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {120,50},
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND_CHAIN01,
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
            id = 55500,
        },
    },
    active = {
        type = "quest",
        id = 55646,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 55736,
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
            id = 152522,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55646,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55647,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55648,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55630,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55632,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55649,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55650,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55651,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55652,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55685,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55729,
            x = 3,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 55730,
            x = 1,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 55995,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 55731,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 55734,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55096,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55736,
            x = 3,
            connections = {
                1, 2, 3, 4, 
            },
        },
        {
            type = "chain",
            id = 80703,
            x = 0,
        },
        {
            type = "chain",
            id = 80704,
        },
        {
            type = "chain",
            id = 80705,
        },
        {
            type = "chain",
            id = 80706,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND_CHAIN03, {
    name = { -- Junkyard Tinkering and You
        type = "quest",
        id = 55101,
    },
    questline = 954,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {120,50},
    prerequisites = {
        {
            type = "level",
            level = 50,
            visible = false,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND_CHAIN01,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND_CHAIN02,
        },
    },
    active = {
        type = "quest",
        id = 55101,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 56181,
    },
    rewards = {
        {
            type = "achievement",
            id = 13478,
            criteriaId = 45308,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND_CHAIN01,
                },
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND_CHAIN02,
                },
            },
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "npc",
            id = 152295,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55101,
            x = 3,
            connections = {
                2, 
            },
        },
        {
            type = "reputation",
            id = 2391,
            standing = 6,
            x = 1,
            y = 2.5,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 56181,
            x = 3,
            y = 3,
            connections = {
                2, 
            },
        },
        {
            type = "reputation",
            id = 2391,
            standing = 7,
            x = 5,
            y = 3.5,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55103,
            x = 3,
            y = 4,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND_CHAIN04, {
    name = { -- Upgraded
        type = "quest",
        id = 55708,
    },
    questline = 952,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {120,50},
    prerequisites = {
        {
            type = "level",
            level = 50,
            visible = false,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND_CHAIN01,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND_CHAIN02,
        },
    },
    active = {
        type = "quest",
        id = 55708,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 55707,
    },
    rewards = {
        {
            name = L["BTWQUESTS_ITEM_POCKET_SIZED_COMPUTATION_DEVICE"],
        },
    },
    items = {
        {
            variations = {
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND_CHAIN01,
                },
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND_CHAIN02,
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
            id = 152747,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55708,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55707,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 55153,
            -- type = "chain",
            -- id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND_TEMP_CHAIN01,
            x = 2,
            aside = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND_CHAIN07,
            aside = true,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND_CHAIN05, {
    name = { -- Making a Mount
        type = "achievement",
        id = 13791,
    },
    questline = 925,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {120,50},
    prerequisites = {
        {
            type = "level",
            level = 50,
            visible = false,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND_CHAIN01,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND_CHAIN02,
        },
    },
    active = {
        type = "quest",
        id = 55608,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 55622,
    },
    rewards = {
        {
            type = "mount",
            id = 1253,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND_CHAIN01,
                },
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND_CHAIN02,
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
            id = 150573,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55608,
            x = 3,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 55161,
            name = L["BTWQUESTS_WAIT_FOR_DAILY_RESET"],
            visible = {
                {
                    type = "quest",
                    id = 55608,
                },
                {
                    type = "quest",
                    id = 54086,
                    status = {
                        "notcompleted",
                    },
                },
            },
            completed = {
                type = "quest",
                id = 55161,
                status = {
                    "notcompleted",
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 54086,
            x = 2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 54965,
            aside = true,
            x = 4,
        },
        {
            type = "quest",
            id = 55161,
            name = L["BTWQUESTS_WAIT_FOR_DAILY_RESET"],
            visible = {
                {
                    type = "quest",
                    id = 54086,
                },
                {
                    type = "quest",
                    id = 54929,
                    status = {
                        "notcompleted",
                    },
                },
            },
            completed = {
                type = "quest",
                id = 55161,
                status = {
                    "notcompleted",
                },
            },
            x = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 54929,
            x = 3,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 55161,
            name = L["BTWQUESTS_WAIT_FOR_DAILY_RESET"],
            visible = {
                {
                    type = "quest",
                    id = 54929,
                },
                {
                    type = "quest",
                    id = 55373,
                    status = {
                        "notcompleted",
                    },
                },
            },
            completed = {
                type = "quest",
                id = 55161,
                status = {
                    "notcompleted",
                },
            },
            x = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55373,
            x = 3,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 55161,
            name = L["BTWQUESTS_WAIT_FOR_DAILY_RESET"],
            visible = {
                {
                    type = "quest",
                    id = 55373,
                },
                {
                    type = "quest",
                    id = 55697,
                    status = {
                        "notcompleted",
                    },
                },
            },
            completed = {
                type = "quest",
                id = 55161,
                status = {
                    "notcompleted",
                },
            },
            x = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55697,
            x = 3,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 55161,
            name = L["BTWQUESTS_WAIT_FOR_DAILY_RESET"],
            visible = {
                {
                    type = "quest",
                    id = 55697,
                },
                {
                    type = "quest",
                    id = 54922,
                    status = {
                        "notcompleted",
                    },
                },
            },
            completed = {
                type = "quest",
                id = 55161,
                status = {
                    "notcompleted",
                },
            },
            x = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 54922,
            x = 3,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 55161,
            name = L["BTWQUESTS_WAIT_FOR_DAILY_RESET"],
            visible = {
                {
                    type = "quest",
                    id = 54922,
                },
                {
                    type = "quest",
                    id = 56168,
                    status = {
                        "notcompleted",
                    },
                },
            },
            completed = {
                type = "quest",
                id = 55161,
                status = {
                    "notcompleted",
                },
            },
            x = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 56168,
            x = 3,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 55161,
            name = L["BTWQUESTS_WAIT_FOR_DAILY_RESET"],
            visible = {
                {
                    type = "quest",
                    id = 56168,
                },
                {
                    type = "quest",
                    id = 54083,
                    status = {
                        "notcompleted",
                    },
                },
            },
            completed = {
                type = "quest",
                id = 55161,
                status = {
                    "notcompleted",
                },
            },
            x = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 54083,
            x = 3,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 55161,
            name = L["BTWQUESTS_WAIT_FOR_DAILY_RESET"],
            visible = {
                {
                    type = "quest",
                    id = 54083,
                },
                {
                    type = "quest",
                    id = 56175,
                    status = {
                        "notcompleted",
                    },
                },
            },
            completed = {
                type = "quest",
                id = 55161,
                status = {
                    "notcompleted",
                },
            },
            x = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 56175,
            x = 3,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 55161,
            name = L["BTWQUESTS_WAIT_FOR_DAILY_RESET"],
            visible = {
                {
                    type = "quest",
                    id = 56175,
                },
                {
                    type = "quest",
                    id = 55696,
                    status = {
                        "notcompleted",
                    },
                },
            },
            completed = {
                type = "quest",
                id = 55161,
                status = {
                    "notcompleted",
                },
            },
            x = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55696,
            x = 3,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 55161,
            name = L["BTWQUESTS_WAIT_FOR_DAILY_RESET"],
            visible = {
                {
                    type = "quest",
                    id = 55696,
                },
                {
                    type = "quest",
                    id = 55753,
                    status = {
                        "notcompleted",
                    },
                },
            },
            completed = {
                type = "quest",
                id = 55161,
                status = {
                    "notcompleted",
                },
            },
            x = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55753,
            x = 3,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 55161,
            name = L["BTWQUESTS_WAIT_FOR_DAILY_RESET"],
            visible = {
                {
                    type = "quest",
                    id = 55753,
                },
                {
                    type = "quest",
                    id = 55622,
                    status = {
                        "notcompleted",
                    },
                },
            },
            completed = {
                type = "quest",
                id = 55161,
                status = {
                    "notcompleted",
                },
            },
            x = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55622,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND_CHAIN06, {
    name = { -- Fishing For Something Bigger
        type = "quest",
        id = 55298,
    },
    questline = 924,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {120,50},
    prerequisites = {
        {
            type = "level",
            level = 50,
            visible = false,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND_CHAIN01,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND_CHAIN02,
        },
    },
    active = {
        type = "quest",
        id = 55298,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 56305,
    },
    rewards = {
        {
            type = "achievement",
            id = 13478,
            criteriaId = 44314,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND_CHAIN01,
                },
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND_CHAIN02,
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
            id = 151462,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55298,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55339,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55055,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 56305,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND_CHAIN07, {
    name = { -- Recharging Rustbolt
        type = "quest",
        id = 55211,
    },
    questline = 953,
    questline = 959,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {120,50},
    prerequisites = {
        {
            type = "level",
            level = 50,
            visible = false,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND_CHAIN04,
        },
    },
    active = {
        type = "quest",
        id = 55210,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 55211,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND_CHAIN04,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "npc",
            id = 150630,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55210,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 56320,
            x = 3,
            connections = {
                2, 
            },
        },
        {
            type = "reputation",
            id = 2391,
            standing = 6,
            x = 1,
            y = 3.5,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 56319,
            x = 3,
            y = 4,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55211,
            x = 3,
            -- connections = {
            --     1, 
            -- },
        },
        -- {
        --     name = "More dailies",
        --     x = 3,
        -- },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND_TEMP_CHAIN01, {
    name = "Construction Projects",
    questline = 960,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {120,50},
    prerequisites = {
        type = "level",
        level = 50,
        visible = false,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND_CHAIN04,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "npc",
            id = 150555,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55153,
            x = 3,
            connections = {
                1, 
            },
        },
    },
})


BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND_OTHER_ALLIANCE, {
    name = "Other Alliance",
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND,
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
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND_OTHER_HORDE, {
    name = "Other Horde",
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND,
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
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND_OTHER_BOTH, {
    name = "Other Both",
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND,
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

BtWQuestsDatabase:AddCategory(BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND, {
    name = BtWQuests_GetMapName(MAP_ID),
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    buttonImage = 3025325,
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND_CHAIN01,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND_CHAIN02,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND_CHAIN03,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND_CHAIN04,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND_CHAIN05,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND_CHAIN06,
        },
        -- {
        --     type = "chain",
        --     id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND_TEMP_CHAIN01,
        -- },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND_CHAIN07,
        },
        -- {
        --     type = "chain",
        --     id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND_OTHER_ALLIANCE,
        -- },
        -- {
        --     type = "chain",
        --     id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND_OTHER_HORDE,
        -- },
        -- {
        --     type = "chain",
        --     id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND_OTHER_BOTH,
        -- },
    },
})
BtWQuestsDatabase:AddExpansionItems(BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH, {
    {
        type = "category",
        id = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND,
    },
})

BtWQuestsDatabase:AddMapRecursive(MAP_ID, {
    type = "category",
    id = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_MECHAGON_ISLAND,
})

BtWQuestsDatabase:AddContinentItems(CONTINENT_ID, {
})