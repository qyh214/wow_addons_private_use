if select(4, GetBuildInfo()) < 100107 then
    return
end

local BtWQuests = BtWQuests
local Database = BtWQuests.Database
local L = BtWQuests.L
local EXPANSION_ID = BtWQuests.Constant.Expansions.Dragonflight
local Chain = BtWQuests.Constant.Chain.Dragonflight
local LEVEL_RANGE = {70, 70}
    
Chain.TheCoalitionOfFlames = 100013
Chain.Reconciliation = 100014
Chain.BronzeReconciliation = 100015
Chain.ReforgingTheTyrsGuard = 100016

Database:AddChain(Chain.TheCoalitionOfFlames, {
    name = L["THE_COALITION_OF_FLAMES"],
    questline = 5381,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 70,
        }
    },
    active = {
        type = "quest",
        id = 75918,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 75923,
    },
    items = {
        {
            type = "npc",
            id = 205067,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 75918,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 75919,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 75920,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 75921,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 75922,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 75923,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Reconciliation, {
    name = L["RECONCILIATION"],
    questline = 5464,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 70,
        },
    },
    active = {
        type = "quest",
        id = 76592,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 76597,
    },
    items = {
        {
            type = "npc",
            id = 207790,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76592,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77098,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 77163,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 76593,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 76594,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76595,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76597,
            x = 0,
        },
    },
})
-- Map markers
Database:AddChain(Chain.BronzeReconciliation, {
    name = L["BRONZE_ECONCILIATION"],
    questline = 5508,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 50,
        }
    },
    active = {
        type = "quest",
        id = 76423,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 76422,
    },
    items = {
        {
            type = "npc",
            id = 208035,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76423,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77417,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76407,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76419,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76420,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76421,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76422,
            x = 0,
        },
    },
})
Database:AddChain(Chain.ReforgingTheTyrsGuard, {
    name = L["REFORGING_THE_TYRS_GUARD"],
    questline = 5455,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 70,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Dragonflight.EmbersOfNeltharion.TyrsFall,
        },
    },
    active = {
        type = "quest",
        id = 75632,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 75638,
    },
    items = {
        {
            type = "npc",
            id = 187669,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 75632,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 75633,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 75634,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76171,
            x = 0,
            connections = {
                1, 2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 75950,
            x = -3,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 75951,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 75952,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 75953,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 75635,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76176,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 75636,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 75637,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 75638,
            x = 0,
        },
    },
})

BtWQuestsDatabase:AddExpansionItems(EXPANSION_ID, {
    {
        type = "chain",
        id = Chain.TheCoalitionOfFlames,
    },
    {
        type = "chain",
        id = Chain.Reconciliation,
    },
    {
        type = "chain",
        id = Chain.BronzeReconciliation,
    },
    {
        type = "chain",
        id = Chain.ReforgingTheTyrsGuard,
    },
})
