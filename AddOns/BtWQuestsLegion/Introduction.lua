local BtWQuests = BtWQuests
local L = BtWQuests.L
local Database = BtWQuests.Database
local EXPANSION_ID = BtWQuests.Constant.Expansions.Legion
local Category = BtWQuests.Constant.Category.Legion
local Chain = BtWQuests.Constant.Chain.Legion
local ALLIANCE_RESTRICTIONS, HORDE_RESTRICTIONS = BtWQuests.Constant.Restrictions.Alliance, BtWQuests.Constant.Restrictions.Horde;
local LEVEL_RANGE = {10, 45}
local LEVEL_PREREQUISITES = {
    {
        type = "level",
        level = 10,
    },
}

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_INTRODUCTION_ALLIANCE, {
    name = L["BTWQUESTS_INTRODUCTION"],
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_INTRODUCTION_HORDE,
    },
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 40519,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        ids = {44663, 44184},
    },
    range = LEVEL_RANGE,
    items = {
        {
            type = "quest",
            id = 40519,
            breadcrumb = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 42782,
            breadcrumb = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 42740,
            breadcrumb = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 40517,
            breadcrumb = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 40593,
            breadcrumb = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 44120,
            breadcrumb = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 44184,
                    restrictions = {
                        type = "quest",
                        id = 44184,
                        status = {'active', 'completed'}
                    }
                },
                {
                    type = "quest",
                    id = 44663,
                }
            },
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_INTRODUCTION_HORDE, {
    name = L["BTWQUESTS_INTRODUCTION"],
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_INTRODUCTION_ALLIANCE,
    },
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 40519,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 44663,
    },
    range = LEVEL_RANGE,
    items = {
        {
            type = "quest",
            id = 43926,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 44281,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 40518,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 40522,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 40760,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 40607,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 40605,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 44663,
            x = 0,
        },
    },
})

BtWQuestsDatabase:AddExpansionItems(EXPANSION_ID, {
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_LEGION_INTRODUCTION_ALLIANCE,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_LEGION_INTRODUCTION_HORDE,
    },
})