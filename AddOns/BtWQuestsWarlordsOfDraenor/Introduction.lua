local BtWQuests = BtWQuests;
local L = BtWQuests.L;
local Database = BtWQuests.Database;
local EXPANSION_ID = BtWQuests.Constant.Expansions.WarlordsOfDraenor;
local Chain = BtWQuests.Constant.Chain.WarlordsOfDraenor;
local ALLIANCE_RESTRICTION, HORDE_RESTRICTION = BtWQuests.Constant.Restrictions.Alliance, BtWQuests.Constant.Restrictions.Horde

BtWQuestsDatabase:AddChain(Chain.Introduction, {
    name = L["BTWQUESTS_INTRODUCTION"],
    category = nil,
    expansion = EXPANSION_ID,
    major = true,
    range = {10,60},
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
    },
    active = {
        type = "quest",
        ids = {34398, 36881, 35933},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {35884, 34446},
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 34398,
                    restrictions = {
                        type = "quest",
                        id = 34398,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "quest",
                    id = 36881,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35933,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34392,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34393,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34420,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 34422,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 35240,
                    restrictions = ALLIANCE_RESTRICTION
                },
                {
                    type = "quest",
                    id = 34421,
                },
            },
            connections = {
                2, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 35242,
                    restrictions = ALLIANCE_RESTRICTION
                },
                {
                    type = "quest",
                    id = 35241,
                },
            },
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34423,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34425,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 34478,
                    restrictions = ALLIANCE_RESTRICTION
                },
                {
                    type = "quest",
                    id = 34427,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34429,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 34431,
                    restrictions = ALLIANCE_RESTRICTION
                },
                {
                    type = "quest",
                    id = 34737,
                },
            },
            x = -2,
            connections = {
                3, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 34432,
                    restrictions = ALLIANCE_RESTRICTION
                },
                {
                    type = "quest",
                    id = 34739,
                },
            },
            connections = {
                2, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 34434,
                    restrictions = ALLIANCE_RESTRICTION
                },
                {
                    type = "quest",
                    id = 34740,
                },
            },
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 34436,
                    restrictions = ALLIANCE_RESTRICTION
                },
                {
                    type = "quest",
                    id = 34741,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 35005,
                    restrictions = ALLIANCE_RESTRICTION
                },
                {
                    type = "quest",
                    id = 35019,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34439,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 34987,
            x = -2,
            connections = {
                5, 
            },
        },
        {
            type = "quest",
            id = 34442,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 34958,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 34925,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34437,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35747,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34445,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 35884,
                    restrictions = ALLIANCE_RESTRICTION
                },
                {
                    type = "quest",
                    id = 34446,
                },
            },
            x = 0,
        },
    },
})

BtWQuestsDatabase:AddExpansionItems(EXPANSION_ID, {
    {
        type = "chain",
        id = Chain.Introduction,
    },
})

-- Introduction map
BtWQuestsDatabase:AddMap(577, {
    type = "chain",
    id = Chain.Introduction,
})