local BtWQuests = BtWQuests;
local L = BtWQuests.L;
local Database = BtWQuests.Database;
local EXPANSION_ID = BtWQuests.Constant.Expansions.BattleForAzeroth;
local CATEGORY_ID = BtWQuests.Constant.Category.BattleForAzeroth.AlliedRaces;
local Chain = BtWQuests.Constant.Chain.BattleForAzeroth.AlliedRaces;
local ALLIANCE_ID, HORDE_ID = BtWQuests.Constant.Faction.Alliance, BtWQuests.Constant.Faction.Horde;
local ALLIANCE_RESTRICTIONS, HORDE_RESTRICTIONS = BtWQuests.Constant.Restrictions.Alliance, BtWQuests.Constant.Restrictions.Horde;

Database:AddChain(Chain.DarkIronDwarves, {
    name = { -- Dark Iron Dwarves
        type = "quest",
        id = 53566,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {120},
    alternatives = {
        Chain.MagharOrc,
    },
    restrictions = {
        type = "faction",
        id = ALLIANCE_ID,
    },
    prerequisites = {
        {
            type = "achievement",
            id = 12510,
            anyone = true,
        },
        -- {
        --     name = {
        --         type = "reputation",
        --         id = 2159,
        --         standing = 8,
        --     },
        --     type = "achievement",
        --     id = 12954,
        --     anyone = true,
        -- },
    },
    active = {
        type = "quest",
        id = 51813,
        status = {'active', 'completed'},
    },
    completed = {
        type = "achievement",
        id = 12515,
        anyone = true,
    },
    rewards = {
        {
            name = L["BTWQUESTS_ALLIED_RACE_DARK_IRON_DWARF"],
        },
        {
            type = "currency",
            id = 1553,
            amount = 600,
        },
    },
    items = {
        {
            type = "quest",
            id = 51813,
            x = 3,
            y = 0,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 53351,
            x = 3,
            y = 1,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 53342,
            x = 3,
            y = 2,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 53352,
            x = 3,
            y = 3,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 51474,
            x = 3,
            y = 4,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 53566,
            x = 3,
            y = 5,
        },
    },
})
Database:AddChain(Chain.MagharOrc, {
    name = L["BTWQUESTS_MAGHAR_ORC"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {120},
    alternatives = {
        Chain.DarkIronDwarves,
    },
    restrictions = {
        type = "faction",
        id = HORDE_ID,
    },
    prerequisites = {
        {
            type = "achievement",
            id = 12509,
            anyone = true,
        },
        -- {
        --     name = {
        --         type = "reputation",
        --         id = 2157,
        --         standing = 8,
        --     },
        --     type = "achievement",
        --     id = 12957,
        --     anyone = true,
        -- },
    },
    active = {
        type = "quest",
        id = 53466,
        status = {'active', 'completed'},
    },
    completed = {
        type = "achievement",
        id = 12518,
        anyone = true,
    },
    rewards = {
        {
            name = L["BTWQUESTS_ALLIED_RACE_MAGHAR_ORC"],
        },
    },
    items = {
        {
            type = "quest",
            id = 53466,
            x = 3,
            y = 0,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 53467,
            x = 3,
            y = 1,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 53354,
            x = 3,
            y = 2,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 53353,
            x = 3,
            y = 3,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 53355,
            x = 3,
            y = 4,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 52942,
            x = 3,
            y = 5,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 52943,
            x = 3,
            y = 6,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 52945,
            x = 3,
            y = 7,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 52955,
            x = 3,
            y = 8,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 51479,
            x = 3,
            y = 9,
        },
    },
})
Database:AddChain(Chain.KulTiran, {
    name = { -- Allegiance of Kul Tiras
        type = "quest",
        id = 53720,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {120},
    alternatives = {
        Chain.ZandalariTroll,
    },
    restrictions = {
        type = "faction",
        id = ALLIANCE_ID,
    },
    prerequisites = {
        {
            type = "achievement",
            id = 12891,
            anyone = true,
        },
        {
            type = "achievement",
            id = 13467,
            anyone = true,
        },
        -- {
        --     name = {
        --         type = "reputation",
        --         id = 2160,
        --         standing = 8,
        --     },
        --     type = "achievement",
        --     id = 12951,
        --     anyone = true,
        -- },
    },
    active = {
        type = "quest",
        id = 54706,
        status = {'active', 'completed'},
    },
    completed = {
        type = "achievement",
        id = 13163,
        anyone = true,
    },
    rewards = {
        {
            name = L["BTWQUESTS_ALLIED_RACE_KUL_TIRAN"],
        },
    },
    items = {
        {
            type = "quest",
            id = 54706,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 55039,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 55043,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54708,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54721,
            x = 3,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 54723,
            x = 2,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 54725,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54726,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54727,
            x = 3,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 54728,
            x = 2,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 54729,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 54730,
            x = 2,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 54732,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 54731,
            x = 2,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 55136,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54733,
            x = 4,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54734,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54735,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54851,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 53720,
            x = 3,
        },
    },
})
Database:AddChain(Chain.ZandalariTroll, {
    name = { -- Allegiance of the Zandalari
        type = "quest",
        id = 53719,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {120},
    alternatives = {
        Chain.KulTiran,
    },
    restrictions = {
        type = "faction",
        id = HORDE_ID,
    },
    prerequisites = {
        {
            type = "achievement",
            id = 12479,
            anyone = true,
        },
        {
            type = "achievement",
            id = 13466,
            anyone = true,
        },
        -- {
        --     name = {
        --         type = "reputation",
        --         id = 2103,
        --         standing = 8,
        --     },
        --     type = "achievement",
        --     id = 12950,
        --     anyone = true,
        -- },
    },
    active = {
        type = "quest",
        id = 53831,
        status = {'active', 'completed'},
    },
    completed = {
        type = "achievement",
        id = 13161,
        anyone = true,
    },
    rewards = {
        {
            name = L["BTWQUESTS_ALLIED_RACE_ZANDALARI_TROLL"],
        },
    },
    items = {
        {
            type = "quest",
            id = 53831,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 53823,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 53824,
            x = 3,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 53826,
            x = 2,
            connections = {
                2, 3, 4,
            },
        },
        {
            type = "quest",
            id = 54419,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 54925,
            x = 1,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 54301,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 54300,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 53825,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 53827,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 53828,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54031,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54033,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54032,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54034,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 53830,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 53719,
            x = 3,
        },
    },
})
Database:AddChain(Chain.Vulpera, {
    name = L["VULPERA"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {120},
    alternatives = {
        Chain.Mechagnomes,
    },
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = {
        {
            type = "achievement",
            id = 12478,
            anyone = true,
        },
        -- {
        --     name = {
        --         type = "reputation",
        --         id = 2158,
        --         standing = 8,
        --     },
        --     type = "achievement",
        --     id = 12949,
        --     anyone = true,
        -- },
    },
    active = {
        type = "quest",
        id = 53870,
        status = {'active', 'completed'},
    },
    completed = {
        type = "achievement",
        id = 13206,
        anyone = true,
    },
    rewards = {
        {
            name = L["ALLIED_RACE_VULPERA"],
        },
    },
    items = {
        {
            type = "npc",
            id = 133523,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 53870,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 53889,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 53890,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 53891,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 53892,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 53893,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 53894,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 53895,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 53897,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 53898,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 54026,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 53899,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 53901,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 53900,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 58087,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 53902,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 54027,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 53903,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 53904,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 53905,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 54036,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 53906,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 53907,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 53908,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 57448,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Mechagnomes, {
    name = L["MECHAGNOME"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {120},
    alternatives = {
        Chain.Vulpera,
    },
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = {
        {
            type = "achievement",
            id = 13553,
            anyone = true,
        },
        -- {
        --     name = {
        --         type = "reputation",
        --         id = 2391,
        --         standing = 8,
        --     },
        --     type = "achievement",
        --     id = 13557,
        --     anyone = true,
        -- },
    },
    active = {
        type = "quest",
        id = 57497,
        status = {'active', 'completed'},
    },
    completed = {
        type = "achievement",
        id = 14013,
        anyone = true,
    },
    rewards = {
        {
            name = L["ALLIED_RACE_MECHAGNOME"],
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 58214,
                    restrictions = BtWQuestsItem_ActiveOrCompleted
                },
                {
                    type = "npc",
                    id = 160101,
                }
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 57486,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 57487,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 57488,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 57490,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 57491,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 57492,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 57493,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 57494,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 57496,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 57495,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 57497,
            x = 0,
        },
    },
})

Database:AddCategory(CATEGORY_ID, {
    name = L["BTWQUESTS_ALLIED_RACES"],
    expansion = EXPANSION_ID,
    items = {
        {
            type = "chain",
            id = Chain.DarkIronDwarves,
        },
        {
            type = "chain",
            id = Chain.MagharOrc,
        },
        {
            type = "chain",
            id = Chain.KulTiran,
        },
        {
            type = "chain",
            id = Chain.ZandalariTroll,
        },
        {
            type = "chain",
            id = Chain.Vulpera,
        },
        {
            type = "chain",
            id = Chain.Mechagnomes,
        },
    },
})

Database:AddExpansionItem(EXPANSION_ID, {
    type = "category",
    id = CATEGORY_ID,
})
