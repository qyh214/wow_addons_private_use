if select(4, GetBuildInfo()) < 110107  then
    return
end

local BtWQuests = BtWQuests
local Database = BtWQuests.Database
local L = BtWQuests.L
local EXPANSION_ID = BtWQuests.Constant.Expansions.TheWarWithin
local Chain = BtWQuests.Constant.Chain.TheWarWithin
local LEVEL_RANGE = {80, 80}

Chain.RiseOfTheRedDawn = 110010

Database:AddChain(Chain.RiseOfTheRedDawn, {
    name = { -- Rise of the Red Dawn
        type = "quest",
        id = 84717,
    },
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    questline = 5684,
    prerequisites = {
        {
            type = "level",
            level = 80,
        },
    },
    active = {
        type = "quest",
        ids = { 91039, 84638, },
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 85529,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 91039,
                    restrictions = {
                        type = "quest",
                        id = 91039,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 223875,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 84638,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 84639,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 84658,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 84640,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 84641,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 84643,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 84645,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 84649,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 84650,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 84651,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 84652,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 84656,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 84704,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 84707,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 84705,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 84706,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 84708,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 84709,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 84710,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 85451,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 84711,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 84712,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 84713,
                    restrictions = 923,
                },
                {
                    type = "quest",
                    id = 84657,
                },
            },
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 84715,
                    restrictions = 923,
                    connections = {
                        2, 
                    },
                },
                {
                    type = "quest",
                    id = 84659,
                    connections = {
                        3, 
                    },
                },
            },
            x = -1,
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 84714,
                    restrictions = 923,
                    connections = {
                        1, 
                    },
                },
                {
                    type = "quest",
                    id = 87299,
                    connections = {
                        2, 
                    },
                },
            },
        },
        {
            type = "quest",
            id = 84716,
            restrictions = 923,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 84717,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 85529,
            x = 0,
        },
    }
})

BtWQuestsDatabase:AddExpansionItems(EXPANSION_ID, {
    {
        type = "chain",
        id = Chain.RiseOfTheRedDawn,
    },
})

BtWQuestsDatabase:AddQuestItemsForChain(Chain.RiseOfTheRedDawn)
