local BtWQuests = BtWQuests
local L = BtWQuests.L
local Database = BtWQuests.Database
local EXPANSION_ID = BtWQuests.Constant.Expansions.Shadowlands
local Chain = BtWQuests.Constant.Chain.Shadowlands
local LEVEL_RANGE = {50, 50}
local LEVEL_PREREQUISITES = {
    {
        type = "level",
        level = 50,
    },
}

Chain.PrologueAlliance = 90091
Chain.PrologueHorde = 90092
Chain.PrologueBothEmbed01 = 90093

Database:AddChain(Chain.PrologueAlliance, {
    name = L["BTWQUESTS_PROLOGUE"],
    questline = 1128,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    alternatives = {
        Chain.PrologueHorde,
    },
    restrictions = 924,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 60113,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 60871,
    },
    items = {
        {
            type = "quest",
            id = 60113,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 60116,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 60117,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 59876,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 60766,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 60767,
            x = 0,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 59877,
            x = -1,
            connections = {
                2.1, 2.2,
            },
        },
        {
            type = "quest",
            id = 61486,
            aside = true,
        },
        {
            type = "chain",
            id = Chain.PrologueBothEmbed01,
            embed = true,
            x = 0,
        },
    }
})
Database:AddChain(Chain.PrologueHorde, {
    name = L["BTWQUESTS_PROLOGUE"],
    questline = 1129,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    alternatives = {
        Chain.PrologueAlliance,
    },
    restrictions = 923,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 60115,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 60869,
    },
    items = {
        {
            type = "quest",
            id = 60115,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 60669,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 60670,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 60725,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 60759,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 60761,
            x = 0,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 60727,
            x = -1,
            connections = {
                2.1, 2.2,
            },
        },
        {
            type = "quest",
            id = 61488,
            aside = true,
        },
        {
            type = "chain",
            id = Chain.PrologueBothEmbed01,
            embed = true,
            x = 0,
        },
    }
})
Database:AddChain(Chain.PrologueBothEmbed01, {
    questline = 1130,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    items = {
        {
            type = "quest",
            id = 60169,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            ids = {
                60003, 60004, 
            },
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 62157,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 60827,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            name = L["WEEK_2"],
            breadcrumb = true,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 60828,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 60843,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 62185,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 60861,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 62225,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 60867,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 60932,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 60871,
                    restrictions = 924,
                },
                {
                    type = "quest",
                    id = 60869,
                },
            },
            x = 0,
        },
    }
})

BtWQuestsDatabase:AddExpansionItems(EXPANSION_ID, {
    {
        type = "chain",
        id = Chain.PrologueAlliance,
    },
    {
        type = "chain",
        id = Chain.PrologueHorde,
    },
})