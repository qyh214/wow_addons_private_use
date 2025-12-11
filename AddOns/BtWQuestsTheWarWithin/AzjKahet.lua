local BtWQuests = BtWQuests
local Database = BtWQuests.Database
local L = BtWQuests.L
local EXPANSION_ID = BtWQuests.Constant.Expansions.TheWarWithin
local CATEGORY_ID = BtWQuests.Constant.Category.TheWarWithin.AzjKahet
local Chain = BtWQuests.Constant.Chain.TheWarWithin.AzjKahet
local THREADS_OF_FATE_RESTRICTION = BtWQuests.Constant.Restrictions.TheWarWithinToF
local ALLIANCE_RESTRICTIONS, HORDE_RESTRICTIONS = 724, 723
local MAP_ID = 2255
local CONTINENT_ID = 2274
local ACHIEVEMENT_ID_1 = 19559
local ACHIEVEMENT_ID_2 = 40636
local LEVEL_RANGE = {78, 80}
local LEVEL_PREREQUISITES = {
    {
        type = "level",
        variations = {
            { level = 68, restrictions = THREADS_OF_FATE_RESTRICTION, },
            { level = 74, },
        }
    },
}

Chain.FriendsInTheDark = 110401
Chain.UnravelingTheTrapped = 110402
Chain.PlansWithinPlans = 110403
Chain.RakUshSwarmery = 110411
Chain.PillarnestVosh = 110412
Chain.GutterWork = 110413
Chain.MelodyOfMadness = 110414
Chain.PawnsAndPuppetry = 110415
Chain.TheWormlands = 110416
Chain.HagglingWithMmarl = 110417
Chain.TheSecondFront = 110418
Chain.MrSunflowersTherapy = 110420
Chain.TheWildCamp = 110421
Chain.PillarnestOfHorrors = 110422
Chain.SubterfugeInSilk = 110424
Chain.SilkenWard = 110425
Chain.GrieveWeave = 110426
Chain.AllGoodThings = 110428
Chain.TempChain22 = 110432
Chain.TempChain23 = 110433
Chain.TempChain24 = 110434
Chain.TempChain25 = 110435
Chain.TempChain26 = 110436
Chain.TempChain27 = 110437
Chain.TempChain28 = 110438
Chain.TempChain29 = 110439
Chain.OtherAlliance = 110497
Chain.OtherHorde = 110498
Chain.OtherBoth = 110499

Database:AddChain(Chain.FriendsInTheDark, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_1, 1),
    questline = 5520,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            variations = {
                { level = 68, restrictions = THREADS_OF_FATE_RESTRICTION, },
                { level = 74, },
            }
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.Hallowfall.HopeInSolidarity,
        },
    },
    active = {
        type = "quest",
        ids = {
            78350, 78384, 83552, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = { 78392, 78393, },
        count = 2,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 83552,
                    restrictions = {
                        type = "quest",
                        id = 83552,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 211699,
                },
            },
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "npc",
            id = 211752,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 78350,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 78384,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78348,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 78352,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 78353,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79139,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78354,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 78392,
            x = -1,
        },
        {
            type = "quest",
            id = 78393,
        },
    },
})
Database:AddChain(Chain.UnravelingTheTrapped, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_1, 2),
    questline = 5521,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            variations = {
                { level = 68, restrictions = THREADS_OF_FATE_RESTRICTION, },
                { level = 74, },
            }
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.Hallowfall.HopeInSolidarity,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.FriendsInTheDark,
        },
    },
    active = {
        type = "quest",
        id = 78233,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 78256,
    },
    items = {
        {
            type = "npc",
            id = 207471,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78233,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 80399,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78236,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 78234,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 78383,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78237,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79625,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79175,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 78249,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 78250,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 78251,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 78254,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78255,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78256,
            x = 0,
        },
    },
})
Database:AddChain(Chain.PlansWithinPlans, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_1, 3),
    questline = 5506,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            variations = {
                { level = 68, restrictions = THREADS_OF_FATE_RESTRICTION, },
                { level = 74, },
            }
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.Hallowfall.HopeInSolidarity,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.FriendsInTheDark,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.UnravelingTheTrapped,
        },
    },
    active = {
        type = "quest",
        id = 78226,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 84022,
    },
    items = {
        {
            type = "npc",
            id = 207471,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78226,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78228,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 78231,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 78232,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78244,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78248,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 84022,
            x = 0,
        },
    },
})
Database:AddChain(Chain.RakUshSwarmery, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 1),
    questline = 5648,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            79119, 83325, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 79123,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 83325,
                    restrictions = {
                        type = "quest",
                        id = 83325,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 214359,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79119,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79114,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79115,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79117,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79118,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79120,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79121,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79122,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79123,
            x = 0,
        },
    },
})
Database:AddChain(Chain.PillarnestVosh, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 2),
    questline = 5647,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            79174, 79355, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 79357,
    },
    items = {
        {
            type = "npc",
            id = 215349,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 79174,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 79355,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 79356,
            aside = true,
            x = -1,
        },
        {
            type = "quest",
            id = 79357,
        },
    },
})
Database:AddChain(Chain.GutterWork, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 3),
    questline = 5543,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            variations = {
                { level = 68, restrictions = THREADS_OF_FATE_RESTRICTION, },
                { level = 74, },
            }
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.Hallowfall.HopeInSolidarity,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.FriendsInTheDark,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.UnravelingTheTrapped,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.PlansWithinPlans,
            upto = 78228,
            completed = {
                type = "quest",
                id = 81623,
            },
        },
    },
    active = {
        type = "quest",
        id = 79710,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 79715,
    },
    items = {
        {
            type = "npc",
            id = 217565,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "kill",
            id = 217724,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 79710,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 79711,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 79713,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 79714,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79715,
            x = 0,
        },
    },
})
Database:AddChain(Chain.MelodyOfMadness, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 4),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            variations = {
                { level = 68, restrictions = THREADS_OF_FATE_RESTRICTION, },
                { level = 74, },
            }
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.Hallowfall.HopeInSolidarity,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.FriendsInTheDark,
        },
    },
    active = {
        type = "quest",
        ids = {
            80563, 80564, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 80572
    },
    items = {
        {
            type = "npc",
            id = 220595,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 80564,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 80563,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82143,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 80565,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 80566,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 80567,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 80568,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 80571,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 80570,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 80569,
            x = -1,
        },
        {
            type = "quest",
            id = 80572,
        },
    },
})
Database:AddChain(Chain.PawnsAndPuppetry, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 5),
    questline = 5613,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            variations = {
                { level = 68, restrictions = THREADS_OF_FATE_RESTRICTION, },
                { level = 74, },
            }
        },
        {
            type = "reputation",
            id = 2605,
            standing = 5,
        },
    },
    active = {
        type = "quest",
        id = 80203,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 80205,
    },
    items = {
        {
            type = "npc",
            id = 219357,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 80203,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 80204,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 80206,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 80205,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheWormlands, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 6),
    questline = 5565,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            78897, 78898, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {
            78897,78898,78902
        },
        count = 3,
    },
    items = {
        {
            type = "npc",
            id = 211652,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "area",
            id = 14754,
            locations = {
                [2255] = {
                    {
                        x = 0.406743,
                        y = 0.399483,
                    },
                },
            },
            x = 2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 78897,
            x = -2,
        },
        {
            type = "quest",
            id = 78898,
        },
        {
            type = "quest",
            id = 78901,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78902,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79349,
            aside = true,
            x = 0,
        },
    },
})
Database:AddChain(Chain.HagglingWithMmarl, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 7),
    questline = 5541,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            variations = {
                { level = 68, restrictions = THREADS_OF_FATE_RESTRICTION, },
                { level = 74, },
            }
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.Hallowfall.HopeInSolidarity,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.FriendsInTheDark,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.UnravelingTheTrapped,
        },
    },
    active = {
        type = "quest",
        ids = {
            79651, 80558, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 79541,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 79651,
                    restrictions = {
                        type = "quest",
                        id = 79651,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 217029,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 80558,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 79538,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 79539,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79540,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79541,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheSecondFront, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 8),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 79574,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {
            79579,79580
        },
        count = 2,
    },
    items = {
        {
            type = "npc",
            id = 217133,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79574,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 79579,
            x = -1,
        },
        {
            type = "quest",
            id = 79580,
        },
    },
})
Database:AddChain(Chain.MrSunflowersTherapy, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 9),
    questline = 5612,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            variations = {
                { level = 68, restrictions = THREADS_OF_FATE_RESTRICTION, },
                { level = 74, },
            }
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.Hallowfall.HopeInSolidarity,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.FriendsInTheDark,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.UnravelingTheTrapped,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.PlansWithinPlans,
            upto = 78228,
        },
    },
    active = {
        type = "quest",
        id = 82340,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 83057,
    },
    items = {
        {
            type = "npc",
            id = 223723,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82340,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83057,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheWildCamp, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 10),
    questline = 5644,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            variations = {
                { level = 68, restrictions = THREADS_OF_FATE_RESTRICTION, },
                { level = 74, },
            }
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.Hallowfall.HopeInSolidarity,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.FriendsInTheDark,
            upto = 79139,
        },
    },
    active = {
        type = "quest",
        id = 83628,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 83639,
    },
    items = {
        {
            type = "npc",
            id = 227222,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83628,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83629,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83632,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83639,
            x = 0,
        },
    },
})
Database:AddChain(Chain.PillarnestOfHorrors, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 11),
    questline = 5545,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            variations = {
                { level = 68, restrictions = THREADS_OF_FATE_RESTRICTION, },
                { level = 74, },
            }
        },
        {
            type = "reputation",
            id = 2605,
            standing = 5,
        },
    },
    active = {
        type = "quest",
        ids = {
            79954, 79955, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 79957,
    },
    items = {
        {
            type = "npc",
            id = 217255,
            aside = true,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "npc",
            id = 217640,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 79954,
            aside = true,
            x = -1,
        },
        {
            type = "quest",
            id = 79955,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79956,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79957,
            x = 0,
        },
    },
})
Database:AddChain(Chain.SubterfugeInSilk, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 12),
    questline = 5600,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            variations = {
                { level = 68, restrictions = THREADS_OF_FATE_RESTRICTION, },
                { level = 74, },
            }
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.Hallowfall.HopeInSolidarity,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.FriendsInTheDark,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.UnravelingTheTrapped,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.PlansWithinPlans,
            upto = 78226,
        },
    },
    active = {
        type = "quest",
        ids = {
            81667, 83616, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 81688,
    },
    items = {
        {
            type = "npc",
            id = 222136,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 81667,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 83616,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 81668,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 81683,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 81687,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 81685,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 81688,
            x = 0,
        },
    },
})
Database:AddChain(Chain.SilkenWard, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 13),
    questline = 5646,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            81890, 81928, 83324, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 81963,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 83324,
                    restrictions = {
                        type = "quest",
                        id = 83324,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "quest",
                    id = 81890,
                    restrictions = {
                        type = "quest",
                        id = 81890,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 221948,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 81928,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 81959,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 81962,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 81963,
            x = 0,
        },
    },
})
Database:AddChain(Chain.GrieveWeave, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 14),
    questline = 5649,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            variations = {
                { level = 68, restrictions = THREADS_OF_FATE_RESTRICTION, },
                { level = 74, },
            }
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.Hallowfall.HopeInSolidarity,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.FriendsInTheDark,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.UnravelingTheTrapped,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.PlansWithinPlans,
            upto = 78228,
        },
    },
    active = {
        type = "quest",
        id = 79630,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 80502,
    },
    items = {
        {
            type = "npc",
            id = 217356,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79630,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79631,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 80502,
            x = 0,
        },
    },
})
Database:AddChain(Chain.AllGoodThings, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 15),
    questline = 5562,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 80,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.Hallowfall.HopeInSolidarity,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.FriendsInTheDark,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.UnravelingTheTrapped,
        },
    },
    active = {
        type = "quest",
        id = 82248,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 82284,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 82248,
                    restrictions = {
                        type = "quest",
                        id = 82248,
                        status = { "active", "completed" }
                    }
                },
                {
                    type = "npc",
                    id = 211409,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 81929,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 81945,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 81950,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 81965,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 81964,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 81969,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82268,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82284,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain22, {
    name = { -- Delver's Call: Tak-Rethan Abyss
        type = "quest",
        id = 83771,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            variations = {
                { level = 68, restrictions = THREADS_OF_FATE_RESTRICTION, },
                { level = 74, },
            }
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.Hallowfall.HopeInSolidarity,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.FriendsInTheDark,
            upto = 78354,
        },
    },
    completed = {
        type = "quest",
        id = 82141,
    },
    items = {
        {
            type = "object",
            id = 455720,
            x = 0,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 83771,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain23, {
    name = { -- Delves: The Underkeep
        type = "quest",
        id = 83761,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 82141,
    },
    items = {
        {
            name = "unknown requirements",
        },
        {
            type = "npc",
            id = 227544,
            x = 0,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 83761,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain24, {
    name = { -- A Light of the Dark
        type = "quest",
        id = 80378,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 82141,
    },
    items = {
        -- Got while doing Melody of Madness in Azj'Kahet but the quest is for The Ringing Deeps
        -- Unknown requirements, item doesnt seem to drop when doing this on an alt.
        -- Maybe it actually drops from lots of places and was just luck it happens here
        {
            type = "kill",
            id = 223116,
            x = 0,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 80378,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain25, {
    name = { -- Saving Private Spindle
        type = "quest",
        id = 83276,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            variations = {
                { level = 68, restrictions = THREADS_OF_FATE_RESTRICTION, },
                { level = 74, },
            }
        },
        {
            type = "currency",
            id = 2904,
            amount = 3,
        },
    },
    active = {
        type = "quest",
        id = 83276,
    },
    completed = {
        type = "quest",
        id = 83277,
    },
    items = {
        {
            type = "npc",
            id = 207471,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83276,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83277,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain26, {
    name = { -- Dogged Pursuit
        type = "quest",
        id = 79730,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            variations = {
                { level = 68, restrictions = THREADS_OF_FATE_RESTRICTION, },
                { level = 74, },
            }
        },
    },
    active = {
        type = "quest",
        id = 79717,
    },
    completed = {
        type = "quest",
        id = 79730,
    },
    items = {
        {
            type = "npc",
            id = 217692,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 79717,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 79718,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 79723,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 79729,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79730,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain27, {
    name = { -- Socialized Medicine
        type = "quest",
        id = 83177,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            variations = {
                { level = 68, restrictions = THREADS_OF_FATE_RESTRICTION, },
                { level = 78, },
            }
        },
        {
            type = "currency",
            id = 2904,
            amount = 7,
        },
    },
    active = {
        type = "quest",
        id = 83177,
    },
    completed = {
        type = "quest",
        id = 83178,
    },
    items = {
        {
            type = "npc",
            id = 208782,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83177,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83178,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain28, {
    name = { -- The Beginning of Something Beautiful
        type = "quest",
        id = 83627,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            variations = {
                { level = 68, restrictions = THREADS_OF_FATE_RESTRICTION, },
                { level = 78, },
            }
        },
    },
    active = {
        type = "quest",
        id = 79717,
    },
    completed = {
        type = "quest",
        id = 83721,
    },
    items = {
        {
            name = {
                type = "kill",
                id = 216046,
            },
            type = "item",
            id = 225952,
            breadcrumb = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83627,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83719,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83720,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83721,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain29, {
    name = L["FRACTURED_LEGACY_OF_ANUBAZAL"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            variations = {
                { level = 68, restrictions = THREADS_OF_FATE_RESTRICTION, },
                { level = 78, },
            }
        },
        {
            type = "currency",
            id = 2904,
            amount = 11,
        },
    },
    active = {
        type = "quest",
        id = 82338,
    },
    completed = {
        type = "quest",
        id = 82339,
    },
    items = {
        {
            type = "npc",
            id = 224345,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82338,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82339,
            x = 0,
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
        { -- Chasing the Light
            type = "quest",
            id = 78384,
        },
        { -- Intention vs Instinct
            type = "quest",
            id = 78898,
        },
        { -- Heeeelllp!!!
            type = "quest",
            id = 78901,
        },
        { -- Delegated Dig
            type = "quest",
            id = 78902,
        },
        {
            type = "quest",
            id = 78974,
        },
        { -- Truffle Shuffle
            type = "quest",
            id = 78995,
        },
        {
            type = "quest",
            id = 79116,
        },
        { -- Lab Access
            type = "quest",
            id = 79233,
        },
        { -- Making of a Monster
            type = "quest",
            id = 79237,
        },
        { -- The Queen's Chains
            type = "quest",
            id = 79239,
        },
        { -- Rogue Agent
            type = "quest",
            id = 79240,
        },
        { -- Go Loud
            type = "quest",
            id = 79241,
        },
        { -- Manufactured Mutiny
            type = "quest",
            id = 79243,
        },
        { -- News From Below
            type = "quest",
            id = 79244,
        },
        { -- Entrepreneur, Inc.
            type = "quest",
            id = 79349,
        },
        { -- Offensive Counter
            type = "quest",
            id = 79580,
        },
        { -- Trade Partners
            type = "quest",
            id = 79651,
        },
        { -- Gutter Work
            type = "quest",
            id = 79722,
        },
        { -- Worm Sign, Sealed, Delivered
            type = "quest",
            id = 79958,
        },
        {
            type = "quest",
            id = 79959,
        },
        {
            type = "quest",
            id = 79960,
        },
        { -- Polarized
            type = "quest",
            id = 80409,
        },
        {
            type = "quest",
            id = 80457,
        },
        {
            type = "quest",
            id = 80573,
        },
        { -- Severed Threads Pact
            type = "quest",
            id = 80592,
        },
        { -- Eyes of the Weaver
            type = "quest",
            id = 80670,
        },
        { -- Blade of the General
            type = "quest",
            id = 80671,
        },
        { -- Hand of the Vizier
            type = "quest",
            id = 80672,
        },
        {
            type = "quest",
            id = 81470,
        },
        { -- Dropping Eaves: Saving the Past
            type = "quest",
            id = 81471,
        },
        { -- Information Control: Ansurek's Truth
            type = "quest",
            id = 81472,
        },
        { -- Information Control: The Right Side of History
            type = "quest",
            id = 81473,
        },
        {
            type = "quest",
            id = 81475,
        },
        {
            type = "quest",
            id = 81476,
        },
        {
            type = "quest",
            id = 81477,
        },
        {
            type = "quest",
            id = 81478,
        },
        {
            type = "quest",
            id = 81479,
        },
        {
            type = "quest",
            id = 81480,
        },
        {
            type = "quest",
            id = 81481,
        },
        {
            type = "quest",
            id = 81482,
        },
        {
            type = "quest",
            id = 81483,
        },
        { -- Wet Work: Death of a Salesman
            type = "quest",
            id = 81484,
        },
        {
            type = "quest",
            id = 81487,
        },
        {
            type = "quest",
            id = 81488,
        },
        {
            type = "quest",
            id = 81489,
        },
        {
            type = "quest",
            id = 81490,
        },
        {
            type = "quest",
            id = 81491,
        },
        {
            type = "quest",
            id = 81492,
        },
        {
            type = "quest",
            id = 81493,
        },
        {
            type = "quest",
            id = 81494,
        },
        {
            type = "quest",
            id = 81495,
        },
        {
            type = "quest",
            id = 81496,
        },
        {
            type = "quest",
            id = 81497,
        },
        {
            type = "quest",
            id = 81498,
        },
        {
            type = "quest",
            id = 81499,
        },
        {
            type = "quest",
            id = 81500,
        },
        {
            type = "quest",
            id = 81501,
        },
        {
            type = "quest",
            id = 81502,
        },
        { -- Infiltration: Terror Made Manifest
            type = "quest",
            id = 81503,
        },
        { -- Infiltration: Hidden Figures
            type = "quest",
            id = 81504,
        },
        {
            type = "quest",
            id = 81505,
        },
        {
            type = "quest",
            id = 81506,
        },
        {
            type = "quest",
            id = 81555,
        },
        { -- The Upstart
            type = "quest",
            id = 81667,
        },
        { -- Measure Once, Cut Thrice
            type = "quest",
            id = 81668,
        },
        { -- Shattered Silk
            type = "quest",
            id = 81670,
        },
        { -- Subterfuge in Silk
            type = "quest",
            id = 81686,
        },
        { -- Skyrider Racing - City of Threads Twist
            type = "quest",
            id = 81824,
        },
        { -- Skyrider Racing - Siegehold Scuttle
            type = "quest",
            id = 81831,
        },
        { -- A Spy Like Us
            type = "quest",
            id = 82125,
        },
        { -- Defense of the People
            type = "quest",
            id = 82126,
        },
        { -- Make Them Prey
            type = "quest",
            id = 82127,
        },
        {
            type = "quest",
            id = 82266,
        },
        { -- Ziriak
            type = "quest",
            id = 82295,
        },
        { -- One Hungry Worm
            type = "quest",
            id = 82297,
        },
        {
            type = "quest",
            id = 82324,
        },
        { -- Unassuming Delivery Spider
            type = "quest",
            id = 82332,
        },
        { -- Absent Errand
            type = "quest",
            id = 82338,
        },
        { -- An Honorless Kill
            type = "quest",
            id = 82339,
        },
        { -- Opposing Forces
            type = "quest",
            id = 82363,
        },
        {
            type = "quest",
            id = 82364,
        },
        { -- Slay the Goo, Save the World
            type = "quest",
            id = 82387,
        },
        { -- Special Assignment: A Pound of Cure
            type = "quest",
            id = 82414,
        },
        { -- A Rare Key
            type = "quest",
            id = 82417,
        },
        { -- A Cache of Crests
            type = "quest",
            id = 82418,
        },
        { -- The Currency of Power
            type = "quest",
            id = 82419,
        },
        { -- Let Them Win
            type = "quest",
            id = 82468,
        },
        { -- Enforcer Extermination
            type = "quest",
            id = 82481,
        },
        { -- Pawns of Dark Masters
            type = "quest",
            id = 82521,
        },
        {
            type = "quest",
            id = 82524,
        },
        {
            type = "quest",
            id = 82526,
        },
        { -- Special Assignment: Bombs from Behind
            type = "quest",
            id = 82531,
        },
        { -- Dye! Dye Dye!
            type = "quest",
            id = 82533,
        },
        {
            type = "quest",
            id = 82536,
        },
        {
            type = "quest",
            id = 82581,
        },
        {
            type = "quest",
            id = 82616,
        },
        {
            type = "quest",
            id = 82640,
        },
        {
            type = "quest",
            id = 82641,
        },
        {
            type = "quest",
            id = 82642,
        },
        {
            type = "quest",
            id = 82643,
        },
        {
            type = "quest",
            id = 82644,
        },
        {
            type = "quest",
            id = 82645,
        },
        {
            type = "quest",
            id = 82646,
        },
        {
            type = "quest",
            id = 82647,
        },
        {
            type = "quest",
            id = 82648,
        },
        {
            type = "quest",
            id = 82649,
        },
        { -- Where the Wild Things Camp
            type = "quest",
            id = 83306,
        },
        { -- Strange Bats
            type = "quest",
            id = 83321,
        },
        { -- Bountiful Beetles
            type = "quest",
            id = 83325,
        },
        {
            type = "quest",
            id = 83536,
        },
        {
            type = "quest",
            id = 83718,
        },
        { -- Delver's Call: Spiral Weave
            type = "quest",
            id = 83770,
        },
        { -- DELVER'S CALL: Tak-Rethan Abyss
            type = "quest",
            id = 83771,
        },
        {
            type = "quest",
            id = 84471,
        },
    },
})

Database:AddCategory(CATEGORY_ID, {
    name = BtWQuests.GetMapName(MAP_ID),
    expansion = EXPANSION_ID,
    buttonImage = 5912548,
    items = {
        {
            type = "chain",
            id = Chain.FriendsInTheDark,
        },
        {
            type = "chain",
            id = Chain.UnravelingTheTrapped,
        },
        {
            type = "chain",
            id = Chain.PlansWithinPlans,
        },
        {
            type = "chain",
            id = Chain.RakUshSwarmery,
        },
        {
            type = "chain",
            id = Chain.PillarnestVosh,
        },
        {
            type = "chain",
            id = Chain.GutterWork,
        },
        {
            type = "chain",
            id = Chain.MelodyOfMadness,
        },
        {
            type = "chain",
            id = Chain.PawnsAndPuppetry,
        },
        {
            type = "chain",
            id = Chain.TheWormlands,
        },
        {
            type = "chain",
            id = Chain.HagglingWithMmarl,
        },
        {
            type = "chain",
            id = Chain.TheSecondFront,
        },
        {
            type = "chain",
            id = Chain.MrSunflowersTherapy,
        },
        {
            type = "chain",
            id = Chain.TheWildCamp,
        },
        {
            type = "chain",
            id = Chain.PillarnestOfHorrors,
        },
        {
            type = "chain",
            id = Chain.SubterfugeInSilk,
        },
        {
            type = "chain",
            id = Chain.SilkenWard,
        },
        {
            type = "chain",
            id = Chain.GrieveWeave,
        },
        {
            type = "chain",
            id = Chain.AllGoodThings,
        },
        {
            type = "chain",
            id = Chain.TempChain26,
        },
        {
            type = "chain",
            id = Chain.TempChain28,
        },
        {
            type = "chain",
            id = Chain.TempChain25,
        },
        {
            type = "chain",
            id = Chain.TempChain27,
        },
        {
            type = "chain",
            id = Chain.TempChain29,
        },
--[==[@debug@
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
Database:AddMapRecursive(2256, {
    type = "category",
    id = CATEGORY_ID,
})
Database:AddMapRecursive(2213, {
    type = "category",
    id = CATEGORY_ID,
})
Database:AddMapRecursive(2216, {
    type = "category",
    id = CATEGORY_ID,
})

BtWQuestsDatabase:AddQuestItemsForChain(Chain.FriendsInTheDark)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.UnravelingTheTrapped)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.PlansWithinPlans)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.RakUshSwarmery)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.PillarnestVosh)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.GutterWork)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.MelodyOfMadness)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.PawnsAndPuppetry)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.TheWormlands)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.HagglingWithMmarl)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.TheSecondFront)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.MrSunflowersTherapy)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.TheWildCamp)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.PillarnestOfHorrors)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.SubterfugeInSilk)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.SilkenWard)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.GrieveWeave)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.AllGoodThings)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.TempChain25)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.TempChain26)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.TempChain28)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.TempChain29)

--[==[@debug@
Database:AddContinentItems(CONTINENT_ID, {
    {
        type = "chain",
        id = Chain.RakUshSwarmery,
    },
    {
        type = "chain",
        id = Chain.PillarnestVosh,
    },
    {
        type = "chain",
        id = Chain.GutterWork,
    },
    {
        type = "chain",
        id = Chain.MelodyOfMadness,
    },
    {
        type = "chain",
        id = Chain.PawnsAndPuppetry,
    },
    {
        type = "chain",
        id = Chain.TheWormlands,
    },
    {
        type = "chain",
        id = Chain.HagglingWithMmarl,
    },
    {
        type = "chain",
        id = Chain.TheSecondFront,
    },
    {
        type = "chain",
        id = Chain.MrSunflowersTherapy,
    },
    {
        type = "chain",
        id = Chain.TheWildCamp,
    },
    {
        type = "chain",
        id = Chain.PillarnestOfHorrors,
    },
    {
        type = "chain",
        id = Chain.SubterfugeInSilk,
    },
    {
        type = "chain",
        id = Chain.SilkenWard,
    },
    {
        type = "chain",
        id = Chain.GrieveWeave,
    },
    {
        type = "chain",
        id = Chain.AllGoodThings,
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
