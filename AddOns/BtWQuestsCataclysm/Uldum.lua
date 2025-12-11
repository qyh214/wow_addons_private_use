local BtWQuests = BtWQuests;
local Database = BtWQuests.Database;
local EXPANSION_ID = BtWQuests.Constant.Expansions.Cataclysm;
local CATEGORY_ID = BtWQuests.Constant.Category.Cataclysm.Uldum;
local Chain = BtWQuests.Constant.Chain.Cataclysm.Uldum;
local MAP_ID = 249
local ACHIEVEMENT_ID = 4872
local CONTINENT_ID = 12

Chain.RescuedByOutsiders = 40401
Chain.TheHighCouncilsDecision = 40402
Chain.Gnomebliteration = 40403
Chain.TheDarkPharaoh = 40404
Chain.TheseObelisksAreTryingToKillUs = 40405
Chain.TheFurrierSchnottz = 40406
Chain.Promises = 40407

Chain.Chain01 = 40411
Chain.Chain02 = 40412
Chain.Chain03 = 40413

Database:AddChain(Chain.RescuedByOutsiders, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 1),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {30,35},
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 30,
        },
    },
    active = {
        type = "quest",
        ids = {27003},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 28112,
    },
    items = {
        {
            type = "npc",
            id = 44833,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27003,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27922,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 27923,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 27924,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 28105,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28112,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheHighCouncilsDecision, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 2),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {30,35},
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 30,
        },
        {
            type = "chain",
            id = Chain.RescuedByOutsiders,
        },
    },
    active = {
        type = "quest",
        ids = {28134},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 28533,
    },
    items = {
        {
            type = "npc",
            id = 47684,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28134,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28135,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 27519,
            aside = true,
            x = -2,
        },
        {
            type = "quest",
            id = 27595,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 27520,
            aside = true,
        },
        {
            type = "quest",
            id = 27602,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27623,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27706,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27628,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "chain",
            id = Chain.Chain01,
            embed = true,
            x = -3,
            connections = {
                3, 
            },
        },
        {
            type = "chain",
            id = Chain.Chain02,
            embed = true,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = Chain.Chain03,
            embed = true,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28533,
            x = 0,
            y = 15,
        },
    },
})
Database:AddChain(Chain.Gnomebliteration, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 3),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {30,35},
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 30,
        },
        {
            type = "chain",
            id = Chain.RescuedByOutsiders,
        },
        {
            type = "chain",
            id = Chain.TheHighCouncilsDecision,
        },
    },
    active = {
        type = "quest",
        ids = {28561},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {27755, 27779},
        count = 2,
    },
    items = {
        {
            type = "npc",
            id = 47684,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28561,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 28498,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 28499,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28500,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28501,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 27755,
            x = -1,
        },
        {
            type = "quest",
            id = 27760,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 27761,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 27777,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27778,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27779,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheDarkPharaoh, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 4),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {30,35},
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 30,
        },
        {
            type = "chain",
            id = Chain.RescuedByOutsiders,
        },
        {
            type = "chain",
            id = Chain.TheHighCouncilsDecision,
        },
        {
            type = "quest",
            id = 28501,
        },
    },
    active = {
        type = "quest",
        ids = {28623},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 28520,
    },
    items = {
        {
            type = "npc",
            id = 48761,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28623,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 28480,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 28483,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28486,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28520,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheseObelisksAreTryingToKillUs, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 5),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {30,35},
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 30,
        },
        {
            type = "quest",
            id = 27003,
        },
    },
    active = {
        type = "quest",
        ids = {27141},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {27511, 27627, 27905},
        count = 3,
    },
    items = {
        {
            type = "npc",
            id = 44860,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27141,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 27179,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 27176,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27196,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 27511,
            x = -2,
        },
        {
            type = "quest",
            ids = {
                27517, 28602, 
            },
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 27541,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27549,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27431,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27624,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 27669,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 27627,
        },
        {
            type = "npc",
            id = 46978,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 27900,
            x = -1,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 27901,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27903,
            x = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27905,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheFurrierSchnottz, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 6),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {30,35},
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 30,
        },
        {
            type = "quest",
            id = 27003,
        },
        {
            type = "quest",
            id = 27669,
        },
    },
    active = {
        type = "quest",
        ids = {28132, 27926},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 28267,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 28132,
                    restrictions = {
                        type = "quest",
                        id = 28132,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 47670,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27926,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 27928,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 27939,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 27941,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 27942,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 27943,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27950,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27969,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28002,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27990,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28187,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 28194,
            x = -1,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 28193,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28195,
            x = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28267,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Promises, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 7),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {30,35},
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 30,
        },
        {
            type = "quest",
            id = 27003,
        },
        {
            type = "quest",
            id = 27669,
        },
        {
            type = "chain",
            id = Chain.TheFurrierSchnottz,
        },
    },
    active = {
        type = "quest",
        ids = {28269},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {28350, 28351, 28633},
        count = 3,
    },
    items = {
        {
            type = "npc",
            id = 48162,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28269,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28273,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28274,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 28350,
            x = -2,
        },
        {
            type = "quest",
            id = 28352,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 28351,
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 28353,
                    restrictions = {
                        type = "quest",
                        id = 28353,
                        status = {'active', 'completed'}
                    },
                },
                {
                    type = "npc",
                    id = 48186,
                },
            },
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 28271,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 28272,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28363,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28367,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28402,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28403,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28404,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28482,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28497,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28613,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27748,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28612,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28621,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28622,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28633,
            x = 0,
        },
    },
})

Database:AddChain(Chain.Chain01, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {30,35},
    items = {
        {
            type = "quest",
            id = 27631,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28198,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28210,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28276,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28277,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28291,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain02, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {30,35},
    items = {
        {
            type = "quest",
            id = 27630,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 27837,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 27836,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28611,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27838,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain03, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {30,35},
    items = {
        {
            type = "quest",
            id = 27629,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27632,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27707,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27738,
            x = 0,
        },
    },
})

Database:AddCategory(CATEGORY_ID, {
    name = BtWQuests.GetMapName(MAP_ID),
    expansion = EXPANSION_ID,
	buttonImage = {
		texture = 1851128,
		texCoords = {0,1,0,1},
	},
    items = {
        {
            type = "chain",
            id = Chain.RescuedByOutsiders,
        },
        {
            type = "chain",
            id = Chain.TheHighCouncilsDecision,
        },
        {
            type = "chain",
            id = Chain.Gnomebliteration,
        },
        {
            type = "chain",
            id = Chain.TheDarkPharaoh,
        },
        {
            type = "chain",
            id = Chain.TheseObelisksAreTryingToKillUs,
        },
        {
            type = "chain",
            id = Chain.TheFurrierSchnottz,
        },
        {
            type = "chain",
            id = Chain.Promises,
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
