local BtWQuests = BtWQuests;
local Database = BtWQuests.Database;
local EXPANSION_ID = BtWQuests.Constant.Expansions.MistsOfPandaria;
local CATEGORY_ID = BtWQuests.Constant.Category.MistsOfPandaria.KunLaiSummit;
local Chain = BtWQuests.Constant.Chain.MistsOfPandaria.KunLaiSummit;
local ALLIANCE_RESTRICTION, HORDE_RESTRICTION = BtWQuests.Constant.Restrictions.Alliance, BtWQuests.Constant.Restrictions.Horde;
local MAP_ID = 379
local ACHIEVEMENT_ID_ALLIANCE = 6537
local ACHIEVEMENT_ID_HORDE = 6538
local CONTINENT_ID = 424

Chain.WestwindRest = 50401
Chain.TheYaungolInvasionAlliance = 50402

Chain.EastwindRest = 50403
Chain.TheYaungolInvasionHorde = 50404

Chain.InkgillMere = 50405
Chain.TheYakWash = 50406
Chain.TheBurlapTrail = 50407
Chain.KotaPeak = 50408
Chain.TheThunderKing = 50409

Chain.TempleOfTheWhiteTigerAlliance = 50410
Chain.TempleOfTheWhiteTigerHorde = 50411

Chain.ZouchinVillage = 50412
Chain.TheShadoPan = 50413

Chain.Chain01 = 50421

Database:AddChain(Chain.WestwindRest, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 1),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {20,35},
    major = true,
    alternatives = {
        Chain.EastwindRest,
    },
    restrictions = ALLIANCE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 20,
        },
    },
    active = {
        type = "quest",
        ids = {30457, 30460, 30459},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 30514,
    },
    items = {
        {
            type = "npc",
            id = 59073,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "npc",
            id = 59077,
            connections = {
                3, 
            },
        },
        {
            type = "npc",
            id = 59076,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 30457,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 30460,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 30459,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            ids = {
                30506, 30507, 30508, 
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30512,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30514,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheYaungolInvasionAlliance, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 2),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {20,35},
    major = true,
    alternatives = {
        Chain.TheYaungolInvasionHorde,
    },
    restrictions = ALLIANCE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 20,
        },
        {
            type = "chain",
            id = Chain.WestwindRest,
        },
    },
    active = {
        type = "quest",
        ids = {30569, 30619},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 30660,
    },
    items = {
        {
            type = "npc",
            id = 63754,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "npc",
            id = 63542,
            x = 2,
            connections = {
                5, 
            },
        },
        {
            type = "quest",
            id = 30569,
            x = -1,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 30571,
            x = -2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 30581,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 31252,
            x = -1,
            connections = {
                2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 30619,
            x = 2,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 30651,
            aside = true,
            x = -2,
        },
        {
            type = "quest",
            id = 30652,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 30650,
            aside = true,
        },
        {
            type = "quest",
            ids = {
                30660, 30662, 
            },
            x = 0,
        },
    },
})

Database:AddChain(Chain.EastwindRest, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 1),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {20,35},
    major = true,
    alternatives = {
        Chain.WestwindRest,
    },
    restrictions = HORDE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 20,
        },
    },
    active = {
        type = "quest",
        ids = {30457, 30460, 30459},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 30515,
    },
    items = {
        {
            type = "npc",
            id = 59073,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "npc",
            id = 59077,
            connections = {
                3, 
            },
        },
        {
            type = "npc",
            id = 59076,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 30457,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 30460,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 30459,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            ids = {
                30511, 30510, 30509, 
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30513,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30515,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheYaungolInvasionHorde, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 2),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {20,35},
    major = true,
    alternatives = {
        Chain.TheYaungolInvasionAlliance,
    },
    restrictions = HORDE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 20,
        },
        {
            type = "chain",
            id = Chain.EastwindRest,
        },
    },
    active = {
        type = "quest",
        ids = {30570, 30620},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 30661,
    },
    items = {
        {
            type = "npc",
            id = 63751,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "npc",
            id = 63535,
            locations = {
                [379] = {
                    {
                        x = 0.623447,
                        y = 0.796044,
                    },
                },
            },
            x = 2,
            connections = {
                5, 
            },
        },
        {
            type = "quest",
            id = 30570,
            x = -1,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 30571,
            x = -2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 30581,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 31253,
            x = -1,
            connections = {
                2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 30620,
            x = 2,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 30656,
            aside = true,
            x = -2,
        },
        {
            type = "quest",
            id = 30657,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 30655,
            aside = true,
        },
        {
            type = "quest",
            ids = {
                30663, 30661, 
            },
            x = 0,
        },
    },
})

Database:AddChain(Chain.InkgillMere, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 3),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {20,35},
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 20,
        },
    },
    active = {
        type = "quest",
        ids = {30496, 30967, 30467, 30469},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 30855,
    },
    items = {
        {
            type = "npc",
            id = 60973,
            x = -2,
            connections = {
                3, 4, 
            },
        },
        {
            type = "npc",
            id = 59273,
            connections = {
                6, 
            },
        },
        {
            type = "npc",
            id = 59263,
            aside = true,
            connections = {
                3, 4, 
            },
        },
        {
            type = "quest",
            id = 30496,
            x = -3,
            connections = {
                6, 
            },
        },
        {
            type = "quest",
            id = 30967,
            connections = {
                5, 
            },
        },
        {
            type = "quest",
            id = 30467,
            aside = true,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 30469,
            aside = true,
        },
        {
            type = "quest",
            id = 30468,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 30834,
            aside = true,
        },
        {
            type = "quest",
            id = 30480,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30828,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30855,
            x = 0,
            connections = {
                
            },
        },
    },
})
Database:AddChain(Chain.TheYakWash, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 4),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {20,35},
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 20,
        },
    },
    active = {
        type = "quest",
        ids = {30488, 30489},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 30492,
    },
    items = {
        {
            type = "npc",
            id = 59353,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 30488,
            x = -1,
            connections = {
                2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 30489,
            aside = true,
        },
        {
            type = "quest",
            id = 30491,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 30587,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 30582,
            aside = true,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 30492,
            x = -1,
        },
        {
            type = "quest",
            id = 30804,
            aside = true,
        },
    },
})
Database:AddChain(Chain.TheBurlapTrail, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 5),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {20,35},
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 20,
        },
    },
    active = {
        type = "quest",
        id = 30592,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 30612,
    },
    items = {
        {
            type = "npc",
            id = 59701,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30592,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 30602,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 30603,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 30599,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 30600,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 30604,
        },
        {
            type = "quest",
            id = 30605,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 30606,
            x = -2,
        },
        {
            type = "quest",
            id = 30607,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 30608,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 30610,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 30611,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30612,
            x = 0,
        },
    },
})
Database:AddChain(Chain.KotaPeak, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 6),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {20,35},
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 20,
        },
    },
    active = {
        type = "quest",
        ids = {
            30745, 30826, 
            30744, 30825, 
            30742, 30823, 
            30743, 30824, 
        },
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 30747,
    },
    items = {
        {
            type = "npc",
            id = 60503,
            x = -2,
            connections = {
                2, 3, 
            },
        },
        {
            type = "npc",
            id = 60596,
            x = 2,
            connections = {
                3, 4, 
            },
        },
        {
            type = "quest",
            ids = {
                30745, 30826, 
            },
            aside = true,
            x = -3,
        },
        {
            type = "quest",
            ids = {
                30744, 30825, 
            },
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            ids = {
                30742, 30823, 
            },
            aside = true,
        },
        {
            type = "quest",
            ids = {
                30743, 30824, 
            },
            aside = true,
        },
        {
            type = "quest",
            id = 30746,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30747,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheThunderKing, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 7),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {20,35},
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 20,
        },
    },
    active = {
        type = "quest",
        id = 30999,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 30800,
    },
    items = {
        {
            type = "npc",
            id = 61847,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30999,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 30601,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 30618,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 30621,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30487,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30683,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30684,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 31306,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30829,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 30795,
            aside = true,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 30797,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 30796,
            aside = true,
            x = -1,
            connections = {
                
            },
        },
        {
            type = "quest",
            id = 30799,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30798,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30800,
            x = 0,
            connections = {
                1, 
            },
        },
    },
})

Database:AddChain(Chain.TempleOfTheWhiteTigerAlliance, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 8),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {20,35},
    major = true,
    alternatives = {
        Chain.TempleOfTheWhiteTigerHorde,
    },
    restrictions = ALLIANCE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 20,
        },
    },
    active = {
        type = "quest",
        id = 31394,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 31394,
    },
    items = {
        {
            type = "npc",
            id = 64540,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 31394,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 31512,
            aside = true,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempleOfTheWhiteTigerHorde, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 8),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {20,35},
    major = true,
    alternatives = {
        Chain.TempleOfTheWhiteTigerAlliance,
    },
    restrictions = HORDE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 20,
        },
    },
    active = {
        type = "quest",
        id = 31395,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 31395,
    },
    items = {
        {
            type = "npc",
            id = 64542,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 31395,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 31511,
            aside = true,
            x = 0,
        },
    },
})

Database:AddChain(Chain.ZouchinVillage, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 9),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {20,35},
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 20,
        },
    },
    active = {
        type = "quest",
        id = 30801,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 30946,
    },
    items = {
        {
            type = "npc",
            id = 61371,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30801,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30802,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30935,
            x = 0,
            connections = {
                1, 2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 30944,
            x = -3,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 30943,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 30945,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 30942,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 31011,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30946,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 31228,
            aside = true,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheShadoPan, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 10),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {20,35},
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 20,
        },
        {
            type = "quest",
            id = 30457,
        },
    },
    active = {
        type = "quest",
        ids = {30665, 30670, 30682},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 30752,
    },
    items = {
        {
            type = "npc",
            id = 60161,
            x = 0,
            connections = {
                2, 3, 
            },
        },
        {
            type = "chain",
            id = Chain.Chain01,
            aside = true,
            embed = true,
            x = 3,
        },
        {
            type = "quest",
            id = 30665,
            x = -1,
            y = 3,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 30670,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30690,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30699,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 30715,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 30723,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30724,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 30750,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 30751,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30994,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30991,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30992,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 30993,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 30768,
            aside = true,
        },
        {
            type = "quest",
            id = 30752,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 31030,
            aside = true,
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
            id = 60178,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30682,
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
            id = Chain.WestwindRest,
        },
        {
            type = "chain",
            id = Chain.TheYaungolInvasionAlliance,
        },
        
        {
            type = "chain",
            id = Chain.EastwindRest,
        },
        {
            type = "chain",
            id = Chain.TheYaungolInvasionHorde,
        },

        {
            type = "chain",
            id = Chain.InkgillMere,
        },
        {
            type = "chain",
            id = Chain.TheYakWash,
        },
        {
            type = "chain",
            id = Chain.TheBurlapTrail,
        },
        {
            type = "chain",
            id = Chain.KotaPeak,
        },
        {
            type = "chain",
            id = Chain.TheThunderKing,
        },

        {
            type = "chain",
            id = Chain.TempleOfTheWhiteTigerAlliance,
        },
        {
            type = "chain",
            id = Chain.TempleOfTheWhiteTigerHorde,
        },

        {
            type = "chain",
            id = Chain.ZouchinVillage,
        },
        {
            type = "chain",
            id = Chain.TheShadoPan,
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
