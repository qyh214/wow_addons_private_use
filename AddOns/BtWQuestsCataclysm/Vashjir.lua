local BtWQuests = BtWQuests;
local Database = BtWQuests.Database;
local EXPANSION_ID = BtWQuests.Constant.Expansions.Cataclysm;
local CATEGORY_ID = BtWQuests.Constant.Category.Cataclysm.Vashjir;
local Chain = BtWQuests.Constant.Chain.Cataclysm.Vashjir;
local ALLIANCE_RESTRICTION, HORDE_RESTRICTION = BtWQuests.Constant.Restrictions.Alliance, BtWQuests.Constant.Restrictions.Horde;
local MAP_ID = 203
local ACHIEVEMENT_ID_ALLIANCE = 4869
local ACHIEVEMENT_ID_HORDE = 4982
local CONTINENT_ID = 13

Chain.DefenseOfTheBrinyCutter = 40201
Chain.DefenseOfTheImmortalCoil = 40202
Chain.SmugglersScar = 40203
Chain.ABuddingTreasureHunter = 40204
Chain.TheClutchAlliance = 40205
Chain.TheClutchHorde = 40206
Chain.SilverTideHollow = 40207
Chain.NespirahAlliance = 40208
Chain.NespirahHorde = 40209
Chain.VisionsOfThePastAlliance = 40210
Chain.VisionsOfThePastHorde = 40211
Chain.TheMercilessOneAlliance = 40212
Chain.TheMercilessOneHorde = 40213
Chain.LghorekAlliance = 40214
Chain.LghorekHorde = 40215
Chain.TheTidehunterAlliance = 40216
Chain.TheTidehunterHorde = 40217

Chain.Chain01 = 40221
Chain.Chain02 = 40222
Chain.Chain03 = 40223

Database:AddChain(Chain.DefenseOfTheBrinyCutter, {
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
        ids = {14482},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 25558,
    },
    items = {
        {
            type = "npc",
            id = 36799,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 14482,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 24432,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25281,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25405,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 25357,
            x = -1,
            connections = {
                2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 25546,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 25545,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 25564,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 27729,
            aside = true,
        },
        {
            type = "quest",
            id = 25547,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25558,
            x = 0,
        },
    },
})
Database:AddChain(Chain.DefenseOfTheImmortalCoil, {
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
        ids = {25924},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 25949,
    },
    items = {
        {
            type = "npc",
            id = 41621,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25924,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25929,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25936,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25941,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 25942,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 25943,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 25944,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25946,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25947,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25948,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25949,
            x = 0,
        },
    },
})

Database:AddChain(Chain.SmugglersScar, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 2),
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
            id = Chain.DefenseOfTheBrinyCutter,
        },
        {
            type = "chain",
            id = Chain.DefenseOfTheImmortalCoil,
        },
    },
    active = {
        type = "quest",
        ids = {25477, 25587},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 25638,
    },
    items = {
        {
            type = "npc",
            id = 41248,
            aside = true,
            x = -2,
            connections = {
                2, 
            },
        },
        {
            type = "npc",
            id = 39667,
            x = 1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25477,
            aside = true,
            x = -2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25587,
            x = 1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 25371,
            aside = true,
            x = -2,
        },
        {
            type = "quest",
            id = 25598,
            connections = {
                2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 25388,
            aside = true,
        },
        {
            type = "quest",
            id = 25389,
            aside = true,
            x = -2,
        },
        {
            type = "quest",
            id = 25602,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 25390,
            aside = true,
        },
        {
            type = "quest",
            id = 25459,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25358,
            aside = true,
        },
        {
            type = "quest",
            id = 25638,
            x = 0,
        },
    },
})
Database:AddChain(Chain.ABuddingTreasureHunter, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 3),
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
            id = Chain.DefenseOfTheBrinyCutter,
        },
        {
            type = "chain",
            id = Chain.DefenseOfTheImmortalCoil,
        },
        {
            type = "quest",
            id = 25602,
        },
    },
    active = {
        type = "quest",
        ids = {25651},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 25743,
    },
    items = {
        {
            type = "npc",
            id = 46338,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25651,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25657,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27699,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25670,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25732,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25743,
            x = 0,
        },
    },
})

Database:AddChain(Chain.TheClutchAlliance, {
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
        {
            type = "chain",
            id = Chain.DefenseOfTheBrinyCutter,
        },
        {
            type = "chain",
            id = Chain.SmugglersScar,
        },
    },
    active = {
        type = "quest",
        ids = {28238},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {25885, 25888, 27708},
        count = 3,
    },
    items = {
        {
            type = "npc",
            id = 40105,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25794,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25812,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25824,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25887,
            x = 0,
            connections = {
                1, 2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 25885,
            x = -3,
        },
        {
            type = "quest",
            id = 25884,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 25888,
        },
        {
            type = "quest",
            id = 25883,
            aside = true,
        },
        {
            type = "quest",
            id = 27708,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheClutchHorde, {
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
            id = Chain.DefenseOfTheImmortalCoil,
        },
        {
            type = "chain",
            id = Chain.SmugglersScar,
        },
    },
    active = {
        type = "quest",
        ids = {25794},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {26040, 26008, 27708},
        count = 3,
    },
    items = {
        {
            type = "npc",
            id = 40105,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25794,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26000,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26007,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25887,
            x = 0,
            connections = {
                1, 2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 26008,
            x = -3,
        },
        {
            type = "quest",
            id = 25884,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 26040,
        },
        {
            type = "quest",
            id = 25883,
            aside = true,
        },
        {
            type = "quest",
            id = 27708,
            x = 0,
        },
    },
})

Database:AddChain(Chain.SilverTideHollow, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 5),
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
            id = Chain.DefenseOfTheBrinyCutter,
        },
        {
            type = "chain",
            id = Chain.DefenseOfTheImmortalCoil,
        },
        {
            type = "chain",
            id = Chain.SmugglersScar,
        },
        {
            type = "quest",
            id = 27708,
        },
    },
    active = {
        type = "quest",
        ids = {25471},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 25456,
    },
    items = {
        {
            type = "npc",
            id = 41341,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25471,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25334,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25164,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25221,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25222,
            x = 0,
            connections = {
                1, 2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 25220,
            aside = true,
            x = -3,
        },
        {
            type = "quest",
            id = 25216,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 25215,
            aside = true,
        },
        {
            type = "quest",
            id = 25219,
            aside = true,
        },
        {
            type = "quest",
            id = 25218,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25360,
            aside = true,
        },
        {
            type = "quest",
            id = 25217,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25456,
            x = 0,
        },
    },
})

Database:AddChain(Chain.NespirahAlliance, {
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
        ids = {25359, 25439, 25441},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 25922,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 25359,
                    restrictions = {
                        type = "quest",
                        id = 25359,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 40221,
                },
            },
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 25439,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 25441,
            aside = true,
        },
        {
            type = "quest",
            id = 25440,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25442,
            aside = true,
        },
        {
            type = "quest",
            id = 25890,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25900,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 25907,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25908,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25909,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25916,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25917,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 25918,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 25919,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25920,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25921,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25922,
            x = 0,
        },
    },
})
Database:AddChain(Chain.VisionsOfThePastAlliance, {
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
            id = Chain.NespirahAlliance,
        },
    },
    active = {
        type = "quest",
        ids = {25535},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {25760, 25755, 25626},
        count = 3,
    },
    items = {
        {
            type = "npc",
            id = 39881,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "npc",
            id = 40642,
            aside = true,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25535,
            x = 0,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 25536,
            aside = true,
        },
        {
            type = "quest",
            id = 25537,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25539,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25538,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25540,
            x = 0,
            connections = {
                1, 2, 3, 4, 5, 
            },
        },
        {
            type = "quest",
            id = 25581,
            aside = true,
            x = 0,
        },
        {
            type = "quest",
            id = 25579,
            x = -3,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 25580,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 25582,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25583,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25760,
            x = 0,
            connections = {
                1, 
            },
            onClick = {
                type = "chain",
                id = Chain.Chain01,
            },
        },
        {
            type = "quest",
            id = 25747,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 25748,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 25749,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25751,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25752,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 25753,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25754,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25755,
            x = 0,
            connections = {
                1, 
            },
            onClick = {
                type = "chain",
                id = Chain.Chain02,
            },
        },
        {
            type = "quest",
            id = 25892,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25893,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 25894,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 25895,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25897,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25898,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25911,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25626,
            x = 0,
            onClick = {
                type = "chain",
                id = Chain.Chain03,
            },
        },
    },
})
Database:AddChain(Chain.TheMercilessOneAlliance, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 8),
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
            id = Chain.NespirahAlliance,
        },
        {
            type = "chain",
            id = Chain.VisionsOfThePastAlliance,
        },
    },
    active = {
        type = "quest",
        ids = {26005},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 25987,
    },
    items = {
        {
            type = "npc",
            id = 39881,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26005,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26219,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26103,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26106,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26014,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26015,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 26017,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 26018,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 26019,
            aside = true,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 26080,
            x = 0,
            connections = {
                2, 3, 4, 5, 
            },
        },
        {
            type = "quest",
            id = 26021,
            aside = true,
        },
        {
            type = "quest",
            id = 25950,
            x = -3,
        },
        {
            type = "quest",
            id = 25975,
        },
        {
            type = "quest",
            id = 25981,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25977,
        },
        {
            type = "quest",
            id = 25987,
            x = 0,
        },
    },
})
Database:AddChain(Chain.LghorekAlliance, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 9),
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
            id = Chain.NespirahAlliance,
        },
        {
            type = "chain",
            id = Chain.VisionsOfThePastAlliance,
        },
        {
            type = "chain",
            id = Chain.TheMercilessOneAlliance,
        },
    },
    active = {
        type = "quest",
        ids = {26072, 26096, 26070, 26056},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 26143,
    },
    items = {
        {
            type = "npc",
            id = 41600,
            x = -3,
            connections = {
                3, 
            },
        },
        {
            type = "npc",
            id = 41639,
            connections = {
                3, 
            },
        },
        {
            type = "npc",
            id = 41598,
            aside = true,
            x = 2,
            connections = {
                3, 4, 
            },
        },
        {
            type = "quest",
            id = 26072,
            x = -3,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 26096,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 26070,
            aside = true,
        },
        {
            type = "quest",
            id = 26056,
            aside = true,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 26111,
            x = 0,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 26065,
            aside = true,
            x = 3,
        },
        {
            type = "quest",
            id = 26130,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 26132,
            aside = true,
        },
        {
            type = "quest",
            id = 26140,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 26141,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 26142,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 26144,
            aside = true,
        },
        {
            type = "quest",
            id = 26154,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26143,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheTidehunterAlliance, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 10),
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
            id = Chain.NespirahAlliance,
        },
        {
            type = "chain",
            id = Chain.VisionsOfThePastAlliance,
        },
        {
            type = "chain",
            id = Chain.TheMercilessOneAlliance,
        },
        {
            type = "chain",
            id = Chain.LghorekAlliance,
        },
    },
    active = {
        type = "quest",
        ids = {26181, 26193},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 26193,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 26181,
                    restrictions = {
                        type = "quest",
                        id = 26181,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 41600,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26193,
            x = 0,
        },
    },
})

Database:AddChain(Chain.NespirahHorde, {
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
        ids = {25359, 25439, 25441},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 25996,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 25359,
                    restrictions = {
                        type = "quest",
                        id = 25359,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 40221,
                },
            },
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 25439,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 25441,
            aside = true,
        },
        {
            type = "quest",
            id = 25440,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25442,
            aside = true,
        },
        {
            type = "quest",
            id = 25890,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25900,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 25907,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25908,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25989,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25990,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25991,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 25992,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 25993,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25994,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25995,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25996,
            x = 0,
        },
    },
})
Database:AddChain(Chain.VisionsOfThePastHorde, {
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
            id = Chain.NespirahHorde,
        },
    },
    active = {
        type = "quest",
        ids = {25595, 25594, 25593, 25592},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {25957, 25966, 26135},
        count = 3,
    },
    items = {
        {
            type = "npc",
            id = 40919,
            x = -3,
            connections = {
                4, 
            },
        },
        {
            type = "npc",
            id = 40918,
            connections = {
                4, 
            },
        },
        {
            type = "npc",
            id = 40916,
            connections = {
                4, 
            },
        },
        {
            type = "npc",
            id = 40917,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 25595,
            x = -3,
            connections = {
                4, 5, 6, 7, 8, 
            },
        },
        {
            type = "quest",
            id = 25594,
            connections = {
                3, 4, 5, 6, 7, 
            },
        },
        {
            type = "quest",
            id = 25593,
            connections = {
                2, 3, 4, 5, 6, 
            },
        },
        {
            type = "quest",
            id = 25592,
            aside = true,
        },
        {
            type = "quest",
            id = 25954,
            aside = true,
            x = 0,
        },
        {
            type = "quest",
            id = 25953,
            x = -3,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 25955,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 25952,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25956,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25957,
            x = 0,
            connections = {
                1, 
            },
            onClick = {
                type = "chain",
                id = Chain.Chain01,
            },
        },
        {
            type = "quest",
            id = 25958,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 25959,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 25960,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25962,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25963,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 25964,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25965,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25966,
            x = 0,
            connections = {
                1, 
            },
            onClick = {
                type = "chain",
                id = Chain.Chain02,
            },
        },
        {
            type = "quest",
            id = 25967,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25968,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 25969,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 25970,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25971,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25972,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25973,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26135,
            x = 0,
            onClick = {
                type = "chain",
                id = Chain.Chain03,
            },
        },
    },
})
Database:AddChain(Chain.TheMercilessOneHorde, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 8),
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
            id = Chain.NespirahHorde,
        },
        {
            type = "chain",
            id = Chain.VisionsOfThePastHorde,
        },
    },
    active = {
        type = "quest",
        ids = {26006},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 25988,
    },
    items = {
        {
            type = "npc",
            id = 40919,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26006,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26221,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26122,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26126,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26086,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26087,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 26088,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 26089,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 26090,
            aside = true,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 26092,
            x = 0,
            connections = {
                2, 3, 4, 5, 
            },
        },
        {
            type = "quest",
            id = 26091,
            aside = true,
        },
        {
            type = "quest",
            id = 25974,
            aside = true,
            x = -3,
        },
        {
            type = "quest",
            id = 25982,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 25980,
            aside = true,
        },
        {
            type = "quest",
            id = 25976,
            aside = true,
        },
        {
            type = "quest",
            id = 25988,
            x = 0,
        },
    },
})
Database:AddChain(Chain.LghorekHorde, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 9),
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
            id = Chain.NespirahHorde,
        },
        {
            type = "chain",
            id = Chain.VisionsOfThePastHorde,
        },
        {
            type = "chain",
            id = Chain.TheMercilessOneHorde,
        },
    },
    active = {
        type = "quest",
        ids = {26072, 26096, 26071, 26057},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 26143,
    },
    items = {
        {
            type = "npc",
            id = 41600,
            x = -3,
            connections = {
                3, 
            },
        },
        {
            type = "npc",
            id = 41639,
            connections = {
                3, 
            },
        },
        {
            type = "npc",
            id = 41636,
            aside = true,
            x = 2,
            connections = {
                3, 4, 
            },
        },
        {
            type = "quest",
            id = 26072,
            x = -3,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 26096,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 26071,
            aside = true,
        },
        {
            type = "quest",
            id = 26057,
            aside = true,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 26111,
            x = 0,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 26065,
            aside = true,
            x = 3,
        },
        {
            type = "quest",
            id = 26130,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 26133,
            aside = true,
        },
        {
            type = "quest",
            id = 26140,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 26141,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 26142,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 26149,
            aside = true,
        },
        {
            type = "quest",
            id = 26154,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26143,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheTidehunterHorde, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 10),
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
            id = Chain.NespirahHorde,
        },
        {
            type = "chain",
            id = Chain.VisionsOfThePastHorde,
        },
        {
            type = "chain",
            id = Chain.TheMercilessOneHorde,
        },
        {
            type = "chain",
            id = Chain.LghorekHorde,
        },
    },
    active = {
        type = "quest",
        ids = {26194},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 26194,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 26182,
                    restrictions = {
                        type = "quest",
                        id = 26182,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 41600,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26194,
            x = 0,
        },
    },
})

Database:AddChain(Chain.Chain01, {
    name = { -- Visions of the Past: The Invasion of Vashj'ir
        type = "quest",
        id = 25760,
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
            visible = false,
            variations = {
                {
                    type = "quest",
                    id = 25760,
                    restrictions = ALLIANCE_RESTRICTION,
                    completed = {
                        type = "quest",
                        id = 25760,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "quest",
                    id = 25957,
                    completed = {
                        type = "quest",
                        id = 25957,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
            },
        }
    },
    active = {
        type = "quest",
        ids = {25619},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 25760,
    },
    items = {
        {
            type = "npc",
            id = 40978,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25619,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25620,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 25637,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25658,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25659,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain02, {
    name = { -- Visions of the Past: The Slaughter of Biel'aran Ridge
        type = "quest",
        id = 25755,
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
            visible = false,
            variations = {
                {
                    type = "quest",
                    id = 25755,
                    restrictions = ALLIANCE_RESTRICTION,
                    completed = {
                        type = "quest",
                        id = 25755,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "quest",
                    id = 25966,
                    completed = {
                        type = "quest",
                        id = 25966,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
            },
        }
    },
    active = {
        type = "quest",
        ids = {25858},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 25755,
    },
    items = {
        {
            type = "npc",
            id = 42076,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25858,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 25859,
            x = -2,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 25862,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25861,
            aside = true,
        },
        {
            type = "quest",
            id = 25863,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26191,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain03, {
    name = { -- Visions of the Past: Rise from the Deep
        type = "quest",
        id = 25626,
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
            visible = false,
            variations = {
                {
                    type = "quest",
                    id = 25626,
                    restrictions = ALLIANCE_RESTRICTION,
                    completed = {
                        type = "quest",
                        id = 25626,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "quest",
                    id = 26135,
                    completed = {
                        type = "quest",
                        id = 26135,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
            },
        }
    },
    active = {
        type = "quest",
        ids = {25896, 25629},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {25626, 26135},
    },
    items = {
        {
            type = "npc",
            id = 41456,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "npc",
            id = 42077,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25896,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25629,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25860,
            x = 0,
        },
    },
})

Database:AddCategory(CATEGORY_ID, {
    name = BtWQuests.GetMapName(MAP_ID),
    expansion = EXPANSION_ID,
	buttonImage = {
		texture = 1851129,
		texCoords = {0,1,0,1},
	},
    items = {
        {
            type = "chain",
            id = Chain.DefenseOfTheBrinyCutter,
        },
        {
            type = "chain",
            id = Chain.DefenseOfTheImmortalCoil,
        },

        {
            type = "chain",
            id = Chain.SmugglersScar,
        },
        {
            type = "chain",
            id = Chain.ABuddingTreasureHunter,
        },

        {
            type = "chain",
            id = Chain.TheClutchAlliance,
        },
        {
            type = "chain",
            id = Chain.TheClutchHorde,
        },

        {
            type = "chain",
            id = Chain.SilverTideHollow,
        },

        {
            type = "chain",
            id = Chain.NespirahAlliance,
        },
        {
            type = "chain",
            id = Chain.VisionsOfThePastAlliance,
        },
        {
            type = "chain",
            id = Chain.TheMercilessOneAlliance,
        },
        {
            type = "chain",
            id = Chain.LghorekAlliance,
        },
        {
            type = "chain",
            id = Chain.TheTidehunterAlliance,
        },
        
        {
            type = "chain",
            id = Chain.NespirahHorde,
        },
        {
            type = "chain",
            id = Chain.VisionsOfThePastHorde,
        },
        {
            type = "chain",
            id = Chain.TheMercilessOneHorde,
        },
        {
            type = "chain",
            id = Chain.LghorekHorde,
        },
        {
            type = "chain",
            id = Chain.TheTidehunterHorde,
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
