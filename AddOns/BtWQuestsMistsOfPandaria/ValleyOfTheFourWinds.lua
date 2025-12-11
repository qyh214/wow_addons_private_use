local BtWQuests = BtWQuests;
local Database = BtWQuests.Database;
local EXPANSION_ID = BtWQuests.Constant.Expansions.MistsOfPandaria;
local CATEGORY_ID = BtWQuests.Constant.Category.MistsOfPandaria.ValleyOfTheFourWinds;
local Chain = BtWQuests.Constant.Chain.MistsOfPandaria.ValleyOfTheFourWinds;
local MAP_ID = 376
local ACHIEVEMENT_ID = 6301
local CONTINENT_ID = 424

Chain.ThunderfootFields = 50201
Chain.MudmugsPlace = 50202
Chain.ChensMasterpiece = 50203
Chain.TheStormstoutBrewery = 50204
Chain.TheHiddenMaster = 50205
Chain.NesingwarysSafari = 50206

Chain.Chain01 = 50211
Chain.Chain02 = 50212
Chain.Chain03 = 50213

Database:AddChain(Chain.ThunderfootFields, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 1),
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
        id = 29907,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 29918,
    },
    items = {
        {
            type = "npc",
            id = 56133,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 29907,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 29908,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 29877,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 29909,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 29940,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 29910,
            aside = true,
        },
        {
            type = "quest",
            id = 29911,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 29912,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 29913,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 29914,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 29915,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 29916,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 29917,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 29918,
            x = 0,
        },
    },
})
Database:AddChain(Chain.MudmugsPlace, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 2),
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
            id = Chain.ThunderfootFields,
        },
    },
    active = {
        type = "quest",
        id = 29919,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 29952,
    },
    items = {
        {
            type = "npc",
            id = 56133,
            locations = {
                [376] = {
                    {
                        x = 0.752769,
                        y = 0.354972,
                    },
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 29919,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 29944,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 29945,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 29948,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 29946,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 29947,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 29949,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 29950,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 29951,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 29952,
            x = 0,
        },
    },
})
Database:AddChain(Chain.ChensMasterpiece, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 3),
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
            id = Chain.ThunderfootFields,
        },
        {
            type = "chain",
            id = Chain.MudmugsPlace,
        },
    },
    active = {
        type = "quest",
        id = 30046,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 30073,
    },
    items = {
        {
            type = "npc",
            id = 56133,
            locations = {
                [376] = {
                    {
                        x = 0.688581,
                        y = 0.434054,
                    },
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30046,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "chain",
            id = Chain.Chain01,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "chain",
            id = Chain.Chain02,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = Chain.Chain03,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30073,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheStormstoutBrewery, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 4),
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
            id = Chain.ThunderfootFields,
        },
        {
            type = "chain",
            id = Chain.MudmugsPlace,
        },
        {
            type = "chain",
            id = Chain.ChensMasterpiece,
        },
    },
    active = {
        type = "quest",
        id = 30074,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 30078,
    },
    items = {
        {
            type = "npc",
            id = 56133,
            locations = {
                [376] = {
                    {
                        x = 0.558316,
                        y = 0.493387,
                    },
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30074,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 30075,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 30077,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 30076,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30078,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheHiddenMaster, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 5),
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
        ids = {29872, 29981, 29982},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 29990,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 29872,
                    restrictions = {
                        type = "quest",
                        id = 29872,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 56111,
                },
            },
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "npc",
            id = 56720,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 29981,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 29982,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 29983,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 29984,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 29985,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 29986,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 29992,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 29987,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 29988,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 29989,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 29990,
            x = 0,
        },
    },
})
Database:AddChain(Chain.NesingwarysSafari, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 6),
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
        ids = {30181, 30183},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 30186,
    },
    items = {
        {
            type = "npc",
            id = 58422,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "npc",
            id = 63822,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 30181,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 30183,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 30184,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 32038,
            aside = true,
        },
        {
            type = "quest",
            id = 30182,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30185,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30186,
            x = 0,
        },
    },
})

Database:AddChain(Chain.Chain01, {
    name = { -- Hop Hunting
        type = "quest",
        id = 30053,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {1,35},
    active = {
        type = "quest",
        ids = {30053, 30050, 30052, 30054},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 30055,
    },
    items = {
        {
            type = "npc",
            id = 56133,
            locations = {
                [376] = {
                    {
                        x = 0.558939,
                        y = 0.494335,
                    },
                },
            },
            x = -3,
            connections = {
                4, 
            },
        },
        {
            type = "npc",
            id = 62377,
            connections = {
                4, 
            },
        },
        {
            type = "npc",
            id = 57385,
            connections = {
                4, 
            },
        },
        {
            type = "npc",
            id = 57401,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 30053,
            x = -3,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 30050,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 30052,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 30054,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30055,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain02, {
    name = { -- Doesn't Hold Water
        type = "quest",
        id = 30049,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {1,35},
    active = {
        type = "quest",
        ids = {30049},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 30172,
    },
    items = {
        {
            type = "npc",
            id = 56133,
            locations = {
                [376] = {
                    {
                        x = 0.558939,
                        y = 0.494335,
                    },
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30049,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30051,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30172,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain03, {
    name = { -- Li Li and the Grain
        type = "quest",
        id = 30048,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {1,35},
    active = {
        type = "quest",
        ids = {30048},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 30047,
    },
    items = {
        {
            type = "npc",
            id = 56133,
            locations = {
                [376] = {
                    {
                        x = 0.558939,
                        y = 0.494335,
                    },
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30048,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 30029,
            x = -2,
            connections = {
                3, 4, 
            },
        },
        {
            type = "quest",
            id = 30030,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 30031,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 30032,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 30028,
            aside = true,
        },
        {
            type = "quest",
            id = 30047,
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
            id = Chain.ThunderfootFields,
        },
        {
            type = "chain",
            id = Chain.MudmugsPlace,
        },
        {
            type = "chain",
            id = Chain.ChensMasterpiece,
        },
        {
            type = "chain",
            id = Chain.TheStormstoutBrewery,
        },
        {
            type = "chain",
            id = Chain.TheHiddenMaster,
        },
        {
            type = "chain",
            id = Chain.NesingwarysSafari,
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
