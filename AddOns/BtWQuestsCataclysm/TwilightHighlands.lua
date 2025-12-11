local BtWQuests = BtWQuests;
local Database = BtWQuests.Database;
local EXPANSION_ID = BtWQuests.Constant.Expansions.Cataclysm;
local CATEGORY_ID = BtWQuests.Constant.Category.Cataclysm.TwilightHighlands;
local Chain = BtWQuests.Constant.Chain.Cataclysm.TwilightHighlands;
local ALLIANCE_RESTRICTION, HORDE_RESTRICTION = BtWQuests.Constant.Restrictions.Alliance, BtWQuests.Constant.Restrictions.Horde;
local MAP_ID = 241
local ACHIEVEMENT_ID_ALLIANCE = 4873
local ACHIEVEMENT_ID_HORDE = 5501
local CONTINENT_ID = 13

Chain.GoodNewsForOnce = 40501
Chain.Firebeard = 40502
Chain.TheDunwalds = 40503
Chain.TheEyeOfTwilightAlliance = 40504
Chain.WildWildWildhammerWedding = 40505
Chain.TheAttackBeginsAlliance = 40506
Chain.SendThemPackingAlliance = 40507

Chain.GoblinWorkEthic = 40511
Chain.ReturningToTheHighlands = 40512
Chain.Krazzworks = 40513
Chain.TheDragonmaw = 40514
Chain.TheEyeOfTwilightHorde = 40515
Chain.TheAttackBeginsHorde = 40516
Chain.SendThemPackingHorde = 40517

Chain.Chain01 = 40521
Chain.Chain02 = 40522
Chain.Chain03 = 40523

Database:AddChain(Chain.GoodNewsForOnce, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 1),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {30,35},
    major = true,
    restrictions = ALLIANCE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 30,
        },
    },
    active = {
        type = "quest",
        ids = {28238},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {27177, 27178, 27468, 27538, 27545},
        count = 5,
    },
    items = {
        {
            type = "npc",
            id = 1750,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28238,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28832,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28596,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28597,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28598,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28599,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 27177,
            x = -2,
        },
        {
            type = "quest",
            id = 27338,
            connections = {
                2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 27178,
        },
        {
            type = "quest",
            id = 27433,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 27341,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 27366,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 27468,
            x = -2,
        },
        {
            type = "quest",
            id = 27514,
            x = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27515,
            x = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27516,
            x = 1,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 27537,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 27538,
        },
        {
            type = "quest",
            id = 27545,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Firebeard, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 2),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {30,35},
    major = true,
    restrictions = ALLIANCE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 30,
        },
        {
            type = "quest",
            id = 27545,
        },
    },
    active = {
        type = "quest",
        ids = {27621},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {27805, 27817},
        count = 2,
    },
    items = {
        {
            type = "npc",
            id = 45172,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27621,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 27803,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 27804,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 27805,
        },
        {
            type = "quest",
            id = 27806,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 27807,
            x = -2,
            connections = {
                3, 4, 
            },
        },
        {
            type = "quest",
            id = 27808,
            connections = {
                7, 
            },
        },
        {
            type = "quest",
            id = 27809,
            connections = {
                3, 4, 7, 
            },
        },
        {
            type = "quest",
            id = 27810,
            x = -3,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 27811,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 27813,
            connections = {
                5, 
            },
        },
        {
            type = "quest",
            id = 27814,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 27812,
            x = -2,
            connections = {
                5, 
            },
        },
        {
            type = "quest",
            id = 27999,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 28233,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28234,
            x = 2,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27815,
            x = 2,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27816,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27817,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheDunwalds, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 3),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {30,35},
    major = true,
    restrictions = ALLIANCE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 30,
        },
        {
            type = "quest",
            id = 27545,
        },
        {
            type = "quest",
            id = 27817,
        },
    },
    active = {
        type = "quest",
        ids = {27640},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {27641, 27642, 27649, 27651},
        count = 4,
    },
    items = {
        {
            type = "npc",
            id = 46804,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27640,
            x = 0,
            connections = {
                1, 2, 3, 4, 5, 
            },
        },
        {
            type = "quest",
            id = 27641,
            x = -2.5,
        },
        {
            type = "quest",
            id = 27642,
            x = 2.5,
        },
        {
            type = "quest",
            id = 27643,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 27644,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 27645,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 27646,
            x = -2,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 27647,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 27648,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 27649,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27650,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27651,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheEyeOfTwilightAlliance, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 4),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {30,35},
    major = true,
    restrictions = ALLIANCE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 30,
        },
    },
    active = {
        type = "quest",
        ids = {28369, 27754, 27752, 27753},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 28244,
    },
    items = {
        {
            type = "npc",
            id = 46591,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "npc",
            id = 48010,
            connections = {
                3, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 28369,
                    restrictions = {
                        type = "quest",
                        id = 28369,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 48013,
                },
            },
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 27754,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 27752,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 27753,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28241,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28242,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28243,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28244,
            x = 0,
        },
    },
})
Database:AddChain(Chain.WildWildWildhammerWedding, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 5),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {30,35},
    major = true,
    restrictions = ALLIANCE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 30,
        },
    },
    active = {
        type = "quest",
        ids = {28369, 27754, 27752, 27753},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {28413, 28655},
        count = 2,
    },
    items = {
        {
            type = "npc",
            id = 46591,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "npc",
            id = 48010,
            connections = {
                3, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 28369,
                    restrictions = {
                        type = "quest",
                        id = 28369,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 48013,
                },
            },
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 27754,
            x = -2,
            connections = {
                3, 4, 5, 6, 
            },
        },
        {
            type = "quest",
            id = 27752,
            connections = {
                2, 3, 4, 5, 
            },
        },
        {
            type = "quest",
            id = 27753,
            connections = {
                1, 2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 28211,
            x = -3,
            connections = {
                4, 5, 
            },
        },
        {
            type = "quest",
            id = 28212,
            connections = {
                3, 4, 
            },
        },
        {
            type = "quest",
            id = 28215,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 28216,
            aside = true,
        },
        {
            type = "quest",
            id = 28280,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 28281,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28282,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28294,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28346,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28377,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 28379,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 28378,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28407,
            x = 0,
            connections = {
                1, 2, 3, 4, 5, 
            },
        },
        {
            type = "quest",
            id = 28413,
            x = 0,
        },
        {
            type = "quest",
            id = 28408,
            x = -3,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 28409,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 28410,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 28411,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28655,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheAttackBeginsAlliance, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 6),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {30,35},
    major = true,
    restrictions = ALLIANCE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 30,
        },
    },
    active = {
        type = "quest",
        ids = {27299},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 28247,
    },
    items = {
        {
            type = "chain",
            id = Chain.Chain01,
            embed = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27485,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "chain",
            id = Chain.Chain02,
            embed = true,
            x = 0,
            connections = {
                [5] = {
                    1, 
                }, [6] = {
                    1, 
                }, [7] = {
                    1, 
                }, 
            },
        },
        {
            type = "quest",
            id = 28101,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 28103,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 28104,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 28107,
            aside = true,
            x = -1,
        },
        {
            type = "quest",
            id = 28108,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28109,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "chain",
            id = Chain.Chain03,
            embed = true,
            x = 0,
        },
    },
})
Database:AddChain(Chain.SendThemPackingAlliance, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 7),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {30,35},
    major = true,
    restrictions = ALLIANCE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 30,
        },
        {
            type = "chain",
            id = Chain.TheAttackBeginsAlliance,
        },
    },
    active = {
        type = "quest",
        ids = {28248},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {27787, 27662},
        count = 2,
    },
    items = {
        {
            type = "npc",
            id = 47902,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28248,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 27492,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 27496,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 27490,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27494,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27498,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27500,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27502,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27636,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 27652,
            x = -2,
            connections = {
                3, 4, 
            },
        },
        {
            type = "quest",
            id = 27654,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 27657,
            connections = {
                3, 4, 6, 
            },
        },
        {
            type = "quest",
            id = 27695,
            x = -3,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 27688,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 27659,
            connections = {
                7, 
            },
        },
        {
            type = "quest",
            id = 27662,
        },
        {
            type = "quest",
            id = 27700,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 27660,
            x = 2,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27661,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 27702,
            x = -2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 27719,
            x = 2,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 27711,
                    restrictions = {
                        type = "quest",
                        id = 27711,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 46243,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27720,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 27742,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 27743,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 27744,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27745,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 27782,
                    restrictions = {
                        type = "quest",
                        id = 27782,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 45796,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27784,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27787,
            x = 0,
        },
    },
})

Database:AddChain(Chain.GoblinWorkEthic, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 1),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {30,35},
    major = true,
    restrictions = HORDE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 30,
        },
    },
    active = {
        type = "quest",
        ids = {26293},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {26372, 26374, 26337},
        count = 3,
    },
    items = {
        {
            type = "npc",
            id = 3144,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26293,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26294,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 28909,
                    restrictions = {
                        type = "quest",
                        id = 28909,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 42637,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26311,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26324,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 26374,
            x = -2,
        },
        {
            type = "quest",
            id = 26358,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 26335,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 26361,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 26337,
            x = 2,
        },
        {
            type = "quest",
            id = 26372,
            x = 0,
        },
    },
})
Database:AddChain(Chain.ReturningToTheHighlands, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 2),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {30,35},
    major = true,
    restrictions = HORDE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 30,
        },
        {
            type = "chain",
            id = Chain.GoblinWorkEthic,
        },
    },
    active = {
        type = "quest",
        ids = {28849},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 26840,
    },
    items = {
        {
            type = "npc",
            id = 42640,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28849,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26388,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 26538,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 26539,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 26540,
            x = -1,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 26549,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26608,
            x = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26619,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26621,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26622,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26786,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 26784,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 26788,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26798,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26830,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26840,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Krazzworks, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 3),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {30,35},
    major = true,
    restrictions = HORDE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 30,
        },
        {
            type = "chain",
            id = Chain.GoblinWorkEthic,
        },
        {
            type = "chain",
            id = Chain.ReturningToTheHighlands,
        },
    },
    active = {
        type = "quest",
        ids = {27607},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 28595,
    },
    items = {
        {
            type = "npc",
            id = 44169,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27607,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 27610,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 27611,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27622,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28583,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 28584,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 28588,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 28586,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28589,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28590,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28591,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 28592,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 28593,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 28594,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28595,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheDragonmaw, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 4),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {30,35},
    major = true,
    restrictions = HORDE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 30,
        },
        {
            type = "chain",
            id = Chain.GoblinWorkEthic,
        },
        {
            type = "chain",
            id = Chain.ReturningToTheHighlands,
        },
    },
    active = {
        type = "quest",
        ids = {27583},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {27747, 27750, 27945, 28133},
        count = 4,
    },
    items = {
        {
            type = "npc",
            id = 44169,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27583,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 27584,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 27586,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27606,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27690,
            x = 0,
            connections = {
                1, 2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 27747,
            x = -3,
        },
        {
            type = "quest",
            id = 27751,
            connections = {
                3, 4, 
            },
        },
        {
            type = "quest",
            id = 27929,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 27750,
        },
        {
            type = "quest",
            id = 27945,
            x = -1,
        },
        {
            type = "quest",
            id = 28041,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28043,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28123,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28133,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheEyeOfTwilightHorde, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 5),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {30,35},
    major = true,
    restrictions = HORDE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 30,
        },
        {
            type = "chain",
            id = Chain.GoblinWorkEthic,
        },
        {
            type = "chain",
            id = Chain.ReturningToTheHighlands,
        },
        {
            type = "quest",
            id = 27751,
        },
        {
            type = "quest",
            id = 27929,
        },
    },
    active = {
        type = "quest",
        ids = {27947},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 27955,
    },
    items = {
        {
            type = "npc",
            id = 46323,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27947,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27951,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27954,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27955,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheAttackBeginsHorde, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 6),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {30,35},
    major = true,
    restrictions = HORDE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 30,
        },
    },
    active = {
        type = "quest",
        ids = {27299},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 28247,
    },
    items = {
        {
            type = "chain",
            id = Chain.Chain01,
            embed = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27486,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "chain",
            id = Chain.Chain02,
            embed = true,
            x = 0,
            connections = {
                [5] = {
                    1, 
                }, [6] = {
                    1, 
                }, [7] = {
                    1, 
                }, 
            },
        },
        {
            type = "quest",
            id = 27576,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 28091,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 28090,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28097,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 28092,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 28094,
            aside = true,
        },
        {
            type = "quest",
            id = 28093,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "chain",
            id = Chain.Chain03,
            embed = true,
            x = 0,
        },
    },
})
Database:AddChain(Chain.SendThemPackingHorde, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 7),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {30,35},
    major = true,
    restrictions = HORDE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 30,
        },
        {
            type = "chain",
            id = Chain.TheAttackBeginsHorde,
        },
    },
    active = {
        type = "quest",
        ids = {28248},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {27788, 27662},
        count = 2,
    },
    items = {
        {
            type = "npc",
            id = 47902,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28249,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 27493,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 27497,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 27491,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27495,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27499,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27501,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27503,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27638,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 27653,
            x = -2,
            connections = {
                3, 4, 
            },
        },
        {
            type = "quest",
            id = 27655,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 27658,
            connections = {
                3, 4, 6, 
            },
        },
        {
            type = "quest",
            id = 27696,
            x = -3,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 27689,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 27659,
            connections = {
                7, 
            },
        },
        {
            type = "quest",
            id = 27662,
        },
        {
            type = "quest",
            id = 27701,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 27660,
            x = 2,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27661,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 27703,
            x = -2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 27798,
            x = 2,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 27712,
                    restrictions = {
                        type = "quest",
                        id = 27712,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 46243,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28885,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 27742,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 27743,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 27744,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27745,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 27783,
                    restrictions = {
                        type = "quest",
                        id = 27783,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 45675,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27786,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27788,
            x = 0,
        },
    },
})

Database:AddChain(Chain.Chain01, {
    name = "Dummy 2",
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {1,35},
    items = {
        {
            type = "npc",
            id = 45332,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27299,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 27300,
            x = -2,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 27301,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 27302,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 27303,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27376,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27377,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27378,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27379,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27380,
            x = 0,
            connections = {
                1, 
            },
        },
    },
})
Database:AddChain(Chain.Chain02, {
    name = "Dummy 3",
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {1,35},
    items = {
        {
            type = "quest",
            id = 27504,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 27505,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 27506,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27564,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 27507,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 27508,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 27509,
            connections = {
                1, 
            },
        },
    },
})
Database:AddChain(Chain.Chain03, {
    name = "Dummy 4",
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {1,35},
    items = {
        {
            type = "quest",
            id = 28712,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28758,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28171,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 28173,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 28191,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 28175,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28176,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28247,
            x = 0,
        },
    },
})

Database:AddCategory(CATEGORY_ID, {
    name = BtWQuests.GetMapName(MAP_ID),
    expansion = EXPANSION_ID,
	buttonImage = {
		texture = 1851127,
		texCoords = {0,1,0,1},
	},
    items = {
        {
            type = "chain",
            id = Chain.GoodNewsForOnce,
        },
        {
            type = "chain",
            id = Chain.Firebeard,
        },
        {
            type = "chain",
            id = Chain.TheDunwalds,
        },
        {
            type = "chain",
            id = Chain.TheEyeOfTwilightAlliance,
        },
        {
            type = "chain",
            id = Chain.WildWildWildhammerWedding,
        },
        {
            type = "chain",
            id = Chain.TheAttackBeginsAlliance,
        },
        {
            type = "chain",
            id = Chain.SendThemPackingAlliance,
        },

        {
            type = "chain",
            id = Chain.GoblinWorkEthic,
        },
        {
            type = "chain",
            id = Chain.ReturningToTheHighlands,
        },
        {
            type = "chain",
            id = Chain.Krazzworks,
        },
        {
            type = "chain",
            id = Chain.TheDragonmaw,
        },
        {
            type = "chain",
            id = Chain.TheEyeOfTwilightHorde,
        },
        {
            type = "chain",
            id = Chain.TheAttackBeginsHorde,
        },
        {
            type = "chain",
            id = Chain.SendThemPackingHorde,
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

