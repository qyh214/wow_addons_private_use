local BtWQuests = BtWQuests
local Database = BtWQuests.Database
local L = BtWQuests.L
local EXPANSION_ID = BtWQuests.Constant.Expansions.TheWarWithin
local CATEGORY_ID = BtWQuests.Constant.Category.TheWarWithin.Hallowfall
local Chain = BtWQuests.Constant.Chain.TheWarWithin.Hallowfall
local THREADS_OF_FATE_RESTRICTION = BtWQuests.Constant.Restrictions.TheWarWithinToF
local NOT_THREADS_OF_FATE_RESTRICTION = BtWQuests.Constant.Restrictions.NotTheWarWithinToF
local ALLIANCE_RESTRICTIONS, HORDE_RESTRICTIONS = 724, 723
local MAP_ID = 2215
local CONTINENT_ID = 2274
local ACHIEVEMENT_ID_1 = 20598
local ACHIEVEMENT_ID_2 = 40844
local LEVEL_RANGE = {75, 80}
local LEVEL_PREREQUISITES = {
    {
        type = "level",
        variations = {
            { level = 68, restrictions = THREADS_OF_FATE_RESTRICTION, },
            { level = 73, },
        }
    },
}

Chain.TheGuidingStar = 110301
Chain.GatheringShadows = 110302
Chain.HopeInSolidarity = 110303
Chain.LightToVelhansClaim = 110311
Chain.ThePriory = 110312
Chain.StrikingSteel = 110313
Chain.LostInTheDarkness = 110314
Chain.TheSkysTheLimit = 110315
Chain.CrushingDepths = 110316
Chain.TheLastMageOfHallowfall = 110317
Chain.TheWeightOfDuty = 110318
Chain.ApartForPurpose = 110319
Chain.RestAtLast = 110320
Chain.AnOrphansDilemma = 110321
Chain.TheMysteriousChef = 110322
Chain.WhatGrowsInTheDark = 110323
Chain.SuspiciousMinds = 110324
Chain.MemoriesOfTheSky = 110325
Chain.TempChain19 = 110329
Chain.TempChain21 = 110331
Chain.TempChain22 = 110332
Chain.TempChain23 = 110333
Chain.TempChain24 = 110334
Chain.TempChain25 = 110335
Chain.TempChain26 = 110336
Chain.TempChain27 = 110337
Chain.OtherAlliance = 110397
Chain.OtherHorde = 110398
Chain.OtherBoth = 110399

Database:AddChain(Chain.TheGuidingStar, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_1, 1),
    questline = 5529,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            variations = {
                { level = 68, restrictions = THREADS_OF_FATE_RESTRICTION, },
                { level = 73, },
            }
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.TheRingingDeeps.TheMonsterAndTheMachine,
            restrictions = NOT_THREADS_OF_FATE_RESTRICTION
        },
    },
    active = {
        type = "quest",
        ids = {
            78658, 78659, 83551, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 78671,
    },
    items = {
        {
            type = "npc",
            id = 213983,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 83551,
                    restrictions = {
                        type = "quest",
                        id = 83551,
                        status = {'active', 'completed'}
                    },
                },
                {
                    type = "quest",
                    id = 78658,
                }
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78659,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 78665,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 79999,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 78666,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 78667,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78668,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 78669,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 78670,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82836,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78671,
            x = 0,
        },
    },
})
Database:AddChain(Chain.GatheringShadows, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_1, 2),
    questline = 5530,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            variations = {
                { level = 68, restrictions = THREADS_OF_FATE_RESTRICTION, },
                { level = 73, },
            }
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.TheRingingDeeps.TheMonsterAndTheMachine,
            restrictions = NOT_THREADS_OF_FATE_RESTRICTION,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheGuidingStar,
        },
    },
    active = {
        type = "quest",
        id = 78672,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 78954,
    },
    items = {
        {
            type = "npc",
            id = 213116,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78672,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 78929,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 78932,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 78934,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 78936,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78937,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78939,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78951,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78952,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 81690,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78954,
            x = 0,
        },
    },
})
Database:AddChain(Chain.HopeInSolidarity, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_1, 3),
    questline = 5526,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            variations = {
                { level = 68, restrictions = THREADS_OF_FATE_RESTRICTION, },
                { level = 73, },
            }
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.TheRingingDeeps.TheMonsterAndTheMachine,
            restrictions = NOT_THREADS_OF_FATE_RESTRICTION,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheGuidingStar,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.GatheringShadows,
        },
    },
    active = {
        type = "quest",
        id = 78607,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 78630,
    },
    items = {
        {
            type = "npc",
            id = 214404,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78607,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78613,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79297,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78626,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78614,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78615,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 78620,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 78621,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78624,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 80049,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 79089,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78627,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 78628,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 78629,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78630,
            x = 0,
        },
    },
})
Database:AddChain(Chain.LightToVelhansClaim, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 1),
    questline = 5522,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 78686,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 78695,
    },
    items = {
        {
            type = "npc",
            id = 214019,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78686,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 78688,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 78689,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78690,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 78693,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 78694,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78692,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 78687,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 78691,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78695,
            x = 0,
        },
    },
})
Database:AddChain(Chain.ThePriory, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 2),
    questline = 5610,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 82628,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 79649,
    },
    items = {
        {
            type = "npc",
            id = 215335,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82628,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 79641,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 79642,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79643,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79644,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 79645,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 79646,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79647,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79648,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79649,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79650,
            aside = true,
            x = 0,
        },
    },
})
Database:AddChain(Chain.StrikingSteel, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 3),
    questline = 5563,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            variations = {
                { level = 68, restrictions = THREADS_OF_FATE_RESTRICTION, },
                { level = 73, },
            }
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.TheRingingDeeps.TheMonsterAndTheMachine,
            restrictions = NOT_THREADS_OF_FATE_RESTRICTION,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheGuidingStar,
            restrictions = NOT_THREADS_OF_FATE_RESTRICTION,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.GatheringShadows,
            restrictions = NOT_THREADS_OF_FATE_RESTRICTION,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.HopeInSolidarity,
            restrictions = NOT_THREADS_OF_FATE_RESTRICTION,
            upto = 78607,
        },
    },
    active = {
        type = "quest",
        ids = {
            82216, 82219, 82220, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 82222,
    },
    items = {
        {
            type = "npc",
            id = 213145,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82216,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 82213,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 82214,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 82215,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82217,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            name = format(L["BTWQUESTS_WAIT_DAYS"], 2),
            active = {
                type = "quest",
                id = 82217,
            },
            completed = {
                {
                    type = "quest",
                    id = 82217,
                },
                {
                    type = "quest",
                    id = 82218,
                    status = { "pending", },
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "npc",
            id = 213145,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 82219,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 82220,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82221,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82222,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82223,
            aside = true,
            x = 0,
        },
    },
})
Database:AddChain(Chain.LostInTheDarkness, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 4),
    questline = 5608,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 80
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.AgainstTheCurrent,
            upto = 79197,
        }
    },
    active = {
        type = "quest",
        id = 79108,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 79110,
    },
    items = {
        {
            type = "npc",
            id = 206528,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 79108,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79109,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79110,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheSkysTheLimit, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 5),
    questline = 5532,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            79300, 79304, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 79303,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 79304,
                    restrictions = {
                        type = "quest",
                        id = 79304,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 216001,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79300,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79301,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79302,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79303,
            x = 0,
        },
    },
})
Database:AddChain(Chain.CrushingDepths, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 6),
    questline = 5602,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            variations = {
                { level = 68, restrictions = THREADS_OF_FATE_RESTRICTION, },
                { level = 73, },
            },
        },
    },
    active = {
        type = "quest",
        ids = {
            80312, 81797, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 80316,
    },
    items = {
        -- Requires 78929 and/or 78932 for just Targeted Recon. Its kind of a breadcrumb for getting the drop
        --Got during 78929, some Arathis turn in to the Shadeshapers who drop the needed item. Not sure if they can be clicked before getting this quest or if the shadeshapers can be seen outside of Targeted Recon
        {
            type = "npc",
            id = 218508,
            x = -2,
            visible = false,
            connections = {
                2,
            },
        },
        {
            type = "kill",
            id = 215653,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 81797,
            visible = false,
            aside = true,
            x = -2,
        },
        {
            type = "quest",
            id = 80312,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 80313,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 80314,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 80315,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 80316,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheLastMageOfHallowfall, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 7),
    questline = 5552,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            80175, 80176, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 80179,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 80175,
                    restrictions = {
                        type = "quest",
                        id = 80175,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 219135,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 80176,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 80177,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 80178,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 80179,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheWeightOfDuty, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 8),
    questline = 5607,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            variations = {
                { level = 68, restrictions = THREADS_OF_FATE_RESTRICTION, },
                { level = 73, },
            }
        },
    },
    active = {
        type = "quest",
        id = 79159,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 79162,
    },
    items = {
        {
            type = "npc",
            id = 215306,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79159,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 79160,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 79162, -- Moved
            x = 0,
        },
    },
})
Database:AddChain(Chain.ApartForPurpose, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 9),
    questline = 5574,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 82477,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 82480,
    },
    items = {
        {
            type = "npc",
            id = 223920,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82477,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82478,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82479,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82480,
            x = 0,
        },
    },
})
Database:AddChain(Chain.RestAtLast, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 10),
    questline = 5542,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 80,
        },
    },
    active = {
        type = "quest",
        ids = {
            79165, 83497, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 79168,
    },
    items = {
        -- Unknown requirement, probably around 78607, level 80
        -- Wowhead comment says both 83497 and 79165 are breadcrumbs
        {
            variations = {
                {
                    type = "quest",
                    id = 83497,
                    restrictions = {
                        type = "quest",
                        id = 83497,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 215341,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79165,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79166,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79167,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79168,
            x = 0,
        },
    },
})
Database:AddChain(Chain.AnOrphansDilemma, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 11),
    questline = 5527,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            variations = {
                { level = 68, restrictions = THREADS_OF_FATE_RESTRICTION, },
                { level = 73, },
            }
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.TheRingingDeeps.TheMonsterAndTheMachine,
            restrictions = NOT_THREADS_OF_FATE_RESTRICTION,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheGuidingStar,
            restrictions = NOT_THREADS_OF_FATE_RESTRICTION,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.GatheringShadows,
            restrictions = NOT_THREADS_OF_FATE_RESTRICTION,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.HopeInSolidarity,
            restrictions = NOT_THREADS_OF_FATE_RESTRICTION,
            upto = 78607,
        },
    },
    active = {
        type = "quest",
        id = 79151,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 79154,
    },
    items = {
        {
            type = "npc",
            id = 215237,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79151,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 83182,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 79152,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79153,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79154,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheMysteriousChef, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 12),
    questline = 5645,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            82843, 84392, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 82847,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 84392,
                    restrictions = {
                        type = "quest",
                        id = 84392,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 224741,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82843,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82844,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82847,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82848,
            aside = true,
            x = 0,
        },
    },
})
Database:AddChain(Chain.WhatGrowsInTheDark, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 13),
    questline = 5603,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 79309,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 79313,
    },
    items = {
        {
            type = "npc",
            id = 216061,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79309,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79310,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 79311,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 79312,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79313,
            x = 0,
        },
    },
})
Database:AddChain(Chain.SuspiciousMinds, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 14),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            83247, 83283, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {
            83247, 83283,
        },
        count = 2,
    },
    items = {
        {
            type = "npc",
            id = 225857,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "npc",
            id = 225879,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 83283,
            x = -1,
        },
        {
            type = "quest",
            id = 83247,
        },
    },
})
Database:AddChain(Chain.MemoriesOfTheSky, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 15),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 80,
        },
    },
    active = {
        type = "quest",
        ids = {
            80673, 80677, 82810, 82813, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {
            80678, 82810, 82813
        },
        count = 3,
    },
    items = {
        {
            type = "npc",
            id = 220718,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 80673,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 80677,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 80678,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            name = L["BTWQUESTS_WAIT_FOR_WEEKLY_RESET"],
            breadcrumb = true,
            active = {
                {
                    type = "quest",
                    ids = { 80678, 82749, },
                    count = 2,
                },
            },
            completed = {
                {
                    type = "quest",
                    id = 80678,
                },
                {
                    type = "quest",
                    id = 82749,
                    status = { "pending", },
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82810,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            name = L["BTWQUESTS_WAIT_FOR_WEEKLY_RESET"],
            breadcrumb = true,
            active = {
                {
                    type = "quest",
                    ids =  { 82810, 82749, },
                    count = 2,
                },
            },
            completed = {
                {
                    type = "quest",
                    id = 82810,
                },
                {
                    type = "quest",
                    id = 82749,
                    status = { "pending", },
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82813,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain19, {
    name = { -- Honor Your Efforts
        type = "quest",
        id = 81673,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 80,
        },
        -- Based on PTR level 80 without campaign there is a requirement for this
    },
    active = {
        type = "quest",
        id = 79232,
        status = { "active", "completed" }
    },
    completed = {
        type = "quest",
        id = 81673,
    },
    items = {
        {
            type = "npc",
            id = 215527,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79232,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 81673,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain21, {
    name = { -- The Price of Hope
        type = "quest",
        id = 82894,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            variations = {
                { level = 68, restrictions = THREADS_OF_FATE_RESTRICTION, },
                { level = 73, },
            }
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.TheRingingDeeps.TheMonsterAndTheMachine,
            restrictions = NOT_THREADS_OF_FATE_RESTRICTION,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheGuidingStar,
            restrictions = NOT_THREADS_OF_FATE_RESTRICTION,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.GatheringShadows,
            restrictions = NOT_THREADS_OF_FATE_RESTRICTION,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.HopeInSolidarity,
            restrictions = NOT_THREADS_OF_FATE_RESTRICTION,
            upto = 78607,
        },
    },
    active = {
        type = "quest",
        id = 82894,
        status = { "active", "completed" }
    },
    completed = {
        type = "quest",
        id = 82894,
    },
    items = {
        {
            type = "npc",
            id = 215335,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82894,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain22, {
    name = { -- The Dawnbreaker: The Christening
        type = "quest",
        id = 83322,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 80,
        },
    },
    completed = {
        type = "quest",
        id = 81673,
    },
    items = {
        {
            type = "npc",
            id = 215335,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83322,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain23, {
    name = { -- Tarnished Compass
        type = "quest",
        id = 80680,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        { -- Something else?
            type = "level",
            variations = {
                { level = 68, restrictions = THREADS_OF_FATE_RESTRICTION, },
                { level = 80, },
            }
        },
    },
    completed = {
        type = "quest",
        id = 80680,
    },
    items = {
        {
            type = "object",
            id = 439890,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 80680,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain24, {
    name = { -- Eggs in One Basket
        type = "quest",
        id = 80382,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        { -- renown 2?
            type = "level",
            level = 80,
        },
    },
    completed = {
        type = "quest",
        id = 80382,
    },
    items = {
        {
            type = "object",
            id = 430581,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 80382,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain25, {
    name = { -- Keep the Home Fires Burning
        type = "quest",
        id = 76247,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = { -- Maybe renown 2?
        {
            type = "level",
            level = 80,
        },
    },
    completed = {
        type = "quest",
        id = 76247,
    },
    items = {
        {
            type = "npc",
            id = 206528,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76247,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain26, { -- Breadcrumb to another npc
    name = { -- The Light's Call
        type = "quest",
        id = 81990,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = { -- Possibly renown 2
        {
            type = "level",
            variations = {
                { level = 68, restrictions = THREADS_OF_FATE_RESTRICTION, },
                { level = 80, },
            }
        },
    },
    completed = {
        type = "quest",
        id = 81990,
    },
    items = {
        {
            type = "npc",
            id = 213145,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 81990,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain27, {
    name = { -- The Flame Within
        type = "quest",
        id = 81692,
    },
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
            id = Chain.TempChain19,
        },
        {
            type = "currency",
            id = 2901,
            amount = 11,
        },
    },
    active = {
        type = "quest",
        id = 81692,
    },
    completed = {
        type = "quest",
        id = 81896,
    },
    items = {
        {
            type = "npc",
            id = 214380,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 81692,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 81751,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 81869,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 81896,
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
        { -- Glow in the Dark
            type = "quest",
            id = 76169,
        },
        { -- A Better Cabbage Smacker
            type = "quest",
            id = 76338,
        },
        { -- Spreading The Light
            type = "quest",
            id = 76586,
        },
        { -- Defender of the Flame
            type = "quest",
            id = 76588,
        },
        { -- Right Between Gyro-Optics - Activate
            type = "quest",
            id = 76599,
        },
        { -- Tater Trawl
            type = "quest",
            id = 76733,
        },
        { -- Lost in Shadows
            type = "quest",
            id = 76997,
        },
        { -- Reinforcements - Activate
            type = "quest",
            id = 78452,
        },
        { -- Havrest Havoc - Activator
            type = "quest",
            id = 78458,
        },
        { -- Shadows of Flavor - Activate
            type = "quest",
            id = 78466,
        },
        { -- Glow In The Dark - Activate
            type = "quest",
            id = 78472,
        },
        { -- Cutting Edge
            type = "quest",
            id = 78590,
        },
        { -- Hose It Down
            type = "quest",
            id = 78656,
        },
        { -- The Midnight Sentry
            type = "quest",
            id = 78657,
        },
        { -- The Hallowed Path
            type = "quest",
            id = 78658,
        },
        { -- Harvest Havoc
            type = "quest",
            id = 78972,
        },
        { -- Web of Manipulation
            type = "quest",
            id = 79216,
        },
        { -- Hose 'Em Down - Activate
            type = "quest",
            id = 79295,
        },
        { -- Glowing Harvest
            type = "quest",
            id = 79329,
        },
        { -- Bog Beast Banishment
            type = "quest",
            id = 79380,
        },
        { -- Web of Manipulation - Activate
            type = "quest",
            id = 79383,
        },
        { -- Lurking Below
            type = "quest",
            id = 79469,
        },
        { -- Waters of War
            type = "quest",
            id = 79470,
        },
        { -- Bleak Sand
            type = "quest",
            id = 79471,
        },
        { -- Crab Grab - Activate
            type = "quest",
            id = 80005,
        },
        { -- Fending off Darkness
            type = "quest",
            id = 80412,
        },
        { -- Blossoming Delight
            type = "quest",
            id = 80562,
        },
        { -- Release the Beasts
            type = "quest",
            id = 81568,
        },
        { -- Recovery Job
            type = "quest",
            id = 81620,
        },
        {
            type = "quest",
            id = 81622,
        },
        { -- The Flame Within
            type = "quest",
            id = 81692,
        },
        { -- Fire and Gemstone
            type = "quest",
            id = 81751,
        },
        { -- Skyrider Racing - Tenir's Traversal
            type = "quest",
            id = 81816,
        },
        { -- Skyrider Racing - Stillstone Slalom
            type = "quest",
            id = 81819,
        },
        { -- Skyrider Racing - Mereldar Meander
            type = "quest",
            id = 81822,
        },
        { -- Feline Frenzy
            type = "quest",
            id = 81862,
        },
        { -- Can Catch More Fires with Honey
            type = "quest",
            id = 81869,
        },
        { -- New and Improved
            type = "quest",
            id = 81896,
        },
        { -- BOOM Treats!
            type = "quest",
            id = 81950,
        },
        { -- The Blacksmith's Fate
            type = "quest",
            id = 81964,
        },
        { -- Invasion Disruption
            type = "quest",
            id = 81965,
        },
        { -- An End to the End
            type = "quest",
            id = 81969,
        },
        { -- The Light's Call
            type = "quest",
            id = 81990,
        },
        {
            type = "quest",
            id = 82041,
        },
        { -- Kobyss Kibosh
            type = "quest",
            id = 82088,
        },
        {
            type = "quest",
            id = 82120,
        },
        {
            type = "quest",
            id = 82131,
        },
        { -- Documenting: Field Manual Edition
            type = "quest",
            id = 82133,
        },
        {
            type = "quest",
            id = 82197,
        },
        {
            type = "quest",
            id = 82206,
        },
        {
            type = "quest",
            id = 82254,
        },
        { -- Burrow Burial
            type = "quest",
            id = 82257,
        },
        { -- Sieging Siege Weapons
            type = "quest",
            id = 82258,
        },
        { -- Honoring our Fallen
            type = "quest",
            id = 82259,
        },
        { -- The Sorrowful Journey Home
            type = "quest",
            id = 82268,
        },
        { -- Remembrance for the Fallen
            type = "quest",
            id = 82284,
        },
        { -- Work Hard, Play Hard
            type = "quest",
            id = 82288,
        },
        { -- Miniature Army
            type = "quest",
            id = 82294,
        },
        { -- The Thing from the Swamp
            type = "quest",
            id = 82298,
        },
        { -- For Want of a Lock
            type = "quest",
            id = 82335,
        },
        { -- Crystals and Crests
            type = "quest",
            id = 82390,
        },
        { -- Mired in Shadow
            type = "quest",
            id = 82582,
        },
        { -- Igniting the Fire Within
            type = "quest",
            id = 82583,
        },
        { -- Light's Gambit
            type = "quest",
            id = 82584,
        },
        { -- With Great Pyre
            type = "quest",
            id = 82585,
        },
        { -- Spore Ender
            type = "quest",
            id = 82586,
        },
        { -- Hallowfall Fishing Derby
            type = "quest",
            id = 82778,
        },
        { -- Special Assignment: Rise of the Colossals
            type = "quest",
            id = 82787,
        },
        { -- Time Found
            type = "quest",
            id = 82810,
        },
        { -- Time Borrowed
            type = "quest",
            id = 82813,
        },
        { -- Special Assignment: Lynx Rescue
            type = "quest",
            id = 82852,
        },
        { -- Prove One's Mettle
            type = "quest",
            id = 83279,
        },
        { -- Hallowfall Fishing Derby
            type = "quest",
            id = 83529,
        },
        { -- Hallowfall Fishing Derby
            type = "quest",
            id = 83530,
        },
        {
            type = "quest",
            id = 83531,
        },
        {
            type = "quest",
            id = 83532,
        },
        { -- Delver's Call: The Sinkhole
            type = "quest",
            id = 83767,
        },
        { -- Delver's Call: The Skittering Breach
            type = "quest",
            id = 83768,
        },
        { -- Delver's Call: Mycomancer Cavern
            type = "quest",
            id = 83769,
        },
        { -- Delver's Call: Nightfall Sanctum (Requires 78613)
            type = "quest",
            id = 83755,
        },
    },
})

Database:AddCategory(CATEGORY_ID, {
    name = BtWQuests.GetMapName(MAP_ID),
    expansion = EXPANSION_ID,
    buttonImage = 5912551,
    items = {
        {
            type = "chain",
            id = Chain.TheGuidingStar,
        },
        {
            type = "chain",
            id = Chain.GatheringShadows,
        },
        {
            type = "chain",
            id = Chain.HopeInSolidarity,
        },
        {
            type = "chain",
            id = Chain.LightToVelhansClaim,
        },
        {
            type = "chain",
            id = Chain.ThePriory,
        },
        {
            type = "chain",
            id = Chain.StrikingSteel,
        },
        {
            type = "chain",
            id = Chain.LostInTheDarkness,
        },
        {
            type = "chain",
            id = Chain.TheSkysTheLimit,
        },
        {
            type = "chain",
            id = Chain.CrushingDepths,
        },
        {
            type = "chain",
            id = Chain.TheLastMageOfHallowfall,
        },
        {
            type = "chain",
            id = Chain.TheWeightOfDuty,
        },
        {
            type = "chain",
            id = Chain.ApartForPurpose,
        },
        {
            type = "chain",
            id = Chain.RestAtLast,
        },
        {
            type = "chain",
            id = Chain.AnOrphansDilemma,
        },
        {
            type = "chain",
            id = Chain.TheMysteriousChef,
        },
        {
            type = "chain",
            id = Chain.WhatGrowsInTheDark,
        },
        {
            type = "chain",
            id = Chain.SuspiciousMinds,
        },
        {
            type = "chain",
            id = Chain.MemoriesOfTheSky,
        },
        {
            type = "chain",
            id = Chain.TempChain19,
        },
        {
            type = "chain",
            id = Chain.TempChain27,
        },
--[==[@debug@
        {
            type = "chain",
            id = Chain.TempChain21,
        },
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

BtWQuestsDatabase:AddQuestItemsForChain(Chain.TheGuidingStar)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.GatheringShadows)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.HopeInSolidarity)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.LightToVelhansClaim)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.ThePriory)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.StrikingSteel)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.LostInTheDarkness)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.TheSkysTheLimit)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.CrushingDepths)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.TheLastMageOfHallowfall)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.TheWeightOfDuty)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.ApartForPurpose)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.RestAtLast)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.AnOrphansDilemma)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.TheMysteriousChef)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.WhatGrowsInTheDark)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.SuspiciousMinds)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.MemoriesOfTheSky)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.TempChain19)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.TempChain27)


--[==[@debug@
Database:AddContinentItems(CONTINENT_ID, {
    {
        type = "chain",
        id = Chain.LightToVelhansClaim,
    },
    {
        type = "chain",
        id = Chain.ThePriory,
    },
    {
        type = "chain",
        id = Chain.StrikingSteel,
    },
    {
        type = "chain",
        id = Chain.LostInTheDarkness,
    },
    {
        type = "chain",
        id = Chain.TheSkysTheLimit,
    },
    {
        type = "chain",
        id = Chain.CrushingDepths,
    },
    {
        type = "chain",
        id = Chain.TheLastMageOfHallowfall,
    },
    {
        type = "chain",
        id = Chain.TheWeightOfDuty,
    },
    {
        type = "chain",
        id = Chain.ApartForPurpose,
    },
    {
        type = "chain",
        id = Chain.RestAtLast,
    },
    {
        type = "chain",
        id = Chain.AnOrphansDilemma,
    },
    {
        type = "chain",
        id = Chain.TheMysteriousChef,
    },
    {
        type = "chain",
        id = Chain.WhatGrowsInTheDark,
    },
    {
        type = "chain",
        id = Chain.SuspiciousMinds,
    },
    {
        type = "chain",
        id = Chain.MemoriesOfTheSky,
    },
    {
        type = "chain",
        id = Chain.TempChain19,
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
