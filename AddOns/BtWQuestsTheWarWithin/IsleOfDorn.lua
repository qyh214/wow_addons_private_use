local BtWQuests = BtWQuests
local Database = BtWQuests.Database
local EXPANSION_ID = BtWQuests.Constant.Expansions.TheWarWithin
local CATEGORY_ID = BtWQuests.Constant.Category.TheWarWithin.IsleOfDorn
local Chain = BtWQuests.Constant.Chain.TheWarWithin.IsleOfDorn
local ALLIANCE_RESTRICTIONS, HORDE_RESTRICTIONS = 724, 723
local MAP_ID = 2248
local CONTINENT_ID = 2274
local ACHIEVEMENT_ID_1 = 20118
local ACHIEVEMENT_ID_2 = 20595
local LEVEL_RANGE = {70, 80}
local LEVEL_PREREQUISITES = {
    {
        type = "level",
        level = 68,
    },
}

Chain.BreakingPoint = 110101
Chain.EarthenFissures = 110102
Chain.TheFirstBlow = 110103
Chain.SporesOfDread = 110111
Chain.BehindClosedDoors = 110112
Chain.SevenSoldiers = 110113
Chain.LostLordOfTheStorm = 110114
Chain.HopeAnAnomaly = 110115
Chain.TheHermit = 110116
Chain.ATitanicExpedition = 110117
Chain.RememberMeEarthen = 110118
Chain.BrotherhoodInTheSkolzgalWood = 110119
Chain.AllOreNothing = 110120
Chain.TempChain14 = 110124
Chain.TempChain21 = 110131
Chain.TempChain22 = 110132
Chain.TempChain25 = 110135
Chain.TempChain26 = 110136
Chain.TempChain27 = 110137
Chain.TempChain28 = 110138
Chain.TempChain29 = 110139
Chain.TempChain30 = 110140
Chain.TempChain31 = 110141
Chain.TempChain32 = 110142
Chain.OtherAlliance = 110197
Chain.OtherHorde = 110198
Chain.OtherBoth = 110199

Database:AddChain(Chain.BreakingPoint, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_1, 1),
    questline = 5539,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 68,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.Introduction,
        },
    },
    active = {
        type = "quest",
        ids = {
            78530, 78531, 78532, 80334, 83548, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 78536,
    },
    items = {
        {
            type = "npc",
            id = 211993,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 83548,
                    restrictions = {
                        type = "quest",
                        id = 83548,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 211994,
                },
            },
            connections = {
                3, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 80334,
                    restrictions = {
                        type = "quest",
                        id = 80334,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 223166,
                },
            },
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 78531,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 78530,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 78532,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78533,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78534,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78535,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78536,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EarthenFissures, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_1, 2),
    questline = 5525,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 68,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.Introduction,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.BreakingPoint,
        },
    },
    active = {
        type = "quest",
        id = 78460,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 78471,
    },
    items = {
        {
            type = "npc",
            id = 217852,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78460,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 78468,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 78457,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78459,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78461,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78464,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 79553,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 78463,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78462,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78470,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 79701,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 79721,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78471,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheFirstBlow, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_1, 3),
    questline = 5540,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 68,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.Introduction,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.BreakingPoint,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.EarthenFissures,
        },
    },
    active = {
        type = "quest",
        id = 78538,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 78546,
    },
    items = {
        {
            type = "npc",
            id = 217904,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78538,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 80022,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78539,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78540,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 78541,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 78542,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78543,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78544,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78545,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78546,
            x = 0,
        },
    },
})
Database:AddChain(Chain.SporesOfDread, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 1),
    questline = 5512,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {78570, 78571},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 78574,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 78570,
                    restrictions = {
                        type = "quest",
                        id = 78570,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 212700,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78571,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78572,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78573,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78574,
            x = 0,
        },
    },
})
Database:AddChain(Chain.BehindClosedDoors, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 2),
    questline = 5605,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            79526, 79542, 80207, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 79530,
    },
    items = {
        {
            type = "npc",
            id = 219393,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 80207,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79521,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79522,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79523,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79525,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "npc",
            id = 225426,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79542,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79543,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79544,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79545,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79176,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79546,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "object",
            id = 429303,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79526,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 79527,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 79528,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79529,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79530,
            x = 0,
        },
    },
})
Database:AddChain(Chain.SevenSoldiers, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 3),
    questline = 5524,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 78996,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 78999,
    },
    items = {
        {
            type = "npc",
            id = 214444,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78996,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 78997,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 78998,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78999,
            x = 0,
        },
    },
})
Database:AddChain(Chain.LostLordOfTheStorm, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 4),
    questline = 5509,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            78289, 78290, 78291, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 78294,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 78289,
                    restrictions = {
                        type = "quest",
                        id = 78289,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 211740,
                },
            },
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 78290,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 78291,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78292,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78293,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78294,
            x = 0,
        },
    },
})
Database:AddChain(Chain.HopeAnAnomaly, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 5),
    questline = 5601,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 78469,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 79703,
    },
    items = {
        {
            type = "npc",
            id = 217961,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78469,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 79691,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 79692,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79703,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheHermit, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 6),
    questline = 5596,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 78754,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 78759,
    },
    items = {
        {
            type = "object",
            id = 423987,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78754,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78757,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78758,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 78755,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 78756,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78759,
            x = 0,
        },
    },
})
Database:AddChain(Chain.ATitanicExpedition, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 7),
    questline = 5652,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 79724,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 79728,
    },
    items = {
        {
            type = "npc",
            id = 217763,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79724,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 79725,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 79726,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79727,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79728,
            x = 0,
        },
    },
})
Database:AddChain(Chain.RememberMeEarthen, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 8),
    questline = 5606,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {81661, 78743},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 82895,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 81661,
                    restrictions = {
                        type = "quest",
                        id = 81661,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 213184,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78743,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78744,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 78745,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 78746,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 78747,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 78748,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78749,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79335,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79336,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79337,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79338,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79339,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 79340,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 79341,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79342,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82895,
            x = 0,
        },
    },
})
Database:AddChain(Chain.BrotherhoodInTheSkolzgalWood, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 9),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 68,
        },
        {
            type = "achievement",
            id = 20598,
            anyone = true,
        },
    },
    active = {
        type = "quest",
        id = 80456,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = { 80218, 83181 },
        count = 2,
    },
    items = {
        {
            type = "npc",
            id = 219437,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 80456,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 80209,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 80210,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 80211,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 80212,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 80213,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 80214,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 80215,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 80216,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 80217,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 80218,
            x = -1,
        },
        {
            type = "quest",
            id = 83181,
        },
    },
})
Database:AddChain(Chain.AllOreNothing, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 10),
    questline = 5591,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 82792,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 82801,
    },
    items = {
        {
            type = "npc",
            id = 218535,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82792,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82796,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82797,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 82799,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 82798,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82800,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82801,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain14, {
    name = { -- Cloudrook Down
        type = "quest",
        id = 82681,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {82680, 82681},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 82768,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 82680,
                    restrictions = {
                        type = "quest",
                        id = 82680,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 224392,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82681,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82682,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82768,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain21, {
    name = { -- Gems Are Forever
        type = "quest",
        id = 82467,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 82441,
        status = { "active", "completed" },
    },
    completed = {
        type = "quest",
        id = 82467,
    },
    items = {
        {
            type = "npc",
            id = 223637,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82441,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82465,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82466,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82467,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain22, {
    name = { -- Concerning Fungarians
        type = "quest",
        id = 79686,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    completed = {
        type = "quest",
        id = 79686,
    },
    items = {
        {
            type = "object",
            id = 428135,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79686,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain25, {
    name = BtWQuests.GetAreaName(14788), -- The Opalcreg
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = { 83082, 83081, },
        status = { "active", "completed" },
    },
    completed = {
        type = "quest",
        id = 83087,
    },
    items = {
        {
            type = "npc",
            id = 225454,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "npc",
            id = 225451,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 83082,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 83081,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78465,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 79716,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 78467,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79213,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83083,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83084,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83087,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain26, {
    name = { -- Wanted: The Boroughbreaker
        type = "quest",
        id = 83335,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    completed = {
        type = "quest",
        id = 83335,
    },
    items = {
        {
            type = "object",
            id = 454463,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83335,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain27, {
    name = { -- The Earthwound
        type = "quest",
        id = 83336,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    completed = {
        type = "quest",
        id = 83336,
    },
    items = {
        {
            type = "npc",
            id = 226750,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83336,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain28, {
    name = { -- Stormscarred
        type = "quest",
        id = 83337,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    completed = {
        type = "quest",
        id = 83337,
    },
    items = {
        {
            type = "npc",
            id = 226792,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83337,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain29, {
    name = { -- Violet Warden
        type = "npc",
        id = 226791,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    completed = {
        type = "quest",
        ids = { 83339, 83338 },
        count = 2,
    },
    items = {
        {
            type = "npc",
            id = 226791,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 83339,
            x = -1,
        },
        {
            type = "quest",
            id = 83338,
        },
    },
})
Database:AddChain(Chain.TempChain30, {
    name = BtWQuests.GetAreaName(14784), -- Rambleshire
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = { 83337, 83339, 83338 },
        status = { "active", "completed" },
    },
    completed = {
        type = "quest",
        ids = { 83337, 83339, 83338 },
        count = 3,
    },
    items = {
        {
            type = "chain",
            id = Chain.TempChain28,
            x = -2,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.TempChain29,
            x = 1,
            embed = true,
        },
    },
})
Database:AddChain(Chain.TempChain31, {
    name = BtWQuests.GetAreaName(15178), -- Crossroads Plaza
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = { 83335, 83336 },
        status = { "active", "completed" },
    },
    completed = {
        type = "quest",
        ids = { 83335, 83336 },
        count = 2,
    },
    items = {
        {
            type = "chain",
            id = Chain.TempChain26,
            x = -1,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.TempChain27,
            x = 1,
            embed = true,
        },
    },
})
Database:AddChain(Chain.TempChain32, {
    name = BtWQuests_GetAchievementName(40860), -- A Star of Dorn
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = { 82775, 82781, 82782, 82784 },
    },
    completed = {
        type = "quest",
        ids = { 82775, 82781, 82782, 82784 },
        count = 4,
    },
    items = {
        {
            type = "npc",
            id = 214296,
            x = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79150,
            x = 1,
            aside = true,
            connections = {
                2, 
            },
        },
        {
            type = "currency",
            id = 2900,
            amount = 8,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 79282,
            aside = true,
        },
        {
            type = "npc",
            id = 215748,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "currency",
            id = 2900,
            amount = 10,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 82775,
            x = -1,
        },
        {
            type = "npc",
            id = 217248,
            connections = {
                2, 
            },
        },
        {
            type = "currency",
            id = 2900,
            amount = 14,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 82781,
        },
        {
            type = "npc",
            id = 215745,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "currency",
            id = 2900,
            amount = 21,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 82782,
            x = -1,
        },
        {
            type = "npc",
            id = 215744,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82784,
            x = 1,
        },
    },
})

Database:AddChain(Chain.OtherAlliance, {
    name = "Other Alliance",
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    items = {
    },
})
Database:AddChain(Chain.OtherHorde, {
    name = "Other Horde",
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    items = {
    },
})
Database:AddChain(Chain.OtherBoth, {
    name = "Other Both",
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    items = {
        {
            type = "quest",
            id = 78717,
        },
        {
            type = "quest",
            id = 78718,
        },
        {
            type = "quest",
            id = 78719,
        },
        {
            type = "quest",
            id = 78721,
        },
        {
            type = "quest",
            id = 78722,
        },
        {
            type = "quest",
            id = 79105,
        },
        {
            type = "quest",
            id = 79106,
        },
        { -- After the Storm
            type = "quest",
            id = 79107,
        },
        { -- Conduit of the Southern Storm
            type = "quest",
            id = 79124,
        },
        { -- Rook Rally
            type = "quest",
            id = 79129,
        },
        { -- Goldbricking
            type = "quest",
            id = 79140,
        },
        { -- Metal and Stone
            type = "quest",
            id = 79145,
        },
        { -- Ground Pounders
            type = "quest",
            id = 79146,
        },
        { -- Thespians at the Proscenium
            type = "quest",
            id = 79150,
        },
        { -- The Edicts
            type = "quest",
            id = 79156,
        },
        { -- Titanic Failsafe
            type = "quest",
            id = 79157,
        },
        { -- The Grand Debut
            type = "quest",
            id = 79282,
        },
        { -- Embassies and Envoys
            type = "quest",
            id = 79328,
        },
        { -- Urban Odyssey
            type = "quest",
            id = 79344,
        },
        { -- Charging Up That Hill
            type = "quest",
            id = 79475,
        },
        { -- Heeding the Call
            type = "quest",
            id = 79476,
        },
        { -- Paying Respects
            type = "quest",
            id = 79480,
        },
        { -- It's Elementary
            type = "quest",
            id = 79667,
        },
        {
            type = "quest",
            id = 80295,
        },
        {
            type = "quest",
            id = 80321,
        },
        { -- Along for the Ride
            type = "quest",
            id = 80394,
        },
        { -- Elemental Excavation
            type = "quest",
            id = 80395,
        },
        {
            type = "quest",
            id = 81465,
        },
        { -- Ship It!
            type = "quest",
            id = 81510,
        },
        {
            type = "quest",
            id = 81512,
        },
        { -- Bountiful Delves
            type = "quest",
            id = 81514,
        },
        {
            type = "quest",
            id = 81615,
        },
        {
            type = "quest",
            id = 81621,
        },
        { -- Activation Protocol
            type = "quest",
            id = 81630,
        },
        { -- Honey Thieving Nerubians
            type = "quest",
            id = 81639,
        },
        { -- Special Assignment: Titanic Resurgence
            type = "quest",
            id = 81650,
        },
        { -- Water the Sheep
            type = "quest",
            id = 81675,
        },
        { -- Mead for the Catalog
            type = "quest",
            id = 81710,
        },
        { -- Sparks of War: Isle of Dorn
            type = "quest",
            id = 81793,
        },
        { -- Skyrider Racing - Storm's Watch Survey
            type = "quest",
            id = 81802,
        },
        { -- Skyrider Racing - The Wold Ways
            type = "quest",
            id = 81804,
        },
        { -- Skyrider Racing - Orecreg's Doglegs
            type = "quest",
            id = 81806,
        },
        { -- Coreway Maintenance Request
            type = "quest",
            id = 81854,
        },
        { -- Dhar Oztan
            type = "quest",
            id = 81914,
        },
        { -- Special Assignment: Cinderbee Surge
            type = "quest",
            id = 82146,
        },
        { -- Embassies and Envoys
            type = "quest",
            id = 82153,
        },
        { -- Weak Lionfish
            type = "quest",
            id = 82212,
        },
        { -- Excavation Extravaganza
            type = "quest",
            id = 82225,
        },
        {
            type = "quest",
            id = 82234,
        },
        { -- Rising the Falls
            type = "quest",
            id = 82237,
        },
        { -- Robot Rumble
            type = "quest",
            id = 82291,
        },
        { -- Rock Collector
            type = "quest",
            id = 82292,
        },
        { -- Weathered Quests
            type = "quest",
            id = 82333,
        },
        { -- A Small Bundle of Goods
            type = "quest",
            id = 82342,
        },
        { -- Weathered Crests
            type = "quest",
            id = 82344,
        },
        { -- Special Assignment: Cinderbee Surge
            type = "quest",
            id = 82355,
        },
        { -- Book It to the Library
            type = "quest",
            id = 82448,
        },
        { -- Preserving Plush Pals
            type = "quest",
            id = 82451,
        },
        {
            type = "quest",
            id = 82454,
        },
        {
            type = "quest",
            id = 82455,
        },
        { -- Chew On This
            type = "quest",
            id = 82456,
        },
        {
            type = "quest",
            id = 82470,
        },
        { -- Bountiful Delves - Template
            type = "quest",
            id = 82705,
        },
        { -- Delves: Khaz Algar Research
            type = "quest",
            id = 82706,
        },
        { -- The Theater Troupe
            type = "quest",
            id = 83240,
        },
        { -- There's Always Another Secret
            type = "quest",
            id = 83271,
        },
        { -- What's Hidden Beneath Dornogal
            type = "quest",
            id = 83286,
        },
        { -- Preparing for the Unknown
            type = "quest",
            id = 83315,
        },
        {
            type = "quest",
            id = 83621,
        },
    },
})

Database:AddCategory(CATEGORY_ID, {
    name = BtWQuests.GetMapName(MAP_ID),
    expansion = EXPANSION_ID,
    buttonImage = 5912553,
    items = {
        {
            type = "chain",
            id = Chain.BreakingPoint,
        },
        {
            type = "chain",
            id = Chain.EarthenFissures,
        },
        {
            type = "chain",
            id = Chain.TheFirstBlow,
        },
        {
            type = "chain",
            id = Chain.SporesOfDread,
        },
        {
            type = "chain",
            id = Chain.BehindClosedDoors,
        },
        {
            type = "chain",
            id = Chain.SevenSoldiers,
        },
        {
            type = "chain",
            id = Chain.LostLordOfTheStorm,
        },
        {
            type = "chain",
            id = Chain.HopeAnAnomaly,
        },
        {
            type = "chain",
            id = Chain.TheHermit,
        },
        {
            type = "chain",
            id = Chain.ATitanicExpedition,
        },
        {
            type = "chain",
            id = Chain.RememberMeEarthen,
        },
        {
            type = "chain",
            id = Chain.BrotherhoodInTheSkolzgalWood,
        },
        {
            type = "chain",
            id = Chain.AllOreNothing,
        },
        {
            type = "chain",
            id = Chain.TempChain14,
        },
        {
            type = "chain",
            id = Chain.TempChain21,
        },
        {
            type = "chain",
            id = Chain.TempChain25,
        },
        {
            type = "chain",
            id = Chain.TempChain30,
        },
        {
            type = "chain",
            id = Chain.TempChain31,
        },
        {
            type = "chain",
            id = Chain.TempChain32,
        },
--[==[@debug@
        {
            type = "chain",
            id = Chain.TempChain22,
        },
        {
            type = "chain",
            id = Chain.OtherAlliance,
        },
        {
            type = "chain",
            id = Chain.OtherHorde,
        },
        {
            type = "chain",
            id = Chain.OtherBoth,
        },
--@end-debug@]==]
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

BtWQuestsDatabase:AddQuestItemsForChain(Chain.BreakingPoint)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.EarthenFissures)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.TheFirstBlow)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.SporesOfDread)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.BehindClosedDoors)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.SevenSoldiers)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.LostLordOfTheStorm)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.HopeAnAnomaly)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.TheHermit)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.ATitanicExpedition)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.RememberMeEarthen)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.BrotherhoodInTheSkolzgalWood)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.AllOreNothing)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.TempChain14)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.TempChain21)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.TempChain25)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.TempChain30)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.TempChain31)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.TempChain32)

--[==[@debug@
Database:AddContinentItems(CONTINENT_ID, {
    {
        type = "chain",
        id = Chain.SporesOfDread,
    },
    {
        type = "chain",
        id = Chain.BehindClosedDoors,
    },
    {
        type = "chain",
        id = Chain.SevenSoldiers,
    },
    {
        type = "chain",
        id = Chain.LostLordOfTheStorm,
    },
    {
        type = "chain",
        id = Chain.HopeAnAnomaly,
    },
    {
        type = "chain",
        id = Chain.TheHermit,
    },
    {
        type = "chain",
        id = Chain.ATitanicExpedition,
    },
    {
        type = "chain",
        id = Chain.RememberMeEarthen,
    },
    {
        type = "chain",
        id = Chain.BrotherhoodInTheSkolzgalWood,
    },
    {
        type = "chain",
        id = Chain.AllOreNothing,
    },
    {
        type = "chain",
        id = Chain.TempChain14,
    },
    {
        type = "chain",
        id = Chain.OtherAlliance,
    },
    {
        type = "chain",
        id = Chain.OtherHorde,
    },
    {
        type = "chain",
        id = Chain.OtherBoth,
    },
})
--@end-debug@]==]
