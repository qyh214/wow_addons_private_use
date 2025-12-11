local BtWQuests = BtWQuests;
local Database = BtWQuests.Database;
local EXPANSION_ID = BtWQuests.Constant.Expansions.MistsOfPandaria;
local CATEGORY_ID = BtWQuests.Constant.Category.MistsOfPandaria.DreadWastes;
local Chain = BtWQuests.Constant.Chain.MistsOfPandaria.DreadWastes;
local MAP_ID = 422
local ACHIEVEMENT_ID = 6540
local CONTINENT_ID = 424

Chain.TheFirstParagons = 50601
Chain.TheMightOfTheKlaxxi = 50602
Chain.TasteOfAmber = 50603
Chain.LikeADeckBoss = 50604

Chain.Chain01 = 50611
Chain.Chain02 = 50612

Database:AddChain(Chain.TheFirstParagons, {
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
        ids = {
            31656, 31000, 31886, 31001, 31002
        },
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 31066,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 31656,
                    restrictions = {
                        {
                            type = "quest",
                            id = 31656,
                            status = {
                                "active",
                                "completed",
                            },
                        },
                    },
                },
                {
                    type = "quest",
                    ids = {
                        31000, 31886, 
                    },
                    restrictions = {
                        {
                            type = "quest",
                            ids = {
                                31000, 31886, 
                            },
                            status = {
                                "active",
                                "completed",
                            },
                        },
                    },
                },
                {
                    type = "npc",
                    id = 62112,
                },
            },
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 31001,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 31002,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 31003,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 31004,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 31005,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 31676,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 31006,
            x = 0,
            connections = {
                1, 2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 31007,
            x = -3,
            connections = {
                
            },
        },
        {
            type = "quest",
            id = 31660,
            connections = {
                
            },
        },
        {
            type = "quest",
            id = 31009,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 31008,
            aside = true,
        },
        {
            type = "quest",
            id = 31010,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 31661,
            aside = true,
        },
        {
            type = "quest",
            id = 31066,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheMightOfTheKlaxxi, {
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
            id = Chain.TheFirstParagons,
        },
    },
    active = {
        type = "quest",
        ids = {31019, 31023, 31087, 31679},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {31026, 31398},
        count = 2,
    },
    items = {
        {
            type = "npc",
            id = 62538,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "npc",
            id = 64815,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = Chain.Chain01,
            x = -1,
        },
        {
            type = "chain",
            id = Chain.Chain02,
        },
    },
})
Database:AddChain(Chain.TasteOfAmber, {
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
            id = Chain.TheFirstParagons,
        },
    },
    active = {
        type = "quest",
        ids = {31067, 31068},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 31086,
    },
    items = {
        {
            type = "npc",
            id = 62666,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "object",
            id = 212389,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 31067,
            x = -1,
            connections = {
                2, 3, 5, 6, 7, 
            },
        },
        {
            type = "quest",
            id = 31068,
            connections = {
                1, 2, 4, 5, 6, 
            },
        },
        {
            type = "quest",
            ids = {
                31076, 31129, 
            },
            x = -3,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 31071,
            aside = true,
            x = 0,
        },
        {
            type = "quest",
            id = 31077,
            x = -3,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 31070,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 31069,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 31072,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 31078,
            x = -3,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 31073,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 31074,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 31075,
            x = 0,
            connections = {
                1, 2, 3, 4, 
            },
            comment = "Not entire sure what is required for this, Chen stuff for sure",
        },
        {
            type = "quest",
            id = 31079,
            x = -3,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 31080,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 31081,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 31082,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 31084,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 31085,
            aside = true,
            x = -1,
        },
        {
            type = "quest",
            id = 31086,
        },
    },
})
Database:AddChain(Chain.LikeADeckBoss, {
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
            id = Chain.TheFirstParagons,
        },
    },
    active = {
        type = "quest",
        id = 31265,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 31354,
    },
    items = {
        {
            type = "npc",
            id = 63349,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 31265,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 31181,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 31182,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 31183,
            x = 0,
            connections = {
                1, 2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 31185,
            aside = true,
            x = -3,
        },
        {
            type = "quest",
            id = 31184,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 31187,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 31188,
            aside = true,
        },
        {
            type = "quest",
            id = 31189,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 31190,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 31354,
            x = 0,
        },
    },
})

Database:AddChain(Chain.Chain01, {
    name = {
        type = "achievement",
        id = 7312,
        criteria = 5,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {30,35},
    prerequisites = {
        {
            type = "level",
            level = 30,
        },
        {
            type = "chain",
            id = Chain.TheFirstParagons,
        },
    },
    active = {
        type = "quest",
        ids = {31019, 31023},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 31026,
    },
    items = {
        {
            type = "chain",
            id = Chain.TheFirstParagons,
        },
        {
            type = "npc",
            id = 62538,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 31019,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 31023,
            aside = true,
        },
        {
            type = "quest",
            id = 31020,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 31021,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 31022,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 31026,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain02, {
    name = {
        type = "achievement",
        id = 7312,
        criteria = 4,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {30,35},
    prerequisites = {
        {
            type = "level",
            level = 30,
        },
        {
            type = "chain",
            id = Chain.TheFirstParagons,
        },
    },
    active = {
        type = "quest",
        ids = {31087, 31679},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 31398,
    },
    items = {
        {
            type = "npc",
            id = 64815,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            ids = {
                31087, 31679, 
            },
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            ids = {
                31088, 31680, 
            },
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            ids = {
                31090, 31681, 
            },
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            ids = {
                31089, 31682, 
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 31091,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 31092,
            aside = true,
            x = -2,
        },
        {
            type = "quest",
            id = 31359,
            aside = true,
        },
        {
            type = "quest",
            id = 31398,
        },
    },
})

Database:AddCategory(CATEGORY_ID, {
    name = BtWQuests.GetMapName(MAP_ID),
    expansion = EXPANSION_ID,
    items = {
        {
            type = "chain",
            id = Chain.TheFirstParagons,
        },
        {
            type = "chain",
            id = Chain.TheMightOfTheKlaxxi,
        },
        {
            type = "chain",
            id = Chain.TasteOfAmber,
        },
        {
            type = "chain",
            id = Chain.LikeADeckBoss,
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
