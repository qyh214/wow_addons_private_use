local BtWQuests = BtWQuests;
local Database = BtWQuests.Database;
local EXPANSION_ID = BtWQuests.Constant.Expansions.WarlordsOfDraenor;
local CATEGORY_ID = BtWQuests.Constant.Category.WarlordsOfDraenor.ShadowmoonValley;
local Chain = BtWQuests.Constant.Chain.WarlordsOfDraenor.ShadowmoonValley;
local ALLIANCE_RESTRICTIONS = BtWQuests.Constant.Restrictions.Alliance;
local MAP_ID = 539
local ACHIEVEMENT_ID = 8845
local CONTINENT_ID = 572

Chain.EstablishingAFoothold = 60201
Chain.ShadowsAwaken = 60202
Chain.DarkSideOfTheMoon = 60203
Chain.TheLightPrevails = 60204
Chain.GloomshadeGrove = 60205
Chain.ThePursuitOfJustice = 60206
Chain.PurifyingTheGenePool = 60207

Chain.Chain01 = 60211
Chain.Chain02 = 60212

Database:AddChain(Chain.EstablishingAFoothold, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 1),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {10,60},
    major = true,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
    },
    active = {
        type = "quest",
        ids = {34575},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 34692,
    },
    items = {
        {
            type = "quest",
            id = 34575,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 34582,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 34583,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 34616,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 34584,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34585,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34586,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 35166,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 35176,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 35174,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34587,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34646,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34692,
            x = 0,
            connections = {
                1, 2, 3, 4, 
            },
        },
        {
            type = "chain",
            id = Chain.ShadowsAwaken,
            aside = true,
            x = -3,
        },
        {
            type = "quest",
            id = 36592,
            aside = true,
        },
        {
            type = "quest",
            id = 36624,
            aside = true,
        },
        {
            type = "chain",
            id = Chain.ThePursuitOfJustice,
            aside = true,
        },
    },
})
Database:AddChain(Chain.ShadowsAwaken, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 2),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {10,60},
    major = true,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = Chain.EstablishingAFoothold,
        },
    },
    active = {
        type = "quest",
        ids = {33075},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 34019,
    },
    items = {
        {
            type = "npc",
            id = 80568,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 33075,
            x = 0,
            connections = {
                1, 2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 33905,
            x = -3,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 33765,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 33070,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 33813,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34019,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "chain",
            id = Chain.DarkSideOfTheMoon,
            aside = true,
            x = -1,
        },
        { -- Might be a breadcrumb to Fiona
            type = "quest",
            id = 35444,
            aside = true,
        },
    },
})
Database:AddChain(Chain.DarkSideOfTheMoon, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 3),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {10,60},
    major = true,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = Chain.EstablishingAFoothold,
        },
        {
            type = "chain",
            id = Chain.ShadowsAwaken,
        },
    },
    active = {
        type = "quest",
        ids = {33072},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 34054,
    },
    items = {
        {
            type = "npc",
            id = 74043,
            locations = {
                [539] = {
                    {
                        x = 0.494232,
                        y = 0.368108,
                    },
                },
            },
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "npc",
            id = 71641,
            aside = true,
            x = -2,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 33072,
            x = 2,
            connections = {
                3, 4, 
            },
        },
        {
            type = "quest",
            id = 34876,
            aside = true,
            x = -3,
        },
        {
            type = "quest",
            id = 33077,
            aside = true,
        },
        {
            type = "quest",
            id = 33076,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 33080,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 33059,
            x = 0,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 33081,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = Chain.Chain01,
            aside = true,
            embed = true,
            x = -2,
        },
        {
            type = "quest",
            id = 33586,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = Chain.Chain02,
            aside = true,
            embed = true,
        },
        {
            type = "quest",
            id = 33082,
            x = 0,
            y = 5,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 34043,
            x = 0,
            connections = {
                2, 3, 4, 5, 6, 
            },
        },
        {
            type = "quest",
            id = 35631,
            aside = true,
        },
        {
            type = "quest",
            id = 33083,
            aside = true,
            x = -3,
        },
        {
            type = "quest",
            id = 33793,
            aside = true,
        },
        {
            type = "quest",
            id = 33794,
            aside = true,
        },
        {
            type = "quest",
            id = 33795,
            aside = true,
        },
        {
            type = "quest",
            id = 35032,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34054,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheLightPrevails, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 4),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {10,60},
    major = true,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = Chain.EstablishingAFoothold,
        },
        {
            type = "chain",
            id = Chain.ShadowsAwaken,
        },
        {
            type = "chain",
            id = Chain.DarkSideOfTheMoon,
        },
        {
            type = "quest",
            id = 33083,
            x = -3,
        },
        {
            type = "quest",
            id = 33793,
        },
        {
            type = "quest",
            id = 33794,
        },
        {
            type = "quest",
            id = 33795,
        },
    },
    active = {
        type = "quest",
        ids = {33837},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 33256,
    },
    items = {
        {
            type = "npc",
            id = 77282,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 33837,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 33255,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 33256,
            x = 0,
        },
    },
})
Database:AddChain(Chain.GloomshadeGrove, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 5),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {10,60},
    major = true,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = Chain.EstablishingAFoothold,
        },
        {
            type = "chain",
            id = Chain.ShadowsAwaken,
        },
        {
            type = "quest",
            id = 34820,
        },
    },
    active = {
        type = "quest",
        ids = {33059},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 33271,
    },
    items = {
        {
            type = "npc",
            id = 80163,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34820,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "npc",
            id = 79966,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 33263,
            x = 0,
            connections = {
                2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 33461,
            aside = true,
        },
        {
            type = "quest",
            id = 33331,
            aside = true,
            x = -2,
        },
        {
            type = "quest",
            id = 33271,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 34806,
            aside = true,
        },
        {
            type = "quest",
            id = 35625,
            aside = true,
            x = 0,
        },
    },
})
Database:AddChain(Chain.ThePursuitOfJustice, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 6),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {10,60},
    major = true,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = Chain.EstablishingAFoothold,
        },
    },
    active = {
        type = "quest",
        ids = {34778},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 34792,
    },
    items = {
        {
            type = "npc",
            id = 79457,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34778,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34779,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34780,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34781,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34782,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 34783,
            x = -2,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 34785,
            x = 2,
            connections = {
                3, 4, 
            },
        },
        {
            type = "quest",
            id = 34790,
            x = -3,
        },
        {
            type = "quest",
            id = 34784,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 35070,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 34786,
        },
        {
            type = "quest",
            id = 34787,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35552,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34791,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34789,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34792,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34788,
            aside = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35905,
            aside = true,
            x = 0,
        },
    },
})
Database:AddChain(Chain.PurifyingTheGenePool, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 7),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {10,60},
    major = true,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
    },
    active = {
        type = "quest",
        ids = {33786, 33787, 33808},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 35015,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 33786,
                    restrictions = {
                        type = "quest",
                        id = 33786,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 76204,
                },
            },
            x = 0,
            connections = {
                2, 3, 
            },
        },
        {
            type = "npc",
            id = 80859,
            aside = true,
            x = 3,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 33787,
            x = -1,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 33808,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 34996,
            aside = true,
        },
        {
            type = "npc",
            id = 80707,
            aside = true,
            x = -3,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 33788,
            x = 0,
            connections = {
                2, 3, 4, 6, 
            },
        },
        {
            type = "quest",
            id = 34997,
            aside = true,
            x = -3,
        },
        {
            type = "quest",
            id = 34994,
            aside = true,
        },
        {
            type = "quest",
            id = 34995,
            aside = true,
        },
        {
            type = "quest",
            id = 35006,
            aside = true,
        },
        {
            type = "quest",
            id = 35014,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35015,
            x = 0,
        },
    },
})

Database:AddChain(Chain.Chain01, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {90,100},
    items = {
        {
            type = "npc",
            id = 77211,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34847,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain02, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {90,100},
    items = {
        {
            type = "npc",
            id = 80248,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34836,
            x = 0,
        },
    },
})

Database:AddCategory(CATEGORY_ID, {
    name = BtWQuests.GetMapName(MAP_ID),
    expansion = EXPANSION_ID,
    restrictions = ALLIANCE_RESTRICTIONS,
    items = {
        {
            type = "chain",
            id = Chain.EstablishingAFoothold,
        },
        {
            type = "chain",
            id = Chain.ShadowsAwaken,
        },
        {
            type = "chain",
            id = Chain.DarkSideOfTheMoon,
        },
        {
            type = "chain",
            id = Chain.TheLightPrevails,
        },
        {
            type = "chain",
            id = Chain.GloomshadeGrove,
        },
        {
            type = "chain",
            id = Chain.ThePursuitOfJustice,
        },
        {
            type = "chain",
            id = Chain.PurifyingTheGenePool,
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
-- Garrisons
Database:AddMapRecursive(582, {
    type = "category",
    id = CATEGORY_ID,
})

Database:AddContinentItems(CONTINENT_ID, {
    { type = "chain", id = Chain.Chain02 }
})
