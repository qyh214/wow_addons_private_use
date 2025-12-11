local BtWQuests = BtWQuests;
local Database = BtWQuests.Database;
local EXPANSION_ID = BtWQuests.Constant.Expansions.MistsOfPandaria;
local CATEGORY_ID = BtWQuests.Constant.Category.MistsOfPandaria.KrasarangWilds;
local Chain = BtWQuests.Constant.Chain.MistsOfPandaria.KrasarangWilds;
local ALLIANCE_RESTRICTION, HORDE_RESTRICTION = BtWQuests.Constant.Restrictions.Alliance, BtWQuests.Constant.Restrictions.Horde;
local MAP_ID = 418
local ACHIEVEMENT_ID_ALLIANCE = 6535
local ACHIEVEMENT_ID_HORDE = 6536
local CONTINENT_ID = 424

Chain.ZhusWatch = 50301
Chain.TheIncursion = 50302
Chain.NayeliLagoon = 50303
Chain.TempleOfTheRedCrane = 50304
Chain.TheWatersOfYouth = 50305
Chain.ThunderCleft = 50306
Chain.DawnchaserRetreat = 50307

Chain.Chain01 = 50311

Database:AddChain(Chain.ZhusWatch, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 1),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {15,35},
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
    },
    active = {
        type = "quest",
        ids = {30079, 30080, 30082},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 30090,
    },
    items = {
        {
            type = "npc",
            id = 56115,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "npc",
            id = 57744,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 30079,
            x = -1,
            connections = {
                3, 4, 
            },
        },
        {
            type = "quest",
            id = 30080,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30082,
            x = 1,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 30081,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 30091,
            aside = true,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 30088,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 30083,
            aside = true,
        },
        {
            type = "quest",
            id = 30084,
            aside = true,
        },
        {
            type = "quest",
            id = 30089,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30090,
            x = 0,
        },
    },
})

Database:AddChain(Chain.TheIncursion, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 2),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {15,35},
    major = true,
    alternatives = {
        Chain.ThunderCleft,
    },
    restrictions = ALLIANCE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
    },
    active = {
        type = "quest",
        id = 30274,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 30348,
    },
    items = {
        {
            type = "quest",
            id = 30274,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 30344,
            x = -2,
            connections = {
                3, 4, 5, 
            },
        },
        {
            type = "quest",
            id = 30350,
            connections = {
                2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 30384,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 30349,
            x = -2,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 30346,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 30351,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 30347,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30348,
            x = 0,
        },
    },
})
Database:AddChain(Chain.ThunderCleft, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 2),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {15,35},
    major = true,
    alternatives = {
        Chain.TheIncursion,
    },
    restrictions = HORDE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
    },
    active = {
        type = "quest",
        id = 30179,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 30131,
    },
    items = {
        {
            type = "npc",
            id = 58160,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30179,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 30123,
            x = -1,
            connections = {
                2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 30124,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 30127,
            x = -2,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 30129,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 30130,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 30128,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30131,
            x = 0,
        },
    },
})

Database:AddChain(Chain.NayeliLagoon, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 3),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {15,35},
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
    },
    active = {
        type = "quest",
        id = 30666,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {30674, 30675, 30672},
        count = 3,
    },
    items = {
        {
            type = "npc",
            id = 60173,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = Chain.Chain01,
            aside = true,
            embed = true,
        },
        {
            type = "quest",
            id = 30666,
            x = 0,
            y = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30668,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30669,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 30671,
            x = -1,
            connections = {
                2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 30691,
            aside = true,
        },
        {
            type = "quest",
            id = 30672,
            x = -2,
        },
        {
            type = "quest",
            id = 30674,
        },
        {
            type = "quest",
            id = 30675,
        },
    },
})
Database:AddChain(Chain.TempleOfTheRedCrane, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 4),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {15,35},
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
        {
            type = "chain",
            id = Chain.ZhusWatch,
        },
    },
    active = {
        type = "quest",
        ids = {
            30133, 30178, 30461, 30462, 
        },
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 30273,
    },
    items = {
        {
            type = "npc",
            id = 57744,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            ids = {
                30133, 30178, 30461, 30462, 
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30269,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 30268,
            x = -2,
            connections = {
                3, 4, 5, 
            },
        },
        {
            type = "quest",
            id = 30270,
            connections = {
                2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 30694,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 30271,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 30695,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 30272,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30273,
            x = 0,
        },
    },
})

Database:AddChain(Chain.TheWatersOfYouth, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 5),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {15,35},
    major = true,
    alternatives = {
        Chain.DawnchaserRetreat,
    },
    restrictions = ALLIANCE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
        {
            type = "chain",
            id = Chain.TheIncursion,
        },
    },
    active = {
        type = "quest",
        ids = {
            30363, 30465, 
        },
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 30445,
    },
    items = {
        {
            type = "npc",
            id = 58735,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            ids = {
                30363, 30465, 
            },
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 30354,
            x = -2,
            connections = {
                3, 4, 
            },
        },
        {
            type = "quest",
            id = 30355,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 30356,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 30361,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 30357,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30359,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30445,
            x = 0,
        },
    },
})
Database:AddChain(Chain.DawnchaserRetreat, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 5),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {15,35},
    major = true,
    alternatives = {
        Chain.TheWatersOfYouth,
    },
    restrictions = HORDE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
        {
            type = "chain",
            id = Chain.ThunderCleft,
        },
    },
    active = {
        type = "quest",
        ids = {
            30132, 30464, 
        },
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 30174,
    },
    items = {
        {
            type = "npc",
            id = 58113,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            ids = {
                30132, 30464, 
            },
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 30163,
            x = -2,
            connections = {
                3, 4, 
            },
        },
        {
            type = "quest",
            id = 30229,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 30230,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 30175,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 30164,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30174,
            x = 0,
        },
    },
})

Database:AddChain(Chain.Chain01, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {1,35},
    items = {
        {
            type = "npc",
            id = 60182,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30667,
            x = 0,
        },
    },
})

Database:AddCategory(CATEGORY_ID, {
    name = BtWQuests.GetMapName(MAP_ID),
    expansion = EXPANSION_ID,
    items = {
        {
            type = "chain",
            id = Chain.ZhusWatch,
        },
        {
            type = "chain",
            id = Chain.TheIncursion,
        },
        {
            type = "chain",
            id = Chain.NayeliLagoon,
        },
        {
            type = "chain",
            id = Chain.TempleOfTheRedCrane,
        },
        {
            type = "chain",
            id = Chain.TheWatersOfYouth,
        },
        {
            type = "chain",
            id = Chain.ThunderCleft,
        },
        {
            type = "chain",
            id = Chain.DawnchaserRetreat,
        },
    },
})

Database:AddExpansionItem(EXPANSION_ID, {
    type = "category",
    id = CATEGORY_ID,
})

Database:AddMapRecursive(MAP_ID, {
    type = "category",
    id = CATEGORY_ID,
})

Database:AddContinentItems(CONTINENT_ID, {
})
