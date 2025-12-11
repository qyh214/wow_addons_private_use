local BtWQuests = BtWQuests;
local Database = BtWQuests.Database;
local EXPANSION_ID = BtWQuests.Constant.Expansions.MistsOfPandaria;
local CATEGORY_ID = BtWQuests.Constant.Category.MistsOfPandaria.TownlongSteppes;
local Chain = BtWQuests.Constant.Chain.MistsOfPandaria.TownlongSteppes;
local MAP_ID = 388
local ACHIEVEMENT_ID = 6539
local CONTINENT_ID = 424

Chain.FireCampOsul = 50501
Chain.MistlurkersInTheSumprushes = 50502
Chain.OnHatredsPath = 50503
Chain.TheShaOfHatred = 50504
Chain.TaiHosInvestigation = 50505

Database:AddChain(Chain.FireCampOsul, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 1),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {25,35},
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 25,
        },
    },
    active = {
        type = "quest",
        ids = {30768, 30814},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 30784,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 30768,
                    restrictions = {
                        type = "quest",
                        id = 30768,
                        status = {'active', 'completed'}
                    },
                },
                {
                    type = "npc",
                    id = 60688,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30814,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 30769,
            x = -2,
            connections = {
                3, 4, 5, 6, 
            },
        },
        {
            type = "quest",
            id = 30770,
            connections = {
                2, 3, 4, 5, 
            },
        },
        {
            type = "quest",
            id = 30771,
            connections = {
                1, 2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 30772,
            x = -3,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 30773,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 30774,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 30775,
            aside = true,
        },
        {
            type = "quest",
            id = 30776,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30777,
            x = 0,
            connections = {
                1, 2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 30778,
            x = -3,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 30779,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 30780,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 30781,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30827,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 30782,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 30783,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30784,
            x = 0,
        },
    },
})
Database:AddChain(Chain.MistlurkersInTheSumprushes, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 2),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {25,35},
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 25,
        },
    },
    active = {
        type = "quest",
        ids = {31894, 30786},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 30793,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 31894,
                    restrictions = {
                        type = "quest",
                        id = 31894,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 60857,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30786,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30787,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 30788,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 30789,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30815,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 30790,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 30791,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 30792,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30793,
            x = 0,
        },
    },
})
Database:AddChain(Chain.OnHatredsPath, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 3),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {25,35},
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 25,
        },
    },
    active = {
        type = "quest",
        ids = {30785, 30884, 30891},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 30900,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 30785,
                    restrictions = {
                        type = "quest",
                        id = 30785,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 61066,
                },
            },
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "npc",
            id = 61470,
            x = 3,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 30884,
            x = -1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30887,
            x = -1,
            connections = {
                2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 30891,
            x = 3,
            connections = {
                6, 7, 
            },
        },
        {
            type = "quest",
            id = 30888,
            x = -3,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 30890,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 30889,
        },
        {
            type = "quest",
            id = 30960,
            x = -1,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 30893,
            x = -1,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 30892,
            x = 1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 30894,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30895,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30898,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30900,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheShaOfHatred, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 4),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {25,35},
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 25,
        },
        {
            type = "chain",
            id = Chain.OnHatredsPath,
        },
    },
    active = {
        type = "quest",
        id = 30901,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 30968,
    },
    items = {
        {
            type = "npc",
            id = 61066,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30901,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 30970,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 30971,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30972,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30973,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30975,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30976,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 30899,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 30977,
            aside = true,
        },
        {
            type = "quest",
            id = 31032,
            aside = true,
        },
        {
            type = "quest",
            id = 30978,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30979,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30980,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 31065,
            x = 0,
            connections = {
                1, 2, 3, 4, 5, 
            },
        },
        {
            type = "quest",
            id = 31687,
            aside = true,
            x = -3,
        },
        {
            type = "quest",
            id = 30981,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 31063,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 31688,
            aside = true,
        },
        {
            type = "quest",
            id = 31064,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30968,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TaiHosInvestigation, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 5),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {25,35},
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 25,
        },
    },
    active = {
        type = "quest",
        ids = {30921, 30923},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 30926,
    },
    items = {
        {
            type = "npc",
            id = 61482,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 30921,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 30923,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30924,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30925,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 30927,
            aside = true,
            x = -2,
        },
        {
            type = "quest",
            id = 30926,
        },
        {
            type = "quest",
            id = 30928,
            aside = true,
        },
    },
})

Database:AddCategory(CATEGORY_ID, {
    name = BtWQuests.GetMapName(MAP_ID),
    expansion = EXPANSION_ID,
    items = {
        {
            type = "chain",
            id = Chain.FireCampOsul,
        },
        {
            type = "chain",
            id = Chain.MistlurkersInTheSumprushes,
        },
        {
            type = "chain",
            id = Chain.OnHatredsPath,
        },
        {
            type = "chain",
            id = Chain.TheShaOfHatred,
        },
        {
            type = "chain",
            id = Chain.TaiHosInvestigation,
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
