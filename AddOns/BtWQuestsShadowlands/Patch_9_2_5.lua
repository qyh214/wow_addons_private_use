local BtWQuests = BtWQuests
local L = BtWQuests.L
local Database = BtWQuests.Database
local EXPANSION_ID = BtWQuests.Constant.Expansions.Shadowlands
local Chain = BtWQuests.Constant.Chain.Shadowlands
local LEVEL_RANGE = {60, 60}

Database:AddChain(Chain.Chain92501, {
    name = L["KNIGHTS_OF_BLOOD"],
    questline = 1216,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    crest = "blood-elf",
    restrictions = {
        type = "race",
        id = BtWQuests.Constant.Race.BloodElf
    },
    prerequisites = {
        {
            type = "level",
            level = 60,
        },
        {
            type = "reputation",
            id = 911,
            standing = 8,
        },
    },
    active = {
        type = "quest",
        ids = { 63479, 65652, },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = { 63490, 65653, },
    },
    rewards = {
        {
            type = "mount",
            id = 1600,
        },
        {
            type = "item",
            id = 191565,
            restrictions = {
                type = "class",
                id = BtWQuests.Constant.Class.Paladin,
            },
        },
        {
            type = "item",
            id = 191604,
        },
        {
            type = "money",
            variations = {
                {
                    amount = 1956240,
                    restrictions = -1,
                },
                {
                    amount = 1956240,
                },
            },
        },
    },
    items = {
        {
            type = "npc",
            id = 176789,
            x = 0,
            connections = {
                1,
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 63479,
                    restrictions = {
                        type = "class",
                        id = BtWQuests.Constant.Class.Paladin,
                    },
                },
                {
                    type = "quest",
                    id = 65652,
                },
            },
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 63480,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 63481,
            x = 0,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 63482,
            x = -1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 63483,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 63484,
            x = 0,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 63485,
            x = -1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 63486,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 63522,
            x = -1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 63519,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 63487,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 63488,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 63489,
            x = 0,
            connections = {
                1,
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 63490,
                    restrictions = {
                        type = "class",
                        id = BtWQuests.Constant.Class.Paladin,
                    },
                },
                {
                    type = "quest",
                    id = 65653,
                },
            },
            x = 0,
        },
    }
})
Database:AddChain(Chain.Chain92502, {
    name = { -- Good Fiery Boy
        type = "quest",
        id = 65564,
    },
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    crest = "dark-iron-dwarf",
    restrictions = {
        type = "race",
        id = BtWQuests.Constant.Race.DarkIronDwarf
    },
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
        {
            type = "quest",
            id = 51483,
        },
    },
    active = {
        type = "quest",
        id = 63494,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 65564,
    },
    rewards = {
        {
            type = "mount",
            id = 1597,
        },
        {
            type = "item",
            id = 184922,
        },
        {
            type = "experience",
            amount = 320,
        },
    },
    items = {
        {
            type = "npc",
            id = 144154,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 63494,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 63498,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 63501,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 63502,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 65563,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 65564,
            x = 0,
        },
    }
})
Database:AddChain(Chain.Chain92503, {
    name = { -- Silent Vigil
        type = "quest",
        id = 66170,
    },
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 60,
        },
        {
            type = "chain",
            id = 91108,
        },
    },
    active = {
        type = "quest",
        id = 66170,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 66170,
    },
    rewards = {
        {
            type = "money",
            amount = 128700,
        },
    },
    items = {
        {
            type = "npc",
            id = 187436,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 66170,
            x = 0,
        },
    }
})
Database:AddChain(Chain.Chain92504, {
    name = L["RETURN_TO_LORDAERON"],
    questline = 1294,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    crest = "alliance",
    major = true,
    restrictions = BtWQuests.Constant.Restrictions.Alliance,
    prerequisites = {
        {
            type = "level",
            level = 60,
        },
    },
    active = {
        type = "quest",
        id = 65655,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 65669,
    },
    rewards = {
        {
            name = L["DARK_RANGER_ELF_CUSTOMIZATION"],
        },
        {
            name = L["OF_LORDAERON_TITLE"],
        },
        {
            type = "experience",
            amount = 75300,
        },
        {
            type = "money",
            amount = 3063060,
        },
        {
            type = "reputation",
            id = 68,
            amount = 3000,
        },
        {
            type = "reputation",
            id = 1134,
            amount = 3000,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "npc",
            id = 185525,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 65655,
            x = 0,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 65657,
            x = -1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 65658,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 65659,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 65660,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 65661,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 65662,
            x = 0,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 65663,
            x = -1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 65664,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 65665,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 65666,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 65667,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 65668,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 66090,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 65669,
            x = 0,
        },
    }
})
Database:AddChain(Chain.Chain92505, {
    name = L["RETURN_TO_LORDAERON"],
    questline = 1295,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    crest = "horde",
    major = true,
    restrictions = BtWQuests.Constant.Restrictions.Horde,
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
    },
    active = {
        type = "quest",
        id = 65656,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 65788,
    },
    rewards = {
        {
            name = L["DARK_RANGER_ELF_CUSTOMIZATION"],
        },
        {
            name = L["OF_LORDAERON_TITLE"],
        },
        {
            type = "experience",
            amount = 73320,
        },
        {
            type = "money",
            amount = 3011580,
        },
        {
            type = "reputation",
            id = 68,
            amount = 3000,
        },
    },
    items = {
        {
            type = "npc",
            id = 173386,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 65656,
            x = 0,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 65657,
            x = -1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 65658,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 65659,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 65660,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 65661,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 65662,
            x = 0,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 65663,
            x = -1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 65664,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 65665,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 65666,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 65667,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 65668,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 66091,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 65788,
            x = 0,
        },
    }
})
Database:AddChain(Chain.Chain92506, {
    name = { -- A Gift of Hope
        type = "quest",
        id = 66243,
    },
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 60,
        },
        {
            type = "chain",
            id = 91108,
        },
    },
    active = {
        type = "quest",
        id = 66243,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 66243,
    },
    rewards = {
        {
            type = "money",
            amount = 128700,
        },
    },
    items = {
        {
            type = "npc",
            id = 187905,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 66243,
            x = 0,
        },
    }
})

Database:AddExpansionItems(EXPANSION_ID, {
    {
        type = "chain",
        id = Chain.Chain92504,
    },
    {
        type = "chain",
        id = Chain.Chain92505,
    },
    {
        type = "chain",
        id = Chain.Chain92503,
    },
    {
        type = "chain",
        id = Chain.Chain92506,
    },
    {
        type = "chain",
        id = Chain.Chain92501,
    },
    {
        type = "chain",
        id = Chain.Chain92502,
    },
})
