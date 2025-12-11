local BtWQuests = BtWQuests
local Database = BtWQuests.Database
local EXPANSION_ID = BtWQuests.Constant.Expansions.TheWarWithin
local Chain = BtWQuests.Constant.Chain.TheWarWithin.SirenIsle
local MAP_ID = 2214
local CONTINENT_ID = 2274
local LEVEL_RANGE = {80, 80}

Chain.Chain01 = 110501
Chain.Chain02 = 110502
Chain.Chain03 = 110503
Chain.Chain04 = 110504

Database:AddChain(Chain.Chain01, {
    name = BtWQuests_GetAchievementNameDelayed(41045),
    questline = 5732,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 80,
        },
    },
    active = {
        type = "quest",
        id = 84719,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 84726,
    },
    items = {
        {
            type = "npc",
            id = 232132,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 84719,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 84720,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 84940,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 84721,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 84722,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 84727,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 84941,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 84723,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 84724,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 84728,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 84725,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 84726,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain02, {
    name = { -- Lingering Shadows
        type = "quest",
        id = 82690,
    },
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 80,
        },
    },
    active = {
        type = "quest",
        id = 82690,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 82702,
    },
    items = {
        {
            type = "npc",
            id = 227758,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82690,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 82692,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 82693,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 82691,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82694,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82695,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82696,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82697,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 82699,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 82698,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82700,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82701,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82702,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 84701,
            aside = true,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain03, {
    name = BtWQuests_GetAchievementNameDelayed(40791),
    questline = 5664,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 80,
        },
    },
    active = {
        type = "quest",
        id = 84223,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 83643,
    },
    items = {},
})
Database:AddChain(Chain.Chain04, {
    name = { -- A Loyal Friend
        type = "quest",
        id = 86485,
    },
    questline = 5664,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 80,
        },
        {
            type = "chain",
            id = Chain.Chain01,
        },
    },
    active = {
        type = "quest",
        id = 86482,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 86485,
    },
    items = {
        {
            type = "npc",
            id = 235216,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 86482,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            name = "Feed Growing Snapdragon Runt",
            breadcrumb = true,
            active = {
                type = "quest",
                ids = {
                    86482, 86566, 
                },
                count = 2,
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 86483,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            name = "Feed Maturing Prismatic Snapdragon",
            breadcrumb = true,
            active = {
                type = "quest",
                ids = {
                    86483, 86566, 
                },
                count = 2,
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 86484,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            name = "Feed Mature Prismatic Snapdragon",
            breadcrumb = true,
            active = {
                type = "quest",
                ids = {
                    86484, 86566, 
                },
                count = 2,
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 86485,
            x = 0,
        },
    },
})

Database:AddExpansionItems(EXPANSION_ID, {
    {
        type = "chain",
        id = Chain.Chain01,
    },
    {
        type = "chain",
        id = Chain.Chain02,
    },
})

BtWQuestsDatabase:AddQuestItemsForChain(Chain.Chain01)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.Chain02)
