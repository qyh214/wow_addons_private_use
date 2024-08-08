-- AUTO GENERATED - NEEDS UPDATING

local BtWQuests = BtWQuests
local Database = BtWQuests.Database
local EXPANSION_ID = BtWQuests.Constant.Expansions.Dragonflight
local CATEGORY_ID = BtWQuests.Constant.Category.Dragonflight.TheAzureSpan
local Chain = BtWQuests.Constant.Chain.Dragonflight.TheAzureSpan
local THREADS_OF_FATE_RESTRICTION = BtWQuests.Constant.Restrictions.DragonflightToF
local NOT_THREADS_OF_FATE_RESTRICTION = BtWQuests.Constant.Restrictions.NOTDragonflightToF
local ALLIANCE_RESTRICTIONS, HORDE_RESTRICTIONS = 924, 923
local MAP_ID = 2024
local CONTINENT_ID = 1978
local ACHIEVEMENT_ID_1 = 16336
local ACHIEVEMENT_ID_2 = 16428
local LEVEL_RANGE = {60, 70}
local LEVEL_PREREQUISITES = {
    {
        type = "level",
        variations = {
            { level = 58, restrictions = THREADS_OF_FATE_RESTRICTION, },
            { level = 63, },
        },
    },
}

Chain.IntoTheArchives = 100301
Chain.TuskarrTroubles = 100302
Chain.DecayedRoots = 100303
Chain.Vakthros = 100304
Chain.TempChain01 = 100311
Chain.TempChain02 = 100312
Chain.TempChain03 = 100313
Chain.TempChain04 = 100314
Chain.TempChain05 = 100315
Chain.TempChain06 = 100316
Chain.TempChain07 = 100317
Chain.TempChain08 = 100318
Chain.TempChain09 = 100319
Chain.TempChain10 = 100320
Chain.TempChain11 = 100321
Chain.TempChain12 = 100322
Chain.TempChain13 = 100323
Chain.TempChain14 = 100324
Chain.TempChain15 = 100325
Chain.TempChain16 = 100326
Chain.TempChain17 = 100327
Chain.TempChain18 = 100328
Chain.TempChain19 = 100329
Chain.TempChain21 = 100331
Chain.TempChain22 = 100332
Chain.TempChain23 = 100333
Chain.TempChain24 = 100334
Chain.TempChain25 = 100335
Chain.TempChain26 = 100336
Chain.TempChain27 = 100337
Chain.TempChain28 = 100338
Chain.TempChain29 = 100339
Chain.TempChain30 = 100340
Chain.TempChain31 = 100341
Chain.TempChain32 = 100342

Chain.OtherAlliance = 100397
Chain.OtherHorde = 100398
Chain.OtherBoth = 100399

Database:AddChain(Chain.IntoTheArchives, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_1, 1),
    questline = 1314,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            variations = {
                { level = 58, restrictions = THREADS_OF_FATE_RESTRICTION, },
                { level = 63, },
            },
        },
        {
            type = "achievement",
            id = 15394,
            restrictions = NOT_THREADS_OF_FATE_RESTRICTION,
        },
    },
    active = {
        type = "quest",
        ids = { 66340, 65686 },
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 65855,
    },
    items = {
        {
            variations = {
                {
                    type = "npc",
                    id = 188181,
                    restrictions = NOT_THREADS_OF_FATE_RESTRICTION,
                },
                {
                    type = "npc",
                    id = 188181,
                    restrictions = {
                        type = "quest",
                        id = 66340,
                        status = {'active', 'completed'},
                    },
                },
                {
                    type = "npc",
                    id = 198386,
                    restrictions = {
                        type = "quest",
                        id = 72268,
                        status = {'active', 'completed'},
                    },
                },
                {
                    visible = false,
                    y = -1,
                }
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 66340,
                    restrictions = NOT_THREADS_OF_FATE_RESTRICTION,
                },
                {
                    type = "quest",
                    id = 66340,
                    restrictions = {
                        type = "quest",
                        id = 66340,
                        status = {'active', 'completed'},
                    },
                },
                {
                    type = "quest",
                    id = 72268,
                    restrictions = {
                        type = "quest",
                        id = 72268,
                        status = {'active', 'completed'},
                    },
                },
                {
                    type = "npc",
                    id = 185599,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65686,
            x = 0,
            connections = {
                1, 2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 67177,
            aside = true,
            x = -3,
        },
        {
            type = "quest",
            id = 66228,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 66227,
            aside = true,
        },
        {
            type = "quest",
            id = 67174,
            aside = true,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 67033,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 67175,
            aside = true,
            x = 3,
        },
        {
            type = "quest",
            id = 67035,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 67036,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65688,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65689,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65702,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65709,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65852,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 65751,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 65752,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65854,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65855,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TuskarrTroubles, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_1, 2),
    questline = 1317,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            variations = {
                { level = 58, restrictions = THREADS_OF_FATE_RESTRICTION, },
                { level = 63, },
            },
        },
        {
            type = "achievement",
            id = 15394,
            lowPriority = true,
            restrictions = NOT_THREADS_OF_FATE_RESTRICTION,
        },
        {
            type = "chain",
            id = Chain.IntoTheArchives,
        }
    },
    active = {
        type = "quest",
        id = 66699,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 66026,
    },
    items = {
        {
            type = "npc",
            id = 183543,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66699,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65864,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 65868,
            x = -2,
            connections = {
                3, 4, 5, 6, 
            },
        },
        {
            type = "quest",
            id = 65866,
            connections = {
                2, 3, 4, 5, 
            },
        },
        {
            type = "quest",
            id = 65867,
            connections = {
                1, 2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 65870,
            x = -3,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 65871,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 65872,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 65873,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66239,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65869,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66026,
            x = 0,
        },
    },
})
Database:AddChain(Chain.DecayedRoots, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_1, 3),
    questline = 1316,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            variations = {
                { level = 58, restrictions = THREADS_OF_FATE_RESTRICTION, },
                { level = 63, },
            },
        },
        {
            type = "achievement",
            id = 15394,
            lowPriority = true,
            restrictions = NOT_THREADS_OF_FATE_RESTRICTION,
        },
        {
            type = "chain",
            id = Chain.IntoTheArchives,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TuskarrTroubles,
        }
    },
    active = {
        type = "quest",
        id = 65838,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 65911,
    },
    items = {
        {
            type = "npc",
            id = 187873,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65838,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 65844,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 65845,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 65846,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65848,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65847,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65849,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 66210,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 66211,
            aside = true,
        },
        {
            type = "quest",
            id = 65850,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65911,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Vakthros, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_1, 4),
    questline = 1315,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            variations = {
                { level = 58, restrictions = THREADS_OF_FATE_RESTRICTION, },
                { level = 63, },
            },
        },
        {
            type = "achievement",
            id = 15394,
            lowPriority = true,
            restrictions = NOT_THREADS_OF_FATE_RESTRICTION,
        },
        {
            type = "chain",
            id = Chain.IntoTheArchives,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TuskarrTroubles,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.DecayedRoots,
        }
    },
    active = {
        type = "quest",
        id = 66027,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 66015,
    },
    items = {
        {
            type = "npc",
            id = 186280,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66027,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65886,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65887,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 65943,
            x = -2,
            connections = {
                3, 4, 
            },
        },
        {
            type = "quest",
            id = 65944,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 66647,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 65958,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 65977,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66007,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66009,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70041,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66015,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain01, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 1),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            variations = {
                { level = 58, restrictions = THREADS_OF_FATE_RESTRICTION, },
                { level = 63, },
            },
        },
        {
            type = "chain",
            id = Chain.TempChain03,
        },
    },
    active = {
        type = "quest",
        id = 71013,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 71135,
    },
    items = {
        {
            type = "npc",
            id = 196812,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 71013,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 71014,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 71016,
            connections = {
                5, 
            },
        },
        {
            type = "quest",
            id = 71015,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 70996,
            x = -2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 71009,
            x = 2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 71000,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 71017,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 71012,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 71135,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain02, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 2),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 66781,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 66559,
    },
    items = {
        { -- Apparently no requirements
            variations = {
                {
                    type = "quest",
                    id = 71234,
                    restrictions = {
                        type = "quest",
                        id = 71234,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 190691,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66781,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 66164,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 66154,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 66147,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66175,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 66177,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 66232,
            aside = true,
        },
        {
            type = "quest",
            id = 66187,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66559,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain03, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 3),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 66709,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 66730,
    },
    items = {
        { -- Apparently no requirements
            type = "npc",
            id = 189963,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66709,
            x = 0,
            connections = {
                1, 
            },
            comment = "Bonus objective became available after this",
        },
        {
            type = "quest",
            id = 66715,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66703,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 67050,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66730,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain04, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 4),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {71235, 68639, 68641},
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 70338,
    },
    items = {
        { -- No apparent requirements
            variations = {
                {
                    type = "quest",
                    id = 71235,
                    restrictions = {
                        type = "quest",
                        id = 71235,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 192825,
                },
            },
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "npc",
            id = 192830,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 68639,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 68641,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 68643,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 68642,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 68644,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 69862,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70338,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain05, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 5),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 66262,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 66270,
    },
    items = {
        { -- Apparently no requirements
            type = "npc",
            id = 187463,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 66262,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 66263,
            x = -1,
            connections = {
                2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 66264,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 66265,
            x = -2,
            connections = {
                3, 4, 
            },
        },
        {
            type = "quest",
            id = 66266,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 66267,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 66268,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 66269,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66270,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain06, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 6),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {65279, 65306,},
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 65595,
    },
    items = {
        { -- Apparently not requirements
            type = "npc",
            id = 183997,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 65279,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 65306,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65302,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65594,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65595,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain07, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 7),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {65750, 65769,},
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 65834,
    },
    items = {
        { -- Apparently no requirements
            type = "npc",
            id = 185778,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 65750,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 65769,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65758,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 65832,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 65833,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65834,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain08, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 8),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {65914, 65925,},
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 66155,
    },
    items = {
        { -- Apparently no requirements
            type = "npc",
            id = 186157,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 65914,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 65925,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65926,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66724,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 65929,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 65928,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65930,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66155,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain09, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 9),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {67111, 67724, 70856,},
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 70970,
    },
    items = {
        { -- No apparent requirements, check if all 3 start quests are required, (67111 required)
            type = "npc",
            id = 196254,
            x = -2,
            connections = {
                2, 
            },
        },
        {
            type = "npc",
            id = 191715,
            x = 1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 67111,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 67724,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 70856,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70858,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70859,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 70931,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 70937,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70946,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70970,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain10, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 10),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 66391,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 66429,
    },
    items = {
        { -- Apparently no requirements
            type = "npc",
            id = 188144,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66391,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 66353,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 66352,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66422,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66423,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66425,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66427,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66428,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66429,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain11, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 11),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 66141,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 66152,
    },
    items = {
        { -- Apparently no requirements
            type = "npc",
            id = 187301,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66141,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 66148,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 66149,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 66150,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66151,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66152,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain12, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 12),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {66553, 66554,},
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 66556,
    },
    items = {
        {
            visible = false,
            x = -3,
        },
        {
            type = "chain",
            id = Chain.TempChain17,
            aside = true,
            embed = true,
            x = 3,
        },
        { -- Apparently no requirements
            type = "npc",
            id = 189401,
            x = 0,
            y = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 66553,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 66554,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66555,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66556,
            x = 0,
        },
    },
})

Database:AddChain(Chain.TempChain13, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    completed = {
        type = "quest",
        id = 66556,
    },
    items = {
        {
            type = "object",
            id = 376757,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66488,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66489,
            x = 0,
        },
    }
})
Database:AddChain(Chain.TempChain14, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    completed = {
        type = "quest",
        id = 66556,
    },
    items = {
        {
            type = "npc",
            id = 191205,
            x = 0,
            comment = "Apparently no requirements, unsure how this chain is set up or where to put nesingwary since he moves around, do each one of these have their own start locations? Yes, it seems so",
        },
        {
            type = "quest",
            id = 66957,
            x = -3,
        },
        {
            type = "quest",
            id = 66958,
        },
        {
            type = "quest",
            id = 66968,
        },
        {
            type = "quest",
            id = 66971,
        },
        {
            type = "quest",
            id = 66972,
            x = -3,
        },
        {
            type = "quest",
            id = 66939,
        },
    }
})
Database:AddChain(Chain.TempChain15, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    completed = {
        type = "quest",
        id = 66556,
    },
    items = {
        {
            type = "quest",
            id = 70941,
            comment = "Maybe after completing Grimtusk Hideaway side quest line?",
        },
    }
})
Database:AddChain(Chain.TempChain16, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    completed = {
        type = "quest",
        id = 66556,
    },
    items = {
        {
            type = "chain",
            id = Chain.TempChain11,
        },
        {
            type = "npc",
            id = 191123,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70627,
            x = 0,
            comment = "Breadcrumb to unrelated quests (66553, 66554)",
        },
    }
})
Database:AddChain(Chain.TempChain17, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    completed = {
        type = "quest",
        id = 66622,
    },
    items = {
        {
            type = "npc",
            id = 186755,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66622,
            x = 0,
        },
    }
})
Database:AddChain(Chain.TempChain18, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    completed = {
        type = "quest",
        id = 66556,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 71233,
                    restrictions = false,
                    comment = "Only breadcrumb to 66837",
                },
                {
                    type = "npc",
                    id = 190315,
                },
            },
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "npc",
            id = 190672,
            x = 2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 66837,
            x = -2,
            connections = {
                3, 4, 
            },
        },
        {
            type = "quest",
            id = 66838,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 66839,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 66840,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 66841,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66845,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66846,
            x = 0,
        },
    }
})
Database:AddChain(Chain.TempChain19, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    completed = {
        type = "quest",
        id = 66844,
    },
    items = {
        {
            type = "npc",
            id = 190892,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66844,
            x = 0,
        },
    }
})
Database:AddChain(Chain.TempChain21, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    completed = {
        type = "quest",
        id = 66843,
    },
    items = {
        {
            type = "npc",
            id = 190884,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66843,
            x = 0,
        },
    }
})
Database:AddChain(Chain.TempChain22, {
    name = { -- Sad Little Accidents
        type = "quest",
        id = 70168,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    prerequisites = {
        {
            type = "level",
            level = 64,
        },
        { -- ???
            type = "chain",
            id = Chain.DecayedRoots,
            upto = 65849,
        },
    },
    active = {
        type = "quest",
        id = 70166,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 70171,
    },
    items = {
        {
            type = "npc",
            id = 194415,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70166,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70168,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70169,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70170,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70171,
            x = 0,
        },
    }
})
Database:AddChain(Chain.TempChain23, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    completed = {
        type = "quest",
        id = 66503,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 69904,
                    restrictions = {
                        type = "quest",
                        id = 69904,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 189198,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66500,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66503,
            x = 0,
        },
    }
})
Database:AddChain(Chain.TempChain24, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    completed = {
        type = "quest",
        id = 66493,
    },
    items = {
        {
            type = "npc",
            id = 189208,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66523,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66493,
            x = 0,
        },
    }
})
Database:AddChain(Chain.TempChain25, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    completed = {
        type = "quest",
        id = 66556,
    },
    items = {
        {
            type = "chain",
            id = Chain.IntoTheArchives,
            upto = 67036,
        },
        {
            type = "quest",
            id = 66671,
            comment = "Breadcrumb to area, doesnt seem to lead to specific quest",
        },
    }
})
Database:AddChain(Chain.TempChain26, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    completed = {
        type = "quest",
        id = 66556,
    },
    items = {
        {
            type = "npc",
            id = 186568,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66217,
            x = 0,
        },
    }
})
Database:AddChain(Chain.TempChain27, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    completed = {
        type = "quest",
        id = 66556,
    },
    items = {
        {
            type = "npc",
            id = 186186,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66218,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66223,
            x = 0,
        },
    }
})
Database:AddChain(Chain.TempChain28, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    completed = {
        type = "quest",
        id = 66556,
    },
    items = {
        {
            type = "npc",
            id = 189533,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66558,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70129,
            x = 0,
        },
    }
})
Database:AddChain(Chain.TempChain29, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    completed = {
        type = "quest",
        id = 66556,
    },
    items = {
        {
            type = "npc",
            id = 186446,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66213,
            x = 0,
        },
    }
})
Database:AddChain(Chain.TempChain30, {
    name = BtWQuests.GetAreaName(13834), -- Camp Antonidas
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    prerequisites = {
        {
            type = "level",
            level = 64,
        },
        {
            type = "chain",
            id = Chain.IntoTheArchives,
            upto = 67036,
        },
    },
    active = {
        type = "quest",
        ids = {66488, 69904, 66500, 66523},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {66489, 66503, 66493},
        count = 3,
    },
    items = {
        {
            type = "chain",
            id = Chain.TempChain13,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.TempChain23,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.TempChain24,
            embed = true,
        },
    }
})
Database:AddChain(Chain.TempChain31, {
    name = BtWQuests.GetAreaName(13888), -- Three-Falls Lookout
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    prerequisites = {
        {
            type = "level",
            level = 64,
        },
    },
    active = {
        type = "quest",
        ids = {66843, 66844, 71233, 66837, 66838, 66839},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {66843, 66844, 66846},
        count = 3,
    },
    items = {
        {
            type = "chain",
            id = Chain.TempChain21,
            embed = true,
            x = -3,
        },
        {
            type = "chain",
            id = Chain.TempChain19,
            embed = true,
            x = -3,
        },
        {
            type = "chain",
            id = Chain.TempChain18,
            embed = true,
            x = 1,
            y = 0,
        },
    }
})
Database:AddChain(Chain.TempChain32, {
    name = BtWQuests.GetAreaName(13837), -- Iskaara
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    prerequisites = {
        {
            type = "level",
            level = 64,
        },
        {
            type = "chain",
            id = Chain.DecayedRoots,
            upto = 65849,
        },
    },
    active = {
        type = "quest",
        ids = {66218, 66558, 66213, 66217},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {66223, 70129, 66213, 66217},
        count = 4,
    },
    items = {
        {
            type = "chain",
            id = Chain.TempChain27,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.TempChain28,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.TempChain29,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.TempChain26,
            embed = true,
        },
    }
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
        { -- Stop the Spread -- Bonus Objective
            type = "quest",
            id = 65841,
        },
        { -- Fishing: Aileron Seamoth
            type = "quest",
            id = 66212,
        },
        { -- Hunting the Huntmaster
            type = "quest",
            id = 66939,
        },
        { -- Protect And Herd
            type = "quest",
            id = 66958,
        },
        { -- The Face of Death
            type = "quest",
            id = 66971,
        },
        { -- Drakes be Gone
            type = "quest",
            id = 67299,
        },
        { -- Blightfur
            type = "quest",
            id = 69858,
        },
        { -- Vakril, the Strongest Tuskarr
            type = "quest",
            id = 69872,
        },
        { -- Summoned Destroyer
            type = "quest",
            id = 69895,
        },
        { -- Fishing Frenzy!
            type = "quest",
            id = 69938,
        },
        { -- Brackenhide Mysteries
            type = "quest",
            id = 69942,
        },
        { -- Unpowered Tools
            type = "quest",
            id = 70037,
        },
        { -- For Imbu!
            type = "quest",
            id = 70064,
        },
        { -- Cobalt Catastrophe
            type = "quest",
            id = 70068,
        },
        { -- Gathering the Magic
            type = "quest",
            id = 70071,
        },
        { -- Mountain Mysteries
            type = "quest",
            id = 70172,
        },
        { -- Web Victims
            type = "quest",
            id = 70176,
        },
        { -- Cursed Creations
            type = "quest",
            id = 70625,
        },
        { -- Caught In a Dusk Storm
            type = "quest",
            id = 70787,
        },
        { -- Community Feast
            type = "quest",
            id = 70925,
        },
        { -- Wayward Archivists
            type = "quest",
            id = 71182,
        },
        { -- Attackin' the Brackenhide
            type = "quest",
            id = 71212,
        },
        { -- Falling Water
            type = "quest",
            id = 71233,
        },
    },
})

Database:AddCategory(CATEGORY_ID, {
    name = BtWQuests.GetMapName(MAP_ID),
    expansion = EXPANSION_ID,
    buttonImage = 4742829,
    items = {
        {
            type = "chain",
            id = Chain.IntoTheArchives,
        },
        {
            type = "chain",
            id = Chain.TuskarrTroubles,
        },
        {
            type = "chain",
            id = Chain.DecayedRoots,
        },
        {
            type = "chain",
            id = Chain.Vakthros,
        },
        {
            type = "chain",
            id = Chain.TempChain01,
        },
        {
            type = "chain",
            id = Chain.TempChain02,
        },
        {
            type = "chain",
            id = Chain.TempChain03,
        },
        {
            type = "chain",
            id = Chain.TempChain04,
        },
        {
            type = "chain",
            id = Chain.TempChain05,
        },
        {
            type = "chain",
            id = Chain.TempChain06,
        },
        {
            type = "chain",
            id = Chain.TempChain07,
        },
        {
            type = "chain",
            id = Chain.TempChain08,
        },
        {
            type = "chain",
            id = Chain.TempChain09,
        },
        {
            type = "chain",
            id = Chain.TempChain10,
        },
        {
            type = "chain",
            id = Chain.TempChain11,
        },
        {
            type = "chain",
            id = Chain.TempChain12,
        },
        {
            type = "chain",
            id = Chain.TempChain32,
        },
        {
            type = "chain",
            id = Chain.TempChain22,
        },
        {
            type = "chain",
            id = Chain.TempChain30,
        },
        {
            type = "chain",
            id = Chain.TempChain31,
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

Database:AddContinentItems(CONTINENT_ID, {
    {
        type = "chain",
        id = Chain.TempChain01,
    },
    {
        type = "chain",
        id = Chain.TempChain02,
    },
    {
        type = "chain",
        id = Chain.TempChain03,
    },
    {
        type = "chain",
        id = Chain.TempChain04,
    },
    {
        type = "chain",
        id = Chain.TempChain05,
    },
    {
        type = "chain",
        id = Chain.TempChain06,
    },
    {
        type = "chain",
        id = Chain.TempChain07,
    },
    {
        type = "chain",
        id = Chain.TempChain08,
    },
    {
        type = "chain",
        id = Chain.TempChain09,
    },
    {
        type = "chain",
        id = Chain.TempChain10,
    },
    {
        type = "chain",
        id = Chain.TempChain11,
    },
    {
        type = "chain",
        id = Chain.TempChain12,
    },
    {
        type = "chain",
        id = Chain.TempChain27,
    },
    {
        type = "chain",
        id = Chain.TempChain28,
    },
    {
        type = "chain",
        id = Chain.TempChain29,
    },
    {
        type = "chain",
        id = Chain.TempChain26,
    },
    {
        type = "chain",
        id = Chain.TempChain22,
    },
    {
        type = "chain",
        id = Chain.TempChain13,
    },
    {
        type = "chain",
        id = Chain.TempChain23,
    },
    {
        type = "chain",
        id = Chain.TempChain24,
    },
    {
        type = "chain",
        id = Chain.TempChain21,
    },
    {
        type = "chain",
        id = Chain.TempChain19,
    },
    {
        type = "chain",
        id = Chain.TempChain18,
    },
    {
        type = "chain",
        id = Chain.TempChain17,
    },
})
