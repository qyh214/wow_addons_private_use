if select(4, GetBuildInfo()) < 100105 then
    return
end

local BtWQuests = BtWQuests
local Database = BtWQuests.Database
local L = BtWQuests.L
local EXPANSION_ID = BtWQuests.Constant.Expansions.Dragonflight
local Chain = BtWQuests.Constant.Chain.Dragonflight
local LEVEL_RANGE = {70, 70}
    
Chain.DawnOfTheInfinite = 100010
Chain.ForsakenHeritageArmor = 100011
Chain.NightElfHeritageArmor = 100012

Database:AddChain(Chain.DawnOfTheInfinite, {
    name = { -- Dawn of the Infinite
        type = "quest",
        id = 76140,
    },
    questline = 5408,
    buttonImage = 5221768,
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
        id = 76140,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 76145,
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
            id = 76140,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76141,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76142,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76143,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76144,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76145,
            x = 0,
        },
    },
})
Database:AddChain(Chain.ForsakenHeritageArmor, {
    name = { -- I Am Forsaken
        type = "quest",
        id = 72867,
    },
    questline = 1391,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = {
        type = "race",
        id = BtWQuests.Constant.Race.Scourge
    },
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
        {
            name = L["RETURN_TO_LORDAERON"],
            type = "quest",
            id = 65788,
        }
    },
    active = {
        type = "quest",
        id = 76140,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 76145,
    },
    items = {
        {
            type = "npc",
            id = 186091,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76530,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72854,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72855,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 72856,
            x = -2,
            connections = {
                3, 4, 
            },
        },
        {
            type = "quest",
            id = 72857,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 72858,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 72859,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 72860,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72861,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72862,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72863,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72864,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72865,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72866,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72867,
            x = 0,
        },
    },
})
Database:AddChain(Chain.NightElfHeritageArmor, {
    name = { -- Honor of the Goddess
        type = "quest",
        id = 76213,
    },
    questline = 5399,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = {
        type = "race",
        id = BtWQuests.Constant.Race.NightElf
    },
    prerequisites = {
        {
            type = "level",
            level = 50,
        }
    },
    active = {
        type = "quest",
        id = 76140,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 76145,
    },
    items = {
        {
            type = "object",
            id = 405958,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 75890,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 75891,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76194,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 76195,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 76196,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76203,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76197,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 76205,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 76206,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76207,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76212,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76213,
            x = 0,
        },
    },
})

BtWQuestsDatabase:AddExpansionItems(EXPANSION_ID, {
    {
        type = "chain",
        id = Chain.DawnOfTheInfinite,
    },
    {
        type = "chain",
        id = Chain.ForsakenHeritageArmor,
    },
    {
        type = "chain",
        id = Chain.NightElfHeritageArmor,
    },
})
